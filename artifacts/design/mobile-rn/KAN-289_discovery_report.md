# KAN-289 Discovery Report

## Request
- 스토리 탭에서 `최근 대화` 카드와 설명을 제거한다.
- 탭 바로 아래부터 스토리 채팅 캐릭터 전체 목록이 바로 이어지게 한다.

## Existing Structure
- 루트 메시지 표면은 [chat-surface.tsx](/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx) 의 `ChatFirstRunSurface`가 담당한다.
- 기존 구현은 story/fortune 탭 모두 동일한 카드 컨테이너 안에 목록을 넣고 있었다.
- story 탭도 `orderedCharacters.slice(0, 4)` 제한이 걸려 있어 전체 목록이 보이지 않았다.

## Reuse / Extend / New
- Reuse: `CharacterListRow`, `orderedCharacters` 정렬 로직
- Extend: story 탭에서만 카드 없이 직접 리스트 렌더
- New behavior: story 탭은 전체 캐릭터 목록 노출, fortune 탭만 카드형 메타 섹션 유지

## Decision
- story 탭
  - `최근 대화` 제목/설명 제거
  - 탭 아래부터 바로 전체 캐릭터 목록 렌더
  - pager dots 제거
  - `+`는 스크롤 내부가 아니라 화면 하단 footer에 고정 유지
- fortune 탭
  - 기존 카드형 메타/최근 결과/전문가 목록 유지

## Risk Check
- story 탭에서 노출 개수가 늘어나므로 세로 길이가 늘어나지만, `Screen`이 `ScrollView` 기반이라 접근성/스크롤 흐름은 유지된다.
- 플로팅 `+`는 `Screen.footer`로 분리해 목록 길이와 무관하게 하단 고정된다.
- 이번 수정은 루트 목록 배치만 건드리며 실제 active chat surface와 survey/result 흐름은 영향 주지 않는다.
