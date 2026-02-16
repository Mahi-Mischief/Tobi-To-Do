/**
 * AI Routes - Endpoints for all Tobi AI features
 */

import express from 'express';
import AIService from '../services/aiService.js';
import { authMiddleware } from '../middleware/auth.js';

const router = express.Router();

/**
 * POST /api/ai/task-breakdown
 * AI: Break down a complex task into subtasks
 */
router.post('/task-breakdown', async (req, res) => {
  try {
    const { taskTitle, taskDescription } = req.body;

    if (!taskTitle) {
      return res.status(400).json({ error: 'taskTitle required' });
    }

    const result = await AIService.generateTaskBreakdown(taskTitle, taskDescription || '');
    res.json(result);
  } catch (error) {
    console.error('[AI] Task breakdown error:', error);
    res.status(500).json({ error: 'Task breakdown failed', details: error.message });
  }
});

/**
 * POST /api/ai/semester-plan
 * AI: Generate a semester-long plan
 */
router.post('/semester-plan', async (req, res) => {
  try {
    const { goal, deadline, currentDate } = req.body;

    if (!goal || !deadline) {
      return res.status(400).json({ error: 'goal and deadline required' });
    }

    const result = await AIService.generateSemesterPlan(goal, deadline, currentDate || new Date());
    res.json(result);
  } catch (error) {
    console.error('[AI] Semester plan error:', error);
    res.status(500).json({ error: 'Semester plan failed', details: error.message });
  }
});

/**
 * POST /api/ai/analyze-fallbehind
 * AI: Analyze why user is falling behind
 */
router.post('/analyze-fallbehind', async (req, res) => {
  try {
    const { missedTasks, completionRate, failurePatterns } = req.body;

    if (missedTasks === undefined || completionRate === undefined) {
      return res.status(400).json({ error: 'missedTasks and completionRate required' });
    }

    const result = await AIService.analyzeWhyFallingBehind(
      missedTasks,
      completionRate,
      failurePatterns || []
    );
    res.json(result);
  } catch (error) {
    console.error('[AI] Fallbehind analysis error:', error);
    res.status(500).json({ error: 'Analysis failed', details: error.message });
  }
});

/**
 * POST /api/ai/goal-steps
 * AI: Generate concrete steps to achieve a goal
 */
router.post('/goal-steps', async (req, res) => {
  try {
    const { goalTitle, goalDescription, timeframe } = req.body;

    if (!goalTitle) {
      return res.status(400).json({ error: 'goalTitle required' });
    }

    const result = await AIService.generateGoalSteps(
      goalTitle,
      goalDescription || '',
      timeframe || '3 months'
    );
    res.json(result);
  } catch (error) {
    console.error('[AI] Goal steps error:', error);
    res.status(500).json({ error: 'Goal steps failed', details: error.message });
  }
});

/**
 * POST /api/ai/schedule
 * Logic: Generate optimized task schedule
 */
router.post('/schedule', async (req, res) => {
  try {
    const { tasks, availableHours } = req.body;

    if (!tasks || !Array.isArray(tasks)) {
      return res.status(400).json({ error: 'tasks array required' });
    }

    const result = await AIService.smartSchedule(tasks, availableHours || 8);
    res.json(result);
  } catch (error) {
    console.error('Schedule error:', error);
    res.status(500).json({ error: 'Scheduling failed', details: error.message });
  }
});

/**
 * GET /api/ai/procrastination
 * Logic: Detect procrastination level
 */
router.get('/procrastination', async (req, res) => {
  try {
    // In real app, fetch user's tasks and habits from DB
    // For now, accept from query
    const { missedToday, overdueTasks, streak } = req.query;
    
    const tasks = req.body?.tasks || [];
    const habits = req.body?.habits || {};

    const result = await AIService.detectProcrastination(tasks, habits);
    res.json(result);
  } catch (error) {
    console.error('Procrastination detection error:', error);
    res.status(500).json({ error: 'Detection failed', details: error.message });
  }
});

/**
 * POST /api/ai/estimate-time
 * Logic: Estimate time for a task
 */
router.post('/estimate-time', async (req, res) => {
  try {
    const { taskType, complexity, historicalData } = req.body;

    if (!taskType) {
      return res.status(400).json({ error: 'taskType required' });
    }

    const result = await AIService.estimateTaskTime(
      taskType,
      complexity || 'medium',
      historicalData || []
    );
    res.json(result);
  } catch (error) {
    console.error('Time estimation error:', error);
    res.status(500).json({ error: 'Estimation failed', details: error.message });
  }
});

/**
 * POST /api/ai/reflection
 * Logic: Generate weekly reflection
 */
router.post('/reflection', async (req, res) => {
  try {
    const { tasksCompleted, tasksMissed, habitsTracked, skillsImproved } = req.body;

    if (tasksCompleted === undefined || tasksMissed === undefined) {
      return res.status(400).json({ error: 'tasksCompleted and tasksMissed required' });
    }

    const result = await AIService.weeklyReflection(
      tasksCompleted,
      tasksMissed,
      habitsTracked || 0,
      skillsImproved || []
    );
    res.json(result);
  } catch (error) {
    console.error('Reflection error:', error);
    res.status(500).json({ error: 'Reflection failed', details: error.message });
  }
});

/**
 * GET /api/ai/motivational
 * Logic: Get a motivational message
 */
router.get('/motivational', (req, res) => {
  try {
    const { context } = req.query;
    const message = AIService.generateMotivationalMessage(context || 'afternoon');
    res.json({ message, aiGenerated: false });
  } catch (error) {
    console.error('Motivational message error:', error);
    res.status(500).json({ error: 'Message generation failed' });
  }
});

/**
 * POST /api/ai/gap-analysis
 * Logic: Analyze gap between current and dream metrics
 */
router.post('/gap-analysis', async (req, res) => {
  try {
    const { currentMetrics, dreamMetrics } = req.body;

    if (!currentMetrics || !dreamMetrics) {
      return res.status(400).json({ error: 'currentMetrics and dreamMetrics required' });
    }

    const result = await AIService.analyzeGap(currentMetrics, dreamMetrics);
    res.json(result);
  } catch (error) {
    console.error('Gap analysis error:', error);
    res.status(500).json({ error: 'Analysis failed', details: error.message });
  }
});

/**
 * GET /api/ai/suggestions
 * Logic: Get Tobi AI suggestions
 */
router.get('/suggestions', async (req, res) => {
  try {
    const userId = req.user?.id;
    const context = req.body?.context || {};

    const result = await AIService.getTobiSuggestions(userId, context);
    res.json(result);
  } catch (error) {
    console.error('Suggestions error:', error);
    res.status(500).json({ error: 'Suggestions failed', details: error.message });
  }
});

export default router;
