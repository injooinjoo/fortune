# iOS App Store 런칭 완벽 가이드

**프로젝트**: Fortune - AI 운세 앱
**버전**: 1.0.0+2
**Bundle ID**: com.beyond.fortune
**Team ID**: 5F7CN7Y54D
**최종 업데이트**: 2025년 10월

---

## 📋 목차

1. [사전 준비사항](#1-사전-준비사항)
2. [보안 점검](#2-보안-점검)
3. [Apple Developer 계정 설정](#3-apple-developer-계정-설정)
4. [Xcode 프로젝트 설정](#4-xcode-프로젝트-설정)
5. [릴리즈 빌드 생성](#5-릴리즈-빌드-생성)
6. [App Store Connect 설정](#6-app-store-connect-설정)
7. [TestFlight 베타 테스트](#7-testflight-베타-테스트)
8. [심사 제출](#8-심사-제출)
9. [출시 후 관리](#9-출시-후-관리)
10. [문제 해결](#10-문제-해결)

---

## 1. 사전 준비사항

### ✅ 현재 프로젝트 상태

```yaml
✓ Flutter 3.32.8 설치됨
✓ Xcode 16.4 설치됨
✓ CocoaPods 1.16.2 설치됨
✓ iOS 실제 디바이스 연결됨
✓ Bundle ID 설정됨: com.beyond.fortune
✓ Team ID 설정됨: 5F7CN7Y54D
✓ 버전: 1.0.0+2
```

### 📱 필수 계정

- [ ] **Apple Developer Program** 가입 ($99/년)
  - URL: https://developer.apple.com
  - 개인 또는 조직 계정 선택
  - 결제 수단 등록 필요

- [ ] **Apple ID** 2단계 인증 활성화
  - 보안 강화 필수
  - 백업 전화번호 등록

### 💻 개발 환경

```bash
# Flutter 버전 확인
flutter --version
# Expected: Flutter 3.32.8 or higher

# Xcode 버전 확인
xcodebuild -version
# Expected: Xcode 16.4 or higher

# CocoaPods 확인
pod --version
# Expected: 1.16.2 or higher
```

---

## 2. 보안 점검

### 🔴 중요: API 키 보안 상태

현재 프로젝트의 `.env` 파일이 제대로 `.gitignore`에 포함되어 있습니다:

```
✓ .env 파일이 Git에서 제외됨
✓ .env.production 파일도 제외됨
✓ Firebase 설정 파일들 제외됨
✓ Android 키스토어 파일들 제외됨
```

### ⚠️ 배포 전 필수 확인사항

**다음 API 키들이 노출되었으므로 반드시 재생성하세요:**

#### 1. OpenAI API 키
```bash
# 현재 키 비활성화 및 재생성
# URL: https://platform.openai.com/api-keys
```
- [ ] 기존 키 삭제
- [ ] 새 키 생성
- [ ] `.env` 파일에 업데이트

#### 2. Supabase Service Role 키
```bash
# Supabase Dashboard > Settings > API
```
- [ ] Service Role 키 재생성
- [ ] Anon 키는 그대로 사용 가능 (공개용)
- [ ] `.env` 파일에 업데이트

#### 3. Upstash Redis 토큰
```bash
# https://console.upstash.com
```
- [ ] 토큰 재생성
- [ ] `.env` 파일에 업데이트

#### 4. Figma Access Token
```bash
# Figma > Settings > Personal Access Tokens
```
- [ ] 토큰 재생성
- [ ] `.env` 파일에 업데이트

#### 5. Kakao REST API 키
```bash
# Kakao Developers Console
```
- [ ] 앱 키 재생성
- [ ] `.env` 파일에 업데이트

### 🔐 `.env` 파일 업데이트 체크리스트

```bash
# .env 파일 확인
cat .env

# 필수 항목들:
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=xxxxx
SUPABASE_SERVICE_ROLE_KEY=xxxxx (재생성 필요!)
OPENAI_API_KEY=xxxxx (재생성 필요!)
UPSTASH_REDIS_REST_TOKEN=xxxxx (재생성 필요!)
KAKAO_REST_API_KEY=xxxxx (재생성 필요!)
FIGMA_ACCESS_TOKEN=xxxxx (재생성 필요!)
```

---

## 3. Apple Developer 계정 설정

### Step 1: Apple Developer Program 가입

1. **가입하기**
   ```
   https://developer.apple.com/programs/enroll/
   ```
   - 개인: 신분증 확인 필요
   - 조직: 사업자등록증 필요
   - 결제: $99/년 (자동 갱신)

2. **가입 완료 확인**
   - 이메일로 승인 통지 (보통 24-48시간)
   - Apple Developer 계정 활성화

### Step 2: Certificates, Identifiers & Profiles 설정

1. **App ID 생성**
   ```
   https://developer.apple.com/account/resources/identifiers
   ```

   - Identifier: `com.beyond.fortune` (이미 설정됨)
   - Description: Fortune - AI Fortune Teller
   - Capabilities 활성화:
     - [ ] Push Notifications
     - [ ] In-App Purchase
     - [ ] Sign in with Apple
     - [ ] WidgetKit (위젯 사용 시)

2. **Distribution Certificate 생성**
   ```
   https://developer.apple.com/account/resources/certificates
   ```

   옵션 A: Xcode에서 자동 생성 (권장)
   ```bash
   # Xcode > Preferences > Accounts
   # 계정 추가 > Download Manual Profiles
   ```

   옵션 B: 수동 생성
   ```bash
   # Certificate Signing Request 생성
   # Keychain Access > Certificate Assistant > Request from CA
   ```

3. **Provisioning Profile 생성**
   ```
   https://developer.apple.com/account/resources/profiles
   ```

   - Type: App Store Distribution
   - App ID: com.beyond.fortune
   - Certificate: 위에서 생성한 Distribution Certificate

---

## 4. Xcode 프로젝트 설정

### Step 1: Xcode 워크스페이스 열기

```bash
cd /Users/jacobmac/Desktop/Dev/fortune
open ios/Runner.xcworkspace
```

**⚠️ 중요**: `.xcodeproj`가 아닌 `.xcworkspace`를 여세요!

### Step 2: Signing & Capabilities 설정

1. **Runner 타겟 선택**
   - Xcode > Runner (최상단 프로젝트)
   - TARGETS > Runner 선택
   - Signing & Capabilities 탭

2. **자동 서명 설정**
   ```
   ✓ Automatically manage signing (체크)
   Team: Beyond Fortune (5F7CN7Y54D)
   Bundle Identifier: com.beyond.fortune
   ```

3. **Capabilities 추가**
   - `+ Capability` 버튼 클릭
   - [ ] Push Notifications
   - [ ] In-App Purchase
   - [ ] Sign in with Apple
   - [ ] Associated Domains (딥링크 사용 시)

### Step 3: 빌드 설정 확인

1. **Deployment Info**
   ```
   Minimum Deployment: iOS 12.0
   Target Device: iPhone, iPad
   Portrait, Landscape 설정
   ```

2. **Build Settings**
   ```
   Product Bundle Identifier: com.beyond.fortune
   Product Name: Fortune
   Display Name: Fortune
   ```

3. **Info.plist 확인**
   ```bash
   # ios/Runner/Info.plist 확인
   cat ios/Runner/Info.plist
   ```

   필수 항목:
   - [ ] CFBundleDisplayName: Fortune
   - [ ] CFBundleIdentifier: $(PRODUCT_BUNDLE_IDENTIFIER)
   - [ ] Privacy 설명들 (Location, Camera 등)

---

## 5. 릴리즈 빌드 생성

### Step 1: 의존성 정리

```bash
# Flutter 캐시 정리
flutter clean

# 의존성 재설치
flutter pub get

# CocoaPods 재설치
cd ios
pod deintegrate  # 기존 pods 제거
pod install      # 새로 설치
cd ..
```

### Step 2: iOS 릴리즈 빌드

```bash
# IPA 파일 생성 (App Store 배포용)
flutter build ipa --release

# 빌드 성공 시 출력 위치:
# build/ios/ipa/fortune.ipa
# build/ios/archive/Runner.xcarchive
```

**빌드 옵션 설명:**
- `--release`: 프로덕션 최적화 빌드
- `--obfuscate`: 코드 난독화 (선택사항)
- `--split-debug-info=<directory>`: 디버그 심볼 분리 (크래시 분석용)

### Step 3: 빌드 검증

```bash
# 빌드 결과 확인
ls -lh build/ios/ipa/
ls -lh build/ios/archive/

# IPA 파일 크기 확인 (보통 50-150MB)
du -sh build/ios/ipa/fortune.ipa
```

### Step 4: 로컬 테스트 (선택사항)

```bash
# 실제 디바이스에 릴리즈 빌드 설치
flutter run --release -d 00008140-00120304260B001C

# 기능 확인:
# - 로그인/로그아웃
# - 운세 생성
# - 결제 기능
# - 푸시 알림
# - 모든 화면 네비게이션
```

---

## 6. App Store Connect 설정

### Step 1: 앱 생성

1. **App Store Connect 접속**
   ```
   https://appstoreconnect.apple.com
   ```

2. **새 앱 만들기**
   - My Apps > + 버튼 > New App
   - Platforms: iOS
   - Name: Fortune
   - Primary Language: Korean
   - Bundle ID: com.beyond.fortune (자동 선택됨)
   - SKU: fortune-ios-001

### Step 2: 앱 정보 입력

#### 기본 정보
```yaml
Name: Fortune - AI 운세
Subtitle: AI가 알려주는 나의 운세
Primary Language: Korean (한국어)
Category:
  Primary: Lifestyle
  Secondary: Entertainment
Age Rating: 4+ (모든 연령)
```

#### 가격 및 판매 범위
```yaml
Price: Free (무료)
Availability:
  - South Korea (우선)
  - Worldwide (선택사항)
```

#### 앱 개인정보 보호

**개인정보처리방침 URL** (필수):
```
https://fortune.app/privacy
```

**데이터 수집 유형**:
- [ ] 연락처 정보: 이름, 이메일
- [ ] 사용자 콘텐츠: 생년월일, 출생 정보
- [ ] 사용 데이터: 운세 조회 기록
- [ ] 진단: 크래시 데이터

**데이터 사용 목적**:
- 앱 기능 제공
- 제품 개인화
- 분석

**제3자 공유**: 없음

### Step 3: 앱 설명 작성

#### 한국어 설명 (4000자 이내)

```markdown
🔮 Fortune - AI 기반 개인 맞춤형 운세 서비스

매일 새로운 나를 발견하는 특별한 경험, Fortune과 함께 시작하세요!

✨ 주요 기능

🎯 개인 맞춤형 운세
• 생년월일, 시간, 장소를 기반으로 한 정확한 사주 분석
• AI가 분석하는 개인별 맞춤형 운세 제공
• 매일 업데이트되는 새로운 인사이트

🌟 다양한 운세 서비스
• 오늘의 운세 - 하루를 시작하는 특별한 메시지
• 연애운 - 사랑과 관계에 대한 조언
• 사업운 - 커리어와 재물에 대한 가이드
• 건강운 - 몸과 마음의 컨디션 체크

🧠 AI 기반 분석
• 최신 AI 기술로 전통 사주학과 현대적 해석을 결합
• 개인의 성향과 특성을 깊이 있게 분석
• 실용적이고 현실적인 조언 제공

📱 쉽고 간편한 사용
• 직관적인 인터페이스로 누구나 쉽게 사용
• 소셜 로그인으로 간편한 회원가입
• 개인정보 보호를 위한 안전한 데이터 관리

🎨 아름다운 디자인
• 세련되고 모던한 UI/UX
• 다크모드 지원으로 언제든 편안한 사용
• 부드러운 애니메이션과 직관적인 네비게이션

Fortune과 함께 매일 새로운 자신을 발견하고, 더 나은 선택을 위한 영감을 얻어보세요!

📞 고객지원
• 이메일: support@fortune.app
• 웹사이트: https://fortune.app

⚠️ 주의사항
본 서비스는 참고용으로만 사용하시고, 중요한 결정은 신중히 하시기 바랍니다.
```

#### 영어 설명 (국제 버전)

```markdown
🔮 Fortune - AI-Powered Personalized Horoscope

Discover a new you every day with Fortune!

✨ Key Features

🎯 Personalized Fortune Reading
• Accurate analysis based on birth date, time, and location
• AI-generated personalized fortune readings
• Daily updated insights and guidance

🌟 Comprehensive Fortune Services
• Daily Fortune - Start your day with special messages
• Love Fortune - Guidance for relationships
• Career Fortune - Insights for work and finances
• Health Fortune - Wellness recommendations

🧠 AI-Powered Analysis
• Combines traditional astrology with modern AI
• Deep personality and characteristic analysis
• Practical and realistic advice

📱 Easy and Intuitive
• User-friendly interface
• Quick social login
• Secure data protection

🎨 Beautiful Design
• Modern and elegant UI/UX
• Dark mode support
• Smooth animations

Discover your true potential with Fortune!

📞 Support: support@fortune.app
⚠️ For entertainment purposes only
```

### Step 4: 키워드 최적화

**한국어 키워드** (100자):
```
운세,사주,타로,토정비결,오늘의운세,띠별운세,별자리,궁합,연애운,재물운,AI운세,점,운명,행운
```

**영어 키워드** (100자):
```
fortune,astrology,tarot,horoscope,daily,zodiac,compatibility,love,career,AI,destiny,luck
```

### Step 5: 스크린샷 준비

#### 필수 스크린샷 크기

**iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max)**
- 크기: 1290 x 2796px (세로)
- 개수: 최소 1개, 최대 10개
- 형식: PNG 또는 JPG

**iPhone 6.5" (iPhone 11 Pro Max, XS Max)**
- 크기: 1242 x 2688px (세로)
- 개수: 최소 1개, 최대 10개
- 형식: PNG 또는 JPG

#### 권장 스크린샷 구성

1. **랜딩 페이지** - 첫인상
2. **로그인 화면** - 소셜 로그인 옵션
3. **메인 대시보드** - 운세 카테고리
4. **운세 생성** - 정보 입력 화면
5. **운세 결과** - AI 분석 결과
6. **프로필 설정** - 개인화 기능
7. **다크 모드** - 모드 전환 예시

#### 스크린샷 생성 방법

```bash
# iOS 시뮬레이터에서 스크린샷 캡처
# Simulator > File > New Screen Shot

# 또는 명령어로:
xcrun simctl io booted screenshot screenshot.png

# 실제 디바이스:
# 볼륨 업 + 사이드 버튼 동시 클릭
```

### Step 6: 앱 아이콘

**크기**: 1024 x 1024px
**형식**: PNG (투명 배경 없음)
**위치**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

현재 아이콘 확인:
```bash
ls -lh ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png
```

---

## 7. TestFlight 베타 테스트

### Step 1: 빌드 업로드

**옵션 1: Apple Transporter (권장)**

1. Mac App Store에서 "Transporter" 다운로드
2. Transporter 앱 실행
3. "+" 버튼 클릭
4. `build/ios/ipa/fortune.ipa` 선택
5. "Deliver" 버튼 클릭
6. 업로드 완료 대기 (5-10분)

**옵션 2: Xcode Organizer**

```bash
# Xcode에서:
# Window > Organizer > Archives
# Runner.xcarchive 선택
# Distribute App > App Store Connect > Upload
```

**옵션 3: 명령줄 (altool)**

```bash
# API Key 필요
xcrun altool --upload-app \
  --type ios \
  -f build/ios/ipa/fortune.ipa \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
```

### Step 2: 빌드 처리 대기

- 업로드 완료: 5-10분
- Apple 처리: 30분-2시간
- TestFlight 활성화: 처리 완료 후

App Store Connect에서 확인:
```
My Apps > Fortune > TestFlight 탭
```

### Step 3: 내부 테스터 추가

1. **Internal Testing** 그룹 생성
2. 테스터 이메일 추가 (최대 100명)
   ```
   developer1@example.com
   developer2@example.com
   qa@example.com
   ```
3. 자동으로 초대 이메일 발송

### Step 4: 외부 테스터 추가 (선택사항)

1. **External Testing** 그룹 생성
2. **Beta App Review** 정보 입력:
   ```yaml
   Beta App Name: Fortune Beta
   Beta App Description: AI 운세 서비스 베타 테스트
   Feedback Email: beta@fortune.app
   Test Information: 로그인, 운세 생성, UI/UX 피드백
   ```

### Step 5: 피드백 수집

- TestFlight 앱에서 피드백 제출 기능 활용
- 크래시 리포트 자동 수집
- 사용 통계 확인

---

## 8. 심사 제출

### Step 1: 버전 정보 입력

```yaml
Version Number: 1.0.0
Build Number: 2
Copyright: © 2024 Beyond Fortune. All rights reserved.

What's New in This Version: |
  🎉 Fortune 앱의 첫 번째 공식 출시입니다!

  ✨ 주요 기능:
  • AI 기반 개인 맞춤형 운세 서비스
  • 오늘의 운세, 연애운, 사업운, 건강운
  • 간편한 소셜 로그인 (Google, Apple, Kakao, Naver)
  • 아름다운 UI/UX 디자인과 다크모드 지원

  💡 지속적인 업데이트로 더 나은 서비스를 제공하겠습니다.

  📞 문의: support@fortune.app
```

### Step 2: 앱 심사 정보

```yaml
Contact Information:
  First Name: [담당자 이름]
  Last Name: [담당자 성]
  Phone: +82-10-XXXX-XXXX
  Email: developer@fortune.app

Demo Account (if required):
  Username: demo@fortune.app
  Password: Demo123456!
  Note: 테스트용 계정입니다

Notes for Review: |
  Fortune은 AI 기반 개인 맞춤형 운세 서비스입니다.

  주요 기능:
  1. 생년월일 기반 개인화된 운세 제공
  2. 소셜 로그인 지원 (Google, Apple, Kakao, Naver)
  3. 광고 수익 모델 (Google AdMob)

  테스트 안내:
  - 회원가입 없이 기본 운세 확인 가능
  - 로그인 후 상세 서비스 이용 가능
  - 광고는 사용자 경험을 해치지 않는 위치에 배치

  ⚠️ 오락 및 참고용 서비스입니다. 중요한 결정에 사용하지 마세요.
```

### Step 3: 앱 카테고리 및 등급

```yaml
Primary Category: Lifestyle
Secondary Category: Entertainment

Age Rating: 4+ (모든 연령)
Rating Reason:
  - 교육적 또는 오락용 점성술 콘텐츠
  - 실제 도박이나 현금 상품 없음
  - 폭력적이거나 선정적 콘텐츠 없음
```

### Step 4: 광고 식별자 (IDFA)

```yaml
Does this app use the Advertising Identifier (IDFA)?
Answer: Yes (Google AdMob 사용 시)

Usage:
- ☑ Serve advertisements within the app
- ☐ Attribute this app installation to a previously served advertisement
- ☐ Attribute an action taken within this app to a previously served advertisement
```

### Step 5: 심사 제출

1. **Submit for Review** 버튼 클릭
2. 모든 정보 최종 확인
3. 제출 완료

**심사 상태:**
```
Waiting for Review → In Review → Processing → Ready for Sale
```

**예상 심사 시간:**
- 첫 제출: 24-48시간
- 재제출: 12-24시간

---

## 9. 출시 후 관리

### 모니터링

**App Store Connect Analytics:**
- 다운로드 수
- 일일 활성 사용자 (DAU)
- 월간 활성 사용자 (MAU)
- 평점 및 리뷰
- 매출 (인앱 결제)

**Firebase Analytics:**
```bash
# Firebase Console > Analytics
- 사용자 참여도
- 이벤트 추적
- 전환 퍼널
- 사용자 인구통계
```

**Sentry 에러 트래킹:**
```bash
# Sentry Dashboard
- 실시간 크래시 리포트
- 성능 모니터링
- 릴리즈 건강도
```

### 사용자 피드백 대응

**리뷰 관리:**
- 긍정 리뷰에 감사 표현
- 부정 리뷰에 건설적 대응
- 버그 수정 약속 이행
- 전문적인 톤 유지

**리뷰 응답 예시:**
```
긍정 리뷰:
"Fortune 앱을 사랑해주셔서 감사합니다! 앞으로도 더 나은 서비스를 제공하겠습니다. 😊"

부정 리뷰:
"불편을 드려 죄송합니다. 말씀하신 문제는 다음 업데이트에서 수정하겠습니다.
자세한 문의는 support@fortune.app로 연락주세요."
```

### 정기 업데이트

**업데이트 주기:**
- 버그 수정: 2주마다
- 기능 개선: 1개월마다
- 메이저 업데이트: 3-4개월마다

**버전 관리:**
```yaml
1.0.1: 버그 수정
1.1.0: 마이너 기능 추가
2.0.0: 메이저 기능 추가 또는 UI 대폭 변경
```

---

## 10. 문제 해결

### 빌드 에러

**에러: Signing certificate not found**
```bash
# 해결:
# Xcode > Preferences > Accounts
# Download Manual Profiles
```

**에러: Provisioning profile doesn't include certificate**
```bash
# 해결:
# Apple Developer Portal에서 프로비저닝 프로필 재생성
```

**에러: Pod installation failed**
```bash
cd ios
pod deintegrate
rm Podfile.lock
pod install
cd ..
```

### 업로드 에러

**에러: ITMS-90xxx 에러**
```
# Apple의 특정 에러 문서 확인
# Info.plist 설정 검증
# Xcode 최신 버전으로 업데이트
```

**에러: Build processing failed**
```
# 빌드 재업로드
# 빌드 번호 증가
# Export Options 확인
```

### 심사 리젝트

**일반적인 리젝트 사유:**

1. **Privacy Policy 없음**
   - 해결: 개인정보처리방침 URL 제공

2. **메타데이터 불일치**
   - 해결: 스크린샷과 설명이 앱 기능과 일치하도록 수정

3. **기능 작동 불가**
   - 해결: 데모 계정 제공 및 테스트 가이드 작성

4. **결제 문제**
   - 해결: 인앱 결제 복원 기능 추가

**대응 방법:**
1. Resolution Center 메시지 확인
2. 지적사항 수정
3. 수정 내용 명확히 설명
4. 재제출

---

## 📝 체크리스트

### 배포 전

- [ ] 모든 노출된 API 키 재생성
- [ ] `.env` 파일 프로덕션 값으로 설정
- [ ] Apple Developer Program 가입
- [ ] App ID 생성 및 Capabilities 설정
- [ ] Distribution Certificate 생성
- [ ] Provisioning Profile 생성
- [ ] Xcode Signing 설정 완료

### 빌드

- [ ] `flutter clean && flutter pub get`
- [ ] `cd ios && pod install`
- [ ] `flutter build ipa --release` 성공
- [ ] 실제 디바이스에서 릴리즈 빌드 테스트
- [ ] 모든 기능 정상 작동 확인

### App Store Connect

- [ ] 앱 생성 완료
- [ ] 앱 정보 입력 (이름, 부제목, 설명)
- [ ] 키워드 최적화
- [ ] 스크린샷 7개 업로드 (6.7", 6.5")
- [ ] 앱 아이콘 1024x1024 업로드
- [ ] 개인정보처리방침 URL 설정
- [ ] 카테고리 및 연령 등급 설정

### TestFlight

- [ ] IPA 파일 업로드 완료
- [ ] 빌드 처리 완료
- [ ] 내부 테스터 추가
- [ ] 베타 테스트 실시
- [ ] 피드백 수집 및 버그 수정

### 심사

- [ ] 버전 정보 입력
- [ ] 앱 심사 정보 작성
- [ ] 데모 계정 제공 (필요시)
- [ ] 심사 노트 작성
- [ ] Submit for Review 클릭

### 출시 후

- [ ] Analytics 설정 (Firebase)
- [ ] 에러 트래킹 설정 (Sentry)
- [ ] 사용자 리뷰 모니터링
- [ ] 정기 업데이트 계획 수립

---

## 📞 지원

**문제 발생 시:**
- Apple Developer Support: https://developer.apple.com/support
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios
- Fortune 개발팀: developer@fortune.app

**유용한 링크:**
- App Store Connect: https://appstoreconnect.apple.com
- Apple Developer Portal: https://developer.apple.com/account
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines
- TestFlight: https://developer.apple.com/testflight

---

**작성일**: 2025년 10월
**문서 버전**: 1.0
**유지보수**: Fortune 개발팀
