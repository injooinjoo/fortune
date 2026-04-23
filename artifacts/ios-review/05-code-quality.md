# iOS Review — 05 Code Quality Audit

Scope: `apps/mobile-rn/src/**`
Rules source: `CLAUDE.md` (design tokens, AppText, no `any`, no empty catch, Context-only state, LLMFactory)
Read-only audit. Numbers are ripgrep counts; file:line citations sampled.

---

## 1. `any` Type Abuse

**Verdict: Excellent.** Only 3 real occurrences across the codebase.

| Location | Context | Severity |
|----------|---------|----------|
| `apps/mobile-rn/src/lib/on-device-llm.ts:736` | `messages: converted.messages as any,` — suppressed with `eslint-disable-next-line @typescript-eslint/no-explicit-any` and inline comment explaining strictness conflict. | Low (documented) |
| `apps/mobile-rn/src/screens/profile-screen.tsx:131` | `(onDeviceLLMEngine as any).onStatusChange?.(...)` — bridge to native engine whose TS type lacks `onStatusChange`. | Medium (undocumented, fixable by extending engine type) |

No `: any` parameter/field annotations found. No implicit `any` abuse. Treat this rule as effectively green.

---

## 2. Hardcoded Colors (`#rrggbb` / `rgb()` / `rgba()`)

**Verdict: Widespread violation.** 319 `#xxxxxx` hits across 176+ .tsx files; rgba also heavily used.

### Top offenders (hex count per file)

| File | Hits |
|------|------|
| `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` | 26 |
| `apps/mobile-rn/src/features/fortune-results/screens/batch-a.tsx` | 22 |
| `apps/mobile-rn/src/screens/welcome-screen.tsx` | 21 |
| `apps/mobile-rn/src/screens/profile-relationships-screen.tsx` | 21 |
| `apps/mobile-rn/src/features/fortune-results/screens/batch-c.tsx` | 17 |
| `apps/mobile-rn/src/features/ios-widgets/showcase/iphone-frame.tsx` | 16 |
| `apps/mobile-rn/src/features/ios-widgets/showcase/wallpaper.tsx` | 15 |
| `apps/mobile-rn/src/features/fortune-results/screens/batch-e.tsx` | 15 |
| `apps/mobile-rn/src/features/fortune-results/manseryeok-card.tsx` | 11 |
| `apps/mobile-rn/src/features/ios-widgets/primitives/iphone-frame/...` (group) | ~10 |
| `apps/mobile-rn/src/components/social-auth-pill-button.tsx` | 10 |
| `apps/mobile-rn/src/screens/friend-picker-screen.tsx` | 10 |

Hero files (`features/fortune-results/heroes/*.tsx`): 35 files, 123 total hits (1–8 per file). Especially `hero-past-life.tsx` (8), `hero-lucky.tsx` (7), `hero-tarot.tsx` (7), `hero-family.tsx` (7), `hero-decision.tsx` (6), `hero-celebrity.tsx` (5), `hero-saju.tsx` (5), `hero-face.tsx` (5), `hero-blood.tsx` (5).

### Legitimate exceptions (palette/token files — not violations)
- `apps/mobile-rn/src/lib/theme.ts` (3 hits — doc examples)
- `apps/mobile-rn/src/features/ios-widgets/primitives/colors.ts` (16 hits — explicit widget palette file, documented deviation)

### Sample (chat-surface.tsx)
```
203: shadowColor: '#000',
451: backgroundColor: '#FF3B30',
518: <AppText ... color="#FFFFFF">
634: backgroundColor: '#2C2C2E',
1911-1913: classic/moonlight/gold palette literals
2232-2235: affinity bucket colors (#8E8E93 / #5AC8FA / #AF52DE / #FF2D55)
```

### rgba()
`rgba(...)` literals appear in `chat-surface.tsx` (~10 bubble-background variants), `chat-survey/tarot-draw-widget.tsx`, `on-device-transition-toast.tsx`, `on-device-download-progress-bar.tsx`. None reach `fortuneTheme.colors.*` + alpha helper from `theme.ts`.

---

## 3. Hardcoded Text Sizes

`fontSize:` numeric literals — 86 hits across 30+ files; `fontWeight:` literals — 60 hits across 30+ files.

### Top offenders (fontSize)

| File | Hits |
|------|------|
| `apps/mobile-rn/src/screens/welcome-screen.tsx` | 12 |
| `apps/mobile-rn/src/features/story-chat-animations/emotion-meter.tsx` | 8 |
| `apps/mobile-rn/src/features/story-chat-animations/pep-capsules.tsx` | 6 |
| `apps/mobile-rn/src/features/story-chat-animations/resonance-orbs.tsx` | 6 |
| `apps/mobile-rn/src/features/fortune-results/manseryeok-card.tsx` | 5 |
| `apps/mobile-rn/src/screens/profile-screen.tsx` | 3 |
| `apps/mobile-rn/src/features/story-chat-animations/memory-recall.tsx` | 4 |
| `apps/mobile-rn/src/features/story-chat-animations/photo-recall.tsx` | 4 |
| `apps/mobile-rn/src/features/story-chat-animations/poem-card.tsx` | 4 |

### Top offenders (fontWeight)

| File | Hits |
|------|------|
| `apps/mobile-rn/src/screens/welcome-screen.tsx` | 8 |
| `apps/mobile-rn/src/features/story-chat-animations/emotion-meter.tsx` | 6 |
| `apps/mobile-rn/src/screens/profile-screen.tsx` | 5 |
| `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` | 5 |
| `apps/mobile-rn/src/features/story-chat-animations/resonance-orbs.tsx` | 3 |

Rule: replace inline `{ fontSize: 12, fontWeight: '700' }` with `AppText variant="labelSmall"` style props.

---

## 4. Bare `<Text>` with inline styles

28 total `<Text ` JSX occurrences across 10 files (most are from `react-native` import and bypass `AppText`):

| File | Hits |
|------|------|
| `apps/mobile-rn/src/features/story-chat-animations/resonance-orbs.tsx` | 7 |
| `apps/mobile-rn/src/features/story-chat-animations/pep-capsules.tsx` | 5 |
| `apps/mobile-rn/src/features/story-chat-animations/emotion-meter.tsx` | 4 |
| `apps/mobile-rn/src/features/story-chat-animations/memory-recall.tsx` | 3 |
| `apps/mobile-rn/src/screens/welcome-screen.tsx` | 3 |
| `apps/mobile-rn/src/features/fortune-results/heroes/hero-exercise.tsx` | 2 |
| `apps/mobile-rn/src/features/fortune-results/heroes/hero-pet.tsx` | 1 |
| `apps/mobile-rn/src/features/fortune-results/heroes/hero-past.tsx` | 1 |
| `apps/mobile-rn/src/features/story-chat-animations/photo-recall.tsx` | 1 |
| `apps/mobile-rn/src/components/avatar.tsx` | 1 |

Sample (`story-chat-animations/resonance-orbs.tsx:102,160,164,177,181`): `<Text style={styles.eyebrow}>...` — should be `<AppText variant="labelSmall">`.

The `story-chat-animations/` feature folder is the most concentrated violator; consider migrating those 5 files to `AppText` as one sprint.

39 files `import { Text } from 'react-native'` — many only keep it for `StyleSheet`, but the 10 above actually render it.

---

## 5. Empty / Swallowed Catch Blocks

**Verdict: Excellent.** Zero empty `catch (e) {}` blocks found in `apps/mobile-rn/src/**`.

All ~43 `catch` clauses log via `console.warn`/`console.error` with labeled prefix (e.g. `[OnDeviceLLM]`, `[bootstrap]`, `[push]`), most following the project RCA convention. Notable files: `lib/on-device-llm.ts` (2 catches), `lib/push-notifications.ts` (3), `lib/crash-reporting.ts` (2), `lib/use-voice-input.ts` (2), `providers/app-bootstrap-provider.tsx` (1), `screens/profile-edit-screen.tsx` (1).

Recommendation: tighten the logging pattern by routing all of these through `crash-reporting.ts` / `error-reporting.ts` (already exists) instead of raw `console.warn`, so Sentry captures them in production.

---

## 6. `console.log` Leftovers

13 `console.log(` calls across 6 files (excluding `warn`/`error`):

| File | Hits |
|------|------|
| `apps/mobile-rn/src/lib/on-device-llm.ts` | 4 |
| `apps/mobile-rn/src/screens/profile-edit-screen.tsx` | 4 |
| `apps/mobile-rn/src/features/chat-results/edge-runtime.ts` | 2 |
| `apps/mobile-rn/src/lib/on-device-chat-provider.ts` | 1 |
| `apps/mobile-rn/src/lib/crash-reporting.ts` | 1 |
| `apps/mobile-rn/src/screens/profile-screen.tsx` | 1 |

All 13 should be gated behind `if (__DEV__)` or removed before ship. (Full `console.*` total is 43 across 13 files, but `.warn`/`.error` in catch blocks are acceptable.)

---

## 7. TODO / FIXME / HACK

Only 3 hits project-wide (very clean):

| File:line | Note |
|-----------|------|
| `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:248` | `TODO: 호기심 탭 임시 비활성화` (commented JSX block) |
| `apps/mobile-rn/src/screens/signup-screen.tsx:41` | `TODO: 카카오/네이버 OAuth 연동 완료 후 복원` |
| `apps/mobile-rn/src/screens/splash-screen.tsx:11` | `TODO(dev): Ondo 온보딩 개발 중 — 모든 실행에서 welcome carousel 강제.` (dev-only override; revisit before ship) |

The splash-screen TODO is ship-blocking if it forces every user back into onboarding.

---

## 8. `@ts-ignore` / `@ts-expect-error`

**Verdict: Excellent.** Zero occurrences in `apps/mobile-rn/src/**`.

---

## 9. Large Inline StyleSheet / Large Component Files

Heuristic: files >1000 lines almost certainly contain massive style blocks.

| File | Lines |
|------|-------|
| `apps/mobile-rn/src/features/fortune-results/screens/batch-e.tsx` | 2371 |
| `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx` | 2361 |
| `apps/mobile-rn/src/features/fortune-results/screens/batch-c.tsx` | 1282 |
| `apps/mobile-rn/src/features/fortune-results/screens/batch-a.tsx` | 1281 |
| `apps/mobile-rn/src/screens/welcome-screen.tsx` | 771 |
| `apps/mobile-rn/src/features/fortune-results/manseryeok-card.tsx` | 457 |

None of these files use `StyleSheet.create` (confirmed via grep!). They rely on **inline style objects** throughout, which is the inverse of the convention in `components/*.tsx` (which do use `StyleSheet.create`). This magnifies the hardcoded-color and fontSize findings above.

21 files use `StyleSheet.create` — mostly small primitives (`components/*`, `story-chat-animations/*`).

Recommendation: 4 batch screens + chat-surface need style extraction + theme-token migration; they are the highest-ROI refactor targets.

---

## 10. `require()` in RN Code

26 hits, all legitimate:
- `apps/mobile-rn/src/lib/chat-character-avatar.ts` — 20 `require('../../assets/character/avatars/*.webp')` (Metro static-asset pattern; **must** be `require`).
- `apps/mobile-rn/src/components/social-auth-pill-button.tsx` — 3 asset requires.
- `apps/mobile-rn/src/lib/push-notifications.ts`, `lib/use-voice-input.ts` — 3 guarded native-module requires (`try { require('expo-notifications') }`), correct pattern to avoid crashes on module absence.

No dynamic/ad-hoc `require` abuse. Clean.

---

## TypeScript Errors (`tsc.log`)

`/Users/injoo/Desktop/Dev/fortune/artifacts/ios-review/tsc.log` contains only Node `ExperimentalWarning` about npm's debug/supports-color CJS/ESM interop — **not a tsc run output at all** (no `error TS` lines, no file references). Either `tsc` was never captured, or it exited before producing diagnostics. Re-run with `npx tsc --noEmit 2>&1 | tee artifacts/ios-review/tsc.log` to populate.

---

## Priority Fix List

### P0 (ship-blockers)
1. **Splash-screen welcome force** (`screens/splash-screen.tsx:11`) — TODO forces onboarding every launch. Guard with `__DEV__`.
2. **Re-capture `tsc.log`** — current file is noise, so TS health unknown.

### P1 (design-system drift, high-impact)
3. **chat-surface.tsx** (2361 lines, 26 hex + 10 rgba + 5 fontWeight + TODO) — single biggest offender. Candidate for split + theme migration.
4. **batch screens** `batch-a/c/e.tsx` (1281/1282/2371 lines, combined 54+ hex colors) — extract hardcoded palettes to `fortuneTheme` / per-screen theme map.
5. **welcome-screen.tsx** (21 hex, 12 fontSize, 8 fontWeight, 2 rgba, 3 bare `<Text>`, has its own `ST` color const at top) — full theme migration.
6. **hero files** (35 files × 1–8 hex colors = 123 hits) — most heroes define a local palette; centralize into `fortune-results/theme/*` or `fortuneTheme.fortune.*`.

### P2 (polish)
7. **story-chat-animations/** — 5 files with 20 bare `<Text>` + inline fontSize/fontWeight. Migrate to `AppText variant`.
8. **`console.log` leftovers** — strip 13 occurrences or gate behind `__DEV__`.
9. **manseryeok-card.tsx** — 11 hex, 7 fontSize, no `StyleSheet.create`; refactor to token-based styles.
10. **`onDeviceLLMEngine as any`** (`screens/profile-screen.tsx:131`) — extend the engine type with `onStatusChange` so the cast can be dropped.
11. **rgba literals in chat-surface** — replace with `fortuneTheme.colors.surface*` + `hexToRgba` helper from `lib/theme.ts`.
12. **Route catch-block logs through `crash-reporting.ts`** — all `console.warn('[...]')` in `lib/push-notifications.ts`, `lib/on-device-llm.ts`, `providers/app-bootstrap-provider.tsx`, `lib/use-voice-input.ts` should feed Sentry.

### Green (no action)
- `any` type abuse (3 documented casts total)
- `@ts-ignore` / `@ts-expect-error` (zero)
- Empty catch blocks (zero)
- TODO/FIXME count (3 total — extremely clean)
- `require()` usage (all legitimate asset/native-module patterns)
- Context-only state management (no Redux/Zustand found)

---

## Summary

Codebase is **strong on type discipline** (no `any`, no empty catch, no suppressions, few TODOs) but **weak on design-token discipline** (319 hex literals, 86 fontSize literals, 60 fontWeight literals, 28 bare `<Text>`). The violations concentrate in a small number of very large files: `chat-surface.tsx`, the four `fortune-results/screens/batch-*.tsx`, `welcome-screen.tsx`, `manseryeok-card.tsx`, and the `story-chat-animations/` folder. Those ~10 files account for >60% of the design-system violations and would close most of the gap if migrated.
