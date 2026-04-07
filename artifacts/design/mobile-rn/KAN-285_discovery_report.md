# KAN-285 Discovery Report

## Goal
- RN `/chat` 메시지 루트를 Pencil `TBctN` 좌측 패널 기준의 채팅 목록 페이지로 다시 정렬한다.
- `스토리` / `운세보기` 탭 분리와 현재 chat-native runtime 로직은 유지한다.

## Sources Checked
- `artifacts/design/pencil/exports/TBctN.png`
- `artifacts/design/pencil/exports/pu8Go.png`
- `artifacts/design/pencil/README.md`
- `artifacts/design/mobile-rn/KAN-276_discovery_report.md`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/lib/chat-characters.ts`

## Searches Run
- `rg -n "TBctN|ready-list|chat list|message|메시지" artifacts/design/pencil artifacts/design/mobile-rn docs .claude/docs -g '!**/*.png'`
- `rg -n "ChatFirstRunSurface|CharacterListRow|EntryActionRow" apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `rg -n "<ChatFirstRunSurface" apps/mobile-rn/src/screens/chat-screen.tsx`

## Findings
1. `TBctN` 좌측 패널은 “메시지 루트 = 채팅 목록”이다.
   - 상단: 제목 + 탭
   - 본문 상단: 추천 쓰레드/진입 CTA
   - 본문 하단: 최근/활성 대화 리스트
   - 즉, 허브형 랜딩보다 인박스형 리스트에 가깝다.

2. 현재 RN `ChatFirstRunSurface`는 허브형으로 읽히도록 과하게 분해되어 있었다.
   - `대화 시작`, `대화 캐릭터`, `운세 상담사` 같은 섹션 제목이 강함
   - 전체 캐릭터 카탈로그를 바로 펼쳐 보여줌
   - 결과적으로 채팅 목록 페이지보다 “기능 시작 페이지”처럼 보였다.

3. route/state 머신은 이미 맞다.
   - `/chat` 루트에서 `surfaceMode='list'`
   - 캐릭터 선택 시 `surfaceMode='chat'`
   - 따라서 이번 수정은 정보구조/레이아웃 보정으로 해결 가능하다.

## Reuse Decision
- 재사용:
  - `ChatFirstRunSurface` 컴포넌트 골격
  - `EntryActionRow`, `CharacterListRow`
  - `selectedCharacterId`, `activeTab`, `firstRunActions`, `firstRunCharacters`
- 유지:
  - `chat-screen.tsx`의 route/state 흐름
  - `RecentResultCard`
- 변경:
  - 허브형 section grammar를 인박스형 list grammar로 교체
  - 목록은 전체 카탈로그 대신 우선순위 캐릭터 몇 개만 먼저 노출

## Implementation Direction
- `ChatFirstRunSurface`를 다음 순서로 렌더한다:
  1. 제목 + 탭
  2. `운세보기` 탭에서만 `맞춤 시작점` 카드
  3. `최근 대화` 또는 `최근 상담` 카드
  4. 하단 pager dots 유지
- `selectedCharacterId` row는 목록 안에서 강조한다.
- `스토리` 탭은 큰 시작 카드를 두지 않고, 상단 `+` 버튼 하나로 새 대화/새 친구 진입을 처리한다.
- `운세보기` 탭은 `추천 운세 쓰레드 + 최근 상담` 구조를 유지하고, `최근 결과`는 독립 카드가 아니라 목록 row로 흡수한다.

## Files To Change
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `artifacts/design/mobile-rn/KAN-285_discovery_report.md`
