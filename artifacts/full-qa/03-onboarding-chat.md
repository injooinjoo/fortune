# Ondo QA — Onboarding + Chat Home

Scope: splash → welcome → onboarding (name/birth/mbti/relationship/tone/topics) → chat home.
Source references are absolute paths from repo root; all routes use expo-router.

---

## 1. Screen-by-screen walkthrough

### Splash `app/splash.tsx` → `src/screens/splash-screen.tsx`
- Wordmark "온도" + `ONDO` + version. No inputs.
- Only `계속 →` escape Pressable after `SLOW_NETWORK_ESCAPE_MS` (4000ms) when `status !== 'ready'`.
- Auto-advance `AUTO_ADVANCE_MS` (1400ms) once `status === 'ready'`.
- Nav by `gate`: `auth-entry` → `readWelcomeSeen()` ? `/signup` : `/welcome`; `profile-flow` → `/onboarding`; else `/chat`. Reads `ondo.welcome-seen.v1`.

### Welcome `app/welcome.tsx` → `src/screens/welcome-screen.tsx`
- 7 scenes: 5 stack + brand reveal + thermometer (0.0→36.5°C, 2400ms).
- Single CTA bar, per-scene label. No Back/Skip.
- Final scene: `markWelcomeSeen()` → `router.replace('/signup')`.

### Onboarding flow shell `src/components/onboarding-shell.tsx`
Every step shares: progress pill (`step/total`), optional Back chevron (hidden/disabled when `onBack` omitted), optional `건너뛰기`, pinned Primary CTA (`다음` by default, disabled when `nextDisabled`), `keyboardAvoiding` Screen wrapper, header role on title.

NOTE: there is a LEGACY `OnboardingScreen` (`src/screens/onboarding-screen.tsx`) still mounted at `/onboarding/index.tsx`. The Ondo 6-step flow starts at `/onboarding/name`. Confirm which route `/onboarding` resolves to at launch — likely legacy card-based flow. (See Red flag §5.)

### Step 1 — Name `app/onboarding/name.tsx`
- Title `어떻게 불러드릴까요?` · caption `편하게 부르실 이름이나 별명을 알려주세요`.
- Input: `TextInput` autoFocus, returnKeyType=done. No Back (first step, arrives via `replace`). No Skip.
- Next disabled when `!name.trim()`. On Next: `update({ name })`, push `/onboarding/birth`.

### Step 2 — Birth `app/onboarding/birth.tsx` (W1 age gate)
- Title `생년월일을 알려주세요` · caption `사주·운세 해석과 대화 톤에 참고해요`.
- Input: `DateInput { y, m, d }` autoFocus.
- `valid` = y.length===4 && m.length≥1 && d.length≥1. `nextDisabled=!valid`.
- Back → `router.back()`. Skip → `goNext()` (no age check, no `update`).
- On Next: if `!valid` call `goNext()` (shouldn't fire due to disabled); else `computeAgeYears(birth)`; if `age < 14` → `Alert.alert('이용 연령 안내', …)` and RETURN (no update, no nav). Else `update({ birth })` + push `/onboarding/mbti`.

### Step 3 — MBTI `app/onboarding/mbti.tsx`
- Title `MBTIを`알려주세요 · caption mentions skip.
- Input: `MBTIPicker`.
- Next always enabled (optional). On Next: if mbti picked → `update({ mbti })`, then push `/onboarding/relationship`. Skip → same target, no update.

### Step 4 — Relationship `app/onboarding/relationship.tsx`
- Title `어떤 사람과 대화하고 싶으세요?` · caption `나중에 언제든 바꿀 수 있어요`.
- 5 cards: 친구/선배/연인/멘토/운세 전문가. Single-select.
- No Skip. `nextDisabled=!selected`. On Next: `update({ relationship })`, push `/onboarding/tone`.

### Step 5 — Tone `app/onboarding/tone.tsx`
- Title `어떤 말투가 좋으세요?` · caption `아무 때나 설정에서 바꿀 수 있어요`.
- 3 `ToneSlider`s: formality/warmth/length (0|1|2). Defaults from provider (0,0,1).
- No Skip, always-valid. On Next: `update({ tone })`, push `/onboarding/topics`.

### Step 6 — Topics `app/onboarding/topics.tsx` (terminal)
- Title `어떤 이야기를 나누고 싶으세요?` · caption `여러 개 골라도 돼요`.
- 16 `SelectableChip`s (일상…타로). Multi-select.
- Next label `시작하기`, disabled when `selected.length===0`. `nextLoading` shown while finishing.
- On finish: `update({ topics })` → `saveProfile({ displayName, birthDate:"YYYY-MM-DD", mbti, interestIds })` → `updateOnboardingProgress({ birthCompleted, interestCompleted })` → `completeOnboarding()` → `router.replace('/chat')`. Failure → `captureError` + `Alert.alert('설정 저장 실패', …)` + re-enables button.

### `/onboarding/toss-style` → `Redirect` to `/onboarding`.

### Provider `src/providers/onboarding-flow-provider.tsx`
In-memory only (`useState`). `update(patch)` merges; `reset()` restores DEFAULT. Not persisted — see Red flag.

### Home chat `app/(tabs)/chat.tsx` → `src/screens/chat-screen.tsx` + `chat-surface.tsx`
- `gate`: `auth-entry` / `profile-flow` (ProfileFlowGateCard) / `ready`.
- Assistant long-press → `MessageReportSheet` (chat-surface:848).
- `useBlockedCharacterIds()` filters `tabCharacters` (chat-screen:1039).
- Composer `+` opens tray, up to 12 actions. Pending pill `대기 +N` when `queuedCount>0`.

---

## 2. Age gate tests (W1)

- [ ] 14세 이상 → `update({ birth })` + push `/onboarding/mbti`.
- [ ] 14세 미만 → Alert "이용 연령 안내", 머묾, no update.
- [ ] 만14세 당일(생일) → 허용 (`hasHadBirthday=true`).
- [ ] 생일 하루 전 + 14년 전 출생 → age=13 → 차단.
- [ ] 2/29 출생, 평년 오늘 → `hasHadBirthday` false until 3/1 — 윤년 케이스 수동 검증.
- [ ] Skip 버튼 → age gate 우회 (`onSkip=goNext` birth:44, no update). 제품팀 확인 필요.
- [ ] 미래 날짜 or y<1900 → `computeAgeYears` null → 차단 없이 통과 (버그 후보).
- [ ] m=13, d=32 → `valid` gate (length only)는 통과, `computeAgeYears` null → 통과.

---

## 3. Home chat checklist

- [ ] 캐릭터 리스트 로드 (`tabCharacters` → `buildCharacterListMeta`).
- [ ] 캐릭터 탭 → `surfaceMode='chat'` + thread 로딩 (`loadCharacterConversation`).
- [ ] Assistant 메시지 long-press (500ms 기본) → `MessageReportSheet` 오픈. 사용자 본인 메시지 long-press 불가.
- [ ] 프로필 → 차단 → `/chat` 복귀 시 해당 캐릭터 리스트에서 제외 (`useBlockedCharacterIds`).
- [ ] Composer `+` → tray 열림/닫힘 토글. 12개 초과 액션은 잘림.
- [ ] InlineCalendar (`date` survey step), SelectableChips (`chips`), 카드 뽑기 (`card-draw`), ImagePicker (`image`) 렌더.
- [ ] TextInput focus → keyboardAvoiding(Screen wrapper) composer 가림 없음.
- [ ] 빈 메시지 전송 버튼 비활성 / voice toggle로 전환.
- [ ] Voice 버튼 → 권한 프롬프트 → transcribing state 표시.
- [ ] 관상 Image picker → `SurveyImagePicker`, 834번 줄 고지문 "선택한 사진은 관상 분석을 위해 안전한 서버로 전송되며…" 노출 (W14).
- [ ] Offline 송신 → `pendingSendCountByCharacterId` 증가 → "대기 +N" pill 표시 → 연결 복구 시 flush.
- [ ] ProfileFlowGateCard: 온보딩 미완 시 `/onboarding` 푸시 또는 `completeOnboarding()`.
- [ ] FloatingCreateButton → 친구 생성 플로우.
- [ ] ChatSoftGate, ChatFirstRunSurface — auth-entry 단계에서 phone 입장 유도.

---

## 4. Splash/Welcome tests

- [ ] Cold start 1.4s 안에 ember 애니메이션 + 온도 wordmark.
- [ ] 4s 경과, bootstrap not ready → `계속 →` 버튼 노출, tap 시 `router.replace(nextRoute ?? '/welcome')`.
- [ ] welcome-seen=false → `/welcome` redirect (auth-entry).
- [ ] welcome-seen=true + unauthed → `/signup`.
- [ ] 인증 완료 + 프로필 미완 → `/onboarding`.
- [ ] 인증 완료 + 프로필 완 → `/chat`.
- [ ] Welcome scene 1→7 CTA 순차 진행, 마지막 `계속` → `markWelcomeSeen()` 후 `router.replace('/signup')`.
- [ ] Welcome brand scene(6) wordmark 렌더 OK (과거 84pt clip bug fix 확인).
- [ ] Thermometer scene 수은주 fill 0→85%, temp label 0.0→36.5°C.

---

## 5. Red flags / static findings

1. **Welcome-seen race**: `await markWelcomeSeen()` precedes `router.replace` (welcome:108) — OK.
2. **Flow-provider data loss**: pure `useState`. OS kill mid-onboarding resets name/birth/mbti/tone. `saveProfile` only runs at topics step. Recommend SecureStore mirror per `update`.
3. **Age gate holes** (birth.tsx): future years / y<1900 return null and pass through; Skip bypasses by design; Alert has no auto-refocus.
4. **Dual onboarding entry**: `/onboarding/index.tsx` still renders legacy `OnboardingScreen` (cards + interest chips), while W-series lives at `/onboarding/name`…. Splash routes to `/onboarding` — profile-flow gate likely lands on legacy, not the redesign. **Router mismatch to confirm.**
5. **Chat-surface perf**: 2431-line surface — verify long threads use virtualization (FlashList) rather than map.
6. **a11y**: shell Back/Skip/header labels OK. Composer `+` labeled; audit tray items, voice toggle, send button.
7. **Hardcoded hex** in welcome+splash (intentional per Ondo Splash.html), but diverges from `fortuneTheme.colors.*`. Design debt only.
8. **DateInput** doesn't reject calendar-invalid dates (Feb 30, m=13); `valid` is length-only.
9. **SecureStore failure on welcome-seen** → returns "not seen" silently; user re-sees welcome every cold start.
