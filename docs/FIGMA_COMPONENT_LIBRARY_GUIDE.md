# Fortune App - Component Library Guide

## 컴포넌트 구조
Fortune 앱의 재사용 가능한 UI 컴포넌트들을 정의합니다.

---

## 1. Button Components

### 1.1 Primary Button
```
이름: Button/Primary
크기: Width: Fill (최소 120px), Height: 56px
```

#### Variants
- **State**: Default, Pressed, Disabled
- **Size**: Large (56px), Medium (48px), Small (40px)

#### Properties
- **Label** (text): "버튼 텍스트"
- **Icon** (boolean): false
- **Icon Position** (left/right): right

#### 스타일
- **Default**
  - 배경: #000000
  - 텍스트: #FFFFFF
  - 모서리: 28px (Large), 24px (Medium), 20px (Small)
  
- **Pressed**
  - 배경: #1F2937
  - Scale: 0.98
  
- **Disabled**
  - 배경: #E5E7EB
  - 텍스트: #9CA3AF

### 1.2 Secondary Button
```
이름: Button/Secondary
```
- **배경**: #FFFFFF
- **테두리**: 1px solid #E5E7EB
- **텍스트**: #111827
- 나머지는 Primary와 동일

### 1.3 Text Button
```
이름: Button/Text
```
- **배경**: transparent
- **텍스트**: #111827
- **밑줄**: underline (hover 시)

---

## 2. Input Components

### 2.1 Text Input
```
이름: Input/Text
크기: Width: Fill, Height: 56px
```

#### Variants
- **State**: Default, Focused, Filled, Error, Disabled
- **Type**: Text, Email, Password

#### Properties
- **Label** (text): "라벨"
- **Placeholder** (text): "플레이스홀더"
- **Helper Text** (text): ""
- **Required** (boolean): false

#### 스타일
- **Default**
  - 배경: #F9FAFB
  - 테두리: 1px solid #E5E7EB
  - 모서리: 12px
  
- **Focused**
  - 테두리: 1px solid #000000
  
- **Error**
  - 테두리: 1px solid #DC3545
  - Helper text 색상: #DC3545

### 2.2 Dropdown
```
이름: Input/Dropdown
```
- 기본 스타일은 Text Input과 동일
- 우측 아이콘: chevron_down
- 클릭 시 옵션 리스트 표시

---

## 3. Card Components

### 3.1 Fortune Card
```
이름: Card/Fortune
크기: 180×180px
```

#### Properties
- **Category** (instance swap): Love, Career, Money, Health
- **Title** (text): "운세 제목"
- **Description** (text): "운세 설명"
- **Badge** (text): ""
- **Icon** (instance swap): 카테고리별 아이콘

#### 스타일
- **배경**: 카테고리별 그라데이션
- **모서리**: 20px
- **그림자**: 0px 4px 12px rgba(0,0,0,0.1)
- **패딩**: 20px

### 3.2 Glass Card
```
이름: Card/Glass
```

#### Properties
- **Blur** (number): 10
- **Opacity** (number): 0.1

#### 스타일
- **배경**: rgba(255,255,255,0.1)
- **Backdrop blur**: 10px
- **테두리**: 1px solid rgba(255,255,255,0.2)
- **모서리**: 24px

---

## 4. Navigation Components

### 4.1 Progress Bar
```
이름: Navigation/ProgressBar
크기: Width: Fill, Height: 4px
```

#### Properties
- **Current Step** (number): 1
- **Total Steps** (number): 4

#### 스타일
- **배경**: #E5E7EB
- **진행**: #000000
- **애니메이션**: 300ms ease-in-out

### 4.2 Tab Bar
```
이름: Navigation/TabBar
```

#### Properties
- **Items** (text list): ["탭1", "탭2", "탭3"]
- **Active Index** (number): 0

#### 스타일
- **비활성 탭**: 텍스트 #6B7280
- **활성 탭**: 텍스트 #000000, 하단 바 2px #000000

---

## 5. Feedback Components

### 5.1 Toast
```
이름: Feedback/Toast
```

#### Variants
- **Type**: Success, Error, Warning, Info

#### Properties
- **Message** (text): "메시지"
- **Action** (boolean): false

#### 스타일
- **Success**: 배경 #D1FAE5, 텍스트 #065F46
- **Error**: 배경 #FEE2E2, 텍스트 #991B1B
- **Warning**: 배경 #FEF3C7, 텍스트 #92400E
- **Info**: 배경 #DBEAFE, 텍스트 #1E40AF

### 5.2 Loading Spinner
```
이름: Feedback/Spinner
```

#### Properties
- **Size** (small/medium/large): medium
- **Color** (color): #000000

---

## 6. Social Login Components

### 6.1 Social Login Button
```
이름: SocialLogin/Button
크기: Width: Fill, Height: 52px
```

#### Variants
- **Provider**: Google, Apple, Kakao, Naver, Instagram, TikTok

#### 스타일 (공통)
- **배경**: #FFFFFF
- **테두리**: 1px solid #E5E7EB
- **모서리**: 26px
- **아이콘 크기**: 24×24px
- **텍스트**: NotoSansKR SemiBold, 16px

---

## 7. Selection Components

### 7.1 Radio Card
```
이름: Selection/RadioCard
크기: Width: Fill, Height: 80px
```

#### Variants
- **State**: Default, Selected, Disabled

#### Properties
- **Label** (text): "옵션"
- **Icon** (instance swap): 옵션 아이콘

#### 스타일
- **Default**
  - 배경: #FFFFFF
  - 테두리: 2px solid #E5E7EB
  
- **Selected**
  - 배경: #000000
  - 텍스트: #FFFFFF
  - 테두리: 2px solid #000000

### 7.2 Chip
```
이름: Selection/Chip
```

#### Variants
- **State**: Default, Selected
- **Size**: Small, Medium

#### Properties
- **Label** (text): "칩 텍스트"

---

## 8. Layout Components

### 8.1 Safe Area Container
```
이름: Layout/SafeArea
```

#### Properties
- **Top** (boolean): true
- **Bottom** (boolean): true

#### 패딩
- **Top**: 47px (iPhone 14 Pro)
- **Bottom**: 34px (iPhone 14 Pro)

### 8.2 Section Container
```
이름: Layout/Section
```

#### Properties
- **Title** (text): "섹션 제목"
- **Description** (text): ""

#### 스타일
- **타이틀**: NotoSansKR Bold, 20px
- **설명**: NotoSansKR Regular, 14px, #6B7280
- **간격**: 타이틀-설명 8px, 설명-콘텐츠 16px

---

## Component 사용 가이드

### 1. Naming Convention
```
[Category]/[ComponentName]/[Variant]
예: Button/Primary/Default
```

### 2. Auto Layout 설정
- 모든 컴포넌트는 Auto Layout 사용
- Responsive하게 Width: Fill 옵션 활용
- 적절한 padding과 gap 설정

### 3. Color Styles 연결
- 모든 색상은 Design System의 Color Style 사용
- 하드코딩된 색상 값 사용 금지

### 4. Text Styles 연결
- 모든 텍스트는 Design System의 Text Style 사용
- 컴포넌트별 커스텀 폰트 설정 금지

### 5. Interactive Components
- 모든 상태 변화는 Variants로 관리
- Hover, Pressed 효과 추가
- 적절한 transition 설정

### 6. 접근성
- 최소 터치 영역 44×44px 유지
- 충분한 색상 대비 확보
- 명확한 포커스 상태 표시

---

## 컴포넌트 체크리스트

### Essential Components
- [ ] Primary Button (3 states, 3 sizes)
- [ ] Secondary Button
- [ ] Text Button
- [ ] Text Input (5 states)
- [ ] Dropdown
- [ ] Progress Bar
- [ ] Social Login Button (6 providers)
- [ ] Radio Card
- [ ] Toast (4 types)
- [ ] Loading Spinner

### Fortune Specific
- [ ] Fortune Card
- [ ] Glass Card
- [ ] Time Slot Selector
- [ ] Date Picker Card
- [ ] Gender Selection Card

### Layout Helpers
- [ ] Safe Area Container
- [ ] Section Container
- [ ] Bottom Sheet Container

이 가이드를 참고하여 Figma에서 일관성 있는 컴포넌트 라이브러리를 구축하세요.