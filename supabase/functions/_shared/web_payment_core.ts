export interface WebPaymentProduct {
  id: string;
  name: string;
  amount: number;
  tokens: number;
}

const WEB_PAYMENT_PRODUCTS: Record<string, WebPaymentProduct> = {
  "com.beyond.fortune.tokens.starter": {
    id: "com.beyond.fortune.tokens.starter",
    name: "30온도",
    amount: 1100,
    tokens: 30,
  },
  "com.beyond.fortune.tokens.basic": {
    id: "com.beyond.fortune.tokens.basic",
    name: "150온도",
    amount: 4400,
    tokens: 150,
  },
  "com.beyond.fortune.tokens.popular": {
    id: "com.beyond.fortune.tokens.popular",
    name: "400온도",
    amount: 9900,
    tokens: 400,
  },
  "com.beyond.fortune.tokens.heavy": {
    id: "com.beyond.fortune.tokens.heavy",
    name: "1000온도",
    amount: 22000,
    tokens: 1000,
  },
};

export function getWebPaymentProduct(productId: unknown): WebPaymentProduct {
  if (typeof productId !== "string" || !(productId in WEB_PAYMENT_PRODUCTS)) {
    throw new TypeError("unsupported web payment product");
  }
  return WEB_PAYMENT_PRODUCTS[productId];
}

export interface ConfirmRequest {
  paymentKey: string;
  orderId: string;
  amount: number;
}

export function validateConfirmRequest(input: unknown): ConfirmRequest {
  if (input === null || typeof input !== "object") {
    throw new TypeError("invalid confirmation request");
  }
  const record = input as Record<string, unknown>;
  if (
    typeof record.paymentKey !== "string" ||
    record.paymentKey.length < 1 ||
    record.paymentKey.length > 200 ||
    typeof record.orderId !== "string" ||
    !/^ondo_[0-9a-f-]{36}$/.test(record.orderId) ||
    !Number.isSafeInteger(record.amount) ||
    Number(record.amount) <= 0
  ) {
    throw new TypeError("invalid confirmation request");
  }
  return {
    paymentKey: record.paymentKey,
    orderId: record.orderId,
    amount: Number(record.amount),
  };
}

export interface ConfirmedPayment {
  paymentKey: string;
  orderId: string;
  totalAmount: number;
  status: "DONE";
  method: string | null;
  approvedAt: string | null;
  transactionKey: string | null;
}

export function validateConfirmedPayment(
  input: unknown,
  expected: ConfirmRequest,
): ConfirmedPayment {
  if (input === null || typeof input !== "object") {
    throw new TypeError("invalid Toss payment response");
  }
  const record = input as Record<string, unknown>;
  if (
    record.paymentKey !== expected.paymentKey ||
    record.orderId !== expected.orderId ||
    record.totalAmount !== expected.amount ||
    record.status !== "DONE"
  ) {
    throw new TypeError("Toss payment response mismatch");
  }
  return {
    paymentKey: expected.paymentKey,
    orderId: expected.orderId,
    totalAmount: expected.amount,
    status: "DONE",
    method: typeof record.method === "string" ? record.method : null,
    approvedAt: typeof record.approvedAt === "string" ? record.approvedAt : null,
    transactionKey: typeof record.lastTransactionKey === "string"
      ? record.lastTransactionKey
      : null,
  };
}
