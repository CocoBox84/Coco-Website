const express = require('express');
const path = require('path');
const fs = require("fs");
const fsp = require("fs/promises");
const { json } = require('stream/consumers');
const { NONAME } = require('dns');
const { render } = require('ejs');
const session = require('express-session');
const bcrypt = require('bcryptjs');
const db = require('./backend/db');
const multer = require('multer');
const { exec } = require('child_process');
const upload = multer({ dest: 'uploads/' });

const app = express();

// Config
const PORT = process.env.PORT || 5500;
const APP_URL = `http://127.0.0.1:${PORT}`;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "public"))); // serves existing assets

// Sessions (in-memory - OK for dev; for production use a store)
app.use(session({
  secret: process.env.SESSION_SECRET || 'dev-secret-change-me',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 1000 * 60 * 60 * 24 } // 1 day
}));

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Helper functions

const os = { path: path } // Use as a fallback. I got used to python's "os.path" so use both

const util = {
  findUserById: (id) => {
    const users = JSON.parse(fs.readFileSync(os.path.join(__dirname, "users.json")));
    return users.find(user => user.id === id);
  },
  findUserByName: (name) => {
    const users = JSON.parse(fs.readFileSync(os.path.join(__dirname, "users.json")));
    return users.find(user => user.username === name);
  }
}

function findProjectID(username, projectName) {
  const user = util.findUserByName(username);
  if (!user || (user.isPublic == false && (user.username === username))) {
    return NaN;
  };
  try {
    const project = JSON.parse(fs.readFileSync(os.path.join(__dirname, "users", username, projects, projectName, "project.json")));
    if (project == {} || !project || (!project.isShared && project.creator != username)) return NaN;
    return project.id;
  } catch (e) {
    return NaN;
  }
}

function getProjectById(id) {
  if (id === NaN) return undefined;
  try {
    const project = JSON.parse(fs.readFileSync(os.path.join(__dirname, "projects", id, "project.json")));
    if (project.isShared) return project;
  } catch (e) {
  }

  return {};
}

/**const user = {name: null}/* */

/**
const user = {
  name: "Nino",
  age: 15,
  birthday: {
    date: "3/31/2010",
    month: {
      text: "march",
      num: "3"
    },
    day: "31",
    year: "2010",
  },
  id: 1,
  description: `Hello, I'm Nino (Jose).`,
  role: "admin",
  isPublic: true,
  projects: ["Coco", "Steamworks"],
};/**/

const products = [{
  name: "Welcome to Coco!",
  id: 1,
  description: `Description here.`,
  imgs: [{ src: "/movingApi/news/images/Coco The Coconut.png", width: 100, height: 120, styles: ``, alt: "Coco The Coconut" }],
  img: { src: "/movingApi/news/images/Coco The Coconut.png", width: 100, height: 120, styles: ``, alt: "Coco The Coconut" },
  media_type: "video",
  video: { src: "/Videos/Movie on 9-4-24 at 5.34 PM.mov" },
  media_description: `About the download`,
  icon: { src: "/Coco.svg", width: 100, height: 120, styles: ``, alt: "Coco Logo" },
  creator: { username: "Coco" },
  date: {
    month: 11,
    day: 6,
    year: 2025,
  },
  metadata: {
    downloads: 0,
  }
},
{
  name: "Welcome to Coco!",
  id: 1,
  description: `<p>So you decided to Drop by!\n<br>
  Want to see what i've been working on? Click <a href="previews/Coco">here</a> for a preview!</p>`,
  imgs: [{ src: "/movingApi/news/images/Coco The Coconut.png", width: 100, height: 120, styles: ``, alt: "Coco The Coconut" }],
  img: { src: "/movingApi/news/images/Coco The Coconut.png", width: 100, height: 120, styles: ``, alt: "Coco The Coconut" },
  media_type: "video",
  video: { src: "/Videos/Movie on 9-4-24 at 5.34 PM.mov" },
  media_description: `Welcome! The site is still new if this is the first news box that you see.`,
  icon: { src: "/Coco.svg", width: 100, height: 120, styles: ``, alt: "Coco Logo" },
  creator: { username: "Coco" },
  date: {
    month: 11,
    day: 6,
    year: 2025,
  },
}];

const news = [{
  name: "Welcome to Coco!",
  id: 1,
  description: `<p>So you decided to Drop by!\n<br>
  Want to see what i've been working on? Click <a href="previews/Coco">here</a> for a preview!</p>`,
  imgs: [{ src: "/movingApi/news/images/Coco The Coconut.png", width: 100, height: 120, styles: ``, alt: "Coco The Coconut" }],
  img: { src: "/movingApi/news/images/Coco The Coconut.png", width: 100, height: 120, styles: ``, alt: "Coco The Coconut" },
  media_type: "video",
  video: { src: "/Videos/Movie on 9-4-24 at 5.34 PM.mov" },
  media_description: `Welcome! The site is still new if this is the first news box that you see.`,
  icon: { src: "/Coco Icon/Old Coco Icon.svg", width: 100, height: 120, styles: ``, alt: "Coco The Coconut" },
  //...
}];

app.get("", (req, res) => {
  // attach session user to template if available
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  res.render('home', { user: sessionUser || user, products: products, news: news });
})

app.get("/index.html", (req, res) => {
  res.redirect("/");
});

app.get("/messages/", (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  res.render('messages', { user: sessionUser || user, products: products, news: news });
});

app.get("/user/messages/", (req, res) => {
  return req
});

app.get('/users/:user', (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  res.render('user', { username: req.params.user, color: 'blue', currentUser: sessionUser });
});

app.get("/faq", (req, res) => {
  // attach session user to template if available
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  res.render('faq', { user: sessionUser || user, products: products, news: news });
})

// --- Auth routes ---
app.get('/register', (req, res) => {
  res.render('register');
});

app.post('/register', async (req, res) => {
  const { username, email, password } = req.body;
  if (!username || !password) return res.status(400).send('username and password required');
  try {
    const existing = db.getUserByUsername(username);
    if (existing) return res.status(400).send('username taken');
    const hash = await bcrypt.hash(password, 10);
    const id = db.createUser(username, email || null, hash);
    req.session.userId = id;
    res.redirect('/');
  } catch (e) {
    console.error(e);
    res.status(500).send('error creating user');
  }
});

app.get('/login', (req, res) => {
  res.render('login');
});

app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) return res.status(400).send('username and password required');
  try {
    const userRecord = db.getUserByUsername(username);
    if (!userRecord) return res.status(400).send('invalid credentials');
    const ok = await bcrypt.compare(password, userRecord.passwordHash);
    if (!ok) return res.status(400).send('invalid credentials');
    req.session.userId = userRecord.id;
    res.redirect('/');
  } catch (e) {
    console.error(e);
    res.status(500).send('error logging in');
  }
});

app.post('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/');
  });
});

app.post("/api/user/messages", (req, res) => {
  const messages = [
    {"sender": "System", "title": "The First Message!", "content": "Hello! This is the first message! <br> So, yeah. Not much more to say other then that."}
    ,{"sender": "Admin", "title": "Welcome to Coco!", "content": "Welcome to the Coco Website! We hope you enjoy your stay here. <br> If you have any questions, feel free to reach out to us!"}
    ,{"sender": "Nino", "title": "Site Updates", "content": "Hey! Just wanted to let you know that we have some new updates coming soon! <br> Stay tuned for more info."}
    ,{"sender": "System", "title": "Maintenance Notice", "content": "The site will be undergoing maintenance on Saturday at 2 AM UTC. <br> Please plan accordingly."}
    ,{"sender": "Admin", "title": "New Features!", "content": "We have added some new features to the site! <br> Check them out and let us know what you think!"}
    ,{"sender": "Nino", "title": "Community Guidelines", "content": "Please remember to follow our community guidelines while using the site. <br> Let's keep it a friendly place for everyone!"}
    ,{"sender": "System", "title": "Password Reset", "content": "If you have requested a password reset, please check your email for instructions. <br> If you did not request this, please ignore this message."}
    ,{"sender": "System", "title": "Test", "content": "You should only be seeing this message after the 5th load messages click."}
  ];
  const messageIndex = req.body.start || 0;
  const numberOfMessagesToSend = 5;
  //const numberOfMessagesToSend = req.body.count;
  const messagesToSend = [];
  for (let i = messageIndex; i < numberOfMessagesToSend; i++) {
    messagesToSend.push(messages[i]);
    if (i >= messages.length) break;
  }
  return res.json({messages: messagesToSend});
});

app.get("/previews/Coco", (req, res) => {
    // attach session user to template if available
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : false;
  res.render('Steamworks', { user: sessionUser });
});

app.get("/downloads/", (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : false;
  res.render('downloads', { user: sessionUser, products });
});

app.get("/:user/projects/:projectname", (req, res) => {
  const id = findProjectID(req.params.user, req.params.projectname);
  const project = getProjectById(id);
  res.render("project", { project });
});

/* Every thing after will be a 404! */

app.use((req, res) => {
  // attach session user to template if available
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  res.status(404).render('404', { user: sessionUser || user, products: products, news: news });
});

/* Streaming video helper */

// Upload and process video
app.post('/uploadVideo', upload.single('video'), (req, res) => {
  const input = req.file.path;
  const output = `processed/videos/${req.file.filename}.m3u8`;

  // Transcode to HLS using FFmpeg
  exec(`ffmpeg -i ${input} -profile:v baseline -level 3.0 -start_number 0 \
    -hls_time 10 -hls_list_size 0 -f hls ${output}`, (err) => {
    if (err) return res.status(500).send('Error processing video');
    res.send('Video uploaded and processed!');
  });
});


app.get('/files/processed/:filename', (req, res) => {
  const filePath = path.join(__dirname, 'processed', "videos", req.params.filename);
  res.sendFile(filePath);
});

// Initialize DB then start server
db.init().then(() => {
  app.listen(PORT, () => {
    console.log(`Coco Website server initialized on ${APP_URL}`);
  });
}).catch(err => {
  console.error('Failed to initialize database', err);
  process.exit(1);
});