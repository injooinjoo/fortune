# KAN-321 Discovery Report

## Request
- Improve the React Native auth entry surface by:
  1. Fully syncing the social auth button style to the Apple-style presentation
  2. Rewriting the top slogan/body copy to sound more productized and business-ready

## Reused / Extended Patterns
- Existing auth entry surface:
  - `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- Existing dedicated signup screen:
  - `apps/mobile-rn/src/screens/signup-screen.tsx`
- Existing Apple auth wrapper:
  - `apps/mobile-rn/src/components/apple-auth-button.tsx`
- Existing shared non-Apple auth button:
  - `apps/mobile-rn/src/components/social-auth-pill-button.tsx`
- Existing RN design tokens:
  - `apps/mobile-rn/src/lib/theme.ts`
  - `packages/design-tokens/src/index.ts`

## Findings
- The hero copy in `ChatSoftGate` still uses lightweight “browse first” language and does not clearly communicate account value.
- The shared `SocialAuthPillButton` already made Google/Kakao/Naver white, but it is still only a plain label button and does not visually feel like part of the Apple auth family.
- `SignupScreen` duplicates auth-entry messaging and should be aligned in tone so users do not get two different product narratives.
- No Figma file or node context was provided, so the visual source of truth is the current RN Apple auth surface plus the attached simulator screenshot.
- A gstack design-review lens is applicable for hierarchy/copy polish, but browser-based gstack QA is not the primary tool here because this surface is React Native, not a web page.

## Decision
- Extend existing shared RN components instead of introducing a new auth surface.
- Update only presentation-layer files.
- Reuse existing design tokens for provider badges and typography rather than inventing new hardcoded styles.

## Planned Changes
1. Upgrade `SocialAuthPillButton` so it can render provider-specific badges while preserving the shared white Apple-like pill structure.
2. Pass provider identity from `chat-surface.tsx` and `signup-screen.tsx`.
3. Rewrite the auth hero copy in `ChatSoftGate` to emphasize continuity of saved insights, personalization, and purchase state.
4. Align the dedicated signup screen copy to the same business/product tone.
