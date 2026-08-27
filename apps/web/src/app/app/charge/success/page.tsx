import type { Metadata } from 'next';
import { Suspense } from 'react';

import { PaymentSuccessClient } from './payment-success-client';

export const metadata: Metadata = {
  title: '결제 확인',
  robots: { index: false, follow: false },
};

export default function PaymentSuccessPage() {
  return (
    <main className="ondo-container ondo-status-page">
      <Suspense fallback={<p>결제 정보를 불러오고 있어요…</p>}>
        <PaymentSuccessClient />
      </Suspense>
    </main>
  );
}
