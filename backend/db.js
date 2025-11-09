// db.js
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
    //db.run("ALTER TABLE users ADD COLUMN description TEXT DEFAULT ''");
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
        description TEXT DEFAULT ""
      );

CREATE TABLE follows (
  follower_id INTEGER NOT NULL,
  followed_id INTEGER NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (follower_id, followed_id),
  FOREIGN KEY (follower_id) REFERENCES users(id),
  FOREIGN KEY (followed_id) REFERENCES users(id)
);
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
  const stmt = db.prepare('INSERT INTO users (username, email, password_hash, isPrivate) VALUES (?, ?, ?, ?)');
  stmt.run([username, email, passwordHash, 1]);
  stmt.free();
  persist();
  const row = db.exec('SELECT last_insert_rowid() as id');
  return row[0].values[0][0];
}

function getUserByUsername(username) {
  const stmt = db.prepare('SELECT id, username, email, password_hash as passwordHash, pfp, isPrivate, created_at, description FROM users WHERE username = ?');
  stmt.bind([username]);
  if (!stmt.step()) { stmt.free(); return null; }
  const row = stmt.getAsObject();
  stmt.free();
  return row;
}

function getUserById(id) {
  const stmt = db.prepare('SELECT id, username, email, password_hash as passwordHash, pfp, isPrivate, created_at, description FROM users WHERE id = ?');
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

module.exports = { init, createUser, getUserByUsername, getUserById, updateUserPfp, followUser, makeUserPrivate, makeUserPublic, unfollowUser, getFollowers, getFollowing, updateUserDescription };