# UI 디자인 시스템 가이드

> 최종 업데이트: 2026.04.06

Ondo의 현재 UI 소스 오브 트루스는 ChatGPT 스타일 모노크롬 문법이 아니라, Paper 정렬형 다크 우선 디자인 시스템입니다. 이 문서는 실제 `DSColors`, `DSTypography`, `DS*` 컴포넌트, `PaperRuntime*` 계층을 기준으로 정리합니다.

## 디자인 시스템 구조

```text
lib/core/design_system/
├── tokens/
│   ├── ds_colors.dart
│   ├── ds_typography.dart
│   ├── ds_spacing.dart
│   ├── ds_radius.dart
│   ├── ds_shadows.dart
│   ├── ds_animation.dart
│   └── ds_saju_colors.dart
├── theme/
│   ├── ds_theme.dart
│   └── ds_extensions.dart
├── components/
│   ├── ds_button.dart
│   ├── ds_card.dart
│   ├── ds_chip.dart
│   ├── ds_badge.dart
│   ├── ds_bottom_sheet.dart
│   ├── ds_text_field.dart
│   ├── ds_loading.dart
│   ├── ds_modal.dart
│   ├── ds_toggle.dart
│   ├── ds_list_tile.dart
│   ├── ds_section_header.dart
│   ├── hanji_background.dart
│   └── traditional/
│       ├── cloud_bubble.dart
│       ├── cloud_bubble_painter.dart
│       └── traditional_knot_indicator.dart
└── utils/
    └── ds_haptics.dart
```

## Source Of Truth

| 영역 | 기준 파일 |
|------|-----------|
| 색상 토큰 | `lib/core/design_system/tokens/ds_colors.dart` |
| 타이포그래피 | `lib/core/design_system/tokens/ds_typography.dart` |
| context extension | `lib/core/design_system/theme/ds_extensions.dart` |
| Paper page chrome | `lib/core/widgets/paper_runtime_chrome.dart`, `lib/core/widgets/paper_runtime_surface_kit.dart` |
| 결과 카드 shell | `lib/shared/components/cards/fortune_cards.dart` |

## 색상 시스템

현재 색상 철학은 다음과 같습니다.

- 다크 모드 우선
- deep navy-black background
- cool white text
- blue-gray secondary text
- purple CTA
- warm amber highlight

### 핵심 토큰

| 용도 | 토큰 | 값 |
|------|------|----|
| 페이지 배경 | `DSColors.background` | `#0B0B10` |
| 보조 배경 | `DSColors.backgroundSecondary` | `#1A1A1A` |
| 카드 표면 | `DSColors.surface` | `#1A1A1A` |
| 중첩 표면 | `DSColors.surfaceSecondary` | `#23232B` |
| 주 텍스트 | `DSColors.textPrimary` | `#F5F6FB` |
| 보조 텍스트 | `DSColors.textSecondary` | `#9198AA` |
| 경계선 | `DSColors.border` | `#FFFFFF14` |
| CTA 배경 | `DSColors.ctaBackground` | `#8B7BE8` |
| 정보 accent | `DSColors.accentSecondary` | `#8FB8FF` |
| 하이라이트 accent | `DSColors.accentTertiary` | `#E0A76B` |

라이트 모드는 `Lt` suffix 토큰(`backgroundLt`, `textPrimaryLt` 등)으로 역상 대응합니다.

### 사용 원칙

```dart
// 권장
final colors = context.colors;
Container(color: colors.background);

// 허용
Container(color: DSColors.ctaBackground);

// 금지
Container(color: const Color(0xFF8B7BE8));
Container(color: Colors.black);
```

## 타이포그래피

문서 기준 권장 API는 `context.typography.*` 또는 `DSTypography.*`입니다.

```dart
Text('타이틀', style: context.typography.headingLarge)
Text('본문', style: context.typography.bodyMedium)
Text('라벨', style: context.typography.labelSmall)
```

### 권장 스타일

| 스타일 | 용도 |
|--------|------|
| `displayLarge`, `displayMedium`, `displaySmall` | splash / hero |
| `headingLarge`, `headingMedium`, `headingSmall` | 페이지/카드 제목 |
| `bodyLarge`, `bodyMedium`, `bodySmall` | 본문/설명 |
| `labelLarge`, `labelMedium`, `labelSmall`, `labelTiny` | UI 라벨 |
| `numberLarge`, `numberMedium`, `numberSmall` | 숫자/통계 |
| `fortuneTitle`, `fortuneSubtitle`, `fortuneContent` | 전통/서사형 콘텐츠 |

### 호환성 메모

- `context.heading1`, `context.heading2` 같은 alias는 남아 있지만, 새 문서와 새 UI 설계는 `context.typography.*`를 기준으로 설명합니다.
- `body1`, `caption`, raw `fontSize` 직접 표기는 더 이상 문서 기준으로 사용하지 않습니다.

## 공용 컴포넌트 계층

### 1. DS primitives

| 컴포넌트 | 핵심 변형 |
|----------|-----------|
| `DSButton` | `primary`, `secondary`, `outline`, `ghost`, `destructive`, `gold`, `progress` |
| `DSCard` | `flat`, `elevated`, `outlined`, `hanji`, `premium`, `gradient`, `glassmorphism` |
| `DSChip` | `filled`, `outlined`, `subtle` |
| `DSChoiceChips` | 단일 선택 segmented chips |
| `DSBadge` | 상태/카운트 표기 |
| `DSTextField` | 폼 입력 |
| `DSModal`, `DSBottomSheet`, `DSLoading`, `DSToggle`, `DSListTile`, `DSSectionHeader` | 공통 surface |

### 2. Paper runtime surface

| 컴포넌트 | 파일 | 역할 |
|----------|------|------|
| `PaperRuntimeBackground` | `paper_runtime_chrome.dart` | 링/배경 wrapper |
| `PaperRuntimePanel` | `paper_runtime_chrome.dart` | Paper 카드 surface |
| `PaperRuntimeExpandablePanel` | `paper_runtime_chrome.dart` | 확장형 패널 |
| `PaperRuntimePill` | `paper_runtime_chrome.dart` | eyebrow / pill |
| `PaperRuntimeAppBar` | `paper_runtime_surface_kit.dart` | 상단 내비게이션 |
| `PaperRuntimeMenuTile` | `paper_runtime_surface_kit.dart` | 설정 list row |
| `PaperRuntimeToggleTile` | `paper_runtime_surface_kit.dart` | 토글 row |
| `PaperRuntimeButton` | `paper_runtime_surface_kit.dart` | 페이지 액션 버튼 |

### 3. 결과 카드 shell

- `FortuneCardSurface`
- `FortuneCardBadge`
- `FortuneMetricPill`
- `FortuneFeatureCard`
- `FortuneRecordCard`
- `FortuneSectionCard`
- `FortuneResultFrame`

결과 화면은 DS primitive만으로 끝내지 않고, 필요 시 `PaperRuntime*`와 `Fortune*` shell을 조합합니다.

## 전통/한지 컴포넌트

| 컴포넌트 | 파일 | 역할 |
|----------|------|------|
| `HanjiBackground` | `components/hanji_background.dart` | 한지 텍스처 배경 wrapper |
| `CloudBubble` | `components/traditional/cloud_bubble.dart` | 전통풍 말풍선 |
| `CloudBubblePainter` | `components/traditional/cloud_bubble_painter.dart` | 구름 bubble painter |
| `TraditionalKnotIndicator` | `components/traditional/traditional_knot_indicator.dart` | 장식형 매듭 indicator |

## Preferred Layer Guide

| 상황 | 우선 사용 |
|------|-----------|
| 일반 앱 UI | `DS*` + `context.colors` + `context.typography` |
| Paper-aligned 페이지 shell | `PaperRuntime*` |
| 운세 결과 공용 card shell | `Fortune*` shared cards |
| 결과 타입별 전용 조립 | feature 전용 `fortune_bodies/` 또는 page/widget layer |

## 금지 사항

| 금지 | 대안 |
|------|------|
| `Color(0xFF...)` 하드코딩 | `DSColors.*`, `context.colors.*` |
| raw `fontSize` 직접 사용 | `context.typography.*`, `DSTypography.*` |
| `Colors.white`, `Colors.black` | `context.colors.textPrimary`, `background` |
| 오래된 ChatGPT 문법을 기본 규칙으로 설명 | Paper-aligned DS 문법으로 설명 |

## 관련 문서

- [16-typography-policy.md](16-typography-policy.md)
- [24-page-layout-reference.md](24-page-layout-reference.md)
- [26-widget-component-catalog.md](26-widget-component-catalog.md)
