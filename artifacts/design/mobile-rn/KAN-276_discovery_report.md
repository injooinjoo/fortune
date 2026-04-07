# KAN-276 Discovery Report

## Goal

- Replace the current debug/scaffold `/chat` presentation in `apps/mobile-rn` with a Pencil-aligned chat surface.
- Keep the existing bootstrap, deep-link, result-route, and persisted chat state behavior intact.
- Validate the runtime on the active iPhone 17 simulator.

## Searches Run

- `rg -n "chat|soft gate|auth entry|premium" artifacts/design/pencil/*.md artifacts/design/mobile-rn/*.md`
- `rg --files apps/mobile-rn/src/features/chat-surface`
- `rg -n "softGateCompleted|profile-flow|sentMessageCount|selectedCharacterId|lastFortuneType" apps/mobile-rn/src/providers apps/mobile-rn/src/lib`
- `rg -n "ChatScreen|MessageBubble|buildSuggestedActions|buildLaunchMessages" apps/mobile-rn/src -g '*.ts' -g '*.tsx'`

## Files Reviewed

1. `apps/mobile-rn/src/screens/chat-screen.tsx`
   - Current bootstrap/auth/profile/chat shell logic is already present.
   - Problem: the rendered UI is a diagnostic scaffold, not the governed product surface.
2. `apps/mobile-rn/src/lib/chat-shell.ts`
   - Reuse message/action generation and fortune label mapping.
3. `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx`
   - Reuse `gate`, `markGuestBrowse()`, and pending deep-link consumption exactly as-is.
4. `apps/mobile-rn/src/providers/social-auth-provider.tsx`
   - Reuse `startSocialAuth()` instead of routing auth-entry through a placeholder signup surface.
5. `apps/mobile-rn/src/components/screen.tsx`
   - Reuse the safe-area + scroll container pattern.
6. `apps/mobile-rn/src/components/card.tsx`
   - Reuse the tokenized dark card baseline.
7. `apps/mobile-rn/src/components/app-text.tsx`
   - Reuse existing RN typography wrapper.
8. `apps/mobile-rn/src/components/primary-button.tsx`
   - Reuse for guest browse / CTA actions where the Pencil surface uses button blocks.
9. `artifacts/design/pencil/exports/uYBc8.png`
   - Source of truth for the `soft gate` entry hero.
10. `artifacts/design/pencil/exports/TBctN.png`
    - Source of truth for `chat first run`, `chat character`, and `premium` visual hierarchy.
11. `artifacts/design/pencil/exports/pu8Go.png`
    - Source of truth for returning chat list rhythm and friend entry structure.

## Reuse Decision

### Reuse Directly

- Existing bootstrap state and route gating in `chat-screen.tsx`
- `buildSuggestedActions()`, `buildInitialThread()`, `buildLaunchMessages()`
- `RecentResultCard` for returning-user continuation
- Existing design tokens via `fortuneTheme`

### Extend

- Add a dedicated `apps/mobile-rn/src/features/chat-surface/` UI module for:
  - soft gate hero
  - chat first-run shell
  - compact premium teaser
  - conversation shell
- Keep `/chat` as the integration point; do not move logic into a new route.

### Do Not Do

- Do not reintroduce debug/status chips into the primary `/chat` surface.
- Do not create a separate in-chat rich fortune renderer.
- Do not change persisted schema for chat.
- Do not expand scope into light mirror or non-chat surfaces.

## Target Surface Mapping

- `gate=auth-entry`
  - Render the Pencil `soft gate` hero from `uYBc8.png`
  - Social auth buttons should live directly on `/chat`
  - Guest browse remains available
- `gate=ready` + no active conversation
  - Render the `chat first run` list-like shell from `TBctN.png`
  - Show tabs, prompt cards, and character list hierarchy
  - Keep recent result CTA only when data exists
- `gate=ready` + active conversation or selected character drill-in
  - Render a `chat character` conversation shell matching the middle panel in `TBctN.png`
  - Keep existing message thread and composer behavior
- `gate=profile-flow`
  - Render a polished onboarding continuation card rather than a diagnostic checklist card

## Known Constraints

- The governed Pencil exports do not yet provide every extended chat state in isolated PNGs.
- The current RN tab bar already provides the app-level bottom navigation, so the chat shell should not duplicate a second persistent nav bar.
- The existing `Screen` primitive is scroll-first, so the first pass should prefer stable vertical layouts over fixed-position composer chrome.

## Jira

- Issue: `KAN-276`

## Runtime Verification Notes

- Device: `iPhone 17` simulator (`9ED1D212-A3D3-43F1-9E36-2F1F54367878`)
- Verified states in this pass:
  - `ready-list`: `/Users/jacobmac/Desktop/Dev/fortune/artifacts/runtime/rn-iphone17-ready-list-v2.png`
  - `active-chat`: `/Users/jacobmac/Desktop/Dev/fortune/artifacts/runtime/rn-iphone17-active-chat-v2.png`
- Improvements confirmed in `v2`:
  - `ready-list` now follows the Pencil left-panel order of `small card -> highlighted conversation card -> small card`
  - counselor rows were reduced to two visible cards and restyled from plain rows to card-like entries
  - `active-chat` no longer uses stacked section cards; it renders as a continuous conversation surface with inline quick-action chips and a compact composer
- Remaining fidelity gaps:
  - top summary/avatar block in `active-chat` is still roomier than the Pencil middle panel
  - composer iconography is still placeholder-grade and should be replaced with proper glyphs/assets in the next pass
