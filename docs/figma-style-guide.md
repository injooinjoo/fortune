# ZPZG - Figma Style Guide

> Flutter 디자인 시스템을 Figma로 이전하기 위한 스타일 가이드
> 마지막 업데이트: 2026-02-09

---

## 1. 디자인 철학

**ChatGPT-inspired Monochrome Design**
- Pure white/black + zero color accent
- Clean, minimal, content-first
- High contrast, no warm tints

---

## 2. 색상 시스템 (Color Tokens)

### 2.1 Dark Mode (Primary)

| Token | Hex | RGB | 용도 |
|-------|-----|-----|------|
| **Background** | `#000000` | rgb(0, 0, 0) | 페이지 배경 |
| **Background Secondary** | `#1A1A1A` | rgb(26, 26, 26) | 보조 배경 |
| **Background Tertiary** | `#212121` | rgb(33, 33, 33) | 3차 배경 |
| **Surface** | `#1A1A1A` | rgb(26, 26, 26) | 카드/모달 표면 |
| **Surface Secondary** | `#2C2C2E` | rgb(44, 44, 46) | 중첩 표면 |
| **Text Primary** | `#FFFFFF` | rgb(255, 255, 255) | 주요 텍스트 |
| **Text Secondary** | `#8E8E93` | rgb(142, 142, 147) | 보조 텍스트 |
| **Text Tertiary** | `#636366` | rgb(99, 99, 102) | 3차 텍스트 |
| **Text Disabled** | `#48484A` | rgb(72, 72, 74) | 비활성 텍스트 |
| **Accent** | `#FFFFFF` | rgb(255, 255, 255) | 강조 (Monochrome) |
| **Accent Secondary** | `#8FB0FF` | rgb(143, 176, 255) | 링크/정보 |
| **Accent Tertiary** | `#E0A76B` | rgb(224, 167, 107) | 하이라이트 |
| **Border** | `#2C2C2E` | rgb(44, 44, 46) | 테두리 |
| **Border Focus** | `#48484A` | rgb(72, 72, 74) | 포커스 테두리 |
| **Divider** | `#2C2C2E` | rgb(44, 44, 46) | 구분선 |
| **User Bubble** | `#2C2C2E` | rgb(44, 44, 46) | 사용자 메시지 버블 |
| **CTA Background** | `#FFFFFF` | rgb(255, 255, 255) | CTA 버튼 배경 |
| **CTA Foreground** | `#000000` | rgb(0, 0, 0) | CTA 버튼 텍스트 |
| **Secondary BG** | `#2C2C2E` | rgb(44, 44, 46) | 보조 버튼 배경 |
| **Secondary FG** | `#FFFFFF` | rgb(255, 255, 255) | 보조 버튼 텍스트 |

### 2.2 Light Mode

| Token | Hex | RGB | 용도 |
|-------|-----|-----|------|
| **Background** | `#FFFFFF` | rgb(255, 255, 255) | 페이지 배경 |
| **Background Secondary** | `#F7F7F8` | rgb(247, 247, 248) | 보조 배경 |
| **Background Tertiary** | `#F0F0F0` | rgb(240, 240, 240) | 3차 배경 |
| **Surface** | `#FFFFFF` | rgb(255, 255, 255) | 카드/모달 표면 |
| **Surface Secondary** | `#F7F7F8` | rgb(247, 247, 248) | 중첩 표면 |
| **Text Primary** | `#000000` | rgb(0, 0, 0) | 주요 텍스트 |
| **Text Secondary** | `#6E6E73` | rgb(110, 110, 115) | 보조 텍스트 |
| **Text Tertiary** | `#8E8E93` | rgb(142, 142, 147) | 3차 텍스트 |
| **Text Disabled** | `#AEAEB2` | rgb(174, 174, 178) | 비활성 텍스트 |
| **Accent** | `#000000` | rgb(0, 0, 0) | 강조 (Monochrome) |
| **Accent Secondary** | `#3B63D3` | rgb(59, 99, 211) | 링크/정보 |
| **Accent Tertiary** | `#C7702F` | rgb(199, 112, 47) | 하이라이트 |
| **Border** | `#E5E5EA` | rgb(229, 229, 234) | 테두리 |
| **Border Focus** | `#C7C7CC` | rgb(199, 199, 204) | 포커스 테두리 |
| **Divider** | `#E5E5EA` | rgb(229, 229, 234) | 구분선 |
| **User Bubble** | `#F7F7F8` | rgb(247, 247, 248) | 사용자 메시지 버블 |
| **CTA Background** | `#000000` | rgb(0, 0, 0) | CTA 버튼 배경 |
| **CTA Foreground** | `#FFFFFF` | rgb(255, 255, 255) | CTA 버튼 텍스트 |
| **Secondary BG** | `#F7F7F8` | rgb(247, 247, 248) | 보조 버튼 배경 |
| **Secondary FG** | `#000000` | rgb(0, 0, 0) | 보조 버튼 텍스트 |

### 2.3 상태 색상 (Semantic Colors)

| Token | Dark Mode | Light Mode | 용도 |
|-------|-----------|------------|------|
| **Success** | `#34C759` | `#34C759` | 성공, 완료 |
| **Success BG** | `#0D2818` | `#E8F9ED` | 성공 배경 |
| **Error** | `#FF3B30` | `#FF3B30` | 에러, 삭제 |
| **Error BG** | `#2D0F0D` | `#FFEBEA` | 에러 배경 |
| **Warning** | `#FFCC00` | `#FFCC00` | 경고 |
| **Warning BG** | `#2D2600` | `#FFF9E0` | 경고 배경 |
| **Info** | `#007AFF` | `#007AFF` | 정보 |
| **Info BG** | `#001A33` | `#E5F0FF` | 정보 배경 |
| **Toggle Active** | `#34C759` | `#34C759` | 토글 활성 (iOS Green) |
| **Toggle Inactive** | `#39393D` | `#D1D1D6` | 토글 비활성 |
| **Overlay** | `#000000` 60% | `#000000` 30% | 모달 오버레이 |

---

## 3. 타이포그래피 (Typography)

### 3.1 폰트 패밀리

| 용도 | 폰트 | 비고 |
|------|------|------|
| **Primary** | NotoSansKR | 모든 텍스트 기본 |
| **Korean** | NotoSansKR | 한글 |
| **English** | NotoSansKR | 영문 |
| **Number** | NotoSansKR | 숫자 (Tabular Figures) |
| **Calligraphy** | NanumMyeongjo | 전통 콘텐츠용 |

### 3.2 타이포그래피 스케일

#### Display (대형 헤드라인)

| Style | Size | Weight | Line Height | Letter Spacing | 용도 |
|-------|------|--------|-------------|----------------|------|
| **Display Large** | 40pt | 600 | 1.22 | -0.2px | 스플래시, 온보딩 |
| **Display Medium** | 34pt | 600 | 1.24 | -0.2px | 큰 헤드라인 |
| **Display Small** | 28pt | 600 | 1.28 | -0.15px | 중간 헤드라인 |

#### Heading (섹션 제목)

| Style | Size | Weight | Line Height | Letter Spacing | 용도 |
|-------|------|--------|-------------|----------------|------|
| **Heading 1** | 26pt | 600 | 1.32 | -0.1px | 메인 페이지 제목 |
| **Heading 2** | 22pt | 600 | 1.34 | -0.05px | 섹션 제목 |
| **Heading 3** | 20pt | 600 | 1.4 | 0px | 서브 섹션 제목 |
| **Heading 4** | 18pt | 600 | 1.42 | 0px | 작은 섹션 제목 |

#### Body (본문 텍스트)

| Style | Size | Weight | Line Height | Letter Spacing | 용도 |
|-------|------|--------|-------------|----------------|------|
| **Body Large** | 16pt | 400 | 1.58 | 0px | 큰 본문 |
| **Body Medium** | 14pt | 400 | 1.56 | 0px | 기본 본문 |
| **Body Small** | 13pt | 400 | 1.5 | 0px | 작은 본문 |

#### Label (라벨, 캡션)

| Style | Size | Weight | Line Height | Letter Spacing | 용도 |
|-------|------|--------|-------------|----------------|------|
| **Label Large** | 13pt | 500 | 1.45 | 0px | 큰 라벨 |
| **Label Medium** | 12pt | 500 | 1.4 | 0px | 기본 라벨 |
| **Label Small** | 11pt | 500 | 1.35 | 0px | 작은 라벨 |
| **Label Tiny** | 10pt | 400 | 1.32 | 0px | 배지, NEW 표시 |

#### Button (버튼 텍스트)

| Style | Size | Weight | Line Height | Letter Spacing | 용도 |
|-------|------|--------|-------------|----------------|------|
| **Button Large** | 16pt | 600 | 1.5 | 0px | 큰 버튼 |
| **Button Medium** | 15pt | 600 | 1.5 | 0px | 기본 버튼 |
| **Button Small** | 14pt | 600 | 1.45 | 0px | 작은 버튼 |
| **Button Tiny** | 13pt | 500 | 1.4 | 0px | 매우 작은 버튼 |

#### Number (숫자 전용)

| Style | Size | Weight | Line Height | Letter Spacing | 용도 |
|-------|------|--------|-------------|----------------|------|
| **Number XLarge** | 36pt | 700 | 1.2 | -0.5px | 매우 큰 숫자 |
| **Number Large** | 28pt | 700 | 1.25 | -0.25px | 큰 숫자 |
| **Number Medium** | 22pt | 700 | 1.3 | 0px | 중간 숫자 |
| **Number Small** | 18pt | 500 | 1.4 | 0px | 작은 숫자 |

#### Calligraphy (전통 콘텐츠)

| Style | Size | Weight | Line Height | Letter Spacing | 용도 |
|-------|------|--------|-------------|----------------|------|
| **Calligraphy Display** | 28pt | 700 | 1.4 | 0.5px | 운세 메인 제목 |
| **Calligraphy Title** | 22pt | 700 | 1.5 | 0.3px | 운세 섹션 제목 |
| **Calligraphy Subtitle** | 20pt | 400 | 1.5 | 0.2px | 운세 부제목 |
| **Calligraphy Body** | 16pt | 400 | 1.8 | 0.1px | 운세 본문 |
| **Calligraphy Quote** | 14pt | 400 Italic | 1.8 | 0.1px | 운세 인용문 |

---

## 4. 스페이싱 & 레이아웃

### 4.1 기본 스페이싱 단위

| Token | Value | 용도 |
|-------|-------|------|
| **xs** | 4px | 최소 간격 |
| **sm** | 8px | 작은 간격 |
| **md** | 12px | 중간 간격 |
| **lg** | 16px | 기본 간격 |
| **xl** | 24px | 큰 간격 |
| **2xl** | 32px | 매우 큰 간격 |
| **3xl** | 48px | 섹션 간격 |

### 4.2 Border Radius

| Token | Value | 용도 |
|-------|-------|------|
| **none** | 0px | 각진 모서리 |
| **sm** | 8px | 작은 둥근 모서리 |
| **md** | 12px | 중간 둥근 모서리 |
| **lg** | 16px | 큰 둥근 모서리 |
| **xl** | 20px | 카드, 모달 |
| **full** | 9999px | 완전 둥근 (pill) |

---

## 5. 그림자 (Shadows)

### 5.1 Elevation

| Level | Shadow | 용도 |
|-------|--------|------|
| **elevation-1** | `0px 1px 2px rgba(0,0,0,0.05)` | 미세한 높이감 |
| **elevation-2** | `0px 2px 4px rgba(0,0,0,0.1)` | 카드, 버튼 |
| **elevation-3** | `0px 4px 8px rgba(0,0,0,0.12)` | 드롭다운, 팝오버 |
| **elevation-4** | `0px 8px 16px rgba(0,0,0,0.15)` | 모달, 시트 |
| **elevation-5** | `0px 16px 32px rgba(0,0,0,0.2)` | 토스트, 알림 |

---

## 6. 컴포넌트 스타일

### 6.1 버튼

#### Primary (CTA)
- Background: `CTA Background`
- Text: `CTA Foreground`
- Border Radius: 12px
- Padding: 16px 24px
- Font: Button Medium

#### Secondary
- Background: `Secondary Background`
- Text: `Secondary Foreground`
- Border Radius: 12px
- Padding: 16px 24px
- Font: Button Medium

#### Ghost
- Background: transparent
- Text: `Text Primary`
- Border: 1px solid `Border`
- Border Radius: 12px
- Padding: 16px 24px

### 6.2 입력 필드

- Background: `Surface Secondary`
- Border: 1px solid `Border`
- Border Focus: `Border Focus`
- Border Radius: 16px
- Padding: 16px
- Placeholder: `Text Disabled`

### 6.3 카드

- Background: `Surface`
- Border: 1px solid `Border`
- Border Radius: 16px
- Padding: 16px
- Shadow: elevation-2

### 6.4 채팅 버블

#### AI 메시지
- Background: transparent
- Text: `Text Primary`
- Padding: 12px 16px

#### 사용자 메시지
- Background: `User Bubble`
- Text: `Text Primary`
- Border Radius: 20px
- Padding: 12px 16px

### 6.5 추천 칩 (Suggestion Chips)

- Background: `Surface Secondary`
- Border: 1px solid `Border`
- Border Radius: 14px
- Padding: 16px
- Title: Label Large, `Text Primary`
- Description: Body Small, `Text Secondary`

---

## 7. 아이콘

### 7.1 아이콘 크기

| Size | Value | 용도 |
|------|-------|------|
| **xs** | 16px | 인라인 아이콘 |
| **sm** | 20px | 버튼 내 아이콘 |
| **md** | 24px | 기본 아이콘 |
| **lg** | 32px | 강조 아이콘 |
| **xl** | 48px | 히어로 아이콘 |

### 7.2 아이콘 색상

- Default: `Text Primary`
- Secondary: `Text Secondary`
- Accent: `Accent`
- Success: `Success`
- Error: `Error`

---

## 8. 페이지 목록 (스크린샷 대상)

### 8.1 메인 탭 (5개)
1. **Chat Home** (`/chat`) - 통합 채팅 진입점
2. **Insight Home** (`/home`) - 일일 인사이트 대시보드
3. **Fortune Tab** (`/fortune`) - 인사이트 카테고리 + Face AI
4. **Trend** (`/trend`) - 트렌드 콘텐츠
5. **Profile/More** (`/profile`) - 설정 + Premium

### 8.2 인사이트 페이지 (주요)
- 건강 운세 (Health Fortune)
- 타로 카드 (Tarot Card)
- 꿈 해몽 (Dream Interpretation)
- 관상 (Face Reading)
- 심리 테스트 (Psychology Test)

### 8.3 기타 페이지
- 토큰 구매 (Token Purchase)
- 설정 (Settings)
- 운세 히스토리 (Fortune History)
- 캐릭터 채팅 (Character Chat)

---

## 9. Figma 적용 가이드

### 9.1 Color Styles 생성
1. Dark Mode 색상을 "Dark/" 접두사로 생성
2. Light Mode 색상을 "Light/" 접두사로 생성
3. Semantic 색상은 공통으로 생성

### 9.2 Text Styles 생성
1. 각 Typography 레벨을 스타일로 등록
2. 네이밍: "Display/Large", "Heading/1", "Body/Medium" 등

### 9.3 Components 생성
1. 버튼, 입력, 카드, 칩 등 기본 컴포넌트 생성
2. Dark/Light 모드 Variants 적용

---

*이 문서는 Flutter 코드에서 자동 추출되었습니다.*
