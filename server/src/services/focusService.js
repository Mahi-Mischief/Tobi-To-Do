import { db } from '../config/database.js';
import { generateId } from '../utils/helpers.js';

/**
 * Start a focus session
 * @param {string} userId
 * @param {string} taskId - optional task to focus on
 * @param {number} durationMinutes
 */
export async function startFocusSession(userId, taskId, durationMinutes) {
  const sessionId = generateId();

  const query = `
    INSERT INTO focus_sessions (id, user_id, task_id, duration_minutes, created_at)
    VALUES ($1, $2, $3, $4, NOW())
    RETURNING *
  `;

  const result = await db.query(query, [sessionId, userId, taskId || null, durationMinutes]);

  return result.rows[0];
}

/**
 * End a focus session
 * @param {string} sessionId
 * @param {boolean} completed - whether user completed the session
 */
export async function endFocusSession(sessionId, completed = true) {
  const query = `
    UPDATE focus_sessions
    SET completed_at = NOW(), was_completed = $1
    WHERE id = $2
    RETURNING *
  `;

  const result = await db.query(query, [completed, sessionId]);

  if (result.rows.length === 0) {
    throw new Error('Focus session not found');
  }

  // Award XP if completed
  if (completed && result.rows[0].duration_minutes >= 25) {
    const xp = Math.ceil(result.rows[0].duration_minutes / 5); // 1 XP per 5 minutes
    const { awardXP } = await import('./gamificationService.js');
    await awardXP(result.rows[0].user_id, xp, 'focus_session');
  }

  return result.rows[0];
}

/**
 * Get focus session history
 */
export async function getFocusHistory(userId, limit = 50) {
  const query = `
    SELECT id, task_id, duration_minutes, created_at, completed_at, was_completed
    FROM focus_sessions
    WHERE user_id = $1 AND completed_at IS NOT NULL
    ORDER BY completed_at DESC
    LIMIT $2
  `;

  const result = await db.query(query, [userId, limit]);
  return result.rows;
}

/**
 * Get focus stats for a user
 */
export async function getFocusStats(userId, days = 30) {
  const query = `
    SELECT
      COUNT(*) as total_sessions,
      COUNT(CASE WHEN was_completed = true THEN 1 END) as completed_sessions,
      COALESCE(SUM(duration_minutes), 0) as total_minutes,
      ROUND(COALESCE(AVG(duration_minutes), 0), 2) as avg_duration,
      ROUND(
        COUNT(CASE WHEN was_completed = true THEN 1 END)::float / NULLIF(COUNT(*), 0) * 100,
        2
      ) as completion_rate
    FROM focus_sessions
    WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '${days} days'
  `;

  const result = await db.query(query, [userId]);

  if (result.rows.length === 0) {
    return {
      totalSessions: 0,
      completedSessions: 0,
      totalMinutes: 0,
      avgDuration: 0,
      completionRate: 0,
    };
  }

  const row = result.rows[0];

  return {
    totalSessions: row.total_sessions,
    completedSessions: row.completed_sessions,
    totalMinutes: row.total_minutes,
    avgDuration: row.avg_duration,
    completionRate: row.completion_rate || 0,
  };
}

/**
 * Detect burnout based on focus patterns
 * Returns burnout level (none, mild, moderate, severe)
 */
export async function detectBurnout(userId) {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  // Get daily focus times for last 30 days
  const focusQuery = `
    SELECT
      DATE(created_at) as date,
      SUM(duration_minutes) as total_minutes,
      COUNT(*) as session_count
    FROM focus_sessions
    WHERE user_id = $1 AND created_at >= $2
    GROUP BY DATE(created_at)
  `;

  const focusResult = await db.query(focusQuery, [userId, thirtyDaysAgo]);

  // Get task completion rates
  const taskQuery = `
    SELECT
      DATE(created_at) as date,
      COUNT(CASE WHEN status = 'completed' THEN 1 END) as completed
    FROM tasks
    WHERE user_id = $1 AND created_at >= $2
    GROUP BY DATE(created_at)
  `;

  const taskResult = await db.query(taskQuery, [userId, thirtyDaysAgo]);

  // Calculate metrics
  const focusData = focusResult.rows;
  const taskData = taskResult.rows;

  if (focusData.length === 0) {
    return { level: 'none', score: 0, factors: [] };
  }

  let burnoutScore = 0;
  const factors = [];

  // Factor 1: Average daily focus time over 8 hours
  const avgDailyFocus =
    focusData.reduce((sum, d) => sum + d.total_minutes, 0) / focusData.length;
  if (avgDailyFocus > 480) {
    // 8 hours
    burnoutScore += 30;
    factors.push('excessive_focus_time');
  }

  // Factor 2: Declining completion rate (moving average)
  const firstHalf = taskData.slice(0, Math.floor(taskData.length / 2));
  const secondHalf = taskData.slice(Math.floor(taskData.length / 2));

  if (firstHalf.length > 0 && secondHalf.length > 0) {
    const firstAvg =
      firstHalf.reduce((sum, d) => sum + d.completed, 0) / firstHalf.length;
    const secondAvg =
      secondHalf.reduce((sum, d) => sum + d.completed, 0) / secondHalf.length;

    if (secondAvg < firstAvg * 0.7) {
      // 30% decline
      burnoutScore += 25;
      factors.push('declining_completion');
    }
  }

  // Factor 3: Inconsistent focus sessions (high variance)
  const avgDuration =
    focusData.reduce((sum, d) => sum + d.total_minutes, 0) / focusData.length;
  const variance =
    focusData.reduce((sum, d) => sum + Math.pow(d.total_minutes - avgDuration, 2), 0) /
    focusData.length;
  const stdDev = Math.sqrt(variance);

  if (stdDev > avgDuration * 0.5) {
    burnoutScore += 20;
    factors.push('inconsistent_focus');
  }

  // Factor 4: Reduced number of days with focus sessions
  const activeDays = focusData.length;
  if (activeDays < 10) {
    burnoutScore += 15;
    factors.push('low_activity_days');
  }

  // Factor 5: Late night focus sessions (after 10pm or before 6am)
  const lateNightQuery = `
    SELECT COUNT(*) as count FROM focus_sessions
    WHERE user_id = $1
    AND created_at >= $2
    AND (EXTRACT(HOUR FROM created_at) < 6 OR EXTRACT(HOUR FROM created_at) >= 22)
  `;

  const lateNightResult = await db.query(lateNightQuery, [userId, thirtyDaysAgo]);
  const lateNightSessions = lateNightResult.rows[0].count;

  if (lateNightSessions > focusData.length * 2) {
    // More than 20% late night
    burnoutScore += 10;
    factors.push('irregular_sleep');
  }

  // Determine burnout level
  let level = 'none';
  if (burnoutScore >= 75) {
    level = 'severe';
  } else if (burnoutScore >= 50) {
    level = 'moderate';
  } else if (burnoutScore >= 25) {
    level = 'mild';
  }

  return { level, score: burnoutScore, factors };
}

/**
 * Get burnout recovery recommendations
 */
export async function getBurnoutRecovery(userId) {
  const burnout = await detectBurnout(userId);

  const recommendations = {
    none: ['Keep up your great balance!', 'Continue your current routine'],
    mild: [
      'Consider taking short breaks between sessions',
      'Aim for more consistent daily schedules',
      'Ensure you have time for personal activities',
    ],
    moderate: [
      'Take 1-2 days off this week',
      'Reduce daily focus time by 1-2 hours',
      'Prioritize only your most important tasks',
      'Get more sleep - aim for 8 hours',
    ],
    severe: [
      'IMPORTANT: Take at least 2-3 days off this week',
      'Reduce your workload significantly',
      'Take breaks every 25 minutes (Pomodoro technique)',
      'Get professional support if needed',
      'Focus on self-care and rest',
    ],
  };

  return {
    burnoutLevel: burnout.level,
    burnoutScore: burnout.score,
    factors: burnout.factors,
    recommendations: recommendations[burnout.level],
  };
}

/**
 * Get current active focus session
 */
export async function getActiveFocusSession(userId) {
  const query = `
    SELECT * FROM focus_sessions
    WHERE user_id = $1 AND completed_at IS NULL
    ORDER BY created_at DESC
    LIMIT 1
  `;

  const result = await db.query(query, [userId]);

  if (result.rows.length === 0) {
    return null;
  }

  const session = result.rows[0];
  const elapsedMinutes = Math.floor((Date.now() - session.created_at) / 1000 / 60);
  const remainingMinutes = session.duration_minutes - elapsedMinutes;

  return {
    ...session,
    elapsedMinutes,
    remainingMinutes: Math.max(remainingMinutes, 0),
    isExpired: remainingMinutes <= 0,
  };
}

/**
 * Get focus streak (consecutive days with focus sessions)
 */
export async function getFocusStreak(userId) {
  const query = `
    WITH daily_sessions AS (
      SELECT DISTINCT DATE(created_at) as date
      FROM focus_sessions
      WHERE user_id = $1 AND completed_at IS NOT NULL
      ORDER BY date DESC
    ),
    consecutive_groups AS (
      SELECT
        date,
        ROW_NUMBER() OVER (ORDER BY date DESC) as rn,
        DATE(date - ROW_NUMBER() OVER (ORDER BY date DESC) * INTERVAL '1 day') as group_date
      FROM daily_sessions
    )
    SELECT COUNT(*) as streak_count
    FROM consecutive_groups
    WHERE group_date = (SELECT MIN(group_date) FROM consecutive_groups)
  `;

  const result = await db.query(query, [userId]);

  return result.rows[0]?.streak_count || 0;
}
