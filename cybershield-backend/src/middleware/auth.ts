import { Hono } from 'hono'
import type { Bindings, Variables } from '../types'
import { verify } from 'hono/jwt'

type AuthEnv = { Bindings: Bindings; Variables: Variables }

export const authMiddleware = async (c: import('hono').Context<AuthEnv>, next: import('hono').Next) => {
  const authHeader = c.req.header('Authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return c.json({ error: 'Unauthorized - missing token' }, 401)
  }

  const token = authHeader.substring(7)
  try {
    const payload = await verify(token, c.env.JWT_SECRET, 'HS256')
    c.set('userId', String(payload.sub))
    c.set('userEmail', String(payload.email))
    await next()
  } catch {
    return c.json({ error: 'Unauthorized - invalid token' }, 401)
  }
}

export const rateLimitMiddleware = async (c: import('hono').Context<{ Bindings: Bindings }>, next: import('hono').Next) => {
  const ip = c.req.header('cf-connecting-ip') || 'unknown'
  const key = `rate_limit:${ip}`
  const count = await c.env.KV.get(key)
  const currentCount = count ? parseInt(count) : 0

  if (currentCount >= 100) {
    return c.json({ error: 'Rate limit exceeded. Try again later.' }, 429)
  }

  await c.env.KV.put(key, String(currentCount + 1), { expirationTtl: 60 })
  await next()
}