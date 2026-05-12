export type Bindings = {
  DB: D1Database
  KV: KVNamespace
  JWT_SECRET: string
  VIRUSTOTAL_API_KEY: string
  GEMINI_API_KEY: string
}

export type Variables = {
  userId: string
  userEmail: string
}