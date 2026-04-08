# KAN-293 RCA Report

## Symptom
- 운세 캐릭터 active chat에서 선택 가능한 운세 종류가 일부만 보인다.
- embedded result 카드가 좌측 캐릭터 아바타 폭만큼 밀려 보여 카드가 비정상적으로 안쪽에 배치된다.
- 결과가 추가되거나 설문이 진행돼도 타임라인이 마지막 메시지로 자동 이동하지 않는다.
- composer 좌측 `+` 버튼과 우측 원형 버튼이 실질적으로 아무 동작도 하지 않는다.

## WHY
1. 전체 운세 선택지 미노출
   - [chat-shell.ts](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/chat-shell.ts) 의 `buildSuggestedActions()`가 `character.specialties.slice(0, 4)`로 잘라서 반환한다.
   - [chat-surface.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx) 의 `promptActions`도 다시 `actions.slice(0, 4)`를 사용한다.

2. 결과 카드 좌측 과도한 들여쓰기
   - [chat-surface.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx) 의 `ChatThreadMessage()`가 모든 assistant 메시지에 24px avatar bubble을 강제한다.
   - `embedded-result`도 같은 row 구조를 타면서 avatar + gap을 그대로 먹어 좌측이 밀린다.

3. 자동 하단 스크롤 부재
   - [screen.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/screen.tsx) 의 `ScrollView` ref가 밖으로 노출되지 않는다.
   - [chat-screen.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx) 에서 메시지 append 후 `scrollToEnd()`를 호출할 경로가 없다.

4. composer 버튼 비동작
   - [chat-surface.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx) 의 좌측 `+`는 `Pressable`이 아니라 단순 `View`라 tap handler가 없다.
   - 우측 원형 버튼은 `onSend`를 호출하지만, [chat-screen.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx) 의 `handleSendDraft()`가 빈 draft에서 즉시 return 하므로 결과적으로 no-op다.

## WHERE
- `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/chat-shell.ts`
- `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/screen.tsx`
- `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx`

## WHERE ELSE
- Flutter 쪽 composer 기준은 [character_chat_panel.dart](/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/pages/character_chat_panel.dart) 에 있고, 좌측 `+`는 이미지 picker sheet를 여는 실제 액션이다.
- Flutter 쪽 액션 툴바/버튼 패턴은 [message_action_toolbar.dart](/Users/jacobmac/Desktop/Dev/fortune/lib/features/character/presentation/widgets/message_action_toolbar.dart) 에 존재한다.

## HOW
- 운세 액션은 character specialties 전체를 노출한다.
- result 메시지는 avatar 없는 full-width assistant block으로 렌더한다.
- chat screen이 내부 `ScrollView` ref를 잡고, 메시지/결과/설문 step append 시 `scrollToEnd()`를 호출한다.
- composer 좌측 `+`는 quick action tray 토글로 연결하고, 우측 버튼은 빈 draft일 때도 첫 추천 운세 또는 기본 후속 대화로 이어지게 한다.
