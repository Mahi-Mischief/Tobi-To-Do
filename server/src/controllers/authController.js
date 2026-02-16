import { AuthService } from '../services/authService.js';

export class AuthController {
  // Register new user
  static async register(req, res, next) {
    try {
      const { email, password, fullName } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }

      const { user, token } = await AuthService.registerUser(email, password, fullName);

      res.status(201).json({
        success: true,
        user,
        token
      });
    } catch (error) {
      next(error);
    }
  }

  // Login user
  static async login(req, res, next) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
      }

      const { user, token } = await AuthService.loginUser(email, password);

      res.status(200).json({
        success: true,
        user,
        token
      });
    } catch (error) {
      res.status(401).json({ error: error.message });
    }
  }

  // Firebase login
  static async firebaseLogin(req, res, next) {
    try {
      const { firebaseUid, email, fullName } = req.body;

      if (!firebaseUid || !email) {
        return res.status(400).json({ error: 'Firebase UID and email are required' });
      }

      const { user, token } = await AuthService.loginWithFirebase(firebaseUid, email, fullName);

      res.status(200).json({
        success: true,
        user,
        token
      });
    } catch (error) {
      next(error);
    }
  }

  // Get current user
  static async getCurrentUser(req, res, next) {
    try {
      const user = await AuthService.getUserById(req.userId);

      res.status(200).json({
        success: true,
        user
      });
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  // Update user profile
  static async updateProfile(req, res, next) {
    try {
      const updates = req.body;
      const user = await AuthService.updateUserProfile(req.userId, updates);

      res.status(200).json({
        success: true,
        user
      });
    } catch (error) {
      next(error);
    }
  }
}
