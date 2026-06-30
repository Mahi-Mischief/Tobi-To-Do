import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import * as habitController from '../controllers/habitController.js';
import Joi from 'joi';
import { validateBody, validateParams, uuidParam } from '../middleware/validate.js';

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

const habitIdSchema = Joi.object({ habitId: uuidParam });

const createHabitSchema = Joi.object({
	name: Joi.string().min(1).max(255).required(),
	frequency: Joi.string().valid('daily', 'weekly', 'monthly').default('daily'),
	description: Joi.string().max(2000).allow('', null),
});

const updateHabitSchema = Joi.object({
	name: Joi.string().min(1).max(255).optional(),
	frequency: Joi.string().valid('daily', 'weekly', 'monthly').optional(),
	description: Joi.string().max(2000).allow('', null).optional(),
}).min(1);

// CRUD operations
router.post('/', validateBody(createHabitSchema), habitController.createHabit);
router.get('/', habitController.getHabits);
router.get('/stats', habitController.getHabitStats);
router.get('/consistency', habitController.getHabitConsistency);
router.get('/due-today', habitController.getHabitsDueToday);
router.get('/streaks', habitController.getStreaksSummary);
router.get('/:habitId', validateParams(habitIdSchema), habitController.getHabitById);
router.patch('/:habitId', validateParams(habitIdSchema), validateBody(updateHabitSchema), habitController.updateHabit);
router.delete('/:habitId', validateParams(habitIdSchema), habitController.deleteHabit);

// Action endpoints
router.post('/:habitId/complete', validateParams(habitIdSchema), habitController.completeHabit);
router.post('/:habitId/reset-streak', validateParams(habitIdSchema), habitController.resetStreak);

export default router;
