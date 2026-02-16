import express from 'express';
import { AuthController } from '../controllers/authController.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

// Public routes
router.post('/register', AuthController.register);
router.post('/login', AuthController.login);
router.post('/firebase-login', AuthController.firebaseLogin);

// Protected routes
router.get('/me', authMiddleware, AuthController.getCurrentUser);
router.patch('/profile', authMiddleware, AuthController.updateProfile);

export default router;
