import type { Metadata } from 'next';
import { encodePath } from '@/lib/href';
import Link from 'next/link';

import { MbtiForm } from '@/features/f-b/mbti-form';
import { MBTI_TYPES } from '@/features/f-b/mbti-types';
import { FortunePageShell } from '@/features/fortune/shell';

export const metadata: Metadata = {
  title: 'MBTI 운세 — 16유형 오늘의 운세',
  description:
    '내 MBTI를 고르면 E/I·N/S·T/F·J/P 네 차원별로 오늘의 흐름과 조심할 함정을 읽어드려요. 강점과 잘 맞는 유형까지 함께 알려드려요.',
  alternates: { canonical: '/운세/엠비티아이' },
};

/**
 * 16유형 목록 + 폼.
 *
 * 아래 링크 줄이 `/운세/엠비티아이/<유형>` 로 가는 유일한 경로다 — "INTJ 운세"
 * 처럼 유형이 붙은 검색어가 실제 유입원이라 유형마다 독립 URL 을 둔다.
 */
export default function MbtiFortunePage() {
  return (
    <FortunePageShell
      description="네 글자만 고르면 바로 오늘의 운세를 읽어드려요. 생년월일은 필요 없어요."
      kicker="MBTI 운세"
      title="내 유형을 골라주세요"
    >
      <MbtiForm />

      <section className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <h2 className="ondo-kicker">유형별로 바로 보기</h2>
        <div className="ondo-row">
          {MBTI_TYPES.map((type) => (
            <Link className="ondo-chip" href={encodePath(`/운세/엠비티아이/${type.id}`)} key={type.id}>
              {`${type.id} ${type.nickname}`}
            </Link>
          ))}
        </div>
      </section>
    </FortunePageShell>
  );
}
