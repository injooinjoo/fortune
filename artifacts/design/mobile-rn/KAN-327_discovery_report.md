# KAN-327 Discovery Report

## Request
- Change the visible RN social auth labels from `Apple 로그인` to `애플 로그인` and from `Google로 로그인` to `구글 로그인`.

## Existing Surface Reviewed
1. `apps/mobile-rn/src/components/apple-auth-button.tsx`
   - Holds the default Apple button label.
2. `apps/mobile-rn/src/screens/signup-screen.tsx`
   - Defines Apple/Google button labels and notes for the signup surface.
3. `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
   - Defines Apple/Google button labels for the chat soft gate.
4. `apps/mobile-rn/src/lib/social-auth.ts`
   - Contains `socialAuthProviderLabelById`, which is reused in progress/error messages shown during auth flows.

## Reuse / Reference Decision
- Reuse as-is:
  - current shared auth button system and layout
- Change required:
  - localize Apple/Google provider names in button labels
  - localize Apple/Google provider names in `socialAuthProviderLabelById`
  - localize static Apple auth error/cancel strings so helper messages stay consistent with the UI labels

## Figma
- No Figma context was provided.
- Result: local RN copy update only.

## Planned Changes
1. Update Apple button default label to `애플 로그인`.
2. Update signup/chat visible labels to `애플 로그인`, `구글 로그인`.
3. Update social auth provider label map and Apple-specific auth error strings to use Korean provider naming.
4. Re-run diff check, RN typecheck, `flutter analyze`, and runtime screenshot verification.
