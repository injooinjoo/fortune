import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'

type ProactiveImageCategory = 'meal' | 'workout'

interface GenerateCharacterProactiveImageRequest {
  characterId: string
  category: ProactiveImageCategory
  contextText?: string
  styleHint?: string
}

interface GenerateCharacterProactiveImageResponse {
  success: boolean
  imageUrl?: string
  meta?: {
    provider: string
    model: string
    latencyMs: number
  }
  error?: string
}

const SUPPORTED_CHARACTER_ID = 'luts'
const BUCKET_NAME = 'character-proactive-images'

function isValidCategory(value: string): value is ProactiveImageCategory {
  return value === 'meal' || value === 'workout'
}

function buildPrompt(request: GenerateCharacterProactiveImageRequest): string {
  const baseTone =
    request.category === 'meal'
      ? 'A natural smartphone snapshot of a Korean lunchbox or meal on a table. Realistic daily life style, cozy indoor lighting.'
      : 'A natural smartphone snapshot after exercise. Gym or workout context, candid realistic style, no brand logos.'

  const contextPart = request.contextText
    ? `Context from recent chat: ${request.contextText.slice(0, 160)}`
    : ''
  const styleHintPart = request.styleHint ? `Style hint: ${request.styleHint}` : ''

  return `
Create a realistic phone photo for a character chat follow-up.
- Character: ${request.characterId}
- Category: ${request.category}
- Visual direction: ${baseTone}
${contextPart}
${styleHintPart}

Requirements:
- photorealistic, candid, not studio
- no text, no watermark, no logos
- safe everyday content only
- single image
`.trim()
}

function buildStoragePath(
  characterId: string,
  category: ProactiveImageCategory
): string {
  const timestamp = Date.now()
  const uid = crypto.randomUUID().split('-')[0]
  return `${characterId}/${category}/${timestamp}_${uid}.png`
}

serve(async (req: Request) => {
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  const startedAt = Date.now()

  try {
    const request = (await req.json()) as GenerateCharacterProactiveImageRequest

    if (!request.characterId || !request.category) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'characterId, category는 필수입니다',
        } as GenerateCharacterProactiveImageResponse),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    if (request.characterId !== SUPPORTED_CHARACTER_ID) {
      return new Response(
        JSON.stringify({
          success: false,
          error: `${SUPPORTED_CHARACTER_ID} 캐릭터만 지원합니다`,
        } as GenerateCharacterProactiveImageResponse),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    if (!isValidCategory(request.category)) {
      return new Response(
        JSON.stringify({
          success: false,
          error: 'category는 meal | workout만 허용됩니다',
        } as GenerateCharacterProactiveImageResponse),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 400,
        }
      )
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    if (!supabaseUrl || !serviceRoleKey) {
      throw new Error('Supabase service role 환경변수가 설정되지 않았습니다')
    }

    const llm = LLMFactory.create('gemini', 'gemini-2.5-flash-image')
    if (!llm.generateImage) {
      throw new Error('선택된 모델이 이미지 생성을 지원하지 않습니다')
    }

    const prompt = buildPrompt(request)
    const imageResult = await llm.generateImage(prompt)

    const imageBytes = Uint8Array.from(atob(imageResult.imageBase64), (c) =>
      c.charCodeAt(0)
    )
    const storagePath = buildStoragePath(request.characterId, request.category)

    const supabase = createClient(supabaseUrl, serviceRoleKey)
    const { error: uploadError } = await supabase.storage
      .from(BUCKET_NAME)
      .upload(storagePath, imageBytes, {
        contentType: 'image/png',
        upsert: false,
      })

    if (uploadError) {
      throw new Error(`이미지 업로드 실패: ${uploadError.message}`)
    }

    const { data: publicUrlData } = supabase.storage
      .from(BUCKET_NAME)
      .getPublicUrl(storagePath)

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
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        meta: {
          provider: 'gemini',
          model: 'gemini-2.5-flash-image',
          latencyMs: Date.now() - startedAt,
        },
      } as GenerateCharacterProactiveImageResponse),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})
