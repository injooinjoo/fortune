# 🔮 Fortune Project Master Guide

> **최종 업데이트**: 2025년 7월 15일  
> **프로젝트 버전**: 3.1.0 (Flutter + Supabase Edge Functions)  
> **상태**: 프로덕션 배포 준비 완료
> 
> 📚 **모든 문서 찾기**: [MASTER_DOCUMENTATION_INDEX.md](./MASTER_DOCUMENTATION_INDEX.md)

## 📑 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [개발 현황](#3-개발-현황)
4. [개발 가이드](#4-개발-가이드)
5. [운영 가이드](#5-운영-가이드)
6. [로드맵](#6-로드맵)

---

## 1. 프로젝트 개요

### 📱 Fortune (행운) - AI 기반 운세 플랫폼

**"모든 운명은 당신의 선택에 달려있습니다."**

Fortune은 전통적인 지혜와 최신 AI 기술을 결합하여 사용자에게 깊이 있는 개인 맞춤형 운세 경험을 제공하는 플랫폼입니다.

### 🎯 핵심 특징

- **59개 운세 카테고리**: 사주, 타로, 꿈해몽, MBTI 운세 등
- **AI 기반 분석**: OpenAI GPT-4, Google Gemini Pro
- **개인화 경험**: 생년월일, MBTI, 성별 기반 맞춤 운세
- **크로스 플랫폼**: iOS/Android 네이티브 앱
- **오프라인 지원**: 로컬 캐싱으로 인터넷 없이도 사용 가능

### 💰 비즈니스 모델

- **토큰 시스템**: 운세별 차등 토큰 소비
- **IAP 결제**: Google Play, App Store 인앱 구매
- **무료 토큰**: 일일 무료 토큰 제공

---

## 2. 시스템 아키텍처

### 🏛️ 전체 구조

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│   API Server     │────▶│   External AI   │
│  (iOS/Android)  │     │ (Express + TS)   │     │ (OpenAI/Gemini) │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                       │                         
         ▼                       ▼                         
┌─────────────────┐     ┌──────────────────┐              
│  Local SQLite   │     │  Supabase DB     │              
│  (캐싱/오프라인) │     │  (PostgreSQL)    │              
└─────────────────┘     └──────────────────┘              
```

### 📱 Flutter 앱 (100% 완료)

**기술 스택**
- Framework: Flutter 3.x, Dart 3.x
- 상태관리: Riverpod 2.0
- 네비게이션: Go Router
- 로컬 DB: SQLite
- 네트워킹: Dio + Retrofit
- UI: Material You + Glassmorphism

**주요 기능**
- 117개 기능 완전 구현
- 오프라인 모드 지원
- 생체 인증 (지문/Face ID)
- 푸시 알림
- 소셜 공유

### 🚀 Supabase Edge Functions (100% 완료)

**기술 스택**
- Runtime: Deno (Supabase Edge Runtime)
- Language: TypeScript
- Database: Supabase (PostgreSQL)
- Cache: 내장 캐싱 시스템
- Deploy: Supabase Platform

**주요 기능**
- 77개 운세 API 엔드포인트 (운세 74개 + 토큰 2개 + 결제 1개)
- Supabase Auth 연동
- IAP 결제 검증
- Rate Limiting
- 토큰 관리 시스템

### 🧠 AI 운세 시스템

**4그룹 최적화 전략**

1. **평생 고정 정보** (그룹 1)
   - 사주, 토정비결 등
   - 최초 1회만 생성
   - SQLite 영구 저장

2. **일일 갱신 정보** (그룹 2)
   - 오늘/내일 운세
   - 매일 자정 배치 생성
   - 24시간 캐싱

3. **실시간 상호작용** (그룹 3)
   - 타로, 꿈해몽, 궁합
   - 사용자 입력 기반
   - 결과 캐싱

4. **온디바이스 처리** (그룹 4)
   - 관상, 손금 분석
   - TensorFlow Lite
   - 서버 비용 0원

---

## 3. 개발 현황

### ✅ 완료된 작업

**Flutter 앱 (100%)**
- 모든 UI/UX 구현 완료
- API 연동 준비 완료
- 로컬 DB 구조 완성
- 테스트 및 최적화 완료

**Supabase Edge Functions (100%)**
- 모든 운세 API 구현 완료
- 77개 함수 배포 완료
- IAP 결제 검증 시스템 구현
- 프로덕션 환경 활성화

### 🔄 진행 중인 작업

1. **앱 스토어 출시 준비**
   - 앱 아이콘/스크린샷 준비
   - 스토어 설명 작성
   - 심사 제출 준비

2. **Flutter-Edge Functions 최종 테스트**
   - 통합 테스트
   - 성능 최적화

### ⏳ 예정된 작업

1. **앱 스토어 출시**
   - 앱 아이콘/스크린샷
   - 스토어 설명 작성
   - 심사 제출

2. **문서 정리 및 최적화**
   - 오래된 문서 정리
   - 통합 문서 체계 구축

---

## 4. 개발 가이드

### 🚀 시작하기

**Flutter 앱**
```bash
cd fortune_flutter
flutter pub get
flutter run --flavor dev
```

**Supabase Edge Functions**
```bash
# Supabase CLI 설치
npm install -g supabase

# 로컬 개발
supabase start
supabase functions serve
```

### 📚 주요 문서

- [마스터 문서 인덱스](./MASTER_DOCUMENTATION_INDEX.md) - 모든 문서 찾기
- [Flutter 개발 가이드](./docs/FLUTTER_DEVELOPMENT_GUIDE.md)
- [Edge Functions 종합 가이드](./docs/EDGE_FUNCTIONS_COMPLETE_GUIDE.md)
- [운세 생성 가이드](./docs/FORTUNE_GENERATION_GUIDE.md)
- [환경 설정 가이드](./docs/ENVIRONMENT_SETUP_GUIDE.md)

### 🔑 환경 변수

**필수 설정**
```env
# Supabase
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# OpenAI
OPENAI_API_KEY=

# Redis
REDIS_URL=

# Security
JWT_SECRET=
INTERNAL_API_KEY=
```

---

## 5. 운영 가이드

### 📊 모니터링

**주요 지표**
- API 응답 시간
- 토큰 사용률
- 에러 발생률
- 사용자 활성도

**도구**
- Sentry: 에러 추적
- Firebase Analytics: 사용자 분석
- Cloud Monitoring: 서버 모니터링

### 🔒 보안

**구현된 보안 기능**
- JWT 인증
- API Rate Limiting
- SQL Injection 방지
- XSS 보호
- HTTPS 통신

### 💰 비용 최적화

**토큰 절약**
- 묶음 요청: 85% 절약
- 캐싱: 90% API 호출 감소
- 온디바이스 ML: 특정 기능 무료화

---

## 6. 로드맵

### 2025년 7월
- [x] Flutter 앱 개발 완료
- [x] Supabase Edge Functions 배포 완료
- [x] 프로덕션 환경 구축 완료
- [ ] 앱 스토어 심사 제출
- [ ] 문서 체계 정리

### 2025년 8월
- [ ] 정식 출시
- [ ] 초기 사용자 피드백 수집
- [ ] 성능 최적화

### 2025년 9월
- [ ] 마케팅 캠페인
- [ ] 기능 업데이트
- [ ] 다국어 지원 준비

### 향후 계획
- 다국어 지원 (영어, 일본어, 중국어)
- Apple Watch 앱
- 위젯 기능 확장
- AI 모델 고도화

---

## 📞 연락처

- **기술 문의**: dev@fortune.app
- **비즈니스**: business@fortune.app
- **지원**: support@fortune.app

---

*이 문서는 Fortune 프로젝트의 마스터 가이드입니다. 정기적으로 업데이트됩니다.*