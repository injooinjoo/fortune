# iOS Review Audit 03 — AI Content Safety

App: Ondo (온도) — Expo RN 1.0.9, bundle `com.beyond.fortune`
Scope: Apple Guideline rejection risk for AI-generated content, fortune telling,
character chat, image/voice input, minor protection. Date: 2026-04-23.

Legend: **CRITICAL** = likely rejection, **WARNING** = likely ask-for-info,
**INFO** = acceptable but worth tracking.

---

## 1. Guideline 1.1.6 — False information / fortune-telling disclaimer

### Finding 1.1 — Disclaimer exists and surfaces on first launch — INFO (PASS)
- Modal on first launch: `apps/mobile-rn/src/screens/onboarding-screen.tsx:150,335-362`
  ("오락 목적 안내" gate, gated by `DISCLAIMER_STORAGE_KEY`).
- Re-reachable any time from Profile: `apps/mobile-rn/src/screens/profile-screen.tsx:722-723`.
- Dedicated page: `apps/mobile-rn/app/disclaimer.tsx:7-22` ("오락 목적",
  "의료, 법률, 금융 등 전문 분야의 조언으로 사용해서는 안 됩니다").
- Back-end mirror: `supabase/functions/legal-pages/index.ts:54,66`.
- ToS mirror: `public/terms.html:108`.
- App Store notes: `metadata/review_information/notes.txt:23-26` explicitly
  claims entertainment-only and "no factual predictions, medical/legal/financial
  advice." Rating 12+.

### Finding 1.2 — Per-result disclaimer is inconsistent — WARNING
- Result cards (hero-*.tsx, fortune-results screens) have NO footer disclaimer on
  the 30+ result screens. Only `fortune-wealth` and `fortune-past-life` emit a
  "disclaimer" field (`supabase/functions/fortune-wealth/index.ts:404,526`; past-
  life rows `category: "entertainment"` lines 695-837). Health, tarot, saju,
  compatibility, face-reading result bodies do not include an inline entertainment
  disclaimer.
- Apple reviewers frequently want disclaimer visible on each result, not only at
  onboarding. Recommend adding a common footer line via
  `apps/mobile-rn/src/features/fortune-results/primitives/result-card-frame.tsx`
  (one change, global).

---

## 2. Guideline 1.1.1 — Objectionable / manipulable AI content

### Finding 2.1 — No server-side moderation API call — CRITICAL
- Every LLM path goes through `LLMFactory` but none call OpenAI moderation,
  Google's separate safety filters, or any equivalent. Grep for
  `moderation|moderations\.create|HarmCategory|safetySettings` returns **0 hits**
  in `supabase/functions`.
- Gemini provider is called with raw `generationConfig` only, no `safetySettings`:
  `supabase/functions/_shared/llm/providers/gemini.ts:56-66`. Google's default
  thresholds apply but are relaxed for harassment/sexual; Apple reviewers have
  rejected apps that rely on provider defaults without app-level moderation.
- `SAFETY_BLOCK_FINISH_REASONS` (line 15-22) only observes, never pre-filters user
  input. Image inputs bypass moderation entirely.

**Recommendation**: add OpenAI moderation (cheap, multilingual) on both
`userMessage` and LLM `response` in `supabase/functions/character-chat/index.ts`
before returning. Same for `free-chat` and `fortune-*` functions that accept
free-form user input.

### Finding 2.2 — Character personas have prompt-level guardrails but no
enforcement — WARNING
- Good: every pilot persona defines `hardBoundaries`:
  `supabase/functions/character-chat/pilot_registry.ts:87-93, 119, 150, 181, 212,
  243, 274, 305, 336, 367` — each lists "미성년/나이 추정 금지", "노골적 성적
  표현 금지", "의존 유도 금지", "죄책감 압박 금지".
- Global style guard in `supabase/functions/character-chat/index.ts:1516-1517`
  ("explicit sexual roleplay … 금지"), plus T5 block
  `character-chat/index.ts:797-798` ("명시적 성행위 묘사 … 어떤 상황에서도 생성
  금지").
- `sanitizePilotResponse()` (`pilot_registry.ts:1090-1117`) only strips leaked
  trace terms ("Guest", "로한"), not sexual/violent content. No regex
  post-filter for the forbidden categories on the response itself.
- Risk: sophisticated jailbreaks (base64, roleplay chains) can bypass prompt-
  level rules. Apple reviewers actively stress-test character chat apps
  (c.ai-inspired enforcement pattern).

### Finding 2.3 — Romance personas are default visible, no age gate — CRITICAL
- 10 pilot personas, all with explicit romance framing:
  `pilot_registry.ts:64-376` (예: "위장결혼이 진짜가 된 탐정",
  "회귀자 집사", "황녀인 당신을 독살하는 인물", "배신 현장에서 '맞바람 치실
  생각 있으세요?'", "캐릭터의 'T4 친밀' tier allows 스킨십 암시").
- `CONTENT_TIER_GUIDE` `t4_intimate`: "달달한 표현, 스킨십 암시 허용"
  (`character-chat/index.ts:764-766`). Per-character `maxContentTier` can be set
  to `t4_intimate` by client with no server-enforced adult gate.
- App Store rating is **12+** (`metadata/review_information/notes.txt`,
  `apps/mobile-rn/appstore-metadata.md:42`) — romance at T4 with no age gate on
  a 12+ app is a very likely 1.1.1 flag.

**Recommendation**: either (a) raise rating to 17+, or (b) force
`maxContentTier ≤ t2_emotional` server-side regardless of client payload, or
(c) add an age-gate before romance pilots unlock.

### Finding 2.4 — Image input bypasses moderation — CRITICAL
- Face-reading accepts `imageBase64` → Gemini vision directly:
  `apps/mobile-rn/src/lib/story-chat-runtime.ts:919-938`,
  `supabase/functions/character-chat/index.ts:82-84`, `on-device-chat-provider`
  equivalents. No NSFW detector, no "is this a face?" classifier. User can
  upload any image.
- Permission strings exist for camera/photos:
  `apps/mobile-rn/app.config.ts:139-141` ("관상 분석을 위해…"). Purpose is
  disclosed. But consent text doesn't mention **server-side transmission and
  LLM processing**, which Apple 5.1.1 expects for biometric-adjacent data.
- No indication in Privacy Policy or UI that photos are sent to Google Gemini.
  Google's retention is out of scope of the developer's control.

---

## 3. Guideline 1.2 — User safety / block & report

### Finding 3.1 — No block/report UI in character chat — CRITICAL
- Grep for `신고|report|block` across the whole mobile-rn tree returns **zero
  user-facing block/report UI**. The character-profile-screen
  (`apps/mobile-rn/src/screens/character-profile-screen.tsx:1-80`) has no
  ReportButton / BlockButton. chat-screen.tsx same.
- Apple 1.2 explicitly: "Apps with user-generated content or social networking
  must include: a method for filtering objectionable material, a mechanism for
  blocking abusive users, the ability to report offensive content and a timely
  response to concerns." Since these AI characters are **user-addressable
  content** and the user-created friend flow lets users generate new personas
  (`apps/mobile-rn/src/screens/friend-creation-screen.tsx`), this clause
  applies even though all counterparties are AI.
- Mitigation path most reviewed-apps use: an overflow menu with "신고하기"
  that sends a report row (character + last N messages) plus a "이 캐릭터
  숨기기" local flag.

---

## 4. Guideline 4.3 — Spam / duplicate content

### Finding 4.1 — 45 fortune edge functions, 39 hero components, 13 screens —
WARNING
- `supabase/functions/fortune-*`: 45 directories (daily, tarot, saju, wealth,
  career, love, blind-date, ex-lover, biorhythm, zodiac, past-life, …).
- Each has distinct inputs/UX (survey questions, hero visuals), but reviewers
  have flagged "duplicate fortune permutations of the same LLM" under 4.3. The
  app's differentiation story is the character-driven delivery and Face AI; this
  is adequately marketed in `apps/mobile-rn/appstore-metadata.md:22-34`.
- Not a rejection by itself, but combined with "AI entertainment" category and
  30+ similar SKUs, worth keeping 4.3(a) note in review notes.

---

## 5. Guideline 5.1.2 — Health / financial claims

### Finding 5.1 — Health fortune emits specific medical-adjacent advice —
CRITICAL
- `supabase/functions/fortune-health/index.ts:478-514`: system prompt positions
  AI as "건강 친구이자 웰니스 코치" and outputs:
  - `diet_advice` with specific food recommendations and meal timetable
    (line 585).
  - `exercise_advice` with prescribed duration/intensity per body part
    (line 586-590).
  - `body_part_advice` with "증상 원인", "관리법", "예방법" (line 569).
  - Accepts Apple Health data: `average_heart_rate`, `resting_heart_rate`,
    `systolic_bp`, `diastolic_bp`, `blood_glucose`, `blood_oxygen`
    (lines 522-528) and feeds them into LLM "맞춤화된 조언".
- Output has **no disclaimer field** (unlike fortune-wealth which sets
  `disclaimer`). No "consult a physician" footer.
- Apple reviewers very reliably flag blood pressure / glucose-driven AI advice
  even with an app-wide disclaimer. This is the single highest rejection risk.

**Recommendation**:
1. Remove `systolic_bp`, `diastolic_bp`, `blood_glucose`, `blood_oxygen`,
   `heart_rate` from the LLM context, or only surface them as visual context
   without AI interpretation.
2. Add mandatory per-response disclaimer field and render it in
   `apps/mobile-rn/src/features/fortune-results/heroes/hero-health.tsx`.
3. Reframe copy from "관리법/예방법" to "일반적 웰빙 팁" and remove
   duration/intensity prescriptions.

### Finding 5.2 — Financial / investment fortune — WARNING
- `fortune-wealth/index.ts:108,325,404,526` names stock categories ("주식",
  "가치투자|성장주|배당주"), outputs `buySignal` and `investmentInsights`.
  BUT it explicitly adds "disclaimer" field and system prompt line 326 says
  "모든 재정 결정은 본인의 선택과 책임".
- `fortune-investment/index.ts:338`: `buySignal: strong | moderate | weak |
  avoid` — this is the riskiest field. Reviewers may read "strong buy" as
  financial advice.
- Add the same per-card visible disclaimer footer and consider softening
  `buySignal` labels to emotional tone ("오늘의 기운", not "buy signal").

---

## 6. Guideline 5.6 — Developer Code of Conduct (impersonation, consent)

### Finding 6.1 — Celebrity/character fortune uses real names — WARNING
- `supabase/migrations/20251128000008_insert_entertainers.sql` seeds real
  entertainer names (e.g. line 83 mentions 남희석 / Nam Hee-seok).
- `supabase/functions/fortune-celebrity/` produces "궁합" with named celebrities.
- Without explicit license from the named person, this is a 5.2.1 / 5.6
  impersonation concern. Recommend either (a) use fictional/composite names, or
  (b) ensure only public-domain / historic figures.

### Finding 6.2 — Face photo consent text is thin — WARNING
- `app.config.ts:139-141` camera/photo purpose string: "관상 분석을 위해
  사진 접근이 필요합니다." Does not disclose cloud upload or AI processing.
- Face-reading screen `features/fortune-results/screens/face-reading.tsx` has
  no in-screen consent dialog before submit. Privacy Policy at
  `public/privacy` should explicitly list Gemini/OpenAI as sub-processors for
  photos; confirm it does (out of this audit scope).

---

## 7. Minor protection

### Finding 7.1 — No age gate, birthdate collected from all users — CRITICAL
- Onboarding asks birthdate: `apps/mobile-rn/app/onboarding/birth.tsx:11-38`.
  No minimum-age check, no parent-consent path.
- App rating 12+, Korean market has users <14 who enter via parent phone.
- Apple 5.1.1(ix) + COPPA: if any US user under 13 can register, must have
  verifiable parental consent OR block <13 in onboarding.
- Recommend: in `onboarding/birth.tsx` compute `age < 14` (Korean child
  standard) or `< 13` (US COPPA) → show "이 앱은 만 14세 이상부터 이용할 수
  있어요" and block completion.

### Finding 7.2 — Romance pilots accessible regardless of age — see 2.3.

---

## 8. Fortune-telling claim tone

### Finding 8.1 — Most prompts use soft/advisory tone — INFO
- Sampled system prompts (`fortune-wealth/index.ts:325-326`,
  `fortune-health/index.ts:478-514`, `fortune-game-enhance/index.ts:153,266`)
  use "조언", "참고", "가능성" language rather than absolute claims ("당신은
  부자가 됩니다"). Good.
- `fortune-wealth` output contains `disclaimer: "재정 결정은 본인의 선택과
  책임입니다. 이 내용은 재미로 참고하시기 바랍니다."` — ideal pattern; apply
  to all fortune functions.

### Finding 8.2 — Character personality prompts are strong on safety — INFO
- `supabase/functions/character-chat/index.ts:402-417,1510-1529` enforce
  "AI 어시스턴트가 아니다" role + "explicit sexual roleplay 금지". Good
  persona scaffolding, but see 2.1 (no runtime filter) + 2.3 (no age gate).

---

## Summary of rejection-grade gaps (ordered by likelihood of Apple block)

| # | Sev | Issue | Fix owner |
|---|-----|-------|-----------|
| A | CRITICAL | `fortune-health` provides specific diet/exercise advice on Apple-Health vitals, no per-result disclaimer (5.1.2) | backend + hero-health |
| B | CRITICAL | No server-side moderation on character-chat / free-chat inputs or outputs (1.1.1) | backend _shared/llm |
| C | CRITICAL | No block/report UI in AI character chat (1.2) | chat-screen, character-profile-screen |
| D | CRITICAL | Romance pilots + T4 intimate tier with 12+ rating, no age gate (1.1.1) | onboarding + character-chat server enforcement |
| E | CRITICAL | No minor age gate on birthdate onboarding (5.1.1 / COPPA) | onboarding/birth.tsx |
| F | CRITICAL | Face image base64 → Gemini with no NSFW filter, weak consent copy (1.1.1 / 5.1.1) | face-reading flow + app.config.ts copy |
| G | WARNING | Per-result fortune disclaimer missing on 30+ cards (1.1.6) | result-card-frame.tsx global footer |
| H | WARNING | Celebrity names in compatibility fortunes (5.2.1 / 5.6) | fortune-celebrity seed data |
| I | WARNING | `fortune-investment.buySignal` reads as financial advice (5.1.2) | investment prompt softening |
| J | INFO | 45 fortune SKUs — 4.3(a) spam risk, but marketed differentiation is OK | metadata only |

---

## Referenced files

- `apps/mobile-rn/app.config.ts:127-142`
- `apps/mobile-rn/app/disclaimer.tsx:1-25`
- `apps/mobile-rn/app/onboarding/birth.tsx:11-38`
- `apps/mobile-rn/appstore-metadata.md:22-52`
- `apps/mobile-rn/src/screens/onboarding-screen.tsx:88,150-164,335-362`
- `apps/mobile-rn/src/screens/profile-screen.tsx:33,222-223,722-723`
- `apps/mobile-rn/src/screens/character-profile-screen.tsx:1-80`
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/screens/friend-creation-screen.tsx`
- `apps/mobile-rn/src/features/fortune-results/screens/face-reading.tsx`
- `apps/mobile-rn/src/features/fortune-results/heroes/hero-health.tsx`
- `apps/mobile-rn/src/lib/character-details.ts:150-303`
- `apps/mobile-rn/src/lib/story-chat-runtime.ts:919-938`
- `apps/mobile-rn/src/lib/story-romance-pilots.ts`
- `supabase/functions/_shared/llm/providers/gemini.ts:15-100`
- `supabase/functions/_shared/llm/safety.ts` (cost/quota guard only, not content)
- `supabase/functions/character-chat/index.ts:82-108,764-800,1510-1529`
- `supabase/functions/character-chat/pilot_registry.ts:64-376,1090-1117`
- `supabase/functions/fortune-health/index.ts:478-594`
- `supabase/functions/fortune-wealth/index.ts:108,325-326,404,526`
- `supabase/functions/fortune-investment/index.ts:338`
- `supabase/functions/legal-pages/index.ts:54,66`
- `public/terms.html:108`
- `metadata/review_information/notes.txt:23-26`
- `supabase/migrations/20251128000008_insert_entertainers.sql:83`
