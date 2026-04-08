# RN Fortune Schema Batch 2 Discovery

Date: 2026-04-08
Scope: `apps/mobile-rn` edge-backed fortune audit batch 2

## Symptoms

- Several RN fortunes still reached edge functions with incomplete or wrong request keys.
- Some edge-backed cards still mixed fallback copy into API-backed sections.
- `family`, `wish`, `talisman`, `tarot`, and `moving` had the clearest schema/output drift.

## Why

- RN survey definitions were narrower than edge schema contracts.
- `edge-runtime.ts` mapped survey answers to older/local field names instead of current edge request keys.
- `adapter.ts` merged fallback content even after API extraction, making real edge output look partially hardcoded.

## High-Risk Mismatches

- `tarot`: RN sent chip ids like `card-1` instead of `selectedCardIndices`/`selectedCards`.
- `wish`: RN sent `wishContent`/`wish_content`, but edge requires `wish_text`.
- `talisman`: RN passed survey purpose values as `category`, but edge only accepts catalog keys like `love_relationship`, `wealth_career`.
- `family`: RN only captured `concern` + `member`, but edge family subtypes expect `relationship`, `concern_label`, `detailed_questions`, `family_member_count`, and optionally `special_question`.
- `moving`: RN adapter expected camelCase sections while edge returns `direction_analysis`, `timing_analysis`, `cautions`, `terrain_analysis`.
- `wish`: edge returns `empathy_message`, `hope_message`, `fortune_flow`, `lucky_mission`, `dragon_message`, but RN normalization/adapter did not surface them properly.

## Fix Plan

1. Expand `family` survey to cover all edge family subtypes and subtype-specific detailed questions.
2. Repair `edge-runtime.ts` request builders for `tarot`, `wish`, `talisman`, and `family`.
3. Make profile field aliases friendlier to edge functions (`mbtiType` alongside `mbti`).
4. Update `adapter.ts` so API-derived metrics/text win over fallback when present.
5. Add wish/family/moving output extraction aligned to current edge payload shapes.
