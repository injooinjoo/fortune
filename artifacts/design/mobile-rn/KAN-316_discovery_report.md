# KAN-316 Discovery Report

## Request
- Change RN back headers so the left label represents the destination page name, not the current page title.

## Existing Structure
- Shared component: `apps/mobile-rn/src/components/route-back-header.tsx`
- Callsites found by `rg -n "RouteBackHeader" apps/mobile-rn/src/screens`
- Current pattern: most screens pass the current page title into `label`

## Callsite Audit
- `character-profile-screen.tsx`
  - current: `캐릭터 프로필`
  - target destination: `메시지`
- `premium-screen.tsx`
  - current: `프리미엄`
  - target destination: `프로필`
- `legal-screen.tsx`
  - current: legal document title
  - target destination: `프로필`
- `account-deletion-screen.tsx`
  - current: `계정 삭제`
  - target destination: `프로필`
- `profile-edit-screen.tsx`
  - current: `프로필 수정`
  - target destination: `프로필`
- `profile-notifications-screen.tsx`
  - current: `알림 설정`
  - target destination: `프로필`
- `profile-relationships-screen.tsx`
  - current: `관계도`
  - target destination: `프로필`
- `profile-saju-summary-screen.tsx`
  - current: `사주 요약`
  - target destination: `프로필`
- `signup-screen.tsx`
  - current: `로그인 및 시작`
  - target destination: derived from `returnTo`
- `onboarding-screen.tsx`
  - current: `처음 설정하기`
  - target destination: derived from `returnTo`
- `auth-callback-screen.tsx`
  - current: `로그인 확인`
  - target destination: derived from `callbackMeta.returnTo`

## Reuse / Extend / New
- Reuse: keep `RouteBackHeader` as the single shared header component.
- Extend: add a route-title resolver that converts fallback destinations into display labels.
- Avoid: repeating manual string mappings at every callsite, especially for `returnTo`-based flows.

## Implementation Direction
1. Add route-destination label resolver near `RouteBackHeader`.
2. Make `RouteBackHeader` default to the resolved destination label when no explicit override is provided.
3. Remove incorrect current-page labels from static callsites and replace with destination-based labels where needed.
4. Use the resolver in `signup`, `onboarding`, and `auth-callback` dynamic flows.

## Validation Plan
- `npm run rn:typecheck`
- `npm run rn:test`
- `flutter analyze`
- iPhone 17 screenshots for at least `premium`, `character profile`, and one `returnTo`-based flow
