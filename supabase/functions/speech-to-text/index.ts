/**
 * speech-to-text Edge Function
 *
 * Transcribes chat voice messages before they are sent to story characters.
 * Primary path uses OpenAI audio transcription when OPENAI_API_KEY is available;
 * Gemini multimodal transcription remains as a fallback for environments without it.
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { encodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY") ?? "";
const OPENAI_TRANSCRIBE_MODEL = Deno.env.get("OPENAI_TRANSCRIBE_MODEL") ??
  "gpt-4o-mini-transcribe";
const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_MODEL = Deno.env.get("SPEECH_TO_TEXT_GEMINI_MODEL") ??
  "gemini-2.0-flash-lite";

function jsonResponse(body: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function transcribeWithOpenAI(params: {
  audioBytes: Uint8Array;
  fileName: string;
  mimeType: string;
  language: string;
}) {
  const formData = new FormData();
  formData.append("model", OPENAI_TRANSCRIBE_MODEL);
  formData.append(
    "language",
    params.language === "ko" ? "ko" : params.language,
  );
  formData.append(
    "prompt",
    "Korean casual chat to a character named 이서준. Return only the spoken transcript.",
  );
  const audioBuffer = new ArrayBuffer(params.audioBytes.byteLength);
  new Uint8Array(audioBuffer).set(params.audioBytes);
  formData.append(
    "file",
    new File([audioBuffer], params.fileName, { type: params.mimeType }),
  );

  const response = await fetch(
    "https://api.openai.com/v1/audio/transcriptions",
    {
      method: "POST",
      headers: { Authorization: `Bearer ${OPENAI_API_KEY}` },
      body: formData,
    },
  );

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(
      `OpenAI API error ${response.status}: ${errorBody.slice(0, 600)}`,
    );
  }

  const result = await response.json();
  return (result?.text ?? "").toString().trim();
}

async function transcribeWithGemini(params: {
  audioBytes: Uint8Array;
  mimeType: string;
  language: string;
}) {
  const base64Audio = encodeBase64(params.audioBytes);
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              {
                inlineData: {
                  mimeType: params.mimeType,
                  data: base64Audio,
                },
              },
              {
                text: `이 오디오를 ${
                  params.language === "ko" ? "한국어" : params.language
                }로 정확하게 받아적어주세요. 오직 말한 내용만 텍스트로 출력하세요. 추가 설명이나 번역은 하지 마세요.`,
              },
            ],
          },
        ],
        generationConfig: {
          temperature: 0,
          maxOutputTokens: 1024,
        },
      }),
    },
  );

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(
      `Gemini API error ${response.status}: ${errorBody.slice(0, 600)}`,
    );
  }

  const result = await response.json();
  return (result?.candidates?.[0]?.content?.parts?.[0]?.text ?? "")
    .toString()
    .trim();
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  if (!OPENAI_API_KEY && !GEMINI_API_KEY) {
    console.error(
      "[speech-to-text] No transcription provider key is configured",
    );
    return jsonResponse(
      { error: "Speech-to-text service is not configured" },
      500,
    );
  }

  try {
    const incomingFormData = await req.formData();
    const audioFile = incomingFormData.get("file");

    if (!audioFile || !(audioFile instanceof File)) {
      return jsonResponse({ error: "Missing audio file in request body" }, 400);
    }

    const language = incomingFormData.get("language")?.toString() ?? "ko";
    const audioBytes = new Uint8Array(await audioFile.arrayBuffer());
    const mimeType = audioFile.type || "audio/mp4";
    const fileName = audioFile.name || "user-audio.m4a";

    console.log(
      `[speech-to-text] received file size=${audioBytes.byteLength} mime=${mimeType} lang=${language}`,
    );

    let transcript = "";
    let provider = "";

    if (OPENAI_API_KEY) {
      try {
        transcript = await transcribeWithOpenAI({
          audioBytes,
          fileName,
          mimeType,
          language,
        });
        provider = "openai";
      } catch (error) {
        console.error("[speech-to-text] OpenAI transcription failed", error);
      }
    }

    if (!transcript && GEMINI_API_KEY) {
      transcript = await transcribeWithGemini({
        audioBytes,
        mimeType,
        language,
      });
      provider = "gemini";
    }

    if (!transcript) {
      return jsonResponse(
        {
          error: "Transcription failed",
          detail: "Could not transcribe audio.",
        },
        502,
      );
    }

    return jsonResponse({ success: true, text: transcript, provider });
  } catch (err) {
    const detail = err instanceof Error
      ? `${err.name}: ${err.message}`
      : String(err);
    console.error(
      "[speech-to-text] Unexpected error:",
      detail,
      err instanceof Error ? err.stack : undefined,
    );
    return jsonResponse({ error: "Internal server error", detail }, 500);
  }
});
