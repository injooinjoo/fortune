# KAN-315 RCA Report

## Symptom
- RN `메시지 > 스토리` 목록 화면에서 하단 `+` 버튼 아래/옆 영역이 검은 footer 배경으로 남아 진짜 플로팅 버튼처럼 보이지 않는다.
- 결과적으로 마지막 리스트 row 우측 하단 일부가 가려진 것처럼 보이고, 사용자가 요청한 `둥둥 떠 있는 FAB` 인상과 다르다.

## WHY
- `apps/mobile-rn/src/screens/chat-screen.tsx`는 story list 상태의 `FloatingCreateButton`을 `Screen.footer`로 전달한다.
- `apps/mobile-rn/src/components/screen.tsx`의 `footer` 렌더링은 전체 폭 컨테이너를 하단에 고정하면서 `backgroundColor`, `paddingHorizontal`, `paddingBottom`, `paddingTop`을 함께 적용한다.
- 그래서 실제로는 버튼만 뜨는 것이 아니라 하단 footer 영역 전체가 화면 위에 추가되며, 그 배경이 검은 밴드처럼 보인다.

## WHERE
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/components/screen.tsx`

## WHERE ELSE
- `rg -n "footer=\{|footer=" apps/mobile-rn/src/screens`
- 다른 화면들도 `Screen.footer`를 사용하지만, friend creation/chat composer처럼 실제 하단 바가 필요한 경우라 동일 문제는 아님.
- 현재 `FloatingCreateButton`를 `footer`로 쓰는 케이스는 `chat-screen.tsx`의 story list 경로가 핵심이다.

## HOW
- footer는 `하단 바`가 필요한 경우에만 유지하고, 진짜 FAB는 scroll 영역/하단 safe area와 독립된 overlay slot으로 렌더해야 한다.
- story list는 overlay FAB를 쓰고, scroll content에는 그 FAB 높이만큼 bottom inset만 추가해 마지막 row가 가려지지 않게 한다.

## Fix Plan
1. `Screen`에 footer와 별개인 overlay slot 및 content bottom inset 지원을 추가한다.
2. `chat-screen.tsx` story list는 `footer` 대신 overlay FAB를 사용한다.
3. iPhone 17에서 메시지 목록 하단이 더 이상 검은 밴드로 덮이지 않는지 재검증한다.
