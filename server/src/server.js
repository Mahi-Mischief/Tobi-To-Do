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
// import aiRoutes from './routes/aiRoutes.js'; // TODO: Fix ES6 module import

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || '*',
  credentials: true
}));
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
// app.use('/api/ai', aiRoutes); // TODO: Fix ES6 module import

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

    // Start server
    app.listen(PORT, () => {
      console.log(`✓ Server running on http://localhost:${PORT}`);
      console.log(`✓ API Health: http://localhost:${PORT}/api/health`);
    });
  } catch (error) {
    console.error('✗ Failed to start server:', error);
    process.exit(1);
  }
}

startServer();

export default app;
