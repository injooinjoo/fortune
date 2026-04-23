# iOS App Store Submission Audit — 온도 (Ondo) v1.0.9

Date: 2026-04-23
Bundle: `com.beyond.fortune` · ASC App ID: `6749496180`
Scope: iOS metadata, permissions, Privacy Manifest, Sign-in with Apple cold-start, OAuth URL schemes, llama.rn footprint, App Review metadata.

---

## CRITICAL (likely rejection)

### C1. `CFBundleShortVersionString` drift — `ios/Info.plist` says `1.0.8`, but `app.config.ts` says `1.0.9`
- File: `apps/mobile-rn/ios/app/Info.plist:24` (`<string>1.0.8</string>`)
- File: `apps/mobile-rn/app.config.ts:89` (`version: '1.0.9'`)
- Risk: Since `ios/` is checked in (managed-workflow hybrid), a local build pipeline that skips `expo prebuild --clean` will ship 1.0.8 binary while ASC metadata is 1.0.9 — App Store build upload will be rejected as duplicate, or worse a mismatch shows in Review. **Must run `expo prebuild --clean` on EAS build, or manually bump the Info.plist before archive.**

### C2. Duplicate `CFBundleURLSchemes` entries for the same scheme
- File: `apps/mobile-rn/ios/app/Info.plist:32-33` — `com.beyond.fortune` listed twice in the same URL type.
- Risk: iOS logs "Unable to register for scheme" warning; reviewer tools (`sysdiagnose`) flag duplicates. Not a hard reject, but fix by regenerating via `expo prebuild --clean` or manually removing the dup.

### C3. `NSSpeechRecognitionUsageDescription` uses Apple's default template string ("Allow $(PRODUCT_NAME) to use speech recognition.")
- File: `apps/mobile-rn/ios/app/Info.plist:64-65`
- Apple 2.1 / 5.1.1: **generic permission strings are a common rejection reason.** Every other key on this app has a proper Korean purpose string; this one doesn't.
- Fix: add to `app.config.ts` → `expo-speech-recognition` plugin options a `speechRecognitionPermission:` entry (the plugin honors it), or override via the infoPlist block:
  ```ts
  NSSpeechRecognitionUsageDescription:
    '음성 메시지를 텍스트로 변환하기 위해 음성 인식 권한이 필요합니다. / Speech recognition is used to transcribe voice messages.'
  ```

### C4. Sign in with Apple iPad cold-start race — `Linking.addEventListener` installs AFTER `getInitialURL`, and auth state is decided inside the same `bootstrap()` promise
- File: `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:190-374`
- Ordering today:
  1. `bootstrap()` runs `Linking.getInitialURL()` at line 217, exchanges code, reads `supabase.auth.getSession()` at 228, then calls `handleDeepLink(initialUrl)` at 269.
  2. Only *after* `bootstrap()` returns does `Linking.addEventListener('url', …)` install at line 355.
- Problem: on iPad, Apple sign-in falls back to `WebBrowser.openAuthSessionAsync` → after dismissal the callback URL is delivered via `Linking` event. If the event fires before the listener is attached (fast return on cached session, or the iPad ASWebAuthSession closes before JS finished first render), the callback is silently dropped — this is the **exact Guideline 2.1 rejection pattern** the previous submission hit.
- Additional issue: `app/_layout.tsx` does NOT install any global Linking listener before child providers mount. The root listener lives deep inside `AppBootstrapProvider`'s effect and races with React first-paint.
- Fix: move the `Linking.addEventListener('url', …)` registration to **module scope** or into a synchronous effect that runs before `bootstrap()`'s awaits. At minimum split it out of the same `useEffect` so the subscription is attached synchronously on mount, and `getInitialURL()` runs afterward.
- Test: iPad cold start → tap Apple sign-in → complete OAuth → verify session is restored on first return, with no "retry" required.

### C5. Privacy Manifest missing entries for Sentry SDK
- File: `apps/mobile-rn/ios/app/PrivacyInfo.xcprivacy:1-48`
- App uses `@sentry/react-native` (see `package.json:20`, `app.config.ts:143`, `app-bootstrap-provider.tsx` initCrashReporting). Sentry collects **crash data, device identifiers, and diagnostic data** — these are `NSPrivacyCollectedDataTypes` categories. Current manifest has `<array/>` (empty).
- Apple's May 2024 enforcement rejects on missing privacy manifest declarations when the binary scan finds tracking SDKs.
- Sentry RN SDK ships its own PrivacyInfo.xcprivacy (since v5) but the *app-level* manifest should also list "Crash Data", "Performance Data", "Other Diagnostic Data" under `NSPrivacyCollectedDataTypes`. And Mixpanel token is declared in `extra.mixpanelToken` — if Mixpanel is actually initialized, app-level declaration of "Product Interaction", "Other Usage Data" is required plus reconciling with ASC App Privacy answers.
- Fix: populate `NSPrivacyCollectedDataTypes` array in `PrivacyInfo.xcprivacy` to mirror ASC "App Privacy" answers.

---

## WARNING (reviewer might ask)

### W1. On-device LLM model download is ~4GB over HTTPS from Hugging Face
- File: `apps/mobile-rn/src/lib/on-device-llm.ts:4` — "Gemma 4 E2B Q4_K_M 모델(~3.1GB) + 비전 프로젝터 mmproj-F16.gguf (~987MB)"
- File: `apps/mobile-rn/src/lib/on-device-model-registry.ts:51` — pulls `https://huggingface.co/...`
- Risk: reviewer on an iPad with low storage / slow Wi-Fi will see download stall. App Review typically runs in constrained networks. Include in Review Notes: "On-device AI features are optional; all core fortune features work server-side without the download."
- Also: on-device model storage must respect Apple's "Don't backup user-generated non-reproducible content" guidance. `FileSystem.documentDirectory` is backed up by iCloud — a 4GB download will bloat user iCloud. Use `cacheDirectory` or set `excludedFromBackup` flag (URLResourceKey). This is a likely **Guideline 2.5 / 5.6 storage concern.**

### W2. `llama.rn` triggers `enableEntitlements: true` + C++20 + OpenCL in plugin
- File: `apps/mobile-rn/app.config.ts:148-156`
- `enableEntitlements: true` may add entitlements to the app that Apple does not expect for this bundle (e.g., Increased Memory Limit / Extended Virtual Addressing). If the generated entitlements exceed what the provisioning profile allows, the build signs but App Review's binary scan may flag. Verify what the plugin actually adds:
  ```bash
  cat apps/mobile-rn/ios/app/app.entitlements
  ```
  Today shows only `com.apple.developer.applesignin`. If a build (with plugin run) adds `com.apple.developer.kernel.increased-memory-limit`, review notes should mention AI inference use case.

### W3. ATT / Tracking — `NSUserTrackingUsageDescription` not declared, `NSPrivacyTracking=false`
- File: `PrivacyInfo.xcprivacy:45-46` — `NSPrivacyTracking=false`
- No `expo-tracking-transparency` pkg installed. Good — reviewer won't see a tracking prompt, and manifest matches.
- Ensure ASC App Privacy answers "Does this app collect data used to track the user?" → **No**. If Mixpanel is actually sending data, and "Mixpanel" is declared as a tracking SDK elsewhere, there's a contradiction.

### W4. `expo-notifications` push prompt timing
- App uses `registerPushTokenForSignedInUser` inside `app-bootstrap-provider.tsx:258,318` — fires right after `setSession`. Make sure the iOS permission prompt is **not** shown at cold start before user is in any meaningful context. Apple historically prefers "just-in-time" permission requests.
- Evidence doc `docs/deployment/review/IOS_REVIEW_EVIDENCE.md:20` says the previous iOS submission already fixed this, but this RN rewrite may have regressed — verify push permission prompt is gated on user action (e.g., turning on notifications in settings), not cold start.

### W5. OAuth URL schemes — Google / Kakao / Naver declared only as universal `com.beyond.fortune` scheme
- File: `Info.plist:27-42` — only app's own scheme + expo dev scheme.
- Good: Supabase OAuth uses the app's own deep-link scheme as callback (`com.beyond.fortune://auth-callback`), so separate Google/Kakao schemes are NOT needed. No `LSApplicationQueriesSchemes` either — fine because app doesn't try to open KakaoTalk app directly. Confirmed no native Kakao SDK.
- Works as designed. No action.

### W6. `UIBackgroundModes: ['remote-notification']` is correct, but must match push usage
- File: `app.config.ts:106`
- Only declared mode. Push handler in `installPushNotificationHandlers`. Apple sometimes asks "why do you need background mode" — review notes should state: "Silent + standard push notifications for new chat messages."

### W7. iPad `supportsTablet: true` but landscape enabled while iPhone is portrait-only
- File: `Info.plist:87-93` — iPad supports all 4 orientations; iPhone only portrait (`Info.plist:82-86`).
- Risk: reviewer rotates iPad, if any screen has broken layout in landscape → rejection. Previous rejection was partially iPad-related. Either lock iPad to portrait (easiest) or do thorough landscape QA on every screen.
- Recommendation: set `UISupportedInterfaceOrientations~ipad` = portrait-only matching iPhone, unless you've QA'd every screen in landscape.

### W8. Subscription metadata (previous 3.1.2 rejection)
- File: `appstore-metadata.md` — contains no subscription disclosures.
- Apple 3.1.2 requires: (1) length of each subscription, (2) content/services provided during each period, (3) price per period, (4) payment charged to iTunes account at purchase confirmation, (5) auto-renewal disclosure, (6) links to privacy policy AND terms of service (EULA).
- Present: Privacy URL `https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/privacy-policy`, Terms URL. **These are supabase function URLs, not a real domain.** Apple reviewers sometimes reject supabase.co "app review" URLs as unprofessional/unstable. Host these on a proper domain (zpzg.co.kr from the evidence doc suggests one exists).
- Missing in `appstore-metadata.md`: explicit EULA clause, subscription length/price matrix, renewal disclosure inside the app (Purchase screen must show these). Check `premium-screen.tsx` displays these before purchase.

---

## INFO

### I1. `ITSAppUsesNonExemptEncryption=false` correctly set in both places
- `app.config.ts:105` and `Info.plist:45-46`.
- App uses only HTTPS (Supabase, OpenAI/Gemini via Edge Function) + Apple Crypto for nonce hashing (`expo-crypto`, SHA-256) for Apple ID Token. SHA-256 within Apple-exempt categories (authentication). `false` is correct — no self-classification report needed.

### I2. Privacy Manifest required-reason API declarations present
- `PrivacyInfo.xcprivacy` declares FileTimestamp (C617.1, 0A2A.1, 3B52.1), UserDefaults (CA92.1), SystemBootTime (35F9.1), DiskSpace (E174.1, 85F4.1). All four mandatory categories covered.

### I3. Entitlements minimal and correct
- `app.entitlements`: only `com.apple.developer.applesignin` → `Default`. Good.
- `aps-environment: production` set in `app.config.ts:109`.
- No Universal Links / Associated Domains (correct, per evidence doc IOS-LINK-001).

### I4. `AppDelegate.swift` forwards `application:openURL:` and `continue userActivity:` to `RCTLinkingManager`
- `ios/app/AppDelegate.swift:36-52`. Native side is wired correctly; the JS-side race (C4) is the real concern.

### I5. iOS permissions actually requested — audit
| Permission | Declared | String quality |
|-----------|----------|----------------|
| Camera | yes (Info.plist:58-59) | Korean, purposeful |
| Photo Library | yes (:62-63) | Korean, purposeful |
| Microphone | yes (:60-61) | Korean, purposeful |
| Speech Recognition | yes (:64-65) | **DEFAULT TEMPLATE — fix (see C3)** |
| Notifications | expo-notifications handles at runtime | no string needed in Info.plist |
| Tracking (ATT) | not declared | not requested — consistent |
| Location | not declared | not requested — good |
| Contacts/Calendar/HealthKit/Bluetooth/Motion/FaceID | not declared | not requested — good |

### I6. Age rating (12+) appropriate
- `appstore-metadata.md:41-49` — 12+ with "Infrequent/Mild Mature/Suggestive" for romance story content. Reasonable for AI persona chat. Consider whether chat can surface adult content that would trigger 17+.

### I7. "No login required" Review Note is smart
- `appstore-metadata.md:54,58` — tells reviewer they don't need a demo account, land on chat directly. Addresses common 2.1 "can't test without account" reject. Keep this language.

---

## Recommended Fix Priority

1. **C4 (iPad Sign-in race)** — move Linking listener out of bootstrap() await chain.
2. **C3 (Speech Recognition string)** — one-line infoPlist override.
3. **C1 + C2 (Info.plist drift)** — run `expo prebuild --clean` so EAS builds regenerate from app.config.ts.
4. **C5 (Sentry PrivacyInfo)** — populate NSPrivacyCollectedDataTypes.
5. **W8 (subscription URL)** — move Privacy/Terms from supabase.co to proper domain before re-submission.
6. **W7 (iPad landscape)** — lock iPad to portrait unless landscape fully QA'd.
7. **W1 (on-device model)** — flag excludedFromBackup + review note explaining model is optional.
