const express = require('express');
const app = express();
const PORT = 8080;

console.log('starting server...');

app.use((req, res, next) => {
  console.log(`Request received: ${req.method} ${req.originalUrl}`);
  next();
});

app.get('*', (req, res) => {
  console.log(`Handling GET ${req.originalUrl}`);
  res.send('hi world');
});

app.listen(PORT, () => {
  console.log(`${PORT}`);
});
