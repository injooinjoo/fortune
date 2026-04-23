# App Store 5.1.2 Review — `supabase/functions/fortune-health/index.ts`

**Verdict: PASS-WITH-CAVEAT**

The Edge Function is compliant on the server side. Three caveats block a clean PASS, all actionable before submission: (a) client does not yet render the new `disclaimer` field, (b) disclaimer text should also be injected into the LLM system prompt, (c) minor prescriptive-language polish in output schema.

---

## 1. Medical diagnosis risk

No remaining occurrence of "진단", "처방", "치료", "예방 약" in prompt text. Prompt explicitly forbids diagnostic/prescriptive framing (line 532: "절대 의학적 진단/치료/예측/처방 형태로 해석하지 말고, 운동·수면·식습관 루틴 차원의 가벼운 팁만 제공").

Residual concerns (low, addressable via prompt guardrail):
- `body_part_advice` still instructs the LLM toward "부위별 컨디션 메모" with "장기적 예방법" (line 629). "예방법" reads as preventive medicine. Recommend swap → "꾸준한 습관" or "오래 유지하는 루틴".
- Example fatigue block (line 622) still attaches a parenthetical English medical term `(fatigue)`. Clinical-looking. Strip the parenthetical English labels.
- `cautions` schema still says "위험 상황 설명" + "대처법" — wellness-acceptable but leans clinical. Reframe as "신경 쓸 부분" + "이렇게 해보기" to land firmly on the consumer-wellness side.
- `ELEMENT_ORGAN_MAP` surfaces organ names (간/담, 심장/소장, 신장/방광) and TCM "취약 증상" (두통, 불면증, 혈액순환 저하, 탈모, 이명). This is traditional-medicine framing — Apple has approved this in horoscope/fortune apps but it's the biggest residual risk. Keep the "오행" (Five-Element / fortune-telling) wrapper visible in the response so reviewer sees it as divination, not Western medicine.

## 2. Residual clinical vitals

Audit result: CLEAN. Matches for `heart_rate|systolic_bp|diastolic_bp|blood_glucose|blood_oxygen|심박|혈압|혈당|산소포화|bpm` in the Edge Function occur only in:
- Lines 67-73 (TypeScript input interface) — input typing only, explicitly acceptable.
- Lines 517, 850 (compliance comment markers) — documentation, not executed.

`healthAppSection` (LLM prompt, 521-532) and `healthAppDataSummary` (response, 852-856) strictly expose steps / sleep / weight / workouts / calories. No vitals reach LLM or client.

## 3. Prescriptive language in `exercise_advice`

`intensity: "가벼움|중간|높음"` and `duration: "10분"` are **fitness-tracking-acceptable**, aligned with Nike Training Club / Apple Fitness+ / Strava precedent. Apple rejects clinical prescriptions (target HR zones, VO2 max zones, HRV-driven recovery). Qualitative intensity labels + duration are routine in approved fitness apps.

The `"tip": "숨차지만 대화는 가능한 페이스로"` is a textbook "talk test" — consumer-wellness language. Good swap.

No action needed. Line: clinical = numeric physiological targets tied to vitals; acceptable = time + subjective effort descriptors.

## 4. Disclaimer sufficiency

Current text is good legally, but two enhancements required:

**(a)** Add the disclaimer stance **into the LLM system prompt** so the generated `overall_health` / `body_part_advice` / `cautions` text itself avoids claims. Current system prompt (478-514) has "금지" rules but nothing explicit like:
```
- 이 앱은 의학적 조언·진단·치료가 아닙니다.
- "증상", "예방", "치료" 단어 사용 금지. "컨디션", "습관", "루틴"으로 대체.
- 의료 상담을 권유하는 문구를 cautions 배열에 최소 1개 포함.
```
Without this, the LLM can still emit diagnostic-sounding text that the bottom-of-card disclaimer has to walk back.

**(b)** Consider adding English mirror line for App Review ("This is for entertainment and general wellness. Not medical advice.") — reviewers are often non-Korean.

## 5. Premium regression

`hasHealthAppData = isPremium && health_app_data !== null` (line 386) unchanged. Premium branch still differentiates via `healthAppSection` (steps/sleep/weight/workouts/calories in prompt) and `healthAppDataSummary` in response. No null-deref risk: all access is `health_app_data!.field` guarded by `hasHealthAppData`. If a Premium user's payload contains legacy vitals fields, they are silently ignored — safe. Premium value preserved: personalized tone driven by actual step/sleep/weight data.

## 6. `body_part_advice` / `cautions` / `exercise_advice` / `diet_advice` as 블러 대상

Comments on 842-846 mark these four as paywall-blur targets. Grep of mobile-rn shows none of these four strings are referenced in `features/fortune-results/screens/` or `hero-health.tsx`. Rendering likely lives in `embedded-result-card.tsx` or a batch screen. This is fine for the 5.1.2 audit — blur state doesn't change Apple's concern (Apple sees unblurred after purchase). No regression from this change.

## 7. Client-side changes required (BLOCKER for ship)

`apps/mobile-rn/src/features/fortune-results/heroes/hero-health.tsx` is a tiny SVG-ish silhouette (body + 4 zone dots). It consumes only `zones[].score`. **It does not render `disclaimer`.**

`grep disclaimer` across `apps/mobile-rn/src` returns only the onboarding T&C flow (`DISCLAIMER_STORAGE_KEY`, `/disclaimer` route) — unrelated. **No component reads the new `disclaimer` response field.**

**Required client work** (flag for P10-B5 follow-up sprint):
1. Update `embedded-result-card.tsx` or a dedicated health screen to render `data.disclaimer` as a persistent footer. Style: small, muted (`fortuneTheme.colors.textTertiary`), always visible, non-blurrable.
2. Ensure the disclaimer survives Premium paywall blur logic (it must NOT be blurred).
3. Confirm the chat-embedded mini-card variant also shows the disclaimer, or at minimum a short badge like "⚠️ 참고용".

Until (1)-(3) ship, Apple reviewer sees a health screen with no visible disclaimer — the server-side field is invisible. This is the only hard blocker.

## 8. Benchmark comparison

Flo / MyFitnessPal / Samsung Health (all approved) share these patterns, all present here:
- Disclaimer present in-UI ✓ server-side; ✗ client-side (see §7).
- Wellness framing (컨디션 / 루틴) rather than clinical (증상 / 처방) ✓ mostly; minor residuals §1.
- No vitals interpretation ✓ fully stripped.
- Qualitative exercise intensity ✓ matches Fitness+/NTC.
- TCM/divination framing: Flo (cycle) and Headspace approved with traditional-wellness framing intact; our 오행 wrapper should survive.

---

## Action items before App Store submission
1. **[BLOCKER]** Wire `disclaimer` field into health result UI (client work).
2. **[HIGH]** Inject disclaimer stance into LLM system prompt (server, ~10 lines).
3. **[MED]** Swap "예방법" → "루틴" in `body_part_advice` example (line 629).
4. **[MED]** Remove parenthetical English medical terms `(fatigue)` from prompt examples.
5. **[LOW]** Add English mirror of disclaimer for App Review reviewer.
