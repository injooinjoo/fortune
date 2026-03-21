# 🚀 iOS App Store 런칭 빠른 시작 가이드

**Fortune - AI 운세 앱**을 iOS App Store에 출시하기 위한 핵심 단계만 정리한 빠른 참조 가이드입니다.

---

## ⚡ 5분 요약

### 1. 사전 준비 (1일)
```bash
# API 키 재생성 (보안 필수!)
# - OpenAI API 키
# - Supabase Service Role 키
# - Upstash Redis 토큰
# - Figma Access Token
# - Kakao REST API 키

# .env 파일 업데이트
cp .env.example .env
# 프로덕션 값으로 수정
```

### 2. Apple Developer 가입 (1일)
- URL: https://developer.apple.com
- 비용: $99/년
- 2단계 인증 필수

### 3. 릴리즈 빌드 (30분)
```bash
# 자동화 스크립트 실행
./scripts/build_ios_release.sh

# 수동 빌드
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```

### 4. App Store Connect 설정 (2-3시간)
- 앱 생성: https://appstoreconnect.apple.com
- 스크린샷 7개 업로드
- 앱 설명 입력
- 개인정보처리방침 URL

### 5. TestFlight 테스트 (2-3일)
- IPA 업로드 (Apple Transporter)
- 내부 테스터 추가
- 피드백 수집

### 6. 심사 제출 (1일)
- Submit for Review
- 심사 대기: 24-48시간

---

## 📋 체크리스트

### 보안 ✅
- [ ] 노출된 API 키 모두 재생성
- [ ] `.env` 파일 프로덕션 값으로 설정
- [ ] `.gitignore`에 `.env` 포함 확인

### Apple Developer ✅
- [ ] Apple Developer Program 가입
- [ ] App ID 생성: `com.beyond.fortune`
- [ ] Distribution Certificate 생성
- [ ] Provisioning Profile 생성

### 빌드 ✅
- [ ] Flutter 환경 확인
- [ ] Xcode Signing 설정
- [ ] 릴리즈 빌드 성공
- [ ] 실제 디바이스 테스트

### App Store Connect ✅
- [ ] 앱 생성 완료
- [ ] 앱 이름: Fortune - AI 운세
- [ ] 스크린샷 7개 업로드
- [ ] 앱 설명 입력 (한글/영문)
- [ ] 키워드 최적화
- [ ] 개인정보처리방침 URL 설정
- [ ] 카테고리: Lifestyle

### TestFlight ✅
- [ ] IPA 업로드 완료
- [ ] 내부 테스터 추가
- [ ] 베타 테스트 실시
- [ ] 버그 수정

### 심사 ✅
- [ ] 버전 정보 입력
- [ ] 심사 노트 작성
- [ ] 데모 계정 제공 (필요 시)
- [ ] Submit for Review

---

## 🚨 중요 명령어

### 빌드
```bash
# iOS 릴리즈 빌드 (자동화)
./scripts/build_ios_release.sh

# iOS 릴리즈 빌드 (수동)
flutter build ipa --release

# 빌드 결과 확인
find build/ios/ipa -maxdepth 1 -name "*.ipa"

# 업로드 전 실제 IPA/xcarchive 버전 검증
./scripts/verify_ios_release_artifact.sh
```

### 테스트
```bash
# 실제 디바이스에 릴리즈 빌드 설치
flutter run --release -d 00008140-00120304260B001C

# 코드 분석
flutter analyze
```

### 환경 확인
```bash
# Flutter 버전
flutter --version

# Xcode 버전
xcodebuild -version

# CocoaPods 버전
pod --version
```

---

## 📱 필수 에셋

### 앱 아이콘
- **크기**: 1024 x 1024px
- **형식**: PNG (투명 배경 없음)
- **위치**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png`

### 스크린샷 (7개 권장)
1. 랜딩 페이지
2. 로그인 화면
3. 메인 대시보드
4. 운세 정보 입력
5. 운세 결과
6. 프로필 설정
7. 다크 모드

**크기:**
- iPhone 6.7": 1290 x 2796px
- iPhone 6.5": 1242 x 2688px

---

## 📖 상세 가이드

### 전체 가이드
📄 [docs/deployment/IOS_LAUNCH_GUIDE.md](docs/deployment/IOS_LAUNCH_GUIDE.md)

### 에셋 가이드
📄 [docs/deployment/APP_STORE_ASSETS_GUIDE.md](docs/deployment/APP_STORE_ASSETS_GUIDE.md)

### 보안 체크리스트
📄 [docs/deployment/SECURITY_CHECKLIST.md](docs/deployment/SECURITY_CHECKLIST.md)

### 배포 가이드
📄 [docs/deployment/DEPLOYMENT_COMPLETE_GUIDE.md](docs/deployment/DEPLOYMENT_COMPLETE_GUIDE.md)

---

## 🔗 빠른 링크

### Apple
- **Developer Portal**: https://developer.apple.com/account
- **App Store Connect**: https://appstoreconnect.apple.com
- **TestFlight**: https://developer.apple.com/testflight

### 도구
- **Apple Transporter**: Mac App Store에서 다운로드
- **Xcode**: Mac App Store 또는 Apple Developer

### 문서
- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines
- **Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines

---

## 💡 팁

### 빠르게 시작하기
1. 보안 점검 먼저 (API 키 재생성)
2. Apple Developer 가입 (24-48시간 소요)
3. 빌드 스크립트 실행: `./scripts/build_ios_release.sh`
4. TestFlight 먼저 테스트
5. 피드백 반영 후 심사 제출

### 시간 절약
- **스크린샷**: 시뮬레이터에서 자동 캡처
- **빌드**: 자동화 스크립트 사용
- **업로드**: Apple Transporter 사용 (가장 빠름)
- **테스트**: 내부 테스터로만 먼저 진행

### 흔한 실수 방지
- ❌ API 키 재생성 안 함
- ❌ `.env` 파일 프로덕션 값 아님
- ❌ 스크린샷 크기 틀림
- ❌ 개인정보처리방침 URL 없음
- ❌ 테스트 없이 바로 심사 제출

---

## 🆘 문제 해결

### 빌드 실패
```bash
# 캐시 정리 후 재시도
flutter clean
flutter pub get
cd ios && pod deintegrate && pod install && cd ..
flutter build ipa --release
```

### Signing 에러
```
# Xcode에서 확인:
# Preferences > Accounts > Download Manual Profiles
```

### Upload 실패
```
# Apple Transporter 재시도
# 또는 Xcode Organizer 사용
```

### 버전 충돌 / 중복 빌드 번호
```bash
# App Store Connect 에서 아직 사용되지 않은 build number 인지 먼저 확인
./scripts/check_app_store_build_number.sh

# source/pubspec 과 실제 iOS 산출물 버전이 같은지 확인
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
./scripts/verify_ios_release_artifact.sh
```

- `./scripts/check_app_store_build_number.sh` 가 실패하면 `pubspec.yaml` 의 `+<build>` 값을 올린 뒤 다시 실행
- `Generated.xcconfig` 또는 `flutter_export_environment.sh` 가 오래된 값이면 먼저 `flutter build ios` 또는 `flutter build ipa`
- `ios/ExportOptions.plist` 와 `build/ios/ipa/ExportOptions.plist` 는 `manageAppVersionAndBuildNumber=false` 여야 함
- `build/ios/ipa/*.ipa` 가 오래된 값이면 새로 `flutter build ipa --release --export-options-plist=ios/ExportOptions.plist`
- 검증 스크립트가 실패한 산출물은 App Store Connect에 업로드하지 않음

---

## 📞 지원

**문제가 있으면:**
- 기술팀: developer@zpzg.co.kr
- 전체 가이드: `docs/deployment/IOS_LAUNCH_GUIDE.md`

**Apple 지원:**
- Developer Support: https://developer.apple.com/support
- App Store Connect Help: https://help.apple.com/app-store-connect

---

## ⏱️ 예상 타임라인

```
Day 1: API 키 재생성 + Apple 가입
Day 2-3: Xcode 설정 + 빌드 생성
Day 4: App Store Connect 설정 + 에셋 준비
Day 5: TestFlight 업로드 + 테스트
Day 6-7: 버그 수정
Day 8: 심사 제출
Day 9-10: 심사 대기 (24-48시간)
Day 11: 출시! 🎉
```

**총 예상 기간: 약 2주**

---

**최종 업데이트**: 2025년 10월
**버전**: 1.0
**작성**: Fortune 개발팀

**🚀 준비되셨나요? 시작하세요!**

```bash
./scripts/build_ios_release.sh
```
