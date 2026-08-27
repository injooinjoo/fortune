'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';

import { getBrowserSupabase } from '@/lib/supabase/client';

type AccountState =
  | { kind: 'loading' }
  | { kind: 'guest' }
  | { kind: 'account'; balance: number };

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
      if (!data.user || data.user.is_anonymous) {
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
