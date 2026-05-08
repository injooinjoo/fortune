# Proactive 메시징 3종 수정 — 시뮬레이터/실기기 테스트 시나리오

본 문서는 다음 세 변경분 검증 절차입니다:
1. `user_replied` 마킹 (서버: `supabase/functions/character-chat/index.ts`)
2. 푸시 권한 JIT 모달 (클라: `push-notifications.ts` + `chat-screen.tsx`)
3. 콜드스타트 펜딩 답장 재개 (클라: `pending-reply-resumer.ts` + `app-bootstrap-provider.tsx`)

배포 전 시뮬레이터 / TestFlight 빌드에서 모두 통과해야 함.

---

## 사전 준비

### 환경
- iOS 시뮬레이터 (iPhone 17 권장) **또는** 실기기 1대
- Supabase 프로젝트 SQL editor 접근 권한
- 테스트 계정 1개 (이미 캐릭터 1+ 명과 대화 이력이 있는 계정 권장)

### 사전 배포
- [ ] `supabase functions deploy character-chat` 완료
- [ ] EAS OTA 푸시 (or `expo start --dev-client`로 로컬 메트로) 완료
- [ ] 시뮬레이터/기기에서 앱 cold-start 후 로그인 성공

### 디버그 도구
SQL editor에서 자주 쓸 쿼리:

```sql
-- 내 user_id 확인
select id from auth.users where email = '<your-email>';

-- proactive_message_log 최근 10개
select id, slot_key, character_id, user_replied, user_replied_at, created_at
from proactive_message_log
where user_id = '<your-uid>'
order by created_at desc limit 10;

-- pending_character_reply_jobs 활성
select id, character_id, status, attempt_count, created_at, started_at
from pending_character_reply_jobs
where user_id = '<your-uid>'
  and status in ('pending', 'processing')
order by created_at desc;
```

---

## 시나리오 1 — `user_replied` 마킹 (서버)

### 1A. 일반 답장 → 마킹 즉시 반영

**목표**: 유저가 답장하면 최근 48h proactive 로그가 모두 `user_replied=true`로 바뀐다.

1. SQL로 임의의 proactive 로그 row 직접 삽입 (또는 cron이 자연스럽게 만들어내길 기다림):
   ```sql
   insert into proactive_message_log (user_id, character_id, slot_key, message_id, user_local_date)
   values ('<your-uid>', 'luts', 'lunch_share', 'test-' || extract(epoch from now()), current_date)
   returning id, user_replied;
   ```
   → **확인**: `user_replied = false`
2. 시뮬레이터에서 `luts` 캐릭터 채팅창 진입 → 아무 텍스트("응") 입력 후 send
3. 서버 응답 도착 후 (5~15초) 다시 SQL:
   ```sql
   select user_replied, user_replied_at from proactive_message_log
   where id = '<step-1의-id>';
   ```
   → **기대**: `user_replied = true`, `user_replied_at` 채워짐

### 1B. 다중 미응답 row 일괄 마킹

1. SQL로 같은 (user, character) 에 대해 24시간 차이로 2개 row 삽입 (lunch + evening)
2. 한 번 답장 → 두 row 모두 `user_replied=true` 되어야 함

### 1C. 48h 윈도우 경계

1. SQL로 `created_at = now() - interval '49 hours'`로 row 삽입
2. 답장 → 이 row 는 `user_replied=false` 유지되어야 함 (윈도우 밖)

### 1D. 답장 중 LLM 에러 → 마킹은 여전히 됨

1. 일부러 비정상 systemPrompt (예: 매우 긴 무의미 문자열) 보내서 LLM 에러 유도
2. proactive_message_log row 는 **여전히** `user_replied=true` (fire-and-forget이라 LLM 결과와 독립)

### 1E. cron 재시도 시 idempotent

1. SQL에서 직접 row 의 `user_replied=true` 로 미리 set
2. 답장 → 마킹 코드 실행되지만 `eq('user_replied', false)` 필터로 0 rows match → 에러 없음

---

## 시나리오 2 — 푸시 권한 JIT 모달

### 2A. 신규 캐릭터 첫 메시지 → 모달 노출

**목표**: 권한 untriggered 상태에서 캐릭터 첫 메시지 보낼 때 soft-ask 모달이 뜬다.

**선조건**:
- iOS 설정 → 알림 → ZPZG → 권한 미허용 (권한 grant 된 적 없는 계정으로 fresh install 권장)
- SecureStore 클린 상태 (`fortune.push.jit.state.v1` 키 없음)

1. 새 캐릭터 채팅방 진입 (그 캐릭터로 한 번도 대화 안 한 상태)
2. 텍스트 입력 후 send
3. **기대**:
   - Alert 모달 노출: `"{캐릭터}이(가) 가끔 먼저 말 걸어도 될까요?"`
   - 버튼: `다음에` / `알림 켜기`
4. `알림 켜기` 탭 → OS 권한 prompt 노출 → `허용` 탭
5. SQL 확인:
   ```sql
   select token, platform from notification_devices
   where user_id = '<your-uid>' and active = true;
   ```
   → 토큰 row 존재해야 함

### 2B. 같은 캐릭터 두 번째 메시지 → 모달 X

1. 2A 직후, 같은 캐릭터에 두 번째 메시지 send
2. **기대**: 모달 안 뜸 (granted 상태 cache)

### 2C. "다음에" 거절 → 7일 cooldown

1. 새 fresh install (또는 SecureStore 키 삭제) → 권한 미허용
2. 캐릭터 첫 메시지 → 모달 → `다음에` 탭
3. 같은 세션 내 다른 캐릭터 첫 메시지 send
4. **기대**: 모달 안 뜸 (`soft-asked` 상태 + cooldown 시작)
5. 7일 후 (혹은 SecureStore의 `fortune.push.jit.lastSoftAskAt.v1` 값을 8일 전으로 수동 변경 후) 다시 첫 메시지 → 모달 다시 뜸

### 2D. 2회 거절 → 영구 침묵

1. 모달 → 다음에 → cooldown skip → 모달 → 다음에 (2회)
2. 그 후 어떤 캐릭터 첫 메시지 send → 모달 안 뜸 (`PUSH_JIT_SOFT_DECLINE_MAX = 2` 도달)

### 2E. OS 거부 → JIT 침묵 + 배너 표시 가능

1. 모달 → `알림 켜기` → OS 권한 prompt → `허용 안 함` 탭
2. 다른 캐릭터 첫 메시지 send
3. **기대**: 모달 안 뜸 (`canAskAgain=false`인 경우 helper가 즉시 noop)
4. (배너 UI 통합은 follow-up이므로 helper 호출 결과만 확인. `shouldShowPushDeniedBanner()` → `true` 반환되어야 함)

### 2F. 빠른 연타 send → 단일 모달

1. 신규 캐릭터에 메시지 입력 후 send 버튼 빠르게 5번 연타
2. **기대**: Alert 모달은 1번만 노출 (fire-and-forget이라 추가 호출은 모두 helper의 state check에서 `os-prompted`/`granted`/`denied`/`soft-asked` 분기로 noop)

### 2G. 이미지 첨부만 send → 모달 노출

1. 신규 캐릭터에 이미지만 첨부 (텍스트 없이) → send
2. **기대**: 모달 노출 (`willSendSomething = !!pendingImage`)

### 2H. 빈 send (action 트리거) → 모달 X

1. 신규 캐릭터, 텍스트/이미지 없이 send 버튼 (action 단축)
2. **기대**: 모달 안 뜸 (`willSendSomething=false`)

### 2I. 하늘이 (Haneul Oracle) 첫 메시지 → 모달 노출 여부 확인

1. 하늘이에게 처음 말 걸 때 모달 어떻게 동작하는지 관찰
2. **기대**: 모달 노출됨 (현재 코드는 character-kind 차별 안 함)
3. **결정 필요**: 하늘이는 fortune-only persona 라 푸시 의미 적은데, exclude 할지 follow-up 결정.

---

## 시나리오 3 — 콜드스타트 펜딩 답장 재개

### 3A. 메시지 send → 즉시 force-kill → 재실행

**목표**: 답장이 채팅창 진입 없이도 재실행 직후 자동 재개되어 도착.

**선조건**: 푸시 권한 grant 됨 (시나리오 2A 통과).

1. 캐릭터 (luts 권장) 채팅창 → 메시지 send
2. typing indicator 뜨자마자 (1~2초 내) 시뮬레이터에서 앱 force-kill
   - iOS 시뮬레이터: ⌘+⇧+H 두번 → 위로 스와이프
   - 실기기: 앱 스위처에서 위로 스와이프
3. **즉시** SQL 확인:
   ```sql
   select id, status, started_at from pending_character_reply_jobs
   where user_id = '<your-uid>' order by created_at desc limit 1;
   ```
   → `status='pending'` 또는 `'processing'` (이미 character-chat이 claim 시작했다면)
4. 30초 이내 앱 cold-start
5. **채팅창 진입하지 말고** 채팅 리스트 화면에서 대기
6. **기대**:
   - 5~15초 내 푸시 알림 도착 (foreground 라 banner 안 뜨고 알림센터에 쌓일 수 있음)
   - SQL: `status='done'` 으로 전환
   - 채팅 리스트에서 해당 캐릭터의 unread 닷 + 마지막 메시지 미리보기 갱신
7. 그 다음 채팅창 진입 → 캐릭터 응답이 이미 thread 에 들어와 있어야 함

### 3B. 메시지 send → 백그라운드 → 30초 대기 → 포그라운드 복귀

1. 메시지 send 직후 시뮬레이터 home (⌘+⇧+H) 으로 백그라운드
2. 30초 대기 (Edge Function timeout 90s 보다 짧게)
3. 포그라운드 복귀 (앱 아이콘 탭)
4. **기대**: AppState 'active' 핸들러가 `resumePendingReplies()` 호출 → 이미 처리 중이면 no-op (jobId 가 server에서 `claim_pending_reply_job_by_id` 이미 클레임됨), 처리 미시작이면 즉시 invoke

### 3C. cron vs 클라이언트 race

1. 메시지 send → force-kill → 90초 이상 대기 (cron polling 1m 이상 지나서 cron이 클레임 시도)
2. 앱 재실행
3. **기대**: 클라가 invoke 해도 `claim_pending_reply_job_by_id` 가 status 가 이미 `processing`이라 NULL 반환 → "noop already claimed" 응답 → 중복 LLM 호출 없음
4. 서버 로그에서 `[character-chat] jobId already claimed/canceled, skipping LLM` 확인

### 3D. AppState 토글 abuse

1. 메시지 send → 빠르게 active ↔ background 토글 5번
2. **기대**: in-flight dedup (`inFlightJobIds`) 으로 동일 jobId 의 character-chat invoke 는 1번만

### 3E. 다중 캐릭터 동시 pending

1. 캐릭터 A 메시지 send → 즉시 캐릭터 B 메시지 send (둘 다 응답 받기 전)
2. force-kill
3. 재실행 → cold-start 시 두 jobId 모두 발견, 둘 다 invoke
4. **기대**: 두 캐릭터 모두 응답 도착

### 3F. 권한 미허용 사용자 — 응답은 도착하지만 푸시 안 옴

1. 푸시 권한 미허용 계정으로 시나리오 3A 반복
2. **기대**:
   - 응답은 character_conversations 에 정상 저장
   - 채팅 리스트는 진입 시 갱신됨 (실시간 푸시 받지 못해 unread 닷 즉시 안 뜸)
   - 채팅창 진입하면 새 메시지 hydrate 됨 (MessageStore가 SQLite에서 읽음)

### 3G. 인증 변경 (다른 계정 로그인) 시 재개

1. 계정 A 로 메시지 send → force-kill
2. 앱 재실행 → 계정 B 로 로그인
3. **기대**: 계정 A 의 pending job 은 계정 B 입장에서 RLS로 안 보임 → 무시 (정상)
4. 계정 A 의 답장은 계정 A 가 다음에 로그인 시 (또는 cron이) 처리

---

## 통합 회귀 검사 (배포 직전 final pass)

- [ ] 일반 채팅 흐름 (proactive 와 무관) — 메시지 보내고 응답 받기 정상
- [ ] 이미지 전송 → 정상 thread 에 노출
- [ ] 다른 캐릭터 전환 시 메시지 누출 없음
- [ ] 앱 콜드스타트 시간 이전 대비 +200ms 이내 (resumer 추가로 인한 지연 미미해야)
- [ ] iOS 알림 권한 거부 후 사진 보내기 — 이미 별도 권한이므로 영향 없는지 확인
- [ ] Android (실기기 가능 시) — Alert.alert 한국어 렌더링, OS 권한 prompt 동작

---

## 합격 기준

- 시나리오 1A, 1B, 1D — 모두 PASS
- 시나리오 2A, 2B, 2C, 2F — 모두 PASS
- 시나리오 3A, 3B, 3C — 모두 PASS
- 회귀 검사 7개 항목 모두 PASS

이 중 하나라도 FAIL 시 EAS 배포 전 디버깅 필요.

---

## 알려진 limitation (배포 전 사용자 합의 필요)

1. **하늘이 캐릭터에서도 JIT 모달 노출됨** — 운세 전용이라 푸시 의미 적을 수 있음. exclude 할지 follow-up.
2. **푸시 거절 배너 UI 미통합** — `shouldShowPushDeniedBanner()` helper 만 존재. 헤더에 배너 띄우는 컴포넌트 작업은 별도.
3. **typing indicator 글로벌화 안 됨** — chat-screen 진입 전엔 typing 표시 안 보임. 응답 자체는 도착하므로 핵심 목표는 달성, UX 폴리싱은 follow-up.
