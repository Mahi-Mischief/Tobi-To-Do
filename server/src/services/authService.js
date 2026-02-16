import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { query } from '../config/database.js';

export class AuthService {
  // Generate JWT token
  static generateToken(userId, email) {
    return jwt.sign(
      { userId, email },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRY || '7d' }
    );
  }

  // Hash password
  static async hashPassword(password) {
    return bcrypt.hash(password, 10);
  }

  // Compare password
  static async comparePassword(password, hash) {
    return bcrypt.compare(password, hash);
  }

  // Register user
  static async registerUser(email, password, fullName = '') {
    try {
      const hashedPassword = await this.hashPassword(password);
      
      const result = await query(
        `INSERT INTO users (email, password_hash, full_name) 
         VALUES ($1, $2, $3) 
         RETURNING id, email, full_name, created_at`,
        [email, hashedPassword, fullName]
      );

      if (result.rows.length === 0) {
        throw new Error('Failed to create user');
      }

      const user = result.rows[0];
      const token = this.generateToken(user.id, user.email);

      return { user, token };
    } catch (error) {
      if (error.code === '23505') {
        throw new Error('Email already registered');
      }
      throw error;
    }
  }

  // Login user
  static async loginUser(email, password) {
    try {
      const result = await query(
        'SELECT * FROM users WHERE email = $1 AND deleted_at IS NULL',
        [email]
      );

      if (result.rows.length === 0) {
        throw new Error('Invalid email or password');
      }

      const user = result.rows[0];
      const isPasswordValid = await this.comparePassword(password, user.password_hash);

      if (!isPasswordValid) {
        throw new Error('Invalid email or password');
      }

      const token = this.generateToken(user.id, user.email);
      
      // Remove sensitive data
      delete user.password_hash;

      return { user, token };
    } catch (error) {
      throw error;
    }
  }

  // Login with Firebase UID
  static async loginWithFirebase(firebaseUid, email, fullName = '') {
    try {
      // Try to find existing user
      let result = await query(
        'SELECT * FROM users WHERE firebase_uid = $1',
        [firebaseUid]
      );

      let user;
      if (result.rows.length > 0) {
        user = result.rows[0];
      } else {
        // Create new user
        result = await query(
          `INSERT INTO users (firebase_uid, email, full_name) 
           VALUES ($1, $2, $3) 
           RETURNING id, email, full_name, firebase_uid, created_at`,
          [firebaseUid, email, fullName]
        );
        user = result.rows[0];
      }

      const token = this.generateToken(user.id, user.email);
      delete user.password_hash;

      return { user, token };
    } catch (error) {
      throw error;
    }
  }

  // Get user by ID
  static async getUserById(userId) {
    try {
      const result = await query(
        'SELECT id, email, full_name, avatar_url, bio, theme_preference, xp_points, level, created_at FROM users WHERE id = $1 AND deleted_at IS NULL',
        [userId]
      );

      if (result.rows.length === 0) {
        throw new Error('User not found');
      }

      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }

  // Update user profile
  static async updateUserProfile(userId, updates) {
    try {
      const allowedFields = ['full_name', 'avatar_url', 'bio', 'theme_preference'];
      const updateFields = [];
      const updateValues = [];
      let paramIndex = 1;

      allowedFields.forEach(field => {
        if (field in updates) {
          updateFields.push(`${field} = $${paramIndex}`);
          updateValues.push(updates[field]);
          paramIndex++;
        }
      });

      if (updateFields.length === 0) {
        throw new Error('No valid fields to update');
      }

      updateFields.push(`updated_at = $${paramIndex}`);
      updateValues.push(new Date());
      updateValues.push(userId);

      const result = await query(
        `UPDATE users SET ${updateFields.join(', ')} WHERE id = $${paramIndex + 1} RETURNING *`,
        updateValues
      );

      if (result.rows.length === 0) {
        throw new Error('User not found');
      }

      return result.rows[0];
    } catch (error) {
      throw error;
    }
  }
}
