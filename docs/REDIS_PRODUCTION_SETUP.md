# 🚀 Redis 프로덕션 설정 가이드

## 📋 개요
Fortune 앱의 Redis를 프로덕션 환경에 최적화하기 위한 설정 가이드입니다.

## 🔧 Upstash Redis 설정

### 1. Upstash 계정 생성
1. [Upstash Console](https://console.upstash.com) 접속
2. GitHub/Google로 회원가입
3. 무료 플랜으로 시작 (일일 10,000 요청 무료)

### 2. Redis 데이터베이스 생성
```bash
# Upstash Console에서:
1. "Create Database" 클릭
2. 데이터베이스 이름: "fortune-production"
3. 지역 선택: "Seoul" (또는 가장 가까운 지역)
4. Type: "Regional" (낮은 지연시간)
5. Eviction 활성화 (캐시용)
```

### 3. 환경 변수 설정
```bash
# Upstash Console > Database Details에서 복사
UPSTASH_REDIS_REST_URL=https://your-instance.upstash.io
UPSTASH_REDIS_REST_TOKEN=your-token-here
```

## 📊 Redis 사용 패턴

### Rate Limiting 구성
```typescript
// 현재 설정:
- Guest: 5 요청/분
- Standard: 10 요청/분  
- Premium: 100 요청/분
```

### 캐싱 전략
```typescript
// 권장 TTL 설정:
- 일일 운세: 24시간
- 실시간 운세: 1시간
- 사용자 프로필: 30분
- API 응답: 5분
```

## 🔍 모니터링 설정

### 1. Upstash 대시보드 활용
- Commands/sec 모니터링
- Hit/Miss 비율 확인
- 메모리 사용량 추적
- 지연시간 모니터링

### 2. 앱 내 모니터링
```bash
# Redis 상태 확인
npm run redis:check

# 관리자 대시보드 접속
/admin/redis-monitor
```

### 3. 알림 설정
Upstash Console에서:
1. Settings > Alerts
2. 설정할 알림:
   - 일일 요청 한도 80% 도달
   - 오류율 5% 초과
   - 평균 지연시간 100ms 초과

## 🚨 프로덕션 체크리스트

### 배포 전 필수 확인
- [ ] Redis URL과 Token이 올바르게 설정됨
- [ ] `npm run redis:check` 모든 테스트 통과
- [ ] Rate limiting이 작동함
- [ ] 캐싱이 정상 작동함
- [ ] 에러 핸들링이 구현됨

### 성능 최적화
- [ ] Connection pooling 활성화
- [ ] Pipeline 사용 (대량 작업 시)
- [ ] 적절한 TTL 설정
- [ ] 불필요한 키 정리 (Eviction)

## 📈 확장 계획

### 트래픽 증가 시
1. **10만 요청/일**: 무료 플랜으로 충분
2. **100만 요청/일**: Pay-as-you-go ($0.2/100K)
3. **1000만 요청/일**: Pro 플랜 고려

### 글로벌 확장
```bash
# Global Database 설정 (Pro 플랜)
- Primary: Seoul
- Read replicas: Tokyo, Singapore, US-West
```

## 🛡️ 보안 설정

### 1. 접근 제어
- REST Token은 서버 사이드에서만 사용
- 클라이언트에 노출 금지
- 환경 변수로만 관리

### 2. 네트워크 보안
- HTTPS 전용 통신
- IP 화이트리스트 설정 (옵션)

## 📝 트러블슈팅

### 연결 실패
```bash
# 확인사항:
1. 환경 변수가 올바른지 확인
2. Upstash 대시보드에서 데이터베이스 상태 확인
3. 네트워크 연결 확인
```

### 성능 저하
```bash
# 대응 방법:
1. 캐시 히트율 확인 (80% 이상 유지)
2. Slow commands 모니터링
3. 키 개수 및 메모리 사용량 확인
```

### Rate Limit 이슈
```bash
# 조정 방법:
1. src/lib/redis.ts에서 한도 조정
2. 사용자 티어별 차별화
3. 임시 화이트리스트 추가
```

## 🔄 유지보수

### 일일 체크
- Redis 연결 상태
- 오류 로그 확인
- 성능 지표 확인

### 주간 체크
- 메모리 사용 패턴 분석
- Slow query 분석
- 캐시 효율성 검토

### 월간 작업
- 불필요한 키 정리
- TTL 정책 검토
- 비용 최적화 검토

---

*최종 업데이트: 2025년 7월 7일*