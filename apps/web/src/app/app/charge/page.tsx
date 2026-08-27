import type { Metadata } from 'next';
import Link from 'next/link';
import { redirect } from 'next/navigation';

import { tossClientKey } from '@/lib/env';
import { createSupabaseServerClient } from '@/lib/supabase/server';

import { ChargeClient } from './charge-client';

export const metadata: Metadata = {
  title: '온도 충전',
  description: '온도 웹 결제 상품과 운영 준비 상태를 확인합니다.',
  robots: { index: false, follow: false },
};

export default async function ChargePage() {
  const supabase = await createSupabaseServerClient();
  if (!supabase) redirect('/auth/login?next=/app/charge');
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/auth/login?next=/app/charge');

  return (
    <main className="ondo-container ondo-account-page ondo-stack" style={{ gap: 24 }}>
      <header className="ondo-stack">
        <p className="ondo-kicker">Charge</p>
        <h1>온도 충전</h1>
        <p className="ondo-muted">결제 금액과 지급 온도는 서버에서 다시 확인한 뒤 한 번만 반영됩니다.</p>
      </header>

      {user.is_anonymous ? (
        <div className="ondo-notice">
          <strong>결제 전에 Google 계정을 연결해 주세요.</strong>
          <p>결제 기록과 잔액을 안전하게 복구할 수 있도록 익명 계정에서는 결제를 받지 않습니다.</p>
          <Link className="ondo-button" href="/auth/login?next=/app/charge">Google 계정 연결</Link>
        </div>
      ) : (
        <ChargeClient
          clientKey={tossClientKey}
          customerKey={user.id}
          email={user.email ?? undefined}
        />
      )}

      <p className="ondo-muted">
        결제·환불 문의는 <Link href="/support">고객 지원</Link>에서 접수할 수 있어요.
      </p>
    </main>
  );
}
