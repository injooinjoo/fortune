# KAN-331 Discovery Report

## Scope

- Jira: `KAN-331`
- Target: `apps/mobile-rn` fortune result system
- Reference sources:
  - Flutter result families in `lib/features/character/presentation/widgets/fortune_bodies/`
  - Edge schema contract in `.claude/docs/25-fortune-result-schemas.md`
  - Pencil gap audit in `artifacts/design/pencil/KAN-271_discovery_report.md`
- Goal: stop collapsing multiple edge-backed fortune types into a smaller RN `resultKind` set, and align RN result surfaces with the existing Flutter/Pencil family split.

## Discovery Commands

- `sed -n '1,240p' apps/mobile-rn/src/features/fortune-results/types.ts`
- `sed -n '1,280p' apps/mobile-rn/src/features/fortune-results/mapping.ts`
- `sed -n '1,260p' apps/mobile-rn/src/features/fortune-results/registry.tsx`
- `find apps/mobile-rn/src/features/fortune-results -maxdepth 2 -type f | sort`
- `sed -n '1,260p' apps/mobile-rn/src/features/chat-results/fixtures.ts`
- `sed -n '1,260p' lib/features/character/presentation/widgets/embedded_fortune_component.dart`
- `sed -n '588,760p' lib/features/character/presentation/widgets/fortune_bodies/relationship_fortune_body.dart`
- `sed -n '1,240p' supabase/functions/fortune-yearly-encounter/index.ts`
- `sed -n '411,470p' .claude/docs/25-fortune-result-schemas.md`
- `sed -n '1151,1298p' .claude/docs/25-fortune-result-schemas.md`

## Current RN Drift

- RN `resultKinds` only covered `F01` through `F20`.
- Edge-backed types were being collapsed into broader families:
  - `exam -> career`
  - `compatibility`, `blind-date`, `ex-lover`, `avoid-people`, `yearly-encounter -> love`
  - `decision -> coaching` was not represented at all in RN result metadata
  - `daily-review` was not represented at all in RN result metadata
- This was inconsistent with:
  - Flutter result family routing
  - Pencil coverage gaps for `F21` through `F28`
  - edge schemas that clearly expose distinct payloads, especially `yearly-encounter`

## Reference Mapping

| RN Result Kind | Fortune Code | Paper Node | Reference Surface |
| --- | --- | --- | --- |
| `exam` | `F21` | `6VU-1` | Flutter career family |
| `compatibility` | `F22` | `6VV-1` | Flutter relationship family |
| `blind-date` | `F23` | `6VW-1` | Flutter relationship family |
| `avoid-people` | `F24` | `6VX-1` | Flutter relationship family |
| `ex-lover` | `F25` | `6VY-1` | Flutter relationship family |
| `yearly-encounter` | `F26` | `6VZ-1` | Edge schema + Flutter relationship family gap |
| `decision` | `F27` | `6W0-1` | Flutter coaching family |
| `daily-review` | `F28` | `6W1-1` | Flutter coaching family |

## Reuse Decision

- Reuse existing RN result primitives and layout system.
- Extend RN metadata and registry instead of replacing batch `A-D`.
- Add a new RN screen batch for `F21` through `F28`.
- Keep survey aliases unchanged for now; the change is limited to result surface mapping and presentation.

## Implementation Decision

1. Expand RN `resultKinds` with `F21` through `F28`.
2. Route edge fortune types to their own RN `resultKind` instead of collapsing them into `love` or `career`.
3. Add dedicated RN screens that mirror the existing Flutter family intent while staying within the current RN primitive system.
4. Add fallback chat-result seeds so embedded result cards stay coherent for the new result kinds.
