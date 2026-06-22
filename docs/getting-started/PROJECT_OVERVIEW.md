# Ondo Project Overview

Ondo is a React Native companion chat and fortune app. The active app is `apps/mobile-rn`, built with Expo, TypeScript, and `expo-router`.

## Product Model

- `일반 채팅`: DM-style conversations with story characters.
- `호기심`: guided fortune or insight conversations with expert characters.
- Fortune results can appear inside chat or in registered result screens.

## Active Surfaces

- `/chat`: primary entry surface
- `/fortune`: feature-flag/legacy fortune entry
- `/profile`: profile and settings
- `/premium`: subscription and purchase surface
- `/onboarding/*`: onboarding flows
- `/friends/new/*`: friend creation flow
- `/result/[resultKind]`: result detail screens

## Code Map

```text
apps/mobile-rn/app/          # route files
apps/mobile-rn/src/screens/  # route-level screens
apps/mobile-rn/src/features/ # feature slices
apps/mobile-rn/src/providers/# global React Context providers
apps/mobile-rn/src/components/
apps/mobile-rn/src/lib/
packages/product-contracts/
packages/design-tokens/
packages/saju-engine/
supabase/functions/
```

## Development

```bash
corepack enable
corepack prepare pnpm@10.33.1 --activate
pnpm install
npm run rn:typecheck
npm run rn:test
```

Local native iOS commands are documented in [local-native-ios-testing.md](../development/local-native-ios-testing.md).

## Source Of Truth

- Runtime app structure: `apps/mobile-rn/`
- Shared contracts: `packages/product-contracts/`
- Server behavior: `supabase/functions/`
- Route reference: [APP_SURFACES_AND_ROUTES.md](./APP_SURFACES_AND_ROUTES.md)
- Architecture reference: [APP_ARCHITECTURE.md](../APP_ARCHITECTURE.md)
