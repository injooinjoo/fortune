# ZPZG - 프로젝트 개요 📖

## 📱 프로젝트 소개

Fortune은 74가지의 다양한 운세 서비스를 제공하는 AI 기반 모바일 애플리케이션입니다. 사용자의 개인 정보를 바탕으로 맞춤형 운세를 생성하며, 현대적인 UI/UX와 프리미엄 경험을 제공합니다.

## 🏗️ 아키텍처 개요

### 기술 스택
- **Frontend**: Flutter 3.5.3+ (Cross-platform)
- **Backend**: Supabase (PostgreSQL + Edge Functions)
- **AI**: OpenAI GPT-4 / Google Genkit
- **State Management**: Riverpod 2.6.1
- **Navigation**: GoRouter 15.1.2
- **Storage**: Hive (Local) + Supabase (Cloud)

### 주요 모듈 구조
```
lib/
├── core/                    # 핵심 공통 기능
├── features/               # 기능별 모듈
│   ├── fortune/           # 운세 서비스 (메인)
│   ├── auth/              # 사용자 인증
│   ├── payment/           # 결제 시스템
│   └── profile/           # 프로필 관리
├── presentation/          # UI 공통 컴포넌트
└── shared/               # 공유 리소스
```

## ✨ 주요 기능

### 🔮 운세 서비스 (74가지)
- **일반 운세**: 오늘/내일/주간/월간/연간
- **전문 운세**: 사주/타로/토정비결/별자리/MBTI
- **생활 운세**: 연애/재물/건강/취업/사업 등
- **AI 맞춤형**: 개인 정보 기반 개인화

### 👤 사용자 시스템
- **소셜 로그인**: 카카오/네이버/구글/애플
- **프로필 관리**: 생년월일/시간/성별/MBTI
- **토큰 시스템**: 인앱 구매 기반 과금

### 💳 결제 시스템
- **iOS**: StoreKit In-App Purchase
- **Android**: Google Play Billing  
- **Web**: Stripe/Toss Payments
- **토큰 패키지**: 1,000원 ~ 99,000원

### 🎨 UI/UX 시스템
- **디자인 시스템**: Toss 기반 모던 디자인
- **다크모드**: 완전 지원
- **글래스모피즘**: 현대적 시각 효과
- **애니메이션**: 부드러운 전환 효과

## 📊 데이터 흐름

### 운세 생성 플로우
1. 사용자 입력 (생년월일, 질문 등)
2. Supabase Edge Function 호출
3. OpenAI/Genkit을 통한 AI 운세 생성
4. 결과 캐싱 및 사용자 히스토리 저장
5. UI에 운세 결과 표시

### 인증 플로우  
1. 소셜 로그인 (OAuth)
2. Supabase Auth를 통한 사용자 생성/로그인
3. 프로필 정보 수집 및 저장
4. JWT 토큰 기반 세션 관리

## 🔧 개발 환경

### 필수 도구
- Flutter SDK 3.5.3+
- Xcode 14+ (iOS)
- Android Studio (Android)
- VS Code (권장 에디터)

### 환경 설정
```bash
# 의존성 설치
flutter pub get
cd ios && pod install

# 개발 서버 실행
flutter run --dart-define-from-file=.env.development

# 빌드
flutter build web --dart-define-from-file=.env.production
```

## 📁 파일 구조

### 주요 디렉토리
```
fortune/
├── lib/
│   ├── core/                    # 핵심 유틸리티
│   │   ├── config/             # 앱 설정
│   │   ├── constants/          # 상수 정의
│   │   ├── theme/              # 테마 시스템
│   │   └── utils/              # 유틸리티 함수
│   │
│   ├── features/               # 기능 모듈
│   │   ├── fortune/           # 운세 기능
│   │   │   ├── domain/        # 비즈니스 로직
│   │   │   ├── data/          # 데이터 레이어
│   │   │   └── presentation/  # UI 레이어
│   │   │
│   │   ├── auth/              # 인증 시스템
│   │   ├── payment/           # 결제 시스템
│   │   └── profile/           # 프로필 관리
│   │
│   ├── presentation/          # 공통 UI
│   │   ├── screens/           # 화면들
│   │   ├── widgets/           # 재사용 위젯
│   │   └── providers/         # 상태 관리
│   │
│   └── shared/                # 공유 리소스
│       ├── components/        # 공통 컴포넌트
│       └── glassmorphism/     # 글래스 효과
│
├── assets/                    # 정적 리소스
│   ├── images/               # 이미지
│   ├── fonts/                # 폰트
│   └── icons/                # 아이콘
│
├── docs/                     # 문서
├── test/                     # 테스트 코드
└── integration_test/         # 통합 테스트
```

### 중요 설정 파일
- `pubspec.yaml`: 패키지 의존성
- `.env`: 환경 변수 (개발/프로덕션)
- `analysis_options.yaml`: 코드 분석 규칙

## 🚀 배포 전략

### 플랫폼별 배포
- **iOS**: App Store Connect
- **Android**: Google Play Console  
- **Web**: Firebase Hosting

### CI/CD 파이프라인
1. GitHub Actions 자동 빌드
2. 자동 테스트 실행
3. 코드 품질 검사
4. 플랫폼별 배포 패키지 생성

## 📊 성능 지표

### 목표 성능
- **앱 시작 시간**: < 3초
- **운세 생성 시간**: < 5초  
- **API 응답 시간**: < 2초
- **메모리 사용량**: < 150MB

### 최적화 전략
- 이미지 레이지 로딩
- API 응답 캐싱
- 번들 크기 최적화
- Native 성능 활용

## 🔐 보안 고려사항

### 데이터 보호
- 모든 API 키 환경변수 관리
- HTTPS 강제 사용
- Supabase RLS 권한 제어
- 사용자 데이터 암호화

### 인증 보안
- JWT 토큰 만료 관리
- OAuth 2.0 표준 준수
- 디바이스별 세션 관리

## 📈 모니터링

### 에러 추적
- **Sentry**: 실시간 에러 모니터링
- **Firebase Crashlytics**: 크래시 분석

### 사용자 분석  
- **Firebase Analytics**: 사용 패턴 분석
- **커스텀 이벤트**: 운세 생성, 결제 등

## 🤝 개발 가이드라인

### 코드 스타일
- Effective Dart 가이드라인 준수
- `flutter analyze` 통과 필수
- `dart format` 자동 포맷팅

### Git 워크플로우
```bash
# Feature 브랜치 생성
git checkout -b feature/amazing-feature

# 작업 완료 후 PR 생성
git push origin feature/amazing-feature
```

### 테스트 전략
- **Unit Test**: 비즈니스 로직
- **Widget Test**: UI 컴포넌트  
- **Integration Test**: E2E 시나리오

## 📚 관련 문서

- [설정 가이드](./SETUP_GUIDE.md)
- [디자인 시스템](./DESIGN_SYSTEM.md)
- [API 문서](./API_DOCUMENTATION.md)
- [배포 가이드](./PRODUCTION_DEPLOYMENT_GUIDE.md)
- [테스트 가이드](./TESTING_GUIDE.md)

---

**업데이트**: 2024-08-08  
**버전**: 1.0.0