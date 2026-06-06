# UX Button Walker QA Report

## Verdict
- **NO-GO for monetization/auth continuation until P1 is fixed.**
- 핵심 리스크: Premium/top-up에서 “로그인하고 계속하기”를 눌러 이메일/전화 인증을 선택하면 원래 결제/충전 경로로 복귀하지 못하고 `/chat` 또는 온보딩으로 빠질 수 있다.

## Scope / Method
- Checklist: `docs/audits/2026-06-ondo-full-audit/checklists/08-ux-button-walker.md`
- App scope: `apps/mobile-rn` Expo Router / React Native screens and relevant Supabase legal page function.
- Reviewed surfaces: Splash, Welcome, Signup/Login, Profile setup/onboarding continuation, Chat entry/list route references, Character profile route references, Fortune route/result references, Premium/token top-up, Settings/Profile, Policy pages, Account deletion, Notification settings, App Store metadata support/privacy/terms links.
- Per user request, **code was not modified**. This report file is the only written artifact.
- Runtime limitation: this pass is static code/document/link QA plus HTTP URL checks. iOS Simulator/real-device button walking was not executed, so simulator success is not claimed as real-device success.

## Repo State Freeze
```text
$ git status --short --branch
## master...origin/master
 M CLAUDE.md
 M apps/mobile-rn/package.json
 M package.json
 M pnpm-lock.yaml
?? .githooks/
?? apps/mobile-rn/scripts/
?? docs/audits/
?? docs/development/local-native-ios-testing.md
?? scripts/verify-rn-native-patch.sh

$ git diff --stat
 CLAUDE.md                   |    8 +
 apps/mobile-rn/package.json |   12 +
 package.json                |   13 +-
 pnpm-lock.yaml              | 1516 ++++++++++++++++++++++++++++++++++++-------
 4 files changed, 1311 insertions(+), 238 deletions(-)

$ git log --oneline origin/master..HEAD
# no output
```

## P0
- No P0 found in this static UX Button Walker pass.

## P1

### P1-1. Email/phone auth drops `returnTo`, breaking “login and continue” from Premium/top-up
- **Severity:** P1 — 주요 전환/매출 손상.
- **Screen path:** `/premium?intent=top-up` → `/signup?returnTo=/premium?intent=top-up` → `/auth/email` or `/auth/phone` → `/auth/callback`
- **Expected:** 사용자가 Premium/top-up에서 로그인한 뒤 원래 Premium/top-up CTA 경로로 돌아온다.
- **Actual from code path:** Apple/Google social auth에는 `returnTo`가 전달되지만 이메일/전화 인증으로 들어가면 `returnTo`가 사라지고 callback 기본값 `/chat` 또는 온보딩 경로로 이동한다.
- **Evidence:**
  - Premium guest CTA preserves intent into signup:
    - `apps/mobile-rn/src/screens/premium-screen.tsx:363-367` → `/signup` with `returnTo: '/premium?intent=top-up'`
    - `apps/mobile-rn/src/screens/premium-screen.tsx:822-826` → `/signup` with `returnTo: '/premium'`
  - Signup computes and preserves `returnTo` for social auth:
    - `apps/mobile-rn/src/screens/signup-screen.tsx:107` computes `returnTo`
    - `apps/mobile-rn/src/screens/signup-screen.tsx:133` passes `returnTo` into `startSocialAuth(providerId, returnTo)`
  - But email/phone entry points drop it:
    - `apps/mobile-rn/src/screens/signup-screen.tsx:356` → `router.push('/auth/email')`
    - `apps/mobile-rn/src/screens/signup-screen.tsx:410` → `router.push('/auth/phone')`
  - Email/phone success sends callback with no params:
    - `apps/mobile-rn/src/screens/email-auth-screen.tsx:73-75` → `router.replace('/auth/callback')`
    - `apps/mobile-rn/src/screens/phone-auth-screen.tsx:130-133` → `router.replace('/auth/callback')`
  - Callback default if missing returnTo:
    - `apps/mobile-rn/src/screens/auth-callback-screen.tsx:19-22` normalizes missing/invalid `returnTo` to `/chat`
    - `apps/mobile-rn/src/screens/auth-callback-screen.tsx:117-122` routes to onboarding or `callbackMeta.returnTo`
- **Reproduction steps:**
  1. Log out or clean-install state.
  2. Open `/premium?intent=top-up`.
  3. Tap `로그인하고 계속하기`.
  4. Expand `다른 방법으로 시작`.
  5. Choose `이메일로 시작` or `전화번호로 시작` and complete auth.
  6. Observe that callback lacks the original premium/top-up return target.
- **Recommended fix:**
  - Pass `returnTo` into `/auth/email` and `/auth/phone`, e.g. `router.push({ pathname: '/auth/email', params: { returnTo } })`.
  - Read `returnTo` in email/phone auth screens and call `router.replace({ pathname: '/auth/callback', params: { returnTo } })` after successful auth.
  - Preserve query strings like `/premium?intent=top-up`, not just pathname.
- **Validation:**
  - Run three auth flows from `/premium?intent=top-up`: Apple/Google, email, phone.
  - After successful auth, assert final route returns to `/premium?intent=top-up` or to onboarding only if onboarding is intentionally required and then resumes the same top-up intent.
  - Add route-flow unit or integration test around `returnTo` propagation.

## P2

### P2-1. New-user auth callback overrides premium/top-up return with onboarding and does not preserve pending purchase intent
- **Severity:** P2 — 특정 monetization path interruption; P1과 결합하면 전환 손실 확대.
- **Screen path:** `/premium?intent=top-up` → `/signup` → social auth → `/auth/callback`
- **Expected:** 신규 가입자에게 온보딩이 필요하더라도 “충전/구독 계속하기” intent가 온보딩 완료 후 복원된다.
- **Actual from code path:** `firstRunHandoffSeen`이 false이면 `callbackMeta.returnTo`보다 `/onboarding/name`이 우선된다.
- **Evidence:**
  - `apps/mobile-rn/src/screens/auth-callback-screen.tsx:112-121`
    - `needsOnboardingFlow = !onboardingProgress.firstRunHandoffSeen`
    - `destination = needsOnboardingFlow ? '/onboarding/name' : ...callbackMeta.returnTo`
- **Reproduction steps:**
  1. Clean install / first-run state.
  2. Open `/premium?intent=top-up`.
  3. Tap `로그인하고 계속하기` and complete Apple/Google auth.
  4. App enters onboarding before honoring Premium/top-up return target.
  5. Verify whether selected top-up context is restored after onboarding; static code does not show a pending-return handoff here.
- **Recommended fix:**
  - Persist pending `returnTo` through onboarding, e.g. auth callback writes pending destination to onboarding provider/route params.
  - After required onboarding completion, route to pending `returnTo` instead of default `/chat`.
- **Validation:**
  - New-user social auth from `/premium?intent=top-up` should either return immediately after auth or return after onboarding completion with top-up intent intact.
  - Test clean install + returning user separately.

### P2-2. Notification “아침 알림 시간” is visible UI but local-only and not saved/synced
- **Severity:** P2 — 설정 버튼은 동작하는 것처럼 보이나 실제 효과가 없다.
- **Screen path:** `/profile/notifications`
- **Expected:** 사용자가 알림 시간을 선택하고 저장하면 로컬 재진입과 백엔드 푸시 설정 모두에 반영된다.
- **Actual from code path:** selected time is component-local state only; save persists only boolean preferences.
- **Evidence:**
  - Local-only state/default:
    - `apps/mobile-rn/src/screens/profile-notifications-screen.tsx:87-88` → `alarmTimeIndex` default index 2 = 07:00
  - Tap only cycles local state:
    - `apps/mobile-rn/src/screens/profile-notifications-screen.tsx:205-209`
  - Save writes booleans only:
    - `apps/mobile-rn/src/screens/profile-notifications-screen.tsx:136-137` → `saveNotifications(preferences)` and `pushPreferencesToBackend(preferences)`
  - Backend sync payload has only boolean fields:
    - `apps/mobile-rn/src/screens/profile-notifications-screen.tsx:151-160` → `enabled`, `dailyFortune`, `characterDm`, `promotion`, `tokenAlert`; no hour/minute/timezone.
- **Reproduction steps:**
  1. Open `/profile/notifications`.
  2. Tap morning alarm time until it shows e.g. `08:30`.
  3. Tap `저장`.
  4. Navigate away and back.
  5. Expected: `08:30`; actual by code: default `07:00` after remount.
- **Recommended fix:**
  - Either remove/disable this selector until supported, or add durable `dailyFortuneTime` / `hour` / `minute` / timezone fields to local state and backend preferences.
  - Make dispatchers consume the same saved field.
- **Validation:**
  - Change time, save, navigate away/back; value persists.
  - Inspect backend `user_notification_preferences` row or sync payload and verify selected time is included.

### P2-3. Notification save has no loading/success/error UI; backend sync failure is silent
- **Severity:** P2 — 네트워크/서버 실패 후 버튼 상태와 사용자 인지가 불명확.
- **Screen path:** `/profile/notifications`
- **Expected:** save button disables while saving, shows success or actionable failure, and does not imply backend sync succeeded when it failed.
- **Actual from code path:** save button always remains tappable; backend sync failures only log to console.
- **Evidence:**
  - Save button has no disabled/loading state:
    - `apps/mobile-rn/src/screens/profile-notifications-screen.tsx:242-249`
  - Backend sync failure only warns:
    - `apps/mobile-rn/src/screens/profile-notifications-screen.tsx:161-165` → `console.warn('[notifications] preferences 백엔드 동기화 실패:', result.reason)`
- **Reproduction steps:**
  1. Open `/profile/notifications`.
  2. Toggle one or more preferences.
  3. Simulate network/backend failure for `syncNotificationPreferencesForSignedInUser`.
  4. Tap `저장` repeatedly.
  5. Observe no visible failed/saving state by code; only console warning.
- **Recommended fix:**
  - Add `isSaving` / `saveMessage` state; disable save during in-flight operation.
  - Surface backend sync errors with alert/toast and retry option.
  - If local save succeeds but backend fails, display partial-save state explicitly.
- **Validation:**
  - Mock backend failure; UI shows failure and button recovers.
  - Rapid-tap save; only one backend sync call is in flight.

### P2-4. App Store Support URL lands on legal index with no support/contact CTA
- **Severity:** P2 — App Review/support path friction.
- **Screen/link path:** App Store metadata `Support URL`
- **Expected:** Support URL exposes contact/support information directly.
- **Actual:** Metadata support URL points to Supabase legal index, whose root page only links Privacy Policy and Terms of Service.
- **Evidence:**
  - Metadata:
    - `apps/mobile-rn/appstore-metadata.md:15-18` → Privacy/Terms/Support URLs; support URL is `/legal-pages`
    - `apps/mobile-rn/appstore-metadata.md:64-66` repeats Terms/Privacy/Support
  - Supabase legal index root:
    - `supabase/functions/legal-pages/index.ts:136-147` renders only two links: `개인정보처리방침`, `이용약관`
  - In-app business info has support email as static legal text, not a tappable support row:
    - `apps/mobile-rn/app/business-info.tsx:28-33`
  - HTTP check:
    - `https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages` → `200 text/plain` in this environment, but page content by source is legal index only.
- **Reproduction steps:**
  1. Open App Store Support URL: `https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages`.
  2. Observe legal links only; no obvious support email/contact/help/account-deletion guidance.
- **Recommended fix:**
  - Point metadata support to a dedicated support page, or update legal index to include support email, contact CTA, response SLA, account deletion route, and privacy/terms links.
  - Add an in-app `문의하기` / `고객센터` row in Profile → 정보 matching metadata support.
- **Validation:**
  - Browser-open Support URL: support contact visible without extra guessing.
  - In-app Profile → 정보 has a tappable support/contact affordance.

### P2-5. External legal pages used by App Store/Premium differ from newer in-app legal text
- **Severity:** P2 — legal/policy consistency and App Review trust risk.
- **Screen/link path:** `/premium` subscription legal links; App Store metadata privacy/terms URLs; in-app `/privacy-policy`, `/terms-of-service`
- **Expected:** App Store metadata, Premium purchase disclosures, and in-app policy pages point to the same canonical terms/privacy content.
- **Actual:** external Supabase pages are older/simpler than in-app LegalScreen routes.
- **Evidence:**
  - App Store metadata points to Supabase legal pages:
    - `apps/mobile-rn/appstore-metadata.md:15-16`, `apps/mobile-rn/appstore-metadata.md:64-65`
  - Premium subscription legal links open Supabase pages:
    - `apps/mobile-rn/src/screens/premium-screen.tsx:805-815`
  - Supabase privacy/terms effective date and simplified content:
    - `supabase/functions/legal-pages/index.ts:3-77`
    - `supabase/functions/legal-pages/index.ts:40-42` → 시행일 2026년 4월 11일
  - In-app legal routes are newer/more complete:
    - `apps/mobile-rn/app/privacy-policy.tsx:3-14` → 최종 개정일 2026-04-23, App Privacy mapping summary
    - `apps/mobile-rn/app/terms-of-service.tsx:3-14` → 최종 개정일 2026-04-23, subscription/UGC guideline context
- **Reproduction steps:**
  1. Open in-app `/privacy-policy` and `/terms-of-service`.
  2. Open metadata/Premium URLs for privacy/terms.
  3. Compare dates and sections; content differs.
- **Recommended fix:**
  - Pick one canonical legal source. Either generate Supabase legal pages from the same content as app routes, or make in-app Premium links route to `/terms-of-service` and `/privacy-policy` while metadata pages mirror those texts externally.
- **Validation:**
  - Compare all legal entry points for title, effective date, subscription/refund terms, privacy contact, support contact, UGC/moderation language.
  - HTTP check must return `200 text/html; charset=utf-8` (currently terminal observed `text/plain` from Supabase response headers).

### P2-6. Welcome final CTA can be duplicate-tapped while async finish writes state and replaces route
- **Severity:** P2 — duplicate action/routing race on first-run UX.
- **Screen path:** `/welcome`
- **Expected:** CTA is disabled or guarded once final transition begins.
- **Actual from code path:** final step calls async `finish()` without an in-flight guard; CTA `Pressable` has no disabled/loading state.
- **Evidence:**
  - `apps/mobile-rn/src/screens/welcome-screen.tsx:115-118` → `finish()` awaits `markWelcomeSeen()` then `router.replace(...)`
  - `apps/mobile-rn/src/screens/welcome-screen.tsx:120-126` → final CTA calls `void finish()`
  - `apps/mobile-rn/src/screens/welcome-screen.tsx:719-744` → `Pressable` with `onPress={onPress}` only; no disabled/loading/in-flight ref.
- **Reproduction steps:**
  1. Navigate through welcome to final screen.
  2. Rapid-tap final CTA.
  3. Multiple `finish()` calls can queue before route replacement completes.
- **Recommended fix:**
  - Add `isFinishing` state or ref; ignore subsequent taps and show stable loading/disabled state.
- **Validation:**
  - Instrument or spy `markWelcomeSeen`; rapid final taps should call it once and perform one `router.replace`.

### P2-7. Premium legal/footer text links have weak accessibility/error handling/hit-area semantics
- **Severity:** P2 — App Review legal disclosure and accessibility quality risk.
- **Screen path:** `/premium`, `/premium?intent=top-up`
- **Expected:** legal/footer links are discoverable as links/buttons, have adequate hit area, and show failure feedback if URL opening fails.
- **Actual from code path:** several small text `Pressable`s lack role/label/hitSlop; legal external URLs are opened without try/catch.
- **Evidence:**
  - Top-up footer `구매 복원` bare text pressable:
    - `apps/mobile-rn/src/screens/premium-screen.tsx:389-397`
  - Top-up footer `구독 상품도 보기` bare text pressable:
    - `apps/mobile-rn/src/screens/premium-screen.tsx:399-403`
  - Subscription legal links open URLs directly; no role/label/hitSlop/error handling:
    - `apps/mobile-rn/src/screens/premium-screen.tsx:805-815`
  - HTTP URL checks did return 200 for the current links:
    - `.../privacy-policy` → `200 text/plain`
    - `.../terms-of-service` → `200 text/plain`
- **Reproduction steps:**
  1. Open `/premium?intent=top-up`; inspect footer controls with VoiceOver and touch target lens.
  2. Open `/premium`, select subscription, use VoiceOver on legal links.
  3. Mock `Linking.openURL` rejection; user receives no visible error by code.
- **Recommended fix:**
  - Add `accessibilityRole="button"`/`"link"`, explicit labels, `accessibilityState`, and `hitSlop` or minHeight 44 to small text controls.
  - Wrap external opens in shared `openExternalUrl` helper with `try/catch`, captureError, and alert/fallback route.
- **Validation:**
  - VoiceOver announces controls as buttons/links with meaningful names.
  - Mock URL open failure and verify recovery alert.
  - Tap target area is at least 44pt where practical.

## P3

### P3-1. Bare Pressable accessibility coverage is inconsistent across important screens
- **Severity:** P3 — polish/accessibility sweep.
- **Affected paths:** Welcome, Signup consent rows, Profile settings/model controls, Account deletion reasons, Chat surface controls, Fortune result primitives.
- **Evidence sample:** automated static scan found many `Pressable` blocks with nearby `onPress` and no nearby `accessibilityLabel`. Examples:
  - `apps/mobile-rn/src/screens/welcome-screen.tsx:719-744` — welcome CTA has no explicit `accessibilityRole`/label.
  - `apps/mobile-rn/src/screens/signup-screen.tsx:481-509` — consent row checkbox has role/state but no explicit label; screen reader may rely on nested text only.
  - `apps/mobile-rn/src/screens/profile-screen.tsx:469-489`, `502-504`, `537-545`, `562-571` — on-device AI download/cancel/retry controls lack explicit labels/roles.
  - `apps/mobile-rn/src/screens/profile-screen.tsx:769-790` — logout/account deletion text links lack explicit role/label.
  - `apps/mobile-rn/src/screens/account-deletion-screen.tsx:114-122` — deletion reason radios have role/state but no label.
  - `apps/mobile-rn/src/features/fortune-results/primitives/term-info-sheet.tsx:470`, `480`, `509` — sheet/dismiss/term controls need semantics review.
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` static scan flagged multiple controls at lines `474`, `685`, `767`, `1796`, `2119`, `2150`, `2495`, `2503`, `2518`, `2594`, `2614`, `2634`, `2654`, `2921`, `3089`, `3375`, `3456`.
- **Recommended fix:**
  - Define a checklist for all non-`PrimaryButton` pressables: `accessibilityRole`, explicit label, state, hitSlop/minHeight, disabled/loading behavior.
  - Prioritize Profile/Premium/Signup/Account deletion/Chat composer before decorative result controls.
- **Validation:**
  - Manual VoiceOver pass on target checklist screens.
  - Add lightweight lint/test script that reports bare `Pressable` with `onPress` and no role/label exceptions list.

### P3-2. Account deletion route is directly accessible when logged out and fails generically
- **Severity:** P3 — edge/deeplink UX; not a main UI route for logged-out users but can strand deep-linked users.
- **Screen path:** `/account-deletion`
- **Expected:** logged-out users are redirected to login or told clearly that login is required.
- **Actual from code path:** screen does not gate on `session`; delete attempts invoke Edge Function and surface generic failure.
- **Evidence:**
  - Route directly maps to screen:
    - `apps/mobile-rn/app/account-deletion.tsx:1-5`
  - Screen calls `useAppBootstrap()` but does not read/check `session`:
    - `apps/mobile-rn/src/screens/account-deletion-screen.tsx:24-31`
  - Delete invokes `delete-account` and generic failure:
    - `apps/mobile-rn/src/screens/account-deletion-screen.tsx:62-72`
- **Reproduction steps:**
  1. Open `/account-deletion` while logged out.
  2. Type `삭제`.
  3. Tap `계정 영구 삭제`.
  4. Expected: login required / redirect. Actual by code: generic failure if Edge rejects no-auth request.
- **Recommended fix:**
  - Add session guard: if no session, show auth-required card or redirect to `/signup?returnTo=/account-deletion`.
- **Validation:**
  - Deep-link `/account-deletion` logged out and logged in.
  - Logged-out path should not show an active destructive CTA.

### P3-3. Static route scan found no broken literal routes, but special/group routes need runtime smoke validation
- **Severity:** P3 — validation note.
- **Evidence:**
  - Local route enumeration found valid app routes including `/chat`, `/premium`, `/signup`, `/profile/*`, `/friends/new/*`, `/result/[resultKind]`, `/privacy-policy`, `/terms-of-service`, `/account-deletion`, `/widgets`.
  - Static script result: `MISSING_LITERAL_ROUTES` had no output.
  - Notable non-standard/special references:
    - `apps/mobile-rn/app/fortune.tsx:78` redirects to `'/+not-found'` for invalid type.
    - `apps/mobile-rn/app/chat.tsx` and `apps/mobile-rn/app/widget.tsx` use grouped route pathnames like `/(tabs)/chat`.
- **Recommended fix:**
  - No static route fix indicated. Runtime smoke invalid `/fortune` params, `/chat` wrapper, `/widget` wrapper.
- **Validation:**
  - Open all target checklist routes in iOS Simulator and verify no unexpected 404 or blank screen.

## Evidence

### Commands / Logs
```text
$ python route scan
ROUTES ['/', '/account-deletion', '/auth/callback', '/auth/email', '/auth/phone', '/business-info', '/character/[id]', '/chat', '/disclaimer', '/eula', '/fortune', '/friends/new', '/friends/new/avatar', '/friends/new/basic', '/friends/new/creating', '/friends/new/persona', '/friends/new/review', '/friends/new/story', '/home', '/onboarding', '/onboarding/birth', '/onboarding/mbti', '/onboarding/name', '/onboarding/relationship', '/onboarding/tone', '/onboarding/topics', '/onboarding/toss-style', '/open-source-licenses', '/premium', '/privacy-policy', '/profile', '/profile/dev-tools', '/profile/edit', '/profile/my-fortunes', '/profile/notifications', '/profile/relationships', '/profile/saju-summary', '/result/[resultKind]', '/signup', '/splash', '/terms-of-service', '/trend', '/welcome', '/widget', '/widgets']
MISSING_LITERAL_ROUTES
# no output
```

```text
$ HTTP link check
https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/privacy-policy 200 text/plain
https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/terms-of-service 200 text/plain
https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages 200 text/plain
https://apps.apple.com/account/subscriptions 200 text/html;charset=UTF-8 redirected to https://appleid.apple.com/
https://play.google.com/store/account/subscriptions 200 text/html; charset=utf-8 redirected to Google sign-in
```

### DB rows
- No DB query was executed in this pass. The checklist items inspected here were code/document/link-flow issues. Notification backend persistence should be verified in a follow-up runtime test by inspecting `user_notification_preferences` or the exact Supabase function payload after saving notification settings.

### Screenshots / Simulator
- No screenshots captured and no simulator run performed. Static evidence is from file paths/lines and HTTP checks.

## Recommended Fix Order
1. **P1:** Preserve `returnTo` through email/phone auth and callback; validate Premium/top-up auth continuation for social/email/phone.
2. **P2:** Preserve pending Premium/top-up intent through required new-user onboarding.
3. **P2:** Decide whether Notification alarm time is real; either persist/sync it or remove/disable it.
4. **P2:** Add notification save in-flight state and visible backend failure recovery.
5. **P2:** Make App Store Support URL and in-app support/contact affordance explicit.
6. **P2:** Unify external Supabase legal pages with in-app legal text; then harden Premium legal links with accessibility/error handling.
7. **P2/P3:** Add duplicate-tap guard to Welcome final CTA and sweep bare `Pressable` accessibility/hit area on high-impact screens.
8. **P3:** Runtime-smoke all target routes in iOS Simulator; real-device only for purchase/subscription/deep-link/notification acceptance.

## Open Questions
- Should Premium/top-up auth intent override onboarding, or should onboarding be mandatory but resume the pending Premium/top-up route afterward?
- Is “아침 알림 시간” meant to control actual proactive/daily notification dispatch time now, or should it be hidden until backend scheduling supports it?
- Should the canonical legal source live in Supabase external pages, app LegalScreen routes, or a shared generated artifact used by both?
