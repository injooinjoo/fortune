import { Redis } from 'ioredis';
import logger from '../utils/logger';

let redisClient: Redis | null = null;

// Redis 연결 초기화
export function initializeRedis(): Redis {
  if (redisClient) {
    return redisClient;
  }

  const redisUrl = process.env.REDIS_URL || process.env.UPSTASH_REDIS_REST_URL;
  
  if (!redisUrl) {
    logger.warn('Redis URL not provided. Redis features will be disabled.');
    // Redis가 없어도 서버가 동작하도록 null 반환
    return null as any;
  }

  try {
    redisClient = new Redis(redisUrl, {
      maxRetriesPerRequest: 3,
      retryStrategy(times) {
        const delay = Math.min(times * 50, 2000);
        return delay;
      },
      reconnectOnError(err) {
        const targetError = 'READONLY';
        if (err.message.includes(targetError)) {
          // Only reconnect when the error contains "READONLY"
          return true;
        }
        return false;
      },
    });

    redisClient.on('connect', () => {
      logger.info('Redis client connected successfully');
    });

    redisClient.on('error', (error) => {
      logger.error('Redis client error:', error);
    });

    redisClient.on('close', () => {
      logger.warn('Redis client connection closed');
    });

    return redisClient;
  } catch (error) {
    logger.error('Failed to initialize Redis client:', error);
    return null as any;
  }
}

// Redis 클라이언트 가져오기
export function getRedisClient(): Redis | null {
  if (!redisClient) {
    return initializeRedis();
  }
  return redisClient;
}

// Redis 연결 종료
export async function closeRedis(): Promise<void> {
  if (redisClient) {
    await redisClient.quit();
    redisClient = null;
    logger.info('Redis client connection closed');
  }
}

// 캐시 헬퍼 함수들
export const cache = {
  // 캐시 설정
  async set(key: string, value: any, ttlSeconds?: number): Promise<boolean> {
    const client = getRedisClient();
    if (!client) return false;

    try {
      const serialized = JSON.stringify(value);
      if (ttlSeconds) {
        await client.setex(key, ttlSeconds, serialized);
      } else {
        await client.set(key, serialized);
      }
      return true;
    } catch (error) {
      logger.error('Cache set error:', error);
      return false;
    }
  },

  // 캐시 가져오기
  async get<T>(key: string): Promise<T | null> {
    const client = getRedisClient();
    if (!client) return null;

    try {
      const value = await client.get(key);
      if (!value) return null;
      return JSON.parse(value) as T;
    } catch (error) {
      logger.error('Cache get error:', error);
      return null;
    }
  },

  // 캐시 삭제
  async del(key: string): Promise<boolean> {
    const client = getRedisClient();
    if (!client) return false;

    try {
      await client.del(key);
      return true;
    } catch (error) {
      logger.error('Cache delete error:', error);
      return false;
    }
  },

  // 패턴으로 캐시 삭제
  async delByPattern(pattern: string): Promise<boolean> {
    const client = getRedisClient();
    if (!client) return false;

    try {
      const keys = await client.keys(pattern);
      if (keys.length > 0) {
        await client.del(...keys);
      }
      return true;
    } catch (error) {
      logger.error('Cache delete by pattern error:', error);
      return false;
    }
  },

  // TTL 확인
  async ttl(key: string): Promise<number> {
    const client = getRedisClient();
    if (!client) return -1;

    try {
      return await client.ttl(key);
    } catch (error) {
      logger.error('Cache TTL error:', error);
      return -1;
    }
  },
};

// Rate limiting 헬퍼
export const rateLimiter = {
  // Rate limit 체크 및 증가
  async checkAndIncrement(key: string, limit: number, windowSeconds: number): Promise<{ allowed: boolean; remaining: number }> {
    const client = getRedisClient();
    if (!client) {
      // Redis가 없으면 rate limiting 비활성화
      return { allowed: true, remaining: limit };
    }

    try {
      const current = await client.incr(key);
      
      if (current === 1) {
        await client.expire(key, windowSeconds);
      }

      const allowed = current <= limit;
      const remaining = Math.max(0, limit - current);

      return { allowed, remaining };
    } catch (error) {
      logger.error('Rate limiter error:', error);
      // 에러 시 요청 허용
      return { allowed: true, remaining: limit };
    }
  },

  // 현재 카운트 가져오기
  async getCount(key: string): Promise<number> {
    const client = getRedisClient();
    if (!client) return 0;

    try {
      const count = await client.get(key);
      return count ? parseInt(count, 10) : 0;
    } catch (error) {
      logger.error('Rate limiter get count error:', error);
      return 0;
    }
  },

  // 리셋
  async reset(key: string): Promise<boolean> {
    const client = getRedisClient();
    if (!client) return false;

    try {
      await client.del(key);
      return true;
    } catch (error) {
      logger.error('Rate limiter reset error:', error);
      return false;
    }
  },
};