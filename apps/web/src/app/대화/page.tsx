import type { Metadata } from 'next';

import { CharacterPicker } from '@/features/chat/character-picker';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 공개 캐릭터 목록.
 *
 * 한글 slug 는 `/운세/오늘` 과 같은 이유다 — 제품이 한국어 전용이고 SERP /
 * 카카오 링크 프리뷰에 경로 토큰이 그대로 읽힌다.
 */
export const metadata: Metadata = {
  title: '캐릭터와 대화 — 로그인 없이 바로',
  description:
    '새벽 편의점 알바, 말 짧은 선배, 텐션 높은 친구, 찻집 주인. 온도의 캐릭터에게 지금 말을 걸어보세요. 설치도 로그인도 없이 시작할 수 있어요.',
  alternates: { canonical: '/대화' },
};

export default function ChatCharactersPage() {
  return (
    <FortunePageShell
      description="말을 거는 쪽은 캐릭터입니다. 마음에 드는 사람을 고르면 바로 대화가 시작돼요."
      kicker="대화"
      title="누구와 이야기할까요"
    >
      <CharacterPicker />

      <p className="ondo-muted">
        온도의 캐릭터 대화는 엔터테인먼트 목적으로 제공되며, 실제 인물이 아닌 AI 캐릭터와의 대화입니다.
      </p>
    </FortunePageShell>
  );
}
