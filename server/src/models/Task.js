// Task Model Schema
export const TaskSchema = {
  tableName: 'tasks',
  columns: {
    id: 'UUID PRIMARY KEY DEFAULT gen_random_uuid()',
    user_id: 'UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE',
    title: 'VARCHAR(255) NOT NULL',
    description: 'TEXT',
    due_date: 'TIMESTAMP',
    priority: "VARCHAR(20) DEFAULT 'medium'",
    category: "VARCHAR(50) DEFAULT 'general'",
    status: "VARCHAR(50) DEFAULT 'todo'",
    completed: 'BOOLEAN DEFAULT false',
    completed_at: 'TIMESTAMP',
    duration_minutes: 'INTEGER',
    created_at: 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP',
    updated_at: 'TIMESTAMP DEFAULT CURRENT_TIMESTAMP'
  }
};

export class Task {
  constructor(data) {
    this.id = data.id;
    this.user_id = data.user_id;
    this.title = data.title;
    this.description = data.description;
    this.due_date = data.due_date;
    this.priority = data.priority || 'medium';
    this.category = data.category || 'general';
    this.status = data.status || 'todo';
    this.completed = data.completed || false;
    this.completed_at = data.completed_at;
    this.duration_minutes = data.duration_minutes;
    this.created_at = data.created_at;
    this.updated_at = data.updated_at;
  }

  toJSON() {
    return {
      id: this.id,
      user_id: this.user_id,
      title: this.title,
      description: this.description,
      due_date: this.due_date,
      priority: this.priority,
      category: this.category,
      status: this.status,
      completed: this.completed,
      completed_at: this.completed_at,
      duration_minutes: this.duration_minutes,
      created_at: this.created_at,
      updated_at: this.updated_at
    };
  }
}
