import type { Metadata } from 'next';

import { getFortuneCostPoints } from '@fortune/product-contracts';

import { DailyForm } from './daily-form';

export const metadata: Metadata = {
  title: '오늘의 운세',
  robots: { index: false, follow: false },
};

export default function DailyFortunePage() {
  return (
    <main className="ondo-shell ondo-stack">
      <header className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <p className="ondo-kicker">오늘의 운세</p>
        <h1 className="ondo-h2">생년월일을 알려주세요</h1>
        <p className="ondo-muted">
          태어난 시간과 성별은 없어도 괜찮아요. 알려주면 사주를 더 정확하게 세울 수 있어요. 1회에 온도{' '}
          {getFortuneCostPoints('daily')}개가 사용됩니다.
        </p>
      </header>

      <DailyForm />
    </main>
  );
}
