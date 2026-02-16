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
    this.title = data.title;
    this.description = data.description;
    this.frequency = data.frequency || 'daily';
    this.streak_count = data.streak_count || 0;
    this.best_streak = data.best_streak || 0;
    this.status = data.status || 'active';
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}
