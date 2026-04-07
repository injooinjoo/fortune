# KAN-288 Discovery Report

## Request
- 메시지 루트에서 `+` 버튼을 우상단에서 제거하고, 하단 플로팅 액션으로 이동한다.
- 우상단에는 프로필 아이콘만 유지한다.

## Existing Structure
- 루트 메시지 표면은 [chat-surface.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx) 의 `ChatFirstRunSurface`가 담당한다.
- `HeaderActionButton`은 원형 헤더 액션 버튼으로 재사용 가능하다.
- 현재 story 탭은 우상단에 `+`와 프로필 아이콘이 같이 있고, 하단 고정 액션은 없다.

## Reuse / Extend / New
- Reuse: `HeaderActionButton` 프로필 아이콘 variant 유지
- Extend: story 탭 하단 우측에 `FloatingCreateButton` 신규 추가
- New behavior: story 탭에서만 `+` 플로팅 액션 표시

## Decision
- 우상단 헤더 액션은 프로필 아이콘만 유지한다.
- `새 대화 시작`은 story 탭 하단 우측의 원형 플로팅 버튼으로 이동한다.
- fortune 탭은 기존처럼 추천/목록 중심 레이아웃을 유지하고 플로팅 `+`는 노출하지 않는다.

## Risk Check
- `Screen` 자체 footer를 쓰지 않고 surface 내부 하단 우측 정렬로 구현해 기존 active chat footer 구조와 충돌하지 않는다.
- 디자인 기준은 Pencil message-list 구조를 따르되, Figma 문맥은 이번 요청에 제공되지 않아 로컬 UI 기준으로 반영한다.
