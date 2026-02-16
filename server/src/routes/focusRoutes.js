import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import * as focusController from '../controllers/focusController.js';

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// Session management
router.post('/start', focusController.startFocusSession);
router.post('/:sessionId/end', focusController.endFocusSession);
router.get('/active', focusController.getActiveFocusSession);
router.get('/history', focusController.getFocusHistory);

// Statistics
router.get('/stats', focusController.getFocusStats);
router.get('/streak', focusController.getFocusStreak);

// Burnout tracking
router.get('/burnout/detect', focusController.getBurnoutInfo);

export default router;
