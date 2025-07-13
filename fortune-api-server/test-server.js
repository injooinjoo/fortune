const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.get('/health', (req, res) => {
  res.json({ status: 'ok', port: PORT });
});

app.get('/', (req, res) => {
  res.send('Fortune API Server - Test Version');
});

app.listen(PORT, () => {
  console.log(`Test server running on port ${PORT}`);
});