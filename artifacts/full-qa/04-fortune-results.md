# 04 — Fortune Results & Embedded Chat Cards QA

Scope: `/result/[resultKind]` route, `fortune-results/registry`, `chat-results/embedded-result-card`, heroes pipeline, edge-runtime (35s timeout), adapter normalization, disclaimer footer.

---

## 1) Fortune Type Inventory (registry + mapping)

Registered ResultKinds in `registry.tsx` (35 kinds). Fortune type → resultKind via `mapping.ts`.

| ResultKind | FortuneType aliases | Source |
|---|---|---|
| traditional-saju | traditional-saju | Edge (F01) |
| daily-calendar | daily, daily-calendar, fortune-cookie | Edge + local manseryeok |
| mbti | mbti | Edge (F03) |
| blood-type | blood-type | Edge (F04) |
| zodiac-animal | zodiac, zodiac-animal, constellation | Edge (F05) |
| career | career | Edge (F07) |
| love | love | Edge (F08) |
| health | health, breathing, biorhythm | Edge (F09) — **disclaimer expected** |
| coaching | coaching, chat-insight | Edge (F10) |
| family | family | Edge (F11) |
| past-life | past-life | Edge (F12) |
| wish | wish, talisman | Edge (F13) |
| personality-dna | personality-dna | Edge (F14) |
| wealth | wealth, lotto | Edge (F15) |
| talent | talent | Edge (F16) |
| exercise | exercise | Edge (F17) |
| tarot | tarot, dream | Edge (F18) |
| game-enhance | game-enhance | Edge (F19) |
| match-insight | match-insight | Edge (F37) |
| ootd-evaluation | ootd-evaluation | Edge (F20) — image upload |
| exam | exam | Edge (F21) |
| compatibility | compatibility | Edge (F22) |
| blind-date | blind-date | Edge — partner image base64 |
| avoid-people | avoid-people | Edge (F24) |
| ex-lover | ex-lover | Edge (F25) |
| yearly-encounter | yearly-encounter | Edge (F26) |
| decision | decision | Edge (F27) |
| daily-review | daily-review, weekly-review | Edge (F28) |
| face-reading | face-reading | Edge — face image |
| naming | naming | Edge (F30) |
| birthstone | birthstone | Edge (F31) |
| celebrity | celebrity | Edge (F32) |
| pet-compatibility | pet-compatibility | Edge (F33) |
| lucky-items | lucky-items | Edge (F34) |
| moving | moving | Edge (F35) |
| new-year | new-year | Edge (F36) |

On-device routing: `edge-runtime.ts` calls `isOnDeviceFortuneSupported(fortuneType)` before hitting Edge; unsupported types → Edge only. (Exact on-device list lives in `on-device-fortune.ts`, not enumerated here.) Cache: 30 min TTL, 50 entries, keyed by `type:YYYY-MM-DD:userId`.

---

## 2) Hero Component Matrix

`EmbeddedResultCard` routes to hero via `HEROED_RESULT_KINDS` map — only 11 kinds have a dedicated hero; others fall through to `RenderFortuneResult(registry)`.

| Hero | Used for | Required payload | Fallback | Animation |
|---|---|---|---|---|
| HeroTarot | tarot | `spread[]` | Placeholder cards | Stamp reveal |
| HeroSaju | traditional-saju | `pillars[4]`, `elements{w,f,e,m,w}` | Default pillars + zero bars | Pillar stamp + bar grow |
| HeroCalendar | daily-calendar | `cal.ganji/lunar/season` | Blank face | Fade |
| HeroLine | wealth, career | `timeline[]` | Flat line | Path draw |
| HeroRadar | mbti, personality-dna | `traits[6]` | `DEFAULT_TRAITS` | Polygon grow |
| HeroCompat | compatibility | `compat.leftLabel/rightLabel/metrics[]` | Generic labels | Score count-up |
| HeroHealth | health | `zones[]` w/ region keys | `zoneScore(...,fallback)` returns default | Pulse |
| HeroOrbs | love | — (decorative) | Always renders | Orbit loop |
| HeroPastLife | past-life | portrait from rawApiResponse | Placeholder art | Fade |

Other heroes in directory (birthstone, celebrity, decision, ex, exam, face, lucky, moving, naming, pet, yearly-encounter) are not wired into `HEROED_RESULT_KINDS` — embedded chat path uses registry fallback for those. Full-page `/result/[resultKind]` uses `Ondo*Result` registry components.

---

## 3) Executable Test Checklist

### Chat → Card → Full screen
- [ ] For every fortuneType listed §1: trigger survey → embedded card renders → tap after reveal (>0.9 progress) → `/result/[resultKind]` opens.
- [ ] Tap during reveal (<0.9 progress) is ignored (see `TAP_PROGRESS_THRESHOLD`).
- [ ] Registry fallback path (non-heroed kinds) also navigates on Pressable tap.
- [ ] Invalid resultKind → `/result/xxx` → error Card "결과 종류를 찾을 수 없습니다" renders (graceful).

### Disclaimer (5.1.2)
- [ ] Health fortune — `payload.disclaimer` block visible, bordered amber, below generic footer (P10).
- [ ] Non-health — only "오락 목적의 AI 생성 콘텐츠입니다" centered footer, no amber block.
- [ ] Registry fallback renders `EntertainmentFootnote` once (NOT double-stacked when `Ondo*Result` also wraps `ResultCardFrame` — confirmed by comment, verify visually).

### Network & reliability (W10)
- [ ] Airplane mode → generate → 35s → throws `edge-runtime timeout (35s)` → UI surfaces user-visible error (check chat-surface error message, not silent).
- [ ] Mid-request network drop → AbortError handled → same timeout error path.
- [ ] Slow 3G (~20s) → card completes, cache populated, second request skips Edge.
- [ ] On-device path failure → cloud fallback attempted (log: `falling back to cloud`).
- [ ] Same user + same day + same type → 2nd generation → `[fortune-cache] HIT` log, no network call.

### UI polish
- [ ] Double-tap on generate chip / survey submit → only one card enqueued.
- [ ] Shimmer sweep visible while `progress < 0.95`, fades at 0.95, stops loop (no RAF leak).
- [ ] Long `summary` (>220 chars) trimmed with `…` by `trimParagraph(… , 220)`.
- [ ] Metric grid: 2 metrics → 2 cols, 3+ → 3 cols (max 4 per `mergeMetricTiles.slice(0,4)`).
- [ ] Lucky items chip row wraps across multiple lines; no horizontal clip.
- [ ] Premium-locked sections: confirm blur overlay for non-premium (check `face-reading`, `past-life`, `new-year` — these have richest payloads).
- [ ] Share button: not present in `ResultCardFrame` — **missing feature**, confirm w/ product or skip.
- [ ] Back nav from `/result/[resultKind]` → chat scroll position preserved (expo-router default).
- [ ] Reveal haptics fire once per message.id (ref guard in `embedded-result-card`).

### Content-specific
- [ ] daily-calendar — local manseryeok attached regardless of edge success.
- [ ] traditional-saju — if `pillars.length !== 4`, HeroSaju uses defaults silently.
- [ ] compatibility — `partnerImage` not leaked in contextTags.
- [ ] face-reading / past-life — faceImage base64 **not** duplicated on wire (past-life explicitly deletes `faceImage` after mapping to `faceImageBase64`).
- [ ] celebrity — `contextTags` hidden (explicitly filtered in fallback render).

---

## 4) Content & Compliance Red Flags

1. **Health disclaimer** — only enforced when server returns `data.disclaimer`. If `fortune-health` Edge Function forgets to set it, medical content ships without the extra block. Client-side **enforcement missing**: should inject default for `fortuneType === 'health' && !disclaimer`.
2. **Financial advice** (wealth, lotto) — no equivalent disclaimer pipe; `wealth` and `lotto` (alias) rely only on generic entertainment footer. Compliance gap for 5.1.2 parity.
3. **Legal / decision fortune** — `decision` has no disclaimer; prescriptive language risk.
4. **Prescriptive phrasing** — adapter hardcodes advisory-ish strings ("~보세요", "~합니다") in `buildContextualAction`. Text like "이직 판단은 기준 세 가지를 먼저 적은 뒤 비교하는 방식이 가장 안전합니다" and "취침 시간을 먼저 고정하는 쪽이 가장 효과적" borders prescriptive. Reword to "~해 보세요" form.
5. **Celebrity references** — `celebrity` fortune accepts freeform `celebrityName` string; no allowlist. Inappropriate real-person content risk; needs moderation layer.
6. **English terms in Korean flow** — `SPECIAL TIP` label, `Ondo` kicker, `score` text in fallback block. Acceptable branding but inconsistent with Korean-only hero components.

---

## 5) Static Findings (code-level)

### Hero crash risk
- `HeroSaju` (`hero-saju.tsx:63-73`): defensive — uses defaults when `pillars.length !== 4`. **Safe**.
- `HeroRadar` (`hero-radar.tsx:35-36`): `DEFAULT_TRAITS` fallback. **Safe**.
- `HeroHealth` (`hero-health.tsx:33-47`): `zoneScore` with explicit fallback arg. **Safe**.
- `HeroLine` (`hero-line.tsx:42`): `timeline` may be undefined — check for downstream `.map` crash (not verified; add guard).
- `HeroTarot`: assumes `spread[]` exists — Edge Functions must populate or component must fall back. **Risk** if server ships without spread.
- `HeroCompat`: requires `compat` object; absence → likely `undefined.metrics.map` crash. **Risk**.
- `HeroPastLife`: pulls portrait from `rawApiResponse.fortune.portraitUrl` — silent blank if missing.

### Adapter normalization gaps (`adapter.ts`)
- `normalizeFortuneResult` from `@fortune/product-contracts` is trusted blindly; unknown shapes collapse to fallback.
- `ITEM_CHAR_LIMIT = 450` — long chapters fit, but metric `value` hard-capped at 40 via `trimValue`. Verify naming fortune `추천 이름` count doesn't exceed.
- `resolveFamilyConcern` default branch returns `'health'` — questionable default; may mis-tag concerns.
- `extractMetricTiles` default branch pulls `fortuneScores / personality_match / element_balance` but does NOT cover many types (career, love, wealth-specific); these fall through and may render empty metrics grid.
- `disclaimer` only captured when `typeof === 'string' && length > 0` — if server sends object, silently dropped.

### Race conditions
- `edge-runtime.ts:95-115`: on-device attempted first; on fail falls through to cloud. No abort of on-device when user backgrounds app — on-device completion **after** cloud may overwrite cache? Actually sequential (await), so no race.
- `fortuneResultCache` is module-scoped Map; cross-user switch must call `invalidateFortuneResultCache()`. Verify this is wired into logout + profile-change handlers (grep confirms export exists; call-sites not audited here).
- `AnimatedResultCard` `setProgress` listener: cleanup removes listener on unmount — good. No leak.
- Cache eviction uses `keys().next().value` (insertion order) — FIFO, not LRU; hot keys may still get evicted. Minor.

### Suggested fixes (priority)
1. **P0**: Client-side default disclaimer for health / wealth / decision when server omits it.
2. **P1**: Add guard rails in `HeroTarot` / `HeroCompat` for missing `spread` / `compat`.
3. **P1**: Show user-facing error toast when `edge-runtime timeout (35s)` bubbles up (confirm chat-surface catches & renders).
4. **P2**: Add timeline fallback array in `HeroLine`.
5. **P2**: Reword prescriptive adapter strings in `buildContextualAction`.

---

File paths referenced:
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/app/result/[resultKind].tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/features/fortune-results/registry.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/features/fortune-results/mapping.ts`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/features/fortune-results/primitives/result-card-frame.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/features/fortune-results/heroes/hero-{saju,health,radar,line,tarot,compat,calendar,past-life,orbs}.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/edge-runtime.ts`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/adapter.ts`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/features/chat-results/types.ts`
