# Server-Side Character Reply Generation (A안)

## 문제

`apps/mobile-rn/src/screens/chat-screen.tsx:1030-1077` 의 자동 답장 재개가 클라이언트 `useEffect` 트리거 + `sendCharacterChatMessage`(line 2791) 가 `await supabase.functions.invoke('character-chat')` (line 2971) 로 동기적으로 묶여 있음.

증상: 유저가 send 직후 앱을 백그라운드/킬 → HTTP invoke 가 inflight 중 끊기거나 시작도 못 함 → 서버는 "답장해야 할 user 메시지가 있다"는 사실을 모름 → 다음 채팅방 진입 때까지 답장 생성 안 됨.

기존 자산: `scheduled_character_replies` + `deliver-due-replies` cron + push 인프라는 견고함. 끊긴 고리는 **생성 트리거**.

## 목표

유저가 send 한 시점부터 답장 생성/전달이 **앱 lifecycle 과 독립**적으로 진행되도록 함.

성공 기준:
1. 유저가 메시지 보낸 직후 앱 강제 종료 → 5분 내 푸시로 답장 도착
2. 정상 foreground 시나리오에서 기존 UX (즉시 typing → reply) 회귀 없음
3. 동일 user 메시지에 대해 답장 중복 생성/전송 없음 (idempotency)

## 설계

### 핵심 변경 1: user 메시지 DB 영속화

현재: `insertStoreMessages` 로 로컬에만 저장.
변경: send 직후 **`character_conversations` (또는 신규 테이블) 에 user 메시지 row INSERT**. 이게 backend 가 "답장 안 한 user 메시지" 를 인식할 single source of truth.

스키마 옵션:
- A. 기존 `character_conversations` 에 `last_user_message_id`, `last_user_message_at`, `last_user_message_text`, `pending_reply_status` 컬럼 추가
- B. 신규 `pending_character_reply_jobs` 테이블 (user_id, character_id, user_message_id, user_message_text, system_prompt_snapshot, status: pending/processing/done/failed, created_at, updated_at, attempt_count)

→ **B 선호**. 기존 테이블 침범 없음, 큐 패턴 깨끗, dedupe/retry 로직 단순.

### 핵심 변경 2: 클라 send 흐름

before:
```
client → invoke('character-chat') [await] → response → render
```

after:
```
client → INSERT pending_character_reply_jobs (user_message_id, ...) [await, 빠름]
       → invoke('character-chat', {jobId}) [fire-and-forget, race-tolerant]
       → push 또는 polling 으로 reply 수신
```

`invoke` 는 더이상 결과 대기 안 함. 성공/실패 무관. 서버측 Edge Function 은:
1. `jobs.status = 'processing'` 마킹 (이미 processing 이면 skip — dedupe)
2. LLM 생성 → `scheduled_character_replies` enqueue
3. `jobs.status = 'done'`

### 핵심 변경 3: 백엔드 backfill cron

신규 cron `process-pending-reply-jobs` (1분 주기):
- `pending_character_reply_jobs` 에서 `status='pending' AND created_at < now() - 30s` 스캔
- 각 row 에 대해 `character-chat` 직접 호출 (또는 인라인 LLM 호출)
- 30초 grace 는 정상 client invoke 경로가 먼저 처리하도록 양보

이게 진짜 "앱 죽어도 답장 생성" 보장.

### 핵심 변경 4: foreground UX 보존

기존 typing indicator + delaySec UX 유지:
- 클라가 `pending_character_reply_jobs.id` 를 받으면 typing 인디케이터 ON
- realtime 또는 폴링 (예: Supabase realtime on `scheduled_character_replies` insert WHERE user_id=me) 으로 reply 인지 → typing OFF + segment 렌더
- foreground 일 때는 server invoke 가 거의 즉시 완료되므로 체감 동일

대안: `invoke` 를 진짜 fire-and-forget 으로 두고 응답은 100% push/realtime 으로만 → 더 단순. 검토 필요.

## 마이그레이션 단계

1. **타입/스키마**: `pending_character_reply_jobs` 테이블 마이그레이션, RLS 정책, TS 타입
2. **Edge Function**: `character-chat` 입력에 `jobId` 옵셔널 추가, 시작/완료 시 jobs row 업데이트, idempotency 가드
3. **클라 send 핸들러**: `sendCharacterChatMessage` 를 job-INSERT-then-fire-and-forget 으로 리팩터, await 제거
4. **수신 경로**: realtime 또는 짧은 폴링 도입 (foreground reply 표시용)
5. **백필 cron**: `process-pending-reply-jobs` Edge Function + pg_cron 등록
6. **자동 재개 useEffect 정리**: chat-screen.tsx:1030-1077 은 "DB 에 pending job 이 없을 때만" fallback 으로 축소 (이상적으론 제거)
7. **테스트**:
   - foreground send → 즉시 answer (회귀 없음)
   - send 후 즉시 kill → 1~2분 내 push 도착
   - send 두 번 빠르게 → reply 두 개 (또는 cancel-and-replace 정책 일관성)

## 위험 / Codex challenge 대상

1. **Race**: 같은 user 메시지에 대해 client invoke 와 cron 이 동시에 처리하지 않게 — `jobs.status` UPDATE WHERE status='pending' RETURNING 패턴 (atomic claim) 필수
2. **realtime 비용/복잡도**: 새 realtime 채널 vs 기존 push-only 패턴 통일성 — push 만으로 foreground UX 가능한지?
3. **system prompt snapshot**: jobs 에 prompt 저장하면 캐릭터 페르소나 변경 시 stale 사용 — 매번 재구성?
4. **잠재 부하**: cron 1분 주기 + 30초 grace = 최악 90초 지연. 짧게 하면 race 위험 ↑
5. **삭제/취소 UX**: 유저가 send 후 즉시 다른 메시지 보내면 이전 job cancel? 둘 다 답장?
6. **jobs 테이블 보존 정책**: done/failed retention, 인덱스
7. **failure mode**: LLM 호출 실패 → retry 정책, 최대 attempt, 유저에게 노출 방식

## 비-목표 (이번 스코프 X)

- 먼저 말 걸기 (proactive) — `project_character_realtime_features.md` 우선순위 2
- 사진 전송
- 답장 딜레이 정책 변경
- fortune 캐릭터 (transactional 패턴이라 자동재개 의미 약함)

## 결정 (delegated to Claude)

1. **foreground UX 경로**: realtime 채널 추가 X. 클라 `invoke` 는 `await` 하되 **10초 timeout + try/catch swallow**. 응답 받으면 기존 segments 렌더 path 그대로. 실패/timeout/abort 시 무시 — server 측은 끊긴 HTTP 와 무관하게 끝까지 진행, push + cron 안전망이 답장 도달 보장. 결과적으로 foreground 시 UX 회귀 없음, background 시 push 로 도달.

2. **연속 send 정책**: cancel-and-replace. 같은 (user, character) 에 대해 `pending_character_reply_jobs.status='pending'|'processing'` row 가 있으면 새 send 시:
   - pending → 이전 job `status='canceled'` 마킹 + 새 job INSERT
   - processing → 이전 job 그대로 두되, 결과 `scheduled_character_replies` 도착 시 새 user 메시지가 더 최신이면 server 측에서 `canceled_at` 마킹 (기존 cancel 로직 재사용). 새 job 도 별도 진행
   
   즉 "한 답장은 가장 최신 user context 기준". 동시 답장 2개 X.

3. **system prompt**: jobs row 에 저장 안 함. cron/Edge Function 이 user_id + character_id 로 매번 재구성 (기존 character-chat 가 이미 그렇게 함). stale 위험 회피.

4. **cron 주기 / grace**: pg_cron 1 분 주기, grace 30 초. 최악 지연 ~90 초.

5. **retry**: LLM 실패 시 attempt_count++, max 3, exponential (1m / 5m / 15m), 초과 시 status='failed' + 클라엔 노출 안 함 (silent). 향후 알림 추가 검토.

6. **jobs 보존**: status in (done, failed, canceled) AND updated_at < now() - 7d → 같은 cron 에서 정리.

## 다음 액션

`/codex challenge` 2 회로 위 결정 반박 → 보강 → 단계별 구현.
