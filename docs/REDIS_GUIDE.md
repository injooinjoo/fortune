# 🚀 Redis 통합 가이드 (Upstash Redis)

## 📋 개요
Fortune 앱은 고성능 캐싱과 분산 Rate Limiting을 위해 Upstash Redis를 사용합니다.

## 🔧 초기 설정

### 1. Upstash 계정 및 데이터베이스 생성
1. [Upstash Console](https://console.upstash.com) 접속
2. GitHub 또는 Google 계정으로 가입
3. "Create Database" 클릭하여 데이터베이스 생성:
   - **Name**: `fortune-production`
   - **Region**: `ap-northeast-1` (Seoul/Tokyo) 또는 가장 가까운 지역
   - **Type**: Regional (낮은 지연시간)
   - **Eviction**: Enable eviction 체크 (캐시용)
   - **TLS/SSL**: Enabled (기본값)

### 2. 환경 변수 설정
Upstash Console > Database Details에서 자격 증명 복사:
```env
# .env.local
UPSTASH_REDIS_REST_URL=https://xxxxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=AX9sASQgN2E3YjQ5ZDkt...

# Redis 기능 활성화 (선택사항)
ENABLE_REDIS_CACHE=true
ENABLE_REDIS_RATE_LIMIT=true
```

## 📊 Redis 사용 패턴

### 1. 캐싱 레이어 (L1 Cache)
**TTL 설정:**
- 일일 운세: 24시간
- 사주/평생 운세: 30일
- 실시간 운세: 1시간
- 사용자 프로필: 30분
- API 응답: 5분

**키 패턴:** `fortune:{userId}:{fortuneType}:{date}`

### 2. 분산 Rate Limiting
**요청 한도:**
- Guest: 5 요청/분
- Standard: 10 요청/분
- Premium: 100 요청/분

**키 패턴:** `ratelimit:{userId}` 또는 `ratelimit:ip:{ipAddress}`

### 3. 세션 관리
- **TTL**: 7일
- **키 패턴**: `session:{sessionId}`

## 💻 구현 코드

### Redis 클라이언트 설정
```typescript
// src/lib/redis.ts
export const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!,
  retry: {
    retries: 3,
    backoff: {
      min: 1000,
      max: 5000,
    },
  },
});
```

### 캐시 전략 구현
```typescript
// 캐시 우선순위
// L1: Redis (~1ms)
// L2: Supabase (~50ms)
// L3: AI Generation (~2-5s)

const getCachedFortune = async (key: string) => {
  // L1: Redis 체크
  const cached = await redis.get(key);
  if (cached) return cached;
  
  // L2: Database 체크
  const dbCached = await checkDatabase(key);
  if (dbCached) {
    await redis.setex(key, 3600, dbCached);
    return dbCached;
  }
  
  // L3: 새로 생성
  return generateNewFortune(key);
};
```

### 캐시 무효화
```typescript
const clearUserCache = async (userId: string) => {
  const keys = await redis.keys(`fortune:${userId}:*`);
  if (keys.length > 0) {
    await redis.del(...keys);
  }
};
```

## 🔍 모니터링 및 관리

### 1. Upstash Console 모니터링
- **Metrics**: 요청 수, 대역폭, 명령어 통계
- **Slow Log**: 느린 쿼리 추적
- **Data Browser**: 키-값 직접 조회/수정
- **Hit/Miss 비율**: 캐시 효율성 확인

### 2. 알림 설정
Console → Settings → Alerts에서 활성화:
- 일일 요청 한도 80% 도달
- 메모리 사용량 80% 초과
- 오류율 5% 초과
- 평균 지연시간 100ms 초과

### 3. 앱 내 모니터링
```bash
# Redis 연결 테스트
node scripts/test-redis.js

# Redis 상태 확인
npm run redis:check

# 관리자 대시보드
/admin/redis-monitor
```

## 💰 비용 관리

### Free Tier
- 일일 10,000 요청
- 256MB 메모리
- 개발/테스트에 충분

### 확장 계획
- **10만 요청/일**: 무료 플랜
- **100만 요청/일**: Pay-as-you-go ($0.2/100K)
- **1000만 요청/일**: Pro 플랜

### 비용 최적화
1. 모든 키에 적절한 TTL 설정
2. 짧고 효율적인 키 네이밍
3. 큰 JSON 데이터는 압축하여 저장
4. 사용량 정기 모니터링

## 🛡️ 보안 고려사항

1. **토큰 보안**: Redis 토큰은 서버 사이드에서만 사용
2. **네트워크**: TLS/SSL 항상 활성화
3. **ACL**: 필요한 명령어만 허용
4. **키 네임스페이스**: 사용자별 격리 보장

## 🚨 프로덕션 체크리스트

### 배포 전 필수 확인
- [ ] Redis URL과 Token 설정 확인
- [ ] `npm run redis:check` 테스트 통과
- [ ] Rate limiting 작동 확인
- [ ] 캐싱 정상 작동 확인
- [ ] 에러 핸들링 구현 확인
- [ ] Connection pooling 활성화
- [ ] 적절한 TTL 설정

## 📝 트러블슈팅

### 연결 실패
1. 환경 변수 확인
2. Upstash 대시보드에서 데이터베이스 상태 확인
3. 네트워크 연결 확인

### Rate Limit 이슈
1. 로그에서 `Rate limit exceeded` 확인
2. Redis Monitor에서 키 패턴 분석
3. `src/lib/redis.ts`에서 한도 조정

### 성능 저하
1. 캐시 히트율 확인 (80% 이상 유지)
2. Slow commands 모니터링
3. 키 개수 및 메모리 사용량 확인

## 🔄 유지보수 일정

### 일일
- Redis 연결 상태 확인
- 오류 로그 검토
- 성능 지표 확인

### 주간
- 메모리 사용 패턴 분석
- Slow query 분석
- 캐시 효율성 검토

### 월간
- 불필요한 키 정리
- TTL 정책 검토
- 비용 최적화 검토

## 🎯 개발 환경 참고사항

### 로컬 개발
Redis가 없어도 개발 가능하도록 폴백 메커니즘 구현:
- Redis 미설정 시 → In-memory 캐시 사용
- Rate limiting → In-memory 카운터 사용

### 테스트 환경
```env
# .env.test
UPSTASH_REDIS_REST_URL=https://test-redis.upstash.io
UPSTASH_REDIS_REST_TOKEN=test-token
```

---

*최종 업데이트: 2025년 7월 11일*