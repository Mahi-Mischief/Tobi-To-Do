import * as gamificationService from '../services/gamificationService.js';

/**
 * Get user's gamification stats (XP, level, achievements)
 */
export async function getGamificationStats(req, res) {
  try {
    const userId = req.user.id;

    const stats = await gamificationService.getGamificationStats(userId);

    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get all user achievements
 */
export async function getAchievements(req, res) {
  try {
    const userId = req.user.id;

    const achievements = await gamificationService.getAchievements(userId);

    res.json(achievements);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get leaderboard
 */
export async function getLeaderboard(req, res) {
  try {
    const { limit } = req.query;

    const leaderboard = await gamificationService.getLeaderboard(limit || 100);

    res.json(leaderboard);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get user's rank on leaderboard
 */
export async function getUserRank(req, res) {
  try {
    const userId = req.user.id;

    const rank = await gamificationService.getUserRank(userId);

    res.json({ rank });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Award XP manually (admin only or special actions)
 */
export async function awardXPManually(req, res) {
  try {
    const userId = req.user.id;
    const { amount, source } = req.body;

    if (!amount || amount <= 0) {
      return res.status(400).json({ error: 'Amount must be greater than 0' });
    }

    const result = await gamificationService.awardXP(userId, amount, source || 'manual');

    res.json(result);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}
