export type AppleReceiptLineItem = {
  product_id?: string;
  transaction_id?: string;
  original_transaction_id?: string;
  purchase_date_ms?: string;
};

export function selectAppleReceiptLineItem(
  validationResult: {
    latest_receipt_info?: AppleReceiptLineItem[];
    receipt?: { in_app?: AppleReceiptLineItem[] };
  },
  requestedProductId: string,
  requestedTransactionId?: string | null,
): AppleReceiptLineItem | null {
  const allItems = [
    ...(validationResult.latest_receipt_info ?? []),
    ...(validationResult.receipt?.in_app ?? []),
  ].filter((item): item is AppleReceiptLineItem => !!item);

  const matchingItems = allItems.filter((item) => {
    if (item.product_id !== requestedProductId) {
      return false;
    }

    if (!requestedTransactionId) {
      return true;
    }

    return item.transaction_id === requestedTransactionId ||
      item.original_transaction_id === requestedTransactionId;
  });

  matchingItems.sort((a, b) => {
    const aDate = Number(a.purchase_date_ms ?? 0);
    const bDate = Number(b.purchase_date_ms ?? 0);
    return bDate - aDate;
  });

  return matchingItems[0] ?? null;
}

export type TokenGrantDecisionInput = {
  verifiedPurchaseUserId: string | null;
  consumedForTokenGrant: boolean | null;
  tokenTransactionUserId: string | null;
  currentUserId: string;
};

export type TokenGrantDecision = {
  shouldGrantTokens: boolean;
  alreadyGranted: boolean;
  replayOwnedByCurrentUser: boolean;
  tokensAddedForResponse: (baseTokens: number) => number;
};

export function resolveTokenGrantDecision(
  input: TokenGrantDecisionInput,
): TokenGrantDecision {
  const purchaseOwnerId = input.tokenTransactionUserId ?? input.verifiedPurchaseUserId;
  const replayOwnedByCurrentUser = !purchaseOwnerId || purchaseOwnerId === input.currentUserId;
  const hasTokenGrant = input.tokenTransactionUserId !== null || input.consumedForTokenGrant === true;
  const alreadyGranted = hasTokenGrant;

  return {
    shouldGrantTokens: replayOwnedByCurrentUser && !hasTokenGrant,
    alreadyGranted,
    replayOwnedByCurrentUser,
    tokensAddedForResponse: () => 0,
  };
}
