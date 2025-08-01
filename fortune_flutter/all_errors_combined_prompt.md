# 전체 에러 파일 통합 수정 - SYNTAX ONLY FIX (36 files)

**⚠️ 중요 지침:**
- **문법 에러만** 수정 (세미콜론, 괄호, 콤마 등 누락)
- 로직 변경, 기능 추가, 주석 추가 **절대 금지**
- 모든 수정사항을 적용 전에 반드시 검증
- 기본 Dart/Flutter 문법 준수에만 집중

**수정할 파일 목록 (36개):**

## Fortune Pages (19개)
```
lib/features/fortune/presentation/pages/fortune_list_page.dart (1 error)
lib/features/fortune/presentation/pages/love_fortune_page.dart (6 errors)
lib/features/fortune/presentation/pages/lucky_color_fortune_page.dart (20 errors)
lib/features/fortune/presentation/pages/lucky_food_fortune_page.dart (19 errors)
lib/features/fortune/presentation/pages/lucky_number_fortune_page.dart (2 errors)
lib/features/fortune/presentation/pages/lucky_place_fortune_page.dart (12 errors)
lib/features/fortune/presentation/pages/mbti_fortune_page.dart (3 errors)
lib/features/fortune/presentation/pages/palmistry_fortune_page.dart (13 errors)
lib/features/fortune/presentation/pages/physiognomy_enhanced_page.dart (18 errors)
lib/features/fortune/presentation/pages/physiognomy_fortune_page.dart (55 errors)
lib/features/fortune/presentation/pages/physiognomy_input_page.dart (30 errors)
lib/features/fortune/presentation/pages/physiognomy_result_page.dart (133 errors) ⚠️
lib/features/fortune/presentation/pages/sports_fortune_page.dart (72 errors)
lib/features/fortune/presentation/pages/time_based_fortune_page.dart (101 errors) ⚠️
lib/features/fortune/presentation/pages/tojeong_fortune_page.dart (37 errors)
lib/features/fortune/presentation/pages/traditional_saju_fortune_page.dart (42 errors)
lib/features/fortune/presentation/pages/wealth_fortune_page.dart (75 errors)
lib/features/fortune/presentation/pages/zodiac_animal_fortune_page.dart (53 errors)
lib/features/fortune/presentation/pages/zodiac_fortune_page.dart (42 errors)
```

## Widgets (1개)
```
lib/features/fortune/presentation/widgets/career_fortune_selector.dart (18 errors)
```

## 핵심 시스템 파일 (1개) - 최고 우선순위
```
lib/routes/app_router.dart (2,680 errors) 🚨 가장 중요한 파일
```

## Screen Files (10개)
```
lib/screens/home/home_screen.dart (5 errors)
lib/screens/landing_page.dart (2 errors)
lib/screens/onboarding/enhanced_onboarding_flow.dart (40 errors)
lib/screens/onboarding/onboarding_flow_page.dart (29 errors)
lib/screens/onboarding/onboarding_page_v2.dart (186 errors) ⚠️
lib/screens/onboarding/onboarding_page.dart (19 errors)
lib/screens/premium/premium_screen.dart (13 errors)
lib/screens/profile/profile_edit_page.dart (46 errors)
lib/screens/profile/profile_screen.dart (543 errors) 🚨 두번째로 많은 에러
lib/screens/settings/phone_management_screen.dart (26 errors)
lib/screens/settings/settings_screen.dart (9 errors)
lib/screens/settings/social_accounts_screen.dart (19 errors)
lib/screens/splash_screen.dart (1 error)
```

## Service Files (2개)
```
lib/services/cache_service.dart (7 errors)
lib/services/native_features_initializer.dart (1 error)
```

**작업 순서:**
1. **최우선**: `lib/routes/app_router.dart` (2,680 errors) - 앱 라우팅 핵심 파일
2. **높은 우선순위**: `lib/screens/profile/profile_screen.dart` (543 errors)
3. **중간 우선순위**: 100+ 에러 파일들
4. **낮은 우선순위**: 나머지 파일들

**예상 문법 에러 유형:**
- 누락된 세미콜론 (;)
- 닫히지 않은 괄호/브라켓 ({}, [], ())
- 누락된 콤마 (,)
- 잘못된 따옴표 사용
- 기본 Dart 언어 문법 오류

**주의사항:**
- `app_router.dart`는 앱 전체 라우팅을 담당하므로 극도로 신중하게 수정
- `profile_screen.dart`는 사용자 인터페이스 핵심 부분
- 문법만 수정하고 기능은 절대 건드리지 말 것

**총 36개 파일, 4,379개 에러를 문법만 수정해주세요.**