export class ApiError extends Error {
  statusCode: number;
  details?: any;

  constructor(message: string, statusCode: number, details?: any) {
    super(message);
    this.statusCode = statusCode;
    this.details = details;
    this.name = 'ApiError';
    Error.captureStackTrace(this, this.constructor);
  }
}

export class ValidationError extends ApiError {
  constructor(message: string, details?: any) {
    super(message, 400, details);
    this.name = 'ValidationError';
  }
}

export class UnauthorizedError extends ApiError {
  constructor(message: string = 'Unauthorized') {
    super(message, 401);
    this.name = 'UnauthorizedError';
  }
}

export class ForbiddenError extends ApiError {
  constructor(message: string = 'Forbidden') {
    super(message, 403);
    this.name = 'ForbiddenError';
  }
}

export class NotFoundError extends ApiError {
  constructor(message: string = 'Resource not found') {
    super(message, 404);
    this.name = 'NotFoundError';
  }
}

export class ConflictError extends ApiError {
  constructor(message: string, details?: any) {
    super(message, 409, details);
    this.name = 'ConflictError';
  }
}

export class TooManyRequestsError extends ApiError {
  constructor(message: string = 'Too many requests') {
    super(message, 429);
    this.name = 'TooManyRequestsError';
  }
}

export class InternalServerError extends ApiError {
  constructor(message: string = 'Internal server error', details?: any) {
    super(message, 500, details);
    this.name = 'InternalServerError';
  }
}