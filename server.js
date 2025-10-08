const express = require('express');
const path = require('path');

const app = express();

// Config
const PORT = process.env.PORT || 5500;
const APP_URL = `http://127.0.0.1:${PORT}`;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "public"))); // serves your existing assets

app.get('/users/:user', (req, res) => {
  res.sendFile(path.join(__dirname, "public", 'user.html'));
});

app.use((req, res) => {
  res.status(404).sendFile(path.join(__dirname, "public", '404.html'));
});

app.listen(PORT, () => {
  console.log(`Coco Website server initialized on ${APP_URL}`);
});
