const express = require('express');
const app = express();
const PORT = 8080;
const cors = require('cors');
const webhookURL = 'https://discord.com/api/webhooks/1416219915936989304/LuhVMyQo4ngb8tYnK6yTThxFT9n_ISdcoNlZYXPU3Kj4d52FcM0y9gTlEsXmaXzLF4k9';
console.log('starting server...');

app.use((req, res, next) => {
  console.log(`Request received: ${req.method} ${req.originalUrl}`);
  next();
});

app.use(cors());
app.use(express.json());
app.use(async (req, res, next) => {
  const ip =
    req.headers['x-forwarded-for']?.split(',')[0] ||
    req.socket.remoteAddress;
  const userAgent = req.headers['user-agent'] || 'Unknown';
  const timestamp = new Date().toLocaleString('en-US', { timeZone: 'UTC' });

  // Optional: Only log once per session or path
  if (!req.path.includes('/favicon.ico')) {
    try {
      await fetch(webhookURL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          content: `🌐 **Proxy Site Visited**

**IP:** \`${ip}\`
**Time (UTC):** ${timestamp}
**Device/Browser:** \`${userAgent}\`
**Path:** \`${req.path}\``
        })
      });
    } catch (err) {
      console.error('', err);
    }
  }

  next();
});

app.get('*', (req, res) => {
  console.log(`Handling GET ${req.originalUrl}`);
  res.send('hi world');
});

app.listen(PORT, () => {
  console.log(`${PORT}`);
});
