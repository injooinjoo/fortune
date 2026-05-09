import { useCallback } from 'react';

import type { ChatShellMessage } from '../../../lib/chat-shell';
import { markLatestUserMessageAsRead } from '../../../lib/chat-message-utils';
import {
  deleteMessage as deleteStoreMessage,
  deleteMessages as deleteStoreMessages,
  insertMessages as insertStoreMessages,
  markUserMessagesAsReadInStore,
} from '../../../lib/message-store';

interface UseChatMessageControllerInput {
  setMessagesByCharacterId: React.Dispatch<
    React.SetStateAction<Record<string, ChatShellMessage[]>>
  >;
}

function mergeById(
  existing: ChatShellMessage[],
  incoming: readonly ChatShellMessage[],
): ChatShellMessage[] {
  if (incoming.length === 0) return existing;
  const ids = new Set(existing.map((message) => message.id));
  const next = incoming.filter((message) => !ids.has(message.id));
  return next.length > 0 ? [...existing, ...next] : existing;
}

export function useChatMessageController(input: UseChatMessageControllerInput) {
  const { setMessagesByCharacterId } = input;

  const appendMessages = useCallback(
    (
      characterId: string,
      messages: readonly ChatShellMessage[],
      options?: { markUserReadBeforeAppend?: boolean; dedupe?: boolean },
    ) => {
      if (messages.length === 0) return;
      setMessagesByCharacterId((current) => {
        const existing = current[characterId] ?? [];
        const base = options?.markUserReadBeforeAppend
          ? markLatestUserMessageAsRead(existing)
          : existing;
        const merged = options?.dedupe === false
          ? [...base, ...messages]
          : mergeById(base, messages);
        if (merged === existing) return current;
        return { ...current, [characterId]: merged };
      });
      insertStoreMessages(characterId, messages).catch(() => undefined);
    },
    [setMessagesByCharacterId],
  );

  const markUserMessagesRead = useCallback(
    (characterId: string) => {
      markUserMessagesAsReadInStore(characterId);
      setMessagesByCharacterId((current) => ({
        ...current,
        [characterId]: markLatestUserMessageAsRead(
          current[characterId] ?? [],
        ),
      }));
    },
    [setMessagesByCharacterId],
  );

  const removeMessage = useCallback(
    (characterId: string, messageId: string) => {
      setMessagesByCharacterId((current) => {
        const thread = current[characterId] ?? [];
        const next = thread.filter((message) => message.id !== messageId);
        if (next.length === thread.length) return current;
        return { ...current, [characterId]: next };
      });
      deleteStoreMessage(characterId, messageId);
    },
    [setMessagesByCharacterId],
  );

  const removeMessages = useCallback(
    (characterId: string, messageIds: readonly string[]) => {
      if (messageIds.length === 0) return;
      const idSet = new Set(messageIds);
      setMessagesByCharacterId((current) => {
        const thread = current[characterId] ?? [];
        const next = thread.filter((message) => !idSet.has(message.id));
        if (next.length === thread.length) return current;
        return { ...current, [characterId]: next };
      });
      deleteStoreMessages(characterId, messageIds);
    },
    [setMessagesByCharacterId],
  );

  return {
    appendMessages,
    markUserMessagesRead,
    removeMessage,
    removeMessages,
  };
}
