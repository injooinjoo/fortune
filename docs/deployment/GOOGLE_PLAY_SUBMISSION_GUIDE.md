# 🤖 Google Play Console 제출 가이드

**최종 업데이트**: 2025년 1월 6일
**목적**: Android 앱 Google Play 스토어 배포 완벽 가이드

---

## 📋 목차

1. [사전 준비 사항](#1-사전-준비-사항)
2. [AAB 빌드 생성](#2-aab-빌드-생성)
3. [스크린샷 촬영](#3-스크린샷-촬영)
4. [Google Play Console 설정](#4-google-play-console-설정)
5. [개인정보 처리방침 설정](#5-개인정보-처리방침-설정)
6. [스토어 등록 정보](#6-스토어-등록-정보)
7. [심사 제출](#7-심사-제출)

---

## 1. 사전 준비 사항

### ✅ 완료된 것들

- [x] **Keystore 생성**: `fortune-release-key.jks` (2024년 9월 18일)
- [x] **서명 설정**: `android/key.properties` 구성 완료
- [x] **빌드 설정**: `android/app/build.gradle` 릴리즈 구성 완료
- [x] **앱 버전**: 1.0.0+2

### ⏳ 필요한 것들

- [ ] **Google Play Developer 계정** ($25 일회성 결제)
  - 가입: https://play.google.com/console/signup
  - 결제 방법: 신용카드 또는 PayPal
  - 소요 시간: 10-15분

- [ ] **개인정보 처리방침 URL**
  - ✅ 준비됨: https://sites.google.com/view/fortune-policy

- [ ] **스크린샷** (7-8개)
  - 해상도: 1080×1920 (최소 2개, 최대 8개)

- [ ] **AAB 파일** (Android App Bundle)
  - 릴리즈 빌드 생성 필요

---

## 2. AAB 빌드 생성

### 🔨 릴리즈 빌드 명령어

```bash
# 프로젝트 루트에서 실행
flutter build appbundle --release
```

### 📦 생성된 파일 위치

```bash
build/app/outputs/bundle/release/app-release.aab
```

### ✅ 빌드 검증

```bash
# 빌드 파일 확인
ls -lh build/app/outputs/bundle/release/app-release.aab

# 예상 출력:
# -rw-r--r--  1 user  staff   45M Jan  6 10:30 app-release.aab
```

### 🔍 AAB 분석 (선택사항)

```bash
# AAB 내용 확인
bundletool dump manifest \
  --bundle=build/app/outputs/bundle/release/app-release.aab

# APK 크기 추정
bundletool estimate-size \
  --bundle=build/app/outputs/bundle/release/app-release.aab
```

---

## 3. 스크린샷 촬영

### 📱 에뮬레이터 실행

```bash
# 사용 가능한 에뮬레이터 확인
flutter emulators

# 에뮬레이터 실행
flutter emulators --launch Pixel_Fold_API_35

# 또는 Android Studio에서 직접 실행
# Tools → Device Manager → Pixel Fold API 35 → Launch
```

### 🎯 앱 실행

```bash
# 에뮬레이터에서 앱 실행
flutter run

# 또는 릴리즈 모드로 실행 (프로덕션 빌드)
flutter run --release
```

### 📸 스크린샷 자동 촬영

```bash
# 스크린샷 스크립트 실행
./scripts/android_screenshots.sh
```

**촬영할 화면 (7-8개):**
1. 랜딩 페이지
2. 로그인 화면
3. 메인 대시보드
4. 운세 생성 입력
5. 운세 결과
6. 프로필 설정
7. 다크모드
8. (선택) 추가 기능

### 📂 저장 위치

```
~/Desktop/Fortune_Screenshots/Android/
```

### ✅ 해상도 요구사항

**Google Play 권장 해상도:**
- **Phone**: 1080×1920 (16:9 비율)
- **Tablet** (선택): 2048×2732

**최소 요구사항:**
- 최소 2개, 최대 8개
- PNG 또는 JPG 형식
- 최대 파일 크기: 8MB

---

## 4. Google Play Console 설정

### 📝 Step 1: Developer 계정 생성

1. https://play.google.com/console/signup 접속
2. Google 계정으로 로그인
3. 개발자 계정 정보 입력:
   - 개발자 이름: `Beyond Fortune`
   - 이메일: 지원 이메일 주소
   - 전화번호: 연락 가능한 번호
4. $25 등록비 결제
5. 약관 동의

### 🆕 Step 2: 새 앱 만들기

**경로**: Google Play Console → 모든 앱 → 앱 만들기

```
앱 이름: Fortune
기본 언어: 한국어
앱 또는 게임: 앱
무료 또는 유료: 무료
개발자 프로그램 정책 동의: ✅
```

### 📋 Step 3: 앱 카테고리 설정

**경로**: Google Play Console → Fortune → 대시보드 → 설정

```
앱 카테고리: 라이프스타일
콘텐츠 등급: 모든 연령
```

---

## 5. 개인정보 처리방침 설정

### 🔐 Step 1: 개인정보 처리방침 URL

**경로**: Google Play Console → Fortune → 스토어 설정 → 개인정보 보호 정책

```
개인정보 처리방침 URL: https://sites.google.com/view/fortune-policy
```

### 📊 Step 2: 데이터 보안

**경로**: Google Play Console → Fortune → 앱 콘텐츠 → 데이터 보안

#### 수집하는 데이터 유형

**1. 위치 정보**
- [ ] 수집하지 않음

**2. 개인 정보**
- [x] **이메일 주소**
  - 수집 목적: 계정 관리, 고객 지원
  - 공유 여부: 아니오
  - 암호화 여부: 예
  - 삭제 요청 가능: 예

**3. 금융 정보**
- [ ] 수집하지 않음 (아직 결제 기능 없음)

**4. 사진 및 동영상**
- [x] **사진** (선택사항)
  - 수집 목적: 프로필 사진
  - 공유 여부: 아니오
  - 암호화 여부: 예
  - 삭제 요청 가능: 예

**5. 기기 또는 기타 ID**
- [x] **기기 ID**
  - 수집 목적: 앱 기능, 분석
  - 공유 여부: 예 (Firebase, Google Analytics)
  - 암호화 여부: 예

- [x] **광고 ID**
  - 수집 목적: 광고
  - 공유 여부: 예 (AdMob)
  - 암호화 여부: 예

**6. 앱 활동**
- [x] **앱 상호작용**
  - 수집 목적: 앱 기능, 분석
  - 공유 여부: 예 (Firebase)
  - 암호화 여부: 예

**7. 앱 정보 및 성능**
- [x] **비정상 종료 로그**
  - 수집 목적: 앱 안정성
  - 공유 여부: 예 (Firebase Crashlytics)
  - 암호화 여부: 예

### 🔒 Step 3: 보안 관행

```
데이터 암호화: ✅ 전송 중 암호화 (HTTPS)
사용자가 데이터 삭제를 요청할 수 있음: ✅ 예
데이터 보안 검토 완료: ✅ 예
```

---

## 6. 스토어 등록 정보

### 📝 앱 세부정보

**경로**: Google Play Console → Fortune → 스토어 설정 → 기본 스토어 등록 정보

#### 짧은 설명 (80자 이내)

```
AI 기반 개인 맞춤형 운세 서비스. 생년월일과 출생시간으로 정확한 운세를 확인하세요.
```

#### 자세한 설명 (4000자 이내)

```
🔮 Fortune - AI가 분석하는 나만의 운세

Fortune은 인공지능 기술을 활용하여 개인 맞춤형 운세를 제공하는 혁신적인 앱입니다.
생년월일과 출생시간을 기반으로 정확하고 상세한 운세 분석을 받아보세요.

✨ 주요 기능

📅 오늘의 운세
매일 새로운 오늘의 운세를 확인하고, 하루를 계획하세요.

💕 연애운
현재 연애 상황과 앞으로의 연애운을 AI가 분석해드립니다.

💼 사업운
사업과 재물운을 확인하고, 중요한 결정에 도움을 받으세요.

💪 건강운
건강 상태와 주의사항을 미리 파악하세요.

💰 재물운
금전운을 확인하고 재테크 타이밍을 잡으세요.

🎯 종합운세
전반적인 운세를 한눈에 확인할 수 있습니다.

🌟 특별한 기능

✅ AI 기반 분석
최신 인공지능 기술로 더욱 정확한 운세 분석

✅ 개인 맞춤형
생년월일, 출생시간 기반 나만을 위한 운세

✅ 간편한 로그인
Google, Apple, Kakao, Naver 소셜 로그인 지원

✅ 다크모드 지원
눈이 편한 다크모드로 언제든지 사용 가능

✅ 깔끔한 UI/UX
직관적이고 아름다운 디자인

🔐 개인정보 보호

Fortune은 사용자의 개인정보를 안전하게 보호합니다.
모든 데이터는 암호화되어 전송되며, 필요한 최소한의 정보만 수집합니다.

📱 지금 바로 다운로드하고
AI가 분석하는 나만의 운세를 확인해보세요!

💌 문의: support@zpzg.co.kr
🌐 개인정보 처리방침: https://sites.google.com/view/fortune-policy
```

#### 앱 아이콘

- 크기: 512×512 PNG
- 배경: 투명하지 않은 단색 또는 이미지
- 위치: `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

#### 그래픽 이미지

**Feature Graphic (필수)**
- 크기: 1024×500 JPG 또는 PNG
- 용도: Google Play 스토어 상단 배너
- 내용: 앱 로고 + 슬로건

**스크린샷**
- 위치: `~/Desktop/Fortune_Screenshots/Android/`
- 개수: 7-8개
- 해상도: 1080×1920

### 🏷️ 분류

```
앱 카테고리: 라이프스타일
태그:
  - 운세
  - 사주
  - 타로
  - AI
  - 개인화
```

### 📧 연락처 정보

```
이메일: support@zpzg.co.kr
전화번호: +82-70-1234-5678 (선택)
웹사이트: https://zpzg.co.kr (선택)
```

---

## 7. 심사 제출

### 📦 Step 1: AAB 업로드

**경로**: Google Play Console → Fortune → 프로덕션 → 새 출시 만들기

1. **AAB 파일 업로드**
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

2. **출시 이름**
   ```
   1.0.0 (Build 2) - 첫 번째 출시
   ```

3. **출시 노트 (한국어)**
   ```
   🎉 Fortune 앱의 첫 번째 출시입니다!

   ✨ 주요 기능:
   • AI 기반 개인 맞춤형 운세 생성
   • 오늘의 운세, 연애운, 사업운, 건강운 등 다양한 운세
   • 생년월일과 출생시간 기반 정확한 분석
   • 간편한 소셜 로그인 (Google, Apple, Kakao, Naver)
   • 다크모드 지원
   • 깔끔하고 직관적인 UI/UX

   🔮 지원하는 운세:
   • 일일 운세
   • 연애운
   • 사업운
   • 건강운
   • 재물운
   • 종합운세

   📱 지금 바로 다운로드하고
   AI가 분석하는 나만의 운세를 확인해보세요!
   ```

### ✅ Step 2: 심사 전 체크리스트

- [ ] AAB 파일 업로드 완료
- [ ] 스크린샷 7-8개 업로드 완료
- [ ] 개인정보 처리방침 URL 입력 완료
- [ ] 데이터 보안 설정 완료
- [ ] 앱 설명 작성 완료
- [ ] 연락처 정보 입력 완료
- [ ] 콘텐츠 등급 설정 완료
- [ ] 타겟 국가 선택 완료 (대한민국, 기타)

### 🚀 Step 3: 심사 제출

1. **검토 및 출시**
   - Google Play Console → Fortune → 프로덕션 → 검토
   - 모든 항목 확인
   - "프로덕션으로 출시 시작" 클릭

2. **예상 심사 기간**
   - 일반적으로 1-3일
   - 최대 7일

3. **심사 결과 확인**
   - 이메일 알림
   - Google Play Console 대시보드

---

## 📊 심사 후 모니터링

### 📈 주요 지표

**경로**: Google Play Console → Fortune → 대시보드

- **다운로드 수**: 일/주/월별 다운로드
- **평점**: 사용자 평균 평점
- **리뷰**: 사용자 피드백
- **비정상 종료율**: 앱 안정성
- **ANR율**: 응답 없음 비율

### 🔧 유지보수

- 사용자 리뷰 모니터링
- 비정상 종료 로그 분석
- 정기 업데이트 배포
- 보안 패치 적용

---

## 🔗 유용한 링크

**Google Play Console**
- 콘솔: https://play.google.com/console
- 정책 센터: https://play.google.com/about/developer-content-policy/
- 도움말: https://support.google.com/googleplay/android-developer

**개발자 도구**
- Bundletool: https://developer.android.com/studio/command-line/bundletool
- Firebase Console: https://console.firebase.google.com
- AdMob: https://apps.admob.com

**문서**
- Android 개발자 가이드: https://developer.android.com/guide
- Flutter 배포 가이드: https://docs.flutter.dev/deployment/android

---

## 📞 문의

**앱 관련 문의:**
- 이메일: support@zpzg.co.kr
- 개인정보: privacy@zpzg.co.kr

**Google Play 지원:**
- Google Play Console 고객센터

---

**작성자**: Claude Code
**작성일**: 2025년 1월 6일
**문서 위치**: `/docs/deployment/GOOGLE_PLAY_SUBMISSION_GUIDE.md`
