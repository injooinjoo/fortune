# Discovery Report

## 1. Goal
- Requested change:
  - Harden the RN App Review flows for auth, IAP discoverability, and review metadata accuracy.
- Work type: Service / Page / App Review metadata
- Scope:
  - Native social auth launch, signup handoff, profile premium entry, and fastlane review notes

## 2. Search Strategy
- Keywords:
  - `apple`
  - `google`
  - `skipBrowserRedirect`
  - `returnTo`
  - `구독 및 토큰`
  - `review_notes`
- Commands:
  - `rg -n "apple|google|skipBrowserRedirect|returnTo" apps/mobile-rn/src`
  - `rg -n "구독 및 토큰|review_notes|Deliverfile" ios/fastlane apps/mobile-rn/src`
  - `rg -n "deepLinkConfig|authCallbackHost" packages/product-contracts/src apps/mobile-rn/src`

## 3. Similar Code Findings
- Reusable:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/auth-callback-screen.tsx` - existing auth finalization surface and return routing
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/app-bootstrap-provider.tsx` - existing session/deep-link synchronization
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/premium-screen.tsx` - existing purchase UI already renders the required products
  4. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx` - existing action-launch path that can be reused as a dead-tap fallback
  5. `/Users/jacobmac/Desktop/Dev/fortune/packages/product-contracts/src/products.ts` - source of truth for reviewer-visible product titles
- Reference only:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/social-auth.ts` - current provider matrix and redirect URI construction
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-screen.tsx` - current premium entry wording
  3. `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/metadata/review_information/review_notes.txt` - current but stale reviewer instructions
  4. `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/Deliverfile` - current but stale App Review note string

## 4. Reuse Decision
- Reuse as-is:
  - `AuthCallbackScreen` for final auth handoff and return routing
  - `productCatalog` / `getProductDisplayTitle()` for reviewer-facing product names
- Extend existing code:
  - `startSocialAuth()` to support in-app auth sessions on native
  - `SignupScreen` to react to a newly established session
  - `ProfileScreen` to make the purchase entry label more reviewer-obvious
- New code required:
  - Minimal helper for native in-app OAuth completion using `expo-web-browser`
- Duplicate prevention notes:
  - Do not add a new auth callback screen or a second premium entry route. Extend the existing RN flow instead.

## 5. Planned Changes
- Files to edit:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/social-auth.ts`
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx`
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx`
  4. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-screen.tsx`
  5. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/app.config.ts`
  6. `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/metadata/review_information/review_notes.txt`
  7. `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/Deliverfile`
- Files to create:
  1. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/mobile-rn/KAN-319_rca_report.md`
  2. `/Users/jacobmac/Desktop/Dev/fortune/artifacts/design/mobile-rn/KAN-319_discovery_report.md`

## 6. Validation Plan
- Static checks:
  - `npm run rn:typecheck`
  - `npm run rn:test`
  - `git diff --check`
- Runtime checks:
  - Native iOS smoke test for Apple login
  - Native iOS smoke test for Google login
  - Profile > 구독 및 토큰 구매 > 상품 목록 확인
- Test cases:
  1. From chat soft-gate, Apple login returns into the app and unlocks the ready state.
  2. From signup, Google login returns into the app and routes through auth completion back to the requested screen.
  3. From profile, reviewer can find `구독 및 토큰 구매` and see `프로 구독` plus `토큰 100개`.
