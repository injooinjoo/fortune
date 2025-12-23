# Fortune Flutter App - 전체 파일 의존성 맵

> 📅 생성일: 2025년 1월 6일
> 🔍 분석 대상: `lib/` 폴더 전체 Dart 파일

---

## 📊 프로젝트 구조 개요

### 통계
- **총 Dart 파일 수**: 661개
- **의존성이 있는 파일**: 511개
- **다른 곳에서 import되는 파일**: 393개
- **완전 고아 파일** (import 없음): 39개
- **리프 파일** (아무도 import 안함): 247개

### 카테고리별 분류
```
lib/
├── core/              (핵심 시스템 - 80+ 파일)
│   ├── cache/
│   ├── components/
│   ├── config/
│   ├── constants/
│   ├── error/
│   ├── network/
│   ├── services/
│   ├── theme/
│   └── utils/
│
├── features/          (기능별 모듈 - 400+ 파일)
│   ├── admin/
│   ├── fortune/       (가장 큰 feature)
│   ├── health/
│   ├── history/
│   ├── interactive/
│   ├── payment/
│   ├── policy/
│   └── ... (20+ features)
│
├── data/              (데이터 계층 - 50+ 파일)
│   ├── constants/
│   ├── datasources/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── domain/            (도메인 계층 - 30+ 파일)
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
├── presentation/      (프레젠테이션 - 40+ 파일)
│   ├── providers/
│   └── widgets/
│
├── routes/            (라우팅 - 10+ 파일)
│   └── routes/
│
├── screens/           (화면 - 40+ 파일)
│   ├── auth/
│   ├── home/
│   ├── onboarding/
│   ├── profile/
│   └── settings/
│
└── services/          (앱 서비스 - 20+ 파일)
```

---

## 🚀 진입점 (main.dart)

### main.dart가 직접 import하는 파일들

```dart
main.dart
├── firebase_options_secure.dart              (Firebase 설정)
├── core/config/environment.dart               (환경 변수)
├── core/config/feature_flags.dart             (기능 플래그)
├── core/utils/logger.dart                     (로깅)
├── core/utils/secure_storage.dart             (보안 저장소)
├── routes/route_config.dart                   (라우팅 설정) ⭐
├── core/theme/toss_design_system.dart         (디자인 시스템) ⭐
├── services/cache_service.dart                (캐시)
├── presentation/providers/theme_provider.dart (테마 관리)
├── core/utils/url_cleaner_stub.dart          (URL 정리)
├── services/native_features_initializer.dart  (네이티브 기능)
├── services/token_monitor_service.dart        (토큰 모니터링)
├── services/screenshot_detection_service.dart (스크린샷 감지)
├── services/ad_service.dart                   (광고)
├── services/analytics_service.dart            (분석)
├── services/remote_config_service.dart        (원격 설정)
├── presentation/providers/font_size_provider.dart (폰트 크기)
├── core/services/test_auth_service.dart       (테스트 인증)
├── core/services/supabase_connection_service.dart (Supabase)
└── core/utils/route_observer_logger.dart      (라우트 관찰)
```

### 초기화 흐름

1. **환경 설정**: `.env` 파일 로드, 날짜 형식 초기화
2. **Hive 초기화**: 로컬 데이터베이스
3. **Supabase 초기화**: 백엔드 연결 (재시도 로직 포함)
4. **Firebase Remote Config**: 원격 설정
5. **소셜 로그인 SDK**: Kakao, Naver 초기화
6. **Ad Service**: 광고 서비스 (백그라운드)
7. **SharedPreferences**: 로컬 저장소
8. **테스트 모드**: 테스트 계정 자동 로그인 (필요시)
9. **RouteObserver**: 라우트 추적 (디버그 모드)
10. **앱 실행**: `ProviderScope` → `MyApp` → `MaterialApp.router`

---

## 🗺️ 라우팅 시스템

### route_config.dart 구조

```
route_config.dart (라우팅 허브)
├── routes/auth_routes.dart           (인증 라우트)
├── routes/fortune_routes.dart        (운세 라우트 - 9개 카테고리)
└── routes/interactive_routes.dart    (인터랙티브 라우트)
```

### Shell 내부 페이지 (네비게이션 바 있음)

**MainShell로 래핑된 페이지들**:
```
/home                → HomeScreen
/profile             → ProfileScreen
  └── /edit          → ProfileEditPage
/premium             → PremiumScreen
/trend               → TrendPage
/fortune             → FortuneListPage (메인 운세 목록)
/interactive/*       → 인터랙티브 기능들
```

### Shell 외부 페이지 (네비게이션 바 없음)

**독립 실행 페이지들**:
```
인증:
/                    → SplashScreen
/landing             → LandingPage
/signup              → SignupScreen
/auth/callback       → CallbackPage

온보딩:
/onboarding/toss-style → OnboardingPage

설정:
/settings            → SettingsScreen
  ├── /social-accounts    → SocialAccountsScreen
  ├── /phone-management   → PhoneManagementScreen
  └── /notifications      → NotificationSettingsPage

운세 (Full Screen):
/moving              → MovingFortuneTossPage
/traditional-saju    → TraditionalSajuTossPage
/lucky-talisman      → TalismanFortunePage
/biorhythm           → BiorhythmFortunePage
/love                → LoveFortuneMainPage
/blind-date          → BlindDateFortunePage
... (100+ 운세 페이지)

기타:
/subscription        → SubscriptionPage
/token-purchase      → TokenPurchasePageV2
/help                → HelpPage
/privacy-policy      → PrivacyPolicyPage
/terms-of-service    → TermsOfServicePage
```

### fortune_routes.dart - 9개 카테고리

1. **basic_fortune_routes.dart**: 기본 운세 (사주, 타로, 꿈해몽 등)
2. **love_fortune_routes.dart**: 연애/궁합 운세
3. **career_fortune_routes.dart**: 커리어/직업 운세
4. **investment_fortune_routes.dart**: 투자/재테크 운세
5. **personality_fortune_routes.dart**: 성격/심리 운세
6. **special_fortune_routes.dart**: 특수 운세
7. **lucky_fortune_routes.dart**: 행운 아이템 운세
8. **family_fortune_routes.dart**: 가족/관계 운세
9. **health_fortune_routes.dart**: 건강/바이오리듬 운세

---

## 📁 카테고리별 파일 의존성

### Core - 핵심 시스템

#### 🎨 테마 & 디자인 시스템 (가장 중요!)

**`lib/core/theme/toss_design_system.dart`**
- **역할**: 전체 앱의 디자인 시스템 통합 (Toss 디자인 언어)
- **사용처**: **335개 파일**에서 import (프로젝트 전체!)
- **의존성 체인**:
  - `main.dart` → `TossDesignSystem.lightTheme()`/`darkTheme()` 직접 사용
  - 거의 모든 화면/위젯 → 테마 참조

**`lib/core/components/glass_container.dart`**
- **역할**: 글라스모피즘 UI 컨테이너
- **사용처**: **118개 파일** (운세 결과 화면, 카드 UI 등)
- **의존성 체인**: 각 페이지 → glass_container → main.dart

**`lib/core/theme/app_spacing.dart`**
- **역할**: 앱 전체 간격 시스템
- **사용처**: **109개 파일**
- **의존성 체인**: 위젯 → spacing → design_system → main.dart

**`lib/widgets/toss_button.dart`**
- **역할**: Toss 스타일 버튼 컴포넌트
- **사용처**: **100개 파일**
- **의존성 체인**: 페이지 → toss_button → design_system → main.dart

#### 🔧 유틸리티

**`lib/core/utils/logger.dart`**
- **역할**: 중앙 집중식 로깅
- **사용처**: **80개 파일**
- **의존성 체인**: main.dart 직접 import + 서비스들에서 사용

**`lib/core/utils/dark_mode_helper.dart`**
- **역할**: 다크모드 감지 및 색상 변환
- **사용처**: 52개 파일
- **의존성 체인**: 위젯 → dark_mode_helper → main.dart

**`lib/core/utils/haptic_utils.dart`**
- **역할**: 햅틱 피드백
- **사용처**: 42개 파일
- **의존성 체인**: 버튼/인터랙션 → haptic → main.dart

#### 🌐 네트워크 & API

**`lib/core/network/api_client.dart`**
- **역할**: HTTP 클라이언트 (Dio 기반)
- **사용처**: 15개 서비스 파일
- **의존성 체인**:
  - fortune_api_service → api_client → main.dart (간접)

**`lib/core/network/auth_api_client.dart`**
- **역할**: 인증이 필요한 API 클라이언트
- **사용처**: 10개 파일
- **의존성 체인**: auth 관련 서비스 → auth_api_client

#### 📦 캐시 & 저장소

**`lib/core/cache/cache_service.dart`**
- **역할**: Hive 기반 캐시 서비스
- **사용처**: main.dart + 8개 서비스
- **의존성 체인**: main.dart → cache_service (직접)

**`lib/core/utils/secure_storage.dart`**
- **역할**: 보안 저장소 (flutter_secure_storage)
- **사용처**: main.dart + 인증 서비스
- **의존성 체인**: main.dart → secure_storage (직접)

---

### Features - 기능별 모듈

#### 🔮 Fortune (운세 - 가장 큰 Feature)

**주요 페이지들과 의존성**:

1. **`lib/features/fortune/presentation/pages/fortune_list_page.dart`**
   - **역할**: 운세 목록 메인 페이지
   - **사용처**: route_config.dart → `/fortune` 경로
   - **의존성 체인**:
     - route_config → fortune_list_page → main.dart

2. **`lib/features/fortune/presentation/pages/saju_page.dart`**
   - **역할**: 사주 운세
   - **사용처**: basic_fortune_routes.dart
   - **의존성 체인**:
     - route_config → fortune_routes → basic_fortune_routes → saju_page

3. **`lib/features/fortune/presentation/pages/tarot_enhanced_page.dart`**
   - **역할**: 타로 운세 (향상된 버전)
   - **사용처**: basic_fortune_routes.dart
   - **의존성 체인**:
     - route_config → fortune_routes → basic_fortune_routes → tarot_enhanced_page

4. **`lib/features/fortune/presentation/pages/dream_fortune_toss_page.dart`**
   - **역할**: 꿈해몽 (Toss 스타일)
   - **사용처**: basic_fortune_routes.dart
   - **의존성 체인**:
     - route_config → fortune_routes → basic_fortune_routes → dream_fortune_toss_page

**운세 위젯 컴포넌트** (100+ 파일):
```
lib/features/fortune/presentation/widgets/
├── fortune_card.dart              (운세 카드 - 50+ 곳에서 사용)
├── fortune_loading_skeleton.dart  (로딩 스켈레톤 - 40+ 곳에서 사용)
├── tarot_card_widget.dart         (타로 카드 - 20+ 곳에서 사용)
├── lucky_items_bottom_sheet.dart  (행운 아이템 - 15+ 곳에서 사용)
└── ... (100+ 위젯)
```

**운세 서비스**:
```
lib/data/services/
├── fortune_api_service.dart           (운세 API - 모든 운세 페이지에서 사용)
├── fortune_api_service_edge_functions.dart (Edge Functions)
└── fortune_batch_service.dart         (배치 운세)

의존성 체인:
페이지 → fortune_api_service → api_client → main.dart (간접)
```

#### 🏥 Admin (관리자)

**`lib/features/admin/pages/celebrity_crawling_page.dart`**
- **역할**: 연예인 데이터 크롤링
- **사용처**: route_config.dart → `/admin/celebrity-crawling`
- **의존성 체인**: route_config → admin_page → main.dart

**`lib/features/admin/presentation/providers/admin_stats_provider.dart`**
- **역할**: 관리자 통계 상태 관리
- **사용처**: 관리자 페이지들
- **의존성 체인**: admin_page → admin_stats_provider

#### 💰 Payment (결제)

**`lib/features/payment/presentation/pages/token_purchase_page_v2.dart`**
- **역할**: 토큰 구매 페이지 (v2)
- **사용처**: route_config.dart → `/token-purchase`
- **의존성 체인**: route_config → token_purchase_page → main.dart

#### 📜 Policy (정책)

**`lib/features/policy/presentation/pages/privacy_policy_page.dart`**
- **역할**: 개인정보처리방침
- **사용처**: route_config.dart → `/privacy-policy`
- **의존성 체인**: route_config → privacy_policy_page → main.dart

---

### Services - 앱 서비스

#### 🔐 인증 & 보안

**`lib/services/auth_service.dart`**
- **역할**: 인증 서비스 (소셜 로그인)
- **사용처**: 인증 화면들, main.dart (간접)
- **의존성 체인**: auth screens → auth_service → main.dart

**`lib/core/services/test_auth_service.dart`**
- **역할**: 테스트 계정 자동 로그인
- **사용처**: main.dart (직접)
- **의존성 체인**: main.dart → test_auth_service

#### 📊 분석 & 모니터링

**`lib/services/analytics_service.dart`**
- **역할**: Firebase Analytics
- **사용처**: main.dart (직접) + 주요 페이지들
- **의존성 체인**: main.dart → analytics_service

**`lib/services/token_monitor_service.dart`**
- **역할**: 토큰 사용량 모니터링
- **사용처**: main.dart (직접)
- **의존성 체인**: main.dart → token_monitor_service

#### 🎯 광고 & 수익화

**`lib/services/ad_service.dart`**
- **역할**: AdMob 광고
- **사용처**: main.dart (직접) + 일부 페이지
- **의존성 체인**: main.dart → ad_service

---

### Data - 데이터 계층

#### 📚 데이터베이스 & 상수

**`lib/data/constants/celebrity_database.dart`**
- **역할**: 연예인 데이터베이스
- **사용처**: celebrity_fortune_page 등
- **의존성 체인**: celebrity_page → celebrity_database

**`lib/data/dream_symbols_database.dart`**
- **역할**: 꿈 상징 데이터베이스
- **사용처**: dream_fortune_page
- **의존성 체인**: dream_page → dream_symbols_database

#### 📦 모델

**`lib/data/models/user_profile.dart`**
- **역할**: 사용자 프로필 모델
- **사용처**: 15개 파일 (프로필, 온보딩, 인증 등)
- **의존성 체인**:
  - profile_screen → user_profile → route_config → main.dart

**`lib/data/models/fortune_response_model.dart`**
- **역할**: 운세 응답 모델
- **사용처**: 모든 운세 서비스
- **의존성 체인**:
  - fortune_api_service → fortune_response_model

---

### Domain - 도메인 계층

#### 🎯 엔티티

**`lib/domain/entities/fortune.dart`**
- **역할**: 운세 엔티티
- **사용처**: 운세 관련 서비스들
- **의존성 체인**: services → fortune entity

**`lib/domain/entities/user_profile.dart`**
- **역할**: 사용자 프로필 엔티티
- **사용처**: 프로필 관련 서비스
- **의존성 체인**: services → user_profile entity

#### 🔄 Use Cases

**`lib/domain/usecases/todo/get_todos_usecase.dart`**
- **역할**: Todo 조회 유즈케이스
- **사용처**: todo 관련 페이지
- **의존성 체인**: todo_page → get_todos_usecase

---

### Presentation - 프레젠테이션

#### 🎨 Providers (상태 관리)

**`lib/presentation/providers/theme_provider.dart`**
- **역할**: 테마 상태 관리 (ThemeModeNotifier)
- **사용처**: main.dart (직접)
- **의존성 체인**: main.dart → theme_provider (직접 watch)

**`lib/presentation/providers/font_size_provider.dart`**
- **역할**: 폰트 크기 상태 관리
- **사용처**: main.dart (직접) + 설정 화면
- **의존성 체인**: main.dart → font_size_provider

#### 🧩 위젯

**`lib/presentation/widgets/animated_fortune_text.dart`**
- **역할**: 애니메이션 운세 텍스트
- **사용처**: 20+ 운세 페이지
- **의존성 체인**: fortune_pages → animated_fortune_text

---

### Screens - 화면

#### 🏠 메인 화면들

**`lib/screens/splash_screen.dart`**
- **역할**: 스플래시 화면
- **사용처**: auth_routes.dart → `/` 경로
- **의존성 체인**: route_config → auth_routes → splash_screen → main.dart

**`lib/screens/landing_page.dart`**
- **역할**: 랜딩 페이지 (미로그인)
- **사용처**: auth_routes.dart → `/landing`
- **의존성 체인**: route_config → auth_routes → landing_page → main.dart

**`lib/screens/home/home_screen.dart`**
- **역할**: 홈 화면 (로그인 후)
- **사용처**: route_config.dart → `/home` (MainShell 내부)
- **의존성 체인**: route_config → home_screen → MainShell → main.dart

#### 👤 프로필

**`lib/screens/profile/profile_screen.dart`**
- **역할**: 프로필 화면
- **사용처**: route_config.dart → `/profile`
- **의존성 체인**: route_config → profile_screen → MainShell → main.dart

**`lib/screens/profile/profile_edit_page.dart`**
- **역할**: 프로필 수정
- **사용처**: route_config.dart → `/profile/edit`
- **의존성 체인**: route_config → profile_edit_page → main.dart

#### 🔐 인증

**`lib/screens/auth/signup_screen.dart`**
- **역할**: 회원가입
- **사용처**: auth_routes.dart → `/signup`
- **의존성 체인**: route_config → auth_routes → signup_screen → main.dart

#### 🎓 온보딩

**`lib/screens/onboarding/onboarding_page.dart`**
- **역할**: 온보딩 플로우
- **사용처**: route_config.dart → `/onboarding/toss-style`
- **의존성 체인**: route_config → onboarding_page → main.dart

---

## 🔗 주요 의존성 체인 예시

### 예시 1: 사주 운세 전체 흐름

```
사용자가 /saju 접근
  ↓
main.dart (앱 시작)
  ├→ route_config.dart (라우터 설정)
  │   └→ fortune_routes.dart (운세 라우트 그룹)
  │       └→ basic_fortune_routes.dart (기본 운세)
  │           └→ saju_page.dart (사주 페이지)
  │               ├→ toss_design_system.dart (디자인)
  │               ├→ fortune_api_service.dart (API 호출)
  │               │   └→ api_client.dart (HTTP)
  │               ├→ saju_provider.dart (상태 관리)
  │               └→ fortune_card.dart (UI 컴포넌트)
  │                   └→ glass_container.dart
  └→ presentation/providers/theme_provider.dart (테마)
```

### 예시 2: 타로 카드 선택 → 결과

```
타로 카드 위젯
  ↓
tarot_enhanced_page.dart
  ├→ enhanced_tarot_card_selection.dart (카드 선택 위젯)
  │   ├→ flip_card_widget.dart (뒤집기 애니메이션)
  │   └→ tarot_card_model.dart (카드 데이터)
  ├→ enhanced_tarot_card_detail.dart (카드 상세)
  ├→ tarot_storytelling_provider.dart (스토리텔링 상태)
  └→ fortune_api_service.dart (타로 해석 API)
      └→ api_client.dart
          └→ core/network/cache_interceptor.dart (캐싱)
```

### 예시 3: 테마 변경 흐름

```
설정 화면에서 다크모드 토글
  ↓
settings_screen.dart
  ↓
presentation/providers/theme_provider.dart
  ├→ ThemeModeNotifier.toggleTheme() 호출
  ├→ SharedPreferences에 저장
  └→ state 변경
      ↓
main.dart의 MyApp (Consumer)
  ├→ themeModeProvider.watch()로 감지
  └→ MaterialApp.router 재빌드
      ├→ theme: TossDesignSystem.lightTheme()
      └→ darkTheme: TossDesignSystem.darkTheme()
```

### 예시 4: 운세 API 호출 체인

```
운세 페이지 (예: blind_date_fortune_page.dart)
  ↓
fortune_api_decision_service.dart (API 결정)
  ├→ fortune_api_service_edge_functions.dart (Edge Function 우선)
  │   └→ core/network/auth_api_client.dart
  │       ├→ token_refresh_interceptor.dart (토큰 갱신)
  │       └→ cache_interceptor.dart (캐싱)
  └→ fortune_api_service.dart (기본 API 폴백)
      └→ core/network/api_client.dart
```

### 예시 5: 인증 → 홈 화면

```
사용자가 Google 로그인 버튼 클릭
  ↓
signup_screen.dart
  ↓
services/auth_service.dart
  ├→ signInWithGoogle() 호출
  ├→ Supabase auth 처리
  └→ 프로필 완성도 체크
      ├→ core/utils/profile_validation.dart
      └→ 결과에 따라 라우팅:
          ├→ 미완성: /onboarding/toss-style
          └→ 완성: /home
              ↓
              route_config.dart
                └→ MainShell (네비게이션 바)
                    └→ home_screen.dart
```

---

## 📈 사용되지 않는 파일

### 완전 고아 파일 (39개)

**아무 곳에서도 import하지 않고, 다른 곳에서도 import되지 않는 파일**:

#### Core
- `lib/core/error/exceptions.dart` (중복, core/errors/exceptions.dart 사용)
- `lib/core/error/failures.dart` (미사용)

#### Features - Fortune (구형/테스트)
- `lib/features/fortune/presentation/pages/career_fortune_page.dart` (폐기, career_coaching_input_page 사용)
- `lib/features/fortune/presentation/pages/face_reading_fortune_page.dart` (미완성 기능)
- `lib/features/fortune/presentation/pages/palmistry_fortune_page.dart` (미완성 기능)
- `lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart` (삭제됨)
- `lib/features/fortune/presentation/pages/base_fortune_page.dart` (base_fortune_page_v2 사용)
- `lib/features/fortune/presentation/pages/celebrity_fortune_page_v2.dart` (enhanced 버전 사용)
- `lib/features/fortune/presentation/pages/saju_psychology_fortune_page.dart` (폐기)

#### Features - Admin
- `lib/features/admin/pages/admin_dashboard_page.dart` (미완성)
- `lib/features/admin/pages/admin_logs_page.dart` (미완성)
- `lib/features/admin/pages/admin_redis_stats_page.dart` (미완성)
- `lib/features/admin/pages/admin_stats_page.dart` (미완성)
- `lib/features/admin/pages/admin_token_usage_page.dart` (미완성)
- `lib/features/admin/pages/admin_users_page.dart` (미완성)

#### Data Models (구형)
- `lib/data/models/celebrity_old.dart` (새 celebrity.dart 사용)
- `lib/data/models/celebrity_saju.dart` (미사용)

#### Screens (테스트/임시)
- `lib/screens/subscription/subscription_test_page.dart` (테스트용)

#### Shared (미사용 위젯)
- `lib/shared/widgets/fortune_subscription_card.dart` (미사용)

### 리프 파일 (247개 - 아무도 import 안함)

**다른 파일들을 import하지만, 자신은 아무도 import하지 않는 파일**:

#### 주요 페이지들 (정상 - 라우트로만 접근)
대부분 정상적인 엔드포인트 페이지들입니다:
- `lib/features/fortune/presentation/pages/*.dart` (100+ 운세 페이지들)
- `lib/screens/auth/*.dart` (인증 화면들)
- `lib/screens/settings/*.dart` (설정 화면들)
- `lib/features/*/presentation/pages/*.dart` (각 feature의 페이지들)

#### 위젯 컴포넌트 (사용 안됨 - 정리 필요)
- `lib/features/fortune/presentation/widgets/old_*.dart` (구형 위젯들)
- `lib/shared/widgets/unused_*.dart` (미사용 위젯들)

#### Provider (고립됨 - 정리 필요)
- `lib/features/fortune/presentation/providers/old_*.dart` (구형 provider)

---

## 🔄 순환 의존성

### 발견된 순환 의존성 없음 ✅

현재 프로젝트는 계층형 아키텍처를 잘 따르고 있어 순환 의존성이 발견되지 않았습니다:

```
main.dart (최상위)
  ↓
routes/ (라우팅)
  ↓
screens/ & features/ (페이지)
  ↓
presentation/ (위젯, providers)
  ↓
domain/ (유즈케이스, 엔티티)
  ↓
data/ (모델, 서비스)
  ↓
core/ (유틸, 테마, 네트워크)
```

**아키텍처 원칙 준수**:
- ✅ 상위 레이어만 하위 레이어 의존
- ✅ core는 아무것도 의존하지 않음 (순수 유틸리티)
- ✅ domain은 data/presentation에 의존하지 않음
- ✅ data는 domain 엔티티만 참조

---

## 🎯 최적화 권장사항

### 1. 미사용 파일 정리
- **39개 완전 고아 파일** 삭제 고려
- **구형 버전** (_old, _v1, _v2) 파일 정리
- **미완성 기능** 주석 처리 또는 제거

### 2. 중복 제거
- `lib/core/error/` vs `lib/core/errors/` 통합
- 같은 기능의 다른 버전 통합 (예: celebrity_fortune_page_v2 → enhanced)

### 3. 리프 위젯 검토
- 247개 리프 파일 중 실제 사용 안되는 위젯 파악
- 정말 필요한 위젯인지 검증

### 4. 문서화
- 주요 의존성 체인 문서화
- 각 feature별 README 작성
- 아키텍처 다이어그램 생성

---

## 📚 참고 자료

### 프로젝트 문서
- [프로젝트 개요](../getting-started/PROJECT_OVERVIEW.md)
- [설정 가이드](../getting-started/SETUP_GUIDE.md)
- [Toss 디자인 시스템](../design/TOSS_DESIGN_SYSTEM.md)

### 관련 문서
- [라우팅 설정](../../lib/routes/README.md)
- [기능 플래그](../../lib/core/config/feature_flags.dart)
- [Claude 자동화](./CLAUDE_AUTOMATION.md)

---

## 🔍 파일 검색 팁

### 특정 파일 찾기
```bash
# 파일명으로 검색
find lib -name "*fortune*.dart"

# 내용으로 검색 (import 추적)
grep -r "import.*toss_design_system" lib/

# 미사용 파일 찾기 (아무도 import 안함)
./scripts/find_unused_files.sh
```

### 의존성 추적
```bash
# 특정 파일을 사용하는 곳 찾기
grep -r "fortune_api_service.dart" lib/

# 특정 파일이 사용하는 것 찾기
grep "^import" lib/features/fortune/presentation/pages/saju_page.dart
```

---

**마지막 업데이트**: 2025-01-06
**분석 도구**: Claude Code + Custom Analysis Scripts
**총 분석 파일**: 661개
