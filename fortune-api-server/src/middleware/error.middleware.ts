import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger';
import { ApiError } from '../utils/errors';

export function errorHandler(
  err: Error | ApiError,
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  // Log error
  logger.error({
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });

  // Default error values
  let statusCode = 500;
  let message = 'Internal Server Error';
  let details = undefined;

  // Handle ApiError
  if (err instanceof ApiError) {
    statusCode = err.statusCode;
    message = err.message;
    details = err.details;
  } else if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation Error';
    details = err.message;
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401;
    message = 'Unauthorized';
  } else if (err.name === 'CastError') {
    statusCode = 400;
    message = 'Invalid ID format';
  }

  // Send error response
  res.status(statusCode).json({
    success: false,
    error: {
      message,
      ...(details && { details }),
      ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    },
    timestamp: new Date().toISOString(),
  });
}