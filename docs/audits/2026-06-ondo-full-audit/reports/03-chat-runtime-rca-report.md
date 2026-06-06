# Chat Runtime RCA Reviewer QA Report

## Verdict
- **NO-GO**
- 핵심 리스크: 현재 채팅 성공 기준인 **“새 unique message → 새 assistant reply → 실제 화면 표시”**가 서버/클라이언트 양쪽에서 완전히 보장되지 않습니다. 특히 `character-chat` direct immediate 경로는 job을 `done` 처리하기 전에 canonical `character_conversations` 저장을 보장하지 않고, 모바일은 토큰을 먼저 차감한 뒤 실패/앱 종료 시 환불·서버 저장 보장이 약해 **토큰 손실 + 답장 누락** 가능성이 있습니다.

## Scope / Method
- 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/03-chat-runtime-rca.md`
- 조사 범위:
  - Mobile RN chat runtime: `apps/mobile-rn/src/screens/chat-screen.tsx`, `apps/mobile-rn/src/lib/*`, push/bootstrap/store 경로
  - Supabase Edge Functions: `character-chat`, `process-pending-reply-jobs`, `claim-scheduled-reply`, `deliver-due-replies`, `_shared/pending_reply_delivery.ts`
  - DB schema/migrations: `pending_character_reply_jobs`, `scheduled_character_replies`, cron/RLS/RPC
  - 기존 계획/테스트/문서: `plans/character-chat-server-side-reply.md`, scheduled/pending helper tests
- 코드 수정은 하지 않았고, 이 markdown 보고서만 작성했습니다.
- Live DB/실기기/APNs 검증은 수행하지 못했습니다. `supabase status`는 로컬 Docker 미실행으로 실패했습니다: `Cannot connect to the Docker daemon at unix:///var/run/docker.sock.` 따라서 DB row/log 증거는 **실제 row가 아닌 schema/코드상 추적 가능성 및 검증 SQL**로 분리합니다.

## P0

### P0-1. 토큰 선차감 후 답장/저장 실패 시 환불 경로가 없어 결제성 자산 손실 가능
- **Impact**: 체크리스트 심각도 기준상 “결제/토큰 손실”은 P0입니다. 사용자가 메시지를 보낸 직후 앱 종료, 네트워크 실패, `character-chat` 실패, 또는 client-owned immediate response 저장 실패가 발생하면 토큰은 이미 차감됐지만 새 assistant reply가 canonical DB/화면에 없을 수 있습니다.
- **Evidence**
  - 모바일 일반 story chat 전송은 optimistic user message를 먼저 store에 넣습니다: `apps/mobile-rn/src/screens/chat-screen.tsx:3407-3409`.
  - 이후 session이 있으면 `character-chat` 호출 전에 토큰을 차감합니다: `apps/mobile-rn/src/screens/chat-screen.tsx:3543-3551`.
  - `consumeRemoteTokens`는 `soul-consume`을 호출해 차감하고 transactionId만 반환합니다: `apps/mobile-rn/src/lib/premium-remote.ts:329-401`.
  - 환불 함수는 존재하지만, `chat-screen.tsx`에서 `refundRemoteTokens` 사용 검색 결과가 없습니다. `refundRemoteTokens` 정의: `apps/mobile-rn/src/lib/premium-remote.ts:404-473`.
  - character-chat 서버 direct immediate 경로는 canonical persist 없이 push/mark done/response로 종료됩니다: `supabase/functions/character-chat/index.ts:3748-3768`.
  - 모바일 catch에서 네트워크/서버 실패는 user message rollback만 하고 환불 호출은 없습니다: `apps/mobile-rn/src/screens/chat-screen.tsx:3936-3948`.
- **Likely root cause**: 결제성 토큰 차감이 “reply canonical persistence 성공”이 아니라 “LLM 호출 전”에 client-owned flow에서 발생합니다. 실패 보상(refund) 또는 서버 단일 트랜잭션/상태 연계가 없습니다.
- **Repro steps**
  1. 유료/토큰 보유 계정으로 캐릭터 채팅방 진입.
  2. 메시지 전송 직후 네트워크 차단 또는 앱 force kill.
  3. `soul-consume` 성공 후 `character-chat` 응답/저장 전 실패를 유도.
  4. 앱 재실행 후 토큰 잔액과 `character_conversations.messages` assistant row 존재 여부 비교.
- **DB/log verification**
  ```sql
  -- 차감 여부
  select id, user_id, fortune_type, reference_id, amount, created_at
  from token_transactions
  where user_id = '<user_id>' and fortune_type = 'character-chat'
  order by created_at desc
  limit 20;

  -- 해당 user message 이후 assistant canonical 저장 여부
  select id, user_id, character_id, messages, updated_at
  from character_conversations
  where user_id = '<user_id>' and character_id = '<character_id>';
  ```
- **Fix direction**
  - 최소: `characterConsumeKey`를 catch/failure/no visible reply 경로에 보존하고 `refundRemoteTokens(..., reason: 'character_chat_reply_failed')` 호출.
  - 권장: 토큰 차감을 서버 delivery lifecycle에 묶어 `canonical persist 성공 → token finalize`, 실패 시 retry/refund가 가능하도록 idempotent transaction을 `jobId`/`userMessageId`와 연결.
- **Validation**
  - “토큰 차감 row 있음 + assistant row 없음” 케이스가 더 이상 발생하지 않는지 staging fault injection.
  - 앱 kill/network loss 후 토큰 balance가 복구되거나 job retry로 assistant row가 생기는지 확인.

## P1

### P1-1. Direct immediate `character-chat` 경로가 job `done` 전에 canonical assistant message 저장을 보장하지 않음
- **Impact**: “푸시는 왔는데 방에 없음”, “job은 done인데 답장 없음”, “리스트/방 불일치”의 핵심 구조적 원인입니다. 서버가 `done` 처리하면 cron worker가 재시도할 수 없는데, direct response를 받은 client가 앱 종료/네트워크 손실로 local append/save를 못 하면 canonical assistant row가 없습니다.
- **Evidence**
  - scheduled reply 운영 기본은 real-phone 회귀 때문에 disabled입니다: `supabase/functions/character-chat/index.ts:3686-3692`.
  - scheduled disabled direct path에서 서버는 push만 보내고 canonical conversation merge를 하지 않습니다: `supabase/functions/character-chat/index.ts:3748-3764`.
  - 바로 이어서 “답장 생성/스케줄/푸시 모두 끝”으로 보고 job을 `done` 처리합니다: `supabase/functions/character-chat/index.ts:3766-3768`.
  - 반면 cron worker 경로는 canonical delivery helper를 통해 persist 후 retry 판단을 합니다: `supabase/functions/process-pending-reply-jobs/index.ts:157-188`.
  - helper는 jobId를 stable message id로 사용하고 canonical persist를 수행합니다: `supabase/functions/_shared/pending_reply_delivery.ts:62-77`, `:150-169`.
  - 모바일 direct path는 response를 받은 뒤 delayed render 후 `saveCharacterConversation`을 fire-and-forget으로 호출합니다: `apps/mobile-rn/src/screens/chat-screen.tsx:3843-3881`.
- **Likely root cause**: 같은 pending job을 처리해도 `character-chat` direct invoke와 `process-pending-reply-jobs` worker가 delivery ownership이 다릅니다. worker는 server-owned canonical delivery, direct invoke는 client-owned local render/save입니다.
- **Repro steps**
  1. `CHARACTER_CHAT_SCHEDULED_REPLIES_ENABLED`가 false인 운영 기본에서 로그인 사용자로 메시지 전송.
  2. `supabase.functions.invoke('character-chat')`가 시작된 직후 앱을 force kill.
  3. push 수신 여부, `pending_character_reply_jobs.status`, `character_conversations.messages` assistant row를 확인.
- **DB/log verification**
  ```sql
  select id, status, user_message_id, attempt_count, completed_at, error_message
  from pending_character_reply_jobs
  where user_id = '<user_id>' and character_id = '<character_id>'
  order by created_at desc
  limit 10;

  select messages, updated_at
  from character_conversations
  where user_id = '<user_id>' and character_id = '<character_id>';
  ```
- **Fix direction**
  - `character-chat` direct path에서도 `jobId`가 있으면 `deliverImmediateReplyIfNeeded`와 동일한 canonical persist를 수행한 뒤 `markJobAsDone()`.
  - persist 실패 시 `done` 금지, pending job을 retryable 상태로 남김.
  - push도 canonical serialized message payload를 사용해 list/room/push id가 동일하게 유지되도록 통일.
- **Validation**
  - fresh unique message별로 `pending job done`과 동일 id assistant message가 `character_conversations.messages`에 존재하는지 자동 SQL assertion.
  - force kill / background / foreground / cold start 실기기 APNs 시나리오.

### P1-2. `scheduled_character_replies` cron delivery가 canonical persist 전에 `delivered_at`을 찍어 retry 불가
- **Impact**: cron이 push를 보냈거나 delivery claim을 완료로 표시했지만, `merge_character_conversation_messages` 실패 시 방/list에 canonical message가 없습니다. 다음 cron은 `delivered_at NOT NULL`이라 재처리하지 않습니다.
- **Evidence**
  - `deliver-due-replies`가 먼저 `delivered_at`을 update하여 claim합니다: `supabase/functions/deliver-due-replies/index.ts:96-108`.
  - 그 다음에야 `persistAndPushScheduledReply`를 호출합니다: `supabase/functions/deliver-due-replies/index.ts:130-140`.
  - persist 실패 시 주석으로 “다음 cron에서는 delivered_at NOT NULL이라 스킵”을 명시합니다: `supabase/functions/deliver-due-replies/index.ts:141-148`.
- **Repro steps**
  1. staging에서 due scheduled row 생성.
  2. RPC 권한/페이로드 fault injection으로 `merge_character_conversation_messages` 실패 유도.
  3. `deliver-due-replies` 호출.
  4. scheduled row는 `delivered_at` set, conversation에는 assistant message 없음 확인.
- **Fix direction**
  - `delivered_at`은 terminal success 상태로만 사용.
  - 별도 `delivery_claimed_at`/`processing_at` 또는 advisory lock으로 claim하고, canonical persist 성공 후 `delivered_at` set.
  - persist 실패 시 `error_message`, `attempt_count`, `next_attempt_at` 등 retry state 추가.
- **Validation**
  - persist failure fault injection 후 row가 retryable 상태로 남고 다음 cron에서 재처리되는지 확인.

### P1-3. Foreground `claim-scheduled-reply`도 persist 전에 `client_acked_at`/`delivered_at`을 찍고 success를 반환
- **Impact**: active chat에서 “타이핑하다 bubble 표시 후 사라짐” 회귀와 직접 연결됩니다. 서버가 delivered로 응답해 typing은 꺼지지만 canonical persist가 실패하면 reload/list에서는 사라질 수 있습니다.
- **Evidence**
  - claim 단계에서 `client_acked_at`, `delivered_at`을 먼저 update합니다: `supabase/functions/claim-scheduled-reply/index.ts:160-174`.
  - 그 다음에 `persistScheduledReplyMessages`를 호출합니다: `supabase/functions/claim-scheduled-reply/index.ts:201-208`.
  - persist failure가 있어도 response는 `success: true`, `status: "delivered"`, `messages`, `persistError`를 반환합니다: `supabase/functions/claim-scheduled-reply/index.ts:210-223`.
  - `character-chat`에 real-phone hotfix 주석이 존재합니다: “타이핑하다가 bubble이 사라지는 회귀”, `client_acked_at`도 찍힘: `supabase/functions/character-chat/index.ts:3686-3689`.
- **Fix direction**
  - foreground claim도 persist 성공 후 terminal ack/delivered 처리.
  - persist failure는 `success:false` 또는 retryable status로 클라이언트가 fallback reload/retry를 수행하게 함.
- **Validation**
  - `claim-scheduled-reply` response의 `persistError`가 UI success로 처리되지 않는지 테스트.
  - real phone active chat에서 scheduled reply 표시 후 refresh/reopen해도 동일 message id가 유지되는지 확인.

### P1-4. 모바일 `daily_chat_limit_reached` 경로가 optimistic user message를 rollback하지 않음
- **Impact**: 사용자는 메시지가 전송된 것처럼 보지만 job/reply 없이 Alert만 뜹니다. 이후 재진입 시 stale user bubble이 남으면 “보냈는데 답이 안 옴”으로 인식됩니다.
- **Evidence**
  - optimistic user message append: `apps/mobile-rn/src/screens/chat-screen.tsx:3391-3409`.
  - 서버 invoke 후 `daily_chat_limit_reached`면 Alert 후 `return`: `apps/mobile-rn/src/screens/chat-screen.tsx:3683-3709`.
  - 이 분기에서는 `rollbackUserMessages(character.id, effectiveUserMessageIds)`가 호출되지 않습니다. 반면 token consume/network failure는 rollback 호출: `apps/mobile-rn/src/screens/chat-screen.tsx:3907-3912`, `:3940-3944`.
- **Repro steps**
  1. 무료 chat streak limit 초과 계정으로 story character에 메시지 전송.
  2. Alert 확인 후 bubble/list preview/앱 재시작 상태 확인.
  3. SQLite `chat_messages`에 해당 user id row만 있고 assistant row가 없는지 확인.
- **Fix direction**
  - limit response에서 draft 복구 + read timer clear + `rollbackUserMessages` 호출.
  - 또는 전송 전 quota/token availability preflight로 optimistic append 이전에 차단.
- **Validation**
  - limit 초과 전송 후 room/list/SQLite에 user bubble이 남지 않는지 확인.

## P2

### P2-1. 단일 진실 공급원(Single Source of Truth)이 아직 bridge 단계라 split-brain 위험이 남음
- **Impact**: 대부분 merge/dedupe 방어가 있지만 `messagesByCharacterId`, `MessageStore`, remote hydrate, push insert가 병존합니다. 특정 rollback/hydrate/readAt 순서에서 list preview와 room render가 달라질 수 있습니다.
- **Evidence**
  - 주석상 `send/append`는 여전히 useState가 source이고 store는 bridge sync입니다: `apps/mobile-rn/src/screens/chat-screen.tsx:510-531`.
  - 화면 read model은 MessageStore 우선, 신규/빈 store만 useState fallback입니다: `apps/mobile-rn/src/screens/chat-screen.tsx:1034-1047`.
  - store snapshot은 active thread에 union merge됩니다: `apps/mobile-rn/src/screens/chat-screen.tsx:532-568`.
  - push payload는 MessageStore에 직접 insert합니다: `apps/mobile-rn/src/lib/push-notifications.ts:166-248`, bootstrap foreground/tap handler `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:468-484`.
- **Fix direction**
  - write path를 MessageStore 중심으로 통일하고 useState는 순수 view cache로 축소.
  - list preview/room/unread/readAt 모두 동일 `getCanonicalVisibleMessages` 기반 selector를 사용하도록 audit.
- **Validation**
  - background push 수신 → 앱 아이콘으로 진입(알림 미탭) → list preview와 room의 latest id 비교.
  - remote hydrate 전/후, cold start 후, active foreground push 시 `message.id` 일치 검증.

### P2-2. `pending_character_reply_jobs` worker의 non-2xx application response 처리와 stuck recovery 지연
- **Impact**: cron-resumed job에서 `character-chat`가 429 daily limit 같은 application response를 반환하면 worker가 retry/failed loop로 처리할 수 있습니다. 또한 invoke exception 후 `processing`에 남으면 hourly recovery까지 침묵할 수 있습니다.
- **Evidence**
  - worker는 이미 claim한 뒤 `jobId`를 삭제하고 `trustedUserId`로 character-chat를 호출합니다: `supabase/functions/process-pending-reply-jobs/index.ts:103-126`.
  - invoke error는 retry 또는 failed로 전환합니다: `supabase/functions/process-pending-reply-jobs/index.ts:128-153`.
  - invoke exception은 row를 `processing`으로 남기고 recovery에 의존합니다: `supabase/functions/process-pending-reply-jobs/index.ts:236-245`.
  - direct character-chat daily limit은 jobId가 있을 때 `markJobAsDone()`을 호출하지만 worker path에서는 jobId가 삭제되어 해당 마킹이 불가능합니다.
- **Fix direction**
  - `character-chat` application-level failure(`daily_chat_limit_reached`, `superseded`, `noop`)를 worker가 명시적 terminal/retry policy로 분리.
  - stuck recovery를 매 tick 시작 시 수행하거나 recovery cron 주기를 5분 이하로 단축.
- **Validation**
  - free limit 초과 사용자의 pending job을 worker로 처리하고 `pending_character_reply_jobs.status/error_message/completed_at` 확인.

### P2-3. `scheduled_character_replies` lineage가 부족해 checklist의 row id/timestamp 추적성이 약함
- **Impact**: “새 unique message → 해당 assistant reply”를 SQL만으로 증명하기 어렵습니다. scheduled row에 `job_id`, `user_message_id`, `request_id`가 없어 user message와 reply의 관계가 간접적입니다.
- **Evidence**
  - scheduled table columns: `id`, `user_id`, `character_id`, `content`, `segments`, `deliver_at`, ack/delivered fields만 존재합니다: `supabase/migrations/20260427000001_scheduled_character_replies.sql:18-44`.
  - `character-chat` scheduled insert에도 lineage field가 없습니다: `supabase/functions/character-chat/index.ts:3715-3728`.
- **Fix direction**
  - `scheduled_character_replies`에 `job_id`, `user_message_id`, `request_id` 추가.
  - `llm_usage_logs.metadata`에도 동일 id들을 기록.
- **Validation**
  ```sql
  select column_name
  from information_schema.columns
  where table_name = 'scheduled_character_replies'
  order by ordinal_position;
  ```
  - fresh send 후 `user_message_id -> job_id -> scheduled_id -> assistant_message_id`가 한 쿼리로 이어지는지 확인.

### P2-4. `scheduled_character_replies` RLS update policy가 ack 범위보다 넓음
- **Impact**: “Users can ack own scheduled replies” 정책이 실제로는 authenticated user가 자기 scheduled row의 모든 update를 시도할 수 있는 형태입니다. 무결성/운영 추적성 리스크입니다.
- **Evidence**
  - RLS update policy: `FOR UPDATE USING (auth.uid() = user_id)`만 존재하고 column 제한/check가 없습니다: `supabase/migrations/20260427000001_scheduled_character_replies.sql:64-72`.
- **Fix direction**
  - 클라이언트 직접 table update를 금지하고 `ack-scheduled-reply` Edge Function만 허용.
  - 또는 update policy에 `WITH CHECK`/column privilege를 적용해 `client_acked_at` 외 변경을 막음.
- **Validation**
  - staging에서 authenticated anon client로 자기 row `content`, `deliver_at`, `delivered_at` update가 가능한지 시도.

## P3

### P3-1. pending 상태/confirmed 상태가 메시지 모델에 명시되지 않아 운영 RCA가 어려움
- **Impact**: optimistic append 후 rollback/delete 방식이라 “pending → confirmed” 전환을 UI/DB row로 추적하기 어렵습니다.
- **Evidence**
  - optimistic user message는 바로 final-looking message로 append됩니다: `apps/mobile-rn/src/screens/chat-screen.tsx:3391-3409`.
  - failure rollback은 delete/restore 중심입니다: `apps/mobile-rn/src/screens/chat-screen.tsx:3907-3948`.
- **Fix direction**
  - message payload에 `sendStatus: pending|confirmed|failed` 또는 별도 lifecycle log를 추가.
  - 최소 운영 로그에 `userMessageId`, `jobId`, `tokenReferenceId`, `assistantMessageId`를 함께 기록.
- **Validation**
  - offline/timeout/limit/normal path에서 각 status가 일관되게 전환되는지 테스트.

### P3-2. immediate worker delivery는 multi-segment 답장을 단일 canonical bubble로 합침
- **Impact**: scheduled path는 segment별 message id를 만들지만 immediate worker path는 jobId 하나에 segments를 `\n` join합니다. 기능 실패는 아니지만 UX/consistency 차이가 생깁니다.
- **Evidence**
  - immediate helper는 `jobId` 하나로 단일 message 생성: `supabase/functions/_shared/pending_reply_delivery.ts:62-77`.
  - segments는 `join("\n")`으로 합쳐집니다: `supabase/functions/_shared/pending_reply_delivery.ts:123-126`.
- **Fix direction**
  - immediate/scheduled 모두 같은 segment-to-message-id 규칙을 사용.
- **Validation**
  - `[SPLIT]` multi-bubble response를 immediate worker와 scheduled path에서 비교.

## Positive Evidence
- pending job 큐 구조는 존재하며 idempotent user message key와 cancel-and-replace 의도가 있습니다.
- worker-owned immediate delivery는 canonical persist + retry를 고려한 구조입니다: `supabase/functions/process-pending-reply-jobs/index.ts:157-218`.
- push payload가 message body/serialized scheduled messages를 담으면 MessageStore에 즉시 insert하고 id dedupe를 사용합니다: `apps/mobile-rn/src/lib/push-notifications.ts:166-248`.
- scheduled reply real-phone 회귀를 운영 기본 disabled로 막은 hotfix 주석이 있어, 위험 기능을 무조건 켜둔 상태는 아닙니다: `supabase/functions/character-chat/index.ts:3686-3692`.

## Evidence
- Checklist 기준:
  - user message save: `apps/mobile-rn/src/screens/chat-screen.tsx:3391-3409`
  - token precharge: `apps/mobile-rn/src/screens/chat-screen.tsx:3543-3551`
  - pending job enqueue: `apps/mobile-rn/src/screens/chat-screen.tsx:3626-3649`
  - direct `character-chat` invoke: `apps/mobile-rn/src/screens/chat-screen.tsx:3655-3660`
  - daily limit no rollback: `apps/mobile-rn/src/screens/chat-screen.tsx:3683-3709`
  - direct reply delayed render/save: `apps/mobile-rn/src/screens/chat-screen.tsx:3727-3890`
  - failure rollback without refund: `apps/mobile-rn/src/screens/chat-screen.tsx:3907-3948`
  - source-of-truth bridge comment: `apps/mobile-rn/src/screens/chat-screen.tsx:510-531`
  - MessageStore read priority: `apps/mobile-rn/src/screens/chat-screen.tsx:1034-1047`
  - push insert path: `apps/mobile-rn/src/lib/push-notifications.ts:166-248`, `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:468-484`
  - scheduled disabled / immediate server path: `supabase/functions/character-chat/index.ts:3686-3768`
  - worker canonical delivery: `supabase/functions/process-pending-reply-jobs/index.ts:157-218`
  - scheduled cron delivered-before-persist: `supabase/functions/deliver-due-replies/index.ts:96-148`
  - scheduled foreground claim delivered-before-persist: `supabase/functions/claim-scheduled-reply/index.ts:160-223`
  - scheduled schema/lineage/RLS: `supabase/migrations/20260427000001_scheduled_character_replies.sql:18-44`, `:64-72`
- Command evidence:
  - `git status --short` showed pre-existing dirty/untracked repo state including `docs/audits/` untracked.
  - `supabase status` could not inspect local stack because Docker daemon was unavailable.
- Missing live evidence:
  - No production/staging DB rows were queried in this run.
  - No simulator or real-device screenshot/logcat/APNs receipt was captured in this run.

## Recommended Fix Order
1. **P0 token loss guard**: tie `characterConsumeKey` to reply lifecycle; refund on invoke/persist/no-visible-reply failure, or move charging into server delivery transaction.
2. **P1 direct immediate canonical persistence**: in `character-chat`, if `jobId` exists, persist assistant reply through the same helper as `process-pending-reply-jobs` before `markJobAsDone()`.
3. **P1 scheduled terminal-state ordering**: change `claim-scheduled-reply` and `deliver-due-replies` so `delivered_at/client_acked_at` are not terminal before canonical persist succeeds.
4. **P1 optimistic rollback gaps**: add rollback/draft restore for `daily_chat_limit_reached` and any OnDeviceNotReady state-only rollback path.
5. **P2 observability lineage**: propagate `requestId`, `userMessageId`, `jobId`, `scheduledId`, `assistantMessageId` into DB rows and `llm_usage_logs`.
6. **P2 SOT hardening**: converge room/list/push/unread to one canonical MessageStore selector and remove useState write-source remnants.
7. **P2 DB policy/retry hardening**: tighten scheduled reply RLS, add retryable scheduled delivery state, shorten stuck job recovery.

## Open Questions
- 운영 Supabase에서 `CHARACTER_CHAT_SCHEDULED_REPLIES_ENABLED` 값은 실제로 false인가? 코드 기본값은 false이지만 live env 확인 필요.
- `soul-consume`의 `character-chat` 요율과 환불 정책은 현재 BM 정책과 일치하는가?
- production에서 `pending_character_reply_jobs` 중 `done`인데 `character_conversations.messages`에 assistant message가 없는 row가 존재하는가?
- real phone에서 “push arrived but room empty”가 direct immediate path인지 scheduled claim path인지, APNs payload의 `messageId/scheduledMessagesJson/scheduledId`를 수집해야 함.

## Required Real-Device / DB Validation Matrix
1. **Normal foreground**: fresh unique message → assistant reply → `pending job done` → canonical assistant row → room/list/unread same id.
2. **Force kill after invoke start**: token charged? job status? canonical assistant row? push payload? room on reopen?
3. **Daily limit**: no stale optimistic user bubble; no token charge; draft restored or clear UX.
4. **Push foreground active room**: MessageStore insert and active room render same id; no duplicate.
5. **Push background without tapping notification**: app icon open → list preview and room hydrate same latest id.
6. **Scheduled fault injection**: persist failure leaves row retryable, not delivered terminal.
7. **Token failure/reply failure**: refund or eventual assistant row is guaranteed.
