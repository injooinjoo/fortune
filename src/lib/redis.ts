import { Redis } from '@upstash/redis';
import { Ratelimit } from '@upstash/ratelimit';

let redis: Redis | null = null;
let ratelimit: Ratelimit | null = null;
let premiumRatelimit: Ratelimit | null = null;
let guestRatelimit: Ratelimit | null = null;
let cacheClient: Redis | null = null;

// Initialize Redis client
export function getRedis(): Redis | null {
  if (!redis && process.env.UPSTASH_REDIS_REST_URL && process.env.UPSTASH_REDIS_REST_TOKEN) {
    try {
      redis = new Redis({
        url: process.env.UPSTASH_REDIS_REST_URL,
        token: process.env.UPSTASH_REDIS_REST_TOKEN,
      });
    } catch (error) {
      console.error('Failed to initialize Redis client:', error);
    }
  }
  return redis;
}

// Initialize rate limiters with different configurations
export function getRateLimiters() {
  const redisClient = getRedis();
  
  if (!redisClient) {
    return { standard: null, premium: null, guest: null };
  }

  // Standard rate limiter: 10 requests per minute
  if (!ratelimit) {
    ratelimit = new Ratelimit({
      redis: redisClient,
      limiter: Ratelimit.slidingWindow(10, '1 m'),
      analytics: true,
      prefix: '@upstash/ratelimit:standard',
    });
  }

  // Premium rate limiter: 100 requests per minute
  if (!premiumRatelimit) {
    premiumRatelimit = new Ratelimit({
      redis: redisClient,
      limiter: Ratelimit.slidingWindow(100, '1 m'),
      analytics: true,
      prefix: '@upstash/ratelimit:premium',
    });
  }

  // Guest rate limiter: 5 requests per minute (stricter)
  if (!guestRatelimit) {
    guestRatelimit = new Ratelimit({
      redis: redisClient,
      limiter: Ratelimit.slidingWindow(5, '1 m'),
      analytics: true,
      prefix: '@upstash/ratelimit:guest',
    });
  }

  return {
    standard: ratelimit,
    premium: premiumRatelimit,
    guest: guestRatelimit,
  };
}

// Check if Redis is available
export function isRedisAvailable(): boolean {
  return !!(process.env.UPSTASH_REDIS_REST_URL && process.env.UPSTASH_REDIS_REST_TOKEN);
}

// Get cache client (separate from rate limiting)
export function getCacheClient(): Redis | null {
  if (!cacheClient && process.env.UPSTASH_REDIS_REST_URL && process.env.UPSTASH_REDIS_REST_TOKEN) {
    try {
      cacheClient = new Redis({
        url: process.env.UPSTASH_REDIS_REST_URL,
        token: process.env.UPSTASH_REDIS_REST_TOKEN,
      });
    } catch (error) {
      console.error('Failed to initialize cache client:', error);
    }
  }
  return cacheClient;
}

// Cache utilities
export const cache = {
  async get<T>(key: string): Promise<T | null> {
    const client = getCacheClient();
    if (!client) return null;
    
    try {
      return await client.get<T>(key);
    } catch (error) {
      console.error('Cache get error:', error);
      return null;
    }
  },

  async set(key: string, value: any, ttlSeconds?: number): Promise<boolean> {
    const client = getCacheClient();
    if (!client) return false;
    
    try {
      if (ttlSeconds) {
        await client.setex(key, ttlSeconds, JSON.stringify(value));
      } else {
        await client.set(key, JSON.stringify(value));
      }
      return true;
    } catch (error) {
      console.error('Cache set error:', error);
      return false;
    }
  },

  async del(key: string): Promise<boolean> {
    const client = getCacheClient();
    if (!client) return false;
    
    try {
      await client.del(key);
      return true;
    } catch (error) {
      console.error('Cache delete error:', error);
      return false;
    }
  },

  async exists(key: string): Promise<boolean> {
    const client = getCacheClient();
    if (!client) return false;
    
    try {
      const result = await client.exists(key);
      return result === 1;
    } catch (error) {
      console.error('Cache exists error:', error);
      return false;
    }
  },
};

// Rate limit check helper
export async function checkRateLimit(
  clientId: string,
  namespace: 'fortune' | 'api' | 'auth' = 'api',
  isPremium = false,
  isGuest = false
) {
  const limiters = getRateLimiters();
  
  // Select appropriate rate limiter
  let limiter;
  if (isPremium && limiters.premium) {
    limiter = limiters.premium;
  } else if (isGuest && limiters.guest) {
    limiter = limiters.guest;
  } else {
    limiter = limiters.standard;
  }
  
  if (!limiter) {
    // Redis not available, return allowed
    return {
      allowed: true,
      limit: isPremium ? 100 : isGuest ? 5 : 10,
      remaining: -1,
      retryAfter: 0,
      resetAt: Date.now() + 60000,
    };
  }
  
  const identifier = `${namespace}:${clientId}`;
  const result = await limiter.limit(identifier);
  
  return {
    allowed: result.success,
    limit: result.limit,
    remaining: result.remaining,
    retryAfter: result.success ? 0 : Math.ceil((result.reset - Date.now()) / 1000),
    resetAt: result.reset,
  };
}