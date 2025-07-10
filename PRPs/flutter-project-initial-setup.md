# Product Requirements Prompt (PRP): Flutter Project Initial Setup

## Feature Name and Description
**Name**: Flutter Fortune App - Initial Project Setup  
**Description**: Complete setup and initialization of the Fortune Flutter application, establishing the foundational project structure, dependencies, development environment, and core architectural patterns for the AI-powered fortune-telling mobile application.

## Goals and Success Criteria

### Primary Goals
1. Create a production-ready Flutter project structure following Clean Architecture principles
2. Configure all necessary dependencies and development tools
3. Establish consistent coding standards and architectural patterns
4. Set up platform-specific configurations for iOS, Android, and Web
5. Implement core infrastructure components (routing, state management, theming)

### Success Criteria
- [ ] Flutter project successfully created with proper organization structure
- [ ] All dependencies from INITIAL.md installed and configured
- [ ] Project builds and runs on iOS, Android, and Web platforms without errors
- [ ] Development environment properly configured with linting and formatting
- [ ] Core architectural layers (presentation, domain, data) established
- [ ] Basic routing system implemented with go_router
- [ ] State management configured with flutter_riverpod
- [ ] Theme system with dark mode support implemented
- [ ] Git repository initialized with proper .gitignore
- [ ] Project documentation updated in README.md

## Required Context

### User-Provided Documents
- `/Users/jacobmac/Desktop/Dev/fortune/INITIAL.md` - Flutter project setup guide
- `/Users/jacobmac/Desktop/Dev/fortune/docs/FLUTTER_PROJECT_STRUCTURE.md` - Detailed project architecture
- `/Users/jacobmac/Desktop/Dev/fortune/docs/FLUTTER_MIGRATION_BLUEPRINT.md` - Complete migration blueprint
- `/Users/jacobmac/Desktop/Dev/fortune/docs/FLUTTER_MASTER_TODO_LIST.md` - Development progress tracker

### Relevant Examples and Patterns
- `/Users/jacobmac/Desktop/Dev/fortune/examples/services/supabase-client.ts` - Reference for service patterns
- `/Users/jacobmac/Desktop/Dev/fortune/fortune_flutter/` - Existing Flutter project directory
- `/Users/jacobmac/Desktop/Dev/fortune/src/` - Next.js source for pattern reference

### Desired Codebase Structure
```
fortune_flutter/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # App configuration
│   ├── injection_container.dart    # Dependency injection
│   │
│   ├── core/                       # Core functionality
│   │   ├── constants/
│   │   │   ├── app_constants.dart
│   │   │   └── fortune_categories.dart
│   │   ├── errors/
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── app_colors.dart
│   │   ├── utils/
│   │   │   └── logger.dart
│   │   └── network/
│   │       └── api_client.dart
│   │
│   ├── features/                   # Feature modules
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── fortune/
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │
│   ├── shared/                     # Shared components
│   │   ├── widgets/
│   │   ├── providers/
│   │   └── services/
│   │
│   └── config/                     # Configuration
│       ├── routes/
│       │   └── app_router.dart
│       └── environment/
│           └── environment.dart
│
├── test/                           # Tests
├── assets/                         # Resources
├── android/                        # Android platform
├── ios/                           # iOS platform
├── web/                           # Web platform
├── pubspec.yaml                   # Dependencies
└── analysis_options.yaml          # Linting rules
```

## Implementation Blueprint

### Task 1: Create Flutter Project
**Files to create/modify**: New Flutter project structure

```bash
# Create Fortune Flutter project with proper organization
flutter create fortune_flutter \
  --org com.fortune \
  --platforms android,ios,web \
  --description "AI-powered fortune telling app"

# Navigate to project
cd fortune_flutter

# Initialize git
git init
git add .
git commit -m "feat: initial Flutter project setup"
```

### Task 2: Configure Dependencies
**Files to modify**: `pubspec.yaml`

```yaml
name: fortune_flutter
description: AI-powered fortune telling app
version: 1.0.0+1
publish_to: 'none'

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  hooks_riverpod: ^2.4.9
  
  # Navigation
  go_router: ^13.0.0
  
  # Networking
  dio: ^5.4.0
  retrofit: ^4.0.3
  pretty_dio_logger: ^1.3.1
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # Supabase
  supabase_flutter: ^2.0.0
  
  # Model/Serialization
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  
  # UI/UX
  flutter_animate: ^4.3.0
  lottie: ^3.0.0
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.9
  shimmer: ^3.0.0
  
  # Utilities
  intl: ^0.18.1
  equatable: ^2.0.5
  dartz: ^0.10.1
  get_it: ^7.6.4
  uuid: ^4.2.1
  
  # Platform Features
  local_auth: ^2.1.6
  device_info_plus: ^9.1.1
  package_info_plus: ^5.0.1
  connectivity_plus: ^5.0.2
  permission_handler: ^11.1.0
  
  # Date & Time
  flutter_datetime_picker_plus: ^2.1.0
  
  # Environment
  flutter_dotenv: ^5.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  
  # Code Generation
  build_runner: ^2.4.7
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  retrofit_generator: ^8.0.6
  riverpod_generator: ^2.3.9
  hive_generator: ^2.0.1
  
  # Linting
  flutter_lints: ^3.0.1
  very_good_analysis: ^5.1.0
  
  # Testing
  mocktail: ^1.0.2
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
  
  assets:
    - .env
    - assets/images/
    - assets/animations/
    - assets/icons/
    
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
          weight: 400
        - asset: assets/fonts/Pretendard-Medium.ttf
          weight: 500
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
```

### Task 3: Create Project Structure
**Files to create**: Directory structure

```bash
# Create core directory structure
mkdir -p lib/{core,features,shared,config}
mkdir -p lib/core/{constants,errors,theme,utils,network}
mkdir -p lib/features/{auth,fortune,profile,payment,token}
mkdir -p lib/features/auth/{data,domain,presentation}
mkdir -p lib/features/auth/data/{datasources,models,repositories}
mkdir -p lib/features/auth/domain/{entities,repositories,usecases}
mkdir -p lib/features/auth/presentation/{providers,screens,widgets}
mkdir -p lib/shared/{widgets,providers,services}
mkdir -p lib/config/{routes,environment}
mkdir -p test/{unit,widget,integration}
mkdir -p assets/{images,animations,icons,fonts}
```

### Task 4: Configure Analysis Options
**Files to create**: `analysis_options.yaml`

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "build/**"
    - "lib/generated/**"
  
  errors:
    invalid_annotation_target: ignore
    
linter:
  rules:
    public_member_api_docs: false
    lines_longer_than_80_chars: false
    avoid_dynamic_calls: false
    sort_pub_dependencies: false
    prefer_relative_imports: true
```

### Task 5: Setup Environment Configuration
**Files to create**: `.env`, `.env.example`, `lib/config/environment/environment.dart`

`.env.example`:
```
# App Configuration
APP_NAME=Fortune
APP_VERSION=1.0.0

# Supabase
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key

# API
API_BASE_URL=https://api.fortune.app
OPENAI_API_KEY=your-openai-key

# Payment
STRIPE_PUBLISHABLE_KEY=your-stripe-key
TOSS_CLIENT_KEY=your-toss-key
```

`lib/config/environment/environment.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static late String appName;
  static late String appVersion;
  static late String supabaseUrl;
  static late String supabaseAnonKey;
  static late String apiBaseUrl;
  static late String openAiApiKey;
  static late String stripePublishableKey;
  static late String tossClientKey;
  
  static Future<void> load() async {
    await dotenv.load();
    
    appName = dotenv.env['APP_NAME'] ?? 'Fortune';
    appVersion = dotenv.env['APP_VERSION'] ?? '1.0.0';
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? '';
    openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    tossClientKey = dotenv.env['TOSS_CLIENT_KEY'] ?? '';
  }
  
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');
}
```

### Task 6: Create Main Entry Point
**Files to create**: `lib/main.dart`, `lib/app.dart`

`lib/main.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune_flutter/app.dart';
import 'package:fortune_flutter/config/environment/environment.dart';
import 'package:fortune_flutter/injection_container.dart' as di;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await Environment.load();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey,
  );
  
  // Initialize dependency injection
  await di.init();
  
  runApp(
    const ProviderScope(
      child: FortuneApp(),
    ),
  );
}
```

`lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune_flutter/config/routes/app_router.dart';
import 'package:fortune_flutter/core/theme/app_theme.dart';

class FortuneApp extends ConsumerWidget {
  const FortuneApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Fortune',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### Task 7: Setup Routing
**Files to create**: `lib/config/routes/app_router.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fortune_flutter/features/auth/presentation/screens/splash_screen.dart';
import 'package:fortune_flutter/features/auth/presentation/screens/login_screen.dart';
import 'package:fortune_flutter/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:fortune_flutter/shared/screens/home_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      // Add more routes as needed
    ],
  );
});
```

### Task 8: Create Theme System
**Files to create**: `lib/core/theme/app_theme.dart`, `lib/core/theme/app_colors.dart`

`lib/core/theme/app_colors.dart`:
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primary = Color(0xFF8B5CF6);
  static const secondary = Color(0xFFEC4899);
  static const accent = Color(0xFFF59E0B);
  
  // Semantic Colors
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
  
  // Neutral Colors
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);
}
```

`lib/core/theme/app_theme.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:fortune_flutter/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    fontFamily: 'Pretendard',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
  
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    fontFamily: 'Pretendard',
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
```

### Task 9: Setup Dependency Injection
**Files to create**: `lib/injection_container.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => const FlutterSecureStorage());
  
  // Network
  getIt.registerLazySingleton(() => Dio());
  
  // Add more dependencies as features are implemented
}
```

### Task 10: Configure Git
**Files to create**: `.gitignore`

```gitignore
# Flutter/Dart
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

# VS Code
.vscode/

# Environment variables
.env
.env.*

# Key files
*.keystore
*.jks
*.p12
*.key
*.pem

# Platform specific
ios/Flutter/flutter_export_environment.sh
android/key.properties
ios/Runner/GeneratedPluginRegistrant.*
android/app/google-services.json
ios/Runner/GoogleService-Info.plist

# macOS
.DS_Store

# Coverage
coverage/
*.lcov
```

### Task 11: Platform-Specific Setup
**Files to modify**: `android/app/src/main/AndroidManifest.xml`, `ios/Runner/Info.plist`

Android permissions (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.USE_BIOMETRIC"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

iOS permissions (`ios/Runner/Info.plist`):
```xml
<key>NSFaceIDUsageDescription</key>
<string>운세를 안전하게 확인하기 위해 Face ID를 사용합니다</string>
<key>NSCameraUsageDescription</key>
<string>관상 분석을 위해 카메라를 사용합니다</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>사진 라이브러리에서 이미지를 선택합니다</string>
```

### Task 12: Create README
**Files to create**: `README.md`

```markdown
# Fortune Flutter

AI-powered fortune telling mobile application built with Flutter.

## Features
- 59 different types of fortune services
- Token-based monetization system
- Premium subscriptions
- AI-powered fortune generation
- Multi-platform support (iOS, Android, Web)

## Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or later)
- Dart SDK (3.0.0 or later)
- Android Studio / Xcode
- VS Code with Flutter extension

### Installation
1. Clone the repository
2. Copy `.env.example` to `.env` and fill in the values
3. Run `flutter pub get`
4. Run `flutter run`

### Development
- Run tests: `flutter test`
- Build APK: `flutter build apk`
- Build iOS: `flutter build ios`

## Architecture
This project follows Clean Architecture principles with:
- Presentation Layer (UI, State Management)
- Domain Layer (Business Logic, Use Cases)
- Data Layer (API, Database, Repository)

## Technologies
- State Management: Riverpod
- Navigation: go_router
- Network: Dio
- Local Storage: Hive, Flutter Secure Storage
- Backend: Supabase
- Payments: Stripe, TossPay
```

## Validation Loop

### Build Commands
```bash
# Get dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Verification Checklist
1. ✓ Project builds without errors
2. ✓ All dependencies resolve correctly
3. ✓ App launches on all platforms
4. ✓ Navigation works between screens
5. ✓ Theme switching works
6. ✓ Environment variables load correctly
7. ✓ Linting passes without errors
8. ✓ Git repository properly initialized

## Notes for Implementation Agent

### Important Patterns
1. **State Management**: Use Riverpod providers for all state management
2. **Error Handling**: Implement Either<Failure, Success> pattern from dartz
3. **Dependency Injection**: Register all dependencies in injection_container.dart
4. **Code Generation**: Run build_runner after creating models with freezed/json_serializable
5. **Platform Differences**: Always test on both iOS and Android simulators

### Common Pitfalls to Avoid
1. Don't forget to run `flutter pub get` after modifying pubspec.yaml
2. Always check for null safety when accessing nullable values
3. Remember to dispose controllers and streams
4. Test deep linking configuration on actual devices
5. Ensure all assets are properly declared in pubspec.yaml

### Next Steps After Setup
1. Implement authentication flow with Supabase
2. Create fortune service API integration
3. Build UI components following the design system
4. Set up payment integration
5. Implement caching strategy with Hive

---

**Generated on**: 2025-01-10
**Generated by**: Claude AI Assistant
**Purpose**: Provide comprehensive setup instructions for Fortune Flutter project initialization