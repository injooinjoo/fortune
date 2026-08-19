import { createServerClient } from '@supabase/ssr';
import type { SupabaseClient } from '@supabase/supabase-js';
import { cookies } from 'next/headers';

import { isSupabaseConfigured, supabaseAnonKey, supabaseUrl } from '@/lib/env';

/**
 * 서버 컴포넌트 / Route Handler 용 Supabase 클라이언트.
 *
 * anon key 만 사용한다 — RLS 를 그대로 통과시키는 것이 의도다.
 * 환경변수가 없으면 `null` (호출부가 로그인 화면으로 보낸다).
 */
export async function createSupabaseServerClient(): Promise<SupabaseClient | null> {
  if (!isSupabaseConfigured) return null;

  const cookieStore = await cookies();

  return createServerClient(supabaseUrl, supabaseAnonKey, {
    cookies: {
      getAll() {
        return cookieStore.getAll();
      },
      setAll(cookiesToSet) {
        try {
          for (const { name, value, options } of cookiesToSet) {
            cookieStore.set(name, value, options);
          }
        } catch {
          // Server Component 렌더 중에는 Next 가 쿠키 쓰기를 금지한다 (읽기 전용 스토어).
          // 세션 refresh 쓰기는 middleware 의 updateSession 이 이미 수행하므로
          // 여기서 실패해도 세션은 유지된다.
        }
      },
    },
  });
}
