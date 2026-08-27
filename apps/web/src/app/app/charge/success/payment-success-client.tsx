'use client';

import { AppLink as Link } from '@/components/app-link';
import { useSearchParams } from 'next/navigation';
import { useEffect, useRef, useState } from 'react';

import { trackProductEvent } from '@/lib/analytics-client';
import { invokeEdgeFunction } from '@/lib/edge-invoke';
import { getBrowserSupabase } from '@/lib/supabase/client';

type ConfirmResponse = {
  paid: boolean;
  replayed: boolean;
  orderId: string;
  grantedTokens: number;
  balance: number;
};

type State =
  | { kind: 'confirming' }
  | { kind: 'success'; grantedTokens: number; balance: number }
  | { kind: 'error'; message: string };

export function PaymentSuccessClient() {
  const searchParams = useSearchParams();
  const started = useRef(false);
  const [state, setState] = useState<State>({ kind: 'confirming' });

  useEffect(() => {
    if (started.current) return;
    started.current = true;

    const paymentKey = searchParams.get('paymentKey') ?? '';
    const orderId = searchParams.get('orderId') ?? '';
    const amount = Number(searchParams.get('amount'));
    if (!paymentKey || !/^ondo_[0-9a-f-]{36}$/.test(orderId) || !Number.isSafeInteger(amount) || amount <= 0) {
      setState({ kind: 'error', message: '결제 승인 정보가 올바르지 않아요.' });
      return;
    }

    const supabase = getBrowserSupabase();
    if (!supabase) {
      setState({ kind: 'error', message: '로그인 정보를 확인하지 못했어요.' });
      return;
    }

    void (async () => {
      const result = await invokeEdgeFunction<ConfirmResponse>(
        supabase,
        'web-payment-confirm',
        { paymentKey, orderId, amount },
      );
      if (!result.ok) {
        trackProductEvent('payment_completed', { outcome: 'error', error_kind: 'confirmation' });
        setState({
          kind: 'error',
          message: result.status === 503
            ? '웹 결제 승인이 아직 준비되지 않았어요. 결제되지 않았다면 다시 시도해 주세요.'
            : '결제 확인을 마치지 못했어요. 다시 시도하거나 고객 지원에 문의해 주세요.',
        });
        return;
      }
      if (!result.data.paid) {
        trackProductEvent('payment_completed', { outcome: 'error', error_kind: 'ledger' });
        setState({ kind: 'error', message: '결제 원장 반영을 확인하지 못했어요. 고객 지원에 문의해 주세요.' });
        return;
      }
      trackProductEvent('payment_completed', { outcome: 'success' });
      setState({
        kind: 'success',
        grantedTokens: result.data.grantedTokens,
        balance: result.data.balance,
      });
    })();
  }, [searchParams]);

  if (state.kind === 'confirming') {
    return <p aria-live="polite">결제를 확인하고 온도를 반영하고 있어요…</p>;
  }
  if (state.kind === 'error') {
    return (
      <div className="ondo-stack">
        <p className="ondo-notice" role="alert">{state.message}</p>
        <button className="ondo-button" onClick={() => window.location.reload()} type="button">결제 다시 확인</button>
        <Link href="/support">고객 지원</Link>
      </div>
    );
  }
  return (
    <div className="ondo-stack" aria-live="polite">
      <h1>충전이 완료됐어요.</h1>
      <p>{state.grantedTokens.toLocaleString('ko-KR')}온도를 반영했어요.</p>
      <p className="ondo-muted">현재 잔액 {state.balance.toLocaleString('ko-KR')}온도</p>
      <Link className="ondo-button" href="/app">내 온도 보기</Link>
    </div>
  );
}
