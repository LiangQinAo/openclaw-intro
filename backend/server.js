import express from 'express'
import path from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const port = process.env.PORT || 3000

app.get('/api/health', (_req, res) => {
  res.json({ ok: true, ts: Date.now() })
})

app.get('/api/info', (_req, res) => {
  res.json({
    name: 'OpenClaw Demo',
    what: 'Vue + Node.js 简介页',
    links: {
      docs: 'https://docs.openclaw.ai',
      github: 'https://github.com/openclaw/openclaw'
    }
  })
})

const publicDir = path.join(__dirname, 'public')
app.use(express.static(publicDir))

// SPA fallback
app.get('*', (req, res) => {
  res.sendFile(path.join(publicDir, 'index.html'))
})

app.listen(port, () => {
  console.log(`[openclaw-intro] listening on :${port}`)
})
