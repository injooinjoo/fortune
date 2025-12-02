# Figma AI (Make Designs) 프롬프트 모음

Fortune 앱의 각 화면/컴포넌트를 Figma AI로 생성하기 위한 프롬프트입니다.
Figma에서 `Cmd+/` → "Make Designs" 또는 Actions 메뉴에서 사용하세요.

---

## 📱 디자인 시스템 기본 정보

모든 프롬프트에 이 정보를 참고하세요:
- **스타일**: Toss 앱 스타일, 미니멀, 깔끔한 한국 금융 앱
- **프레임 사이즈**: 430×932 (iPhone 14 Pro Max)
- **메인 컬러**: #1F4EF5 (파란색), #191F28 (다크 텍스트)
- **배경색**: #FFFFFF (라이트), #17171C (다크)
- **폰트**: Pretendard (또는 SF Pro)
- **모서리**: 12-16px radius
- **그림자**: 부드러운 그림자, 4-8% 투명도

---

## 🏠 핵심 화면 프롬프트

### 1. Landing Page (랜딩)

```
Create a mobile app landing page in Toss/Korean fintech style:

- Full screen gradient background: deep purple (#1a1a2e) to dark blue (#16213e)
- Centered content with constellation/star pattern overlay (subtle, 10% opacity)
- Main title: "오늘의 운세" in large white text (50px, bold)
- Subtitle: "AI가 분석하는 나만의 운세" in gray (#9CA3AF, 17px)
- Primary CTA button: rounded blue (#1F4EF5), white text "시작하기", full width with 24px padding
- Secondary link below: "이미 계정이 있으신가요? 로그인" in light gray
- Bottom safe area padding

Style: Clean, minimal, premium Korean app feel
Frame: 430x932
```

### 2. Home Page (홈 - 스토리 스타일)

```
Create a mobile home screen with horizontal story cards like Instagram/Toss:

Header:
- Safe area top padding
- Left: App logo or "Fortune" text
- Right: Notification bell icon, Profile avatar (32px circle)

Story Section (horizontal scroll):
- 5-6 circular avatars (64px) with gradient ring borders
- Labels below each: "일일운세", "타로", "궁합", "꿈해몽", "건강운"
- Active indicator ring in blue (#1F4EF5)

Main Content:
- Section title: "오늘의 추천" (20px, bold)
- Large feature card (full width, 200px height):
  - Gradient background (purple to blue)
  - Icon or illustration
  - Title: "오늘의 운세 확인하기"
  - Arrow indicator

- Grid of fortune cards (2 columns):
  - Each card: white background, 12px radius, subtle shadow
  - Icon (40px), Title, Brief description
  - Cards: 타로, 궁합, MBTI운세, 꿈해몽

Bottom Navigation:
- 4 tabs: 홈, 운세, 트렌드, 프로필
- Active tab in blue with filled icon

Frame: 430x932, Light theme
```

### 3. Fortune List (운세 목록)

```
Create a mobile fortune/horoscope list page in Toss style:

Header:
- Back button (left arrow)
- Title: "전체 운세" (centered, 20px bold)
- Filter icon (right)

Search Bar:
- Rounded search input with gray background (#F5F5F5)
- Search icon, placeholder "운세 검색"

Category Tabs (horizontal scroll):
- Pills/chips: "전체", "기본운", "사랑운", "재물운", "건강운"
- Active tab: blue background (#1F4EF5), white text
- Inactive: gray background, dark text

Fortune Cards Grid (2 columns):
Each card contains:
- White background, 16px radius, soft shadow
- Top: Emoji or icon (32px)
- Title: "일일 운세", "타로 카드" etc (16px bold)
- Description: 1-2 lines (14px gray)
- Bottom: Category tag (small pill)

Cards to show:
1. 일일 운세 (🌟)
2. 타로 카드 (🃏)
3. 궁합 보기 (💕)
4. MBTI 운세 (🧬)
5. 꿈 해몽 (🌙)
6. 손금 보기 (✋)
7. 사주 팔자 (📜)
8. 바이오리듬 (📊)

Frame: 430x932
```

### 4. Daily Fortune (일일 운세 결과)

```
Create a fortune result page in premium Korean app style:

Header:
- Back button, Share button
- Title: "오늘의 운세"

User Info Section:
- Profile area with birth date display
- "1990년 5월 15일생 · 뱀띠"
- Zodiac icon

Score/Rating Section:
- Large circular progress (120px)
- Score number in center: "85점" (large, bold, blue)
- Label below: "전체 운세 점수"

Category Scores (horizontal):
- 4 small circles in a row
- 재물운 78, 애정운 92, 건강운 75, 직장운 88
- Each with icon and percentage

Main Content Cards (vertical stack):
Each card:
- White background, 16px radius
- Section title with icon (금전운 💰)
- 3-4 lines of fortune text
- Divider between sections

Cards:
1. 종합운 (Overall)
2. 금전운 (Money)
3. 애정운 (Love)
4. 건강운 (Health)

Bottom CTA:
- "상세 분석 보기" button (blue, full width)

Premium Badge (optional):
- Blur overlay on lower sections
- Lock icon
- "프리미엄으로 전체 보기"

Frame: 430x932
```

### 5. Tarot Card Selection

```
Create a tarot card selection screen:

Header:
- Back button
- Title: "타로 카드 선택"
- Step indicator: "1/3"

Instruction Text:
- "마음을 가라앉히고"
- "3장의 카드를 선택하세요"
- Centered, gray text (17px)

Card Spread (fan layout or grid):
- 5-7 tarot card backs arranged in arc/fan
- Card back design: mystical purple gradient with star pattern
- Card size: approximately 100x150px
- Cards slightly overlapping

Selected Cards Area:
- 3 placeholder slots at bottom
- Empty slots: dashed border, gray
- Selected: card thumbnail with checkmark

Selection Counter:
- "선택한 카드: 1/3"
- Progress bar

Action Button:
- "카드 뒤집기" (disabled until 3 selected)
- Blue when active

Background:
- Dark gradient (purple/navy)
- Subtle mystical particle effects

Frame: 430x932
```

### 6. Profile Page

```
Create a user profile page in Toss style:

Header:
- Title: "프로필" (left aligned)
- Settings gear icon (right)

Profile Section:
- Large avatar circle (80px) with edit badge
- User name: "홍길동" (24px bold)
- Email: "user@email.com" (14px gray)
- Edit profile button (outline style)

Birth Info Card:
- White card with icon
- "사주 정보"
- Birth date, time, lunar/solar toggle
- Zodiac animal and sign display

Stats Row:
- 3 columns: 운세 조회수, 저장한 운세, 구독 상태
- Number + label for each

Menu List:
- List items with right arrow:
  - 알림 설정
  - 구독 관리
  - 결제 내역
  - 연결된 계정
  - 고객센터
  - 이용약관
  - 개인정보처리방침
  - 로그아웃

Each item:
- Left icon, text, right chevron
- Divider between items

Version info at bottom:
- "버전 1.0.0" (small, gray, centered)

Frame: 430x932
```

### 7. Premium/Subscription Page

```
Create a premium subscription page:

Header:
- Close X button
- "프리미엄" title

Hero Section:
- Gradient background (gold/purple)
- Crown or star icon (large)
- "Fortune Premium" text
- "모든 운세를 무제한으로" subtitle

Benefits List:
- Checkmark icons with benefits:
  ✓ 모든 운세 무제한 열람
  ✓ 광고 제거
  ✓ 상세 분석 리포트
  ✓ 매일 푸시 알림
  ✓ 우선 고객 지원

Pricing Cards (2 options):
Card 1 - Monthly:
- "월간 구독"
- "₩9,900/월"
- Outline style

Card 2 - Annual (recommended):
- "연간 구독" with "BEST" badge
- "₩79,900/년"
- "월 ₩6,658 (33% 할인)"
- Filled/highlighted style

CTA Button:
- "프리미엄 시작하기"
- Full width, blue (#1F4EF5)

Terms:
- Small text about auto-renewal
- Links to terms

Frame: 430x932
```

---

## 🧩 컴포넌트 프롬프트

### Button Component

```
Create a button component system in Toss style:

4 variants:
1. Primary: Blue (#1F4EF5) background, white text
2. Secondary: Light blue (#EBF0FF) background, blue text
3. Outline: White background, blue border, blue text
4. Ghost: Transparent, blue text only

3 sizes:
- Large: 56px height, 18px text, 24px horizontal padding
- Medium: 48px height, 16px text, 20px horizontal padding
- Small: 36px height, 14px text, 16px horizontal padding

States for each:
- Default
- Hover (slightly darker)
- Pressed (darker)
- Disabled (gray, 50% opacity)

All buttons:
- Rounded corners (12px for large, 10px for medium, 8px for small)
- Pretendard font, semibold
- Center aligned text
```

### Card Component

```
Create a card component in Toss style:

Base card:
- White background (#FFFFFF)
- Border radius: 16px
- Shadow: 0 4px 16px rgba(0,0,0,0.08)
- Padding: 20px

Variants:
1. Basic Card: just content area
2. Header Card: title section + content + optional action
3. Fortune Card: icon + title + description + category tag
4. List Card: left icon + title + subtitle + right chevron

Show dark mode variant:
- Background: #1F1F23
- Shadow: 0 4px 16px rgba(0,0,0,0.3)
```

### Input Field

```
Create input field components:

States:
1. Empty: Gray background (#F5F5F5), placeholder text
2. Focused: White background, blue border (#1F4EF5)
3. Filled: White background, dark text
4. Error: White background, red border (#EF4444), error message below
5. Disabled: Light gray, reduced opacity

Features:
- Height: 52px
- Border radius: 12px
- Padding: 16px horizontal
- Label above (14px, gray)
- Optional helper text below
- Optional left/right icons

Show variants:
- Text input
- Password (with show/hide toggle)
- Search (with search icon)
- Dropdown (with chevron)
```

### Fortune Result Card (with Blur)

```
Create a fortune result card with blur/premium lock:

Normal state:
- White card, 16px radius
- Icon and title at top
- 3-4 lines of fortune text
- Fully readable

Blurred/Locked state:
- Same card structure
- Content has gaussian blur (10px)
- Overlay with:
  - Lock icon (centered)
  - "프리미엄으로 전체 보기" text
  - Small "unlock" button

Show both states side by side
```

### Bottom Navigation

```
Create a bottom navigation bar:

Structure:
- White background
- Height: 56px + safe area
- Top border: 1px #E5E5E5

4 tabs:
1. 홈 (Home icon)
2. 운세 (Star/crystal ball icon)
3. 트렌드 (Chart/trending icon)
4. 프로필 (Person icon)

States:
- Active: Blue (#1F4EF5) icon and text
- Inactive: Gray (#9CA3AF) icon and text

Each tab:
- Icon (24px)
- Label below (12px)
- Vertically centered
```

---

## 🌙 다크 모드 프롬프트

### Dark Mode Landing

```
Same as landing page but with dark theme:
- Background: #17171C
- Text: #FFFFFF (primary), #9CA3AF (secondary)
- Cards: #1F1F23 background
- Blue accent: #1F4EF5 (same)
- Shadows: rgba(0,0,0,0.3)
```

각 화면에 "dark mode variant" 또는 "dark theme"를 추가하면 Figma AI가 다크 모드 버전을 생성합니다.

---

## 💡 사용 팁

1. **프레임 먼저 생성**: 430×932 프레임을 먼저 만들고 선택한 상태에서 프롬프트 실행
2. **구체적으로 작성**: 색상, 크기, 간격을 구체적인 숫자로 명시
3. **참고 이미지 첨부**: 비슷한 스타일의 이미지를 함께 첨부하면 더 정확
4. **반복 수정**: 한 번에 완벽하지 않으면 부분 수정 요청
5. **컴포넌트화**: 생성된 요소들을 Figma 컴포넌트로 만들어 재사용

---

## 🔗 추가 참고

생성된 디자인에 적용할 디자인 토큰:
- `figma/design-tokens.json` 참조
- Tokens Studio 플러그인으로 import 후 적용
