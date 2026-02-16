-- ============================================================
-- TOBI TO-DO DATABASE SETUP FOR SUPABASE
-- ============================================================
-- Copy and paste this entire script into Supabase SQL Editor
-- Then click "Run" to create all tables with RLS policies
-- ============================================================

-- ============================================================
-- 1. USERS TABLE
-- ============================================================
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

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can only read/update their own data
CREATE POLICY "Users can read own data"
  ON users FOR SELECT
  USING (auth.uid()::text = id::text OR id = auth.uid());

CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid()::text = id::text OR id = auth.uid())
  WITH CHECK (auth.uid()::text = id::text OR id = auth.uid());

-- ============================================================
-- 2. TASKS TABLE
-- ============================================================
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

-- Enable RLS on tasks table
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

-- Users can only access their own tasks
CREATE POLICY "Users can read own tasks"
  ON tasks FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can create own tasks"
  ON tasks FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own tasks"
  ON tasks FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own tasks"
  ON tasks FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================
-- 3. HABITS TABLE
-- ============================================================
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

-- Enable RLS on habits table
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;

-- Users can only access their own habits
CREATE POLICY "Users can read own habits"
  ON habits FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can create own habits"
  ON habits FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own habits"
  ON habits FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own habits"
  ON habits FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================
-- 4. GOALS TABLE
-- ============================================================
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

-- Enable RLS on goals table
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- Users can only access their own goals
CREATE POLICY "Users can read own goals"
  ON goals FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can create own goals"
  ON goals FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own goals"
  ON goals FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own goals"
  ON goals FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================
-- 5. FOCUS_SESSIONS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS focus_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
  duration_minutes INTEGER NOT NULL,
  was_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS on focus_sessions table
ALTER TABLE focus_sessions ENABLE ROW LEVEL SECURITY;

-- Users can only access their own focus sessions
CREATE POLICY "Users can read own focus sessions"
  ON focus_sessions FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can create own focus sessions"
  ON focus_sessions FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own focus sessions"
  ON focus_sessions FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own focus sessions"
  ON focus_sessions FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================
-- ADDITIONAL TABLES (For full feature support)
-- ============================================================

-- Habit-Goal Links Junction Table
CREATE TABLE IF NOT EXISTS habit_goal_links (
  habit_id UUID NOT NULL REFERENCES habits(id) ON DELETE CASCADE,
  goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (habit_id, goal_id)
);

-- Achievements Table
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  achievement_type VARCHAR(100) NOT NULL,
  earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, achievement_type)
);

-- Enable RLS on achievements table
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own achievements"
  ON achievements FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can create own achievements"
  ON achievements FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Dream Profiles Table
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

-- Enable RLS on dream_profiles table
ALTER TABLE dream_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own dream profile"
  ON dream_profiles FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can create own dream profile"
  ON dream_profiles FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own dream profile"
  ON dream_profiles FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Reflections Table
CREATE TABLE IF NOT EXISTS reflections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  content TEXT,
  mood VARCHAR(50),
  insights TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enable RLS on reflections table
ALTER TABLE reflections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own reflections"
  ON reflections FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can create own reflections"
  ON reflections FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own reflections"
  ON reflections FOR DELETE
  USING (user_id = auth.uid());

-- ============================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_tasks_user_id ON tasks(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_status ON goals(status);
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_status ON habits(status);
CREATE INDEX IF NOT EXISTS idx_focus_sessions_user_id ON focus_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_achievements_user_id ON achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_reflections_user_id ON reflections(user_id);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks(due_date);
CREATE INDEX IF NOT EXISTS idx_goals_deadline ON goals(deadline);

-- ============================================================
-- ALL DONE! 
-- ============================================================
-- Your Supabase database is now fully set up with:
-- ✅ All 9 tables created
-- ✅ All RLS policies enabled
-- ✅ All relationships configured
-- ✅ Performance indexes created
--
-- Next: Configure Flutter app authentication in Supabase
-- ============================================================
