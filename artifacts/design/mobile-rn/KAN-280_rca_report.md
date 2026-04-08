# KAN-280 RCA Report

## Symptom
- Inside the RN active chat room, the back button/header scrolls out of view instead of staying visible at the top.

## Why
- The active chat header was rendered as part of `ActiveCharacterChatSurface` content.
- `Screen` only fixed the footer; it did not provide a fixed header region.
- Because the header lived inside the `ScrollView`, it moved together with the message list.

## Where
- `apps/mobile-rn/src/components/screen.tsx`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/screens/chat-screen.tsx`

## Correct Pattern
- Fixed room chrome should be composed outside the scrollable message body.
- `Screen` should own reusable fixed layout regions.
- Active chat body should render only scrollable room content when a fixed header is supplied.

## Fix
1. Add optional `header` slot to `Screen`.
2. Extract a reusable `ActiveCharacterChatHeader`.
3. Mount that header from `chat-screen.tsx` only in active-room mode.
4. Hide the in-body header in `ActiveCharacterChatSurface` when fixed header mode is active.
