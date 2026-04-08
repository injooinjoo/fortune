# KAN-270 Discovery Report

## 1. Goal
- Requested change: audit the live `Paper` fortune result screens one by one, tighten `Pencil` fidelity decisions, and prepare/apply the same composition to the real Flutter app.
- Work type: Widget
- Scope:
  - `Paper` source-of-truth review for `F07` through `F20`
  - `Pencil` import intent validation
  - Flutter `fortune_bodies/*` presentation-layer refinement

## 2. Search Strategy
- Keywords:
  - `fortune_bodies`
  - `EmbeddedFortuneComponent`
  - `fortune result`
  - `Paper artboard`
  - `Color(` / `Colors.`
- Commands:
  - `rg --files lib/features/character/presentation/widgets/fortune_bodies`
  - `sed -n '1,240p' lib/features/character/presentation/widgets/embedded_fortune_component.dart`
  - `sed -n '1,260p' lib/features/character/presentation/widgets/fortune_bodies/*_fortune_body.dart`
  - `rg -n "Color\\(|Colors\\." lib/features/character/presentation/widgets/fortune_bodies`
- MCP checks:
  - `paper.get_basic_info`
  - `paper.get_tree_summary` for `5EM-1`, `5H4-1`, `5NH-1`, `5R7-1`

## 3. Similar Code Findings
- Reusable:
  1. `lib/features/character/presentation/widgets/embedded_fortune_component.dart` - canonical type router from normalized `fortuneType` to body widgets
  2. `lib/features/character/presentation/widgets/fortune_bodies/_fortune_body_shared.dart` - shared shell/card/list/timeline/tip primitives already used across all fortune result bodies
  3. `lib/features/character/presentation/widgets/fortune_bodies/_fortune_visual_components.dart` - shared animated score ring, staggered reveals, metric tiles, and infographic primitives
  4. `lib/features/character/presentation/widgets/fortune_bodies/career_fortune_body.dart` - closest existing example of Paper-first composition with section order comments and relatively tight scope
  5. `lib/features/character/presentation/widgets/fortune_bodies/tarot_fortune_body.dart` - strong Paper-aligned composition for card spread + interpretation sequence
- Reference only:
  1. `lib/features/character/presentation/widgets/fortune_bodies/relationship_fortune_body.dart` - functionally rich, but currently over-expanded versus `Paper` `F08`
  2. `lib/features/character/presentation/widgets/fortune_bodies/health_fortune_body.dart` - mostly aligned structurally, but still carries hard-coded visual colors
  3. `lib/features/character/presentation/widgets/fortune_bodies/personality_fortune_body.dart` - rich component inventory, but several Paper accents are hard-coded instead of tokenized
  4. `lib/features/character/presentation/widgets/fortune_bodies/wealth_fortune_body.dart` - section order is close to `Paper` `F15`, but visual accents are still hard-coded

## 4. Paper-to-App Mapping
- `F07` `5BF-1` -> `CareerFortuneBody._buildCareerBody`
- `F08` `5EM-1` -> `RelationshipFortuneBody._buildLoveBody`
- `F09` `5H4-1` -> `HealthFortuneBody._buildHealthBody`
- `F10` `5JA-1` -> `CoachingFortuneBody._buildCoachingBody`
- `F11` `5KK-1` -> `FamilyFortuneBody._buildFamilyBody`
- `F12` `5LS-1` -> `MysticalFortuneBody._buildMysticalBody`
- `F13` `5MP-1` -> `InteractiveFortuneBody._buildGameEnhanceBody`
- `F14` `5NH-1` -> `PersonalityFortuneBody._buildPersonalityDnaBody` / `mbti` branch depending on payload
- `F15` `5R7-1` -> `WealthFortuneBody._buildWealthBody`
- `F16` `4XI-1` -> `CareerFortuneBody._buildTalentBody`
- `F17` `510-1` -> `HealthFortuneBody._buildExerciseBody`
- `F18` `53E-1` -> `TarotFortuneBody`
- `F19` `55X-1` -> `InteractiveFortuneBody._buildGameEnhanceBody`
- `F20` `58H-1` -> `InteractiveFortuneBody._buildOotdBody`

## 5. Priority Diff Findings
- `P0` `relationship_fortune_body.dart`
  - `Paper F08` preserves a compact stack: header, love-energy hero, 3 stat cards, do/don't, timeline, luck grid.
  - App body currently adds love profile, charm points, improvement areas, compatibility insights, today advice, predictions.
  - Decision: reduce `love` layout to the Paper stack and treat extra data as fallback-only, not primary structure.
- `P1` `health_fortune_body.dart`
  - `Paper F09` structure is acceptable, but the current build hard-codes several accent colors directly in the widget tree.
  - Decision: keep section order, move health accents behind a single local token palette or derived design-system colors.
- `P1` `personality_fortune_body.dart`
  - `Paper F14` is still dense, but the visual system should be normalized; current implementation carries many direct hex colors for dimension bars and comparison cards.
  - Decision: preserve layout grammar while centralizing accent colors and reducing one-off color literals.
- `P1` `wealth_fortune_body.dart`
  - `Paper F15` section order is already close, but the finance category/status colors are still local hex values instead of a coherent palette wrapper.
  - Decision: keep the structure and normalize accent usage.

## 6. Reuse Decision
- Reuse as-is:
  - `EmbeddedFortuneComponent`
  - `_fortune_body_shared.dart`
  - `_fortune_visual_components.dart`
  - `CareerFortuneBody`
  - `TarotFortuneBody`
- Extend existing code:
  - `RelationshipFortuneBody` for Paper parity
  - `HealthFortuneBody` for palette cleanup
  - `PersonalityFortuneBody` for palette cleanup
  - `WealthFortuneBody` if palette abstraction is needed after the first pass
- New code required:
  - Small local helper constants or palette accessors inside existing body files
  - No new feature, provider, service, or route files required
- Duplicate prevention notes:
  - Do not create new body widgets or parallel v2 files
  - Keep changes inside existing presentation-layer body widgets and shared fortune UI primitives

## 7. Planned Changes
- Files to edit:
  1. `lib/features/character/presentation/widgets/fortune_bodies/relationship_fortune_body.dart`
  2. `lib/features/character/presentation/widgets/fortune_bodies/health_fortune_body.dart`
  3. `lib/features/character/presentation/widgets/fortune_bodies/personality_fortune_body.dart`
  4. `lib/features/character/presentation/widgets/fortune_bodies/wealth_fortune_body.dart`
  5. `lib/features/character/presentation/widgets/fortune_bodies/_fortune_body_shared.dart` if shared palette helpers are the cleanest path
- Files to create:
  1. `artifacts/design/pencil/KAN-270_discovery_report.md`

## 8. Validation Plan
- Static checks:
  - `flutter analyze`
  - `dart format --set-exit-if-changed lib/features/character/presentation/widgets/fortune_bodies`
- Runtime checks:
  - verify the affected Paper artboards remain the source-of-truth for section order and visual intent
  - confirm app bodies still render with missing/partial fields because all result payloads are schema-flexible
- Test cases:
  - `love` payload with only score + dos/donts + timeline + lucky items
  - `health` payload with partial metric data
  - `mbti/personality-dna` payload with reduced spectrum data
  - `wealth` payload with only categories + usage tip + lucky items
