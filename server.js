const express = require('express');
const path = require('path');

const app = express();

// Config
const PORT = process.env.PORT || 5500;
const APP_URL = `http://127.0.0.1:${PORT}`;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "public"))); // serves existing assets

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

  const user = {
    name: "user",
    age: 15,
    birthday: {
      date: "3/31/2010", 
      month: {
        text: "march",
        num: "3"
      },
      day: "31",
      year: "2010"
    },
    description: `Hello, I'm Nino (Jose).`,
    //role: "admin"
  };

app.get("", (req, res) => {
  res.render('home', {user: user});
})

app.get("/", (req, res) => {
  res.render('home', {user: user});
})

app.get('/users/:user', (req, res) => {
  res.render('user', { username: req.params.user, color: 'blue' });
});

app.use((req, res) => {
  res.status(404).sendFile(path.join(__dirname, "public", '404.html'));
});

app.listen(PORT, () => {
  console.log(`Coco Website server initialized on ${APP_URL}`);
});
