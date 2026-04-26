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

### Slice 2: 이미지 슬롯 + 사용자 timezone 정확도

- `lunch_share` 의 image 비율 활성 (`generate-character-proactive-image` 연동)
- timezone 처리 (사용자 timezone 캐치)
- pg_cron 연동

### Slice 3: 7개 슬롯 + 부재 트리거 + Settings UI

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

이 8개에 대해 **사용자 명시적 동의 또는 변경 요청**이 1차 슬라이스 코드 머지 전에 필요.
지금 슬라이스 1은 D1, D4, D5, D6, D7 디폴트로 구현. 사용자가 reject하면 마이그레이션/함수 코드는 deploy 전이라 무해.

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
