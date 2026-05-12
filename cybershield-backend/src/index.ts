import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import type { Bindings } from './types'
import { authRoutes } from './routes/auth'
import { scanRoutes } from './routes/scan'
import { historyRoutes } from './routes/history'
import { errorHandler } from './middleware/error'

type AppType = { Bindings: Bindings }

const app = new Hono<AppType>()

app.use('*', logger())
app.use(
  '*',
  cors({
    origin: ['*'],
    allowMethods: ['GET', 'POST', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization'],
    maxAge: 600,
    credentials: true,
  }),
)

app.get('/', (c) =>
  c.json({
    name: 'CyberShield API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      auth: { login: 'POST /auth/login', register: 'POST /auth/register' },
      scans: {
        link: 'POST /scans/link',
        file: 'POST /scans/file',
        result: 'GET /scans/result/:scanId',
      },
      history: 'GET /scans/history',
    },
  }),
)

app.route('/auth', authRoutes)
app.route('/scans', scanRoutes)
app.route('/scans', historyRoutes)

app.notFound((c) => c.json({ error: 'Not Found' }, 404))
app.onError(errorHandler)

export default app