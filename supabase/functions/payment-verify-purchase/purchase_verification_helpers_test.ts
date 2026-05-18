import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";

import {
  resolveTokenGrantDecision,
  selectAppleReceiptLineItem,
} from "./purchase_verification_helpers.ts";

Deno.test("selectAppleReceiptLineItem binds Apple receipt to requested product and transaction", () => {
  const selected = selectAppleReceiptLineItem(
    {
      latest_receipt_info: [
        {
          product_id: "com.beyond.fortune.tokens.starter",
          transaction_id: "txn-old",
          purchase_date_ms: "1000",
        },
        {
          product_id: "com.beyond.fortune.tokens.popular",
          transaction_id: "txn-new",
          purchase_date_ms: "2000",
        },
      ],
      receipt: {
        in_app: [
          {
            product_id: "com.beyond.fortune.tokens.popular",
            transaction_id: "txn-fallback",
            purchase_date_ms: "1500",
          },
        ],
      },
    },
    "com.beyond.fortune.tokens.popular",
    "txn-new",
  );

  assertEquals(selected?.transaction_id, "txn-new");
});

Deno.test("resolveTokenGrantDecision retries token grant when verification row exists but token grant is not consumed", () => {
  const decision = resolveTokenGrantDecision({
    verifiedPurchaseUserId: "user-1",
    consumedForTokenGrant: false,
    tokenTransactionUserId: null,
    currentUserId: "user-1",
  });

  assertEquals(decision.shouldGrantTokens, true);
  assertEquals(decision.alreadyGranted, false);
  assertEquals(decision.replayOwnedByCurrentUser, true);
  assertEquals(decision.tokensAddedForResponse(30), 0);
});

Deno.test("resolveTokenGrantDecision treats existing token transaction as same-user idempotent replay", () => {
  const decision = resolveTokenGrantDecision({
    verifiedPurchaseUserId: "user-1",
    consumedForTokenGrant: true,
    tokenTransactionUserId: "user-1",
    currentUserId: "user-1",
  });

  assertEquals(decision.shouldGrantTokens, false);
  assertEquals(decision.alreadyGranted, true);
  assertEquals(decision.replayOwnedByCurrentUser, true);
  assertEquals(decision.tokensAddedForResponse(30), 0);
});

Deno.test("resolveTokenGrantDecision blocks another account replay", () => {
  const decision = resolveTokenGrantDecision({
    verifiedPurchaseUserId: "user-2",
    consumedForTokenGrant: true,
    tokenTransactionUserId: "user-2",
    currentUserId: "user-1",
  });

  assertEquals(decision.shouldGrantTokens, false);
  assertEquals(decision.alreadyGranted, true);
  assertEquals(decision.replayOwnedByCurrentUser, false);
  assertEquals(decision.tokensAddedForResponse(30), 0);
});
