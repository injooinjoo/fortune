# Firebase Analytics 완벽 설정 가이드

## 🎯 설정 체크리스트

### ✅ 개발 완료 (제가 이미 구현함)
- Analytics 추적 코드
- A/B Test Manager
- Remote Config Service
- 자동 화면 추적 위젯
- 이벤트 로깅 시스템

### ⚙️ 직접 설정 필요 (아래 가이드 참조)
- Firebase Console 설정
- Google Analytics 4 연동
- 플랫폼별 설정 파일
- 이벤트 및 전환 설정

---

## 📱 Step 1: Firebase 프로젝트 생성/설정

### 1.1 Firebase Console 접속
1. https://console.firebase.google.com 접속
2. "프로젝트 만들기" 클릭
3. 프로젝트 이름: `fortune-app` (또는 원하는 이름)
4. Google Analytics 활성화 ✅ 체크
5. Analytics 계정 선택 또는 새로 만들기

### 1.2 앱 등록

#### Android 앱 등록
1. Firebase Console → 프로젝트 설정 → 앱 추가 → Android
2. 패키지 이름: `com.beyond.fortune`
3. 앱 닉네임: Fortune Android
4. SHA-1 인증서 지문 추가 (선택사항, 소셜 로그인 시 필수)
   ```bash
   # SHA-1 얻는 방법 (터미널에서)
   cd android
   ./gradlew signingReport
   ```
5. `google-services.json` 다운로드
6. 파일을 `android/app/` 폴더에 복사

#### iOS 앱 등록
1. Firebase Console → 프로젝트 설정 → 앱 추가 → iOS
2. 번들 ID: `com.beyond.fortune`
3. 앱 닉네임: Fortune iOS
4. `GoogleService-Info.plist` 다운로드
5. Xcode에서 프로젝트 열기
6. `Runner` 폴더에 드래그 앤 드롭
7. "Copy items if needed" 체크

#### Web 앱 등록
1. Firebase Console → 프로젝트 설정 → 앱 추가 → Web
2. 앱 닉네임: Fortune Web
3. Firebase SDK 설정 코드 복사
4. `web/index.html`에 추가:

```html
<!-- web/index.html의 <head> 태그 안에 추가 -->
<script type="module">
  import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
  import { getAnalytics } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-analytics.js";
  
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID",
    measurementId: "YOUR_MEASUREMENT_ID"
  };
  
  const app = initializeApp(firebaseConfig);
  const analytics = getAnalytics(app);
  
  // 전역 변수로 설정
  window.firebaseApp = app;
  window.firebaseAnalytics = analytics;
</script>
```

---

## 📊 Step 2: Google Analytics 4 설정

### 2.1 GA4 속성 확인
1. Firebase Console → 프로젝트 설정 → 통합
2. Google Analytics 카드 → 관리
3. 연결된 GA4 속성 확인 (자동 생성됨)

### 2.2 GA4 Console에서 추가 설정
1. https://analytics.google.com 접속
2. 관리 → 속성 선택
3. 데이터 스트림 확인:
   - iOS 스트림
   - Android 스트림  
   - 웹 스트림

### 2.3 향상된 측정 설정 (웹)
1. 데이터 스트림 → 웹 스트림 선택
2. 향상된 측정 → 톱니바퀴 아이콘 클릭
3. 모두 활성화:
   - ✅ 페이지 조회수
   - ✅ 스크롤
   - ✅ 아웃바운드 클릭
   - ✅ 사이트 검색
   - ✅ 양식 상호작용
   - ✅ 동영상 참여도

---

## 🎯 Step 3: Firebase Console에서 이벤트 설정

### 3.1 전환 이벤트 지정
Firebase Console → Analytics → 이벤트에서 다음 이벤트를 전환으로 표시:

1. **필수 전환 이벤트**:
   - `subscription_purchased` - 구독 구매
   - `token_purchased` - 토큰 구매
   - `sign_up` - 회원가입
   - `first_fortune_generated` - 첫 운세 생성

2. **전환 표시 방법**:
   - 이벤트 목록에서 해당 이벤트 찾기
   - 오른쪽 토글 스위치 켜기

### 3.2 사용자 속성 설정
Firebase Console → Analytics → 사용자 속성:

```
생성할 사용자 속성:
- is_premium (텍스트) - 프리미엄 여부
- user_type (텍스트) - 사용자 유형
- gender (텍스트) - 성별
- birth_year (숫자) - 출생년도
- mbti (텍스트) - MBTI
- exp_subscription_price (숫자) - A/B 테스트 구독 가격
- exp_onboarding_flow (텍스트) - A/B 테스트 온보딩 플로우
```

---

## 🧪 Step 4: A/B Testing 설정

### 4.1 Remote Config 활성화
1. Firebase Console → Remote Config
2. "시작하기" 클릭
3. 첫 번째 매개변수 만들기

### 4.2 기본 매개변수 생성
다음 매개변수들을 생성하세요:

#### subscription_price
- 키: `subscription_price`
- 기본값: `2500`
- 데이터 유형: 숫자

#### subscription_title
- 키: `subscription_title`
- 기본값: `무제한 이용권`
- 데이터 유형: 문자열

#### subscription_features
- 키: `subscription_features`
- 기본값:
```json
["모든 운세 무제한 이용","광고 제거","우선 고객 지원","프리미엄 기능 이용"]
```
- 데이터 유형: JSON

#### onboarding_flow
- 키: `onboarding_flow`
- 기본값: `standard`
- 데이터 유형: 문자열

#### payment_ui_layout
- 키: `payment_ui_layout`
- 기본값: `split`
- 데이터 유형: 문자열

#### daily_free_tokens
- 키: `daily_free_tokens`
- 기본값: `1`
- 데이터 유형: 숫자

### 4.3 A/B 테스트 생성
1. Firebase Console → A/B Testing
2. "실험 만들기" → "Remote Config"
3. 실험 설정:
   - 이름: 구독 가격 테스트
   - 설명: 최적의 구독 가격 찾기
   - 대상: 100% 사용자
   - 목표: subscription_purchased 이벤트

---

## 🔧 Step 5: 플랫폼별 추가 설정

### 5.1 Android 설정
`android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

`android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

### 5.2 iOS 설정
`ios/Podfile`:
```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  
  # Firebase
  pod 'Firebase/Analytics'
  pod 'Firebase/RemoteConfig'
end
```

터미널에서:
```bash
cd ios
pod install
```

### 5.3 Web 추가 설정
`web/index.html`에 추가:
```html
<!-- Google Analytics 디버그 모드 (개발 시) -->
<script>
  window.gtag = window.gtag || function() {
    (window.dataLayer = window.dataLayer || []).push(arguments);
  };
  if (window.location.hostname === 'localhost') {
    gtag('config', 'YOUR_MEASUREMENT_ID', {
      'debug_mode': true
    });
  }
</script>
```

---

## 🔍 Step 6: 디버그 및 테스트

### 6.1 DebugView 활성화

#### Android
```bash
adb shell setprop debug.firebase.analytics.app com.beyond.fortune
```

#### iOS
1. Xcode → Product → Scheme → Edit Scheme
2. Run → Arguments → Arguments Passed on Launch
3. 추가: `-FIRDebugEnabled`

#### Web
Chrome DevTools Console에서:
```javascript
gtag('config', 'YOUR_MEASUREMENT_ID', {
  'debug_mode': true
});
```

### 6.2 실시간 확인
1. Firebase Console → Analytics → DebugView
2. 앱 실행 후 이벤트 확인
3. 이벤트가 제대로 들어오는지 검증

---

## 📋 Step 7: 대시보드 설정

### 7.1 Firebase Console 대시보드
1. Analytics → 대시보드
2. "맞춤 대시보드 만들기"
3. 추가할 카드:
   - 일일 활성 사용자 (DAU)
   - 전환 퍼널
   - 수익 지표
   - 사용자 참여도

### 7.2 Google Analytics 4 보고서
1. GA4 → 보고서 → 맞춤설정
2. 새 보고서 만들기:
   - 사용자 동선 분석
   - 전환 경로 분석
   - A/B 테스트 결과

---

## 🚨 중요 확인사항

### 1. 개인정보 설정
Firebase Console → 프로젝트 설정 → 개인정보:
- ✅ Google 신호 데이터 수집 활성화
- ✅ 광고 개인화 활성화 (선택)

### 2. 데이터 보관
GA4 → 관리 → 데이터 설정 → 데이터 보관:
- 이벤트 데이터 보관: 14개월 (최대)
- 사용자 데이터 보관: 14개월 (최대)

### 3. 필터 설정
GA4 → 관리 → 데이터 설정 → 데이터 필터:
- 내부 트래픽 제외 필터 생성
- 개발자 트래픽 제외

---

## ✅ 최종 체크리스트

- [ ] Firebase 프로젝트 생성
- [ ] Android `google-services.json` 추가
- [ ] iOS `GoogleService-Info.plist` 추가
- [ ] Web Firebase 설정 코드 추가
- [ ] Remote Config 매개변수 생성
- [ ] 전환 이벤트 설정
- [ ] 사용자 속성 생성
- [ ] DebugView 테스트
- [ ] 첫 A/B 테스트 생성

모든 설정이 완료되면 앱을 실행하고 Firebase Console → Analytics → DebugView에서 이벤트가 제대로 들어오는지 확인하세요!