# Proactive Push Reviewer QA Report

## Verdict
- **조건부 GO**
- 핵심 리스크: 선톡 생성/저장/푸시/탭 이동의 기본 파이프라인은 운영 DB에서 동작 중이나, **앱 알림 설정 UI가 `character_proactive`를 제어하지 않아 사용자가 캐릭터 메시지를 꺼도 선톡 푸시가 계속 갈 수 있음**. 또한 Expo receipt 영속 추적이 없어 “DB에는 있는데 알림이 없었다” RCA가 제한된다.

## Scope / Method
- 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/05-proactive-push.md`
- 코드 수정 없음. 보고서 파일만 작성.
- 조사 대상:
  - Server dispatch/reveal/push: `supabase/functions/proactive-message-dispatch/index.ts`, `_shared/notification_push.ts`, `_shared/character_message_helper.ts`, `character-chat/index.ts`
  - DB schema/migrations: `supabase/migrations/20260426000001_proactive_messaging.sql`, `20260505100000_proactive_log_revealed_at.sql`, `20260512155000_proactive_dispatch_default_prefs_and_lunch_photo.sql`
  - RN push/UX path: `apps/mobile-rn/src/lib/push-notifications.ts`, `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx`, `apps/mobile-rn/src/screens/chat-screen.tsx`, `apps/mobile-rn/src/screens/profile-notifications-screen.tsx`
  - Production DB read-only queries via `supabase db query --linked`
  - Deno unit tests for proactive rules/push payload
- 실기기 푸시 수신/탭/foreground banner는 이번 실행 환경에서 수행하지 못함. 아래에 별도 실기기 검증 필요 항목으로 분리.

## P0
- 없음.

## P1

### P1-1. “캐릭터 메시지” 알림 OFF가 선톡(`character_proactive`) 푸시를 끄지 못함
- **영향**: 사용자가 앱 설정에서 캐릭터 메시지를 껐다고 인지해도 선톡 푸시가 계속 수신될 수 있다. 체크리스트의 “유저 알림 설정/선호가 반영되는가”, “부담스럽거나 스팸처럼 느껴지지 않는가”에 직접 위배된다.
- **증거**:
  - 서버는 일반 DM과 선톡 알림을 의도적으로 분리한다.
    - `supabase/functions/_shared/notification_push.ts:114-128` — `character_dm` vs `character_proactive` 별도 컬럼 설명 및 `getCharacterNotificationPreferenceColumn()`.
    - `supabase/functions/proactive-message-dispatch/index.ts:1099-1112` — dispatch 전 `user_notification_preferences.enabled, character_proactive`를 조회하고 `character_proactive === false`일 때만 선톡 푸시 skip.
    - `supabase/migrations/20260426000001_proactive_messaging.sql:98-130` — `character_proactive BOOLEAN NOT NULL DEFAULT true` 추가 및 “캐릭터 선톡 알림 별도 토글” 코멘트.
  - RN 알림 설정 화면은 `character_proactive`를 노출/동기화하지 않는다.
    - `apps/mobile-rn/src/screens/profile-notifications-screen.tsx:51-54` — UI 라벨 “캐릭터 메시지”, 설명 “캐릭터가 새 메시지를 보냈을 때”. 사용자는 선톡도 포함한다고 이해하기 쉽다.
    - `apps/mobile-rn/src/screens/profile-notifications-screen.tsx:151-160` — backend sync 매핑은 `characterDm: next.chatReminders`만 보내고 `characterProactive`/`character_proactive`는 전송하지 않음.
    - `supabase/functions/sync-notification-device/index.ts:6-13`, `153-167` — 서버 payload type에도 `characterProactive` 필드가 없고 upsert도 `character_dm`까지만 처리.
  - 운영 DB sample:
    - `/tmp/ondo-proactive-db-prefs.log` — `user_notification_preferences` sample row: `enabled=true`, `character_dm=true`, `character_proactive=true`.
- **재현 단계**:
  1. 실기기에서 로그인 후 프로필 → 알림 설정으로 이동.
  2. “캐릭터 메시지” 토글만 OFF, “일일 인사이트 알림”은 ON 유지 후 저장.
  3. DB에서 해당 user의 `character_dm=false`, `character_proactive` 값 확인.
  4. 선톡 슬롯 시각에 `proactive-message-dispatch`가 해당 user에 대해 push를 보내는지 확인.
- **수정 방향**:
  - UX를 둘 중 하나로 명확히 결정한다.
    1. 단일 “캐릭터 메시지” 토글이 답장+선톡 모두 끄는 정책이면 `sync-notification-device` payload/schema에 `characterProactive`를 추가하고 RN에서 `characterProactive: next.chatReminders`를 함께 전송.
    2. 답장/선톡을 분리할 정책이면 RN 알림 설정에 “캐릭터 선톡” 별도 토글을 추가하고 설명을 명확화.
  - 기존 유저의 의도 보정을 위한 migration/backfill 정책 필요: `character_dm=false`인 사용자의 `character_proactive`를 어떻게 처리할지 결정.
- **검증 방법**:
  - Unit/integration: `sync-notification-device`에 `characterProactive=false`를 보내면 DB `character_proactive=false`로 저장되는 테스트.
  - 실기기: 토글 OFF 후 강제 dry-run/운영 슬롯에서 push가 skip되고 `proactive_message_log.push_skipped_reason='character_proactive disabled'` 또는 동등 값인지 확인.

## P2

### P2-1. 같은 user/character/slot/date 중복 발송을 DB unique constraint로 막지 않음
- **영향**: 현재 코드는 발송 전 count 조회로 중복을 피하지만, cron overlap/수동 호출/네트워크 retry가 겹치면 같은 날짜·슬롯 선톡 row가 2개 이상 insert될 수 있다. “같은 메시지가 반복 발송되지 않는가”, “과도한 발송 방지” 체크리스트 리스크.
- **증거**:
  - check-then-insert 패턴:
    - `supabase/functions/proactive-message-dispatch/index.ts:817-834` — `proactive_message_log`에서 오늘 같은 slot count 조회 후 있으면 skip.
    - `supabase/functions/proactive-message-dispatch/index.ts:1127-1150` — 별도 transaction/unique 없이 insert.
  - 운영 DB constraints/indexes:
    - `/tmp/ondo-proactive-db-constraints.log` — `proactive_message_log` constraint는 `pkey`, `content_kind_check`, `user_id_fkey`뿐. `(user_id, character_id, slot_key, user_local_date)` unique 없음.
    - `/tmp/ondo-proactive-db-schema.log` — 관련 index는 조회용 btree/partial index이며 unique index 없음.
  - 현재 운영 데이터에서는 중복 그룹이 발견되지 않음:
    - `/tmp/ondo-proactive-db-duplicates.log` — duplicate slot/day query 결과 없음.
- **재현 단계**:
  1. 동일 user에 대해 같은 `forceSlotKey`/시각 조건으로 dispatch를 동시에 2회 호출한다.
  2. 두 호출이 모두 `alreadySentCount=0`을 읽은 뒤 insert하면 같은 slot/date row 2개가 생길 수 있다.
- **수정 방향**:
  - DB에 `UNIQUE (user_id, character_id, slot_key, user_local_date)` 또는 product 정책상 character 무관이면 `UNIQUE (user_id, slot_key, user_local_date)` 추가.
  - Edge Function insert를 `upsert(..., onConflict)` 또는 insert conflict handling으로 변경하고, conflict 시 `already sent this slot today`로 skip 처리.
- **검증 방법**:
  - 병렬 dispatch 테스트 10회에서 row count가 1로 고정되는지 확인.
  - 기존 데이터 중복 backfill/cleanup SQL을 먼저 검토.

### P2-2. Expo push “ticket ok”까지만 기록하고 receipt/delivery 상태 추적이 없음
- **영향**: DB row는 있고 push가 실제 기기에 도달하지 않은 경우(Expo receipt error, APNs/FCM downstream error)를 사후 추적하기 어렵다. 체크리스트의 “notification receipt 추적이 가능한가”, “DB에는 있는데 알림이 없거나” RCA에 취약.
- **증거**:
  - `supabase/functions/_shared/notification_push.ts:240-352` — Expo `/push/send` 응답 ticket만 파싱. `ticket.id`를 DB에 저장하지 않고 `/push/getReceipts` 호출도 없음.
  - `supabase/functions/proactive-message-dispatch/index.ts:1216-1246` — log에는 `push_sent_count`, `push_skipped_reason`만 업데이트.
  - 운영 DB table 목록:
    - `/tmp/ondo-proactive-db-receipts.log` — notification/push/receipt 관련 public table은 `notification_settings`, `user_notification_preferences` 등뿐이며 Expo push receipt 저장소 없음.
- **수정 방향**:
  - `proactive_message_log` 또는 별도 `push_delivery_receipts` 테이블에 token hash, ticket id, send status, receipt status, error code/message, checked_at 저장.
  - 별도 cron/worker로 Expo `/push/getReceipts` polling.
  - 토큰 개인정보 최소화를 위해 원문 token 대신 hash 저장.
- **검증 방법**:
  - invalid token/expired credential 테스트에서 ticket/receipt error가 row에 남고, `fcm_tokens.is_active=false` 처리까지 추적되는지 확인.

### P2-3. 선톡 문구가 deterministic fallback에 장기간 의존하며 슬롯별 반복이 실제 운영 대화에 노출됨
- **영향**: “반복 문구나 generic 문구가 많은가”, “캐릭터 관계 톤이 자연스러운가” 기준에서 품질 저하. 여러 날 연속 같은 문장이 반복되면 스팸/봇처럼 느껴질 수 있다.
- **증거**:
  - 운영 `proactive_message_log` 최근 rows:
    - `/tmp/ondo-proactive-db-recent.log` — 2026-06-04~2026-06-05 rows의 `meta.provider=rule`, `model=deterministic-proactive-fallback:gemini-2.0-flash-lite`.
  - 운영 `character_conversations` 최근 proactive messages:
    - `/tmp/ondo-proactive-db-latest-messages.log`
      - `2026-06-05 lunch_share`: “나 지금 점심 먹으려는 중이야. 너도 밥 거르지 말고 챙겨 먹어.”
      - `2026-06-04 lunch_share`: 같은 문장 반복.
      - `2026-06-05 morning_greet`: “굿모닝. 일어났어? 오늘 시작하기 전에 네 생각나서 먼저 보냈어.”
      - `2026-06-04 morning_greet`: 같은 문장 반복.
      - evening/goodnight도 동일 문장 반복.
  - 코드 경로:
    - `supabase/functions/proactive-message-dispatch/index.ts:984-1028` — LLM 실패 시 deterministic fallback 사용.
    - `supabase/functions/_shared/proactive_message_rules.ts` — fallback text pool/slot rules.
- **수정 방향**:
  - fallback pool을 slot별 10~20개 이상으로 확장하고, 최근 N회 동일 문장 LRU 제외.
  - fallback 사용률을 metric으로 노출하고 Gemini failure 원인(credential/quota/model safety)을 별도 alert.
  - LLM failure가 장기화될 경우 발송 빈도 축소 또는 더 자연스러운 서버-side template rotation 사용.
- **검증 방법**:
  - 최근 7일 동일 user/slot별 content duplicate rate query.
  - fallback forced unit test에서 최근 5회 동일 문장 미반복 확인.

### P2-4. 이미지 reveal은 기본 race/idempotency가 있으나, “URL이 나중에 깨짐/placeholderUrl 누락” fallback이 약함
- **영향**: dispatch 시점에는 Storage list로 파일 존재를 확인하지만, 사용자가 나중에 답장하는 reveal 시점에는 URL 유효성을 재확인하지 않는다. Storage 파일 삭제/권한 변경/row meta 손상 시 사용자는 broken image 또는 일반 답장만 받을 수 있다.
- **증거**:
  - 안전한 부분:
    - `supabase/functions/proactive-message-dispatch/index.ts:176-201` — `storage.list()`로 placeholder 파일 존재 확인 후 public URL 생성.
    - `supabase/functions/character-chat/index.ts:2640-2652` — `revealed_at IS NULL` 조건으로 claim, 24h window, user/character/id 조건 확인.
    - `supabase/functions/character-chat/index.ts:2675-2721` — merge 실패 시 `revealed_at` rollback.
  - 약한 부분:
    - `supabase/functions/character-chat/index.ts:2663-2667` — claim 후 `placeholderUrl`이 없으면 rollback 없이 `return null`. row meta 손상 시 phantom reveal 상태가 될 수 있음.
    - reveal 시점 URL HEAD/list 재검증 없음.
  - 운영 URL spot-check:
    - `https://.../character-proactive-images/luts/meal/2.png` → HTTP 200 `image/png`, content-length 2,124,830.
    - `https://.../character-proactive-images/luts/meal/4.png` → HTTP 200 `image/png`, content-length 2,349,989.
- **수정 방향**:
  - reveal 직전 `placeholderUrl` 없음/HEAD 실패/Storage list 실패 시 `revealed_at` rollback 또는 `meta.reveal_failed_reason` 기록 후 사용자에게 자연스러운 text fallback.
  - public URL 의존 대신 signed URL 정책을 쓴다면 만료/refresh 경로 설계.
- **검증 방법**:
  - 테스트 row에 `hookForReveal=true` but `placeholderUrl=null`을 넣고 답장 시 `revealed_at`이 남지 않는지/실패 메타가 남는지 확인.
  - Storage 파일 임시 삭제/비공개 전환 환경에서 reveal UX 확인.

## P3

### P3-1. 실기기 foreground/background/terminated tap QA가 아직 자동 증거화되어 있지 않음
- **영향**: 체크리스트가 요구하는 push token 등록, foreground 표시, background 수신 후 클릭 이동, 앱 종료 상태 클릭 이동은 코드상 경로가 있으나 실기기 증거가 별도 아티팩트로 남지 않았다.
- **증거/현재 코드 경로**:
  - token 등록: `apps/mobile-rn/src/lib/push-notifications.ts:558-620` — physical device, permission, projectId, Expo token 등록.
  - foreground handler: `apps/mobile-rn/src/lib/push-notifications.ts:115-149` — same active chat 일반 DM suppress, proactive는 예외로 banner/sound 표시.
  - foreground receive/tap insert+route: `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:468-512` — `insertMessageFromPushIfPresent`, ack, route rewrite `/chat?characterId=...`.
  - cold-start tap fallback: `apps/mobile-rn/src/lib/push-notifications.ts:477-492` — `getLastNotificationResponseAsync()`.
- **개선 방향**:
  - Dev Tools의 로컬 푸시 외에 원격 Expo push e2e 실기기 체크리스트를 `docs/audits/.../evidence/`에 표준화.
  - 각 케이스별 스크린샷/화면녹화/DB row id/Expo ticket id를 묶어 저장.

## Evidence

### Checklist mapping
- 선톡 발송 조건
  - 명확한 슬롯: `proactive-message-dispatch/index.ts:216-265`, `_shared/proactive_message_rules.ts` tests passed.
  - daily cap: `proactive-message-dispatch/index.ts:836-853`.
  - cooldown: `proactive-message-dispatch/index.ts:887-910`; 답장 시 `character-chat/index.ts:2917-2939`에서 `user_replied=true` 마킹.
  - default opt-in candidate synthesis: `proactive-message-dispatch/index.ts:728-758`.
- 메시지 내용
  - LLM prompt guard: `proactive-message-dispatch/index.ts:273-305`.
  - service tone block: `proactive-message-dispatch/index.ts:444-465`.
  - 운영 fallback 반복: `/tmp/ondo-proactive-db-latest-messages.log`.
- 이미지 선톡
  - LRU placeholder: `proactive-message-dispatch/index.ts:134-174`.
  - Storage existence check: `proactive-message-dispatch/index.ts:176-201`.
  - hook meta insert: `proactive-message-dispatch/index.ts:1139-1149`.
  - reveal claim: `character-chat/index.ts:2605-2768`.
- Push notification
  - payload route: `_shared/notification_push.ts:51-73` → `/chat?characterId=...`.
  - pending proactive id payload: `_shared/notification_push.ts:100-105`.
  - mobile payload parse/stash: `apps/mobile-rn/src/lib/push-notifications.ts:187-194`, `425-439`.
  - tap route: `app-bootstrap-provider.tsx:478-512`.
- DB/상태/실기기
  - live rows saved/pushed: `/tmp/ondo-proactive-db-recent.log` shows latest `luts` rows with `push_sent_count=1` and `push_skipped_reason=NULL`.
  - cron active: `/tmp/ondo-proactive-db-cron.log` shows `proactive-message-dispatch-5min`, schedule `*/5 * * * *`, active `true`, vault worker token path.
  - Deno tests: `/tmp/ondo-proactive-deno-test.log` — 7 passed, including proactive preference column and pendingProactiveMessageId payload tests.
  - Supabase local status: `supabase status` failed because Docker daemon not running; production linked DB queries succeeded.

### Commands run
```sh
# unit tests
cd /Users/injoo/Desktop/Dev/fortune/supabase/functions \
  && deno test --allow-env --allow-net=0.0.0.0 \
    _shared/proactive_message_rules_test.ts \
    _shared/notification_push_test.ts

# production read-only DB evidence
supabase db query --linked "select id, user_id, character_id, slot_key, message_id, user_local_date, push_sent_count, push_skipped_reason, meta, revealed_at, created_at from proactive_message_log order by created_at desc limit 5;"
supabase db query --linked "select conname, contype, pg_get_constraintdef(oid) as def from pg_constraint where conrelid='public.proactive_message_log'::regclass order by conname;"
supabase db query --linked "select jobid, jobname, schedule, active, command from cron.job where jobname='proactive-message-dispatch-5min';"
supabase db query --linked "select elem->>'id' as id, elem->>'type' as type, elem->>'content' as content, elem->'proactive' as proactive from character_conversations c, lateral jsonb_array_elements(c.messages) with ordinality arr(elem, ord) where c.character_id='luts' and c.user_id='8a0e34e5-112d-40cc-b190-403b9dd36465' order by arr.ord desc limit 8;"
```

## Recommended Fix Order
1. **P1-1 알림 설정 불일치 수정**: `character_proactive` UI/서버 sync 정책 결정 후 구현, 기존 prefs backfill 포함.
2. **P2-2 receipt 추적 추가**: Expo ticket id 저장 + receipt polling으로 “push_sent_count=1인데 유저가 못 받음” RCA 가능하게 만들기.
3. **P2-1 DB unique/idempotency 추가**: duplicate-prevention을 애플리케이션 count check에서 DB constraint로 강화.
4. **P2-3 fallback 반복 완화**: fallback pool/LRU/LLM failure metric 추가.
5. **P2-4 reveal fallback 보강**: reveal 시점 URL/placeholder failure 처리 및 rollback/failed meta.
6. **P3 실기기 QA evidence pack**: foreground/background/terminated tap, active-chat proactive banner 예외, token registration을 영상+DB row+ticket/receipt로 남기기.

## Open Questions
- “캐릭터 메시지” 토글은 답장+선톡을 모두 끄는 단일 토글이어야 하나, 아니면 “캐릭터 답장”과 “캐릭터 선톡”을 분리해야 하나?
- `proactive_message_log` uniqueness 범위는 `(user_id, slot_key, user_local_date)`가 맞나, 아니면 Slice 3 다중 캐릭터 확장을 고려해 `(user_id, character_id, slot_key, user_local_date)`가 맞나?
- 선톡 기본값은 현재 opt-out(`user_proactive_preferences` row 없음 → ON)인데, App Store/privacy 문구와 온보딩 동의 UX가 이 정책을 충분히 설명하고 있나?
- fallback provider가 운영에서 계속 쓰이는 원인이 Gemini credential/quota/model failure 중 무엇인지 별도 로그/alert로 확인할 필요가 있다.

## 실기기 검증 필요 항목
- iOS 실제 기기에서 권한 prompt → Expo token 등록 → `fcm_tokens` row active 확인.
- foreground + 다른 화면: proactive push banner/sound/list 표시, MessageStore insert 후 채팅 목록 preview 반영.
- foreground + 같은 채팅방: 일반 DM은 suppress, proactive는 예외 표시되는지 확인.
- background: push 수신 후 탭 시 `/chat?characterId=luts` 직행 및 해당 message id가 중복 없이 표시되는지 확인.
- terminated/cold start: `getLastNotificationResponseAsync()` fallback으로 같은 경로가 동작하는지 확인.
- image hook: lunch_share push 수신 → 사용자 답장 → reveal image 표시 + `proactive_message_log.revealed_at` set + 중복 답장 시 reveal 1회만 발생.
