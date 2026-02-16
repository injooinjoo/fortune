# RCA Report - Luts 읽음 후 10초 무응답 아이스브레이킹 부재

## 1) 증상
- 러츠가 답장을 보낸 뒤 사용자가 채팅방에서 메시지를 읽고 멈추면, 대화가 끊긴 느낌이 발생.
- 초기 아이스브레이킹 구간에서 사용자의 재진입 동기가 약해짐.

## 2) WHY (근본 원인)
1. 현재 로직은 장기 follow-up(분 단위) 중심으로만 설계되어, 채팅방 내 단기 무응답(초 단위) 대응이 없음.
2. 읽음 이벤트(`clearUnreadCount`)와 대화 연결 질문 로직이 연결되어 있지 않음.
3. 사용자 무응답 상황에서 즉시 1회만 보내는 안전장치(중복 방지 anchor)가 없음.

## 3) WHERE (파일/구간)
- `lib/features/character/presentation/providers/character_chat_provider.dart`
  - 읽음 처리, 메시지 추가, follow-up 스케줄 연결 지점
- `lib/features/character/presentation/utils/luts_tone_policy.dart`
  - 러츠 질문 문구/말투 규칙 생성 지점

## 4) WHERE ELSE (전역 영향)
- `lib/features/character/presentation/pages/character_chat_panel.dart`
  - 채팅방 진입 시 읽음 처리 호출
- `lib/features/character/data/services/follow_up_scheduler.dart`
  - 분 단위 follow-up 스케줄(이번 10초 로직과 별개)

## 5) HOW (정상 패턴)
- 채팅방 내 읽음 후 10초 무응답 시, 초기 단계에서만 1회 짧은 질문으로 대화를 이어간다.
- 사용자가 답장하면 즉시 취소한다.
- 같은 anchor 메시지에 대해서는 중복 발송하지 않는다.

## 6) 수정 계획
1. `CharacterChatNotifier`에 read-idle 타이머(10초) 추가.
2. 읽음/캐릭터 메시지 이벤트에서 조건부 스케줄링, 사용자 답장 시 취소.
3. 러츠 전용 시간대 질문 빌더 추가(`지금 뭐 하고 계세요/점심/저녁`).
4. 단위 테스트와 정책 문서 업데이트.
