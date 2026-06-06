import { describe, expect, it } from 'vitest';
import { readFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

import {
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
