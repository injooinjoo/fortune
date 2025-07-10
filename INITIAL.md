# Flutter 프로젝트 초기 설정 가이드

## 프로젝트 생성
```bash
# Fortune Flutter 프로젝트 생성
flutter create fortune_flutter --org com.fortune --platforms android,ios

# 프로젝트 디렉토리로 이동
cd fortune_flutter

# Git 초기화
git init
git add .
git commit -m "feat: initial Flutter project setup"
```

## 필수 패키지 설치

### pubspec.yaml 설정
```yaml
name: fortune_flutter
description: AI 기반 운세 앱
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # 상태 관리
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # 네비게이션
  go_router: ^13.0.0
  
  # 네트워킹
  dio: ^5.4.0
  retrofit: ^4.0.3
  
  # 로컬 저장소
  sqflite: ^2.3.0
  path: ^1.8.3
  flutter_secure_storage: ^9.0.0
  
  # 모델/직렬화
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # UI/UX
  flutter_animate: ^4.3.0
  lottie: ^3.0.0
  cached_network_image: ^3.3.1
  
  # 유틸리티
  intl: ^0.18.1
  equatable: ^2.0.5
  dartz: ^0.10.1
  
  # 인증
  local_auth: ^2.1.6
  
  # 플랫폼
  device_info_plus: ^9.1.1
  package_info_plus: ^5.0.1
  connectivity_plus: ^5.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # 코드 생성
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.6
  riverpod_generator: ^2.3.9
  
  # 린팅
  flutter_lints: ^3.0.1
  very_good_analysis: ^5.1.0
  
  # 테스팅
  mocktail: ^1.0.2
  flutter_test:
    sdk: flutter
```

## 프로젝트 구조 설정

```bash
# 디렉토리 구조 생성
mkdir -p lib/{core,data,domain,presentation}
mkdir -p lib/core/{constants,errors,theme,utils}
mkdir -p lib/data/{datasources,models,repositories}
mkdir -p lib/data/datasources/{local,remote}
mkdir -p lib/domain/{entities,repositories,usecases}
mkdir -p lib/presentation/{screens,widgets,providers}
mkdir -p test/{unit,widget,integration}
```

## 환경 설정

### 1. 환경 변수 (.env)
```bash
# .env
API_BASE_URL=https://api.fortune.app
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
```

### 2. Git 설정 (.gitignore)
```gitignore
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# IntelliJ
*.iml
*.ipr
*.iws
.idea/

# VS Code
.vscode/

# 환경 변수
.env
.env.*

# 키 파일
*.keystore
*.jks
*.p12
*.key
*.pem

# 플랫폼별
ios/Flutter/flutter_export_environment.sh
android/key.properties
```

## 초기 코드 설정

### 1. 앱 진입점 (lib/main.dart)
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune_flutter/core/constants/app_constants.dart';
import 'package:fortune_flutter/core/theme/app_theme.dart';
import 'package:fortune_flutter/presentation/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 초기화 작업
  await initializeApp();
  
  runApp(
    const ProviderScope(
      child: FortuneApp(),
    ),
  );
}

Future<void> initializeApp() async {
  // 환경 변수 로드
  // 로컬 DB 초기화
  // 의존성 주입 설정
}
```

### 2. 라우팅 설정 (lib/core/routes/app_router.dart)
```dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
```

## 플랫폼별 설정

### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
```

### iOS
```xml
<!-- ios/Runner/Info.plist -->
<key>NSFaceIDUsageDescription</key>
<string>운세를 안전하게 확인하기 위해 Face ID를 사용합니다</string>
```

## 개발 도구 설정

### 1. VS Code 설정 (.vscode/settings.json)
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

### 2. 분석 옵션 (analysis_options.yaml)
```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  
linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
```

## 테스트 환경 설정

### 단위 테스트 예시
```dart
// test/unit/fortune_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FortuneService', () {
    test('should generate daily fortune', () async {
      // 테스트 구현
    });
  });
}
```

## 빌드 및 실행

```bash
# 의존성 설치
flutter pub get

# 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 개발 실행
flutter run

# 특정 기기 실행
flutter run -d chrome     # 웹
flutter run -d ios        # iOS
flutter run -d android    # Android

# 빌드
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ios --release        # iOS
```

## 다음 단계

1. **인증 시스템 구현**: Supabase Auth 연동
2. **API 클라이언트 설정**: Dio + Retrofit
3. **로컬 데이터베이스 구조**: SQLite 스키마
4. **상태 관리 아키텍처**: Riverpod 프로바이더
5. **UI 컴포넌트 라이브러리**: 공통 위젯

---

이 가이드를 따라 Fortune Flutter 프로젝트의 기초를 설정할 수 있습니다. 각 단계를 완료한 후 커밋하여 진행 상황을 추적하세요.