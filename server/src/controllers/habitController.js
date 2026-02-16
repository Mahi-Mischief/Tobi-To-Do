import * as habitService from '../services/habitService.js';
import { awardXP, checkAndAwardAchievements } from '../services/gamificationService.js';

/**
 * Create a new habit
 */
export async function createHabit(req, res) {
  try {
    const { name, frequency, description } = req.body;
    const userId = req.user.id;

    const habit = await habitService.createHabit(userId, {
      name,
      frequency,
      description,
    });

    // Award XP for creating habit
    await awardXP(userId, 10, 'create_habit');

    res.status(201).json(habit);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Get all habits for user
 */
export async function getHabits(req, res) {
  try {
    const userId = req.user.id;
    const habits = await habitService.getHabits(userId);

    res.json(habits);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get habit by ID
 */
export async function getHabitById(req, res) {
  try {
    const { habitId } = req.params;
    const habit = await habitService.getHabitById(habitId);

    res.json(habit);
  } catch (error) {
    res.status(404).json({ error: error.message });
  }
}

/**
 * Update habit
 */
export async function updateHabit(req, res) {
  try {
    const { habitId } = req.params;
    const updates = req.body;

    const habit = await habitService.updateHabit(habitId, updates);

    res.json(habit);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Delete habit
 */
export async function deleteHabit(req, res) {
  try {
    const { habitId } = req.params;

    await habitService.deleteHabit(habitId);

    res.status(204).send();
  } catch (error) {
    res.status(404).json({ error: error.message });
  }
}

/**
 * Mark habit as complete for today
 */
export async function completeHabit(req, res) {
  try {
    const { habitId } = req.params;
    const userId = req.user.id;

    const result = await habitService.completeHabit(habitId);

    // Award XP for completing habit
    await awardXP(userId, 5, 'complete_habit');

    // Check for streak achievements
    if (result.streak_count === 7) {
      await checkAndAwardAchievements(userId);
    }

    res.json(result);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Reset habit streak
 */
export async function resetStreak(req, res) {
  try {
    const { habitId } = req.params;

    const habit = await habitService.resetStreak(habitId);

    res.json(habit);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Get streaks summary
 */
export async function getStreaksSummary(req, res) {
  try {
    const userId = req.user.id;

    const summary = await habitService.getStreaksSummary(userId);

    res.json(summary);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get habits due today
 */
export async function getHabitsDueToday(req, res) {
  try {
    const userId = req.user.id;

    const habits = await habitService.getHabitsDueToday(userId);

    res.json(habits);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get habit statistics
 */
export async function getHabitStats(req, res) {
  try {
    const userId = req.user.id;

    const stats = await habitService.getHabitStats(userId);

    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get habit consistency percentage
 */
export async function getHabitConsistency(req, res) {
  try {
    const userId = req.user.id;

    const consistency = await habitService.getHabitConsistency(userId);

    res.json({ consistency });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
