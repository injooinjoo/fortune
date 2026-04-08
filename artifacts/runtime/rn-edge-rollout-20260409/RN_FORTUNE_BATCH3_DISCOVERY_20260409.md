# RN Fortune Batch 3 Discovery

Date: 2026-04-09
Target: `apps/mobile-rn`
Scope: embedded result card readability for already edge-backed fortunes

## Goal

- RN 카드가 이미 edge에서 내려오는 구조화된 payload를 generic flatten보다 더 잘 읽도록 보강한다.
- 특히 `zodiac`, `zodiac-animal`, `constellation`, `birthstone`, `biorhythm`, `game-enhance` 같은 타입의 가독성을 올린다.

## What I Checked

- [adapter.ts](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/adapter.ts)
- [embedded-result-card.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx)
- [primitives.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/fortune-results/primitives.tsx)
- [fortune-zodiac-animal/index.ts](/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-zodiac-animal/index.ts)
- [fortune-constellation/index.ts](/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-constellation/index.ts)
- [fortune-birthstone/index.ts](/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-birthstone/index.ts)
- [fortune-biorhythm/index.ts](/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-biorhythm/index.ts)

## Findings

- `adapter.ts`는 이미 여러 운세에서 `scoreRails`, `actionPair`, 전용 `detailSections`를 뽑고 있다.
- 하지만 RN 카드 렌더러는 그 richer payload를 충분히 소비하지 못하면, 결국 숫자형 운세도 긴 bullet/card 묶음처럼 보이게 된다.
- `KeywordPills`는 짧은 키워드에는 맞지만 긴 phrase형 `luckyItems`에는 읽기성이 떨어진다.

## Decision

- 카드 자체는 유지하되, richer payload를 노출하는 최소 렌더링 보강을 우선한다.
- 새 디자인 시스템을 만들지 않고, 기존 primitive인 `StatRail`, `DoDontPair`, `BulletList` 재사용으로 해결한다.

## Implementation Focus

- `scoreRails` 렌더링 활성화
- `actionPair`가 있으면 `recommendations/warnings`를 분리 렌더링하지 않고 쌍 구조 우선
- `luckyItems`가 길면 pills 대신 bullet list로 렌더링
