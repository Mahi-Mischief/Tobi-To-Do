import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import * as gamificationController from '../controllers/gamificationController.js';

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// User stats and achievements
router.get('/stats', gamificationController.getGamificationStats);
router.get('/achievements', gamificationController.getAchievements);
router.get('/rank', gamificationController.getUserRank);

// Leaderboard
router.get('/leaderboard', gamificationController.getLeaderboard);

// XP management
router.post('/xp/award', gamificationController.awardXPManually);

export default router;
