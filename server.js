const express = require('express');
const path = require('path');
const fs = require("fs");
const fsp = require("fs/promises");
const { json } = require('stream/consumers');
const { NONAME } = require('dns');

const { render } = require('ejs');
const session = require('express-session');
const FileStore = require('session-file-store')(session);
const bcrypt = require('bcryptjs');
const db = require('./backend/db');
const multer = require('multer');
const { exec } = require('child_process');
const { Amp } = require('./@');
const upload = multer({ storage: multer.memoryStorage() });

const app = express();

// Config
const PORT = process.env.PORT || 5500;
const HOST = '0.0.0.0'; // listen on all network interfaces
const APP_URL = `http://${HOST}:${PORT}`;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, "public"))); // serves existing assets
// Sessions (in-memory - OK for dev; for production use a store)
// Initialize session BEFORE routes/static so handlers can read/write session and cookie is set correctly.
app.use(session({
  store: new FileStore({
    path: path.join(__dirname, 'sessions'),
    retries: 1,
    // ttl in seconds
    ttl: 60 * 60 * 24
  }),
  secret: process.env.SESSION_SECRET || 'dev-secret-change-me',
  resave: false,
  saveUninitialized: false,
  cookie: { maxAge: 1000 * 60 * 60 * 24, sameSite: 'lax' } // 1 day
}));

// NOTE: removed stray `app.use(express.Router())` which can interfere with middleware ordering

/**
 * Error handler (handles 403, 405, 500, etc.)
 * Make sure this is the LAST middleware
 */
app.use((err, req, res, next) => {
  const status = err.status || 500;

  // Optionally log
  if (status >= 500) {
    console.error(err);
  }

  // Render a specific view per status if you prefer
  switch (status) {
    case 403:
      return res.status(403).render('403', { message: err.message });
    case 404:
      return res.status(404).render('404', { url: req.originalUrl });
    case 405:
      // You can add Allow header listing supported methods if you want
      res.set('Allow', 'GET, POST'); // example
      return res.status(405).render('405', { method: req.method });
    default:
      // 500 and other unexpected errors
      return res.status(status).render('500', {
        message: err.message,
        // In production, avoid leaking stack traces
        stack: req.app.get('env') === 'development' ? err.stack : undefined
      });
  }
});

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Helper functions

const os = { path: path } // Use as a fallback. I got used to python's "os.path" so use both

const tools = {
  generateRandomString: function (myLength) {
    const chars =
      "AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890";
    const randomArray = Array.from(
      { length: myLength },
      (v, k) => chars[Math.floor(Math.random() * chars.length)]
    );

    const randomString = randomArray.join("");
    return randomString;
  }
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
}/*, {
  name: "Sticker Update!",
  id: 2,
  description: `<p>Today I have added a new feature! Stickers!<br>
  Want to use them?  Click <a href="/projects/Coco/0/">here</a>.</p>`,
  imgs: [{ src: "/Stickers/Sticker Face.stikr", width: 100, height: 120, styles: ``, alt: "Sticker Face" }],
  img: { src: "/Stickers/Sticker Face.stikr", width: 100, height: 120, styles: ``, alt: "Sticker Face" },
  media_type: "image",
  video: { src: "/Videos/Movie on 9-4-24 at 5.34 PM.mov" },
  media_description: `Welcome! The site is still new if this is the first news box that you see.`,
  icon: { src: "/Stickers/Sticker Face.stikr", width: 100, height: 120, styles: ``, alt: "Sticker Sally" },
  //...
  
}*/];

app.get("", (req, res) => {
  // attach session user to template if available
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  res.render('home', { user: sessionUser, products: products, news: news });
})

app.get("/index.html", (req, res) => {
  res.redirect("/");
});

app.get("/messages/", (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  if (!sessionUser) return res.status(300).redirect("/");
  res.render('messages', { user: sessionUser });
});

app.get('/users/:user', (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  let isEditable = false;
  if (!db.getUserByUsername(req.params.user)) return res.redirect("/noUser/"); // this will be a 404 page.
  console.log("User is private: ", db.getUserByUsername(req.params.user).isPrivate);
  if ((!sessionUser || sessionUser.username !== req.params.user) && db.getUserByUsername(req.params.user).isPrivate === 1) {
    return res.status(405).send("Not your profile. Weirdo. This profile has been privated.");
  }
  if (sessionUser && sessionUser.username === req.params.user) isEditable = true;
  const following = db.getFollowing(db.getUserByUsername(req.params.user).id);
  const followers = db.getFollowers(db.getUserByUsername(req.params.user).id);
  res.render('user', { username: req.params.user, user: sessionUser, isEditable, user2: db.getUserByUsername(req.params.user), following, followers });
});

app.get("/manage", (req, res) => {
  return res.status(302).redirect("/account/users/manage/");
});

app.get("/account/users/manage", (req, res) => {
  if (!req.session.userId) return res.status(302).redirect("/");
  const sessionUser = (req.session.userId) ? db.getUserById(req.session.userId) : null;
  return res.status(200).render("manage_user", { user: sessionUser });
});

app.get("/users/:username/pfp", async (req, res) => {
  await db.init();
  const user = db.getUserByUsername(req.params.username);
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;

  // Only check username if sessionUser exists
  if (sessionUser && sessionUser.username !== req.params.username) {
    if (user && user.isPrivate === 1) {
      return res.status(404).sendFile(path.join(__dirname, "public", "Coco Icon", "Coco The Coconut.png"));
    }
  }

  if (!user || !user.pfp) {
    return res.status(404).sendFile(path.join(__dirname, "public", "Coco Icon", "Coco The Coconut.png"));
  }

  const filePath = path.resolve(user.pfp);

  if (!fs.existsSync(filePath)) {
    return res.status(404).sendFile(path.join(__dirname, "public", "Coco Icon", "Coco The Coconut.png"));
  }

  res.sendFile(filePath);
});

app.post("/users/:username/changePfp", upload.single("pfp"), (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  if (!sessionUser || sessionUser.username !== req.params.username) {
    return res.status(405).send("Not your profile. Weirdo.");
  }

  if (!req.file) {
    return res.status(400).send("No file uploaded.");
  }

  const ext = path.extname(req.file.originalname).toLowerCase();
  const allowed = [".png", ".jpg", ".jpeg", ".gif"];
  if (!allowed.includes(ext)) {
    return res.status(400).send("Invalid file type.");
  }

  const pfpPath = path.join(__dirname, "private", "users", req.params.username, "pfp");
  fs.mkdirSync(pfpPath, { recursive: true });

  const filePath = path.join(pfpPath, `pfp${ext}`);
  fs.writeFileSync(filePath, req.file.buffer);

  // 🔗 Update the database record
  db.updateUserPfp(sessionUser.id, filePath);

  return res.send("Profile picture updated.");
});

app.get('/users/:username/changePfp', (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  console.log(sessionUser);
  if (!sessionUser || sessionUser.username != req.params.username) return res.status(405).send("Not your profile. Weirdo.");

  return res.send("Ok");
});

// CocoScript Tutorial (Original):

/*
// Welcome to CocoScript!

// Very likely that you have never used
// it before. Let me show you!
//// Comments ////
// First, comments. comments are pieces of "code"
// that don't run, like this text that 
// you are reading right now, 
// it is a comment. Comments can be
// used for taking notes, or saving code for later.
// to type a comment, type "//" 
// and everything after it on
// the line will be ignored.

//// Output ////

// One of the most important things 
// about coding is output.
// So you can see your progress
// and keep track of variables.

// Note: Other users, cannot see your
// output, it's just for testing

// Here is a simple output program:
diplay("Coco!");
// No, that's not a typ0 it's diplay not display
// You can also output your username
diplay(username); // This output's the name of the user currently 
// on your page, so it's not always your username.
// See how the first one 
// was ' "text" ' and the second
// one was ' text '?
// Anything between "" is 
// a string (text) and the
// other one was the name
// of a variable or keyword
// like diplay, or username
// So make sure when writing
// text you make sure to put "".

//// Styles ////

// If you know a bit of how CSS works
// then styling your page will be
// easier for you, and even easier with
// CocoScript. You don't need to style pages
// with CSS syntax ("Grammar of CSS"), but rather with a simple keyword
// instead. Here is how it works

// The "style" keyword

// Here is how you would write
// a valid style:

// style(item, attribute, value);

// Here is an example, it is commented
// out because, it this script runs automatically.
// To use it, just un-comment it.

// style("body", "background-color", "white");

// The "body" is the webpage, that's our target.
// We want to change the "background-color" attribute of the body.
// "white" is the value of the attribute. So we want the attribute
// "background-color" of the "body" to be set to "white".

//// Variables ////
// The "username" variable stores your username,
// I think you knew that already.
// A variable is basically...
// Ok, i'll just show you:

// A variable is used for storing data, ok?

!var1 = 5; // The "!" tells The CocoScript Interpreter to create a new variable.
// diplay(var1); // This will display your value inside the variable named "var1"

// you can reassign variables:
var1 = 6;
//diplay(var1); // Display 6
var1 = 7;
//diplay(var1); // Display 7

!var2 = username; // You can store your username in a custom variable
//username = var1; // You can also do that.

//username = "My New Name!"; // And also that.

//// Booleans ////

// A Boolean is a type of data that could only be true or false.
// Here is an example:

!var3 = true;
!var4 = false;

// What's a use for this? How about this:

!var5 = var1 == var2;

// Huh? What's that "==" for? Well that's the compare operator.
// It checks if two values are the same, if the one on 
// the left side and the right ate the same, then it output's true
// so it will be like: "!var5 = true;". Or if it's false: "!var5 = false;"
// Get it? No? Well get someone else to teach you, this is not unique to CocoScript.

//// If Statements ////

// An if statement will only run code if a variable is true, write one like this:

!isTrue = false;

?isTrue { // The "?" is the "if"
  // diplay("It is false");
}

// So it's structured like this:
// ?var {code}

// Here is a real world example of if statements

!isNot = true;
!isMyName = username == "My Username";

?isMyName {
  diplay("Hello, Me!");
  isNot = false; // Set it to false so that the next if statement won't run
}

// This will not run if isNot is false
?isNot {
  // diplay("You are ");
  // diplay(username);
  // diplay(" not me!");
}

//// If-Else Statements ////

// If else statement are a way better way to 
// run code always, even when false

// Here is the other program, just cleaned up:

!isMyName = username == "My Username";

?isMyName {
  diplay("Hello, Me!");
} else {
  // diplay("You are ");
  // diplay(username);
  // diplay(" not me!");
}

// See? It's a lot more cleaned up.
// There is also an else if:

!isMyName = username == "My Username";
!isMyOtherName = username == "My other username";

?isMyName {
  diplay("Hello, Me!");
} else ?isMyOtherUsername {
  diplay("Hello, me on another account!");
} else {
  // diplay("You are ");
  // diplay(username);
  // diplay(" not me!");
}

// See? It's like this:
// Check if, do this. ?condition {code}
// Check if, not if, but if, do if. ?condition {skip} else ?condition {code}
// Check if, not any if's? Then do else. Get it?

// You can put as many else ifs you want, but the else block has to be last, and there can only be one.

//// Important Notes!: ////

// If statements are completely broken, don't use them, yet.

// Use styles to style your webpage, don't add any inappropriate images, you will get banned.

// Again, diplay's output will not be visible to other users,
// However it will appear in the web browsers DevTools, so don't hide anything important there!.

*/

// CocoScript Tutorial (Fixed by AI):

/*
// Welcome to CocoScript!
// If this is your first time using it, let me show you the basics.

//// Comments ////
// Comments are pieces of "code" that don’t run.
// For example, this text you’re reading is a comment.
// Comments are useful for taking notes or saving code for later.
// To write a comment, type "//". Everything after it on the line will be ignored.

//// Output ////
// One of the most important things in coding is output.
// Output lets you see your progress and keep track of variables.
//
// Note: Other users cannot see your output — it’s just for testing.
//
// Here is a simple output program:
diplay("Coco!");
// No, that’s not a typo — it’s "diplay", not "display".
//
// You can also output your username:
diplay(username); 
// This prints the name of the user currently on your page.
// Notice the difference: "text" in quotes is a string,
// while text without quotes is a variable or keyword.
// Always put "" around text you want to display literally.

//// Styles ////
// If you know a bit of CSS, styling your page will be easier.
// CocoScript makes styling even simpler — you don’t need full CSS syntax.
// Instead, you use the "style" keyword.
//
// Example:
style("body", "background-color", "white");
// This changes the background color of the page’s body to white.

//// Variables ////
// The "username" variable stores your username.
// Variables are used to store data.
//
// Example:
!var1 = 5; // "!" creates a new variable
diplay(var1); // Displays 5
//
// You can reassign variables:
var1 = 6;
diplay(var1); // Displays 6
var1 = 7;
diplay(var1); // Displays 7
//
// You can also store your username in a variable:
!var2 = username;
// Or even overwrite the username:
username = "My New Name!";

//// Booleans ////
// A Boolean is a type of data that can only be true or false.
!var3 = true;
!var4 = false;
//
// Example use:
!var5 = var1 == var2; // "==" compares values
// If var1 equals var2, var5 becomes true. Otherwise, it’s false.

//// If Statements ////
// An if statement runs code only if a condition is true.
!isTrue = false;
?isTrue {
  diplay("It is true!");
}
//
// Example:
!isMyName = username == "My Username";
?isMyName {
  diplay("Hello, Me!");
}

//// If-Else Statements ////
// If-else statements let you run code whether the condition is true or false.
!isMyName = username == "My Username";
?isMyName {
  diplay("Hello, Me!");
} else {
  diplay("You are not me!");
}
//
// You can also chain else-if statements:
!isMyOtherName = username == "My other username";
?isMyName {
  diplay("Hello, Me!");
} else ?isMyOtherName {
  diplay("Hello, me on another account!");
} else {
  diplay("You are not me!");
}

//// Important Notes ////
// - If statements are still experimental — they may not work perfectly yet.
// - Use styles to customize your webpage. Don’t add inappropriate images.
// - diplay’s output is visible only to you in DevTools, not to other users.

*/

// CocoScript Tutorial (Fixed by AI, Modified again by me):

/*
// Welcome to CocoScript!
// Note!: AI fixed my text, it did not do it for me!
// If this is your first time using it, let me show you the basics.

//// Comments ////
// Comments are pieces of "code" that don’t run.
// For example, this text you’re reading is a comment.
// Comments are useful for taking notes or saving code for later.
// To write a comment, type "//". Everything after it on the line will be ignored.

//// Output ////
// One of the most important things in coding is output.
// Output lets you see your progress and keep track of variables.
//
// Note: Other users cannot see your output — it’s just for testing.
//
// Here is a simple output program:
diplay("Coco!");
// No, that’s not a typo — it’s "diplay", not "display".
//
// You can also output your username:
diplay(username); 
// This prints the name of the user currently on your page.
// Notice the difference: "text" in quotes is a string,
// while text without quotes is a variable or keyword.
// Always put "" around text you want to display literally.

//// Styles ////
// If you know a bit of CSS, styling your page will be easier.
// CocoScript makes styling even simpler — you don’t need full CSS syntax.
// Instead, you use the "style" keyword.
//
// Example:
style("body", "background-color", "white");
// This changes the background color of the page’s body to white.

// Note!: you have to remove the background image first!
// The image covers the color, un-comment this to see the color,
// Or modify it to a different background image.

// style("body", "background-image", "none");

// To modify background images to another image, use background-img instead.

//style("body", "background-img", "/Images/background.png");

// Which is: style (target, "background-img", url to image);

// CocoScript cannot parse nested "()", so
// style ("body", "background-image", "url(url)");
// will not work. Any CSS within nested parenthesis, will fail.
// At least currently, this may be fixed by the time your reading this.

//// Variables ////
// The "username" variable stores your username.
// Variables are used to store data.
//
// Example:
!var1 = 5; // "!" creates a new variable
diplay(var1); // Displays 5
//
// You can reassign variables:
var1 = 6;
diplay(var1); // Displays 6
var1 = 7;
diplay(var1); // Displays 7
//
// You can also store your username in a variable:
!var2 = username;
// Or even overwrite the username:
username = "My New Name!";

//// Booleans ////
// A Boolean is a type of data that can only be true or false.
!var3 = true;
!var4 = false;
//
// Example use:
!var5 = var1 == var2; // "==" compares values
// If var1 equals var2, var5 becomes true. Otherwise, it’s false.

//// If Statements ////
// An if statement runs code only if a condition is true.
!isTrue = false;
?isTrue {
  diplay("It is true!");
}
//
// Example:
!isMyName = username == "My Username";
?isMyName {
  diplay("Hello, Me!");
}

//// If-Else Statements ////
// If-else statements let you run code whether the condition is true or false.
!isMyName = username == "My Username";
?isMyName {
  diplay("Hello, Me!");
} else {
  diplay("You are not me!");
}
//
// You can also chain else-if statements:
!isMyOtherName = username == "My other username";
?isMyName {
  diplay("Hello, Me!");
} else ?isMyOtherName {
  diplay("Hello, me on another account!");
} else {
  diplay("You are not me!");
}

//// Important Notes ////
// - If statements are still experimental — they may not work perfectly yet.
// - Use styles to customize your webpage. Don’t add inappropriate images.
// - diplay’s output is visible only to you in DevTools, or in the output below; not to other users.

diplay("Program End.");
   
*/

app.get('/api/follow/:username', (req, res) => {
  if (!req.session.userId) return res.status(401).send("Not logged in");

  const targetUser = db.getUserByUsername(req.params.username);
  if (!targetUser) return res.status(404).send("User not found");
  if (targetUser.isPrivate === 1) return res.status(405).send("Target user is not public.");

  db.followUser(req.session.userId, targetUser.id);
  return res.status(200).redirect(`/users/${req.params.username}/`);
});

app.get('/api/unfollow/:username', (req, res) => {
  if (!req.session.userId) return res.status(401).send("Not logged in");

  const targetUser = db.getUserByUsername(req.params.username);
  if (!targetUser) return res.status(404).send("User not found");
  if (targetUser.isPrivate === 1) return res.status(405).send("Target user is not public.");

  db.unfollowUser(req.session.userId, targetUser.id);
  return res.status(200).redirect(`/users/${req.params.username}/`);
});

app.get('/api/set/public', (req, res) => {
  const sessionUser = (req.session.userId) ? db.getUserById(req.session.userId) : null;
  if (!sessionUser || sessionUser.username === "") return res.status(405).send("Sign in to change this.");
  db.makeUserPublic(sessionUser.id);
  res.status(200).send("You are now public!");
});

app.get('/api/set/private', (req, res) => {
  const sessionUser = (req.session.userId) ? db.getUserById(req.session.userId) : null;
  if (!sessionUser || sessionUser.username === "") return res.status(405).send("Sign in to change this.");
  db.makeUserPrivate(sessionUser.id);
  res.status(200).send("You are now private!");
});

// Sets the users description (and custom CocoScript)
app.post('/api/set/description', (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  const { description, CocoScriptCode } = req.body;
  if (!sessionUser || !sessionUser.username) {
    return res.status(405).json({ error: "Sign in to change this." });
  }
  db.updateUserDescription(sessionUser.id, description);
  db.updateUserScript(sessionUser.id, CocoScriptCode);
  return res.status(200).json({ message: "Updated" });
});

app.get("/faq", (req, res) => {
  // attach session user to template if available
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  res.render('faq', { user: sessionUser, products: products, news: news });
})

// --- Auth routes ---
app.get('/register', (req, res) => {
  res.render('register');
});

app.post('/register', async (req, res) => {
  const { username, email, password } = req.body;
  const cleanUsername = new Amp().cleanNameNonSplit(username);

  if (!cleanUsername || !password) return res.status(400).send('username and password required');

  try {
    const existing = db.getUserByUsername(cleanUsername);
    if (existing) return res.status(400).send('username taken');

    const hash = await bcrypt.hash(password, 10);
    const id = db.createUser(cleanUsername, email || '', hash);

    // set session directly from insert ID and explicitly save before redirecting
    req.session.userId = id;
    console.log('Register: set session.userId =', id);
    req.session.save(err => {
      if (err) console.error('Session save error (register):', err);
      return res.redirect('/');
    });
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
    console.log('Login: set session.userId =', userRecord.id);
    req.session.save(err => {
      if (err) console.error('Session save error (login):', err);
      return res.redirect('/');
    });
  } catch (e) {
    console.error(e);
    res.status(500).send('error logging in');
  }
});

app.get('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/');
  });
});

app.post('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/');
  });
});

/*-- Messaging API --*/

app.post("/api/user/messages", (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  if (!sessionUser) {
    return res.status(401).json({ error: "Not logged in" });
  }

  //const { start, count } = req.body;
  const { start } = req.body;
  const count = 5;

  const messages = db.getMessages(sessionUser.id, Number(start), Number(count));

  return res.json({ messages });
});

app.post("/api/messages/read/:id", (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  if (!sessionUser) {
    return res.status(401).json({ error: "Not logged in" });
  }

  const messageId = Number(req.params.id);
  if (!messageId) {
    return res.status(400).json({ error: "Invalid message ID" });
  }

  db.markMessageRead(messageId, sessionUser.id);
  return res.status(200).json({ message: "Message marked as read" });
});

app.post("/api/send/message", (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  const amp = new Amp(); // Create username cleaner.
  if (!sessionUser) return res.status(401).send("Be logged in, then we'll talk.");
  const { to, text, fromNickname, title } = req.body;
  const from = { user: { username: sessionUser.username, id: sessionUser.id }, nickname: fromNickname || sessionUser.username };
  if ((!text || !to) || !title) return res.status(400).send("Malformed form; text content; title, and target user is required");

  const targetUser = req.session.userId ? db.getUserByUsername(amp.cleanNameNonSplit(to)) : null;
  if (!targetUser) return res.status(402).send("Who? This user does not exist. Remember their username is different form their real name.");

  if (fromNickname.length > 500 || text.length > 500 || title.length > 500) return res.status(400).send("Your message or other entries are not allowed to be more then 500 characters.");

  db.addMessage(targetUser.id, JSON.stringify(from), title, text);
  //db.addFromMessage(targetUser.id, JSON.stringify(from), title, text);
  return res.status(200).send("Message successfully sent.");
});

/*app.post("/api/send/message/:toUsername", (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  if (!sessionUser) {
    return res.status(401).json({ error: "Not logged in" });
  }

  const targetUser = db.getUserByUsername(req.params.toUsername);

  if (!targetUser) {
    return res.status(404).json({ error: "Recipient not found" });
  }

  if (targetUser.isPrivate === 1) {
    return res.status(405).json({ error: "User is private" });
  }

  if (targetUser.isPrivate === 1) {
    return res.status(405).json({ error: "Stop! Your blocked." });
  }

  const { title, content } = req.body;
  if (!title || !content) {
    return res.status(400).json({ error: "Title and content required" });
  }

  db.sendMessage(targetUser.id, sessionUser.id, title, content, nickname);
  return res.status(200).json({ message: "Message sent successfully" });
});*/

// Delete a message
app.post("/api/messages/delete/:id", (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  if (!sessionUser) {
    return res.status(401).json({ error: "Not logged in" });
  }

  const messageId = Number(req.params.id);
  if (!messageId) {
    return res.status(400).json({ error: "Invalid message ID" });
  }

  db.deleteMessage(messageId, sessionUser.id);
  return res.status(200).json({ message: "Message deleted" });
});

// Preview

app.get("/previews/Coco", (req, res) => {
  // attach session user to template if available
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : false;
  res.render('Steamworks', { user: sessionUser });
});

app.get("/downloads/", (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : false;
  res.render('downloads', { user: sessionUser, products });
});

// Download APIs

// Project APIs

app.get('/api/get/project/users/:user/:projectID', (req, res) => {
  let file;
  try {
    file = fs.readFileSync(
      path.join(__dirname, "private", "users", req.params.user, "projects", req.params.projectID, "metadata.json")
    );
  } catch {
    return res.status(404).redirect("/NotFound/");
  }

  let metadata;
  try {
    metadata = JSON.parse(file.toString());
  } catch {
    return res.status(500).render("500", { message: "Invalid metadata file." });
  }

  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;

  if (!sessionUser && !metadata.isShared) {
    return res.status(405).render("405", { method: `You are not logged in! "${req.originalUrl}"` });
  }
  if (sessionUser && req.params.user !== sessionUser.username && !metadata.isShared) {
    return res.status(403).render("403", { message: "This project does not exist or is private." });
  }

  return res.status(200).json(metadata);
});

app.get('/api/create/new/project/users/:user/:ProjectName/:type', (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  if (!sessionUser) {
    return res.status(405).render("405", { method: `You are not logged in! "${req.originalUrl}"` });
  }
  if (req.params.user !== sessionUser.username) {
    return res.status(403).render("403", { message: "You are not allowed here! To create a project use the endpoint under your account." });
  }

  const projectPath = path.join(__dirname, "private", "users", req.params.user, "projects");
  fs.mkdirSync(projectPath, { recursive: true });

  let id, projectDir, tries = 0;
  do {
    id = tools.generateRandomString(10);
    projectDir = path.join(projectPath, id);
    tries++;
  } while (fs.existsSync(projectDir) && tries < 20);

  if (tries >= 20) {
    return res.status(500).render("500", { message: "Tried 20 times to generate a unique project id. Try again." });
  }

  fs.mkdirSync(projectDir, { recursive: true });

  const metadata = {
    views: [],
    "project-name": req.params.ProjectName,
    downloads: [],
    type: req.params.type,
    creators: [{ username: req.params.user, id: req.session.userId }],
    Owner: { username: req.params.user, id: req.session.userId },
    isShared: false,
    projectId: id
  };

  fs.writeFileSync(path.join(projectDir, "metadata.json"), JSON.stringify(metadata, null, 2));

  return res.status(200).json({ message: "Project Saved", metadata });
});

app.get('/api/list/projects/:user', (req, res) => {
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  const targetUser = db.getUserByUsername(req.params.user);

  if (!targetUser) {
    return res.status(404).redirect("/NotFound/");
  }

  if ((!sessionUser || sessionUser.username !== req.params.user) && targetUser.isPrivate === 1) {
    return res.status(403).render("403", { message: "This user's projects are private." });
  }

  const projectsPath = path.join(__dirname, "private", "users", req.params.user, "projects");
  if (!fs.existsSync(projectsPath)) {
    return res.status(200).json([]);
  }

  const projects = [];
  const projectDirs = fs.readdirSync(projectsPath);

  projectDirs.forEach(dir => {
    const metadataFile = path.join(projectsPath, dir, "metadata.json");
    if (fs.existsSync(metadataFile)) {
      try {
        const metadata = JSON.parse(fs.readFileSync(metadataFile, "utf8"));
        if (metadata.isShared || (sessionUser && sessionUser.username === targetUser.username)) {
          projects.push({ id: dir, ...metadata });
        }
      } catch (err) {
        console.error(`Invalid metadata in project ${dir}:`, err);
      }
    }
  });

  return res.status(200).json(projects);
});

/*--- Sidebar API ---*/

app.get("/sidebar/help/screens/:screen", (req, res) => {
  const screen = req.params.screen;
  switch (screen) {
    case "about":
    case "help":
    case "mailbox":
      break;
    default:
      return res.status(404).redirect("/sidebar/help/404/");
  };
  const user = (req.session.userId) ? db.getUserById(req.session.userId) : false;
  //console.log(path.join(__dirname, "views", "sidebar", `${screen}.ejs`));
  if (fs.existsSync(path.join(__dirname, "views", "sidebar", `${screen}.ejs`))) {
    return res.status(200).render(path.join("sidebar", screen), { user, isLoggedIn: !!user });
  } else {
    return res.status(404).redirect("/sidebar/help/404/");
  }
});

app.get("/sidebar/help/404/", (req, res) => {
  const user = (req.session.userId) ? db.getUserById(req.session.userId) : false;
  return res.render(path.join("sidebar", "404"), { user, isLoggedIn: !!user });
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

app.use((req, res) => {
  // attach session user to template if available
  const sessionUser = req.session.userId ? db.getUserById(req.session.userId) : null;
  res.status(404).render('404', { user: sessionUser, products: products, news: news });
});

// Initialize DB then start server
db.init().then(() => {
  app.listen(PORT, HOST, () => {
    console.log(`Coco Website server initialized on ${APP_URL}`);
  });
}).catch(err => {
  console.error('Failed to initialize database', err);
  process.exit(1);
});