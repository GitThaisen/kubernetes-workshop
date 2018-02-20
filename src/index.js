const express = require('express')
const app = express()

app.get('/', (req, res) => res.send('Hello World!'))

// The liveness probe defined in `.kubernetes/deployment.yaml` expects that
// your application provides a `GET /health` endpoint which returns `200 OK`.
app.get('/health', (req, res) => res.send('OK'))
app.listen(8090, () => console.log('Listening on port 8090'))
