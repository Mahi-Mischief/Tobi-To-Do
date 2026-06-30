// Habit Model Schema
export const HabitSchema = {
  tableName: 'habits',
  columns: {
    id: 'UUID PRIMARY KEY DEFAULT gen_random_uuid()',
    user_id: 'UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE',
    title: 'VARCHAR(255) NOT NULL',
    description: 'TEXT',
    frequency: "VARCHAR(50) DEFAULT 'daily'",
    streak_count: 'INTEGER DEFAULT 0',
    best_streak: 'INTEGER DEFAULT 0',
    status: "VARCHAR(50) DEFAULT 'active'",
    created_at: 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
    updated_at: 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP'
  }
};

export class Habit {
  constructor(data) {
    this.id = data.id;
    this.user_id = data.user_id;
    this.name = data.name || data.title;
    this.title = data.title || data.name; // backward compatibility
    this.description = data.description;
    this.frequency = data.frequency || 'daily';
    this.streak_count = data.streak_count ?? data.streakCount ?? 0;
    this.streakCount = this.streak_count;
    this.best_streak = data.best_streak ?? data.bestStreak ?? 0;
    this.bestStreak = this.best_streak;
    this.last_completed = data.last_completed || data.lastCompleted || null;
    this.lastCompleted = this.last_completed;
    this.status = data.status || 'active';
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}
