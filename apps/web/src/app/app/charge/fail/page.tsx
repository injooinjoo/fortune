import type { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  title: '결제 미완료',
  robots: { index: false, follow: false },
};

export default async function PaymentFailPage({
  searchParams,
}: {
  searchParams: Promise<{ code?: string }>;
}) {
  const { code } = await searchParams;
  const safeCode = code && /^[A-Z0-9_]{1,80}$/.test(code) ? code : null;

  return (
    <main className="ondo-container ondo-status-page">
      <p className="ondo-kicker">Payment</p>
      <h1>결제가 완료되지 않았어요.</h1>
      <p className="ondo-muted">승인되지 않은 주문에는 온도가 지급되지 않습니다.</p>
      {safeCode ? <p className="ondo-muted">오류 코드: {safeCode}</p> : null}
      <div className="ondo-account-actions">
        <Link className="ondo-button" href="/app/charge">다시 결제하기</Link>
        <Link href="/support">고객 지원</Link>
      </div>
    </main>
  );
}
