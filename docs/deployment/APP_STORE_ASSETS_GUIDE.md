# App Store 에셋 준비 가이드

**프로젝트**: Fortune - AI 운세 앱
**플랫폼**: iOS App Store
**목적**: 앱 스토어 등록에 필요한 모든 그래픽 에셋 준비

---

## 📋 목차

1. [필수 에셋 체크리스트](#1-필수-에셋-체크리스트)
2. [앱 아이콘](#2-앱-아이콘)
3. [스크린샷](#3-스크린샷)
4. [앱 미리보기 비디오](#4-앱-미리보기-비디오-선택사항)
5. [프로모션 이미지](#5-프로모션-이미지-선택사항)

---

## 1. 필수 에셋 체크리스트

### iOS App Store 필수 항목

- [ ] **앱 아이콘** - 1024x1024px PNG
- [ ] **iPhone 6.7" 스크린샷** - 1290x2796px (최소 1개, 최대 10개)
- [ ] **iPhone 6.5" 스크린샷** - 1242x2688px (최소 1개, 최대 10개)
- [ ] **iPad Pro 12.9" 스크린샷** (선택사항) - 2048x2732px

### 권장 항목

- [ ] **앱 미리보기 비디오** - 30초 이내
- [ ] **다국어 스크린샷** - 한국어, 영어
- [ ] **다크모드 스크린샷** - 추가 변형

---

## 2. 앱 아이콘

### 사양

```yaml
크기: 1024 x 1024 pixels
형식: PNG (투명 배경 없음)
색상 공간: RGB
DPI: 72 (또는 144, 300)
알파 채널: 없음 (불투명)
```

### 디자인 가이드라인

**DO ✅**
- 단순하고 인식 가능한 디자인
- 브랜드 색상 사용
- 정사각형 형태 (라운드 코너는 시스템이 자동 적용)
- 고해상도 이미지 사용

**DON'T ❌**
- 텍스트 포함 (특히 작은 텍스트)
- 투명 배경 사용
- 사진 배경 사용
- 복잡한 디테일

### 현재 아이콘 확인

```bash
# 현재 앱 아이콘 위치
ls -lh ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png

# 크기 확인
sips -g pixelWidth -g pixelHeight ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png
```

### 아이콘 생성 도구

**온라인 도구:**
- [App Icon Generator](https://appicon.co/)
- [MakeAppIcon](https://makeappicon.com/)
- [IconKitchen](https://icon.kitchen/)

**디자인 도구:**
- Paper (공식 디자인 SoT 참조)
- Sketch
- Adobe Illustrator
- Canva

---

## 3. 스크린샷

### 필수 크기

#### iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max)

```yaml
크기: 1290 x 2796 pixels (세로)
비율: 9:19.5
개수: 최소 1개, 최대 10개
형식: PNG 또는 JPG
최대 파일 크기: 500MB
```

#### iPhone 6.5" (iPhone 11 Pro Max, XS Max)

```yaml
크기: 1242 x 2688 pixels (세로)
비율: 9:19.5
개수: 최소 1개, 최대 10개
형식: PNG 또는 JPG
최대 파일 크기: 500MB
```

### 권장 스크린샷 구성

#### 1. 랜딩 페이지 (Landing Page)
```
목적: 앱의 첫인상
포함 요소:
- 앱 로고
- "시작하기" 버튼
- 주요 메시지: "AI가 알려주는 나만의 운세"
```

#### 2. 로그인 화면 (Login Screen)
```
목적: 간편한 로그인 옵션 강조
포함 요소:
- 소셜 로그인 버튼 (Google, Apple, Kakao, Naver)
- "이메일로 계속하기" 옵션
```

#### 3. 메인 대시보드 (Main Dashboard)
```
목적: 다양한 운세 카테고리 표시
포함 요소:
- 오늘의 운세
- 연애운
- 사업운
- 건강운
- 타로 카드
```

#### 4. 운세 생성 - 정보 입력 (Fortune Input)
```
목적: 개인화된 정보 수집 화면
포함 요소:
- 생년월일 입력
- 출생 시간 입력
- 출생 지역 선택
```

#### 5. 운세 결과 (Fortune Result)
```
목적: AI 분석 결과 표시
포함 요소:
- 개인화된 운세 내용
- 종합 점수
- 세부 분석 (연애, 재물, 건강, 사업)
```

#### 6. 프로필 설정 (Profile Settings)
```
목적: 개인화 기능 강조
포함 요소:
- 사용자 정보
- 알림 설정
- 테마 설정 (라이트/다크)
```

#### 7. 다크 모드 (Dark Mode)
```
목적: 다크 모드 지원 강조
포함 요소:
- 메인 화면의 다크 모드 버전
```

### 스크린샷 캡처 방법

#### iOS 시뮬레이터 사용

```bash
# iPhone 14 Pro Max 시뮬레이터 실행
open -a Simulator

# 시뮬레이터에서 디바이스 선택:
# Hardware > Device > iOS 17.x > iPhone 14 Pro Max

# 앱 실행
flutter run -d "iPhone 14 Pro Max"

# 스크린샷 캡처 (시뮬레이터에서)
# File > New Screen Shot
# 또는 Command + S

# 명령어로 캡처
xcrun simctl io booted screenshot ~/Desktop/screenshot.png
```

#### 실제 디바이스 사용

```bash
# 실제 iPhone에서
# 볼륨 업 + 사이드 버튼 동시 클릭

# 또는 QuickTime Player 사용:
# 1. QuickTime Player 실행
# 2. File > New Movie Recording
# 3. 카메라 옆 화살표 클릭 > iPhone 선택
# 4. 화면 녹화 중 스크린샷 캡처
```

### 스크린샷 편집

#### 텍스트 오버레이 추가

각 스크린샷에 기능 설명 텍스트를 추가하여 더 효과적으로 전달:

```yaml
랜딩 페이지:
  텍스트: "AI 기반 개인 맞춤형 운세"
  위치: 상단 1/3

로그인 화면:
  텍스트: "간편한 소셜 로그인"
  위치: 하단 1/3

메인 대시보드:
  텍스트: "다양한 운세 카테고리"
  위치: 상단

운세 결과:
  텍스트: "정확한 AI 분석"
  위치: 중앙
```

#### 디자인 팁

**일관성:**
- 모든 스크린샷에 동일한 폰트 사용
- 브랜드 색상 유지
- 동일한 레이아웃 구조

**가독성:**
- 큰 폰트 크기 (최소 36pt)
- 높은 대비 색상
- 짧고 명확한 문구

**시각적 매력:**
- 실제 앱 UI 사용
- 고품질 이미지
- 시각적 계층 구조

### 스크린샷 편집 도구

**온라인 도구:**
- [Screenshot.rocks](https://screenshot.rocks/)
- [AppLaunchpad](https://theapplaunchpad.com/)
- [Previewed](https://previewed.app/)

**디자인 도구:**
- Paper (레이아웃 기준), Canva (목업 템플릿)
- Sketch
- Adobe Photoshop
- Canva (App Store Screenshot 템플릿)

### 스크린샷 파일명 규칙

```
fortune_screenshot_01_landing.png
fortune_screenshot_02_login.png
fortune_screenshot_03_dashboard.png
fortune_screenshot_04_input.png
fortune_screenshot_05_result.png
fortune_screenshot_06_profile.png
fortune_screenshot_07_darkmode.png
```

---

## 4. 앱 미리보기 비디오 (선택사항)

### 사양

```yaml
길이: 15-30초 권장
해상도:
  - iPhone 6.7": 886x1920 또는 1080x1920
  - iPhone 6.5": 886x1920 또는 1080x1920
파일 형식: .mov, .m4v, .mp4
코덱: H.264 또는 HEVC
최대 파일 크기: 500MB
```

### 콘텐츠 구성

**인트로 (0-3초)**
- 앱 로고 애니메이션
- 앱 이름: Fortune

**주요 기능 시연 (3-25초)**
1. 로그인 화면 (2초)
2. 메인 대시보드 탐색 (3초)
3. 운세 정보 입력 (3초)
4. 운세 결과 생성 애니메이션 (4초)
5. 결과 화면 스크롤 (3초)
6. 다크 모드 전환 (2초)

**아웃트로 (25-30초)**
- "지금 다운로드하세요" 메시지
- 앱 로고

### 촬영 방법

**iOS 시뮬레이터 녹화:**

```bash
# 시뮬레이터 실행
open -a Simulator

# 녹화 시작 (QuickTime Player)
# QuickTime Player > File > New Screen Recording
# 시뮬레이터 영역만 선택

# 또는 명령어로:
xcrun simctl io booted recordVideo fortune_preview.mov
# 종료: Ctrl+C
```

**실제 디바이스 녹화:**

```bash
# QuickTime Player 사용:
# 1. iPhone을 Mac에 연결
# 2. QuickTime Player > File > New Movie Recording
# 3. 카메라 선택 > iPhone
# 4. 녹화 버튼 클릭
```

### 편집 도구

**macOS 기본 도구:**
- iMovie (무료)
- Final Cut Pro

**온라인 도구:**
- [Kapwing](https://www.kapwing.com/)
- [Clipchamp](https://clipchamp.com/)

**전문 도구:**
- Adobe Premiere Pro
- DaVinci Resolve (무료)

---

## 5. 프로모션 이미지 (선택사항)

### Feature Graphic (Android용)

iOS에는 직접적인 Feature Graphic이 없지만, 웹사이트 및 마케팅에 사용:

```yaml
크기: 1024 x 500 pixels
형식: PNG 또는 JPG
내용:
  - 앱 이름: Fortune
  - 태그라인: "AI가 알려주는 나만의 운세"
  - 주요 기능 아이콘
  - 브랜드 색상 배경
```

### 소셜 미디어 이미지

```yaml
Facebook/Instagram:
  크기: 1200 x 630 pixels
  형식: PNG 또는 JPG

Twitter:
  크기: 1200 x 675 pixels
  형식: PNG 또는 JPG

App Store 프로모션:
  크기: 1200 x 600 pixels
  형식: PNG 또는 JPG
```

---

## 📋 최종 체크리스트

### 파일 확인

- [ ] 앱 아이콘 1024x1024 PNG
- [ ] iPhone 6.7" 스크린샷 7개
- [ ] iPhone 6.5" 스크린샷 7개
- [ ] 앱 미리보기 비디오 (선택사항)

### 품질 확인

- [ ] 모든 이미지가 선명함 (블러 없음)
- [ ] 텍스트가 읽기 쉬움
- [ ] 브랜드 일관성 유지
- [ ] 파일 크기가 요구사항 충족
- [ ] 파일 형식이 올바름

### 콘텐츠 확인

- [ ] 앱의 주요 기능 모두 표시됨
- [ ] 스크린샷이 최신 버전 UI 반영
- [ ] 개인정보나 민감한 데이터 없음
- [ ] 다국어 버전 준비 (필요 시)

---

## 📂 파일 구조

```
assets/
└── app_store/
    ├── icon/
    │   └── app_icon_1024.png
    ├── screenshots/
    │   ├── iphone_6.7/
    │   │   ├── 01_landing.png
    │   │   ├── 02_login.png
    │   │   ├── 03_dashboard.png
    │   │   ├── 04_input.png
    │   │   ├── 05_result.png
    │   │   ├── 06_profile.png
    │   │   └── 07_darkmode.png
    │   └── iphone_6.5/
    │       └── (동일한 7개 파일)
    ├── preview/
    │   └── app_preview.mov
    └── promo/
        └── feature_graphic.png
```

---

## 🔧 유용한 명령어

```bash
# 이미지 크기 확인
sips -g pixelWidth -g pixelHeight image.png

# 이미지 리사이즈
sips -z 1290 2796 input.png --out output.png

# 여러 이미지 일괄 리사이즈
for file in *.png; do
  sips -z 1290 2796 "$file" --out "resized_$file"
done

# PNG 최적화 (파일 크기 감소)
pngquant --quality=80-95 image.png
```

---

## 📞 도움말

**에셋 생성 도움이 필요하면:**
- 디자인팀 문의: design@zpzg.co.kr
- 기술팀 문의: developer@zpzg.co.kr

**유용한 리소스:**
- [App Store Screenshot Guidelines](https://developer.apple.com/app-store/product-page/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [App Preview Specifications](https://developer.apple.com/help/app-store-connect/manage-app-previews/)

---

**작성일**: 2025년 10월
**문서 버전**: 1.0
**유지보수**: Fortune 디자인팀
