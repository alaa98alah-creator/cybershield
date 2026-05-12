import { Hono } from 'hono'
import { hashPassword, verifyPassword, signJWT } from '../utils/auth'
import type { Bindings, Variables } from '../types'

const auth = new Hono<{ Bindings: Bindings; Variables: Variables }>()

auth.post('/register', async (c) => {
  const body = await c.req.json()
  const { first_name, last_name, username, email, phone, gender, date_of_birth, residence, password } = body

  if (!first_name || !last_name || !username || !email || !phone || !gender || !date_of_birth || !residence || !password) {
    return c.json({ error: 'All fields are required' }, 400)
  }
  if (password.length < 8) {
    return c.json({ error: 'Password must be at least 8 characters' }, 400)
  }
  if (!email.includes('@')) {
    return c.json({ error: 'Invalid email format' }, 400)
  }
  if (username.length < 3 || username.length > 30) {
    return c.json({ error: 'Username must be 3-30 characters' }, 400)
  }

  const db = c.env.DB
  const existing = await db
    .prepare('SELECT id FROM users WHERE email = ? OR username = ?')
    .bind(email, username)
    .first()

  if (existing) {
    return c.json({ error: 'Email or username already exists' }, 409)
  }

  const password_hash = await hashPassword(password)
  const userId = crypto.randomUUID()

  await db
    .prepare(
      `INSERT INTO users (id, first_name, last_name, username, email, phone, gender, date_of_birth, residence, password_hash)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`
    )
    .bind(userId, first_name, last_name, username, email, phone, gender, date_of_birth, residence, password_hash)
    .run()

  const token = await signJWT({ sub: userId, email }, c.env.JWT_SECRET)

  await c.env.KV.put(`session:${userId}`, token, { expirationTtl: 604800 })

  return c.json({
    token,
    user_id: userId,
    email,
    username,
  }, 201)
})

auth.post('/login', async (c) => {
  const body = await c.req.json()
  const { email, password } = body

  if (!email || !password) {
    return c.json({ error: 'Email and password are required' }, 400)
  }

  const db = c.env.DB
  const user: any = await db
    .prepare('SELECT id, email, username, password_hash FROM users WHERE email = ?')
    .bind(email)
    .first()

  if (!user) {
    return c.json({ error: 'Invalid email or password' }, 401)
  }

  const valid = await verifyPassword(password, user.password_hash)
  if (!valid) {
    return c.json({ error: 'Invalid email or password' }, 401)
  }

  const token = await signJWT({ sub: user.id, email: user.email }, c.env.JWT_SECRET)

  await c.env.KV.put(`session:${user.id}`, token, { expirationTtl: 604800 })

  return c.json({
    token,
    user_id: user.id,
    email: user.email,
    username: user.username,
  })
})

export const authRoutes = auth