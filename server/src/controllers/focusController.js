import * as focusService from '../services/focusService.js';
import { awardXP } from '../services/gamificationService.js';

/**
 * Start a focus session
 */
export async function startFocusSession(req, res) {
  try {
    const { taskId, durationMinutes } = req.body;
    const userId = req.user.id;

    const session = await focusService.startFocusSession(userId, taskId, durationMinutes);

    res.status(201).json(session);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * End a focus session
 */
export async function endFocusSession(req, res) {
  try {
    const { sessionId } = req.params;
    const { completed } = req.body;

    const session = await focusService.endFocusSession(sessionId, completed || true);

    res.json(session);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Get focus session history
 */
export async function getFocusHistory(req, res) {
  try {
    const userId = req.user.id;
    const { limit } = req.query;

    const history = await focusService.getFocusHistory(userId, limit || 50);

    res.json(history);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get focus statistics
 */
export async function getFocusStats(req, res) {
  try {
    const userId = req.user.id;
    const { days } = req.query;

    const stats = await focusService.getFocusStats(userId, days || 30);

    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get burnout detection and recovery recommendations
 */
export async function getBurnoutInfo(req, res) {
  try {
    const userId = req.user.id;

    const recovery = await focusService.getBurnoutRecovery(userId);

    res.json(recovery);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get current active focus session
 */
export async function getActiveFocusSession(req, res) {
  try {
    const userId = req.user.id;

    const session = await focusService.getActiveFocusSession(userId);

    res.json(session);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get focus streak
 */
export async function getFocusStreak(req, res) {
  try {
    const userId = req.user.id;

    const streak = await focusService.getFocusStreak(userId);

    res.json({ streak });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
