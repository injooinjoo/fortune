# Mobile RN UI Audit

Date: 2026-04-07
Device: iPhone 17 simulator (`9ED1D212-A3D3-43F1-9E36-2F1F54367878`)

## Scope
- `/chat`
- `/profile`
- `/premium`
- `/signup`
- `/privacy-policy`
- `/friends/new/basic`
- `/character/luts`

## Screenshots
- `/Users/jacobmac/Desktop/Dev/fortune/artifacts/runtime/rn-iphone17-ui-audit-chat-root-2026-04-07.png`
- `/Users/jacobmac/Desktop/Dev/fortune/artifacts/runtime/rn-iphone17-ui-audit-profile-root-2026-04-07.png`
- `/Users/jacobmac/Desktop/Dev/fortune/artifacts/runtime/rn-iphone17-ui-audit-premium-2026-04-07.png`
- `/Users/jacobmac/Desktop/Dev/fortune/artifacts/runtime/rn-iphone17-ui-audit-signup-2026-04-07.png`
- `/Users/jacobmac/Desktop/Dev/fortune/artifacts/runtime/rn-iphone17-ui-audit-privacy-2026-04-07.png`
- `/Users/jacobmac/Desktop/Dev/fortune/artifacts/runtime/rn-iphone17-ui-audit-friend-basic-2026-04-07.png`
- `/Users/jacobmac/Desktop/Dev/fortune/artifacts/runtime/rn-iphone17-ui-audit-character-luts-2026-04-07.png`

## Runtime blocker resolved
- 기존 전수 감사는 `Cannot find native module 'Expolap'` redbox 때문에 `/profile`, `/premium`, `/signup`이 공통으로 죽어서 의미 있는 UI 검수가 불가능했다.
- 이번 패치 후 위 화면들은 모두 정상 렌더되며, 전수 캡처가 가능해졌다.

## Passed checks
- `/chat` 루트는 목록형 구조로 렌더된다.
- `/profile`, `/premium`, `/signup`, `/privacy-policy`, `/friends/new/basic`, `/character/luts`는 redbox 없이 열린다.
- 서브페이지 상단 back affordance는 공통 chevron 패턴으로 보인다.

## Findings
1. Chat empty-composer send affordance is misleading. 빈 입력 상태에서도 우측 전송 버튼이 실제로는 첫 quick action/fallback을 실행한다. 아이콘 의미와 동작이 다르다.
2. Chat recent result reopen can become a dead tap. 최근 결과 row가 렌더되지만 `reopenFortuneResult()` 실패를 surface에서 처리하지 않는다.
3. Chat hierarchy still drifts around embedded results. 결과 카드에서는 avatar gutter를 없애고 일반 메시지는 유지해서 같은 스레드 안에서도 좌측 정렬 규칙이 달라진다.
4. Chat chip-heavy areas still risk overflow. composer tray, multi-select survey, prompt chips는 긴 한국어에서 ragged multi-line cluster가 생길 수 있다.
5. Profile/premium/legal/account leaves still mix exit semantics. top chevron은 `router.back()` 중심인데 일부 하단 CTA는 `push`, `replace`, `back`을 섞어 쓴다.
6. Profile subpages expose duplicate escape systems. top chevron이 생겼는데 하단 `동작` 카드가 또 back/exit를 제공해 계층이 흐려진다.
7. Friend creation wizard loses `returnTo` continuity. guard redirect가 `/friends/new/basic|persona|story`로 넘길 때 원래 `returnTo`를 재전달하지 않는다.
8. Friend creation intermediate steps rely on `router.back()`. 히스토리가 꼬이면 이전 wizard step이 아니라 다른 화면으로 튈 수 있다.
9. Onboarding -> signup -> auth callback does not preserve original destination. onboarding은 `returnTo`를 읽지만 signup으로 넘길 때 `/onboarding`으로 고정한다.
10. Signup/onboarding UI is still placeholder-grade. onboarding은 checklist placeholder이고 `toss-style` route도 실제 구현 없이 redirect만 한다.

## Priority
- P0: friend wizard `returnTo` preservation + deterministic back routes
- P0: onboarding -> signup -> auth callback continuity
- P1: chat composer empty-send behavior와 recent-result dead action 정리
- P1: profile/premium/legal/account leaf navigation semantics 정리
- P2: chip overflow, embedded result indentation, first-run hierarchy polish

## Notes
- Figma context는 이번 감사에 제공되지 않아 로컬 RN 기준으로만 확인했다.
- premium screen은 이번 감사 시점에 상품 리스트가 렌더되었고, 런타임 blocker는 재현되지 않았다.
