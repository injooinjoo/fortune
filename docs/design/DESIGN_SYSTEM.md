# Fortune App Design System v1.0

## 목차
1. [디자인 철학](#디자인-철학)
2. [색상 시스템](#색상-시스템)
3. [타이포그래피](#타이포그래피)
4. [컴포넌트 가이드](#컴포넌트-가이드)
5. [레이아웃 시스템](#레이아웃-시스템)
6. [페이지 구조](#페이지-구조)
7. [다크모드 가이드](#다크모드-가이드)
8. [애니메이션 가이드](#애니메이션-가이드)
9. [데이터 표시 규칙](#데이터-표시-규칙)
10. [접근성 가이드](#접근성-가이드)

---

## 디자인 철학

### 핵심 원칙
Fortune 앱의 디자인은 Toss의 디자인 철학을 기반으로 합니다:

1. **명확성 (Clarity)**: 모든 요소는 명확한 목적을 가져야 합니다
2. **일관성 (Consistency)**: 전체 앱에서 일관된 경험을 제공합니다
3. **간결성 (Simplicity)**: 불필요한 요소를 제거하고 핵심에 집중합니다
4. **신뢰성 (Reliability)**: 사용자가 예측 가능한 경험을 할 수 있도록 합니다
5. **즐거움 (Delight)**: 미세한 인터랙션으로 사용의 즐거움을 제공합니다

### 디자인 목표
- 운세와 타로를 현대적이고 세련되게 표현
- 젊은 세대가 친숙하게 느낄 수 있는 인터페이스
- 빠르고 부드러운 사용자 경험
- 다크모드에서도 완벽한 가독성

---

## 색상 시스템

### 1. 기본 색상 팔레트

#### 라이트 모드
```
Primary Colors:
- primary: #000000 (Pure Black)
- primaryLight: #333333 (Dark Gray)
- primaryDark: #1A1A1A (Very Dark Gray)

Secondary Colors (Instagram Accent):
- secondary: #F56040 (Orange)
- secondaryLight: #FD1D1D (Red)
- secondaryDark: #E1306C (Magenta)

Background Colors:
- background: #FAFAFA (Light Gray)
- cardBackground: #F6F6F6 (Card Container)
- cardSurface: #FFFFFF (Card Surface)
```

#### 다크 모드
```
Primary Colors:
- primary: #FFFFFF (Pure White)
- primaryLight: #E0E0E0 (Light Gray)
- primaryDark: #CCCCCC (Lighter Gray)

Secondary Colors: (동일)
- secondary: #F56040
- secondaryLight: #FD1D1D
- secondaryDark: #E1306C

Background Colors:
- background: #000000 (Pure Black)
- cardBackground: #0A0A0A (Very Dark)
- cardSurface: #1C1C1C (Dark Surface)
```

### 2. 시멘틱 색상

#### 상태 색상
```
Success:
- Light: #28A745
- Dark: #34D399

Error:
- Light: #DC3545
- Dark: #F87171

Warning:
- Light: #FFC107
- Dark: #FBBF24

Info:
- Light: #17A2B8
- Dark: #60A5FA
```

### 3. 텍스트 색상
```
Light Mode:
- textPrimary: #262626
- textSecondary: #8E8E8E
- textLight: #C7C7C7

Dark Mode:
- textPrimary: #F5F5F5
- textSecondary: #B0B0B0
- textLight: #808080
```

### 4. 그라데이션
```dart
// 메인 그라데이션
primaryGradient: [#000000, #333333, #666666]

// 배경 그라데이션
backgroundGradient: [#000000, #2C2C2C, #4A4A4A, #666666]
```

### 5. 운세별 시그니처 색상
각 운세 타입별로 고유한 색상을 정의하되, 모노톤 테마를 유지:
- 타로: #333333 (Dark Gray)
- 사주: #1A1A1A (Very Dark)
- 별자리: #4A4A4A (Medium Gray)
- 혈액형: #666666 (Light Gray)

---

## 타이포그래피

### 1. 폰트 패밀리
**Toss Product Sans** - 모든 텍스트에 사용

### 2. 텍스트 스타일 정의

#### Display (화면 제목)
```
display1: 48px, Bold, -0.02em
display2: 36px, Bold, -0.01em
display3: 28px, Bold, 0em
```

#### Headline (섹션 제목)
```
headline1: 24px, SemiBold, 0em
headline2: 20px, SemiBold, 0em
headline3: 18px, Medium, 0em
```

#### Body (본문)
```
body1: 16px, Regular, 0em, 1.6 line-height
body2: 15px, Regular, 0em, 1.6 line-height
body3: 14px, Regular, 0em, 1.6 line-height
```

#### Label (라벨)
```
label1: 15px, Medium, 0em
label2: 14px, Medium, 0em
label3: 13px, Medium, 0em
```

#### Caption (캡션)
```
caption1: 13px, Regular, 0em
caption2: 12px, Regular, 0em
caption3: 11px, Regular, 0em
```

### 3. 숫자 표기 규칙
- 모든 숫자는 Tabular Figures 사용
- 천 단위 구분: 쉼표 사용 (1,000)
- 소수점: 최대 2자리까지 표시
- 금액: ₩ 기호 + 숫자

---

## 컴포넌트 가이드

### 1. 버튼 시스템

#### Primary Button (주요 액션)
```
높이: 56px
패딩: 좌우 32px
Border Radius: 16px
폰트: 16px, SemiBold
배경색: Primary Color
텍스트색: 반대 색상
```

#### Secondary Button (보조 액션)
```
높이: 48px
패딩: 좌우 24px
Border Radius: 12px
폰트: 15px, Medium
배경색: Transparent
Border: 1px, Primary Color
```

#### Text Button (텍스트 버튼)
```
높이: 40px
패딩: 좌우 16px
폰트: 14px, Medium
배경색: None
텍스트색: Primary Color
```

#### Floating Action Button
```
크기: 56x56px
Border Radius: 16px
Shadow: 0px 4px 12px rgba(0,0,0,0.15)
아이콘 크기: 24px
```

### 2. 카드 시스템

#### Base Card
```
Border Radius: 16px
패딩: 16px
배경색: cardSurface
Shadow: 0px 2px 8px rgba(0,0,0,0.08)
```

#### Section Card
```
Border Radius: 16px
헤더 패딩: 20px
콘텐츠 패딩: 16px
헤더 배경: Primary Color 5% opacity
```

#### Glass Card
```
Border Radius: 24px
Backdrop Blur: 20px
Border: 1px solid rgba(255,255,255,0.1)
배경: Linear Gradient with opacity
```

### 3. 입력 필드

#### Text Input
```
높이: 48px
Border Radius: 8px
Border: 1px solid divider
패딩: 좌우 12px
폰트: 14px, Regular
Focus Border: Primary Color
```

#### Select/Dropdown
```
높이: 48px
Border Radius: 8px
화살표 아이콘: 오른쪽 12px
```

### 4. 네비게이션

#### Bottom Navigation
```
높이: 56px + Safe Area
아이템 개수: 최대 5개
아이콘 크기: 24px
라벨 폰트: 12px, Medium
선택 색상: Primary
미선택 색상: textSecondary
```

#### App Bar
```
높이: 56px
제목: 18px, SemiBold
배경: Transparent
뒤로가기 아이콘: 24px
```

### 5. 모달 & 다이얼로그

#### Bottom Sheet
```
Border Radius: Top 24px
핸들바: 4x40px, 상단 12px
최소 높이: 200px
최대 높이: 화면의 90%
```

#### Dialog
```
Border Radius: 16px
패딩: 24px
최대 너비: 280px
버튼 높이: 48px
```

### 6. 토스트 & 스낵바

#### Toast
```
Border Radius: 8px
패딩: 12px 16px
폰트: 14px, Regular
배경: rgba(0,0,0,0.9)
위치: 하단 80px
```

---

## 레이아웃 시스템

### 1. 간격 시스템 (8px 그리드)
```
spacing-0: 0px
spacing-1: 4px
spacing-2: 8px
spacing-3: 12px
spacing-4: 16px
spacing-5: 20px
spacing-6: 24px
spacing-8: 32px
spacing-10: 40px
spacing-12: 48px
spacing-16: 64px
```

### 2. 그리드 시스템
- 기본 컬럼: 12 columns
- Gutter: 16px
- Margin: 16px (모바일), 24px (태블릿)

### 3. 반응형 브레이크포인트
```
Mobile: 0-599px
Tablet: 600-1023px
Desktop: 1024px+
```

### 4. Safe Area
- 상단: StatusBar + 8px
- 하단: NavigationBar + 8px
- 좌우: 16px (기본)

---

## 페이지 구조

### 1. 기본 페이지 레이아웃
```
AppBar (옵션)
  └─ ScrollView
      ├─ Header Section
      ├─ Content Sections
      └─ Bottom Padding (80px)
```

### 2. 리스트 페이지
```
AppBar with Title
  └─ ListView
      ├─ Section Headers (Sticky)
      ├─ List Items
      └─ Load More Indicator
```

### 3. 상세 페이지
```
CustomScrollView
  ├─ SliverAppBar (Collapsible)
  ├─ Hero Image/Header
  ├─ Content Cards
  └─ Action Buttons (Fixed Bottom)
```

### 4. 폼 페이지
```
AppBar with Close/Save
  └─ ScrollView
      ├─ Form Sections
      ├─ Input Fields
      ├─ Helper Text
      └─ Submit Button (Sticky Bottom)
```

---

## 다크모드 가이드

### 1. 색상 전환 규칙
- Primary Colors: 반전 (Black ↔ White)
- Secondary Colors: 동일 유지
- Background: 명도 반전
- Text Colors: 대비 유지

### 2. 이미지 처리
- 아이콘: 색상 반전 또는 다크모드 전용 아이콘
- 일러스트: opacity 조정 또는 다크모드 버전
- 사진: 밝기 80%로 조정

### 3. 그림자 처리
- Light Mode: rgba(0,0,0,0.08-0.15)
- Dark Mode: rgba(0,0,0,0.3-0.5)

---

## 애니메이션 가이드

### 1. 기본 애니메이션 값
```
Duration:
- Micro: 100ms (호버, 탭)
- Short: 200ms (페이드, 슬라이드)
- Medium: 300ms (확장, 축소)
- Long: 500ms (페이지 전환)

Easing:
- Standard: cubic-bezier(0.4, 0.0, 0.2, 1)
- Decelerate: cubic-bezier(0.0, 0.0, 0.2, 1)
- Accelerate: cubic-bezier(0.4, 0.0, 1, 1)
```

### 2. 페이지 전환
- 기본: Slide + Fade
- 모달: Slide Up
- 탭: Fade Only

### 3. 마이크로 인터랙션
- 버튼 탭: Scale 0.95
- 카드 호버: Elevation 증가
- 로딩: Skeleton or Shimmer

### 4. 제스처 피드백
- 탭: Ripple Effect
- 스와이프: Follow Finger
- 당겨서 새로고침: Bounce Effect

---

## 데이터 표시 규칙

### 1. 날짜/시간 표시
```
날짜:
- 오늘: "오늘"
- 어제: "어제"
- 이번주: "월요일"
- 올해: "1월 15일"
- 작년: "2023년 1월 15일"

시간:
- 12시간제: "오후 3:30"
- 24시간제: "15:30"
- 상대시간: "3분 전", "1시간 전"
```

### 2. 숫자 표시
```
일반 숫자:
- 1,000 (천 단위 구분)
- 1.5K (1,500 이상)
- 10.2M (백만 단위)

금액:
- ₩1,000
- ₩1.5만 (만원 단위)
- ₩3.2억 (억원 단위)

백분율:
- 85%
- 12.5%
- 0.1%
```

### 3. 상태 표시
```
로딩: Skeleton / Spinner
비어있음: 일러스트 + 설명 텍스트
오류: 아이콘 + 설명 + 재시도 버튼
성공: 체크 아이콘 + 메시지
```

---

## 접근성 가이드

### 1. 색상 대비
- 일반 텍스트: 4.5:1 이상
- 큰 텍스트(18px+): 3:1 이상
- 아이콘: 3:1 이상

### 2. 터치 영역
- 최소 크기: 44x44px
- 권장 크기: 48x48px
- 간격: 최소 8px

### 3. 텍스트 가독성
- 최소 폰트 크기: 12px
- 줄 높이: 1.5-1.8
- 단락 간격: 폰트 크기의 1.5배

### 4. 스크린 리더
- 모든 이미지에 대체 텍스트
- 의미있는 버튼 레이블
- 논리적인 포커스 순서

---

## 디자인 토큰

### 1. 파일 구조
```
/core/theme/
  ├── app_colors.dart (색상 정의)
  ├── app_typography.dart (텍스트 스타일)
  ├── app_spacing.dart (간격 상수)
  ├── app_animations.dart (애니메이션 값)
  └── app_dimensions.dart (크기 상수)
```

### 2. 네이밍 규칙
- 색상: colorPurpose (예: textPrimary)
- 간격: spacingSize (예: spacing4)
- 크기: sizeComponent (예: buttonHeightLarge)
- 애니메이션: durationPurpose (예: durationPageTransition)

---

## 구현 체크리스트

### Phase 1: 기초 설정 (1개월)
- [ ] 색상 시스템 통합
- [ ] 타이포그래피 시스템 구현
- [ ] 기본 컴포넌트 라이브러리
- [ ] 다크모드 지원

### Phase 2: 컴포넌트 확장 (2개월)
- [ ] 모든 버튼 스타일
- [ ] 카드 시스템 완성
- [ ] 폼 컴포넌트
- [ ] 네비게이션 패턴

### Phase 3: 페이지 표준화 (3개월)
- [ ] 모든 페이지 리팩토링
- [ ] 애니메이션 통합
- [ ] 반응형 레이아웃
- [ ] 성능 최적화

### Phase 4: 고급 기능 (2개월)
- [ ] 제스처 시스템
- [ ] 고급 애니메이션
- [ ] 접근성 개선
- [ ] 테마 커스터마이징

---

## 버전 관리

### v1.0 (Current)
- 기본 디자인 시스템 정립
- Toss 스타일 가이드라인
- 다크모드 지원

### v1.1 (Planned)
- 컴포넌트 라이브러리 확장
- 애니메이션 시스템 강화
- 접근성 개선

### v2.0 (Future)
- 디자인 토큰 자동화
- Figma 연동
- 스토리북 구축

---

이 문서는 Fortune 앱의 모든 디자인 결정의 기준이 되며, 지속적으로 업데이트됩니다.
마지막 업데이트: 2024년 12월