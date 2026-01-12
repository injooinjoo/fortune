/**
 * 2026 올해의 인연 (Yearly Encounter) Edge Function
 *
 * 미래 애인 얼굴을 AI로 생성하고, 만남 예측 정보를 제공하는 운세 기능
 *
 * Cost: 10 tokens
 * - Image: Gemini 2.5 Flash Image (gemini-2.5-flash-image)
 * - Text: Gemini 2.0 Flash Lite (gemini-2.0-flash-lite)
 *
 * Self-contained: 공유 모듈 없이 독립 실행 가능
 */

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

// ============================================================================
// Types
// ============================================================================

interface YearlyEncounterRequest {
  userId: string
  targetGender: 'male' | 'female'
  userAge: string // '20대 초반', '20대 중반', etc.
  idealMbti: string // MBTI or '상관없음'
  idealType: string // 자유 텍스트 이상형 설명
  isPremium?: boolean
}

interface YearlyEncounterResponse {
  success: boolean
  data?: {
    imageUrl: string
    appearanceHashtags: string[]
    encounterSpot: string
    fateSignal: string
    personality: string
    compatibilityScore: string
    compatibilityDescription: string
    targetGender: string
    createdAt: string
  }
  isBlurred: boolean
  blurredSections: string[]
  error?: string
}

// ============================================================================
// DB Constants (고정값)
// ============================================================================

const ENCOUNTER_SPOTS = [
  { id: 'station', text: '비 오는 날, 우산이 없어 망설이던 지하철역 3번 출구' },
  { id: 'party', text: '친구가 억지로 불러서 나갔던 시끄러운 술자리 구석' },
  { id: 'office', text: '프로젝트 협업을 위해 처음 마주한 업무용 미팅룸' },
  { id: 'cafe', text: '주말 오후, 자리가 없어 우연히 합석하게 된 단골 카페' },
  { id: 'library', text: '시험 기간, 조용한 도서관에서 계속 눈이 마주치던 옆자리' },
  { id: 'park', text: '노을 지는 한강 공원, 강아지 줄이 꼬여서 사과하던 순간' },
  { id: 'concert', text: '좋아하는 가수의 공연장, 티켓을 떨어뜨렸을 때 주워준 사람' },
  { id: 'elevator', text: '늦잠 자서 급하게 탄 엘리베이터 안, 같은 층을 누른 인연' },
  { id: 'travel', text: '여행지 게스트하우스, 공용 공간에서 맥주 한 잔 나누던 밤' },
  { id: 'workshop', text: '원데이 클래스, 서툰 손길로 무언가를 만들다 웃음이 터진 순간' },
]

const FATE_SIGNALS = [
  { id: 'scent', text: '상대방이 가까이 올 때 은은하게 풍기는 우디향 향수 냄새' },
  { id: 'color', text: '그 사람이 유독 선명한 파란색 셔츠를 입고 나타나는 날' },
  { id: 'item', text: '나와 똑같은 브랜드의 키링이나 핸드폰 케이스를 가지고 있음' },
  { id: 'habit', text: '말을 걸 때 살짝 뒷머리를 긁적이는 수줍은 습관' },
  { id: 'drink', text: '아무 말 없이 건네주는 시원한 아이스 아메리카노 한 잔' },
  { id: 'sound', text: '대화 중 들려오는 낮고 차분하지만 다정한 중저음 목소리' },
  { id: 'weather', text: '유독 첫눈이 내리거나 비가 쏟아지는 날의 만남' },
  { id: 'gesture', text: '내 쪽으로 몸을 살짝 기울여 경청하는 정중한 자세' },
  { id: 'eyes', text: '눈이 마주쳤을 때 피하지 않고 3초간 머무는 따뜻한 시선' },
  { id: 'time', text: '오후 4시 44분, 혹은 밤 11시 11분 같은 반복되는 숫자 확인 후 만남' },
]

const PERSONALITY_TRAITS = [
  { id: 'contrast', text: "연락은 조금 느리지만, 만나면 누구보다 다정한 '낮져밤이' 타입" },
  { id: 'care', text: '툭툭 무심한 듯 챙겨주지만 속은 깊고 따뜻한 츤데레 정석' },
  { id: 'hobby', text: '자기 일에 몰입할 땐 섹시하고, 쉴 때는 영락없는 집돌이 너드' },
  { id: 'social', text: '처음엔 낯가리지만 내 사람이다 싶으면 장난기 폭발하는 유죄인간' },
  { id: 'loyalty', text: '한 번 마음 주면 흔들림 없이 나만 바라보는 서사 맛집 해바라기' },
  { id: 'polite', text: '선을 지킬 줄 알면서도 결정적인 순간엔 직진하는 어른스러운 연하남' },
  { id: 'passion', text: '조용한 성격 뒤에 숨겨진 뜨거운 열정과 은근한 소유욕' },
  { id: 'healing', text: '같이 있기만 해도 힐링 되는, 정서적 안정감을 주는 대화 천재' },
  { id: 'sharp', text: '예민하고 섬세한 감각을 가졌지만 나에게만큼은 무장해제되는 반전남' },
  { id: 'classic', text: '유행에 민감하지 않아도 본인만의 확고한 취향이 있는 댄디한 성격' },
]

const COMPATIBILITY_SCORES: { score: string; description: string }[] = [
  { score: '98%', description: '전생부터 정해진 역대급 비주얼 합! (SNS 공유 필수 지수)' },
  { score: '92%', description: "첫눈에 서로 '내 사람이다' 느낄 찰떡 비주얼 조합" },
  { score: '88%', description: '같이 서 있기만 해도 화보가 되는 비주얼 완성형 궁합' },
  { score: '85%', description: '서로의 매력을 극대화해 주는 가장 이상적인 밸런스' },
  { score: '79%', description: '닮은 듯 다른 느낌이 주는 묘한 끌림, 케미 폭발 지수' },
]

// ============================================================================
// Helper Functions
// ============================================================================

function getAgeRange(userAge: string): string {
  const ageMap: Record<string, string> = {
    '20대 초반': 'early 20s',
    '20대 중반': 'mid 20s',
    '20대 후반': 'late 20s',
    '30대 초반': 'early 30s',
    '30대 중반': 'mid 30s',
    '30대 후반': 'late 30s',
    '40대 이상': 'early 40s',
  }
  return ageMap[userAge] || 'mid 20s'
}

function randomPick<T>(array: T[]): T {
  return array[Math.floor(Math.random() * array.length)]
}

// ============================================================================
// Image Prompt Builders (사용자 제공 프롬프트 기반)
// ============================================================================

function buildMalePrompt(ageRange: string, idealType: string, mbti: string): string {
  const mbtiHint = mbti !== '상관없음' ? `, personality vibe matching ${mbti}` : ''

  return `A high-quality digital illustration of a charming young Korean man in his ${ageRange}.
He possesses a warm and inviting aura with a gentle, attractive smile, ideal for a "boyfriend material" look.
His facial features are naturally appealing and balanced, free from exaggerated fantasy elements,
reflecting a contemporary webtoon or drama character style.
${idealType ? `User's ideal type preference: ${idealType}.` : ''}
${mbtiHint}
He has clear, kind eyes. The lighting is soft and flattering, emphasizing a fresh and healthy complexion.
Wearing a stylish knit sweater or dandy shirt in neutral tones.
Pose: natural confident pose, slight head tilt or direct gaze.
Style: modern Korean drama aesthetic, soft natural lighting.
Quality: 4K, high fashion illustration, sharp focus, professional quality.
Aspect ratio: 1:1 (square portrait).
DO NOT include: text, logos, watermarks, blurry, distorted, cartoon, anime style.`
}

function buildFemalePrompt(ageRange: string, idealType: string, mbti: string): string {
  const mbtiHint = mbti !== '상관없음' ? `, personality vibe matching ${mbti}` : ''

  return `A high-quality digital illustration of a beautiful young Korean woman in her ${ageRange}.
She exudes a sophisticated yet approachable elegance, embodying a "girlfriend material" or "ideal best friend" aesthetic.
Her features are delicate and harmonious, with a radiant smile that feels genuine and engaging,
suitable for a modern webtoon or trendy character design.
${idealType ? `User's ideal type preference: ${idealType}.` : ''}
${mbtiHint}
Her eyes are bright and expressive. The illustration benefits from bright, natural lighting that highlights a clear, glowing skin tone.
Wearing a soft pastel blouse, simple knit, or elegant shirt.
Pose: elegant natural pose, warm inviting expression.
Style: modern Korean drama aesthetic, soft natural lighting.
Quality: 4K, high fashion illustration, sharp focus, professional quality.
Aspect ratio: 1:1 (square portrait).
DO NOT include: text, logos, watermarks, blurry, distorted, cartoon, anime style.`
}

// ============================================================================
// Text Generation (Gemini 2.0 Flash Lite - Direct API Call)
// ============================================================================

async function generateAppearanceHashtags(
  targetGender: string,
  idealType: string,
  mbti: string
): Promise<string[]> {
  console.log('📝 Generating appearance hashtags with Gemini 2.0 Flash Lite...')

  try {
    const systemPrompt = `You are a creative Korean content writer for a "2026 Destiny Finder" app.
Generate 3 trendy Korean hashtags describing a ${targetGender === 'male' ? 'charming man' : 'beautiful woman'}'s appearance.
The hashtags should be fun, trendy, and relate to Korean dating culture.

Examples:
- #무쌍_강아지상
- #셔츠가잘어울리는
- #너드미
- #따뜻한_아우라
- #생기있는_미소
- #도서관에서볼듯한
- #첫사랑_느낌

Output ONLY a JSON array of 3 hashtags, nothing else.
Example: ["#무쌍_강아지상", "#셔츠가잘어울리는", "#너드미"]`

    const userPrompt = `Generate 3 appearance hashtags for:
- Gender: ${targetGender === 'male' ? '남성' : '여성'}
- Ideal type description: ${idealType || '특별한 선호 없음'}
- MBTI preference: ${mbti}`

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          contents: [{
            role: 'user',
            parts: [{ text: `${systemPrompt}\n\n${userPrompt}` }],
          }],
          generationConfig: {
            temperature: 0.9,
            maxOutputTokens: 200,
          },
        }),
      }
    )

    if (!response.ok) {
      throw new Error(`Gemini API error: ${response.status}`)
    }

    const data = await response.json()
    const content = data.candidates?.[0]?.content?.parts?.[0]?.text || ''

    // Parse JSON array from response
    const match = content.match(/\[.*\]/s)
    if (match) {
      return JSON.parse(match[0])
    }

    // Fallback
    return ['#따뜻한_미소', '#눈빛이_다정한', '#설렘유발자']
  } catch (error) {
    console.error('❌ Hashtag generation error:', error)
    return ['#따뜻한_미소', '#눈빛이_다정한', '#설렘유발자']
  }
}

// ============================================================================
// Gemini Image Generation (gemini-2.5-flash-image - Direct API Call)
// ============================================================================

async function generateImageWithGemini(prompt: string): Promise<string> {
  console.log('🎨 Generating encounter image with Gemini 2.5 Flash Image...')
  const startTime = Date.now()

  const imageModel = 'gemini-2.5-flash-image'

  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${imageModel}:generateContent?key=${GEMINI_API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=utf-8' },
      body: JSON.stringify({
        contents: [{
          role: 'user',
          parts: [{ text: prompt }],
        }],
        generationConfig: {
          responseModalities: ['TEXT', 'IMAGE'],
        },
      }),
    }
  )

  if (!response.ok) {
    const errorText = await response.text()
    throw new Error(`Gemini Image API error: ${response.status} - ${errorText}`)
  }

  const data = await response.json()

  if (!data.candidates || data.candidates.length === 0) {
    throw new Error('No candidates in Gemini Image response')
  }

  // 이미지 데이터 추출
  const parts = data.candidates[0].content?.parts || []
  const imagePart = parts.find((p: { inlineData?: { mimeType?: string } }) =>
    p.inlineData?.mimeType?.startsWith('image/')
  )

  if (!imagePart || !imagePart.inlineData) {
    throw new Error('No image data in Gemini response')
  }

  const latency = Date.now() - startTime
  console.log(`✅ Image generated successfully in ${latency}ms`)

  return imagePart.inlineData.data
}

// ============================================================================
// Supabase Storage Upload
// ============================================================================

async function uploadToSupabase(
  imageBase64: string,
  userId: string
): Promise<string> {
  console.log('📤 Uploading to Supabase Storage...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  // Convert base64 to blob
  const imageBuffer = Uint8Array.from(atob(imageBase64), (c) => c.charCodeAt(0))
  const fileName = `${userId}/yearly_encounter_${Date.now()}.png`

  const { error } = await supabase.storage
    .from('yearly-encounter-images')
    .upload(fileName, imageBuffer, {
      contentType: 'image/png',
      upsert: false,
    })

  if (error) {
    console.error('❌ Upload error:', error)
    throw new Error(`Upload failed: ${error.message}`)
  }

  const { data: publicUrlData } = supabase.storage
    .from('yearly-encounter-images')
    .getPublicUrl(fileName)

  console.log('✅ Upload successful:', publicUrlData.publicUrl)
  return publicUrlData.publicUrl
}

// ============================================================================
// Database Record
// ============================================================================

async function saveYearlyEncounterRecord(
  userId: string,
  result: YearlyEncounterResponse['data']
): Promise<string> {
  console.log('💾 Saving yearly encounter record...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  const { data, error } = await supabase
    .from('fortunes')
    .insert({
      user_id: userId,
      fortune_data: {
        fortune_type: 'yearlyEncounter',
        ...result,
      },
      created_at: new Date().toISOString(),
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

// ============================================================================
// Main Handler
// ============================================================================

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: CORS_HEADERS })
  }

  try {
    const request: YearlyEncounterRequest = await req.json()
    console.log('📥 Yearly Encounter request:', {
      userId: request.userId,
      targetGender: request.targetGender,
      userAge: request.userAge,
      idealMbti: request.idealMbti,
    })

    const isPremium = request.isPremium ?? false

    // 1. Build image prompt based on target gender
    const ageRange = getAgeRange(request.userAge)
    const imagePrompt = request.targetGender === 'male'
      ? buildMalePrompt(ageRange, request.idealType, request.idealMbti)
      : buildFemalePrompt(ageRange, request.idealType, request.idealMbti)

    console.log('📝 Image prompt length:', imagePrompt.length)

    // 2. Generate image with Gemini 2.5 Flash
    const imageBase64 = await generateImageWithGemini(imagePrompt)

    // 3. Upload to Supabase Storage
    const imageUrl = await uploadToSupabase(imageBase64, request.userId)

    // 4. Generate appearance hashtags using LLM
    const appearanceHashtags = await generateAppearanceHashtags(
      request.targetGender,
      request.idealType,
      request.idealMbti
    )

    // 5. Pick random values from constants
    const encounterSpot = randomPick(ENCOUNTER_SPOTS).text
    const fateSignal = randomPick(FATE_SIGNALS).text
    const personality = randomPick(PERSONALITY_TRAITS).text
    const compatibility = randomPick(COMPATIBILITY_SCORES)

    // 6. Build result
    const resultData: YearlyEncounterResponse['data'] = {
      imageUrl,
      appearanceHashtags,
      encounterSpot,
      fateSignal,
      personality,
      compatibilityScore: compatibility.score,
      compatibilityDescription: compatibility.description,
      targetGender: request.targetGender,
      createdAt: new Date().toISOString(),
    }

    // 7. Save to database
    await saveYearlyEncounterRecord(request.userId, resultData)

    // 8. Determine blur sections (non-premium users see blurred results)
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['encounterSpot', 'fateSignal', 'personality', 'compatibilityDescription']
      : []

    const response: YearlyEncounterResponse = {
      success: true,
      data: resultData,
      isBlurred,
      blurredSections,
    }

    return new Response(JSON.stringify(response), {
      headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    console.error('❌ Error:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error',
        isBlurred: true,
        blurredSections: [],
      }),
      {
        status: 500,
        headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
      }
    )
  }
})
