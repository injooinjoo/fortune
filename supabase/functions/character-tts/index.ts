// character-tts
//
// Gemini 3.1 Flash TTS preview 로 캐릭터 응답 텍스트를 합성한다.
// 입력: { text, voice, emotion?, messageId? }
// 출력: { success, audioBase64, mimeType: 'audio/wav' }
//
// 흐름:
//   1) 인증 (premium 사용자만)
//   2) 토큰 1개 차감 (unlimited 구독자는 제외)
//   3) emotion → inline instruction tag 적용
//   4) Gemini TTS API 호출 → PCM 24kHz 16-bit mono base64
//   5) PCM → WAV header 래핑 → base64 응답
//
// API key 는 GEMINI_API_KEY (LLMFactory 와 공유). PCM 포맷 정보:
//   sample rate 24000, bits 16, channels 1.

import { authenticateUser, checkTokenBalance, deductTokens } from '../_shared/auth.ts';
import { corsHeaders, handleCors } from '../_shared/cors.ts';

interface TtsRequest {
  text: string;
  voice: string;
  emotion?: string;
  messageId?: string;
}

interface TtsResponse {
  success: boolean;
  audioBase64?: string;
  mimeType?: string;
  error?: string;
  errorCode?: 'PREMIUM_REQUIRED' | 'INVALID_INPUT' | 'TTS_FAILED' | 'INTERNAL';
}

const GEMINI_TTS_ENDPOINT =
  'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent';

const ALLOWED_VOICES = new Set([
  'Kore',
  'Puck',
  'Charon',
  'Zephyr',
  'Fenrir',
  'Aoede',
  'Leda',
  'Enceladus',
  'Achernar',
  'Achird',
]);

const EMOTION_INSTRUCTIONS: Record<string, string> = {
  애정: '[warmly, softly]',
  기쁨: '[cheerful, light]',
  고민: '[thoughtful, slow]',
  분노: '[firm, low]',
  당황: '[hesitant, slightly faster]',
  // '일상' 은 명시 안 하고 모델 기본값 사용
};

const TTS_TOKEN_COST = 1;
const MAX_TTS_TEXT_LENGTH = 1500;

function jsonResponse(body: TtsResponse, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

/**
 * Gemini TTS API 응답에서 base64 PCM 추출.
 * 응답 형태: { candidates: [{ content: { parts: [{ inlineData: { data, mimeType } }] } }] }
 */
function extractAudioBase64FromGeminiResponse(payload: unknown): string | null {
  const root = payload as Record<string, unknown> | null;
  if (!root) return null;

  const candidates = root.candidates as Array<Record<string, unknown>> | undefined;
  if (!Array.isArray(candidates) || candidates.length === 0) return null;

  const content = candidates[0]?.content as Record<string, unknown> | undefined;
  const parts = content?.parts as Array<Record<string, unknown>> | undefined;
  if (!Array.isArray(parts) || parts.length === 0) return null;

  for (const part of parts) {
    const inlineData = part?.inlineData as
      | { data?: string; mimeType?: string }
      | undefined;
    if (inlineData?.data) {
      return inlineData.data;
    }
  }
  return null;
}

/**
 * Base64 PCM 24kHz 16-bit mono → Base64 WAV 변환.
 * WAV 컨테이너는 44바이트 RIFF/fmt/data 헤더 + PCM 페이로드.
 * 클라이언트 (expo-av) 는 WAV 를 안전하게 디코드한다 (raw PCM 은 못 읽음).
 */
function wrapPcmAsWavBase64(
  pcmBase64: string,
  sampleRate = 24000,
  channels = 1,
  bitsPerSample = 16,
): string {
  // base64 → Uint8Array
  const binary = atob(pcmBase64);
  const pcmBytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i += 1) {
    pcmBytes[i] = binary.charCodeAt(i);
  }

  const byteRate = (sampleRate * channels * bitsPerSample) / 8;
  const blockAlign = (channels * bitsPerSample) / 8;
  const dataSize = pcmBytes.length;
  const chunkSize = 36 + dataSize;

  const header = new ArrayBuffer(44);
  const view = new DataView(header);

  // RIFF chunk
  view.setUint8(0, 'R'.charCodeAt(0));
  view.setUint8(1, 'I'.charCodeAt(0));
  view.setUint8(2, 'F'.charCodeAt(0));
  view.setUint8(3, 'F'.charCodeAt(0));
  view.setUint32(4, chunkSize, true);
  view.setUint8(8, 'W'.charCodeAt(0));
  view.setUint8(9, 'A'.charCodeAt(0));
  view.setUint8(10, 'V'.charCodeAt(0));
  view.setUint8(11, 'E'.charCodeAt(0));

  // fmt sub-chunk
  view.setUint8(12, 'f'.charCodeAt(0));
  view.setUint8(13, 'm'.charCodeAt(0));
  view.setUint8(14, 't'.charCodeAt(0));
  view.setUint8(15, ' '.charCodeAt(0));
  view.setUint32(16, 16, true); // Sub-chunk size (PCM)
  view.setUint16(20, 1, true); // Audio format (1 = PCM)
  view.setUint16(22, channels, true);
  view.setUint32(24, sampleRate, true);
  view.setUint32(28, byteRate, true);
  view.setUint16(32, blockAlign, true);
  view.setUint16(34, bitsPerSample, true);

  // data sub-chunk
  view.setUint8(36, 'd'.charCodeAt(0));
  view.setUint8(37, 'a'.charCodeAt(0));
  view.setUint8(38, 't'.charCodeAt(0));
  view.setUint8(39, 'a'.charCodeAt(0));
  view.setUint32(40, dataSize, true);

  const wavBytes = new Uint8Array(44 + dataSize);
  wavBytes.set(new Uint8Array(header), 0);
  wavBytes.set(pcmBytes, 44);

  // Uint8Array → base64. 큰 데이터에서 String.fromCharCode(...arr) 가 stack
  // overflow 위험 있어 청크 단위로 처리.
  let binaryStr = '';
  const chunkLen = 0x8000;
  for (let i = 0; i < wavBytes.length; i += chunkLen) {
    const chunk = wavBytes.subarray(i, i + chunkLen);
    binaryStr += String.fromCharCode.apply(null, Array.from(chunk));
  }
  return btoa(binaryStr);
}

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { user, error: authError } = await authenticateUser(req);
    if (authError || !user) {
      return authError ?? jsonResponse({ success: false, error: 'Unauthorized', errorCode: 'PREMIUM_REQUIRED' }, 401);
    }

    let body: TtsRequest;
    try {
      body = (await req.json()) as TtsRequest;
    } catch {
      return jsonResponse(
        { success: false, error: 'Invalid JSON body', errorCode: 'INVALID_INPUT' },
        400,
      );
    }

    const text = (body.text ?? '').trim();
    const voice = (body.voice ?? '').trim();
    const emotion = (body.emotion ?? '').trim();

    if (!text || text.length > MAX_TTS_TEXT_LENGTH) {
      return jsonResponse(
        { success: false, error: 'text required (1..1500 chars)', errorCode: 'INVALID_INPUT' },
        400,
      );
    }
    if (!ALLOWED_VOICES.has(voice)) {
      return jsonResponse(
        { success: false, error: `voice must be one of: ${Array.from(ALLOWED_VOICES).join(', ')}`, errorCode: 'INVALID_INPUT' },
        400,
      );
    }

    // Premium 게이트 — unlimited 또는 잔액 1+ 토큰
    const tokenCheck = await checkTokenBalance(user.id, TTS_TOKEN_COST);
    if (!tokenCheck.hasBalance && !tokenCheck.isUnlimited) {
      return jsonResponse(
        {
          success: false,
          error: '음성 재생은 프리미엄 구독자 전용입니다.',
          errorCode: 'PREMIUM_REQUIRED',
        },
        402, // Payment Required
      );
    }

    // emotion → inline instruction prefix
    const instruction = EMOTION_INSTRUCTIONS[emotion] ?? '';
    const ttsText = instruction ? `${instruction} ${text}` : text;

    // Gemini TTS 호출
    const apiKey = Deno.env.get('GEMINI_API_KEY');
    if (!apiKey) {
      console.error('[character-tts] GEMINI_API_KEY missing');
      return jsonResponse(
        { success: false, error: 'TTS not configured', errorCode: 'INTERNAL' },
        500,
      );
    }

    const geminiResponse = await fetch(GEMINI_TTS_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: JSON.stringify({
        contents: [{ parts: [{ text: ttsText }] }],
        generationConfig: {
          responseModalities: ['AUDIO'],
          speechConfig: {
            voiceConfig: {
              prebuiltVoiceConfig: { voiceName: voice },
            },
          },
        },
      }),
    });

    if (!geminiResponse.ok) {
      const errText = await geminiResponse.text().catch(() => '');
      console.error(
        '[character-tts] Gemini TTS HTTP',
        geminiResponse.status,
        errText.slice(0, 500),
      );
      return jsonResponse(
        { success: false, error: 'TTS upstream failed', errorCode: 'TTS_FAILED' },
        502,
      );
    }

    const geminiPayload = await geminiResponse.json().catch(() => null);
    const pcmBase64 = extractAudioBase64FromGeminiResponse(geminiPayload);
    if (!pcmBase64) {
      console.error(
        '[character-tts] No audio data in Gemini response',
        JSON.stringify(geminiPayload).slice(0, 500),
      );
      return jsonResponse(
        { success: false, error: 'TTS empty response', errorCode: 'TTS_FAILED' },
        502,
      );
    }

    const wavBase64 = wrapPcmAsWavBase64(pcmBase64);

    // 토큰 차감 (unlimited 는 skip — checkTokenBalance.isUnlimited 이미 true)
    if (!tokenCheck.isUnlimited) {
      const deductResult = await deductTokens(
        user.id,
        TTS_TOKEN_COST,
        `character-tts:${voice}${body.messageId ? `:${body.messageId}` : ''}`,
      );
      if (!deductResult.success) {
        // 차감 실패해도 audio 는 이미 받았으므로 응답은 정상으로 — log 만.
        console.error('[character-tts] token deduct failed:', deductResult.error);
      }
    }

    return jsonResponse({
      success: true,
      audioBase64: wavBase64,
      mimeType: 'audio/wav',
    });
  } catch (err) {
    console.error('[character-tts] uncaught:', err);
    return jsonResponse(
      { success: false, error: 'Internal error', errorCode: 'INTERNAL' },
      500,
    );
  }
});
