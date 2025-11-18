// db.js

const DEFAULT_SCRIPT = `

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
`;

const fs = require('fs');
const path = require('path');
const initSqlJs = require('sql.js');
const sqljsPath = require.resolve('sql.js');
const sqljsDir = path.dirname(sqljsPath);

const DB_FILE = path.join(__dirname, '..', 'data.sqlite3');
let SQL;
let db;

async function init() {
  if (SQL) return;
  SQL = await initSqlJs({ locateFile: file => path.join(sqljsDir, file) });
  if (fs.existsSync(DB_FILE)) {
    const filebuffer = fs.readFileSync(DB_FILE);
    db = new SQL.Database(filebuffer);
    //db.run(`ALTER TABLE users ADD COLUMN CocoScriptEnabled TEXT DEFAULT 'true'`);
    /**
    setDefaultScriptForAllUsers();
    resetAllScripts();
    /**/
  } else {
    db = new SQL.Database();
    db.run(`
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT,
        password_hash TEXT NOT NULL,
        isPrivate INTEGER DEFAULT 1,
        pfp TEXT, -- new column for profile picture path/URL
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        description TEXT DEFAULT "",
        script TEXT,
        CocoScriptEnabled TEXT DEFAULT 'true'
      );

      CREATE TABLE follows (
        follower_id INTEGER NOT NULL,
        followed_id INTEGER NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (follower_id, followed_id),
        FOREIGN KEY (follower_id) REFERENCES users(id),
        FOREIGN KEY (followed_id) REFERENCES users(id)
      );

      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        sender TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        isTrashed INTEGER DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      );


      CREATE TABLE project (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        creator TEXT DEFAULT "",
        workers TEXT DEFAULT "",
        BASE_64 TEXT DEFAULT "",
        name TEXT DEFAULT ""
      )

    `);
    persist();
  }
}

function persist() {
  const data = db.export();
  const buffer = Buffer.from(data);
  fs.writeFileSync(DB_FILE, buffer);
}

function createUser(username, email, passwordHash) {
  const stmt = db.prepare(
    'INSERT INTO users (username, email, password_hash, isPrivate, script) VALUES (?, ?, ?, ?, ?)'
  );
  stmt.run([username, email, passwordHash, 1, DEFAULT_SCRIPT]);
  stmt.free();
  persist();
  // After persisting, query the user row to obtain the id (more reliable across sql.js)
  const user = getUserByUsername(username);
  if (!user || !user.id) throw new Error('Failed to retrieve inserted user id');
  const userId = user.id;
  // seed welcome messages
  addMessage(userId, "System", "Welcome!", `Thanks for joining Coco! Please follow the rules… To learn CocoScript, go to your profile and click edit. Find products made made by me, or someone else. <a href="/users/Coco/">@Coco</a>`);
  addMessage(userId, "Admin", "Community Guidelines", "Please follow the rules… <a href=\"/faq#guidelines\">Community Guidelines</a>");
  return userId;
}

function setDefaultScriptForAllUsers() {
  const stmt = db.prepare('UPDATE users SET script = ? WHERE script IS NULL OR script = ""');
  stmt.run([DEFAULT_SCRIPT]);
  stmt.free();
  persist();
}

function resetAllScripts() {
  const stmt = db.prepare('UPDATE users SET script = ?');
  stmt.run([DEFAULT_SCRIPT]);
  stmt.free();
  persist();
}

function getUserByUsername(username) {
  const stmt = db.prepare('SELECT id, username, email, password_hash as passwordHash, pfp, isPrivate, created_at, description, script FROM users WHERE username = ?');
  stmt.bind([username]);
  if (!stmt.step()) { stmt.free(); return null; }
  const row = stmt.getAsObject();
  stmt.free();
  return row;
}

function getUserById(id) {
  const stmt = db.prepare('SELECT id, username, email, password_hash as passwordHash, pfp, isPrivate, created_at, description, script FROM users WHERE id = ?');
  stmt.bind([id]);
  if (!stmt.step()) { stmt.free(); return null; }
  const row = stmt.getAsObject();
  stmt.free();
  return row;
}

function updateUserPfp(userId, pfpPath) {
  const stmt = db.prepare('UPDATE users SET pfp = ? WHERE id = ?');
  stmt.run([pfpPath, userId]);
  stmt.free();
  persist();
}

function makeUserPublic(userId) {
  const stmt = db.prepare('UPDATE users SET isPrivate = ? WHERE id = ?');
  stmt.run([0, userId]);
  stmt.free();
  persist();
}

function makeUserPrivate(userId) {
  const stmt = db.prepare('UPDATE users SET isPrivate = ? WHERE id = ?');
  stmt.run([1, userId]);
  stmt.free();
  persist();
}

function followUser(followerId, followedId) {
  const stmt = db.prepare('INSERT OR IGNORE INTO follows (follower_id, followed_id) VALUES (?, ?)');
  stmt.run([followerId, followedId]);
  stmt.free();
  persist();
}

function unfollowUser(followerId, followedId) {
  const stmt = db.prepare('DELETE FROM follows WHERE follower_id = ? AND followed_id = ?');
  stmt.run([followerId, followedId]);
  stmt.free();
  persist();
}

function getFollowers(userId) {
  const stmt = db.prepare(`
    SELECT u.id, u.username 
    FROM follows f 
    JOIN users u ON f.follower_id = u.id 
    WHERE f.followed_id = ?
  `);
  stmt.bind([userId]);
  const followers = [];
  while (stmt.step()) {
    followers.push(stmt.getAsObject());
  }
  stmt.free();
  return followers;
}

function getFollowing(userId) {
  const stmt = db.prepare(`
    SELECT u.id, u.username 
    FROM follows f 
    JOIN users u ON f.followed_id = u.id 
    WHERE f.follower_id = ?
  `);
  stmt.bind([userId]);
  const following = [];
  while (stmt.step()) {
    following.push(stmt.getAsObject());
  }
  stmt.free();
  return following;
}

function updateUserDescription(userId, description) {
  const stmt = db.prepare('UPDATE users SET description = ? WHERE id = ?');
  stmt.run([description, userId]);
  stmt.free();
  persist();
}

function updateUserScript(userId, script) {
  const stmt = db.prepare('UPDATE users SET script = ? WHERE id = ?');
  stmt.run([script, userId]);
  stmt.free();
  persist();
}

function addMessage(userId, sender, title, content) {
  const stmt = db.prepare(
    'INSERT INTO messages (user_id, sender, title, content, isRead) VALUES (?, ?, ?, ?, 0)'
  );
  stmt.run([userId, sender, title, content]);
  stmt.free();
  persist();
}

function getMessages(userId, start, count) {
  const stmt = db.prepare(
    'SELECT id, sender, title, content, isRead, created_at FROM messages WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?'
  );
  stmt.bind([userId, count, start]);
  const messages = [];
  while (stmt.step()) {
    messages.push(stmt.getAsObject());
  }
  stmt.free();
  return messages;
}

function markMessageRead(messageId) {
  const stmt = db.prepare('UPDATE messages SET isRead = 1 WHERE id = ?');
  stmt.run([messageId]);
  stmt.free();
  persist();
}

function sendMessage(toUserId, fromUserId, title, content) {
  const sender = db.getUserById(fromUserId)?.username || "System";
  const stmt = db.prepare(
    'INSERT INTO messages (user_id, sender, title, content, isRead) VALUES (?, ?, ?, ?, 0)'
  );
  stmt.run([toUserId, sender, title, content]);
  stmt.free();
  persist();
}

function deleteMessage(messageId, userId) {
  const stmt = db.prepare('DELETE FROM messages WHERE id = ? AND user_id = ?');
  stmt.run([messageId, userId]);
  stmt.free();
  persist();
}

function hiddenPlace() {}

module.exports = { init, createUser, getUserByUsername, getUserById, updateUserPfp, followUser, makeUserPrivate, makeUserPublic, unfollowUser, getFollowers, getFollowing, updateUserDescription, updateUserScript, setDefaultScriptForAllUsers, resetAllScripts, addMessage, getMessages, markMessageRead, sendMessage, deleteMessage };