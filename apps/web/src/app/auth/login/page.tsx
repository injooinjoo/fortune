import type { Metadata } from 'next';

import { sanitizeNextPath } from '@/lib/safe-path';

import { LoginForm } from './login-form';

export const metadata: Metadata = {
  title: '로그인',
  robots: { index: false, follow: false },
};

/**
 * `next` / `error` 는 서버에서 읽어 props 로 내린다.
 * 클라이언트에서 `useSearchParams` 로 읽으면 Next 가 이 서브트리를
 * 프리렌더에서 제외해서, 초기 HTML 에 폼이 아예 없는 상태가 된다.
 */
export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const params = await searchParams;
  const rawNext = Array.isArray(params.next) ? params.next[0] : params.next;
  const rawError = Array.isArray(params.error) ? params.error[0] : params.error;

  return (
    <main className="ondo-shell ondo-stack">
      <header className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <p className="ondo-kicker">로그인</p>
        <h1 className="ondo-h2">Google 로 로그인</h1>
        <p className="ondo-muted">비밀번호는 따로 없어요. 구글 계정으로 한 번에 들어옵니다.</p>
      </header>

      <LoginForm callbackError={rawError ?? null} nextPath={sanitizeNextPath(rawNext)} />
    </main>
  );
}
