# Verify Report - Luts Kakao Tone Logic

## 1. Change Summary
- What changed:
  - Added Luts-specific tone policy utility and tests.
  - Replaced hardcoded first greeting branch for Luts with tone-policy-driven opening.
  - Injected Luts style guard prompt into real-time response, pending response, and follow-up generation.
  - Normalized Luts follow-up and lunch proactive templates in app + server fallback.
  - Added Luts output guard in `character-chat` edge function (dedupe, 1~2 sentences, <=1 question, nickname gate).
- Why changed:
  - Remove unnatural forced banmal opening and enforce Kakao-like short-turn conversational style with user tone mirroring.
- Affected area:
  - `lib/features/character/...`
  - `supabase/functions/character-chat`
  - `supabase/functions/character-follow-up`
  - `docs/development/character-chat`

## 2. Static Validation
- `flutter analyze`
  - Result: Failed (repository-wide pre-existing issues)
  - Notes:
    - Command returned 78 issues (mainly existing lint infos/warnings in unrelated files).
- `flutter analyze <changed-files>`
  - Result: Passed
  - Notes:
    - `character_chat_provider.dart`, `luts_tone_policy.dart`, `default_characters.dart`, `luts_tone_policy_test.dart` => no issues.
- `dart format --set-exit-if-changed .`
  - Result: Passed
  - Notes:
    - `Formatted 1042 files (0 changed)`.
- `dart run build_runner build --delete-conflicting-outputs` (if applicable)
  - Result: Not required
  - Notes:
    - No freezed/model generation changes for this task.
- `deno check supabase/functions/character-chat/index.ts`
  - Result: Failed (pre-existing shared module type issues)
  - Notes:
    - Fails in `_shared` modules (`llm/factory.ts`, `gemini.ts`, `notification_push.ts`, `template-engine.ts`), not from current Luts logic changes.

## 3. Tests and QA
- Unit/Widget/Integration tests run:
  - Command: `flutter test`
  - Result: Passed (`All tests passed!`)
- Playwright QA (if applicable):
  - Command: Not run
  - Result:
    - This change is logic/prompt/policy focused and existing automated Flutter tests passed.

## 4. Files Changed
1. `docs/development/character-chat/luts_kakao_style_v2.md` - Luts Kakao style rules spec.
2. `docs/development/reports/2026-02-16_luts_tone_rca.md` - RCA report.
3. `docs/development/reports/2026-02-16_luts_tone_discovery.md` - Discovery report.
4. `docs/development/reports/2026-02-16_luts_tone_verify.md` - Verify report.
5. `lib/features/character/presentation/utils/luts_tone_policy.dart` - Luts tone profile/heuristics/prompt + output normalization.
6. `lib/features/character/presentation/providers/character_chat_provider.dart` - Luts tone policy integration across message flows.
7. `lib/features/character/data/default_characters.dart` - Luts follow-up/lunch proactive template normalization.
8. `supabase/functions/character-chat/index.ts` - Luts prompt guard + output post-processing.
9. `supabase/functions/character-follow-up/index.ts` - Luts fallback template normalization.
10. `test/unit/features/character/presentation/utils/luts_tone_policy_test.dart` - New unit tests.

## 5. Risks and Follow-ups
- Known risks:
  - Heuristic language/speech-level detection can misclassify mixed-language or very short inputs.
  - `deno check` currently blocked by pre-existing `_shared` typing issues, so strict TS gate is not green.
- Deferred items:
  - Improve mixed-language scoring and configurable nickname lexicon in a follow-up task.

## 6. User Manual Test Request
- Scenario:
  1. Open an existing Luts chat room (no reset).
  2. Send Korean formal message (`안녕하세요, 지금 뭐하고 계세요?`) and verify formal mirrored short reply.
  3. Send Korean casual message (`야 뭐해?`) and verify casual mirrored short reply.
  4. Send English/Japanese messages and verify language mirroring.
  5. Verify no nickname appears before user-first nickname usage.
  6. Send nickname first (`자기야`) and verify limited nickname usage can appear afterwards.
  7. Trigger follow-up/lunch proactive and verify short non-repetitive one-bubble style.
- Expected result:
  - Luts keeps 1~2 sentence concise replies, <=1 question, direct first sentence answer, nickname gate respected.
- Failure signal:
  - Multi-paragraph response, repeated sentence, >1 question, premature nickname usage, or mismatch with user language/formality.

## 7. Completion Gate
- Verify reports generated and automated checks executed.
- Pending: Jira transition/comment + commit/push + GitHub Actions verification.
