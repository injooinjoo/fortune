# iOS Review Audit 06 — UI/UX + Accessibility

Scope: `apps/mobile-rn/` (Expo RN app "온도" v1.0.9). Static code audit, no
simulator run. Checks map to the reviewer-visible criteria A–K.

## Severity summary

| Sev | Count |
|-----|-------|
| CRITICAL | 3 |
| WARNING | 9 |
| INFO | 7 |

---

## CRITICAL findings

### C1. Dark-mode mismatch with `userInterfaceStyle: 'automatic'`
- `apps/mobile-rn/app.config.ts:93` declares `userInterfaceStyle: 'automatic'`.
- `apps/mobile-rn/src/lib/theme.ts:4` hardcodes `createFortuneTheme('dark')`.
- `apps/mobile-rn/app/_layout.tsx:62` hardcodes `<StatusBar style="light" />`.
- Effect: on a reviewer device set to Light mode, the declared light variant is
  never actually rendered. All screens stay dark-on-dark. While this looks
  "fine" visually (no contrast bug), the `Info.plist` promises it adapts.
  Reviewers sometimes flag this as dishonest manifest. Fix: either set
  `userInterfaceStyle: 'dark'` (truthful) or wire the theme through
  `useColorScheme()`.

### C2. Dev-only welcome gate is forced in production
- `apps/mobile-rn/src/screens/splash-screen.tsx:13`
  `const FORCE_WELCOME_FOR_DEV = true;`
- Regardless of gate / `welcome-seen` flag, every cold start replaces to
  `/welcome` (7-scene carousel). Reviewers using the test account will still
  see the carousel on every launch until they tap through. Should be `false`
  before App Store submission.

### C3. Test-account allowlist does not include the reviewer email
- `apps/mobile-rn/src/lib/test-accounts.ts:2` — `TEST_ACCOUNT_EMAILS` contains
  only `ink595@g.harvard.edu`. Previous review cycle used
  `test@zpzg.com`. If reviewer logs in with that email the Factory-Reset /
  test-tools card (`profile-screen.tsx:781`) is hidden, and any other
  reviewer-only affordance that keys off `isTestAccount` is off. Add the
  reviewer email (or disable the gate for App Store reviewer flow).

---

## WARNING findings

### W1. `SocialAuthPillButton` uses hardcoded `#FFFFFF` pill background
- Referenced at `signup-screen.tsx:215,262` (email & phone CTAs). Even though
  the outer surface is dark, the pill is pure white with `#111111` text.
  Works in dark mode but ignores theme tokens — if C1 is fixed and light
  mode enabled, this would invert improperly.

### W2. Onboarding text input not keyboard-avoiding
- `apps/mobile-rn/src/screens/onboarding-screen.tsx:323-335` calls `<Screen>`
  without the `keyboardAvoiding` prop.
- `onboarding-screen.tsx:655` renders a `TextInput` (표시 이름) plus the
  `DateInput` that also triggers numeric keyboard. On small iPhones the
  keyboard covers the "관심사 선택으로 이동" CTA. Add `keyboardAvoiding`.

### W3. Interactive icon buttons below 44pt
- `chat-surface.tsx:93-117` (`HeaderActionButton`): `height: 36, width: 36`.
- `components/inline-calendar.tsx:10` `CELL_SIZE = 36` — every day cell in the
  birthdate picker is 36×36, below Apple HIG 44pt minimum.
- `components/selectable-chip.tsx:55` / `components/composer.tsx:98,118`
  height 36–40.
- HIG requires ≥44×44pt for reliable touch. A reviewer with an accessibility
  audit tool will surface these. Add `hitSlop` (e.g. `hitSlop={8}`) at minimum,
  or raise dimensions.

### W4. `useLocalSearchParams` value cast to `Href` without runtime guard
- `signup-screen.tsx:73,114` casts `returnTo as Href`. If a malformed deep
  link arrives the app may push an invalid route and show blank content
  — not blocking, but shows as "blank screen" to reviewers. `normalizeReturnTo`
  only checks leading `/`.

### W5. Edge-runtime fetch has no timeout
- `features/chat-results/edge-runtime.ts` (see `fetchEmbeddedEdgeResultPayload`)
  does not set `AbortController` / timeout for Supabase Edge function calls.
  On a flaky reviewer Wi-Fi the chat result card can spin indefinitely.
  Add a ~20s timeout and a retry CTA in `embedded-result-card.tsx`.

### W6. Chat screen has no visible network-error retry UI
- `screens/chat-screen.tsx` sends AI requests via provider; on failure the
  user message stays but no assistant error bubble with Retry appears
  (searched for `retry`, `재시도` — no assistant error fallback found).
  Reviewers who chat while offline will see a "silent" failure. Add an
  error-variant `ChatShellMessage` + retry pill.

### W7. Hardcoded brand hex in `onboarding-screen` modal + welcome screen
- `welcome-screen.tsx:18-29` defines a local token object `T` with
  `#0B0B10`, `#F5F6FB` etc. instead of `fortuneTheme.colors.*`.
- `onboarding-screen.tsx:341` `backgroundColor: 'rgba(0,0,0,0.6)'` inline.
- Violates project rule ("색상은 `fortuneTheme.colors.*`"). Low user-visible
  risk but maintenance debt and will hurt if C1 is ever addressed.

### W8. Splash "escape" tap has no `accessibilityLabel`
- `splash-screen.tsx:196-217` Pressable shows `계속 →` but no a11y label or
  role. VoiceOver users after 4s escape will just hear "계속" without button
  context.

### W9. `authMessage` error surfacing in signup is transient `AppText`
- `signup-screen.tsx:126-130` renders error as bodySmall text with no
  `accessibilityLiveRegion` / `accessibilityRole="alert"`. Screen readers
  won't announce failed Apple/Google auth. Add `accessibilityLiveRegion=
  "polite"`.

---

## INFO findings

### I1. Safe-area coverage is good via `<Screen>`
- `components/screen.tsx` wraps `SafeAreaView` with correct edges toggle for
  keyboard-avoiding mode. Every result screen uses `FortuneResultLayout` →
  `Screen`. Splash and Welcome use `SafeAreaView edges={['top','bottom']}`
  directly. No top-edge bleed found.

### I2. Splash + first-launch path is safe
- `app/index.tsx` redirects to `/splash`; `splash-screen.tsx:18` auto-advances
  after 800ms and shows `계속 →` fallback after 4s (`SLOW_NETWORK_ESCAPE_MS`).
  No infinite loop risk even on offline.
- `app-bootstrap-provider.tsx` has `finally { setStatus('ready') }` so the
  gate always unblocks.

### I3. Sign-in — Apple Sign-In is first
- `signup-screen.tsx:27-38` has Apple at position 0, Google at 1. Uses
  `AppleAuthButton` (native Apple button). Korean copy ("애플 로그인",
  "iPhone에서 가장 자연스럽게 인증…") clearly explains scope. Meets 4.8
  Sign-in requirement.

### I4. Paywall meets 3.1.2 checklist (mostly)
- `premium-screen.tsx:302-323` — subscription title + 월 price + period.
- `premium-screen.tsx:386-410` — auto-renewal disclosure + Terms + Privacy
  Policy links (via Supabase legal-pages fn).
- `premium-screen.tsx:449-454` — "구매 복원" PrimaryButton.
- Note: Privacy/Terms links go to a **Supabase functions URL**
  (`https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/…`).
  Functional but not a marketing domain — reviewers sometimes want these on
  the app's website. Consider moving to `ondo.beyond.kr` or similar.

### I5. Entry path for reviewer — gated correctly but no bypass
- Onboarding disclaimer modal (`onboarding-screen.tsx:332-367`) requires one
  tap before content. Not blocking.
- Reviewer doesn't need the test-account gate to complete happy path; just to
  see the "factory reset" tool (which is dev-only anyway).

### I6. Copy quality
- No leftover `TODO` / `lorem` / `asdf` visible in rendered Korean strings.
- `chat-surface.tsx:248` has a commented-out 호기심 탭 TODO — internal only.
- `signup-screen.tsx:41` 카카오/네이버 TODO — internal, the disabled providers
  are never shown. OK.

### I7. Orientation + iPad
- `app.config.ts:90` `orientation: 'portrait'`, `supportsTablet: true`.
- `components/screen.tsx:56` clamps content at `maxWidth: 600, alignSelf:
  'center'`, which prevents the ugly "stretched form field" look on iPad.
- No fixed `width: 375` found in shared components. Minor: `maxWidth: 360`
  appears for centered modal cards which is fine.

---

## Files audited (summary)

- Tab routes: `app/(tabs)/{_layout,chat}.tsx`, `app/(tabs)/profile/*`
- Redirects: `app/{index,home,fortune,trend,chat,welcome,splash}.tsx`
- Screens: 20 files in `src/screens/` — the high-traffic ones (`splash`,
  `welcome`, `onboarding`, `signup`, `chat`, `premium`, `profile`,
  `email-auth`, `phone-auth`, `friend-creation`, `legal`) read in depth.
- Fortune results: 37 hero + 13 screen + primitives; all use shared
  `FortuneResultLayout` → `<Screen>` so safe-area is uniform.
- Chat surface / survey / results: 3 main files + widgets. Keyboard-avoiding
  correctly threaded via `<Screen keyboardAvoiding>` in chat-screen.
- Components: 25 in `src/components/` — theme-aware via `fortuneTheme` with
  the exception of hardcoded `#FFFFFF` pills in `social-auth-pill-button.tsx`.

## Recommended blockers to address before resubmission

1. **C2** — flip `FORCE_WELCOME_FOR_DEV` to `false` (or gate it on `__DEV__`).
2. **C3** — add the reviewer account email to `TEST_ACCOUNT_EMAILS`.
3. **C1** — either set `userInterfaceStyle: 'dark'` in `app.config.ts` to
   match reality, or wire `useColorScheme()` into `theme.ts`.
4. **W2** — add `keyboardAvoiding` to `onboarding-screen.tsx`.
5. **W5/W6** — add timeout + retry CTA for edge function chat results.
