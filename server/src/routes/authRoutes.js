import express from 'express';
import { AuthController } from '../controllers/authController.js';
import { authMiddleware } from '../middleware/auth.js';
import Joi from 'joi';
import { validateBody } from '../middleware/validate.js';
import { loginLimiter } from '../middleware/rateLimit.js';

const router = express.Router();

// Validation schemas
const registerSchema = Joi.object({
	email: Joi.string().email().max(255).required(),
	password: Joi.string().min(6).max(255).required(),
	fullName: Joi.string().max(255).allow('', null),
});

const loginSchema = Joi.object({
	email: Joi.string().email().max(255).required(),
	password: Joi.string().min(6).max(255).required(),
});

const firebaseLoginSchema = Joi.object({
	firebaseUid: Joi.string().max(255).required(),
	email: Joi.string().email().max(255).required(),
	fullName: Joi.string().max(255).allow('', null),
});

// Public routes
router.post('/register', loginLimiter, validateBody(registerSchema), AuthController.register);
router.post('/login', loginLimiter, validateBody(loginSchema), AuthController.login);
router.post('/firebase-login', loginLimiter, validateBody(firebaseLoginSchema), AuthController.firebaseLogin);
router.post('/firebase-exchange', loginLimiter, validateBody(firebaseLoginSchema), AuthController.exchangeFirebase);

// Protected routes
router.get('/me', authMiddleware, AuthController.getCurrentUser);
router.patch('/profile', authMiddleware, AuthController.updateProfile);

export default router;
