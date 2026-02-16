# RCA Report - Luts Persona & Prompt Engine

## 1) Symptom
- 러츠가 카톡 대화 맥락에서 사람 대화보다 상담봇처럼 응답함.
- 대표 증상:
  - 인사 반복 (`반갑습니다` → `네, 반갑습니다`)
  - 서비스형 문구 (`무엇을 도와드릴 수 있을지...`)
  - 페르소나 원문의 반말/애칭 전제와 런타임 가드가 충돌.

## 2) WHY (Root Cause)
- 페르소나 원문이 `기본 반말 + 애칭 사용`을 강하게 전제하고 있음.
- 런타임 가드가 추가됐어도, 상위 시스템 프롬프트의 낡은 규칙이 지속적으로 영향.
- 응답 후처리가 길이/질문 수 중심이라, `상담봇 어휘`와 `인사 반복`을 충분히 제거하지 못함.

## 3) WHERE (Primary Locations)
- `lib/features/character/data/default_characters.dart` (러츠 persona/system prompt 원문)
- `lib/features/character/presentation/utils/luts_tone_policy.dart` (클라이언트 말투/후처리 정책)
- `lib/features/character/presentation/providers/character_chat_provider.dart` (프롬프트 주입 경로)
- `supabase/functions/character-chat/index.ts` (서버 프롬프트/후처리 가드)

## 4) WHERE ELSE (Global Search Findings)
- 동일 계열 규칙은 러츠 외 캐릭터에도 존재하지만, 현재 증상은 러츠에서 집중적으로 재현됨.
- 검색 키워드: `systemPrompt`, `LUTS STYLE GUARD`, `무엇을 도와드릴 수`, `first meet`.

## 5) HOW (Corrective Pattern)
- 단건 문장 치환이 아니라:
  1. 페르소나 기본 규칙 자체를 재정의
  2. turn-intent 기반 프롬프트 전략(인사/감사/질문/짧은답/공유)
  3. 후처리에서 서비스 어휘/인사 반복 차단
  4. 모든 생성 경로에 동일 정책 주입

## 6) Fix Plan
1. 러츠 시스템 프롬프트를 카톡형 대화 규칙 중심으로 리라이트.
2. `LutsToneProfile`에 `turnIntent`를 추가하고 prompt 전략을 intent 기반으로 변경.
3. 클라이언트/서버 후처리에 서비스형 문구 차단 및 인사 반복 정규화 추가.
4. 선택지 응답/운세응답 경로까지 러츠 스타일 가드 확장.
5. 테스트 케이스에 서비스톤 차단/인사 반복 차단 추가.
