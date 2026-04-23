# 05 — Profile / Settings / Account QA Checklist

Scope: profile tab, edit, notifications, relationships, saju summary, account deletion, character block, legal pages. Source: `apps/mobile-rn/src/screens/profile-*.tsx`, `account-deletion-screen.tsx`, `character-profile-screen.tsx`, `supabase/functions/delete-account/index.ts`.

---

## 1. Profile screen button inventory (`profile-screen.tsx`)

| Row / Button | onPress target | Visibility | Expected |
|---|---|---|---|
| Header back chevron | `router.back()` → fallback `/chat` | always | Pop or replace to chat |
| Avatar initial | — | always | First char of displayName/email |
| `프로필 수정` PrimaryButton | `router.push('/profile/edit')` | always | Opens edit screen |
| Info grid rows (이름/생년월일/태어난 시간/MBTI/혈액형) | `router.push('/profile/edit')` | editField only | Taps go to edit |
| Info grid rows (띠/별자리/토큰) | no-op | always | Non-pressable display |
| `내 만세력` | `/profile/saju-summary` | always | Manseryeok dashboard |
| `인간관계` | `/profile/relationships` | always | Relationship map |
| `알림 설정` | `/profile/notifications` | always | Notifications screen |
| `Ondo 위젯 미리보기` | `/widgets` | always | Widget preview |
| `구독 및 토큰` | `/premium` | always | Premium paywall |
| `구매 복원` | `restorePurchases()` | always | Spinner label `구매 복원 중...`, alert on failure |
| `구독 관리` | `Linking.openURL` → App Store / Play | always | Opens store subscription page |
| Theme chips 시스템/라이트/다크 | local `setThemeMode` | always | Active state only (NOT wired to real theme) |
| AI 응답 chips 클라우드/온디바이스/자동 | `saveSettings({aiMode})` | always | Persists setting |
| `AI 모델 다운로드` | `onDeviceLLMEngine.startDownload()` | aiMode≠cloud & not-downloaded | Begins GGUF download |
| Download progress `취소` | `cancelDownload()` | downloading | Aborts |
| 채팅 진동 켜짐/꺼짐 | `saveSettings({chatHapticsEnabled})` | always | Toggle + persist |
| 계정 연결 row | — (display only, chevron is cosmetic) | session & provider | Shows Google/Apple/Kakao badge |
| 개인정보처리방침 | `/privacy-policy` | always | Legal screen |
| 이용약관 | `/terms-of-service` | always | Legal screen |
| 사용자 라이선스 (EULA) | `/eula` | always | Legal screen |
| 면책 조항 | `/disclaimer` | always | Disclaimer screen |
| 사업자 정보 | `/business-info` | always | Business info |
| 오픈소스 라이선스 | `/open-source-licenses` | always | OSS list |
| `회원가입 / 로그인` | `/signup?returnTo=/profile` | !session | Auth flow |
| 로그아웃 | `supabase.auth.signOut()` → `/chat?showList=1` | session | Confirm alert → sign out |
| 계정 삭제 | `/account-deletion` | session | Opens deletion screen |
| 앱 초기화 (Factory Reset) | `handleResetOnboarding` + `Updates.reloadAsync` | `isTestAccountEmail(email)` only | Wipe + reload |
| 버전 / build badge | — | always | v / runtime / build badge |

---

## 2. Execution test checklist

**Profile load**
- [ ] Launch → `/profile` renders name, avatar initial, email, token balance (∞ if unlimited).
- [ ] Provider badge shows Google/Apple/Kakao/이메일 per `app_metadata.provider`.
- [ ] Info grid 띠/별자리 populate when `birthDate` present; show "—" otherwise.
- [ ] Focus return from /edit calls `refreshLocalState + syncRemoteProfile` (values stay fresh).

**Profile edit**
- [ ] Tap 프로필 수정 → pre-fills from SecureStore.
- [ ] Change name/DOB/MBTI/blood/birth time → 저장 → SecureStore written, Supabase push logged, toast "저장 완료" after back.
- [ ] 취소 pops without write.
- [ ] InlineCalendar maxDate blocks future dates.
- [ ] 생년월일 "변경" button re-opens calendar.
- [ ] Empty save (no DOB) persists empty strings; profile screen shows "—".
- [ ] Save with no network → remote push fails silently (local still saved), warn logged.

**Notifications**
- [ ] Open `/profile/notifications` → hydrates from `state.notifications`.
- [ ] Toggle each switch (push / chatReminders / weeklyDigest / marketing) → UI flips immediately.
- [ ] Tap `테스트 알림 보내기` → calls `saveNotifications(preferences)`. **⚠ 현재 구현은 OS 권한 프롬프트나 푸시 토큰 등록을 트리거하지 않음** (red flag below).
- [ ] Alarm time chip cycles 06:00→09:00 in 30 min steps, wraps.

**Relationships**
- [ ] `/profile/relationships` — 스토리/인사이트 섹션 분리.
- [ ] Stat chips: `캐릭터 N명`, `대화 N개` reflect real `sentMessageCount`.
- [ ] Tap a card → `/character/[id]?returnTo=/profile/relationships`.
- [ ] `새 친구 만들기` → `/friends/new`.
- [ ] (Note: no "remove secondary profile" UI on this screen — character blocking handled on character profile.)

**Saju summary**
- [ ] `/profile/saju-summary` with valid birthDate → HeroManseryeok 4 pillars + 15 rows.
- [ ] YearSwitcher changes refYear → useMySaju refetches; LuckCycle / AnnualCycle / MonthlyCycle update.
- [ ] Missing/malformed birthDate → fallback Card (no crash).

**Character block (P11)**
- [ ] Non-fortune character → Safety Card visible; fortune character → hidden.
- [ ] 이 캐릭터 차단하기 → Alert "차단하면…" → 차단하기 (destructive) → `blockCharacter(id)` → success Alert → `router.replace('/chat')`.
- [ ] After block, character disappears from chat list.
- [ ] `blockCharacter` failure → "차단 실패" alert, no redirect.
- [ ] 취소 closes alert, no state change.
- [ ] (Deferred) Manage-blocked-characters screen — not yet present; confirm no UI link.

**Legal pages**
- [ ] Each of /privacy-policy, /terms-of-service, /eula, /disclaimer, /business-info, /open-source-licenses renders title + summary + sections via `LegalScreen`.
- [ ] Back button (`RouteBackHeader fallbackHref=/profile`) works from deep link (app launched on URL).
- [ ] "프로필로 이동" / "채팅으로 돌아가기" buttons route correctly.
- [ ] Korean typography consistent across pages (same `displaySmall`/`heading4`).
- [ ] No empty section bodies (visual scan).

**Factory Reset (test accounts only)**
- [ ] Non-test email → card NOT rendered (`isTestAccountEmail` false).
- [ ] Test email → card visible, 앱 초기화 button.
- [ ] Tap → confirm alert → 초기화 후 재시작 → remote profile cleared, signOut, all 9 SecureStore keys wiped, Updates.reloadAsync.
- [ ] Partial failure shows "일부 단계 실패" alert with failure list, still reloads.

**Sign out**
- [ ] Confirm alert → signOut → router.replace `/chat?showList=1`.
- [ ] Next cold launch shows welcome carousel (WELCOME_SEEN_KEY NOT cleared by logout — only by Factory Reset). ⚠ verify expected.

**Delete account**
- [ ] `/account-deletion` renders warning card.
- [ ] Button disabled until user types `삭제`.
- [ ] On confirm → `supabase.functions.invoke('delete-account')` → signOut → `/chat`.
- [ ] Server-side: 25 tables (incl. fcm_tokens, user_notification_preferences, llm_usage_logs, message_reports.reporter_id, character_blocks, user_profiles) purged + `profile-images/<uid>/` storage list+remove.
- [ ] Any table delete fails → 500 → auth user NOT deleted → retry idempotent.
- [ ] Storage purge fails → 500 → auth user NOT deleted → retry idempotent.
- [ ] Re-sign-in after successful deletion → fresh onboarding, zero prior rows (verify user_profiles, token_balance, fortune_history, chat_conversations, fcm_tokens).

---

## 3. Red flags / static findings

1. **Notifications screen does NOT register push token.** `handleSave` only persists prefs via `saveNotifications`. W9 spec says toggling push should call `registerPushTokenForSignedInUser(..., { promptIfNotGranted: true })`. Currently flipping the push switch writes local pref only; OS permission prompt never fires and no row lands in `fcm_tokens`. Evidence: `profile-notifications-screen.tsx:111-113`, no import of `registerPushTokenForSignedInUser`. The only call sites are bootstrap (`app-bootstrap-provider.tsx:274,355`).

2. **Delete account spinner deadlock on 500.** `handleDeleteAccount` sets `isDeleting=true`, invokes edge fn. On `error` branch it sets error message + `setIsDeleting(false)` in `finally` — OK, not stuck. **However**, on network timeout (edge function hangs >60s) the Supabase client default timeout applies; there is no AbortController. User sees red button spinner indefinitely if edge function streams no response. Add a client timeout (e.g., 45s) and surface retry CTA.

3. **Delete account UX gap:** retry after 500 is silently idempotent (server guards), but UI re-enables button without explaining "이전 시도에서 일부 데이터가 정리되지 않았어요. 다시 시도해 주세요." — generic message only.

4. **Profile edit race vs background session refresh.** `handleSave` does SecureStore → `refreshLocalState` → remote push. If `syncRemoteProfile` on profile screen focus fires between SecureStore write and remote push (it runs `.catch(() => undefined)`), remote stale values could overwrite local. Mitigated by doing remote push BEFORE navigating back, but if remote push throws, local wins locally while remote stays stale → next cold launch re-hydrates stale remote. Consider a pending-write queue.

5. **Accessibility:** `IconMenuTile` has `accessibilityRole="button"` ✅. `ProfileInfoGrid` row Pressables lack `accessibilityRole` and `accessibilityLabel` — VoiceOver will read whole cell as text. Same for 로그아웃 / 계정 삭제 Pressables on profile-screen:771-793. Legal page "이어서 보기" PrimaryButtons OK.

6. **Theme chips are dead UI.** `setThemeMode` is local state with no wiring to the actual theme provider — user can tap 라이트/다크 but nothing changes. Either wire or hide until implemented.

7. **AI 응답 "자동" (auto)** — `saveSettings` accepts it but there's no runtime branching that respects `auto` vs `on-device` in chat-surface as of this branch; verify before shipping the chip as visible.

8. **Factory Reset clears WELCOME_SEEN_KEY, but Sign out does not.** Intentional but inconsistent with "로그아웃 후 next launch welcome carousel" expectation in checklist. Confirm product intent.

9. **Test-account gate leaks visually only.** `isTestAccountEmail` check is client-side; the `runResetSteps` function including `updateRemoteUserProfile` is compiled into every build. Not exploitable (requires user's own session), but any future extension (e.g., impersonation) could be. Server-side guard not needed for current scope.

10. **Account deletion screen: `deletionReasons` not sent.** The array of 3 reasons is rendered as static cards; no selection state, no submission. Edge fn accepts `reason` from payload but client sends empty body. Either wire the reasons as a selector or remove the UI (dead-code red flag).

11. **Delete account — `character_conversations` missing `returning` audit when CASCADE wins.** Comment notes CASCADE already handles it; the explicit delete returns 0 rows silently (logged as `zero_rows`). Not a bug but log noise.

12. **Relationships screen** has no "add/remove secondary profile" affordance — the checklist item is aspirational; current UI only links to `/friends/new` for new character creation, not secondary profile management (that lives elsewhere — `secondary_profiles` table is only touched by `delete-account`). Confirm QA expectation.

---

## 4. Verification status

- `npx tsc --noEmit`: NOT run (read-only QA pass).
- Manual device verification: required for items (1), (2), (6), (7), (10).

---

File paths:
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-screen.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-edit-screen.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-notifications-screen.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-saju-summary-screen.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/account-deletion-screen.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/character-profile-screen.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/legal-screen.tsx`
- `/Users/injoo/Desktop/Dev/fortune/supabase/functions/delete-account/index.ts`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/lib/push-notifications.ts`
