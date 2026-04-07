# KAN-295 RCA Report

## Symptom
- RN `/premium` looked like a real purchase surface, but buying or restoring only changed local secure-store state.
- RN `/profile` displayed premium/tokens, but those values could drift from actual backend subscription state.

## WHY
- RN inherited product catalog and route scaffolding first, but never ported Flutter's actual in-app purchase pipeline.
- The current RN purchase methods are local state transforms in `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/mobile-app-state.ts`, not store-backed flows.

## WHERE
- Fake purchase application:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/mobile-app-state.ts`
- Placeholder premium screen copy:
  - `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/premium-screen.tsx`

## WHERE ELSE
- Flutter already has the real flow:
  - `/Users/jacobmac/Desktop/Dev/fortune/lib/services/in_app_purchase_service.dart`
  - `/Users/jacobmac/Desktop/Dev/fortune/lib/screens/premium/premium_screen.dart`
- Backend already has real purchase/subscription surfaces:
  - `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/payment-verify-purchase/index.ts`
  - `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/subscription-activate/index.ts`
  - `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/token-balance/index.ts`
  - `/Users/jacobmac/Desktop/Dev/fortune/supabase/migrations/20251203100001_create_subscriptions_table.sql`

## HOW
- Stop presenting fake local purchase application as if it were real.
- Sync actual subscription and token state from backend into RN shared state.
- Reframe restore as remote state refresh plus purchase-state recovery, not local optimistic mutation.
- Keep purchase CTA behavior honest until native RN store integration is ported.
