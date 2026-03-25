import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

import { corsHeaders, handleCors } from "../_shared/cors.ts";
import { LLMFactory } from "../_shared/llm/factory.ts";
import { authenticateUser } from "../_shared/auth.ts";

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

interface GenerateCharacterProactiveImageResponse {
  success: boolean;
  imageUrl?: string;
  meta?: {
    provider: string;
    model: string;
    latencyMs: number;
  };
  error?: string;
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
    const storagePath = buildStoragePath(request.characterId, request.category);

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
        imageUrl: publicUrlData.publicUrl,
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
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : "Unknown error",
        meta: {
          provider: "gemini",
          model: "gemini-2.5-flash-image",
          latencyMs: Date.now() - startedAt,
        },
      } as GenerateCharacterProactiveImageResponse),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      },
    );
  }
});
