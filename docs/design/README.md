# Ondo 디자인 운영 가이드

## 개요

이 저장소의 공식 디자인 source of truth는 이제 **Paper**입니다.

- 디자인 기준 파일: `Ondo`
- 기준 페이지: `iPhone`
- canonical inventory: `paper/catalog_inventory.json`
- canonical tokens: `paper/design-tokens.json`
- repo-side governance docs: `docs/design/PAPER_*`

Flutter 런타임 UI는 기존 코드가 source of truth이고, Paper는 그 런타임을 설명하는 수동 디자인 계약으로 운영합니다.

## 핵심 문서

| 문서 | 설명 |
|------|------|
| [paper/README.md](../../paper/README.md) | Paper 운영 방식과 수동 동기화 절차 |
| [paper/catalog_inventory.json](../../paper/catalog_inventory.json) | 현재 Paper 파일의 canonical artboard inventory |
| [paper/design-tokens.json](../../paper/design-tokens.json) | Paper 기준 canonical design token export |
| [PAPER_SOURCE_OF_TRUTH.md](./PAPER_SOURCE_OF_TRUTH.md) | Paper 파일 정의와 현재 runtime coverage |
| [PAPER_SCREEN_ROUTE_MAPPING.md](./PAPER_SCREEN_ROUTE_MAPPING.md) | Paper artboard와 Flutter route/state 매핑 |
| [PAPER_SCREEN_COMPONENT_REGISTRY.md](./PAPER_SCREEN_COMPONENT_REGISTRY.md) | 화면/컴포넌트 인벤토리와 tracked source group |
| [PAPER_SYNC_CHANGELOG.md](./PAPER_SYNC_CHANGELOG.md) | 코드 변경과 Paper 계약 동기화 이력 |
| [CARD_COMPONENT_TAXONOMY.md](./CARD_COMPONENT_TAXONOMY.md) | 앱 카드 패턴과 shared component taxonomy |
| [WIDGET_ARCHITECTURE_DESIGN.md](./WIDGET_ARCHITECTURE_DESIGN.md) | 위젯 아키텍처 |
| [TALISMAN_GENERATION_INTEGRATION.md](./TALISMAN_GENERATION_INTEGRATION.md) | 부적 생성 통합 가이드 |

## Canonical Structure

Paper 기준 현재 canonical 구조는 아래 25개 artboard입니다.

- 개별 모바일 surface artboard `18`개
- catalog/governance artboard `7`개
- catalog section:
  - `00 Cover & Governance`
  - `10 Entry / Auth / Onboarding`
  - `20 Chat Home / Character`
  - `80 Admin / Policy / Utility`
  - `90 Components`
  - `99 Archive`

자세한 목록은 [paper/catalog_inventory.json](../../paper/catalog_inventory.json)과 [PAPER_SOURCE_OF_TRUTH.md](./PAPER_SOURCE_OF_TRUTH.md)를 기준으로 봅니다.

## 운영 절차

1. Paper 파일에서 artboard 또는 카탈로그 구성을 갱신합니다.
2. 변경된 기준을 `paper/catalog_inventory.json`에 반영합니다.
3. route/component 영향이 있으면 `PAPER_SOURCE_OF_TRUTH.md`, `PAPER_SCREEN_ROUTE_MAPPING.md`, `PAPER_SCREEN_COMPONENT_REGISTRY.md`를 함께 갱신합니다.
4. `PAPER_SYNC_CHANGELOG.md`에 해당 turn의 동기화 기록을 추가합니다.
5. `npm run paper:guard`를 실행해 repo-side 계약이 유지되는지 검증합니다.

## 런타임 기준

제품 표면과 라우트의 최종 source of truth는 여전히 아래 순서입니다.

1. `lib/routes/route_config.dart`
2. `lib/routes/routes/auth_routes.dart`
3. `lib/routes/character_routes.dart`
4. `docs/getting-started/APP_SURFACES_AND_ROUTES.md`
5. Paper design contract 문서

## 디자인 시스템 사용

현재 앱의 공통 스타일 계약은 계속 Flutter design system 기준으로 유지합니다.

### 1. 색상 사용

```dart
import 'package:ondo/core/design_system/design_system.dart';

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
import 'package:ondo/core/design_system/design_system.dart';

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
