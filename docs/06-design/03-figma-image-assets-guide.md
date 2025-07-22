# Fortune App - Image Assets Export Guide

## SVG 파일 목록 및 내보내기 가이드

Fortune 앱의 Flutter 프로젝트에서 사용하는 SVG 파일들을 Figma에서 사용하기 위한 가이드입니다.

## 1. 로고 파일

### 1.1 main_logo.svg
- **위치**: `/assets/images/main_logo.svg`
- **용도**: 앱 메인 로고
- **크기**: 100×100px
- **색상**: 단색 (Figma에서 색상 변경 가능하도록)

### 1.2 splash_logo.svg
- **위치**: `/assets/images/splash_logo.svg`
- **용도**: 스플래시 화면 로고
- **크기**: 200×200px

### 1.3 splash_logo_dark.svg
- **위치**: `/assets/images/splash_logo_dark.svg`
- **용도**: 다크모드 스플래시 로고
- **크기**: 200×200px

## 2. 소셜 로그인 아이콘

### 2.1 Google
- **위치**: `/assets/images/social/google.svg`
- **크기**: 24×24px
- **특징**: 풀컬러 Google 로고

### 2.2 Apple
- **위치**: `/assets/images/social/apple.svg`
- **크기**: 24×24px
- **색상**: 검은색 (모노크롬)

### 2.3 Kakao
- **위치**: `/assets/images/social/kakao.svg`
- **크기**: 24×24px
- **특징**: 카카오 말풍선 로고

### 2.4 Naver
- **위치**: `/assets/images/social/naver.svg`
- **크기**: 24×24px
- **특징**: 네이버 N 로고

### 2.5 Instagram
- **위치**: `/assets/images/social/instagram.svg`
- **크기**: 24×24px
- **특징**: 인스타그램 카메라 로고

### 2.6 TikTok
- **위치**: `/assets/images/social/tiktok.svg`
- **크기**: 24×24px
- **색상**: 검은색 (모노크롬)

## 3. Fortune 카드 이미지 (PNG)

주요 운세 카드 이미지들 (PNG 형식):

### 카테고리별 대표 이미지
1. **daily_fortune.png** - 오늘의 운세
2. **saju_fortune.png** - 사주팔자
3. **zodiac_fortune.png** - 띠 운세
4. **love_fortune.png** - 연애운
5. **chemistry_fortune.png** - 궁합운
6. **marriage_fortune.png** - 결혼운
7. **career_fortune.png** - 직업운
8. **money_fortune.png** - 재물운
9. **health_fortune.png** - 건강운
10. **tarot_fortune.png** - 타로 운세

### 랜덤 썸네일 이미지
- **thumbnail_1.jpg ~ thumbnail_8.jpg**
- **용도**: 운세 카드의 배경 이미지로 랜덤 사용
- **크기**: 정사각형 (인스타그램 스타일)

## 4. Figma에서 SVG 가져오기

### 4.1 SVG 파일 준비
1. Flutter 프로젝트의 assets 폴더에서 SVG 파일 복사
2. 필요시 Adobe Illustrator나 Inkscape로 정리

### 4.2 Figma로 가져오기
1. Figma에서 드래그 앤 드롭으로 SVG 임포트
2. 또는 Copy & Paste로 직접 붙여넣기
3. Place Image (Shift + Cmd + K)로 가져오기

### 4.3 SVG 최적화
1. 불필요한 그룹 해제
2. 색상을 Figma Color Style로 변경
3. 컴포넌트로 변환하여 재사용

## 5. 아이콘 폰트 대체

Flutter 코드에서 사용하는 Material Icons를 Figma 아이콘으로 대체:

### 주요 아이콘 매핑
- `Icons.dark_mode_outlined` → Figma의 Moon 아이콘
- `Icons.light_mode_outlined` → Figma의 Sun 아이콘
- `Icons.arrow_back_ios` → Figma의 Arrow Left 아이콘
- `Icons.chevron_down` → Figma의 Chevron Down 아이콘
- `Icons.calendar_today` → Figma의 Calendar 아이콘
- `Icons.favorite` → Figma의 Heart 아이콘
- `Icons.share` → Figma의 Share 아이콘

## 6. 이미지 자산 구성

Figma 파일 내 구조:
```
Assets
├── Logos
│   ├── main_logo
│   ├── splash_logo
│   └── splash_logo_dark
├── Social Icons
│   ├── google
│   ├── apple
│   ├── kakao
│   ├── naver
│   ├── instagram
│   └── tiktok
├── Fortune Cards
│   ├── Daily
│   ├── Love
│   ├── Career
│   └── ...
└── Icons
    ├── UI Icons
    └── Category Icons
```

## 7. 내보내기 설정

### SVG 내보내기 옵션
- **Format**: SVG
- **Include "id" attribute**: Off
- **Outline text**: On (폰트 의존성 제거)
- **Include fill/stroke**: On

### PNG 내보내기 옵션
- **Format**: PNG
- **Size**: 2x, 3x (iOS), xxhdpi, xxxhdpi (Android)
- **Background**: Transparent

## 8. 색상 처리

### 모노크롬 아이콘
- Figma에서 Union으로 합치기
- Fill을 단일 색상으로 설정
- Flutter에서 ColorFilter로 색상 변경 가능

### 풀컬러 아이콘
- 원본 색상 유지
- 브랜드 가이드라인 준수

## 체크리스트

### 필수 SVG 자산
- [ ] main_logo.svg
- [ ] google.svg
- [ ] apple.svg
- [ ] kakao.svg
- [ ] naver.svg
- [ ] instagram.svg
- [ ] tiktok.svg

### 선택 PNG 자산
- [ ] Fortune 카드 대표 이미지들
- [ ] 랜덤 썸네일 이미지들

### Figma 설정
- [ ] 모든 SVG를 컴포넌트로 변환
- [ ] Color override 가능하도록 설정
- [ ] 적절한 네이밍 규칙 적용

이 가이드를 참고하여 Flutter 앱의 이미지 자산을 Figma 디자인 시스템에 통합하세요.