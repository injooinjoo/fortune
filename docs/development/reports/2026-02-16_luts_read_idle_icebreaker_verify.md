# Verify Report - Luts 읽음 후 10초 아이스브레이킹

## 1. Change Summary
- `CharacterChatNotifier`에 read-idle 타이머(10초) 추가.
- 사용자 읽음 처리(`clearUnreadCount`)와 캐릭터 메시지 추가 시점에 조건부 스케줄 연결.
- 사용자 답장 시 타이머 즉시 취소.
- 동일 anchor 메시지에 대해 아이스브레이킹 중복 발송 방지.
- 러츠 전용 질문 빌더 추가(시간대 기반: 일반/점심/저녁).

## 2. Static Validation
- `flutter analyze`
  - Result: failed
  - Notes: 레포 기존 베이스라인 78건으로 실패(신규 이슈 아님).
- `flutter analyze lib/features/character/presentation/providers/character_chat_provider.dart lib/features/character/presentation/utils/luts_tone_policy.dart test/unit/features/character/presentation/utils/luts_tone_policy_test.dart`
  - Result: passed
- `dart format --set-exit-if-changed .`
  - Result: passed

## 3. Tests and QA
- `flutter test test/unit/features/character/presentation/utils/luts_tone_policy_test.dart`
  - Result: passed
  - Added coverage:
    - read-idle 질문 시간대 분기(일반/점심/저녁)
    - 1단계 존댓말 floor 유지
- `flutter test`
  - Result: passed (`All tests passed!`)
- `deno check /Users/jacobmac/Desktop/Dev/fortune/supabase/functions/character-chat/index.ts`
  - Result: failed
  - Notes: `_shared` 베이스라인 타입 오류 6건(기존 동일)

## 4. Manual Scenarios
1. 러츠 채팅방(1~2단계)에서 캐릭터 메시지를 읽고 10초 대기.
   - Expected: 1회 아이스브레이킹 질문 전송.
2. 캐릭터 메시지 직후 10초 내 사용자 답장.
   - Expected: 아이스브레이킹 미발송.
3. 동일 anchor 메시지에서 반복 대기.
   - Expected: 같은 질문 재발송되지 않음.
4. 점심/저녁 시간대 검증.
   - Expected: `점심/저녁` 문구 질문으로 분기.
