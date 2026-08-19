import Link from 'next/link';

import { getFortuneCostPoints } from '@fortune/product-contracts';

export default function AppHomePage() {
  return (
    <main className="ondo-shell ondo-stack">
      <header className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <p className="ondo-kicker">내 운세</p>
        <h1 className="ondo-h2">무엇을 볼까요?</h1>
      </header>

      <Link className="ondo-card ondo-stack" href="/app/f/daily" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <h2 className="ondo-h3">오늘의 운세</h2>
        <p className="ondo-muted">
          생년월일과 태어난 시간으로 오늘 하루의 흐름을 읽어요. 온도 {getFortuneCostPoints('daily')}개.
        </p>
      </Link>
    </main>
  );
}
