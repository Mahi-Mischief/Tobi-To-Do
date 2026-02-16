import express from 'express';
import { TaskController } from '../controllers/taskController.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

// All task routes require authentication
router.use(authMiddleware);

// Task CRUD operations
router.post('/', TaskController.createTask);
router.get('/', TaskController.getTasks);
router.get('/dashboard-stats', TaskController.getDashboardStats);
router.get('/:id', TaskController.getTask);
router.patch('/:id', TaskController.updateTask);
router.delete('/:id', TaskController.deleteTask);

// AI features
router.post('/ai/breakdown', TaskController.generateTaskBreakdown);
router.get('/ai/schedule', TaskController.getSmartSchedule);

export default router;
