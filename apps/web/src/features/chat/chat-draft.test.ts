import { describe, expect, it } from 'vitest';

import { readChatDraft, writeChatDraft } from './chat-draft';

class MemoryStorage {
  private readonly values = new Map<string, string>();

  get size(): number {
    return this.values.size;
  }

  getItem(key: string): string | null {
    return this.values.get(key) ?? null;
  }

  removeItem(key: string): void {
    this.values.delete(key);
  }

  setItem(key: string, value: string): void {
    this.values.set(key, value);
  }
}

describe('character chat draft', () => {
  it('restores only the selected character draft within the current session', () => {
    const storage = new MemoryStorage();

    writeChatDraft(storage, 'ondo_seo_haeun', '아직 보내지 않은 초안');

    expect(readChatDraft(storage, 'ondo_seo_haeun')).toBe('아직 보내지 않은 초안');
    expect(readChatDraft(storage, 'ondo_cha_dogyeong')).toBe('');
  });

  it('removes the session entry when the draft becomes empty', () => {
    const storage = new MemoryStorage();

    writeChatDraft(storage, 'ondo_seo_haeun', '보내기 전 초안');
    writeChatDraft(storage, 'ondo_seo_haeun', '');

    expect(storage.size).toBe(0);
  });
});
