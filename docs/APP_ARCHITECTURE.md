# Ondo Architecture

Ondo의 활성 런타임은 Expo 기반 React Native 앱입니다. 모바일 앱은 `apps/mobile-rn/`, 공유 계약은 `packages/`, 서버 로직은 `supabase/functions/`를 기준으로 합니다.

## Runtime Boundaries

```text
apps/mobile-rn/
  app/                 # expo-router route files
  src/screens/         # route-level screen composition
  src/features/        # domain feature slices
  src/providers/       # React Context providers
  src/components/      # reusable UI primitives
  src/lib/             # runtime logic, clients, storage, theme
packages/
  product-contracts/   # routes, products, fortune contracts, normalizers
  design-tokens/       # shared design token package
  saju-engine/         # local saju calculation package
supabase/
  functions/           # Edge Functions
  migrations/          # database migrations
```

## Routing

Routes are defined by `apps/mobile-rn/app/` with `expo-router`.

- `/chat`: primary chat surface
- `/fortune`: legacy/feature-flag fortune entry
- `/profile`: profile/settings stack
- `/character/[id]`: character detail
- `/friends/new/*`: friend creation flow
- `/result/[resultKind]`: fortune result surface
- `/auth/*`, `/onboarding/*`, `/premium`, legal/account routes

## Layer Rules

- `app/*` should stay thin and delegate to screens/features/providers.
- `screens/*` composes feature slices and route params.
- `features/*` owns domain UI and local feature logic.
- `providers/*` owns global app state via React Context.
- `lib/*` owns runtime logic, remote clients, storage, haptics, analytics, and theme.
- `components/*` stays domain-light and reusable.

Avoid feature-to-feature imports. Move shared logic to `src/lib/` or shared UI to `src/components/`.

## State

Global state uses React Context plus hooks. Existing providers include app bootstrap, mobile app state, social auth, and friend creation. Do not add a separate global state library unless explicitly approved.

## Server Boundary

Mobile calls Supabase Edge Functions through established client modules and feature runtime adapters. Edge Functions use shared modules under `supabase/functions/_shared/`, including the LLM factory and shared pricing/contracts. Direct provider API calls from arbitrary UI components are not the standard path.

## Design System

RN UI code should use:

- `apps/mobile-rn/src/components/app-text.tsx`
- `apps/mobile-rn/src/lib/theme.ts`
- existing button/card/chip/screen primitives

Hardcoded colors and ad hoc text styling should be avoided when a token or primitive exists.
