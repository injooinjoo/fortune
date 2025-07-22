# 🔐 API Key Rotation Guide

> **최종 업데이트**: 2025년 7월 11일  
> **중요도**: 🚨 매우 높음 - 정기적인 키 로테이션은 보안의 핵심입니다

## 📋 API 키 로테이션 체크리스트

### 1. OpenAI API Key

#### 재발급 절차
1. [OpenAI Platform](https://platform.openai.com/api-keys) 접속
2. 기존 키 삭제 (Revoke)
3. "Create new secret key" 클릭
4. 키 이름 지정 (예: `fortune-app-prod-2025-07`)
5. 새 키 안전하게 저장

#### 업데이트 위치
```bash
# Supabase Edge Functions
supabase secrets set OPENAI_API_KEY="sk-proj-새로운키"

# 로컬 개발 환경
# .env.local 파일 업데이트
OPENAI_API_KEY=sk-proj-새로운키
```

### 2. Supabase Service Role Key

#### 재발급 절차
1. [Supabase Dashboard](https://app.supabase.com) 접속
2. Project Settings → API
3. "Regenerate service role key" 클릭
4. 확인 후 재생성

#### 업데이트 위치
```bash
# Edge Functions secrets
supabase secrets set SUPABASE_SERVICE_ROLE_KEY="새로운키"

# fortune-api-server/.env
SUPABASE_SERVICE_ROLE_KEY=새로운키

# 로컬 .env.local
SUPABASE_SERVICE_ROLE_KEY=새로운키
```

### 3. Redis (Upstash) Token

#### 재발급 절차
1. [Upstash Console](https://console.upstash.com) 접속
2. 해당 Redis 인스턴스 선택
3. Details → REST API → "Reset Token"
4. 새 토큰 복사

#### 업데이트 위치
```bash
# .env 파일들
UPSTASH_REDIS_REST_TOKEN=새로운토큰
```

### 4. Google OAuth Client Secret

#### 재발급 절차
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. APIs & Services → Credentials
3. OAuth 2.0 Client ID 선택
4. "Reset Secret" 클릭
5. 새 client_secret.json 다운로드

#### 업데이트 위치
- 새 client_secret.json 파일로 교체
- **절대 Git에 커밋하지 마세요!**

### 5. Stripe API Keys

#### 재발급 절차
1. [Stripe Dashboard](https://dashboard.stripe.com) 접속
2. Developers → API keys
3. "Roll key" 클릭 (Secret key)
4. Webhook endpoint에서 새 signing secret 생성

#### 업데이트 위치
```bash
# Edge Functions (프로덕션용)
supabase secrets set STRIPE_SECRET_KEY="sk_live_새로운키"
supabase secrets set STRIPE_WEBHOOK_SECRET="whsec_새로운키"

# 로컬 개발 (테스트키)
STRIPE_SECRET_KEY=sk_test_새로운키
```

## 🔄 정기 로테이션 일정

| API Key | 권장 주기 | 마지막 로테이션 | 다음 예정일 |
|---------|-----------|----------------|-------------|
| OpenAI | 3개월 | 2025.07.11 | 2025.10.11 |
| Supabase Service Role | 6개월 | 2025.07.11 | 2026.01.11 |
| Redis Token | 6개월 | 2025.07.11 | 2026.01.11 |
| Google OAuth | 1년 | 2025.07.11 | 2026.07.11 |
| Stripe Keys | 1년 | 2025.07.11 | 2026.07.11 |

## 🚨 긴급 로테이션이 필요한 경우

즉시 키를 로테이션해야 하는 상황:
1. 키가 공개 저장소에 노출된 경우
2. 의심스러운 API 사용 패턴 감지
3. 팀원 퇴사 또는 접근 권한 변경
4. 보안 침해 의심 시

## 📝 로테이션 후 체크리스트

### 1. 기능 테스트
- [ ] OpenAI 운세 생성 테스트
- [ ] Supabase 인증 테스트
- [ ] Redis 캐싱 동작 확인
- [ ] Google OAuth 로그인 테스트
- [ ] Stripe 결제 테스트

### 2. 배포 확인
- [ ] Edge Functions 재배포
- [ ] 환경 변수 업데이트 확인
- [ ] 모니터링 대시보드 확인

### 3. 문서 업데이트
- [ ] 이 문서의 로테이션 날짜 업데이트
- [ ] 팀 위키 업데이트
- [ ] 관련자 통보

## 🛡️ 보안 모범 사례

### DO ✅
- 정기적인 키 로테이션 실시
- 키 생성 시 설명적인 이름 사용
- 환경별로 다른 키 사용 (dev/staging/prod)
- 키 접근 로그 모니터링
- 최소 권한 원칙 적용

### DON'T ❌
- 키를 코드에 하드코딩
- 키를 Git에 커밋
- 키를 평문으로 저장
- 키를 이메일/메신저로 공유
- 만료된 키 재사용

## 🔧 자동화 도구

### 키 로테이션 스크립트 예시
```bash
#!/bin/bash
# rotate-keys.sh

echo "🔐 Starting API key rotation..."

# 1. OpenAI 키 로테이션
read -p "Enter new OpenAI API key: " OPENAI_KEY
supabase secrets set OPENAI_API_KEY="$OPENAI_KEY"

# 2. 로컬 환경 업데이트
sed -i '' "s/OPENAI_API_KEY=.*/OPENAI_API_KEY=$OPENAI_KEY/" .env.local

echo "✅ Key rotation completed!"
```

## 📊 모니터링

### 키 사용량 모니터링
- OpenAI: Platform dashboard에서 사용량 확인
- Supabase: Project dashboard에서 API 호출 확인
- Stripe: Dashboard에서 API 로그 확인

### 이상 징후 감지
- 비정상적인 API 호출 증가
- 예상치 못한 지역에서의 접근
- 실패한 인증 시도 급증

## 🆘 문제 발생 시

### 키가 작동하지 않을 때
1. 키가 올바르게 복사되었는지 확인
2. 환경 변수가 제대로 설정되었는지 확인
3. 서비스 재시작
4. 캐시 클리어

### 롤백이 필요한 경우
1. 이전 키가 아직 유효한지 확인
2. 임시로 이전 키로 복구
3. 문제 해결 후 새 키로 재시도

---

*이 문서는 Fortune 프로젝트의 API 키 관리를 위한 가이드입니다.*  
*보안은 모든 팀원의 책임입니다. 의심스러운 활동을 발견하면 즉시 보고하세요.*