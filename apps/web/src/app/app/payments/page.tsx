import type { Metadata } from 'next';
import Link from 'next/link';
import { redirect } from 'next/navigation';

import { createSupabaseServerClient } from '@/lib/supabase/server';

import { RefundRequestForm } from './refund-request-form';

export const metadata: Metadata = {
  title: '결제 내역',
  robots: { index: false, follow: false },
};

const STATUS_LABEL: Record<string, string> = {
  pending: '승인 대기',
  paid: '결제 완료',
  cancel_requested: '환불 검토 중',
  cancelled: '환불 완료',
  failed: '결제 실패',
};

export default async function PaymentsPage() {
  const supabase = await createSupabaseServerClient();
  if (!supabase) redirect('/auth/login?next=/app/payments');
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/auth/login?next=/app/payments');

  const [ordersResult, refundsResult] = await Promise.all([
    supabase
      .from('web_payment_orders')
      .select('order_id,order_name,amount,granted_tokens,status,created_at,paid_at')
      .order('created_at', { ascending: false })
      .limit(30),
    supabase
      .from('web_payment_refund_requests')
      .select('order_id,status,requested_at')
      .order('requested_at', { ascending: false })
      .limit(30),
  ]);

  const orders = ordersResult.data ?? [];
  const refundByOrder = new Map((refundsResult.data ?? []).map((item) => [item.order_id, item]));
  const sevenDays = 7 * 24 * 60 * 60 * 1000;

  return (
    <main className="ondo-shell ondo-account-page ondo-stack">
      <header className="ondo-stack">
        <p className="ondo-kicker">Payments</p>
        <h1>결제 내역</h1>
        <p className="ondo-muted">주문 승인, 온도 지급, 환불 요청 상태를 함께 확인하세요.</p>
      </header>

      {ordersResult.error || refundsResult.error ? (
        <p className="ondo-notice" role="alert">결제 내역을 불러오지 못했어요.</p>
      ) : orders.length === 0 ? (
        <div className="ondo-card ondo-stack">
          <h2>아직 웹 결제 내역이 없어요.</h2>
          <Link className="ondo-button" href="/app/charge">온도 충전 보기</Link>
        </div>
      ) : (
        <ol className="ondo-history-list">
          {orders.map((order) => {
            const refund = refundByOrder.get(order.order_id);
            const refundable = order.status === 'paid' && !refund && order.paid_at &&
              Date.now() - new Date(order.paid_at).getTime() <= sevenDays;
            return (
              <li className="ondo-card ondo-stack" key={order.order_id}>
                <div className="ondo-section-heading">
                  <div>
                    <p className="ondo-kicker">{new Date(order.created_at).toLocaleString('ko-KR')}</p>
                    <h2>{order.order_name}</h2>
                  </div>
                  <strong>{order.amount.toLocaleString('ko-KR')}원</strong>
                </div>
                <p className="ondo-muted">
                  {STATUS_LABEL[order.status] ?? '확인 중'} · 지급 {order.granted_tokens.toLocaleString('ko-KR')}온도
                </p>
                {refund ? <p className="ondo-notice">환불 요청 상태: {refund.status}</p> : null}
                {refundable ? <RefundRequestForm orderId={order.order_id} /> : null}
              </li>
            );
          })}
        </ol>
      )}

      <p className="ondo-muted">
        부분 환불이나 7일이 지난 주문은 <Link href="/support">고객 지원</Link>에서 법정 사유와 사용 내역을 확인해 주세요.
      </p>
    </main>
  );
}
