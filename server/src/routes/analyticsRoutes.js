import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import * as analyticsController from '../controllers/analyticsController.js';

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// Overview
router.get('/dashboard', analyticsController.getAnalyticsDashboard);

// Specific metrics
router.get('/completion-rate', analyticsController.getTaskCompletionRate);
router.get('/habit-consistency', analyticsController.getHabitConsistency);
router.get('/goal-trends', analyticsController.getGoalTrends);
router.get('/goal-progress', analyticsController.getGoalProgressTracking);

// Focus analytics
router.get('/focus-time', analyticsController.getDailyFocusTime);
router.get('/productive-time', analyticsController.getMostProductiveTime);

// Heatmap and engagement
router.get('/productivity-heatmap', analyticsController.getProductivityHeatmap);
router.get('/engagement', analyticsController.getEngagementMetrics);

// Habit comparison
router.get('/habits-comparison', analyticsController.getHabitComparison);

// Weekly summary
router.get('/weekly-summary', analyticsController.getWeeklySummary);

export default router;
