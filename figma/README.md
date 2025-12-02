# Fortune App → Figma 마이그레이션 가이드

## 📁 이 폴더의 파일들

| 파일 | 용도 |
|------|------|
| `design-tokens.json` | 디자인 토큰 (색상, 타이포, 스페이싱) |
| `README.md` | 이 가이드 |

---

## 🚀 시작하기 (Day 1)

### Step 1: Figma 기본 설정 (무료)

**Figma 내장 기능만 사용합니다:**
- Variables (색상, 스페이싱 관리)
- Text Styles (타이포그래피)
- Components & Variants
- Auto Layout
- Figma AI (Make Designs) - Figma 구독에 포함

### Step 2 (선택): Tokens Studio 플러그인

JSON으로 토큰 일괄 import 원하면:
- https://www.figma.com/community/plugin/843461159747178978
- **무료 플러그인**입니다

### Step 3: Figma 파일 구조 생성

Figma에서 다음 페이지들을 생성하세요:

```
Fortune App Design System
├── 📋 Cover (커버 페이지)
├── 🎨 Foundation
│   ├── Colors (색상)
│   ├── Typography (타이포그래피)
│   └── Spacing & Effects (스페이싱, 그림자)
├── 🧩 Components
│   ├── Buttons
│   ├── Cards
│   ├── Inputs
│   ├── Navigation
│   └── Fortune-specific
├── 📱 Screens - Core
│   ├── Landing
│   ├── Home
│   ├── Profile
│   └── Settings
├── 📱 Screens - Fortune
│   ├── Fortune List
│   ├── Daily Fortune
│   ├── Tarot
│   └── (기타 운세 페이지들)
└── 📄 Documentation
```

### Step 3: 디자인 토큰 Import

1. Figma에서 Tokens Studio 플러그인 실행
2. "Import" 클릭
3. `design-tokens.json` 파일 업로드
4. "Create Variables" 선택
5. Light/Dark 모드 설정

---

## 📸 스크린샷 캡처 (Day 2)

### 준비

```bash
# 1. Flutter Web 서버 실행
flutter run -d chrome --web-port=3000

# 2. 별도 터미널에서 스크린샷 캡처
node playwright/scripts/mass-screenshot.js
```

### 출력 위치
- `screenshots/raw/{category}/{page}_{theme}.png`
- 120+ 화면 × 2 테마 = 240+ 스크린샷

### Figma에서 화면 만들기 (수동)

**스크린샷을 참고 이미지로 활용:**
1. Figma에서 Frame 생성 (430×932, iPhone 14 Pro Max)
2. 스크린샷을 배경에 깔고 50% 투명도로 설정
3. 컴포넌트와 Auto Layout으로 직접 구현
4. 완성 후 참고 이미지 삭제

**Figma AI (Make Designs) 활용:**
1. Cmd+/ 또는 Actions 메뉴 열기
2. "운세 카드 컴포넌트" 같이 설명 입력
3. AI가 생성한 디자인 수정

---

## 🎨 디자인 토큰 매핑

### 색상 (Colors)

| Figma Variable | Flutter 상수 | 값 |
|----------------|-------------|-----|
| `color/brand/tossBlue` | `TossDesignSystem.tossBlue` | `#1F4EF5` |
| `color/gray/900` | `TossDesignSystem.gray900` | `#191F28` |
| `color/gray/50` | `TossDesignSystem.gray50` | `#F9FAFB` |
| `color/semantic/success` | `TossDesignSystem.successGreen` | `#10B981` |
| `color/semantic/error` | `TossDesignSystem.errorRed` | `#EF4444` |
| `color/semantic/warning` | `TossDesignSystem.warningOrange` | `#F59E0B` |

### 다크모드 색상

| Figma Variable | Flutter 상수 | 값 |
|----------------|-------------|-----|
| `color/grayDark/900` | `TossDesignSystem.grayDark900` | `#FFFFFF` |
| `color/grayDark/50` | `TossDesignSystem.grayDark50` | `#17171C` |
| `color/background/dark/primary` | `TossDesignSystem.backgroundDark` | `#17171C` |
| `color/text/dark/primary` | `TossDesignSystem.textPrimaryDark` | `#FFFFFF` |

### 타이포그래피 (Typography)

| Figma Text Style | Flutter 스타일 | 크기/굵기 |
|------------------|---------------|-----------|
| `typography/display/large` | `TypographyUnified.displayLarge` | 50pt Bold |
| `typography/heading/h1` | `TypographyUnified.heading1` | 30pt Bold |
| `typography/heading/h2` | `TypographyUnified.heading2` | 26pt Bold |
| `typography/body/medium` | `TypographyUnified.bodyMedium` | 17pt Regular |
| `typography/label/medium` | `TypographyUnified.labelMedium` | 14pt Regular |
| `typography/button/medium` | `TypographyUnified.buttonMedium` | 18pt SemiBold |

### 스페이싱 (Spacing)

| Figma Variable | Flutter 상수 | 값 |
|----------------|-------------|-----|
| `spacing/xxs` | `TossDesignSystem.spacingXXS` | 2px |
| `spacing/xs` | `TossDesignSystem.spacingXS` | 4px |
| `spacing/s` | `TossDesignSystem.spacingS` | 8px |
| `spacing/m` | `TossDesignSystem.spacingM` | 16px |
| `spacing/l` | `TossDesignSystem.spacingL` | 24px |
| `spacing/xl` | `TossDesignSystem.spacingXL` | 32px |

### 모서리 반경 (Border Radius)

| Figma Variable | Flutter 상수 | 값 |
|----------------|-------------|-----|
| `borderRadius/xs` | `TossDesignSystem.radiusXS` | 4px |
| `borderRadius/s` | `TossDesignSystem.radiusS` | 8px |
| `borderRadius/m` | `TossDesignSystem.radiusM` | 12px |
| `borderRadius/l` | `TossDesignSystem.radiusL` | 16px |
| `borderRadius/full` | `TossDesignSystem.radiusFull` | 9999px |

### 그림자 (Shadows)

| Figma Effect Style | Flutter 상수 | 설정 |
|-------------------|-------------|------|
| `boxShadow/xs` | `TossDesignSystem.shadowXS` | y:1, blur:3, 4% |
| `boxShadow/s` | `TossDesignSystem.shadowS` | y:2, blur:8, 4% |
| `boxShadow/m` | `TossDesignSystem.shadowM` | y:4, blur:16, 8% |
| `boxShadow/l` | `TossDesignSystem.shadowL` | y:8, blur:24, 12% |

---

## 🔄 싱크 워크플로우

### Code → Figma (코드 변경 시)

```bash
# 1. Flutter 코드 수정 후
# 2. 토큰 JSON 재생성 (필요시)
# 3. Figma Tokens Studio에서 재import
```

### Figma → Code (새 디자인 반영 시)

```bash
# 1. Figma Dev Mode에서 노드 선택
# 2. Claude MCP로 코드 추출:
#    mcp__figma-dev-mode-mcp-server__get_design_context
# 3. 생성된 코드 참조하여 구현
```

---

## 📚 Figma 학습 리소스

### 필수 튜토리얼 (총 2시간)

1. **Figma 기초** (30분)
   - https://help.figma.com/hc/en-us/articles/360040328653

2. **Auto Layout** (45분) ⭐ 가장 중요
   - https://help.figma.com/hc/en-us/articles/360040451373

3. **Variables** (30분)
   - https://help.figma.com/hc/en-us/articles/15339657135383

4. **Components** (30분)
   - https://help.figma.com/hc/en-us/articles/360038662654

### YouTube 추천

- Figma 공식 채널: https://www.youtube.com/@Figma
- "Figma Auto Layout Tutorial" 검색

---

## ✅ 체크리스트

### Day 1-2: 기반 구축
- [ ] Figma 플러그인 설치 (Tokens Studio - 무료)
- [ ] Figma 파일 생성 및 페이지 구조 설정
- [ ] design-tokens.json import
- [ ] Color Variables 생성 (Light/Dark 모드)
- [ ] Text Styles 생성 (15개)

### Day 3-4: 스크린샷 캡처 + Figma 작업
- [ ] Flutter Web 서버 실행 (`flutter run -d chrome --web-port=3000`)
- [ ] 스크린샷 캡처 (`node playwright/scripts/mass-screenshot.js`)
- [ ] 스크린샷을 참고하여 핵심 20개 화면 Figma로 제작
- [ ] Figma AI (Make Designs) 활용하여 작업 가속화

### Day 5-7: 컴포넌트 라이브러리
- [ ] UnifiedButton (4 스타일 × 3 사이즈)
- [ ] TossCard
- [ ] TossInput
- [ ] AppBar / BottomNav
- [ ] Toast / Dialog
- [ ] FortuneCard (블러/언블러)

### Day 8-10: 핵심 화면
- [ ] Landing
- [ ] Home
- [ ] Fortune List
- [ ] Daily Fortune
- [ ] Tarot
- [ ] Profile
- [ ] Settings
- [ ] Premium

---

## 🆘 도움이 필요하면

Claude에게 요청하세요:
- "Figma에서 이 컴포넌트 어떻게 만들어?"
- "이 Flutter 코드를 Figma로 옮기려면?"
- "토큰 import가 안 돼요"
