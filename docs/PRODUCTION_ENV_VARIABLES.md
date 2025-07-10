# 🔐 Fortune 프로덕션 환경 변수 설정 가이드

> **최종 업데이트**: 2025년 7월 7일  
> **중요도**: 🔴 긴급 - 프로덕션 배포 전 필수

## 📋 목차

1. [필수 환경 변수](#필수-환경-변수)
2. [환경별 설정값](#환경별-설정값)
3. [보안 주의사항](#보안-주의사항)
4. [설정 검증](#설정-검증)

## 필수 환경 변수

### 🗄️ Supabase (필수)
```env
# Supabase 프로젝트 설정에서 확인
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=your-jwt-secret-from-supabase-settings
```

### 🤖 AI API Keys (필수)
```env
# OpenAI Platform에서 발급
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxx

# Google AI Studio에서 발급 (옵션)
GOOGLE_GENAI_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 💳 결제 시스템 (필수)

#### Stripe (프로덕션)
```env
# Stripe Dashboard > API Keys
STRIPE_SECRET_KEY=sk_live_51xxxxxxxxxxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxxxxxxx

# Stripe Dashboard > Products
STRIPE_PREMIUM_MONTHLY_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx
STRIPE_PREMIUM_YEARLY_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx
STRIPE_TOKENS_SMALL_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx
STRIPE_TOKENS_MEDIUM_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx
STRIPE_TOKENS_LARGE_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx
```

#### Toss Payments (프로덕션)
```env
# Toss Payments Console
TOSS_CLIENT_KEY=live_ck_xxxxxxxxxxxxxxxxxxxxxxxxxx
TOSS_SECRET_KEY=live_sk_xxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 📊 인프라 (필수)

#### Upstash Redis
```env
# Upstash Console > Redis > Details
UPSTASH_REDIS_REST_URL=https://xxxxxxxx-xxxxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=AxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxNjA
```

#### Sentry 모니터링
```env
# Sentry > Settings > Projects > Client Keys
NEXT_PUBLIC_SENTRY_DSN=https://xxxxxxxxxxxxxxxxxx@o4507234567890.ingest.us.sentry.io/1234567890
SENTRY_DSN=https://xxxxxxxxxxxxxxxxxx@o4507234567890.ingest.us.sentry.io/1234567890
SENTRY_ORG=your-org-slug
SENTRY_PROJECT=fortune
SENTRY_AUTH_TOKEN=sntrsu_xxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 🔒 보안 키 (필수)
```env
# 강력한 랜덤 키 생성 필요
INTERNAL_API_KEY=generate_using_openssl_rand_hex_32
CRON_SECRET=generate_using_openssl_rand_hex_32
```

### 💰 광고 (옵션)
```env
# Google AdSense Console
NEXT_PUBLIC_ADSENSE_CLIENT_ID=ca-pub-xxxxxxxxxxxxxxxxx
NEXT_PUBLIC_ADSENSE_SLOT_ID=xxxxxxxxxx
NEXT_PUBLIC_ADSENSE_DISPLAY_SLOT=xxxxxxxxxx
```

## 환경별 설정값

### 개발 환경 (.env.local)
```env
NODE_ENV=development
# Stripe 테스트 키 사용
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxxxxxxxxxxxxxxxx
# Toss 테스트 키 사용
TOSS_CLIENT_KEY=test_ck_xxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 스테이징 환경 (.env.staging)
```env
NODE_ENV=production
# 프로덕션 키 사용하되 테스트 모드 활성화
STRIPE_TEST_MODE=true
TOSS_TEST_MODE=true
```

### 프로덕션 환경 (.env.production)
```env
NODE_ENV=production
# 모든 실제 프로덕션 키 사용
# 테스트 모드 비활성화
```

## 보안 주의사항

### ⚠️ 절대 하지 말아야 할 것들

1. **환경 변수를 코드에 하드코딩하지 마세요**
2. **.env 파일을 Git에 커밋하지 마세요**
3. **서비스 키를 클라이언트에 노출하지 마세요**
4. **프로덕션 키를 개발 환경에서 사용하지 마세요**

### ✅ 반드시 해야 할 것들

1. **강력한 랜덤 키 생성**
   ```bash
   # macOS/Linux
   openssl rand -hex 32
   
   # Node.js
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

2. **환경 변수 검증**
   ```bash
   # 검증 스크립트 실행
   npm run verify:env
   ```

3. **정기적인 키 로테이션**
   - 3개월마다 API 키 갱신
   - 보안 사고 시 즉시 교체

## 설정 검증

### 1. 환경 변수 검증 스크립트
```bash
# 모든 필수 환경 변수가 설정되었는지 확인
node scripts/verify-env.js
```

### 2. Redis 연결 테스트
```bash
# Redis 연결 및 성능 테스트
node scripts/redis-production-check.js
```

### 3. 결제 시스템 테스트
```bash
# Stripe Webhook 테스트
stripe listen --forward-to localhost:3000/api/webhook/stripe

# Toss Payments 테스트
curl -X POST https://api.tosspayments.com/v1/payments/confirm \
  -H "Authorization: Basic $(echo -n $TOSS_SECRET_KEY: | base64)"
```

### 4. Sentry 연결 테스트
```bash
# Sentry 테스트 이벤트 전송
npx @sentry/cli send-event -m "Test event from production setup"
```

## 📝 체크리스트

배포 전 확인사항:

- [ ] 모든 필수 환경 변수 설정 완료
- [ ] 프로덕션 키로 교체 완료
- [ ] 환경 변수 검증 스크립트 통과
- [ ] Redis 연결 테스트 성공
- [ ] 결제 시스템 연동 테스트 성공
- [ ] Sentry 연동 확인
- [ ] 보안 키 강도 확인 (32자 이상)
- [ ] .env 파일 권한 설정 (600)
- [ ] 백업 및 복구 계획 수립

## 🚨 긴급 연락처

문제 발생 시:
1. Supabase Status: https://status.supabase.com
2. Stripe Status: https://status.stripe.com
3. Upstash Status: https://status.upstash.com
4. Sentry Status: https://status.sentry.io

---

**Note**: 이 문서는 민감한 정보를 포함하고 있으므로 안전하게 관리하시기 바랍니다.