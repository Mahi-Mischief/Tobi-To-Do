// Global error handling middleware
export function errorHandler(err, req, res, next) {
  console.error('Error:', err);

  // Handle JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({ error: 'Invalid token' });
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({ error: 'Token expired' });
  }

  // Handle validation errors
  if (err.isJoi) {
    return res.status(400).json({ 
      error: 'Validation error',
      details: err.details?.map(d => d.message)
    });
  }

  // Handle database errors
  if (err.code === '23505') { // Unique constraint violation
    return res.status(400).json({ error: 'Resource already exists' });
  }

  if (err.code === '23503') { // Foreign key violation
    return res.status(400).json({ error: 'Invalid reference' });
  }

  // Generic error response
  res.status(err.status || 500).json({
    error: process.env.NODE_ENV === 'development' 
      ? err.message 
      : 'Internal server error'
  });
}

// 404 handler
export function notFoundHandler(req, res) {
  res.status(404).json({ error: 'Route not found' });
}
