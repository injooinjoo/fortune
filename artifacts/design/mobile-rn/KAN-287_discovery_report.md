# KAN-287 Discovery Report

## Request
- 메시지 루트 우상단에 프로필 버튼을 아이콘으로 노출한다.

## Existing Pattern
- 루트 메시지 헤더는 [chat-surface.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx) 의 `ChatFirstRunSurface`에서 구성한다.
- story 탭은 `+` 버튼만 노출하고 있었고, fortune 탭은 임시 `HeaderDots`만 보여 실제 프로필 진입점이 없었다.
- 라우팅 호출부는 [chat-screen.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx) 에서 `ChatFirstRunSurface`를 렌더한다.

## Reuse / Extend / New
- Reuse: 기존 `HeaderActionButton` 컨테이너 스타일 재사용
- Extend: `HeaderActionButton`을 `plus | profile` 아이콘 variant로 확장
- New: 루트 헤더에 `onOpenProfile` prop 추가

## Decision
- story 탭: `+` + 프로필 아이콘 노출
- fortune 탭: 프로필 아이콘만 노출
- 프로필 버튼은 `/profile`로 라우팅

## Risk Check
- `HeaderDots` 제거로 fortune 탭 우상단 폭이 줄어들 수 있으나, 실제 요구사항상 프로필 액션이 우선이다.
- root header만 수정하며 active chat header의 info button은 이번 범위에서 건드리지 않는다.
