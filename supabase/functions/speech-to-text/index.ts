/**
 * speech-to-text Edge Function
 *
 * Proxies audio recordings to Gemini API for transcription.
 * Uses the existing GEMINI_API_KEY — no additional keys needed.
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { encodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_MODEL = "gemini-2.0-flash";

serve(async (req: Request) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  if (!GEMINI_API_KEY) {
    console.error("[speech-to-text] GEMINI_API_KEY is not configured");
    return new Response(
      JSON.stringify({ error: "Speech-to-text service is not configured" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }

  try {
    const incomingFormData = await req.formData();
    const audioFile = incomingFormData.get("file");

    if (!audioFile || !(audioFile instanceof File)) {
      return new Response(
        JSON.stringify({ error: "Missing audio file in request body" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const language = incomingFormData.get("language")?.toString() ?? "ko";

    // Convert audio file to base64 (chunk-safe via std encoder)
    const audioBytes = new Uint8Array(await audioFile.arrayBuffer());
    const base64Audio = encodeBase64(audioBytes);

    // Determine MIME type
    const mimeType = audioFile.type || "audio/mp4";
    console.log(`[speech-to-text] received file size=${audioBytes.byteLength} mime=${mimeType} lang=${language}`);

    // LLM-FACTORY-BYPASS: Audio transcription (multimodal inline_data).
    // LLMFactory 가 아직 `transcribeAudio` 인터페이스를 제공하지 않음.
    // FU3-3 참조 (artifacts/sprint-fixes/FU3-llmfactory-bypass/analysis.md).
    const geminiResponse = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          contents: [
            {
              parts: [
                {
                  inline_data: {
                    mime_type: mimeType,
                    data: base64Audio,
                  },
                },
                {
                  text: `이 오디오를 ${language === "ko" ? "한국어" : language}로 정확하게 받아적어주세요. 오직 말한 내용만 텍스트로 출력하세요. 추가 설명이나 번역은 하지 마세요.`,
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

    if (!geminiResponse.ok) {
      const errorBody = await geminiResponse.text();
      console.error(`[speech-to-text] Gemini API error ${geminiResponse.status}: ${errorBody}`);
      return new Response(
        JSON.stringify({ error: "Transcription failed", detail: "Could not transcribe audio." }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const geminiResult = await geminiResponse.json();
    const transcript =
      geminiResult?.candidates?.[0]?.content?.parts?.[0]?.text?.trim() ?? "";

    return new Response(
      JSON.stringify({ success: true, text: transcript }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (err) {
    const detail = err instanceof Error ? `${err.name}: ${err.message}` : String(err);
    console.error("[speech-to-text] Unexpected error:", detail, err instanceof Error ? err.stack : undefined);
    return new Response(
      JSON.stringify({ error: "Internal server error", detail }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
