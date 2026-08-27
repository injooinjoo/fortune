import {
  assertEquals,
  assertThrows,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

import {
  getWebPaymentProduct,
  validateConfirmRequest,
  validateConfirmedPayment,
} from "./web_payment_core.ts";

Deno.test("serves only the four consumable web packs", () => {
  assertEquals(getWebPaymentProduct("com.beyond.fortune.tokens.starter"), {
    id: "com.beyond.fortune.tokens.starter",
    name: "30온도",
    amount: 1100,
    tokens: 30,
  });
  assertThrows(() => getWebPaymentProduct("com.beyond.fortune.subscription.pro"));
});

const ORDER_ID = "ondo_11111111-1111-4111-8111-111111111111";

Deno.test("validates the browser success payload without trusting its amount", () => {
  assertEquals(
    validateConfirmRequest({ paymentKey: "pay_123", orderId: ORDER_ID, amount: 4400 }),
    { paymentKey: "pay_123", orderId: ORDER_ID, amount: 4400 },
  );
  assertThrows(() => validateConfirmRequest({ paymentKey: "pay_123", orderId: ORDER_ID, amount: -1 }));
});

Deno.test("accepts only a matching DONE response from Toss", () => {
  const result = validateConfirmedPayment(
    {
      paymentKey: "pay_123",
      orderId: ORDER_ID,
      totalAmount: 4400,
      status: "DONE",
      method: "카드",
      approvedAt: "2026-08-27T00:00:00+09:00",
    },
    { paymentKey: "pay_123", orderId: ORDER_ID, amount: 4400 },
  );
  assertEquals(result.method, "카드");
  assertThrows(() => validateConfirmedPayment(
    { paymentKey: "other", orderId: ORDER_ID, totalAmount: 4400, status: "DONE" },
    { paymentKey: "pay_123", orderId: ORDER_ID, amount: 4400 },
  ));
});
