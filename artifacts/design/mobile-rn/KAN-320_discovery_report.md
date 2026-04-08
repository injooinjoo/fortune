# Discovery Report

## 1. Goal
- Requested change:
  - Match Google, Kakao, and Naver login buttons to the same white pill design used by the Apple button in the RN app.
- Work type: Widget / Page
- Scope:
  - Auth entry surfaces in chat soft gate and signup screen

## 2. Search Strategy
- Keywords:
  - `AppleAuthButton`
  - `Google로 계속하기`
  - `카카오로 계속하기`
  - `네이버로 계속하기`
  - `SocialActionButton`
- Commands:
  - `rg -n "AppleAuthButton|Google로 계속하기|카카오로 계속하기|네이버로 계속하기|SocialActionButton" apps/mobile-rn/src -g '*.tsx'`
  - `sed -n '1,220p' apps/mobile-rn/src/components/apple-auth-button.tsx`
  - `sed -n '520,700p' apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  - `sed -n '110,190p' apps/mobile-rn/src/screens/signup-screen.tsx`

## 3. Similar Code Findings
- Reusable:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/apple-auth-button.tsx` - current target visual treatment for the white auth pill
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/theme.ts` - source of theme tokens for the shared button colors and radius
- Reference only:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` - local `SocialActionButton` still uses the old dark style
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx` - non-Apple providers still use `PrimaryButton`

## 4. Reuse Decision
- Reuse as-is:
  - `AppleAuthButton` for native Apple sign-in on iOS
- Extend existing code:
  - Add a shared custom pill button component for non-Apple social providers
  - Reuse that component in both chat soft gate and signup
- New code required:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/social-auth-pill-button.tsx`
- Duplicate prevention notes:
  - Avoid keeping separate dark and light auth button implementations across the two screens

## 5. Planned Changes
- Files to edit:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/apple-auth-button.tsx`
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx`
- Files to create:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/components/social-auth-pill-button.tsx`
  2. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/mobile-rn/KAN-320_discovery_report.md`

## 6. Validation Plan
- Static checks:
  - `npm run rn:typecheck`
  - `git diff --check -- <changed files>`
- Runtime checks:
  - Launch RN app on iOS simulator
  - Capture auth entry screenshot
- Test cases:
  1. Chat soft gate shows Apple, Google, Kakao, and Naver with the same white pill treatment
  2. Signup screen shows the same treatment for all social providers
