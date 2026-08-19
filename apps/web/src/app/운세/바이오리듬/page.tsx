import type { Metadata } from 'next';

import { BiorhythmForm } from '@/features/f-b/biorhythm-form';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 공개 바이오리듬. 입력은 생년월일 하나 — 서버가 출생 이후 경과일로
 * 신체(23일)·감정(28일)·지성(33일) 주기를 계산한다.
 */
export const metadata: Metadata = {
  title: '바이오리듬 — 생년월일로 오늘 컨디션 보기',
  description:
    '생년월일 하나로 신체 23일, 감정 28일, 지성 33일 주기의 오늘 위치를 계산해요. 오늘 몰아붙일 일과 미룰 일, 이번 주 흐름까지 알려드려요.',
  alternates: { canonical: '/운세/바이오리듬' },
};

export default function BiorhythmFortunePage() {
  return (
    <FortunePageShell
      description="태어난 날부터 지금까지의 경과일로 세 리듬의 오늘 위치를 계산해요."
      kicker="바이오리듬"
      title="생년월일을 알려주세요"
    >
      <BiorhythmForm />
    </FortunePageShell>
  );
}
