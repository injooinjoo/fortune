# Fortune Paper 운영 가이드

## 개요

이 저장소의 공식 디자인 source of truth는 Paper입니다.

- Paper 파일명: `Fortune`
- 기준 페이지: `iPhone`
- canonical inventory: `paper/catalog_inventory.json`
- canonical tokens: `paper/design-tokens.json`
- repo-side governance docs: `docs/design/PAPER_*`

Flutter 구현은 기존 코드가 source of truth이고, Paper는 그 런타임을 설명하는 수동 디자인 계약으로 유지합니다.

## Canonical Inventory

현재 Paper 파일은 총 `25`개 artboard를 canonical set으로 사용합니다.

- 모바일 surface artboard `18`개
- catalog/governance artboard `7`개

catalog/governance artboard는 아래 구조를 따릅니다.

- `Paper Catalog · M9 Surface Inventory`
- `Paper Catalog · 00 Cover & Governance`
- `Paper Catalog · 10 Entry / Auth / Onboarding`
- `Paper Catalog · 20 Chat Home / Character`
- `Paper Catalog · 80 Admin / Policy / Utility`
- `Paper Catalog · 90 Components`
- `Paper Catalog · 99 Archive`

세부 메타데이터는 `paper/catalog_inventory.json`에 고정합니다.

## Tokens

`paper/design-tokens.json`은 현재 canonical token export입니다.

- 색상, 타이포그래피, spacing, radius, shadow, sizing, duration을 보관합니다.
- Flutter design system 값과 다르면 Flutter 런타임 코드가 우선이며, Paper token export는 그 차이를 문서화하는 용도로 갱신합니다.

## 운영 절차

1. Paper 파일에서 artboard 또는 카탈로그 구조를 수동으로 갱신합니다.
2. 저장소의 `paper/catalog_inventory.json`을 같은 구조로 업데이트합니다.
3. route 또는 component 영향이 있으면 아래 문서를 함께 갱신합니다.
   - `docs/design/PAPER_SOURCE_OF_TRUTH.md`
   - `docs/design/PAPER_SCREEN_ROUTE_MAPPING.md`
   - `docs/design/PAPER_SCREEN_COMPONENT_REGISTRY.md`
4. 변경 turn을 `docs/design/PAPER_SYNC_CHANGELOG.md`에 기록합니다.
5. `npm run paper:guard`를 실행해 repo-side design contract를 검증합니다.

## Scope Rules

- Paper는 수동 SoT입니다. 자동 push, remote capture, external design sync는 현재 운영 범위에 포함하지 않습니다.
- redirect-only route (`/`, `/home`)는 Paper artboard를 만들지 않습니다.
- transient runtime (`/auth/callback`)은 전용 Paper artboard 대신 문서로만 유지할 수 있습니다.
