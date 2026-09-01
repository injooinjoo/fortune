'use client';

import { AppLink as Link } from '@/components/app-link';
import { useEffect, useState } from 'react';

import { getBrowserSupabase } from '@/lib/supabase/client';

type AccountState =
  | { kind: 'loading' }
  | { kind: 'guest' }
  | { kind: 'account'; balance: number };

/**
 * 헤더 오른쪽의 계정 영역.
 *
 * 익명(게스트) 세션도 온도를 쓰고 잔액을 가진다. 예전에는 익명을 'guest' 로 묶어
 * 헤더에 "로그인"만 띄웠는데, 그 결과 `/app` 본문은 "로그아웃"을 보여주는데
 * 헤더는 "로그인"을 보여주는 모순이 생겼고, 정작 온도를 쓰는 사람에게 잔액이
 * 아무 화면에도 안 보였다. 세션이 있으면 잔액을 보여준다.
 */
export function AccountHeaderActions({ mobile = false }: { mobile?: boolean }) {
  const [state, setState] = useState<AccountState>({ kind: 'loading' });

  useEffect(() => {
    let active = true;
    const supabase = getBrowserSupabase();
    if (!supabase) {
      setState({ kind: 'guest' });
      return;
    }
    const client = supabase;

    async function refresh() {
      const { data } = await client.auth.getUser();
      if (!active) return;
      if (!data.user) {
        setState({ kind: 'guest' });
        return;
      }

      const { data: balance } = await client
        .from('token_balance')
        .select('balance')
        .eq('user_id', data.user.id)
        .maybeSingle();
      if (!active) return;
      setState({
        kind: 'account',
        balance: typeof balance?.balance === 'number' ? Math.max(0, balance.balance) : 0,
      });
    }

    void refresh();
    const { data: subscription } = client.auth.onAuthStateChange(() => void refresh());
    return () => {
      active = false;
      subscription.subscription.unsubscribe();
    };
  }, []);

  if (state.kind === 'account') {
    return (
      <Link className={mobile ? undefined : 'ondo-login-link'} href="/app">
        내 온도 {state.balance}개
      </Link>
    );
  }

  return (
    <Link
      aria-busy={state.kind === 'loading'}
      className={mobile ? undefined : 'ondo-login-link'}
      href="/auth/login"
    >
      {state.kind === 'loading' ? '계정 확인 중' : '로그인'}
    </Link>
  );
}
