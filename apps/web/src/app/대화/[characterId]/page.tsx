import type { Metadata } from 'next';
import { notFound } from 'next/navigation';

import { ChatThread } from '@/features/chat/chat-thread';
import { WEB_CHAT_CHARACTERS, findWebChatCharacter } from '@/features/chat/characters';
import { FortunePageShell } from '@/features/fortune/shell';

/**
 * 캐릭터 한 명과의 스레드. 공개 경로다 — 결과(=대화) 앞에 로그인 벽을 두지
 * 않는다. 세션은 `ChatThread` 가 마운트되면서 익명으로 만든다.
 *
 * 캐릭터 수가 고정이라 파라미터를 미리 뽑아 정적 생성한다. 목록에 없는 id 는
 * 404 — dynamicParams 를 끄면 존재하지 않는 캐릭터에 대해 빈 대화창이 뜨는 일이 없다.
 */
export const dynamicParams = false;

export function generateStaticParams() {
  return WEB_CHAT_CHARACTERS.map((character) => ({ characterId: character.id }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ characterId: string }>;
}): Promise<Metadata> {
  const { characterId } = await params;
  const character = findWebChatCharacter(characterId);
  if (!character) return {};

  return {
    title: `${character.name} — ${character.tagline}`,
    description: character.intro,
    alternates: { canonical: `/대화/${character.id}` },
  };
}

export default async function ChatThreadPage({
  params,
}: {
  params: Promise<{ characterId: string }>;
}) {
  const { characterId } = await params;
  const character = findWebChatCharacter(characterId);
  if (!character) notFound();

  return (
    <FortunePageShell description={character.intro} kicker={character.relationship} title={character.name}>
      <ChatThread character={character} />
    </FortunePageShell>
  );
}
