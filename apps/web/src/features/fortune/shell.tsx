/**
 * 운세 페이지 공용 껍데기.
 *
 * `/운세/오늘/page.tsx` 가 인라인으로 쓰던 header 블록 그대로다. 새 운세 페이지는
 * 이걸 쓰면 kicker/제목/설명 위계가 자동으로 같아진다.
 *
 * 순수 컴포넌트라 서버 컴포넌트(page.tsx)에서 바로 쓸 수 있다 — 폼만 'use client'.
 */

import type { ReactNode } from 'react';

export function FortunePageShell({
  kicker,
  title,
  description,
  children,
}: {
  kicker: string;
  title: string;
  description?: ReactNode;
  children: ReactNode;
}) {
  return (
    <main className="ondo-shell ondo-stack ondo-fortune-shell">
      <header className="ondo-stack ondo-fortune-heading" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <p className="ondo-kicker">{kicker}</p>
        <h1 className="ondo-h2">{title}</h1>
        {description ? <p className="ondo-muted">{description}</p> : null}
      </header>

      {children}
    </main>
  );
}
