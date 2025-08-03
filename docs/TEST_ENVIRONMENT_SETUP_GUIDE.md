# Flutter 테스트 환경 구축 가이드

## 개요
Fortune Flutter 앱의 Android/iOS 테스트 환경 구축을 위한 가이드입니다.

## 현재 프로젝트 설정

### 패키지/번들 ID
- **Android Production**: `com.fortune.fortune_flutter`
- **Android Debug**: `com.fortune.fortune_flutter.debug`
- **Android Staging**: `com.fortune.fortune_flutter.staging`
- **iOS**: Xcode 빌드 설정에서 구성

### 버전 정보
- 현재 버전: 1.0.0+1

## Android 테스트 환경 구축

### 1. Build Variants 설정
현재 프로젝트에는 다음 빌드 타입이 구성되어 있습니다:
- **Release**: 프로덕션 환경
- **Debug**: 개발 환경 (`.debug` 접미사)
- **Staging**: 스테이징 환경 (`.staging` 접미사)

### 2. Firebase 앱 분리
각 환경별로 별도의 Firebase 앱을 생성해야 합니다:
```
1. Firebase Console에서 새 앱 추가
2. 각 패키지명으로 Android 앱 등록:
   - com.fortune.fortune_flutter (production)
   - com.fortune.fortune_flutter.debug
   - com.fortune.fortune_flutter.staging
3. 각 환경별 google-services.json 다운로드
4. 파일 위치:
   - android/app/src/release/google-services.json
   - android/app/src/debug/google-services.json
   - android/app/src/staging/google-services.json
```

### 3. 서명 설정
각 환경별 서명 설정:
```gradle
android {
    signingConfigs {
        debug {
            // 디버그 키스토어 사용
        }
        staging {
            // 스테이징 전용 키스토어
        }
        release {
            // 프로덕션 키스토어
        }
    }
}
```

### 4. Google Play Console 테스트 트랙
1. 내부 테스트 트랙 생성
2. 알파/베타 테스트 트랙 구성
3. 테스터 그룹 관리

## iOS 테스트 환경 구축

### 1. Bundle ID 설정
Apple Developer Console에서:
1. `com.fortune.fortune_flutter` (production)
2. `com.fortune.fortune_flutter.staging` (staging)
3. `com.fortune.fortune_flutter.debug` (debug)

### 2. Provisioning Profiles
각 환경별 프로비저닝 프로파일 생성:
- Development Profile (디버그용)
- Ad Hoc Profile (내부 테스트용)
- App Store Profile (프로덕션용)

### 3. Firebase 설정
각 Bundle ID별 Firebase 앱 등록:
```
1. Firebase Console에서 iOS 앱 추가
2. 각 Bundle ID로 등록
3. GoogleService-Info.plist 다운로드
4. Xcode에서 각 Configuration별로 파일 설정
```

### 4. TestFlight 설정
1. App Store Connect에서 앱 생성
2. TestFlight 빌드 업로드
3. 내부/외부 테스터 그룹 구성

## 환경 변수 관리

### 1. 환경별 설정 파일
```
.env                    # 기본 (개발)
.env.staging           # 스테이징
.env.production        # 프로덕션
```

### 2. 환경별 API 엔드포인트
```dart
// lib/core/config/environment.dart
class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://dev-api.fortune.com',
  );
}
```

### 3. 빌드 시 환경 지정
```bash
# 개발 빌드
flutter build apk --debug

# 스테이징 빌드
flutter build apk --flavor staging --dart-define=ENV=staging

# 프로덕션 빌드
flutter build apk --release --dart-define=ENV=production
```

## CI/CD 파이프라인

### 1. Fastlane 설정
```ruby
# android/fastlane/Fastfile
platform :android do
  desc "Deploy to internal test track"
  lane :internal do
    gradle(task: "clean assembleRelease")
    upload_to_play_store(track: 'internal')
  end
end

# ios/fastlane/Fastfile
platform :ios do
  desc "Deploy to TestFlight"
  lane :beta do
    build_app(scheme: "Runner")
    upload_to_testflight
  end
end
```

### 2. GitHub Actions 워크플로우
```yaml
name: Deploy to Test
on:
  push:
    branches: [develop, staging]

jobs:
  deploy-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
      - name: Build APK
        run: flutter build apk --flavor staging
      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
```

## 딥링크 및 OAuth 설정

### 1. URL Scheme 설정
- Production: `fortune://`
- Staging: `fortune-staging://`
- Debug: `fortune-debug://`

### 2. OAuth 리다이렉트 URL
각 환경별로 별도의 OAuth 앱 등록:
- Google OAuth
- Apple Sign In
- Kakao Login

### 3. 소셜 로그인 테스트 계정
테스트 환경용 별도 OAuth 앱 생성 및 테스트 계정 관리

## 테스트 결제 설정

### 1. Stripe 테스트 키
```
STRIPE_PUBLISHABLE_KEY_TEST=pk_test_...
STRIPE_SECRET_KEY_TEST=sk_test_...
```

### 2. In-App Purchase 테스트
- Android: 테스트 계정 등록
- iOS: Sandbox 테스터 계정 생성

## 모니터링 및 크래시 리포팅

### 1. Firebase Crashlytics
각 환경별로 별도 프로젝트에서 크래시 모니터링

### 2. Sentry
환경별 DSN 설정으로 에러 트래킹 분리

## 체크리스트

### Android 테스트 환경
- [ ] Firebase 앱 분리 (debug/staging/production)
- [ ] google-services.json 파일 환경별 설정
- [ ] 서명 키 환경별 구성
- [ ] Play Console 테스트 트랙 설정
- [ ] Firebase App Distribution 설정

### iOS 테스트 환경
- [ ] Bundle ID 환경별 생성
- [ ] Provisioning Profile 환경별 생성
- [ ] GoogleService-Info.plist 환경별 설정
- [ ] TestFlight 설정
- [ ] 푸시 인증서 환경별 등록

### 공통 설정
- [ ] 환경 변수 파일 생성 (.env.staging, .env.production)
- [ ] CI/CD 파이프라인 구성
- [ ] 딥링크 URL Scheme 설정
- [ ] OAuth 테스트 앱 등록
- [ ] 결제 테스트 환경 구성
- [ ] 모니터링 도구 환경 분리

## 참고사항

1. **보안**: 프로덕션 키와 인증서는 반드시 안전하게 관리
2. **버전 관리**: 각 환경별로 버전 코드를 다르게 관리하여 충돌 방지
3. **테스터 관리**: 내부 테스터와 외부 테스터를 명확히 구분
4. **자동화**: 가능한 모든 배포 과정을 자동화하여 실수 방지