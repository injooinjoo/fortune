# Discovery Report - Luts 읽음 후 10초 아이스브레이킹

## 1) Scope
- 러츠 채팅에서 읽음 후 10초 무응답 시 1회 아이스브레이킹 질문 전송.
- 초기 단계(1~2단계)에서만 동작하도록 제한.

## 2) Search Performed
- `rg -n "clearUnreadCount|addCharacterMessage|addUserMessage|FollowUp|schedule" lib/features/character/presentation/providers/character_chat_provider.dart`
- `rg -n "follow_up|scheduleFollowUp|Timer" lib/features/character/data/services/follow_up_scheduler.dart`
- `rg -n "applyTemplateTone|buildStyleGuidePrompt|detectSpeechLevel" lib/features/character/presentation/utils/luts_tone_policy.dart`

## 3) Existing Reusable Components
- `CharacterChatNotifier`의 메시지 추가/읽음 처리/follow-up 연계 구조.
- `activeCharacterChatProvider`를 통한 현재 열린 채팅방 상태 판단.
- `LutsTonePolicy`의 말투/격식/관계단계 미러링 로직.

## 4) Gap Analysis
- 초 단위 무응답 타이머가 없어서 UX가 끊김.
- 동일 anchor 중복 발송 제어가 없어 단순 타이머 도입 시 스팸 위험.

## 5) Reuse vs New
- Reuse:
  - 기존 notifier 이벤트 훅(add/clear/read), luts tone policy를 그대로 활용.
- New:
  - read-idle 전용 타이머/anchor 상태 필드.
  - read 이벤트 기반 스케줄링 함수.
  - 시간대 기반 질문 생성 함수.

## 6) Implementation Decision
- 서버/API 변경 없이 클라이언트 notifier 로직으로 구현.
- 러츠 전용 + 초기 단계 제한 + 동일 anchor 1회 제한으로 안전하게 배포.
