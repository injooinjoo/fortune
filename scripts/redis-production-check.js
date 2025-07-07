#!/usr/bin/env node

/**
 * Redis 프로덕션 체크 스크립트
 * Redis 연결, 성능, 그리고 설정을 검증합니다.
 */

const { Redis } = require('@upstash/redis');
const { Ratelimit } = require('@upstash/ratelimit');
require('dotenv').config({ path: '.env.local' });

// 색상 코드
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

async function checkRedisProduction() {
  console.log(`\n${colors.cyan}🚀 Redis 프로덕션 체크 시작${colors.reset}\n`);

  const results = {
    connection: false,
    basicOperations: false,
    caching: false,
    rateLimiting: false,
    performance: {},
    warnings: [],
    errors: []
  };

  // 1. 환경 변수 체크
  console.log(`${colors.blue}1️⃣ 환경 변수 검증${colors.reset}`);
  const hasUrl = !!process.env.UPSTASH_REDIS_REST_URL;
  const hasToken = !!process.env.UPSTASH_REDIS_REST_TOKEN;

  if (!hasUrl || !hasToken) {
    results.errors.push('Redis 환경 변수가 설정되지 않았습니다');
    console.log(`${colors.red}❌ Redis 환경 변수 누락${colors.reset}`);
    return results;
  }

  console.log(`${colors.green}✅ Redis 환경 변수 확인됨${colors.reset}`);

  let redis;
  try {
    redis = new Redis({
      url: process.env.UPSTASH_REDIS_REST_URL,
      token: process.env.UPSTASH_REDIS_REST_TOKEN,
    });
    results.connection = true;
    console.log(`${colors.green}✅ Redis 클라이언트 초기화 성공${colors.reset}`);
  } catch (error) {
    results.errors.push(`Redis 초기화 실패: ${error.message}`);
    console.log(`${colors.red}❌ Redis 초기화 실패: ${error.message}${colors.reset}`);
    return results;
  }

  // 2. 기본 작업 테스트
  console.log(`\n${colors.blue}2️⃣ 기본 작업 테스트${colors.reset}`);
  try {
    // SET/GET 테스트
    const testKey = 'prod-test-key';
    const testValue = { test: true, timestamp: Date.now() };
    
    await redis.set(testKey, JSON.stringify(testValue));
    const retrieved = await redis.get(testKey);
    
    if (JSON.stringify(testValue) === retrieved) {
      results.basicOperations = true;
      console.log(`${colors.green}✅ SET/GET 작업 성공${colors.reset}`);
    } else {
      results.errors.push('SET/GET 값 불일치');
      console.log(`${colors.red}❌ SET/GET 값 불일치${colors.reset}`);
    }

    // 정리
    await redis.del(testKey);

    // EXISTS 테스트
    const exists = await redis.exists(testKey);
    if (exists === 0) {
      console.log(`${colors.green}✅ EXISTS/DEL 작업 성공${colors.reset}`);
    }

  } catch (error) {
    results.errors.push(`기본 작업 실패: ${error.message}`);
    console.log(`${colors.red}❌ 기본 작업 실패: ${error.message}${colors.reset}`);
  }

  // 3. 캐싱 기능 테스트
  console.log(`\n${colors.blue}3️⃣ 캐싱 기능 테스트${colors.reset}`);
  try {
    // TTL 테스트
    const cacheKey = 'cache-test';
    const cacheValue = { data: 'cached', time: Date.now() };
    
    await redis.setex(cacheKey, 5, JSON.stringify(cacheValue)); // 5초 TTL
    const ttl = await redis.ttl(cacheKey);
    
    if (ttl > 0 && ttl <= 5) {
      results.caching = true;
      console.log(`${colors.green}✅ TTL 캐싱 작동 중 (TTL: ${ttl}초)${colors.reset}`);
    } else {
      results.warnings.push('TTL 값이 예상과 다름');
      console.log(`${colors.yellow}⚠️  TTL 값 이상: ${ttl}${colors.reset}`);
    }

    await redis.del(cacheKey);

  } catch (error) {
    results.errors.push(`캐싱 테스트 실패: ${error.message}`);
    console.log(`${colors.red}❌ 캐싱 테스트 실패: ${error.message}${colors.reset}`);
  }

  // 4. Rate Limiting 테스트
  console.log(`\n${colors.blue}4️⃣ Rate Limiting 테스트${colors.reset}`);
  try {
    // 각 타입별 rate limiter 테스트
    const limiters = {
      guest: new Ratelimit({
        redis,
        limiter: Ratelimit.slidingWindow(5, '1 m'),
        prefix: '@upstash/ratelimit:guest',
      }),
      standard: new Ratelimit({
        redis,
        limiter: Ratelimit.slidingWindow(10, '1 m'),
        prefix: '@upstash/ratelimit:standard',
      }),
      premium: new Ratelimit({
        redis,
        limiter: Ratelimit.slidingWindow(100, '1 m'),
        prefix: '@upstash/ratelimit:premium',
      }),
    };

    let allPassed = true;
    for (const [type, limiter] of Object.entries(limiters)) {
      const testId = `test-${type}-user`;
      const limit = type === 'guest' ? 5 : type === 'standard' ? 10 : 100;
      
      // 첫 요청은 허용되어야 함
      const result = await limiter.limit(testId);
      if (result.success && result.remaining === limit - 1) {
        console.log(`${colors.green}✅ ${type} rate limiter 작동 중 (한도: ${limit}/분)${colors.reset}`);
      } else {
        allPassed = false;
        results.warnings.push(`${type} rate limiter 이상 동작`);
        console.log(`${colors.yellow}⚠️  ${type} rate limiter 이상${colors.reset}`);
      }

      // 정리
      await redis.del(`@upstash/ratelimit:${type}:${testId}`);
    }

    results.rateLimiting = allPassed;

  } catch (error) {
    results.errors.push(`Rate limiting 테스트 실패: ${error.message}`);
    console.log(`${colors.red}❌ Rate limiting 테스트 실패: ${error.message}${colors.reset}`);
  }

  // 5. 성능 테스트
  console.log(`\n${colors.blue}5️⃣ 성능 테스트${colors.reset}`);
  try {
    // 읽기 성능
    const readStart = Date.now();
    const readPromises = [];
    for (let i = 0; i < 100; i++) {
      readPromises.push(redis.get(`perf-test-${i}`));
    }
    await Promise.all(readPromises);
    const readTime = Date.now() - readStart;
    results.performance.readTime = readTime;
    console.log(`${colors.green}✅ 100개 읽기 작업: ${readTime}ms${colors.reset}`);

    // 쓰기 성능
    const writeStart = Date.now();
    const writePromises = [];
    for (let i = 0; i < 100; i++) {
      writePromises.push(redis.set(`perf-test-${i}`, `value-${i}`));
    }
    await Promise.all(writePromises);
    const writeTime = Date.now() - writeStart;
    results.performance.writeTime = writeTime;
    console.log(`${colors.green}✅ 100개 쓰기 작업: ${writeTime}ms${colors.reset}`);

    // 정리
    const delPromises = [];
    for (let i = 0; i < 100; i++) {
      delPromises.push(redis.del(`perf-test-${i}`));
    }
    await Promise.all(delPromises);

    // 성능 경고
    if (readTime > 1000 || writeTime > 1000) {
      results.warnings.push('Redis 응답 시간이 1초를 초과합니다');
      console.log(`${colors.yellow}⚠️  성능 경고: 응답 시간이 느립니다${colors.reset}`);
    }

  } catch (error) {
    results.errors.push(`성능 테스트 실패: ${error.message}`);
    console.log(`${colors.red}❌ 성능 테스트 실패: ${error.message}${colors.reset}`);
  }

  // 6. 결과 요약
  console.log(`\n${colors.cyan}📊 테스트 결과 요약${colors.reset}`);
  console.log('─'.repeat(50));
  
  const checks = [
    { name: '연결', status: results.connection },
    { name: '기본 작업', status: results.basicOperations },
    { name: '캐싱', status: results.caching },
    { name: 'Rate Limiting', status: results.rateLimiting },
  ];

  checks.forEach(check => {
    const status = check.status ? `${colors.green}✅ 성공${colors.reset}` : `${colors.red}❌ 실패${colors.reset}`;
    console.log(`${check.name}: ${status}`);
  });

  if (results.performance.readTime && results.performance.writeTime) {
    console.log(`\n성능 지표:`);
    console.log(`  읽기: ${results.performance.readTime}ms (100개 작업)`);
    console.log(`  쓰기: ${results.performance.writeTime}ms (100개 작업)`);
  }

  if (results.warnings.length > 0) {
    console.log(`\n${colors.yellow}⚠️  경고사항:${colors.reset}`);
    results.warnings.forEach(warning => console.log(`  - ${warning}`));
  }

  if (results.errors.length > 0) {
    console.log(`\n${colors.red}❌ 오류:${colors.reset}`);
    results.errors.forEach(error => console.log(`  - ${error}`));
  }

  const allPassed = results.connection && results.basicOperations && 
                   results.caching && results.rateLimiting && 
                   results.errors.length === 0;

  if (allPassed) {
    console.log(`\n${colors.green}🎉 모든 테스트 통과! Redis가 프로덕션 준비 완료되었습니다.${colors.reset}`);
  } else {
    console.log(`\n${colors.red}❌ 일부 테스트 실패. 문제를 해결한 후 다시 실행하세요.${colors.reset}`);
  }

  return results;
}

// 메인 실행
if (require.main === module) {
  checkRedisProduction()
    .then(results => {
      const exitCode = results.errors.length === 0 ? 0 : 1;
      process.exit(exitCode);
    })
    .catch(error => {
      console.error(`${colors.red}예기치 않은 오류:${colors.reset}`, error);
      process.exit(1);
    });
}

module.exports = { checkRedisProduction };