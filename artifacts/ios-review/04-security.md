# Security Audit — `/Users/injoo/Desktop/Dev/fortune`

Read-only audit focused on App Store + production readiness. Performed 2026-04-23.

Severity scale: **CRITICAL** (ship-blocker), **HIGH**, **MEDIUM**, **LOW**.

---

## 1. Secret Leakage in Client Bundle

### [HIGH] Real service_role key & JWT secret sitting on disk (not committed but undeleted)
- `/Users/injoo/Desktop/Dev/fortune/.env.local` (lines 3-5, 19, 45, 55)
  - `SUPABASE_SERVICE_ROLE_KEY=eyJ...` (real JWT, role=service_role, exp 2030)
  - `SUPABASE_JWT_SECRET=llGoYJDvMrVSeU0J...` (real HS256 secret — anyone with this can forge any JWT against the Supabase project)
  - `OPENAI_API_KEY=sk-proj-cR68IfBK-...` (real OpenAI project key)
  - `UPSTASH_REDIS_REST_TOKEN=AV2WAAIjcDEwMT...` (real)
  - `FIGMA_ACCESS_TOKEN=figd_bR2cafX...` (real)
- `.gitignore` line 194 covers `.env*` except `.env.example`, so these are NOT in git history (git ls-files confirms only `.env.development` and `.env.example` are tracked — both contain placeholders only). Verified via `git ls-files | grep env`.
- Risk: local-machine exposure only. **Rotate these secrets anyway** (JWT secret rotation invalidates all current sessions — schedule accordingly). The JWT secret leaking would be a full-project compromise.

### [LOW] `EXPO_PUBLIC_*` values shipped to client
Enumerated in `apps/mobile-rn/app.config.ts:175-201`:
- `supabaseUrl`, `supabaseAnonKey` (correct — anon key is safe to ship)
- `appDomain`, `sentryDsn`, `mixpanelToken`, `googleWebClientId`, `googleIosClientId`, `googleAndroidClientId`, `kakaoAppKey`

All are public-by-design (OAuth client IDs, analytics public tokens, Sentry DSN). No `SERVICE_ROLE`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC` references found in `apps/mobile-rn/src/`. Grep confirmed.

### [LOW] Bundle snapshot contains older env files
`/Users/injoo/Desktop/Dev/fortune/fortune-transfer-bundle-20260409/repo/{.env, .env.local, .env.production, .env.test}` — `.gitignore` line 22 excludes `fortune-transfer-bundle*` so these are not tracked, but they are ad-hoc snapshots on disk. Delete the bundle after transfer.

---

## 2. Supabase Usage

### [PASS] RN client correctly uses anon key
`apps/mobile-rn/src/lib/supabase.ts:19` — `createClient(appEnv.supabaseUrl, appEnv.supabaseAnonKey, ...)`. Storage adapter uses `expo-secure-store` (Keychain/EncryptedSharedPreferences). No `service_role` reference anywhere in `apps/mobile-rn/src/`.

### [MEDIUM] Many tables expose `FOR SELECT USING (true)` — public reads
Samples:
- `supabase/migrations/20260104000001_create_cohort_fortune_pool.sql:299,302` (cohort_fortune_pool — likely intentional)
- `supabase/migrations/20251127000002_create_trend_content_tables.sql:126-341` (psychology tests, worldcups, trend likes, comments — likely public content, acceptable)
- `supabase/migrations/20251126100000_create_llm_model_config.sql:37` (LLM model config readable by anon — leaks model/prompt config to any user)
- `supabase/migrations/20260310000001_repair_llm_guard_schema.sql:45` — same.

### [HIGH] `FOR UPDATE USING (true) WITH CHECK (true)` on celebrity tables
- `supabase/migrations/20250826000004_create_celebrity_master_list.sql:43` — any authenticated user can UPDATE the celebrity master list. This looks like an admin-only table.
- `supabase/migrations/20251207000001_fix_talisman_pool_schema.sql:91`, `20251128000012_talisman_pool_optimization.sql:103`, `20251222000002_create_widget_fortune_cache.sql:56`, `20251022000001_create_popular_regions.sql:27` — similar permissive writes. Verify each is service-role-only writable by checking `TO service_role` clauses (not checked comprehensively — follow-up audit needed).

### [MEDIUM] Notification tables have `USING (true)` policies
- `supabase/migrations/20251222000001_create_notification_tables.sql:38, 84, 138, 175` — possibly overly broad. Check whether `TO service_role` is set or if `auth.uid()` is enforced.

### [PASS-ish] Edge functions auth
- Default Supabase gateway enforces `verify_jwt=true` for all functions **except** those listed in `supabase/config.toml`:
  - `kakao-oauth` (verify_jwt=false)
  - `naver-oauth` (verify_jwt=false)
- Most sampled functions read JWT via `_shared/auth.ts` (`supabase.auth.getUser(token)`) — correct. E.g. `character-chat/index.ts:1948`, `token-balance/index.ts:78`, `delete-account/index.ts:59`, `payment-verify-purchase/index.ts:525`.

### [HIGH] Edge functions that trust `body.userId` instead of JWT claims
- `supabase/functions/fortune-tarot/index.ts:419-424` — `userId = body.userId || body.user_id || body.answers?.userId || 'anonymous'`. No JWT verification. Even though Supabase gateway requires a valid JWT to reach the function, the function never reconciles JWT subject with body userId — a legitimate user A can pass `userId: B` to write tarot results tagged as user B (written at line 527 — verify what downstream table writes it touches).
- `supabase/functions/fortune-birthstone/index.ts:258` — echoes `body.userId` into response. No DB write based on it, so impact is limited (LOW).
- `supabase/functions/widget-cache/index.ts:49` — same pattern; used for `.eq('user_id', userId)`. If the gateway requires JWT, this still lets user A read/write user B's widget cache.

**Remediation**: Extract userId from `supabase.auth.getUser(token)` on every endpoint that touches user-owned data, not from request body.

---

## 3. LLM Usage — LLMFactory Bypass

CLAUDE.md rule: all LLM calls go through `LLMFactory.createFromConfig(...)`. Violations found:

### [MEDIUM] Direct Gemini REST calls bypassing LLMFactory
- `supabase/functions/fortune-past-life/index.ts:2181` — `fetch('https://generativelanguage.googleapis.com/...:generateContent?key=${GEMINI_API_KEY}')`
- `supabase/functions/fortune-yearly-encounter/index.ts:584, 693` — same pattern (text + image models)
- `supabase/functions/speech-to-text/index.ts:57` — Gemini audio transcription via direct fetch

These bypass `LLMFactory.createFromConfig`, so central cost tracking, safety filtering, retries, model versioning are skipped. API key passes through URL query string → may end up in request logs.

### [LOW] `generate-talisman` uses `OpenAIProvider` directly
- `supabase/functions/generate-talisman/index.ts:230-241` — instantiates `new OpenAIProvider(...)` directly rather than via `LLMFactory.createFromConfig`. Not as bad as direct fetch (reuses provider logic) but still bypasses the factory pattern.

Library-internal direct calls in `_shared/llm/providers/{openai.ts, gemini.ts, anthropic.ts}` are expected — they implement the providers that the factory creates.

---

## 4. Injection / Misuse

- **SQL injection**: No evidence found. `supabase.rpc(...)` calls in client code use named parameter objects (not concatenated strings). `Grep rpc\s*\(\s*['"\`]|executeRawSQL|\.sql\(` in `apps/mobile-rn/src/` → 0 matches.
- **eval / Function / new Function**: 0 matches in `apps/mobile-rn/src/`.
- **WebView**: 0 matches in `apps/mobile-rn/src/`. Audit clean.
- **Path traversal**: `FileSystem.*` calls in `on-device-llm.ts` use hardcoded paths from `on-device-model-registry.ts`, no user-controlled path segments. Audit clean.

---

## 5. Network Security

### [PASS] No cleartext HTTP exceptions
- `Grep NSAppTransportSecurity|usesCleartextTraffic` → 0 matches. No Info.plist override. `apps/mobile-rn/app.config.ts` does not add cleartext exceptions.
- Only `http://` URL in `apps/mobile-rn/src/`: `apps/mobile-rn/src/lib/social-auth.ts:243` → `http://localhost:19006` as OAuth fallback for local dev only. Safe.

### [PASS] On-device model downloads use HTTPS
- `apps/mobile-rn/src/lib/on-device-model-registry.ts:51,70,85,104` — all `https://huggingface.co/...` URLs.
- **[LOW] No integrity check**: downloads verified only by `minModelBytes` size threshold (`on-device-llm.ts:263-266`). A MITM-capable attacker able to swap the HuggingFace response (unlikely with TLS) could deliver a tampered model. Consider SHA-256 verification of downloaded gguf files.

---

## 6. Auth Flow Correctness

### [PASS] Apple Sign-In nonce
- `apps/mobile-rn/src/lib/social-auth.ts:67-95` — raw nonce generated, hashed nonce passed to Apple, raw nonce sent to Supabase for validation. Correct.

### [PASS] Token storage uses expo-secure-store
- `apps/mobile-rn/src/lib/secure-store-storage.ts` wraps `expo-secure-store` with chunking. Used as Supabase session storage in `supabase.ts:12-16`.
- Only AsyncStorage-adjacent file is `welcome-state.ts`, but it uses `secure-store-storage.ts` wrapper (not actually AsyncStorage). Audit clean.
- `Grep AsyncStorage|@react-native-async-storage` in `apps/mobile-rn/src/` → only `welcome-state.ts` (false positive, uses SecureStore).

### [CRITICAL] Kakao OAuth does not verify access_token with Kakao
- `supabase/functions/kakao-oauth/index.ts` (`verify_jwt=false`, public):
  - Request body takes `{ access_token, user_info: { id, email, nickname, profile_image_url } }` (lines 56-57).
  - Function NEVER calls `https://kapi.kakao.com/v2/user/me` to verify the access_token or validate `user_info.id` against Kakao's server.
  - Instead it immediately calls `supabase.auth.admin.createUser(...)` / `supabase.auth.admin.generateLink(...)` using the provided email (line 88-128).
- **Impact**: An attacker can POST `{ access_token: 'anything', user_info: { id: '123', email: 'victim@example.com', nickname: 'x' } }` to this public endpoint and log in as any existing Kakao-linked user (or create an account bound to anyone's email). Complete account takeover for all Kakao-auth users.
- **Remediation**: Call `GET https://kapi.kakao.com/v2/user/me` with the supplied `access_token` and compare `id` with `user_info.id` before doing anything. Same pattern as naver-oauth already does (`supabase/functions/naver-oauth/index.ts` calls `openapi.naver.com/v1/nid/me` — see line 21).

---

## 7. Llama.rn On-Device Model

- **Source**: `https://huggingface.co/unsloth/...` (Gemma 4, Phi-4-mini, Qwen3) — reputable HF org. HTTPS only.
- **Integrity**: size-threshold check only (`on-device-llm.ts:263-266`). Add SHA-256 hash verification for defense-in-depth. [LOW]
- **Prompt data leakage**: on-device model runs locally; prompts never leave device. No PII forwarded to external servers in the on-device code path.
- **Storage**: model file lives in `FileSystem.documentDirectory` area, no explicit sandbox concerns.

---

## 8. Push Notifications

- `supabase/functions/_shared/notification_push.ts` uses Expo Push endpoint `https://exp.host/--/api/v2/push/send` (line 6).
- Function requires `supabase: SupabaseClient, userId, params` — callers pass a **service-role** `SupabaseClient` instance.
- Callers found: `character-chat/index.ts:2277` — only runs for authenticated users (`if (shouldSendPush && userId && supabase)`, userId from JWT, not body).
- **No rate limiting** visible. An authenticated user spamming character-chat could in principle trigger many pushes to themselves; mitigated by the chat cost (token consumption) — acceptable. [LOW]
- **No direct /send-push endpoint exposed** to clients. Good.

---

## 9. File Uploads (Face Reading, Avatars, Talismans)

### [MEDIUM] `profile-images` bucket is **public**
- `supabase/migrations/20250929130000_create_storage_buckets_and_policies.sql:13-20` — `public=true`, 5MB limit, image/jpeg|png|webp.
- Line 63-67: `CREATE POLICY "Public access to profile images" ... FOR SELECT USING (bucket_id = 'profile-images')` — any unauthenticated user with a URL can read any profile image. Standard pattern but means deleted users' faces may remain cached publicly on Supabase CDN.
- **[MEDIUM] No retention policy / auto-delete** on profile images. Privacy: once a user deletes their account, their previously uploaded face images should be purged. Couldn't find a cleanup hook in `supabase/functions/delete-account/index.ts`. Verify.

### [PASS] Face-reading photos NOT persisted
- `supabase/functions/fortune-face-reading/index.ts` takes `imageBase64` in request body, passes to Gemini, never writes to storage (no `storage.from().upload` call in the file). Photo lives in memory for the request duration only.

### Other uploads (all service-role, server-side generated images)
- `generate-talisman/index.ts:472` — server-generated talisman → storage
- `fortune-yearly-encounter/index.ts:853` — server-generated
- `generate-character-proactive-image/index.ts:263`, `generate-friend-avatar/index.ts:184`, `fortune-past-life/index.ts:2257` — server-generated avatars

These are not user-uploaded content, lower risk. Confirm those buckets are scoped correctly.

---

## Summary of Ship-Blocking Items (CRITICAL / HIGH)

| Severity | Issue | Location |
|----------|-------|----------|
| **CRITICAL** | Kakao OAuth accepts unverified `access_token` — account takeover | `supabase/functions/kakao-oauth/index.ts:56-128` (public, verify_jwt=false) |
| **HIGH** | Edge functions trust `body.userId` for user-scoped writes | `supabase/functions/fortune-tarot/index.ts:419-527`, `widget-cache/index.ts:49` |
| **HIGH** | Celebrity/talisman/widget-cache tables allow RLS `UPDATE USING (true)` | See migrations listed in §2 |
| **HIGH** | Real service_role key + JWT secret on disk in `.env.local` | `/Users/injoo/Desktop/Dev/fortune/.env.local` (rotate) |
| **MEDIUM** | LLMFactory bypass via direct Gemini fetch | `fortune-past-life`, `fortune-yearly-encounter`, `speech-to-text` |
| **MEDIUM** | `profile-images` public bucket + no retention on account delete | `supabase/migrations/20250929130000_*.sql`, `delete-account/index.ts` |
| **MEDIUM** | `llm_model_config` / `llm_guard` tables readable by any user | `supabase/migrations/20251126100000_*.sql`, `20260310000001_*.sql` |
| **LOW** | On-device model downloads lack hash verification | `apps/mobile-rn/src/lib/on-device-llm.ts:263-266` |
| **LOW** | `generate-talisman` instantiates `OpenAIProvider` directly (not via factory) | `supabase/functions/generate-talisman/index.ts:230-241` |
| **LOW** | Transfer bundle snapshot on disk contains older env files | `/Users/injoo/Desktop/Dev/fortune/fortune-transfer-bundle-20260409/repo/` |

### Clean
- No secrets in client bundle
- Anon key used client-side; SecureStore for sessions
- Apple Sign-In nonce correct
- No WebView/eval/SQL injection
- No cleartext HTTP
- Face-reading photos not persisted
- JWT verify default-on for all functions except explicit OAuth bridges
