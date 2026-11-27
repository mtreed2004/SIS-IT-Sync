CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    sis_id VARCHAR(32) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(20) NOT NULL CHECK (role IN ('student', 'staff')),
    building VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE devices (
    id SERIAL PRIMARY KEY,
    asset_tag VARCHAR(50) UNIQUE NOT NULL,
    model VARCHAR(100) NOT NULL,
    assigned_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'available' CHECK (status IN ('assigned', 'available', 'repair', 'retired')),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE sync_runs (
    id SERIAL PRIMARY KEY,
    trigger_type VARCHAR(20) NOT NULL CHECK (trigger_type IN ('scheduled', 'manual')),
    status VARCHAR(30) NOT NULL CHECK (status IN ('running', 'completed', 'completed_with_errors', 'failed')),
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    duration_ms INTEGER,
    records_processed INTEGER NOT NULL DEFAULT 0,
    records_created INTEGER NOT NULL DEFAULT 0,
    records_updated INTEGER NOT NULL DEFAULT 0,
    records_failed INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE sync_errors (
    id SERIAL PRIMARY KEY,
    sync_run_id INTEGER NOT NULL REFERENCES sync_runs(id) ON DELETE CASCADE,
    sis_id VARCHAR(32),
    error_type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    raw_payload JSONB NOT NULL,
    resolved BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_building ON users(building);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_sync_runs_started_at ON sync_runs(started_at DESC);
CREATE INDEX idx_sync_errors_run_id ON sync_errors(sync_run_id);
CREATE INDEX idx_sync_errors_unresolved ON sync_errors(resolved) WHERE resolved = FALSE;