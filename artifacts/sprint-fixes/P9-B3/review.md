# P9-B3 Security Review — kakao-oauth

**Verdict: PASS-WITH-CAVEAT**

Impersonation vulnerability is closed. Two medium-severity account-merging concerns remain (documented below as caveats, not blockers for the CVE fix).

---

## 1. Impersonation closed — YES

Traced every email derivation path:

- `serve()` (index.ts:106-107): reads ONLY `access_token` from body. `user_info` is never destructured, never referenced.
- `fetchKakaoUser()` (index.ts:42-97): calls `https://kapi.kakao.com/v2/user/me` with Bearer token. If non-200 → returns null → caller returns 401. Email is derived solely from `payload.kakao_account.email` (Kakao-verified) or synthesized `kakao_${id}@kakao.local` where `id = String(payload.id)`.
- `existingUser` lookup (index.ts:149), `createUser` / `updateUserById` (index.ts:156,169), `generateLink` (index.ts:212) all consume `kakaoUser.email` only.

Exploit `{access_token:"x", user_info:{email:"victim@x.com"}}` now returns 401 because Kakao rejects the bogus token. **Impersonation path closed.**

## 2. Kakao API shape mapping — CORRECT

Parser is defensive against all realistic shapes:
- `payload.id` number → coerced via `String(rawId)`.
- `kakao_account` and `profile` are cast through `?? {}` guards — tolerates missing scopes.
- Nickname falls back profile → properties → null.
- Profile image falls back profile_image_url → properties.profile_image → null.

No shape I can construct from Kakao docs breaks parsing. One minor: `email_verified:false` users are still accepted (Kakao allows unverified email). Not exploitable here because the attacker cannot control which email Kakao returns for a valid token, but worth noting.

## 3. Missing-email fallback

`kakao_${id}@kakao.local` matches the legacy behavior (confirmed via git history patterns in naver-oauth which uses `naver_${id}@zpzg.co.kr`). The `id` is a stable Kakao user ID, so collision is impossible between Kakao users. Collision with a real user who happens to register `kakao_999@kakao.local` via another provider is theoretical but `.local` TLD is reserved so not a realistic attack vector.

## 4. Response body leak — CLEAN

Success response exposes only `{id, email, name, profile_image}` and session tokens — no Kakao raw payload, no stack trace. Error path returns generic Korean message; details go only to `console.error`. Naver-oauth legacy POST path leaks `error.message` in 500 body — kakao is stricter, which is good.

## 5. Rate limiting — CONCERN (not blocker)

Function is public (`verify_jwt=false`) and forwards every request to Kakao `/v2/user/me`. Attacker can use our endpoint as a validation oracle or to DoS our Kakao quota. **Recommendation**: add IP-based throttling at Supabase gateway or inside function (e.g., Redis counter). Track in a follow-up ticket — not required for this CVE fix since Kakao itself rate-limits per-token.

## 6. `crypto.randomUUID()` — OK

Deno Deploy / Supabase Edge Runtime ship `crypto.randomUUID()` (Web Crypto API, available since Deno 1.11). Strictly better than `Math.random().toString(36)` which is non-CSPRNG. Note: naver-oauth still uses the weaker `Math.random()` pattern (line 260) — worth aligning in a follow-up, but not regression-relevant here since the password is never used for login (magicLink flow).

## 7. **CAVEAT — kakao_id not required to match existing user's kakao_id**

Scenario: User A signed up via Kakao with kakao_id=1, email=shared@x.com. Attacker owns a different Kakao account with kakao_id=2 but Kakao-verified email=shared@x.com. Attacker's token passes Kakao validation → our code matches `existingUser` by email → `updateUserById` OVERWRITES `user_metadata.kakao_id` from 1 to 2 → attacker now has a valid session for User A.

**Likelihood**: low (Kakao requires email verification and email uniqueness at Kakao's side for most account states, but email changes can introduce collisions). 

**Fix**: before updating, if `existingUser.user_metadata.kakao_id` exists and differs from `kakaoUser.id`, reject with 409. Naver-oauth has the same issue — not a regression introduced by this PR.

Recommend: file follow-up ticket, mark this PR PASS-WITH-CAVEAT.

## 8. Legacy Flutter compat — OK

Request contract still accepts `{access_token, ...}` POST. `user_info` is silently ignored (comment says "deprecated"). Legacy clients that still send it won't break. Response shape unchanged (`success, user, session` or `success, user, needsManualAuth`).

## 9. Naver parity — PARTIAL

Divergences vs `naver-oauth/index.ts`:
- Kakao does NOT preserve `linked_providers` merge on update (index.ts:156-166 overwrites without reading existing `linked_providers`). Naver does (lines 222-229). **Regression risk**: a user who linked Kakao+Apple will lose `apple` from `linked_providers` on next Kakao login. Profile upsert (index.ts:201) hardcodes `linked_providers: ['kakao']` — **this overwrites and is a regression for multi-linked users.**
- Kakao hardcodes `primary_provider: 'kakao'` — naver preserves `existingProfile?.primary_provider || 'naver'`. Same regression: Apple-primary users get demoted to Kakao-primary on login.

This is a user-metadata correctness bug, not a security bug, but it conflicts with contract acceptance #5 ("existing upsert/session logic reused"). **Recommend fix before ship.**

## 10. Account merging via email

Kakao-oauth merging into an Apple-created account is behavior-preserving vs legacy (pre-fix code did the same). No new audit trail concern introduced.

---

## Open exploit paths after this fix

1. **kakao_id swap on shared email** (§7): medium — requires attacker to control a Kakao account with victim's email. Follow-up ticket.
2. **linked_providers clobber** (§9): regression, not exploit — breaks multi-provider account integrity.
3. **No rate limit on public endpoint** (§5): abuse vector, not auth bypass.

## Must-fix before ship

- §9: preserve `linked_providers` and `primary_provider` on existing users (align with naver-oauth pattern).

## Ship-blocking? 

The CVE (impersonation via body.user_info) is fully closed. §9 is a correctness regression that should be fixed in this PR or immediately after. §7 and §5 are acceptable follow-ups.

**Verdict: PASS-WITH-CAVEAT** — ship the security fix, address §9 in same sprint, file §7 and §5 as tickets.
