# Ondo Setup Guide

## Requirements

- Node.js 20.x
- pnpm 10.33.1
- Xcode and CocoaPods for iOS native builds
- Supabase CLI for Edge Function development
- EAS CLI when performing production native builds

## Install

```bash
git clone https://github.com/injooinjoo/fortune.git
cd fortune
corepack enable
corepack prepare pnpm@10.33.1 --activate
pnpm install
```

## Environment

Start from the sample file and fill in real local values.

```bash
cp .env.example .env
```

Common values:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
MOBILE_APP_SCHEME=com.beyond.fortune
MOBILE_AUTH_CALLBACK_HOST=auth-callback
MOBILE_AUTH_CALLBACK_URL=com.beyond.fortune://auth-callback
```

## Verification

```bash
npm run rn:typecheck
npm run rn:test
pnpm --filter @fortune/mobile-rn lint
```

## RN Native

```bash
pnpm --filter @fortune/mobile-rn native:prepare
pnpm --filter @fortune/mobile-rn native:pods
pnpm --filter @fortune/mobile-rn native:build
pnpm --filter @fortune/mobile-rn ios:xcode
```

Do not run Expo or Metro from automation. Start local app servers manually when runtime testing is needed.

## Web Export For QA

```bash
npm run rn:web:export
npm run serve:rn-web
```

Playwright uses the same export path when it starts its own web server.
