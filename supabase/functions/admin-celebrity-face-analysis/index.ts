// Admin Edge Function: Celebrity Face Analysis
// 연예인 관상 데이터 배치 분석 및 노션 스타일 캐릭터 생성
// 보안: Service Role Key 필수

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3'
import { GeminiProvider } from '../_shared/llm/providers/gemini.ts'
import { OpenAIProvider } from '../_shared/llm/providers/openai.ts'

// ===== Types =====

interface FaceFeatures {
  face_shape: 'oval' | 'round' | 'square' | 'oblong' | 'heart' | 'diamond'
  eyes: {
    shape: 'round' | 'almond' | 'phoenix' | 'monolid' | 'double_lid'
    size: 'large' | 'medium' | 'small'
  }
  eyebrows: {
    shape: 'straight' | 'arched' | 'curved' | 'angled'
    thickness: 'thick' | 'medium' | 'thin'
  }
  nose: {
    bridge: 'high' | 'medium' | 'low'
    tip: 'round' | 'pointed' | 'upturned'
  }
  mouth: {
    size: 'large' | 'medium' | 'small'
    lips: 'full' | 'medium' | 'thin'
  }
  jawline: {
    shape: 'angular' | 'rounded' | 'pointed' | 'square'
  }
  overall_impression: string[]
  analyzed_at: string
}

interface Celebrity {
  id: string
  name: string
  gender: string
  external_ids?: {
    instagram?: string
    wikipedia?: string
    profile_image?: string
  }
  face_features?: FaceFeatures | null
  character_image_url?: string | null
}

interface RequestBody {
  celebrityIds?: string[]
  limit?: number
  generateCharacter?: boolean
  forceReanalyze?: boolean
}

interface AnalysisResult {
  celebrityId: string
  celebrityName: string
  success: boolean
  faceFeatures?: FaceFeatures
  characterImageUrl?: string
  error?: string
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
    // 1. Service Role 인증 확인
    const authHeader = req.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ error: 'Missing authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

    // Service Role Key 확인 (Admin 전용)
    const token = authHeader.replace('Bearer ', '')
    if (token !== serviceRoleKey) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized. Service role key required.' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 2. Supabase Client 생성 (Service Role)
    const supabase = createClient(supabaseUrl, serviceRoleKey)

    // 3. 요청 파싱
    const body: RequestBody = await req.json()
    const {
      celebrityIds,
      limit = 10,
      generateCharacter = false,
      forceReanalyze = false
    } = body

    console.log('🎬 Admin Celebrity Face Analysis 시작')
    console.log(`  - celebrityIds: ${celebrityIds?.length || 'all'}`)
    console.log(`  - limit: ${limit}`)
    console.log(`  - generateCharacter: ${generateCharacter}`)
    console.log(`  - forceReanalyze: ${forceReanalyze}`)

    // 4. 분석 대상 연예인 조회
    let query = supabase
      .from('celebrities')
      .select('id, name, gender, external_ids, face_features, character_image_url')

    if (celebrityIds && celebrityIds.length > 0) {
      query = query.in('id', celebrityIds)
    } else if (!forceReanalyze) {
      // face_features가 없는 연예인만 조회
      query = query.is('face_features', null)
    }

    query = query.limit(limit)

    const { data: celebrities, error: fetchError } = await query

    if (fetchError) {
      throw new Error(`Failed to fetch celebrities: ${fetchError.message}`)
    }

    if (!celebrities || celebrities.length === 0) {
      return new Response(
        JSON.stringify({
          message: 'No celebrities to analyze',
          processed: 0,
          results: []
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`📊 분석 대상: ${celebrities.length}명`)

    // 5. LLM Providers 초기화
    const geminiProvider = new GeminiProvider({
      apiKey: Deno.env.get('GEMINI_API_KEY') || '',
      model: 'gemini-2.0-flash-exp'
    })

    const openaiProvider = new OpenAIProvider({
      apiKey: Deno.env.get('OPENAI_API_KEY') || '',
      model: 'gpt-4o'
    })

    // 6. 배치 분석 실행
    const results: AnalysisResult[] = []

    for (const celebrity of celebrities as Celebrity[]) {
      console.log(`\n🔍 분석 중: ${celebrity.name} (${celebrity.id})`)

      try {
        // 6a. 이미지 URL 가져오기
        const imageUrl = getImageUrl(celebrity)

        if (!imageUrl) {
          console.log(`  ⚠️ 이미지 URL 없음, 스킵`)
          results.push({
            celebrityId: celebrity.id,
            celebrityName: celebrity.name,
            success: false,
            error: 'No image URL available'
          })
          continue
        }

        console.log(`  📸 이미지 URL: ${imageUrl.substring(0, 50)}...`)

        // 6b. 이미지 다운로드 및 Base64 변환
        const imageBase64 = await fetchImageAsBase64(imageUrl)

        if (!imageBase64) {
          console.log(`  ⚠️ 이미지 다운로드 실패, 스킵`)
          results.push({
            celebrityId: celebrity.id,
            celebrityName: celebrity.name,
            success: false,
            error: 'Failed to download image'
          })
          continue
        }

        // 6c. Gemini Vision으로 관상 분석
        const faceFeatures = await analyzeFaceWithVision(geminiProvider, imageBase64, celebrity)

        if (!faceFeatures) {
          console.log(`  ⚠️ 관상 분석 실패`)
          results.push({
            celebrityId: celebrity.id,
            celebrityName: celebrity.name,
            success: false,
            error: 'Face analysis failed'
          })
          continue
        }

        console.log(`  ✅ 관상 분석 완료: ${faceFeatures.face_shape}`)

        // 6d. DB 업데이트
        const { error: updateError } = await supabase
          .from('celebrities')
          .update({
            face_features: faceFeatures,
            updated_at: new Date().toISOString()
          })
          .eq('id', celebrity.id)

        if (updateError) {
          throw new Error(`DB update failed: ${updateError.message}`)
        }

        // 6e. 노션 스타일 캐릭터 생성 (옵션)
        let characterImageUrl: string | undefined

        if (generateCharacter && (!celebrity.character_image_url || forceReanalyze)) {
          console.log(`  🎨 노션 캐릭터 생성 중...`)
          characterImageUrl = await generateNotionCharacter(
            openaiProvider,
            supabase,
            celebrity,
            faceFeatures
          )

          if (characterImageUrl) {
            console.log(`  ✅ 캐릭터 생성 완료`)

            // character_image_url 업데이트
            await supabase
              .from('celebrities')
              .update({ character_image_url: characterImageUrl })
              .eq('id', celebrity.id)
          }
        }

        results.push({
          celebrityId: celebrity.id,
          celebrityName: celebrity.name,
          success: true,
          faceFeatures,
          characterImageUrl
        })

      } catch (error) {
        console.error(`  ❌ 오류: ${error}`)
        results.push({
          celebrityId: celebrity.id,
          celebrityName: celebrity.name,
          success: false,
          error: error instanceof Error ? error.message : String(error)
        })
      }

      // Rate limiting: 1초 대기
      await new Promise(resolve => setTimeout(resolve, 1000))
    }

    // 7. 결과 반환
    const successCount = results.filter(r => r.success).length
    const failCount = results.filter(r => !r.success).length

    console.log(`\n📊 분석 완료: 성공 ${successCount}, 실패 ${failCount}`)

    return new Response(
      JSON.stringify({
        message: `Analyzed ${successCount} celebrities successfully`,
        processed: celebrities.length,
        success: successCount,
        failed: failCount,
        results
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Admin Celebrity Face Analysis 오류:', error)
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
 * 연예인 이미지 URL 추출
 */
function getImageUrl(celebrity: Celebrity): string | null {
  const externalIds = celebrity.external_ids

  if (!externalIds) return null

  // 우선순위: profile_image > instagram > wikipedia
  if (externalIds.profile_image) {
    return externalIds.profile_image
  }

  // Instagram 프로필은 직접 접근 어려우므로 스킵
  // Wikipedia 이미지도 별도 처리 필요

  return null
}

/**
 * 이미지 URL을 Base64로 변환
 */
async function fetchImageAsBase64(imageUrl: string): Promise<string | null> {
  try {
    const response = await fetch(imageUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
      }
    })

    if (!response.ok) {
      console.log(`    이미지 fetch 실패: ${response.status}`)
      return null
    }

    const arrayBuffer = await response.arrayBuffer()
    const uint8Array = new Uint8Array(arrayBuffer)

    // Base64 인코딩
    let binary = ''
    for (let i = 0; i < uint8Array.length; i++) {
      binary += String.fromCharCode(uint8Array[i])
    }

    return btoa(binary)
  } catch (error) {
    console.error(`    이미지 다운로드 오류: ${error}`)
    return null
  }
}

/**
 * Gemini Vision으로 관상 분석
 */
async function analyzeFaceWithVision(
  provider: GeminiProvider,
  imageBase64: string,
  celebrity: Celebrity
): Promise<FaceFeatures | null> {
  const systemPrompt = `당신은 동양 관상학(觀相學) 전문가입니다.
주어진 얼굴 이미지를 분석하여 관상학적 특징을 추출해주세요.

다음 JSON 스키마에 맞춰 정확하게 응답하세요:

{
  "face_shape": "oval|round|square|oblong|heart|diamond 중 하나",
  "eyes": {
    "shape": "round|almond|phoenix|monolid|double_lid 중 하나",
    "size": "large|medium|small 중 하나"
  },
  "eyebrows": {
    "shape": "straight|arched|curved|angled 중 하나",
    "thickness": "thick|medium|thin 중 하나"
  },
  "nose": {
    "bridge": "high|medium|low 중 하나",
    "tip": "round|pointed|upturned 중 하나"
  },
  "mouth": {
    "size": "large|medium|small 중 하나",
    "lips": "full|medium|thin 중 하나"
  },
  "jawline": {
    "shape": "angular|rounded|pointed|square 중 하나"
  },
  "overall_impression": ["키워드 3-5개 배열 (예: elegant, charismatic, friendly, intellectual, warm)"]
}

주의사항:
- 반드시 위 스키마의 허용된 값만 사용하세요
- overall_impression은 영어 형용사로 3-5개 입력하세요
- JSON만 출력하고, 다른 텍스트는 포함하지 마세요`

  const userPrompt = `이 ${celebrity.gender === 'male' ? '남성' : '여성'} 연예인(${celebrity.name})의 얼굴을 관상학적으로 분석해주세요.`

  try {
    const response = await provider.generate(
      [
        { role: 'system', content: systemPrompt },
        {
          role: 'user',
          content: [
            { type: 'text', text: userPrompt },
            {
              type: 'image_url',
              image_url: { url: `data:image/jpeg;base64,${imageBase64}` }
            }
          ] as any
        }
      ],
      {
        temperature: 0.3,
        maxTokens: 1000,
        jsonMode: true
      }
    )

    // JSON 파싱
    const content = response.content.trim()
    const jsonMatch = content.match(/\{[\s\S]*\}/)

    if (!jsonMatch) {
      console.log('    JSON 파싱 실패:', content.substring(0, 100))
      return null
    }

    const parsed = JSON.parse(jsonMatch[0]) as FaceFeatures
    parsed.analyzed_at = new Date().toISOString()

    return parsed

  } catch (error) {
    console.error('    Vision 분석 오류:', error)
    return null
  }
}

/**
 * 노션 스타일 캐릭터 이미지 생성
 */
async function generateNotionCharacter(
  provider: OpenAIProvider,
  supabase: ReturnType<typeof createClient>,
  celebrity: Celebrity,
  faceFeatures: FaceFeatures
): Promise<string | null> {
  // 특징 기반 프롬프트 생성
  const genderKo = celebrity.gender === 'male' ? 'male' : 'female'
  const impressions = faceFeatures.overall_impression.join(', ')

  const prompt = `Notion-style minimalist avatar of a Korean ${genderKo} celebrity.

Key facial features:
- Face shape: ${faceFeatures.face_shape}
- Eyes: ${faceFeatures.eyes.shape}, ${faceFeatures.eyes.size}
- Eyebrows: ${faceFeatures.eyebrows.shape}, ${faceFeatures.eyebrows.thickness}
- Nose: ${faceFeatures.nose.bridge} bridge, ${faceFeatures.nose.tip} tip
- Mouth: ${faceFeatures.mouth.size}, ${faceFeatures.mouth.lips} lips
- Jawline: ${faceFeatures.jawline.shape}
- Overall impression: ${impressions}

Style requirements:
- Simple flat illustration
- Pastel colors with soft gradients
- White or light cream background
- Friendly, approachable expression
- No text or labels
- Clean vector style like Notion avatars
- Portrait composition, head and shoulders only`

  try {
    const imageResponse = await provider.generateImage(prompt, {
      size: '1024x1024',
      quality: 'standard',
      style: 'natural'
    })

    if (!imageResponse.imageBase64) {
      console.log('    캐릭터 이미지 생성 실패')
      return null
    }

    // Supabase Storage에 업로드
    const fileName = `celebrity-characters/${celebrity.id}.png`
    const imageBuffer = Uint8Array.from(atob(imageResponse.imageBase64), c => c.charCodeAt(0))

    const { error: uploadError } = await supabase.storage
      .from('public-assets')
      .upload(fileName, imageBuffer, {
        contentType: 'image/png',
        upsert: true
      })

    if (uploadError) {
      console.log('    Storage 업로드 실패:', uploadError.message)
      return null
    }

    // Public URL 생성
    const { data: urlData } = supabase.storage
      .from('public-assets')
      .getPublicUrl(fileName)

    return urlData.publicUrl

  } catch (error) {
    console.error('    캐릭터 생성 오류:', error)
    return null
  }
}
