import { NextRequest, NextResponse } from 'next/server';
import { getRedis, getCacheClient } from '@/lib/redis';
import { withAuth } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse } from '@/lib/api-response';

// Redis 통계를 메모리에 저장 (실제로는 Redis에서 가져와야 함)
let statsCache = {
  operations: { reads: 0, writes: 0, errors: 0 },
  cache: { hits: 0, misses: 0 },
  performance: { totalReadTime: 0, totalWriteTime: 0, readCount: 0, writeCount: 0 },
  lastReset: Date.now()
};

async function getRedisStats() {
  const redis = getRedis();
  const cacheClient = getCacheClient();
  
  if (!redis || !cacheClient) {
    throw new Error('Redis not connected');
  }

  // Redis 연결 테스트
  let connection = false;
  try {
    await redis.ping();
    connection = true;
  } catch (error) {
    connection = false;
  }

  // Rate limit 현황 조회 (예시)
  const rateLimitStats = {
    guest: { used: 0, limit: 5 },
    standard: { used: 0, limit: 10 },
    premium: { used: 0, limit: 100 }
  };

  // 실제로는 Redis에서 rate limit 정보를 가져와야 함
  // 여기서는 예시로 랜덤 값 생성
  if (connection) {
    rateLimitStats.guest.used = Math.floor(Math.random() * 5);
    rateLimitStats.standard.used = Math.floor(Math.random() * 10);
    rateLimitStats.premium.used = Math.floor(Math.random() * 100);
  }

  // 캐시 히트율 계산
  const totalCacheRequests = statsCache.cache.hits + statsCache.cache.misses;
  const hitRate = totalCacheRequests > 0 
    ? (statsCache.cache.hits / totalCacheRequests) * 100 
    : 0;

  // 평균 성능 계산
  const avgReadTime = statsCache.performance.readCount > 0
    ? Math.round(statsCache.performance.totalReadTime / statsCache.performance.readCount)
    : 0;
  
  const avgWriteTime = statsCache.performance.writeCount > 0
    ? Math.round(statsCache.performance.totalWriteTime / statsCache.performance.writeCount)
    : 0;

  return {
    connection,
    operations: statsCache.operations,
    rateLimit: rateLimitStats,
    cache: {
      hits: statsCache.cache.hits,
      misses: statsCache.cache.misses,
      hitRate
    },
    performance: {
      avgReadTime,
      avgWriteTime
    },
    lastUpdated: new Date().toISOString()
  };
}

export async function GET(request: NextRequest) {
  return withAuth(async (req: NextRequest, user?: any) => {
    try {
      // 관리자 권한 체크 (실제로는 user role 확인 필요)
      // if (!user || user.role !== 'admin') {
      //   return createErrorResponse('Unauthorized', 403);
      // }

      const stats = await getRedisStats();
      return createSuccessResponse(stats);
    } catch (error) {
      console.error('Redis stats error:', error);
      return createErrorResponse('Failed to fetch Redis stats', 500);
    }
  })(request);
}

// Redis 작업을 추적하는 헬퍼 함수들 (실제 구현시 redis.ts에서 호출)
export function trackRedisOperation(type: 'read' | 'write' | 'error', duration?: number) {
  if (type === 'read' && duration !== undefined) {
    statsCache.operations.reads++;
    statsCache.performance.totalReadTime += duration;
    statsCache.performance.readCount++;
  } else if (type === 'write' && duration !== undefined) {
    statsCache.operations.writes++;
    statsCache.performance.totalWriteTime += duration;
    statsCache.performance.writeCount++;
  } else if (type === 'error') {
    statsCache.operations.errors++;
  }
}

export function trackCacheHit(hit: boolean) {
  if (hit) {
    statsCache.cache.hits++;
  } else {
    statsCache.cache.misses++;
  }
}

// 통계 리셋 (일정 주기로 실행)
export function resetStats() {
  statsCache = {
    operations: { reads: 0, writes: 0, errors: 0 },
    cache: { hits: 0, misses: 0 },
    performance: { totalReadTime: 0, totalWriteTime: 0, readCount: 0, writeCount: 0 },
    lastReset: Date.now()
  };
}