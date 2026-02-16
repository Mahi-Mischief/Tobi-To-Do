import { db } from '../config/database.js';
import { Habit } from '../models/Habit.js';
import { generateId, getCurrentTimestamp } from '../utils/helpers.js';

/**
 * Create a new habit for a user
 */
export async function createHabit(userId, habitData) {
  const query = `
    INSERT INTO habits (id, user_id, name, frequency)
    VALUES ($1, $2, $3, $4)
    RETURNING *
  `;

  const result = await db.query(query, [
    generateId(),
    userId,
    habitData.name,
    habitData.frequency || 'daily',
  ]);

  return new Habit(result.rows[0]);
}

/**
 * Get all habits for a user
 */
export async function getHabits(userId) {
  const query = `
    SELECT * FROM habits
    WHERE user_id = $1
    ORDER BY created_at DESC
  `;

  const result = await db.query(query, [userId]);
  return result.rows.map((row) => new Habit(row));
}

/**
 * Get a single habit by ID
 */
export async function getHabitById(habitId) {
  const query = `
    SELECT * FROM habits WHERE id = $1
  `;

  const result = await db.query(query, [habitId]);

  if (result.rows.length === 0) {
    throw new Error('Habit not found');
  }

  return new Habit(result.rows[0]);
}

/**
 * Update habit details
 */
export async function updateHabit(habitId, updates) {
  const allowedFields = ['name', 'frequency'];
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
    return getHabitById(habitId);
  }

  values.push(habitId);
  const query = `
    UPDATE habits
    SET ${fields.join(', ')}, updated_at = NOW()
    WHERE id = $${paramCount}
    RETURNING *
  `;

  const result = await db.query(query, values);
  return new Habit(result.rows[0]);
}

/**
 * Delete a habit
 */
export async function deleteHabit(habitId) {
  const query = `DELETE FROM habits WHERE id = $1`;
  await db.query(query, [habitId]);
  return { message: 'Habit deleted' };
}

/**
 * Mark habit as completed today
 */
export async function completeHabit(habitId) {
  const habit = await getHabitById(habitId);

  const lastCompleted = habit.lastCompleted
    ? new Date(habit.lastCompleted)
    : null;
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  let newStreak = habit.streakCount;

  if (!lastCompleted) {
    // First time completing
    newStreak = 1;
  } else {
    const lastCompletedDate = new Date(lastCompleted);
    lastCompletedDate.setHours(0, 0, 0, 0);

    const daysDifference = Math.floor(
      (today - lastCompletedDate) / (1000 * 60 * 60 * 24)
    );

    if (daysDifference === 0) {
      // Already completed today
      return new Habit(habit);
    } else if (daysDifference === 1) {
      // Completed yesterday - increment streak
      newStreak = habit.streakCount + 1;
    } else {
      // Streak broken - reset to 1
      newStreak = 1;
    }
  }

  // Update best_streak if current streak is better
  const newBestStreak = Math.max(habit.bestStreak || 0, newStreak);

  const query = `
    UPDATE habits
    SET 
      streak_count = $1,
      best_streak = $2,
      last_completed = NOW(),
      updated_at = NOW()
    WHERE id = $3
    RETURNING *
  `;

  const result = await db.query(query, [newStreak, newBestStreak, habitId]);
  return new Habit(result.rows[0]);
}

/**
 * Reset habit streak
 */
export async function resetStreak(habitId) {
  const query = `
    UPDATE habits
    SET streak_count = 0, updated_at = NOW()
    WHERE id = $1
    RETURNING *
  `;

  const result = await db.query(query, [habitId]);
  return new Habit(result.rows[0]);
}

/**
 * Get streaks summary for dashboard
 */
export async function getStreaksSummary(userId) {
  const query = `
    SELECT id, name, streak_count, best_streak, frequency
    FROM habits
    WHERE user_id = $1
    ORDER BY streak_count DESC
    LIMIT 5
  `;

  const result = await db.query(query, [userId]);
  return result.rows;
}

/**
 * Get habits due today
 */
export async function getHabitsDueToday(userId) {
  const query = `
    SELECT * FROM habits
    WHERE user_id = $1
    AND (
      frequency = 'daily'
      OR (frequency = 'weekly' AND EXTRACT(dow FROM NOW()) = 
          EXTRACT(dow FROM last_completed))
      OR (frequency = 'monthly' AND EXTRACT(day FROM NOW()) = 
          EXTRACT(day FROM last_completed))
    )
    ORDER BY name ASC
  `;

  const result = await db.query(query, [userId]);
  return result.rows.map((row) => new Habit(row));
}

/**
 * Get habit statistics for a user
 */
export async function getHabitStats(userId) {
  const query = `
    SELECT
      COUNT(*) as total_habits,
      AVG(streak_count) as avg_streak,
      MAX(best_streak) as best_streak_overall,
      SUM(CASE WHEN streak_count > 0 THEN 1 ELSE 0 END) as active_streaks
    FROM habits
    WHERE user_id = $1
  `;

  const result = await db.query(query, [userId]);
  return result.rows[0];
}

/**
 * Get habit consistency (percentage of completion last 7 days)
 */
export async function getHabitConsistency(userId) {
  const query = `
    SELECT
      h.id,
      h.name,
      COUNT(DISTINCT DATE(h.last_completed)) as days_completed,
      ROUND(
        (COUNT(DISTINCT DATE(h.last_completed)) / 7.0 * 100)::numeric,
        2
      ) as consistency_percent
    FROM habits h
    WHERE h.user_id = $1
    AND h.last_completed >= NOW() - INTERVAL '7 days'
    GROUP BY h.id, h.name
    ORDER BY consistency_percent DESC
  `;

  const result = await db.query(query, [userId]);
  return result.rows;
}
