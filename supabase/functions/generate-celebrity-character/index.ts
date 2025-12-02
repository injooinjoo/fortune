// Edge Function: Generate Celebrity Character Image
// 연예인 노션 스타일 캐릭터 이미지 생성
// fortune-face-reading에서 호출됨

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'
import { OpenAIProvider } from '../_shared/llm/providers/openai.ts'

// ===== Types =====

interface FaceFeatures {
  face_shape: string
  eyes: { shape: string; size: string }
  eyebrows: { shape: string; thickness: string }
  nose: { bridge: string; tip: string }
  mouth: { size: string; lips: string }
  jawline: { shape: string }
  overall_impression: string[]
}

interface RequestBody {
  celebrityId: string
  celebrityName: string
  gender: string
  faceFeatures: FaceFeatures
}

// ===== CORS Headers =====

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ===== Main Handler =====

serve(async (req) => {
  // CORS Preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const body: RequestBody = await req.json()
    const { celebrityId, celebrityName, gender, faceFeatures } = body

    console.log(`🎨 [GenerateCharacter] 시작: ${celebrityName} (${celebrityId})`)

    if (!celebrityId || !faceFeatures) {
      return new Response(
        JSON.stringify({ error: 'celebrityId and faceFeatures are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Supabase Client 생성
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 1. 이미 이미지가 있는지 다시 확인 (동시 요청 방지)
    const { data: existing } = await supabase
      .from('celebrities')
      .select('character_image_url')
      .eq('id', celebrityId)
      .single()

    if (existing?.character_image_url) {
      console.log(`✅ [GenerateCharacter] 이미 존재: ${existing.character_image_url}`)
      return new Response(
        JSON.stringify({
          success: true,
          characterImageUrl: existing.character_image_url,
          cached: true
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. OpenAI Provider 초기화 (DALL-E)
    const openaiProvider = new OpenAIProvider({
      apiKey: Deno.env.get('OPENAI_API_KEY') || '',
      model: 'gpt-4o'
    })

    // 3. 노션 스타일 캐릭터 생성
    const characterImageUrl = await generateNotionCharacter(
      openaiProvider,
      supabase,
      celebrityId,
      celebrityName,
      gender,
      faceFeatures
    )

    if (!characterImageUrl) {
      return new Response(
        JSON.stringify({ error: 'Failed to generate character image' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`✅ [GenerateCharacter] 완료: ${characterImageUrl}`)

    return new Response(
      JSON.stringify({
        success: true,
        characterImageUrl,
        cached: false
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ [GenerateCharacter] 오류:', error)
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : 'Unknown error'
      }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// ===== Helper Functions =====

/**
 * 노션 스타일 캐릭터 이미지 생성
 */
async function generateNotionCharacter(
  provider: OpenAIProvider,
  supabase: ReturnType<typeof createClient>,
  celebrityId: string,
  celebrityName: string,
  gender: string,
  faceFeatures: FaceFeatures
): Promise<string | null> {
  const genderEn = gender === 'male' ? 'male' : 'female'
  const impressions = faceFeatures.overall_impression?.join(', ') || 'friendly'

  const prompt = `Notion-style minimalist avatar of a Korean ${genderEn} celebrity.

Key facial features:
- Face shape: ${faceFeatures.face_shape}
- Eyes: ${faceFeatures.eyes?.shape || 'almond'}, ${faceFeatures.eyes?.size || 'medium'}
- Eyebrows: ${faceFeatures.eyebrows?.shape || 'arched'}, ${faceFeatures.eyebrows?.thickness || 'medium'}
- Nose: ${faceFeatures.nose?.bridge || 'medium'} bridge, ${faceFeatures.nose?.tip || 'round'} tip
- Mouth: ${faceFeatures.mouth?.size || 'medium'}, ${faceFeatures.mouth?.lips || 'medium'} lips
- Jawline: ${faceFeatures.jawline?.shape || 'rounded'}
- Overall impression: ${impressions}

Style requirements:
- Simple flat illustration
- Pastel colors with soft gradients
- White or light cream background
- Friendly, approachable expression
- No text or labels
- Clean vector style like Notion avatars
- Portrait composition, head and shoulders only
- Minimalist design, avoid complex details`

  try {
    console.log(`  🖼️ DALL-E 이미지 생성 중...`)

    const imageResponse = await provider.generateImage(prompt, {
      size: '1024x1024',
      quality: 'standard',
      style: 'natural'
    })

    if (!imageResponse.imageBase64) {
      console.log('  ⚠️ 캐릭터 이미지 생성 실패: no imageBase64')
      return null
    }

    // Supabase Storage에 업로드
    const fileName = `celebrity-characters/${celebrityId}.png`
    const imageBuffer = Uint8Array.from(atob(imageResponse.imageBase64), c => c.charCodeAt(0))

    console.log(`  📦 Storage 업로드 중: ${fileName}`)

    const { error: uploadError } = await supabase.storage
      .from('public-assets')
      .upload(fileName, imageBuffer, {
        contentType: 'image/png',
        upsert: true
      })

    if (uploadError) {
      console.log('  ⚠️ Storage 업로드 실패:', uploadError.message)
      return null
    }

    // Public URL 생성
    const { data: urlData } = supabase.storage
      .from('public-assets')
      .getPublicUrl(fileName)

    const publicUrl = urlData.publicUrl

    // DB 업데이트
    const { error: updateError } = await supabase
      .from('celebrities')
      .update({
        character_image_url: publicUrl,
        updated_at: new Date().toISOString()
      })
      .eq('id', celebrityId)

    if (updateError) {
      console.log('  ⚠️ DB 업데이트 실패:', updateError.message)
      // 이미지는 생성됐으므로 URL 반환
    }

    console.log(`  ✅ 캐릭터 생성 완료: ${publicUrl}`)
    return publicUrl

  } catch (error) {
    console.error('  ❌ 캐릭터 생성 오류:', error)
    return null
  }
}
