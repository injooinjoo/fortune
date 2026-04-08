# KAN-322 Discovery Report

## Request
- Add official-style provider logos/labels to the React Native social auth buttons and keep them aligned to the Apple button sizing system.

## Existing Surface
- `apps/mobile-rn/src/components/apple-auth-button.tsx`
- `apps/mobile-rn/src/components/social-auth-pill-button.tsx`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/screens/signup-screen.tsx`

## Findings
- The current non-Apple buttons only use text and internal badge placeholders, so they do not feel like official provider entry points.
- `@expo/vector-icons` exists in the lockfile via Expo, but no official Google/Kakao/Naver button assets are currently stored in the app.
- Google’s official brand resource page exposes an approved `Google G` icon asset.
- Kakao resource tooling exposes official Kakao Sync login button PNGs, including Korean wide variants.
- Naver provides official Korean login button PNG sets, including white and green wide variants.
- There is a branding tension:
  - the user wants Apple-aligned sizing and consistency
  - Naver’s guide recommends the green complete button in many mixed-button contexts
  - Kakao’s official button remains yellow
- To satisfy the user request while staying close to provider guidance, the safest compromise is:
  - preserve one common button height and overall layout rhythm
  - use official provider assets where available
  - keep Google as a custom white button with the official `G` icon because no equivalent downloadable full button asset was found in the consulted source

## Source Assets Chosen
- Google:
  - official `Google G` icon from Google Brand Resource Center
- Kakao:
  - official Korean wide login PNG from Kakao resource tooling
- Naver:
  - official Korean white wide login PNG from Naver login BI download pack

## Planned Changes
1. Add provider logo/button PNG assets under `apps/mobile-rn/assets/social-auth/`.
2. Update `SocialAuthPillButton` to render provider-specific official content.
3. Align button labels in chat/signup surfaces to the official asset wording where needed.
4. Re-run RN typecheck, `flutter analyze`, iOS runtime launch, and screenshot verification.
