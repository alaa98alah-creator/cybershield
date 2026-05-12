DROP TABLE IF EXISTS files_metadata;
DROP TABLE IF EXISTS ai_analyses;
DROP TABLE IF EXISTS vt_results;
DROP TABLE IF EXISTS scans;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id TEXT PRIMARY KEY,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  gender TEXT,
  date_of_birth TEXT,
  residence TEXT,
  password_hash TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE scans (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  scan_type TEXT NOT NULL CHECK(scan_type IN ('link', 'file')),
  target TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'scanning', 'completed', 'failed')),
  error_message TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  completed_at TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE vt_results (
  id TEXT PRIMARY KEY,
  scan_id TEXT NOT NULL UNIQUE,
  malicious_count INTEGER NOT NULL DEFAULT 0,
  suspicious_count INTEGER NOT NULL DEFAULT 0,
  harmless_count INTEGER NOT NULL DEFAULT 0,
  undetected_count INTEGER NOT NULL DEFAULT 0,
  vt_permalink TEXT,
  raw_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (scan_id) REFERENCES scans(id)
);

CREATE TABLE ai_analyses (
  id TEXT PRIMARY KEY,
  scan_id TEXT NOT NULL UNIQUE,
  risk_level TEXT NOT NULL CHECK(risk_level IN ('safe', 'low', 'medium', 'high', 'critical')),
  simplified_summary TEXT NOT NULL,
  preventive_tips TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (scan_id) REFERENCES scans(id)
);

CREATE TABLE files_metadata (
  id TEXT PRIMARY KEY,
  scan_id TEXT NOT NULL UNIQUE,
  file_name TEXT,
  file_hash TEXT,
  mime_type TEXT,
  size_bytes INTEGER,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (scan_id) REFERENCES scans(id)
);

CREATE INDEX idx_scans_user_id ON scans(user_id);
CREATE INDEX idx_scans_status ON scans(status);
CREATE INDEX idx_scans_created_at ON scans(created_at);