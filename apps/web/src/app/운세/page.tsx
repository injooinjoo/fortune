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

export default function FortuneIndexPage() {
  const sections = groupWebFortunes();

  return (
    <FortunePageShell
      description="생년월일만 있으면 됩니다. 설치도 로그인도 없이 바로 볼 수 있어요."
      kicker="운세"
      title="무엇을 볼까요?"
    >
      {sections.map((section, index) => {
        const headingId = `fortune-group-${index}`;
        return (
          <section aria-labelledby={headingId} className="ondo-stack" key={section.group}>
            <h2 className="ondo-h3" id={headingId}>
              {section.group}
            </h2>
            <div className="ondo-grid-2">
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
