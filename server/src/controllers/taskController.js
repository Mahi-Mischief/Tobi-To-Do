import { TaskService } from '../services/taskService.js';
import AIService from '../services/aiService.js';

export class TaskController {
  // Create task
  static async createTask(req, res, next) {
    try {
      const taskData = req.body;
      const task = await TaskService.createTask(req.userId, taskData);

      res.status(201).json({
        success: true,
        task
      });
    } catch (error) {
      next(error);
    }
  }

  // Get all tasks
  static async getTasks(req, res, next) {
    try {
      const filters = {
        status: req.query.status,
        priority: req.query.priority,
        completed: req.query.completed === 'true'
      };

      // Remove undefined filters
      Object.keys(filters).forEach(key => 
        filters[key] === undefined && delete filters[key]
      );

      const tasks = await TaskService.getTasks(req.userId, filters);

      res.status(200).json({
        success: true,
        tasks,
        count: tasks.length
      });
    } catch (error) {
      next(error);
    }
  }

  // Get single task
  static async getTask(req, res, next) {
    try {
      const task = await TaskService.getTaskById(req.userId, req.params.id);

      res.status(200).json({
        success: true,
        task
      });
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  // Update task
  static async updateTask(req, res, next) {
    try {
      const updates = req.body;
      const task = await TaskService.updateTask(req.userId, req.params.id, updates);

      res.status(200).json({
        success: true,
        task
      });
    } catch (error) {
      next(error);
    }
  }

  // Delete task
  static async deleteTask(req, res, next) {
    try {
      const result = await TaskService.deleteTask(req.userId, req.params.id);

      res.status(200).json({
        success: true,
        result
      });
    } catch (error) {
      res.status(404).json({ error: error.message });
    }
  }

  // Get dashboard stats
  static async getDashboardStats(req, res, next) {
    try {
      const stats = await TaskService.getDashboardStats(req.userId);

      res.status(200).json({
        success: true,
        stats
      });
    } catch (error) {
      next(error);
    }
  }

  // Generate task breakdown with AI
  static async generateTaskBreakdown(req, res, next) {
    try {
      const { taskDescription } = req.body;

      if (!taskDescription) {
        return res.status(400).json({ error: 'Task description is required' });
      }

      const breakdown = await AIService.generateTaskBreakdown(taskDescription);

      res.status(200).json({
        success: true,
        breakdown
      });
    } catch (error) {
      next(error);
    }
  }

  // Get smart schedule
  static async getSmartSchedule(req, res, next) {
    try {
      const tasks = await TaskService.getTasks(req.userId, { completed: false });
      const schedule = await AIService.smartSchedule(tasks);

      res.status(200).json({
        success: true,
        schedule
      });
    } catch (error) {
      next(error);
    }
  }
}
