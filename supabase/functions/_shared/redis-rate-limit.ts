// Redis-based rate limiting for Supabase Edge Functions
// Uses Upstash Redis for distributed rate limiting

interface RateLimitConfig {
  windowMs: number;  // Time window in milliseconds
  max: number;       // Max requests per window
  keyPrefix?: string; // Prefix for Redis keys
  skipSuccessfulRequests?: boolean; // Don't count successful requests
  skipFailedRequests?: boolean; // Don't count failed requests
}

interface RateLimitResult {
  allowed: boolean;
  remaining: number;
  resetTime: number;
  retryAfter?: number;
}

// Upstash Redis client
class UpstashRedis {
  private baseUrl: string;
  private token: string;

  constructor() {
    this.baseUrl = Deno.env.get('UPSTASH_REDIS_REST_URL') || '';
    this.token = Deno.env.get('UPSTASH_REDIS_REST_TOKEN') || '';

    if (!this.baseUrl || !this.token) {
      console.warn('Upstash Redis not configured. Rate limiting will fall back to in-memory.');
    }
  }

  async command(...args: any[]): Promise<any> {
    if (!this.baseUrl || !this.token) {
      throw new Error('Redis not configured');
    }

    try {
      const response = await fetch(`${this.baseUrl}`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(args),
      });

      if (!response.ok) {
        throw new Error(`Redis command failed: ${response.statusText}`);
      }

      const data = await response.json();
      return data.result;
    } catch (error) {
      console.error('Redis command error:', error);
      throw error;
    }
  }

  // Atomic increment with expiry
  async incr(key: string, windowMs: number): Promise<number> {
    const multi = [
      ['INCR', key],
      ['EXPIRE', key, Math.ceil(windowMs / 1000)],
    ];

    const results = await this.command('MULTI', ...multi, 'EXEC');
    return results[0]; // Return the incremented value
  }

  // Get current count
  async get(key: string): Promise<number> {
    const result = await this.command('GET', key);
    return result ? parseInt(result) : 0;
  }

  // Get TTL
  async ttl(key: string): Promise<number> {
    const result = await this.command('TTL', key);
    return result > 0 ? result * 1000 : 0; // Convert to milliseconds
  }

  // Set with expiry (for initialization)
  async setex(key: string, seconds: number, value: string): Promise<void> {
    await this.command('SETEX', key, seconds, value);
  }
}

// Fallback in-memory store for when Redis is unavailable
interface MemoryStore {
  [key: string]: {
    count: number;
    resetTime: number;
  };
}

const memoryStore: MemoryStore = {};

// Clean up expired entries periodically
const cleanupMemoryStore = () => {
  const now = Date.now();
  for (const key in memoryStore) {
    if (memoryStore[key].resetTime < now) {
      delete memoryStore[key];
    }
  }
};

export class RedisRateLimiter {
  private config: RateLimitConfig;
  private redis: UpstashRedis;
  private useRedis: boolean;

  constructor(config: RateLimitConfig) {
    this.config = {
      windowMs: config.windowMs || 60000,  // 1 minute default
      max: config.max || 100,              // 100 requests default
      keyPrefix: config.keyPrefix || 'ratelimit:',
      skipSuccessfulRequests: config.skipSuccessfulRequests || false,
      skipFailedRequests: config.skipFailedRequests || false,
    };

    this.redis = new UpstashRedis();
    this.useRedis = !!Deno.env.get('UPSTASH_REDIS_REST_URL');
  }

  private generateKey(identifier: string): string {
    const window = Math.floor(Date.now() / this.config.windowMs);
    return `${this.config.keyPrefix}${identifier}:${window}`;
  }

  async checkLimit(identifier: string): Promise<RateLimitResult> {
    const key = this.generateKey(identifier);
    const now = Date.now();
    const windowStart = Math.floor(now / this.config.windowMs) * this.config.windowMs;
    const resetTime = windowStart + this.config.windowMs;

    try {
      if (this.useRedis) {
        // Use Redis for distributed rate limiting
        const count = await this.redis.incr(key, this.config.windowMs);
        
        if (count > this.config.max) {
          // Limit exceeded
          const ttl = await this.redis.ttl(key);
          return {
            allowed: false,
            remaining: 0,
            resetTime: now + ttl,
            retryAfter: Math.ceil(ttl / 1000),
          };
        }

        return {
          allowed: true,
          remaining: Math.max(0, this.config.max - count),
          resetTime,
        };
      } else {
        // Fallback to in-memory rate limiting
        cleanupMemoryStore();
        
        if (!memoryStore[key] || memoryStore[key].resetTime < now) {
          // Create new window
          memoryStore[key] = {
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
        if (memoryStore[key].count >= this.config.max) {
          return {
            allowed: false,
            remaining: 0,
            resetTime: memoryStore[key].resetTime,
            retryAfter: Math.ceil((memoryStore[key].resetTime - now) / 1000),
          };
        }

        // Increment counter
        memoryStore[key].count++;
        return {
          allowed: true,
          remaining: this.config.max - memoryStore[key].count,
          resetTime: memoryStore[key].resetTime,
        };
      }
    } catch (error) {
      console.error('Rate limit check error, falling back to allow:', error);
      // On error, fail open (allow the request)
      return {
        allowed: true,
        remaining: this.config.max,
        resetTime,
      };
    }
  }

  // Create middleware function
  createMiddleware(keyGenerator?: (req: Request) => string) {
    const defaultKeyGenerator = (req: Request): string => {
      // Use IP address or user ID as key
      const ip = req.headers.get('x-forwarded-for')?.split(',')[0].trim() || 
                 req.headers.get('x-real-ip') || 
                 'unknown';
      const userId = req.headers.get('x-user-id') || 
                     req.headers.get('authorization')?.split(' ')[1] || 
                     'anonymous';
      return `${ip}:${userId}`;
    };

    const getKey = keyGenerator || defaultKeyGenerator;

    return async (req: Request): Promise<Response | null> => {
      const identifier = getKey(req);
      const result = await this.checkLimit(identifier);

      // Set rate limit headers
      const headers = new Headers();
      headers.set('X-RateLimit-Limit', this.config.max.toString());
      headers.set('X-RateLimit-Remaining', result.remaining.toString());
      headers.set('X-RateLimit-Reset', new Date(result.resetTime).toISOString());

      if (!result.allowed) {
        headers.set('Retry-After', result.retryAfter!.toString());
        
        return new Response(
          JSON.stringify({
            error: 'Too Many Requests',
            message: 'Rate limit exceeded. Please try again later.',
            retryAfter: result.retryAfter,
          }),
          {
            status: 429,
            headers: headers,
          }
        );
      }

      // Add headers to the request for later use
      (req as any).rateLimitHeaders = headers;
      
      // Continue with request (return null to proceed)
      return null;
    };
  }
}

// Pre-configured rate limiters for different use cases
export const redisRateLimiters = {
  // General API rate limit
  general: new RedisRateLimiter({
    windowMs: 60 * 1000,    // 1 minute
    max: 60,                // 60 requests per minute
    keyPrefix: 'rl:general:',
  }),

  // Strict rate limit for expensive operations
  strict: new RedisRateLimiter({
    windowMs: 60 * 1000,    // 1 minute
    max: 10,                // 10 requests per minute
    keyPrefix: 'rl:strict:',
  }),

  // Fortune generation rate limit
  fortune: new RedisRateLimiter({
    windowMs: 60 * 1000,    // 1 minute
    max: 20,                // 20 fortunes per minute
    keyPrefix: 'rl:fortune:',
  }),

  // Authentication rate limit
  auth: new RedisRateLimiter({
    windowMs: 15 * 60 * 1000,  // 15 minutes
    max: 5,                    // 5 attempts per 15 minutes
    keyPrefix: 'rl:auth:',
  }),

  // Payment verification rate limit
  payment: new RedisRateLimiter({
    windowMs: 60 * 1000,       // 1 minute
    max: 5,                    // 5 verifications per minute
    keyPrefix: 'rl:payment:',
  }),
};

// Helper function to apply rate limit headers to response
export function applyRateLimitHeaders(req: Request, response: Response): Response {
  const headers = (req as any).rateLimitHeaders;
  if (headers) {
    headers.forEach((value: string, key: string) => {
      response.headers.set(key, value);
    });
  }
  return response;
}