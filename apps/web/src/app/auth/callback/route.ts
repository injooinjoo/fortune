import { NextResponse, type NextRequest } from 'next/server';

import { sanitizeNextPath } from '@/lib/safe-path';
import { createSupabaseServerClient } from '@/lib/supabase/server';

/**
 * PKCE 콜백 — Supabase 가 붙여준 `?code=` 를 세션 쿠키로 교환한다.
 *
 * code verifier 는 `@supabase/ssr` 의 브라우저 클라이언트가 쿠키에 저장해서
 * 이 Route Handler 가 그대로 읽는다. Route Handler 는 Server Component 와 달리
 * 쿠키 쓰기가 허용되므로 여기서 세션이 실제로 심어진다.
 */
export async function GET(request: NextRequest): Promise<NextResponse> {
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get('code');
  const nextPath = sanitizeNextPath(searchParams.get('next'));

  const failTo = (reason: string) => {
    const loginUrl = new URL('/auth/login', origin);
    loginUrl.searchParams.set('error', reason);
    loginUrl.searchParams.set('next', nextPath);
    return NextResponse.redirect(loginUrl);
  };

  if (!code) return failTo('missing_code');

  const supabase = await createSupabaseServerClient();
  if (!supabase) return failTo('not_configured');

  const { error } = await supabase.auth.exchangeCodeForSession(code);
  if (error) return failTo('exchange_failed');

  const { error: bonusError } = await supabase.rpc('claim_account_upgrade_bonus');
  if (bonusError) return failTo('bonus_grant_failed');

  return NextResponse.redirect(`${origin}${nextPath}`);
}
