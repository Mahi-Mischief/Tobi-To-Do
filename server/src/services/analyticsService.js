import { db } from '../config/database.js';

/**
 * Get user's completion rate for tasks
 */
export async function getTaskCompletionRate(userId, days = 30) {
  const query = `
    SELECT
      COUNT(*) as total,
      COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed
    FROM tasks
    WHERE user_id = $1
    AND created_at >= NOW() - INTERVAL '${days} days'
  `;

  const result = await db.query(query, [userId]);
  const { total, completed } = result.rows[0];

  return total > 0 ? Math.round((completed / total) * 100) : 0;
}

/**
 * Get habit consistency rate (% days habits were completed)
 */
export async function getHabitConsistency(userId, days = 7) {
  const query = `
    SELECT
      COUNT(*) as total,
      COUNT(CASE WHEN last_completed >= NOW() - INTERVAL '${days} days' THEN 1 END) as recent
    FROM habits
    WHERE user_id = $1
  `;

  const result = await db.query(query, [userId]);
  const { total, recent } = result.rows[0];

  return total > 0 ? Math.round((recent / total) * 100) : 0;
}

/**
 * Get goal completion trends
 */
export async function getGoalTrends(userId, days = 90) {
  const query = `
    SELECT
      DATE(created_at) as date,
      COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed,
      COUNT(*) as total
    FROM goals
    WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '${days} days'
    GROUP BY DATE(created_at)
    ORDER BY date ASC
  `;

  const result = await db.query(query, [userId]);

  return result.rows.map((row) => ({
    date: row.date.toISOString().split('T')[0],
    completionRate: row.total > 0 ? Math.round((row.completed / row.total) * 100) : 0,
    completed: row.completed,
    total: row.total,
  }));
}

/**
 * Get productivity heatmap (activity by day of week and hour)
 */
export async function getProductivityHeatmap(userId, weeks = 4) {
  const query = `
    SELECT
      EXTRACT(DOW FROM completed_at)::int as day_of_week,
      EXTRACT(HOUR FROM completed_at)::int as hour,
      COUNT(*) as count
    FROM tasks
    WHERE user_id = $1
    AND completed_at IS NOT NULL
    AND completed_at >= NOW() - INTERVAL '${weeks} weeks'
    GROUP BY day_of_week, hour
    ORDER BY day_of_week, hour
  `;

  const result = await db.query(query, [userId]);

  // Create heatmap grid (7 days × 24 hours)
  const heatmap = Array(7)
    .fill(null)
    .map(() => Array(24).fill(0));

  result.rows.forEach((row) => {
    heatmap[row.day_of_week][row.hour] = row.count;
  });

  return heatmap;
}

/**
 * Get weekly summary statistics
 */
export async function getWeeklySummary(userId) {
  const weekStart = new Date();
  weekStart.setDate(weekStart.getDate() - weekStart.getDay());
  weekStart.setHours(0, 0, 0, 0);

  const queries = {
    tasksCompleted: `
      SELECT COUNT(*) as count FROM tasks
      WHERE user_id = $1 AND status = 'completed'
      AND completed_at >= $2
    `,
    habitsCompleted: `
      SELECT COUNT(*) as count FROM habits
      WHERE user_id = $1 AND last_completed >= $2
    `,
    focusMinutes: `
      SELECT COALESCE(SUM(duration_minutes), 0) as total FROM focus_sessions
      WHERE user_id = $1 AND created_at >= $2
    `,
    goalsActive: `
      SELECT COUNT(*) as count FROM goals
      WHERE user_id = $1 AND status = 'in_progress'
    `,
  };

  const results = {
    tasksCompleted: (await db.query(queries.tasksCompleted, [userId, weekStart])).rows[0].count,
    habitsCompleted: (await db.query(queries.habitsCompleted, [userId, weekStart])).rows[0].count,
    focusMinutes: (await db.query(queries.focusMinutes, [userId, weekStart])).rows[0].total,
    goalsActive: (await db.query(queries.goalsActive, [userId])).rows[0].count,
  };

  return results;
}

/**
 * Get daily focus time
 */
export async function getDailyFocusTime(userId, days = 30) {
  const query = `
    SELECT
      DATE(created_at) as date,
      SUM(duration_minutes) as total_minutes
    FROM focus_sessions
    WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '${days} days'
    GROUP BY DATE(created_at)
    ORDER BY date ASC
  `;

  const result = await db.query(query, [userId]);

  return result.rows.map((row) => ({
    date: row.date.toISOString().split('T')[0],
    focusMinutes: row.total_minutes || 0,
  }));
}

/**
 * Get most productive time of day
 */
export async function getMostProductiveTime(userId, days = 30) {
  const query = `
    SELECT
      EXTRACT(HOUR FROM completed_at)::int as hour,
      COUNT(*) as count
    FROM tasks
    WHERE user_id = $1
    AND completed_at IS NOT NULL
    AND completed_at >= NOW() - INTERVAL '${days} days'
    GROUP BY hour
    ORDER BY count DESC
    LIMIT 1
  `;

  const result = await db.query(query, [userId]);

  if (result.rows.length === 0) {
    return null;
  }

  const hour = result.rows[0].hour;
  const period = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';

  return { hour, period, taskCount: result.rows[0].count };
}

/**
 * Get habit performance comparison
 */
export async function getHabitComparison(userId) {
  const query = `
    SELECT
      id,
      name,
      streak_count,
      best_streak,
      frequency,
      CASE
        WHEN frequency = 'daily' THEN 7
        WHEN frequency = 'weekly' THEN 1
        WHEN frequency = 'monthly' THEN 1
      END as max_expected,
      ROUND(
        (streak_count::float / CASE
          WHEN frequency = 'daily' THEN 7
          WHEN frequency = 'weekly' THEN 1
          WHEN frequency = 'monthly' THEN 1
        END) * 100, 2
      ) as consistency_percent
    FROM habits
    WHERE user_id = $1
    ORDER BY consistency_percent DESC
  `;

  const result = await db.query(query, [userId]);
  return result.rows;
}

/**
 * Get analytics dashboard data
 */
export async function getAnalyticsDashboard(userId) {
  const [
    taskRate,
    habitConsistency,
    weeklySummary,
    mostProductive,
    leaderboard,
  ] = await Promise.all([
    getTaskCompletionRate(userId),
    getHabitConsistency(userId),
    getWeeklySummary(userId),
    getMostProductiveTime(userId),
    getHabitComparison(userId),
  ]);

  return {
    taskCompletionRate: taskRate,
    habitConsistency,
    weeklySummary,
    mostProductiveTime: mostProductive,
    habitPerformance: leaderboard,
  };
}

/**
 * Get goal progress tracking
 */
export async function getGoalProgressTracking(userId) {
  const query = `
    SELECT
      id,
      title,
      category,
      progress_percent,
      deadline,
      status,
      CASE
        WHEN status = 'completed' THEN 'complete'
        WHEN deadline < NOW() THEN 'overdue'
        WHEN deadline < NOW() + INTERVAL '7 days' THEN 'urgent'
        ELSE 'on_track'
      END as urgency
    FROM goals
    WHERE user_id = $1
    ORDER BY urgency DESC, deadline ASC
  `;

  const result = await db.query(query, [userId]);

  return result.rows.map((row) => ({
    ...row,
    daysUntilDeadline: Math.ceil(
      (new Date(row.deadline) - new Date()) / (1000 * 60 * 60 * 24)
    ),
  }));
}

/**
 * Get engagement metrics
 */
export async function getEngagementMetrics(userId) {
  const query = `
    SELECT
      (SELECT COUNT(*) FROM tasks WHERE user_id = $1) as total_tasks,
      (SELECT COUNT(*) FROM habits WHERE user_id = $1) as total_habits,
      (SELECT COUNT(*) FROM goals WHERE user_id = $1) as total_goals,
      (SELECT COALESCE(AVG(daily_count), 0) FROM (
        SELECT DATE(created_at) as date, COUNT(*) as daily_count
        FROM tasks WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '30 days'
        GROUP BY date
      ) t) as avg_tasks_per_day,
      (SELECT COUNT(DISTINCT DATE(completed_at)) FROM tasks
        WHERE user_id = $1 AND completed_at >= NOW() - INTERVAL '30 days') as active_days_last_month
  `;

  const result = await db.query(query, [userId]);

  if (result.rows.length === 0) {
    return {};
  }

  const row = result.rows[0];

  return {
    totalTasks: row.total_tasks,
    totalHabits: row.total_habits,
    totalGoals: row.total_goals,
    avgTasksPerDay: Math.round(row.avg_tasks_per_day * 100) / 100,
    activeLastMonth: row.active_days_last_month,
  };
}
