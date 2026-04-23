# P8 / B4 — Security Review (Edge Function body.userId 제거)

**Verdict: PASS-WITH-CAVEAT**

Scope: `_shared/auth.ts` (new helper), `fortune-tarot`, `fortune-birthstone`, `widget-cache`, `_shared/middleware.ts`.

---

## Per-check findings

### 1. `deriveUserIdFromJwt` correctness — PASS
`_shared/auth.ts:12-29`. Early returns `null` when header missing or bearer empty; uses `supabase.auth.getUser(token)` (the only trusted path); returns `user?.id ?? null`. No path can return a non-UUID string or leak body content. Matches the pattern of the existing `authenticateUser` helper (same file, lines 31-68). No secret leakage, no fallback to body.

Minor: when `getUser` throws network-side, the promise rejects and bubbles up. Acceptable — callers that want "guest on failure" (fortune-tarot) wrap with `?? 'anonymous'`; if rejected it short-circuits to the outer 500 catch, which is the safe default.

### 2. `fortune-tarot` — PASS
`fortune-tarot/index.ts:422` now reads `const userId = (await deriveUserIdFromJwt(req)) ?? 'anonymous'`. Grep for `body.userId`, `body.user_id`, `body['userId']`, `body.answers?.userId`, `body.answers?.user_id` returns **zero matches** in this file. Downstream uses of `userId` (`UsageLogger.log` line 525, `saveToCohortPool` line 533, cohort filter) all accept a string — `'anonymous'` is a benign aggregated bucket (no FK constraint fires because cohort pool and usage-logger treat it as a string key).

### 3. `fortune-birthstone` — PASS
`EdgeHandlerContext<TBody>` does expose `req: Request` (`middleware.ts:30-35`). Handler destructures `{ body, req, requestId }` (line 218) correctly. `userId: await deriveUserIdFromJwt(req)` at line 262 replaces the old `body.userId ?? null`. The `BirthstoneRequest.userId?` type field is kept (line 15) with a comment that it's ignored — acceptable backward-compat marker, no runtime read anywhere.

### 4. `widget-cache` — PASS
Now requires JWT via `authenticateUser` (line 53). Rejects with 401 on missing/invalid token. Query filter is `.eq('user_id', userId)` where `userId = user.id` (line 60) — cannot be spoofed. No other body field is security-sensitive; the function only uses auth'd user + Korea-time date math. **Cross-user PII leak (scores / lotto / lucky items) is no longer possible.**

### 5. Backward compatibility (RN client) — PASS
`apps/mobile-rn/src/features/chat-results/edge-runtime.ts:184-187` still writes both `payload.userId = userId` and `payload.user_id = userId`. Edge functions now silently ignore these — extra fields on a JSON body are no-ops. No client changes needed.

### 6. Widget breakage — CAVEAT (non-blocking)
Grep confirms **no active consumer** of `widget-cache` in the codebase:
- RN app: zero imports of `widget-cache` (only a `/widgets` showcase route exists; no `supabase.functions.invoke('widget-cache')` call).
- iOS: `apps/mobile-rn/ios/` has no WidgetKit extension target (`app`, `app.xcodeproj`, `Pods` only).
- The only writer is `fortune-daily/index.ts:1917` (`saveWidgetCache` — service role, server-side, unaffected).

**Ship-safe**, but when the iOS widget extension lands, it MUST:
1. Share the Supabase access token via App Group or Shared Keychain.
2. Send `Authorization: Bearer <access_token>` on every `widget-cache` call.
3. Handle 401 by surfacing a "re-open app to refresh" state instead of crashing.

Recommend adding a line to `docs/design/WIDGET_ARCHITECTURE_DESIGN.md` noting the JWT requirement before any widget extension PR.

### 7. Regression sanity — PASS
`UsageLogger.log({ userId, ... })` and `saveToCohortPool(..., cohortHash, cohortData, normalized)` both accept `userId` as a string. `'anonymous'` already appeared previously in the fallback chain (`... ?? 'anonymous'`), so DB schemas accept it. No new nullability issue introduced.

### 8. Cross-check — 14 other functions use `supabase.auth.getUser`
`character-chat`, `soul-refund`, `character-conversation-save`, `character-conversation-load`, `subscription-activate`, `payment-verify-purchase`, `token-balance`, `subscription-status`, `soul-earn`, `soul-consume`, `profile-completion-bonus`, `generate-fortune-story`, `calculate-saju` — these already follow the JWT-only pattern. Consistent with the new helper. (Opportunity: refactor them to use `deriveUserIdFromJwt`/`authenticateUser` where they currently inline the logic — follow-up, not in scope.)

Global grep for `body.userId` / `body.user_id` / `body.answers?.userId` across `supabase/functions/` returns **only the two comments we authored** (`fortune-birthstone` header + inline note) plus the helper docstring and the widget-cache security comment. No residual anti-pattern read paths remain in the three in-scope files.

### 9. Guest flow for `fortune-tarot` — PASS
No Authorization header ⇒ `deriveUserIdFromJwt` returns `null` at line 14 ⇒ `userId` becomes `'anonymous'`. Downstream cohort/usage paths execute normally. Guest tarot preserved.

### 10. Type check (manual) — PASS
- All imports resolve (`deriveUserIdFromJwt` from `../_shared/auth.ts`; `withEdgeFunction` from `../_shared/middleware.ts`).
- `EdgeHandlerContext<BirthstoneRequest>` properly exposes `req` — destructure on line 218 type-checks.
- `Deno.env.get('SUPABASE_URL')!` non-null assertion is consistent with existing file conventions.
- `deriveUserIdFromJwt` returns `Promise<string | null>` — `??  'anonymous'` narrows to `string`; `userId: await deriveUserIdFromJwt(req)` assigns `string | null` which matches the field usage.

No obvious Deno type errors.

---

## Residual concerns

1. **Widget extension future work** — documented above (CAVEAT #6).
2. **Follow-up sweep (out of scope per contract)** — the contract lists these as deferred; confirming they still have the anti-pattern and should be tracked as a next sprint:
   - `fortune-talent`, `fortune-wealth`, `fortune-investment`, `fortune-blind-date`, `fortune-avoid-people` — cache-key uses body-supplied identifiers. Low-risk (no cross-user DB read), but spoof-able usage attribution. Tag FORT-TBD.
   - `fortune-past-life`, `fortune-yearly-encounter`, `speech-to-text` — LLMFactory bypass (P9/W4).
3. **Minor nit (non-blocking)**: in `fortune-birthstone`, `deriveUserIdFromJwt(req)` is called inside the handler return block. If this becomes hot, consider awaiting once near the top of the handler rather than inline inside the response construction — purely stylistic, no security impact.
4. **Nit**: `widget-cache/index.ts` requestBody JSDoc (lines 9-11) still advertises `userId: string` as the request body. Update the comment to reflect that the body is now empty and auth is header-only, so future integrators don't re-introduce the anti-pattern.

---

## Quality gates
- [x] RCA accurate (prototype guest fallback never got hardened post-auth).
- [x] Discovery: existing `authenticateUser` pattern reused, no new auth stack introduced.
- [x] `npx tsc` not required for Deno functions; manual type-check clean.
- [x] Impersonation / spoof attack surface closed on all three files.

**Recommendation: ship.** Address nits #3 and #4 opportunistically; track follow-up #2 as a separate security-sweep sprint.
