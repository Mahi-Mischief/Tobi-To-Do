import express from 'express';
import { authMiddleware } from '../middleware/auth.js';
import * as dreamMeController from '../controllers/dreamMeController.js';

const router = express.Router();

// All routes require authentication
router.use(authMiddleware);

// Profile management
router.post('/profile', dreamMeController.saveDreamProfile);
router.get('/profile', dreamMeController.getDreamProfile);

// Insights and tracking
router.get('/insights', dreamMeController.getDreamMeInsights);
router.get('/alignment', dreamMeController.getAlignmentScore);
router.get('/gaps', dreamMeController.getGapAnalysis);
router.get('/milestones', dreamMeController.getMilestoneProgress);

// Journaling/Reflections
router.post('/reflections', dreamMeController.recordReflection);
router.get('/reflections', dreamMeController.getReflections);

export default router;
