# KAN-324 Discovery Report

## Request
- Standardize the React Native social auth button design so it behaves like a real button system instead of a mix of native Apple, custom Google, and full-image Kakao/Naver buttons.

## Goal
- Keep Apple sizing as the reference rhythm.
- Use official provider marks and official login wording where possible.
- Normalize shell metrics across providers: height, radius, inner padding, icon slot, label alignment.

## Existing Surface Reviewed
1. `apps/mobile-rn/src/components/social-auth-pill-button.tsx`
   - Current non-Apple entry point for Google/Kakao/Naver.
   - Problem: Google uses icon mode but Kakao/Naver bypass the system with full-button PNGs.
2. `apps/mobile-rn/src/components/apple-auth-button.tsx`
   - Defines the Apple reference height (`52`) and native iOS behavior.
   - Reuse decision: keep native Apple button on iOS and match its shell rhythm elsewhere.
3. `apps/mobile-rn/src/screens/signup-screen.tsx`
   - Defines the auth option labels and explanatory notes for signup.
   - Reuse decision: update only provider wording, keep flow and copy structure.
4. `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
   - Reuses the same auth button surface inside the chat soft gate.
   - Reuse decision: keep structure and only align labels/buttons.
5. `apps/mobile-rn/src/components/app-text.tsx`
   - Central text rendering wrapper for the RN app.
   - Reuse decision: preserve existing typography variants instead of adding raw text styles.
6. `apps/mobile-rn/src/lib/theme.ts`
   - Provides `fortuneTheme` tokens for radius, spacing, and text/background colors.
   - Reuse decision: use existing theme tokens for shell sizing/radius and limit brand-specific values to provider marks only.

## Branding Asset Review
- Existing assets under `apps/mobile-rn/assets/social-auth/`:
  - `google-g-20dp.png`
  - `kakao-login-large-wide.png`
  - `naver-login-light-white-wide-h56.png`
- Findings:
  - Google already fits the shell-based button pattern.
  - Kakao/Naver wide assets encode their own container, so they break system consistency.
  - Naver provides official icon-only assets in the BI pack.
  - Kakao’s resource tooling exposes an official simple login asset from which the approved speech-bubble mark can be isolated.

## Reuse / Reference Decision
- Reuse as-is:
  - `AppleAuthButton` native iOS implementation
  - `AppText` typography variants
  - `fortuneTheme.radius.full` and existing button height `52`
- Reference pattern:
  - Existing left-icon / centered-label / right-spacer layout in `social-auth-pill-button.tsx`
- New work required:
  - Replace full-button image mode with icon-only mark mode
  - Add normalized provider metadata for icon sizing and official wording
  - Add local icon assets for Kakao and Naver that can live inside one shared shell

## Figma
- No Figma file key / node id / URL was provided in this turn.
- Result: local RN design standardization proceeds without Figma sync for this task.

## Planned Changes
1. Add icon-only official provider marks for Kakao and Naver under `apps/mobile-rn/assets/social-auth/`.
2. Refactor `social-auth-pill-button.tsx` into a single-shell button system for all non-native providers.
3. Align provider labels in `signup-screen.tsx` and `chat-surface.tsx` to the standardized wording set.
4. Re-run diff check, RN typecheck, `flutter analyze`, iOS simulator launch, and screenshot verification.
