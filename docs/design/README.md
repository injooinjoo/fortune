# ZPZG 디자인 문서 가이드

## 개요

ZPZG의 디자인 시스템은 **ChatGPT/Claude 스타일의 모던 AI 채팅 인터페이스**를 기반으로 합니다.

> **핵심 정체성**: 미니멀하고 중립적인 모노크롬 디자인, 콘텐츠 중심 레이아웃, iOS 시스템 컬러 활용

---

## ⚠️ 디자인 시스템 마이그레이션 (2026-02)

**중요**: 디자인 시스템이 ChatGPT 스타일로 전면 통일되었습니다.

### 변경 사항

| 항목 | 이전 (한국 전통 미학) | 현재 (ChatGPT 스타일) |
|------|---------------------|---------------------|
| 색상 시스템 | 오방색, DSFortuneColors, DSLuckColors | **DSColors only** |
| 배경 | 한지 질감 | 순수 단색 배경 |
| 카드 | HanjiCard (한지 텍스처) | DSCard (클린 카드) |
| 타이포그래피 | 서예/명조 스타일 | 시스템 폰트 기반 |

### 삭제된 색상 시스템

다음 파일들이 삭제되었습니다:
- `ds_fortune_colors.dart` → DSColors 사용
- `ds_obangseok_colors.dart` → DSColors 사용
- `ds_luck_colors.dart` → DSColors 사용
- `ds_love_colors.dart` → DSColors 사용
- `ds_biorhythm_colors.dart` → DSColors 사용
- `fortune_colors.dart` → DSColors 사용

### 유지된 색상 시스템

- **DSColors** - 기본 색상 시스템 (ChatGPT 스타일)
- **DSSajuColors** - 사주 오행 데이터 시각화용 (semantic coloring)

---

## 핵심 디자인 원칙

### ChatGPT 스타일 4대 원칙

```
┌─────────────────────────────────────────────────────────────┐
│                    ChatGPT Style Design                      │
├──────────────┬──────────────┬──────────────┬───────────────┤
│    색상       │     레이아웃   │   타이포그래피  │     상호작용    │
│    Color     │    Layout    │  Typography  │  Interaction  │
├──────────────┼──────────────┼──────────────┼───────────────┤
│  모노크롬     │   콘텐츠 중심   │   시스템 폰트   │   미니멀 피드백  │
│  Monochrome  │Content-First │ System Font  │Minimal Feedback│
└──────────────┴──────────────┴──────────────┴───────────────┘
```

### 핵심 색상

| 용도 | Light Mode | Dark Mode | DSColors |
|------|-----------|-----------|----------|
| 배경 | #FFFFFF | #000000 | `background` / `backgroundDark` |
| 표면 | #F5F5F5 | #1C1C1E | `surface` / `surfaceDark` |
| 텍스트 | #000000 | #FFFFFF | `textPrimary` / `textPrimaryDark` |
| 강조 | #007AFF | #0A84FF | `accent` / `accentDark` |
| 성공 | #34C759 | #30D158 | `success` |
| 경고 | #FF9500 | #FF9F0A | `warning` |
| 오류 | #FF3B30 | #FF453A | `error` |

---

## 문서 계층 구조

### Tier 1: 핵심 디자인 시스템

| 문서 | 설명 |
|------|------|
| **[.claude/docs/03-ui-design-system.md](../../.claude/docs/03-ui-design-system.md)** | ChatGPT 스타일 통합 디자인 시스템 (**최우선**) |

### Tier 2: 도메인 가이드

| 문서 | 설명 | 상태 |
|------|------|------|
| [FIGMA_SOURCE_OF_TRUTH.md](./FIGMA_SOURCE_OF_TRUTH.md) | 공식 Figma 파일 정의 및 운영 규칙 | 활성 |
| [FIGMA_SCREEN_COMPONENT_REGISTRY.md](./FIGMA_SCREEN_COMPONENT_REGISTRY.md) | 화면, 레이아웃, 컴포넌트 인벤토리 | 활성 |
| [BLUR_SYSTEM_GUIDE.md](./BLUR_SYSTEM_GUIDE.md) | 블러 시스템 가이드 | 활성 |
| [UI_UX_MASTER_POLICY.md](./UI_UX_MASTER_POLICY.md) | UI/UX 마스터 정책 | 활성 |
| [WIDGET_ARCHITECTURE_DESIGN.md](./WIDGET_ARCHITECTURE_DESIGN.md) | 위젯 아키텍처 | 활성 |
| [FORTUNE_INPUT_ACCORDION_STANDARD.md](./FORTUNE_INPUT_ACCORDION_STANDARD.md) | 입력 아코디언 표준 | 활성 |

### 아카이브 (Deprecated)

다음 문서들은 더 이상 사용되지 않습니다:

| 문서 | 이유 |
|------|------|
| ~~DESIGN_SYSTEM.md~~ | 한국 전통 미학 → ChatGPT 스타일로 변경 |
| ~~TOSS_DESIGN_SYSTEM.md~~ | Toss 디자인 → ChatGPT 스타일로 변경 |
| ~~KOREAN_TALISMAN_DESIGN_GUIDE.md~~ | 부적/민화 → 단순 이미지로 변경 |
| ~~FONT_SYSTEM_GUIDE.md~~ | 서예 폰트 → 시스템 폰트로 변경 |

---

## 빠른 시작

### 0. 공식 Figma 운영 기준 확인

- 공식 파일: [Fortune Screen Catalog - Official](https://www.figma.com/design/dkx3Biwe5xkiMQWsjq95LA)
- 파일 키: `dkx3Biwe5xkiMQWsjq95LA`
- 기준 디바이스: `iPhone 15 Pro 393x852 @3x`
- 운영 규칙: [FIGMA_SOURCE_OF_TRUTH.md](./FIGMA_SOURCE_OF_TRUTH.md)
- 화면/컴포넌트 인벤토리: [FIGMA_SCREEN_COMPONENT_REGISTRY.md](./FIGMA_SCREEN_COMPONENT_REGISTRY.md)

### 0.1 캡처 파이프라인

- 빌드 서빙: `npm run figma:serve-build`
- 라이브 캡처: `npm run figma:capture`
- 카탈로그 HTML 생성: `npm run figma:catalog`

공식 Figma 파일은 위 파이프라인으로 생성한 iPhone 규격 카탈로그를 Figma MCP로 기존 파일에 추가하는 방식으로 관리한다.

### 1. 색상 사용

```dart
import 'package:fortune/core/design_system/design_system.dart';

// Context extensions (권장)
Container(color: context.colors.surface)
Text('제목', style: TextStyle(color: context.colors.textPrimary))

// 직접 사용
Container(color: DSColors.surface)
Container(color: DSColors.surfaceDark)  // 다크모드
```

### 2. 타이포그래피

```dart
// Context extensions (권장)
Text('제목', style: context.heading1)
Text('본문', style: context.body1)
Text('캡션', style: context.caption)
```

### 3. 카드 사용

```dart
import 'package:fortune/core/design_system/design_system.dart';

DSCard.elevated(
  child: YourContent(),
)
```

### 4. 버튼 사용

```dart
DSButton.primary(
  text: '확인',
  onPressed: () {},
)
```

---

## 색상 매핑 참조

### iOS 시스템 컬러 → DSColors

| iOS System Color | DSColors |
|------------------|----------|
| systemBlue | `accent` |
| systemGreen | `success` |
| systemOrange | `warning` |
| systemRed | `error` |
| systemPurple | `accentSecondary` |

### Semantic Colors

| 용도 | DSColors |
|------|----------|
| 행운/성공 | `success` (green) |
| 경고/주의 | `warning` (amber) |
| 위험/오류 | `error` (red) |
| 정보/링크 | `info` (blue) |
| 보조 강조 | `accentSecondary` (purple) |

---

## 업데이트 이력

| 날짜 | 변경 내용 |
|------|----------|
| 2026-02 | ChatGPT 스타일로 전면 마이그레이션 |
| 2026-02 | 레거시 색상 시스템 삭제 (DSFortuneColors, DSObangseokColors 등) |
| 2026-02 | 문서 구조 간소화 |
