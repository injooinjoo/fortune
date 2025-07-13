import { Request, Response, NextFunction } from 'express';
import { ForbiddenError } from '../utils/errors';

export function adminMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  // Check if user is authenticated
  if (!req.user) {
    return next(new ForbiddenError('Authentication required'));
  }

  // Check if user has admin role
  if (req.user.role !== 'admin' && req.user.role !== 'super_admin') {
    return next(new ForbiddenError('Admin access required'));
  }

  next();
}