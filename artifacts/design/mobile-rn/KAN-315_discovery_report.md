# KAN-315 Discovery Report

## Request
- Make the `메시지 > 스토리` add button a true floating FAB with no footer/background band behind it.

## Existing Implementation
- `apps/mobile-rn/src/screens/chat-screen.tsx`
  - story list mode currently passes `FloatingCreateButton` through `Screen.footer`.
- `apps/mobile-rn/src/components/screen.tsx`
  - `footer` renders a full-width bottom container with background + padding.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
  - `FloatingCreateButton` itself is already visually close to the desired circular FAB.

## Reuse / Extend / New
- Reuse: keep `FloatingCreateButton` as the visual button component.
- Extend: add overlay support to `Screen` so floating UI can be placed above scroll content without footer chrome.
- Avoid: creating a one-off absolute wrapper directly inside `chat-screen.tsx`, because the same layout need can recur on other RN surfaces.

## Target Change
1. Add `overlay` support to `Screen`.
2. Add a content bottom inset option so list content clears the FAB.
3. Move story-list FAB usage from `footer` to `overlay`.

## Validation Plan
- `npm run rn:typecheck`
- `npm run rn:test`
- `flutter analyze`
- iPhone 17 runtime rebuild and screenshot of the story list root
