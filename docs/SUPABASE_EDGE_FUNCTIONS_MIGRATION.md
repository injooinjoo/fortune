# Supabase Edge Functions Migration Guide

## Overview

This guide documents the migration from our current backend infrastructure (Express.js on Cloud Run + Firebase Functions) to Supabase Edge Functions.

## Current Architecture

### 1. **Firebase Functions** (`/functions/`)
- Simple proxy to Cloud Run API
- Deployed to asia-northeast3

### 2. **Fortune API Server** (`/fortune-api-server/`)
- Express.js + TypeScript
- Deployed on Google Cloud Run
- Features:
  - 59 fortune generation endpoints
  - Authentication with JWT
  - Token system (consumption/balance)
  - Redis caching (Upstash)
  - Payment integration (Stripe/TossPay)
  - Admin endpoints

### 3. **Next.js API Routes** (`/src/app/api/`)
- 84+ endpoints (mostly unused)
- Planned for removal

## Migration Strategy

### Phase 1: Setup & Core Infrastructure

1. **Edge Functions Structure**
```
supabase/
└── functions/
    ├── _shared/
    │   ├── cors.ts
    │   ├── auth.ts
    │   ├── cache.ts
    │   ├── openai.ts
    │   └── types.ts
    ├── fortune-daily/
    │   └── index.ts
    ├── fortune-zodiac/
    │   └── index.ts
    ├── token-balance/
    │   └── index.ts
    └── payment-webhook/
        └── index.ts
```

2. **Core Utilities Migration**
- Auth middleware → Supabase Auth helpers
- Token system → Supabase storage + Edge Functions
- Redis cache → Supabase cache or KV store
- OpenAI client → Deno-compatible version

### Phase 2: Fortune Endpoints Migration

Each fortune type becomes its own Edge Function:
- `/fortune-daily` - Daily fortune
- `/fortune-zodiac` - Zodiac fortune
- `/fortune-mbti` - MBTI fortune
- etc.

**Benefits:**
- Independent scaling
- Easier maintenance
- Better monitoring
- Reduced cold starts

### Phase 3: Payment & Admin Functions

- `/payment-stripe` - Stripe webhook handler
- `/payment-toss` - TossPay integration
- `/admin-stats` - Admin statistics
- `/admin-users` - User management

### Phase 4: Flutter App Update

Update API endpoints in Flutter app:
```dart
// Before
const API_BASE_URL = 'https://fortune-api-server.run.app/api/v1';

// After
const API_BASE_URL = 'https://[project-ref].supabase.co/functions/v1';
```

## Key Migration Considerations

### 1. **Deno vs Node.js**
- Use Deno-compatible packages
- No `node_modules`, use URL imports
- TypeScript built-in

### 2. **Authentication**
```typescript
// Express.js middleware
export const authMiddleware = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  // JWT verification
};

// Edge Function
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

export async function handler(req: Request) {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!
  );
  
  const token = req.headers.get('authorization')?.split(' ')[1];
  const { data: { user } } = await supabase.auth.getUser(token);
}
```

### 3. **Caching Strategy**
- Replace Redis with Supabase cache
- Use database for persistent cache
- Consider edge caching for static data

### 4. **Environment Variables**
```bash
# Set via Supabase CLI
supabase secrets set OPENAI_API_KEY=sk-xxx
supabase secrets set STRIPE_SECRET_KEY=sk-xxx
```

## Testing Strategy

1. **Local Development**
```bash
supabase start
supabase functions serve fortune-daily --env-file ./supabase/.env.local
```

2. **Unit Tests**
- Use Deno test runner
- Mock Supabase client
- Test edge cases

3. **Integration Tests**
- Test with local Supabase
- Verify auth flow
- Check token consumption

## Deployment Process

1. **Gradual Rollout**
- Deploy one function at a time
- Use feature flags in Flutter
- Monitor performance

2. **Traffic Migration**
- Start with 10% traffic
- Monitor error rates
- Gradually increase

## Cost Comparison

### Current (Cloud Run + Firebase)
- Cloud Run: ~$50-100/month
- Firebase Functions: ~$20/month
- Redis (Upstash): $10/month
- Total: ~$80-130/month

### Supabase Edge Functions
- Edge Functions: ~$25/month (estimated)
- Database: Included in Supabase plan
- Caching: Included
- Total: ~$25/month

## Monitoring & Analytics

1. **Supabase Dashboard**
- Function invocations
- Error rates
- Response times

2. **Custom Logging**
```typescript
console.log(JSON.stringify({
  function: 'fortune-daily',
  userId: user.id,
  duration: Date.now() - startTime,
  status: 'success'
}));
```

## Rollback Plan

1. Keep Cloud Run API running
2. Use environment variable for API switching
3. Quick rollback via Flutter config update

## Timeline

- Week 1: Setup & core utilities
- Week 2-3: Fortune endpoints
- Week 4: Payment & admin
- Week 5: Testing & deployment

## Next Steps

1. Create first Edge Function (daily fortune)
2. Set up shared utilities
3. Test with Flutter app
4. Document API changes