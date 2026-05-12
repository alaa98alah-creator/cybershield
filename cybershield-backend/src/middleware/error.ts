export async function errorHandler(err: Error, c: any) {
  console.error('Server error:', err.message)
  console.error(err.stack)
  return c.json({ error: 'Internal Server Error', message: err.message, stack: err.stack?.split('\n')[0] }, 500)
}