import { useCallback } from 'react';

import { router } from 'expo-router';
import type { SajuResult } from '@fortune/saju-engine';

import { buildMySajuContextMessage } from '../lib/chat-shell';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

/**
 * "내 사주로 대화하기" entry point from the Manseryeok screen.
 *
 * Stages a `my-saju-context` system message on the AppBootstrap provider and
 * navigates to /chat. The chat screen consumes the pending message in a
 * mount-time effect and prepends it to the active thread so the user sees
 * their own chart pinned at the top of the conversation.
 *
 * Keeps the same shape as `pendingChatFortuneType` deep-link hand-off — no
 * new storage layer, just in-memory session-scoped context.
 */
export function useEnterChatWithSaju() {
  const { setPendingMySajuContext } = useAppBootstrap();

  return useCallback(
    (saju: SajuResult) => {
      const message = buildMySajuContextMessage(saju);
      setPendingMySajuContext(message);
      router.push('/chat');
    },
    [setPendingMySajuContext],
  );
}
