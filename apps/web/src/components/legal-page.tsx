import type { ReactNode } from 'react';

interface LegalPageProps {
  eyebrow: string;
  title: string;
  intro: ReactNode;
  children: ReactNode;
}

export function LegalPage({ eyebrow, title, intro, children }: LegalPageProps) {
  return (
    <main className="ondo-shell ondo-legal-page" id="main" tabIndex={-1}>
      <header className="ondo-legal-header">
        <p className="ondo-kicker">{eyebrow}</p>
        <h1 className="ondo-h1">{title}</h1>
        <div className="ondo-muted">{intro}</div>
      </header>
      <div className="ondo-legal-content">{children}</div>
    </main>
  );
}
