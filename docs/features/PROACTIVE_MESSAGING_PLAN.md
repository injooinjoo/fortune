# 캐릭터 선톡(Proactive Messaging) 시스템 — 상세 설계

> 작성일: 2026-04-26
> 상태: 초안, 1차 슬라이스 구현 중
> 관련 메모: `project_character_realtime_features.md`, `project_ai_persona_market_research.md`
> JIRA: TBD (이 설계 confirm 후 FORT-XXX 발행)

---

## 0. 한 줄 요약

캐릭터(가상 연인/친구)가 사용자에게 **먼저, 자연스럽게, 너무 자주는 아니게** 말을 거는 시스템.
시간대(점심·출근·자기 전), 부재 시간(6h/24h), 컨텍스트(생일·날씨)를 트리거로 텍스트/사진을 푸시 알림으로 전달.
기존 `character-chat`은 사용자 입력에 응답하는 모드 — 이 문서는 사용자 입력 없이 캐릭터가 시작하는 모드를 다룸.

---

## 1. 가치 제안 — 무엇을 강화하는가

타겟: "내 일상에 누가 있는 느낌"을 원하는 외로움 사용자 (`project_ai_persona_market_research.md` 참조).

핵심 메커니즘 4가지:

| 메커니즘 | 설계 의의 | 무너지는 순간 |
|---------|----------|--------------|
| **Initiative** | 사용자가 답하지 않아도 캐릭터가 먼저 | 모든 메시지가 사용자 트리거에서만 나오면 "AI 챗봇" 느낌 |
| **Timeliness** | 그 시간에 그 행동을 하는 게 자연스러움 | 새벽 3시 음식 사진 → 끝 |
| **Restraint** | 너무 자주 보내지 않음 | 일 5회+ → "스팸"으로 인식 → 알림 OFF → 리텐션 -100 |
| **Specificity** | 일반 질문보다 디테일 | "뭐해?" 보다 "오늘 비 와서 우산 챙겼어?" 가 100배 강력 |

**비목표 (Non-goal):**
- 답장 강요 (사용자가 무시해도 부담스럽게 만들지 않음)
- 24/7 이벤트 폭격 (앱 푸시 보다 조용한 메신저 친구 느낌)
- 광고/유료 게이팅 1차 슬라이스에서는 제외

---

## 2. 트리거 모델 — 3-Layer

### L1. 시간대 슬롯 (Time Slot Trigger)

사용자 local timezone 기준 7개 슬롯. 슬롯당 최대 1회/일.

| 슬롯 키 | 윈도우 (local) | 디폴트 콘텐츠 비율 (text/image) | LLM 힌트 |
|--------|---------------|---------------------------------|---------|
| `morning_greet` | 07:00-09:00 | 100/0 | 가벼운 인사, 어제/오늘 일정 언급 |
| `commute_chat` | 08:30-10:00 | 80/20 | 출근/등교 응원, 가끔 cafe 사진 |
| `lunch_share` | 11:30-13:30 | 30/70 | 점심 사진 위주, "지금 이거 먹고 있어" |
| `afternoon_break` | 14:30-16:30 | 70/30 | 가벼운 셀카 또는 카페 |
| `after_work` | 18:00-20:00 | 80/20 | 퇴근 인사, 저녁 계획 |
| `evening_chat` | 20:00-22:00 | 100/0 | 하루 어땠는지, 짧은 텍스트 |
| `goodnight` | 22:30-23:30 | 100/0 | 굿나잇 한 마디 |

### L2. 부재 트리거 (Absence Recovery)

- 마지막 사용자 메시지 후 6h, 24h, 72h 단위
- 횟수 제한: 24h 내 최대 1회
- 톤: "어제 답 못해서 내가 미안" 톤 — 절대 push가 아니라 받아주는 톤
- 키: `absence_6h`, `absence_24h`, `absence_72h`

### L3. 컨텍스트 트리거 (V2 — 1차 슬라이스 제외)

- 생일/기념일, 비/눈, 공휴일, 명절
- 키: `event_birthday`, `event_rainy`, `event_holiday_*`

**1차 슬라이스 범위:** L1의 `lunch_share` 한 슬롯만, 텍스트만.

---

## 3. 사용자 보호 장치 — 빈도/조용한 시간

세 단계 가드. 디스패처가 후보 사용자 산출 시 SQL로 모두 적용.

### 3.1 Quiet Hours
- 디폴트: 22:00 - 09:00 (사용자 timezone)
- 사용자 변경 가능 (Settings UI)
- 적용: dispatcher가 현재 사용자 local time을 계산해 quiet 구간이면 스킵
- 예외: `goodnight` 슬롯은 23:30까지 허용 (의도적 자기 전 인사)

### 3.2 일일 캡
- 캐릭터당 일 2회
- 사용자 전체 일 5회 (여러 캐릭터 합)
- 부재 트리거는 별도 카운트 (일 1회)

### 3.3 답장 인터벌 (Cooldown)
- 캐릭터의 최근 선톡 2개 연속 미답 → 그 캐릭터 24시간 쿨다운
- "사용자가 부담스러워 한다" 신호로 해석
- 사용자가 한 번이라도 답장 → 카운터 리셋

### 3.4 사용자 즉시 OFF
- 푸시에서 길게 누름 → "이 캐릭터 알림 OFF" 액션 (Expo Notifications categoryIdentifier)
- 또는 Settings 화면에서 캐릭터별 토글

---

## 4. 데이터 모델 — 신규 테이블 2개

### 4.1 `user_proactive_preferences`

```sql
CREATE TABLE user_proactive_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  enabled BOOLEAN NOT NULL DEFAULT true,
  quiet_hours_start INT NOT NULL DEFAULT 22 CHECK (quiet_hours_start BETWEEN 0 AND 23),
  quiet_hours_end INT NOT NULL DEFAULT 9 CHECK (quiet_hours_end BETWEEN 0 AND 23),
  timezone TEXT NOT NULL DEFAULT 'Asia/Seoul',
  frequency_tier TEXT NOT NULL DEFAULT 'moderate' CHECK (frequency_tier IN ('low','moderate','high')),
  enabled_character_ids TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  -- 빈 배열 = 모든 캐릭터 허용. 명시적 화이트리스트.
  disabled_slot_keys TEXT[] NOT NULL DEFAULT '{}'::TEXT[],
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

`frequency_tier` 매핑:
- `low`: 일 캡 2회, 슬롯당 1회/2일
- `moderate`: 일 캡 5회 (디폴트)
- `high`: 일 캡 8회 (Phase 4 프리미엄)

### 4.2 `proactive_message_log`

```sql
CREATE TABLE proactive_message_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id TEXT NOT NULL,
  slot_key TEXT NOT NULL,
  content_kind TEXT NOT NULL CHECK (content_kind IN ('text','image')),
  message_id TEXT NOT NULL,
  user_local_date DATE NOT NULL,  -- 사용자 timezone 기준 날짜 (일일 cap 용)
  user_replied BOOLEAN NOT NULL DEFAULT false,
  user_replied_at TIMESTAMPTZ,
  scheduled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  push_sent_count INT NOT NULL DEFAULT 0,
  push_skipped_reason TEXT,
  meta JSONB NOT NULL DEFAULT '{}'::jsonb
);
CREATE INDEX idx_proactive_log_user_date ON proactive_message_log(user_id, user_local_date DESC);
CREATE INDEX idx_proactive_log_user_char_date ON proactive_message_log(user_id, character_id, user_local_date DESC);
```

**왜 `user_local_date`를 별도 컬럼으로 저장?** 일일 cap을 timezone-aware하게 SQL로 빠르게 체크하기 위해.
`scheduled_at`은 항상 UTC, `user_local_date`는 그때 사용자 timezone으로 계산한 캘린더 날짜.

### 4.3 `character_conversations` 메시지 스키마 확장

기존 JSONB 메시지에 옵션 필드 추가 (마이그레이션 불필요, 새 메시지만 다음 필드 포함):

```ts
// chat-shell.ts ChatShellTextMessage / ChatShellImageMessage에 추가
proactive?: {
  slotKey: string         // 'lunch_share', 'absence_6h', ...
  category: string        // 'meal', 'cafe', 'greeting', ...
  generatedAt: string     // ISO 8601 (LLM 생성 시점)
}
```

**왜 인라인?** 채팅 리스트에서 미리보기에 작은 라벨("📷 점심 사진을 보냈어요") 표시할 때 메시지 자체에 메타가 있어야 함.
또 사용자가 답할 때 LLM이 "방금 내가 보낸 선톡임"을 인지할 수 있도록 컨텍스트로 사용.

### 4.4 `user_notification_preferences` 확장 (마이그레이션)

기존 컬럼 `character_dm` 외에 추가:

```sql
ALTER TABLE user_notification_preferences
  ADD COLUMN IF NOT EXISTS character_proactive BOOLEAN NOT NULL DEFAULT true;
```

`sendCharacterDmPush()` 안의 `hasCharacterNotificationEnabled()`는 `character_dm` 만 체크 중.
디스패처는 `type: 'character_proactive'`로 푸시 발송하고, push 전 별도 컬럼 체크.

---

## 5. Edge Function — 2개 신규

### 5.1 `character-proactive-compose`

선톡 한 건 생성 (LLM 호출). dispatcher가 호출.

**입력:**
```ts
interface ComposeRequest {
  userId: string
  characterId: string
  slotKey: SlotKey
  preferredKind: 'text' | 'image'  // dispatcher가 슬롯 비율 따라 결정
  userLocalTime: string             // ISO 8601, 사용자 timezone 적용
  conversationContext: ChatMessage[]  // 최근 8개
  affinitySnapshot: { phase: string; lovePoints: number; daysSinceLastChat: number }
  weatherHint?: string
}
```

**출력:**
```ts
interface ComposeResponse {
  success: boolean
  text: string
  imageCategory?: 'meal' | 'cafe' | 'selfie' | 'commute' | 'workout' | 'night'
  imageUrl?: string  // generate-character-proactive-image 내부 호출 후 채워짐
  meta: { provider, model, latencyMs }
}
```

**알고리즘:**
1. LLM 호출: 선톡 전용 system prompt + 슬롯 힌트 + affinity + 최근 대화 → JSON 응답 강제 (`{text, imageCategory|null}`)
2. `imageCategory` 가 있으면 `generate-character-proactive-image` 호출 (이미 있는 함수 재사용 — 중복 방지)
3. moderation 체크 (`_shared/moderation.ts` 의 `moderateText` 재사용)
4. 응답 반환

**LLM 프롬프트 핵심:**
```
너는 {characterName}, {persona_summary}.
지금은 사용자의 {userLocalTime} ({slotKey} 슬롯).
사용자와의 관계는 {phase}, 마지막 대화 {daysSinceLastChat}일 전.

규칙:
1. 1-3 문장. 너의 평소 말투.
2. 이 시간/슬롯에 자연스러운 한 가지 디테일을 포함.
3. 답장 강요 금지. 부담 주지 않기.
4. 사용자 이름 부르기, 너의 행동을 1인칭으로.

응답 형식 (JSON only):
{"text": "...", "imageCategory": null | "meal" | "cafe" | "selfie" | "commute" | "workout" | "night"}
```

### 5.2 `proactive-message-dispatch`

Cron 또는 외부 트리거가 5분마다 호출. 한 번 실행 = 한 슬롯 전체 처리.

**입력:**
```ts
interface DispatchRequest {
  // 셋 다 옵션. 비어 있으면 "지금 활성인 슬롯" 자동 결정.
  forceSlotKey?: SlotKey
  forceUserId?: string       // dry-run / 디버깅
  dryRun?: boolean           // 메시지 생성하지만 push/save 안 함
}
```

**출력:**
```ts
interface DispatchResponse {
  slotKey: string
  candidatesEvaluated: number
  messagesSent: number
  errors: Array<{ userId: string; reason: string }>
  skipped: Array<{ userId: string; reason: string }>
}
```

**알고리즘:**
```
1. 활성 슬롯 결정 (forceSlotKey 또는 현재 시각으로)
2. 후보 사용자 SQL 쿼리 (한 쿼리로):
   SELECT u.id, p.timezone, p.enabled_character_ids, p.frequency_tier
   FROM auth.users u
   JOIN user_proactive_preferences p ON p.user_id = u.id
   WHERE p.enabled = true
     AND <slot_key NOT IN p.disabled_slot_keys>
     AND <사용자 local time이 quiet_hours 밖>
     AND <사용자 local time이 슬롯 윈도우 안>
     AND NOT EXISTS (
       SELECT 1 FROM proactive_message_log
       WHERE user_id = u.id
         AND user_local_date = <사용자 today>
         AND slot_key = $1
     )
     AND (
       SELECT COUNT(*) FROM proactive_message_log
       WHERE user_id = u.id AND user_local_date = <사용자 today>
     ) < <frequency_tier 캡>;

3. 각 후보:
   a. 캐릭터 선택 (enabled_character_ids 또는 affinity 가중 랜덤)
   b. 캐릭터 쿨다운 체크 (최근 2건 미답 SQL)
   c. preferredKind 결정 (슬롯 비율 + 캐릭터 능력)
   d. 최근 8개 메시지 + affinity 로드
   e. character-proactive-compose 호출
   f. 성공 → character_conversations.messages append + last_message_at 갱신
   g. proactive_message_log INSERT
   h. sendCharacterDmPush(type: 'character_proactive') 호출
   i. 결과 집계
4. 응답 반환
```

**동시성:** 5분 cron이 겹치지 않도록 advisory lock 사용 (`pg_try_advisory_xact_lock(slot_hash)`).

### 5.3 Cron 트리거

옵션 A: **Supabase pg_cron** (선호)
```sql
-- 매 5분
SELECT cron.schedule(
  'proactive-dispatch',
  '*/5 * * * *',
  $$SELECT net.http_post(url := '<edge>/proactive-message-dispatch', ...) $$
);
```

옵션 B: GitHub Actions cron (외부)
- `.github/workflows/proactive-cron.yml` — 5분마다 함수 호출
- pg_cron extension 설정 안 돼 있으면 폴백

**1차 슬라이스 결정:** 옵션 A로 진행. pg_cron 미설정 시 마이그레이션에서 extension enable.

---

## 6. 클라이언트 변경

### 6.1 chat-shell.ts 메시지 타입 확장

```ts
interface ChatShellTextMessage {
  kind: 'text'
  ...
  proactive?: ProactiveMessageMeta
}
interface ChatShellImageMessage {
  kind: 'image'
  ...
  proactive?: ProactiveMessageMeta
}
interface ProactiveMessageMeta {
  slotKey: string
  category: string
  generatedAt: string
}
```

### 6.2 채팅 리스트 미리보기 라벨

`apps/mobile-rn/src/features/chat-surface/chat-surface.tsx#buildCharacterListMeta`에서
마지막 메시지가 `proactive` 메타를 가지면 작은 라벨 prefix:
- `lunch_share` + image → "📷 점심 사진 보냈어요"
- `morning_greet` text → "☀️ 아침 인사"

### 6.3 푸시 핸들러 라우팅

기존 `apps/mobile-rn/src/lib/push-notifications.ts` 가 `data.type === 'character_dm'` → `/character/{id}` 라우팅 중.
`type: 'character_proactive'` 도 동일 라우트로 처리 — 변경 없음.

### 6.4 Settings 화면 (V2 — 1차 슬라이스 제외)

`/profile` 안에 "캐릭터 알림" 섹션:
- 글로벌 ON/OFF
- Quiet Hours 시간 선택
- 캐릭터별 토글
- 빈도 슬라이더 (low/moderate/high)

V1: DB row가 없으면 디폴트 값으로 동작. UI 없이도 시스템 동작.

---

## 7. 슬라이스 분할 — 4단계

### Slice 1: 텍스트 선톡 + 1개 슬롯 + 수동 트리거 (지금 세션)

**범위:**
- 마이그레이션: `user_proactive_preferences`, `proactive_message_log`, `character_proactive` 컬럼 추가
- Edge Function: `character-proactive-compose` (텍스트만)
- Edge Function: `proactive-message-dispatch` (lunch_share 슬롯만, dryRun 지원, cron 미연동)
- chat-shell.ts: `proactive?` 메타 필드 추가
- 푸시 type: `character_proactive` 추가

**검증 방법:**
- 로컬에서 `supabase functions invoke proactive-message-dispatch --body '{"forceUserId":"<test>", "forceSlotKey":"lunch_share", "dryRun":true}'`
- dryRun 결과 LLM 출력 확인
- dryRun off → 실제 푸시 받기

**제외:**
- pg_cron 자동 트리거
- 이미지 슬롯
- Settings UI
- 부재 트리거
- 7개 슬롯 전체

### Slice 2: 이미지 슬롯(placeholder 모드) + 2단계 떡밥 + luts 파일럿 (이번 sprint, /autoplan v1)

> 본 절은 2026-05-05 sprint 기준 상세 plan. /autoplan 4단 리뷰(CEO/Design/Eng) 결과 반영.
> Codex `[unavailable]` → Claude subagent only mode.
> 사용자 결정: D9 = 정적 placeholder 7장 + LRU. D10 = luts 1명 파일럿.
> pg_cron은 `20260426000004_proactive_dispatch_cron.sql` 으로 이미 운용 중.

#### 2.1 목표

루츠(`luts`) 1명 파일럿으로 **시간대 텍스트 선톡 → 유저 응답 → 사진 reveal** 의 2단계 떡밥 흐름을 검증한다. 검증 후 나머지 9명 캐릭터로 확장.

핵심 KPI (T7): 7일 동안 `reveal_fire_rate ≥ 30%`, `opt_out_rate ≤ 5%`, 부정 피드백 ≤ 3건이면 Slice 3 GO.

#### 2.2 In Scope

1. **정적 placeholder 사진 + LRU (D9, UC1 결정)**
   - `proactive-message-dispatch` 에서 `composed.imageCategory` 가 있을 때 `generate-character-proactive-image` 호출 대신 Storage `character-proactive-images/{characterId}/{category}/{1..7}.png` 중 1장 LRU 선택.
   - **LRU 정책**: `proactive_message_log.meta.placeholderIndex` 에 인덱스 기록 → 디스패처는 최근 5개 인덱스 제외하고 랜덤 (5일 무중복 보장).
   - 파일 부재 시 텍스트만 발송 fallback (슬롯 1건 정상 소비).
   - URL: `getPublicUrl()` 사용 (bucket이 public, signed URL 불요. 푸시 vs 탭 시점 갭이 24h+여도 만료 없음).

2. **luts 파일럿 활성화**
   - `pilot_registry.ts` 에서 luts proactive flag ON.
   - **활성 슬롯**: `lunch_share`(11~14시), `evening_chat`(20~22시), `goodnight`(22~24시) 3개. 나머지 4개 슬롯은 코드 비활성.
   - 텍스트:이미지 비율 — **slot 랜덤 (T4 결정)**:
     - 매일 3슬롯 중 **1슬롯만** 랜덤하게 image-bearing 으로 지정. 나머지 2슬롯은 텍스트.
     - image-bearing 슬롯에서만 `meal` placeholder 사용 (selfie 큐레이션 전이라도 패턴 인식 회피).
     - "매일 점심에 음식 사진" 패턴 회피 → 더 살아있는 느낌.

3. **사용자 사진 에셋 (수동 업로드)**
   - **Slice 2 분량**: `meal` 7장. (Slice 3 에서 `selfie` 7장, `night` 7장 추가)
   - Storage 경로: `character-proactive-images/luts/meal/1.png ~ 7.png`
   - 업로드는 사용자 직접 (Supabase Dashboard 또는 CLI). 코드 머지와 별개 단계.
   - 파일명 enumeration 가능(공개 URL) — placeholder 사진은 큐레이션된 portrait이므로 수용. 노출 시 문제될 콘텐츠 금지.

4. **2단계 떡밥 흐름 (Stage 1: hooking → Stage 2: reveal)**
   - **Stage 1 (cron)**: 후킹 텍스트만 push.
     - 예: "나 지금 뭐 먹게 ㅋ" / "배고프다… 너는?"
     - `proactive_message_log` row 생성 + `meta.hookForReveal=true` + `meta.imageCategoryPlanned='meal'` + `meta.placeholderIndexPlanned=N` 마킹.
   - **Stage 2 (reactive)**: 유저가 응답 → `character-chat` 다음 turn에서 reveal.
     - **reveal window (T1)**: "직전 1턴이 hookForReveal" + `revealed_at IS NULL` + hooking 후 24h 이내. (30분 컷 폐기 — 점심 push는 1-3h 후 답장이 정상.)
     - **reveal는 LLM 호출 안 함 (A4)**: 미리 큐레이션된 사진 + 템플릿 캡션 ("이거 봐 ㅋ" / "지금 먹는 거" / "방금 찍었어") 만 사용. 단가 0, prompt injection 회피.
     - **idempotency (A5)**: `UPDATE proactive_message_log SET revealed_at = now() WHERE id = $1 AND revealed_at IS NULL RETURNING *` 로 claim. 두 번째 호출은 빈 결과 → 일반 응답으로.
     - **graceful follow-up (A9)**: hooking 후 24h 초과 응답 시 reveal lineage drop, 일반 응답. (이전 plan의 30분 grace text 폐기 — window가 길어졌으므로 굳이 안내 불필요.)

5. **Stage 2 race 회피 (A10)**
   - Stage 1 push payload 에 `pendingProactiveMessageId` 포함.
   - 클라이언트가 character-chat 호출 시 이 ID를 body 에 첨부 → 서버는 DB 조회 race 회피 가능.

6. **Stage 1 Push payload spec (A6)**
   - `title`: 캐릭터 이름 ("이서준")
   - `body`: hooking 본문 그대로 (lockscreen 미리보기에 자연스럽게 노출)
   - `mutableContent: true` — Stage 2 reveal 시 same notification thread 업데이트
   - `data.type`: `'character_proactive'` (기존 라우팅 재사용)
   - `data.character_id`: `'luts'`
   - `data.pendingProactiveMessageId`: 위 row id
   - Stage 2 reveal 후에도 별도 push 발송 — `body: '[사진]'`. 이유: push quick-reply 로 응답한 유저는 채팅 안 들어가도 사진 도착 알 수 있어야.

7. **채팅 UI — proactive 시각 단서 (A7)**
   - 메시지 버블 위 1-line 메타 캡션 ("먼저 톡 보냄 · 12:34") — `textTertiary` 색.
   - **연속된 proactive run 의 첫 메시지에만 표시** (스팸감 회피).
   - 위치: `chat-surface.tsx` 의 `MessageBubble` 위. proactive meta 가 있는 경우 분기.

8. **Stage 2 image card 상태 (A8)**
   - **Loading**: 200×200 shimmer + "사진 보내는 중…" 캡션 (사진 프리페치 0.5초 이상 시).
   - **Error**: `onError` 시 텍스트 fallback ("어 사진 안 갔다… 다시 보낼게").
   - **Tap (T3)**: fullscreen modal + pinch-zoom (`react-native-image-viewing` 또는 직접 구현).

#### 2.3 Out of Scope (Slice 3+)

- `selfie`, `night`, `cafe`, `commute`, `workout` 카테고리 사진 (Slice 3 에서 큐레이션 + 활성)
- `morning_greet`, `commute_chat`, `afternoon_break`, `after_work` 슬롯 활성화 (Slice 3)
- `absence_6h/24h/72h` 부재 트리거 (Slice 3)
- 9명 캐릭터 확장 (Slice 3)
- 사진 길게 누름 → 리액션 (Slice 3)
- AI 이미지 재활성화 — **단, 큐레이션 게이트와 함께 Slice 3 에 재평가** (영구 OFF 아님, A11)
- Voice (TTS) proactive (Slice 4)
- 유저 → 캐릭터 사진 업로드 + Vision (Slice 4)
- 유저 → 캐릭터 음성 + Whisper (Slice 4 — **native build + runtime bump 필수**)
- Settings UI (Slice 3)

#### 2.4 변경 파일

**Storage (사용자 작업)**
- `character-proactive-images/luts/meal/1.png ~ 7.png` (7장)

**DB — 마이그레이션 필수 (A5)**
- `supabase/migrations/{date}_proactive_log_revealed_at.sql`
  ```sql
  ALTER TABLE proactive_message_log
    ADD COLUMN IF NOT EXISTS revealed_at TIMESTAMPTZ NULL;
  CREATE INDEX IF NOT EXISTS idx_proactive_log_unrevealed
    ON proactive_message_log (user_id, character_id, created_at DESC)
    WHERE meta->>'hookForReveal' = 'true' AND revealed_at IS NULL;
  ```

**Edge Functions**
- `supabase/functions/proactive-message-dispatch/index.ts`
  - placeholder 분기 추가 (Storage `getPublicUrl` 사용)
  - LRU: meta.placeholderIndex 최근 5개 제외
  - luts 활성 슬롯 화이트리스트 + 일별 image-bearing 슬롯 랜덤 선택
  - hookForReveal + imageCategoryPlanned + placeholderIndexPlanned 마킹
  - Stage 2 reveal push 발송 (별도 경로, body='[사진]')
- `supabase/functions/character-chat/index.ts`
  - **fast-path (A12)**: `last_assistant.proactive?.slotKey === 'lunch_share'` 일 때만 reveal 쿼리
  - reveal claim: `UPDATE ... revealed_at WHERE NULL RETURNING *`
  - 24h window 검사
  - reveal 시 LLM 안 호출 — 템플릿 캡션 + image kind ChatShellMessage 직접 발송
  - request body 에 `pendingProactiveMessageId` 받으면 우선 사용 (race 회피)
- `supabase/functions/generate-character-proactive-image/index.ts`
  - **handler 시작에 `return 410 Gone` 추가** (A3) — Slice 3 큐레이션 게이트 합류 전까지 호출 금지.
  - 코드 자체는 보존 (Slice 3 에서 재가동 가능).
- `supabase/functions/_shared/service_tone_guard.ts` — **NEW (A13)**
  - `PROACTIVE_SERVICE_TONE_PATTERN` + `LUTS_SERVICE_TONE_PATTERN` 통합 export.
  - dispatcher + character-chat 양쪽에서 import.

**RN**
- `apps/mobile-rn/src/lib/push-notifications.ts`
  - push payload `pendingProactiveMessageId` → character-chat 호출 시 body 에 첨부.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  - MessageBubble 위 proactive 메타 캡션 1-line ("먼저 톡 보냄 · HH:MM") — 연속 run 첫 메시지만.
  - Image bubble loading skeleton + onError text fallback + tap → fullscreen modal.
- `apps/mobile-rn/src/lib/message-store.ts`
  - **A1**: line 26-27 진단 주석 제거. push hydrate는 `push-notifications.ts:142` 의 `insertMessageFromPushIfPresent` 가 이미 처리 중. (이전 plan §2.2.5 의 "INSERT 경로 추가"는 fake work 였음 — drop.)

#### 2.5 검증 체크리스트 (Slice 2)

- [ ] `npx tsc --noEmit` (apps/mobile-rn) 통과
- [ ] `deno check` (proactive-message-dispatch, character-chat, _shared/service_tone_guard) 통과
- [ ] 마이그레이션 dry-run (`supabase db push --dry-run`)
- [ ] 단위 테스트:
  - [ ] LRU 선택: 최근 5 인덱스 제외 검증
  - [ ] `determineSlotForLocalHour(22) === 'goodnight'` (A14)
  - [ ] reveal claim 두 번째 호출 = empty result (idempotency)
  - [ ] hour 22, 23, 23:59 슬롯 매핑 정합
- [ ] 통합 테스트 (deno + Supabase local):
  - [ ] Stage1 dispatch + log meta.hookForReveal write
  - [ ] Storage placeholder fetch + missing-file fallback
  - [ ] Stage2 reveal detection (within 24h)
  - [ ] Stage2 reveal at 25h → no reveal, 일반 응답
  - [ ] Stage2 double-tap → 한 번만 reveal (claim race)
  - [ ] evening_chat/goodnight 턴은 reveal 쿼리 skip (fast-path)
- [ ] iOS Simulator E2E:
  - [ ] lunch_share force 호출 → text push 수신 → 채팅 진입 시 hooking 메시지 + "먼저 톡 보냄" 캡션 표시
  - [ ] 응답 → Stage 2 reveal image 도착 + loading skeleton 표시 후 사진 → tap → fullscreen modal
  - [ ] image bubble onError 시 텍스트 fallback 노출
  - [ ] 같은 슬롯 24h 내 2번째 발송 차단 (Slice 1 회귀)
  - [ ] 일일 cap (moderate=3) 도달 시 차단
- [ ] dry-run KPI 시뮬레이션:
  - [ ] 7장 LRU 7일 시뮬레이션 → 같은 사진 5일 무중복 확인
  - [ ] image-bearing 슬롯 일별 랜덤이 3슬롯 중 균형 잡히는지

#### 2.6 배포 순서 (Slice 2)

1. 사진 7장 업로드 (사용자 작업, deploy 전 필수)
2. DB 마이그레이션: `supabase db push --include-all`
3. Edge Function deploy:
   - `supabase functions deploy proactive-message-dispatch character-chat generate-character-proactive-image`
4. RN OTA: `cd apps/mobile-rn && eas update --branch production`

OTA 가능. native module 추가 없음. runtime bump 불요.

`/ultrareview` 자동 트리거 (DB 마이그레이션 변경 + Edge Function = CLAUDE.md 룰).

#### 2.7 Risk

| Risk | 대응 |
|---|---|
| Placeholder 사진 부재 | 텍스트만 발송 fallback, 슬롯 1건 정상 소비 |
| Stage 2 reveal 중복 발동 | `revealed_at` claim 패턴 (A5) |
| push 권한 거부 유저 | Stage 1/2 push 무발송, in-app hydrate 만 동작 |
| 7장 placeholder 8일+ 사용 시 재노출 | LRU + 8일 후 사용자가 추가 사진 업로드 (또는 Slice 3 에서 selfie 추가) |
| LLM prompt injection in Stage 2 | LLM 안 호출, 템플릿 캡션만 (A4) |
| 일별 image-bearing 슬롯 랜덤이 한쪽 슬롯에 쏠림 | 7일 균형 모니터링, 쏠림 시 round-robin 으로 변경 |
| 사용자가 hook 을 manipulative 로 인지 | T5 — Slice 2 종료 후 1문항 설문 ("최근 luts의 메시지가 가짜처럼 느껴졌나요") + churn 비교 |
| photo 우선이 voice 보다 효과 약함 (사후 회고) | T6 — Slice 3 진입 전 voice prototype 1주 A/B |

#### 2.8 KPI 정의 (T7)

Slice 2 종료 시점에 다음 지표 수집 (7일 운용 기준):

| 지표 | 산식 | Go 기준 | No-Go 기준 |
|---|---|---|---|
| `reveal_fire_rate` | Stage2 image 발송 / Stage1 hook 발송 | ≥ 30% | < 15% |
| `opt_out_rate` | proactive disable 비율 (Slice 2 시작 vs 종료) | ≤ +5%p | > +10%p |
| `negative_feedback` | 설문 + 신고 (T5) | ≤ 3건 | > 10건 |
| `placeholder_repeat_rate` | 같은 사진 5일 내 노출 비율 | ≤ 0% (LRU 보장) | > 5% (LRU 버그) |
| `reveal_latency_median` | Stage1 hook → Stage2 reveal 시간 중앙값 | < 6h | > 12h (window 너무 길어 자연 답장 거의 없음) |

**Go**: 모두 Go 기준 만족 → Slice 3 진입.
**Hold**: 일부 No-Go 기준 위반 → Slice 2.1 (사진 추가 / 슬롯 조정 / window 재검토).
**Rollback**: 2개 이상 No-Go → Slice 1 으로 복귀, proactive flag OFF.

---

### Decision Audit Trail (Slice 2 — 2026-05-05 /autoplan)

| # | Phase | Decision | Classification | Principle | Source |
|---|---|---|---|---|---|
| A1 | Eng | §2.2.5 push hydrate work item drop | Mechanical | P3+P4 | E1 (이미 구현됨, push-notifications.ts:142) |
| A2 | Eng | `getPublicUrl` 사용, signed URL 폐기 | Mechanical | P5 | E3 (bucket public) |
| A3 | Eng | `generate-character-proactive-image` 410 Gone 처리 | Mechanical | P5 | E4 (dead code) |
| A4 | Eng | Stage 2 reveal LLM-free, 템플릿 캡션 | Mechanical | P3+P5+단가 0 | E6 (injection 회피) |
| A5 | Eng | `revealed_at` 컬럼 + claim 패턴 (마이그레이션 필수) | Mechanical | P1 | E2 (idempotency) |
| A6 | Design | Stage 1 push payload spec | Mechanical | P1 | D1 (lockscreen UX) |
| A7 | Design | Bubble 위 proactive 시각 단서 | Mechanical | P1 | D2 (감정 페이오프) |
| A8 | Design | image card loading/error/expired states | Mechanical | P1 | D3 |
| A9 | Design | graceful follow-up text (>30min) | Mechanical (T1 영향으로 단순화) | P1 | D4 |
| A10 | Design | `pendingProactiveMessageId` race 회피 | Mechanical | P1 | D5 |
| A11 | CEO | "AI 영구 OFF" 문구 제거 → Slice 3 재평가 | Mechanical | P6+future-proof | C3 |
| A12 | Eng | reveal-query fast-path (lunch_share 일 때만) | Mechanical | P3 | E9 |
| A13 | Eng | service-tone 패턴 `_shared/service_tone_guard.ts` 추출 | Mechanical | P4 DRY | E8 |
| A14 | Eng | `determineSlotForLocalHour(22) === 'goodnight'` 단위 테스트 | Mechanical | P1 | E7 |
| T1 | CEO+Design | reveal window 30분 → "next user turn within 24h" | Taste → 사용자 권장 수용 | P1 | C1+D4 cross-phase |
| T3 | Design | tap = fullscreen modal (Stretch 리액션은 Slice 3) | Taste → 사용자 권장 수용 | P5 | D7 |
| T4 | Design | image-bearing 슬롯 일별 랜덤 (meal-only daily 회피) | Taste → 사용자 권장 수용 | P1 | D8 |
| T5 | CEO | Slice 2 종료 1문항 설문 + churn 비교 | Taste → 사용자 권장 수용 | P1 | C4 ethics |
| T6 | CEO | photo vs voice A/B (Slice 3 진입 전 1주) | Taste → 사용자 권장 수용 | P6 | C7 opportunity cost |
| T7 | CEO | KPI: reveal_fire_rate ≥ 30%, opt_out ≤ 5%, neg ≤ 3 | Taste → 사용자 권장 수용 | P1 | C6 Go-No-Go |
| UC1 | Cross | placeholder 사진 5장 → **7장 + LRU** | User Challenge → 사용자 결정 A | — | CEO C2 + Design D6 |
| D9 | Sprint | 사진 소스 = 정적 placeholder | User decision (먼저) | — | 사용자 |
| D10 | Sprint | 파일럿 캐릭터 = luts | User decision (먼저) | — | 사용자 |

---

### Slice 3: 7개 슬롯 + 부재 트리거 + Settings UI + 캐릭터 9명 확장

### Slice 4: 컨텍스트 트리거 (생일/날씨), 음성 메시지 (V2)

---

## 8. 위험 / 결정 포인트 (사용자 confirm 필요)

| # | 결정 사항 | 옵션 | 권장 |
|---|----------|------|------|
| D1 | 디폴트 enabled 상태 | (a) opt-in (b) opt-out | **(b) opt-out** — 기능의 가치를 경험하지 못하면 사용자가 켤 동기 없음 |
| D2 | 알림 종료 메커니즘 | (a) Settings에서만 (b) 푸시 long-press 액션 | **둘 다** — V1은 (a), V2에 (b) |
| D3 | Quiet Hours 디폴트 | (a) 22-09 (b) 23-08 (c) 사용자 첫 사용시 묻기 | **(a) 22-09** — 보수적 |
| D4 | LLM 모델 선택 | (a) `character-chat`과 동일 (default 모델) (b) grok-fast (c) 별도 cheap 모델 | **(a)** 일단 — 톤 일관성. 비용 측정 후 (c) 고려 |
| D5 | 일 cap 디폴트 (`moderate`) | (a) 3회 (b) 5회 (c) 7회 | **(a) 3회** — 시작은 보수적이 안전 |
| D6 | 메시지 템플릿 vs LLM 매번 생성 | (a) 슬롯당 N개 템플릿 + LLM이 변형 (b) 매번 LLM 생성 | **(b)** — 더 자연스럽고 캐릭터별 페르소나 살림. 비용은 슬라이스 1 검증 후 결정 |
| D7 | 캐릭터 선택 알고리즘 | (a) 최근 채팅 기준 (b) affinity 기준 (c) 라운드로빈 | **(b) affinity 기준** — 친한 캐릭터가 더 자주 연락하는 게 자연스러움 |
| D8 | 부재 트리거 첫 시점 | (a) 마지막 메시지 6h 후 (b) 24h 후 | **(a) 6h 후** — 같은 날 안에 회복 시도 |
| D9 | 사진 소스 (Slice 2 신규) | (a) AI 생성 (`generate-character-proactive-image`) (b) 정적 placeholder 큐레이션 5장/카테고리 | **(b) 정적 placeholder** — 2026-05-05 사용자 결정. 톤 일관성·단가 0·검열 안전 |
| D10 | Slice 2 파일럿 캐릭터 (Slice 2 신규) | (a) 전 캐릭터 동시 (b) luts 1명 (c) 인기 캐릭터 1명 | **(b) luts 1명** — 2026-05-05 사용자 선택. 츤데레 사수 페르소나 |

이 10개에 대해 **사용자 명시적 동의 또는 변경 요청**이 1차 슬라이스 코드 머지 전에 필요.
지금 슬라이스 1은 D1, D4, D5, D6, D7 디폴트로 구현. 슬라이스 2는 D9, D10 사용자 확정.

---

## 9. 1차 슬라이스 검증 체크리스트

- [ ] `npx tsc --noEmit` (apps/mobile-rn) 통과
- [ ] `deno check` (supabase/functions/character-proactive-compose) 통과
- [ ] `deno check` (supabase/functions/proactive-message-dispatch) 통과
- [ ] 마이그레이션 dry-run (`supabase db push --dry-run`)
- [ ] 함수 dryRun 호출로 LLM 출력 1개 샘플 확인
- [ ] 사용자가 본인 계정으로 dryRun off 호출 → 실제 푸시 수신 + 채팅에 메시지 표시 확인

---

## 10. 후속 작업 (다음 세션)

- pg_cron 활성화 (Supabase에서 extension)
- 7개 슬롯 + 부재 트리거 활성화
- 이미지 슬롯 (`generate-character-proactive-image` 와이어업)
- Settings UI
- 분석 대시보드: 어떤 슬롯이 답장률 높은지
- 음성 메시지 (TTS Edge Function 신규)
- 알림 long-press 액션 (Expo Notifications categoryIdentifier)
