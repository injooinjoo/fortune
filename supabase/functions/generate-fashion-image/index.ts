/**
 * NanoBanana 패션 이미지 생성 Edge Function
 *
 * 사용자의 스타일 선택과 오행 기반 패션 추천을 바탕으로
 * 전신 패션 이미지를 생성합니다.
 *
 * Cost: 35 souls ($0.02/image via NanoBanana)
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const NANOBANANA_API_KEY = Deno.env.get('NANOBANANA_API_KEY')
const NANOBANANA_API_URL = 'https://api.nanobanana.ai/v1/generate'
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

interface FashionImageRequest {
  userId: string
  gender: 'male' | 'female'
  styleType: string // hip, neat, sexy, intellectual, natural, romantic, sporty
  outfitData: {
    top: { item: string; color: string }
    bottom: { item: string; color: string }
    outer?: { item: string; color: string }
    shoes: { item: string; color: string }
    accessories?: string[]
  }
  colorTone: 'warm' | 'cool'
}

// 스타일별 프롬프트 힌트
const STYLE_PROMPTS: Record<string, string> = {
  hip: 'trendy streetwear aesthetic, oversized fit, urban fashion, bold accessories',
  neat: 'clean minimalist style, well-fitted formal wear, polished professional look',
  sexy: 'elegant fitted silhouette, sophisticated glamour, confident pose',
  intellectual: 'smart casual, classic refined style, glasses optional, scholarly vibe',
  natural: 'relaxed comfortable fit, earthy tones, effortless casual style',
  romantic: 'soft feminine aesthetic, flowing fabrics, delicate details, pastel accents',
  sporty: 'athletic wear, dynamic pose, active lifestyle, sporty accessories',
}

/**
 * 패션 이미지 프롬프트 생성
 */
function buildFashionPrompt(request: FashionImageRequest): string {
  const { gender, styleType, outfitData, colorTone } = request
  const modelType = gender === 'male' ? 'Korean male model' : 'Korean female model'
  const styleHint = STYLE_PROMPTS[styleType] || STYLE_PROMPTS.neat

  const accessories = outfitData.accessories?.join(', ') || 'minimal accessories'
  const outer = outfitData.outer
    ? `${outfitData.outer.item} in ${outfitData.outer.color},`
    : ''

  return `Professional fashion photography, ${modelType}, full body shot,
wearing ${outfitData.top.item} in ${outfitData.top.color},
${outfitData.bottom.item} in ${outfitData.bottom.color},
${outer}
${outfitData.shoes.item} in ${outfitData.shoes.color}.
Accessories: ${accessories}.
Style: ${styleHint}.
Color palette: ${colorTone} tones.
Setting: Clean white studio background, soft studio lighting.
Pose: Confident natural standing pose, fashion editorial quality.
Camera: Full body portrait, 9:16 aspect ratio, high fashion magazine style.
Quality: 4K, professional photography, studio lighting, sharp focus.
DO NOT include: text, logos, watermarks, blurry, distorted, cartoon, anime.`
}

/**
 * NanoBanana API를 통한 이미지 생성
 */
async function generateImageWithNanoBanana(prompt: string): Promise<string> {
  console.log('🎨 Generating fashion image with NanoBanana...')

  if (!NANOBANANA_API_KEY) {
    // NanoBanana API 키가 없으면 placeholder 반환
    console.log('⚠️ NanoBanana API key not configured, returning placeholder')
    throw new Error('NanoBanana API key not configured')
  }

  const response = await fetch(NANOBANANA_API_URL, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${NANOBANANA_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      prompt,
      aspect_ratio: '9:16',
      style: 'fashion_photography',
      quality: 'high',
    }),
  })

  if (!response.ok) {
    const errorText = await response.text()
    console.error('❌ NanoBanana API error:', errorText)
    throw new Error(`NanoBanana API failed: ${response.status}`)
  }

  const result = await response.json()
  console.log('✅ Image generated successfully')

  return result.image_base64 || result.imageBase64 || result.image
}

/**
 * Supabase Storage에 이미지 업로드
 */
async function uploadToSupabase(
  imageBase64: string,
  userId: string,
  styleType: string
): Promise<string> {
  console.log('📤 Uploading to Supabase Storage...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  // Convert base64 to blob
  const imageBuffer = Uint8Array.from(atob(imageBase64), (c) => c.charCodeAt(0))
  const fileName = `${userId}/${styleType}_${Date.now()}.png`

  const { error } = await supabase.storage
    .from('fashion-images')
    .upload(fileName, imageBuffer, {
      contentType: 'image/png',
      upsert: false,
    })

  if (error) {
    console.error('❌ Upload error:', error)
    throw new Error(`Upload failed: ${error.message}`)
  }

  const { data: publicUrlData } = supabase.storage
    .from('fashion-images')
    .getPublicUrl(fileName)

  console.log('✅ Upload successful:', publicUrlData.publicUrl)
  return publicUrlData.publicUrl
}

/**
 * 패션 이미지 기록 저장
 */
async function saveFashionImageRecord(
  userId: string,
  styleType: string,
  gender: string,
  imageUrl: string,
  prompt: string,
  outfitData: FashionImageRequest['outfitData']
): Promise<string> {
  console.log('💾 Saving fashion image record to database...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  const { data, error } = await supabase
    .from('fashion_images')
    .insert({
      user_id: userId,
      style_type: styleType,
      gender,
      image_url: imageUrl,
      prompt_used: prompt,
      outfit_data: outfitData,
    })
    .select('id')
    .single()

  if (error) {
    console.error('❌ Database error:', error)
    throw new Error(`Database insert failed: ${error.message}`)
  }

  console.log('✅ Record saved with ID:', data.id)
  return data.id
}

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: CORS_HEADERS })
  }

  try {
    const request: FashionImageRequest = await req.json()
    console.log('📥 Fashion image request:', {
      userId: request.userId,
      gender: request.gender,
      styleType: request.styleType,
    })

    // 1. 프롬프트 생성
    const prompt = buildFashionPrompt(request)
    console.log('📝 Generated prompt length:', prompt.length)

    // 2. NanoBanana로 이미지 생성
    const imageBase64 = await generateImageWithNanoBanana(prompt)

    // 3. Supabase Storage에 업로드
    const imageUrl = await uploadToSupabase(
      imageBase64,
      request.userId,
      request.styleType
    )

    // 4. DB에 기록 저장
    const recordId = await saveFashionImageRecord(
      request.userId,
      request.styleType,
      request.gender,
      imageUrl,
      prompt,
      request.outfitData
    )

    return new Response(
      JSON.stringify({
        success: true,
        imageUrl,
        recordId,
        styleType: request.styleType,
      }),
      {
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    console.error('❌ Error:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      }
    )
  }
})
