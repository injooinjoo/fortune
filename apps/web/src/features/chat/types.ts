/**
 * 대화 메시지 모델.
 *
 * 필드 이름은 마음대로 정한 게 아니라 `character-conversation-load` /
 * `character-conversation-save` 의 ChatMessage 인터페이스 그대로다
 * (`{ id, type, content, timestamp }`). 웹에서 다르게 부르면 저장/복원
 * 왕복에서 필드가 조용히 사라진다.
 *
 * `type` 은 서버가 4종을 쓴다. 웹은 user/character 만 만들지만, 같은
 * user_id + character_id 스레드에 다른 클라이언트가 넣어둔 system/narration
 * 이 섞여 올 수 있으므로 읽을 때는 4종을 다 받아 렌더한다.
 */

export const CHAT_MESSAGE_TYPES = ['user', 'character', 'system', 'narration'] as const;

export type ChatMessageType = (typeof CHAT_MESSAGE_TYPES)[number];

export interface ChatMessage {
  id: string;
  type: ChatMessageType;
  content: string;
  timestamp: string;
}

function isChatMessageType(value: unknown): value is ChatMessageType {
  return CHAT_MESSAGE_TYPES.includes(value as ChatMessageType);
}

/**
 * 서버에서 받은 임의 값을 메시지로 좁힌다.
 *
 * 스레드는 JSONB 배열이라 스키마 보증이 없다. 모양이 안 맞는 원소는 통째로
 * 버리는 대신 렌더 가능한 것만 통과시켜 "한 줄이 이상해서 화면 전체가 빈다"
 * 를 막는다.
 */
export function toChatMessage(value: unknown, index: number): ChatMessage | null {
  if (value === null || typeof value !== 'object') return null;
  const raw = value as Record<string, unknown>;

  const content = typeof raw.content === 'string' ? raw.content.trim() : '';
  if (content.length === 0) return null;

  return {
    id: typeof raw.id === 'string' && raw.id.length > 0 ? raw.id : `restored-${index}`,
    type: isChatMessageType(raw.type) ? raw.type : 'character',
    content,
    timestamp: typeof raw.timestamp === 'string' ? raw.timestamp : new Date().toISOString(),
  };
}
