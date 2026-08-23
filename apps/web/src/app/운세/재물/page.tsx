import type { Metadata } from 'next';

import { WealthForm } from '@/features/f-c/wealth-form';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 공개 재물운. 로그인 벽 없이 여기서 바로 결과까지 간다.
 * 한글 slug 는 `/운세/오늘` 과 같은 이유 (한국어 전용 제품 + SERP/링크 프리뷰).
 */
export const metadata: Metadata = {
  title: '재물운 — 목표와 고민으로 보는 금전 흐름',
  description:
    '재물 목표와 가장 큰 고민만 고르면 금전 흐름, 관심 분야별 인사이트, 이번 달 실천 항목까지 정리해드려요. 설치도 로그인도 없이 바로 볼 수 있어요.',
  alternates: { canonical: '/운세/재물' },
};

export default function WealthFortunePage() {
  return (
    <FortunePageShell
      description="목표와 고민 두 가지만 고르면 돼요. 나머지는 흔한 값으로 맞춰뒀으니 다르면 눌러서 바꿔주세요."
      kicker="재물운"
      title="지금 돈 흐름이 궁금하신가요?"
    >
      <WealthForm />
    </FortunePageShell>
  );
}
