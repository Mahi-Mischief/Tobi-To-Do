import fs from 'fs';
import pg from 'pg';
import dotenv from 'dotenv';

dotenv.config();
const { Pool } = pg;

// Configure SSL for Postgres with an opt-out flag for local/non-SSL servers.
// Modes:
// 1) DB_SSL=false  -> disable SSL entirely (dev/local DBs that don't support SSL)
// 2) Cert present  -> use CA file with rejectUnauthorized=true
// 3) Fallback flag -> allow insecure SSL if cert missing and DB_SSL_FALLBACK_ALLOW_INSECURE=true
// 4) Default       -> attempt SSL with rejectUnauthorized=true and log guidance on failure
const dbSslSetting = (process.env.DB_SSL || '').trim().toLowerCase();
const shouldUseSSL = dbSslSetting === '' ? true : !['false', '0', 'no', 'off'].includes(dbSslSetting);
const certPath = process.env.PROD_CA_PATH || 'server/prod-ca-2021.crt';
let sslConfig = false;

if (shouldUseSSL) {
  const sslOptions = {};
  try {
    if (fs.existsSync(certPath)) {
      sslOptions.ca = fs.readFileSync(certPath).toString();
      sslOptions.rejectUnauthorized = true;
      console.log(`Using DB SSL cert from ${certPath}`);
    } else if (process.env.DB_SSL_FALLBACK_ALLOW_INSECURE === 'true') {
      sslOptions.rejectUnauthorized = false; // development fallback
      console.warn('DB SSL cert not found — falling back to rejectUnauthorized=false (development only)');
    } else {
      sslOptions.rejectUnauthorized = true;
      console.warn('No DB SSL cert found. If connection fails, set PROD_CA_PATH, DB_SSL=false (local dev), or DB_SSL_FALLBACK_ALLOW_INSECURE=true.');
    }
  } catch (err) {
    console.error('Error configuring DB SSL options:', err);
    sslOptions.rejectUnauthorized = false;
  }
  sslConfig = sslOptions;
} else {
  console.warn('DB_SSL=false — using non-SSL Postgres connection (development only).');
  sslConfig = false;
}

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  ssl: sslConfig,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

export async function initializeDatabase() {
  try {
    const client = await pool.connect();

    // ------------------ Users Table ------------------
    await client.query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255),
        firebase_uid VARCHAR(255) UNIQUE,
        full_name VARCHAR(255),
        avatar_url TEXT,
        bio TEXT,
        theme_preference VARCHAR(20) DEFAULT 'light',
        notifications_enabled BOOLEAN DEFAULT true,
        xp INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        deleted_at TIMESTAMP
      );
    `);

    // ------------------ Tasks Table ------------------
    await client.query(`
      CREATE TABLE IF NOT EXISTS tasks (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        due_date TIMESTAMP,
        priority VARCHAR(20) DEFAULT 'medium',
        category VARCHAR(50) DEFAULT 'general',
        status VARCHAR(50) DEFAULT 'todo',
        completed BOOLEAN DEFAULT false,
        completed_at TIMESTAMP,
        duration_minutes INTEGER,
        ai_breakdown JSONB,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // ------------------ Goals Table ------------------
    await client.query(`
      CREATE TABLE IF NOT EXISTS goals (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        category VARCHAR(50) DEFAULT 'personal',
        deadline TIMESTAMP,
        progress_percent INTEGER DEFAULT 0,
        status VARCHAR(50) DEFAULT 'in_progress',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // ------------------ Habits Table ------------------
    await client.query(`
      CREATE TABLE IF NOT EXISTS habits (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        frequency VARCHAR(50) DEFAULT 'daily',
        streak_count INTEGER DEFAULT 0,
        best_streak INTEGER DEFAULT 0,
        last_completed TIMESTAMP,
        status VARCHAR(50) DEFAULT 'active',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // ------------------ Habit-Goal Links Table ------------------
    await client.query(`
      CREATE TABLE IF NOT EXISTS habit_goal_links (
        habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
        goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (habit_id, goal_id)
      );
    `);

    // ------------------ Focus Sessions Table ------------------
    await client.query(`
      CREATE TABLE IF NOT EXISTS focus_sessions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
        duration_minutes INTEGER NOT NULL,
        was_completed BOOLEAN DEFAULT false,
        completed_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // ------------------ Achievements Table ------------------
    await client.query(`
      CREATE TABLE IF NOT EXISTS achievements (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        achievement_type VARCHAR(100) NOT NULL,
        earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, achievement_type)
      );
    `);

    // ------------------ Dream Profiles Table ------------------
    await client.query(`
      CREATE TABLE IF NOT EXISTS dream_profiles (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        vision_statement TEXT,
        core_values TEXT,
        three_year_goal TEXT,
        identity_statements JSONB DEFAULT '[]',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // ------------------ Reflections Table ------------------
    await client.query(`
      CREATE TABLE IF NOT EXISTS reflections (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        content TEXT,
        mood VARCHAR(50),
        insights TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // ------------------ Indexes ------------------
    await client.query('CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);');
    await client.query('CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);');
    await client.query('CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);');
    await client.query('CREATE INDEX IF NOT EXISTS idx_focus_sessions_user_id ON focus_sessions(user_id);');
    await client.query('CREATE INDEX IF NOT EXISTS idx_achievements_user_id ON achievements(user_id);');
    await client.query('CREATE INDEX IF NOT EXISTS idx_reflections_user_id ON reflections(user_id);');

    client.release();
    console.log('Database initialized successfully');
  } catch (error) {
    console.error('Error initializing database:', error);
  }
}

// ------------------ Helpers ------------------
export function getPool() {
  return pool;
}

export async function query(text, params) {
  return pool.query(text, params);
}

export async function getClient() {
  return pool.connect();
}

export { pool as db };