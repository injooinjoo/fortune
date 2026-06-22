# Ondo Focused Consulting Findings — 2026-06-22

## Scope

User asked to avoid too many external skills/agents, install only important ones, and run one focused consulting pass on why the Ondo app feels “구린지” and where to revise first.

This was a **no-code consulting pass**. No product/runtime code was changed.

## External skills installed

Installed globally through `npx skills add ... -g -y`:

1. `anthropics/knowledge-work-plugins@design-critique`
   - Role: first-impression, usability, hierarchy, consistency, accessibility critique.
2. `wshobson/agents@react-native-design`
   - Role: React Native mobile UI/UX, navigation, animation/layout review.
3. `pproenca/dot-skills@expo-react-native-performance`
   - Role: Expo/RN startup, list, render, animation, image, memory performance review.
4. `safaiyeh/app-store-review-skill@app-store-review`
   - Role: App Store, IAP, privacy, account deletion, AI/health-sensitive wording risk review.

Skipped for now to avoid agent confusion:
- generic mobile testing skills
- low-install onboarding/CRO skills
- broader mobile-dev agent specs that overlap with Ondo’s existing internal agent roles

## Repo state at audit start

- Repo: `/Users/injoo/Desktop/Dev/fortune`
- `git pull --ff-only`: already up to date
- Branch: `master...origin/master`
- Dirty state before report creation: clean
- Project rules reviewed: `AGENTS.md`, `CLAUDE.md`

## Executive verdict

Ondo’s “구림” is not one isolated visual bug. It comes from four converging problems:

1. **First value is delayed**: warm emotional onboarding leads into login/profile gates before the app proves its value.
2. **Product identity is blurry**: AI friend, fortune, mood temperature, token economy, profile setup, on-device AI, and premium are all competing for attention.
3. **Design execution is inconsistent**: core first-impression surfaces still use raw colors/text/styles instead of a tight app-level visual system.
4. **Chat architecture is too coupled**: the main chat files are huge, non-virtualized, and still carry duplicated message source-of-truth logic, making UX polish risky and regressions likely.

Recommended first move: **do not start by adding features.** Start by rebuilding the first-session path around a simple promise:

> “Open app → immediately receive a meaningful AI friend / fortune moment → only then ask to save, personalize, or pay.”

## Priority findings

### P0/P1 — First session is blocked before value is proven

#### Finding
Welcome creates emotional expectation, then routes the user into chat/auth/profile gates instead of a direct first meaningful experience.

#### Evidence
- `apps/mobile-rn/src/screens/welcome-screen.tsx`
  - `SCENES` defines a 7-step emotional onboarding sequence.
  - completion routes to `/chat?showList=1`.
- `apps/mobile-rn/src/screens/chat-screen.tsx`
  - `gate === 'auth-entry'` renders `ChatSoftGate`.
  - `gate === 'profile-flow'` renders profile/onboarding gate.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  - login gate copy includes “기록과 개인화를 계속 이어가세요”, “계정을 연결하고 시작”.
  - “로그인 없이 둘러보기” exists but is visually secondary.
  - `ProfileFlowGateCard` asks for profile data before chat value is fully experienced.

#### Why it feels bad
The app promises emotional relief, then asks for setup. That makes the experience feel like a questionnaire/login funnel instead of a companion app.

#### Minimal direction
- Welcome completion should lead to one of two high-value guest-first actions:
  1. “오늘의 운세 바로 보기”
  2. “AI 친구와 바로 대화”
- Move login to the moment of saving/restoring/purchasing.
- Move birth/MBTI/topics into contextual personalization prompts, not a front-loaded gate.

---

### P1 — Chat home hides the app’s core jobs-to-be-done

#### Finding
The app’s main surface is labeled and structured like a generic message inbox, while Ondo’s core actions are fortune, emotional check-in, and AI friend interaction.

#### Evidence
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  - header copy is basically `메시지`.
  - list mode is character-row centered.
  - new friend creation is a floating plus icon, with label mostly in accessibility.
  - fortune/quick actions are inside composer tray, not obvious from the home surface.
- `apps/mobile-rn/src/screens/chat-screen.tsx`
  - list overlay has `FloatingCreateButton label="새 대화 시작"` but visually this remains a generic FAB pattern.

#### Why it feels bad
Users do not immediately know “what to do today.” The app becomes an inbox with hidden features rather than a daily ritual.

#### Minimal direction
Replace the top-level chat list mental model with a **Today/Companion hub**:

1. Primary card: “오늘의 운세 보기”
2. Secondary card: “AI 친구에게 지금 기분 말하기”
3. Tertiary action: “새 친구 만들기”
4. Recent conversations below

Do not bury fortune in the composer tray only.

---

### P1 — Design system drift creates the “cheap/unfinished” feel

#### Finding
The project rules say to use `AppText` and `fortuneTheme`, but several visible surfaces use local tokens, raw React Native `Text`, and hardcoded colors. This makes each screen feel designed by a different system.

#### Evidence
- `packages/design-tokens/src/index.ts`
  - official colors, spacing, radius, typography exist.
- `apps/mobile-rn/src/screens/welcome-screen.tsx`
  - defines local `T` token object.
  - uses raw `Text`, inline font/color decisions.
- `apps/mobile-rn/src/screens/signup-screen.tsx`
  - hardcoded `#FFFFFF`, `#111111` on auth buttons.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  - pastel quick-action RGBA values and recording red hardcoded.
- Static count under `apps/mobile-rn/src` found high volume of raw style signals:
  - `#` color hits: 344
  - `rgba(` hits: 116
  - `fontFamily` hits: 76
  - raw `Text` / `<Text` hits: 213

#### Why it feels bad
Even if individual screens are “fine,” the app lacks one polished visual language. Hardcoded colors, mismatched button styles, and raw text choices accumulate into a cheap-feeling product.

#### Minimal direction
Start with a visual-system cleanup of only first-session surfaces:

1. Welcome
2. Chat home
3. First active chat
4. Fortune entry card
5. Premium/top-up

Promote repeated colors into semantic tokens:
- `brand.primary`
- `brand.warm`
- `surface.card`
- `action.primary`
- `danger.recording`
- `premium.accent`

---

### P1 — Chat runtime architecture makes UX polish risky

#### Finding
Two chat files are too large and hold too many responsibilities.

#### Evidence
Largest TS/TSX files include:
- `apps/mobile-rn/src/screens/chat-screen.tsx` — about 4,960 lines
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` — about 3,696 lines

`chat-screen.tsx` mixes routing, message state, send queues, transcription, remote calls, survey flow, unread state, audio/image drafts, scroll control, and UI composition.

#### Why it feels bad
When chat UX is structurally hard to reason about, small visual or interaction improvements risk causing no-reply, stale-message, push/list/room mismatch, scroll, audio, and retry regressions.

#### Minimal direction
Do not rewrite everything. Split only along current pain boundaries:

1. `chat-message-orchestrator` — send/retry/pending job coordination
2. `chat-thread-selector` — canonical message list, unread, latest preview
3. `chat-composer-controller` — text/image/audio draft and send intent
4. `chat-surface` — mostly rendering/presentation

This should be done after the product/first-session direction is chosen.

---

### P1 — Long chat threads are non-virtualized

#### Finding
Active chat renders message items through a scroll surface and `.map`, not a virtualized list.

#### Evidence
- `apps/mobile-rn/src/components/screen.tsx`
  - `Screen` wraps content with `ScrollView`.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  - active chat renders all message items through `.map`.
  - render items are rebuilt through `visibleMessages` and `buildChatRenderItems(...)`.

#### Why it feels bad
Early use is fine, but real companion apps accumulate long histories. Mount time, scroll performance, memory, and visual jitter will degrade exactly in the most valuable user state: long-term relationship/chat history.

#### Minimal direction
Move active chat rendering to `FlatList` or `FlashList` with:
- stable item keys
- item type separation for messages/dividers/result cards
- memoized message rows
- controlled scroll-to-bottom behavior

---

### P1 — Message source of truth is still duplicated

#### Finding
Chat display state still reconciles multiple message authorities.

#### Evidence
- `apps/mobile-rn/src/screens/chat-screen.tsx`
  - local `messagesByCharacterId` state exists.
  - `useStoreMessages(selectedCharacterId)` is also read.
  - `useStoreMessagesMap(...)` is also read.
  - `displayMessagesByCharacterId` prefers store messages over local state.
  - nearby comments mention prior cross-character leak and stale snapshot bugs.

#### Why it feels bad
This is likely behind recurring “push arrived but room/list differs,” “message disappears,” and “reply exists but not visible” classes of bugs. It also makes the app feel unreliable even if the UI is pretty.

#### Minimal direction
Define one canonical visible-thread selector and make:
- room render
- list preview
- unread count
- push hydration
- retry/pending state
all read from that same selector.

---

### P1 — Legal/privacy/IAP trust has concrete mismatch risks

#### Finding A: Paywall legal links may point to stale hosted legal copy

##### Evidence
- `apps/mobile-rn/src/screens/premium-screen.tsx`
  - opens Supabase legal URLs directly.
- `supabase/functions/legal-pages/index.ts`
  - hosted privacy/terms content is thinner/older.
  - hosted terms mention Apple payments, despite Google Play support elsewhere.
- `apps/mobile-rn/app/privacy-policy.tsx`
  - in-app privacy copy is richer and newer.

##### Direction
Serve hosted legal pages from the same source as in-app legal screens, or make the app link to a canonical generated legal document.

#### Finding B: Health/phone/privacy disclosures appear inconsistent

##### Evidence
- `apps/mobile-rn/app.config.js`
  - privacy manifest declares phone number.
- `apps/mobile-rn/app/privacy-policy.tsx`
  - signup/login section does not clearly list phone number.
  - says sensitive health information is not collected.
- `supabase/functions/fortune-health/index.ts`
  - request model includes chronic condition, body parts, heart rate, blood pressure, glucose, oxygen-like health data.
  - request body substring is logged.

##### Direction
Decide if health-like data is collected. If yes, disclose it consistently and stop logging raw health request content.

#### Finding C: Apple account deletion revoke is deferred

##### Evidence
- `apps/mobile-rn/src/screens/account-deletion-screen.tsx`
  - TODO says Apple revoke is not implemented; only Supabase-side deletion is performed.

##### Direction
Implement Apple credential/token revocation or document a safe reason why unavailable before review.

---

### P2 — Premium/Profile expose internal system language

#### Finding
Premium and Profile talk like internal infrastructure screens: tokens, long answer counts, cloud model, Gemini model name, on-device model download, device tier/variant.

#### Evidence
- `apps/mobile-rn/src/screens/premium-screen.tsx`
  - “토큰 충전”, “긴 답변”, “심층 분석”, “스토어 확인 필요” style copy.
- `apps/mobile-rn/src/screens/profile-screen.tsx`
  - “AI 응답 모드”, “클라우드 모델”, `Gemini 3.1 Flash Lite`, on-device AI download/status/error.

#### Why it feels bad
The user sees the machinery instead of the benefit. This makes the app feel experimental rather than emotionally polished.

#### Minimal direction
- Premium should sell outcomes:
  - “하루 대화 여유”
  - “심층 운세 n개”
  - “관계/사주 리포트 n개”
- Profile should default to user tasks:
  - 내 정보
  - 운세 기록
  - 알림
  - 구독/결제
- AI model/download belongs under “고급 설정” or “실험실”.

## Recommended improvement order

### Phase 1 — Decide first-session product story
No code first. Write a one-page desired flow:

1. First launch
2. First emotional value moment
3. First chat or fortune action
4. Save/personalize prompt
5. Premium/top-up moment

### Phase 2 — Fix first-session surfaces only
Implement a narrow visual/product revision:

1. Welcome completion target
2. Chat home as Today/Companion hub
3. One guest-first fortune or AI friend path
4. First premium/top-up copy simplification

### Phase 3 — Stabilize chat source-of-truth
Before heavy chat UX polish, reduce the risk of disappearing/mismatched messages:

1. canonical thread selector
2. list/room/push/latest preview unification
3. message render virtualization plan

### Phase 4 — Legal/trust cleanup
Before next review/submission push:

1. canonical hosted legal pages
2. health/privacy disclosure alignment
3. account deletion Apple revoke story
4. subscription lifecycle notification/reconciliation plan

## What not to do next

- Do not install ten more skills/agents.
- Do not start redesigning every screen.
- Do not polish premium before first value is clear.
- Do not touch chat visuals heavily before the canonical message source is under control.
- Do not ship App Store-facing changes until legal/privacy mismatches are reconciled.

## Best next concrete task

Create a small implementation plan for:

> “온도 첫 3분 경험 개선: Welcome → guest-first Today hub → first fortune/chat value → save/personalize later.”

Acceptance criteria:
- user reaches a meaningful chat/fortune result without account/profile wall
- chat home clearly offers 2 primary jobs: today fortune + AI friend conversation
- no new payment/security changes
- no broad architecture rewrite
- simulator evidence before OTA
