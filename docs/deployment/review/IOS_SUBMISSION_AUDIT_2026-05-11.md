# iOS App Review Submission Audit — 2026-05-11

## Verdict

**NO-GO for immediate upload/submission.**

I did not start a new EAS production build, upload, or App Store Connect submission because the release candidate is not currently problem-free. The blockers below are grounded in repository evidence, local validation output, EAS state, and an independent OpenClaw/Claude Opus 4.7 release review.

## Scope

- App: 온도 (Ondo)
- Bundle ID: `com.beyond.fortune`
- ASC App ID: `6749496180`
- EAS project ID: `f7a724ea-b46e-494a-b83c-94e7a6fec02a`
- Local repo: `/Users/injoo/Desktop/Dev/fortune`
- RN app: `apps/mobile-rn`
- Current branch: `master`

## Current repository state

### Git baseline

- `master...origin/master [ahead 3]`
- Ahead commits:
  - `20060d3a fix: add cancellable Haneul fortune flow`
  - `3fac91f5 fix: render fortune trend as line chart`
  - `b2686c48 fix: lift haneul survey option buttons`

### Dirty working tree

Modified tracked files:

- `apps/mobile-rn/app/onboarding/topics.tsx`
- `apps/mobile-rn/src/features/chat-results/on-device-fortune.ts`
- `apps/mobile-rn/src/lib/message-store.ts`
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `supabase/functions/_shared/character_message_helper.ts`
- `supabase/functions/_shared/notification_push.ts`
- `supabase/functions/character-chat/index.ts`
- `supabase/functions/generate-character-proactive-image/index.ts`
- `supabase/functions/proactive-message-dispatch/index.ts`

Untracked release/QA/test assets also exist, including:

- `.hermes/plans/*`
- `.hermes/reports/`
- `artifacts/qa/`
- `docs/qa/haneul-fortune-e2e-*.md`
- `scripts/qa/`
- `supabase/functions/_shared/character_user_preferences*.ts`
- `supabase/functions/_shared/notification_push_test.ts`
- `supabase/functions/_shared/proactive_message_rules*.ts`

This means there is no frozen, reproducible SHA for a new App Store submission candidate.

## Validation already run

| Check | Result | Evidence |
|---|---:|---|
| `npm run rn:typecheck` | PASS | product-contracts, design-tokens, mobile-rn TypeScript completed with exit 0 |
| `npm run rn:test` | PASS | Vitest: 5 files, 20 tests passed |
| `deno check` changed Edge/shared files | PASS | `character-chat`, `proactive-message-dispatch`, `generate-character-proactive-image`, shared helpers checked |
| `deno test` new shared tests | PASS | 10 tests passed |
| Production Expo config render | PASS with warnings | version/runtime `1.0.14`, bundle `com.beyond.fortune`, production Supabase secrets present |
| Privacy/Terms/Support URLs | PASS | all configured Supabase legal URLs returned HTTP 200 |
| EAS auth | PASS | logged in as `injooinjoo / injooinjoo@gmail.com` |
| `npx expo-doctor` | FAIL | 14/17 checks passed, 3 failed |

## Blockers

### B1 — Existing release decision documents still mark iOS submission as NO-GO

`docs/deployment/review/STORE_REVIEW_MASTER_CHECKLIST.md`, `IOS_REVIEW_EVIDENCE.md`, and `RELEASE_DECISION_LOG.md` still list pending P0/P1 App Review evidence:

- previous App Review rejection path re-verified on a clean-install real iPhone
- IAP success, cancellation, and restore flows captured on device
- iPad review path checked
- optional NAT64 / IPv6-only path if available
- final risk approver sign-off

The repo’s release policy says any pending P0/P1 makes the decision **NO-GO**.

### B2 — No frozen release commit

The repository is ahead of `origin/master` and has a dirty working tree with broad app + Edge Function changes. A store build from this state would be hard to reproduce, audit, or bisect if rejected.

### B3 — `expo-doctor` failed 3 checks

`npx expo-doctor` reported:

1. `@expo/config-plugins` should not be installed directly.
2. Expo SDK expected `@expo/config-plugins ~54.0.4`, but the project has `55.0.8` direct dependency.
3. Expo SDK expected `react-native-worklets 0.5.1`, but the project has `0.8.1`.
4. `react-native-shared-group-preferences` is unmaintained / untested with New Architecture.

The first two are release-relevant because config plugins influence native Info.plist/entitlements/prebuild output. The worklets mismatch is also native/runtime-relevant, not just a JS warning.

### B4 — Existing latest EAS iOS build is not current HEAD

Latest finished EAS iOS STORE build:

- EAS build ID: `24ad5372-113b-4d44-8634-c7227257fccd`
- App version: `1.0.14`
- Build number: `60`
- Git commit: `6faa96f9acbf216f5153d27ca64814a42df4db3a`
- Created: `2026-05-08T05:42:35.563Z`

Current HEAD is `20060d3a`, with many commits after `6faa96f9`. Submitting build #60 would omit later fixes and would not match the current requested release candidate.

## Metadata status

Source file checked: `apps/mobile-rn/appstore-metadata.md`.

Current metadata summary:

- App name: `온도`
- Subtitle: `AI 운세 & 스토리 채팅`
- Bundle ID: `com.beyond.fortune`
- Privacy Policy: `https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/privacy-policy` — HTTP 200
- Terms: `https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/terms-of-service` — HTTP 200
- Support: `https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages` — HTTP 200
- Review notes currently say no login required and demo account not needed.

Metadata is usable as a starting point, but final review notes should be updated only after the RC and evidence are frozen, so the notes can accurately reference the submitted build and any rejection-fix evidence.

## Independent review

OpenClaw using Claude Opus 4.7 independently reviewed the release state and agreed with **NO-GO**. Key independent findings:

- dirty working tree prevents frozen release SHA
- existing decision/evidence docs still list P0/P1 pending items
- `expo-doctor` failures are release-relevant
- real-device evidence is still the biggest App Review rejection risk

## Minimum path to GO

1. Decide the exact release content: either include current dirty changes or cut from a clean stable commit.
2. Fix or explicitly risk-accept `expo-doctor` failures; rerun `npx expo-doctor`.
3. Commit only intended source changes; keep QA artifacts either committed intentionally or ignored; push and verify GitHub Actions.
4. Deploy changed Supabase Edge Functions if the submitted client depends on those changes.
5. Run gates again:
   - `npm run rn:typecheck`
   - `npm run rn:test`
   - relevant `deno check` / `deno test`
   - `npx expo-doctor`
   - production Expo config render
6. Produce real-device evidence for:
   - clean install → guest/main flow → Apple Sign-In path
   - IAP success
   - IAP cancel/error recovery
   - restore purchases
   - iPad review path
7. Update `STORE_REVIEW_MASTER_CHECKLIST.md`, `IOS_REVIEW_EVIDENCE.md`, and `RELEASE_DECISION_LOG.md` from NO-GO to GO with evidence links/paths.
8. Create a new EAS production iOS build from the clean pushed commit.
9. Submit the exact new build to App Store Connect and update review notes with the final RC evidence.

## Commands run during this audit

```bash
git status --short --branch
git log --oneline origin/master..HEAD
git diff --stat
npm run rn:typecheck
npm run rn:test
npx expo config --type public --json
EXPO_PUBLIC_APP_ENV=production EAS_BUILD_PROFILE=production npx expo config --type public --json
npx expo-doctor
deno check supabase/functions/character-chat/index.ts supabase/functions/proactive-message-dispatch/index.ts supabase/functions/generate-character-proactive-image/index.ts supabase/functions/_shared/character_message_helper.ts supabase/functions/_shared/notification_push.ts supabase/functions/_shared/character_user_preferences.ts supabase/functions/_shared/proactive_message_rules.ts
deno test supabase/functions/_shared/character_user_preferences_test.ts supabase/functions/_shared/notification_push_test.ts supabase/functions/_shared/proactive_message_rules_test.ts
eas env:list --environment production
eas build:list --platform ios --limit 5 --json
```


## 2026-05-11 Remediation Update — Expo Doctor / RN Directory Risk Acceptance

### Dependency blockers remediated locally
- Removed direct `@expo/config-plugins@55.x` dependency from `apps/mobile-rn/package.json`. The local config plugin now imports `withPodfileProperties` through `expo/config-plugins`, which is the Expo-supported SDK 54 sub-export path.
- Pinned `react-native-worklets` to `0.5.1` for Expo SDK 54 compatibility and added a root `pnpm.overrides` entry so peer/optional resolution stays on the same version.
- Replaced the accidental `yarn@1.22.22` package manager marker with `pnpm@10.33.1`, matching the repo lockfile.

### `react-native-shared-group-preferences` risk acceptance
`react-native-shared-group-preferences` remains excluded from Expo Doctor's React Native Directory metadata check because the package is used only for the optional iOS widget/App Group shared UserDefaults sync path. This exclusion does not remove runtime risk; it records a release risk acceptance. Required mitigation before final GO:
- TestFlight/production iOS build smoke test on a real iPhone.
- Widget install/display smoke test.
- Verify widget data sync failure does not crash the host app.
- Record evidence path in `IOS_REVIEW_EVIDENCE.md` or keep final decision as `NO-GO`.

### Verification after remediation
- `pnpm --filter @fortune/mobile-rn exec expo install --check` → pass.
- `pnpm dlx expo-doctor --verbose` → 17/17 checks passed.
- `deno check`/`deno test` for touched Edge functions/shared tests → pass.
- `npm run rn:typecheck` and `npm run rn:test` → pass.
