import type { Metadata } from 'next';

import { LoveForm } from '@/features/f-a/love-form';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 공개 연애운.
 */
export const metadata: Metadata = {
  title: '연애운 — 지금 내 연애 흐름 보기',
  description:
    '나이·성별·연애 상태만 알려주면 연애 스타일, 잘 맞는 사람, 이번 주와 이번 달의 흐름까지 읽어드려요. 설치 없이 웹에서 바로 볼 수 있어요.',
  alternates: { canonical: '/운세/연애' },
};

export default function LovePage() {
  return (
    <FortunePageShell
      description="세 가지만 알려주면 됩니다. 지금 상태에 맞춰 연애 흐름과 조언을 정리해 드려요."
      kicker="연애운"
      title="지금 연애는 어떤가요?"
    >
      <LoveForm />
    </FortunePageShell>
  );
}
