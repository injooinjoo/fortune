# Character chat SoT/no-reply RCA plan

## Goal
Fix the current Ondo character-chat regression where push notification, chat list preview, and actual chat room can diverge, and where replies can fail to appear or repeat fallback text.

## Acceptance criteria
- Push-arrived assistant messages, chat list preview, room body, unread/read state, active reconcile, and auto-resume decisions all read from the same canonical MessageStore/display selector.
- Sending a fresh unique message results in a new assistant reply visible after that exact message, not a repeated stale fallback bubble.
- No symptom-only sync effects; fix the source-of-truth/read-model divergence.
- Gates pass: diff check, mobile typecheck/tests/lint as available, relevant Deno checks if Edge code changed.
- Mobile-visible fix is committed, pushed, and shipped via EAS production OTA unless deployment is explicitly blocked.

## RCA approach
1. Inspect current dirty tree to avoid overwriting unrelated work.
2. Query recent production chat rows/jobs to separate backend generation failure from client render/state failure.
3. Trace write paths: push handler, scheduled reply claim, direct character-chat response, local optimistic send, SQLite MessageStore insert/dedup.
4. Trace read paths: chat list meta, selected room thread, unread/read state, scroll/latest logic, auto-resume, active reconcile polling.
5. Patch only the divergent paths so all UI-visible latest-message decisions use the canonical display read model.
6. Add/adjust tests around MessageStore/display model if a suitable local test seam exists.
7. Validate and deploy.

## Likely files
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/lib/message-store.ts`
- `apps/mobile-rn/src/lib/push-notifications.ts`
- `apps/mobile-rn/src/lib/pending-reply-resumer.ts`
- possibly `supabase/functions/character-chat/index.ts` / scheduled reply functions if DB proves backend no-reply rather than UI divergence

## Risks
- Dirty tree already contains other user/agent work; final commit/OTA must isolate this fix or use a clean worktree.
- Simulator success is not sufficient for acceptance because the reported failure is on a real phone with existing cache/OTA state.
