/**
 * generate-poster-guide — Generic 포스터 가이드 운세 Edge Function
 *
 * @description posterType 별로 POSTER_REGISTRY 에서 config 를 lookup 한 뒤
 *   gpt-image-2 multi-image edits 로 한국어 가이드 이미지를 생성한다.
 *   기존 `fortune-palm-reading` 의 호출 패턴을 generic 화한 것 — palm-reading 도
 *   본 함수로 통합 가능하지만 legacy 클라이언트 보호를 위해 기존 함수는 보존.
 *
 *   토큰 차감은 본 함수가 아니라 client (`completeSurvey`) 가 담당.
 *
 * @endpoint POST /generate-poster-guide
 *
 * @requestBody
 *   {
 *     posterType: PosterType,        // 7종 중 하나
 *     userId: string,                // 결과 저장 폴더
 *     imageBase64?: string,          // requiresUserPhoto=true 시 필수
 *     contextText?: string,          // 옵션 (past-life/blind-date 등)
 *   }
 *
 * @response 성공 (200)
 *   { success: true, posterType, imageUrl, generatedAt }
 *
 * @response 실패 (400/500)
 *   { success: false, error: string }   // error 는 한국어 사용자 메시지
 *
 * @env
 *   - OPENAI_API_KEY (필수)
 *   - SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY (필수)
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

import {
  getPosterConfig,
  isValidPosterType,
  normalizeContextText,
  type PosterType,
  type PosterTypeConfig,
} from "../_shared/poster_registry.ts";
import { requireWorkerAuth } from "../_shared/worker_auth.ts";

// =====================================================
// 상수 (매직 넘버 금지)
// =====================================================
const MODEL_ID = "gpt-image-2-2026-04-21";
const ASSETS_BUCKET = "poster-guide-assets";
const RESULTS_BUCKET = "poster-guide-images";
const OPENAI_EDITS_ENDPOINT = "https://api.openai.com/v1/images/edits";

/** gpt-image-2 multi-image edits 평균 30~60s — 90s 여유. */
// Supabase Edge Function platform max wall-clock = 150s. 안전 마진 위해 140s.
const REQUEST_TIMEOUT_MS = 140_000;
// gpt-image-2 quality: 'low' | 'medium' | 'high' | 'auto'. 'medium' = 속도/품질 균형.
const OPENAI_QUALITY = "medium";

/** 사용자 사진 raw bytes 상한 (8MB). 더 크면 base64 inflate 로 OpenAI 거부. */
const MAX_USER_IMAGE_BYTES = 8 * 1024 * 1024;
// base64 expansion ~33% → 8MB raw ≈ 11MB string. 12MB cap = early-out before decode (DoS 방지).
const MAX_BASE64_STRING_LENGTH = 12 * 1024 * 1024;

/** 결과 이미지 1장만 받는다. */
const OPENAI_N_IMAGES = "1";
const SIGNED_RESULT_URL_TTL_SECONDS = 7 * 24 * 60 * 60;

/** 사용자에게 노출하는 일반 한국어 에러 (로그는 별도). */
const KOREAN_USER_ERROR = "운세 분석에 실패했어요. 다시 시도해주세요.";

const KOREAN_TEMPLATE_MISSING =
  "준비 중인 운세예요. 잠시 후 다시 시도해주세요.";

const KOREAN_PHOTO_REQUIRED =
  "사진이 필요한 운세예요. 사진을 다시 선택해주세요.";

const KOREAN_PHOTO_TOO_LARGE =
  "사진 용량이 너무 커요. 더 작은 사진으로 다시 시도해주세요.";

const KOREAN_INVALID_TYPE = "지원하지 않는 운세 유형이에요.";

const KOREAN_INVALID_USER = "사용자 정보가 올바르지 않아요.";

/**
 * userId 형식 — Supabase auth uid 는 RFC4122 UUID (36자, 하이픈 4개).
 * Storage 경로 injection (`../`, 슬래시 포함) 방지 위해 strict 검증.
 */
const UUID_REGEX =
  /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/u;

// =====================================================
// 환경 변수 (startup 검증)
// =====================================================
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ??
  "";

if (!OPENAI_API_KEY) {
  console.error(
    "⛔ generate-poster-guide: OPENAI_API_KEY missing. 모든 요청이 500 으로 실패합니다.",
  );
}
if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error(
    "⛔ generate-poster-guide: SUPABASE credentials missing. Storage 호출 실패합니다.",
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
interface PosterGuideRequest {
  posterType?: unknown;
  userId?: unknown;
  imageBase64?: unknown;
  contextText?: unknown;
}

interface PosterGuideSuccess {
  success: true;
  posterType: PosterType;
  imageUrl: string;
  generatedAt: string;
}

interface PosterGuideFailure {
  success: false;
  error: string;
}

type PosterGuideResponseBody = PosterGuideSuccess | PosterGuideFailure;

// =====================================================
// 유틸
// =====================================================
function jsonResponse(body: PosterGuideResponseBody, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

function failure(
  status: number,
  log: string,
  userMsg = KOREAN_USER_ERROR,
): Response {
  console.error(`❌ generate-poster-guide: ${log}`);
  return jsonResponse({ success: false, error: userMsg }, status);
}

function decodeBase64(b64: string): Uint8Array {
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
      `Asset download failed: ${ASSETS_BUCKET}/${path} — ${
        error?.message ?? "no data"
      }`,
    );
  }

  const buffer = await data.arrayBuffer();
  return new Uint8Array(buffer);
}

/**
 * 우선 templatePath, 실패하면 fallbackTemplatePath 시도.
 * 둘 다 실패하면 throw (호출자가 한국어 에러로 변환).
 */
async function downloadTemplateWithFallback(
  config: PosterTypeConfig,
): Promise<{ bytes: Uint8Array; usedFallback: boolean }> {
  try {
    const bytes = await downloadAsset(config.templatePath);
    return { bytes, usedFallback: false };
  } catch (primaryErr) {
    if (!config.fallbackTemplatePath) {
      throw primaryErr;
    }
    console.warn(
      `⚠️  generate-poster-guide: ${config.posterType} 템플릿 fetch 실패 → fallback (${config.fallbackTemplatePath}) 사용. err=${
        (primaryErr as Error).message
      }`,
    );
    const bytes = await downloadAsset(config.fallbackTemplatePath);
    return { bytes, usedFallback: true };
  }
}

async function uploadResult(
  userId: string,
  posterType: PosterType,
  bytes: Uint8Array,
): Promise<string> {
  const supabase = getServiceClient();
  // 경로: {userId}/{posterType}/{uuid}.png — userId 와 posterType 모두 검증된 값.
  const fileName = `${userId}/${posterType}/${crypto.randomUUID()}.png`;

  const { error } = await supabase.storage
    .from(RESULTS_BUCKET)
    .upload(fileName, bytes, {
      contentType: "image/png",
      upsert: false,
    });

  if (error) {
    throw new Error(`Storage upload failed: ${error.message}`);
  }

  const { data: signed, error: signedError } = await supabase.storage
    .from(RESULTS_BUCKET)
    .createSignedUrl(fileName, SIGNED_RESULT_URL_TTL_SECONDS);
  if (signedError || !signed?.signedUrl) {
    throw new Error(
      `Storage upload succeeded but signed URL missing: ${
        signedError?.message ?? "no url"
      }`,
    );
  }
  return signed.signedUrl;
}

// =====================================================
// OpenAI gpt-image-2 multi-image edit 호출
// =====================================================
/**
 * gpt-image-2 의 /v1/images/edits 엔드포인트는 multipart/form-data 로
 * 여러 image 파일을 받는다. 같은 필드명 `image` 를 여러 번 append 하면
 * OpenAI 가 array 로 인식 (snapshot 2026-04-21 기준).
 *
 * Image 1 = 템플릿, Image 2 = (있으면) 사용자 사진.
 *   prompt 는 이 순서를 가정해서 작성되어야 함 (Generator C 책임).
 */
async function generatePosterImage(
  config: PosterTypeConfig,
  prompt: string,
  templatePng: Uint8Array,
  userPhotoPng: Uint8Array | null,
): Promise<Uint8Array> {
  const form = new FormData();
  form.append("model", MODEL_ID);
  form.append("prompt", prompt);
  form.append("size", config.outputSize);
  form.append("n", OPENAI_N_IMAGES);
  form.append("quality", OPENAI_QUALITY);

  // Uint8Array → BlobPart 캐스팅으로 Deno DOM lib 의 SharedArrayBuffer 추론 회피.
  const blobOf = (bytes: Uint8Array): Blob =>
    new Blob([bytes as unknown as BlobPart], { type: "image/png" });

  // OpenAI gpt-image-2: 여러 reference 이미지는 `image[]` 배열 문법 필수.
  // 같은 필드 `image` 를 중복 append 하면 400 "Duplicate parameter" 에러.
  form.append("image[]", blobOf(templatePng), "template.png");
  if (userPhotoPng) {
    form.append("image[]", blobOf(userPhotoPng), "user.png");
  }

  const controller = new AbortController();
  const timeoutHandle = setTimeout(
    () => controller.abort(),
    REQUEST_TIMEOUT_MS,
  );

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
    throw new Error(
      `OpenAI images/edits ${response.status}: ${text.slice(0, 500)}`,
    );
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

  // Internal image-generation endpoint: only process-poster-jobs/service-role or
  // CRON_SECRET callers may invoke it. Public clients must use start-poster-job,
  // which charges before queueing.
  const authError = requireWorkerAuth(req);
  if (authError) return authError;

  if (!OPENAI_API_KEY) {
    return failure(500, "OPENAI_API_KEY not configured");
  }
  if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
    return failure(500, "Supabase credentials not configured");
  }

  // ---------- 입력 파싱 ----------
  let body: PosterGuideRequest;
  try {
    body = await req.json() as PosterGuideRequest;
  } catch (err) {
    return failure(400, `Invalid JSON body: ${(err as Error).message}`);
  }

  // posterType validation
  if (!isValidPosterType(body.posterType)) {
    return failure(
      400,
      `Invalid posterType: ${JSON.stringify(body.posterType)}`,
      KOREAN_INVALID_TYPE,
    );
  }
  const posterType: PosterType = body.posterType;
  const config = getPosterConfig(posterType);

  // userId validation (UUID 강제)
  const userId = readString(body.userId);
  if (!userId || !UUID_REGEX.test(userId)) {
    return failure(
      400,
      `Invalid userId: ${JSON.stringify(body.userId)}`,
      KOREAN_INVALID_USER,
    );
  }

  // contextText 정규화 (옵션)
  const contextText = normalizeContextText(body.contextText);

  // 사용자 사진 처리 (config.requiresUserPhoto 따라 분기)
  const imageBase64 = readString(body.imageBase64);
  let userPhotoBytes: Uint8Array | null = null;

  if (config.requiresUserPhoto) {
    if (!imageBase64) {
      return failure(
        400,
        `posterType=${posterType} requires imageBase64`,
        KOREAN_PHOTO_REQUIRED,
      );
    }
    if (imageBase64.length > MAX_BASE64_STRING_LENGTH) {
      return failure(
        400,
        `imageBase64 string too long: ${imageBase64.length} > ${MAX_BASE64_STRING_LENGTH}`,
        KOREAN_PHOTO_TOO_LARGE,
      );
    }
    try {
      userPhotoBytes = decodeBase64(imageBase64);
    } catch (err) {
      return failure(
        400,
        `imageBase64 decode failed: ${(err as Error).message}`,
      );
    }
    if (userPhotoBytes.byteLength === 0) {
      return failure(400, "imageBase64 decoded to 0 bytes");
    }
    if (userPhotoBytes.byteLength > MAX_USER_IMAGE_BYTES) {
      return failure(
        400,
        `User image too large: ${userPhotoBytes.byteLength} > ${MAX_USER_IMAGE_BYTES} bytes`,
        KOREAN_PHOTO_TOO_LARGE,
      );
    }
  } else if (imageBase64) {
    // requiresUserPhoto=false 인데 사진이 들어온 경우는 그대로 사용 (전생 가이드 등 옵션)
    if (imageBase64.length > MAX_BASE64_STRING_LENGTH) {
      return failure(
        400,
        `imageBase64 string too long: ${imageBase64.length} > ${MAX_BASE64_STRING_LENGTH}`,
        KOREAN_PHOTO_TOO_LARGE,
      );
    }
    try {
      userPhotoBytes = decodeBase64(imageBase64);
    } catch (err) {
      return failure(
        400,
        `imageBase64 decode failed: ${(err as Error).message}`,
      );
    }
    if (userPhotoBytes.byteLength === 0) {
      userPhotoBytes = null;
    } else if (userPhotoBytes.byteLength > MAX_USER_IMAGE_BYTES) {
      return failure(
        400,
        `User image too large: ${userPhotoBytes.byteLength} > ${MAX_USER_IMAGE_BYTES} bytes`,
        KOREAN_PHOTO_TOO_LARGE,
      );
    }
  }

  console.log(
    `🎨 generate-poster-guide: posterType=${posterType} userId=${userId} userImageBytes=${
      userPhotoBytes?.byteLength ?? 0
    } contextLen=${contextText?.length ?? 0}`,
  );

  // ---------- 템플릿 fetch (with fallback) ----------
  let templateBytes: Uint8Array;
  let usedFallback = false;
  try {
    const result = await downloadTemplateWithFallback(config);
    templateBytes = result.bytes;
    usedFallback = result.usedFallback;
  } catch (err) {
    return failure(
      500,
      `Template fetch failed for ${posterType}: ${(err as Error).message}. ` +
        `${ASSETS_BUCKET} 에 ${config.templatePath} 가 업로드되었는지 확인 필요.`,
      KOREAN_TEMPLATE_MISSING,
    );
  }
  console.log(
    `📦 template: ${config.templatePath} (${templateBytes.byteLength}b)${
      usedFallback ? " [fallback]" : ""
    }`,
  );

  // ---------- Prompt 빌드 (Generator C 가 작성한 buildPrompt) ----------
  const prompt = config.buildPrompt({ contextText });

  // ---------- OpenAI 호출 ----------
  let resultBytes: Uint8Array;
  try {
    resultBytes = await generatePosterImage(
      config,
      prompt,
      templateBytes,
      userPhotoBytes,
    );
    console.log(`✅ gpt-image-2 result: ${resultBytes.byteLength} bytes`);
  } catch (err) {
    return failure(500, `OpenAI generation failed: ${(err as Error).message}`);
  }

  // ---------- Storage 업로드 ----------
  let imageUrl: string;
  try {
    imageUrl = await uploadResult(userId, posterType, resultBytes);
    console.log(`📤 uploaded: ${imageUrl}`);
  } catch (err) {
    return failure(500, `Result upload failed: ${(err as Error).message}`);
  }

  // ---------- 성공 응답 ----------
  return jsonResponse(
    {
      success: true,
      posterType,
      imageUrl,
      generatedAt: new Date().toISOString(),
    },
    200,
  );
});
