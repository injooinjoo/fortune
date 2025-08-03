# Flutter 임포트 활성화 체크리스트

## 현재 상태
- ✅ flutter_dotenv 활성화 완료
- ✅ dart:async 활성화 완료  
- ✅ flutter/services.dart 활성화 완료
- ✅ flutter/foundation.dart (kIsWeb) 활성화 완료
- ✅ home_screen.dart 활성화 완료

## main.dart 남은 임포트
```dart
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options_secure.dart';
// import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
// import 'package:flutter_naver_login/flutter_naver_login.dart';
// import 'package:intl/date_symbol_data_local.dart';

// import 'core/config/environment.dart';
// import 'core/config/feature_flags.dart';
// import 'core/utils/logger.dart';
// import 'core/utils/secure_storage.dart';
// import 'routes/minimal_router.dart';
// import 'routes/test_router.dart';
// import 'core/theme/app_theme.dart';
// import 'core/theme/app_theme_extensions.dart';
// import 'services/cache_service.dart';
// import 'presentation/providers/theme_provider.dart';
// import 'core/utils/url_cleaner_stub.dart'
```

## router_config.dart 남은 임포트
```dart
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../screens/profile/profile_edit_page.dart';
// import '../screens/settings/settings_screen.dart';
// import '../screens/settings/social_accounts_screen.dart';
// import '../screens/settings/phone_management_screen.dart';
// import '../screens/onboarding/onboarding_page_v2.dart';
// import '../screens/onboarding/onboarding_flow_page.dart';
// import '../screens/onboarding/enhanced_onboarding_flow.dart';
// import '../screens/premium/premium_screen.dart';

// 기능별 경로들...
// import 'routes/fortune_routes.dart';
// import 'routes/interactive_routes.dart';
```

## 활성화 순서 권장사항

### 1단계: 핵심 설정 파일
1. `core/config/environment.dart` - 환경 설정
2. `core/config/feature_flags.dart` - 기능 플래그
3. `core/utils/logger.dart` - 로깅
4. `core/utils/secure_storage.dart` - 보안 저장소

### 2단계: 테마 및 UI
1. `core/theme/app_theme.dart` - 앱 테마
2. `core/theme/app_theme_extensions.dart` - 테마 확장
3. `presentation/providers/theme_provider.dart` - 테마 프로바이더

### 3단계: 서비스
1. `services/cache_service.dart` - 캐시 서비스
2. `intl/date_symbol_data_local.dart` - 날짜 포맷팅

### 4단계: 외부 패키지 (신중하게)
1. Firebase 관련 - 설정 파일 확인 필요
2. Stripe - API 키 설정 필요
3. 소셜 로그인 (Kakao, Naver) - 앱 등록 필요

### 5단계: 라우팅
1. `routes/fortune_routes.dart`
2. `routes/interactive_routes.dart`

## 에러 해결 팁

### 파일이 없을 때
```bash
# 파일 찾기
find . -name "환경_설정.dart" -type f

# 예시 파일 생성
echo "// TODO: Implement" > lib/core/config/environment.dart
```

### 패키지가 없을 때
```bash
# pubspec.yaml 확인
grep "패키지명" pubspec.yaml

# 패키지 추가
flutter pub add 패키지명
```

### 설정이 필요할 때
- Firebase: google-services.json, GoogleService-Info.plist
- Stripe: 퍼블리셔블 키 설정
- 소셜 로그인: 앱 ID 설정

## 자동화 명령어

```bash
# 현재 주석 처리된 임포트 확인
grep -n "^// import" lib/main.dart lib/routes/route_config.dart

# 특정 임포트 활성화
sed -i '' '라인번호s/^\/\/ //' 파일경로

# 에러 체크
flutter analyze --no-pub 2>&1 | grep -E "error|Error"

# 빌드 테스트
flutter build ios --debug --simulator --no-pub
```