import { db } from '../config/database.js';
import { Goal } from '../models/Goal.js';
import { generateId } from '../utils/helpers.js';

/**
 * Create a new goal
 */
export async function createGoal(userId, goalData) {
  const query = `
    INSERT INTO goals (id, user_id, title, description, category, deadline, status)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    RETURNING *
  `;

  const result = await db.query(query, [
    generateId(),
    userId,
    goalData.title,
    goalData.description || null,
    goalData.category || 'personal',
    goalData.deadline || null,
    'active',
  ]);

  return new Goal(result.rows[0]);
}

/**
 * Get all goals for a user
 */
export async function getGoals(userId, status = null) {
  let query = `
    SELECT * FROM goals
    WHERE user_id = $1
  `;

  const params = [userId];

  if (status) {
    query += ` AND status = $2`;
    params.push(status);
  }

  query += ` ORDER BY created_at DESC`;

  const result = await db.query(query, params);
  return result.rows.map((row) => new Goal(row));
}

/**
 * Get a single goal by ID
 */
export async function getGoalById(goalId) {
  const query = `SELECT * FROM goals WHERE id = $1`;

  const result = await db.query(query, [goalId]);

  if (result.rows.length === 0) {
    throw new Error('Goal not found');
  }

  return new Goal(result.rows[0]);
}

/**
 * Update goal progress
 */
export async function updateGoal(goalId, updates) {
  const allowedFields = ['title', 'description', 'progress_percent', 'status'];
  const fields = [];
  const values = [];
  let paramCount = 1;

  for (const key of allowedFields) {
    if (key in updates) {
      fields.push(`${key} = $${paramCount}`);
      values.push(updates[key]);
      paramCount++;
    }
  }

  if (fields.length === 0) {
    return getGoalById(goalId);
  }

  values.push(goalId);
  const query = `
    UPDATE goals
    SET ${fields.join(', ')}, updated_at = NOW()
    WHERE id = $${paramCount}
    RETURNING *
  `;

  const result = await db.query(query, values);
  return new Goal(result.rows[0]);
}

/**
 * Delete a goal
 */
export async function deleteGoal(goalId) {
  const query = `DELETE FROM goals WHERE id = $1`;
  await db.query(query, [goalId]);
  return { message: 'Goal deleted' };
}

/**
 * Calculate goal probability of completion
 * Based on: progress, days remaining, historical completion rate
 */
export async function calculateGoalProbability(goalId, userId) {
  const goal = await getGoalById(goalId);

  if (!goal.deadline) {
    return 50; // No deadline = uncertain
  }

  // Days remaining
  const now = new Date();
  const deadline = new Date(goal.deadline);
  const daysRemaining = Math.floor((deadline - now) / (1000 * 60 * 60 * 24));

  if (daysRemaining <= 0) {
    return goal.progressPercent >= 100 ? 100 : 0;
  }

  // User completion rate (based on past completed goals)
  const userStatsQuery = `
    SELECT
      COUNT(*) as total_goals,
      COUNT(*) FILTER (WHERE status = 'completed') as completed_goals
    FROM goals WHERE user_id = $1
  `;

  const statsResult = await db.query(userStatsQuery, [userId]);
  const totalGoals = parseInt(statsResult.rows[0].total_goals);
  const completedGoals = parseInt(statsResult.rows[0].completed_goals);

  const completionRate = totalGoals > 0 ? completedGoals / totalGoals : 0.5;

  // Calculate probability
  // (progress/100) * 0.5 + (completion_rate) * 0.3 + (days_remaining_factor) * 0.2
  const progressFactor = Math.min(goal.progressPercent / 100, 1);
  const daysRemainFactor = Math.min(daysRemaining / 30, 1); // Assume 30 days ideal

  const probability =
    progressFactor * 0.5 + completionRate * 0.3 + daysRemainFactor * 0.2;

  return Math.round(Math.min(probability, 1) * 100);
}

/**
 * Link a habit to a goal
 */
export async function linkHabitToGoal(habitId, goalId) {
  // Create a junction table entry if not exists
  const query = `
    INSERT INTO habit_goal_links (id, habit_id, goal_id)
    VALUES ($1, $2, $3)
    ON CONFLICT DO NOTHING
  `;

  await db.query(query, [generateId(), habitId, goalId]);
  return { message: 'Habit linked to goal' };
}

/**
 * Get habits linked to a goal
 */
export async function getLinkedHabits(goalId) {
  const query = `
    SELECT h.* FROM habits h
    JOIN habit_goal_links hgl ON h.id = hgl.habit_id
    WHERE hgl.goal_id = $1
  `;

  const result = await db.query(query, [goalId]);
  return result.rows;
}

/**
 * Detect conflicting goals (same category, conflicting objectives)
 */
export async function detectGoalConflicts(userId) {
  const query = `
    SELECT
      g1.id as goal1_id,
      g1.title as goal1_title,
      g2.id as goal2_id,
      g2.title as goal2_title,
      g1.category
    FROM goals g1
    JOIN goals g2 ON g1.category = g2.category
    WHERE g1.user_id = $1
    AND g2.user_id = $1
    AND g1.id < g2.id
    AND g1.status = 'active'
    AND g2.status = 'active'
    ORDER BY g1.category
  `;

  const result = await db.query(query, [userId]);
  return result.rows;
}

/**
 * Get goal statistics
 */
export async function getGoalStats(userId) {
  const query = `
    SELECT
      COUNT(*) as total_goals,
      COUNT(*) FILTER (WHERE status = 'completed') as completed_goals,
      COUNT(*) FILTER (WHERE status = 'active') as active_goals,
      AVG(progress_percent) as avg_progress
    FROM goals
    WHERE user_id = $1
  `;

  const result = await db.query(query, [userId]);
  return result.rows[0];
}
