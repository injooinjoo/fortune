# P11-B2 Principal Review — UGC Moderation / Report / Block

**Verdict: PASS-WITH-CAVEAT**

Implementation is App Store 5.2.3 ship-ready. No blockers for submission. Three minor caveats should be fixed in a follow-up PR, but none of them would cause an Apple rejection.

---

## 1. SQL migration — PASS

- RLS on `message_reports`: `mr_insert_self` (WITH CHECK `auth.uid() = reporter_id`) + `mr_select_self` (USING). UPDATE/DELETE intentionally missing, so only `service_role` can change state/status. Correct — reviewers cannot rewrite their own report status.
- RLS on `character_blocks`: `FOR ALL` with both USING and WITH CHECK on `auth.uid() = user_id`. Correct — self-serve block/unblock.
- `moderation_flags`: RLS enabled but zero client policies, so anon/authenticated roles have no access. Only `service_role` via Edge Function writes. Correct for an audit table.
- CHECK constraints: `reason_code` and `status` are whitelisted (enum-like); `source` on flags constrained. Cascade deletes on `auth.users` work. Covers the delete-account flow independently of `DELETE_TARGETS`, which is a good belt-and-suspenders.
- Indexes: `idx_message_reports_reporter` (reporter lookup) and partial index on `status='pending'` (operator queue). `idx_moderation_flags_flagged` partial. Hot paths covered.

No issues.

## 2. moderation.ts — PASS

- Fail-open on every error path (non-200, thrown fetch, empty results). Confirmed: `evaluated:false`, `flagged:false` always returned. No UX block if OpenAI is down.
- Kill switch: `MODERATION_ENABLED !== 'false'` — safe default-on; can disable without redeploy.
- Cache key `${source}:${sha256(trimmed)}` — no raw text retained in map key, no PII leak across requests beyond a 256-entry LRU per Deno isolate. Trimmed-only; whitespace variants would hit separate entries but that's acceptable.
- Audit log is fire-and-forget (`void writeAuditLog(...)`) — doesn't block response. Only writes when `evaluated:true` (skips noise from disabled/missing-key paths).
- Input truncated to 4000 chars before API call; `text_sample` truncated to 500 before DB write.

**Caveat (minor, non-blocking):** The `moderation_flags` partial index `(flagged, created_at) WHERE flagged = true` is useful, but the `user_id` FK is `ON DELETE SET NULL` — so after a user is deleted, their flag history survives with `user_id=NULL`. That's likely the intent for safety investigation, but it's worth confirming this aligns with GDPR/ASC privacy copy ("we keep abuse signal even after account deletion"). Not a blocker, but a policy document update may be needed.

## 3. report-message Edge Function — PASS

- `authenticateUser` → 401 if JWT missing/invalid. Correct.
- `reporter_id` comes from the verified `user.id` (not body). Body-provided `reporter_id` ignored entirely. Correct.
- RLS-enforcing client: uses `SUPABASE_ANON_KEY` + user's `Authorization` header in `global.headers`. RLS `WITH CHECK auth.uid() = reporter_id` will run. Correct pattern (NOT service_role). This is defense-in-depth: even if code were buggy and set `reporter_id` wrong, RLS would reject.
- `reason_code` validated against `ALLOWED_REASON_CODES` Set (matches DB CHECK). Double-layered validation — client, edge, DB.
- Length caps: `message_text` 4000, `reason_note` 500, `message_id` 200, `character_id` 200. All truncated before insert.
- Response payload safe, no PII echo.

No issues.

## 4. character-blocks.ts client — PASS

- Uses the anon `supabase` client, RLS enforces ownership. Session guard returns early when no session — which just no-ops block/unblock/fetch. That's acceptable — guest users don't have persisted blocks.
- `fetchBlockedCharacterIds` filters `.is('unblocked_at', null)` — correct (returns only active blocks).
- `useBlockedCharacterIds` uses cancellation token. No real-time subscription — intentional. Trade-off: after unblock from a settings screen, list won't reactively update until navigation causes a remount. Acceptable for MVP (Apple reviewer never sees this).

**Caveat (minor):** If a user calls `blockCharacter` from the profile screen, the chat screen's `firstRunCharacters` memo doesn't refresh until the chat tab remounts. The current flow calls `router.replace('/chat')` after block, which triggers remount — so the Apple reviewer flow works. But internally, if a user navigates back via swipe or gesture (no remount), they'd still see the blocked character briefly. Low risk; flag for follow-up to add a pub/sub or increment-key invalidator.

## 5. message-report-sheet.tsx — PASS

- `supabase.functions.invoke` — supabase-js auto-attaches `Authorization: Bearer <session.access_token>`. Correct.
- State reset: `setSelected(null)` is called AFTER Alert.alert success — good. `submitting` reset in `finally`. However: if user closes modal without submitting, `selected` persists across opens because the component isn't unmounted (Modal toggles `visible`). Not a bug, just slightly surprising UX. **Caveat — minor**: consider resetting `selected` in an effect keyed to `visible`.
- Accessibility: no `accessibilityRole="button"` / `accessibilityLabel` on the reason chips. The long-press Pressable in chat-surface has them. Apple reviewer won't fail for this (not a blocker), but VoiceOver users get a worse experience. **Caveat — minor non-blocking.**
- Error handling: `captureError` + Alert fallback. `supabase.functions.invoke` error shapes — `error` can be non-null even when response succeeds; we also check `!data?.success`, which correctly covers the Edge Function's `{ success: true, ... }` shape. Good.

## 6. character-chat moderation hooks — PASS

- Input check runs AFTER `userId` resolution — audit log properly linked to user. Correct.
- Short-circuit response: all required `CharacterChatResponse` fields present — `success`, `response`, `segments` (non-empty array `[SAFETY_BLOCK_FALLBACK_RESPONSE]`), `emotionTag`, `delaySec`, `affinityDelta`, `meta`. I cross-checked `normalizeStoryChatResponse` in `story-chat-runtime.ts`: it requires `response: string (non-empty)`, synthesizes `segments` from response if absent, and tolerates missing `followUpHint`/`romanceStatePatch`. **The safety short-circuit payload satisfies all invariants** — no silent error in the client.
- `affinityDelta.points: -3` — reasonable punitive signal but not hostile. Reason `safety_blocked` is a new reason string; existing code just stores it as-is (no enum crash).
- Output moderation replaces `responseText` only — preserves `affinityDelta`, segments synthesis logic downstream, romance state patch. Safe.
- Both checks fail-open. Confirmed.

No issues.

## 7. chat-surface long-press — PASS

- Scoped correctly: `text` kind + `assistant` sender + non-empty trimmed text. System cards, user bubbles, result cards, survey widgets all excluded.
- Default `delayLongPress=500ms` — matches iOS HIG; scroll won't misfire. `android_ripple={null}` keeps visuals consistent.
- Accessibility: `role="button"` + `label="메시지 길게 눌러 신고"`. Good.
- Pressable wrapping doesn't break existing bubble layout (wraps at the outer View, not inside).

## 8. character-profile block button — PASS

- Gated on `!isFortune` — fortune (insight) characters hidden correctly.
- Alert.alert confirmation with `destructive` style for primary action.
- Post-block `router.replace('/chat')` triggers list remount → blocked character disappears without stale state. This is the critical UX for the reviewer walkthrough.
- Error path: generic alert + no state pollution.

## 9. chat-screen list filter — PASS

- `useBlockedCharacterIds` runs once per mount. Memo correctly keyed on `(tabCharacters, blockedCharacterIds)`. Short-circuits when Set is empty (cheap path for 99% of users).
- `characterListMetaById` rebuilt from `firstRunCharacters` (not `tabCharacters`), so blocked-character metadata never leaks.

## 10. delete-account — PASS

- `message_reports` uses explicit `column: 'reporter_id'`. Matches schema.
- `character_blocks` uses default `user_id`. Matches schema.
- Both placed before `user_profiles` and inside the RLS-bypassing `service_role` client, so cascade works regardless of RLS. And the schema-level `ON DELETE CASCADE` on `auth.users` FK is a second safety net.

## 11. Apple reviewer walkthrough — PASS

Flow:
1. Open chat → send message → receive AI reply
2. Long-press AI bubble (500ms) → sheet slides up with 6 reasons + label explaining 24h review
3. Tap reason → "신고하기" → success alert "24시간 이내 검토"
4. Back to chat → tap character avatar → profile → scroll to "안전 도구" → "이 캐릭터 차단하기" → Alert confirm → replaced to `/chat` → character gone

Discoverability: Long-press is standard iOS pattern (iMessage, WhatsApp, KakaoTalk all use it for message actions). Block button is in a clearly labeled "안전 도구" card on every non-system character profile. **ASC reviewer notes should explicitly call out both paths** — recommend adding a screenshot of each to the submission.

## 12. Edge cases — PASS

- Guest user → 401 → generic alert. Acceptable (guests shouldn't be able to chat in prod anyway).
- Blocked character direct URL → chat screen still renders for that character. This is a gap — blocked filter is list-only, not route-guard. **Caveat — non-blocking**: Apple's 5.2.3 test focuses on discoverability of block/report, not whether a determined user can reach a blocked character via deeplink. Add a route-level guard in a follow-up sprint.

## 13. Deno type safety — PASS

Import paths resolve (`_shared/moderation.ts`, `_shared/auth.ts`, `_shared/cors.ts`). Types consistent between edge modules and client `ChatShellMessage`. `CharacterChatResponse` type extended implicitly via `meta.safetyBlocked`/`safetyReason` — already `Record<string, unknown>` tolerant in the existing shape.

---

## Caveats (all non-blocking, follow-up eligible)

1. **MessageReportSheet `selected` not reset on close** — cosmetic. Reset in `useEffect(..., [visible])`.
2. **Reason chips missing accessibilityRole/Label** — VoiceOver quality-of-life.
3. **No route guard on blocked character chat screen** — determined user could reach via deeplink. Apple reviewer flow unaffected.
4. **No real-time invalidation** of `useBlockedCharacterIds` — works because `router.replace('/chat')` remounts. Document this coupling.
5. **moderation_flags retention after account deletion** (`ON DELETE SET NULL`) — confirm policy language matches privacy doc.

## Blockers

None. Ship it.
