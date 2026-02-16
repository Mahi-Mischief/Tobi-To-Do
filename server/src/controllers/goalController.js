import * as goalService from '../services/goalService.js';
import { awardXP, checkAndAwardAchievements } from '../services/gamificationService.js';

/**
 * Create a new goal
 */
export async function createGoal(req, res) {
  try {
    const { title, description, category, deadline, targetValue } = req.body;
    const userId = req.user.id;

    const goal = await goalService.createGoal(userId, {
      title,
      description,
      category,
      deadline,
      targetValue,
    });

    // Award XP for creating goal
    await awardXP(userId, 15, 'create_goal');

    res.status(201).json(goal);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Get all goals for user (optionally filtered by status)
 */
export async function getGoals(req, res) {
  try {
    const userId = req.user.id;
    const { status } = req.query;

    const goals = await goalService.getGoals(userId, status);

    res.json(goals);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get goal by ID
 */
export async function getGoalById(req, res) {
  try {
    const { goalId } = req.params;

    const goal = await goalService.getGoalById(goalId);

    res.json(goal);
  } catch (error) {
    res.status(404).json({ error: error.message });
  }
}

/**
 * Update goal
 */
export async function updateGoal(req, res) {
  try {
    const { goalId } = req.params;
    const userId = req.user.id;
    const updates = req.body;

    // If status is changing to completed, award XP
    if (updates.status === 'completed') {
      await awardXP(userId, 50, 'complete_goal');
      await checkAndAwardAchievements(userId);
    }

    const goal = await goalService.updateGoal(goalId, updates);

    res.json(goal);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Delete goal
 */
export async function deleteGoal(req, res) {
  try {
    const { goalId } = req.params;

    await goalService.deleteGoal(goalId);

    res.status(204).send();
  } catch (error) {
    res.status(404).json({ error: error.message });
  }
}

/**
 * Calculate goal probability/likelihood of success
 */
export async function getGoalProbability(req, res) {
  try {
    const { goalId } = req.params;
    const userId = req.user.id;

    const probability = await goalService.calculateGoalProbability(goalId, userId);

    res.json({ probability });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Link habit to goal
 */
export async function linkHabitToGoal(req, res) {
  try {
    const { goalId, habitId } = req.body;

    await goalService.linkHabitToGoal(habitId, goalId);

    res.status(201).json({ message: 'Habit linked to goal' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Get habits linked to a goal
 */
export async function getLinkedHabits(req, res) {
  try {
    const { goalId } = req.params;

    const habits = await goalService.getLinkedHabits(goalId);

    res.json(habits);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Detect goal conflicts (overlapping goals in same category)
 */
export async function detectConflicts(req, res) {
  try {
    const userId = req.user.id;

    const conflicts = await goalService.detectGoalConflicts(userId);

    res.json({ conflicts });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get goal statistics
 */
export async function getGoalStats(req, res) {
  try {
    const userId = req.user.id;

    const stats = await goalService.getGoalStats(userId);

    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Update goal progress
 */
export async function updateProgress(req, res) {
  try {
    const { goalId } = req.params;
    const { progress_percent } = req.body;
    const userId = req.user.id;

    if (progress_percent < 0 || progress_percent > 100) {
      return res.status(400).json({ error: 'Progress must be between 0 and 100' });
    }

    const goal = await goalService.updateGoal(goalId, {
      progress_percent,
    });

    // Award XP based on progress increase
    if (progress_percent % 25 === 0) {
      await awardXP(userId, 10, 'goal_progress');
    }

    res.json(goal);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}
