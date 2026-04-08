# RN Fortune Batch 3 RCA

Date: 2026-04-09
Target: `apps/mobile-rn`
Scope: edge-backed fortune card readability

## Symptom

- edge는 구조화된 결과를 내려주는데 RN 채팅 카드에서 숫자형 운세와 paired guidance가 충분히 드러나지 않았다.
- 같은 payload라도 카드가 generic bullet/card 묶음처럼 보여 정보 밀도가 떨어졌다.

## WHY

- 어댑터가 이미 `scoreRails`와 `actionPair`를 만들더라도 카드 렌더러가 그 구조를 직접 소비하지 않으면, 실제 edge 구조화 결과가 일반 리스트로 다운그레이드된다.

## WHERE

- [embedded-result-card.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx)

## WHERE ELSE

- `adapter.ts`의 `extractScoreRails`, `buildActionPair`, `luckyItems` 추출 경로
- `fortune-results/primitives.tsx`의 `StatRail`, `DoDontPair`

## HOW

- 카드 렌더러에서 `scoreRails`와 `actionPair`를 직접 읽는다.
- `luckyItems` 길이에 따라 pills와 bullets를 분기해서 읽기성을 맞춘다.
- 기존 카드 구조와 토큰/edge/runtime 절차는 건드리지 않는다.
## Verification Plan

- `npm --prefix apps/mobile-rn run typecheck`
- `npx expo export --platform ios --output-dir /tmp/fortune-rn-export-batch4-20260409`
- `flutter analyze`
