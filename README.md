# Fortune

Ondo React Native monorepo입니다. 현재 활성 앱은 Expo 기반 `apps/mobile-rn/` 하나이며, 서버 경계는 `supabase/functions/`, 공유 계약은 `packages/` 아래 패키지를 기준으로 합니다.

## Product Surface

- Main route: `/chat`
- Alias route: `/home` -> `/chat`
- Supporting routes: onboarding, auth callback, character detail, premium, legal, account deletion
- Product language: `일반 채팅` and `호기심`

## Repository Map

```text
apps/mobile-rn/
  app/                 # expo-router routes
  src/components/      # reusable UI primitives
  src/features/        # feature slices
  src/lib/             # runtime logic, clients, storage, theme
  src/providers/       # React Context providers
packages/
  design-tokens/
  product-contracts/
  saju-engine/
supabase/
  functions/
  migrations/
docs/
  getting-started/
  development/
  deployment/
  native/
  legal/
```

## Requirements

- Node.js 20.x
- pnpm 10.33.1
- Xcode and CocoaPods for local iOS native builds
- Supabase CLI for Edge Function work

## Setup

```bash
corepack enable
corepack prepare pnpm@10.33.1 --activate
pnpm install
```

## Common Commands

```bash
npm run rn:typecheck
npm run rn:test
pnpm --filter @fortune/mobile-rn lint
pnpm --filter @fortune/mobile-rn native:prepare
pnpm --filter @fortune/mobile-rn native:build
```

Do not start Expo or Metro from automation. For manual app testing, run the RN start/build commands yourself and share logs when debugging is needed.

## CI

- `CI Pipeline`: dependency install, Edge pricing sync check, RN typecheck, Supabase RLS static audit
- `E2E Tests`: Playwright smoke/E2E against RN web export
- `Security Scan`: secret scanning, dependency scan, RN typecheck

## Documentation

- [Current routes](docs/getting-started/APP_SURFACES_AND_ROUTES.md)
- [Project overview](docs/getting-started/PROJECT_OVERVIEW.md)
- [Architecture](docs/APP_ARCHITECTURE.md)
- [Local native iOS testing](docs/development/local-native-ios-testing.md)
- [Expo CNG build and release](docs/development/expo-cng-build-and-release.md)

## Security

- Keep secrets out of git.
- Use `.env.example` only for placeholder documentation.
- Runtime secrets are provided through local env files, EAS secrets, Supabase secrets, or GitHub Actions secrets depending on the boundary.
