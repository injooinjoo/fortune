# KAN-293 Discovery Report

## Goal
- 운세 캐릭터별 전체 운세 선택지를 active chat 안에서 모두 보이게 한다.
- embedded result 카드가 좌측도 충분히 채우도록 avatar row 구조를 정리한다.
- 결과/설문 진행 시 자동으로 마지막 메시지 위치로 이동시킨다.
- composer 좌우 버튼을 실제 동작하게 만든다.

## Search
- `rg -n "EmbeddedResultCard|kind === 'embedded-result'|composer|ActiveChatComposer|ScrollView|scrollToEnd|avatar" apps/mobile-rn/src/features apps/mobile-rn/src/screens apps/mobile-rn/src/lib -S`
- `rg -n "buildSuggestedActions|slice\\(0, 4\\)|promptActions" apps/mobile-rn/src -S`
- `rg -n "message action|toolbar|chip tray|quick action|compose" lib/features/character lib/features/chat apps/mobile-rn/src -S`

## Files Reviewed
1. [chat-shell.ts](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/chat-shell.ts)
   - 운세 액션 생성과 초기 스레드 패턴 확인
2. [chat-surface.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx)
   - thread row, embedded result, composer, prompt chip 렌더 위치 확인
3. [chat-screen.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx)
   - action press, draft send, survey complete, recent result reopen 흐름 확인
4. [screen.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/screen.tsx)
   - chat scroll container 구조 확인
5. [embedded-result-card.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx)
   - result card 자체 폭/내부 섹션 구조 확인
6. [character_chat_panel.dart](/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/pages/character_chat_panel.dart)
   - Flutter composer 기준 동작 참고

## Reuse / Extend / New
- Reuse
  - `buildSuggestedActions()`
  - `ChatThreadMessage()`
  - `ActiveChatComposer`
  - `Screen` scroll container
- Extend
  - `buildSuggestedActions()`를 full specialties 기반으로 확장
  - `Screen`에 scroll ref / content size callback 추가
  - `ActiveChatComposer`에 quick action tray 및 empty-state action handler 추가
- New
  - chat-native composer tray state
  - result/avatar suppression logic for embedded result messages

## Decision
- 운세 선택지는 `selectedCharacter.specialties` 전체를 chip tray로 노출한다.
- result message는 avatar를 숨기고 row gap 없이 full-width로 렌더한다.
- message/result/survey step append 시 자동 하단 스크롤을 수행한다.
- 좌측 `+`는 quick action tray 토글, 우측 버튼은 빈 draft일 때도 기본 action을 실행하도록 만든다.
