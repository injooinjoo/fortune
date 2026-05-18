# App Store Connect Token IAP Product Setup

온도 토큰 충전 화면(`intent=top-up`)과 서버 영수증 검증(`payment-verify-purchase`)이 기대하는 App Store Connect 소모성 IAP 상품 목록입니다.

## Required consumable products

| Product ID | Type | Reference name | Display name (ko-KR) | Token credit | Price (KRW) | App code source |
|---|---|---|---|---:|---:|---|
| `com.beyond.fortune.tokens.starter` | Consumable | Ondo Tokens Starter 30 | 30 토큰 | 30 | ₩1,100 | `productCatalog`, focused top-up card |
| `com.beyond.fortune.tokens.basic` | Consumable | Ondo Tokens Basic 150 | 150 토큰 | 150 | ₩4,400 | full premium storefront |
| `com.beyond.fortune.tokens.popular` | Consumable | Ondo Tokens Popular 400 | 400 토큰 | 400 | ₩9,900 | focused top-up recommended card |
| `com.beyond.fortune.tokens.heavy` | Consumable | Ondo Tokens Heavy 1000 | 1000 토큰 | 1000 | ₩22,000 | focused top-up high-use card |

## App Store Connect checklist

1. App Store Connect → 온도 (`com.beyond.fortune`, ASC App ID `6749496180`) → Features / In-App Purchases.
2. Create each product above as **Consumable**.
3. Product IDs must match exactly; they are the StoreKit SKUs requested by `expo-iap`.
4. Add Korean localization:
   - Display name: table value.
   - Description suggestion: `온도 앱에서 AI 운세와 캐릭터 대화에 사용할 수 있는 토큰입니다.`
5. Set price equal to the app catalog KRW price. If Apple tier mapping differs by region, keep StoreKit `displayPrice` as the UI source of truth.
6. Attach the required review screenshot for each IAP product before submission.
7. Keep legacy products (`tokens10`, `tokens50`, `tokens100`, `tokens200`, `points*`) available only for restore/backward compatibility unless intentionally reintroduced into storefront.

## Code/server linkage verified in repo

- Client fetches StoreKit products from `storefrontConsumableProductIds` in `packages/product-contracts/src/products.ts`.
- Purchase request uses `requestPurchase({ type: 'in-app', request: { apple: { sku: productId } } })` in `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx`.
- iOS receipt is sent to `supabase/functions/payment-verify-purchase`, and the server binds the Apple receipt line to the requested StoreKit product/transaction before granting tokens.
- Server token grant uses `grant_purchase_tokens_atomic`, so balance update, first-purchase bonus, and purchase transaction insert are atomic and globally idempotent by store transaction ID.

## Current automation limitation

This machine does not currently have App Store Connect API credentials in the shell environment, and browser access redirects to `authResult=FAILED`. Product creation in ASC is therefore a manual/App Store Connect-authenticated step unless API credentials are provided to the session.
