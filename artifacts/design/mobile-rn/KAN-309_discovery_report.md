# KAN-309 Discovery Report

## Summary
- Goal: RN `운세보기`에서 각 상담사가 실제 보유한 운세 옵션(1~7개)을 모두 노출하고, 옵션 탭 시 같은 채팅 안에서 설문/결과 흐름이 이어지도록 만든다.
- Source of truth: product contracts + Flutter fortune chat 구조.
- Agent split:
  - `Turing`: Flutter/product-contract roster 및 specialty truth audit
  - `Volta`: RN current truncation/filter points audit
  - `Hubble`: runtime/design QA 관점의 target UX audit

## Source Of Truth
- Product-contract fortune roster: `packages/product-contracts/src/characters.ts`
- Product-contract fortune type universe: `packages/product-contracts/src/fortunes.ts`
- Flutter fortune roster: `lib/features/character/data/fortune_characters.dart`
- Flutter specialty chip bar: `lib/features/character/presentation/pages/character_chat_panel.dart`

## Character Specialty Inventory
- 하늘: `daily`, `new-year`, `fortune-cookie`
- 무현 도사: `traditional-saju`, `face-reading`, `naming`
- 스텔라: `zodiac`, `zodiac-animal`, `birthstone`
- Dr. 마인드: `mbti`, `personality-dna`, `talent`, `past-life`
- 로제: `love`, `compatibility`, `blind-date`, `ex-lover`, `avoid-people`, `celebrity`, `yearly-encounter`
- 제임스 김: `career`, `wealth`, `exam`
- 럭키: `lucky-items`, `lotto`, `ootd-evaluation`
- 마르코: `match-insight`, `game-enhance`, `exercise`
- 리나: `moving`
- 루나: `tarot`, `dream`, `biorhythm`, `family`, `pet-compatibility`, `talisman`, `wish`

## Current RN Gaps
- Fortune characters with no supported runtime are filtered out entirely in `apps/mobile-rn/src/screens/chat-screen.tsx`.
- Selected character actions are filtered by `supportsChatNativeRuntime`, so many real specialties never appear in chat.
- Fortune root list truncates characters to 4 in `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`.
- Fortune root “맞춤 시작점” truncates actions to 3.
- Empty-send fallback auto-picks the first supported action only.

## Target UX
- `운세보기` root keeps the expert-list structure.
- Every fortune character row shows its own specialty options directly under the character summary.
- Each specialty chip is tappable.
- Tapping a specialty chip:
  1. selects that fortune character
  2. opens the same chat surface
  3. appends launch messages
  4. starts inline survey if defined
  5. otherwise injects an embedded result in the same thread
- No `/result/*` page push in the production path.

## Runtime Strategy
- Do not hide unsupported specialties.
- Expand RN support by aliasing missing fortune types to an existing survey family and/or existing embedded-result family.
- Representative family mapping will follow Flutter’s embedded result grouping:
  - daily family -> `daily-calendar`
  - traditional/profile family -> `traditional-saju` / `family` / `constellation`
  - love family -> `love`
  - career family -> `career`
  - wealth family -> `wealth`
  - personality family -> `personality-dna`
  - health/activity family -> `exercise`
  - mystical family -> `past-life` / `tarot`
  - interactive family -> `wish` / `game-enhance`

## Files Expected To Change
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/lib/chat-shell.ts`
- `apps/mobile-rn/src/features/chat-survey/registry.ts`
- `apps/mobile-rn/src/features/fortune-results/mapping.ts`
- `apps/mobile-rn/src/features/chat-results/fixtures.ts`

## Validation Plan
- `npm run rn:typecheck`
- `npm run rn:test`
- `flutter analyze`
- `git diff --check`
- iPhone 17 runtime screenshots for:
  - fortune root list with all experts + per-row options
  - high-density expert like 로제/루나
  - specialty chip tap -> same-chat survey/result launch
