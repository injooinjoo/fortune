import type { Metadata } from 'next';
import { encodePath } from '@/lib/href';
import Link from 'next/link';

import { ZodiacForm } from '@/features/f-b/zodiac-form';
import { ZODIAC_ANIMALS } from '@/features/f-b/zodiac-animals';
import { FortunePageShell } from '@/features/fortune/shell';

export const metadata: Metadata = {
  title: '띠별 운세 — 12지 오늘의 운세',
  description:
    '내 띠를 고르면 오늘의 흐름을 대인·실행·감정·타이밍으로 나눠 읽어드려요. 궁합이 좋은 띠와 행운의 시간·색·방향까지 함께 알려드려요.',
  alternates: { canonical: '/운세/띠별' },
};

/**
 * 12지 목록 + 폼.
 *
 * 아래 링크 줄은 장식이 아니라 `/운세/띠별/<띠>` 를 크롤러가 찾는 유일한 경로다
 * ("호랑이띠 운세" 처럼 띠 이름이 붙은 검색어가 실제 유입원이라 띠마다 독립
 * URL 을 둔다). 폼의 칩은 클라이언트 상태만 바꾸므로 링크를 대신하지 못한다.
 */
export default function ZodiacFortunePage() {
  return (
    <FortunePageShell
      description="태어난 해의 12지를 고르면 바로 오늘의 운세를 읽어드려요."
      kicker="띠별 운세"
      title="내 띠를 골라주세요"
    >
      <ZodiacForm />

      <section className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <h2 className="ondo-kicker">띠별로 바로 보기</h2>
        <div className="ondo-row">
          {ZODIAC_ANIMALS.map((animal) => (
            <Link className="ondo-chip" href={encodePath(`/운세/띠별/${animal.name}`)} key={animal.name}>
              {`${animal.emoji} ${animal.name}띠`}
            </Link>
          ))}
        </div>
      </section>
    </FortunePageShell>
  );
}
