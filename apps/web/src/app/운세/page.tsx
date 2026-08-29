import type { Metadata } from 'next';

import { FortuneLinkCard } from '@/components/fortune-link-card';
import { groupWebFortunes } from '@/features/fortune/catalog';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 웹이 서빙하는 운세 전체 목록.
 *
 * 목록은 파일 시스템이 아니라 `WEB_FORTUNES` 에서 만든다 — 라우트 폴더가
 * 늘어나는 순서와 무관하게 카탈로그 순서/문구/가격을 그대로 따른다.
 */
export const metadata: Metadata = {
  title: '운세 전체 보기',
  description:
    '오늘의 운세, 타로, 사주, 궁합, 재물, 꿈해몽까지. 설치 없이 웹에서 바로 볼 수 있는 온도의 운세 목록이에요.',
  alternates: { canonical: '/운세' },
};

function FortuneGuideContent({ headingId, showKicker = true }: { headingId: string; showKicker?: boolean }) {
  return (
    <>
      <div className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xxs)' }}>
        {showKicker ? <p className="ondo-kicker">고르는 기준</p> : null}
        <h2 className="ondo-h3" id={headingId}>
          지금 궁금한 깊이에 맞춰 골라보세요
        </h2>
      </div>
      <div className="ondo-grid-2">
        <div className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xxs)' }}>
          <strong>지금의 흐름을 가볍게</strong>
          <p className="ondo-muted">오늘의 운세와 타로로 먼저 마음을 정리해 보세요.</p>
        </div>
        <div className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xxs)' }}>
          <strong>관계나 마음을 더 깊게</strong>
          <p className="ondo-muted">연애·궁합·사주처럼 한 가지 질문을 골라 천천히 읽어보세요.</p>
        </div>
      </div>
      <p className="ondo-muted">각 카드의 온도 사용량을 확인한 뒤, 원하는 리딩을 선택할 수 있어요.</p>
    </>
  );
}

export default function FortuneIndexPage() {
  const sections = groupWebFortunes();

  return (
    <FortunePageShell
      description="생년월일만 있으면 됩니다. 설치도 로그인도 없이 바로 볼 수 있어요."
      kicker="운세"
      title="무엇을 볼까요?"
    >
      <section
        aria-labelledby="fortune-guide-title"
        className="ondo-fortune-guide ondo-fortune-guide-desktop ondo-stack"
      >
        <FortuneGuideContent headingId="fortune-guide-title" />
      </section>

      <details className="ondo-fortune-guide-mobile">
        <summary>
          <span>
            <span className="ondo-kicker">고르는 기준</span>
            <strong>필요하면 펼쳐보세요</strong>
          </span>
          <span aria-hidden="true" className="ondo-fortune-guide-toggle">+</span>
        </summary>
        <div className="ondo-fortune-guide ondo-fortune-guide-mobile-content ondo-stack">
          <FortuneGuideContent headingId="fortune-guide-mobile-title" showKicker={false} />
        </div>
      </details>

      {sections.map((section, index) => {
        const headingId = `fortune-group-${index}`;
        return (
          <section aria-labelledby={headingId} className="ondo-stack ondo-fortune-group" key={section.group}>
            <h2 className="ondo-h3" id={headingId}>
              {section.group}
            </h2>
            <div className="ondo-fortune-list">
              {section.fortunes.map((fortune) => (
                <FortuneLinkCard fortune={fortune} key={fortune.slug} />
              ))}
            </div>
          </section>
        );
      })}
    </FortunePageShell>
  );
}
