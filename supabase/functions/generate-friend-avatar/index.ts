import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
import { authenticateUser } from "../_shared/auth.ts";
import type { ImageResponse } from "../_shared/llm/types.ts";

interface GenerateFriendAvatarRequest {
  gender: string;
  appearancePrompt: string;
  name: string;
  stylePreset: string;
}

type GenerateFriendAvatarErrorCode = "safety_blocked" | "unknown";

interface GenerateFriendAvatarResponse {
  success: boolean;
  data?: { avatarUrl: string };
  meta?: {
    provider: string;
    model: string;
    latencyMs: number;
  };
  error?: string;
  errorCode?: GenerateFriendAvatarErrorCode;
}

const BUCKET_NAME = "friend-avatars";

function buildGenderHint(gender: string): string {
  switch (gender) {
    case "male":
      return "handsome Korean man, defined jawline";
    case "female":
      return "beautiful Korean woman, elegant features";
    default:
      return "attractive Korean person, androgynous features";
  }
}

function buildStyleExpression(stylePreset: string): string {
  switch (stylePreset) {
    case "warm":
      return "warm smile, approachable expression";
    case "calm":
      return "serene composure, slightly aloof expression";
    case "chic":
      return "mysterious gaze, enigmatic expression";
    case "dreamy":
      return "bright cheerful expression, sparkling eyes";
    default:
      return "gentle expression";
  }
}

function buildPrompt(request: GenerateFriendAvatarRequest): string {
  const genderHint = buildGenderHint(request.gender);
  const styleExpression = buildStyleExpression(request.stylePreset);

  return `
Create a photorealistic portrait of a character for a chat app profile image.

Base description:
- A beautiful/handsome Korean person in their 20s-30s
- Photorealistic portrait, soft studio lighting, dark background
- Looking at camera with a gentle expression
- ${genderHint}
- ${styleExpression}

User's custom appearance description: ${request.appearancePrompt.slice(0, 300)}

Requirements:
- photorealistic, high quality portrait
- no text, no watermark, no logos
- safe everyday content only
- app-store-safe portrait only
- fully clothed, non-sexualized, no nudity
- no explicit sexual content, no suggestive posing
- single person portrait, face clearly visible
- suitable for a chat profile image
`.trim();
}

/**
 * Gemini 우선 시도 → safety 블록이면 Grok Aurora 자동 폴백.
 * 둘 다 실패하면 마지막 에러를 throw (SafetyBlockedError 우선 보존).
 */
async function generateImageWithFallback(
  prompt: string,
): Promise<ImageResponse> {
  const primary = LLMFactory.create("gemini", "gemini-2.5-flash-image");
  if (!primary.generateImage) {
    throw new Error("Gemini 이미지 생성 지원 불가");
  }

  try {
    return await primary.generateImage(prompt);
  } catch (primaryError) {
    const isSafetyBlocked = primaryError instanceof Error &&
      primaryError.name === "SafetyBlockedError";
    if (!isSafetyBlocked) throw primaryError;

    console.warn("[generate-friend-avatar] Gemini safety blocked → Grok 폴백 시도");
    const fallback = LLMFactory.create("grok", "grok-2-image-1212");
    if (!fallback.generateImage) {
      throw primaryError;
    }
    try {
      return await fallback.generateImage(prompt);
    } catch (fallbackError) {
      console.error("[generate-friend-avatar] Grok 폴백도 실패:", fallbackError);
      // 두 엔진 모두 실패 → 원본 Safety 에러 유지 (사용자 메시지 일관성)
      throw primaryError;
    }
  }
}

function buildStoragePath(name: string): string {
  const timestamp = Date.now();
  const uid = crypto.randomUUID().split("-")[0];
  const safeName = name.replace(/[^a-zA-Z0-9가-힣]/g, "_").slice(0, 20);
  return `custom/${safeName}/${timestamp}_${uid}.png`;
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const startedAt = Date.now();

  try {
    const { user, error: authError } = await authenticateUser(req);
    if (authError || !user) {
      return (
        authError ??
        new Response(
          JSON.stringify({
            success: false,
            error: "Unauthorized",
          } as GenerateFriendAvatarResponse),
          {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 401,
          },
        )
      );
    }

    const request = (await req.json()) as GenerateFriendAvatarRequest;

    if (!request.appearancePrompt || !request.gender) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "gender, appearancePrompt는 필수입니다",
        } as GenerateFriendAvatarResponse),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error("Supabase service role 환경변수가 설정되지 않았습니다");
    }

    const prompt = buildPrompt(request);
    const imageResult = await generateImageWithFallback(prompt);

    const imageBytes = Uint8Array.from(
      atob(imageResult.imageBase64),
      (c) => c.charCodeAt(0),
    );
    const storagePath = buildStoragePath(request.name || "friend");

    const supabase = createClient(supabaseUrl, serviceRoleKey);
    const { error: uploadError } = await supabase.storage
      .from(BUCKET_NAME)
      .upload(storagePath, imageBytes, {
        contentType: "image/png",
        upsert: false,
      });

    if (uploadError) {
      throw new Error(`이미지 업로드 실패: ${uploadError.message}`);
    }

    const { data: publicUrlData } = supabase.storage
      .from(BUCKET_NAME)
      .getPublicUrl(storagePath);

    return new Response(
      JSON.stringify({
        success: true,
        data: { avatarUrl: publicUrlData.publicUrl },
        meta: {
          provider: imageResult.provider,
          model: imageResult.model,
          latencyMs: imageResult.latency,
        },
      } as GenerateFriendAvatarResponse),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    const isSafetyBlocked = error instanceof Error &&
      error.name === "SafetyBlockedError";

    const body: GenerateFriendAvatarResponse = {
      success: false,
      error: isSafetyBlocked
        ? "실명 연예인 등은 생성이 어려워요. 헤어스타일, 분위기 같은 일반적인 특징으로 묘사해주세요."
        : error instanceof Error
        ? error.message
        : "Unknown error",
      errorCode: isSafetyBlocked ? "safety_blocked" : "unknown",
      meta: {
        provider: "gemini",
        model: "gemini-2.5-flash-image",
        latencyMs: Date.now() - startedAt,
      },
    };

    return new Response(JSON.stringify(body), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: isSafetyBlocked ? 400 : 500,
    });
  }
});
