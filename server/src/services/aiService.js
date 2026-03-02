/**
 * AI Service - Handles all Mistral-7B interactions via Hugging Face API
 * Budget-conscious: Minimal calls, caching, batching
 */

import axios from 'axios';

// Mistral model via Hugging Face Inference API
const HF_API_URL = 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.1';
const HF_TOKEN = process.env.HUGGING_FACE_API_KEY;

// Simple in-memory cache to avoid duplicate calls (in production, use Redis)
const cache = new Map();

/**
 * Call Mistral AI via Hugging Face API
 */
async function callMistral(prompt, maxTokens = 256) {
  if (!HF_TOKEN) {
    throw new Error('HUGGING_FACE_API_KEY not set; cannot call Hugging Face');
  }
  const cacheKey = `mistral_${prompt.substring(0, 50)}`;
  if (cache.has(cacheKey)) {
    console.log('[AI] Cache hit:', cacheKey);
    return cache.get(cacheKey);
  }

  try {
    console.log('[AI] Calling Mistral API...');
    const response = await axios.post(
      HF_API_URL,
      {
        inputs: prompt,
        parameters: {
          max_new_tokens: maxTokens,
          temperature: 0.7,
          top_p: 0.95,
        },
      },
      {
        headers: {
          Authorization: `Bearer ${HF_TOKEN}`,
          'Content-Type': 'application/json',
        },
        timeout: 30000,
      }
    );

    const generatedText = response.data[0]?.generated_text || '';
    const aiResponse = generatedText.replace(prompt, '').trim();
    cache.set(cacheKey, aiResponse);

    console.log('[AI] Response received');
    return aiResponse;
  } catch (error) {
    console.error('[AI] Mistral API error:', error.message);
    throw error;
  }
}

class AIService {
  /**
   * AI Task Breakdown - Break down complex tasks using Mistral
   */
  static async generateTaskBreakdown(taskTitle, taskDescription) {
    try {
      console.log('[AI] Generating task breakdown for:', taskTitle);
      
      const prompt = `Break down this task into 3-5 concrete subtasks:
Task: "${taskTitle}"
Details: "${taskDescription}"

Return as JSON array only:
[{"title":"Subtask 1","estimatedMinutes":15}]`;

      const response = await callMistral(prompt, 300);
      const subtasks = JSON.parse(response);
      
      return {
        subtasks,
        estimatedDuration: subtasks.reduce((sum, t) => sum + t.estimatedMinutes, 0),
        aiGenerated: true
      };
    } catch (error) {
      console.error('[AI] Task breakdown error:', error);
      // Logic fallback: simple slicing of description into 3 chunks
      const chunks = (taskDescription || taskTitle).split(/[,.;]/).filter(Boolean).map(s => s.trim());
      const fallback = (chunks.length > 0 ? chunks : ['Plan', 'Execute', 'Review']).slice(0, 3).map((c, i) => ({
        title: c || `Step ${i + 1}`,
        estimatedMinutes: 30,
      }));
      return {
        subtasks: fallback,
        estimatedDuration: fallback.reduce((sum, t) => sum + t.estimatedMinutes, 0),
        aiGenerated: false
      };
    }
  }

  /**
   * AI Semester Planner - Complex planning with AI
   */
  static async generateSemesterPlan(goal, deadline, currentDate) {
    try {
      const daysLeft = Math.ceil((new Date(deadline) - new Date(currentDate)) / (1000 * 60 * 60 * 24));
      
      const prompt = `Create a semester plan for: "${goal}" (due in ${daysLeft} days).
Return 4-6 milestones with week numbers, tasks, and reasoning.
Format: [{"week":1,"milestone":"Name","tasks":["Task 1"],"reasoning":"Why"}]`;

      const response = await callMistral(prompt, 500);
      const plan = JSON.parse(response);
      
      return { plan, aiGenerated: true };
    } catch (error) {
      console.error('[AI] Semester plan error:', error);
      // Logic fallback: evenly spaced milestones until deadline
      const milestones = [];
      for (let i = 1; i <= 4; i++) {
        milestones.push({ week: i * 2, milestone: `Milestone ${i}`, tasks: [`Progress ${i * 25}%`], reasoning: 'Even pacing fallback' });
      }
      return { plan: milestones, aiGenerated: false };
    }
  }

  /**
   * AI Why Falling Behind Analysis
   */
  static async analyzeWhyFallingBehind(missedTasks, completionRate, failurePatterns) {
    try {
      const prompt = `Analyze why user is falling behind:
- Missed tasks: ${missedTasks}
- Completion rate: ${completionRate}%
- Patterns: ${failurePatterns.join(', ')}

Give brief empathetic analysis and ONE actionable step.`;

      const response = await callMistral(prompt, 200);
      
      return {
        analysis: response,
        aiGenerated: true
      };
    } catch (error) {
      console.error('[AI] Fallbehind analysis error:', error);
      const missed = missedTasks || 0;
      const rate = completionRate || 0;
      const patterns = (failurePatterns || []).join(', ');
      const analysis = `You missed ${missed} tasks and completed ${rate}% recently.${patterns ? ` Patterns: ${patterns}.` : ''} Focus on one high-priority task now and set a small deadline.`;
      return { analysis, aiGenerated: false };
    }
  }

  /**
   * AI Goal Step Generator
   */
  static async generateGoalSteps(goalTitle, goalDescription, timeframe) {
    try {
      const prompt = `Generate 5-7 concrete steps to achieve this goal:
Goal: "${goalTitle}"
Details: "${goalDescription}"
Timeframe: ${timeframe}

Return JSON: [{"step":1,"title":"Step","description":"What","metrics":"How to measure"}]`;

      const response = await callMistral(prompt, 400);
      const steps = JSON.parse(response);
      
      return { steps, aiGenerated: true };
    } catch (error) {
      console.error('[AI] Goal steps error:', error);
      const fallback = [
        { step: 1, title: 'Clarify the goal', description: 'Write what success looks like', metrics: 'Definition written' },
        { step: 2, title: 'Break into tasks', description: 'List 3-5 tasks', metrics: 'Task list ready' },
        { step: 3, title: 'Schedule tasks', description: 'Place tasks on calendar', metrics: 'Calendar slots filled' },
        { step: 4, title: 'Do first task', description: 'Ship the first task within 24h', metrics: 'Task 1 done' },
        { step: 5, title: 'Review weekly', description: 'Adjust scope based on progress', metrics: 'Weekly review logged' },
      ];
      return { steps: fallback, aiGenerated: false };
    }
  }

  /**
   * Logic-based: Adaptive Workload Balancer
   */
  static async adaptiveWorkloadBalance(tasks = [], maxHoursPerDay = 6, startDate = new Date()) {
    const schedule = {};
    const overflow = [];
    const tasksWithDefaults = tasks.map((t, idx) => ({
      id: t.id || `task_${idx}`,
      title: t.title || `Task ${idx + 1}`,
      priority: t.priority || 'medium',
      dueDate: t.dueDate ? new Date(t.dueDate) : null,
      estimatedMinutes: Number(t.estimatedMinutes) || 30,
    }));

    const order = { high: 0, medium: 1, low: 2 };
    tasksWithDefaults.sort((a, b) => {
      if (order[a.priority] !== order[b.priority]) return order[a.priority] - order[b.priority];
      if (a.dueDate && b.dueDate) return a.dueDate - b.dueDate;
      if (a.dueDate) return -1;
      if (b.dueDate) return 1;
      return a.estimatedMinutes - b.estimatedMinutes;
    });

    const dayMinutesCap = maxHoursPerDay * 60;
    let cursor = new Date(startDate);

    for (const task of tasksWithDefaults) {
      let placed = false;
      // Try from today until due date (or 14 days lookahead if no due date)
      const lookahead = task.dueDate ? Math.max(1, Math.ceil((task.dueDate - cursor) / (1000 * 60 * 60 * 24))) : 14;
      for (let d = 0; d <= lookahead; d++) {
        const day = new Date(cursor);
        day.setDate(cursor.getDate() + d);
        const key = day.toISOString().slice(0, 10);
        if (!schedule[key]) schedule[key] = { tasks: [], totalMinutes: 0 };
        if (schedule[key].totalMinutes + task.estimatedMinutes <= dayMinutesCap) {
          schedule[key].tasks.push(task);
          schedule[key].totalMinutes += task.estimatedMinutes;
          placed = true;
          break;
        }
      }
      if (!placed) overflow.push(task);
    }

    return { schedule, overflow, aiGenerated: false };
  }

  /**
   * Logic-based: Context/Energy-aware reminders
   */
  static contextAwareReminders(tasks = [], focusHistory = []) {
    // Derive peak windows from focus history
    const buckets = { morning: 0, afternoon: 0, evening: 0 };
    focusHistory.forEach(f => {
      const hour = f.hour ?? new Date(f.start || Date.now()).getHours();
      if (hour < 12) buckets.morning += f.minutes || 0;
      else if (hour < 18) buckets.afternoon += f.minutes || 0;
      else buckets.evening += f.minutes || 0;
    });
    const peak = Object.entries(buckets).sort((a, b) => b[1] - a[1])[0]?.[0] || 'afternoon';

    const dueSoon = tasks.filter(t => {
      if (!t.dueDate) return false;
      const diff = (new Date(t.dueDate) - new Date()) / (1000 * 60 * 60);
      return diff >= 0 && diff <= 48;
    });

    const reminders = dueSoon.map(t => ({
      taskId: t.id,
      title: t.title,
      sendAt: peak,
      reason: 'Due soon',
    }));

    return { reminders, peakWindow: peak, aiGenerated: false };
  }

  /**
   * Logic-based: Long-term consistency predictor
   */
  static predictConsistency(stats = {}) {
    const completionRates = stats.completionRates || [];
    const avgStreak = stats.avgStreak || 0;
    const recent = completionRates.slice(-7);
    const rate = recent.length ? recent.reduce((a, b) => a + b, 0) / recent.length : 0;
    const score = Math.max(0, Math.min(100, Math.round(rate * 0.6 + Math.min(avgStreak, 30) * 1.3)));
    const outlook = score > 75 ? 'Strong consistency expected' : score > 50 ? 'Moderate consistency; keep streaks alive' : 'At risk; simplify daily goals';
    return { score, outlook, aiGenerated: false };
  }

  /**
   * Logic-based: Smart Scheduling
   */
  static async smartSchedule(tasks, availableHours = 8) {
    try {
      const sorted = tasks.sort((a, b) => {
        const priorityOrder = { high: 0, medium: 1, low: 2 };
        if (priorityOrder[a.priority] !== priorityOrder[b.priority]) {
          return priorityOrder[a.priority] - priorityOrder[b.priority];
        }
        return new Date(a.dueDate) - new Date(b.dueDate);
      });

      const schedule = [];
      let hoursUsed = 0;

      for (const task of sorted) {
        const taskHours = (task.estimatedMinutes || 30) / 60;
        if (hoursUsed + taskHours <= availableHours) {
          schedule.push(task);
          hoursUsed += taskHours;
        }
      }

      return {
        schedule,
        optimized: true,
        aiGenerated: false
      };
    } catch (error) {
      console.error('Error in smart schedule:', error);
      throw error;
    }
  }

  /**
   * Logic-based: Procrastination Detection
   */
  static async detectProcrastination(tasks, habits) {
    const missedToday = tasks.filter(t => t.dueDate === 'today' && !t.completed).length;
    const overdue = tasks.filter(t => new Date(t.dueDate) < new Date() && !t.completed).length;
    const streak = habits?.currentStreak || 0;

    let level = 'low';
    let reasoning = '';

    if (overdue > 2 || missedToday > 1) {
      level = 'high';
      reasoning = 'High procrastination detected. You have overdue tasks.';
    } else if (missedToday > 0 || streak === 0) {
      level = 'medium';
      reasoning = 'Some procrastination. Check your habits.';
    } else {
      level = 'low';
      reasoning = 'You\'re on track! Keep it up.';
    }

    return { level, reasoning, score: { missedToday, overdue, streak }, aiGenerated: false };
  }

  /**
   * Logic-based: Time Estimation
   */
  static async estimateTaskTime(taskType, complexity, historicalData = []) {
    const baseEstimates = {
      homework: 45, project: 120, reading: 30, coding: 90, studying: 60, misc: 30
    };

    const base = baseEstimates[taskType] || 30;
    const multiplier = { simple: 0.5, medium: 1, complex: 1.5, veryComplex: 2 }[complexity] || 1;

    const similar = historicalData.filter(t => t.type === taskType);
    const historicalAvg = similar.length > 0 
      ? similar.reduce((sum, t) => sum + (t.actualMinutes || base), 0) / similar.length 
      : base;

    const estimate = Math.round(historicalAvg * 0.7 + base * multiplier * 0.3);

    return {
      estimatedMinutes: estimate,
      reasoning: `${taskType} + ${complexity} complexity`,
      aiGenerated: false
    };
  }

  /**
   * Logic-based: Weekly Reflection
   */
  static async weeklyReflection(tasksCompleted, tasksMissed, habitsTracked, skillsImproved) {
    const rate = Math.round((tasksCompleted / (tasksCompleted + tasksMissed)) * 100);
    
    return {
      insights: [
        `You completed ${tasksCompleted} tasks (${rate}% completion rate)`,
        `You maintained ${habitsTracked} habits this week`,
        skillsImproved.length > 0 ? `Improved: ${skillsImproved.join(', ')}` : 'Focus on consistency'
      ],
      recommendations: rate > 80 ? 'Challenge yourself with more tasks' : 'Focus on completing fewer, high-priority tasks',
      motivationalMessage: rate > 80 ? 'Crushing it! 🔥' : 'Great effort! Keep going! 💪',
      aiGenerated: false
    };
  }

  /**
   * Logic-based: Motivational Messages
   */
  static generateMotivationalMessage(context = 'afternoon') {
    const messages = {
      morning: [
        "Rise and shine! 🌅 Let's make today count!",
        "New day, new opportunities. What will you achieve today?",
      ],
      afternoon: [
        "Halfway through! Keep the momentum going. 🚀",
        "You've got this! One task at a time.",
      ],
      evening: [
        "Great work today! Rest well tonight. 🌙",
        "Be proud of your effort. Consistency wins.",
      ],
      struggling: [
        "It's okay. Progress isn't linear. Keep going! 💙",
        "This is temporary. Your determination is permanent.",
      ],
      winning: [
        "You're on fire! 🔥 Keep riding this wave!",
        "Absolutely crushing it! Your consistency is paying off.",
      ],
    };

    const list = messages[context] || messages.afternoon;
    return list[Math.floor(Math.random() * list.length)];
  }

  /**
   * Logic-based: Gap Analysis (Current vs Dream)
   */
  static async analyzeGap(currentMetrics, dreamMetrics) {
    const gaps = {};
    let totalGap = 0;

    for (const key in dreamMetrics) {
      const current = currentMetrics[key] || 0;
      const dream = dreamMetrics[key] || 0;
      const gap = dream > 0 ? Math.round(((dream - current) / dream) * 100) : 0;
      gaps[key] = { current, dream, gapPercentage: gap };
      totalGap += gap;
    }

    const avgGap = Math.round(totalGap / Object.keys(gaps).length);

    return {
      gaps,
      avgGap,
      insights: avgGap > 50 ? 'Large gap. Focus on one area.' : 'Making progress. Stay consistent.',
      aiGenerated: false
    };
  }

  /**
   * Tobi AI Suggestions - Context-aware recommendations
   */
  static async getTobiSuggestions(userId, context = {}) {
    const { completionRate, streakDays, pendingTasks, focusTime } = context;

    const suggestions = [];
    
    if (pendingTasks > 5) suggestions.push(`You have ${pendingTasks} tasks. Start with the highest priority.`);
    if (streakDays > 0) suggestions.push(`You have a ${streakDays}-day streak! Keep it going! 🔥`);
    if (completionRate < 50) suggestions.push('Try breaking tasks into smaller chunks.');
    if (focusTime === 0) suggestions.push('Start a focus session to boost productivity.');
    
    return {
      suggestions: suggestions.length > 0 ? suggestions : ['You\'re all set! Great job today.'],
      action: 'CONTINUE',
      aiGenerated: false
    };
  }
}

export default AIService;
