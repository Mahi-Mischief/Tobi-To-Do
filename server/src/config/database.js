import pkg from 'pg';
const { Pool } = pkg;

// PostgreSQL connection pool (Supabase compatible)
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'postgres',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || 'password',
  // SSL required for Supabase
  ssl: process.env.DB_SSL === 'true' || process.env.DB_HOST?.includes('supabase') ? {
    rejectUnauthorized: false
  } : false,
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle client', err);
});

// Initialize database tables if they don't exist
export async function initializeDatabase() {
  try {
    const client = await pool.connect();
    
    // Create users table
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

    // Create tasks table
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

    // Create goals table
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

    // Create habits table
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

    // Create habit_goal_links table (junction table)
    await client.query(`
      CREATE TABLE IF NOT EXISTS habit_goal_links (
        habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
        goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (habit_id, goal_id)
      );
    `);

    // Create focus_sessions table
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

    // Create achievements table
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

    // Create dream_profiles table
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

    // Create reflections table
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

    // Create indexes for better performance
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
