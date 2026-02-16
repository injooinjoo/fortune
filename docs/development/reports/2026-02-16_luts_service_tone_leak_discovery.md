# Discovery Report - Luts Service Tone Leak Hotfix

## 1) Scope
- 러츠 응답에서 `무엇을 도와드릴까요` 문구 누출 방지.
- 인사 에코 정규화 보강.

## 2) Search Performed
- `rg -n "_serviceTonePattern|_serviceToneReplacements|greetingEchoPattern" lib/features/character/presentation/utils/luts_tone_policy.dart`
- `rg -n "LUTS_SERVICE_TONE_PATTERN|removeLutsServiceTone|greetingEchoPattern" supabase/functions/character-chat/index.ts`
- `rg -n "서비스형 문구|applyGeneratedTone" test/unit/features/character/presentation/utils/luts_tone_policy_test.dart`

## 3) Existing Reusable Components
- Dart: `applyGeneratedTone` + `_sanitizeServiceTone` + `_normalizeGreetingEcho`
- TS: `applyLutsOutputGuard` + `removeLutsServiceTone` + `normalizeLutsGreetingEcho`

## 4) Gap Analysis
- `무엇을 도와드릴까요` 변형이 서비스 톤 금지 패턴에서 누락.
- 인사 에코 패턴이 `저도` 삽입 케이스를 놓침.

## 5) Reuse vs New
- Reuse:
  - 기존 guard 파이프라인 유지.
- New:
  - 패턴/치환 규칙 확장.
  - 누출 재발 방지 단위 테스트 1건 추가.

## 6) Implementation Decision
- 구조 변경 없이 규칙 강화로 hotfix.
- 클라이언트/서버 가드를 동시에 강화해 경로별 편차를 줄임.
