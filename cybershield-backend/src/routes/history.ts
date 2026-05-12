import { Hono } from 'hono'
import type { Bindings, Variables } from '../types'
import { verify } from 'hono/jwt'

type HistoryEnv = { Bindings: Bindings; Variables: Variables }

const history = new Hono<HistoryEnv>()

history.use('/*', async (c, next) => {
  const authHeader = c.req.header('Authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized' }, 401)
  }
  const token = authHeader.substring(7)
  try {
    const payload = await verify(token, c.env.JWT_SECRET, 'HS256')
    c.set('userId', String(payload.sub))
    c.set('userEmail', String(payload.email))
    await next()
  } catch {
    return c.json({ error: 'Unauthorized' }, 401)
  }
})

history.get('/history', async (c) => {
  const userId = c.get('userId')
  const db = c.env.DB

  const { results } = await db
    .prepare(
      `SELECT s.id, s.scan_type, s.target, s.status, s.created_at, s.completed_at,
              a.risk_level
       FROM scans s
       LEFT JOIN ai_analyses a ON a.scan_id = s.id
       WHERE s.user_id = ?
       ORDER BY s.created_at DESC
       LIMIT 100`,
    )
    .bind(userId)
    .all()

  return c.json({ scans: results, total: results.length })
})

export const historyRoutes = history