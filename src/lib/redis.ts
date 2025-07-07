import { Redis } from '@upstash/redis';
import { Ratelimit } from '@upstash/ratelimit';

let redis: Redis | null = null;
let ratelimit: Ratelimit | null = null;
let premiumRatelimit: Ratelimit | null = null;

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
    return { standard: null, premium: null };
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

  return {
    standard: ratelimit,
    premium: premiumRatelimit,
  };
}

// Check if Redis is available
export function isRedisAvailable(): boolean {
  return !!(process.env.UPSTASH_REDIS_REST_URL && process.env.UPSTASH_REDIS_REST_TOKEN);
}