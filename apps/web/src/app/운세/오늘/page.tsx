import type { Metadata } from 'next';

import { DailyForm } from '@/features/daily/daily-form';

/**
 * 공개 오늘의 운세.
 *
 * 로그인 벽 뒤가 아니라 여기가 첫 방문자의 도착점이다. 한글 slug 를 쓰는 이유는
 * 제품이 한국어 전용이고 SERP/카카오 링크 프리뷰에서 경로 토큰이 그대로 읽히기
 * 때문이다 (plans/web-first-pivot.md §5.2).
 */
export const metadata: Metadata = {
  title: '오늘의 운세 — 생년월일로 바로 보기',
  description:
    '생년월일 하나로 오늘 하루의 흐름을 종합·애정·재물·일·건강으로 나눠 읽어드려요. 설치도 로그인도 없이 바로 볼 수 있어요.',
  alternates: { canonical: '/운세/오늘' },
};

export default function TodayFortunePage() {
  return (
    <main className="ondo-shell ondo-stack">
      <header className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <p className="ondo-kicker">오늘의 운세</p>
        <h1 className="ondo-h2">생년월일을 알려주세요</h1>
        <p className="ondo-muted">
          태어난 시간과 성별은 없어도 괜찮아요. 알려주면 사주를 더 정확하게 세울 수 있어요.
        </p>
      </header>

      <section aria-labelledby="today-reading-guide" className="ondo-notice ondo-stack">
        <div className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xxs)' }}>
          <p className="ondo-kicker">미리 보는 구성</p>
          <h2 className="ondo-h3" id="today-reading-guide">
            한 번의 입력으로 오늘의 흐름을 나눠 읽어요
          </h2>
        </div>
        <p className="ondo-muted">전체 흐름을 먼저 보고, 애정·재물·일·건강 순서로 필요한 부분을 골라 살펴볼 수 있어요.</p>
        <p className="ondo-muted">생년월일만 필수예요. 태어난 시간과 성별은 알고 있을 때만 더해 주세요.</p>
      </section>

      <DailyForm />
    </main>
  );
}
