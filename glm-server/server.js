require('dotenv').config()
const express = require('express')
const axios = require('axios')
const cors = require('cors')

const app = express()

app.use(cors())
app.use((req, res, next) => {
  console.log(`>>> 收到新请求: ${req.method} ${req.url}`);
  next();
});
app.use(express.json({ limit: '1mb' }))


const PORT = 3000
const MODEL_URL = 'https://open.bigmodel.cn/api/paas/v4/chat/completions'
const API_KEY = process.env.API_KEY

if (!API_KEY) {
  console.error('未检测到 API_KEY，请在 .env 中配置')
  process.exit(1)
}

const requestMap = new Map()
const WINDOW_TIME = 60 * 1000
const MAX_REQUEST = 20

function rateLimit(ip) {
  const now = Date.now()

  if (!requestMap.has(ip)) {
    requestMap.set(ip, [])
  }

  const timestamps = requestMap
    .get(ip)
    .filter(t => now - t < WINDOW_TIME)

  timestamps.push(now)
  requestMap.set(ip, timestamps)

  return timestamps.length <= MAX_REQUEST
}

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: Date.now()
  })
})

app.post('/api/chat', async (req, res) => {

  const ip = req.ip || req.connection.remoteAddress

  console.log('\n==============================')
  console.log('[请求时间]', new Date().toLocaleString())
  console.log('[请求IP]', ip)

  if (!rateLimit(ip)) {
    console.log('[限流触发]')
    return res.status(429).json({
      error: 'Too many requests'
    })
  }

  const { messages } = req.body

  if (!messages || !Array.isArray(messages)) {
    return res.status(400).json({
      error: 'messages format invalid'
    })
  }

  try {

    const response = await axios.post(
      MODEL_URL,
      {
        model: "glm-4.7",
        messages: messages,
        thinking: { type: "disabled" },
        temperature: 0.6,
        max_tokens: 512
      },
      {
        headers: {
          Authorization: `Bearer ${API_KEY}`,
          'Content-Type': 'application/json'
        },
        timeout: 15000
      }
    )

    console.log('[模型调用成功]')
    console.log('[token usage]', response.data.usage)

    res.json(response.data)

  } catch (err) {

    console.error('[模型调用失败]')
    console.error(err.response?.data || err.message)

    res.status(500).json({
      error: 'Model request failed'
    })
  }
})

app.listen(PORT, '0.0.0.0', () => {
  console.log(`服务已启动！`);
  console.log(`请确保手机访问的是: http://192.168.10.107:${PORT}/api/chat`);
});
