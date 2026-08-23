import type { Metadata } from 'next';

import { SajuForm } from '@/features/f-a/saju-form';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 공개 전통 사주. 명식(4주)은 브라우저에서 `@fortune/saju-engine` 으로 세우고
 * 해석만 Edge Function 이 만든다 (`saju-form.tsx` 주석 참고).
 */
export const metadata: Metadata = {
  title: '사주 — 생년월일로 세우는 사주팔자',
  description:
    '생년월일로 년주·월주·일주·시주와 오행 균형을 세우고, 전통 사주 해석으로 지금의 흐름과 조언을 읽어드려요. 설치 없이 웹에서 바로 볼 수 있어요.',
  alternates: { canonical: '/운세/사주' },
};

export default function SajuPage() {
  return (
    <FortunePageShell
      description="태어난 시간을 알면 시주까지 세울 수 있어요. 몰라도 나머지 세 기둥으로 풀어드려요."
      kicker="사주"
      title="사주를 세워볼까요?"
    >
      <SajuForm />
    </FortunePageShell>
  );
}
