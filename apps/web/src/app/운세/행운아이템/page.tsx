import type { Metadata } from 'next';

import { LuckyItemsForm } from '@/features/f-c/lucky-items-form';
import { FortunePageShell } from '@/features/fortune/shell';

export const metadata: Metadata = {
  title: '행운 아이템 — 오늘의 색·숫자·방향',
  description:
    '생년월일과 궁금한 카테고리만 고르면 오늘의 행운 색과 숫자, 방향, 패션과 음식까지 이유와 함께 추천해드려요. 설치도 로그인도 없이 바로 볼 수 있어요.',
  alternates: { canonical: '/운세/행운아이템' },
};

export default function LuckyItemsFortunePage() {
  return (
    <FortunePageShell
      description="궁금한 카테고리를 고르면 그 쪽을 특히 자세히 봐드려요."
      kicker="행운 아이템"
      title="오늘 뭘 들고 나갈까요?"
    >
      <LuckyItemsForm />
    </FortunePageShell>
  );
}
