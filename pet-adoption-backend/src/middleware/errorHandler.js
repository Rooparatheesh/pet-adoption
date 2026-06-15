module.exports = (err, req, res, next) => {
  console.error('Unhandled Error:', err);

  const status = err.status || 500;
  const message = err.message || 'An unexpected error occurred on the server.';
  
  res.status(status).json({
    error: message,
    stack: process.env.NODE_ENV === 'development' ? err.stack : undefined
  });
};
