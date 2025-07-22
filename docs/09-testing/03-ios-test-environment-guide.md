# iOS 테스트 환경 구축 가이드 🍎

## 📱 테스트 환경 옵션

### 옵션 1: 실제 iPhone에서 개발 모드 테스트 (권장)

#### 필요 사항
- Mac 컴퓨터 (Xcode 설치 필요)
- iPhone (iOS 14.0 이상)
- Apple Developer 계정 (무료 가능)
- USB 케이블

#### 설정 단계

1. **Xcode 설치**
   ```bash
   # App Store에서 Xcode 설치 또는
   xcode-select --install
   ```

2. **개발자 모드 활성화**
   - iPhone 설정 > 개인정보 보호 및 보안 > 개발자 모드 활성화
   - iPhone 재시작 필요

3. **프로젝트 열기**
   ```bash
   cd fortune_flutter
   open ios/Runner.xcworkspace
   ```

4. **Team 설정**
   - Xcode에서 Runner 프로젝트 선택
   - Signing & Capabilities 탭
   - Team 선택 (개인 Apple ID 사용 가능)

5. **Bundle Identifier 수정**
   - 개발용으로 고유한 ID 설정
   - 예: `com.yourname.fortune.dev`

6. **빌드 및 실행**
   ```bash
   # Flutter로 직접 실행
   flutter run --dart-define-from-file=.env.development
   
   # 또는 Xcode에서 실행
   ```

### 옵션 2: TestFlight를 통한 베타 테스트

#### 필요 사항
- Apple Developer Program 멤버십 ($99/년)
- App Store Connect 계정
- 프로비저닝 프로파일

#### 설정 단계

1. **App Store Connect에서 앱 생성**
   - https://appstoreconnect.apple.com
   - 새 앱 추가
   - Bundle ID 설정

2. **빌드 아카이브 생성**
   ```bash
   flutter build ios --dart-define-from-file=.env.development --release
   ```

3. **Xcode에서 업로드**
   - Product > Archive
   - Distribute App
   - App Store Connect 선택

4. **TestFlight 설정**
   - 테스터 그룹 생성
   - 빌드 선택
   - 테스터 초대

### 옵션 3: 시뮬레이터 사용

```bash
# 사용 가능한 시뮬레이터 확인
flutter devices

# 특정 시뮬레이터로 실행
flutter run -d "iPhone 15 Pro" --dart-define-from-file=.env.development
```

## 🧪 테스트 체크리스트

### 필수 테스트 항목

#### 1. 인증 테스트
- [ ] 카카오 로그인
- [ ] 네이버 로그인
- [ ] 구글 로그인
- [ ] 애플 로그인
- [ ] 로그아웃
- [ ] 자동 로그인

#### 2. 핵심 기능 테스트
- [ ] 운세 조회 (74가지 각각)
- [ ] 운세 히스토리
- [ ] 프로필 수정
- [ ] 토큰 잔액 확인

#### 3. 결제 테스트
- [ ] 인앱 구매 플로우
- [ ] 토큰 패키지 구매
- [ ] 구매 복원
- [ ] 영수증 검증

#### 4. UI/UX 테스트
- [ ] 다크모드 전환
- [ ] 화면 회전
- [ ] 애니메이션 성능
- [ ] 스크롤 성능

#### 5. 네이티브 기능 테스트
- [ ] 푸시 알림
- [ ] 카메라 (얼굴 인식 운세)
- [ ] 사진 라이브러리
- [ ] 음성 인식

#### 6. iOS 특화 기능
- [ ] Dynamic Island (iPhone 14 Pro+)
- [ ] Lock Screen Widget
- [ ] Siri Shortcuts
- [ ] App Shortcuts (3D Touch)

## 🔧 디버깅 도구

### Flutter Inspector
```bash
# DevTools 실행
flutter pub global activate devtools
flutter pub global run devtools
```

### 네트워크 디버깅
```dart
// main.dart에 추가
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  // 네트워크 요청 로깅 활성화
  HttpClient.enableTimelineLogging = true;
}
```

### 성능 프로파일링
```bash
# 성능 모드로 실행
flutter run --profile
```

## 📝 환경 변수 설정

### 개발용 .env.development 수정
```env
# Supabase (로컬 개발)
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your-local-anon-key

# Edge Functions (로컬)
API_BASE_URL=http://localhost:54321/functions/v1
USE_EDGE_FUNCTIONS=true

# 소셜 로그인 (테스트용)
GOOGLE_WEB_CLIENT_ID=your-test-google-client-id
KAKAO_APP_KEY=your-test-kakao-key
NAVER_CLIENT_ID=your-test-naver-id

# 기능 플래그
ENABLE_ANALYTICS=false
ENABLE_CRASH_REPORTING=false
ENABLE_ADS=false
ENABLE_PAYMENT=true
```

## 🚨 주의사항

1. **Bundle ID**: 개발용과 프로덕션용 Bundle ID를 반드시 구분
2. **API Keys**: 테스트용 키만 사용, 프로덕션 키 노출 주의
3. **인증서**: 개발용 인증서 만료일 확인 (7일)
4. **TestFlight**: 빌드 번호는 매번 증가해야 함

## 🆘 자주 발생하는 문제

### 1. "Unable to install" 오류
```bash
# 기존 앱 삭제
# Xcode에서 Product > Clean Build Folder
# 다시 빌드
```

### 2. 소셜 로그인 실패
- URL Scheme 설정 확인 (Info.plist)
- 개발용 앱 키 설정 확인
- 리다이렉트 URL 허용 확인

### 3. 인앱 구매 테스트 실패
- Sandbox 계정 설정
- 제품 ID 일치 확인
- StoreKit Configuration 파일 사용

## 📚 참고 자료

- [Flutter iOS 개발 가이드](https://docs.flutter.dev/platform-integration/ios)
- [TestFlight 문서](https://developer.apple.com/testflight/)
- [iOS 네이티브 기능 구현 가이드](./IOS_NATIVE_FEATURES_IMPLEMENTATION.md)