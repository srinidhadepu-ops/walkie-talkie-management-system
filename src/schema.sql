PRAGMA journal_mode=WAL;
PRAGMA synchronous=FULL;
PRAGMA foreign_keys=ON;
PRAGMA busy_timeout=5000;

CREATE TABLE IF NOT EXISTS users (id TEXT PRIMARY KEY, username TEXT UNIQUE NOT NULL, display_name TEXT NOT NULL, role TEXT NOT NULL CHECK(role IN ('admin','operator')), password_hash TEXT NOT NULL, active INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS employees (id TEXT PRIMARY KEY, hrms_id TEXT UNIQUE NOT NULL, display_name TEXT NOT NULL, department TEXT, status TEXT NOT NULL DEFAULT 'active', created_at TEXT NOT NULL, updated_at TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS devices (id TEXT PRIMARY KEY, asset_code TEXT UNIQUE NOT NULL, serial_number TEXT UNIQUE, make TEXT, model TEXT, operational_status TEXT NOT NULL CHECK(operational_status IN ('AVAILABLE','ISSUED','CHARGING','MAINTENANCE','TESTING','PENDING_DAMAGE','PENDING_LOSS','DAMAGED','LOST','RETIRED')), active_issue_id TEXT, qr_token TEXT UNIQUE NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS shift_sessions (id TEXT PRIMARY KEY, user_id TEXT NOT NULL REFERENCES users(id), started_at TEXT NOT NULL, ended_at TEXT, status TEXT NOT NULL CHECK(status IN ('active','closed')));
CREATE UNIQUE INDEX IF NOT EXISTS one_active_shift_per_user ON shift_sessions(user_id) WHERE status='active';
CREATE TABLE IF NOT EXISTS issues (id TEXT PRIMARY KEY, device_id TEXT NOT NULL REFERENCES devices(id), employee_id TEXT NOT NULL REFERENCES employees(id), issued_at TEXT NOT NULL, issued_by TEXT NOT NULL REFERENCES users(id), issued_session_id TEXT NOT NULL REFERENCES shift_sessions(id), returned_at TEXT, returned_by TEXT REFERENCES users(id), return_method TEXT CHECK(return_method IN ('qr_scan','hrms_fallback','admin_correction')), fallback_reason TEXT, event_id TEXT UNIQUE NOT NULL);
CREATE UNIQUE INDEX IF NOT EXISTS one_open_issue_per_device ON issues(device_id) WHERE returned_at IS NULL;
CREATE UNIQUE INDEX IF NOT EXISTS one_open_issue_per_employee ON issues(employee_id) WHERE returned_at IS NULL;
CREATE TABLE IF NOT EXISTS chargers (id TEXT PRIMARY KEY, charger_number TEXT UNIQUE NOT NULL, active INTEGER NOT NULL DEFAULT 1);
CREATE TABLE IF NOT EXISTS charging_assignments (id TEXT PRIMARY KEY, charger_id TEXT NOT NULL REFERENCES chargers(id), device_id TEXT NOT NULL REFERENCES devices(id), started_at TEXT NOT NULL, ended_at TEXT, entered_by TEXT NOT NULL REFERENCES users(id));
CREATE UNIQUE INDEX IF NOT EXISTS one_open_charge_per_device ON charging_assignments(device_id) WHERE ended_at IS NULL;
CREATE TABLE IF NOT EXISTS status_history (id TEXT PRIMARY KEY, device_id TEXT NOT NULL REFERENCES devices(id), from_status TEXT, to_status TEXT NOT NULL, reason TEXT NOT NULL, actor_id TEXT REFERENCES users(id), occurred_at TEXT NOT NULL, correlation_id TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS audit_log (id TEXT PRIMARY KEY, occurred_at TEXT NOT NULL, actor_id TEXT REFERENCES users(id), action TEXT NOT NULL, entity_type TEXT NOT NULL, entity_id TEXT NOT NULL, correlation_id TEXT NOT NULL, before_json TEXT, after_json TEXT, previous_hash TEXT, entry_hash TEXT NOT NULL);
CREATE TABLE IF NOT EXISTS sync_outbox (event_id TEXT PRIMARY KEY, sequence_no INTEGER UNIQUE NOT NULL, event_type TEXT NOT NULL, aggregate_id TEXT NOT NULL, payload_json TEXT NOT NULL, payload_hash TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'PENDING', created_at TEXT NOT NULL);
