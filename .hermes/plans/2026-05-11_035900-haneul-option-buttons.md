# 하늘이 옵션 선택 버튼 UX 개선 계획

## Goal
- 하늘이 채팅에서 설문/옵션 선택 버튼들이 화면 최하단에 붙어 보이지 않도록 조금 위로 올린다.
- 선택지가 작아 보이지 않도록 시각 크기와 터치 영역을 키운다.
- 입력창/일반 채팅 UX에는 불필요한 영향을 주지 않는다.

## Current context / assumptions
- 대상 repo: `/Users/injoo/Desktop/Dev/fortune`
- 요청 문맥의 “하늘이 아래쪽 옵션 선택 버튼”은 하늘이 운세 설문 진행 중 footer에 표시되는 `ActiveSurveyFooter` 선택지로 해석한다.
- Figma URL/node-id가 제공되지 않았고 현재 Hermes에는 Figma MCP 도구가 노출되어 있지 않아, 로컬 코드 기준으로 디자인 시스템 토큰을 사용해 수정한다.
- PaperclipAI 로컬 API health는 정상이나 `/api/companies`가 403으로 막혀 자동 Issue 생성은 불가하다. 추후 인증 가능한 세션에서 retrospective issue를 생성한다.

## Discovery
- `apps/mobile-rn/src/screens/chat-screen.tsx`에서 채팅 화면 footer로 `ActiveSurveyFooter`를 렌더한다.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`의 `ActiveSurveyFooter`가 `chips`, `deck-picker`, `multi-select`, `text` 입력 형태를 처리한다.
- 버튼 크기 문제는 `chips`/`multi-select` 선택지의 `paddingVertical: 10`, `paddingHorizontal: 16`, `labelMedium` 조합에서 발생할 가능성이 높다.
- footer 위치 문제는 `ActiveSurveyFooter` 자체가 Screen footer에 바로 붙어 있어 하단 safe area와 가까운 체감이 생기는 것으로 보인다.

## Proposed approach
1. `ActiveSurveyFooter`에 survey footer 전용 wrapper를 추가해 전체 옵션 블록을 약간 위로 올린다.
2. 단일/다중 선택 chip 버튼의 padding과 최소 높이를 키워 더 큰 선택지로 보이게 한다.
3. 다중 선택의 제출/건너뛰기 액션도 같은 리듬으로 맞춰 footer 내부 균형을 유지한다.
4. TypeScript/format 검증을 실행한다.

## Files likely to change
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`

## Validation
- `npm run typecheck` 또는 repo에 정의된 mobile TS gate 확인
- `npm test`/targeted test 가능 여부 확인
- 가능하면 iOS Simulator에서 하늘이 설문 흐름을 열어 footer 위치/버튼 크기를 스크린샷으로 확인

## Risks / tradeoffs
- 모든 운세 설문 footer에 적용된다. 하늘이 운세 진입점이 단일화되어 있으므로 의도한 범위로 판단한다.
- 작은 화면에서 버튼이 커지면 줄바꿈이 늘 수 있으나, 사용자는 선택지가 작아 보인다고 했으므로 가독성/터치성이 우선이다.
