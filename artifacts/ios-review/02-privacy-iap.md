# iOS App Store Review Audit — Privacy, Tracking, IAP, Account Deletion

App: 온도 (Ondo) · Bundle: `com.beyond.fortune` · Version 1.0.9 · Expo SDK 54 / RN 0.81
Audit date: 2026-04-23
Scope: apps/mobile-rn + supabase/functions

Severity legend: **CRITICAL** = will be rejected, **WARNING** = likely followup, **INFO** = noted.

---

## 1. Guideline 5.1.1(v) — Account Deletion — **PASS (with WARNING)**

**Reachability — PASS.** Entry point is in-app on the profile tab:
- `apps/mobile-rn/src/screens/profile-screen.tsx:767-777` — visible "계정 삭제" text button under the "정보" section, navigates to `/account-deletion`.
- Route registered: `apps/mobile-rn/app/account-deletion.tsx`.
- Confirmation flow: `apps/mobile-rn/src/screens/account-deletion-screen.tsx` — user must type "삭제" before the red "계정 영구 삭제" CTA enables. Not a "contact us" path.

**Deletion is real — PASS.** Calls edge function `delete-account`:
- `supabase/functions/delete-account/index.ts:23-45` — explicit `DELETE_TARGETS` array covering 20 tables (user_profiles, subscriptions, token_balance, fortune_history, fortune_cache, face_reading_history, user_saju, pets, etc.).
- Line 79-83: uses `delete({ count: 'exact' })` to verify rows actually removed (catches silent RLS failures).
- Line 126: finally calls `supabase.auth.admin.deleteUser(userId)` to hard-delete the auth record. Auth user is ONLY deleted after all table deletes succeed (line 112-124 guards). This is a high-quality implementation.
- `apps/mobile-rn/src/screens/account-deletion-screen.tsx:51-52` — client calls `supabase.auth.signOut()` + redirects to `/chat` after success.

**WARNING — orphan tables.** The hard-coded list may miss tables added later. There is no consolidated RPC/trigger on `auth.users` delete. Recommend adding an `ON DELETE CASCADE` to `auth.users(id)` for all user-owned tables OR a Postgres `before_delete_auth_user()` trigger, so future tables do not silently leak PII. Specifically not in the list: chat messages, character conversation caches, friend relationships, push tokens — if these tables hold user data, they are not being purged. Reviewer testing may not catch this, but a GDPR/privacy audit would.

---

## 2. Guideline 5.1.1 — Data Collected — **WARNING (disclosure accuracy)**

Personal data actually collected:
- **Birthdate + birth time + birth location** (saju) — `onboarding-screen.tsx:93-129`, stored in `user_profiles`, `user_saju`.
- **Name** — onboarding, `user_profiles.insert` at `user-profile-remote.ts:108-114`.
- **Photos** — face reading + character chat image attachments. `expo-image-picker` configured in `app.config.ts:137-142` with photosPermission/cameraPermission strings. Images are base64-encoded and forwarded to `character-chat` edge function (per commit `67a3f091`).
- **Voice (speech-to-text)** — `expo-speech-recognition` configured at `app.config.ts:126-128`, used by `apps/mobile-rn/src/lib/use-voice-input.ts`.
- **Chat content** — user messages + AI responses stored server-side for character chat.
- **Email / phone** — Apple/Google/Kakao/Naver login, email-auth, phone-auth screens.
- **Device identifiers** — Sentry auto-collects install ID and device model via `@sentry/react-native` (`crash-reporting.ts:31-47`). Sentry user id set to Supabase user id (crash-reporting.ts:67-71); email explicitly omitted (good).
- **Push token** — `expo-notifications`, stored server-side.

**Make sure Privacy Nutrition Labels on App Store Connect declare (all linked to identity):** Contact Info (Email, Phone), User Content (Photos, Voice Data, Other User Content = chat), Identifiers (User ID, Device ID via Sentry), Diagnostics (Crash/Performance Data via Sentry), Sensitive Info (Date of Birth, Location — birth place as freeform text counts as "Other Sensitive Info"). Fortune + saju inputs are "Other User Content".

No evidence of: GPS location, contacts, HealthKit, IDFA/ad tracking, or microphone recording beyond STT.

---

## 3. App Tracking Transparency (ATT) — **INFO (no prompt required today)**

- No Mixpanel SDK is actually installed. `package.json:14-56` does not list `mixpanel-react-native`. Only the env plumbing exists (`app.config.ts:186-188`, `env.ts:9/24`).
- `apps/mobile-rn/src/lib/analytics.ts:5-12` is a **no-op stub** — `trackEvent` only logs to console in dev when `isAnalyticsConfigured` is true. No network egress. **Safe.**
- Sentry is used for crash reporting only. Sentry's install ID is a per-app ID, not a cross-app tracker. With `Sentry.setUser({ id })` using the first-party Supabase user id (crash-reporting.ts:67-71), no ATT prompt is required.
- No `requestTrackingPermissionsAsync`, no `NSUserTrackingUsageDescription` in `app.config.ts` infoPlist — correct state given current collection.

**WARNING:** If Mixpanel is wired later without ATT, this becomes a rejection risk. Remove the dangling `mixpanelToken` config entries (app.config.ts:186-188, env.ts:9/24) or gate them behind an ATT prompt when the SDK is added.

---

## 4. Guideline 3.1.1 — In-App Purchase — **PASS (with WARNINGS)**

- **IAP used** — `expo-iap` 3.4.13 (package.json:32); Podfile.lock confirms ExpoIap (3.4.13) + openiap (1.3.15). Native purchase flow via `mobile-app-state-provider.tsx:12-27` (initConnection, requestPurchase, finishTransaction, getAvailablePurchases).
- **Restore Purchases — PASS.** `premium-screen.tsx:449-454` "구매 복원" button visible on the subscription screen, backed by `restorePurchases()` at `mobile-app-state-provider.tsx`.
- **Subscription disclosure — PASS.** `premium-screen.tsx:386-410` renders before the purchase button when `selectedProduct.isSubscription`:
  - Korean subscription terms: "자동 갱신 구독... 구독 기간 종료 최소 24시간 전에 자동 갱신을 해제하지 않으면 구독이 자동으로 갱신됩니다. 설정 > Apple ID > 구독에서 관리할 수 있습니다."
  - 이용약관 + 개인정보처리방침 links rendered side-by-side. This specifically addresses the prior 3.1.2 rejection evidence.
- **No external payment steering — PASS.** Searched for "결제는 웹에서" and external checkout URLs — none found. Only external link is to `apps.apple.com/account/subscriptions` for managing active sub (`premium-screen.tsx:187-188`), which is Apple-approved.
- **Product IDs** bundle-scoped (`com.beyond.fortune.subscription.max`, etc.) — consistent with App Store Connect.

**WARNING 4a — price/title source.** `premium-screen.tsx:315,337,351` prefers `storePriceLabels[product.id] ?? formatPrice(product.price)`. If the StoreKit fetch fails in review (reviewer network), the `formatPrice()` fallback shows a hardcoded KRW price from `productCatalog`. Reviewers sometimes flag "price displayed in-app does not match App Store Connect". Verify that `product.price` in `@fortune/product-contracts` matches every App Store Connect tier exactly, or show a loading skeleton instead of a stale price.

**WARNING 4b — subscription title rendering.** The localized subscription title/length is generated by `getProductDisplayTitle` + `getSubscriptionPeriodLabel` helpers (from product-contracts). Confirm these produce strings literally matching the App Store Connect "Subscription Display Name" + "Duration"; Apple has rejected mismatches (3.1.2).

**WARNING 4c — legal links on web domain.** The links open a Supabase function URL (`https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/...` in premium-screen.tsx:398-407). The bundled `apps/mobile-rn/app/privacy-policy.tsx` route exists in-app — prefer `router.push('/privacy-policy')` for consistency with the profile screen (profile-screen.tsx:713). Opening an external URL to Supabase infra also means the links break if the edge function is ever down during review.

---

## 5. Sign in with Apple — **PASS**

- Apple Sign-in configured: `app.config.ts:103` `usesAppleSignIn: true`, plugin `expo-apple-authentication` at line 124.
- Native flow: `apps/mobile-rn/src/lib/social-auth.ts:51-134` — `AppleAuthentication.signInAsync` with hashed nonce + Supabase `signInWithIdToken`.
- Login UI: `apps/mobile-rn/src/screens/signup-screen.tsx:31-52` — Apple is the **first** option in the auth list, rendered with the official `AppleAuthButton` component (line 133-138), above Google. Kakao/Naver are commented out. Order + styling comply with guideline 4.8 visual equivalence requirement.

---

## 6. Third-party SDK Privacy Manifests — **WARNING**

SDKs installed per `ios/Podfile.lock`:
- Sentry (HybridSDK 8.56.1) — PrivacyInfo.xcprivacy present at `ios/Pods/Sentry/Sources/Resources/PrivacyInfo.xcprivacy`. PASS.
- ExpoAppleAuthentication 8.0.8 — Apple first-party, no manifest required.
- ExpoIap 3.4.13 + openiap 1.3.15 — on Apple's "commonly used" SDK list (StoreKit wrappers) — **no `PrivacyInfo.xcprivacy` found** under `ios/Pods/ExpoIap` or `ios/Pods/openiap`. If Apple's required-reason SDK list names openiap / expo-iap, submission will be flagged. **Action:** upgrade expo-iap to a version that bundles a privacy manifest, or request upstream add one.
- No Mixpanel / Google Sign-in / Kakao SDK native pods in Podfile.lock — Google and Kakao login go through Supabase OAuth (web flow via `expo-web-browser`), so no native SDK is bundled. This is the best outcome for privacy manifest purposes.
- `@supabase/supabase-js` is JS-only, no native pod — no manifest requirement.

`app.config.ts:105` declares `ITSAppUsesNonExemptEncryption: false` — accurate since only TLS is used.

---

## 7. Guideline 1.2 / 5.2.3 — UGC Moderation — **CRITICAL**

The app ships AI character chat plus user-to-AI messaging and user-submitted images. Apple requires (for apps with user-generated or AI-generated conversational content):
1. EULA or in-app terms prohibiting objectionable content,
2. A mechanism to **filter** objectionable content,
3. A mechanism for users to **flag/report** content,
4. A mechanism to **block abusive users**,
5. Developer response to reports within 24 hours.

Findings:
- **No in-app report button.** Grep for `신고|report|block|차단` across `apps/mobile-rn/src` (chat-screen.tsx, chat-surface.tsx, character-profile-screen.tsx) returned zero matches. The only matches are `captureError`/`error-reporting` (crash telemetry) and `신고` inside a fortune copy string about birth registration (`fixtures.ts:533`) — not a moderation feature.
- **No user blocking.** No `blockUser`, no `blocked_users` table referenced in code.
- **No content filter.** `supabase/functions/_shared/llm/safety.ts` is a cost/usage circuit breaker, not a content moderator. No OpenAI moderation endpoint calls, no keyword filter, no image safety check on user-uploaded photos.
- EULA text exists (`app/disclaimer.tsx`, legal-pages function) but does not include a clause about prohibiting objectionable user content or the 24-hour removal commitment.

**This is a very likely rejection for a chat-centric AI app in 2025/2026.** Apple has been actively rejecting AI chat apps lacking (3) report and (4) block. Must-do before submission:
1. Add "신고" long-press action on character chat messages → posts to a new `chat_message_reports` table.
2. Add "차단" option on character profile screen to hide all messages from a given character persona / block proactive messages.
3. Add a pre-send filter (cheapest: call OpenAI `omni-moderation-latest` on user text and image base64 in `supabase/functions/character-chat/index.ts` before LLM call; drop if flagged).
4. Update EULA / ToS to include a zero-tolerance clause + 24h takedown promise.

---

## 8. Age Gate & Kids — **WARNING**

- No age gate in `onboarding-screen.tsx`. The "기본 정보" step (line 42-46) collects birthdate but does not branch on "< 13" or "< 17".
- Saju/face reading inherently involves a birthdate, so computing age is trivial — yet no guard restricts minor access to AI character chat.
- `app.config.ts` has no parental-gate plugin, no kids-category config.
- `metadata/en-US/description.txt` positions app as entertainment; `app/disclaimer.tsx:8-12` labels content as 오락 목적.

**Recommendation:** Declare age rating 17+ on App Store Connect (realistic for an AI chat app with romance "pilots" seen in `story-romance-pilots.ts`), OR add a birthdate-based age check at onboarding that routes users under your chosen floor to a "come back later" screen. A 12+/13+ rating with open AI chat is likely to be escalated.

---

## Checklist — Action Items Before Submission

| # | Severity | Item |
|---|----------|------|
| 1 | CRITICAL | Add in-app **report message** + **block user/character** flow in chat. (Guideline 5.2.3 / 1.2) |
| 2 | CRITICAL | Add pre-send content moderation in `supabase/functions/character-chat/index.ts` (OpenAI moderation for text + images). |
| 3 | WARNING | Verify expo-iap 3.4.13 ships `PrivacyInfo.xcprivacy`; if missing, upgrade or patch. |
| 4 | WARNING | Audit `delete-account` `DELETE_TARGETS` against current schema; add ON DELETE CASCADE from `auth.users`. Likely missing: chat/message tables, push tokens, friend-creation data. |
| 5 | WARNING | Confirm `productCatalog` prices/titles/durations exactly match App Store Connect entries (3.1.2 prior-rejection risk). |
| 6 | WARNING | Replace Supabase-hosted legal links in `premium-screen.tsx:398-407` with in-app `/privacy-policy` + `/terms-of-service` routes. |
| 7 | WARNING | Add EULA clause: "objectionable content will be removed within 24 hours" + specific user conduct prohibitions. |
| 8 | WARNING | Declare age rating 17+ OR add age gate at onboarding. |
| 9 | WARNING | Remove unused `mixpanelToken` wiring (app.config.ts:186-188, env.ts) OR document why it exists. |
| 10 | INFO | Privacy Nutrition Labels: declare Contact Info, User Content (Photos/Audio/Other), Identifiers (User/Device ID), Diagnostics, Sensitive Info (DOB + birth place). |
| 11 | INFO | No ATT prompt needed today; re-check if Mixpanel or any cross-app tracker is added. |
