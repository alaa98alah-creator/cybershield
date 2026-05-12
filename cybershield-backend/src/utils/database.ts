export interface Env {
  DB: D1Database
  KV: KVNamespace
  R2: R2Bucket
  JWT_SECRET: string
  VIRUSTOTAL_API_KEY: string
  GEMINI_API_KEY: string
}

export async function executeQuery<T = Record<string, unknown>>(
  db: D1Database,
  query: string,
  params: unknown[] = [],
): Promise<T[]> {
  const result = await db.prepare(query).bind(...params).run()
  return (result.results ?? []) as T[]
}

export async function executeFirst<T = Record<string, unknown>>(
  db: D1Database,
  query: string,
  params: unknown[] = [],
): Promise<T | null> {
  const result = await db.prepare(query).bind(...params).first()
  return result as T | null
}

export async function executeRun(
  db: D1Database,
  query: string,
  params: unknown[] = [],
): Promise<D1Result> {
  return db.prepare(query).bind(...params).run()
}