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
| [FIGMA_LAYER_NAMING_STANDARD.md](./FIGMA_LAYER_NAMING_STANDARD.md) | 공식 Figma 내부 레이어 네이밍 계약 | 활성 |
| [FIGMA_LAYER_RENAME_MATRIX.md](./FIGMA_LAYER_RENAME_MATRIX.md) | 공식 Figma 레이어 현재값 → 목표값 리네임 매트릭스 | 활성 |
| [FIGMA_APPEND_RENAME_RUNBOOK.md](./FIGMA_APPEND_RENAME_RUNBOOK.md) | append된 공식 페이지 범위 기준 수동 리네임 실행 문서 | 활성 |
| [FIGMA_SOURCE_OF_TRUTH.md](./FIGMA_SOURCE_OF_TRUTH.md) | 공식 Figma 파일 정의 및 운영 규칙 | 활성 |
| [FIGMA_SCREEN_COMPONENT_REGISTRY.md](./FIGMA_SCREEN_COMPONENT_REGISTRY.md) | 화면, 레이아웃, 컴포넌트 인벤토리 | 활성 |
| [CARD_COMPONENT_TAXONOMY.md](./CARD_COMPONENT_TAXONOMY.md) | 앱 카드 패턴과 shared component taxonomy | 활성 |
| [FIGMA_SCREEN_ROUTE_MAPPING.md](./FIGMA_SCREEN_ROUTE_MAPPING.md) | Figma 카드와 실제 Flutter 페이지/라우트의 1:1 매칭 레지스트리 | 활성 |
| [FIGMA_PAGE_USAGE_AUDIT.md](./FIGMA_PAGE_USAGE_AUDIT.md) | Figma 페이지 그룹별 active/archive/duplicate 감사 기준 | 활성 |
| [FIGMA_SYNC_CHANGELOG.md](./FIGMA_SYNC_CHANGELOG.md) | 코드 변경과 Figma 동기화 이력 | 활성 |
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
- 현재 카탈로그 범위: active route surface `18`개, live `15`, placeholder `3`
- canonical governance roots: `89:2`-`94:2`
- latest chat refresh append: `181:2` (`20 Chat Home / Character`)
- current manual delete targets: 없음
- 현재 관리 판정: active-route 삭제 후보 `0`, redirect-only 제외 `/`, `/home`
- 운영 규칙: [FIGMA_SOURCE_OF_TRUTH.md](./FIGMA_SOURCE_OF_TRUTH.md)
- 화면-라우트 매칭: [FIGMA_SCREEN_ROUTE_MAPPING.md](./FIGMA_SCREEN_ROUTE_MAPPING.md)
- 레이어 계약: [FIGMA_LAYER_NAMING_STANDARD.md](./FIGMA_LAYER_NAMING_STANDARD.md)
- 리네임 체크리스트: [FIGMA_LAYER_RENAME_MATRIX.md](./FIGMA_LAYER_RENAME_MATRIX.md)
- append rename runbook: [FIGMA_APPEND_RENAME_RUNBOOK.md](./FIGMA_APPEND_RENAME_RUNBOOK.md)
- 화면/컴포넌트 인벤토리: [FIGMA_SCREEN_COMPONENT_REGISTRY.md](./FIGMA_SCREEN_COMPONENT_REGISTRY.md)
- 동기화 이력: [FIGMA_SYNC_CHANGELOG.md](./FIGMA_SYNC_CHANGELOG.md)

### 0.1 캡처 파이프라인

- 빌드 서빙: `npm run figma:serve-build`
- 라이브 캡처: `npm run figma:capture`
- 카탈로그 HTML 생성: `npm run figma:catalog`
- 공식 파일 append: `npm run figma:push-catalog -- --initial-capture-id <capture-id>`
- 드리프트 검사: `npm run figma:guard`

공식 Figma 파일은 위 파이프라인으로 생성한 iPhone 규격 카탈로그를 Figma MCP existing-file capture로 기존 파일에 추가하는 방식으로 관리한다.
`<capture-id>`는 Figma MCP `generate_figma_design(outputMode="existingFile", fileKey="dkx3Biwe5xkiMQWsjq95LA")` 호출에서 시작한다.
카탈로그 append 이후에도 내부 레이어명이 `Main Content`, `Header`, `Article`, `Container` 같은 generic 이름으로 들어올 수 있으므로 canonical naming contract는 별도 rename batch로 정리해야 한다.
실제 수동 작업은 [FIGMA_APPEND_RENAME_RUNBOOK.md](./FIGMA_APPEND_RENAME_RUNBOOK.md)의 current canonical range `89:2`-`94:2` 기준으로 진행하되, `KAN-127`에서 append된 rich mystical 채팅 새로고침 페이지 `181:2`를 최신 검수 대상으로 확인한다. `180:2`와 기존 `95:2`는 historical append로 보존한다.
CI는 `npm run figma:guard`를 통해 route/UI 변경 시 Figma sync 기록, 문서 동기화, 그리고 canonical layer naming contract 존재 여부를 강제한다.

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
