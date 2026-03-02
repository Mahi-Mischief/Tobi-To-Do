import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { initializeDatabase } from './config/database.js';
import { initializeFirebase } from './config/firebase.js';
import { errorHandler, notFoundHandler } from './middleware/errorHandler.js';
import authRoutes from './routes/authRoutes.js';
import taskRoutes from './routes/taskRoutes.js';
import habitRoutes from './routes/habitRoutes.js';
import goalRoutes from './routes/goalRoutes.js';
import focusRoutes from './routes/focusRoutes.js';
import analyticsRoutes from './routes/analyticsRoutes.js';
import gamificationRoutes from './routes/gamificationRoutes.js';
import dreamMeRoutes from './routes/dreamMeRoutes.js';
import aiRoutes from './routes/aiRoutes.js';
import avatarRoutes from './routes/avatarRoutes.js';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
// Configure CORS:
// - If CORS_ORIGIN is set in .env it should be a comma-separated list of allowed origins.
// - In development, when not set, reflect the request origin (allow any local frontend) while still
//   enabling cookies/credentials support.
const rawCors = process.env.CORS_ORIGIN;
const allowedOrigins = rawCors ? rawCors.split(',').map(s => s.trim()).filter(Boolean) : null;

if (allowedOrigins && allowedOrigins.length > 0) {
  // Support exact matches, wildcard '*' and host-only matches (e.g. http://127.0.0.1)
  app.use(
    cors({
      origin: (origin, callback) => {
        // Non-browser requests (curl, server-to-server) may have no origin
        if (!origin) return callback(null, true);

        // Allow explicit wildcard
        if (allowedOrigins.includes('*')) return callback(null, true);

        // Exact origin match
        if (allowedOrigins.includes(origin)) return callback(null, true);

        // Host-only match: allow entries like 'http://127.0.0.1' to match any port
        try {
          const reqHost = new URL(origin).hostname;
          for (const ao of allowedOrigins) {
            try {
              const aoHost = new URL(ao).hostname;
              if (aoHost && aoHost === reqHost) return callback(null, true);
            } catch (e) {
              // ignore malformed allowed origin entries
            }
          }
        } catch (e) {
          // ignore parse errors
        }

        return callback(new Error('Not allowed by CORS'));
      },
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
    }),
  );
} else {
  // Allow reflected origin for development (supports credentials and common methods/headers)
  app.use(
    cors({
      origin: (origin, callback) => callback(null, true),
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
    }),
  );
}
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/habits', habitRoutes);
app.use('/api/goals', goalRoutes);
app.use('/api/focus', focusRoutes);
app.use('/api/analytics', analyticsRoutes);
app.use('/api/gamification', gamificationRoutes);
app.use('/api/dream-me', dreamMeRoutes);
app.use('/api/ai', aiRoutes);
app.use('/api/avatar', avatarRoutes);

// 404 handler
app.use(notFoundHandler);

// Error handling middleware (must be last)
app.use(errorHandler);

// Initialize server
async function startServer() {
  try {
    // Initialize database
    await initializeDatabase();
    console.log('✓ Database initialized');

    // Initialize Firebase (optional)
    initializeFirebase();

    // Start server binding to all interfaces so browsers/containers can reach it
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`✓ Server running on http://0.0.0.0:${PORT}`);
      console.log(`✓ API Health: http://0.0.0.0:${PORT}/api/health`);
    });
  } catch (error) {
    console.error('✗ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

export default app;
