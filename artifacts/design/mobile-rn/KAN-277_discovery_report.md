# KAN-277 Discovery Report

## Goal
- Keep the RN chat composer fixed to the bottom of the screen in active chat.
- The conversation body should scroll independently.
- The composer should rise only when the keyboard is shown.

## Files Reviewed
- `apps/mobile-rn/src/components/screen.tsx`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/screens/chat-screen.tsx`

## Findings
- `Screen` currently wraps all screen content in a single `ScrollView`.
- `ActiveCharacterChatSurface` renders the composer inline at the end of the scroll body.
- Because the composer is part of the scroll content, it cannot stay pinned to the bottom.
- There is no existing `KeyboardAvoidingView` or fixed footer screen pattern in `apps/mobile-rn`.

## Reuse vs New
- Reuse the existing `Screen` component and extend it with an optional fixed footer mode.
- Reuse the current composer visuals from `ActiveCharacterChatSurface`.
- Extract the composer into a dedicated component so `ChatScreen` can place it in a fixed footer slot.

## Implementation Direction
- Add optional `footer` and `keyboardAvoiding` support to `Screen`.
- Keep auth-entry and ready-list on the existing scroll-only path.
- Use the fixed footer path only for `gate === 'ready' && surfaceMode === 'chat'`.
- Validate on the iPhone 17 simulator.
