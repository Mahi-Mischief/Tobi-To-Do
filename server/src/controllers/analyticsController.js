import * as analyticsService from '../services/analyticsService.js';

/**
 * Get task completion rate
 */
export async function getTaskCompletionRate(req, res) {
  try {
    const userId = req.user.id;
    const { days } = req.query;

    const rate = await analyticsService.getTaskCompletionRate(userId, days || 30);

    res.json({ completionRate: rate });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get habit consistency
 */
export async function getHabitConsistency(req, res) {
  try {
    const userId = req.user.id;
    const { days } = req.query;

    const consistency = await analyticsService.getHabitConsistency(userId, days || 7);

    res.json({ consistency });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get goal trends
 */
export async function getGoalTrends(req, res) {
  try {
    const userId = req.user.id;
    const { days } = req.query;

    const trends = await analyticsService.getGoalTrends(userId, days || 90);

    res.json(trends);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get productivity heatmap
 */
export async function getProductivityHeatmap(req, res) {
  try {
    const userId = req.user.id;
    const { weeks } = req.query;

    const heatmap = await analyticsService.getProductivityHeatmap(userId, weeks || 4);

    res.json({ heatmap });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get weekly summary
 */
export async function getWeeklySummary(req, res) {
  try {
    const userId = req.user.id;

    const summary = await analyticsService.getWeeklySummary(userId);

    res.json(summary);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get daily focus time
 */
export async function getDailyFocusTime(req, res) {
  try {
    const userId = req.user.id;
    const { days } = req.query;

    const focusTime = await analyticsService.getDailyFocusTime(userId, days || 30);

    res.json(focusTime);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get most productive time of day
 */
export async function getMostProductiveTime(req, res) {
  try {
    const userId = req.user.id;
    const { days } = req.query;

    const time = await analyticsService.getMostProductiveTime(userId, days || 30);

    res.json(time);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get habit comparison
 */
export async function getHabitComparison(req, res) {
  try {
    const userId = req.user.id;

    const comparison = await analyticsService.getHabitComparison(userId);

    res.json(comparison);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get analytics dashboard
 */
export async function getAnalyticsDashboard(req, res) {
  try {
    const userId = req.user.id;

    const dashboard = await analyticsService.getAnalyticsDashboard(userId);

    res.json(dashboard);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get goal progress tracking
 */
export async function getGoalProgressTracking(req, res) {
  try {
    const userId = req.user.id;

    const tracking = await analyticsService.getGoalProgressTracking(userId);

    res.json(tracking);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get engagement metrics
 */
export async function getEngagementMetrics(req, res) {
  try {
    const userId = req.user.id;

    const metrics = await analyticsService.getEngagementMetrics(userId);

    res.json(metrics);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
