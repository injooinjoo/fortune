# KAN-316 RCA Report

## Symptom
- RN 서브페이지의 상단 back header가 `누르면 돌아가는 목적지`가 아니라 `현재 페이지 제목`을 표시하고 있다.
- 사용자는 `< 캐릭터 프로필` 같은 표기가 실제로는 캐릭터 프로필 페이지로 돌아간다는 의미가 되어야 한다고 요청했다.

## WHY
- `RouteBackHeader`는 `label` prop을 그대로 왼쪽 chevron 옆에 렌더한다.
- 대부분의 screen callsite가 이 `label`에 현재 화면 제목을 넘기고 있어, back affordance가 목적지 정보가 아니라 현재 페이지 이름 반복이 되어 버렸다.
- dynamic route 흐름(`signup`, `onboarding`, `auth-callback`)은 `returnTo`를 이미 들고 있지만, 현재는 이 목적지 문자열을 왼쪽 back label로 해석하지 않는다.

## WHERE
- `apps/mobile-rn/src/components/route-back-header.tsx`
- `apps/mobile-rn/src/screens/*` 중 `RouteBackHeader` 사용 화면 전체

## WHERE ELSE
- `rg -n "RouteBackHeader" apps/mobile-rn/src/screens`
- 주요 대상:
  - `character-profile-screen.tsx`
  - `premium-screen.tsx`
  - `legal-screen.tsx`
  - `account-deletion-screen.tsx`
  - `profile-edit-screen.tsx`
  - `profile-notifications-screen.tsx`
  - `profile-relationships-screen.tsx`
  - `profile-saju-summary-screen.tsx`
  - `signup-screen.tsx`
  - `onboarding-screen.tsx`
  - `auth-callback-screen.tsx`

## HOW
- back header는 `current page title`이 아니라 `destination page title`을 기본 의미로 가져야 한다.
- 정적 목적지는 route 기준 공통 helper로 제목을 유도하고, 동적 `returnTo`도 같은 helper를 사용해 label을 계산한다.
- callsite에서 정말 다른 목적지명을 보여줘야 할 때만 명시적으로 override 한다.

## Fix Plan
1. route -> destination title helper를 추가한다.
2. `RouteBackHeader`가 `fallbackHref` 기준으로 목적지명을 계산할 수 있게 확장한다.
3. 기존 callsite를 전체 점검해서 현재 페이지명을 넘기던 부분을 목적지명 규칙으로 교체한다.
4. iPhone 17에서 대표 화면들을 직접 열어 header 텍스트를 검증한다.
