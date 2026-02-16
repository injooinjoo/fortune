# RCA Report - Luts Service Tone Leak (`무엇을 도와드릴까요`)

## 1) Symptom
- 러츠 인사 턴에서 금지된 상담사 톤 문구 `무엇을 도와드릴까요?`가 그대로 출력됨.

## 2) WHY (Root Cause)
- 서비스 톤 차단 정규식이 `무엇을 도와드릴 수` 계열만 포함하고 `무엇을 도와드릴까요` 직접 표현을 누락.
- 인사 에코 정규식이 `네, 저도 만나서 반가워요` 형태를 충분히 커버하지 못해 기본 응답 정규화가 빗나감.

## 3) WHERE (Primary Locations)
- `lib/features/character/presentation/utils/luts_tone_policy.dart`
  - `_serviceTonePattern`
  - `_serviceToneReplacements`
  - `_normalizeGreetingEcho`
- `supabase/functions/character-chat/index.ts`
  - `LUTS_SERVICE_TONE_PATTERN`
  - `removeLutsServiceTone`
  - `normalizeLutsGreetingEcho`

## 4) WHERE ELSE (Global Search Findings)
- 검색 키워드:
  - `도와드릴까요`
  - `service tone`
  - `greetingEchoPattern`
- 동일 누락 패턴이 Dart/TypeScript 양쪽 가드에 동일하게 존재함.

## 5) HOW (Corrective Pattern)
- `도와드릴까요` 직표현을 클라이언트/서버 모두 하드 블록 패턴에 추가.
- 인사 에코 정규식에 `저도` 옵셔널을 추가해 중복 인사를 기본 응답으로 강제 정규화.

## 6) Fix Plan
1. Dart/TS service-tone 패턴 및 치환 규칙 동시 보강.
2. Dart style guide 금지 문구 라인에 `무엇을 도와드릴까요` 명시.
3. 단위 테스트에 직표현 제거 케이스 추가.
