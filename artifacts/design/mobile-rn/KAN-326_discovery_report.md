# KAN-326 Discovery Report

## Request
- Fix the Apple auth button so its design matches the standardized RN social auth button system and change the visible text to `Apple 로그인`.

## Existing Surface Reviewed
1. `apps/mobile-rn/src/components/apple-auth-button.tsx`
   - Current problem source.
   - It still uses `AppleAuthenticationButton`, so the visual treatment and wording are controlled by the native control instead of the app design system.
2. `apps/mobile-rn/src/components/social-auth-pill-button.tsx`
   - Already contains the standardized shared shell for provider buttons, including Apple provider styling.
   - Reuse decision: use this as the single source of truth for Apple button visuals too.
3. `apps/mobile-rn/src/screens/signup-screen.tsx`
   - Contains the visible Apple label in the signup auth options.
4. `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
   - Contains the explicit Apple label in the chat soft gate.

## Reuse / Reference Decision
- Reuse as-is:
  - `SocialAuthPillButton` provider=`apple`
  - existing Apple provider visual tokens in `social-auth-pill-button.tsx`
- Remove from this surface:
  - `AppleAuthenticationButton` visual dependency inside `apple-auth-button.tsx`
- Required update:
  - turn `AppleAuthButton` into a thin wrapper around `SocialAuthPillButton`
  - change visible label to `Apple 로그인`

## Figma
- No Figma context was provided.
- Result: local RN component standardization only.

## Planned Changes
1. Replace native Apple button rendering in `apple-auth-button.tsx` with the shared shell component.
2. Update Apple labels in signup/chat surfaces to `Apple 로그인`.
3. Re-run diff check, RN typecheck, `flutter analyze`, iOS runtime launch, and screenshot verification.
