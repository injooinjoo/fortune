# 🚀 Redis 설정 가이드 (Upstash Redis)

## Overview
Fortune 앱은 고성능 캐싱과 분산 Rate Limiting을 위해 Upstash Redis를 사용합니다.

## 1. Upstash 계정 생성

### 1.1 회원가입
1. [Upstash Console](https://console.upstash.com) 접속
2. GitHub 또는 Google 계정으로 가입
3. 이메일 인증 완료

### 1.2 Redis Database 생성
1. Console 대시보드에서 "Create Database" 클릭
2. Database 설정:
   - **Name**: `fortune-app-redis`
   - **Region**: `ap-northeast-1` (도쿄) 또는 가장 가까운 지역
   - **Type**: Regional (단일 지역)
   - **Eviction**: Enable eviction 체크
   - **TLS/SSL**: Enabled (기본값)

## 2. 환경 변수 설정

### 2.1 Redis 자격 증명 확인
1. 생성된 데이터베이스 클릭
2. "Details" 탭에서 다음 정보 확인:
   - `UPSTASH_REDIS_REST_URL`
   - `UPSTASH_REDIS_REST_TOKEN`

### 2.2 .env.local 업데이트
```env
# Redis Configuration (Upstash)
UPSTASH_REDIS_REST_URL=https://xxxxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=AX9sASQgN2E3YjQ5ZDkt...

# Redis 기능 활성화 (선택사항)
ENABLE_REDIS_CACHE=true
ENABLE_REDIS_RATE_LIMIT=true
```

## 3. Redis 기능 및 사용처

### 3.1 캐싱 레이어 (L1 Cache)
- **용도**: 자주 요청되는 운세 데이터의 초고속 캐싱
- **TTL**: 
  - 일일 운세: 24시간
  - 사주/평생 운세: 30일
  - 실시간 운세: 1시간
- **키 패턴**: `fortune:{userId}:{fortuneType}:{date}`

### 3.2 분산 Rate Limiting
- **표준 사용자**: 분당 10회 요청
- **프리미엄 사용자**: 분당 100회 요청
- **게스트 사용자**: 분당 5회 요청
- **키 패턴**: `ratelimit:{userId}` 또는 `ratelimit:ip:{ipAddress}`

### 3.3 세션 관리
- **용도**: 사용자 세션 상태 저장
- **TTL**: 7일
- **키 패턴**: `session:{sessionId}`

## 4. 성능 최적화 설정

### 4.1 Connection Pooling
```typescript
// src/lib/redis.ts
export const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!,
  // 자동 재시도 설정
  retry: {
    retries: 3,
    backoff: {
      min: 1000,
      max: 5000,
    },
  },
});
```

### 4.2 캐시 전략
```typescript
// 캐시 우선순위
// 1. Redis (L1) - ~1ms
// 2. Supabase (L2) - ~50ms
// 3. AI Generation (L3) - ~2-5s

const getCachedFortune = async (key: string) => {
  // L1: Redis 체크
  const cached = await redis.get(key);
  if (cached) return cached;
  
  // L2: Database 체크
  const dbCached = await checkDatabase(key);
  if (dbCached) {
    // Redis에 백필
    await redis.setex(key, 3600, dbCached);
    return dbCached;
  }
  
  // L3: 새로 생성
  return generateNewFortune(key);
};
```

## 5. 모니터링 및 관리

### 5.1 Upstash Console 모니터링
- **Metrics**: 요청 수, 대역폭, 명령어 통계
- **Slow Log**: 느린 쿼리 추적
- **Data Browser**: 키-값 직접 조회/수정

### 5.2 알림 설정
1. Console → Settings → Alerts
2. 다음 알림 활성화:
   - 일일 요청 한도 80% 도달
   - 메모리 사용량 80% 초과
   - 연결 오류 발생

## 6. 비용 관리

### 6.1 Free Tier
- 일일 10,000 요청
- 256MB 메모리
- 대부분의 개발/테스트에 충분

### 6.2 비용 최적화 팁
1. **TTL 설정**: 모든 키에 적절한 만료 시간 설정
2. **키 네이밍**: 짧고 효율적인 키 사용
3. **압축**: 큰 JSON 데이터는 압축하여 저장
4. **모니터링**: 사용량 정기적으로 확인

## 7. 문제 해결

### 7.1 연결 실패
```bash
# Redis 연결 테스트
node scripts/test-redis.js
```

### 7.2 Rate Limit 이슈
- 로그에서 `Rate limit exceeded` 확인
- Redis Monitor에서 키 패턴 분석
- 필요시 한도 조정

### 7.3 캐시 무효화
```typescript
// 특정 사용자의 모든 캐시 삭제
const clearUserCache = async (userId: string) => {
  const keys = await redis.keys(`fortune:${userId}:*`);
  if (keys.length > 0) {
    await redis.del(...keys);
  }
};
```

## 8. 개발 환경 설정

### 8.1 로컬 개발 (선택사항)
Redis가 없어도 개발 가능하도록 폴백 메커니즘이 구현되어 있습니다:
- Redis 미설정 시 → In-memory 캐시 사용
- Rate limiting → In-memory 카운터 사용

### 8.2 테스트 환경
```env
# .env.test
UPSTASH_REDIS_REST_URL=https://test-redis.upstash.io
UPSTASH_REDIS_REST_TOKEN=test-token
```

## 9. 보안 고려사항

1. **토큰 보안**: Redis 토큰은 절대 클라이언트에 노출하지 않음
2. **네트워크**: TLS/SSL 항상 활성화
3. **ACL**: 필요한 명령어만 허용하도록 설정
4. **키 네임스페이스**: 사용자별 격리 보장

## 10. 다음 단계

1. ✅ Upstash 계정 생성 및 Redis 인스턴스 설정
2. ✅ 환경 변수 설정
3. ⏳ Redis 연결 테스트 실행
4. ⏳ 캐싱 전략 구현
5. ⏳ 모니터링 대시보드 설정