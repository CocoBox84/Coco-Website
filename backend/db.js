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
  } else {
    db = new SQL.Database();
    db.run(`
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT,
        password_hash TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
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
  const stmt = db.prepare('INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)');
  stmt.run([username, email, passwordHash]);
  stmt.free();
  persist();
  const row = db.exec('SELECT last_insert_rowid() as id');
  return row[0].values[0][0];
}

function getUserByUsername(username) {
  const stmt = db.prepare('SELECT id, username, email, password_hash as passwordHash, created_at FROM users WHERE username = ?');
  stmt.bind([username]);
  if (!stmt.step()) { stmt.free(); return null; }
  const row = stmt.getAsObject();
  stmt.free();
  return row;
}

function getUserById(id) {
  const stmt = db.prepare('SELECT id, username, email, password_hash as passwordHash, created_at FROM users WHERE id = ?');
  stmt.bind([id]);
  if (!stmt.step()) { stmt.free(); return null; }
  const row = stmt.getAsObject();
  stmt.free();
  return row;
}

module.exports = { init, createUser, getUserByUsername, getUserById };
