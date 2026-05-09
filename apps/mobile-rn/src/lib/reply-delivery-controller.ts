import type { ChatShellMessage } from './chat-shell';
import { randomInRange } from './chat-message-utils';
import {
  fromPersistedStoryMessages,
  type StoryChatResponse,
} from './story-chat-runtime';
import { supabase } from './supabase';

interface ReplyPhaseDelays {
  beforeReadMs: number;
  readToTypingMs: number;
  typingPreviewMs: number;
}

interface ScheduledReplyOptions {
  characterId: string;
  response: Pick<StoryChatResponse, 'scheduledId' | 'deliverAt'>;
  phaseDelays: ReplyPhaseDelays;
  onMarkRead: () => void;
  onTypingChange: (isTyping: boolean) => void;
  onMessages: (messages: ChatShellMessage[]) => void;
  onDrop?: (status: ClaimScheduledReplyStatus) => void;
  onError?: (error: unknown) => void;
}

type ClaimScheduledReplyStatus =
  | 'delivered'
  | 'canceled'
  | 'already_delivered'
  | 'not_due';

interface ClaimScheduledReplyResponse {
  success?: boolean;
  status?: ClaimScheduledReplyStatus;
  messages?: unknown;
  error?: string;
}

interface PendingTask {
  generation: number;
  timer: ReturnType<typeof setTimeout> | null;
}

const MIN_RECHECK_DELAY_MS = 1000;
const MAX_NOT_DUE_RECHECK_MS = 15_000;

class ReplyDeliveryController {
  private generationByCharacter = new Map<string, number>();
  private taskByCharacter = new Map<string, PendingTask>();

  cancelLocal(characterId: string): void {
    const nextGeneration = (this.generationByCharacter.get(characterId) ?? 0) + 1;
    this.generationByCharacter.set(characterId, nextGeneration);
    const task = this.taskByCharacter.get(characterId);
    if (task?.timer) {
      clearTimeout(task.timer);
    }
    this.taskByCharacter.delete(characterId);
  }

  cancelServerScheduledReplies(characterId: string): void {
    this.cancelLocal(characterId);
    if (!supabase) return;
    void supabase.rpc('cancel_scheduled_replies_for_character', {
      p_character_id: characterId,
    }).then(({ error }) => {
      if (error) {
        console.warn('[reply-delivery] cancel scheduled replies failed:', error);
      }
    });
  }

  beginLocalReply(characterId: string): number {
    this.cancelLocal(characterId);
    return this.generationByCharacter.get(characterId) ?? 0;
  }

  isLocalReplyCurrent(characterId: string, generation: number): boolean {
    return this.isCurrent(characterId, generation);
  }

  scheduleScheduledReply(options: ScheduledReplyOptions): boolean {
    const scheduledId = options.response.scheduledId;
    const deliverAt = options.response.deliverAt;
    if (!scheduledId || !deliverAt || !supabase) {
      return false;
    }

    this.cancelLocal(options.characterId);
    const generation = this.generationByCharacter.get(options.characterId) ?? 0;
    const totalMs = Math.max(0, Date.parse(deliverAt) - Date.now());
    const typingPreviewMs = Math.min(options.phaseDelays.typingPreviewMs, totalMs);
    const readToTypingMs = Math.min(
      options.phaseDelays.readToTypingMs,
      Math.max(0, totalMs - typingPreviewMs),
    );
    const beforeReadMs = Math.max(0, totalMs - typingPreviewMs - readToTypingMs);

    this.scheduleStep(options.characterId, generation, beforeReadMs, () => {
      if (!this.isCurrent(options.characterId, generation)) return;
      options.onMarkRead();
      this.scheduleStep(options.characterId, generation, readToTypingMs, () => {
        if (!this.isCurrent(options.characterId, generation)) return;
        options.onTypingChange(true);
        this.scheduleStep(options.characterId, generation, typingPreviewMs, () => {
          void this.claimAndRender(options, generation);
        });
      });
    });

    return true;
  }

  private scheduleStep(
    characterId: string,
    generation: number,
    delayMs: number,
    callback: () => void,
  ): void {
    const timer = setTimeout(callback, Math.max(0, delayMs));
    this.taskByCharacter.set(characterId, { generation, timer });
  }

  private isCurrent(characterId: string, generation: number): boolean {
    return (this.generationByCharacter.get(characterId) ?? 0) === generation;
  }

  private async claimAndRender(
    options: ScheduledReplyOptions,
    generation: number,
  ): Promise<void> {
    if (!this.isCurrent(options.characterId, generation)) return;
    const scheduledId = options.response.scheduledId;
    if (!scheduledId || !supabase) return;
    let keepTask = false;

    try {
      const { data, error } = await supabase.functions.invoke(
        'claim-scheduled-reply',
        { body: { scheduledId } },
      );
      if (error) throw error;
      if (!this.isCurrent(options.characterId, generation)) return;

      const payload = data as ClaimScheduledReplyResponse | null;
      const status = payload?.status;
      if (status === 'not_due') {
        const recheckMs = randomInRange(
          MIN_RECHECK_DELAY_MS,
          MAX_NOT_DUE_RECHECK_MS,
        );
        this.scheduleStep(options.characterId, generation, recheckMs, () => {
          void this.claimAndRender(options, generation);
        });
        keepTask = true;
        return;
      }

      if (status !== 'delivered') {
        options.onDrop?.(status ?? 'canceled');
        return;
      }

      const messages = fromPersistedStoryMessages(payload?.messages);
      if (messages.length > 0) {
        options.onMessages(messages);
      }
    } catch (error) {
      options.onError?.(error);
    } finally {
      if (!keepTask && this.isCurrent(options.characterId, generation)) {
        options.onTypingChange(false);
        this.taskByCharacter.delete(options.characterId);
      }
    }
  }
}

export const replyDeliveryController = new ReplyDeliveryController();
