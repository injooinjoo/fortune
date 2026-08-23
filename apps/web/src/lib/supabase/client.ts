import { createBrowserClient } from '@supabase/ssr';
import type { SupabaseClient } from '@supabase/supabase-js';

import { isSupabaseConfigured, supabaseAnonKey, supabaseUrl } from '@/lib/env';

/**
 * 브라우저용 Supabase 클라이언트.
 *
 * `apps/mobile-rn/src/lib/supabase.ts` 를 재사용하지 않는 이유: 그쪽은
 * SecureStore storage + processLock + `detectSessionInUrl: false` 로 native
 * 전용이다. 웹은 @supabase/ssr 의 쿠키 기반 세션이어야 서버 컴포넌트와
 * 세션을 공유한다.
 *
 * lazy singleton 인 이유: 모듈 로드 시점에 만들면 프리렌더 중에도 실행돼
 * 환경변수 없는 CI 빌드에서 터진다.
 */
let cachedClient: SupabaseClient | null = null;

export function getBrowserSupabase(): SupabaseClient | null {
  if (!isSupabaseConfigured) return null;
  cachedClient ??= createBrowserClient(supabaseUrl, supabaseAnonKey);
  return cachedClient;
}
