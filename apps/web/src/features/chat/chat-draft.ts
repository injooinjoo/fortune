type DraftStorage = Pick<Storage, 'getItem' | 'removeItem' | 'setItem'>;

const CHAT_DRAFT_PREFIX = 'ondo:chat-draft:';

function draftKey(characterId: string): string {
  return `${CHAT_DRAFT_PREFIX}${characterId}`;
}

export function readChatDraft(storage: DraftStorage, characterId: string): string {
  try {
    return storage.getItem(draftKey(characterId)) ?? '';
  } catch {
    return '';
  }
}

export function writeChatDraft(
  storage: DraftStorage,
  characterId: string,
  draft: string,
): void {
  try {
    if (draft.length === 0) {
      storage.removeItem(draftKey(characterId));
      return;
    }
    storage.setItem(draftKey(characterId), draft);
  } catch {
    // Storage can be unavailable in private/restricted browsing; chat still works in memory.
  }
}
