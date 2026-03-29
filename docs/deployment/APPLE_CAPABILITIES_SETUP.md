# Apple Developer Capabilities 설정 가이드

**프로젝트**: Fortune - AI 운세 앱
**목적**: App ID Capabilities 활성화 및 Xcode 설정

---

## 📋 목차

1. [Capabilities란?](#1-capabilities란)
2. [Apple Developer Portal 설정](#2-apple-developer-portal-설정)
3. [Xcode 설정](#3-xcode-설정)
4. [각 Capability 상세 가이드](#4-각-capability-상세-가이드)
5. [문제 해결](#5-문제-해결)

---

## 1. Capabilities란?

**Capabilities**는 앱이 iOS의 특정 기능을 사용할 수 있도록 허가하는 권한입니다.

### Fortune 앱에 필요한 Capabilities

```yaml
필수:
  - Push Notifications: 푸시 알림 (오늘의 운세 알림)
  - Sign in with Apple: Apple 로그인

선택사항:
  - In-App Purchase: 인앱 결제 (프리미엄 기능)
  - WidgetKit: 홈 화면 위젯
  - App Groups: 앱-위젯 간 데이터 공유
```

---

## 2. Apple Developer Portal 설정

### Step 1: Apple Developer Portal 접속

1. **URL로 이동**
   ```
   https://developer.apple.com/account
   ```

2. **로그인**
   - Apple ID로 로그인
   - 2단계 인증 완료

3. **Identifiers 메뉴 선택**
   ```
   Certificates, Identifiers & Profiles > Identifiers
   ```

### Step 2: App ID 찾기

1. **App IDs 필터 선택**
   - 왼쪽 드롭다운에서 "App IDs" 선택

2. **Fortune 앱 찾기**
   - 리스트에서 `com.beyond.ondo` 검색
   - 클릭하여 상세 페이지 열기

### Step 3: Capabilities 활성화

#### 🔔 Push Notifications (필수)

**설명**: 사용자에게 오늘의 운세 알림 전송

**활성화 방법**:
1. "Push Notifications" 체크박스 찾기
2. ☑️ 체크 활성화
3. 자동으로 설정 완료 (추가 설정 불필요)

**상태**:
```
✓ Push Notifications
  Configured
```

#### 🍎 Sign in with Apple (필수)

**설명**: Apple 계정으로 간편 로그인

**활성화 방법**:
1. "Sign in with Apple" 체크박스 찾기
2. ☑️ 체크 활성화
3. 옵션 선택:
   - ☑️ **Enable as a primary App ID** (기본 앱 ID로 설정)
   - Group 설정은 비워두기 (Fortune 앱만 사용)

**상태**:
```
✓ Sign in with Apple
  Enabled as primary App ID
```

#### 💳 In-App Purchase (선택사항)

**설명**: 앱 내에서 프리미엄 기능 구매

**활성화 방법**:
1. "In-App Purchase" 체크박스 찾기
2. ☑️ 체크 활성화
3. 자동으로 설정 완료

**상태**:
```
✓ In-App Purchase
  Configured
```

**추가 설정** (나중에):
- App Store Connect에서 인앱 상품 등록
- 가격 및 설명 설정

#### 📱 WidgetKit (선택사항)

**설명**: 홈 화면 위젯 기능

**활성화 방법**:
1. "WidgetKit" 또는 "App Extensions" 찾기
2. ☑️ 체크 활성화
3. 자동으로 설정 완료

**상태**:
```
✓ App Extensions
  Configured (includes WidgetKit)
```

#### 👥 App Groups (위젯 사용 시 필수)

**설명**: 앱과 위젯 간 데이터 공유

**활성화 방법**:
1. "App Groups" 체크박스 찾기
2. ☑️ 체크 활성화
3. "Configure" 버튼 클릭
4. "+" 버튼 클릭하여 새 그룹 생성
5. Group ID 입력:
   ```
   group.com.fortune.fortune
   ```
6. "Continue" → "Register" → "Done"

**상태**:
```
✓ App Groups
  1 group: group.com.fortune.fortune
```

### Step 4: 저장

1. 페이지 상단 **"Save"** 버튼 클릭
2. 확인 메시지 대기

```
✓ Your App ID has been updated
```

---

## 3. Xcode 설정

Apple Developer Portal에서 활성화한 후, Xcode에도 설정해야 합니다.

### Step 1: Xcode 프로젝트 열기

```bash
cd /Users/jacobmac/Desktop/Dev/fortune
open ios/Runner.xcworkspace
```

**⚠️ 중요**: `.xcodeproj`가 아닌 `.xcworkspace`를 여세요!

### Step 2: Runner 타겟 선택

1. Xcode 왼쪽 네비게이터에서 **"Runner"** (최상단 파란색 아이콘) 클릭
2. 중앙 패널 "TARGETS" 아래 **"Runner"** 선택
3. 상단 탭에서 **"Signing & Capabilities"** 클릭

### Step 3: Capabilities 추가

#### 기본 확인

현재 설정된 Capabilities 확인:
```
✓ Background Modes (이미 있음)
```

#### Capability 추가 방법

1. **"+ Capability" 버튼 클릭**
   - 상단 중앙에 있는 "+ Capability" 버튼

2. **검색 및 선택**
   - 추가할 Capability 이름 입력
   - 더블클릭하여 추가

### Step 4: 각 Capability 설정

#### 🔔 Push Notifications

**추가**:
1. "+ Capability" 클릭
2. "Push Notifications" 검색
3. 더블클릭하여 추가

**설정**:
```yaml
Push Notifications:
  자동으로 설정됨
  추가 옵션 없음
```

**결과**:
```
✓ Push Notifications
  Enabled
```

#### 🍎 Sign in with Apple

**추가**:
1. "+ Capability" 클릭
2. "Sign in with Apple" 검색
3. 더블클릭하여 추가

**설정**:
```yaml
Sign in with Apple:
  자동으로 설정됨
  추가 옵션 없음
```

**결과**:
```
✓ Sign in with Apple
  Enabled
```

#### 💳 In-App Purchase

**추가**:
1. "+ Capability" 클릭
2. "In-App Purchase" 검색
3. 더블클릭하여 추가

**설정**:
```yaml
In-App Purchase:
  자동으로 설정됨
  추가 옵션 없음
```

**결과**:
```
✓ In-App Purchase
  Enabled
```

#### 📱 App Groups (위젯 사용 시)

**추가**:
1. "+ Capability" 클릭
2. "App Groups" 검색
3. 더블클릭하여 추가

**설정**:
1. Container 섹션에서 그룹 선택
2. ☑️ `group.com.fortune.fortune` 체크

**결과**:
```
✓ App Groups
  1 group selected:
    ☑ group.com.fortune.fortune
```

### Step 5: 자동 서명 확인

**Signing (Release)** 섹션 확인:
```yaml
Automatically manage signing: ☑️ (체크됨)
Team: Beyond Fortune (5F7CN7Y54D)
Provisioning Profile: Xcode Managed Profile

Status: ✓ No issues
```

**문제가 있으면**:
1. "Download Manual Profiles" 버튼 클릭
2. Xcode 재시작
3. Clean Build Folder: Shift + Command + K

---

## 4. 각 Capability 상세 가이드

### 🔔 Push Notifications

#### Firebase 연동 (이미 설정됨)

**현재 상태**:
```dart
// lib/main.dart
await Firebase.initializeApp();
FirebaseMessaging.instance.requestPermission();
```

**Info.plist 확인** (이미 설정됨):
```xml
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

#### 테스트 방법

```bash
# Firebase Console에서 테스트 알림 전송
# Cloud Messaging > Test on device
```

---

### 🍎 Sign in with Apple

#### 이미 구현됨

**현재 상태**:
```dart
// lib/services/auth_service.dart
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final credential = await SignInWithApple.getAppleIDCredential(...);
```

#### Info.plist 확인 (이미 설정됨):
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.beyond.ondo</string>
    </array>
  </dict>
</array>
```

#### 테스트 방법

```bash
# 실제 디바이스에서 테스트
flutter run --release -d 00008140-00120304260B001C

# Apple 로그인 버튼 클릭
# Face ID 또는 Touch ID로 인증
```

---

### 💳 In-App Purchase

#### 추가 설정 필요

**1. App Store Connect에서 인앱 상품 등록**

```yaml
상품 정보:
  Product ID: fortune_premium_monthly
  Type: Auto-Renewable Subscription
  Price: $4.99/month

  Description:
    Fortune 프리미엄 구독
    - 광고 제거
    - 무제한 운세 생성
    - 프리미엄 타로 카드
```

**2. StoreKit Configuration 파일 생성** (테스트용)

```bash
# Xcode에서:
# File > New > File > StoreKit Configuration File
# 이름: Products.storekit
```

**3. 테스트 방법**

```bash
# 샌드박스 환경에서 테스트
# Settings > App Store > Sandbox Account
# 테스트 계정으로 로그인
```

---

### 📱 WidgetKit

#### 이미 구현됨

**현재 상태**:
- `OndoWidgetExtension` 타겟 생성됨
- Widget Provider 구현됨

**Info.plist 확인** (이미 설정됨):
```xml
<key>NSSupportsLiveActivities</key>
<true/>
<key>NSWidgetExtensionBundleIdentifiers</key>
<array>
  <string>$(PRODUCT_BUNDLE_IDENTIFIER).FortuneWidget</string>
</array>
```

#### 테스트 방법

```bash
# 위젯 추가:
# 홈 화면 길게 누르기 > + 버튼 > Fortune 위젯 선택
```

---

## 5. 문제 해결

### ❌ "No such module" 에러

**원인**: CocoaPods 설치 안 됨

**해결**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios --release
```

### ❌ Provisioning Profile 에러

**원인**: Capabilities가 프로필에 포함 안 됨

**해결**:
```
Xcode > Preferences > Accounts
Select Team > Download Manual Profiles
```

또는:
```
Apple Developer Portal > Profiles
기존 프로필 삭제 후 재생성
```

### ❌ "Sign in with Apple" 버튼 안 보임

**원인**: Capability 활성화 안 됨

**해결**:
1. Apple Developer Portal에서 App ID 확인
2. Xcode에서 Capability 추가 확인
3. 프로비저닝 프로필 재다운로드

### ❌ Push Notification 안 옴

**원인**: APNs 인증서 문제

**해결**:
```
Firebase Console > Project Settings > Cloud Messaging
Upload APNs Authentication Key or Certificate
```

---

## 📋 최종 체크리스트

### Apple Developer Portal
- [ ] App ID에 Push Notifications 활성화
- [ ] App ID에 Sign in with Apple 활성화
- [ ] App ID에 In-App Purchase 활성화 (선택)
- [ ] App ID에 App Groups 활성화 (위젯 사용 시)
- [ ] 변경사항 저장

### Xcode
- [ ] Runner.xcworkspace 열기
- [ ] Signing & Capabilities 탭 열기
- [ ] Push Notifications 추가
- [ ] Sign in with Apple 추가
- [ ] In-App Purchase 추가 (선택)
- [ ] App Groups 추가 및 그룹 선택 (위젯 사용 시)
- [ ] "No issues" 상태 확인

### 테스트
- [ ] 빌드 성공
- [ ] 실제 디바이스에서 실행
- [ ] Push Notification 테스트
- [ ] Apple 로그인 테스트
- [ ] 인앱 결제 테스트 (선택)
- [ ] 위젯 추가 테스트 (선택)

---

## 🎯 빠른 설정 요약

### 1분 설정 (필수만)

```bash
# 1. Apple Developer Portal
https://developer.apple.com/account
→ Identifiers > com.beyond.ondo
→ Push Notifications ☑️
→ Sign in with Apple ☑️
→ Save

# 2. Xcode
open ios/Runner.xcworkspace
→ Runner > Signing & Capabilities
→ + Capability > Push Notifications
→ + Capability > Sign in with Apple
→ Command + B (빌드 테스트)

# 3. 완료!
```

### 5분 설정 (전체)

위 1분 설정 +

```bash
# Apple Developer Portal
→ In-App Purchase ☑️
→ App Groups ☑️ → Configure → group.com.fortune.fortune
→ Save

# Xcode
→ + Capability > In-App Purchase
→ + Capability > App Groups > ☑️ group.com.fortune.fortune
→ Command + B

# App Store Connect (나중에)
→ My Apps > Fortune > In-App Purchases
→ 상품 등록
```

---

## 📞 도움말

**문제가 계속되면:**
- Apple Developer Support: https://developer.apple.com/support
- Capabilities 가이드: https://developer.apple.com/documentation/xcode/capabilities
- Fortune 개발팀: developer@zpzg.co.kr

---

**작성일**: 2025년 10월
**문서 버전**: 1.0
**유지보수**: Fortune 개발팀
