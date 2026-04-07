# KAN-279 RCA Report

## Symptom
- RN `/chat` first-run surface showed fortune-expert data regardless of whether the user looked at `스토리` or `운세보기`.
- Supporting surfaces treated the last selected character as if it always came from the fortune-expert registry.

## Why
- RN only had `fortuneCharacters` as a usable character source.
- The segmented pills on the first-run surface were visual only; there was no active tab state driving the list.
- Deep-link and recent-selection logic also resolved through the fortune-only registry.

## Where
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/screens/profile-screen.tsx`
- `apps/mobile-rn/src/screens/character-profile-screen.tsx`
- `apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
- `apps/mobile-rn/src/components/recent-chat-signal-card.tsx`
- `apps/mobile-rn/src/features/fortune-results/recent-result-card.tsx`

## Where Else
- Any RN view reading `selectedCharacterId` and resolving it only through `fortuneCharacters` would mis-handle story characters.
- `/profile/relationships` also drifted from docs by previewing fortune experts even though the surface is documented as story-character relationships.

## Correct Pattern
- Flutter already uses a split model:
  - story list for normal character conversations
  - fortune list for curiosity/fortune experiences
- RN should mirror that by:
  - holding a real `activeTab`
  - resolving chat selections against a unified local chat registry
  - limiting result reopen flows to fortune experts

## Fix
1. Added `apps/mobile-rn/src/lib/chat-characters.ts` with:
   - `storyChatCharacters`
   - `fortuneChatCharacters`
   - `chatCharacters`
   - `findChatCharacterById`
   - `isFortuneChatCharacter`
2. Updated chat shell helpers to accept both story and fortune characters.
3. Updated `/chat` to:
   - initialize from `chatCharacters`
   - track `activeTab`
   - show story characters in `스토리`
   - show fortune experts in `운세보기`
4. Updated supporting surfaces to resolve recent characters through the unified chat registry.
5. Updated `/profile/relationships` preview cards to use story characters, matching route docs.

## Verification Target
- Story tab shows story characters only.
- Fortune tab shows fortune experts only.
- Story character selection opens a story conversation with no fortune quick chips.
- Fortune character selection keeps result-stack routing intact.
- Recent/profile surfaces no longer lose story-character identity.
