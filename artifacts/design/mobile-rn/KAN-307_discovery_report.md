# Discovery Report

## Goal
- Update RN subpage back navigation from `chevron only` to `chevron + current page label`
- Apply the pattern consistently across all screens using `RouteBackHeader`
- Verify the result on iPhone 17

## Search Strategy
- Commands:
  - `rg -n "RouteBackHeader|header={<RouteBackHeader|fallbackHref" apps/mobile-rn/src apps/mobile-rn/app`
  - `sed -n '1,240p' apps/mobile-rn/src/components/route-back-header.tsx`
  - `sed -n '1,260p' apps/mobile-rn/src/screens/*.tsx`

## Findings
- Current shared header is chevron-only:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/route-back-header.tsx`
- Active usage sites:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/legal-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/premium-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/account-deletion-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-edit-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/character-profile-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/onboarding-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-saju-summary-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/auth-callback-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-notifications-screen.tsx`

## Reuse Decision
- Reuse:
  - existing `RouteBackHeader` press and fallback behavior
- Extend:
  - add `label` prop to `RouteBackHeader`
  - wire each screen with its current page label
- No new screen components needed

## Label Plan
- `캐릭터 프로필`
- `프리미엄`
- `계정 삭제`
- `프로필 수정`
- `로그인 및 시작`
- `처음 설정하기`
- `사주 요약`
- `관계도`
- `로그인 확인`
- `알림 설정`
- legal pages use their runtime `title`

## Validation Plan
- `npm run rn:typecheck`
- `npm run rn:test`
- `flutter analyze`
- `git diff --check`
- iPhone 17 screenshots:
  - character profile
  - premium
  - privacy or another legal surface
