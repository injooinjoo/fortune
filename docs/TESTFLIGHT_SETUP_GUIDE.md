# TestFlight 설정 가이드 🚀

## 📋 사전 준비사항

### 필수 요구사항
- Apple Developer Program 멤버십 ($99/년)
- App Store Connect 접근 권한
- 유효한 Distribution 인증서
- App Store 프로비저닝 프로파일

## 🏗️ App Store Connect 설정

### 1. 앱 생성
1. [App Store Connect](https://appstoreconnect.apple.com) 로그인
2. "My Apps" → "+" → "New App" 클릭
3. 앱 정보 입력:
   ```
   Platform: iOS
   Name: Fortune AI
   Primary Language: Korean
   Bundle ID: com.beyond.fortune
   SKU: FORTUNE-AI-001
   ```

### 2. 앱 정보 설정
- **General Information**
  - Category: Lifestyle
  - Content Rights: Yes (자체 콘텐츠)
  
- **Age Rating**
  - Infrequent/Mild Mature/Suggestive Themes
  - No Gambling
  
- **Privacy Policy URL**
  - 필수: 개인정보 처리방침 URL 입력

## 🔧 Xcode 프로젝트 설정

### 1. Bundle ID 및 Team 설정
```bash
cd fortune_flutter
open ios/Runner.xcworkspace
```

Xcode에서:
1. Runner 프로젝트 선택
2. Signing & Capabilities 탭
3. Team: [Your Developer Team]
4. Bundle Identifier: com.beyond.fortune

### 2. 버전 관리
```yaml
# pubspec.yaml
version: 1.0.0+1  # 버전+빌드번호
```

### 3. 앱 아이콘 및 Launch Screen
- 1024x1024 앱 아이콘 준비
- Launch Screen 스토리보드 확인

## 📦 빌드 및 업로드

### 1. Archive 생성
```bash
# Flutter 빌드
flutter build ios --release --dart-define-from-file=.env.production

# Xcode에서
# 1. Generic iOS Device 선택
# 2. Product → Archive
# 3. Archives 창에서 Distribute App 클릭
```

### 2. 업로드 옵션
1. **App Store Connect** 선택
2. **Upload** 선택
3. 다음 옵션 확인:
   - Include bitcode: Yes
   - Strip Swift symbols: Yes
   - Upload symbols: Yes

### 3. Export Compliance
- 암호화 사용 여부 선택
- HTTPS만 사용하는 경우: No

## 🧪 TestFlight 설정

### 1. 빌드 처리
- 업로드 후 15-30분 처리 시간 필요
- Processing 완료 후 사용 가능

### 2. 테스트 정보 입력
**Test Information**에서 필수 입력:
```
What to Test:
- 74가지 AI 운세 기능 테스트
- 소셜 로그인 (카카오, 네이버, 구글, 애플)
- 인앱 구매 및 토큰 시스템
- iOS 네이티브 기능 (위젯, Dynamic Island)

Test Accounts (필요시):
- 테스트용 계정 정보
```

### 3. 테스터 그룹 생성

#### Internal Testing (내부 테스트)
- 최대 100명
- 즉시 사용 가능
- 개발팀 및 QA팀

#### External Testing (외부 테스트)
- 최대 10,000명
- Apple 심사 필요 (24-48시간)
- 베타 사용자

### 4. 테스터 초대
1. **테스터 추가**
   - 이메일 주소 입력
   - 역할 지정 (Tester)

2. **초대 발송**
   - TestFlight 앱 설치 안내
   - 리딤 코드 또는 링크 제공

## 📱 테스터 가이드

### TestFlight 앱 설치
1. App Store에서 "TestFlight" 검색
2. Apple 공식 TestFlight 앱 설치
3. 초대 이메일의 링크 클릭
4. "Accept" → "Install"

### 피드백 제공
- 스크린샷 캡처: 전원 + 볼륨 업
- 피드백 전송: TestFlight 앱에서 직접
- 크래시 리포트: 자동 전송

## 🔄 빌드 업데이트

### 새 빌드 업로드
```bash
# 빌드 번호 증가
# pubspec.yaml: version: 1.0.0+2

# 다시 빌드 및 업로드
flutter build ios --release --dart-define-from-file=.env.production
```

### 빌드 만료
- 90일 후 자동 만료
- 만료 전 새 빌드 업로드 필요

## ⚠️ 주의사항

### 1. 빌드 번호
- 매 업로드마다 증가 필요
- 같은 번호 재사용 불가

### 2. 외부 테스트 심사
- 첫 빌드는 심사 필요
- 이후 빌드는 자동 승인 (대부분)

### 3. 테스트 기간
- 빌드당 90일
- 연장 불가

### 4. 프로덕션 준비
- TestFlight 피드백 반영
- 성능 및 안정성 확인
- 최종 빌드 준비

## 📊 테스트 메트릭

### 확인 가능한 데이터
- 설치 수
- 세션 수
- 크래시 리포트
- 피드백 내용

### 분석 도구
- App Store Connect
- Xcode Organizer
- Firebase Crashlytics (선택)

## 🚀 프로덕션 배포 준비

### TestFlight → App Store
1. 최종 빌드 선택
2. App Store 제출
3. 앱 심사 대기 (24-48시간)

### 필요 자료
- 스크린샷 (필수 크기별)
- 앱 설명
- 키워드
- 지원 URL
- 마케팅 URL (선택)

## 🆘 문제 해결

### "Missing Compliance" 오류
```xml
<!-- Info.plist에 추가 -->
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

### 프로비저닝 프로파일 오류
1. Apple Developer에서 새로 생성
2. Xcode에서 다운로드
3. Clean Build Folder

### 업로드 실패
- Xcode 재시작
- 네트워크 확인
- Application Loader 사용 (대안)

---

**팁**: TestFlight는 실제 사용자 환경에서의 테스트를 위한 최고의 도구입니다. 충분한 테스트 기간을 가지고 피드백을 수집하세요!