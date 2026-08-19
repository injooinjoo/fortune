import type { Metadata } from 'next';

import { CompatibilityForm } from '@/features/f-a/compatibility-form';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 공개 궁합. 두 사람의 이름 + 생년월일을 받는다.
 */
export const metadata: Metadata = {
  title: '궁합 — 두 사람의 생년월일로 보는 케미',
  description:
    '두 사람의 이름과 생년월일로 띠·별자리·운명수 궁합을 계산하고, 성격·애정·결혼·소통 궁합을 함께 읽어드려요. 설치 없이 웹에서 바로 볼 수 있어요.',
  alternates: { canonical: '/운세/궁합' },
};

export default function CompatibilityPage() {
  return (
    <FortunePageShell
      description="두 사람의 이름과 생년월일만 있으면 됩니다. 연인, 친구, 동료 누구든 괜찮아요."
      kicker="궁합"
      title="두 사람의 케미가 궁금하다면"
    >
      <CompatibilityForm />
    </FortunePageShell>
  );
}
