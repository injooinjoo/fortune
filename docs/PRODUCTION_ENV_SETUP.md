# 🔐 Fortune 앱 프로덕션 환경 변수 설정 가이드

## 📋 개요
이 문서는 Fortune 앱을 프로덕션 환경에 배포하기 위한 환경 변수 설정 가이드입니다.

## 🚨 중요 사항
- **절대로 실제 API 키를 코드 저장소에 커밋하지 마세요**
- `.env.local` 파일은 `.gitignore`에 포함되어 있어야 합니다
- 프로덕션 키는 안전한 방법으로 관리하세요 (환경 변수 관리 서비스 사용 권장)

## 📝 환경 변수 설정 체크리스트

### 1. Stripe 결제 시스템 (🔴 필수)
```bash
# 현재: 테스트 키 사용 중
# 필요: 프로덕션 키로 교체

# Stripe Dashboard에서 가져올 키들:
STRIPE_SECRET_KEY=sk_live_... # API Keys 섹션
STRIPE_WEBHOOK_SECRET=whsec_... # Webhooks 섹션

# Products & Prices에서 생성한 가격 ID들:
STRIPE_PREMIUM_MONTHLY_PRICE_ID=price_... # 프리미엄 월간
STRIPE_PREMIUM_YEARLY_PRICE_ID=price_... # 프리미엄 연간
STRIPE_TOKENS_SMALL_PRICE_ID=price_... # 토큰 소량
STRIPE_TOKENS_MEDIUM_PRICE_ID=price_... # 토큰 중량
STRIPE_TOKENS_LARGE_PRICE_ID=price_... # 토큰 대량
```

**설정 방법:**
1. [Stripe Dashboard](https://dashboard.stripe.com) 로그인
2. API Keys 메뉴에서 Production Secret Key 복사
3. Webhooks 메뉴에서 Endpoint 생성 후 Signing Secret 복사
4. Products 메뉴에서 각 상품의 Price ID 복사

### 2. Toss Payments (🔴 필수)
```bash
# 현재: 테스트 키 사용 중
# 필요: 프로덕션 키로 교체

TOSS_CLIENT_KEY=live_ck_... # 라이브 클라이언트 키
TOSS_SECRET_KEY=live_sk_... # 라이브 시크릿 키
```

**설정 방법:**
1. [토스페이먼츠 대시보드](https://dashboard.tosspayments.com) 로그인
2. 개발 정보 > API 키 메뉴
3. 라이브 환경 키 복사

### 3. Upstash Redis (🔴 필수)
```bash
# 현재: 플레이스홀더 값
# 필요: 실제 Redis 인스턴스 정보

UPSTASH_REDIS_REST_URL=https://your-instance.upstash.io
UPSTASH_REDIS_REST_TOKEN=your_token_here
```

**설정 방법:**
1. [Upstash Console](https://console.upstash.com) 로그인
2. Redis Database 생성
3. REST API 섹션에서 URL과 Token 복사

### 4. Sentry 모니터링 (🟡 권장)
```bash
# 현재: 플레이스홀더 값
# 필요: 실제 프로젝트 정보

NEXT_PUBLIC_SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
SENTRY_ORG=your-organization
SENTRY_PROJECT=fortune
SENTRY_AUTH_TOKEN=sntrys_xxx...
```

**설정 방법:**
1. [Sentry](https://sentry.io) 로그인
2. 새 프로젝트 생성 (Next.js 선택)
3. Settings > Projects > Client Keys에서 DSN 복사
4. Settings > Account > API > Auth Tokens에서 토큰 생성

### 5. AI API 키 확인 (🟢 기존 키 검증)
```bash
# OpenAI API 키가 유효한지 확인
OPENAI_API_KEY=sk-proj-...

# Google Genkit API 키 설정 (사용 시)
GOOGLE_GENAI_API_KEY=your_api_key
```

## 🔧 환경별 설정

### Vercel 배포 시
1. Vercel Dashboard > Settings > Environment Variables
2. 각 환경 변수를 Production 환경에 추가
3. `NODE_ENV=production` 자동 설정됨

### 직접 배포 시
1. 서버의 `.env.production` 파일에 설정
2. PM2 사용 시: `ecosystem.config.js`에 환경 변수 추가
3. Docker 사용 시: `docker-compose.yml`에 환경 변수 추가

## 🔍 환경 변수 검증 스크립트

`scripts/verify-env.js` 실행하여 모든 필수 환경 변수가 설정되었는지 확인:

```bash
npm run verify-env
```

## 📊 환경 변수 우선순위

1. **🔴 즉시 필요** (서비스 작동 필수)
   - Stripe 키 (결제 기능)
   - Toss Payments 키 (한국 결제)
   - Upstash Redis (Rate Limiting)

2. **🟡 곧 필요** (모니터링/안정성)
   - Sentry DSN (에러 추적)
   - Redis 모니터링 설정

3. **🟢 이미 설정됨** (검증만 필요)
   - Supabase 키
   - OpenAI API 키
   - 보안 키 (INTERNAL_API_KEY, CRON_SECRET)

## 🚀 다음 단계

1. 위 체크리스트에 따라 프로덕션 키 획득
2. `.env.local` 파일 업데이트
3. `npm run verify-env`로 검증
4. 스테이징 환경에서 테스트
5. 프로덕션 배포

## ⚠️ 보안 주의사항

- API 키는 절대 클라이언트 코드에 노출하지 마세요
- `NEXT_PUBLIC_` 접두사가 붙은 변수만 클라이언트에서 접근 가능
- 정기적으로 API 키 로테이션 수행
- 접근 권한은 최소한으로 설정

---

*최종 업데이트: 2025년 7월 7일*