// Utility functions for common operations

export function generateId() {
  return crypto.randomUUID();
}

export function getCurrentTimestamp() {
  return new Date().toISOString();
}

export function calculateTaskStats(tasks) {
  return {
    total: tasks.length,
    completed: tasks.filter(t => t.completed).length,
    pending: tasks.filter(t => !t.completed).length,
    highPriority: tasks.filter(t => t.priority === 'high' && !t.completed).length
  };
}

export function formatErrorResponse(error) {
  return {
    error: error.message,
    timestamp: getCurrentTimestamp()
  };
}
