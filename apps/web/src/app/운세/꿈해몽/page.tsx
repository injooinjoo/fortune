import type { Metadata } from 'next';

import { DreamForm } from '@/features/f-b/dream-form';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 공개 꿈해몽. 입력은 꿈 내용 하나뿐이라 생년월일 없이도 바로 결과가 나온다.
 * 한글 slug 는 `/운세/오늘` 과 같은 이유 (한국어 전용 제품 + SERP 가독성).
 */
export const metadata: Metadata = {
  title: '꿈해몽 — 꾼 꿈을 적으면 바로 풀이',
  description:
    '어젯밤 꾼 꿈을 그대로 적어보세요. 꿈에 담긴 상징과 지금의 마음 상태, 오늘 하루 지침까지 읽어드려요. 설치도 로그인도 없이 바로 볼 수 있어요.',
  alternates: { canonical: '/운세/꿈해몽' },
};

export default function DreamFortunePage() {
  return (
    <FortunePageShell
      description="기억나는 만큼만 적어도 괜찮아요. 장면과 감정을 같이 적으면 더 깊게 읽어드려요."
      kicker="꿈해몽"
      title="어떤 꿈을 꾸셨나요"
    >
      <DreamForm />
    </FortunePageShell>
  );
}
