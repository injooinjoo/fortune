import type { Metadata } from 'next';

import { TarotForm } from '@/features/f-a/tarot-form';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 공개 타로 리딩. `/운세/오늘` 과 같은 한글 slug 규칙.
 */
export const metadata: Metadata = {
  title: '타로 — 카드 뽑고 바로 보는 리딩',
  description:
    '뒤집힌 카드 중에서 직접 골라 보세요. 뽑은 카드마다 위치별 해석과 전체 흐름을 이야기처럼 읽어드려요. 설치 없이 웹에서 바로 볼 수 있어요.',
  alternates: { canonical: '/운세/타로' },
};

export default function TarotPage() {
  return (
    <FortunePageShell
      description="궁금한 결을 고르고, 뒤집힌 카드 중에서 마음이 가는 자리를 골라주세요."
      kicker="타로"
      title="카드를 뽑아볼까요?"
    >
      <TarotForm />
    </FortunePageShell>
  );
}
