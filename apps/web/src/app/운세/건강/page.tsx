import type { Metadata } from 'next';

import { HealthForm } from '@/features/f-c/health-form';
import { FortunePageShell } from '@/features/fortune/shell';

export const metadata: Metadata = {
  title: '건강운 — 오늘 컨디션으로 보는 건강 흐름',
  description:
    '요즘 컨디션과 생활 습관을 고르면 주의할 점, 추천 활동, 식습관과 운동 루틴을 정리해드려요. 의학적 진단이 아닌 참고용이며, 설치도 로그인도 필요 없어요.',
  alternates: { canonical: '/운세/건강' },
};

export default function HealthFortunePage() {
  return (
    <FortunePageShell
      description="컨디션만 골라도 바로 볼 수 있어요. 생활 습관을 맞춰주면 조언이 더 정확해져요."
      kicker="건강운"
      title="요즘 컨디션 어떠세요?"
    >
      <HealthForm />
    </FortunePageShell>
  );
}
