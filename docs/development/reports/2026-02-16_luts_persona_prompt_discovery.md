# Discovery Report - Luts Persona/Prompt Refactor

## 1) Scope
- 목적: 러츠 대화를 "문장 보정"이 아닌 "페르소나 + 프롬프트 엔진" 차원에서 개선.
- 적용 범위: 실시간 응답, follow-up/선톡, 선택지 응답, 운세 응답, 서버 edge 후처리.

## 2) Search Performed
- `rg -n "luts|러츠|systemPrompt|LUTS STYLE GUARD|first meet" lib/features/character supabase/functions/character-chat/index.ts`
- `rg -n "무엇을 도와드릴 수|도움이 필요" lib/features/character supabase/functions`

## 3) Existing Reusable Components
- 재사용:
  - `lib/features/character/presentation/utils/luts_tone_policy.dart`
  - `lib/features/character/presentation/providers/character_chat_provider.dart` 내 러츠 분기
  - `supabase/functions/character-chat/index.ts` 내 러츠 전용 guard
- 확장 포인트:
  - ToneProfile 필드 확장 (`turnIntent`)
  - style prompt 생성 규칙 강화
  - 후처리 규칙 강화(서비스형 문구/인사 반복)

## 4) Gap Analysis
- 현재 강점:
  - 언어/격식 미러링, 애칭 게이트, 1~2문장/질문 제한.
- 현재 약점:
  - 페르소나 원문이 낡은 규칙(반말/애칭 기본)을 유지.
  - 응답 목적(인사/감사/질문 등) 분류가 없어 모든 상황에서 비슷한 문장 패턴 발생.
  - 상담형 문구에 대한 금지 룰이 미약.

## 5) Reuse vs New
- Reuse/Extend:
  - 기존 `LutsTonePolicy`와 서버 guard를 유지하고 정책만 확장.
- New:
  - `turnIntent` 분류 로직
  - 서비스형 문구 차단/인사 반복 차단 후처리
  - 러츠 시스템 프롬프트 원문 리라이트

## 6) Implementation Decision
- 새 엔진 파일 추가보다 기존 정책 계층을 확장하는 방식 채택.
- 이유:
  - 이미 실시간/follow-up/선톡 경로에 훅이 존재해 적용 범위가 넓음.
  - 변경 리스크를 최소화하면서 즉시 효과를 낼 수 있음.
