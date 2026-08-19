import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

import { isSupabaseConfigured, supabaseAnonKey, supabaseUrl } from '@/lib/env';

/**
 * 세션 refresh 전용.
 *
 * 인가(authorization) 판단은 여기서 하지 않는다. 미들웨어는 서명 검증 없이
 * 쿠키를 읽는 자리라 접근 제어의 근거가 될 수 없다 — 게이트는
 * `app/app/layout.tsx` 의 `supabase.auth.getUser()` 가 담당한다.
 */
export async function updateSession(request: NextRequest): Promise<NextResponse> {
  let response = NextResponse.next({ request });

  if (!isSupabaseConfigured) return response;

  const supabase = createServerClient(supabaseUrl, supabaseAnonKey, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        for (const { name, value } of cookiesToSet) {
          request.cookies.set(name, value);
        }
        response = NextResponse.next({ request });
        for (const { name, value, options } of cookiesToSet) {
          response.cookies.set(name, value, options);
        }
      },
    },
  });

  // 반환값을 쓰지 않는 것이 의도. 만료 임박 토큰을 갱신하고 그 결과를
  // 위 setAll 이 응답 쿠키에 실어보내게 하는 side effect 만 필요하다.
  await supabase.auth.getUser();

  return response;
}
