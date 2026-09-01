import type { Metadata } from 'next';
import { AppLink as Link } from '@/components/app-link';

import { tossClientKey } from '@/lib/env';
import { createSupabaseServerClient } from '@/lib/supabase/server';

import { ChargeClient } from './charge-client';
import { ChargeProductGrid } from './product-grid';

export const metadata: Metadata = {
  title: '온도 충전',
  description: '온도 웹 결제 상품과 운영 준비 상태를 확인합니다.',
  robots: { index: false, follow: false },
};

/**
 * 로그인 전에도 상품과 가격은 보여준다.
 *
 * 예전에는 세션이 없으면 로그인으로 돌려보내고, 익명이면 "Google 계정 연결"
 * 버튼만 띄웠다. 얼마인지 모르는 채로 계정부터 연결하라는 순서였다. 가격을
 * 먼저 보여주고 결제 직전에 로그인을 받는다. 결제 자체는 그대로 연결된
 * 계정에서만 받는다 — 익명 계정에 결제 기록이 묶이면 복구할 방법이 없다.
 */
function ConnectFirstNotice({ heading, body }: { heading: string; body: string }) {
  return (
    <div className="ondo-notice">
      <strong>{heading}</strong>
      <p>{body}</p>
      <Link className="ondo-button" href="/auth/login?next=%2Fapp%2Fcharge">
        Google 계정 연결
      </Link>
    </div>
  );
}

export default async function ChargePage() {
  const supabase = await createSupabaseServerClient();
  const user = supabase ? (await supabase.auth.getUser()).data.user : null;
  const canPay = Boolean(user) && !user?.is_anonymous;

  return (
    <main className="ondo-container ondo-account-page ondo-stack" style={{ gap: 24 }}>
      <header className="ondo-stack">
        <p className="ondo-kicker">Charge</p>
        <h1>온도 충전</h1>
        <p className="ondo-muted">결제 금액과 지급 온도는 서버에서 다시 확인한 뒤 한 번만 반영됩니다.</p>
      </header>

      {canPay && user ? (
        <ChargeClient
          clientKey={tossClientKey}
          customerKey={user.id}
          email={user.email ?? undefined}
        />
      ) : (
        <>
          <ChargeProductGrid
            action={() => (
              <Link className="ondo-button" href="/auth/login?next=%2Fapp%2Fcharge">
                결제하려면 로그인
              </Link>
            )}
          />
          {user ? (
            <ConnectFirstNotice
              body="결제 기록과 잔액을 안전하게 복구할 수 있도록 익명 계정에서는 결제를 받지 않습니다."
              heading="결제 전에 Google 계정을 연결해 주세요."
            />
          ) : (
            <ConnectFirstNotice
              body="충전한 온도가 어느 계정에 쌓일지 정해야 결제를 진행할 수 있어요."
              heading="결제는 Google 계정을 연결한 뒤에 진행돼요."
            />
          )}
        </>
      )}

      <p className="ondo-muted">
        결제·환불 문의는 <Link href="/support">고객 지원</Link>에서 접수할 수 있어요.
      </p>
    </main>
  );
}
