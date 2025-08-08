# Fortune Flutter App 🔮

AI 기반 종합 운세 서비스 Flutter 애플리케이션

## 📱 개요

Fortune은 74가지의 다양한 운세를 제공하는 프리미엄 모바일 애플리케이션입니다. 사용자의 생년월일과 개인 정보를 바탕으로 AI가 맞춤형 운세를 생성합니다.

## ✨ 주요 기능

### 운세 서비스
- **74가지 운세 타입**: 일일운세부터 전문 사주까지
- **AI 맞춤형 분석**: GPT-4 기반 개인화된 운세 제공
- **배치 운세**: 여러 운세를 한 번에 조회
- **운세 히스토리**: 과거 운세 기록 조회

### 사용자 기능
- **소셜 로그인**: 카카오, 네이버, 구글, 애플
- **프로필 관리**: 생년월일, 시간, 성별 정보 관리
- **토큰 시스템**: 인앱 구매를 통한 토큰 충전
- **오프라인 모드**: 네트워크 없이도 캐시된 운세 조회

### UI/UX
- **글래스모피즘 디자인**: 현대적이고 세련된 UI
- **다크모드 지원**: 시스템 설정 연동
- **반응형 레이아웃**: 다양한 화면 크기 지원
- **애니메이션**: 부드러운 화면 전환 효과

## 🛠 기술 스택

### Frontend
- **Framework**: Flutter 3.5.3+
- **State Management**: Riverpod 2.6.1
- **Navigation**: GoRouter 14.6.2
- **Local Storage**: Hive 2.2.3
- **HTTP Client**: Dio 5.7.0

### Backend Integration
- **Authentication**: Supabase Auth
- **Database**: Supabase (PostgreSQL)
- **Edge Functions**: Deno/TypeScript
- **AI**: OpenAI GPT-4

### 결제
- **iOS**: StoreKit (In-App Purchase)
- **Android**: Google Play Billing
- **토큰 패키지**: 1,000원 ~ 99,000원

## 📂 프로젝트 구조

```
fortune_flutter/
├── lib/
│   ├── core/               # 핵심 기능 (설정, 상수, 유틸)
│   │   ├── config/         # 앱 설정
│   │   ├── constants/      # 상수 정의
│   │   ├── theme/          # 테마 설정
│   │   └── utils/          # 유틸리티 함수
│   ├── data/               # 데이터 레이어
│   │   ├── models/         # 데이터 모델
│   │   ├── repositories/   # 저장소 패턴
│   │   └── services/       # API 서비스
│   ├── features/           # 기능별 모듈
│   │   ├── fortune/        # 운세 기능
│   │   ├── auth/           # 인증 기능
│   │   ├── profile/        # 프로필 관리
│   │   └── payment/        # 결제 기능
│   ├── presentation/       # UI 레이어
│   │   ├── screens/        # 화면
│   │   ├── widgets/        # 재사용 위젯
│   │   └── providers/      # 상태 관리
│   └── main.dart           # 앱 진입점
├── assets/                 # 리소스 파일
│   ├── images/            # 이미지
│   ├── fonts/             # 폰트
│   └── animations/        # Lottie 애니메이션
├── test/                  # 테스트 코드
└── pubspec.yaml           # 의존성 관리
```

## 🚀 시작하기

### 필수 요구사항
- Flutter SDK 3.5.3 이상
- Dart SDK 3.5.3 이상
- Xcode 14+ (iOS 개발)
- Android Studio (Android 개발)

### 설치 및 실행

1. **의존성 설치**
```bash
flutter pub get
```

2. **환경 변수 설정**
```bash
# 개발 환경
cp .env.development.example .env.development

# 프로덕션 환경
cp .env.production.example .env.production
```

3. **iOS 설정**
```bash
cd ios
pod install
cd ..
```

4. **앱 실행**
```bash
# 개발 모드
flutter run --dart-define-from-file=.env.development

# 프로덕션 모드
flutter run --dart-define-from-file=.env.production --release
```

## 📱 빌드

### iOS
```bash
flutter build ios --dart-define-from-file=.env.production --release
```

### Android
```bash
flutter build appbundle --dart-define-from-file=.env.production --release
```

## 🧪 테스트

```bash
# 유닛 테스트
flutter test

# 위젯 테스트
flutter test test/widget_test.dart

# 통합 테스트
flutter test integration_test/
```

## 📋 환경 변수

### 필수 환경 변수
```env
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key

# OAuth Keys
KAKAO_APP_KEY=your_kakao_key
KAKAO_NATIVE_APP_KEY=your_kakao_native_key
NAVER_CLIENT_ID=your_naver_id
NAVER_CLIENT_SECRET=your_naver_secret
GOOGLE_CLIENT_ID=your_google_id
APPLE_SERVICE_ID=your_apple_service_id

# Firebase (Push Notifications)
FIREBASE_API_KEY=your_firebase_key
FIREBASE_APP_ID=your_firebase_app_id
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_PROJECT_ID=your_project_id
```

## 🎯 운세 타입

### 일반 운세 (15종)
- 오늘의 운세, 내일의 운세, 주간 운세
- 월간 운세, 연간 운세, 시간대별 운세
- 종합 운세, 간단 운세, 상세 운세 등

### 전문 운세 (20종)
- 사주, 토정비결, 타로
- 별자리, 띠별 운세, 혈액형
- MBTI, 바이오리듬 등

### 생활 운세 (39종)
- 연애운, 재물운, 건강운
- 취업운, 사업운, 학업운
- 투자운, 부동산운, 여행운 등

[전체 목록: docs/FORTUNE_TYPES_COMPREHENSIVE_GUIDE.md]

## 🔒 보안

- 모든 API 키는 환경 변수로 관리
- 민감한 정보는 절대 하드코딩하지 않음
- Supabase RLS로 데이터 접근 제어
- HTTPS 통신만 사용

## 📝 코드 스타일

- [Effective Dart](https://dart.dev/guides/language/effective-dart) 가이드라인 준수
- `flutter analyze` 통과 필수
- `dart format` 자동 포맷팅 적용

## 🤝 기여 가이드

1. Feature 브랜치 생성 (`feature/amazing-feature`)
2. 변경사항 커밋 (`git commit -m 'Add amazing feature'`)
3. 브랜치 푸시 (`git push origin feature/amazing-feature`)
4. Pull Request 생성

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

## 📚 문서 가이드

### 핵심 문서
- [프로젝트 개요](docs/PROJECT_OVERVIEW.md) - 전체 아키텍처와 기능 소개
- [설정 가이드](docs/SETUP_GUIDE.md) - 개발 환경 구축 및 설정
- [디자인 시스템](docs/DESIGN_SYSTEM.md) - UI/UX 가이드라인

### 개발 가이드  
- [테스트 가이드](docs/TESTING_GUIDE.md) - 테스트 전략과 구현
- [프로덕션 배포](docs/PRODUCTION_DEPLOYMENT_GUIDE.md) - 배포 프로세스
- [네이티브 기능](docs/NATIVE_PLATFORM_FEATURES_GUIDE.md) - 플랫폼별 네이티브 기능

### 특화 가이드
- [Toss UI 통합](docs/TOSS_THEME_UNIFIED_GUIDE.md) - Toss 스타일 적용
- [위젯 아키텍처](docs/WIDGET_ARCHITECTURE_DESIGN.md) - 위젯 설계 원칙
- [UI/UX 확장 로드맵](docs/UI_UX_EXPANSION_ROADMAP.md) - 향후 개선 계획

---

**Fortune Flutter App** - 당신의 운명을 AI가 읽어드립니다 ✨