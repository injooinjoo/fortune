import type { Metadata } from 'next';

import { CareerForm } from '@/features/f-c/career-form';
import { FortunePageShell } from '@/features/fortune/shell';

export const metadata: Metadata = {
  title: '직업운 — 지금 직무로 보는 커리어 흐름',
  description:
    '현재 직무 한 줄이면 강점과 보완할 점, 시기별 실행 계획, 행운의 시기까지 짚어드려요. 직군에 맞는 성장 경로로 읽어주고, 설치도 로그인도 필요 없어요.',
  alternates: { canonical: '/운세/직업' },
};

export default function CareerFortunePage() {
  return (
    <FortunePageShell
      description="지금 하는 일을 적어주면 그 직군에 맞는 경로로 읽어드려요. 나머지는 선택이에요."
      kicker="직업운"
      title="커리어 흐름을 봐드릴게요"
    >
      <CareerForm />
    </FortunePageShell>
  );
}
