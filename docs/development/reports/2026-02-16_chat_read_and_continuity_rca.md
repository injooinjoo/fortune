# RCA Report - Character Chat Read Status + Luts Continuity

## 1) Symptom
- 버그 1: 사용자 연속 전송(2개 이상) 시 첫 번째 메시지의 읽음 표시 `1`이 남음.
- 버그 2: 러츠 응답이 단절형으로 끝나 대화가 끊기는 느낌이 강함.

## 2) WHY (Root Cause)
- 버그 1:
  - 읽음 처리 함수가 `마지막 사용자 메시지 1개`만 `sent -> read` 전환.
  - 연속 전송 허용 구조에서 앞 메시지는 `sent`로 남을 수 있음.
- 버그 2:
  - 짧은 1버블 제약은 있으나, 초기 소개팅형 턴에서 “대화 연결(bridge)” 규칙이 약함.
  - 인사/짧은 응답/자기소개 턴에서 후속 대화로 이어지는 마무리 문장이 누락될 수 있음.

## 3) WHERE (Primary Locations)
- `lib/features/character/presentation/providers/character_chat_provider.dart`
  - `markLastUserMessageAsRead()` + 호출 지점들.
- `lib/features/character/presentation/utils/luts_tone_policy.dart`
  - 생성 응답 후처리(단절 방지 bridge 부재).
- `supabase/functions/character-chat/index.ts`
  - 서버 Luts output guard에서 단절 방지 bridge 부재.

## 4) WHERE ELSE (Global Search Findings)
- 검색 키워드:
  - `markLastUserMessageAsRead`, `status == MessageStatus.sent`
  - `FIRST_MEET MODE`, `LUTS STYLE GUARD`
- 동일 read 처리 패턴은 캐릭터 채팅 provider에 집중되어 있었고, UI는 sent 상태를 그대로 표시함.

## 5) HOW (Corrective Pattern)
- 버그 1: 마지막 1개가 아니라 pending 사용자 메시지 전체(`sent`)를 읽음 처리.
- 버그 2: 초기/연결 필요 턴에 후속 대화를 여는 bridge 문장(가벼운 질문)을 자동 보강.

## 6) Fix Plan
1. `markPendingUserMessagesAsRead()` 추가 후 기존 호출 전부 교체.
2. 러츠 생성 톤 후처리에 continuity bridge 옵션 추가.
3. FIRST_MEET 프롬프트/서버 guard에 단절 방지 규칙 보강.
4. 테스트/검증 후 커밋/푸시/Actions 확인.
