import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import * as goalController from '../controllers/goalController.js';

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// CRUD operations
router.post('/', goalController.createGoal);
router.get('/', goalController.getGoals);
router.get('/stats', goalController.getGoalStats);
router.get('/:goalId', goalController.getGoalById);
router.patch('/:goalId', goalController.updateGoal);
router.delete('/:goalId', goalController.deleteGoal);

// Goal-specific operations
router.get('/:goalId/probability', goalController.getGoalProbability);
router.get('/:goalId/habits', goalController.getLinkedHabits);
router.post('/:goalId/progress', goalController.updateProgress);

// Habit-goal linking
router.post('/link-habit', goalController.linkHabitToGoal);

// Conflict detection
router.get('/conflicts/detect', goalController.detectConflicts);

export default router;
