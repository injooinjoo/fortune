'use client';

import { useState } from 'react';

import { getBrowserSupabase } from '@/lib/supabase/client';

export function SignOutButton() {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');

  async function signOut() {
    setBusy(true);
    setError('');
    const supabase = getBrowserSupabase();
    if (!supabase) {
      setError('로그아웃을 준비하지 못했어요. 잠시 후 다시 시도해 주세요.');
      setBusy(false);
      return;
    }

    const result = await supabase.auth.signOut();
    if (result.error) {
      setError('로그아웃하지 못했어요. 잠시 후 다시 시도해 주세요.');
      setBusy(false);
      return;
    }
    window.location.assign('/');
  }

  return (
    <div className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
      <button className="ondo-button ondo-button--secondary" disabled={busy} onClick={signOut} type="button">
        {busy ? '로그아웃 중…' : '로그아웃'}
      </button>
      {error ? <p className="ondo-notice ondo-notice--error" role="alert">{error}</p> : null}
    </div>
  );
}
