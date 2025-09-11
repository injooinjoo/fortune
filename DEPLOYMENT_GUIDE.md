# Fortune 앱 배포 가이드 (Android & iOS)

## 🔐 보안 주의사항
**중요: 절대로 키스토어 파일과 비밀번호를 Git에 커밋하지 마세요!**

## 📱 Android 배포

### 1. 키스토어 생성 (안전한 방법)
```bash
# 1. 키스토어 생성 (강력한 비밀번호 사용)
keytool -genkey -v -keystore android/app/fortune-release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 -alias fortune

# 2. key.properties 파일 생성
cat > android/key.properties << EOF
storePassword=YOUR_SECURE_PASSWORD
keyPassword=YOUR_SECURE_PASSWORD
keyAlias=fortune
storeFile=fortune-release.keystore
EOF

# 3. 중요: 이 파일들을 백업하고 안전한 곳에 보관하세요!
# - fortune-release.keystore
# - key.properties
```

### 2. 환경 변수로 보안 강화 (권장)
```bash
# .env.local 파일 생성 (Git에 추가하지 않음)
export ANDROID_KEYSTORE_PATH=/path/to/fortune-release.keystore
export ANDROID_KEYSTORE_PASSWORD=your_secure_password
export ANDROID_KEY_ALIAS=fortune
export ANDROID_KEY_PASSWORD=your_secure_password
```

### 3. 릴리스 빌드
```bash
# AAB (Google Play 업로드용)
flutter build appbundle --release

# APK (직접 설치용)
flutter build apk --release
```

### 4. Google Play Console 체크리스트
- [ ] 앱 생성
- [ ] 앱 정보 입력
  - 앱 이름: Fortune - AI 운세
  - 간단한 설명 (80자)
  - 자세한 설명 (4000자)
  - 카테고리: 라이프스타일
- [ ] 그래픽 자산
  - 앱 아이콘: 512x512 PNG
  - 기능 그래픽: 1024x500 PNG
  - 스크린샷: 최소 2개 (권장 8개)
    - Phone: 320-3840px
    - 7" Tablet: 320-3840px (선택)
    - 10" Tablet: 1080-7680px (선택)
- [ ] 개인정보처리방침 URL
- [ ] 콘텐츠 등급 설문
- [ ] 타겟 국가: 대한민국
- [ ] 가격: 무료

---

## 🍎 iOS 배포

### 1. Apple Developer 계정
- Apple Developer Program 가입 필요 ($99/년)
- https://developer.apple.com

### 2. 인증서 및 프로파일 설정
```bash
# Fastlane Match 사용 (권장)
cd ios
fastlane match appstore
```

### 3. Xcode 설정
1. Runner.xcworkspace 열기
2. Signing & Capabilities 설정
   - Team 선택
   - Bundle Identifier: com.beyond.fortune
   - Automatically manage signing 체크

### 4. 빌드 및 업로드
```bash
# TestFlight 업로드
cd ios
fastlane beta

# App Store 제출
cd ios
fastlane release
```

### 5. App Store Connect 체크리스트
- [ ] 앱 정보
  - 이름: Fortune - AI 운세
  - 부제: AI가 알려주는 나의 운세
  - 카테고리: 라이프스타일
- [ ] 스크린샷 (필수)
  - 6.7" (iPhone 14 Pro Max)
  - 6.5" (iPhone 11 Pro Max)
  - 5.5" (iPhone 8 Plus)
  - 12.9" iPad Pro (선택)
- [ ] 앱 설명
  - 한국어 설명
  - 키워드 (100자)
  - 지원 URL
  - 마케팅 URL (선택)
- [ ] 일반 정보
  - 앱 아이콘: 1024x1024 PNG (투명도 없음)
  - 버전: 1.0.0
  - 저작권: © 2024 Beyond
- [ ] 연령 등급
- [ ] 가격: 무료
- [ ] 심사 정보
  - 연락처 정보
  - 테스트 계정 (필요시)
  - 심사 노트

---

## 📋 배포 전 체크리스트

### 공통
- [ ] 버전 번호 업데이트 (pubspec.yaml)
- [ ] 테스트 완료
  - [ ] 로그인/로그아웃
  - [ ] 주요 기능
  - [ ] 결제 (있는 경우)
- [ ] 프로덕션 API 엔드포인트 확인
- [ ] 디버그 코드 제거
- [ ] 성능 최적화
- [ ] 크래시 리포팅 설정 (Firebase Crashlytics)

### Android 전용
- [ ] ProGuard 규칙 확인
- [ ] 64비트 지원 확인
- [ ] minSdkVersion: 23
- [ ] targetSdkVersion: 최신

### iOS 전용
- [ ] iOS 최소 버전: 12.0
- [ ] iPad 지원 여부
- [ ] 권한 설명 문구 확인 (Info.plist)

---

## 🚀 Fastlane 자동화

### Android
```bash
cd android
fastlane internal  # 내부 테스트
fastlane beta      # 베타 테스트
fastlane deploy    # 프로덕션 배포
```

### iOS
```bash
cd ios
fastlane screenshots  # 스크린샷 생성
fastlane beta        # TestFlight
fastlane release     # App Store
```

---

## 📱 테스트 배포

### Android - Firebase App Distribution
```bash
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "beta-testers"
```

### iOS - TestFlight
1. App Store Connect에서 TestFlight 탭
2. 내부 테스터 추가 (최대 100명)
3. 외부 테스터 추가 (최대 10,000명)

---

## ⚠️ 주의사항

1. **키스토어 백업**: Android 키스토어를 잃어버리면 앱 업데이트 불가
2. **버전 관리**: 항상 이전 버전보다 높은 버전 번호 사용
3. **심사 기간**: 
   - Google Play: 보통 2-3시간
   - App Store: 보통 24-48시간
4. **거절 대응**: 심사 거절 시 피드백에 따라 수정 후 재제출

---

## 📞 지원

문제 발생 시:
- Google Play Console: https://play.google.com/console
- App Store Connect: https://appstoreconnect.apple.com
- Flutter 문서: https://docs.flutter.dev/deployment