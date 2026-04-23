# Ondo — Auth & Login Flow QA Checklist

Scope: `signup.tsx`, `auth/callback.tsx`, `auth/email.tsx`, `auth/phone.tsx` + supporting providers/lib.
Target device: iPhone 15 + iPad (iOS 17), plus iOS 14/15 regression device.
Date: 2026-04-23

---

## 1. Flow Map — Every Button on `signup-screen.tsx`

| # | Label (KO) | Provider | Handler (file:line) | Happy path | Error path |
|---|---|---|---|---|---|
| 1 | 애플 로그인 | Apple (native) | `handleSocialAuthStart('apple')` → `social-auth.ts:51 startAppleNativeAuth` | `AppleAuthentication.signInAsync` → `signInWithIdToken` → `onAuthStateChange` sets session → `useEffect` in signup redirects to `/auth/callback?returnTo=` | `ERR_REQUEST_CANCELED` → "애플 로그인을 취소했습니다." toast text; `!identityToken` → "애플 인증 토큰을 확인하지 못했습니다."; `!isAvailable` → "이 기기에서는 애플 로그인을 사용할 수 없습니다." |
| 2 | 구글 로그인 | Google (OAuth via `WebBrowser.openAuthSessionAsync`) | `handleSocialAuthStart('google')` → `social-auth.ts:325 signInWithOAuth` → `completeInAppAuthSession` | OAuth sheet → redirect to `ondo://auth/callback?code=…` → `exchangeAuthCodeFromUrl` → session set → `/auth/callback` | cancel/dismiss → `"구글 로그인을 취소했습니다."`; `locked` → "이미 다른 로그인 창이 열려 있습니다."; no code → "로그인 세션을 확인하지 못했습니다." |
| 3 | 전체 동의 | — | inline (signup-screen.tsx:148) | toggles all 4 consents | none (pure state) |
| 4 | 만 14세 이상 (필수) | — | `setAgreedAge(v => !v)` | toggles | none |
| 5 | 이용약관 동의 (필수) | — | `setAgreedTerms` | toggles; 약관 보기 → `/terms-of-service` | none |
| 6 | 개인정보처리방침 동의 (필수) | — | `setAgreedPrivacy` | toggles; 방침 보기 → `/privacy-policy` | none |
| 7 | 마케팅 수신 (선택) | — | `setAgreedMarketing` | toggles | none |
| 8 | 다른 방법으로 시작 | — | `setOtherMethodsExpanded` | toggles accordion | none |
| 9 | 이메일로 시작 | Email | `router.push('/auth/email')` (signup-screen.tsx:318) | navigates to email screen | blocks w/ Alert if consent missing |
| 10 | 전화번호로 시작 | Phone OTP | `router.push('/auth/phone')` | navigates to phone screen | blocks w/ Alert if consent missing |

Kakao/Naver buttons are commented out (signup-screen.tsx:41-51) — not user-visible.

### Email screen (`email-auth-screen.tsx`)
| Button | Handler | Happy | Error |
|---|---|---|---|
| 가입하기 / 로그인 | `handleSubmit` → `signUpWithEmail` / `signInWithEmail` | `markAuthComplete()` → `/auth/callback` | "비밀번호가 일치하지 않습니다.", Supabase error → `result.errorMessage`, catch → "오류가 발생했습니다. 다시 시도해 주세요." |
| 모드 토글 | `handleToggleMode` | signup↔login swap, clears confirm + error | — |

### Phone screen (`phone-auth-screen.tsx`)
| Button | Handler | Happy | Error |
|---|---|---|---|
| 인증 코드 받기 | `handleSendOtp` → `signInWithPhone` | step → `otp`, starts 3-min timer | failure → errorMessage; bad format already blocked by `isPhoneValid` |
| 인증하기 | `handleVerifyOtp` → `verifyPhoneOtp` | `markAuthComplete` → `/auth/callback` | fail errorMessage |
| 인증 코드 다시 받기 | `handleResendOtp` | timer restart | fail errorMessage |
| 전화번호 다시 입력 | `handleBackToPhone` | step → `phone`, clears OTP | — |

---

## 2. Executable Test Checklist

### A. Apple Login (iPhone)
- [ ] A1 Happy (new user): Tap 애플 로그인 with all required consents → OS Apple sheet → continue → lands on `/onboarding/name` (first run) — `firstRunHandoffSeen=false` path.
- [ ] A2 Happy (existing user): same but `firstRunHandoffSeen=true` → lands on `/chat?showList=1`, welcome carousel skipped, character list visible.
- [ ] A3 Consent missing: leave 만14세 unchecked → button disabled (opacity 0.46), tap still shows Alert "약관 동의가 필요해요".
- [ ] A4 Cancel on OS sheet: "취소" button → `ERR_REQUEST_CANCELED` → message "애플 로그인을 취소했습니다.", button re-enabled, no crash, `activeProviderId` resets.
- [ ] A5 Airplane mode mid-flow: enable airplane after sheet accepts → `signInWithIdToken` network error → Korean error bubble, retryable.
- [ ] A6 Token persistence: kill app, reopen → `supabase.auth.getSession()` restores session → bootstrap goes straight to `/chat` (no signup screen).
- [ ] A7 Double-fire dedup (iOS 14/15): reproduce cold-start + `url` event both firing → only one `exchangeAuthCodeFromUrl` runs (check `exchangedAuthUrls` Set in bootstrap). No `invalid_grant` in Sentry.

### B. Apple Login (iPad — P7-B1 fallback)
- [ ] B1 iPad happy: sheet presents `FULL_SCREEN` (social-auth.ts:175) + `state: 'apple-auth'` passed → success.
- [ ] B2 iPad OAuth fallback cold-start: trigger fallback path (iPad returns no `identityToken`, uses OAuth redirect). Force-quit app, open from callback URL → `Linking.getInitialURL()` picks up URL → `exchangeOnce` fires → `/auth/callback` renders → session lands → `/chat`. Regression guard: listener is attached before `bootstrap()` (see app-bootstrap-provider.tsx:301), so even if URL arrives while bootstrap still awaiting storage, it's queued.
- [ ] B3 iPad background resume: background app during OAuth → return → `url` event → handled by `addEventListener('url')` → `/auth/callback`.

### C. Google Login
- [ ] C1 Happy (new): OAuth sheet → in-app browser → redirect → session → onboarding.
- [ ] C2 Happy (existing): redirect → `/chat?showList=1`.
- [ ] C3 Tap-cancel on WebBrowser: "Done"/swipe down → `result.type === 'cancel'` → "구글 로그인을 취소했습니다.", button re-enabled.
- [ ] C4 Locked session: open Google sheet twice rapidly → second returns `result.type === 'locked'` → "이미 다른 로그인 창이 열려 있습니다."
- [ ] C5 Bad redirect (no code): simulate by killing browser mid-redirect → `exchangeAuthCodeFromUrl` returns null → "로그인 세션을 확인하지 못했습니다."
- [ ] C6 Airplane mode before tap → Supabase `signInWithOAuth` fails → errorMessage rendered.
- [ ] C7 Airplane mode after redirect, before exchange → catch surface `bootstrap:auth-code-exchange` logs.
- [ ] C8 Account merge: sign out → sign in with same email via Apple → expect same user, `needsAuthScopedReset = false`. Sign out → sign in with *different* Google account → `needsAuthScopedReset=true` → onboarding progress reset (`birthCompleted:false`, `firstRunHandoffSeen:false`).

### D. Email auth
- [ ] D1 Signup happy: enter valid email + 6+ char pwd + matching confirm → success → markAuthComplete → `/auth/callback`.
- [ ] D2 Signup wrong confirm: mismatch → error text "비밀번호가 일치하지 않습니다." + red border.
- [ ] D3 Signup <6 char pwd: caption "✗ 6자 이상 필요 (현재 N자)" shows, submit button disabled.
- [ ] D4 Login wrong pwd: Supabase returns error → "로그인에 실패했습니다." or passthrough message.
- [ ] D5 Unknown email on login: error surfaced to user (not swallowed).
- [ ] D6 Airplane mode: catch branch → "오류가 발생했습니다. 다시 시도해 주세요."
- [ ] D7 Double-submit guard: rapidly tap 가입하기 → `isLoading` blocks second call.
- [ ] D8 Toggle mode mid-flow: clears `confirmPassword` + error, keeps email.

### E. Phone OTP
- [ ] E1 Happy: enter 01012345678 → 인증 코드 받기 → step `otp` → 3:00 countdown → enter SMS 6-digit → 인증하기 → session.
- [ ] E2 Invalid phone (<10 digits): button disabled (opacity via `disabled`).
- [ ] E3 OTP timer expiry: wait 180s → button disabled + "인증 코드가 만료되었습니다. 다시 요청해 주세요." → 재발송 flow.
- [ ] E4 Wrong OTP: 6-digit incorrect → `verifyPhoneOtp` fails → "인증에 실패했습니다." + retry enabled.
- [ ] E5 Resend: tap 다시 받기 → timer reset to 3:00.
- [ ] E6 Back-to-phone: resets step + OTP + error, keeps `phone` field.
- [ ] E7 Airplane mode during send → catch path message.
- [ ] E8 Background during OTP wait: minimize → return → timer still counting (note: interval keeps running via ref; verify it hasn't paused/drifted badly — see finding F3).

### F. Deep-link callback (`/auth/callback`)
- [ ] F1 Happy deep link: `ondo://auth/callback?code=xyz&returnTo=/chat` → bootstrap exchanges → screen renders spinner → replaces to `/onboarding/name` or `/chat?showList=1`.
- [ ] F2 Error in query: `?error=server_error&error_description=foo` → red error screen "로그인 실패" + 다시 시도 button → `/signup`.
- [ ] F3 Malformed URL: `?authCallbackUrl=%FF%FF` → try/catch falls back to directReturnTo (= `/chat`). No crash.
- [ ] F4 `returnTo=/auth/callback` self-loop: normalizer rejects → `/chat`. (auth-callback-screen.tsx:19-23)
- [ ] F5 Cold-start from deep link: kill app, open ondo://auth/callback?code=… from Notes → single exchange (Set dedup) → success.

### G. Sign-out + re-sign-in matrix
- [ ] G1 Sign out from profile → returns to authed-but-no-session state → subsequent bootstrap `getSession()` null → `/signup` accessible.
- [ ] G2 After sign-out, re-sign Apple with same Apple ID → `needsAuthScopedReset=false`, onboarding progress preserved.
- [ ] G3 After sign-out, sign in with Google using different email → `needsAuthScopedReset=true` → onboarding resets to birth/interest incomplete.

---

## 3. Quality Red Flags (watch while testing)

- [ ] Infinite spinner on `/auth/callback` (stuck at `bootstrapStatus !== 'ready'` or `appStateStatus !== 'ready'` — see finding F1).
- [ ] Double Apple sheet on iPad (both native + fallback firing).
- [ ] Empty error card without retry (currently covered by "다시 시도" button — verify the error path always sets `callbackMeta.errorMessage`).
- [ ] Copy consistency — all messages are Korean; verify no English leaks in Supabase-returned `response.error.message` (it is passed through raw — see finding F2).
- [ ] Touch target: Apple + Google pill `minHeight: 52`, consent checkboxes `paddingVertical:6` → hit area may be ~32pt, below HIG 44pt minimum.
- [ ] Apple HIG: Sign-in-with-Apple button must use SF Pro, black/white/outlined only, corner radius consistent — current impl uses `SocialAuthPillButton` with Ionicon `logo-apple`, **NOT** `AppleAuthentication.AppleAuthenticationButton`. **Risk: App Store review rejection** (finding F4).
- [ ] Password visibility toggle missing on email screen (both password fields `secureTextEntry` with no reveal). Not strictly a bug but common UX miss.

---

## 4. Static Findings (from source review)

- **F1 — Stale closure in `AuthCallbackScreen` error guard** (`auth-callback-screen.tsx:83-92`): `useEffect` returns early when `callbackMeta.errorMessage` is truthy, but error UI is only rendered when `callbackMeta.errorMessage` is truthy. If `session` never arrives *and* no error is reported (e.g., Supabase still loading), user is stuck on spinner indefinitely. No timeout / fallback. Recommend: add a ~10s safety timer → fallback to `/signup` with toast.

- **F2 — Raw Supabase error bubbled to UI** (`social-auth.ts:102`, `email-auth-screen.tsx:68`): `response.error.message` is shown verbatim. These strings are English (e.g., "Invalid login credentials") and leak into the Korean UI. Wrap with a Korean-friendly mapper.

- **F3 — `Platform.isPad` cast is not a real API** (`social-auth.ts:77, 174`): `(Platform as { isPad?: boolean }).isPad` always resolves to `undefined` on React Native — `Platform.isPad` is iOS-native only (via `Platform.constants`). iPad branch (`state: 'apple-auth'`, `FULL_SCREEN` presentation) **never fires**. Use `Platform.OS === 'ios' && Platform.isPad` requires `Platform.isPad` import from `react-native` — but RN's `Platform` does not expose `isPad` directly; need `DeviceInfo` or `PlatformIOSStatic` cast. This silently neutralizes the P7-B1 iPad fix. **High priority bug.**

- **F4 — Apple HIG non-compliance** (`apple-auth-button.tsx`): delegates to `SocialAuthPillButton` instead of `AppleAuthentication.AppleAuthenticationButton`. Apple requires the official button component for App Store submission if `expo-apple-authentication` is used. Risk: 2.5.1 rejection.

- **F5 — `isAuthCallbackUrl` false-positive** (`auth-session.ts:13-25`): returns true for any URL containing `code=` (e.g., `https://example.com/?code=SOMETHING` in-app webview). `exchangeCodeForSession` on an unrelated code throws. Tighten to host+scheme check only.

- **F6 — Email trim asymmetry** (`email-auth-screen.tsx:64-65`): sign-up trims email, but password is not trimmed. If user typed leading/trailing whitespace in password it silently fails with generic error. Consider clarifying or disallowing.

- **F7 — Phone OTP timer not cleared on unmount path from success** (`phone-auth-screen.tsx:130`): `handleVerifyOtp` calls `clearTimer()` but if the user navigates away before verify completes, the cleanup return of the `useEffect` at line 78 does clear it — OK. However `startTimer` calls `clearTimer()` first but `remainingSeconds` is set before `setInterval` assignment; a rapid double-tap of "다시 받기" could spawn an orphan interval if `isLoading` guard is bypassed by React 18 StrictMode (dev only). Minor.

- **F8 — `markAuthComplete` race** (`app-bootstrap-provider.tsx:407-413`): `authCompleted: Boolean(session)` uses closure-captured `session` which may still be null at the moment the email/phone screen calls `markAuthComplete()` immediately after `router.replace('/auth/callback')`. The screen awaits nothing between success and navigation, so `onAuthStateChange` hasn't fired yet. On callback screen the second `markAuthComplete` runs after session is ready, so the flow recovers — but the first call writes `authCompleted:false`, which can briefly toggle the gate state. Low impact, consider removing the redundant early call in `email-auth-screen.tsx:74` / `phone-auth-screen.tsx:132`.

- **F9 — Missing `await` on `setPendingChatFortuneType`** (`app-bootstrap-provider.tsx:198`): actually present; OK.

- **F10 — `Linking.addEventListener` before `bootstrap()` is correct** (app-bootstrap-provider.tsx:301-317) — this is the recent P7-B1 fix. Verified: listener attached synchronously before `void bootstrap()` so no event loss.

---

## 5. Sign-off

- [ ] All sections A–G pass on iPhone 15 (iOS 17).
- [ ] Sections A, B, C, F pass on iPad (iPadOS 17).
- [ ] Section A7 passes on iOS 14 device or simulator.
- [ ] Static findings F1, F3, F4 triaged (created/linked to JIRA).

Word count: ~1180.
