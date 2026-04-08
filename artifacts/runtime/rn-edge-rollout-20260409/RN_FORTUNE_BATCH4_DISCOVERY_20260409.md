# RN Fortune Batch4 Discovery

Date: 2026-04-09
Target: `apps/mobile-rn`
Scope: compatibility / blind-date / family / past-life edge drift cleanup

## Goal

- 이미 edge를 타는 운세라도 RN 요청 필드와 카드 소비가 edge 스키마를 충분히 반영하지 못하는 지점을 줄인다.
- 특히 `compatibility`, `blind-date`, `family`는 구조화된 응답이 있는데도 RN 카드가 일반 bullet/card로 평평해지는 문제를 우선 해결한다.

## What I Checked

- [edge-runtime.ts](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/edge-runtime.ts)
- [adapter.ts](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/adapter.ts)
- [registry.ts](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-survey/registry.ts)
- [fortune-compatibility/index.ts](/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-compatibility/index.ts)
- [fortune-blind-date/index.ts](/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-blind-date/index.ts)
- [fortune-family-children/index.ts](/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-family-children/index.ts)
- [fortune-family-health/index.ts](/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-family-health/index.ts)
- [fortune-past-life/index.ts](/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/fortune-past-life/index.ts)

## Findings

- `compatibility`는 실제 edge가 `name_compatibility`, `zodiac_animal.score`, `star_sign.score`, `destiny_number`를 주는데 RN은 `personality_match` 텍스트 위주로만 소비하고 있었다.
- `blind-date`는 edge가 `firstImpressionTips`, `conversationTopics`, `outfitAdvice`, `locationAdvice`, `meetingInfo`, `finalMessage`를 주는데 RN은 일부만 반영하고 있었다.
- `family`는 subtype별로 `childrenCategories`, `seasonalAdvice`, `familySynergy`, `monthlyFlow` 같은 핵심 섹션이 내려오는데 RN은 공통 필드 몇 개만 읽고 있었다.
- `past-life`는 survey가 있지만 request builder에 전용 case가 없어 survey 문맥이 요청 body에 전혀 남지 않았다.

## Implementation Focus

- `edge-runtime.ts`
  - `compatibility` 요청에 nested `person1/person2`와 `compatibilityType` 보강
  - `blind-date` 요청에 edge 기본 필드 채움
  - `past-life` survey 문맥을 request body에 남김
- `adapter.ts`
  - `compatibility`를 score rail + structured sections 중심으로 노출
  - `blind-date` detail/recommendation/warning/specialTip 확장
  - `family` subtype 공통 구조를 더 많이 반영
