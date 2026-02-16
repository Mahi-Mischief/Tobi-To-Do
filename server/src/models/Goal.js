// Goal Model Schema
export const GoalSchema = {
  tableName: 'goals',
  columns: {
    id: 'UUID PRIMARY KEY DEFAULT gen_random_uuid()',
    user_id: 'UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE',
    title: 'VARCHAR(255) NOT NULL',
    description: 'TEXT',
    category: "VARCHAR(50) DEFAULT 'personal'",
    target_date: 'TIMESTAMP',
    progress_percentage: 'INTEGER DEFAULT 0',
    status: "VARCHAR(50) DEFAULT 'active'",
    created_at: 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
    updated_at: 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP'
  }
};

export class Goal {
  constructor(data) {
    this.id = data.id;
    this.user_id = data.user_id;
    this.title = data.title;
    this.description = data.description;
    this.category = data.category || 'personal';
    this.target_date = data.target_date;
    this.progress_percentage = data.progress_percentage || 0;
    this.status = data.status || 'active';
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }
}
