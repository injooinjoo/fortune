# Ondo 관리 에이전트 통합 개선점 도출 — 2026-06-10

## 0. Scope / Freeze
- Repo: `/Users/injoo/Desktop/Dev/fortune`
- Branch: `master...origin/master`
- Tracked diff: none at audit start.
- Untracked artifacts present:
  - `docs/audits/2026-06-ondo-security-check/report-2026-06-10.md`
  - `docs/audits/2026-06-ondo-security-check/fix-plan-2026-06-10.md`
  - `docs/development/expo-cng-build-and-release.md`
- Paperclip/JIRA: this Hermes session has no exposed Paperclip/JIRA tool, so issue creation was not automated.
- Work performed: audit/report only. No app code, DB, deployment, OTA, or production write was changed.

## 1. Agents used
### Hermes / Ondo management roles
- BM/IAP Security Reviewer
- Supabase IAP Security Reviewer
- Fortune Edge LLM Engineer
- iOS Review Gatekeeper
- UX Button Walker
- Design System / Motion Reviewer
- Conversation UX Designer
- Survey Flow Designer
- Chat Product Lead
- Chat Runtime Engineer
- Chat QA Reviewer
- Fortune Domain Architect
- Fortune Schema Registry QA
- Bug RCA Investigator
- Architecture Reviewer
- Release Real Device QA / iOS Simulator Test Agent
- Loop Agent consolidation

### External adversarial reviewer
- OpenClaw was attempted with `/opt/homebrew/bin/openclaw agent --agent main --json --timeout 600`, but failed due configured Anthropic authentication error: `401 Invalid authentication credentials`. It was not counted as successful evidence.

## 2. Executive verdict
- **Release security:** NO-GO until write-path evidence exists.
- **App Store:** NO-GO until AI transparency, privacy/AdMob/ATT metadata, account deletion evidence, and real-device evidence are aligned.
- **BM / revenue safety:** risky but improved. Several June P0s are materially mitigated, but tarot auth/token, poster subscription-token policy, and consumable restore remain high-risk.
- **Chat trust:** risky. The app still has multiple structural paths where the user sees a sent message or push/job state, but canonical assistant persistence is not guaranteed.
- **Maintainability / performance:** risky. Large God objects, unvirtualized chat thread rendering, bootstrap hydration, and polling patterns keep regression cost high.

## 3. Current closed or superseded risks
These should not be repeated as live P0s without rechecking current code/production:

1. **Ad reward client POST abuse is now materially blocked**
   - Current evidence from security report: unauth POST returns `403 ssv_required`; `grant-ad-reward` requires AdMob SSV GET + `transaction_id`; atomic RPC/ledger exists.
   - Remaining need: live AdMob test SSV write/replay evidence.

2. **Poster queue now has server-side charge/job guard**
   - Current evidence: `start-poster-job` requires JWT and calls `schedule_poster_job_with_charge`; worker rejects jobs without `charge_transaction_id`.
   - Remaining issue: subscription branch may bypass finite-token consumption for poster jobs.

3. **User/generated Storage buckets are private at bucket/policy level**
   - Current evidence: private buckets include `palm-reading-images`, `poster-guide-images`, `past-life-portraits`, `talisman-images`, `yearly-encounter-images`, `friend-avatars`, `character-audio-messages`.
   - Remaining issue: old/new result payloads persist expiring signed URLs without canonical `{bucket,path}` refresh metadata.

4. **Delete-account source health is improved**
   - Current evidence: latest security report says `deno check supabase/functions/delete-account/index.ts` passed and real UGC/result buckets are in manifest.
   - Remaining need: controlled test-account DB/Auth/Storage purge write evidence.

## 4. Prioritized improvement backlog

### P0-1. Live write-path QA evidence before release security GO
- **Impact:** payment tokens, ad rewards, subscriptions, and account deletion are side-effect paths. Static/read-only checks cannot prove release safety.
- **Evidence:** `docs/audits/2026-06-ondo-security-check/report-2026-06-10.md:17-28` explicitly marks this as release security blocker.
- **Minimal action:** run controlled QA using test accounts only:
  1. AdMob test SSV valid callback grants once; replay grants zero; POST remains 403.
  2. StoreKit sandbox consumable purchase/cancel/replay and subscription activate/restore grant exactly once.
  3. Test account deletion removes DB rows, Storage prefixes, auth user, and prevents re-login.
- **Validation:** capture row IDs/timestamps from `token_transactions`, purchase/ad ledgers, storage object counts, auth user state, and device screenshots.

### P0-2. `fortune-tarot` no-auth / token policy must be locked before LLM
- **Impact:** all AI/fortune paths are supposed to consume tokens. No-auth tarot reaching validation/function logic is a cost and abuse risk if valid payload reaches LLM.
- **Evidence:** latest security report flags `supabase/config.toml` `verify_jwt=false`, optional JWT fallback to `anonymous`, and production no-auth POST reaching function-level selectedCards validation.
- **Minimal fix:** require auth before parsing/LLM-cost path; consume token or enforce explicit anonymous quota before any LLM. Safe default: no guest tarot for now.
- **Validation:** no-auth valid tarot payload returns `401 auth_required` before selectedCards/LLM; authenticated insufficient-token returns `402`; enough-token creates consume transaction before LLM; LLM failure refunds once.

### P0-3. Chat token charge must be coupled to canonical assistant persistence
- **Impact:** user can lose paid tokens if reply generation, save, or room render fails after precharge.
- **Evidence from agents:** `chat-screen.tsx` token precharge path; no clear `refundRemoteTokens` usage in failure path; `character-chat` direct immediate path can mark job done before canonical assistant persistence.
- **Minimal fix:** persist/lineage-first flow: `pending_reply_job` links charge transaction; assistant message canonical persist succeeds before `done/delivered/ack`; failure triggers retry/refund and visible failed state.
- **Validation:** fresh unique paid message -> assistant row ID/timestamp -> visible room bubble. Fault injection after charge produces either refund transaction or retryable job, never silent token loss.

### P1-1. Private media durability: store `{bucket,path,expiresAt}` not only 7-day signed URL
- **Impact:** privacy fix can cause old generated images to break after signed URL expiry.
- **Evidence:** security report lines 41-50; `generate-poster-guide` and related image flows return/persist signed URLs as `imageUrl` / `result_image_url`.
- **Minimal fix:** server returns/stores canonical bucket/path metadata plus transient signed URL; mobile refreshes via owner-checked Edge Function when expired or failed to load.
- **Validation:** manually expired old result reopens and refreshes image; user A cannot refresh user B path; direct public URL remains 401/403.

### P1-2. Poster subscription branch must follow finite-token policy
- **Impact:** if `schedule_poster_job_with_charge` lets active subscribers skip `consume_token_atomic`, high-cost image generation becomes effectively unlimited while app copy says finite monthly tokens.
- **Evidence:** BM/security agent found product contracts define finite lite/pro/max monthly tokens, while poster job RPC subscription branch may bypass token consumption.
- **Minimal fix:** remove subscription skip for poster jobs unless product explicitly chooses an unlimited poster entitlement; all paid poster jobs create consume transaction.
- **Validation:** lite/pro/max subscriber with low/zero balance cannot generate without token consumption; successful poster job has linked consume transaction.

### P1-3. AI character transparency must stop denying AI identity
- **Impact:** App Store transparency/review and user trust risk.
- **Evidence:** UX/App Store agent found prompt/code patterns forcing character not to say AI/LLM/chatbot and fallback rejecting AI self-identification.
- **Minimal fix:** allow identity questions to answer “AI 기반 가상 캐릭터” while preserving character tone; add sensitive advice guardrails.
- **Validation:** “너 AI야?” returns transparent answer; medical/legal/finance red-team prompts avoid professional advice substitution.

### P1-4. App Privacy / AdMob / ATT / Review Notes alignment
- **Impact:** actual rewarded AdMob SDK usage conflicts with metadata if ASC says no ads/advertising data.
- **Evidence:** `react-native-google-mobile-ads`, AdMob config, rewarded ad path, and old privacy answers mismatch.
- **Minimal fix:** update App Privacy answers and review notes to describe non-personalized rewarded ads, no cross-app tracking, and no ATT prompt because tracking is not used.
- **Validation:** ASC export/repo metadata match; fresh install shows no ATT prompt; rewarded ad -> SSV -> token path works.

### P1-5. Premium/top-up `returnTo` preservation across email/phone auth
- **Impact:** logged-out purchase/top-up users lose purchase intent, harming conversion.
- **Evidence:** premium screen passes `/signup?returnTo=/premium?intent=top-up`; social auth preserves it, email/phone paths drop it.
- **Minimal fix:** propagate encoded `returnTo` through signup -> email/phone auth -> auth callback -> onboarding completion.
- **Validation:** Apple/Google/email/phone from `/premium?intent=top-up` all return to the same top-up intent after auth.

### P1-6. Durable first-send / local batching risk in chat
- **Impact:** message appears sent locally, but server has no job if app is killed within 1.5s batching window.
- **Evidence:** chat runtime/UX agents identified local queue + delayed `flushBatch` as root cause path.
- **Minimal fix:** first send immediately upserts durable batch/job head; subsequent messages append to same batch; AppState background flushes; failure marks user bubble pending/failed.
- **Validation:** kill app at 0.2s/0.8s/1.4s after send and verify pending job/reply survives.

### P1-7. Scheduled/immediate reply delivery ordering must be canonical-persist-first
- **Impact:** push/list/room mismatch and “reply arrived but room empty” if delivered/acked/done happens before DB merge.
- **Evidence:** agents found direct immediate and scheduled claim/deliver paths setting terminal state before/without guaranteed canonical persist.
- **Minimal fix:** introduce processing/claimed state; set delivered/acked/done only after `merge_character_conversation_messages` succeeds; persist failure stays retryable.
- **Validation:** fault-injected DB merge failure leaves row retryable, not delivered/acked; retry later creates assistant row.

### P1-8. Real-device QA path must be unblocked
- **Impact:** push, IAP, Apple auth, camera/photo/mic/haptics, widgets/NSE cannot be release-proven on simulator alone.
- **Evidence:** existing `12-ios-simulator-real-device-report.md`; provisioning/dev-client issues block release-like evidence.
- **Minimal fix:** separate dev-client simulator flow from release/TestFlight flow; fix provisioning for app + NSE/widgets; document/run physical-device smoke.
- **Validation:** physical iPhone launch/install evidence, push token DB row, IAP sandbox transaction, Apple auth, camera/photo/mic, haptic evidence.

### P2-1. Chat surface performance: virtualize long conversations
- **Impact:** large threads can lag because entire `renderItems.map` tree renders inside a view, despite some memoization improvements.
- **Minimal fix:** migrate message list to `FlatList`/`FlashList`, memoize message rows, keep time-divider selector pure.
- **Validation:** 100/500/1000 message synthetic threads with input, append, TTS, scroll frame metrics.

### P2-2. Bootstrap should not block ready on all character conversation hydration
- **Impact:** cold start TTI grows with character count/message history.
- **Minimal fix:** critical bootstrap loads session/profile/minimal previews; full conversation hydration moves to idle/background or on-demand.
- **Validation:** compare app-open -> ready time across synthetic message volumes; ensure preview correctness.

### P2-3. Progress cards need centralized polling manager
- **Impact:** multiple progress cards poll every 3s and query multiple tables, creating linear Supabase/network/battery load.
- **Minimal fix:** screen-level job polling manager, batched job IDs, realtime first, AppState backoff/stop.
- **Validation:** request count over 60s with 1/3/5 cards drops materially; background disables intervals.

### P2-4. Product/fortune contracts should have automated drift tests
- **Impact:** missing endpoints (`constellation`, `lotto`) or SKU/token map drift creates runtime or payment failures.
- **Minimal fix:** tests ensure non-local fortune endpoints exist; local-only types declare no endpoint; mobile catalog, Edge allowlist, and token grant maps match generated SoT.
- **Validation:** missing endpoint count 0; ProductId count/mapping match mobile + Edge.

### P2-5. UX/accessibility quick wins
- **Impact:** Korean VoiceOver and button state quality affect App Review and perceived polish.
- **Minimal fixes:** Korean labels/hints for composer buttons; welcome final CTA in-flight guard; notification save loading/success/error; daily-free cost sheet and ledger consistency.
- **Validation:** VoiceOver walkthrough, rapid-tap CTA test, notification save failure mock, daily first/second ledger check.

### P2-6. Motion/design system cleanup
- **Impact:** reduced-motion/haptic preferences and raw text/color drift create accessibility and design inconsistency.
- **Minimal fixes:** shared `useReducedMotion`, global haptic policy or rename to chat-only, raw `Text`/color/font budget starting with splash/welcome/premium/chat composer.
- **Validation:** iOS Reduce Motion ON/OFF recordings; haptic OFF produces zero haptics across welcome/chat/result/purchase; static raw usage count does not increase.

## 5. Highest ROI fix order
1. **Release blocker evidence:** controlled write-path QA for SSV, StoreKit, delete-account.
2. **Block cost leaks:** `fortune-tarot` auth/token before LLM; poster subscription finite-token policy.
3. **Protect paid chat trust:** charge/job/reply canonical persistence ordering + refund/retry.
4. **Fix private media durability:** canonical Storage refs + signed URL refresh.
5. **App Store trust alignment:** AI transparency, App Privacy/AdMob/ATT notes, account deletion evidence.
6. **Conversion continuity:** premium/top-up `returnTo` across auth and onboarding.
7. **Chat delivery robustness:** durable first-send, scheduled/immediate persist-first delivery, photo/multimodal remote pipeline.
8. **Real-device QA:** provisioning/TestFlight evidence path.
9. **Performance/maintainability:** chat virtualization, bootstrap lazy hydration, progress polling manager, contract drift tests.
10. **Polish/accessibility:** composer Korean a11y labels, CTA guards, notification states, reduced motion/haptics, premium IA.

## 6. Safe small fixes if we want to start immediately
These are low-blast-radius compared with billing/security rewrites:
1. Patch stale `generate-poster-guide` header comment to say worker-only and server charge happens in `start-poster-job`/RPC.
2. Koreanize chat composer accessibility labels/hints.
3. Add welcome final CTA in-flight guard.
4. Add product/fortune endpoint drift tests.
5. Add `daily_chat_limit_reached` rollback/failed-state fix.

## 7. Validation gates for any implementation
- Repo freeze: `git status --short --branch --untracked-files=all`.
- RN gates: `pnpm --filter @fortune/mobile-rn typecheck`; lint if UI/native-facing.
- Edge gates: `deno check supabase/functions/<fn>/index.ts`; targeted no-auth/insufficient-token/replay smoke.
- DB/security gates: migration review, dry-run/staging where possible, controlled write smoke with test accounts.
- Mobile QA: simulator for UI regressions; physical iPhone/TestFlight for push/IAP/Apple auth/camera/mic/haptic.
- Reporting: include update/deploy IDs only after actual deployment; this report did not deploy.

## 8. Open decisions
1. Is guest tarot intentionally free? If yes, define anonymous daily quota/device/IP abuse guard. If no, auth + token is default.
2. Are subscribers finite-token for all high-cost image/poster paths, or is there a separate unlimited entitlement? Current product contract implies finite.
3. Should expired old image URLs be backfilled by migration or lazily refreshed on next open?
4. Is haptic setting global or chat-only? UI copy and gate logic should match.
