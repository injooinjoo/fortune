import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
import { authenticateUser } from "../_shared/auth.ts";

interface GenerateFriendAvatarRequest {
  gender: string;
  appearancePrompt: string;
  name: string;
  stylePreset: string;
}

interface GenerateFriendAvatarResponse {
  success: boolean;
  data?: { avatarUrl: string };
  meta?: {
    provider: string;
    model: string;
    latencyMs: number;
  };
  error?: string;
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

    const llm = LLMFactory.create("gemini", "gemini-2.5-flash-image");
    if (!llm.generateImage) {
      throw new Error("선택된 모델이 이미지 생성을 지원하지 않습니다");
    }

    const prompt = buildPrompt(request);
    const imageResult = await llm.generateImage(prompt);

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
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
        meta: {
          provider: "gemini",
          model: "gemini-2.5-flash-image",
          latencyMs: Date.now() - startedAt,
        },
      } as GenerateFriendAvatarResponse),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      },
    );
  }
});
