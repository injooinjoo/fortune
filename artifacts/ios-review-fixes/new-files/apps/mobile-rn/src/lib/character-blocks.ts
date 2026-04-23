/**
 * Character block helper — Apple 5.2.3 대응.
 *
 * 사용자가 특정 AI 캐릭터를 차단하면 `character_blocks` 테이블에 row를 insert.
 * 차단된 캐릭터는 리스트에서 숨겨지고 채팅 화면 진입이 차단된다. RLS에 의해
 * 자신의 블록만 읽고 쓸 수 있다.
 */
import { useEffect, useState } from 'react';

import { captureError } from './error-reporting';
import { supabase } from './supabase';

const TABLE = 'character_blocks';

export async function blockCharacter(characterId: string): Promise<void> {
  if (!supabase) return;
  const session = (await supabase.auth.getSession()).data.session;
  if (!session) return;

  const { error } = await supabase
    .from(TABLE)
    .upsert(
      {
        user_id: session.user.id,
        character_id: characterId,
        unblocked_at: null,
      },
      { onConflict: 'user_id,character_id' },
    );

  if (error) {
    await captureError(error, { surface: 'character-blocks:block' }).catch(
      () => undefined,
    );
    throw error;
  }
}

export async function unblockCharacter(characterId: string): Promise<void> {
  if (!supabase) return;
  const session = (await supabase.auth.getSession()).data.session;
  if (!session) return;

  const { error } = await supabase
    .from(TABLE)
    .update({ unblocked_at: new Date().toISOString() })
    .eq('user_id', session.user.id)
    .eq('character_id', characterId);

  if (error) {
    await captureError(error, { surface: 'character-blocks:unblock' }).catch(
      () => undefined,
    );
    throw error;
  }
}

export async function fetchBlockedCharacterIds(): Promise<Set<string>> {
  if (!supabase) return new Set();
  const session = (await supabase.auth.getSession()).data.session;
  if (!session) return new Set();

  const { data, error } = await supabase
    .from(TABLE)
    .select('character_id, unblocked_at')
    .eq('user_id', session.user.id)
    .is('unblocked_at', null);

  if (error) {
    await captureError(error, { surface: 'character-blocks:fetch' }).catch(
      () => undefined,
    );
    return new Set();
  }

  const ids = new Set<string>();
  for (const row of data ?? []) {
    const id = (row as { character_id?: unknown }).character_id;
    if (typeof id === 'string') ids.add(id);
  }
  return ids;
}

export function useBlockedCharacterIds(): Set<string> {
  const [ids, setIds] = useState<Set<string>>(new Set());

  useEffect(() => {
    let cancelled = false;
    void fetchBlockedCharacterIds().then((next) => {
      if (!cancelled) setIds(next);
    });
    return () => {
      cancelled = true;
    };
  }, []);

  return ids;
}
