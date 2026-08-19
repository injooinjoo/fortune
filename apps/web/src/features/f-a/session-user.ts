/**
 * 로그인 여부와 무관하게 "지금 호출자의 user id" 를 얻는다.
 *
 * 왜 필요한가: `fortune-love` 는 body 의 필수 필드 목록에 `userId` 가 들어 있어
 * (`supabase/functions/fortune-love/index.ts` 의 requiredFields), 값이 없으면
 * 400 `필수 필드 누락: userId` 로 끝난다. 캐시 키(`love_<userId>_...`)도 이 값을
 * 쓴다. `runFortune` 은 user id 를 돌려주지 않으므로 호출 직전에 여기서 읽는다.
 *
 * 게스트 우선 원칙은 그대로다 — 세션이 없으면 익명 로그인을 시도하고,
 * 프로젝트에서 익명 로그인이 꺼져 있어 실패하면 null 을 돌려준다. null 이어도
 * 호출 자체를 막지 않는다 (로그인 벽 금지). 서버가 거절하면 그때 안내한다.
 *
 * 여기서 세션을 만들어 두면 뒤이어 부르는 `runFortune` 의 부트스트랩은
 * 이미 있는 세션을 발견하고 그냥 통과한다 (중복 익명 가입 없음).
 */

import { getBrowserSupabase } from '@/lib/supabase/client';

export async function ensureUserId(fortuneType: string): Promise<string | null> {
  const supabase = getBrowserSupabase();
  if (!supabase) return null;

  const { data: sessionData } = await supabase.auth.getSession();
  const existing = sessionData.session?.user.id;
  if (existing) return existing;

  const { data, error } = await supabase.auth.signInAnonymously();
  if (error) {
    console.warn(`[${fortuneType}] 익명 세션 발급 실패 — userId 없이 계속:`, error.message);
    return null;
  }
  return data.user?.id ?? null;
}
