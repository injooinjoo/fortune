'use client';

import { useState } from 'react';

import { beginGoogleAuth } from '@/lib/google-auth';
import { trackProductEvent } from '@/lib/analytics-client';
import { getBrowserSupabase } from '@/lib/supabase/client';

/**
 * 웹 로그인은 Google 하나만 쓴다.
 *
 * 이메일 매직링크를 뺀 이유는 취향이 아니라 실제로 안 됐기 때문이다. 웹에서
 * 메일을 보내면 Supabase 가 `emailRedirectTo` 를 무시하고
 * `redirect_to=com.beyond.fortune://auth-callback` 으로 링크를 만들어 보냈다.
 * 웹 주소가 Redirect URLs 허용목록에 없어서 모바일 앱 커스텀 스킴으로 폴백한
 * 것이고, 브라우저에서 그 링크를 눌러도 아무 일도 일어나지 않는다.
 *
 * OAuth 는 Supabase 가 자기 콜백(`/auth/v1/callback`)으로 먼저 받은 뒤
 * `redirectTo` 로 돌려주는 구조라 경로가 하나뿐이고, 우리 `/auth/callback`
 * Route Handler 가 이미 PKCE `?code=` 를 세션 쿠키로 교환하고 있다.
 *
 * 단, `redirectTo` 도 허용목록에 있어야 한다 — Supabase 대시보드
 * Authentication → URL Configuration → Redirect URLs 에
 * `https://zpzg.co.kr/**` 가 필요하다.
 */

type Status =
  | { kind: 'idle' }
  | { kind: 'redirecting' }
  | { kind: 'error'; message: string };

const CALLBACK_ERRORS: Record<string, string> = {
  missing_code: '로그인이 완료되지 않았어요. 다시 시도해 주세요.',
  not_configured: '로그인 설정이 아직 준비되지 않았어요.',
  exchange_failed: '로그인 정보가 만료됐어요. 다시 시도해 주세요.',
  bonus_grant_failed: '로그인은 됐지만 온도 지급을 확인하지 못했어요. 다시 시도해 주세요.',
};

/** Google 브랜드 가이드상 로고는 원본 색을 유지해야 해서 여기만 고정 색을 쓴다. */
function GoogleMark() {
  return (
    <svg aria-hidden="true" height="18" viewBox="0 0 48 48" width="18">
      <path
        d="M45.12 24.5c0-1.56-.14-3.06-.4-4.5H24v8.51h11.84c-.51 2.75-2.06 5.08-4.39 6.64v5.52h7.11c4.16-3.83 6.56-9.47 6.56-16.17z"
        fill="#4285F4"
      />
      <path
        d="M24 46c5.94 0 10.92-1.97 14.56-5.33l-7.11-5.52c-1.97 1.32-4.49 2.1-7.45 2.1-5.73 0-10.58-3.87-12.31-9.07H4.34v5.7C7.96 41.07 15.4 46 24 46z"
        fill="#34A853"
      />
      <path
        d="M11.69 28.18C11.25 26.86 11 25.45 11 24s.25-2.86.69-4.18v-5.7H4.34C2.85 17.09 2 20.45 2 24s.85 6.91 2.34 9.88l7.35-5.7z"
        fill="#FBBC05"
      />
      <path
        d="M24 10.75c3.23 0 6.13 1.11 8.41 3.29l6.31-6.31C34.91 4.18 29.93 2 24 2 15.4 2 7.96 6.93 4.34 14.12l7.35 5.7c1.73-5.2 6.58-9.07 12.31-9.07z"
        fill="#EA4335"
      />
    </svg>
  );
}

export function LoginForm({
  nextPath,
  callbackError,
}: {
  nextPath: string;
  callbackError: string | null;
}) {
  const [status, setStatus] = useState<Status>({ kind: 'idle' });

  async function handleGoogle() {
    const supabase = getBrowserSupabase();
    if (!supabase) {
      setStatus({ kind: 'error', message: '로그인 설정이 아직 준비되지 않았어요.' });
      return;
    }

    setStatus({ kind: 'redirecting' });
    trackProductEvent('auth_started', { provider: 'google' });

    const { error } = await beginGoogleAuth(
      supabase,
      `${window.location.origin}/auth/callback?next=${encodeURIComponent(nextPath)}`,
    );

    // 성공하면 브라우저가 Google 로 떠나므로 여기 아래는 실패했을 때만 실행된다.
    if (error) {
      setStatus({ kind: 'error', message: error.message });
    }
  }

  const errorMessage =
    status.kind === 'error'
      ? status.message
      : callbackError
        ? (CALLBACK_ERRORS[callbackError] ?? '로그인에 실패했어요. 다시 시도해 주세요.')
        : null;

  return (
    <div className="ondo-stack">
      <button
        className="ondo-button"
        disabled={status.kind === 'redirecting'}
        onClick={handleGoogle}
        style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 'var(--ondo-spacing-xs)' }}
        type="button"
      >
        <GoogleMark />
        {status.kind === 'redirecting' ? 'Google로 이동 중…' : 'Google로 계속하기'}
      </button>

      <p className="ondo-muted">
        로그인하지 않아도 운세는 바로 볼 수 있어요. Google 계정으로 연결하면 기존 기록을 유지하고 온도 50개로 시작해요.
      </p>

      {errorMessage ? (
        <p className="ondo-notice" role="alert">
          {errorMessage}
        </p>
      ) : null}
    </div>
  );
}
