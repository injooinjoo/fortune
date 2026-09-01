'use client';

import Script from 'next/script';
import { useState } from 'react';

import { trackProductEvent } from '@/lib/analytics-client';
import { invokeEdgeFunction } from '@/lib/edge-invoke';
import { getBrowserSupabase } from '@/lib/supabase/client';

import { ChargeProductGrid } from './product-grid';

type TossPayment = {
  requestPayment(input: {
    method: 'CARD';
    amount: { currency: 'KRW'; value: number };
    orderId: string;
    orderName: string;
    successUrl: string;
    failUrl: string;
    customerEmail?: string;
    customerName: string;
  }): Promise<void>;
};

declare global {
  interface Window {
    TossPayments?: (clientKey: string) => {
      payment(input: { customerKey: string }): TossPayment;
    };
  }
}

type OrderResponse = {
  orderId: string;
  orderName: string;
  amount: number;
  productId: string;
  tokens: number;
};

export function ChargeClient({
  clientKey,
  customerKey,
  email,
}: {
  clientKey: string;
  customerKey: string;
  email?: string;
}) {
  const [sdkReady, setSdkReady] = useState(false);
  const [pendingProduct, setPendingProduct] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  async function startPayment(productId: string) {
    if (!clientKey || !window.TossPayments) {
      setError('웹 결제가 아직 준비되지 않았어요.');
      return;
    }
    const supabase = getBrowserSupabase();
    if (!supabase) {
      setError('로그인 정보를 확인하지 못했어요.');
      return;
    }

    setPendingProduct(productId);
    setError(null);
    trackProductEvent('payment_started', { product_id: productId });
    const order = await invokeEdgeFunction<OrderResponse>(
      supabase,
      'web-payment-create-order',
      { productId },
    );
    if (!order.ok) {
      setPendingProduct(null);
      setError(
        order.status === 503
          ? '웹 결제가 아직 준비되지 않았어요.'
          : '주문을 만들지 못했어요. 잠시 후 다시 시도해 주세요.',
      );
      return;
    }

    try {
      const payment = window.TossPayments(clientKey).payment({ customerKey });
      await payment.requestPayment({
        method: 'CARD',
        amount: { currency: 'KRW', value: order.data.amount },
        orderId: order.data.orderId,
        orderName: order.data.orderName,
        successUrl: `${window.location.origin}/app/charge/success`,
        failUrl: `${window.location.origin}/app/charge/fail`,
        customerEmail: email,
        customerName: '온도 사용자',
      });
    } catch {
      setPendingProduct(null);
      setError('결제창을 열지 못했어요. 다시 시도해 주세요.');
    }
  }

  return (
    <>
      {clientKey ? (
        <Script
          onLoad={() => setSdkReady(true)}
          src="https://js.tosspayments.com/v2/standard"
          strategy="afterInteractive"
        />
      ) : null}
      <ChargeProductGrid
        action={(productId) => (
          <button
            className="ondo-button"
            disabled={!clientKey || !sdkReady || pendingProduct !== null}
            onClick={() => void startPayment(productId)}
            type="button"
          >
            {pendingProduct === productId
              ? '결제 준비 중…'
              : clientKey
                ? '카드로 결제하기'
                : '웹 결제 준비 중'}
          </button>
        )}
      />
      {!clientKey ? (
        <div className="ondo-notice" role="status">
          <strong>웹 결제를 준비하고 있어요.</strong>
          <p>운영 결제키와 심사가 완료되기 전에는 주문이나 청구를 만들지 않습니다.</p>
        </div>
      ) : null}
      {error ? <p className="ondo-notice" role="alert">{error}</p> : null}
    </>
  );
}
