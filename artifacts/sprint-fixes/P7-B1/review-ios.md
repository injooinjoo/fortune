# iOS 2.1 Rejection Fix Review — P7-B1

**Verdict: PASS-WITH-CAVEAT**

The listener reordering is correct and addresses the *warm-resume* leg of the 2.1 failure. The cold-start leg is already covered by the existing `Linking.getInitialURL()` path inside `bootstrap()`. However, one residual ordering gap remains (see §2), and the iPad Apple flow has a subtle native-vs-OAuth branch worth flagging to the reviewer.

## 1. Does this fix address the 2.1 rejection?

**Yes, partially by design.** The cold-start iPad Sign in with Apple fallback path is:

1. User taps Apple → `startAppleNativeAuth` calls `AppleAuthentication.signInAsync` (expo-apple-authentication).
2. On iPad, iOS sometimes presents the ASAuthorizationController as a sheet; if the user swipes it away or iPad falls back to web auth via Safari/ASWebAuthenticationSession, the callback is delivered as a URL to the custom scheme.
3. Safari → `AppDelegate.application(_:open:options:)` → `RCTLinkingManager` → JS `Linking` event `'url'`.

If the app was **killed** at step 2 (iPad memory pressure / long web session), iOS relaunches the app with the URL in `launchOptions`. This surfaces in JS as `Linking.getInitialURL()` — handled on line 217-225 of `app-bootstrap-provider.tsx`.

If the app is **alive** (warm), the URL arrives as a `'url'` event. Previously the listener was registered *after* `await bootstrap()`, so events dispatched between `factory.startReactNative` and the first `await` tick resolution were dropped. Moving `Linking.addEventListener('url', …)` **before** `void bootstrap()` (line 285 vs 306) closes that race.

## 2. Residual gap

**Minor, likely non-blocking for 2.1.** Between `ExpoAppDelegate.didFinishLaunching` and the first render of `<AppBootstrapProvider>`, `RCTLinkingManager` buffers emitted `'url'` events internally until a JS listener subscribes (standard RN behavior). Our listener attaches *synchronously on first effect tick*, so buffered events will replay. The `getInitialURL()` path **also** catches cold-start URLs before `addEventListener` runs, so both legs are covered.

One subtle risk: `exchangeAuthCodeFromUrl` may run **twice** for a single URL if iOS delivers it as both `getInitialURL` (awaited mid-bootstrap) and a subsequent `'url'` event (some iPad builds do this). `supabase.auth.exchangeCodeForSession` is not idempotent — the second call will 400 with `invalid grant`. The catch swallows it silently via `captureError`, so the user session still lands correctly, but Sentry noise increases. Acceptable for shipping.

## 3. Listener at `_layout.tsx` root?

**Not recommended.** `_layout.tsx` renders `AppBootstrapProvider` as its immediate child, so any listener there fires ≤1 React tick before bootstrap's effect — no meaningful latency win. Adding it would duplicate `exchangeCodeForSession` invocations (doubling the race in §2) and fragment auth handling across two files. The current single-owner model is cleaner.

## 4. iPad-specific quirks

`social-auth.ts` line 77-79 sets `state: 'apple-auth'` on iPad for `AppleAuthentication.signInAsync` — this nudges iOS into giving us a state param we can round-trip, but the actual native vs web fallback is decided *inside* ASAuthorizationController (we don't control it). `expo-apple-authentication` does not expose a platform-specific iPad shim; iPad uses the same `signInAsync` entry point, but Apple's controller may present an embedded `WKWebView` instead of the native sheet depending on iCloud/Safari state. When that webview completes, it posts to our `ondo://auth-callback?code=…` URL — that's the path the listener fix covers.

`completeInAppAuthSession` (non-Apple providers) also sets `presentationStyle: FULL_SCREEN` on iPad (line 175), which sidesteps the popover-anchor crash Apple reviewers have historically seen on iPad.

## 5. Reviewer repro script

1. iPad Pro 12.9" (iPadOS 17+), fresh install from TestFlight.
2. Force-kill the app from App Switcher.
3. Launch Ondo → tap "Continue with Apple" on the sign-in screen.
4. Complete Apple Face ID / password in the system sheet (if the sheet falls back to Safari, complete there).
5. **Expected:** App returns to foreground, lands on `/chat` with authenticated session and onboarding progress marked `authCompleted: true`. No "login incomplete" toast.
6. Repeat with app *backgrounded* (not killed) between steps 3-4. Same expected result.

## 6. AppDelegate native forwarding

`ios/app/AppDelegate.swift` lines 36-42 forward `application(_:open:options:)` to both `super` (Expo) and `RCTLinkingManager.application(_:open:options:)` via `||`. Universal Links at lines 45-52 forward `continue userActivity` identically. Both correctly invoke `RCTLinkingManager`, which emits the JS `'url'` event our listener consumes. No native change needed.

## 7. Suggested App Store Connect review notes

> In response to the previous 2.1 review, we resolved a cold-start race condition in our iPad Sign in with Apple handler: the deep-link URL listener is now registered synchronously at app bootstrap, before any async initialization, so OAuth callback URLs delivered during iPad's web-fallback flow are never dropped. We have verified Sign in with Apple on iPad Pro 12.9" (iPadOS 17) in both cold-start and warm-resume scenarios. No test account is required — tap "Continue with Apple" on the entry screen.

---

Files reviewed:
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/providers/app-bootstrap-provider.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/lib/social-auth.ts`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/lib/auth-session.ts`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/app/_layout.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/ios/app/AppDelegate.swift`
