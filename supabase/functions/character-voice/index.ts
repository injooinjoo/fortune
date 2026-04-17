/**
 * 캐릭터 보이스 메시지 생성 Edge Function
 *
 * 텍스트를 캐릭터 음성으로 변환 (Google Cloud TTS).
 * 캐릭터별 다른 음성 설정 (pitch, speed, voice name).
 *
 * @endpoint POST /character-voice
 * @requestBody { characterId: string, text: string }
 * @response audio/mp3 바이너리
 */

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { corsHeaders, handleCors } from "../_shared/cors.ts";

// 캐릭터별 음성 설정 (Google Cloud TTS)
const CHARACTER_VOICES: Record<string, {
  languageCode: string;
  name: string;
  ssmlGender: string;
  pitch: number;    // -20.0 ~ 20.0
  speakingRate: number; // 0.25 ~ 4.0
}> = {
  luts: {
    languageCode: "ko-KR",
    name: "ko-KR-Neural2-C", // 남성, 차분
    ssmlGender: "MALE",
    pitch: -2.0,
    speakingRate: 0.95,
  },
  jung_tae_yoon: {
    languageCode: "ko-KR",
    name: "ko-KR-Neural2-C",
    ssmlGender: "MALE",
    pitch: -3.0,     // 더 낮고 절제된 톤
    speakingRate: 0.9,
  },
  seo_yoonjae: {
    languageCode: "ko-KR",
    name: "ko-KR-Neural2-C",
    ssmlGender: "MALE",
    pitch: 1.0,      // 약간 밝은 톤
    speakingRate: 1.05,
  },
  han_seojun: {
    languageCode: "ko-KR",
    name: "ko-KR-Neural2-C",
    ssmlGender: "MALE",
    pitch: -4.0,     // 가장 낮고 조용한 톤
    speakingRate: 0.85,
  },
};

const DEFAULT_VOICE = {
  languageCode: "ko-KR",
  name: "ko-KR-Neural2-A",
  ssmlGender: "FEMALE",
  pitch: 0,
  speakingRate: 1.0,
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") return handleCors(req);

  try {
    const { characterId, text } = await req.json();

    if (!text || typeof text !== "string") {
      return new Response(
        JSON.stringify({ error: "text is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const apiKey = Deno.env.get("GOOGLE_TTS_API_KEY") || Deno.env.get("GEMINI_API_KEY");
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: "TTS API key not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const voice = CHARACTER_VOICES[characterId] ?? DEFAULT_VOICE;

    // Google Cloud Text-to-Speech API
    const ttsResponse = await fetch(
      `https://texttospeech.googleapis.com/v1/text:synthesize?key=${apiKey}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          input: { text: text.slice(0, 500) }, // 최대 500자
          voice: {
            languageCode: voice.languageCode,
            name: voice.name,
            ssmlGender: voice.ssmlGender,
          },
          audioConfig: {
            audioEncoding: "MP3",
            pitch: voice.pitch,
            speakingRate: voice.speakingRate,
            effectsProfileId: ["handset-class-device"],
          },
        }),
      },
    );

    if (!ttsResponse.ok) {
      const errorText = await ttsResponse.text();
      console.error("[character-voice] TTS API error:", errorText);
      return new Response(
        JSON.stringify({ error: "TTS generation failed", detail: errorText }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const ttsData = await ttsResponse.json();
    const audioBase64 = ttsData.audioContent;

    if (!audioBase64) {
      return new Response(
        JSON.stringify({ error: "No audio content returned" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({
        success: true,
        audioBase64,
        characterId,
        voiceName: voice.name,
        durationEstimate: Math.ceil(text.length * 0.15), // 대략적 초 단위
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("[character-voice] Error:", error);
    return new Response(
      JSON.stringify({ error: String(error) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
