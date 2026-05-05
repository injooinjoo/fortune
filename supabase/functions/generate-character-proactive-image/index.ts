import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
import { authenticateUser } from "../_shared/auth.ts";
import { chargeTokens, refundTokens } from "../_shared/token_charge.ts";
import type { ImageResponse } from "../_shared/llm/types.ts";

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

    console.warn("[proactive-image] Gemini safety blocked → Grok 폴백 시도");
    const fallback = LLMFactory.create("grok", "grok-2-image-1212");
    if (!fallback.generateImage) throw primaryError;
    try {
      return await fallback.generateImage(prompt);
    } catch (fallbackError) {
      console.error("[proactive-image] Grok 폴백도 실패:", fallbackError);
      throw primaryError;
    }
  }
}

type ProactiveImageCategory =
  | "meal"
  | "workout"
  | "selfie"
  | "cafe"
  | "commute"
  | "night";

interface GenerateCharacterProactiveImageRequest {
  characterId: string;
  category: ProactiveImageCategory;
  contextText?: string;
  styleHint?: string;
  timeSlot?: string;
  weatherHint?: string;
  locationHint?: string;
}

type GenerateCharacterProactiveImageErrorCode = "safety_blocked" | "unknown";

interface GenerateCharacterProactiveImageResponse {
  success: boolean;
  imageUrl?: string;
  meta?: {
    provider: string;
    model: string;
    latencyMs: number;
  };
  error?: string;
  errorCode?: GenerateCharacterProactiveImageErrorCode;
}

const SUPPORTED_CHARACTER_IDS = new Set([
  "luts",
  "jung_tae_yoon",
  "seo_yoonjae",
  "kang_harin",
  "jayden_angel",
  "ciel_butler",
  "lee_doyoon",
  "han_seojun",
  "baek_hyunwoo",
  "min_junhyuk",
]);
const BUCKET_NAME = "character-proactive-images";

// 이미지 1장 생성 원가 ≈ ₩52 (gemini-2.5-flash-image 기준).
// 마진과 사용자 perception 고려해 50 토큰 차감.
const PROACTIVE_IMAGE_TOKEN_COST = 50;

function isValidCategory(value: string): value is ProactiveImageCategory {
  return [
    "selfie",
    "meal",
    "cafe",
    "commute",
    "workout",
    "night",
  ].includes(value);
}

function characterVisualHint(characterId: string): string {
  const hints: Record<string, string> = {
    luts: "adult East Asian man, silver hair, refined detective mood",
    jung_tae_yoon:
      "adult East Asian man, neat office styling, calm lawyer vibe",
    seo_yoonjae:
      "adult East Asian man, stylish casual look, playful confident vibe",
    kang_harin:
      "adult East Asian woman, polished professional look, elegant calm vibe",
    jayden_angel:
      "adult East Asian man, soft ethereal styling, gentle mysterious vibe",
    ciel_butler:
      "adult East Asian man, formal butler-inspired styling, composed demeanor",
    lee_doyoon:
      "adult East Asian man, bright approachable styling, warm athletic vibe",
    han_seojun: "adult East Asian man, dark casual styling, quiet cool vibe",
    baek_hyunwoo:
      "adult East Asian man, clean smart styling, observant composed vibe",
    min_junhyuk:
      "adult East Asian man, warm modern casual styling, reliable caring vibe",
  };

  return hints[characterId] ??
    "adult East Asian character, natural daily styling";
}

function buildPrompt(request: GenerateCharacterProactiveImageRequest): string {
  const baseToneByCategory: Record<ProactiveImageCategory, string> = {
    selfie:
      "A natural smartphone selfie in a real daily-life setting. Comfortable styling, candid expression, realistic lighting.",
    meal:
      "A natural smartphone snapshot of a meal or tray on a table. Cozy everyday dining mood, realistic home or casual restaurant lighting.",
    cafe:
      "A natural smartphone snapshot in a cafe with coffee or dessert nearby. Relaxed daily-life atmosphere, candid composition.",
    commute:
      "A natural smartphone snapshot during a commute. Train, subway, bus stop, or city street mood, everyday candid realism.",
    workout:
      "A natural smartphone snapshot after exercise. Gym or light workout context, candid realistic style, no brand logos.",
    night:
      "A natural smartphone snapshot during a calm night outing or at home near a window. Soft city lights or warm indoor night mood.",
  };

  const environmentHints = [
    request.timeSlot ? `Time slot: ${request.timeSlot}` : "",
    request.weatherHint ? `Weather hint: ${request.weatherHint}` : "",
    request.locationHint ? `Location hint: ${request.locationHint}` : "",
  ].filter(Boolean);

  const contextPart = request.contextText
    ? `Context from recent chat: ${request.contextText.slice(0, 160)}`
    : "";
  const styleHintPart = request.styleHint
    ? `Style hint: ${request.styleHint}`
    : "";
  const environmentPart = environmentHints.join("\n");

  return `
Create a realistic phone photo for a character chat follow-up.
- Character: ${request.characterId}
- Character visual hint: ${characterVisualHint(request.characterId)}
- Category: ${request.category}
- Visual direction: ${baseToneByCategory[request.category]}
${contextPart}
${styleHintPart}
${environmentPart}

Requirements:
- photorealistic, candid, not studio
- no text, no watermark, no logos
- safe everyday content only
- app-store-safe daily-life scene only
- fully clothed, non-sexualized, no lingerie, no nudity
- no explicit sexual content, no suggestive posing, no fetish framing
- single image
`.trim();
}

function buildStoragePath(
  characterId: string,
  category: ProactiveImageCategory,
): string {
  const timestamp = Date.now();
  const uid = crypto.randomUUID().split("-")[0];
  return `${characterId}/${category}/${timestamp}_${uid}.png`;
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  // Slice 2 (2026-05-05): AI 이미지 생성 비활성. /autoplan A3 결정.
  // proactive-message-dispatch 가 이 함수 대신 character-proactive-images 버킷의
  // 정적 placeholder (사용자 큐레이션) 를 사용하도록 우회됨. Slice 3 에서 큐레이션
  // 게이트(생성 → 사용자 1-click 승인 → Storage 적재) 와 함께 재가동 검토.
  // 코드는 보존 — 재가동 시 이 가드 블록만 제거하면 됨.
  return new Response(
    JSON.stringify(
      {
        success: false,
        error:
          "이 함수는 Slice 2 기간 비활성화됨. character-proactive-images 버킷의 정적 placeholder 를 사용하세요. (PROACTIVE_MESSAGING_PLAN.md Slice 2 §2.4)",
        errorCode: "disabled_for_slice_2",
      } satisfies GenerateCharacterProactiveImageResponse & { errorCode: string },
    ),
    {
      status: 410,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    },
  );

  // 아래 본 핸들러는 Slice 3 큐레이션 게이트 합류 전까지 dead code.
  // deno-lint-ignore no-unreachable
  const startedAt = Date.now();

  try {
    const { user, error: authError } = await authenticateUser(req);
    if (authError || !user) {
      return authError ?? new Response(
        JSON.stringify(
          {
            success: false,
            error: "Unauthorized",
          } as GenerateCharacterProactiveImageResponse,
        ),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 401,
        },
      );
    }

    const request =
      (await req.json()) as GenerateCharacterProactiveImageRequest;

    if (!request.characterId || !request.category) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "characterId, category는 필수입니다",
        } as GenerateCharacterProactiveImageResponse),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    if (!SUPPORTED_CHARACTER_IDS.has(request.characterId)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "지원되지 않는 캐릭터입니다",
        } as GenerateCharacterProactiveImageResponse),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    if (!isValidCategory(request.category)) {
      return new Response(
        JSON.stringify({
          success: false,
          error:
            "category는 selfie | meal | cafe | commute | workout | night만 허용됩니다",
        } as GenerateCharacterProactiveImageResponse),
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

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // 토큰 차감 (₩52/장 적자 차단). 무제한 구독자 통과. LLM 호출 + storage
    // upload 까지 한 try 블록으로 감싸 어디서 실패해도 환불 보장.
    const chargeCtx = {
      description: "캐릭터 선톡 이미지",
      referenceType: "proactive_image",
      referenceId: request.characterId,
    };
    const charge = await chargeTokens(
      supabase,
      user.id,
      PROACTIVE_IMAGE_TOKEN_COST,
      chargeCtx,
    );

    if (!charge.charged && !charge.unlimited) {
      return new Response(
        JSON.stringify({
          success: false,
          error: "토큰이 부족합니다",
          errorCode: "unknown",
        } as GenerateCharacterProactiveImageResponse),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 402,
        },
      );
    }

    let imageResult: ImageResponse;
    let storagePath: string;
    let publicUrl: string;
    try {
      const prompt = buildPrompt(request);
      imageResult = await generateImageWithFallback(prompt);

      const imageBytes = Uint8Array.from(
        atob(imageResult.imageBase64),
        (c) => c.charCodeAt(0),
      );
      storagePath = buildStoragePath(request.characterId, request.category);

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
      publicUrl = publicUrlData.publicUrl;
    } catch (workError) {
      if (charge.charged) {
        await refundTokens(
          supabase,
          user.id,
          PROACTIVE_IMAGE_TOKEN_COST,
          charge.balanceBeforeCharge,
          chargeCtx,
        );
      }
      throw workError;
    }

    return new Response(
      JSON.stringify({
        success: true,
        imageUrl: publicUrl,
        meta: {
          provider: imageResult.provider,
          model: imageResult.model,
          latencyMs: imageResult.latency,
        },
      } as GenerateCharacterProactiveImageResponse),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    const isSafetyBlocked = error instanceof Error &&
      error.name === "SafetyBlockedError";

    const body: GenerateCharacterProactiveImageResponse = {
      success: false,
      error: isSafetyBlocked
        ? "안전 정책으로 인해 이미지 생성이 차단됐어요."
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
