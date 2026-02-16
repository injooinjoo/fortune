# Discovery Report - Read Status / Continuity Fix

## 1) Scope
- 연속 메시지 읽음 처리 버그 수정
- 러츠 초기 대화 단절감 개선(소개팅형 연결 대화)

## 2) Search Performed
- `rg -n "markLastUserMessageAsRead|MessageStatus.sent|readAt" lib/features/character`
- `rg -n "FIRST_MEET MODE|LUTS STYLE GUARD|applyGeneratedTone" lib/features/character supabase/functions/character-chat/index.ts`
- `rg -n "enabled: true|연속 메시지 전송 허용" lib/features/character/presentation/pages/character_chat_panel.dart`

## 3) Existing Reusable Components
- `character_chat_provider.dart`의 기존 읽음 처리 훅
- `luts_tone_policy.dart`의 응답 후처리(길이/질문/중복/서비스톤)
- `character-chat/index.ts`의 서버 Luts output guard

## 4) Gap Analysis
- Read 처리: last-only 방식이라 multi-send에서 누락 발생 가능.
- 대화 연결: short-bubble 제한은 있으나 early-turn bridge 규칙이 약함.

## 5) Reuse vs New
- Reuse:
  - 기존 provider 구조/호출 흐름 유지.
  - 기존 Luts style guard 유지.
- New:
  - pending 전체 read 처리 함수.
  - continuity bridge 보강(클라이언트/서버).
  - FIRST_MEET 단절 방지 규칙 강화.

## 6) Implementation Decision
- 기능 분해를 최소화하고 기존 경로에 확장 방식 적용:
  - read는 provider에서 일괄 처리.
  - continuity는 tone policy + first meet prompt에 이중 반영.
