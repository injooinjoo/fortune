# OpenAI Codex 문법 수정 요청 프롬프트

**Flutter/Dart 프로젝트 문법 에러 수정 요청**

당신은 Flutter/Dart 전문 개발자입니다. 다음 36개 파일의 문법 에러만을 수정해주세요.

## 🚨 중요 제약사항
- **오직 문법 에러만 수정** (세미콜론, 괄호, 콤마 누락 등)
- **로직, 기능, 주석 변경 절대 금지**
- **기존 코드 구조와 의미 보존**
- **Dart/Flutter 문법 규칙만 준수**

## 📁 수정 대상 파일 (36개, 4,379 errors)

### 🔥 최우선 수정 (가장 많은 에러)
```
lib/routes/app_router.dart (2,680 errors) - 앱 라우팅 핵심 파일
lib/screens/profile/profile_screen.dart (543 errors) - 프로필 화면
lib/screens/onboarding/onboarding_page_v2.dart (186 errors) - 온보딩
```

### 📋 전체 파일 목록
```
lib/features/fortune/presentation/pages/fortune_list_page.dart
lib/features/fortune/presentation/pages/love_fortune_page.dart
lib/features/fortune/presentation/pages/lucky_color_fortune_page.dart
lib/features/fortune/presentation/pages/lucky_food_fortune_page.dart
lib/features/fortune/presentation/pages/lucky_number_fortune_page.dart
lib/features/fortune/presentation/pages/lucky_place_fortune_page.dart
lib/features/fortune/presentation/pages/mbti_fortune_page.dart
lib/features/fortune/presentation/pages/palmistry_fortune_page.dart
lib/features/fortune/presentation/pages/physiognomy_enhanced_page.dart
lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart
lib/features/fortune/presentation/pages/physiognomy_input_page.dart
lib/features/fortune/presentation/pages/physiognomy_result_page.dart
lib/features/fortune/presentation/pages/sports_fortune_page.dart
lib/features/fortune/presentation/pages/time_based_fortune_page.dart
lib/features/fortune/presentation/pages/tojeong_fortune_page.dart
lib/features/fortune/presentation/pages/traditional_saju_fortune_page.dart
lib/features/fortune/presentation/pages/wealth_fortune_page.dart
lib/features/fortune/presentation/pages/zodiac_animal_fortune_page.dart
lib/features/fortune/presentation/pages/zodiac_fortune_page.dart
lib/features/fortune/presentation/widgets/career_fortune_selector.dart
lib/routes/app_router.dart
lib/screens/home/home_screen.dart
lib/screens/landing_page.dart
lib/screens/onboarding/enhanced_onboarding_flow.dart
lib/screens/onboarding/onboarding_flow_page.dart
lib/screens/onboarding/onboarding_page_v2.dart
lib/screens/onboarding/onboarding_page.dart
lib/screens/premium/premium_screen.dart
lib/screens/profile/profile_edit_page.dart
lib/screens/profile/profile_screen.dart
lib/screens/settings/phone_management_screen.dart
lib/screens/settings/settings_screen.dart
lib/screens/settings/social_accounts_screen.dart
lib/screens/splash_screen.dart
lib/services/cache_service.dart
lib/services/native_features_initializer.dart
```

## 🛠️ 수정해야 할 문법 에러 유형
- 누락된 세미콜론 (`;`)
- 닫히지 않은 괄호 (`{}`, `[]`, `()`)
- 누락된 콤마 (`,`)
- 잘못된 따옴표 사용
- 괄호 매칭 오류
- 기본 Dart 언어 문법 위반

## 📝 작업 방식
1. 각 파일을 읽고 문법 에러만 식별
2. 최소한의 변경으로 문법 수정
3. 기존 코드 로직과 기능 보존
4. Flutter/Dart 문법 규칙 준수

## ⚠️ 절대 하지 말 것
- 기능 추가나 로직 변경
- 주석 추가나 코드 설명
- 변수명이나 함수명 변경  
- import 문 추가나 변경
- 코드 리팩토링이나 최적화

**오직 문법 에러만 수정하여 Flutter 빌드가 성공하도록 만들어주세요.**