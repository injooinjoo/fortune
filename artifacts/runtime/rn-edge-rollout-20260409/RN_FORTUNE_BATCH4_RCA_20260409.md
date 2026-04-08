# RN Fortune Batch4 RCA

Date: 2026-04-09
Target: `apps/mobile-rn`
Scope: edge-backed fortune schema drift

## Symptom

- edge function은 이미 richer payload를 주는데 RN 채팅 카드가 일부 운세를 generic 형태로만 보여줬다.
- 일부 운세는 survey에서 받은 문맥이 실제 edge request body에 충분히 실리지 않았다.

## WHY

- request builder가 최소 필드만 채우는 케이스가 남아 있었다.
- adapter가 `fallback seed + generic flatten` 중심으로 작성된 케이스가 남아 있어서, 실제 numeric/section payload가 카드에 잘 드러나지 않았다.

## WHERE

- [edge-runtime.ts](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/edge-runtime.ts)
- [adapter.ts](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/adapter.ts)

## WHERE ELSE

- `compatibility`: 숫자형 궁합 세부 항목 미소비
- `blind-date`: 첫인상/대화/룩/장소/만남 정보 미소비
- `family`: subtype별 공통 구조 미소비
- `past-life`: survey 문맥 미전달

## HOW

- request builder는 edge에서 안전하게 받을 수 있는 기본 필드를 더 채운다.
- adapter는 숫자형 payload는 `metric + score rail`, 구조형 payload는 `detailSections`, paired guidance는 `recommendation/warning`으로 분리해 소비한다.

## Verification Plan

- `npm --prefix apps/mobile-rn run typecheck`
- `npx expo export --platform ios --output-dir /tmp/fortune-rn-export-batch5-20260409`
- `flutter analyze`
