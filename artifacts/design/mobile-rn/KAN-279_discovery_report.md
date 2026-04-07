# KAN-279 Discovery Report

## Goal
- Fix the RN `/chat` first-run surface so:
  - `스토리` shows story conversation characters
  - `운세보기` shows fortune expert characters
- Keep recent character/profile lookups consistent across RN screens after the split.

## Sources Checked
- `docs/getting-started/APP_SURFACES_AND_ROUTES.md`
- `artifacts/design/paper_sync/mapping.json`
- `artifacts/design/pencil/README.md`
- `lib/features/character/presentation/providers/character_provider.dart`
- `lib/features/character/data/default_characters.dart`
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/screens/profile-screen.tsx`
- `apps/mobile-rn/src/screens/character-profile-screen.tsx`
- `apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
- `apps/mobile-rn/src/components/recent-chat-signal-card.tsx`
- `apps/mobile-rn/src/features/fortune-results/recent-result-card.tsx`

## Search Commands
- `rg -n "스토리|운세보기|일반 채팅|호기심|/chat" docs/getting-started/APP_SURFACES_AND_ROUTES.md .claude/docs/paper-artboard-map.md artifacts/design/paper_sync/mapping.json artifacts/design/pencil/README.md`
- `rg -n "fortuneCharacters\\b|findCharacterById|selectedCharacterId|characterId" apps/mobile-rn/src/screens apps/mobile-rn/src/components apps/mobile-rn/src/features -g '*.{ts,tsx}'`
- `rg -n "storyCharactersProvider|fortuneCharactersProvider|CharacterListTab" lib/features/character -g '*.dart'`
- `rg -n "defaultCharacters" lib/features/character/data -g '*.dart'`

## Findings
1. Route truth already defines two internal `/chat` experiences.
   - `일반 채팅` maps to `story`
   - `호기심` maps to `fortune`
   - Source: `docs/getting-started/APP_SURFACES_AND_ROUTES.md`

2. Flutter already splits the registries.
   - `storyCharactersProvider` serves general/story characters
   - `fortuneCharactersProvider` serves fortune experts
   - Default tab is `story`

3. RN did not have a story-character registry.
   - `chat-screen.tsx` initialized only from `fortuneCharacters`
   - `ChatFirstRunSurface` rendered static pills with no real data split
   - Result: both tabs effectively pointed to the same fortune-expert list

4. Supporting RN screens also assumed all selected characters were fortune experts.
   - `profile-screen.tsx`
   - `character-profile-screen.tsx`
   - `profile-relationships-screen.tsx`
   - `recent-chat-signal-card.tsx`
   - `recent-result-card.tsx`

5. `/profile/relationships` is documented as a story-character surface.
   - Source says: `스토리 캐릭터 관계도`
   - That means its preview list should not be seeded from fortune experts.

## Reuse Decision
- Reuse RN chat-shell and current route stack.
- Add a local RN chat registry instead of changing shared product contracts for story characters.
- Reuse shared product contracts only for fortune experts.
- Follow Flutter split semantics for `story` vs `fortune`.

## Implementation Direction
- Create a local RN chat registry that merges:
  - story characters copied from Flutter default character inventory
  - fortune experts from `@fortune/product-contracts`
- Make `/chat` own a real `activeTab` state.
- Make `ChatFirstRunSurface` render:
  - story tab: story characters + `새 친구 만들기`
  - fortune tab: fortune experts + fortune quick actions
- Change recent/profile lookups to the unified RN chat registry.
- Keep result-stack reopen bound to fortune experts only.

## Files To Touch
- `apps/mobile-rn/src/lib/chat-characters.ts`
- `apps/mobile-rn/src/lib/chat-shell.ts`
- `apps/mobile-rn/src/screens/chat-screen.tsx`
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx`
- `apps/mobile-rn/src/screens/profile-screen.tsx`
- `apps/mobile-rn/src/screens/character-profile-screen.tsx`
- `apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
- `apps/mobile-rn/src/components/recent-chat-signal-card.tsx`
- `apps/mobile-rn/src/features/fortune-results/recent-result-card.tsx`
