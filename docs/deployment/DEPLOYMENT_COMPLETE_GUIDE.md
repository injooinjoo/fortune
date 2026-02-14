# ZPZG Deployment Complete Guide

**Last Updated**: December 2025
**Purpose**: Comprehensive deployment guide for Android and iOS app stores

---

## Table of Contents

1. [Pre-Deployment Security Checklist](#1-pre-deployment-security-checklist)
2. [Environment Setup](#2-environment-setup)
3. [Android Deployment](#3-android-deployment)
4. [iOS Deployment](#4-ios-deployment)
5. [Store Listing Optimization](#5-store-listing-optimization)
6. [Deployment Automation](#6-deployment-automation)
7. [Post-Deployment Monitoring](#7-post-deployment-monitoring)
8. [Troubleshooting](#8-troubleshooting)

---

## 1. Pre-Deployment Security Checklist

### API Key Security

배포 전 모든 API 키가 올바르게 관리되고 있는지 확인하세요.

| Service | 관리 위치 | 키 로테이션 주기 |
|---------|----------|----------------|
| OpenAI | [platform.openai.com](https://platform.openai.com/api-keys) | 90일 권장 |
| Supabase | Supabase Dashboard > Settings > API | 90일 권장 |
| Upstash Redis | [console.upstash.com](https://console.upstash.com) | 90일 권장 |
| Figma | Figma 개인 설정 | 필요시 |
| Kakao | Kakao Developer Console | 연간 |

> **참고**: API 키 로테이션 상세 가이드는 [API_KEY_ROTATION_GUIDE.md](./API_KEY_ROTATION_GUIDE.md)를 참조하세요.

### Security Best Practices

1. **Never commit sensitive files to Git**:
   ```bash
   # Already in .gitignore:
   .env
   .env.local
   .env.production
   android/key.properties
   android/app/*.keystore
   ios/Runner.xcarchive
   ```

2. **Use environment-specific keys**:
   - Development: Use test/sandbox keys
   - Staging: Use staging environment keys
   - Production: Use production keys only

3. **Enable 2FA on all services**:
   - Google Play Console
   - App Store Connect
   - Firebase Console
   - Supabase Dashboard
   - All third-party service accounts

4. **Backup critical files securely**:
   - Android keystore files
   - iOS certificates and provisioning profiles
   - Environment configuration files
   - Store in encrypted storage (1Password, AWS Secrets Manager)

---

## 2. Environment Setup

### Environment Variables Configuration

1. **Copy production template**:
   ```bash
   cp .env.production.example .env
   ```

2. **Configure production values** in `.env`:
   ```env
   # Environment
   ENVIRONMENT=production

   # API Configuration
   PROD_API_BASE_URL=https://api.zpzg.co.kr

   # Supabase
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_production_anon_key

   # Payment Providers (PRODUCTION KEYS ONLY)
   STRIPE_PUBLIC_KEY=pk_live_xxxxx
   TOSS_CLIENT_KEY=live_ck_xxxxx

   # Firebase
   FIREBASE_API_KEY=your_production_key

   # Sentry (Error Tracking)
   SENTRY_DSN=https://xxxxx@sentry.io/xxxxx
   ```

3. **Verify environment**:
   ```bash
   flutter run --release
   ```

### Required Accounts

- [ ] **Apple Developer Account** ($99/year) - [developer.apple.com](https://developer.apple.com)
- [ ] **Google Play Developer Account** ($25 one-time) - [play.google.com/console](https://play.google.com/console)
- [ ] **Domain with SSL** (for privacy policy and terms of service)

### Legal Requirements (Korea)

- [ ] Telecommunications Business Report (if applicable)
- [ ] Information Network Act compliance
- [ ] Personal Information Protection Act compliance
- [ ] Electronic Commerce Act compliance (for in-app purchases)

---

## 3. Android Deployment

### Step 1: Keystore Generation

**IMPORTANT**: Store keystore files securely. Loss = inability to update app.

```bash
# Generate release keystore
keytool -genkey -v -keystore ~/fortune-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias fortune

# You will be prompted for:
# - Keystore password (use strong password)
# - Key password (can be same as keystore password)
# - Name, Organization, City, State, Country
```

**Security Tip**: Use environment variables instead of hardcoding:

```bash
# Create .env.local (not committed to Git)
export ANDROID_KEYSTORE_PATH=/path/to/fortune-release-key.jks
export ANDROID_KEYSTORE_PASSWORD=your_secure_password
export ANDROID_KEY_ALIAS=fortune
export ANDROID_KEY_PASSWORD=your_secure_password
```

### Step 2: Configure Signing

1. **Copy key.properties template**:
   ```bash
   cp android/key.properties.example android/key.properties
   ```

2. **Edit `android/key.properties`**:
   ```properties
   storePassword=your_keystore_password
   keyPassword=your_key_password
   keyAlias=fortune
   storeFile=/Users/your_username/fortune-release-key.jks
   ```

### Step 3: Build Release

```bash
# Build AAB for Google Play (recommended)
flutter build appbundle --release

# Build APK for direct distribution
flutter build apk --release

# Using automation script
./build_production.sh android
```

**Output locations**:
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### Step 4: Google Play Console Setup

1. **Create App**:
   - Go to [Google Play Console](https://play.google.com/console)
   - Create application
   - Select "App" (not "Game")
   - Choose default language: Korean (한국어)

2. **App Details**:
   - App name: `Fortune - AI 운세`
   - Short description (80 characters):
     ```
     AI가 알려주는 나의 운세! 사주, 타로, 궁합까지
     ```
   - Full description (4000 characters): See [Store Listing](#5-store-listing-optimization)
   - Category: Lifestyle
   - Tags: astrology, fortune telling, tarot, horoscope

3. **Graphic Assets**:
   - App icon: 512×512 PNG
   - Feature graphic: 1024×500 PNG
   - Screenshots (2-8 required):
     - Phone: 320-3840px (portrait or landscape)
     - 7" Tablet: 320-3840px (optional)
     - 10" Tablet: 1080-7680px (optional)

4. **Content Rating**:
   - Complete questionnaire
   - Expected rating: Everyone / PEGI 3

5. **Privacy Policy**:
   - URL: `https://zpzg.co.kr/privacy` (must be accessible)

6. **Release Track**:
   - Internal testing → Closed testing → Open testing → Production
   - Upload AAB file
   - Complete release notes

### Step 5: Deploy

```bash
# Option 1: Manual upload via Google Play Console
# Upload the AAB file from build/app/outputs/bundle/release/

# Option 2: Fastlane automation
cd android
fastlane internal    # Internal testing
fastlane beta        # Closed testing
fastlane production  # Production release
```

**Review Time**: Typically 2-3 hours (can be up to 7 days for first submission)

---

## 4. iOS Deployment

### Step 1: Apple Developer Setup

1. **Enroll in Apple Developer Program**:
   - Visit [developer.apple.com](https://developer.apple.com)
   - Cost: $99/year
   - Individual or Organization account

2. **Create App ID**:
   - Identifier: `com.beyond.fortune`
   - Description: Fortune - AI Fortune Teller
   - Capabilities: Enable as needed (Push Notifications, In-App Purchase, etc.)

3. **Certificates and Profiles**:
   ```bash
   # Using Fastlane Match (recommended)
   cd ios
   fastlane match init       # First time setup
   fastlane match appstore   # Generate distribution certificate
   fastlane match development # Generate development certificate
   ```

### Step 2: Xcode Configuration

1. **Open workspace**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure Signing**:
   - Select Runner target
   - Go to Signing & Capabilities tab
   - Team: Select your Apple Developer team
   - Bundle Identifier: `com.beyond.fortune`
   - Provisioning Profile: Select distribution profile
   - ☑ Automatically manage signing

3. **Update version**:
   - Update in `pubspec.yaml`: `version: 1.0.0+1`
   - Version matches in Xcode automatically via Flutter

### Step 3: Build Archive

```bash
# Option 1: Flutter command
flutter build ios --release

# Option 2: Xcode
# Product → Archive
# Wait for archive to complete

# Option 3: Fastlane
cd ios
fastlane beta     # TestFlight
fastlane release  # App Store
```

### Step 4: App Store Connect Setup

1. **Create App**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com)
   - My Apps → + → New App
   - Platform: iOS
   - Name: Fortune - AI 운세
   - Primary Language: Korean
   - Bundle ID: com.beyond.fortune
   - SKU: fortune-ios

2. **App Information**:
   - Name: Fortune - AI 운세
   - Subtitle (30 chars): `AI가 알려주는 나의 운세`
   - Category: Primary - Lifestyle, Secondary - Entertainment
   - Content Rights: Does not contain third-party content

3. **Pricing and Availability**:
   - Price: Free
   - Availability: All countries or select Korea
   - Pre-orders: Optional

4. **Privacy Details**:
   - Complete Data Collection questionnaire
   - Privacy Policy URL: `https://zpzg.co.kr/privacy`
   - Data Types Collected: Account Data, Contact Info, Usage Data
   - Data Usage: App Functionality, Analytics, Product Personalization

5. **App Screenshots** (Required):

   | Device | Size | Required |
   |--------|------|----------|
   | 6.7" (iPhone 14 Pro Max) | 1290×2796 | ✅ Yes |
   | 6.5" (iPhone 11 Pro Max) | 1242×2688 | ✅ Yes |
   | 5.5" (iPhone 8 Plus) | 1242×2208 | Optional |
   | 12.9" iPad Pro | 2048×2732 | Recommended |

6. **App Description**:
   - Promotional text (170 chars): Updates shown before description
   - Description (4000 chars): See [Store Listing](#5-store-listing-optimization)
   - Keywords (100 chars): `운세,사주,타로,별자리,궁합,AI,점,운명,행운`
   - Support URL: `https://zpzg.co.kr/support`
   - Marketing URL: `https://zpzg.co.kr` (optional)

### Step 5: Submit for Review

1. **Upload Build**:
   - Xcode: Window → Organizer → Distribute App → App Store Connect
   - OR use Fastlane: `fastlane release`

2. **Complete Version Information**:
   - Build: Select uploaded build
   - What's New: Release notes for this version
   - Screenshots: Upload all required sizes
   - App Review Information:
     - Contact: Email and phone
     - Demo Account: If app requires login
     - Notes: Special instructions for reviewers

3. **Submit**:
   - Click "Submit for Review"
   - Monitor status in App Store Connect

**Review Time**: Typically 24-48 hours (can be up to 7 days)

### Step 6: TestFlight Beta Testing

Before production release, test with TestFlight:

```bash
cd ios
fastlane beta
```

- **Internal Testing**: Up to 100 Apple IDs (no review required)
- **External Testing**: Up to 10,000 testers (requires beta app review)

---

## 5. Store Listing Optimization

### App Store Optimization (ASO) Strategy

#### App Name Optimization

**Best Practices**:
- Include main keyword in title
- Keep under 30 characters
- Format: `Brand - Main Keyword`

**Examples**:
- Korean: `포춘 - AI 운세, 사주, 타로`
- English: `Fortune - AI Fortune Teller`

#### Keywords

**Korean Keywords** (iOS - 100 characters):
```
운세,사주,타로,토정비결,오늘의운세,띠별운세,별자리,궁합,연애운,재물운,AI운세,점,운명,행운
```

**English Keywords**:
```
fortune,astrology,tarot,horoscope,daily fortune,zodiac,compatibility,love,wealth,AI fortune,destiny,luck,divination
```

#### App Description Structure

1. **Hook** (First 2-3 lines - always visible):
   ```
   ✨ AI가 당신만을 위한 맞춤 운세를 알려드립니다
   매일 아침 확인하는 오늘의 운세로 하루를 시작하세요!
   ```

2. **Key Features** (Bullet points):
   ```
   🔮 주요 기능
   • 오늘의 운세: 매일 새로운 운세로 하루를 시작
   • 사주풀이: AI가 분석하는 정확한 사주 해석
   • 타로 카드: 고민이 있을 때 타로로 답을 찾아보세요
   • 궁합 보기: 연인, 친구와의 궁합을 확인
   • 띠별 운세: 12지신별 오늘의 운세
   • 별자리 운세: 서양 점성술 기반 운세
   ```

3. **Differentiation**:
   ```
   💡 Fortune만의 특별함
   • 최첨단 AI 기술로 더욱 정확한 운세 제공
   • 개인 맞춤형 해석과 조언
   • 깔끔하고 세련된 디자인
   • 매일 업데이트되는 신선한 콘텐츠
   ```

4. **Social Proof** (when available):
   ```
   ⭐ 사용자 만족도
   • 10만 명이 선택한 운세 앱
   • 평균 별점 4.5/5.0
   • "가장 정확한 운세 앱" - 사용자 리뷰
   ```

5. **Call to Action**:
   ```
   📲 지금 다운로드하고 오늘의 운세를 확인해보세요!
   처음 사용하는 분들을 위한 특별 혜택이 준비되어 있습니다.
   ```

### Screenshot Guidelines

**Content Recommendations**:
1. **Main Screen**: App first impression, show clean UI
2. **Daily Fortune**: Core feature - today's fortune
3. **Fortune Categories**: Show variety of fortune types
4. **Fortune Results**: Detailed information display
5. **Premium Features**: Revenue model showcase
6. **User Profile**: Personalization features

**Design Tips**:
- Use device frames for polish
- Add captions/text overlays to explain features
- Show actual app UI (not marketing renders)
- Use high-contrast, readable text
- Maintain consistent branding
- Localize text for each market

**Tools**:
```bash
# iOS Simulator screenshots
xcrun simctl io booted screenshot screenshot.png

# Android Emulator screenshots
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# Automated with Fastlane
cd ios && fastlane screenshots
cd android && fastlane screengrab
```

---

## 6. Deployment Automation

### Fastlane Setup

Fastlane automates building, testing, and deploying apps.

#### Android Fastlane

**`android/fastlane/Fastfile`**:
```ruby
lane :internal do
  gradle(task: "bundle", build_type: "Release")
  upload_to_play_store(
    track: 'internal',
    aab: '../build/app/outputs/bundle/release/app-release.aab'
  )
end

lane :beta do
  gradle(task: "bundle", build_type: "Release")
  upload_to_play_store(
    track: 'beta',
    aab: '../build/app/outputs/bundle/release/app-release.aab'
  )
end

lane :production do
  gradle(task: "bundle", build_type: "Release")
  upload_to_play_store(
    track: 'production',
    aab: '../build/app/outputs/bundle/release/app-release.aab'
  )
end
```

**Usage**:
```bash
cd android
fastlane internal     # Deploy to internal testing
fastlane beta         # Deploy to closed testing
fastlane production   # Deploy to production
```

#### iOS Fastlane

**`ios/fastlane/Fastfile`**:
```ruby
lane :beta do
  build_app(
    workspace: "Runner.xcworkspace",
    scheme: "Runner",
    export_method: "app-store"
  )
  upload_to_testflight
end

lane :release do
  build_app(
    workspace: "Runner.xcworkspace",
    scheme: "Runner",
    export_method: "app-store"
  )
  upload_to_app_store(
    submit_for_review: false,
    automatic_release: false
  )
end

lane :screenshots do
  capture_screenshots
  frame_screenshots(white: true)
end
```

**Usage**:
```bash
cd ios
fastlane screenshots  # Generate screenshots
fastlane beta         # Deploy to TestFlight
fastlane release      # Upload to App Store
```

### Unified Deployment Script

**`deploy.sh`** provides interactive deployment:

```bash
./deploy.sh

# Menu options:
1) Build Android AAB
2) Build Android APK
3) Deploy Android Internal
4) Deploy Android Production
5) Build iOS Release
6) Deploy iOS TestFlight
7) Deploy iOS App Store
8) Security Check
```

---

## 7. Post-Deployment Monitoring

### Error Tracking with Sentry

1. **Configure Sentry**:
   ```dart
   // lib/main.dart
   await SentryFlutter.init(
     (options) {
       options.dsn = Environment.sentryDsn;
       options.environment = Environment.environment;
       options.release = 'fortune@$version';
       options.enableAutoSessionTracking = true;
     },
     appRunner: () => runApp(MyApp()),
   );
   ```

2. **Monitor Dashboard**: [sentry.io](https://sentry.io)
   - Real-time error tracking
   - Performance monitoring
   - Release health metrics

### Firebase Performance Monitoring

1. **Add to app**:
   ```bash
   flutter pub add firebase_performance
   ```

2. **Track key metrics**:
   - Screen load times
   - API response times
   - Custom traces for critical operations

3. **Monitor in Firebase Console**:
   - Performance → Dashboard
   - Set alerts for degradation

### Analytics Setup

**Firebase Analytics**:
```dart
FirebaseAnalytics.instance.logEvent(
  name: 'fortune_generated',
  parameters: {
    'fortune_type': 'daily',
    'user_type': 'premium',
  },
);
```

**Key Events to Track**:
- App opens / screen views
- Fortune generations by type
- In-app purchases
- User retention (Day 1, Day 7, Day 30)
- Feature usage

### App Store Metrics

**Monitor Regularly**:
- Downloads and installations
- Daily/Monthly Active Users (DAU/MAU)
- Retention rates
- Crash-free rate (target: >99%)
- Average rating and reviews
- In-app purchase revenue

**Set Alerts**:
- Crash rate > 1%
- Rating drops below 4.0
- Negative reviews mentioning bugs
- Significant drop in DAU

---

## 8. Troubleshooting

### Android Issues

#### Keystore Problems
```
Error: KeyStore file not found
Solution: Verify key.properties path is correct
```

#### Method Count Exceeded
```
Error: Cannot fit requested classes in a single dex file
Solution: Ensure multidexEnabled true in build.gradle
```

#### Signing Issues
```
Error: App not properly signed
Solution: Check key.properties credentials match keystore
```

### iOS Issues

#### Code Signing Errors
```
Error: No signing certificate found
Solution: Run `fastlane match appstore` to regenerate certificates
```

#### Provisioning Profile Issues
```
Error: Provisioning profile doesn't include signing certificate
Solution: Regenerate provisioning profile in Apple Developer portal
```

#### Pod Installation Errors
```bash
cd ios
pod deintegrate
pod install
```

### Environment Variable Issues

#### Missing Required Variables
```
Error: Environment variable not set
Solution: Check .env file has all required variables from .env.example
```

#### Wrong Environment Values
```
Error: Using development keys in production
Solution: Verify ENVIRONMENT=production and all keys are production keys
```

### Build Issues

#### Flutter Clean Build
```bash
# Clear all caches and rebuild
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ios --release
```

#### Gradle Build Failed (Android)
```bash
cd android
./gradlew clean
./gradlew build
```

---

## Deployment Checklist

### Pre-Deployment
- [ ] All exposed API keys rotated
- [ ] Environment variables configured for production
- [ ] App tested on release build
- [ ] All features working (login, fortune generation, payments)
- [ ] Debug code removed
- [ ] Performance optimized
- [ ] Crash reporting configured (Sentry/Firebase)

### Android Specific
- [ ] Keystore generated and backed up securely
- [ ] key.properties configured
- [ ] ProGuard rules verified
- [ ] 64-bit support enabled
- [ ] minSdkVersion: 23, targetSdkVersion: latest
- [ ] AAB built successfully
- [ ] Google Play Console app created
- [ ] Graphic assets uploaded
- [ ] Privacy policy URL active
- [ ] Content rating completed

### iOS Specific
- [ ] Apple Developer account active
- [ ] App ID created
- [ ] Certificates and profiles generated
- [ ] Xcode signing configured
- [ ] iOS 12.0+ minimum deployment target
- [ ] Archive built successfully
- [ ] App Store Connect app created
- [ ] All screenshot sizes uploaded
- [ ] Privacy policy URL active
- [ ] App Review information complete

### Common
- [ ] Version number updated in pubspec.yaml
- [ ] Privacy policy accessible at provided URL
- [ ] Terms of service accessible (if applicable)
- [ ] Support email responsive
- [ ] Both light and dark modes tested
- [ ] App tested on multiple screen sizes
- [ ] Localization tested (if multi-language)

---

## Support Resources

- **Google Play Console**: [play.google.com/console](https://play.google.com/console)
- **App Store Connect**: [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
- **Flutter Deployment Docs**: [docs.flutter.dev/deployment](https://docs.flutter.dev/deployment)
- **Fastlane Docs**: [docs.fastlane.tools](https://docs.fastlane.tools)
- **App Store Review Guidelines**: [developer.apple.com/app-store/review/guidelines](https://developer.apple.com/app-store/review/guidelines)
- **Google Play Developer Policies**: [play.google.com/about/developer-content-policy](https://play.google.com/about/developer-content-policy)

---

**Document Version**: 1.0
**Last Updated**: January 2025
**Maintained by**: Fortune Development Team

For questions or issues, refer to project documentation or contact the development team.