/**
 * useMessageQueue — 캐릭터 메시지 append + 카톡 리듬 segment enqueue.
 *
 * 추출 이유: chat-screen.tsx (3,500+줄) 분해 Step B. enqueueAssistantSegments
 * + appendMessages 가 메시지 append 도메인의 핵심 로직이지만 chat-screen 의
 * useState 와 강결합. hook 으로 분리해 책임 격리 + 테스트 가능성 ↑.
 *
 * 동작 변경 0:
 *   - enqueueAssistantSegments: segment 사이 200-600ms 타이핑 + 600-1800ms 간격
 *     (카톡 멀티버블 emulation). 첫 segment 는 호출자가 replyDelay 처리.
 *   - appendMessages: assistant/system 섞이면 markLatestUserMessageAsRead 동시 적용.
 *   - 양쪽 모두 MessageStore 에도 sync (Step 1.D/E bridge 유지).
 *
 * Hook input/output 설계:
 *   - input: setMessagesByCharacterId (chat-screen state setter), triggerAssistantHaptic
 *   - output: enqueueAssistantSegments, appendMessages
 *   - state 자체는 chat-screen 이 소유 — hook 은 비즈니스 로직만. 점진 마이그레이션.
 *
 * 다음 phase 에서 store 가 source 가 되면 setMessagesByCharacterId 의존 제거.
 */

import { useCallback } from 'react';

import type { ChatCharacterSpec } from '../../../lib/chat-characters';
import {
  buildAssistantTextMessage,
  type ChatShellMessage,
} from '../../../lib/chat-shell';
import {
  markLatestUserMessageAsRead,
  randomInRange,
  sleep,
} from '../../../lib/chat-message-utils';
import { insertMessages as insertStoreMessages } from '../../../lib/message-store';

interface UseMessageQueueInput {
  setMessagesByCharacterId: React.Dispatch<
    React.SetStateAction<Record<string, ChatShellMessage[]>>
  >;
  triggerAssistantHaptic: (emotionTag?: string) => void;
}

export interface EnqueueAssistantSegmentsOptions {
  characterId: string;
  segments: string[];
  emotionTag?: string;
}

export function useMessageQueue(input: UseMessageQueueInput) {
  const { setMessagesByCharacterId, triggerAssistantHaptic } = input;

  /**
   * 어시스턴트 segments 를 카톡 리듬으로 하나씩 append. 각 버블 앞에 타이핑
   * 인디케이터 200-600ms + 버블 사이 600-1800ms 랜덤 간격. 첫 버블은 호출자가
   * 이미 replyDelay 를 걸었다고 가정.
   *
   * 반환: 최종 thread (호출자가 saveCharacterConversation 등에 사용).
   *
   * MessageStore bridge: 각 bubble 마다 store.insertMessages — push 도착과
   * 동일 store 에 모임. id dedup 으로 멱등성 보장.
   */
  const enqueueAssistantSegments = useCallback(
    async (
      options: EnqueueAssistantSegmentsOptions,
    ): Promise<ChatShellMessage[]> => {
      const { characterId, segments, emotionTag } = options;
      // 응답 append 는 항상 현재 state 위에 쌓는다. 큐잉된 유저 메시지(응답
      // 대기 중 사용자가 추가로 보낸 것) 를 덮어쓰지 않도록 functional setter
      // 만 사용.
      let latestThread: ChatShellMessage[] = [];

      for (let index = 0; index < segments.length; index += 1) {
        const text = segments[index]?.trim() ?? '';
        if (text.length === 0) {
          continue;
        }

        if (index > 0) {
          // 버블 간 타이핑 인디케이터 유지 — storyTyping/fortuneTyping 은
          // 이미 on 상태 (호출자 책임).
          // 옛 200~600ms + 600~1800ms = 0.8~2.4초 간격 → "우르르 한꺼번에"
          // 체감. 진짜 사람처럼 한 줄 보내고 다음 줄 타이핑하는 페이스로 늘림.
          // 한 줄당 최소 2초, 보통 3~5초 → 멀티버블 3개면 총 6~15초 spread.
          const gap = randomInRange(800, 2000); // 다음 버블 전 타이핑 인디케이터
          await sleep(gap);
          const betweenBubbles = randomInRange(1500, 3500);
          await sleep(betweenBubbles);
        }

        const bubble = buildAssistantTextMessage(text, {
          animate: true,
          emotionTag,
        });
        setMessagesByCharacterId((current) => {
          const thread = current[characterId] ?? [];
          const updated = [...thread, bubble];
          latestThread = updated;
          return { ...current, [characterId]: updated };
        });
        // Bridge to MessageStore — segment 단위로 store 에 sync. 같은 bubble
        // id 면 dedup, push 로 먼저 도착해도 안전.
        insertStoreMessages(characterId, [bubble]).catch(() => undefined);

        // 햅틱 — 카톡도 각 메시지마다 울리므로 전부.
        triggerAssistantHaptic(emotionTag);
      }

      return latestThread;
    },
    [setMessagesByCharacterId, triggerAssistantHaptic],
  );

  /**
   * 메시지 N 개 append. assistant/system 이 섞여 있으면 그 시점에 미읽음
   * 상태인 user 메시지 모두 읽음 처리 (운세 설문/액션/일반 채팅 모든 경로
   * 한 곳에서 커버, "1" 배지 잔존 방지).
   *
   * MessageStore bridge — 멱등 INSERT.
   */
  const appendMessages = useCallback(
    (character: ChatCharacterSpec, nextMessages: ChatShellMessage[]) => {
      const hasNonUserMessage = nextMessages.some(
        (m) => m.sender === 'assistant' || m.sender === 'system',
      );
      setMessagesByCharacterId((current) => {
        const existing = current[character.id] ?? [];
        const base = hasNonUserMessage
          ? markLatestUserMessageAsRead(existing)
          : existing;
        return {
          ...current,
          [character.id]: [...base, ...nextMessages],
        };
      });
      insertStoreMessages(character.id, nextMessages).catch(() => undefined);
    },
    [setMessagesByCharacterId],
  );

  return { enqueueAssistantSegments, appendMessages };
}
