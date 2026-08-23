import type { Metadata } from 'next';
import { redirect } from 'next/navigation';
import type { ReactNode } from 'react';

import { createSupabaseServerClient } from '@/lib/supabase/server';

export const metadata: Metadata = {
  robots: { index: false, follow: false },
};

// 쿠키 기반 세션을 매 요청 확인해야 하므로 정적 생성 대상이 아니다.
export const dynamic = 'force-dynamic';

/**
 * 로그인 뒤 화면의 인가 게이트.
 *
 * 여기가 authorization 의 유일한 판단 지점이다 — middleware 는 서명 검증 없이
 * 쿠키만 보므로 세션 refresh 만 하고 접근을 막지 않는다. `auth.getUser()` 는
 * Supabase auth 서버에 실제로 물어본다.
 */
export default async function AuthenticatedLayout({ children }: { children: ReactNode }) {
  const supabase = await createSupabaseServerClient();
  const user = supabase ? (await supabase.auth.getUser()).data.user : null;

  if (!user) {
    redirect('/auth/login?next=%2Fapp');
  }

  return <>{children}</>;
}
