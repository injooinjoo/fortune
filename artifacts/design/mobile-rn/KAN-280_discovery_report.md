# KAN-280 Discovery Report

## Goal
- Keep the top back button/header visible inside the RN active chat room while the message area scrolls.

## Files Reviewed
- `apps/mobile-rn/src/components/screen.tsx`
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/screens/friend-creation-screen.tsx`
- `apps/mobile-rn/src/features/fortune-results/primitives.tsx`

## Search Commands
- `rg -n "<Screen|header=|footer=|keyboardAvoiding=" apps/mobile-rn/src apps/mobile-rn/app -g '*.{ts,tsx}'`
- `rg -n "onBack\\(|ActiveCharacterChatSurface|header|back" apps/mobile-rn/src/screens/chat-screen.tsx apps/mobile-rn/src/features/chat-surface/chat-surface.tsx apps/mobile-rn/src/components/screen.tsx -g '*.{ts,tsx}'`
- `rg -n "<Screen footer=|<Screen\\s*$|footer=\\{|keyboardAvoiding" apps/mobile-rn/src/screens apps/mobile-rn/src/features -g '*.{ts,tsx}'`

## Findings
1. `Screen` already supports a fixed footer but has no header slot.
2. Active chat room header currently lives inside `ActiveCharacterChatSurface`, so it scrolls away with the conversation body.
3. `chat-screen.tsx` already composes active-room state at the `Screen` level, which makes it the right place to mount a fixed header.
4. Existing screens such as friend creation and result layouts use `Screen` directly and would not be affected by adding an optional header slot.

## Reuse Decision
- Reuse `Screen` as the common fixed-chrome layout primitive.
- Extract the active chat room header into a reusable component instead of duplicating markup.
- Keep all changes within `apps/mobile-rn`.

## Implementation Plan
- Add optional `header` prop to `Screen`.
- Render the active chat header in `chat-screen.tsx` via the fixed `Screen` header slot.
- Let `ActiveCharacterChatSurface` hide its internal header when the fixed header is provided.
