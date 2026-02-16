import { db } from '../config/database.js';
import { generateId } from '../utils/helpers.js';

/**
 * Award XP to a user
 * @param {string} userId
 * @param {number} amount - XP to award
 * @param {string} source - 'task', 'habit', 'focus', 'goal', etc.
 */
export async function awardXP(userId, amount, source = 'general') {
  const query = `
    UPDATE users
    SET xp = xp + $1, updated_at = NOW()
    WHERE id = $2
    RETURNING xp, level
  `;

  const result = await db.query(query, [amount, userId]);

  // Check if level up
  const newLevel = calculateLevel(result.rows[0].xp);
  const oldResult = await db.query(`SELECT level FROM users WHERE id = $1`, [
    userId,
  ]);
  const oldLevel = oldResult.rows[0].level;

  if (newLevel > oldLevel) {
    await updateLevel(userId, newLevel);
    return { xp: result.rows[0].xp, level: newLevel, levelUp: true };
  }

  return { xp: result.rows[0].xp, level: newLevel, levelUp: false };
}

/**
 * Calculate level from XP
 * Formula: level = floor(sqrt(xp / 100))
 */
export function calculateLevel(xp) {
  return Math.floor(Math.sqrt(xp / 100));
}

/**
 * Calculate XP needed for next level
 */
export function calculateXPForLevel(level) {
  return level * level * 100;
}

/**
 * Calculate progress to next level (0-100%)
 */
export function calculateLevelProgress(xp) {
  const currentLevel = calculateLevel(xp);
  const currentLevelXP = calculateXPForLevel(currentLevel);
  const nextLevelXP = calculateXPForLevel(currentLevel + 1);

  const progress = Math.round(
    ((xp - currentLevelXP) / (nextLevelXP - currentLevelXP)) * 100
  );

  return Math.min(Math.max(progress, 0), 100);
}

/**
 * Update user level
 */
export async function updateLevel(userId, level) {
  const query = `
    UPDATE users SET level = $1, updated_at = NOW()
    WHERE id = $2
  `;

  await db.query(query, [level, userId]);
}

/**
 * Record an achievement
 */
export async function recordAchievement(userId, achievementType) {
  // Check if already earned
  const checkQuery = `
    SELECT id FROM achievements
    WHERE user_id = $1 AND achievement_type = $2
  `;

  const existing = await db.query(checkQuery, [userId, achievementType]);

  if (existing.rows.length > 0) {
    return { message: 'Achievement already earned' };
  }

  // Award achievement
  const query = `
    INSERT INTO achievements (id, user_id, achievement_type, earned_at)
    VALUES ($1, $2, $3, NOW())
    RETURNING *
  `;

  const result = await db.query(query, [generateId(), userId, achievementType]);

  // Award bonus XP
  await awardXP(userId, 25, 'achievement');

  return result.rows[0];
}

/**
 * Get all achievements for a user
 */
export async function getAchievements(userId) {
  const query = `
    SELECT achievement_type, earned_at FROM achievements
    WHERE user_id = $1
    ORDER BY earned_at DESC
  `;

  const result = await db.query(query, [userId]);
  return result.rows;
}

/**
 * Check and award achievements based on conditions
 */
export async function checkAndAwardAchievements(userId) {
  const achievements = [];

  // Get user stats
  const userQuery = `
    SELECT xp, level FROM users WHERE id = $1
  `;
  const userResult = await db.query(userQuery, [userId]);
  const { xp, level } = userResult.rows[0];

  // First task achievement
  const tasksQuery = `
    SELECT COUNT(*) as total FROM tasks WHERE user_id = $1
  `;
  const tasksResult = await db.query(tasksQuery, [userId]);
  if (tasksResult.rows[0].total >= 1) {
    const achievement = await recordAchievement(userId, 'first_task');
    if (achievement.id) achievements.push('first_task');
  }

  // 7-day streak achievement
  const habitsQuery = `
    SELECT MAX(streak_count) as max_streak FROM habits WHERE user_id = $1
  `;
  const habitsResult = await db.query(habitsQuery, [userId]);
  if (habitsResult.rows[0].max_streak >= 7) {
    const achievement = await recordAchievement(userId, 'seven_day_streak');
    if (achievement.id) achievements.push('seven_day_streak');
  }

  // 100 XP achievement
  if (xp >= 100) {
    const achievement = await recordAchievement(userId, 'hundred_xp');
    if (achievement.id) achievements.push('hundred_xp');
  }

  // Level up achievements (every 5 levels)
  if (level > 0 && level % 5 === 0) {
    const achievement = await recordAchievement(
      userId,
      `level_${level}_reached`
    );
    if (achievement.id) achievements.push(`level_${level}_reached`);
  }

  // Goal completion achievement
  const goalsQuery = `
    SELECT COUNT(*) as completed FROM goals
    WHERE user_id = $1 AND status = 'completed'
  `;
  const goalsResult = await db.query(goalsQuery, [userId]);
  if (goalsResult.rows[0].completed >= 1) {
    const achievement = await recordAchievement(userId, 'first_goal');
    if (achievement.id) achievements.push('first_goal');
  }

  return achievements;
}

/**
 * Get user's gamification stats
 */
export async function getGamificationStats(userId) {
  const userQuery = `
    SELECT xp, level FROM users WHERE id = $1
  `;
  const userResult = await db.query(userQuery, [userId]);
  const { xp, level } = userResult.rows[0];

  const achievementsQuery = `
    SELECT COUNT(*) as total FROM achievements WHERE user_id = $1
  `;
  const achievementsResult = await db.query(achievementsQuery, [userId]);

  const streaksQuery = `
    SELECT COUNT(*) as active FROM habits
    WHERE user_id = $1 AND streak_count > 0
  `;
  const streaksResult = await db.query(streaksQuery, [userId]);

  return {
    xp,
    level,
    nextLevelXP: calculateXPForLevel(level + 1),
    levelProgress: calculateLevelProgress(xp),
    achievements: achievementsResult.rows[0].total,
    activeStreaks: streaksResult.rows[0].active,
  };
}

/**
 * Get leaderboard (top users by XP)
 */
export async function getLeaderboard(limit = 100) {
  const query = `
    SELECT id, full_name, xp, level, avatar_url
    FROM users
    ORDER BY xp DESC
    LIMIT $1
  `;

  const result = await db.query(query, [limit]);
  return result.rows.map((row, index) => ({
    rank: index + 1,
    ...row,
  }));
}

/**
 * Get user's rank on leaderboard
 */
export async function getUserRank(userId) {
  const query = `
    SELECT COUNT(*) as rank FROM users
    WHERE xp > (SELECT xp FROM users WHERE id = $1)
  `;

  const result = await db.query(query, [userId]);
  return result.rows[0].rank + 1; // +1 because rank is 0-indexed
}
