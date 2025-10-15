# 📱 Android 배포 준비 현황 및 TODO

**최종 업데이트**: 2025년 1월 6일
**현재 상태**: 🟡 스크린샷 및 빌드 대기 중

---

## ✅ 완료된 작업

### 1. 빌드 설정 완료
- [x] **Keystore 생성**: `fortune-release-key.jks` (2024년 9월 18일)
- [x] **서명 설정**: `android/key.properties` 구성
- [x] **Gradle 설정**: `android/app/build.gradle` 릴리즈 구성
- [x] **앱 버전**: 1.0.0+2

### 2. 문서 작성 완료
- [x] Google Play Console 제출 가이드
- [x] 스크린샷 자동화 스크립트
- [x] 개인정보 처리방침 URL 준비

### 3. 에뮬레이터 준비 완료
- [x] Pixel Fold API 35 에뮬레이터 사용 가능

---

## ⏳ 남은 작업 (직접 실행 필요)

### 1️⃣ 스크린샷 촬영 (10-15분)

**명령어:**
```bash
# 1. 에뮬레이터 실행
flutter emulators --launch Pixel_Fold_API_35

# 2. 앱 실행
flutter run

# 3. 스크린샷 자동 촬영
./scripts/android_screenshots.sh
```

**촬영 화면:**
1. 랜딩 페이지
2. 로그인 화면
3. 메인 대시보드
4. 운세 생성 입력
5. 운세 결과
6. 프로필 설정
7. 다크모드
8. (선택) 추가 기능

**저장 위치:** `~/Desktop/Fortune_Screenshots/Android/`

---

### 2️⃣ AAB 빌드 생성 (5분)

**명령어:**
```bash
# 릴리즈 빌드 생성
flutter build appbundle --release

# 생성 확인
ls -lh build/app/outputs/bundle/release/app-release.aab
```

**생성 위치:**
```
build/app/outputs/bundle/release/app-release.aab
```

---

### 3️⃣ Google Play Console 설정 (30분)

#### A. Developer 계정 생성 ($25 필요)
- URL: https://play.google.com/console/signup
- 결제: 신용카드 또는 PayPal

#### B. 필수 입력 정보

**앱 기본 정보:**
- 앱 이름: `Fortune`
- 카테고리: 라이프스타일
- 언어: 한국어

**개인정보 처리방침:**
- URL: `https://sites.google.com/view/fortune-policy`

**스크린샷:**
- 위치: `~/Desktop/Fortune_Screenshots/Android/`
- 개수: 7-8개
- 해상도: 1080×1920

**AAB 파일:**
- 위치: `build/app/outputs/bundle/release/app-release.aab`

**앱 설명:**
```
짧은 설명 (80자):
AI 기반 개인 맞춤형 운세 서비스. 생년월일과 출생시간으로 정확한 운세를 확인하세요.
```

(자세한 설명은 `/docs/deployment/GOOGLE_PLAY_SUBMISSION_GUIDE.md` 참고)

---

## 📋 빠른 체크리스트

### 로컬 작업
- [ ] 에뮬레이터 실행
- [ ] 스크린샷 촬영 (7-8개)
- [ ] AAB 빌드 생성

### Google Play Console
- [ ] Developer 계정 생성 ($25)
- [ ] 새 앱 만들기
- [ ] 개인정보 처리방침 URL 입력
- [ ] 데이터 보안 설정
- [ ] 스크린샷 업로드
- [ ] 앱 설명 작성
- [ ] AAB 파일 업로드
- [ ] 심사 제출

---

## 🚀 다음 단계

### 즉시 실행 가능 (Flutter 명령어)

```bash
# 1. 스크린샷 촬영
flutter emulators --launch Pixel_Fold_API_35
flutter run
./scripts/android_screenshots.sh

# 2. AAB 빌드
flutter build appbundle --release
```

### 웹에서 직접 해야 함

1. **Google Play Console 가입 및 설정**
   - https://play.google.com/console/signup

2. **스크린샷 및 AAB 업로드**
   - 촬영한 스크린샷 업로드
   - 생성한 AAB 파일 업로드

3. **심사 제출**
   - 모든 정보 입력 완료 후 제출

---

## 📖 상세 가이드 문서

모든 세부 사항은 다음 문서를 참고하세요:

```
/docs/deployment/GOOGLE_PLAY_SUBMISSION_GUIDE.md
```

---

## ❓ FAQ

**Q: Android Studio 없이 에뮬레이터 실행 가능한가요?**
A: 네! Flutter 명령어로 가능합니다.
```bash
flutter emulators --launch Pixel_Fold_API_35
```

**Q: 스크린샷 해상도가 다르면 어떻게 하나요?**
A: 스크립트에 자동 리사이즈 기능이 포함되어 있습니다.

**Q: AAB 빌드 시간은 얼마나 걸리나요?**
A: 일반적으로 3-5분 정도 소요됩니다.

**Q: Google Play 심사 기간은?**
A: 보통 1-3일, 최대 7일 정도 소요됩니다.

---

**작성자**: Claude Code
**작성일**: 2025년 1월 6일
