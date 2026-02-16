import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import * as habitController from '../controllers/habitController.js';

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// CRUD operations
router.post('/', habitController.createHabit);
router.get('/', habitController.getHabits);
router.get('/stats', habitController.getHabitStats);
router.get('/consistency', habitController.getHabitConsistency);
router.get('/due-today', habitController.getHabitsDueToday);
router.get('/streaks', habitController.getStreaksSummary);
router.get('/:habitId', habitController.getHabitById);
router.patch('/:habitId', habitController.updateHabit);
router.delete('/:habitId', habitController.deleteHabit);

// Action endpoints
router.post('/:habitId/complete', habitController.completeHabit);
router.post('/:habitId/reset-streak', habitController.resetStreak);

export default router;
