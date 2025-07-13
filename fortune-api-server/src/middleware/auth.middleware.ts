import { Request, Response, NextFunction } from 'express';
import { createClient } from '@supabase/supabase-js';
import { env } from '../config/env';
import { UnauthorizedError } from '../utils/errors';
import logger from '../utils/logger';

// Extend Express Request type
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        email: string;
        role?: string;
        metadata?: any;
      };
      session?: string;
    }
  }
}

// Initialize Supabase client
const supabase = createClient(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);

export async function authMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    // Check for authorization header
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('Missing or invalid authorization header');
    }

    // Extract token
    const token = authHeader.substring(7);

    // Verify token with Supabase
    const { data: { user }, error } = await supabase.auth.getUser(token);

    if (error || !user) {
      logger.warn('Invalid token attempt', { error: error?.message });
      throw new UnauthorizedError('Invalid token');
    }

    // Attach user to request
    req.user = {
      id: user.id,
      email: user.email!,
      role: user.user_metadata?.role || 'user',
      metadata: user.user_metadata,
    };
    req.session = token;

    next();
  } catch (error) {
    next(error);
  }
}

// Optional auth middleware (doesn't throw error if no token)
export async function optionalAuthMiddleware(
  req: Request,
  res: Response,
  next: NextFunction,
): Promise<void> {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const token = authHeader.substring(7);
    const { data: { user } } = await supabase.auth.getUser(token);

    if (user) {
      req.user = {
        id: user.id,
        email: user.email!,
        role: user.user_metadata?.role || 'user',
        metadata: user.user_metadata,
      };
      req.session = token;
    }
  } catch (error) {
    // Log error but continue without auth
    logger.error('Optional auth error:', error);
  }
  
  next();
}