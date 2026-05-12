import { Hono } from 'hono'
import type { Bindings, Variables } from '../types'
import { submitUrlScan, submitFileScan, getUrlAnalysis } from '../services/virusTotal'
import { analyzeWithGemini } from '../services/gemini'
import { verify } from 'hono/jwt'

type ScanEnv = { Bindings: Bindings; Variables: Variables }

const scan = new Hono<ScanEnv>()

scan.use('/*', async (c, next) => {
  const authHeader = c.req.header('Authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized - missing token', debug_has_header: !!authHeader }, 401)
  }
  const token = authHeader.substring(7)
  const secret = c.env.JWT_SECRET
  if (!secret) {
    return c.json({ error: 'Server config error - no secret' }, 500)
  }
  try {
    const payload = await verify(token, secret, 'HS256')
    if (!payload.sub || !payload.email) {
      return c.json({ error: 'Unauthorized - invalid payload' }, 401)
    }
    c.set('userId', String(payload.sub))
    c.set('userEmail', String(payload.email))
    await next()
  } catch (err) {
    console.error('JWT verify error:', String(err))
    return c.json({ error: 'Unauthorized - invalid token', debug: String(err) }, 401)
  }
})

scan.post('/link', async (c) => {
  const body = await c.req.json()
  const target_url = body.target_url
  if (!target_url) {
    return c.json({ error: 'target_url is required' }, 400)
  }
  try {
    new URL(target_url)
  } catch {
    return c.json({ error: 'Invalid URL format' }, 400)
  }

  const userId = c.get('userId')
  const db = c.env.DB
  const scanId = crypto.randomUUID()

  await db
    .prepare(
      `INSERT INTO scans (id, user_id, scan_type, target, status) VALUES (?, ?, 'link', ?, 'pending')`,
    )
    .bind(scanId, userId, target_url)
    .run()

  const analysisId = await submitUrlScan(target_url, c.env.VIRUSTOTAL_API_KEY)

  c.executionCtx.waitUntil(
    (async () => {
      try {
        await db.prepare("UPDATE scans SET status = 'scanning' WHERE id = ?").bind(scanId).run()

        let vtResult = null
        for (let i = 0; i < 10; i++) {
          const analysis = await getUrlAnalysis(analysisId, c.env.VIRUSTOTAL_API_KEY)
          if (analysis.status === 'completed' && analysis.result) {
            vtResult = analysis.result
            break
          }
          if (analysis.status === 'failed') break
          await new Promise((r) => setTimeout(r, 15000))
        }

        if (!vtResult) {
          await db.prepare("UPDATE scans SET status = 'failed' WHERE id = ?").bind(scanId).run()
          return
        }

        await db.prepare(
          `INSERT INTO vt_results (id, scan_id, malicious_count, suspicious_count, harmless_count, undetected_count, vt_permalink, raw_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        ).bind(
          crypto.randomUUID(), scanId,
          vtResult.malicious_count, vtResult.suspicious_count,
          vtResult.harmless_count, vtResult.undetected_count,
          vtResult.vt_permalink, vtResult.raw_json,
        ).run()

        const aiAnalysis = await analyzeWithGemini(
          target_url, 'link',
          {
            malicious: vtResult.malicious_count,
            suspicious: vtResult.suspicious_count,
            harmless: vtResult.harmless_count,
            undetected: vtResult.undetected_count,
            rawJson: vtResult.raw_json,
          },
          { GEMINI_API_KEY: c.env.GEMINI_API_KEY },
        )

        await db.prepare(
          `INSERT INTO ai_analyses (id, scan_id, risk_level, simplified_summary, preventive_tips) VALUES (?, ?, ?, ?, ?)`,
        ).bind(
          crypto.randomUUID(), scanId,
          aiAnalysis.risk_level, aiAnalysis.simplified_summary,
          JSON.stringify(aiAnalysis.preventive_tips),
        ).run()

        await db.prepare(
          "UPDATE scans SET status = 'completed', completed_at = datetime('now') WHERE id = ?",
        ).bind(scanId).run()
      } catch (error) {
        console.error(`Link scan ${scanId} failed:`, error)
        await db.prepare("UPDATE scans SET status = 'failed' WHERE id = ?").bind(scanId).run()
      }
    })(),
  )

  return c.json({ scan_id: scanId, status: 'pending' }, 201)
})

scan.post('/file', async (c) => {
  const userId = c.get('userId')
  const formData = await c.req.formData()
  const file = formData.get('file') as File | null
  if (!file) {
    return c.json({ error: 'No file uploaded' }, 400)
  }
  if (file.size > 32 * 1024 * 1024) {
    return c.json({ error: 'File exceeds 32MB limit' }, 400)
  }

  const allowedExts = /\.(pdf|zip|exe|doc|docx|xls|xlsx|ppt|pptx)$/i
  if (!allowedExts.test(file.name)) {
    return c.json({ error: 'File type not supported' }, 400)
  }

  const db = c.env.DB
  const fileName = file.name
  const scanId = crypto.randomUUID()

  await db
    .prepare(
      `INSERT INTO scans (id, user_id, scan_type, target, status) VALUES (?, ?, 'file', ?, 'pending')`,
    )
    .bind(scanId, userId, fileName)
    .run()

  await db.prepare(
    `INSERT INTO files_metadata (id, scan_id, file_name, mime_type, size_bytes) VALUES (?, ?, ?, ?, ?)`,
  ).bind(crypto.randomUUID(), scanId, fileName, file.type, file.size).run()

  const fileBuffer = await file.arrayBuffer()

  const analysisId = await submitFileScan(fileBuffer, fileName, c.env.VIRUSTOTAL_API_KEY)

  c.executionCtx.waitUntil(
    (async () => {
      try {
        await db.prepare("UPDATE scans SET status = 'scanning' WHERE id = ?").bind(scanId).run()

        let vtResult = null
        for (let i = 0; i < 10; i++) {
          const analysis = await getUrlAnalysis(analysisId, c.env.VIRUSTOTAL_API_KEY)
          if (analysis.status === 'completed' && analysis.result) {
            vtResult = analysis.result
            break
          }
          if (analysis.status === 'failed') break
          await new Promise((r) => setTimeout(r, 15000))
        }

        if (!vtResult) {
          await db.prepare("UPDATE scans SET status = 'failed' WHERE id = ?").bind(scanId).run()
          return
        }

        await db.prepare(
          `INSERT INTO vt_results (id, scan_id, malicious_count, suspicious_count, harmless_count, undetected_count, vt_permalink, raw_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        ).bind(
          crypto.randomUUID(), scanId,
          vtResult.malicious_count, vtResult.suspicious_count,
          vtResult.harmless_count, vtResult.undetected_count,
          vtResult.vt_permalink, vtResult.raw_json,
        ).run()

        const aiAnalysis = await analyzeWithGemini(
          fileName, 'file',
          {
            malicious: vtResult.malicious_count,
            suspicious: vtResult.suspicious_count,
            harmless: vtResult.harmless_count,
            undetected: vtResult.undetected_count,
            rawJson: vtResult.raw_json,
          },
          { GEMINI_API_KEY: c.env.GEMINI_API_KEY },
        )

        await db.prepare(
          `INSERT INTO ai_analyses (id, scan_id, risk_level, simplified_summary, preventive_tips) VALUES (?, ?, ?, ?, ?)`,
        ).bind(
          crypto.randomUUID(), scanId,
          aiAnalysis.risk_level, aiAnalysis.simplified_summary,
          JSON.stringify(aiAnalysis.preventive_tips),
        ).run()

        await db.prepare(
          "UPDATE scans SET status = 'completed', completed_at = datetime('now') WHERE id = ?",
        ).bind(scanId).run()
      } catch (error) {
        console.error(`File scan ${scanId} failed:`, error)
        await db.prepare("UPDATE scans SET status = 'failed' WHERE id = ?").bind(scanId).run()
      }
    })(),
  )

  return c.json({ scan_id: scanId, status: 'pending' }, 201)
})

scan.get('/result/:scanId', async (c) => {
  const userId = c.get('userId')
  const scanId = c.req.param('scanId')
  const db = c.env.DB

  const scan: any = await db
    .prepare('SELECT * FROM scans WHERE id = ? AND user_id = ?')
    .bind(scanId, userId)
    .first()

  if (!scan) {
    return c.json({ error: 'Scan not found' }, 404)
  }

  const response: Record<string, unknown> = {
    scan_id: scan.id,
    scan_type: scan.scan_type,
    target: scan.target,
    status: scan.status,
    created_at: scan.created_at,
    completed_at: scan.completed_at,
  }

  if (scan.status === 'completed' || scan.status === 'failed') {
    const vtResult: any = await db
      .prepare('SELECT * FROM vt_results WHERE scan_id = ?')
      .bind(scanId)
      .first()

    if (vtResult) {
      response.vt_result = {
        malicious_count: vtResult.malicious_count,
        suspicious_count: vtResult.suspicious_count,
        harmless_count: vtResult.harmless_count,
        undetected_count: vtResult.undetected_count,
        vt_permalink: vtResult.vt_permalink,
        raw_json: vtResult.raw_json ? JSON.parse(vtResult.raw_json) : null,
      }
    }

    const aiAnalysis: any = await db
      .prepare('SELECT * FROM ai_analyses WHERE scan_id = ?')
      .bind(scanId)
      .first()

    if (aiAnalysis) {
      response.ai_analysis = {
        risk_level: aiAnalysis.risk_level,
        simplified_summary: aiAnalysis.simplified_summary,
        preventive_tips: aiAnalysis.preventive_tips
          ? JSON.parse(aiAnalysis.preventive_tips)
          : [],
      }
    }
  }

  return c.json(response)
})

export const scanRoutes = scan