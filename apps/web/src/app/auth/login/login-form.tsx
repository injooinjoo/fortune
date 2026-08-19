'use client';

import { useState, type FormEvent } from 'react';

import { siteUrl } from '@/lib/env';
import { getBrowserSupabase } from '@/lib/supabase/client';

type Status =
  | { kind: 'idle' }
  | { kind: 'sending' }
  | { kind: 'sent'; email: string }
  | { kind: 'error'; message: string };

const CALLBACK_ERRORS: Record<string, string> = {
  missing_code: '로그인 링크가 올바르지 않아요. 다시 시도해 주세요.',
  not_configured: '로그인 설정이 아직 준비되지 않았어요.',
  exchange_failed: '로그인 링크가 만료됐어요. 새 링크를 받아주세요.',
};

export function LoginForm({
  nextPath,
  callbackError,
}: {
  nextPath: string;
  callbackError: string | null;
}) {
  const [email, setEmail] = useState('');
  const [status, setStatus] = useState<Status>({ kind: 'idle' });

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const supabase = getBrowserSupabase();
    if (!supabase) {
      setStatus({ kind: 'error', message: '로그인 설정이 아직 준비되지 않았어요.' });
      return;
    }

    setStatus({ kind: 'sending' });

    const { error } = await supabase.auth.signInWithOtp({
      email,
      options: {
        emailRedirectTo: `${siteUrl}/auth/callback?next=${encodeURIComponent(nextPath)}`,
      },
    });

    if (error) {
      setStatus({ kind: 'error', message: error.message });
      return;
    }

    setStatus({ kind: 'sent', email });
  }

  if (status.kind === 'sent') {
    return (
      <div className="ondo-notice ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }} role="status">
        <p className="ondo-h3">메일함을 확인해 주세요</p>
        <p className="ondo-muted">
          {status.email} 으로 로그인 링크를 보냈어요. 링크를 열면 이 브라우저로 돌아옵니다.
        </p>
      </div>
    );
  }

  return (
    <form className="ondo-stack" onSubmit={handleSubmit}>
      {callbackError ? (
        <p className="ondo-notice ondo-notice--error" role="alert">
          {CALLBACK_ERRORS[callbackError] ?? '로그인에 실패했어요. 다시 시도해 주세요.'}
        </p>
      ) : null}

      <div>
        <label className="ondo-label" htmlFor="login-email">
          이메일 주소
        </label>
        <input
          autoComplete="email"
          className="ondo-input"
          id="login-email"
          name="email"
          onChange={(event) => setEmail(event.target.value)}
          placeholder="you@example.com"
          required
          type="email"
          value={email}
        />
      </div>

      {status.kind === 'error' ? (
        <p className="ondo-notice ondo-notice--error" role="alert">
          {status.message}
        </p>
      ) : null}

      <button className="ondo-button" disabled={status.kind === 'sending'} type="submit">
        {status.kind === 'sending' ? '보내는 중…' : '로그인 링크 받기'}
      </button>
    </form>
  );
}
