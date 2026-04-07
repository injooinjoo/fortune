# RCA Report

## 1. Symptom
- Error message:
  - Apple review previously reported Google login blank screen, external-browser auth UX rejection, and inability to find IAP.
- Repro steps:
  1. Open the RN app and enter the login surface.
  2. Tap `Google로 계속하기` or enter the `signup` screen from profile/premium.
  3. Complete OAuth or attempt to locate subscriptions/tokens from profile.
- Observed behavior:
  - Google OAuth launched via `Linking.openURL()`, which leaves the app and depends on an external browser/deep-link round trip.
  - Successful auth from `signup` did not have a deterministic post-login handoff.
  - App Review notes described an outdated IAP route, making reviewer discovery harder than the actual UI.
- Expected behavior:
  - Social OAuth should stay in-app, return deterministically, and finish on a known callback path.
  - `signup` should always hand off to auth completion and then to the requested route.
  - Reviewer instructions and visible labels should match the RN navigation exactly.

## 2. WHY (Root Cause)
- Direct cause:
  - Native OAuth providers still used `Linking.openURL()` and `signup` had no session-driven redirect after successful auth.
- Root cause:
  - The RN auth flow mixed two patterns: chat soft-gate relied on gate recomputation, while `signup` relied on external deep-link navigation that was never enforced for native Apple auth and was brittle for Google OAuth.
  - App Review metadata drifted away from the current RN UI, so the reviewer was looking for the wrong entry path and outdated labels.
- Data/control flow:
  - Step 1: `startSocialAuth()` generated an OAuth URL and opened it with `Linking.openURL()`.
  - Step 2: Browser/app return was expected to restore control via deep link listeners, but `signup` itself did not redirect on session success.
  - Step 3: Reviewer instructions pointed to stale path names, so even working IAP UI could be missed during review.

## 3. WHERE
- Primary location: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/social-auth.ts`
- Related call sites:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-screen.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/metadata/review_information/review_notes.txt`
  - `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/Deliverfile`

## 4. WHERE ELSE (Global Search)
- Search patterns used:
  - `rg -n "openURL|skipBrowserRedirect|google|apple|signup|returnTo" apps/mobile-rn/src`
  - `rg -n "구독 및 토큰|review_notes|Profile" ios/fastlane apps/mobile-rn/src`
- Findings:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/social-auth.ts` - native OAuth launch path
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx` - no post-auth redirect on existing session
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx` - recent result reopen path could no-op when no reusable payload exists
  4. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-screen.tsx` - IAP entry label existed but was not explicit enough for review copy alignment
  5. `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/metadata/review_information/review_notes.txt` - stale `profile avatar` wording
  6. `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/Deliverfile` - stale `bottom-right Profile tab` wording

## 5. HOW (Correct Pattern)
- Reference implementation: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/auth-callback-screen.tsx`
- Before:
```ts
await Linking.openURL(response.data.url);
```
- After:
```ts
const result = await WebBrowser.openAuthSessionAsync(
  authorizationUrl,
  redirectTo,
);
await exchangeAuthCodeFromUrl(result.url);
```
- Why this fix is correct:
  - `expo-web-browser` keeps OAuth inside the app-auth flow expected on iOS.
  - Session establishment becomes explicit instead of depending on an external browser hop.
  - `signup` can redirect deterministically once session exists, regardless of provider.
  - Reviewer notes and in-app labels now describe the same path the reviewer actually sees.

## 6. Fix Plan
- Files to change:
  1. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/social-auth.ts` - switch native OAuth to in-app auth session and exchange callback codes directly
  2. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/signup-screen.tsx` - add deterministic session-based handoff to `/auth/callback`
  3. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/chat-screen.tsx` - fallback from recent-result reopen into the standard action flow
  4. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-screen.tsx` - make IAP entry clearer for reviewers
  5. `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/app.config.ts` - register `expo-web-browser` plugin
  6. `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/metadata/review_information/review_notes.txt` - align reviewer instructions to current RN flow
  7. `/Users/jacobmac/Desktop/Dev/fortune/ios/fastlane/Deliverfile` - align App Review notes to current RN flow
- Risk assessment:
  - OAuth behavior changes on native iOS/Android, so callback handling and cancellation states must be rechecked.
  - Review note changes must stay aligned with visible labels in the shipped build.
- Validation plan:
  - `npm run rn:typecheck`
  - `npm run rn:test`
  - RN iOS runtime smoke test for Apple login, Google login, and profile > premium path
  - `git diff --check`
