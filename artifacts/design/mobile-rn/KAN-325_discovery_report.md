# KAN-325 Discovery Report

## Request
- Make the social auth button wording match one consistent pattern across providers.

## Goal
- Align Apple, Google, Kakao, and Naver CTAs to one action family.
- Keep the Apple button official/native on iOS.

## Existing Surface Reviewed
1. `apps/mobile-rn/src/components/apple-auth-button.tsx`
   - Current default label is `Apple로 계속하기`.
   - iOS native button uses `AppleAuthenticationButtonType.CONTINUE`, which creates wording mismatch with the other providers.
2. `apps/mobile-rn/src/screens/signup-screen.tsx`
   - Signup auth option list defines the visible CTA copy.
   - Only Apple still uses the `계속하기` pattern.
3. `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
   - Chat soft gate reuses the same buttons but does not explicitly pass an Apple label.
   - This should be aligned to the same wording family for consistency.

## Reuse / Reference Decision
- Reuse as-is:
  - `SocialAuthPillButton` structure from `KAN-324`
  - provider-specific labels already standardized to `로그인` for Google/Kakao/Naver
- Change required:
  - Apple button default label from `Apple로 계속하기` to `Apple로 로그인`
  - Apple native button type from `CONTINUE` to `SIGN_IN`
  - Pass the same Apple label on surfaces where clarity helps

## Figma
- No Figma context was provided for this request.
- Result: local RN copy standardization only.

## Planned Changes
1. Update Apple auth button wording to the `로그인` family.
2. Align signup and chat entry surfaces to the same Apple label.
3. Re-run diff check, RN typecheck, and `flutter analyze`.
