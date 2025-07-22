# 🔐 Secure Deployment Guide

> **최종 업데이트**: 2025년 7월 11일  
> **중요도**: 🚨 매우 높음 - 보안은 배포의 핵심입니다

## 📋 배포 전 보안 체크리스트

### 1. 환경 변수 보안

#### ❌ 절대 하지 말아야 할 것
```bash
# 하드코딩된 시크릿
const API_KEY = "sk-proj-actual-key-here"  # 절대 금지!

# .env 파일 커밋
git add .env  # 절대 금지!
```

#### ✅ 올바른 방법
```bash
# 환경 변수 사용
const API_KEY = process.env.OPENAI_API_KEY

# Supabase Secrets 사용
const API_KEY = Deno.env.get('OPENAI_API_KEY')
```

### 2. Supabase Edge Functions 보안 배포

#### 시크릿 설정
```bash
# 프로덕션 시크릿 설정
supabase secrets set OPENAI_API_KEY="sk-proj-xxx" --project-ref hayjukwfcsdmppairazc
supabase secrets set STRIPE_SECRET_KEY="sk_live_xxx" --project-ref hayjukwfcsdmppairazc

# 시크릿 확인 (값은 보이지 않음)
supabase secrets list --project-ref hayjukwfcsdmppairazc
```

#### 안전한 배포 프로세스
```bash
# 1. 환경 변수 확인
echo "Checking environment..."
supabase secrets list

# 2. 함수 배포
supabase functions deploy function-name --project-ref hayjukwfcsdmppairazc

# 3. 배포 확인
supabase functions list
```

### 3. Flutter 앱 보안 배포

#### 환경별 설정 분리
```dart
// lib/core/config/environment.dart
class Environment {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  
  // 프로덕션 여부 확인
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}
```

#### 빌드 시 환경 변수 주입
```bash
# iOS 빌드
flutter build ios --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key

# Android 빌드
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## 🛡️ 보안 강화 설정

### 1. Rate Limiting

#### Edge Functions에서
```typescript
// _shared/rateLimit.ts
const RATE_LIMIT = {
  windowMs: 60000, // 1분
  maxRequests: 20, // 사용자당 분당 20회
};

export async function checkRateLimit(userId: string): Promise<boolean> {
  // Redis 또는 Supabase 테이블을 사용한 rate limiting
  const key = `rate_limit:${userId}`;
  const count = await incrementCounter(key);
  
  if (count > RATE_LIMIT.maxRequests) {
    return false;
  }
  
  return true;
}
```

### 2. CORS 설정

#### 엄격한 CORS 정책
```typescript
// _shared/cors.ts
export const corsHeaders = {
  'Access-Control-Allow-Origin': process.env.ALLOWED_ORIGINS || 'https://your-app.com',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
  'Access-Control-Max-Age': '86400',
};
```

### 3. 입력 검증

#### 요청 데이터 검증
```typescript
// _shared/validation.ts
import { z } from 'https://deno.land/x/zod/mod.ts';

export const fortuneRequestSchema = z.object({
  name: z.string().min(1).max(100),
  birthDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  birthTime: z.string().optional(),
  // ... 기타 필드
});

export function validateRequest(data: unknown) {
  return fortuneRequestSchema.parse(data);
}
```

## 📊 모니터링 및 로깅

### 1. 보안 이벤트 로깅

```typescript
// 모든 인증 실패 로깅
console.log(JSON.stringify({
  event: 'auth_failure',
  timestamp: new Date().toISOString(),
  ip: req.headers.get('x-forwarded-for'),
  userAgent: req.headers.get('user-agent'),
  reason: 'invalid_token'
}));
```

### 2. 이상 징후 감지

```sql
-- 비정상적인 토큰 사용 감지
SELECT 
  user_id,
  COUNT(*) as request_count,
  SUM(tokens_used) as total_tokens
FROM fortune_requests
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY user_id
HAVING COUNT(*) > 100 -- 시간당 100회 초과
   OR SUM(tokens_used) > 500; -- 시간당 500토큰 초과
```

## 🚀 CI/CD 보안

### GitHub Actions 보안 설정

```yaml
# .github/workflows/deploy.yml
name: Secure Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to Supabase
      env:
        SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
        SUPABASE_PROJECT_ID: ${{ secrets.SUPABASE_PROJECT_ID }}
      run: |
        # 시크릿은 GitHub Secrets에서만 관리
        supabase functions deploy --project-ref $SUPABASE_PROJECT_ID
```

## 🔒 프로덕션 체크리스트

### 배포 전
- [ ] 모든 API 키가 환경 변수로 설정되었는가?
- [ ] .env 파일이 .gitignore에 포함되었는가?
- [ ] 테스트 키가 프로덕션 키로 교체되었는가?
- [ ] Rate limiting이 설정되었는가?
- [ ] CORS가 올바르게 설정되었는가?
- [ ] 입력 검증이 구현되었는가?
- [ ] 에러 메시지에 민감한 정보가 노출되지 않는가?

### 배포 후
- [ ] 모든 엔드포인트가 HTTPS로만 접근 가능한가?
- [ ] 로깅이 제대로 작동하는가?
- [ ] 모니터링 대시보드가 설정되었는가?
- [ ] 백업이 자동화되었는가?
- [ ] 보안 알림이 설정되었는가?

## 🚨 보안 사고 대응

### 즉시 조치 사항
1. **영향받은 서비스 중단**
   ```bash
   # Edge Function 비활성화
   supabase functions delete compromised-function
   ```

2. **모든 API 키 즉시 재발급**
   - OpenAI, Supabase, Stripe 등 모든 키 로테이션

3. **감사 로그 확인**
   ```sql
   -- 의심스러운 활동 확인
   SELECT * FROM audit_logs
   WHERE created_at > '침해 의심 시점'
   ORDER BY created_at DESC;
   ```

4. **사용자 알림**
   - 영향받은 사용자에게 즉시 통보
   - 필요시 비밀번호 재설정 요구

## 📚 추가 보안 리소스

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Supabase Security Best Practices](https://supabase.com/docs/guides/auth/security)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)

---

*보안은 일회성 작업이 아닌 지속적인 프로세스입니다.*  
*정기적인 보안 감사와 업데이트를 잊지 마세요!*