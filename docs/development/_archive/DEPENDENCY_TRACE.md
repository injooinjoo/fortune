# Fortune Flutter - 전체 파일 연결 경로 (656개)

## 구조 요약

```
main.dart (진입점)
├─ Level 1: 21개 핵심 파일
│  └─ route_config.dart ⭐ (가장 중요)
│     ├─ Level 2: 54개 직접 페이지 + 3개 라우트 그룹
│     │  ├─ auth_routes.dart (인증 라우트)
│     │  ├─ fortune_routes.dart (운세 라우트 - 가장 큼)
│     │  │  └─ Level 3: 9개 카테고리별 라우트
│     │  │     ├─ basic_fortune_routes.dart (50+ 페이지)
│     │  │     ├─ love_fortune_routes.dart (15+ 페이지)
│     │  │     ├─ career_fortune_routes.dart (10+ 페이지)
│     │  │     ├─ lucky_item_routes.dart (8+ 페이지)
│     │  │     ├─ traditional_fortune_routes.dart (12+ 페이지)
│     │  │     ├─ health_sports_routes.dart (5+ 페이지)
│     │  │     ├─ personality_routes.dart (8+ 페이지)
│     │  │     ├─ time_based_routes.dart (6+ 페이지)
│     │  │     └─ special_fortune_routes.dart (10+ 페이지)
│     │  └─ interactive_routes.dart (인터랙티브 라우트)
│     └─ 각 페이지들이 위젯/서비스/모델 import
│        └─ Level 4-6: 위젯(300+), 서비스(60+), 모델(60+)
└─ toss_design_system.dart (모든 화면에서 사용)
```

## 연결 통계

- **Level 0 (main.dart)**: 1개
- **Level 1 (main 직접 import)**: 21개
- **Level 2 (route_config 직접 import)**: 54개
- **Level 3 (카테고리별 라우트)**: 9개
- **Level 4+ (페이지/위젯/서비스)**: 약 570개

**총합**: 656개 파일

---

## 상세 연결 경로

### Level 0: main.dart

```
0417 lib/main.dart
```

### Level 1: main.dart 직접 import (21개)

```
main.dart
├── 0416 lib/firebase_options_secure.dart
├── 0014 lib/core/config/environment.dart
├── 0015 lib/core/config/feature_flags.dart
├── 0066 lib/core/utils/logger.dart
├── 0072 lib/core/utils/secure_storage.dart
├── 0509 lib/routes/route_config.dart ⭐
├── 0057 lib/core/theme/toss_design_system.dart ⭐
├── 0542 lib/services/cache_service.dart
├── 0447 lib/presentation/providers/theme_provider.dart
├── 0075 lib/core/utils/url_cleaner_stub.dart
├── 0551 lib/services/native_features_initializer.dart
├── 0568 lib/services/token_monitor_service.dart
├── 0560 lib/services/screenshot_detection_service.dart
├── 0539 lib/services/ad_service.dart
├── 0540 lib/services/analytics_service.dart
├── 0558 lib/services/remote_config_service.dart
├── 0434 lib/presentation/providers/font_size_provider.dart
├── 0047 lib/core/services/test_auth_service.dart
├── 0045 lib/core/services/supabase_connection_service.dart
└── 0071 lib/core/utils/route_observer_logger.dart
```

### Level 2: route_config.dart 직접 import (54개)

```
route_config.dart
├── screens/ (주요 화면들)
│   ├── 0535 lib/screens/splash_screen.dart
│   ├── 0526 lib/screens/landing_page.dart
│   ├── 0524 lib/screens/auth/signup_screen.dart
│   ├── 0523 lib/screens/auth/callback_page.dart
│   ├── 0525 lib/screens/home/home_screen.dart
│   ├── 0531 lib/screens/profile/profile_screen.dart
│   ├── 0530 lib/screens/profile/profile_edit_page.dart
│   ├── 0527 lib/screens/onboarding/onboarding_page.dart
│   ├── 0529 lib/screens/premium/premium_screen.dart
│   ├── 0533 lib/screens/settings/settings_screen.dart
│   ├── 0534 lib/screens/settings/social_accounts_screen.dart
│   ├── 0532 lib/screens/settings/phone_management_screen.dart
│   └── 0536 lib/screens/subscription/subscription_page.dart
│
├── features/ (기능별 페이지들)
│   ├── 0181 lib/features/fortune/presentation/pages/fortune_list_page.dart ⭐
│   ├── 0155 lib/features/fortune/presentation/pages/blind_date_fortune_page.dart
│   ├── 0161 lib/features/fortune/presentation/pages/career_coaching_input_page.dart
│   ├── 0165 lib/features/fortune/presentation/pages/celebrity_fortune_enhanced_page.dart
│   ├── 0163 lib/features/fortune/presentation/pages/compatibility_page.dart
│   ├── 0178 lib/features/fortune/presentation/pages/family_fortune_unified_page.dart
│   ├── 0185 lib/features/fortune/presentation/pages/investment_fortune_enhanced_page.dart
│   ├── 0186 lib/features/fortune/presentation/pages/love/love_fortune_main_page.dart
│   ├── 0202 lib/features/fortune/presentation/pages/moving_fortune_toss_page.dart
│   ├── 0218 lib/features/fortune/presentation/pages/talisman_fortune_page.dart
│   ├── 0355 lib/features/health/presentation/pages/health_fortune_toss_page.dart
│   ├── 0361 lib/features/history/presentation/pages/fortune_history_page.dart
│   ├── 0369 lib/features/interactive/presentation/pages/fortune_cookie_page.dart
│   ├── 0386 lib/features/payment/presentation/pages/token_purchase_page_v2.dart
│   ├── 0415 lib/features/trend/presentation/pages/trend_page.dart
│   └── ... (더 많은 페이지)
│
├── 라우트 그룹들
│   ├── 0510 lib/routes/routes/auth_routes.dart
│   ├── 0511 lib/routes/routes/fortune_routes.dart ⭐ (가장 큼)
│   └── 0521 lib/routes/routes/interactive_routes.dart
│
├── shared/
│   └── 0577 lib/shared/layouts/main_shell.dart (네비게이션 래퍼)
│
└── utils/
    ├── 0068 lib/core/utils/page_transitions.dart
    └── 0070 lib/core/utils/profile_validation.dart
```

### Level 3: fortune_routes.dart → 9개 카테고리 (120+ 페이지)

```
fortune_routes.dart
├── 0512 lib/routes/routes/fortune_routes/basic_fortune_routes.dart (50+ 페이지)
│   ├── 0211 lib/features/fortune/presentation/pages/saju_page.dart
│   ├── 0217 lib/features/fortune/presentation/pages/saju_toss_page.dart
│   ├── 0224 lib/features/fortune/presentation/pages/tarot_enhanced_page.dart
│   ├── 0168 lib/features/fortune/presentation/pages/dream_fortune_toss_page.dart
│   ├── 0201 lib/features/fortune/presentation/pages/mbti_fortune_page.dart
│   └── ... (약 45개 더)
│
├── 0524 lib/routes/routes/fortune_routes/love_fortune_routes.dart (15+ 페이지)
│   ├── 0186 lib/features/fortune/presentation/pages/love/love_fortune_main_page.dart
│   ├── 0175 lib/features/fortune/presentation/pages/ex_lover_fortune_enhanced_page.dart
│   └── ... (약 13개 더)
│
├── 0522 lib/routes/routes/fortune_routes/career_fortune_routes.dart (10+ 페이지)
│   ├── 0156 lib/features/fortune/presentation/pages/career_change_fortune_page.dart
│   ├── 0159 lib/features/fortune/presentation/pages/career_future_fortune_page.dart
│   └── ... (약 8개 더)
│
├── 0525 lib/routes/routes/fortune_routes/lucky_item_routes.dart (8+ 페이지)
│   ├── 0196 lib/features/fortune/presentation/pages/lucky_job_fortune_page.dart
│   ├── 0197 lib/features/fortune/presentation/pages/lucky_outfit_fortune_page.dart
│   └── ... (약 6개 더)
│
├── 0529 lib/routes/routes/fortune_routes/traditional_fortune_routes.dart (12+ 페이지)
│   ├── 0233 lib/features/fortune/presentation/pages/traditional_saju_fortune_page.dart
│   ├── 0234 lib/features/fortune/presentation/pages/traditional_saju_toss_page.dart
│   └── ... (약 10개 더)
│
├── 0523 lib/routes/routes/fortune_routes/health_sports_routes.dart (5+ 페이지)
│   ├── 0355 lib/features/health/presentation/pages/health_fortune_toss_page.dart
│   └── ... (약 4개 더)
│
├── 0526 lib/routes/routes/fortune_routes/personality_routes.dart (8+ 페이지)
│   ├── 0207 lib/features/fortune/presentation/pages/personality_dna_page.dart
│   └── ... (약 7개 더)
│
├── 0528 lib/routes/routes/fortune_routes/time_based_routes.dart (6+ 페이지)
│   ├── 0164 lib/features/fortune/presentation/pages/daily_calendar_fortune_page.dart
│   └── ... (약 5개 더)
│
└── 0527 lib/routes/routes/fortune_routes/special_fortune_routes.dart (10+ 페이지)
    ├── 0150 lib/features/fortune/presentation/pages/batch_fortune_page.dart
    └── ... (약 9개 더)
```

### Level 4+: 페이지가 사용하는 위젯/서비스/모델 (400+ 파일)

**예시: saju_page.dart의 의존성**

```
saju_page.dart
├── widgets/ (사주 관련 위젯 20+개)
│   ├── 0315 lib/features/fortune/presentation/widgets/saju_element_chart.dart
│   ├── 0316 lib/features/fortune/presentation/widgets/saju_input_form.dart
│   ├── 0317 lib/features/fortune/presentation/widgets/saju_intro_animation.dart
│   ├── 0318 lib/features/fortune/presentation/widgets/saju_loading_animation.dart
│   └── ...
│
├── services/ (API 서비스)
│   ├── 0099 lib/data/services/fortune_api_service.dart
│   ├── 0100 lib/data/services/fortune_api_service_edge_functions.dart
│   └── 0600 lib/services/saju_calculation_service.dart
│
├── providers/ (상태 관리)
│   └── 0240 lib/features/fortune/presentation/providers/saju_provider.dart
│
├── models/ (데이터 모델)
│   ├── 0092 lib/data/models/fortune_response_model.dart
│   └── 0095 lib/data/models/user_profile.dart
│
└── core/ (공통 컴포넌트)
    ├── 0057 lib/core/theme/toss_design_system.dart
    ├── 0066 lib/core/utils/logger.dart
    └── 0064 lib/core/utils/haptic_utils.dart
```

**모든 페이지가 비슷한 구조로 위젯/서비스/모델을 import**

---

## 주요 허브 파일 (많은 곳에서 사용됨)

### 1. toss_design_system.dart (335곳에서 사용)
```
main.dart
└→ toss_design_system.dart
   └→ 거의 모든 페이지/위젯 (335개)
```

### 2. logger.dart (80곳에서 사용)
```
main.dart
└→ logger.dart
   └→ 주요 서비스들 (80개)
```

### 3. glass_container.dart (118곳에서 사용)
```
main.dart
└→ route_config
   └→ 페이지들
      └→ glass_container (118개)
```

---

## 미사용 파일 (main.dart까지 연결 안됨)

약 40개 파일이 어디서도 import되지 않음:

- 구형 파일들 (_old, _v1)
- 미완성 페이지들 (face_reading, palmistry)
- 실험적 기능들

**예시**:
- lib/features/fortune/presentation/pages/face_reading_fortune_page.dart
- lib/features/fortune/presentation/pages/palmistry_fortune_page.dart
- lib/data/models/celebrity_old.dart (이미 삭제됨)

---

## 결론

### 필요한 파일들 (~400-450개)
- main.dart에서 직접/간접으로 사용됨
- 라우트에 등록된 페이지들
- 실제 사용 중인 위젯/서비스

### 정리 가능한 파일들 (~200-250개)
- 중복 페이지 (비슷한 운세들 통합)
- 미사용 위젯 (아무도 import 안함)
- 구형 버전 파일들
- 실험적/미완성 기능

**현재 656개 → 정리 후 400-450개 권장**
