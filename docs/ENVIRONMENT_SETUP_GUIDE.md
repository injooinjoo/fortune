# Fortune App 환경 설정 가이드

> 최종 업데이트: 2025년 7월 11일  
> Fortune 앱의 개발/프로덕션 환경 설정을 위한 통합 가이드

## 📋 목차

1. [필수 환경 변수](#필수-환경-변수)
2. [Supabase 설정](#supabase-설정)
3. [OpenAI 설정](#openai-설정)
4. [결제 시스템 설정](#결제-시스템-설정)
5. [Redis 설정](#redis-설정)
6. [모니터링 설정](#모니터링-설정)
7. [보안 설정](#보안-설정)
8. [환경별 설정 방법](#환경별-설정-방법)
9. [검증 및 테스트](#검증-및-테스트)

## 필수 환경 변수

### 🔴 즉시 필요 (서비스 작동 필수)

```env
# Supabase (인증 및 데이터베이스)
NEXT_PUBLIC_SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_JWT_SECRET=your-jwt-secret-from-supabase-settings

# OpenAI (AI 운세 생성)
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxx

# Stripe (국제 결제)
STRIPE_SECRET_KEY=sk_live_51xxxxxxxxxxxxxxxxxxxxx
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxxxxxxxxxxxxxxxx
STRIPE_PREMIUM_MONTHLY_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx
STRIPE_PREMIUM_YEARLY_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx
STRIPE_TOKENS_SMALL_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx
STRIPE_TOKENS_MEDIUM_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx
STRIPE_TOKENS_LARGE_PRICE_ID=price_1xxxxxxxxxxxxxxxxxxxxx

# Toss Payments (한국 결제)
TOSS_CLIENT_KEY=live_ck_xxxxxxxxxxxxxxxxxxxxxxxxxx
TOSS_SECRET_KEY=live_sk_xxxxxxxxxxxxxxxxxxxxxxxxxx

# Upstash Redis (캐싱 및 Rate Limiting)
UPSTASH_REDIS_REST_URL=https://xxxxxxxx-xxxxx.upstash.io
UPSTASH_REDIS_REST_TOKEN=AxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxNjA

# 보안 키
INTERNAL_API_KEY=generate_using_openssl_rand_hex_32
CRON_SECRET=generate_using_openssl_rand_hex_32
```

### 🟡 권장 설정

```env
# Sentry (에러 모니터링)
NEXT_PUBLIC_SENTRY_DSN=https://xxxxxxxxxxxxxxxxxx@o4507234567890.ingest.us.sentry.io/1234567890
SENTRY_DSN=https://xxxxxxxxxxxxxxxxxx@o4507234567890.ingest.us.sentry.io/1234567890
SENTRY_ORG=your-org-slug
SENTRY_PROJECT=fortune
SENTRY_AUTH_TOKEN=sntrsu_xxxxxxxxxxxxxxxxxxxxxxxxxx

# Google 서비스 (선택)
GOOGLE_GENAI_API_KEY=AIzaSyxxxxxxxxxxxxxxxxxxxxxxxxxx
NEXT_PUBLIC_ADSENSE_CLIENT_ID=ca-pub-xxxxxxxxxxxxxxxxx
NEXT_PUBLIC_ADSENSE_SLOT_ID=xxxxxxxxxx
```

## Supabase 설정

### 1. 프로젝트 생성

1. [Supabase](https://supabase.com) 접속 후 새 프로젝트 생성
   - Project name: `fortune-app`
   - Region: `Northeast Asia (Seoul)`
   - 강력한 데이터베이스 비밀번호 설정

2. 프로젝트 URL과 키 확인 (Settings → API)
   - `URL`: 프로젝트 URL
   - `anon public`: 클라이언트용 익명 키
   - `service_role`: 서버용 관리자 키
   - `JWT secret`: JWT 시크릿 (Settings → Database)

### 2. 데이터베이스 설정

SQL Editor에서 다음 스크립트 실행:

```sql
-- 사용자 프로필 테이블
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE,
  name TEXT,
  birth_date DATE,
  birth_time TIME,
  is_lunar_calendar BOOLEAN DEFAULT false,
  gender TEXT CHECK (gender IN ('male', 'female', 'other')),
  mbti TEXT,
  blood_type TEXT CHECK (blood_type IN ('A', 'B', 'O', 'AB')),
  subscription_status TEXT DEFAULT 'free',
  subscription_expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  UNIQUE(user_id)
);

-- 토큰 관리 테이블
CREATE TABLE user_tokens (
  user_id UUID PRIMARY KEY REFERENCES user_profiles(user_id),
  balance INTEGER NOT NULL DEFAULT 0 CHECK (balance >= 0),
  total_purchased INTEGER DEFAULT 0,
  total_used INTEGER DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- RLS 정책 활성화
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_tokens ENABLE ROW LEVEL SECURITY;

-- RLS 정책 생성
CREATE POLICY "Users can view own profile" 
  ON user_profiles FOR SELECT 
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" 
  ON user_profiles FOR UPDATE 
  USING (auth.uid() = user_id);

-- 트리거: 신규 사용자에게 100 토큰 지급
CREATE OR REPLACE FUNCTION grant_initial_tokens()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_tokens (user_id, balance, total_bonus)
  VALUES (NEW.user_id, 100, 100);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER grant_tokens_on_profile_create
  AFTER INSERT ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION grant_initial_tokens();
```

### 3. 인증 설정

1. Authentication → Providers → Google OAuth 활성화
2. Google Cloud Console에서 OAuth 2.0 클라이언트 생성
3. Authorized redirect URIs 추가: `https://xxxxxxxxxxxxx.supabase.co/auth/v1/callback`

## OpenAI 설정

### 1. API 키 발급

1. [OpenAI Platform](https://platform.openai.com) 접속
2. API Keys 메뉴에서 새 키 생성
3. 사용 한도 설정 권장

### 2. 모델 설정

```typescript
// 권장 모델 설정
const AI_CONFIG = {
  model: 'gpt-4o-mini',  // 비용 효율적인 모델
  temperature: 0.7,
  max_tokens: 1000,
  response_format: { type: 'json_object' }
};
```

## 결제 시스템 설정

### Stripe 설정

1. **API 키 획득**
   - [Stripe Dashboard](https://dashboard.stripe.com) → API Keys
   - Production Secret Key 복사

2. **Webhook 설정**
   - Webhooks → Add endpoint
   - Endpoint URL: `https://yourdomain.com/api/payment/webhook/stripe`
   - Events: `checkout.session.completed`, `customer.subscription.deleted`

3. **상품 생성**
   ```
   프리미엄 월간: ₩9,900/월
   프리미엄 연간: ₩99,000/년
   토큰 패키지:
   - 소량 (10개): ₩1,000
   - 중량 (60+12개): ₩5,000
   - 대량 (150+50개): ₩10,000
   ```

### Toss Payments 설정

1. **API 키 획득**
   - [토스페이먼츠 대시보드](https://dashboard.tosspayments.com)
   - 개발 정보 → API 키 → 라이브 환경 키 복사

2. **결제 창 연동**
   - 성공 URL: `/payment/success`
   - 실패 URL: `/payment/fail`

## Redis 설정

### Upstash Redis 설정

1. [Upstash Console](https://console.upstash.com) 접속
2. Create Database → Seoul region 선택
3. Details 탭에서 REST URL과 Token 복사

### Rate Limiting 설정

```typescript
// 기본 제한 설정
const RATE_LIMITS = {
  fortune_generation: {
    free: { limit: 10, window: 3600 },      // 시간당 10회
    premium: { limit: 100, window: 3600 }   // 시간당 100회
  },
  api_calls: {
    default: { limit: 60, window: 60 }      // 분당 60회
  }
};
```

## 모니터링 설정

### Sentry 설정

1. [Sentry](https://sentry.io) 계정 생성
2. 새 프로젝트 생성 (Next.js 선택)
3. Settings → Projects → Client Keys에서 DSN 복사
4. Settings → Account → API → Auth Tokens에서 토큰 생성

### 에러 모니터링 설정

```typescript
// 환경별 에러 수집
const SENTRY_CONFIG = {
  environment: process.env.NODE_ENV,
  tracesSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
  ignoreErrors: ['ResizeObserver', 'Non-Error promise rejection']
};
```

## 보안 설정

### 1. 보안 키 생성

```bash
# macOS/Linux
openssl rand -hex 32

# Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 2. 환경 변수 보안

- `.env.local` 파일은 절대 Git에 커밋하지 않음
- `NEXT_PUBLIC_` 접두사가 붙은 변수만 클라이언트에서 접근 가능
- Service Role Key는 서버 사이드에서만 사용

## 환경별 설정 방법

### Vercel 배포

1. Vercel Dashboard → Settings → Environment Variables
2. Production 환경에 모든 환경 변수 추가
3. Preview 환경에는 테스트 키 사용

### 로컬 개발

`.env.local` 파일 생성:
```env
# 개발 환경용 테스트 키 사용
NODE_ENV=development
STRIPE_SECRET_KEY=sk_test_...
TOSS_CLIENT_KEY=test_ck_...
```

### Docker 배포

```yaml
# docker-compose.yml
services:
  app:
    environment:
      - NODE_ENV=production
      - NEXT_PUBLIC_SUPABASE_URL=${SUPABASE_URL}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      # ... 기타 환경 변수
```

## 검증 및 테스트

### 1. 환경 변수 검증

```bash
# 검증 스크립트 실행
npm run verify-env
```

### 2. 연결 테스트

```bash
# Supabase 연결 테스트
node scripts/test-supabase-connection.js

# Redis 연결 테스트
node scripts/test-redis-connection.js

# OpenAI API 테스트
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"
```

### 3. 결제 시스템 테스트

```bash
# Stripe CLI로 webhook 테스트
stripe listen --forward-to localhost:3000/api/payment/webhook/stripe

# 테스트 결제 시뮬레이션
stripe trigger checkout.session.completed
```

## 🚀 배포 체크리스트

### 필수 확인사항
- [ ] 모든 필수 환경 변수 설정 완료
- [ ] 프로덕션 API 키로 교체 완료
- [ ] Supabase 테이블 및 RLS 정책 적용
- [ ] Redis 연결 테스트 성공
- [ ] 결제 webhook 엔드포인트 등록
- [ ] 보안 키 강도 확인 (32자 이상)
- [ ] 환경 변수 검증 스크립트 통과

### 권장 확인사항
- [ ] Sentry 에러 추적 설정
- [ ] 백업 정책 수립
- [ ] 모니터링 대시보드 설정
- [ ] Rate limiting 정책 검토

## ⚠️ 주의사항

1. **API 키 관리**
   - 정기적인 키 로테이션 (3개월마다)
   - 접근 권한 최소화
   - 사용량 모니터링

2. **데이터베이스 보안**
   - RLS 정책 항상 활성화
   - Service Role Key 보호
   - 정기적인 백업

3. **결제 시스템**
   - Webhook 시크릿 보호
   - 중복 결제 방지 로직
   - 환불 정책 구현

---

이 가이드를 따라 Fortune 앱의 환경을 안전하고 효율적으로 설정할 수 있습니다.