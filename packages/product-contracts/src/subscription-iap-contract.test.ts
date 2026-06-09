import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
  allProductIds,
  consumableProductIds,
  legacyConsumableProductIds,
  legacySubscriptionProductIds,
  productCatalog,
  subscriptionProductIds,
} from './products';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '../../..');

function readRepoFile(path: string): string {
  return readFileSync(resolve(repoRoot, path), 'utf8');
}

function extractNumberMap(source: string, constName: string): Record<string, number> {
  const start = source.indexOf(`const ${constName}`);
  expect(start, `${constName} must exist`).toBeGreaterThanOrEqual(0);
  const end = source.indexOf('};', start);
  expect(end, `${constName} object must end`).toBeGreaterThan(start);
  const block = source.slice(start, end);
  const entries: [string, number][] = [];
  const matcher = /"(com\.beyond\.fortune\.[^"]+)":\s*(\d+)/g;
  let match = matcher.exec(block);
  while (match) {
    entries.push([match[1], Number(match[2])]);
    match = matcher.exec(block);
  }
  return Object.fromEntries(entries);
}

function extractQuotedSet(source: string, constName: string): string[] {
  const start = source.indexOf(`const ${constName}`);
  expect(start, `${constName} must exist`).toBeGreaterThanOrEqual(0);
  const end = source.indexOf(']);', start);
  expect(end, `${constName} set must end`).toBeGreaterThan(start);
  const block = source.slice(start, end);
  const entries: string[] = [];
  const matcher = /"(com\.beyond\.fortune\.[^"]+)"/g;
  let match = matcher.exec(block);
  while (match) {
    entries.push(match[1]);
    match = matcher.exec(block);
  }
  return entries;
}

describe('subscription IAP monthly token contract', () => {
  const activationEligibleSubscriptionProductIds = [
    ...subscriptionProductIds,
    ...legacySubscriptionProductIds,
  ];

  it('keeps subscription monthly token allowances in sync with the product catalog', () => {
    const paymentFunction = readRepoFile('supabase/functions/payment-verify-purchase/index.ts');
    const tokenMap = extractNumberMap(paymentFunction, 'PRODUCT_TOKENS');

    for (const productId of activationEligibleSubscriptionProductIds) {
      expect(tokenMap[productId]).toBe(productCatalog[productId].points);
    }

    expect(paymentFunction).toContain('const isSubscriptionPurchase = SUBSCRIPTION_PRODUCT_IDS.has');
    expect(paymentFunction).toContain('? 0');
    expect(paymentFunction).toContain(': PRODUCT_TOKENS[verifiedProductId] || 0');
    expect(paymentFunction).toContain('subscriptionTokensPendingActivation');
  });

  it('keeps consumable token grants and allowed products in sync with the product catalog', () => {
    const paymentFunction = readRepoFile('supabase/functions/payment-verify-purchase/index.ts');
    const tokenMap = extractNumberMap(paymentFunction, 'PRODUCT_TOKENS');
    const allowedProductIds = extractQuotedSet(paymentFunction, 'ALLOWED_PRODUCT_IDS');

    for (const productId of [...consumableProductIds, ...legacyConsumableProductIds]) {
      expect(tokenMap[productId]).toBe(productCatalog[productId].points);
    }

    expect(new Set(allowedProductIds)).toEqual(new Set(allProductIds));
  });

  it('does not finish consumable purchases unless a server grant or safe replay is confirmed', () => {
    const paymentFunction = readRepoFile('supabase/functions/payment-verify-purchase/index.ts');
    const premiumRemote = readRepoFile('apps/mobile-rn/src/lib/premium-remote.ts');
    const provider = readRepoFile(
      'apps/mobile-rn/src/providers/mobile-app-state-provider.tsx',
    );
    const purchaseStart = provider.indexOf('const processQueuedPurchase = useCallback');
    const purchaseBlock = provider.slice(purchaseStart, provider.indexOf('useEffect(() => {', purchaseStart));

    expect(paymentFunction).toContain('Authentication required');
    expect(paymentFunction).toContain('!alreadyGranted &&\n      replayOwnedByCurrentUser');
    expect(paymentFunction).toContain('alreadyGranted && replayOwnedByCurrentUser');
    expect(paymentFunction).toContain('.from("token_balance")');
    expect(paymentFunction).toContain('balance: newBalance,');
    expect(premiumRemote).toContain('alreadyGranted: result.alreadyGranted === true');
    expect(premiumRemote).toContain('balance:');
    expect(purchaseBlock).toContain('if (isConsumableProductId(productId))');
    expect(purchaseBlock).toContain('verification.tokensAdded <= 0 && verification.balance == null');
    expect(purchaseBlock.indexOf('verification.tokensAdded <= 0')).toBeLessThan(
      purchaseBlock.indexOf('await finishStoreTransaction'),
    );
    expect(purchaseBlock).toContain('tokenBalance:');
    expect(purchaseBlock).toContain('verification.balance ??');
  });

  it('uses one server-side RPC to atomically activate subscriptions and grant monthly tokens', () => {
    const activationFunction = readRepoFile('supabase/functions/subscription-activate/index.ts');
    const migration = readRepoFile(
      'supabase/migrations/20260606125000_subscription_activation_idempotency.sql',
    );

    for (const productId of activationEligibleSubscriptionProductIds) {
      expect(activationFunction).toContain(`"${productId}"`);
      expect(activationFunction).toContain(`monthlyTokens: ${productCatalog[productId].points}`);
    }

    expect(activationFunction).not.toContain('com.beyond.fortune.subscription.yearly');
    expect(activationFunction).toContain('activate_subscription_purchase_atomic');
    expect(migration).toContain('idx_subscriptions_platform_purchase_id');
    expect(migration).toContain('FOR UPDATE');
    expect(migration).toContain("'subscription_renewal'");
    expect(migration).toContain('consumed_for_subscription = true');
    expect(migration).toContain('consumed_for_token_grant = true');
  });

  it('describes subscriptions as token allowances, not unlimited usage', () => {
    for (const productId of activationEligibleSubscriptionProductIds) {
      expect(productCatalog[productId].description).not.toContain('무제한');
      expect(productCatalog[productId].description).toContain('토큰');
    }
  });

  it('reports token balance as finite even when a subscription is active', () => {
    const tokenBalanceFunction = readRepoFile('supabase/functions/token-balance/index.ts');

    expect(tokenBalanceFunction).not.toContain('const isUnlimited = !!subscription');
    expect(tokenBalanceFunction).toContain('isUnlimited: false');
  });

  it('does not bypass token consumption for active subscriptions', () => {
    const soulConsumeFunction = readRepoFile('supabase/functions/soul-consume/index.ts');
    const tokenChargeHelper = readRepoFile('supabase/functions/_shared/token_charge.ts');
    const edgeAuthHelper = readRepoFile('supabase/functions/_shared/auth.ts');
    const soulRefundFunction = readRepoFile('supabase/functions/soul-refund/index.ts');

    expect(soulConsumeFunction).toContain('consume_token_atomic');
    expect(soulConsumeFunction).not.toContain('Unlimited access');
    expect(soulConsumeFunction).not.toContain('hasUnlimitedAccess: true');
    expect(soulConsumeFunction).not.toContain('no token consumption');
    expect(tokenChargeHelper).toContain('consume_token_atomic');
    expect(tokenChargeHelper).not.toContain('hasUnlimitedSubscription');
    expect(edgeAuthHelper).not.toContain('Infinity');
    expect(edgeAuthHelper).not.toContain('isUnlimited: true');
    expect(soulRefundFunction).not.toContain('Subscriber — no refund needed');
    expect(soulRefundFunction).not.toContain('hasUnlimitedAccess: true');
  });

  it('server-verifies restored subscriptions before activating them', () => {
    const provider = readRepoFile(
      'apps/mobile-rn/src/providers/mobile-app-state-provider.tsx',
    );
    const restoreStart = provider.indexOf('const restorePurchases = useCallback');
    const restoreBlock = provider.slice(restoreStart, provider.indexOf('const value = useMemo', restoreStart));

    expect(restoreBlock).toContain('const verification = await verifyRemotePurchase');
    expect(restoreBlock).toContain('await activateRemoteSubscription');
    expect(restoreBlock.indexOf('const verification = await verifyRemotePurchase')).toBeLessThan(
      restoreBlock.indexOf('await activateRemoteSubscription'),
    );
    expect(restoreBlock).toContain('productId: verification.productId');
    expect(restoreBlock).toContain('purchaseId: verifiedTransactionId');
  });
});
