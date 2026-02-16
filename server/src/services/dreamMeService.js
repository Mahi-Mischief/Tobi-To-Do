import { db } from '../config/database.js';
import { generateId } from '../utils/helpers.js';

/**
 * Create or update Dream Me profile
 */
export async function saveDreamProfile(userId, profileData) {
  // Check if exists
  const checkQuery = `SELECT id FROM dream_profiles WHERE user_id = $1`;
  const existing = await db.query(checkQuery, [userId]);

  if (existing.rows.length > 0) {
    // Update
    const updateQuery = `
      UPDATE dream_profiles
      SET
        vision_statement = $1,
        core_values = $2,
        three_year_goal = $3,
        identity_statements = $4,
        updated_at = NOW()
      WHERE user_id = $5
      RETURNING *
    `;

    const result = await db.query(updateQuery, [
      profileData.visionStatement,
      profileData.coreValues,
      profileData.threeYearGoal,
      JSON.stringify(profileData.identityStatements),
      userId,
    ]);

    return result.rows[0];
  } else {
    // Create
    const createQuery = `
      INSERT INTO dream_profiles
      (id, user_id, vision_statement, core_values, three_year_goal, identity_statements, created_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
      RETURNING *
    `;

    const result = await db.query(createQuery, [
      generateId(),
      userId,
      profileData.visionStatement,
      profileData.coreValues,
      profileData.threeYearGoal,
      JSON.stringify(profileData.identityStatements),
    ]);

    return result.rows[0];
  }
}

/**
 * Get Dream Me profile
 */
export async function getDreamProfile(userId) {
  const query = `
    SELECT * FROM dream_profiles WHERE user_id = $1
  `;

  const result = await db.query(query, [userId]);

  if (result.rows.length === 0) {
    return null;
  }

  const profile = result.rows[0];
  return {
    ...profile,
    identityStatements: JSON.parse(profile.identity_statements),
  };
}

/**
 * Calculate alignment score (0-100)
 * How well current goals and habits align with Dream Me
 */
export async function calculateAlignmentScore(userId) {
  const profile = await getDreamProfile(userId);

  if (!profile) {
    return { score: 0, breakdown: {} };
  }

  // Get user's current goals and habits
  const goalsQuery = `
    SELECT id, title, category, status, progress_percent
    FROM goals
    WHERE user_id = $1 AND status != 'abandoned'
  `;

  const habitsQuery = `
    SELECT id, name, streak_count, frequency
    FROM habits
    WHERE user_id = $1
  `;

  const [goalsResult, habitsResult] = await Promise.all([
    db.query(goalsQuery, [userId]),
    db.query(habitsQuery, [userId]),
  ]);

  const goals = goalsResult.rows;
  const habits = habitsResult.rows;

  let scoreBreakdown = {
    goalCount: 0,
    habitConsistency: 0,
    progressRealization: 0,
    overallAlignment: 0,
  };

  // Factor 1: Goal count (having goals shows commitment)
  // Up to 20 points for 5+ goals
  scoreBreakdown.goalCount = Math.min(goals.length * 4, 20);

  // Factor 2: Habit consistency
  // Up to 30 points based on active streaks
  const activeHabits = habits.filter((h) => h.streak_count > 0).length;
  scoreBreakdown.habitConsistency = Math.min((activeHabits / Math.max(habits.length, 1)) * 30, 30);

  // Factor 3: Progress realization (completion of goals)
  // Up to 40 points based on average goal progress
  if (goals.length > 0) {
    const avgProgress =
      goals.reduce((sum, g) => sum + g.progress_percent, 0) / goals.length;
    scoreBreakdown.progressRealization = (avgProgress / 100) * 40;
  }

  // Factor 4: Gap analysis for identity alignment
  // Up to 10 points for having identity statements
  scoreBreakdown.overallAlignment = profile.identity_statements.length > 0 ? 10 : 0;

  const totalScore = Math.round(
    scoreBreakdown.goalCount +
      scoreBreakdown.habitConsistency +
      scoreBreakdown.progressRealization +
      scoreBreakdown.overallAlignment
  );

  return {
    score: Math.min(totalScore, 100),
    breakdown: scoreBreakdown,
  };
}

/**
 * Generate gap analysis (areas to improve)
 */
export async function generateGapAnalysis(userId) {
  const profile = await getDreamProfile(userId);
  const alignment = await calculateAlignmentScore(userId);

  if (!profile) {
    return {
      gaps: ['Create your Dream Me profile first'],
      suggestions: [],
    };
  }

  const gaps = [];
  const suggestions = [];

  // Check goals
  const goalsQuery = `
    SELECT COUNT(*) as count FROM goals
    WHERE user_id = $1 AND status != 'abandoned'
  `;

  const goalsResult = await db.query(goalsQuery, [userId]);
  const goalCount = goalsResult.rows[0].count;

  if (goalCount < 3) {
    gaps.push('You have fewer than 3 active goals');
    suggestions.push(
      'Create goals that support your ' +
        (profile.three_year_goal || 'long-term vision')
    );
  }

  // Check habits
  const habitsQuery = `
    SELECT COUNT(*) as count FROM habits WHERE user_id = $1
  `;

  const habitsResult = await db.query(habitsQuery, [userId]);
  const habitCount = habitsResult.rows[0].count;

  if (habitCount < 3) {
    gaps.push('You have fewer than 3 habits');
    suggestions.push(
      'Build daily habits that support your identity as: ' +
        (profile.identity_statements[0] || 'your Dream Me')
    );
  }

  // Check focus consistency
  const focusQuery = `
    SELECT
      COUNT(DISTINCT DATE(created_at)) as active_days,
      COUNT(*) as total_sessions
    FROM focus_sessions
    WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '7 days'
  `;

  const focusResult = await db.query(focusQuery, [userId]);
  const activeDays = focusResult.rows[0]?.active_days || 0;

  if (activeDays < 3) {
    gaps.push('Low focus consistency (less than 3 days this week)');
    suggestions.push('Schedule at least 4 focused work sessions this week');
  }

  // Check alignment score
  if (alignment.score < 50) {
    gaps.push('Low alignment between current actions and Dream Me vision');
    suggestions.push('Review your goals and habits - ensure they support your vision');
  }

  return {
    gaps: gaps.length > 0 ? gaps : ['You are doing great! Keep it up!'],
    suggestions,
    alignmentScore: alignment.score,
  };
}

/**
 * Record a reflection/journaling entry
 */
export async function recordReflection(userId, reflectionData) {
  const query = `
    INSERT INTO reflections (id, user_id, content, mood, insights, created_at)
    VALUES ($1, $2, $3, $4, $5, NOW())
    RETURNING *
  `;

  const result = await db.query(query, [
    generateId(),
    userId,
    reflectionData.content,
    reflectionData.mood || null,
    reflectionData.insights || null,
  ]);

  return result.rows[0];
}

/**
 * Get recent reflections
 */
export async function getReflections(userId, limit = 10) {
  const query = `
    SELECT id, content, mood, insights, created_at
    FROM reflections
    WHERE user_id = $1
    ORDER BY created_at DESC
    LIMIT $2
  `;

  const result = await db.query(query, [userId, limit]);
  return result.rows;
}

/**
 * Get Dream Me insights (summary of progress)
 */
export async function getDreamMeInsights(userId) {
  const profile = await getDreamProfile(userId);
  const alignment = await calculateAlignmentScore(userId);
  const gaps = await generateGapAnalysis(userId);

  // Get latest reflection
  const reflectionQuery = `
    SELECT content, mood, created_at FROM reflections
    WHERE user_id = $1
    ORDER BY created_at DESC
    LIMIT 1
  `;

  const reflectionResult = await db.query(reflectionQuery, [userId]);
  const lastReflection = reflectionResult.rows[0] || null;

  // Get recent goals and habits
  const goalsQuery = `
    SELECT id, title, progress_percent, status
    FROM goals
    WHERE user_id = $1 AND status = 'in_progress'
    ORDER BY created_at DESC
    LIMIT 3
  `;

  const habitsQuery = `
    SELECT id, name, streak_count, frequency
    FROM habits
    WHERE user_id = $1 AND streak_count > 0
    ORDER BY streak_count DESC
    LIMIT 3
  `;

  const [goalsResult, habitsResult] = await Promise.all([
    db.query(goalsQuery, [userId]),
    db.query(habitsQuery, [userId]),
  ]);

  return {
    dreamProfile: profile,
    alignmentScore: alignment.score,
    gaps: gaps.gaps,
    suggestions: gaps.suggestions,
    recentGoals: goalsResult.rows,
    activeHabits: habitsResult.rows,
    lastReflection,
  };
}

/**
 * Get milestone progress toward 3-year goal
 */
export async function getMilestoneProgress(userId) {
  const profile = await getDreamProfile(userId);

  if (!profile || !profile.three_year_goal) {
    return null;
  }

  // Get goals related to 3-year goal
  const query = `
    SELECT
      id,
      title,
      category,
      progress_percent,
      status,
      deadline
    FROM goals
    WHERE user_id = $1
    AND (
      status = 'completed'
      OR status = 'in_progress'
    )
    ORDER BY deadline ASC
  `;

  const result = await db.query(query, [userId]);
  const goals = result.rows;

  // Calculate overall progress (simple average)
  const avgProgress =
    goals.length > 0 ? Math.round(goals.reduce((sum, g) => sum + g.progress_percent, 0) / goals.length) : 0;

  // Count completed goals
  const completedCount = goals.filter((g) => g.status === 'completed').length;

  return {
    threeYearGoal: profile.three_year_goal,
    totalGoals: goals.length,
    completedGoals: completedCount,
    overallProgress: avgProgress,
    goals: goals.map((g) => ({
      ...g,
      daysUntilDeadline: g.deadline
        ? Math.ceil((new Date(g.deadline) - new Date()) / (1000 * 60 * 60 * 24))
        : null,
    })),
  };
}
