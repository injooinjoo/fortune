# Flutter 개발 환경 설정 가이드

> Fortune 앱의 Flutter 개발을 위한 환경 설정 및 CI/CD 구성
> 작성일: 2025년 1월 8일

## 📑 목차
1. [개요](#개요)
2. [개발 환경 설정](#개발-환경-설정)
3. [Flavor 설정](#flavor-설정)
4. [환경 변수 관리](#환경-변수-관리)
5. [빌드 설정](#빌드-설정)
6. [CI/CD 파이프라인](#cicd-파이프라인)
7. [디버깅 도구](#디버깅-도구)
8. [성능 최적화](#성능-최적화)

---

## 개요

Fortune Flutter 앱은 개발, 스테이징, 프로덕션 환경을 명확히 분리하여 안전하고 효율적인 개발 프로세스를 보장합니다.

### 환경 구분
- **Development**: 로컬 개발 및 테스트
- **Staging**: QA 및 베타 테스트
- **Production**: 실제 서비스 환경

---

## 개발 환경 설정

### 1. Flutter SDK 설치
```bash
# Flutter 설치 (macOS)
brew install --cask flutter

# 또는 수동 설치
git clone https://github.com/flutter/flutter.git
export PATH="$PATH:`pwd`/flutter/bin"

# 설치 확인
flutter doctor

# 필요한 도구 설치
flutter doctor --android-licenses
```

### 2. IDE 설정

#### VS Code
```json
// .vscode/settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "dart.flutterSdkPath": "${env:FLUTTER_HOME}",
  "dart.lineLength": 80,
  "dart.previewLsp": true,
  "[dart]": {
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}

// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Fortune Dev",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug",
      "args": [
        "--flavor",
        "dev",
        "--dart-define-from-file=config/dev.json"
      ]
    },
    {
      "name": "Fortune Staging",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile",
      "args": [
        "--flavor",
        "staging",
        "--dart-define-from-file=config/staging.json"
      ]
    },
    {
      "name": "Fortune Prod",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release",
      "args": [
        "--flavor",
        "prod",
        "--dart-define-from-file=config/prod.json"
      ]
    }
  ]
}

// .vscode/tasks.json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Build Runner Watch",
      "type": "shell",
      "command": "flutter pub run build_runner watch --delete-conflicting-outputs",
      "group": "build",
      "problemMatcher": []
    },
    {
      "label": "Generate Localizations",
      "type": "shell",
      "command": "flutter gen-l10n",
      "group": "build",
      "problemMatcher": []
    }
  ]
}
```

#### Android Studio / IntelliJ
```xml
<!-- .idea/runConfigurations/Fortune_Dev.xml -->
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Fortune Dev" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="additionalArgs" value="--flavor dev --dart-define-from-file=config/dev.json" />
    <option name="filePath" value="$PROJECT_DIR$/lib/main.dart" />
    <method v="2" />
  </configuration>
</component>
```

### 3. Git 설정
```bash
# .gitignore
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/
*.iml
*.ipr
*.iws
.idea/

# 환경 설정
.env
.env.*
config/*.json
!config/*.example.json

# 키 파일
*.jks
*.keystore
*.p12
*.p8
*.pem
GoogleService-Info.plist
google-services.json

# 플랫폼별
/android/key.properties
/ios/Runner/GoogleService-Info.plist
/ios/Flutter/Generated.xcconfig
/ios/Flutter/flutter_export_environment.sh
```

---

## Flavor 설정

### 1. Android 설정
```gradle
// android/app/build.gradle
android {
    ...
    
    flavorDimensions "environment"
    
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            
            manifestPlaceholders = [
                appName: "Fortune Dev",
                appIcon: "@mipmap/ic_launcher_dev"
            ]
            
            buildConfigField "String", "BASE_URL", '"https://dev-api.fortune.com"'
        }
        
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            
            manifestPlaceholders = [
                appName: "Fortune Staging",
                appIcon: "@mipmap/ic_launcher_staging"
            ]
            
            buildConfigField "String", "BASE_URL", '"https://staging-api.fortune.com"'
        }
        
        prod {
            dimension "environment"
            
            manifestPlaceholders = [
                appName: "Fortune",
                appIcon: "@mipmap/ic_launcher"
            ]
            
            buildConfigField "String", "BASE_URL", '"https://api.fortune.com"'
        }
    }
    
    // 서명 설정
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 2. iOS 설정
```ruby
# ios/Flutter/Pods-Runner-{flavor}.xcconfig 파일 생성

# Dev Configuration
// ios/Flutter/Dev.xcconfig
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.fortune.app.dev
PRODUCT_NAME = Fortune Dev
FLUTTER_BUILD_MODE = debug
ASSET_PREFIX = dev

# Staging Configuration
// ios/Flutter/Staging.xcconfig
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.fortune.app.staging
PRODUCT_NAME = Fortune Staging
FLUTTER_BUILD_MODE = profile
ASSET_PREFIX = staging

# Prod Configuration
// ios/Flutter/Prod.xcconfig
#include "Generated.xcconfig"
PRODUCT_BUNDLE_IDENTIFIER = com.fortune.app
PRODUCT_NAME = Fortune
FLUTTER_BUILD_MODE = release
ASSET_PREFIX = prod
```

```ruby
# ios/Runner/Info.plist
<key>CFBundleDisplayName</key>
<string>$(PRODUCT_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

### 3. Dart 코드에서 Flavor 사용
```dart
// lib/config/environment/environment.dart
enum Environment { dev, staging, prod }

class EnvironmentConfig {
  static late Environment _environment;
  static late Map<String, dynamic> _config;
  
  static void init(Environment env) {
    _environment = env;
    _config = _loadConfig(env);
  }
  
  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        return 'https://dev-api.fortune.com';
      case Environment.staging:
        return 'https://staging-api.fortune.com';
      case Environment.prod:
        return 'https://api.fortune.com';
    }
  }
  
  static String get supabaseUrl => _config['SUPABASE_URL'];
  static String get supabaseAnonKey => _config['SUPABASE_ANON_KEY'];
  static String get openAiApiKey => _config['OPENAI_API_KEY'];
  
  static bool get isProduction => _environment == Environment.prod;
  static bool get isDevelopment => _environment == Environment.dev;
}

// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Flavor 감지
  const String flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  final Environment env = Environment.values.firstWhere(
    (e) => e.name == flavor,
    orElse: () => Environment.dev,
  );
  
  EnvironmentConfig.init(env);
  
  await initializeApp();
  runApp(const MyApp());
}
```

---

## 환경 변수 관리

### 1. 환경별 설정 파일
```json
// config/dev.json
{
  "SUPABASE_URL": "https://dev.supabase.co",
  "SUPABASE_ANON_KEY": "dev_key_here",
  "OPENAI_API_KEY": "sk-dev-xxx",
  "STRIPE_PUBLISHABLE_KEY": "pk_test_xxx",
  "GOOGLE_ADSENSE_ID": "ca-pub-test",
  "ENABLE_ANALYTICS": false,
  "ENABLE_CRASHLYTICS": false
}

// config/staging.json
{
  "SUPABASE_URL": "https://staging.supabase.co",
  "SUPABASE_ANON_KEY": "staging_key_here",
  "OPENAI_API_KEY": "sk-staging-xxx",
  "STRIPE_PUBLISHABLE_KEY": "pk_test_xxx",
  "GOOGLE_ADSENSE_ID": "ca-pub-staging",
  "ENABLE_ANALYTICS": true,
  "ENABLE_CRASHLYTICS": true
}

// config/prod.json
{
  "SUPABASE_URL": "https://prod.supabase.co",
  "SUPABASE_ANON_KEY": "prod_key_here",
  "OPENAI_API_KEY": "sk-prod-xxx",
  "STRIPE_PUBLISHABLE_KEY": "pk_live_xxx",
  "GOOGLE_ADSENSE_ID": "ca-pub-live",
  "ENABLE_ANALYTICS": true,
  "ENABLE_CRASHLYTICS": true
}

// config/dev.example.json (Git에 포함)
{
  "SUPABASE_URL": "YOUR_SUPABASE_URL",
  "SUPABASE_ANON_KEY": "YOUR_ANON_KEY",
  "OPENAI_API_KEY": "YOUR_OPENAI_KEY",
  "STRIPE_PUBLISHABLE_KEY": "YOUR_STRIPE_KEY",
  "GOOGLE_ADSENSE_ID": "YOUR_ADSENSE_ID",
  "ENABLE_ANALYTICS": false,
  "ENABLE_CRASHLYTICS": false
}
```

### 2. 빌드 시 환경 변수 주입
```bash
# 개발 빌드
flutter run --flavor dev --dart-define-from-file=config/dev.json

# 스테이징 빌드
flutter run --flavor staging --dart-define-from-file=config/staging.json

# 프로덕션 빌드
flutter run --flavor prod --dart-define-from-file=config/prod.json
```

### 3. 코드에서 환경 변수 사용
```dart
// lib/core/config/app_config.dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
  
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );
  
  static void validateConfig() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Missing required environment variables');
    }
  }
}
```

---

## 빌드 설정

### 1. Android 빌드 최적화
```gradle
// android/gradle.properties
org.gradle.jvmargs=-Xmx4096M
android.useAndroidX=true
android.enableJetifier=true
android.enableR8=true
```

### 2. iOS 빌드 최적화
```ruby
# ios/Podfile
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      
      # 빌드 속도 향상
      if config.name == 'Debug'
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        config.build_settings['GCC_OPTIMIZATION_LEVEL'] = '0'
      end
    end
  end
end
```

### 3. 빌드 스크립트
```bash
#!/bin/bash
# scripts/build.sh

FLAVOR=$1
PLATFORM=$2

if [ -z "$FLAVOR" ] || [ -z "$PLATFORM" ]; then
  echo "Usage: ./build.sh [dev|staging|prod] [android|ios|all]"
  exit 1
fi

echo "Building Fortune $FLAVOR for $PLATFORM..."

# 클린 빌드
flutter clean
flutter pub get

# 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 빌드
case $PLATFORM in
  android)
    flutter build apk --flavor $FLAVOR --dart-define-from-file=config/$FLAVOR.json
    flutter build appbundle --flavor $FLAVOR --dart-define-from-file=config/$FLAVOR.json
    ;;
  ios)
    flutter build ios --flavor $FLAVOR --dart-define-from-file=config/$FLAVOR.json
    ;;
  all)
    flutter build apk --flavor $FLAVOR --dart-define-from-file=config/$FLAVOR.json
    flutter build appbundle --flavor $FLAVOR --dart-define-from-file=config/$FLAVOR.json
    flutter build ios --flavor $FLAVOR --dart-define-from-file=config/$FLAVOR.json
    ;;
esac

echo "Build completed!"
```

---

## CI/CD 파이프라인

### 1. GitHub Actions
```yaml
# .github/workflows/flutter_ci.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

env:
  FLUTTER_VERSION: '3.16.0'

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: ${{ env.FLUTTER_VERSION }}
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run code generation
      run: flutter pub run build_runner build --delete-conflicting-outputs
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

  build_android:
    name: Build Android
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    
    strategy:
      matrix:
        flavor: [dev, staging, prod]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: ${{ env.FLUTTER_VERSION }}
    
    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '11'
    
    - name: Decode keystore
      if: matrix.flavor == 'prod'
      run: |
        echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
        echo "storeFile=keystore.jks" >> android/key.properties
        echo "storePassword=${{ secrets.ANDROID_KEYSTORE_PASSWORD }}" >> android/key.properties
        echo "keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}" >> android/key.properties
        echo "keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}" >> android/key.properties
    
    - name: Create config file
      run: |
        echo '${{ secrets[format('CONFIG_{0}', matrix.flavor)] }}' > config/${{ matrix.flavor }}.json
    
    - name: Build APK
      run: flutter build apk --flavor ${{ matrix.flavor }} --dart-define-from-file=config/${{ matrix.flavor }}.json
    
    - name: Build App Bundle
      if: matrix.flavor == 'prod'
      run: flutter build appbundle --flavor ${{ matrix.flavor }} --dart-define-from-file=config/${{ matrix.flavor }}.json
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: android-${{ matrix.flavor }}
        path: |
          build/app/outputs/flutter-apk/app-${{ matrix.flavor }}-release.apk
          build/app/outputs/bundle/${{ matrix.flavor }}Release/app-${{ matrix.flavor }}-release.aab

  build_ios:
    name: Build iOS
    needs: test
    runs-on: macos-latest
    if: github.event_name == 'push'
    
    strategy:
      matrix:
        flavor: [dev, staging, prod]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: ${{ env.FLUTTER_VERSION }}
    
    - name: Install Apple Certificate
      if: matrix.flavor == 'prod'
      uses: apple-actions/import-codesign-certs@v2
      with:
        p12-file-base64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
        p12-password: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
    
    - name: Install Provisioning Profile
      if: matrix.flavor == 'prod'
      run: |
        PP_PATH=$RUNNER_TEMP/build_pp.mobileprovision
        echo -n "${{ secrets.IOS_PROVISIONING_PROFILE_BASE64 }}" | base64 --decode --output $PP_PATH
        mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
        cp $PP_PATH ~/Library/MobileDevice/Provisioning\ Profiles
    
    - name: Create config file
      run: |
        echo '${{ secrets[format('CONFIG_{0}', matrix.flavor)] }}' > config/${{ matrix.flavor }}.json
    
    - name: Build iOS
      run: flutter build ios --flavor ${{ matrix.flavor }} --dart-define-from-file=config/${{ matrix.flavor }}.json --no-codesign
    
    - name: Archive iOS
      if: matrix.flavor == 'prod'
      run: |
        xcodebuild -workspace ios/Runner.xcworkspace \
          -scheme ${{ matrix.flavor }} \
          -sdk iphoneos \
          -configuration Release \
          -archivePath $RUNNER_TEMP/fortune.xcarchive \
          archive
    
    - name: Export IPA
      if: matrix.flavor == 'prod'
      run: |
        xcodebuild -exportArchive \
          -archivePath $RUNNER_TEMP/fortune.xcarchive \
          -exportOptionsPlist ios/ExportOptions.plist \
          -exportPath $RUNNER_TEMP/build
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: ios-${{ matrix.flavor }}
        path: $RUNNER_TEMP/build/Fortune.ipa

  deploy:
    name: Deploy
    needs: [build_android, build_ios]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - name: Download artifacts
      uses: actions/download-artifact@v3
    
    - name: Deploy to Play Store
      if: contains(github.event.head_commit.message, '[deploy-android]')
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT }}
        packageName: com.fortune.app
        releaseFiles: android-prod/app-prod-release.aab
        track: internal
    
    - name: Deploy to App Store
      if: contains(github.event.head_commit.message, '[deploy-ios]')
      uses: apple-actions/upload-testflight-build@v1
      with:
        app-path: ios-prod/Fortune.ipa
        issuer-id: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
        api-key-id: ${{ secrets.APP_STORE_CONNECT_API_KEY_ID }}
        api-private-key: ${{ secrets.APP_STORE_CONNECT_API_PRIVATE_KEY }}
```

### 2. Fastlane 설정
```ruby
# ios/fastlane/Fastfile
default_platform(:ios)

platform :ios do
  desc "Build and upload to TestFlight"
  lane :beta do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "prod",
      export_method: "app-store",
      output_directory: "./build"
    )
    
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )
  end
  
  desc "Deploy to App Store"
  lane :release do
    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "prod",
      export_method: "app-store"
    )
    
    upload_to_app_store(
      skip_metadata: true,
      skip_screenshots: true
    )
  end
end

# android/fastlane/Fastfile
default_platform(:android)

platform :android do
  desc "Build and upload to Play Store Internal Testing"
  lane :beta do
    gradle(
      task: "bundle",
      flavor: "prod",
      build_type: "Release"
    )
    
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/prodRelease/app-prod-release.aab"
    )
  end
  
  desc "Deploy to Play Store"
  lane :release do
    gradle(
      task: "bundle",
      flavor: "prod",
      build_type: "Release"
    )
    
    upload_to_play_store(
      track: "production",
      aab: "../build/app/outputs/bundle/prodRelease/app-prod-release.aab"
    )
  end
end
```

---

## 디버깅 도구

### 1. Flutter Inspector
```dart
// 디버그 모드에서만 표시
if (kDebugMode) {
  // Performance overlay
  MaterialApp(
    showPerformanceOverlay: true,
    checkerboardRasterCacheImages: true,
    checkerboardOffscreenLayers: true,
  );
}
```

### 2. 로깅 시스템
```dart
// lib/core/utils/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: kDebugMode ? Level.verbose : Level.info,
  );
  
  static void d(dynamic message) => _logger.d(message);
  static void i(dynamic message) => _logger.i(message);
  static void w(dynamic message) => _logger.w(message);
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error, stackTrace);
    
    if (kReleaseMode) {
      // Crashlytics에 보고
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message.toString(),
      );
    }
  }
}

// 사용 예시
AppLogger.i('User logged in: ${user.email}');
AppLogger.e('API call failed', error, stackTrace);
```

### 3. 네트워크 디버깅
```dart
// Charles Proxy 설정
class NetworkConfig {
  static Dio createDio() {
    final dio = Dio();
    
    if (kDebugMode) {
      // Charles Proxy 설정
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
        client.findProxy = (uri) {
          return "PROXY localhost:8888";
        };
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
      
      // 로깅
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ));
    }
    
    return dio;
  }
}
```

### 4. 메모리 프로파일링
```dart
// 메모리 릭 감지
class MemoryMonitor {
  static void startMonitoring() {
    if (kDebugMode) {
      Timeline.startSync('Memory Monitor');
      
      Timer.periodic(const Duration(minutes: 1), (timer) {
        final usage = ProcessInfo.currentRss / 1024 / 1024; // MB
        AppLogger.d('Memory usage: ${usage.toStringAsFixed(2)} MB');
        
        if (usage > 500) {
          AppLogger.w('High memory usage detected!');
        }
      });
    }
  }
}
```

---

## 성능 최적화

### 1. 빌드 최적화
```yaml
# pubspec.yaml
flutter:
  # 사용하지 않는 아이콘 제거
  uses-material-design: true
  
  # 폰트 서브셋
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
```

### 2. 코드 최적화
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 병렬 초기화
  await Future.wait([
    _initializeFirebase(),
    _initializeSupabase(),
    _initializeLocalStorage(),
  ]);
  
  // 이미지 캐시 크기 설정
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB
  
  runApp(const MyApp());
}

// Tree shaking을 위한 조건부 import
import 'package:fortune/features/admin/admin.dart' 
  if (dart.library.html) 'package:fortune/features/admin/admin_web.dart';
```

### 3. 앱 크기 최적화
```bash
# 앱 크기 분석
flutter build apk --analyze-size
flutter build ios --analyze-size

# 난독화 및 최적화
flutter build apk --obfuscate --split-debug-info=build/symbols
```

### 4. 시작 시간 최적화
```dart
// Lazy loading 적용
class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      // Lazy loading for heavy screens
      GoRoute(
        path: '/fortune/:type',
        builder: (context, state) => FutureBuilder(
          future: _loadFortuneModule(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return FortuneScreen(type: state.params['type']!);
            }
            return const LoadingScreen();
          },
        ),
      ),
    ],
  );
}
```

---

## 개발 도구 및 스크립트

### 1. Makefile
```makefile
# Makefile
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make setup        - Initial project setup"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make format       - Format code"
	@echo "  make analyze      - Analyze code"
	@echo "  make test         - Run tests"
	@echo "  make build-dev    - Build development version"
	@echo "  make build-prod   - Build production version"

setup:
	flutter pub get
	flutter pub run build_runner build --delete-conflicting-outputs
	cd ios && pod install

clean:
	flutter clean
	cd ios && pod cache clean --all
	rm -rf ~/Library/Developer/Xcode/DerivedData

format:
	dart format lib test

analyze:
	flutter analyze
	dart run dart_code_metrics:metrics analyze lib

test:
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html

build-dev:
	./scripts/build.sh dev all

build-prod:
	./scripts/build.sh prod all
```

### 2. Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Running pre-commit checks..."

# Format check
dart format --set-exit-if-changed lib test
if [ $? -ne 0 ]; then
  echo "❌ Code formatting issues found. Run 'dart format lib test'"
  exit 1
fi

# Analyze
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Code analysis failed"
  exit 1
fi

# Test
flutter test
if [ $? -ne 0 ]; then
  echo "❌ Tests failed"
  exit 1
fi

echo "✅ All pre-commit checks passed!"
```

---

## 문제 해결

### 일반적인 문제

1. **빌드 실패**
```bash
# 클린 빌드
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# iOS 관련
cd ios
pod deintegrate
pod install
```

2. **환경 변수 문제**
```dart
// 디버깅용 환경 변수 출력
if (kDebugMode) {
  print('Environment Variables:');
  print('SUPABASE_URL: ${const String.fromEnvironment('SUPABASE_URL')}');
  print('Flavor: ${const String.fromEnvironment('FLAVOR')}');
}
```

3. **성능 문제**
```dart
// Timeline 이벤트 추가
Timeline.startSync('Heavy Operation');
// ... heavy operation
Timeline.finishSync();

// Flutter DevTools에서 확인 가능
```

---

이 문서는 Fortune Flutter 앱의 개발 환경 설정부터 배포까지의 전체 프로세스를 다룹니다. 각 환경별로 명확히 분리된 설정과 자동화된 CI/CD 파이프라인을 통해 안정적이고 효율적인 개발이 가능합니다.