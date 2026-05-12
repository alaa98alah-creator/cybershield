import { getUrlAnalysis, getFileReport } from './virusTotal'
import { analyzeWithGemini } from './gemini'
import type { Bindings } from '../types'

export async function processLinkScan(
  env: Bindings,
  scanId: string,
  targetUrl: string,
  analysisId: string,
) {
  try {
    await env.DB.prepare("UPDATE scans SET status = 'scanning' WHERE id = ?").bind(scanId).run()

    let vtResult = null
    for (let i = 0; i < 10; i++) {
      const analysis = await getUrlAnalysis(analysisId, env.VIRUSTOTAL_API_KEY)
      if (analysis.status === 'completed' && analysis.result) {
        vtResult = analysis.result
        break
      }
      if (analysis.status === 'failed') break
      await new Promise((r) => setTimeout(r, 15000))
    }

    if (!vtResult) {
      await env.DB.prepare("UPDATE scans SET status = 'failed' WHERE id = ?").bind(scanId).run()
      return
    }

    await env.DB.prepare(
      `INSERT INTO vt_results (id, scan_id, malicious_count, suspicious_count, harmless_count, undetected_count, vt_permalink, raw_json) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
    ).bind(
      crypto.randomUUID(), scanId,
      vtResult.malicious_count, vtResult.suspicious_count,
      vtResult.harmless_count, vtResult.undetected_count,
      vtResult.vt_permalink, vtResult.raw_json,
    ).run()

    const aiAnalysis = await analyzeWithGemini(
      targetUrl, 'link',
      {
        malicious: vtResult.malicious_count,
        suspicious: vtResult.suspicious_count,
        harmless: vtResult.harmless_count,
        undetected: vtResult.undetected_count,
        rawJson: vtResult.raw_json,
      },
      { GEMINI_API_KEY: env.GEMINI_API_KEY },
    )

    await env.DB.prepare(
      `INSERT INTO ai_analyses (id, scan_id, risk_level, simplified_summary, preventive_tips) VALUES (?, ?, ?, ?, ?)`,
    ).bind(
      crypto.randomUUID(), scanId,
      aiAnalysis.risk_level, aiAnalysis.simplified_summary,
      JSON.stringify(aiAnalysis.preventive_tips),
    ).run()

    await env.DB.prepare(
      "UPDATE scans SET status = 'completed', completed_at = datetime('now') WHERE id = ?",
    ).bind(scanId).run()
  } catch (error) {
    console.error(`Link scan ${scanId} failed:`, error)
    await env.DB.prepare("UPDATE scans SET status = 'failed' WHERE id = ?").bind(scanId).run()
  }
}

export async function processFileScan(
  env: Bindings,
  scanId: string,
  fileHash: string,
  fileName: string,
  analysisId: string,
) {
  try {
    await env.DB.prepare("UPDATE scans SET status = 'scanning' WHERE id = ?").bind(scanId).run()

    let vtResult = null
    for (let i = 0; i < 10; i++) {
      const analysis = await getUrlAnalysis(analysisId, env.VIRUSTOTAL_API_KEY)
      if (analysis.status === 'completed' && analysis.result) {
        vtResult = analysis.result
        break
      }
      if (analysis.status === 'failed') break
      await new Promise((r) => setTimeout(r, 15000))
    }

    if (!vtResult && fileHash) {
      vtResult = await getFileReport(fileHash, env.VIRUSTOTAL_API_KEY)
    }

    if (!vtResult) {
      await env.DB.prepare("UPDATE scans SET status = 'failed' WHERE id = ?").bind(scanId).run()
      return
    }

    await env.DB.prepare(
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
      { GEMINI_API_KEY: env.GEMINI_API_KEY },
    )

    await env.DB.prepare(
      `INSERT INTO ai_analyses (id, scan_id, risk_level, simplified_summary, preventive_tips) VALUES (?, ?, ?, ?, ?)`,
    ).bind(
      crypto.randomUUID(), scanId,
      aiAnalysis.risk_level, aiAnalysis.simplified_summary,
      JSON.stringify(aiAnalysis.preventive_tips),
    ).run()

    await env.DB.prepare(
      "UPDATE scans SET status = 'completed', completed_at = datetime('now') WHERE id = ?",
    ).bind(scanId).run()
  } catch (error) {
    console.error(`File scan ${scanId} failed:`, error)
    await env.DB.prepare("UPDATE scans SET status = 'failed' WHERE id = ?").bind(scanId).run()
  }
}