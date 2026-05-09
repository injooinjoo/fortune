import { type SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

export interface ScheduledReplyMessage {
  id: string;
  type: "character";
  content: string;
  timestamp: string;
  emotionTag?: string;
}

export interface ScheduledReplyInput {
  scheduledId: string;
  content: string;
  segments?: string[] | null;
  emotionTag?: string | null;
  timestamp?: string;
}

export function normalizeScheduledSegments(
  input: Pick<ScheduledReplyInput, "content" | "segments">,
): string[] {
  const segments = Array.isArray(input.segments)
    ? input.segments
      .filter((segment): segment is string => typeof segment === "string")
      .map((segment) => segment.trim())
      .filter((segment) => segment.length > 0)
    : [];
  if (segments.length > 0) return segments;
  const fallback = input.content.trim();
  return fallback.length > 0 ? [fallback] : [];
}

export function buildScheduledReplyMessages(
  input: ScheduledReplyInput,
): ScheduledReplyMessage[] {
  const segments = normalizeScheduledSegments(input);
  const timestamp = input.timestamp ?? new Date().toISOString();
  const useSegmentIds = segments.length > 1;

  return segments.map((content, index) => {
    const message: ScheduledReplyMessage = {
      id: useSegmentIds
        ? `scheduled-${input.scheduledId}-${index}`
        : `scheduled-${input.scheduledId}`,
      type: "character",
      content,
      timestamp,
    };
    if (input.emotionTag) {
      message.emotionTag = input.emotionTag;
    }
    return message;
  });
}

export async function persistScheduledReplyMessages(input: {
  supabase: SupabaseClient;
  userId: string;
  characterId: string;
  messages: ScheduledReplyMessage[];
  maxMessages?: number;
}): Promise<{ persistedCount: number; persistError?: string }> {
  if (input.messages.length === 0) {
    return { persistedCount: 0 };
  }

  const { data: mergedCount, error } = await input.supabase.rpc(
    "merge_character_conversation_messages",
    {
      p_user_id: input.userId,
      p_character_id: input.characterId,
      p_incoming_messages: input.messages,
      p_runtime_state: null,
      p_max_messages: input.maxMessages ?? 200,
    },
  );

  return {
    persistedCount: typeof mergedCount === "number" && !error
      ? input.messages.length
      : 0,
    persistError: error?.message,
  };
}
