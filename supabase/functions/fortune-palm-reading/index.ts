/**
 * 손금가이드 (Palm Reading) Edge Function
 *
 * @description 사용자 손바닥 사진 + 정적 reference 1장(template)을
 *   gpt-image-2 multi-image edits 에 입력해서 한국어 손금 분석 가이드 이미지를
 *   생성한다. (example 이미지는 과잉 정보라서 제외 — template 만으로 레이아웃 강제)
 *
 *   기존 talisman/face-reading 패턴과 다른 점:
 *   - LLMFactory 우회 (OpenAIProvider 가 multi-image edits 미지원)
 *   - 직접 fetch + multipart/form-data 로 OpenAI /v1/images/edits 호출
 *   - 토큰 차감은 본 함수가 아니라 client (`completeSurvey`) 에서 처리.
 *     본 함수는 이미지 생성 + 업로드만 책임.
 *
 * @endpoint POST /fortune-palm-reading
 *
 * @requestBody
 *   { userId: string, imageBase64: string }
 *   - userId: 결과 이미지 저장 경로용 (palm-reading-images/{userId}/...).
 *   - imageBase64: 사용자 손바닥 사진의 base64 (data: prefix 제거된 raw).
 *
 * @response 성공
 *   { success: true, imageUrl: string, generatedAt: string (ISO8601) }
 *
 * @response 실패
 *   { success: false, error: string }  (HTTP 400/500)
 *
 * @env
 *   - OPENAI_API_KEY (필수)
 *   - SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (필수)
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// =====================================================
// 상수 (매직 넘버 금지)
// =====================================================
const MODEL_ID = "gpt-image-2-2026-04-21";
const OUTPUT_SIZE = "1024x1536"; // portrait
const ASSETS_BUCKET = "palm-reading-assets";
const RESULTS_BUCKET = "palm-reading-images";
const TEMPLATE_PATH = "template.png";
const OPENAI_EDITS_ENDPOINT = "https://api.openai.com/v1/images/edits";
const REQUEST_TIMEOUT_MS = 90_000; // gpt-image-2 multi-image 는 30~60s 소요
const MAX_USER_IMAGE_BYTES = 8 * 1024 * 1024; // 8MB raw bytes (base64 decoded)
const KOREAN_USER_ERROR =
  "손금 분석에 실패했어요. 다시 시도해주세요.";

const COMBINED_PROMPT = [
  "You are creating a premium Korean palm reading guide poster.",
  "",
  "Input image roles:",
  "Image 1 = layout template. Preserve this structure as closely as possible.",
  "",
  "Image 2 = actual user palm photo. Use this as the only source for palm shape, palm lines, and palm-reading analysis.",
  "",
  "Main goal:",
  "Create a completed Korean palm reading guide using the layout of Image 1, and the actual palm analysis from Image 2.",
  "",
  "Rules:",
  "- Keep the same overall layout as Image 1.",
  "- Do not invent a new layout.",
  "- Replace the blank palm photo area with a clean, bright cutout of the actual palm from Image 2.",
  "- Replace the blank hand map area with a simple black line contour diagram based on Image 2.",
  "- Use Image 2 only as a style and content-density reference.",
  "- All visible text must be Korean.",
  "- Keep the design minimal, premium, editorial, warm ivory, thin black lines, rounded cards, lots of white space.",
  "- Avoid mystical, neon, cartoon, or overly decorative styling.",
  "- Make Korean text clean and readable.",
  "",
  "Poster text:",
  "Title: 손금 리딩 가이드",
  "Subtitle: 통찰 · 강점 · 방향을 찾아서",
  "",
  "Sections:",
  "1. 한눈에 보는 요약",
  "2. 손바닥 상태 안내",
  "3. 손금 지도",
  "4. 주요 손금",
  "5. 손바닥 특징",
  "6. 이것이 당신에게 의미하는 것",
  "7. 당신의 길",
  "",
  "Analyze the actual palm from Image 2 and fill the sections naturally.",
  "Use concise, elegant Korean copy.",
  "Palm reading should feel warm, insightful, and premium, not fortune-telling exaggerated.",
].join("\n");

// =====================================================
// 환경 변수 (startup 검증)
// =====================================================
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

if (!OPENAI_API_KEY) {
  console.error(
    "⛔ fortune-palm-reading: OPENAI_API_KEY missing. 모든 요청이 500 으로 실패합니다.",
  );
}
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error(
    "⛔ fortune-palm-reading: SUPABASE credentials missing. Storage 호출 실패합니다.",
  );
}

// =====================================================
// CORS
// =====================================================
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// =====================================================
// 타입
// =====================================================
interface PalmReadingRequest {
  userId?: unknown;
  imageBase64?: unknown;
}

interface PalmReadingSuccess {
  success: true;
  imageUrl: string;
  generatedAt: string;
}

interface PalmReadingFailure {
  success: false;
  error: string;
}

// =====================================================
// 유틸
// =====================================================
function jsonResponse(
  body: PalmReadingSuccess | PalmReadingFailure,
  status: number,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

function failure(status: number, log: string, userMsg = KOREAN_USER_ERROR): Response {
  console.error(`❌ fortune-palm-reading: ${log}`);
  return jsonResponse({ success: false, error: userMsg }, status);
}

function decodeBase64(b64: string): Uint8Array {
  // strip optional data: prefix
  const cleaned = b64.replace(/^data:image\/[a-zA-Z0-9.+-]+;base64,/u, "");
  const binary = atob(cleaned);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

function readString(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

// =====================================================
// Storage helpers
// =====================================================
function getServiceClient() {
  return createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
}

async function downloadAsset(path: string): Promise<Uint8Array> {
  const supabase = getServiceClient();
  const { data, error } = await supabase.storage
    .from(ASSETS_BUCKET)
    .download(path);

  if (error || !data) {
    throw new Error(
      `Asset download failed: ${ASSETS_BUCKET}/${path} — ${error?.message ?? "no data"}`,
    );
  }

  const buffer = await data.arrayBuffer();
  return new Uint8Array(buffer);
}

async function uploadResult(
  userId: string,
  bytes: Uint8Array,
): Promise<string> {
  const supabase = getServiceClient();
  const fileName = `${userId}/${crypto.randomUUID()}.png`;

  const { error } = await supabase.storage
    .from(RESULTS_BUCKET)
    .upload(fileName, bytes, {
      contentType: "image/png",
      upsert: false,
    });

  if (error) {
    throw new Error(`Storage upload failed: ${error.message}`);
  }

  const { data } = supabase.storage.from(RESULTS_BUCKET).getPublicUrl(fileName);
  if (!data?.publicUrl) {
    throw new Error("Storage upload succeeded but public URL missing");
  }
  return data.publicUrl;
}

// =====================================================
// OpenAI gpt-image-2 multi-image edit 호출
// =====================================================
/**
 * gpt-image-2 의 /v1/images/edits 엔드포인트는 multipart/form-data 로
 * 여러 image 파일을 받는다. 같은 필드명 `image` 를 여러 번 append 하면
 * OpenAI 가 array 로 인식 (snapshot 2026-04-21 기준).
 *
 * 응답: { data: [{ b64_json: "..." }] }
 */
async function generatePalmReadingImage(
  templatePng: Uint8Array,
  userPalmPng: Uint8Array,
): Promise<Uint8Array> {
  const form = new FormData();
  form.append("model", MODEL_ID);
  form.append("prompt", COMBINED_PROMPT);
  form.append("size", OUTPUT_SIZE);
  form.append("n", "1");
  // Uint8Array → BlobPart 캐스팅으로 Deno DOM lib 의 SharedArrayBuffer 추론 회피.
  const blobOf = (bytes: Uint8Array): Blob =>
    new Blob([bytes as unknown as BlobPart], { type: "image/png" });

  // Image 1 = template, Image 2 = user palm — 순서 중요 (prompt가 참조함)
  form.append("image", blobOf(templatePng), "template.png");
  form.append("image", blobOf(userPalmPng), "user.png");

  const controller = new AbortController();
  const timeoutHandle = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  let response: Response;
  try {
    response = await fetch(OPENAI_EDITS_ENDPOINT, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${OPENAI_API_KEY}`,
      },
      body: form,
      signal: controller.signal,
    });
  } catch (err) {
    if ((err as { name?: string })?.name === "AbortError") {
      throw new Error(`OpenAI request timeout (${REQUEST_TIMEOUT_MS}ms)`);
    }
    throw err;
  } finally {
    clearTimeout(timeoutHandle);
  }

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`OpenAI images/edits ${response.status}: ${text.slice(0, 500)}`);
  }

  const json = await response.json() as {
    data?: Array<{ b64_json?: string }>;
  };

  const b64 = json?.data?.[0]?.b64_json;
  if (typeof b64 !== "string" || !b64) {
    throw new Error("OpenAI response missing b64_json data");
  }

  return decodeBase64(b64);
}

// =====================================================
// 메인 핸들러
// =====================================================
serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return failure(405, `Method not allowed: ${req.method}`);
  }

  if (!OPENAI_API_KEY) {
    return failure(500, "OPENAI_API_KEY not configured");
  }
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return failure(500, "Supabase credentials not configured");
  }

  // ---------- 입력 파싱 ----------
  let body: PalmReadingRequest;
  try {
    body = await req.json() as PalmReadingRequest;
  } catch (err) {
    return failure(400, `Invalid JSON body: ${(err as Error).message}`);
  }

  const userId = readString(body.userId);
  const imageBase64 = readString(body.imageBase64);

  if (!userId) {
    return failure(400, "userId required");
  }
  if (!imageBase64) {
    return failure(400, "imageBase64 required");
  }

  let userPalmBytes: Uint8Array;
  try {
    userPalmBytes = decodeBase64(imageBase64);
  } catch (err) {
    return failure(400, `imageBase64 decode failed: ${(err as Error).message}`);
  }

  if (userPalmBytes.byteLength === 0) {
    return failure(400, "imageBase64 decoded to 0 bytes");
  }
  if (userPalmBytes.byteLength > MAX_USER_IMAGE_BYTES) {
    return failure(
      400,
      `User palm image too large: ${userPalmBytes.byteLength} > ${MAX_USER_IMAGE_BYTES} bytes`,
    );
  }

  console.log(
    `🖐️ fortune-palm-reading: userId=${userId} userImageBytes=${userPalmBytes.byteLength}`,
  );

  // ---------- Reference 이미지 fetch (template만) ----------
  let templateBytes: Uint8Array;
  try {
    templateBytes = await downloadAsset(TEMPLATE_PATH);
  } catch (err) {
    return failure(
      500,
      `Reference asset fetch failed: ${(err as Error).message}. ` +
        `palm-reading-assets/template.png 가 업로드되었는지 확인 필요.`,
    );
  }

  console.log(`📦 reference: template=${templateBytes.byteLength}b`);

  // ---------- OpenAI 호출 ----------
  let resultBytes: Uint8Array;
  try {
    resultBytes = await generatePalmReadingImage(templateBytes, userPalmBytes);
    console.log(`✅ gpt-image-2 result: ${resultBytes.byteLength} bytes`);
  } catch (err) {
    return failure(500, `OpenAI generation failed: ${(err as Error).message}`);
  }

  // ---------- Storage 업로드 ----------
  let imageUrl: string;
  try {
    imageUrl = await uploadResult(userId, resultBytes);
    console.log(`📤 uploaded: ${imageUrl}`);
  } catch (err) {
    return failure(500, `Result upload failed: ${(err as Error).message}`);
  }

  // ---------- 성공 응답 ----------
  return jsonResponse(
    {
      success: true,
      imageUrl,
      generatedAt: new Date().toISOString(),
    },
    200,
  );
});
