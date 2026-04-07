# KAN-281 Discovery Report

## Goal
- RN fortune flow를 `/chat` 내부 설문 + `/chat` 내부 결과 카드 구조로 옮긴다.
- `story` 대화 흐름은 유지한다.
- 기존 RN `fortune-results/*`는 채팅 안 임베드 렌더러로 재사용한다.

## Flutter Truth
- `/chat`이 메인 런타임 표면이다.
- `curiosity-home -> curiosity-survey -> curiosity-result`가 모두 `/chat` 안 상태 전이로 동작한다.
- 기준 코드:
  - `docs/getting-started/APP_SURFACES_AND_ROUTES.md`
  - `lib/core/navigation/fortune_chat_route.dart`
  - `lib/features/character/presentation/pages/character_chat_panel.dart`
  - `lib/features/character/presentation/providers/character_chat_survey_provider.dart`
  - `lib/features/character/presentation/providers/character_chat_provider.dart`
  - `lib/features/character/presentation/widgets/embedded_fortune_component.dart`

## RN Current State
- `/chat` 쉘:
  - `apps/mobile-rn/src/screens/chat-screen.tsx`
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- separate result route:
  - `apps/mobile-rn/app/result/[resultKind].tsx`
  - `apps/mobile-rn/src/features/fortune-results/*`

## Reusable RN Pieces Found
- 이미 존재하는 chat-native survey artifact:
  - `apps/mobile-rn/src/features/chat-survey/types.ts`
  - `apps/mobile-rn/src/features/chat-survey/registry.ts`
- 이미 존재하는 embedded result artifact:
  - `apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx`
- 이미 존재하는 embedded message type:
  - `apps/mobile-rn/src/lib/chat-shell.ts`
  - `kind: 'embedded-result'`

## Gap
- `chat-screen.tsx`가 아직 fortune action/deeplink/recent-result에서 `/result/*` push 중심이다.
- survey registry는 존재하지만 실제 `/chat` footer/input flow에 연결되지 않았다.
- embedded result message renderer는 존재하지만 런타임 fortune flow에서 거의 사용되지 않는다.
- `운세보기` 탭이 전체 운세 상담사가 아니라, 현재 RN result runtime과 연결된 일부 상담사만 노출하는 구조였다.
- `fortuneType -> resultKind` 매핑에서 `blood-type`가 빠져 있어서 F04 결과는 chat-native runtime에 연결되지 않았다.
- `resultKinds`와 `fortune character specialties` 사이에 drift가 있어, 일부 결과는 컴포넌트가 있어도 상담사 액션으로 바로 노출되지 않는다.

## Safe First Patch
- `/chat`에서 fortune action press 시:
  - launch messages 추가
  - survey definition 있으면 같은 thread 안에서 질문/답변 진행
  - 완료 시 `embedded-result` message 삽입
- survey definition이 없거나 step이 0개면:
  - same chat 안에서 결과 카드 바로 삽입
- `/result/[resultKind]`는 debug/preview route로만 남긴다.

## Files To Change
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/features/chat-survey/registry.ts`
- `apps/mobile-rn/src/features/fortune-results/recent-result-card.tsx`
- 신규:
  - `apps/mobile-rn/src/features/chat-survey/inline-survey-card.tsx`

## Risks
- RN survey renderer는 Flutter 전체 입력 타입을 아직 다 커버하지 못한다.
- 이번 패치는 현재 registry에 있는 타입 중심으로 먼저 연결한다.
- dirty worktree가 커서 RN 범위 밖 파일은 절대 건드리지 않는다.
