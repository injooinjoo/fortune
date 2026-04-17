import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { OpenAIProvider } from "../_shared/llm/providers/openai.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const TALISMAN_IMAGE_MODEL = "gpt-image-1-mini";
const TALISMAN_STORAGE_BUCKET = "talisman-images";
const DEFAULT_TALISMAN_SCORE = 88;

type TalismanGenerationMode = "prebuilt" | "premium_ai";
type TalismanImageSource = "catalog" | "generated" | "none";

interface TalismanRequest {
  userId: string;
  category: string;
  characters?: string[];
  generationMode?: TalismanGenerationMode | string;
  purpose?: string;
  situation?: string;
}

interface TalismanPromptConfig {
  purpose: string;
  purposeKr: string;
  mood: string;
  colorIntensity: string;
  animalSymbol: string;
  geometricPattern: string;
  specialElements: string;
  defaultCharacters: string[];
  shortDescription: string;
}

interface CatalogAsset {
  id: string;
  imageUrl: string;
  title: string;
}

interface TalismanResponseData {
  fortuneType: "talisman";
  title: string;
  score: number;
  advice: string;
  id: string;
  imageUrl: string;
  category: string;
  categoryName: string;
  shortDescription: string;
  characters: string[];
  content: string;
  summary: string;
  recommendations: string[];
  generationMode: TalismanGenerationMode;
  imageSource: TalismanImageSource;
  catalogAssetId?: string;
  imageGenerationFailed?: boolean;
  imageGenerationFailureReason?: string;
  warnings?: string[];
  imageGenerationSkipped?: boolean;
  imageGenerationReason?: string;
  reusedFromPool?: boolean;
  sourceImageId?: string;
  timestamp: string;
}

const CATEGORY_CONFIGS: Record<string, TalismanPromptConfig> = {
  disease_prevention: {
    purpose: "disease prevention and healing (질병 퇴치)",
    purposeKr: "질병 퇴치",
    mood: "powerful protective energy, fierce guardian spirit",
    colorIntensity: "deep cinnabar red (#D32F2F) with bold, confident strokes",
    animalSymbol:
      "a fierce tiger (호랑이) with exaggerated claws and intense eyes, facing forward in guardian stance",
    geometricPattern:
      "spiral vortex patterns (와문형) representing life energy circulation, radiating from center",
    specialElements: "protective barrier circles, healing energy symbols",
    defaultCharacters: ["病退散", "藥神降臨"],
    shortDescription:
      "질병과 나쁜 기운을 물리치는 부적입니다. 침실이나 현관에 붙여두고, 아침마다 한 번 바라보며 건강을 빌어보세요.",
  },
  love_relationship: {
    purpose: "love and harmonious relationships (부부화합)",
    purposeKr: "사랑 성취",
    mood: "gentle romantic energy, tender connection",
    colorIntensity:
      "soft rose-tinted red (#EF5350) with graceful, flowing strokes",
    animalSymbol:
      "a pair of mandarin ducks (원앙) or butterflies facing each other, symbolizing eternal love",
    geometricPattern:
      "decorative Korean knot patterns (매듭), intertwining circles representing union",
    specialElements: "heart motifs, flower decorations, clouds",
    defaultCharacters: ["夫婦和合", "百年好合"],
    shortDescription:
      "사랑과 좋은 인연을 불러오는 부적입니다. 지갑이나 핸드폰 케이스에 넣어 늘 가까이 지니세요.",
  },
  wealth_career: {
    purpose: "wealth abundance and career success (재물운)",
    purposeKr: "재물운",
    mood: "prosperous authoritative energy, ascending fortune",
    colorIntensity: "bold cinnabar red with gold accent highlights (#FFD700)",
    animalSymbol:
      "a majestic dragon (용) with cloud swirls and a treasure pearl (여의주)",
    geometricPattern:
      "staircase ascending patterns representing promotion, layered tower shapes",
    specialElements: "coin motifs, treasure symbols, upward-pointing arrows",
    defaultCharacters: ["財祿豊盈", "官運亨通"],
    shortDescription:
      "재물과 성공을 불러오는 부적입니다. 지갑이나 금고 근처에 두고, 매일 아침 바라보며 소원을 빌어보세요.",
  },
  disaster_removal: {
    purpose: "protection from three disasters - fire, water, wind (삼재소멸)",
    purposeKr: "삼재 소멸",
    mood: "intensely protective barrier energy, cosmic shield",
    colorIntensity: "intense deep red (#B71C1C) with heavy, commanding strokes",
    animalSymbol:
      "a three-legged crow/hawk (삼족오) with spread wings, representing solar power",
    geometricPattern:
      "eight trigrams (팔괘) arranged in circle, triangular repetitive patterns",
    specialElements:
      "protective circle barriers, cosmic diagrams, elemental symbols",
    defaultCharacters: ["三災消滅", "厄運退散"],
    shortDescription:
      "삼재와 액운을 막아주는 부적입니다. 현관문 안쪽에 붙여두고, 외출 전 한 번 바라보세요.",
  },
  home_protection: {
    purpose: "home peace and family protection (가내평안)",
    purposeKr: "안택",
    mood: "warm nurturing protection, stable foundation",
    colorIntensity:
      "warm guardian red (#E53935) with steady, confident strokes",
    animalSymbol:
      "a guardian tiger positioned as house protector, watchful but calm",
    geometricPattern:
      "square and rectangular patterns symbolizing home structure, stable foundations",
    specialElements:
      "four directional guardians symbols, doorway motifs, roof patterns",
    defaultCharacters: ["家內平安", "安宅大吉"],
    shortDescription:
      "가정의 평안과 화목을 지키는 부적입니다. 거실이나 가족이 모이는 곳에 두고, 온 가족이 함께 바라보세요.",
  },
  academic_success: {
    purpose: "academic achievement and examination success (급제)",
    purposeKr: "학업 성취",
    mood: "intellectual ascending energy, focused clarity",
    colorIntensity:
      "red with blue accents (#1976D2 touches) representing wisdom",
    animalSymbol:
      "a crane (학) or eagle with spread wings, holding a calligraphy brush",
    geometricPattern:
      "ascending staircase patterns, layered tower shapes representing achievement",
    specialElements: "book motifs, ascending clouds, scholarly symbols",
    defaultCharacters: ["及第及第", "文昌帝君"],
    shortDescription:
      "학업 성취와 합격을 기원하는 부적입니다. 책상 위나 필통에 넣어두고, 공부 전 한 번 바라보세요.",
  },
  health_longevity: {
    purpose: "health and long life (무병장수)",
    purposeKr: "건강 장수",
    mood: "majestic sacred vitality, eternal blessing",
    colorIntensity: "red with gold highlights, sacred golden accents",
    animalSymbol:
      "a crane and turtle (학과 거북이) together, traditional longevity symbols",
    geometricPattern:
      "circular endless patterns representing completeness and cycles of life",
    specialElements: "peach motifs (longevity), pine trees, clouds of blessing",
    defaultCharacters: ["無病長壽", "福祿壽康"],
    shortDescription:
      "건강과 장수를 기원하는 부적입니다. 침대 머리맡이나 거울 옆에 두고, 매일 아침 감사하며 바라보세요.",
  },
};

function normalizeGenerationMode(
  value: unknown,
): TalismanGenerationMode {
  return value === "prebuilt" ? "prebuilt" : "premium_ai";
}

function buildTalismanPrompt(config: TalismanPromptConfig): string {
  return `A traditional Korean bujeok (부적) talisman, vertical portrait orientation (2:3 aspect ratio),
hand-painted on aged yellow hanji paper (rice paper) with cinnabar vermillion red ink.

The talisman features:
- **Central mystical symbols** that resemble deconstructed Chinese characters (파자 style)
  but are actually esoteric shamanic glyphs - not readable as standard Chinese.
  These should appear as broken, reconstructed character-like shapes with overlapping
  components, ancient seal script inspired forms, and abstract mystical symbol patterns.
- **${config.animalSymbol}** drawn in traditional Korean folk art style with bold brushstrokes
- **${config.geometricPattern}** arranged symmetrically around the central symbols
- A red square seal stamp (낙관) at the bottom corner
- ${config.specialElements}
- Taoist/Buddhist mystical diagrams and protective circles

Purpose: ${config.purpose}

Visual qualities:
- Visible brushstroke texture with varying ink thickness
- Aged yellow paper with subtle grain and slight imperfections (#FFF4C4 base color)
- ${config.colorIntensity}
- Hand-drawn calligraphy appearance, NOT computer-generated fonts
- Traditional Korean shamanic (무속) art aesthetic
- Symmetrical composition with central vertical axis
- Vertical format optimized for mobile phone display

Mood and atmosphere: ${config.mood}

Style: Authentic Korean folk talisman art, detailed traditional brushwork,
mystical protective aesthetic, hand-painted appearance on aged paper.

DO NOT include: modern fonts, digital text, readable Chinese characters,
3D effects, photorealistic textures, anime style, English text,
Arabic numerals, gradients, shadows, glossy effects, western calligraphy.`;
}

const IMAGE_RETRY_DELAYS_MS = [0, 2_000, 6_000];

function isTransientImageError(error: unknown): boolean {
  const message = error instanceof Error ? error.message : String(error ?? "");
  if (!message) return false;
  if (message.includes("OPENAI_API_KEY")) return false;
  if (message.includes("LLM_ALLOW_HIGH_COST_MODELS")) return false;
  if (/\b(408|409|425|429|500|502|503|504)\b/.test(message)) return true;
  if (/timeout|timed out|fetch failed|ECONNRESET|ETIMEDOUT|socket/i.test(message)) return true;
  return false;
}

async function generateImageWithOpenAI(
  prompt: string,
): Promise<string> {
  if (!OPENAI_API_KEY) {
    throw new Error("OPENAI_API_KEY is missing");
  }

  const provider = new OpenAIProvider({
    apiKey: OPENAI_API_KEY,
    model: TALISMAN_IMAGE_MODEL,
    featureName: "generate-talisman",
  });

  let lastError: unknown;
  for (let attempt = 0; attempt < IMAGE_RETRY_DELAYS_MS.length; attempt += 1) {
    const delay = IMAGE_RETRY_DELAYS_MS[attempt];
    if (delay > 0) {
      console.warn(
        `⏳ Retrying talisman image generation in ${delay}ms (attempt ${attempt + 1})`,
      );
      await new Promise((resolve) => setTimeout(resolve, delay));
    }

    try {
      console.log(
        `🎨 Generating talisman with OpenAI... (attempt ${attempt + 1})`,
      );
      const result = await provider.generateImage!(prompt, {
        model: TALISMAN_IMAGE_MODEL,
        size: "1024x1536",
        quality: "medium",
      });
      console.log(
        `✅ Image generated successfully (${result.provider}/${result.model})`,
      );
      console.log(`⏱️ Generation time: ${result.latency}ms`);
      return result.imageBase64;
    } catch (err) {
      lastError = err;
      if (!isTransientImageError(err)) {
        throw err;
      }
    }
  }

  throw lastError instanceof Error
    ? lastError
    : new Error(`Image generation failed: ${String(lastError)}`);
}

function getErrorMessage(error: unknown): string {
  return error instanceof Error
    ? error.message
    : String(error ?? "Unknown error");
}

function classifyImageFallbackReason(error: unknown): string {
  const message = getErrorMessage(error);

  if (message.includes("LLM_ALLOW_HIGH_COST_MODELS")) {
    return "high_cost_model_blocked";
  }

  if (message.includes("OPENAI_API_KEY")) {
    return "openai_api_key_missing";
  }

  if (message.includes("Upload failed")) {
    return "storage_upload_failed";
  }

  if (message.includes("No image data")) {
    return "image_missing";
  }

  if (message.includes("OpenAI") || message.includes("gpt-image")) {
    return "image_api_failed";
  }

  return "image_generation_failed";
}

function buildTalismanRecommendations(
  config: TalismanPromptConfig,
): string[] {
  return [
    config.shortDescription,
    "중요한 일정 전에는 부적의 의미를 한 번 떠올리며 마음을 정돈해 보세요.",
  ];
}

function buildTalismanResponseData(
  params: {
    id: string;
    imageUrl: string;
    category: string;
    config: TalismanPromptConfig;
    characters: string[];
    generationMode: TalismanGenerationMode;
    imageSource: TalismanImageSource;
    catalogAssetId?: string;
    warnings?: string[];
    imageGenerationFailed?: boolean;
    imageGenerationFailureReason?: string;
    imageGenerationSkipped?: boolean;
    imageGenerationReason?: string;
    reusedFromPool?: boolean;
    sourceImageId?: string;
  },
): TalismanResponseData {
  const summary = params.config.shortDescription;

  return {
    fortuneType: "talisman",
    title: "부적",
    score: DEFAULT_TALISMAN_SCORE,
    advice: params.config.shortDescription,
    id: params.id,
    imageUrl: params.imageUrl,
    category: params.category,
    categoryName: params.config.purposeKr,
    shortDescription: params.config.shortDescription,
    characters: params.characters,
    content: summary,
    summary,
    recommendations: buildTalismanRecommendations(params.config),
    generationMode: params.generationMode,
    imageSource: params.imageSource,
    ...(params.catalogAssetId != null
      ? { catalogAssetId: params.catalogAssetId }
      : {}),
    ...(params.warnings != null && params.warnings.length > 0
      ? { warnings: params.warnings }
      : {}),
    ...(params.imageGenerationFailed != null
      ? { imageGenerationFailed: params.imageGenerationFailed }
      : {}),
    ...(params.imageGenerationFailureReason != null
      ? { imageGenerationFailureReason: params.imageGenerationFailureReason }
      : {}),
    ...(params.imageGenerationSkipped != null
      ? { imageGenerationSkipped: params.imageGenerationSkipped }
      : {}),
    ...(params.imageGenerationReason != null
      ? { imageGenerationReason: params.imageGenerationReason }
      : {}),
    ...(params.reusedFromPool != null
      ? { reusedFromPool: params.reusedFromPool }
      : {}),
    ...(params.sourceImageId != null
      ? { sourceImageId: params.sourceImageId }
      : {}),
    timestamp: new Date().toISOString(),
  };
}

function buildSuccessResponse(data: TalismanResponseData): Response {
  return new Response(
    JSON.stringify({
      success: true,
      data,
      ...data,
    }),
    {
      status: 200,
      headers: { "Content-Type": "application/json" },
    },
  );
}

async function getRandomCatalogTalisman(): Promise<CatalogAsset | null> {
  console.log("🎴 Checking talisman catalog assets...");
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    const { data, error } = await supabase
      .from("talisman_catalog_assets")
      .select("id, image_url, title")
      .eq("is_active", true)
      .order("sort_order", { ascending: true })
      .limit(100);

    if (error) {
      console.warn("⚠️ Failed to read talisman catalog:", error.message);
      return null;
    }

    if (!Array.isArray(data) || data.length === 0) {
      console.log("✗ No active talisman catalog assets");
      return null;
    }

    const selected = data[Math.floor(Math.random() * data.length)] as Record<
      string,
      unknown
    >;
    const imageUrl = typeof selected.image_url === "string"
      ? selected.image_url
      : "";

    if (!imageUrl) {
      console.warn("⚠️ Talisman catalog entry missing image_url");
      return null;
    }

    const id = typeof selected.id === "string"
      ? selected.id
      : `talisman-catalog-${Date.now()}`;
    const title = typeof selected.title === "string"
      ? selected.title
      : "랜덤 부적";

    console.log("✅ Reusing talisman catalog asset:", id);

    return {
      id,
      imageUrl,
      title,
    };
  } catch (error) {
    console.warn("⚠️ Exception while checking talisman catalog:", error);
    return null;
  }
}

async function uploadToSupabase(
  imageBase64: string,
  userId: string,
  category: string,
): Promise<string> {
  console.log("📤 Uploading to Supabase Storage...");

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const imageBuffer = Uint8Array.from(
    atob(imageBase64),
    (c) => c.charCodeAt(0),
  );

  const fileName = `${userId}/generated/${category}_${Date.now()}.png`;

  const { error } = await supabase.storage
    .from(TALISMAN_STORAGE_BUCKET)
    .upload(fileName, imageBuffer, {
      contentType: "image/png",
      upsert: false,
    });

  if (error) {
    console.error("❌ Upload error:", error);
    throw new Error(`Upload failed: ${error.message}`);
  }

  const { data: publicUrlData } = supabase.storage
    .from(TALISMAN_STORAGE_BUCKET)
    .getPublicUrl(fileName);

  console.log("✅ Upload successful:", publicUrlData.publicUrl);
  return publicUrlData.publicUrl;
}

async function saveGeneratedTalismanRecord(
  userId: string,
  category: string,
  imageUrl: string,
  prompt: string,
  characters: string[],
): Promise<string> {
  console.log("💾 Saving talisman record to database...");

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  const { data, error } = await supabase
    .from("talisman_images")
    .insert({
      user_id: userId,
      category,
      image_url: imageUrl,
      prompt_used: prompt,
      characters,
      is_public: false,
      model_used: TALISMAN_IMAGE_MODEL,
      created_at: new Date().toISOString(),
    })
    .select("id")
    .single();

  if (error) {
    console.error("❌ Database insert error:", error);
    throw new Error(`Database insert failed: ${error.message}`);
  }

  console.log("✅ Talisman record saved, id:", data.id);
  return data.id;
}

// Startup validation — fail fast if secrets are missing, rather than silently
// falling back at image-generation time.
if (!OPENAI_API_KEY) {
  console.error(
    "⛔ generate-talisman: OPENAI_API_KEY is not set. Premium AI image generation will be disabled.",
  );
}
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error(
    "⛔ generate-talisman: SUPABASE credentials missing, storage + DB calls will fail.",
  );
}

serve(async (req) => {
  try {
    const {
      userId,
      category,
      characters,
      generationMode: rawGenerationMode,
    }: TalismanRequest = await req.json();

    const generationMode = normalizeGenerationMode(rawGenerationMode);

    console.log("🔮 Talisman generation request:", {
      userId,
      category,
      generationMode,
    });

    if (!userId || !category) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: userId, category" }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const config = CATEGORY_CONFIGS[category];
    if (!config) {
      return new Response(
        JSON.stringify({ error: `Invalid category: ${category}` }),
        { status: 400, headers: { "Content-Type": "application/json" } },
      );
    }

    const usedCharacters = characters || config.defaultCharacters;
    const prompt = buildTalismanPrompt(config);

    if (generationMode === "prebuilt") {
      const catalogTalisman = await getRandomCatalogTalisman();
      if (catalogTalisman != null) {
        return buildSuccessResponse(
          buildTalismanResponseData({
            id: catalogTalisman.id,
            imageUrl: catalogTalisman.imageUrl,
            category,
            config,
            characters: usedCharacters,
            generationMode,
            imageSource: "catalog",
            catalogAssetId: catalogTalisman.id,
          }),
        );
      }

      return buildSuccessResponse(
        buildTalismanResponseData({
          id: `talisman-catalog-empty-${Date.now()}`,
          imageUrl: "",
          category,
          config,
          characters: usedCharacters,
          generationMode,
          imageSource: "none",
          imageGenerationFailed: true,
          imageGenerationFailureReason: "catalog_empty",
          warnings: [
            "현재 미리 준비된 부적이 아직 준비되지 않아 설명형 부적으로 안내해드려요.",
          ],
          imageGenerationSkipped: true,
          imageGenerationReason: "catalog_empty",
          reusedFromPool: false,
        }),
      );
    }

    try {
      const imageBase64 = await generateImageWithOpenAI(prompt);
      const imageUrl = await uploadToSupabase(imageBase64, userId, category);
      const recordId = await saveGeneratedTalismanRecord(
        userId,
        category,
        imageUrl,
        prompt,
        usedCharacters,
      );

      console.log("🎉 Talisman generation complete!");

      return buildSuccessResponse(
        buildTalismanResponseData({
          id: recordId,
          imageUrl,
          category,
          config,
          characters: usedCharacters,
          generationMode,
          imageSource: "generated",
        }),
      );
    } catch (imageError) {
      const fallbackReason = classifyImageFallbackReason(imageError);
      console.warn(
        "⚠️ Talisman image generation skipped, attempting catalog fallback",
        {
          userId,
          category,
          reason: fallbackReason,
          message: getErrorMessage(imageError),
        },
      );

      const catalogTalisman = await getRandomCatalogTalisman();
      if (catalogTalisman != null) {
        return buildSuccessResponse(
          buildTalismanResponseData({
            id: `talisman-fallback-${Date.now()}`,
            imageUrl: catalogTalisman.imageUrl,
            category,
            config,
            characters: usedCharacters,
            generationMode,
            imageSource: "catalog",
            catalogAssetId: catalogTalisman.id,
            warnings: [
              "현재 맞춤 이미지 생성이 제한되어 준비된 부적으로 전환했어요.",
            ],
            imageGenerationFailed: true,
            imageGenerationFailureReason: fallbackReason,
            imageGenerationSkipped: true,
            imageGenerationReason: fallbackReason,
            reusedFromPool: true,
            sourceImageId: catalogTalisman.id,
          }),
        );
      }

      return buildSuccessResponse(
        buildTalismanResponseData({
          id: `talisman-textonly-${Date.now()}`,
          imageUrl: "",
          category,
          config,
          characters: usedCharacters,
          generationMode,
          imageSource: "none",
          warnings: [
            "현재 맞춤 이미지 생성이 제한되어 설명형 부적으로 전환되었어요.",
          ],
          imageGenerationFailed: true,
          imageGenerationFailureReason: fallbackReason,
          imageGenerationSkipped: true,
          imageGenerationReason: fallbackReason,
          reusedFromPool: false,
        }),
      );
    }
  } catch (error) {
    console.error("❌ Error generating talisman:", error);

    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Unknown error",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});
