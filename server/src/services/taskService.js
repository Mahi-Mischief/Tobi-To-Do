import { query } from '../config/database.js';

export class TaskService {
  // Create task
  static async createTask(userId, taskData) {
    try {
      const { title, description, due_date, priority = 'medium', category = 'general' } = taskData;
      
      const result = await query(
        `INSERT INTO tasks (user_id, title, description, due_date, priority, category, status) 
         VALUES ($1, $2, $3, $4, $5, $6, 'todo') 
         RETURNING *`,
        [userId, title, description, due_date, priority, category]
      );

      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  // Get all tasks for user
  static async getTasks(userId, filter = {}) {
    try {
      let baseQuery = 'SELECT * FROM tasks WHERE user_id = $1';
      const params = [userId];
      let paramIndex = 2;

      // Apply filters
      if (filter.status) {
        baseQuery += ` AND status = $${paramIndex}`;
        params.push(filter.status);
        paramIndex++;
      }

      if (filter.priority) {
        baseQuery += ` AND priority = $${paramIndex}`;
        params.push(filter.priority);
        paramIndex++;
      }

      if (filter.completed !== undefined) {
        baseQuery += ` AND completed = $${paramIndex}`;
        params.push(filter.completed);
        paramIndex++;
      }

      baseQuery += ' ORDER BY due_date ASC, created_at DESC';

      const result = await query(baseQuery, params);
      return result.rows;
    } catch (error) {
      throw error;
    }
  }

  // Get task by ID
  static async getTaskById(userId, taskId) {
    try {
      const result = await query(
        'SELECT * FROM tasks WHERE id = $1 AND user_id = $2',
        [taskId, userId]
      );

      if (result.rows.length === 0) {
        throw new Error('Task not found');
      }

      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  // Update task
  static async updateTask(userId, taskId, updates) {
    try {
      const allowedFields = ['title', 'description', 'due_date', 'priority', 'category', 'status', 'completed', 'duration_minutes', 'ai_breakdown'];
      const updateFields = [];
      const updateValues = [];
      let paramIndex = 1;

      allowedFields.forEach(field => {
        if (field in updates) {
          updateFields.push(`${field} = $${paramIndex}`);
          if (field === 'completed') {
            updateValues.push(updates[field]);
            // Also set completed_at when marking as complete
            if (updates[field] === true) {
              updateFields.push(`completed_at = $${paramIndex + 1}`);
              updateValues.push(new Date());
              paramIndex++;
            }
          } else {
            updateValues.push(updates[field]);
          }
          paramIndex++;
        }
      });

      if (updateFields.length === 0) {
        throw new Error('No valid fields to update');
      }

      updateFields.push(`updated_at = $${paramIndex}`);
      updateValues.push(new Date());
      updateValues.push(taskId);
      updateValues.push(userId);

      const result = await query(
        `UPDATE tasks SET ${updateFields.join(', ')} 
         WHERE id = $${paramIndex + 1} AND user_id = $${paramIndex + 2} 
         RETURNING *`,
        updateValues
      );

      if (result.rows.length === 0) {
        throw new Error('Task not found');
      }

      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  // Delete task
  static async deleteTask(userId, taskId) {
    try {
      const result = await query(
        'DELETE FROM tasks WHERE id = $1 AND user_id = $2 RETURNING id',
        [taskId, userId]
      );

      if (result.rows.length === 0) {
        throw new Error('Task not found');
      }

      return { success: true, id: taskId };
    } catch (error) {
      throw error;
    }
  }

  // Get dashboard stats
  static async getDashboardStats(userId) {
    try {
      const result = await query(
        `SELECT 
          COUNT(*) as total_tasks,
          SUM(CASE WHEN completed = true THEN 1 ELSE 0 END) as completed_tasks,
          SUM(CASE WHEN priority = 'high' AND completed = false THEN 1 ELSE 0 END) as high_priority_tasks,
          SUM(CASE WHEN status = 'todo' THEN 1 ELSE 0 END) as todo_count,
          SUM(CASE WHEN status = 'in_progress' THEN 1 ELSE 0 END) as in_progress_count
         FROM tasks 
         WHERE user_id = $1`,
        [userId]
      );

      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }
}
