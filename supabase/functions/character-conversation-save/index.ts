/**
 * 캐릭터 대화 스레드 저장 Edge Function
 *
 * @description 유저-캐릭터 조합의 대화 스레드를 저장/업데이트합니다.
 * 최근 50개 메시지만 저장합니다.
 *
 * @endpoint POST /character-conversation-save
 *
 * @requestBody
 * - characterId: string - 캐릭터 ID
 * - messages: Array<{id, type, content, timestamp}> - 저장할 메시지 배열
 *
 * @response
 * - success: boolean
 * - messageCount: number - 저장된 메시지 수
 * - error?: string
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders, handleCors } from "../_shared/cors.ts";
import {
  loadUserCharacterAffinity,
  maybeRefreshCharacterMemory,
} from "../_shared/character_memory.ts";

interface ChatMessage {
  id: string;
  type: "user" | "character" | "system" | "narration";
  content: string;
  timestamp: string;
}

interface RuntimeStatePayload {
  personaKey?: string;
  romanceState?: Record<string, unknown>;
  sceneIntent?: string;
  responseGoal?: string;
  safeAffectionCap?: number;
  followUpHint?: string | null;
  [key: string]: unknown;
}

interface SaveRequest {
  characterId: string;
  messages: ChatMessage[];
  runtimeState?: RuntimeStatePayload | null;
}

interface SaveResponse {
  success: boolean;
  messageCount: number;
  error?: string;
}

// 클라이언트의 REMOTE_PERSIST_MESSAGE_CAP 과 동기화. 활성 유저가 몇 세션 만에
// 50을 초과하면, load 시 원격이 잘린 상태로 돌아오고 focus 재하이드레이션이
// 로컬을 stripped 버전으로 덮어써 비-텍스트 카드를 영구 소실시키던 원인.
const MAX_MESSAGES = 200;

serve(async (req: Request) => {
  // CORS 처리
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // 인증 확인
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify(
          {
            success: false,
            messageCount: 0,
            error: "Missing authorization header",
          } as SaveResponse,
        ),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    const token = authHeader.replace("Bearer ", "");

    // Supabase 클라이언트 (사용자 컨텍스트)
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_ANON_KEY")!,
      { global: { headers: { Authorization: authHeader } } },
    );

    // 사용자 확인
    const { data: { user }, error: authError } = await supabase.auth.getUser(
      token,
    );
    if (authError || !user) {
      return new Response(
        JSON.stringify(
          {
            success: false,
            messageCount: 0,
            error: "Invalid token",
          } as SaveResponse,
        ),
        {
          status: 401,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 요청 파싱
    const { characterId, messages, runtimeState }: SaveRequest = await req.json();

    if (!characterId) {
      return new Response(
        JSON.stringify(
          {
            success: false,
            messageCount: 0,
            error: "characterId is required",
          } as SaveResponse,
        ),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (!Array.isArray(messages)) {
      return new Response(
        JSON.stringify(
          {
            success: false,
            messageCount: 0,
            error: "messages array is required",
          } as SaveResponse,
        ),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (
      runtimeState !== undefined &&
      runtimeState !== null &&
      (typeof runtimeState !== "object" || Array.isArray(runtimeState))
    ) {
      return new Response(
        JSON.stringify(
          {
            success: false,
            messageCount: 0,
            error: "runtimeState must be an object when provided",
          } as SaveResponse,
        ),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 최근 50개만 저장 (오래된 메시지 제거)
    const limitedMessages = messages.slice(-MAX_MESSAGES);

    // UPSERT: 기존 대화 업데이트 또는 새로 생성
    const { error: upsertError } = await supabase
      .from("character_conversations")
      .upsert(
        {
          user_id: user.id,
          character_id: characterId,
          messages: limitedMessages,
          runtime_state: runtimeState ?? {},
          last_message_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        },
        { onConflict: "user_id,character_id" },
      );

    if (upsertError) {
      console.error("Upsert error:", upsertError);
      return new Response(
        JSON.stringify(
          {
            success: false,
            messageCount: 0,
            error: upsertError.message,
          } as SaveResponse,
        ),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    // 장기 메모리 요약 갱신 (soft-fail: 저장 성공을 막지 않음)
    try {
      const affinityContext = await loadUserCharacterAffinity(
        supabase,
        user.id,
        characterId,
      );

      const memoryResult = await maybeRefreshCharacterMemory({
        supabase,
        userId: user.id,
        characterId,
        messages: limitedMessages,
        affinityContext,
      });

      if (memoryResult.refreshed) {
        console.log(
          `[character-conversation-save] memory refreshed for user=${user.id}, character=${characterId}`,
        );
      }
    } catch (memoryError) {
      console.warn(
        `[character-conversation-save] memory refresh skipped (soft-fail): ${
          memoryError instanceof Error
            ? memoryError.message
            : String(memoryError)
        }`,
      );
    }

    console.log(
      `[character-conversation-save] User ${user.id} saved ${limitedMessages.length} messages for character ${characterId}`,
    );

    return new Response(
      JSON.stringify(
        { success: true, messageCount: limitedMessages.length } as SaveResponse,
      ),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("character-conversation-save error:", error);
    return new Response(
      JSON.stringify({
        success: false,
        messageCount: 0,
        error: error instanceof Error ? error.message : "Unknown error",
      } as SaveResponse),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
