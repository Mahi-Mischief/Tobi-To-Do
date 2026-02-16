import * as dreamMeService from '../services/dreamMeService.js';
import { awardXP } from '../services/gamificationService.js';

/**
 * Save or update Dream Me profile
 */
export async function saveDreamProfile(req, res) {
  try {
    const userId = req.user.id;
    const profileData = req.body;

    const profile = await dreamMeService.saveDreamProfile(userId, profileData);

    // Award XP for creating dream profile
    await awardXP(userId, 25, 'dream_me_profile');

    res.status(201).json(profile);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Get Dream Me profile
 */
export async function getDreamProfile(req, res) {
  try {
    const userId = req.user.id;

    const profile = await dreamMeService.getDreamProfile(userId);

    if (!profile) {
      return res.status(404).json({ error: 'Dream profile not found' });
    }

    res.json(profile);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get alignment score
 */
export async function getAlignmentScore(req, res) {
  try {
    const userId = req.user.id;

    const alignment = await dreamMeService.calculateAlignmentScore(userId);

    res.json(alignment);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get gap analysis
 */
export async function getGapAnalysis(req, res) {
  try {
    const userId = req.user.id;

    const analysis = await dreamMeService.generateGapAnalysis(userId);

    res.json(analysis);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Record a reflection/journaling entry
 */
export async function recordReflection(req, res) {
  try {
    const userId = req.user.id;
    const reflectionData = req.body;

    const reflection = await dreamMeService.recordReflection(userId, reflectionData);

    res.status(201).json(reflection);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

/**
 * Get recent reflections
 */
export async function getReflections(req, res) {
  try {
    const userId = req.user.id;
    const { limit } = req.query;

    const reflections = await dreamMeService.getReflections(userId, limit || 10);

    res.json(reflections);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get Dream Me insights (comprehensive dashboard)
 */
export async function getDreamMeInsights(req, res) {
  try {
    const userId = req.user.id;

    const insights = await dreamMeService.getDreamMeInsights(userId);

    res.json(insights);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}

/**
 * Get milestone progress toward 3-year goal
 */
export async function getMilestoneProgress(req, res) {
  try {
    const userId = req.user.id;

    const progress = await dreamMeService.getMilestoneProgress(userId);

    res.json(progress);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
}
