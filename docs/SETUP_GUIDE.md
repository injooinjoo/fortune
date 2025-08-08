# Fortune App 설정 가이드 🚀

## 📋 개요

이 문서는 Fortune Flutter 앱의 전체 설정 과정을 단계별로 안내합니다.

## 🔧 개발 환경 설정

### 필수 요구사항
- Flutter SDK 3.5.3+
- Dart SDK 3.5.3+
- Xcode 14+ (iOS)
- Android Studio (Android)

### 기본 설정

1. **프로젝트 클론**
```bash
git clone https://github.com/injooinjoo/fortune.git
cd fortune
```

2. **의존성 설치**
```bash
flutter pub get
cd ios && pod install && cd ..
```

3. **환경 변수 설정**
```bash
# .env 파일 설정
cp .env.local .env
```

## 🔑 인증 시스템 설정

### Supabase 설정
```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### 소셜 로그인 설정

#### Google 로그인
```env
GOOGLE_WEB_CLIENT_ID=your-web-client-id
GOOGLE_IOS_CLIENT_ID=your-ios-client-id
GOOGLE_ANDROID_CLIENT_ID=your-android-client-id
```

#### Kakao 로그인 (네이티브 앱 키 사용)
```env
KAKAO_NATIVE_APP_KEY=your-kakao-native-key
```

## 📱 Firebase 설정

### FCM (푸시 알림)
1. Firebase 프로젝트 생성
2. `google-services.json` (Android) 및 `GoogleService-Info.plist` (iOS) 다운로드
3. 각각 `android/app/` 및 `ios/Runner/`에 배치

### 환경 변수
```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_APP_ID=your-app-id
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
```

## 💳 결제 시스템 설정

### Stripe 설정 (테스트 키)
```env
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_test...
```

### Toss Payments 설정 (테스트 키)
```env
TOSS_CLIENT_KEY=test_ck_...
TOSS_SECRET_KEY=test_sk_...
```

### In-App Purchase (iOS/Android)
- iOS: App Store Connect에서 In-App Purchase 설정
- Android: Google Play Console에서 In-App Products 설정

## 🔍 AI 및 외부 서비스

### OpenAI 설정
```env
OPENAI_API_KEY=sk-proj-...
```

### Google Genkit AI 설정
```env
GOOGLE_GENAI_API_KEY=your-genai-key
```

### Sentry 에러 모니터링
```env
NEXT_PUBLIC_SENTRY_DSN=https://...
SENTRY_ORG=your-org
SENTRY_PROJECT=fortune
```

## 📊 애널리틱스 및 광고

### Google AdSense
```env
NEXT_PUBLIC_ADSENSE_CLIENT_ID=ca-pub-...
NEXT_PUBLIC_ADSENSE_SLOT_ID=...
```

### Upstash Redis (캐싱)
```env
UPSTASH_REDIS_REST_URL=https://...
UPSTASH_REDIS_REST_TOKEN=...
```

## 🚀 빌드 및 배포

### 개발 빌드
```bash
flutter run --dart-define-from-file=.env.development
```

### 프로덕션 빌드
```bash
# iOS
flutter build ios --dart-define-from-file=.env.production --release

# Android
flutter build appbundle --dart-define-from-file=.env.production --release

# Web
flutter build web --dart-define-from-file=.env.production --release
```

## 🧪 테스트 설정

### 단위 테스트
```bash
flutter test
```

### 통합 테스트
```bash
flutter test integration_test/
```

### 테스트 환경 설정
- Supabase 테스트 데이터베이스 별도 구성
- 테스트용 API 키 사용
- Mock 데이터 활용

## 🔧 네이티브 플랫폼 기능

### iOS 설정
1. **WidgetKit** (iOS 위젯)
   - `Runner.entitlements`에 App Groups 추가
   - Widget Extension 타겟 생성

2. **App Links**
   - Associated Domains 설정
   - Universal Links 구성

### Android 설정
1. **App Widgets**
   - Widget Provider 설정
   - Layout 및 Configuration 파일 생성

2. **Deep Links**
   - Intent Filters 설정
   - App Links 검증

## ⚡ 성능 최적화

### 캐싱 전략
- Supabase 데이터 로컬 캐싱
- 이미지 캐싱 (cached_network_image)
- Redis를 통한 API 응답 캐싱

### 번들 최적화
```bash
flutter build web --tree-shake-icons --split-debug-info=debug-info/
```

## 🔐 보안 설정

### API 키 보호
- 모든 민감한 정보는 환경 변수로 관리
- .env 파일은 .gitignore에 추가
- 프로덕션 키는 별도 관리

### 네트워크 보안
- HTTPS 강제 사용
- Certificate Pinning 적용
- API Rate Limiting

## 📝 문제 해결

### 일반적인 문제들

1. **iOS Pod 설치 실패**
```bash
cd ios
rm Podfile.lock
pod deintegrate
pod install
```

2. **Android Gradle 빌드 실패**
```bash
cd android
./gradlew clean
flutter clean && flutter pub get
```

3. **환경 변수 인식 안됨**
- .env 파일 위치 확인
- flutter_dotenv 패키지 설정 확인

## 📞 지원

문제가 발생하면:
1. 이슈 등록: GitHub Issues
2. 문서 참조: `docs/` 디렉토리
3. 커뮤니티: Discord/Slack

---

**업데이트**: 2024-08-08