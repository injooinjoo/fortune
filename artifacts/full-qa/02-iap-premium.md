# 02 · IAP + Premium QA Checklist (Ondo / 온도)

Scope: Apple Guideline 3.1.1 (in-app purchase for digital goods), 3.1.2 (auto-renewable subscription metadata + restore).

Target build: `com.beyond.fortune` (iOS, Expo SDK 54, react-native-iap runtime).

---

## 1. Product inventory (from `packages/product-contracts/src/products.ts`)

Three product types live side-by-side in the paywall (`premium-screen.tsx`):

| SKU | Type | Display | Price (KRW) | Notes |
|---|---|---|---|---|
| `com.beyond.fortune.tokens10` | Consumable | 토큰 10개 | ₩1,100 | Active storefront |
| `com.beyond.fortune.tokens50` | Consumable | 토큰 50개 | — | Active storefront |
| `com.beyond.fortune.tokens100` | Consumable | 토큰 100개 | — | Active storefront |
| `com.beyond.fortune.tokens200` | Consumable | 토큰 200개 | — | Active storefront |
| `com.beyond.fortune.points300` | Consumable (legacy) | — | — | **Not shown** in paywall; restore-only (`legacyConsumableProductIds`) |
| `com.beyond.fortune.points600` | Consumable (legacy) | — | — | Restore-only |
| `com.beyond.fortune.points1200` | Consumable (legacy) | — | — | Restore-only |
| `com.beyond.fortune.points3000` | Consumable (legacy) | — | ₩22,000 | Restore-only |
| `com.beyond.fortune.subscription.monthly` | Auto-renewable subscription | 프로 구독 | ₩4,500/월 | `subscriptionPeriod: monthly` |
| `com.beyond.fortune.subscription.max` | Auto-renewable subscription | 맥스 구독 | ₩12,900/월 | Labeled `max`, badge "추천" |
| `com.beyond.fortune.premium_saju_lifetime` | Non-consumable | 상세 사주명리서 | ₩39,000 | 평생 소장 |

Guideline 3.1.1 check: all digital goods use IAP; no external payment link found in `premium-screen.tsx`. OK.

---

## 2. Guideline 3.1.2 metadata disclosure (paywall)

Audit vs `src/screens/premium-screen.tsx` before the purchase CTA:

| Required element | Present? | Evidence |
|---|---|---|
| Subscription title | YES | `getProductDisplayTitle` → "프로 구독" / "맥스 구독" rendered in `ProductOption` |
| Length of subscription | **PARTIAL** | `getSubscriptionPeriodLabel` returns "매월 결제" but is only shown in "선택된 상품" Chip (`selectedProductDeliveryLabel`) — the plan list just says `월 ₩4,500`, acceptable shorthand but worth double-check |
| Price per period | YES | `월 ${storePriceLabels[...] ?? formatPrice(price)}` in the list, plus `Chip label="가격 ..."` detail block |
| Auto-renewal disclosure | YES | Full Korean 3.1.2(b) boilerplate rendered **only when `selectedProduct.isSubscription`** (lines 386–396): "자동 갱신 구독입니다. 구독 기간 종료 최소 24시간 전에…" |
| Privacy Policy link (tappable) | YES | `Pressable` → `Linking.openURL('https://hayjukwfcsdmppairazc.supabase.co/functions/v1/legal-pages/privacy-policy')` |
| Terms of Use / EULA link (tappable) | YES | Same pattern → `.../terms-of-service` |
| Restore Purchases button | YES | Bottom of the "선택된 상품" card (`tone="secondary"`), plus a second entry point in `profile-screen.tsx` (`IconMenuTile` "구매 복원") |

Findings / risks:
- **T&C + Privacy only render for subscription selection.** If the reviewer lands on a token/lifetime product first, the subscription block is hidden. Apple's practice: the auto-renew disclosure + legal links must be visible **when a subscription is the purchase action**. Current behavior is compliant because links appear together with the 구독 CTA. Still, consider also exposing the links in `profile-screen.tsx` or a persistent footer to avoid reviewer ambiguity.
- Links go to `legal-pages` Supabase function — depends on that endpoint staying up during review. Verify 200 OK before submission.
- "Length of subscription" in the list row reads only "월 ₩4,500". Acceptable as abbreviation for monthly, but explicitly show "1개월 자동 갱신" if 3.1.2 rejection occurs.

---

## 3. Test checklist (sandbox + TestFlight)

Run on a real iOS device signed into a sandbox Apple ID (Settings → App Store → Sandbox Account).

- [ ] Cold-start → Chat home tab. **No "Sign in to Apple Account" prompt** (regression check for the P8 lazy StoreKit fix in `mobile-app-state-provider.tsx` L796–806).
- [ ] Navigate `/profile` → 구매 복원 tile shown; do **not** tap yet.
- [ ] Open `/premium` first time → Apple ID password/FaceID prompt (expected, StoreKit `initConnection` + `fetchProducts` fires here) → products render with live prices (`storePriceLabels`).
- [ ] Leave and re-enter `/premium` → products render immediately from cache; no prompt.
- [ ] Tap "이용약관" → Safari (or in-app browser) opens T&C page. Verify HTTP 200, Korean copy visible.
- [ ] Tap "개인정보처리방침" → same. Verify 200.
- [ ] Tap "구매 복원" (no prior purchases) → no crash; either empty restore or Apple ID prompt; restoreCount increments.
- [ ] Select `com.beyond.fortune.subscription.monthly` → verify auto-renew disclosure block is visible above CTA.
- [ ] Buy monthly subscription (sandbox) → payment sheet → confirm → `purchaseUpdatedListener` fires → `payment-verify-purchase` edge function validates receipt → `subscription-activate` activates → Chip turns "정기 결제 이용 중" + 만료일 표시.
- [ ] Cancel purchase mid-flow (sheet dismiss) → `purchaseErrorListener` → `isPurchasePending` resets to false → no stuck spinner.
- [ ] Airplane mode → open `/premium` → `storeStatus === 'error'` → "스토어 상품 정보를 불러오지 못했어요" toast.
- [ ] Airplane mode mid-purchase → listener queues purchase (`queuedPurchasesRef`) → reconnect → `useEffect` drains queue for signed-in session.
- [ ] Delete app → reinstall → sign in → tap 구매 복원 → `restoreStorePurchases` + `getAvailableStorePurchases` → subscription re-activates (`activateRemoteSubscription` server call).
- [ ] Buy `premium_saju_lifetime` (non-consumable) → reinstall → 복원 → lifetime badge returns (`applyProductPurchase`).
- [ ] Switch device region to EN/US sandbox account → prices render in USD from StoreKit (`displayPrice` falls back to `storePriceLabels`).
- [ ] Sign out of Supabase **during** payment sheet → purchase completes → listener enqueues to `queuedPurchasesRef` (no session) → re-login drains queue (see L832–840).

---

## 4. Happy-path IAP transaction sequence (traced)

```
premium-screen.handlePurchase()
  → purchaseProduct(sku)                               // mobile-app-state-provider L863
      → isStoreRuntimeAvailable check
      → session check
      → storeProductsRef lookup (else refreshStoreProducts)
      → setIsPurchasePending(true)
      → requestStorePurchase({ type: 'subs'|'in-app', request: { apple: { sku } } })
         // NOTE: andDangerouslyFinishTransactionAutomatically is NOT passed;
         // react-native-iap default = false on iOS, which is correct.
  → [iOS payment sheet]
  → purchaseUpdatedListener(purchase)                  // L755
      → isProductId guard
      → dedupe via processedPurchaseKeysRef
      → if !session → queue to queuedPurchasesRef and return
      → processQueuedPurchase(purchase, session)        // L673
          → getIosReceiptDataForVerification() (3 retries)
          → verifyRemotePurchase(session, {...})        // edge: payment-verify-purchase
          → if subscription: activateRemoteSubscription // edge: subscription-activate
          → if non-consumable: applyProductPurchase local state
          → finishStoreTransaction({ purchase, isConsumable })
          → syncRemoteProfile()                         // refresh premium chips
      → setIsPurchasePending(false)
```

Gaps / concerns flagged:
1. **Consumables never call `applyProductPurchase` locally.** In `processQueuedPurchase` (L710–721) the else-if only handles subscription + non-consumable. Token balance for consumables relies entirely on `syncRemoteProfile()` returning the updated balance after server credit. If `payment-verify-purchase` doesn't credit tokens atomically, the UI will show stale balance until next sync. Verify server side credits before `finishTransaction`.
2. **`finishStoreTransaction` runs only on success path.** If `verifyRemotePurchase` throws, the transaction stays in the StoreKit queue and `processedPurchaseKeysRef` is rolled back (L730). Good for retry, but a permanently failing receipt will re-fire on every app launch. Consider max-retry + surface to user.
3. **`activateRemoteSubscription` is called twice** in different paths: once in `processQueuedPurchase` (new purchase, uses `verification.transactionId`) and once in `restorePurchases` (uses `purchase.transactionId ?? purchase.id`). Server must be idempotent by `transactionId`.
4. **No `purchaseUpdatedListener` check for iOS sandbox vs prod receipts.** Edge function handles 21007/21008 fallback (`payment-verify-purchase/index.ts` L22–23). OK.
5. Restore path calls `restoreStorePurchases()` then `getAvailableStorePurchases({ onlyIncludeActiveItemsIOS: true })`. `true` excludes expired subs — correct for re-activation but means expired-then-resubscribe users won't surface their history. Acceptable.

---

## 5. Edge-case / static findings

- **Logout mid-purchase:** handled via `queuedPurchasesRef` drain effect (L832). Verify manually — the drain only runs when `session` transitions truthy and the map is non-empty; if user logs out and immediately kills the app, the queue is lost (in-memory Map, not persisted). Risk: unverified receipt on next launch relies on StoreKit's own unfinished-transaction replay. Acceptable given `finishTransaction` gating, but document.
- **Receipt validation is server-side:** YES — `payment-verify-purchase` hits Apple's `/verifyReceipt` with sandbox fallback. Receipt fetched via `getReceiptDataIOS()` + up to 3 `requestReceiptRefreshIOS()` retries (L269–298). Good.
- **Sandbox vs production switch:** server auto-retries on 21007 (sandbox receipt sent to prod) / 21008 (prod receipt sent to sandbox). Confirmed at `payment-verify-purchase/index.ts` L19–24.
- **Unhandled promise rejections:**
  - `handleRestore` in profile-screen: try/catch + Alert. OK.
  - `processQueuedPurchase`: try/catch + `captureError`. OK.
  - `purchaseErrorListener`: swallows unexpected errors via `captureError`. OK.
  - `endConnection()` on unmount: `.catch(() => undefined)` (L827). OK.
- **UI regressions to watch:**
  - `storeStatus === 'loading'` stays indefinitely if `initConnection` hangs — no timeout. Consider 10s timeout + error state.
  - "구독 상태 새로고침" button runs `Promise.all([syncRemoteProfile, refreshStoreProducts])`; if one fails the other result is discarded but captured. Fine.

---

## Go / no-go summary

| Gate | Status |
|---|---|
| 3.1.1 digital-goods routing via IAP | PASS |
| 3.1.2 paywall metadata (title, length, price, auto-renew, T&C, Privacy, Restore) | PASS — watch "length" abbreviation wording |
| Receipt validation server-side | PASS |
| Sandbox/prod fallback | PASS |
| Restore flow | PASS (subs + non-consumables) |
| Consumable token credit after purchase | NEEDS SERVER VERIFICATION (no local fallback) |
| Lazy StoreKit init on cold start | PASS (documented at L796–806) |
| Store loading timeout | MISSING — suggest adding |

Relevant files:
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/app/premium.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/premium-screen.tsx`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/screens/profile-screen.tsx` (L107, L309, L437)
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/providers/mobile-app-state-provider.tsx` (L624 refresh, L673 process, L742 listeners, L863 purchase, L938 restore)
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/src/lib/premium-remote.ts` (L257 verifyRemotePurchase, L296 activateRemoteSubscription)
- `/Users/injoo/Desktop/Dev/fortune/packages/product-contracts/src/products.ts`
- `/Users/injoo/Desktop/Dev/fortune/supabase/functions/payment-verify-purchase/index.ts`
- `/Users/injoo/Desktop/Dev/fortune/supabase/functions/subscription-activate/index.ts`
- `/Users/injoo/Desktop/Dev/fortune/apps/mobile-rn/appstore-metadata.md`
