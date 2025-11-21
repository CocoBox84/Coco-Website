// db.js

const DEFAULT_SCRIPT = `
diplay("Hello, World!");
diplay("Coco");
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
        CocoScriptEnabled TEXT DEFAULT 'true',
        role TEXT default "User"
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

      CREATE TABLE sentMessages (
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
        name TEXT DEFAULT "",
        isShared INTEGER default 0
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

function createUser(username, email, passwordHash, isAdmin) {
  const stmt = db.prepare(
    'INSERT INTO users (username, email, password_hash, isPrivate, script, role) VALUES (?, ?, ?, ?, ?, ?)'
  );
  const role = (isAdmin) ? "Admin" : "User";
  stmt.run([username, email, passwordHash, 1, DEFAULT_SCRIPT, role]);
  stmt.free();
  persist();
  // After persisting, query the user row to obtain the id (more reliable across sql.js)
  const user = getUserByUsername(username);
  if (!user || !user.id) throw new Error('Failed to retrieve inserted user id');
  const userId = user.id;
  // seed welcome messages
  addMessage(userId, "System", "Welcome!", `Thanks for joining %sticker="Coco"! Please follow the rules… To learn CocoScript, go to your profile and click edit. Find products made made by me, or someone else. <a href="/users/Coco/">@Coco</a>`);
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

function markMessageUnRead(messageId) {
  const stmt = db.prepare('UPDATE messages SET isRead = 0 WHERE id = ?');
  stmt.run([messageId]);
  stmt.free();
  persist();
}

function sendMessage(toUserId, fromUserId, title, content) {
  const sender = from || "System";
  const stmt = db.prepare(
    'INSERT INTO messages (user_id, sender, title, content, isRead) VALUES (?, ?, ?, ?, 0)'
  );
  stmt.run([toUserId, sender, title, content]);
  stmt.free();
  persist();
}

// Add sent message to the sender
function addSentMessage(toUserId, from, title, content, fromUserId) {
  const sender = from;
  const stmt = db.prepare(
    'INSERT INTO sentMessages (user_id, sender, title, content, isRead) VALUES (?, ?, ?, ?, 0)'
  );
  stmt.run([fromUserId, sender, title, content]);
  stmt.free();
  persist();
}

function getSentMessages(userId, start, count) {
  const stmt = db.prepare(
    'SELECT id, sender, title, content, isRead, created_at FROM sentMessages WHERE user_id = ? ORDER BY created_at DESC LIMIT ? OFFSET ?'
  );
  stmt.bind([userId, count, start]);
  const messages = [];
  while (stmt.step()) {
    messages.push(stmt.getAsObject());
  }
  stmt.free();
  return messages;
}

function deleteMessage(messageId, userId) {
  const stmt = db.prepare('DELETE FROM messages WHERE id = ? AND user_id = ?');
  stmt.run([messageId, userId]);
  stmt.free();
  persist();
}

function hiddenPlace() {}

module.exports = { init, createUser, getUserByUsername, getUserById, updateUserPfp, followUser, makeUserPrivate, makeUserPublic, unfollowUser, getFollowers, getFollowing, updateUserDescription, updateUserScript, setDefaultScriptForAllUsers, resetAllScripts, addMessage, getMessages, markMessageRead, sendMessage, deleteMessage, addSentMessage, getSentMessages, markMessageUnRead };