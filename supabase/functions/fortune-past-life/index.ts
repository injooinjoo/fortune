/**
 * 전생 운세 (Past Life Fortune) Edge Function
 *
 * @description 사용자의 전생 신분, 스토리, AI 초상화를 생성합니다.
 * 국립중앙박물관 자화상 스타일의 이미지를 Gemini로 생성합니다.
 *
 * @endpoint POST /fortune-past-life
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name: string - 사용자 이름
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 생시 (선택)
 * - gender: string - 현재 성별 (전생 성별과 다를 수 있음)
 * - isPremium?: boolean - 프리미엄 여부
 *
 * @response PastLifeFortuneResponse
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { GeminiProvider } from '../_shared/llm/providers/gemini.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

const GEMINI_API_KEY = Deno.env.get('GEMINI_API_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 신분 설정
interface StatusConfig {
  kr: string
  en: string
  desc: string
  clothing: string
  accessories: string
}

const STATUS_CONFIGS: Record<string, StatusConfig> = {
  king: {
    kr: '왕',
    en: 'King',
    desc: 'a royal Korean king',
    clothing: 'ceremonial dragon robes (곤룡포) with gold dragon embroidery, royal crown (익선관)',
    accessories: 'jade belt, royal seal, ceremonial fan',
  },
  queen: {
    kr: '왕비',
    en: 'Queen',
    desc: 'a Korean queen',
    clothing: 'royal court attire (적의) with phoenix patterns, elaborate headdress (적관)',
    accessories: 'jade ornaments, royal jewelry, ceremonial fan',
  },
  gisaeng: {
    kr: '기생',
    en: 'Gisaeng',
    desc: 'a talented gisaeng entertainer',
    clothing: 'elegant colorful hanbok with flowing sleeves, elaborate hairstyle with ornaments',
    accessories: 'gayageum strings, flower hairpins, jade earrings',
  },
  scholar: {
    kr: '선비',
    en: 'Scholar',
    desc: 'a Confucian scholar',
    clothing: 'scholarly robes (도포) in muted colors, traditional gat hat (갓)',
    accessories: 'calligraphy brush, books, jade pendant',
  },
  warrior: {
    kr: '장군',
    en: 'General',
    desc: 'a military general',
    clothing: 'traditional armor (갑옷) with helmet (투구), military robes',
    accessories: 'sword, bow, military insignia, commander flag',
  },
  farmer: {
    kr: '농부',
    en: 'Farmer',
    desc: 'a dignified farmer',
    clothing: 'simple but clean hanbok in earth tones, straw hat (삿갓)',
    accessories: 'farming tools, grain basket, simple pipe',
  },
  merchant: {
    kr: '상인',
    en: 'Merchant',
    desc: 'a wealthy merchant',
    clothing: 'fine silk hanbok with subtle patterns, merchant hat',
    accessories: 'abacus, money pouch, trading goods',
  },
  noble: {
    kr: '양반',
    en: 'Noble',
    desc: 'a yangban aristocrat',
    clothing: 'formal hanbok with ceremonial hat (사모), jade decorations',
    accessories: 'folding fan, jade belt ornament, scholarly items',
  },
  monk: {
    kr: '승려',
    en: 'Buddhist Monk',
    desc: 'a Buddhist monk',
    clothing: 'gray monk robes (승복), prayer beads, shaved head',
    accessories: 'Buddhist prayer beads (염주), sutra, wooden fish drum',
  },
  artisan: {
    kr: '장인',
    en: 'Master Artisan',
    desc: 'a master craftsman',
    clothing: 'practical working hanbok, craftsman apron',
    accessories: 'craft tools, finished artwork, materials of trade',
  },
  shaman: {
    kr: '무당',
    en: 'Shaman',
    desc: 'a spiritual shaman',
    clothing: 'colorful ceremonial dress (무복) with flowing ribbons, spirit crown',
    accessories: 'spirit bells, ritual knife, shamanic fan',
  },
  servant: {
    kr: '하인',
    en: 'Servant',
    desc: 'a loyal household servant',
    clothing: 'simple modest hanbok in muted colors',
    accessories: 'serving tray, household items',
  },
}

// 조선시대 시대 구분
const ERAS = ['조선 초기 (15세기)', '조선 중기 (16-17세기)', '조선 후기 (18-19세기)']

// 전생 이름 생성용 성씨와 이름
const SURNAMES = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임', '한', '신', '권', '황', '안']
const MALE_NAMES = ['학문', '도윤', '성현', '태호', '재민', '건우', '정민', '승호', '현우', '진석', '명수', '철수', '영호', '기현', '동혁']
const FEMALE_NAMES = ['설희', '채원', '민지', '수아', '은지', '소연', '하나', '지은', '영숙', '순희', '옥분', '춘화', '미연', '정아', '혜진']

function generateName(gender: string): string {
  const surname = SURNAMES[Math.floor(Math.random() * SURNAMES.length)]
  const names = gender === 'male' ? MALE_NAMES : FEMALE_NAMES
  const name = names[Math.floor(Math.random() * names.length)]
  return `${surname}${name}`
}

function selectRandomStatus(): string {
  const statuses = Object.keys(STATUS_CONFIGS)
  // 희소성 가중치 적용 (왕/왕비는 드물게)
  const weights: Record<string, number> = {
    king: 1, queen: 1, gisaeng: 8, scholar: 15, warrior: 8,
    farmer: 20, merchant: 12, noble: 10, monk: 5, artisan: 10,
    shaman: 5, servant: 5,
  }
  const totalWeight = Object.values(weights).reduce((a, b) => a + b, 0)
  let random = Math.random() * totalWeight

  for (const [status, weight] of Object.entries(weights)) {
    random -= weight
    if (random <= 0) return status
  }
  return 'farmer'
}

function selectRandomGender(): string {
  return Math.random() > 0.5 ? 'male' : 'female'
}

function selectRandomEra(): string {
  return ERAS[Math.floor(Math.random() * ERAS.length)]
}

/**
 * 국립중앙박물관 자화상 스타일 초상화 프롬프트 생성
 */
function buildPortraitPrompt(status: string, gender: string, era: string): string {
  const config = STATUS_CONFIGS[status]
  const genderKo = gender === 'male' ? '남성' : '여성'

  return `A traditional Korean Joseon dynasty portrait in the authentic style of
the National Museum of Korea (국립중앙박물관) self-portrait collection (자화상).

Subject: ${config.desc}, ${genderKo}
Era: ${era} period aesthetic

Attire and Appearance:
- ${config.clothing}
- ${config.accessories}
- Period-appropriate hairstyle and grooming
- Dignified, composed expression typical of Joseon portraits

Portrait Style Requirements:
- Traditional Korean portrait painting technique (초상화법)
- Ink and natural pigments on silk or paper appearance
- Formal frontal or subtle 3/4 pose, as seen in Korean ancestral portraits
- Subject seated or standing in dignified posture
- Muted, aged color palette with subtle earth tones, ochre, and natural pigments
- Visible brushstroke texture characteristic of traditional Korean painting
- Accurate period-appropriate facial features and bone structure
- Meticulous attention to clothing folds and fabric texture
- Simple, minimal background (plain warm-toned backdrop or subtle atmospheric effect)
- Soft, diffused lighting as seen in traditional Korean portraits
- Portrait orientation (3:4 aspect ratio)
- Museum-quality rendering with aged patina effect

Artistic References:
- Study the style of 윤두서 (Yun Duseo) self-portraits
- Reference 강세황 (Kang Sehwang) portrait techniques
- Emulate the dignified quality of Joseon royal portraits
- Incorporate the subtle realism of Korean ancestor portraits (조상화)

DO NOT include:
- Modern elements or clothing
- Anime or cartoon style
- Bright saturated colors
- Western painting techniques
- Fantasy elements
- Text or watermarks
- Digital or photorealistic rendering`
}

/**
 * Gemini로 초상화 이미지 생성
 */
async function generatePortraitImage(prompt: string): Promise<string> {
  console.log('🎨 [PastLife] Generating portrait with Gemini...')
  const startTime = Date.now()

  const provider = new GeminiProvider({
    apiKey: GEMINI_API_KEY,
    model: 'gemini-2.0-flash-exp',
  })

  const result = await provider.generateImage!(prompt)

  console.log(`✅ [PastLife] Portrait generated in ${Date.now() - startTime}ms`)
  return result.imageBase64
}

/**
 * Supabase Storage에 이미지 업로드
 */
async function uploadPortraitToStorage(
  imageBase64: string,
  userId: string
): Promise<string> {
  console.log('📤 [PastLife] Uploading portrait to storage...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  // Base64를 Blob으로 변환
  const imageBuffer = Uint8Array.from(atob(imageBase64), (c) => c.charCodeAt(0))
  const fileName = `${userId}/past_life_${Date.now()}.png`

  const { data, error } = await supabase.storage
    .from('past-life-portraits')
    .upload(fileName, imageBuffer, {
      contentType: 'image/png',
      upsert: false,
    })

  if (error) {
    console.error('❌ [PastLife] Upload error:', error)
    throw new Error(`Upload failed: ${error.message}`)
  }

  const { data: publicUrlData } = supabase.storage
    .from('past-life-portraits')
    .getPublicUrl(fileName)

  console.log('✅ [PastLife] Portrait uploaded:', publicUrlData.publicUrl)
  return publicUrlData.publicUrl
}

/**
 * LLM으로 전생 스토리 생성
 */
async function generatePastLifeStory(
  status: string,
  statusKr: string,
  gender: string,
  era: string,
  name: string,
  userName: string,
  userBirthDate: string
): Promise<{ story: string; summary: string; advice: string; score: number }> {
  console.log('📝 [PastLife] Generating story with LLM...')

  const llm = LLMFactory.createFromConfig('fortune-past-life')

  const genderKo = gender === 'male' ? '남성' : '여성'

  const prompt = `당신은 전생 운세 전문가입니다. 사용자의 전생 이야기를 생성해주세요.

## 사용자 정보
- 이름: ${userName}
- 생년월일: ${userBirthDate}

## 전생 정보
- 신분: ${statusKr} (${status})
- 성별: ${genderKo}
- 시대: ${era}
- 전생 이름: ${name}

## 작성 지침
1. **story**: 300-500자의 스토리텔링 형식으로 작성
   - 전생에서의 삶, 중요한 사건, 성격, 업적 등을 포함
   - 해당 시대와 신분에 맞는 역사적 디테일 포함
   - 감동적이고 몰입감 있는 이야기로 구성
   - "당신의 전생은..." 으로 시작

2. **summary**: 1-2문장의 핵심 요약

3. **advice**: 150-250자로 현생과의 연결점, 교훈 작성
   - 전생의 특성이 현생에 어떻게 영향을 미치는지
   - 현생에서 활용할 수 있는 조언

4. **score**: 1-100 사이의 전생 운세 점수
   - 신분에 따라 기본 점수 차등 (왕/왕비: 90-100, 양반/선비: 75-90, 일반: 60-80)

## JSON 응답 형식
{
  "story": "당신의 전생은...",
  "summary": "요약 문장",
  "advice": "현생과의 연결점...",
  "score": 85
}`

  const response = await llm.chat([
    { role: 'system', content: '전생 운세 전문가로서 JSON 형식으로 응답합니다.' },
    { role: 'user', content: prompt },
  ])

  // JSON 파싱
  const content = response.content
  const jsonMatch = content.match(/\{[\s\S]*\}/)
  if (!jsonMatch) {
    throw new Error('Failed to parse LLM response as JSON')
  }

  const parsed = JSON.parse(jsonMatch[0])
  return {
    story: parsed.story || '',
    summary: parsed.summary || '',
    advice: parsed.advice || '',
    score: parsed.score || 75,
  }
}

/**
 * 결과를 DB에 저장
 */
async function savePastLifeResult(
  userId: string,
  status: string,
  statusEn: string,
  gender: string,
  era: string,
  name: string,
  story: string,
  summary: string,
  portraitUrl: string,
  portraitPrompt: string,
  advice: string,
  score: number
): Promise<string> {
  console.log('💾 [PastLife] Saving result to database...')

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

  const { data, error } = await supabase
    .from('past_life_results')
    .insert({
      user_id: userId,
      past_life_status: status,
      past_life_status_en: statusEn,
      past_life_gender: gender,
      past_life_era: era,
      past_life_name: name,
      story_text: story,
      story_summary: summary,
      portrait_url: portraitUrl,
      portrait_prompt: portraitPrompt,
      advice: advice,
      score: score,
    })
    .select('id')
    .single()

  if (error) {
    console.error('❌ [PastLife] Database insert error:', error)
    throw new Error(`Database insert failed: ${error.message}`)
  }

  console.log('✅ [PastLife] Result saved, id:', data.id)
  return data.id
}

/**
 * 블러 처리 적용
 */
function applyBlurring(fortune: any, isPremium: boolean): any {
  if (isPremium) {
    return { ...fortune, isBlurred: false, blurredSections: [] }
  }

  return {
    ...fortune,
    isBlurred: true,
    blurredSections: ['story', 'advice', 'portrait'],
  }
}

serve(async (req) => {
  // CORS 처리
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const startTime = Date.now()

  try {
    const requestData = await req.json()
    const {
      userId,
      name: userName = '사용자',
      birthDate: userBirthDate,
      birthTime,
      gender: userGender,
      isPremium = false,
    } = requestData

    console.log('🔮 [PastLife] 전생 운세 요청 시작')
    console.log(`   - 사용자: ${userName}`)
    console.log(`   - 생년월일: ${userBirthDate}`)
    console.log(`   - Premium: ${isPremium}`)

    // 필수 필드 검증
    if (!userId || !userBirthDate) {
      return new Response(
        JSON.stringify({ error: 'Missing required fields: userId, birthDate' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 전생 정보 랜덤 생성
    const pastLifeStatus = selectRandomStatus()
    const pastLifeGender = selectRandomGender()  // 현재 성별과 무관하게 랜덤
    const pastLifeEra = selectRandomEra()
    const pastLifeName = generateName(pastLifeGender)
    const statusConfig = STATUS_CONFIGS[pastLifeStatus]

    console.log(`   - 전생 신분: ${statusConfig.kr} (${pastLifeStatus})`)
    console.log(`   - 전생 성별: ${pastLifeGender}`)
    console.log(`   - 전생 시대: ${pastLifeEra}`)
    console.log(`   - 전생 이름: ${pastLifeName}`)

    // 1. 초상화 프롬프트 생성 및 이미지 생성
    const portraitPrompt = buildPortraitPrompt(pastLifeStatus, pastLifeGender, pastLifeEra)
    const imageBase64 = await generatePortraitImage(portraitPrompt)

    // 2. Storage에 업로드
    const portraitUrl = await uploadPortraitToStorage(imageBase64, userId)

    // 3. LLM으로 스토리 생성
    const { story, summary, advice, score } = await generatePastLifeStory(
      pastLifeStatus,
      statusConfig.kr,
      pastLifeGender,
      pastLifeEra,
      pastLifeName,
      userName,
      userBirthDate
    )

    // 4. DB에 저장
    const recordId = await savePastLifeResult(
      userId,
      statusConfig.kr,
      statusConfig.en,
      pastLifeGender,
      pastLifeEra,
      pastLifeName,
      story,
      summary,
      portraitUrl,
      portraitPrompt,
      advice,
      score
    )

    // 5. 응답 구성
    const fortune = {
      id: recordId,
      fortuneType: 'past-life',
      pastLifeStatus: statusConfig.kr,
      pastLifeStatusEn: statusConfig.en,
      pastLifeGender: pastLifeGender,
      pastLifeEra: pastLifeEra,
      pastLifeName: pastLifeName,
      story: story,
      summary: summary,
      portraitUrl: portraitUrl,
      advice: advice,
      score: score,
      timestamp: new Date().toISOString(),
    }

    // 블러 처리
    const processedFortune = applyBlurring(fortune, isPremium)

    // 사용량 로깅
    await UsageLogger.log({
      userId,
      functionName: 'fortune-past-life',
      tokensUsed: 0,  // 이미지 생성은 별도 과금
      latencyMs: Date.now() - startTime,
      success: true,
    })

    console.log(`🎉 [PastLife] 완료! 총 소요시간: ${Date.now() - startTime}ms`)

    return new Response(
      JSON.stringify({ fortune: processedFortune }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
      }
    )
  } catch (error) {
    console.error('❌ [PastLife] Error:', error)

    await UsageLogger.log({
      userId: 'unknown',
      functionName: 'fortune-past-life',
      tokensUsed: 0,
      latencyMs: Date.now() - startTime,
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
    })

    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : 'Unknown error',
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
