// Rate limiting middleware for Supabase Edge Functions

interface RateLimitConfig {
  windowMs: number;  // Time window in milliseconds
  max: number;       // Max requests per window
  keyGenerator?: (req: Request) => string;  // Custom key generator
}

interface RateLimitStore {
  [key: string]: {
    count: number;
    resetTime: number;
  };
}

// In-memory store (will reset on function cold start)
const store: RateLimitStore = {};

// Clean up expired entries periodically
const cleanupStore = () => {
  const now = Date.now();
  for (const key in store) {
    if (store[key].resetTime < now) {
      delete store[key];
    }
  }
};

export class RateLimiter {
  private config: RateLimitConfig;

  constructor(config: RateLimitConfig) {
    this.config = {
      windowMs: config.windowMs || 60000,  // 1 minute default
      max: config.max || 100,              // 100 requests default
      keyGenerator: config.keyGenerator || this.defaultKeyGenerator,
    };
  }

  private defaultKeyGenerator(req: Request): string {
    // Use IP address or user ID as key
    const ip = req.headers.get('x-forwarded-for') || 
               req.headers.get('x-real-ip') || 
               'unknown';
    const userId = req.headers.get('x-user-id') || 'anonymous';
    return `${ip}:${userId}`;
  }

  async checkLimit(req: Request): Promise<{ allowed: boolean; remaining: number; resetTime: number }> {
    cleanupStore();
    
    const key = this.config.keyGenerator!(req);
    const now = Date.now();
    const resetTime = now + this.config.windowMs;

    if (!store[key] || store[key].resetTime < now) {
      // Create new window
      store[key] = {
        count: 1,
        resetTime: resetTime,
      };
      return {
        allowed: true,
        remaining: this.config.max - 1,
        resetTime: resetTime,
      };
    }

    // Check if limit exceeded
    if (store[key].count >= this.config.max) {
      return {
        allowed: false,
        remaining: 0,
        resetTime: store[key].resetTime,
      };
    }

    // Increment counter
    store[key].count++;
    return {
      allowed: true,
      remaining: this.config.max - store[key].count,
      resetTime: store[key].resetTime,
    };
  }

  createMiddleware() {
    return async (req: Request): Promise<Response | null> => {
      const result = await this.checkLimit(req);

      // Set rate limit headers
      const headers = new Headers();
      headers.set('X-RateLimit-Limit', this.config.max.toString());
      headers.set('X-RateLimit-Remaining', result.remaining.toString());
      headers.set('X-RateLimit-Reset', new Date(result.resetTime).toISOString());

      if (!result.allowed) {
        headers.set('Retry-After', Math.ceil((result.resetTime - Date.now()) / 1000).toString());
        
        return new Response(
          JSON.stringify({
            error: 'Too Many Requests',
            message: 'Rate limit exceeded. Please try again later.',
            retryAfter: Math.ceil((result.resetTime - Date.now()) / 1000),
          }),
          {
            status: 429,
            headers: headers,
          }
        );
      }

      // Continue with request (return null to proceed)
      return null;
    };
  }
}

// Pre-configured rate limiters for different use cases
export const rateLimiters = {
  // General API rate limit
  general: new RateLimiter({
    windowMs: 60 * 1000,    // 1 minute
    max: 60,                // 60 requests per minute
  }),

  // Strict rate limit for expensive operations
  strict: new RateLimiter({
    windowMs: 60 * 1000,    // 1 minute
    max: 10,                // 10 requests per minute
  }),

  // Fortune generation rate limit
  fortune: new RateLimiter({
    windowMs: 60 * 1000,    // 1 minute
    max: 20,                // 20 fortunes per minute
    keyGenerator: (req) => {
      const userId = req.headers.get('x-user-id') || 
                     req.headers.get('authorization')?.split(' ')[1] || 
                     'anonymous';
      return `fortune:${userId}`;
    },
  }),

  // Authentication rate limit
  auth: new RateLimiter({
    windowMs: 15 * 60 * 1000,  // 15 minutes
    max: 5,                    // 5 attempts per 15 minutes
    keyGenerator: (req) => {
      const ip = req.headers.get('x-forwarded-for') || 
                 req.headers.get('x-real-ip') || 
                 'unknown';
      return `auth:${ip}`;
    },
  }),
};