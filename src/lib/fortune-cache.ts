/**
 * 운세 캐싱 시스템
 * Redis 기반 분산 캐싱 + 로컬 메모리 캐시 폴백
 */

import { getCacheClient, cache } from './redis';
import { createDeterministicRandom, getTodayDateString } from './deterministic-random';

// 캐시 키 생성 유틸리티
export function generateCacheKey(params: {
  userId: string;
  fortuneType: string;
  date?: string;
  extra?: Record<string, any>;
}): string {
  const { userId, fortuneType, date = getTodayDateString(), extra = {} } = params;
  
  // 기본 키 구성
  const baseKey = `fortune:${userId}:${fortuneType}:${date}`;
  
  // 추가 파라미터가 있는 경우 해시 추가
  if (Object.keys(extra).length > 0) {
    const extraHash = Object.entries(extra)
      .sort(([a], [b]) => a.localeCompare(b))
      .map(([k, v]) => `${k}:${v}`)
      .join(':');
    return `${baseKey}:${extraHash}`;
  }
  
  return baseKey;
}

// 캐시 TTL 설정 (초 단위)
export const CACHE_TTL = {
  daily: 24 * 60 * 60,        // 24시간
  hourly: 60 * 60,            // 1시간
  weekly: 7 * 24 * 60 * 60,   // 7일
  monthly: 30 * 24 * 60 * 60, // 30일
  yearly: 365 * 24 * 60 * 60, // 365일
  saju: 90 * 24 * 60 * 60,    // 90일 (사주는 변하지 않음)
  personality: 30 * 24 * 60 * 60, // 30일
  realtime: 5 * 60,           // 5분 (실시간 운세)
  default: 60 * 60,           // 기본 1시간
};

// 메모리 캐시 (Redis 사용 불가 시 폴백)
class MemoryCache {
  private cache = new Map<string, { data: any; expiry: number }>();
  private maxSize = 1000; // 최대 1000개 항목

  set(key: string, value: any, ttlSeconds: number): void {
    // 캐시 크기 제한
    if (this.cache.size >= this.maxSize) {
      // LRU 방식으로 가장 오래된 항목 제거
      const firstKey = this.cache.keys().next().value;
      if (firstKey) this.cache.delete(firstKey);
    }

    const expiry = Date.now() + ttlSeconds * 1000;
    this.cache.set(key, { data: value, expiry });
  }

  get(key: string): any | null {
    const item = this.cache.get(key);
    if (!item) return null;

    if (Date.now() > item.expiry) {
      this.cache.delete(key);
      return null;
    }

    return item.data;
  }

  has(key: string): boolean {
    return this.get(key) !== null;
  }

  delete(key: string): void {
    this.cache.delete(key);
  }

  clear(): void {
    this.cache.clear();
  }

  // 만료된 항목 정리
  cleanup(): void {
    const now = Date.now();
    for (const [key, item] of this.cache.entries()) {
      if (now > item.expiry) {
        this.cache.delete(key);
      }
    }
  }
}

// 메모리 캐시 인스턴스
const memoryCache = new MemoryCache();

// 정기적으로 만료된 캐시 정리 (5분마다)
if (typeof setInterval !== 'undefined') {
  setInterval(() => memoryCache.cleanup(), 5 * 60 * 1000);
}

// 운세 캐시 인터페이스
export interface FortuneCache {
  get<T>(key: string): Promise<T | null>;
  set(key: string, value: any, ttl?: number): Promise<boolean>;
  delete(key: string): Promise<boolean>;
  exists(key: string): Promise<boolean>;
  clear(pattern: string): Promise<number>;
}

// 하이브리드 캐시 구현 (Redis + Memory)
export const fortuneCache: FortuneCache = {
  async get<T>(key: string): Promise<T | null> {
    try {
      // 1. Redis에서 먼저 확인
      const redisValue = await cache.get<T>(key);
      if (redisValue !== null) {
        // Redis 히트 시 메모리 캐시에도 저장 (읽기 최적화)
        const ttl = CACHE_TTL.default;
        memoryCache.set(key, redisValue, ttl);
        return redisValue;
      }

      // 2. Redis 미스 시 메모리 캐시 확인
      const memoryValue = memoryCache.get(key);
      if (memoryValue !== null) {
        // 메모리 캐시 히트
        return memoryValue as T;
      }

      return null;
    } catch (error) {
      console.error('Cache get error:', error);
      // Redis 오류 시 메모리 캐시만 확인
      return memoryCache.get(key) as T | null;
    }
  },

  async set(key: string, value: any, ttl?: number): Promise<boolean> {
    const ttlSeconds = ttl || CACHE_TTL.default;

    try {
      // 1. Redis에 저장
      const redisResult = await cache.set(key, value, ttlSeconds);
      
      // 2. 메모리 캐시에도 저장
      memoryCache.set(key, value, ttlSeconds);
      
      return redisResult;
    } catch (error) {
      console.error('Cache set error:', error);
      // Redis 오류 시 메모리 캐시에만 저장
      memoryCache.set(key, value, ttlSeconds);
      return true;
    }
  },

  async delete(key: string): Promise<boolean> {
    try {
      // Redis와 메모리 캐시 모두에서 삭제
      const redisResult = await cache.del(key);
      memoryCache.delete(key);
      return redisResult;
    } catch (error) {
      console.error('Cache delete error:', error);
      memoryCache.delete(key);
      return true;
    }
  },

  async exists(key: string): Promise<boolean> {
    try {
      // Redis 확인
      const redisExists = await cache.exists(key);
      if (redisExists) return true;
      
      // 메모리 캐시 확인
      return memoryCache.has(key);
    } catch (error) {
      console.error('Cache exists error:', error);
      return memoryCache.has(key);
    }
  },

  async clear(pattern: string): Promise<number> {
    // 패턴 매칭 캐시 삭제 (Redis에서만 지원)
    try {
      const client = getCacheClient();
      if (!client) return 0;

      // Redis SCAN으로 패턴 매칭 키 찾기
      let cursor = 0;
      let deletedCount = 0;
      
      do {
        const result = await client.scan(cursor, { match: pattern, count: 100 });
        cursor = result[0];
        const keys = result[1];
        
        if (keys.length > 0) {
          await client.del(...keys);
          deletedCount += keys.length;
        }
      } while (cursor !== 0);

      // 메모리 캐시는 전체 클리어
      memoryCache.clear();
      
      return deletedCount;
    } catch (error) {
      console.error('Cache clear error:', error);
      memoryCache.clear();
      return 0;
    }
  }
};

// 캐시 워밍 (사전 로드)
export async function warmCache(userId: string, fortuneTypes: string[]) {
  const today = getTodayDateString();
  const promises = fortuneTypes.map(async (type) => {
    const key = generateCacheKey({ userId, fortuneType: type, date: today });
    const exists = await fortuneCache.exists(key);
    
    if (!exists) {
      // 캐시가 없으면 생성 요청 (실제 생성은 서비스 레이어에서)
      return { type, needsGeneration: true };
    }
    
    return { type, needsGeneration: false };
  });

  const results = await Promise.all(promises);
  return results.filter(r => r.needsGeneration).map(r => r.type);
}

// 캐시 통계
export interface CacheStats {
  hits: number;
  misses: number;
  errors: number;
  hitRate: number;
}

class CacheStatsCollector {
  private stats = {
    hits: 0,
    misses: 0,
    errors: 0,
  };

  recordHit() {
    this.stats.hits++;
  }

  recordMiss() {
    this.stats.misses++;
  }

  recordError() {
    this.stats.errors++;
  }

  getStats(): CacheStats {
    const total = this.stats.hits + this.stats.misses;
    const hitRate = total > 0 ? (this.stats.hits / total) * 100 : 0;

    return {
      ...this.stats,
      hitRate: Math.round(hitRate * 10) / 10,
    };
  }

  reset() {
    this.stats = { hits: 0, misses: 0, errors: 0 };
  }
}

export const cacheStats = new CacheStatsCollector();

// 캐시 래퍼 함수
export async function withCache<T>(
  key: string,
  factory: () => Promise<T>,
  options?: {
    ttl?: number;
    force?: boolean;
  }
): Promise<T> {
  const { ttl, force = false } = options || {};

  // 강제 갱신이 아니면 캐시 확인
  if (!force) {
    try {
      const cached = await fortuneCache.get<T>(key);
      if (cached !== null) {
        cacheStats.recordHit();
        return cached;
      }
    } catch (error) {
      cacheStats.recordError();
      console.error('Cache read error:', error);
    }
  }

  // 캐시 미스 - 새로 생성
  cacheStats.recordMiss();
  
  try {
    const result = await factory();
    
    // 결과를 캐시에 저장
    await fortuneCache.set(key, result, ttl);
    
    return result;
  } catch (error) {
    cacheStats.recordError();
    throw error;
  }
}