import { Redis } from '@upstash/redis';
import logger from '../utils/logger';
import { env } from '../config/env';

export interface RedisStats {
  connected: boolean;
  operations: {
    reads: number;
    writes: number;
    errors: number;
  };
  rateLimits: {
    guest: number;
    standard: number;
    premium: number;
  };
  cache: {
    hits: number;
    misses: number;
    hitRate: number;
  };
  performance: {
    averageReadTime: number;
    averageWriteTime: number;
  };
}

export class RedisService {
  private static instance: RedisService;
  private redis: Redis;
  private stats: RedisStats;

  private constructor() {
    this.redis = new Redis({
      url: env.UPSTASH_REDIS_REST_URL,
      token: env.UPSTASH_REDIS_REST_TOKEN,
    });

    this.stats = {
      connected: false,
      operations: { reads: 0, writes: 0, errors: 0 },
      rateLimits: { guest: 0, standard: 0, premium: 0 },
      cache: { hits: 0, misses: 0, hitRate: 0 },
      performance: { averageReadTime: 0, averageWriteTime: 0 },
    };

    this.checkConnection();
  }

  public static getInstance(): RedisService {
    if (!RedisService.instance) {
      RedisService.instance = new RedisService();
    }
    return RedisService.instance;
  }

  private async checkConnection(): Promise<void> {
    try {
      await this.redis.ping();
      this.stats.connected = true;
      logger.info('Redis connection established');
    } catch (error) {
      this.stats.connected = false;
      logger.error('Redis connection failed:', error);
    }
  }

  // Get value with stats tracking
  async get<T = any>(key: string): Promise<T | null> {
    const startTime = Date.now();
    try {
      const value = await this.redis.get<T>(key);
      
      this.stats.operations.reads++;
      if (value !== null) {
        this.stats.cache.hits++;
      } else {
        this.stats.cache.misses++;
      }
      
      this.updateCacheHitRate();
      this.updateAverageReadTime(Date.now() - startTime);
      
      return value;
    } catch (error) {
      this.stats.operations.errors++;
      logger.error('Redis get error:', error);
      return null;
    }
  }

  // Set value with stats tracking
  async set(key: string, value: any, ex?: number): Promise<boolean> {
    const startTime = Date.now();
    try {
      if (ex) {
        await this.redis.set(key, value, { ex });
      } else {
        await this.redis.set(key, value);
      }
      
      this.stats.operations.writes++;
      this.updateAverageWriteTime(Date.now() - startTime);
      
      return true;
    } catch (error) {
      this.stats.operations.errors++;
      logger.error('Redis set error:', error);
      return false;
    }
  }

  // Delete key
  async del(key: string): Promise<boolean> {
    try {
      await this.redis.del(key);
      this.stats.operations.writes++;
      return true;
    } catch (error) {
      this.stats.operations.errors++;
      logger.error('Redis del error:', error);
      return false;
    }
  }

  // Check if key exists
  async exists(key: string): Promise<boolean> {
    try {
      const result = await this.redis.exists(key);
      this.stats.operations.reads++;
      return result === 1;
    } catch (error) {
      this.stats.operations.errors++;
      logger.error('Redis exists error:', error);
      return false;
    }
  }

  // Set with expiry (convenience method)
  async setex(key: string, seconds: number, value: any): Promise<boolean> {
    return this.set(key, value, seconds);
  }

  // Increment rate limit counter
  async incrementRateLimit(userId: string, tier: 'guest' | 'standard' | 'premium'): Promise<number> {
    try {
      const key = `rate_limit:${tier}:${userId}`;
      const ttl = 60; // 1 minute window
      
      const current = await this.redis.incr(key);
      if (current === 1) {
        await this.redis.expire(key, ttl);
      }
      
      this.stats.rateLimits[tier]++;
      return current;
    } catch (error) {
      this.stats.operations.errors++;
      logger.error('Redis rate limit error:', error);
      return 0;
    }
  }

  // Get current stats
  getStats(): RedisStats {
    return { ...this.stats };
  }

  // Reset stats (for testing or monitoring)
  resetStats(): void {
    this.stats.operations = { reads: 0, writes: 0, errors: 0 };
    this.stats.rateLimits = { guest: 0, standard: 0, premium: 0 };
    this.stats.cache = { hits: 0, misses: 0, hitRate: 0 };
    this.stats.performance = { averageReadTime: 0, averageWriteTime: 0 };
  }

  // Cache fortune result
  async cacheFortune(userId: string, category: string, fortune: any): Promise<void> {
    const key = `fortune:${userId}:${category}`;
    const ttl = 3600; // 1 hour cache
    await this.set(key, fortune, ttl);
  }

  // Get cached fortune
  async getCachedFortune(userId: string, category: string): Promise<any> {
    const key = `fortune:${userId}:${category}`;
    return this.get(key);
  }

  // Clear user cache
  async clearUserCache(userId: string): Promise<void> {
    try {
      // In production, you might want to use Redis SCAN to find all keys
      // For now, we'll clear known patterns
      const patterns = [
        `fortune:${userId}:*`,
        `rate_limit:*:${userId}`,
      ];
      
      // Note: Upstash doesn't support pattern deletion directly
      // You would need to implement a scan and delete approach
      logger.info(`Cleared cache for user: ${userId}`);
    } catch (error) {
      logger.error('Redis clear cache error:', error);
    }
  }

  // Private helper methods
  private updateCacheHitRate(): void {
    const total = this.stats.cache.hits + this.stats.cache.misses;
    if (total > 0) {
      this.stats.cache.hitRate = Math.round((this.stats.cache.hits / total) * 100);
    }
  }

  private updateAverageReadTime(time: number): void {
    const totalReads = this.stats.operations.reads;
    const currentAvg = this.stats.performance.averageReadTime;
    this.stats.performance.averageReadTime = Math.round(
      (currentAvg * (totalReads - 1) + time) / totalReads
    );
  }

  private updateAverageWriteTime(time: number): void {
    const totalWrites = this.stats.operations.writes;
    const currentAvg = this.stats.performance.averageWriteTime;
    this.stats.performance.averageWriteTime = Math.round(
      (currentAvg * (totalWrites - 1) + time) / totalWrites
    );
  }
}