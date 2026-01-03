// Edge Function: Generate Celebrity Character Image
// 유명인 치비/SD 스타일 캐릭터 이미지 생성
// fortune-face-reading에서 호출됨

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'

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
  faceFeatures?: FaceFeatures  // 선택적 (없어도 생성 가능)
  celebrityType: string        // 필수: actor, idol_member, athlete 등
  professionData?: Record<string, unknown>  // 운동선수 종목 등 추가 정보
}

// ===== Profession Configs (직업별 복장 + 소품) =====

interface ProfessionConfig {
  outfit: string
  props: string
  colors: string
  maleVariant?: string
  femaleVariant?: string
}

const PROFESSION_CONFIGS: Record<string, ProfessionConfig> = {
  actor: {
    outfit: 'stylish casual outfit with jacket',
    props: 'holding a movie clapperboard, film reel nearby',
    colors: 'warm tones, golden accents',
    maleVariant: 'suit jacket, dress shirt',
    femaleVariant: 'elegant blouse, fashionable jacket'
  },
  solo_singer: {
    outfit: 'glamorous stage costume with sparkles',
    props: 'holding a microphone, musical notes floating around',
    colors: 'vibrant purple and pink accents',
    maleVariant: 'stylish performance outfit',
    femaleVariant: 'elegant stage dress'
  },
  idol_member: {
    outfit: 'trendy K-pop style outfit with sparkles',
    props: 'microphone, floating hearts and stars',
    colors: 'bright pastel with glitter effects',
    maleVariant: 'stylish coordinated group outfit',
    femaleVariant: 'cute matching group costume'
  },
  athlete: {
    outfit: 'professional sports uniform',
    props: 'sport-specific equipment (ball, trophy, medal)',
    colors: 'dynamic team colors'
  },
  politician: {
    outfit: 'formal business suit',
    props: 'podium, microphone, small Korean flag',
    colors: 'professional navy, burgundy accents',
    maleVariant: 'navy or charcoal suit, tie',
    femaleVariant: 'formal blazer, professional attire'
  },
  business: {
    outfit: 'executive business attire',
    props: 'briefcase, laptop, smartphone',
    colors: 'corporate blue, gold accents',
    maleVariant: 'premium suit, power tie',
    femaleVariant: 'executive suit or dress'
  },
  streamer: {
    outfit: 'casual gaming attire with hoodie',
    props: 'gaming headset, RGB lights glow, chat bubbles',
    colors: 'neon purple, cyan, pink RGB style',
    maleVariant: 'gaming hoodie, casual style',
    femaleVariant: 'cute casual outfit, gaming accessories'
  },
  pro_gamer: {
    outfit: 'esports team jersey uniform',
    props: 'gaming mouse, mechanical keyboard glow, trophy',
    colors: 'team colors with RGB accents',
    maleVariant: 'team jersey, gaming headset',
    femaleVariant: 'team jersey, gaming headset'
  }
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
    const { celebrityId, celebrityName, gender, faceFeatures, celebrityType, professionData } = body

    console.log(`🎨 [GenerateChibiCharacter] 시작: ${celebrityName} (${celebrityId}) - ${celebrityType}`)

    if (!celebrityId || !celebrityType) {
      return new Response(
        JSON.stringify({ error: 'celebrityId and celebrityType are required' }),
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

    // 2. 치비 스타일 캐릭터 생성
    const result = await generateChibiCharacter(
      supabase,
      celebrityId,
      celebrityName,
      gender,
      celebrityType,
      faceFeatures,
      professionData
    )

    if (!result.success) {
      return new Response(
        JSON.stringify({ error: result.error || 'Failed to generate character image' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`✅ [GenerateCharacter] 완료: ${result.url}`)

    return new Response(
      JSON.stringify({
        success: true,
        characterImageUrl: result.url,
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
 * 치비 스타일 프롬프트 생성
 */
function buildChibiCharacterPrompt(
  celebrityType: string,
  gender: string,
  faceFeatures?: FaceFeatures,
  professionData?: Record<string, unknown>
): string {
  const config = PROFESSION_CONFIGS[celebrityType] || PROFESSION_CONFIGS['actor']
  const genderEn = gender === 'male' ? 'male' : 'female'

  // 성별에 따른 복장 변형
  const outfit = genderEn === 'male'
    ? (config.maleVariant || config.outfit)
    : (config.femaleVariant || config.outfit)

  // 운동선수의 경우 종목별 소품 추가
  let props = config.props
  if (celebrityType === 'athlete' && professionData?.sport) {
    const sportProps: Record<string, string> = {
      'soccer': 'soccer ball, goal net in background',
      'baseball': 'baseball bat, glove, cap',
      'basketball': 'basketball, hoop in background',
      'golf': 'golf club, golf ball',
      'tennis': 'tennis racket, tennis ball',
      'figure_skating': 'ice skates, sparkle effects',
      'swimming': 'swimming goggles, medal',
      'esports': 'gaming headset, keyboard glow'
    }
    props = sportProps[professionData.sport as string] || props
  }

  // 얼굴 특징이 있으면 반영
  let faceDescription = ''
  if (faceFeatures) {
    faceDescription = `
Facial characteristics to subtly reflect:
- Face shape: ${faceFeatures.face_shape || 'oval'}
- Eyes: ${faceFeatures.eyes?.shape || 'almond'} shape
- Expression mood: ${faceFeatures.overall_impression?.join(', ') || 'cheerful'}`
  }

  return `Cute chibi/SD (super-deformed) style character illustration of a Korean ${genderEn}.

Character proportions (CRITICAL):
- Head: 2-3x larger than body (big head ratio)
- Body: Short, simplified, rounded limbs
- Eyes: Large, expressive, sparkling with highlights
- Expression: Cheerful, cute, exaggerated smile
- Height: Full body visible from head to feet

Profession: ${celebrityType.replace('_', ' ')}
- Outfit: ${outfit}
- Props/Accessories: ${props}
- Color palette: ${config.colors}
${faceDescription}

Art style requirements:
- Clean vector-style illustration
- Soft pastel color palette with vibrant accents
- Simple white or light gradient background
- Kawaii Japanese anime aesthetic
- Standing pose, facing slightly toward viewer (3/4 view)
- Cute chibi proportions with expressive face
- Professional quality, suitable for app avatar

DO NOT include: realistic body proportions, complex detailed backgrounds, text, watermarks, multiple characters, adult proportions, scary or serious expressions`
}

/**
 * 치비 스타일 캐릭터 이미지 생성
 */
interface GenerationResult {
  success: boolean
  url?: string
  error?: string
}

async function generateChibiCharacter(
  supabase: ReturnType<typeof createClient>,
  celebrityId: string,
  celebrityName: string,
  gender: string,
  celebrityType: string,
  faceFeatures?: FaceFeatures,
  professionData?: Record<string, unknown>
): Promise<GenerationResult> {
  const prompt = buildChibiCharacterPrompt(celebrityType, gender, faceFeatures, professionData)

  try {
    console.log(`  🖼️ DALL-E 치비 캐릭터 생성 중... (${celebrityType})`)
    console.log(`  📝 프롬프트 길이: ${prompt.length}자`)
    console.log(`  📝 프롬프트:`, prompt)

    // 직접 OpenAI API 호출 (에러 상세 확인용)
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      console.error('  ❌ OPENAI_API_KEY가 설정되지 않음!')
      return { success: false, error: 'OPENAI_API_KEY not set' }
    }
    console.log(`  🔑 API 키 존재: ${openaiApiKey.substring(0, 10)}...`)

    const response = await fetch('https://api.openai.com/v1/images/generations', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${openaiApiKey}`,
      },
      body: JSON.stringify({
        model: 'dall-e-3',
        prompt: prompt,
        n: 1,
        size: '1024x1024',
        quality: 'standard',
        style: 'vivid',
        response_format: 'b64_json',
      }),
    })

    console.log(`  📡 OpenAI 응답 상태: ${response.status} ${response.statusText}`)

    if (!response.ok) {
      const errorBody = await response.text()
      console.error(`  ❌ OpenAI API 에러 (${response.status}):`, errorBody)
      return { success: false, error: `OpenAI API error ${response.status}: ${errorBody}` }
    }

    const data = await response.json()
    const imageResponse = {
      imageBase64: data.data[0].b64_json,
      revisedPrompt: data.data[0].revised_prompt
    }

    console.log(`  ✅ 이미지 생성 성공, revised_prompt: ${imageResponse.revisedPrompt?.substring(0, 100)}...`)

    if (!imageResponse.imageBase64) {
      console.log('  ⚠️ 캐릭터 이미지 생성 실패: no imageBase64')
      return { success: false, error: 'No imageBase64 in response' }
    }

    // Supabase Storage에 업로드 (celebrities 버킷 사용)
    const fileName = `characters/${celebrityId}.png`
    const imageBuffer = Uint8Array.from(atob(imageResponse.imageBase64), c => c.charCodeAt(0))

    console.log(`  📦 Storage 업로드 중: celebrities/${fileName}`)

    const { error: uploadError } = await supabase.storage
      .from('celebrities')
      .upload(fileName, imageBuffer, {
        contentType: 'image/png',
        upsert: true
      })

    if (uploadError) {
      console.log('  ⚠️ Storage 업로드 실패:', uploadError.message)
      return { success: false, error: `Storage upload failed: ${uploadError.message}` }
    }

    // Public URL 생성
    const { data: urlData } = supabase.storage
      .from('celebrities')
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

    console.log(`  ✅ 치비 캐릭터 생성 완료: ${publicUrl}`)
    return { success: true, url: publicUrl }

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error)
    console.error('  ❌ 치비 캐릭터 생성 오류:', errorMessage)
    console.error('  ❌ 상세 에러:', JSON.stringify(error, null, 2))
    return { success: false, error: errorMessage }
  }
}
