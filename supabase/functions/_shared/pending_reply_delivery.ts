import { type SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

import { sendCharacterDmPush } from "./notification_push.ts";
import {
  persistScheduledReplyMessages,
  type ScheduledReplyMessage,
} from "./scheduled_reply_message.ts";

interface CharacterChatReplyResponse {
  success?: boolean;
  scheduledId?: string | null;
  response?: string;
  segments?: unknown;
  emotionTag?: string | null;
  status?: string;
  meta?: { provider?: string } | null;
}

export interface ImmediateReplyDeliveryPlan {
  shouldDeliver: boolean;
  reason?:
    | "chat_failed"
    | "scheduled_reply"
    | "superseded"
    | "noop_provider"
    | "empty_content";
  content: string;
  segments: string[];
  messages: ScheduledReplyMessage[];
  emotionTag?: string | null;
}

export interface DeliverImmediateReplyInput {
  supabase: SupabaseClient;
  userId: string;
  characterId: string;
  characterName: string;
  jobId: string;
  chatData: unknown;
  roomState?: string;
  maxMessages?: number;
}

export interface DeliverImmediateReplyResult
  extends ImmediateReplyDeliveryPlan {
  persistedCount: number;
  pushSentCount: number;
  pushSkipped: boolean;
  pushSkipReason?: string;
  persistError?: string;
}

function normalizeSegments(segments: unknown): string[] {
  return Array.isArray(segments)
    ? segments
      .filter((segment): segment is string => typeof segment === "string")
      .map((segment) => segment.trim())
      .filter((segment) => segment.length > 0)
    : [];
}

function buildImmediateReplyMessages(input: {
  jobId: string;
  content: string;
  emotionTag?: string | null;
}): ScheduledReplyMessage[] {
  const message: ScheduledReplyMessage = {
    // Use one stable entity per pending job. If character-chat is retried and
    // the LLM flips between response/segments shapes, id-based RPC dedupe still
    // prevents duplicate bubbles for the same job.
    id: input.jobId,
    type: "character",
    content: input.content,
    timestamp: new Date().toISOString(),
  };
  if (input.emotionTag) message.emotionTag = input.emotionTag;
  return [message];
}

export function planImmediateReplyDelivery(params: {
  jobId: string;
  chatData: unknown;
}): ImmediateReplyDeliveryPlan {
  const directResponse = (params.chatData ?? {}) as CharacterChatReplyResponse;
  const responseSuccess = directResponse.success ?? true;
  if (!responseSuccess) {
    return {
      shouldDeliver: false,
      reason: "chat_failed",
      content: "",
      segments: [],
      messages: [],
    };
  }
  if (directResponse.scheduledId != null) {
    return {
      shouldDeliver: false,
      reason: "scheduled_reply",
      content: "",
      segments: [],
      messages: [],
    };
  }
  if (directResponse.status === "superseded") {
    return {
      shouldDeliver: false,
      reason: "superseded",
      content: "",
      segments: [],
      messages: [],
    };
  }
  if (directResponse.meta?.provider === "noop") {
    return {
      shouldDeliver: false,
      reason: "noop_provider",
      content: "",
      segments: [],
      messages: [],
    };
  }

  const segments = normalizeSegments(directResponse.segments);
  const content = segments.length > 0
    ? segments.join("\n")
    : (directResponse.response ?? "").trim();
  if (content.length === 0) {
    return {
      shouldDeliver: false,
      reason: "empty_content",
      content,
      segments,
      messages: [],
    };
  }

  return {
    shouldDeliver: true,
    content,
    segments,
    emotionTag: directResponse.emotionTag ?? null,
    messages: buildImmediateReplyMessages({
      jobId: params.jobId,
      content,
      emotionTag: directResponse.emotionTag,
    }),
  };
}

export async function deliverImmediateReplyIfNeeded(
  input: DeliverImmediateReplyInput,
): Promise<DeliverImmediateReplyResult> {
  const plan = planImmediateReplyDelivery({
    jobId: input.jobId,
    chatData: input.chatData,
  });

  if (!plan.shouldDeliver) {
    return {
      ...plan,
      persistedCount: 0,
      pushSentCount: 0,
      pushSkipped: true,
      pushSkipReason: plan.reason,
    };
  }

  const persistResult = await persistScheduledReplyMessages({
    supabase: input.supabase,
    userId: input.userId,
    characterId: input.characterId,
    messages: plan.messages,
    maxMessages: input.maxMessages,
  });

  if (persistResult.persistError) {
    return {
      ...plan,
      persistedCount: persistResult.persistedCount,
      persistError: persistResult.persistError,
      pushSentCount: 0,
      pushSkipped: true,
      pushSkipReason: "persist_failed",
    };
  }

  const pushResult = await sendCharacterDmPush({
    supabase: input.supabase,
    userId: input.userId,
    characterId: input.characterId,
    characterName: input.characterName,
    messageText: plan.content,
    messageId: plan.messages[0]?.id,
    scheduledMessagesJson: JSON.stringify(plan.messages),
    type: "character_dm",
    roomState: input.roomState ?? "character_chat",
  });

  return {
    ...plan,
    persistedCount: persistResult.persistedCount,
    persistError: persistResult.persistError,
    pushSentCount: pushResult.sentCount,
    pushSkipped: pushResult.skipped,
    pushSkipReason: pushResult.reason,
  };
}
