# KAN-295 Discovery Report

## Request
- RN 기준으로 프로필, 프리미엄, 구매 관련 페이지의 라우트와 실제 구독 플랜 적용 상태를 정리하고 필요한 연결을 반영한다.

## Surfaces Audited
- `/profile`: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-screen.tsx`
- `/profile/edit`: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-edit-screen.tsx`
- `/profile/notifications`: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-notifications-screen.tsx`
- `/profile/relationships`: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-relationships-screen.tsx`
- `/profile/saju-summary`: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-saju-summary-screen.tsx`
- `/premium`: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/premium-screen.tsx`
- `/privacy-policy`: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/legal-screen.tsx`
- `/terms-of-service`: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/legal-screen.tsx`
- `/account-deletion`: `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/screens/account-deletion-screen.tsx`

## Existing Reuse
- Route registry already exists in `/Users/jacobmac/Desktop/Dev/fortune/packages/product-contracts/src/routes.ts`.
- Product catalog and subscription IDs already exist in `/Users/jacobmac/Desktop/Dev/fortune/packages/product-contracts/src/products.ts`.
- RN state container already has premium/profile/chat slices in `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/mobile-app-state.ts`.
- RN bootstrap/profile sync already exists in `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx` and `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/lib/user-profile-remote.ts`.
- Flutter source of truth for actual purchase flow exists in `/Users/jacobmac/Desktop/Dev/fortune/lib/services/in_app_purchase_service.dart` and `/Users/jacobmac/Desktop/Dev/fortune/lib/screens/premium/premium_screen.dart`.

## Gap Analysis
- RN premium purchase actions are placeholder-level today.
  - `purchaseProduct()` and `restorePurchases()` in `/Users/jacobmac/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx` only mutate local secure-store state.
  - No RN store SDK, no receipt verification, and no Supabase function invocation exist in `apps/mobile-rn/src`.
- RN can already reflect real premium state from backend with current infra.
  - `subscriptions` table has user-selectable RLS for reads in `/Users/jacobmac/Desktop/Dev/fortune/supabase/migrations/20251203100001_create_subscriptions_table.sql`.
  - `token-balance` edge function can return real token balance and active subscription boolean in `/Users/jacobmac/Desktop/Dev/fortune/supabase/functions/token-balance/index.ts`.
- Profile and legal/account routes are present, but some screens are still thin shells.
  - Profile edit and notifications are real local-state editors.
  - Legal and account deletion are still mostly placeholder content.

## Decision
- Reuse the existing route and product contracts.
- Add RN-side remote premium sync instead of inventing new route structure.
- Remove user-facing reliance on fake local purchase application.
- Make profile and premium pages read from actual remote premium state where possible, and keep purchase/restore actions honest about what is and is not wired in RN.

## Implementation Scope
- Add RN helper to fetch:
  - active subscription from `subscriptions`
  - token balance from `token-balance` edge function
- Extend RN premium state with sync metadata and expiry.
- Update mobile app state provider to merge remote premium state on sync/restore.
- Update profile and premium screens to show actual plan/balance/sync info and route users through real management/refresh paths.

## Out of Scope
- Full RN native in-app purchase engine migration in this turn
- Account deletion backend execution flow
- Full legal copy migration from production source
