# 🔮 Fortune Project Master Guide

> **최종 업데이트**: 2025년 7월 7일  
> **프로젝트 버전**: 1.4.0  
> **상태**: Production Ready with Admin Dashboard & Enhanced AI

## 📑 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [기술 아키텍처](#2-기술-아키텍처)
3. [현재 프로젝트 상태](#3-현재-프로젝트-상태)
4. [개발 가이드라인](#4-개발-가이드라인)
5. [TODO 및 로드맵](#5-todo-및-로드맵)
6. [API 및 보안](#6-api-및-보안)
7. [배포 및 운영](#7-배포-및-운영)

---

## 1. 프로젝트 개요

### 📱 Fortune (행운) 소개

**"모든 운명은 당신의 선택에 달려있습니다."**

Fortune은 전통적인 지혜와 최신 AI 기술을 결합하여 사용자에게 깊이 있는 개인 맞춤형 운세 경험을 제공하는 풀스택 애플리케이션입니다.

- **[🔗 실시간 웹 데모](https://fortune-explorer.vercel.app)**
- **총 59개 운세 서비스**: 사주, 타로, 꿈해몽, MBTI 운세 등
- **AI 기반 분석**: OpenAI GPT-4.1-nano
- **개인화 경험**: 생년월일, MBTI, 성별 기반 맞춤 운세

### 🎯 핵심 기능

#### 🔮 핵심 운세 서비스
- **매일의 운세**: 오늘/내일/시간별 운세, MBTI별 운세
- **심층 분석**: 사주팔자, 토정비결, 주역점, 풍수지리
- **인터랙티브 운세**: 타로카드, 관상/손금 분석, 꿈해몽

#### ✨ 특별 콘텐츠
- **주제별 운세**: 연애/결혼, 취업/시험, 재물/투자
- **흥미 운세**: 연예인 궁합, 이름풀이, SNS 닉네임 운세

#### 💰 결제 시스템 (NEW)
- **토큰 시스템**: 운세별 차등 토큰 소비
- **구독 플랜**: Free, Basic, Premium, Enterprise
- **결제 연동**: Stripe, Toss Payments, Naver Pay

---

## 2. 기술 아키텍처

### 🏛️ 시스템 아키텍처

#### 프론트엔드
```
- Framework: Next.js 15 (App Router)
- UI: React 18, Tailwind CSS, shadcn/ui
- State: React Hook Form, Zod
- Animation: Framer Motion, Tailwind Animate
- Design: Liquid Glass UI (2025 iOS 26 Design)
```

#### 백엔드 & AI
```
- Auth & DB: Supabase (PostgreSQL)
- AI: OpenAI GPT-4.1-nano
- API: Next.js API Routes
- Security: API Auth, Rate Limiting
- Cache: Redis (Upstash), LocalStorage
- Payment: Stripe, Toss Payments
```

### 🧠 4그룹 운세 시스템

#### 그룹 1: 평생 고정 정보
- **특징**: 최초 1회만 생성, 영구 저장
- **대상**: 사주, 전통사주, 토정비결, 전생, 성격분석
- **비용 절감**: 90% API 비용 감소

#### 그룹 2: 일일 정보
- **특징**: 매일 자정 배치 생성
- **대상**: 일일운세, 시간별운세, 행운의 숫자/색상
- **성능**: DB 조회로 즉시 응답

#### 그룹 3: 실시간 상호작용
- **특징**: 사용자 입력 기반 실시간 생성
- **대상**: 타로, 꿈해몽, 궁합, 고민구슬
- **캐싱**: 입력값 해시로 중복 방지

#### 그룹 4: 클라이언트 기반
- **특징**: 서버 비용 0원, 오프라인 작동
- **대상**: 관상분석, 손금, 부적생성
- **기술**: Teachable Machine, 클라이언트 모델

### 💾 데이터베이스 스키마

#### 핵심 테이블
```sql
-- 운세 데이터
fortunes (id, user_id, fortune_type, data, expires_at)

-- 사용자 프로필
user_profiles (id, name, birth_date, mbti, gender)

-- 결제 관련 (NEW)
payment_transactions (id, user_id, amount, status)
user_tokens (user_id, balance, total_purchased)
subscription_status (user_id, plan_type, status)
fortune_history (user_id, fortune_type, token_cost)
```

---

## 3. 현재 프로젝트 상태

### ✅ 구현 완료 (100%)

#### AI 통합
- ✅ 59개 운세 페이지 GPT-4.1-nano 연동
- ✅ 중앙집중식 배치 생성 시스템
- ✅ 3단계 fallback 시스템
- ✅ 토큰 사용량 65-85% 절감
- ✅ 향상된 운세 서비스 (enhanced-fortune-service.ts)
- ✅ Unicode 정규화로 한글 인코딩 문제 해결

#### 보안 (Phase 1 & 2)
- ✅ API 인증 미들웨어 (95% 보호)
- ✅ Rate Limiting (Redis + 메모리)
- ✅ Math.random() 완전 제거
- ✅ Sentry 에러 추적
- ✅ 보안 점수: 91/100

#### 기능 개선
- ✅ 사용자 ID 컨텍스트 연결 (11개 페이지)
- ✅ API 응답 표준화 (73개 엔드포인트)
- ✅ 운세 히스토리 차트 (Recharts)
- ✅ 소셜 공유 기능 (html2canvas)
- ✅ 18개 Fortune API 실제 프로필 조회

#### 결제 & 토큰 시스템
- ✅ Stripe Webhook 처리
- ✅ 토큰 차감 시스템 (token-tracker.ts)
- ✅ 구독 관리
- ✅ 결제 히스토리
- ✅ 토큰 잔액 표시 컴포넌트
- ✅ 토큰 사용량 대시보드 (/dashboard/tokens)

#### 관리자 기능
- ✅ Admin Dashboard (/admin)
- ✅ Redis 모니터링 (/admin/redis-monitor)
- ✅ 토큰 통계 API (/api/admin/token-stats)
- ✅ Redis 통계 API (/api/admin/redis-stats)

### 📊 성능 지표

| 지표 | 현재값 | 목표 |
|-----|-------|-----|
| API 응답시간 | 1-3초 | <1초 |
| 캐시 히트율 | 80-90% | >90% |
| 일일 API 호출 | ~10,000회 | - |
| 월간 비용 | $25-50 | <$100 |
| 보호된 API | 95% | 100% |
| API 표준화 | 100% | 100% |

---

## 4. 개발 가이드라인

### 🏴‍☠️ 필수 개발 규칙

#### 코드 작성시
1. **TypeScript 엄격 모드**: 모든 타입 명시
2. **파일 크기**: 최대 500줄 (초과시 리팩토링)
3. **임포트**: 절대 경로 사용 (`@/lib/...`)
4. **환경 변수**: 서버 컴포넌트에서만 직접 접근
5. **보안**: API 키는 절대 하드코딩 금지

#### 개발 완료 후 필수 체크리스트
```bash
# 1. 코드 품질 검증
npm run lint
npm run type-check
npm run format:check

# 2. 테스트 실행
npm test
npm run test:coverage

# 3. 빌드 검증
npm run build

# 4. 보안 검사
npm audit
```

### 🔒 보안 체크리스트
- [ ] 프론트엔드에 민감 정보 노출 없음
- [ ] API 엔드포인트 인증 적용
- [ ] 입력값 검증 (Zod)
- [ ] XSS/CSRF 방어
- [ ] SQL Injection 방지

### 📚 코드 설명 요구사항
개발 완료 후 반드시:
1. 전체 아키텍처 설명
2. 주요 함수/컴포넌트 작동 방식
3. 보안 고려사항
4. 성능 최적화 내용
5. 테스트 전략

---

## 5. TODO 및 로드맵

### 🔴 긴급 (이번 주)

#### 1. 코드 품질 개선
- 734개 console.log 제거/대체
- 87개 alert() UI 알림으로 변경
- 3개 TODO 주석 해결
- 빌드 에러 수정

#### 2. 프로덕션 환경 설정
```env
# 실제 키로 교체 필요
STRIPE_SECRET_KEY=(현재 테스트 키)
STRIPE_WEBHOOK_SECRET=(현재 테스트 키)
UPSTASH_REDIS_REST_URL=(프로덕션 URL)
UPSTASH_REDIS_REST_TOKEN=(프로덕션 토큰)
```

#### 3. Redis 프로덕션 최적화
- 프로덕션 연결 테스트
- 캐시 전략 최적화
- 모니터링 대시보드 활성화

### 🟡 높은 우선순위

#### 4. 시스템 모니터링
- [ ] Sentry 알림 규칙 설정
- [ ] Redis 성능 최적화
- [ ] API 응답 시간 개선 (<1초)
- [ ] 토큰 사용량 분석

#### 5. 사용자 경험
- [ ] 온보딩 프로세스 개선
- [ ] 푸시 알림 시스템
- [ ] 운세 피드백 수집

### 🟢 중간 우선순위

#### 6. 코드 정리
- [ ] 불필요한 TODO 주석 제거
- [ ] API 라우트 프로필 조회 개선
- [ ] 테스트 커버리지 80% 달성

#### 7. 최적화
- [ ] 번들 사이즈 감소
- [ ] 이미지 최적화
- [ ] PWA 기능 강화

### 📅 장기 로드맵

#### Q1 2025
- ✅ 보안 Phase 1&2 (완료)
- ✅ 결제 시스템 (완료)
- [ ] 푸시 알림
- [ ] 모니터링 대시보드

#### Q2 2025
- [ ] React Native 앱
- [ ] OAuth 2.0 확장
- [ ] 국제화 (i18n)

#### Q3 2025
- [ ] AI 모델 고도화
- [ ] 음성 기반 운세
- [ ] 블록체인 NFT 운세

---

## 6. API 및 보안

### 🔐 보안 구현 현황

#### API 보호
```typescript
// 모든 운세 API는 인증 필요
import { withAuth } from '@/middleware/auth';

export async function GET(request) {
  return withAuth(request, async (req) => {
    // 인증된 사용자만 접근 가능
  });
}
```

#### Rate Limiting
```typescript
// 분당 10회 제한
const rateLimitResult = await checkRateLimit(clientIp, 'fortune');
if (!rateLimitResult.allowed) {
  return NextResponse.json({ error: 'Too many requests' }, { status: 429 });
}
```

### 💳 결제 API

#### 토큰 차감
```typescript
// 운세 생성시 자동 차감
const deductionResult = await tokenService.deductTokens(userId, 'daily');
if (!deductionResult.success) {
  return NextResponse.json({ error: '토큰 부족' }, { status: 402 });
}
```

#### Webhook 처리
```typescript
// Stripe 결제 성공시
async function handleCheckoutSessionCompleted(session) {
  // 1. 결제 기록
  // 2. 토큰/구독 업데이트
  // 3. 사용자 알림
}
```

---

## 7. 배포 및 운영

### 🚀 배포 체크리스트

#### 데이터베이스
```bash
# 결제 테이블 생성
psql $DATABASE_URL < scripts/create-payment-tables.sql
```

#### 환경 변수
1. Vercel 대시보드에서 모든 환경 변수 설정
2. 특히 `SUPABASE_SERVICE_ROLE_KEY` 보안 주의

#### 모니터링
- Sentry: 에러 추적
- Vercel Analytics: 성능 모니터링
- Supabase: DB 쿼리 분석

### 📊 운영 지표 모니터링

#### 필수 추적 항목
1. **API 성능**: 응답시간, 에러율
2. **토큰 사용량**: 일일/월간 소비
3. **결제 지표**: 전환율, 수익
4. **사용자 지표**: DAU, 리텐션

### 🔧 유지보수

#### 일일 점검
- [ ] 에러 로그 확인
- [ ] API 응답시간 체크
- [ ] 토큰 사용량 모니터링

#### 주간 작업
- [ ] 보안 업데이트 확인
- [ ] 성능 리포트 검토
- [ ] 사용자 피드백 수집

#### 월간 작업
- [ ] 비용 분석
- [ ] 기능 사용 통계
- [ ] 시스템 최적화

---

## 📚 참고 문서

### 내부 문서
- [보안 가이드](./docs/SECURITY.md)
- [GPT 통합 상태](./docs/GPT_INTEGRATION_STATUS.md)
- [AdSense 구현](./docs/ADSENSE_IMPLEMENTATION.md)

### 외부 링크
- [프로덕션 사이트](https://fortune-explorer.vercel.app)
- [GitHub 저장소](https://github.com/injooinjoo/fortune)
- [Vercel 대시보드](https://vercel.com/dashboard)

---

**Note**: 이 문서는 Fortune 프로젝트의 단일 진실 공급원(Single Source of Truth)입니다. 모든 팀원은 이 문서를 기준으로 개발하고, 변경사항이 있으면 즉시 업데이트해야 합니다.

*마지막 업데이트: 2025년 7월 7일*  
*다음 검토: 2025년 7월 14일*

## 🎆 최근 업데이트

### 2025년 7월 7일 (v1.4.0)
- ✅ Admin Dashboard 구현 (/admin)
- ✅ Redis 모니터링 시스템
- ✅ 토큰 사용량 대시보드
- ✅ GPT-4.1-nano 업그레이드
- ✅ 향상된 운세 서비스 (캐싱, 에러 처리)
- ✅ 코드 품질 검사 도구 추가
- ✅ 환경 변수 검증 시스템

### 2025년 1월 9일
- ✅ 사용자 ID 컨텍스트 연결 (11개 fortune 페이지)
- ✅ API 응답 표준화 (73개 엔드포인트)
- ✅ 운세 히스토리 차트 구현
- ✅ 소셜 공유 기능 완성
- ✅ 18개 Fortune API 실제 프로필 조회