# iOS App Store Submission Audit — 2026-05-13

- Created at: `2026-05-13 20:22:24 KST`
- Request: `온도 앱 IOS 심사 등록하는과정하고 등록까지하자`
- Project: Ondo / Fortune mobile RN
- Repo: `/Users/injoo/Desktop/Dev/fortune`

## Verdict

**NO-GO for final App Review submission right now.**

A binary was already uploaded to App Store Connect for the 2026-05-11 release candidate, but the repository is not currently in a clean/frozen release state and the release evidence still marks final App Review submission as blocked/pending.

## Commands / checks run

- `git status --short --branch`
- `git log --oneline origin/master..HEAD`
- `git diff --stat`
- `git diff --cached --stat`
- `git diff --cached --name-status`
- `git diff --name-status`
- `git rev-parse HEAD`
- `eas whoami`
- `cat apps/mobile-rn/eas.json`
- `EXPO_PUBLIC_APP_ENV=production EAS_BUILD_PROFILE=production npx expo config --type public --json`
- URL checks for:
  - `https://zpzg.co.kr/privacy`
  - `https://zpzg.co.kr/terms`
  - `https://zpzg.co.kr/support`
- `eas build:list --platform ios --limit 5 --json`
- `gh run list --branch master --limit 5 --json ...`
- `gh run view 25788918266 --json conclusion,headSha,status,name,displayTitle,jobs`
- Independent fallback review via Hermes delegate subagent

OpenClaw/Claude Opus validation was attempted, but OpenClaw returned `401 Invalid authentication credentials`; no OpenClaw verdict was used.

## Current repository state

- Branch: `master`
- Current HEAD: `62c23f9505fc7a3f3bd74e1cb6fb93e41a0c317c`
- `origin/master..HEAD`: empty
- Worktree/index: **dirty**

Staged additions:

- `apps/mobile-rn/src/features/fortune-results/fullscreen/fortune-reading-summary-card.tsx`
- `apps/mobile-rn/src/features/fortune-results/fullscreen/haneul-fortune-reading-screen.tsx`
- `apps/mobile-rn/src/features/fortune-results/fullscreen/reading-sentences.test.ts`
- `apps/mobile-rn/src/features/fortune-results/fullscreen/reading-sentences.ts`
- `apps/mobile-rn/src/features/fortune-results/fullscreen/sentence-reading-player.tsx`
- `docs/qa/ondo-audit/2026-05-12-cycle-1-architecture-addendum.md`
- `docs/qa/ondo-audit/2026-05-12-cycle-1.md`

Unstaged modifications:

- `apps/mobile-rn/src/lib/chat-characters.ts`
- `apps/mobile-rn/src/screens/character-profile-screen.tsx`
- `apps/mobile-rn/src/screens/friend-creation-screen.tsx`
- `apps/mobile-rn/src/screens/friend-picker-screen.tsx`

This dirty state is a release blocker under the iOS submission workflow because there is no clean reproducible release candidate at the current working tree.

## EAS / App Store state

EAS account:

- `injooinjoo`
- `injooinjoo@gmail.com`

Submit config:

- `submit.production.ios.ascAppId`: `6749496180`

Production config:

- App name: `온도`
- Slug: `ondo-mobile-rn`
- Version: `1.0.14`
- runtimeVersion: `1.0.14`
- iOS bundle identifier: `com.beyond.fortune`
- EAS project ID: `f7a724ea-b46e-494a-b83c-94e7a6fec02a`

Latest iOS production EAS build:

- Build ID: `758211db-3ba7-4c29-b41b-d3b1939a1cc5`
- Status: `FINISHED`
- Version: `1.0.14`
- Build number: `61`
- runtimeVersion: `1.0.14`
- Channel: `production`
- Distribution: `STORE`
- Commit: `8b7d6adb582cbc8ac0c6d6b1e18a1bf1b61ec3e1`
- Artifact: `https://expo.dev/artifacts/eas/fvAZ2A1TedP1PuCGaDKqEz.ipa`

Release docs record:

- EAS submission ID: `455c2055-0142-4321-a77d-57c37d32c552`
- ASC App ID: `6749496180`
- App Store Connect/TestFlight URL: `https://appstoreconnect.apple.com/apps/6749496180/testflight/ios`

Important distinction: this build was created from commit `8b7d6adb...`, while the current repository HEAD is `62c23f...` and the current worktree is dirty.

## Public metadata URL status

All checked public URLs returned HTTP 200:

- `https://zpzg.co.kr/privacy` → 200
- `https://zpzg.co.kr/terms` → 200
- `https://zpzg.co.kr/support` → 200

## Release decision blockers

`docs/deployment/review/RELEASE_DECISION_LOG.md` still records P0/P1 blockers:

- `DEC-002` — P0 fail
- `DEC-003` — P1 fail
- `DEC-004` — P0 fail
- `DEC-007` — P0 pending
- `DEC-008` — P0 pending

The 2026-05-11 entry states:

> `NO-GO for final App Review submission until ASC login/processing + required evidence are complete; binary upload complete`

`docs/deployment/review/IOS_REVIEW_EVIDENCE.md` records:

- `IOS-BUILD-004` — fresh EAS iOS production build: pass
- `IOS-BUILD-005` — binary uploaded to App Store Connect via EAS Submit: pass
- `IOS-BUILD-006` — App Store Connect build processing / review submission completed: pending / blocked because ASC browser session is required

Additional evidence still pending includes real iPhone clean install rejection-path verification, IAP purchase/cancel/restore, iPad review path, optional NAT64/IPv6 evidence, and explicit risk sign-off.

## GitHub Actions status

For current HEAD `62c23f9505fc7a3f3bd74e1cb6fb93e41a0c317c`:

- `CI Pipeline` run `25788918266`: **failure**
- Failing job: `mobile-rn typecheck`
- Failing step: `tsc --noEmit`

This is also a release blocker for a current-HEAD submission candidate.

## Decision

I did **not** run `eas build`, `eas submit`, or attempt final App Store Connect review submission during this audit because the current state is NO-GO.

Safe completion status today:

- Verified that the prior EAS iOS production binary upload exists for build `61`.
- Verified current App Store/EAS config and public policy URLs.
- Verified final App Review submission remains blocked by release documentation, dirty tree, CI failure, and ASC/session/evidence requirements.

## Required closure criteria before final App Review submission

1. Resolve or intentionally shelve the current staged/unstaged work so the release candidate is clean.
2. Decide whether the submitted binary should remain the 2026-05-11 build `61` from commit `8b7d6adb...`, or whether a new build must be created from a new frozen SHA.
3. Get GitHub CI green for the intended frozen SHA, including `mobile-rn typecheck`.
4. Verify App Store Connect build processing and select the intended build on the version page.
5. Capture or explicitly risk-accept required real-device evidence: iPhone clean install/rejection path, IAP success/cancel/restore, iPad review path, and NAT64/IPv6 if applicable.
6. Update `IOS_REVIEW_EVIDENCE.md` and `RELEASE_DECISION_LOG.md` from NO-GO/pending to GO/pass with exact evidence.
7. Complete App Store Connect final `Submit for Review` with review notes matching the selected build.

## 2026-05-13 20:49 KST Remediation Update

Technical blockers from this audit were remediated:

- Dirty release tree resolved: staged/unstaged work was classified, committed, and pushed.
- TypeScript CI blocker resolved: `mobile-rn typecheck` now passes locally and in GitHub Actions.
- Source inventory CI blocker resolved: `npm run repo:sync` regenerated `docs/development/FILE_INVENTORY.md`, `docs/development/UNUSED_CANDIDATES.md`, and `artifacts/file_inventory.json`; the regenerated outputs were committed and pushed.
- Current frozen SHA: `b30096f9f6e6e6eabed49b3e19de0a3d348818f7`.
- Git state after remediation: `master...origin/master`, clean.
- GitHub Actions for frozen SHA `b30096f9`: `CI Pipeline` run `25796724955` success; `E2E Tests` run `25796724963` success; `Security Scan` run `25796725010` success.
- Local gates passed: `npm run rn:typecheck`, `npm run rn:test`, `pnpm --filter @fortune/mobile-rn exec expo install --check`, `pnpm dlx expo-doctor --verbose` (17/17). `expo lint` exits 0 with warnings.
- Fresh current-SHA EAS iOS production build created:
  - Build ID: `5737a653-3030-464c-914e-613b673c150d`
  - Version/build: `1.0.14` / `62`
  - runtimeVersion: `1.0.14`
  - Channel/distribution: `production` / `STORE`
  - Commit: `b30096f9f6e6e6eabed49b3e19de0a3d348818f7`
  - Artifact: `https://expo.dev/artifacts/eas/bLEcc1bNAmF4RwnkSRQvAV.ipa`

Updated verdict after remediation:

- **Technical RC status: GO for current-SHA build artifact creation.**
- **Final App Review submission status: still NO-GO until the remaining manual/submission evidence is closed.**

Remaining final-submission blockers:

1. `IOS-BUILD-009`: build 62 has not yet been uploaded to App Store Connect via EAS Submit.
2. `IOS-BUILD-010`: ASC build processing/build selection/final `Submit for Review` evidence is still pending and requires an ASC session.
3. `IOS-RUNTIME-002`: real iPhone clean-install / previous rejection-path verification remains pending.
4. `IOS-IAP-001~003`: IAP success, cancel/error recovery, and restore purchases evidence remains pending.
5. `IOS-RUNTIME-003`: iPad review-path evidence remains pending.
6. `DEC-008`: explicit risk approver sign-off remains pending.

## 2026-05-13 22:09 KST EAS Submit Update

User explicitly asked to finish the submission path. I ran EAS Submit for the latest iOS production build.

Command:

- `eas submit --platform ios --profile production --latest --non-interactive`

Result:

- EAS submission ID: `d2ced764-68c4-4cae-9902-49dea5b9157f`
- Submission URL: `https://expo.dev/accounts/injooinjoo/projects/ondo-mobile-rn/submissions/d2ced764-68c4-4cae-9902-49dea5b9157f`
- ASC App ID: `6749496180`
- Uploaded EAS build: `5737a653-3030-464c-914e-613b673c150d`
- App version/build: `1.0.14` / `62`
- EAS output: `Submitted your app to Apple App Store Connect!`
- EAS output: `Your binary has been successfully uploaded to App Store Connect!`
- Apple processing URL: `https://appstoreconnect.apple.com/apps/6749496180/testflight/ios`

Post-submit ASC browser check:

- Browser redirected to `https://appstoreconnect.apple.com/login?targetUrl=%2Fapps%2F6749496180%2Ftestflight%2Fios&authResult=FAILED`.

Updated status:

- **Binary upload to App Store Connect: DONE for build 62.**
- **Final App Review submission button flow: NOT VERIFIED / NOT COMPLETED by this automation, because ASC login/session is unavailable.**

Remaining manual finalization in ASC:

1. Log in to App Store Connect.
2. Wait until build `1.0.14 (62)` finishes Apple processing.
3. Open the App Store version page for app `6749496180`.
4. Select build `62` for the version submission.
5. Confirm review notes, support/privacy URLs, sign-in-required setting, and IAP review details.
6. Click `Submit for Review` and capture the confirmation evidence.
