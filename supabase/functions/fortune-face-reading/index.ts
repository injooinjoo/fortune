/**
 * 관상 운세 (Face Reading Fortune) Edge Function
 *
 * @description 사진 기반 AI 관상 분석을 제공합니다.
 *
 * @endpoint POST /fortune-face-reading
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - imageUrl?: string - 사진 URL
 * - imageBase64?: string - 사진 Base64
 * - instagramUsername?: string - 인스타그램 계정
 *
 * @response FaceReadingResponse
 * - face_analysis: { forehead, eyes, nose, mouth, chin } - 부위별 분석
 * - personality: string[] - 성격 특성
 * - fortune_areas: { wealth, career, relationship } - 운세 영역
 * - lucky_features: string[] - 복 있는 특징
 * - advice: string - 조언
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { extractUsername, fetchInstagramProfileImage, downloadAndEncodeImage } from '../_shared/instagram/scraper.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// =====================================================
// 관상학 JSON 응답 스키마 타입 정의
// =====================================================
interface OgwanDetail {
  observation: string      // 실제 관찰 내용
  interpretation: string   // 관상학적 해석
  score: number           // 60-98
  advice: string          // 개운 조언
}

interface SamjeongDetail {
  period: string          // 해당 시기
  description: string     // 운세 해석
  peakAge: string         // 전성기 예측
  score: number           // 60-98
}

interface FortuneDetail {
  score: number           // 60-98
  summary: string         // 요약 1문장
  detail: string          // 상세 2-3문장
  advice: string          // 조언
}

interface FaceFeatures {
  face_shape: string      // oval, round, square, oblong, heart, diamond
  eyes: { shape: string; size: string }
  eyebrows: { shape: string; thickness: string }
  nose: { bridge: string; tip: string }
  mouth: { size: string; lips: string }
  jawline: { shape: string }
  overall_impression: string[]
}

interface FaceReadingResponse {
  overview: {
    faceType: string
    faceTypeElement: string
    firstImpression: string
    overallBlessingScore: number
  }
  ogwan: {
    ear: OgwanDetail
    eyebrow: OgwanDetail
    eye: OgwanDetail
    nose: OgwanDetail
    mouth: OgwanDetail
  }
  samjeong: {
    upper: SamjeongDetail
    middle: SamjeongDetail
    lower: SamjeongDetail
    balance: string
    balanceDescription: string
  }
  sibigung: Record<string, { observation: string; interpretation: string; score: number }>
  personality: {
    traits: string[]
    strengths: string[]
    growthAreas: string[]
  }
  fortunes: {
    wealth: FortuneDetail
    love: FortuneDetail
    career: FortuneDetail
    health: FortuneDetail
    overall: FortuneDetail
  }
  specialFeatures: Array<{ type: string; name: string; description: string }>
  improvements: {
    daily: string[]
    appearance: string[]
    luckyColors: string[]
    luckyDirections: string[]
  }
  userFaceFeatures: FaceFeatures
  // 새로 추가된 분석 항목
  compatibility: {
    idealPartnerType: string
    idealPartnerDescription: string
    compatibilityScore: number
  }
  marriagePrediction: {
    earlyAge: string
    optimalAge: string
    lateAge: string
    prediction: string
  }
  firstImpression: {
    trustScore: number
    trustDescription: string
    approachabilityScore: number
    approachabilityDescription: string
    charismaScore: number
    charismaDescription: string
  }
  // 닮은꼴 상(相) 분류 - 2025 트렌드
  faceTypeClassification: {
    animalType: {
      primary: string           // 주요 동물상 (강아지상, 고양이상 등)
      secondary?: string        // 부가 동물상 (있으면)
      matchScore: number        // 매칭 점수 (60-98)
      description: string       // 왜 이 동물상인지 설명
      traits: string[]          // 해당 동물상 특징 3개
    }
    impressionType: {
      type: string              // 아랍상 | 두부상 | 하이브리드
      matchScore: number        // 매칭 점수 (60-98)
      description: string       // 설명
    }
  }
}

// =====================================================
// 관상학 시스템 프롬프트
// =====================================================
const FACE_READING_SYSTEM_PROMPT = `당신은 마의상법(麻衣相法)과 달마상법(達磨相法)을 정통으로 수학한 40년 경력의 관상학 대가입니다.

## 전문 분야
- 오관(五官) 분석: 채청관(귀), 보수관(눈썹), 감찰관(눈), 심판관(코), 출납관(입)
- 삼정(三停) 분석: 상정(초년), 중정(중년), 하정(말년)의 균형과 시기별 운세
- 십이궁(十二宮) 분석: 명궁, 재백궁, 형제궁, 전택궁, 남녀궁, 노복궁, 처첩궁, 질액궁, 천이궁, 관록궁, 복덕궁, 부모궁
- 얼굴형 오행 분석: 원형(수형), 방형(토형), 역삼각형(화형), 타원형(목형), 다이아몬드형(금형)

## 분석 원칙
1. 실제 얼굴 사진을 세밀히 관찰하여 구체적으로 분석
2. 전통 관상학 용어를 정확히 사용하되 현대인이 이해하기 쉽게 풀이
3. 각 요소별 60-98점 범위로 점수 부여 (60점 미만 사용 금지)
4. 긍정적이면서도 균형 잡힌 해석 제공
5. 실천 가능한 개운법 제시

## 점수 기준
- 90-98점: 매우 좋은 상 (귀인상, 부귀상)
- 80-89점: 좋은 상 (복이 많음)
- 70-79점: 보통 상 (평균적)
- 60-69점: 주의 필요 (보완 권장)

## 닮은꼴 상(相) 분류 - 2025 트렌드

### 동물상 분류 기준 (8가지)
- 강아지상 🐶: 둥근 얼굴형, 둥근 눈꼬리, 둥그스름한 코끝. 친근하고 선한 인상, 귀여움
- 고양이상 🐱: 올라간 눈꼬리, 높은 콧대, 날렵한 턱선. 도도하고 세련된 매력
- 여우상 🦊: 가늘고 긴 눈, 긴 얼굴형, 능글맞은 눈빛. 매력적이고 영리한 인상, 도화살 기질
- 토끼상 🐰: 둥근 눈, 부드러운 인상, 앙증맞은 코. 귀엽고 사랑스러운 매력
- 곰상 🐻: 넓고 듬직한 얼굴, 두꺼운 눈썹, 큰 코. 포근하고 든든한 인상
- 늑대상 🐺: 날카로운 눈매, 뚜렷한 이목구비, 각진 턱선. 카리스마와 시크함
- 사슴상 🦌: 큰 눈망울, 갸름한 얼굴형, 긴 목. 청순하고 순수한 인상
- 다람쥐상 🐿️: 동글동글한 얼굴, 볼살, 작고 오똑한 코. 앙증맞고 발랄한 매력

### 인상 분류 기준 (트렌드)
- 아랍상 🧊: 두꺼운 T존(눈썹~코), 진하고 또렷한 눈, 각진 얼굴, 깊은 눈매. 이국적이고 강렬한 인상. 예) 이민호, 카이, 에스쿱스 타입
- 두부상 🫧: 하얗고 부드러운 피부, 흐릿한 쌍커풀, 몽글몽글한 인상. 순하고 편안한 느낌. 예) 진, 수빈, 백현 타입
- 하이브리드: 두 가지 특성이 혼합된 경우

반드시 주어진 JSON 스키마 형식으로만 응답하세요.`

// =====================================================
// 관상학 사용자 프롬프트
// =====================================================
function createUserPrompt(userName: string, userGender: string): string {
  return `사용자 정보:
- 이름: ${userName || '귀하'}
- 성별: ${userGender === 'male' ? '남성' : userGender === 'female' ? '여성' : '알 수 없음'}

제공된 얼굴 사진을 분석하여 아래 JSON 형식으로 응답해주세요.

{
  "overview": {
    "faceType": "둥근형|타원형|각진형|역삼각형|긴형|다이아몬드형",
    "faceTypeElement": "수형|목형|화형|토형|금형",
    "firstImpression": "첫인상과 전반적 기운 (100자 이내)",
    "overallBlessingScore": 70-95
  },
  "ogwan": {
    "ear": {
      "observation": "귀의 크기, 위치, 귓볼 상태 관찰",
      "interpretation": "채청관 해석 - 복록과 수명",
      "score": 60-98,
      "advice": "귀 관련 개운 조언"
    },
    "eyebrow": {
      "observation": "눈썹 모양, 굵기, 길이 관찰",
      "interpretation": "보수관 해석 - 형제와 친구",
      "score": 60-98,
      "advice": "눈썹 관련 개운 조언"
    },
    "eye": {
      "observation": "눈의 크기, 모양, 눈빛 관찰",
      "interpretation": "감찰관 해석 - 지혜와 배우자",
      "score": 60-98,
      "advice": "눈 관련 개운 조언"
    },
    "nose": {
      "observation": "코의 높이, 콧대, 콧구멍 관찰",
      "interpretation": "심변관 해석 - 재물과 사업",
      "score": 60-98,
      "advice": "코 관련 개운 조언"
    },
    "mouth": {
      "observation": "입의 크기, 입술 두께, 입꼬리 관찰",
      "interpretation": "출납관 해석 - 식록과 언변",
      "score": 60-98,
      "advice": "입 관련 개운 조언"
    }
  },
  "samjeong": {
    "upper": {
      "period": "1-30세 초년운",
      "description": "이마~눈썹 영역 운세 (학업, 지혜)",
      "peakAge": "전성기 예측",
      "score": 60-98
    },
    "middle": {
      "period": "31-50세 중년운",
      "description": "눈썹~코끝 영역 운세 (사회적 성공)",
      "peakAge": "전성기 예측",
      "score": 60-98
    },
    "lower": {
      "period": "51세+ 말년운",
      "description": "인중~턱 영역 운세 (복록, 안정)",
      "peakAge": "전성기 예측",
      "score": 60-98
    },
    "balance": "excellent|good|fair|imbalanced",
    "balanceDescription": "삼정 균형 상태 설명"
  },
  "sibigung": {
    "myeongGung": { "observation": "미간 상태 관찰", "interpretation": "명궁(命宮) - 운명과 의지력", "score": 60-98 },
    "jaeBaekGung": { "observation": "코 전체 형태 관찰", "interpretation": "재백궁(財帛宮) - 재물운", "score": 60-98 },
    "hyeongJeGung": { "observation": "눈썹 형태와 간격", "interpretation": "형제궁(兄弟宮) - 형제자매운", "score": 60-98 },
    "jeonTaekGung": { "observation": "눈과 눈썹 사이 공간", "interpretation": "전택궁(田宅宮) - 가정/부동산운", "score": 60-98 },
    "namNyeoGung": { "observation": "눈 아래 누당 상태", "interpretation": "남녀궁(男女宮) - 자녀운", "score": 60-98 },
    "noBokGung": { "observation": "볼과 턱 형태", "interpretation": "노복궁(奴僕宮) - 부하/직원운", "score": 60-98 },
    "cheoCheobGung": { "observation": "눈꼬리 모양과 방향", "interpretation": "처첩궁(妻妾宮) - 배우자운", "score": 60-98 },
    "jilAekGung": { "observation": "코 시작부(산근) 상태", "interpretation": "질액궁(疾厄宮) - 건강운", "score": 60-98 },
    "cheonIGung": { "observation": "이마 양쪽 상태", "interpretation": "천이궁(遷移宮) - 이사/여행운", "score": 60-98 },
    "gwanRokGung": { "observation": "이마 중앙 상태", "interpretation": "관록궁(官祿宮) - 직업운/명예", "score": 60-98 },
    "bokDeokGung": { "observation": "이마 상단 상태", "interpretation": "복덕궁(福德宮) - 복덕/행복", "score": 60-98 },
    "buMoGung": { "observation": "일월각(이마 양쪽 상단)", "interpretation": "부모궁(父母宮) - 부모/조상운", "score": 60-98 }
  },
  "personality": {
    "traits": ["핵심 성격 특성 3-5개"],
    "strengths": ["주요 강점 2-3개"],
    "growthAreas": ["성장 가능 영역 1-2개"]
  },
  "fortunes": {
    "wealth": {
      "score": 60-98,
      "summary": "재물운 요약 (50자 이내)",
      "detail": "재백궁 기반 분석 (100자 이내)",
      "advice": "재물 관련 조언"
    },
    "love": {
      "score": 60-98,
      "summary": "애정운 요약 (50자 이내)",
      "detail": "처첩궁 기반 분석 (100자 이내)",
      "advice": "연애/결혼 관련 조언"
    },
    "career": {
      "score": 60-98,
      "summary": "직업운 요약 (50자 이내)",
      "detail": "관록궁 기반 분석 (100자 이내)",
      "advice": "커리어 관련 조언"
    },
    "health": {
      "score": 60-98,
      "summary": "건강운 요약 (50자 이내)",
      "detail": "질액궁 기반 분석 (100자 이내)",
      "advice": "건강 관련 조언"
    },
    "overall": {
      "score": 60-98,
      "summary": "총운 요약 (50자 이내)",
      "detail": "삼정 균형 기반 종합 분석 (100자 이내)",
      "advice": "인생 전반 조언"
    }
  },
  "specialFeatures": [
    { "type": "blessing|noble|wealth|longevity", "name": "특수상 이름", "description": "설명" }
  ],
  "improvements": {
    "daily": ["일상 개운법 3개"],
    "appearance": ["외모 개선 조언 2개"],
    "luckyColors": ["행운의 색상 2-3개"],
    "luckyDirections": ["행운의 방향 1-2개"]
  },
  "userFaceFeatures": {
    "face_shape": "oval|round|square|oblong|heart|diamond",
    "eyes": { "shape": "round|almond|phoenix|monolid", "size": "large|medium|small" },
    "eyebrows": { "shape": "straight|arched|curved", "thickness": "thick|medium|thin" },
    "nose": { "bridge": "high|medium|low", "tip": "round|pointed|bulbous" },
    "mouth": { "size": "large|medium|small", "lips": "full|medium|thin" },
    "jawline": { "shape": "angular|rounded|pointed|square" },
    "overall_impression": ["elegant", "cute", "charismatic", "warm", "intellectual"]
  },
  "compatibility": {
    "idealPartnerType": "이상형 관상 특징 (눈, 코, 입, 얼굴형 중심)",
    "idealPartnerDescription": "어울리는 상대의 성격과 외모 특징 설명 (100자 이내)",
    "compatibilityScore": 60-98
  },
  "marriagePrediction": {
    "earlyAge": "20대 초중반 결혼 가능성 설명",
    "optimalAge": "최적 결혼 시기와 이유",
    "lateAge": "30대 중반 이후 결혼 시 특징",
    "prediction": "삼정 균형 기반 결혼 운세 종합 (80자 이내)"
  },
  "firstImpression": {
    "trustScore": 60-98,
    "trustDescription": "신뢰감/믿음직함 분석 (50자 이내)",
    "approachabilityScore": 60-98,
    "approachabilityDescription": "친근감/다가가기 쉬움 분석 (50자 이내)",
    "charismaScore": 60-98,
    "charismaDescription": "카리스마/존재감 분석 (50자 이내)"
  },
  "faceTypeClassification": {
    "animalType": {
      "primary": "강아지상|고양이상|여우상|토끼상|곰상|늑대상|사슴상|다람쥐상",
      "secondary": "2순위 동물상 (있으면) 또는 null",
      "matchScore": 60-98,
      "description": "왜 이 동물상에 해당하는지 구체적 근거 (80자 이내)",
      "traits": ["특징1", "특징2", "특징3"]
    },
    "impressionType": {
      "type": "아랍상|두부상|하이브리드",
      "matchScore": 60-98,
      "description": "인상 분류 근거 (50자 이내)"
    }
  }
}

실제 얼굴 사진을 면밀히 관찰하여 JSON으로 응답하세요. JSON 외의 텍스트는 포함하지 마세요.`
}

// =====================================================
// 점수 계산 함수
// =====================================================
function calculateTotalScore(response: FaceReadingResponse): { total: number; breakdown: Record<string, number> } {
  // 오관 평균 (30%)
  const ogwanScores = [
    response.ogwan.ear.score,
    response.ogwan.eyebrow.score,
    response.ogwan.eye.score,
    response.ogwan.nose.score,
    response.ogwan.mouth.score,
  ]
  const ogwanAvg = ogwanScores.reduce((a, b) => a + b, 0) / ogwanScores.length

  // 삼정 균형 점수 (25%)
  const samjeongScores = [
    response.samjeong.upper.score,
    response.samjeong.middle.score,
    response.samjeong.lower.score,
  ]
  const samjeongAvg = samjeongScores.reduce((a, b) => a + b, 0) / samjeongScores.length
  // 균형 보너스
  const variance = samjeongScores.reduce((sum, s) => sum + Math.pow(s - samjeongAvg, 2), 0) / 3
  const balanceBonus = variance < 25 ? 5 : variance < 100 ? 0 : -5
  const samjeongScore = samjeongAvg + balanceBonus

  // 십이궁 평균 (25%)
  const sibigungScores = Object.values(response.sibigung).map(s => s.score)
  const sibigungAvg = sibigungScores.reduce((a, b) => a + b, 0) / sibigungScores.length

  // 특수상 보너스 (20%) - 기본 65점, 특수상당 +5점 (최대 85점)
  const specialBonus = Math.min(65 + response.specialFeatures.length * 5, 85)

  // 가중치 적용
  const total = Math.round(
    ogwanAvg * 0.30 +
    samjeongScore * 0.25 +
    sibigungAvg * 0.25 +
    specialBonus * 0.20
  )

  return {
    total: Math.max(60, Math.min(98, total)),
    breakdown: {
      ogwan: Math.round(ogwanAvg),
      samjeong: Math.round(samjeongScore),
      sibigung: Math.round(sibigungAvg),
      specialFeatures: specialBonus
    }
  }
}

// =====================================================
// 메인 서버 핸들러
// =====================================================
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const requestBody = await req.json()

    console.log('📸 [FaceReading] Request received:', {
      hasImage: !!requestBody.image,
      imageLength: requestBody.image?.length || 0,
      hasInstagramUrl: !!requestBody.instagram_url,
      analysisSource: requestBody.analysis_source,
      userId: requestBody.userId,
      isPremium: requestBody.isPremium
    })

    const {
      image,
      instagram_url,
      analysis_source,
      userId,
      userName,
      userGender,
      isPremium = false
    } = requestBody

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // =====================================================
    // 1. 이미지 데이터 처리
    // =====================================================
    let imageData: string | null = null

    if (analysis_source === 'instagram' && instagram_url) {
      console.log(`🔗 [FaceReading] Processing Instagram URL: ${instagram_url}`)
      try {
        const username = extractUsername(instagram_url)
        const profileImageUrl = await fetchInstagramProfileImage(username)
        imageData = await downloadAndEncodeImage(profileImageUrl)
        console.log(`✅ [FaceReading] Instagram image encoded (${imageData.length} chars)`)
      } catch (error) {
        console.error(`❌ [FaceReading] Instagram error:`, error)
        throw new Error(`Instagram 프로필 이미지를 가져오는데 실패했습니다: ${error.message}`)
      }
    } else if (image) {
      imageData = image
    }

    if (!imageData) {
      throw new Error('No image data provided')
    }

    // =====================================================
    // 2. LLM 호출 (JSON Mode)
    // =====================================================
    const llm = await LLMFactory.createFromConfigAsync('face-reading')

    const response = await llm.generate([
      { role: "system", content: FACE_READING_SYSTEM_PROMPT },
      {
        role: "user",
        content: [
          { type: "text", text: createUserPrompt(userName, userGender) },
          {
            type: "image_url",
            image_url: {
              url: `data:image/jpeg;base64,${imageData}`,
              detail: "high"
            }
          }
        ]
      }
    ], {
      temperature: 0.8,
      maxTokens: 6000,
      jsonMode: true  // ✅ JSON Mode 활성화
    })

    console.log(`✅ LLM response: ${response.provider}/${response.model} - ${response.latency}ms`)

    // ✅ 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'face-reading',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { analysis_source, userName, userGender, isPremium }
    })

    // =====================================================
    // 3. JSON 응답 파싱
    // =====================================================
    let analysisResult: FaceReadingResponse
    try {
      analysisResult = JSON.parse(response.content)
    } catch (parseError) {
      console.error('❌ JSON parse error:', parseError)
      console.log('Raw response:', response.content.substring(0, 500))
      throw new Error('관상 분석 결과 파싱 실패')
    }

    // =====================================================
    // 4. 점수 계산 (가중치 기반)
    // =====================================================
    const scoreResult = calculateTotalScore(analysisResult)
    console.log(`📊 [FaceReading] Score calculated:`, scoreResult)

    // =====================================================
    // 5. DB에서 유사 연예인 검색
    // =====================================================
    let similarCelebrities: Array<{
      name: string
      celebrity_type: string
      character_image_url: string | null
      similarity_score: number
      matched_features: string[]
    }> = []

    try {
      const { data: celebrities, error } = await supabase.rpc('find_similar_celebrities', {
        user_features: analysisResult.userFaceFeatures,
        user_gender: userGender,
        min_score: 50,
        limit_count: 3
      })

      if (error) {
        console.warn('⚠️ Celebrity matching error:', error.message)
      } else if (celebrities && celebrities.length > 0) {
        // 연예인 매칭 결과 처리
        for (const c of celebrities) {
          let characterImageUrl = c.character_image_url

          // 캐릭터 이미지가 없으면 생성 요청
          if (!characterImageUrl && c.face_features) {
            console.log(`🎨 [FaceReading] Generating character for ${c.celebrity_name}...`)
            try {
              const genResponse = await fetch(`${supabaseUrl}/functions/v1/generate-celebrity-character`, {
                method: 'POST',
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': `Bearer ${supabaseServiceKey}`
                },
                body: JSON.stringify({
                  celebrityId: c.celebrity_id,
                  celebrityName: c.celebrity_name,
                  gender: c.gender || userGender,
                  faceFeatures: c.face_features
                })
              })

              if (genResponse.ok) {
                const genResult = await genResponse.json()
                characterImageUrl = genResult.characterImageUrl
                console.log(`✅ [FaceReading] Character generated: ${characterImageUrl}`)
              }
            } catch (genError) {
              console.warn(`⚠️ [FaceReading] Character generation failed:`, genError)
            }
          }

          similarCelebrities.push({
            name: c.celebrity_name,
            celebrity_type: c.celebrity_type,
            character_image_url: characterImageUrl,
            similarity_score: c.similarity_score,
            matched_features: c.matched_features || []
          })
        }
        console.log(`✅ [FaceReading] Found ${similarCelebrities.length} similar celebrities`)
      } else {
        console.log('ℹ️ [FaceReading] No similar celebrities found (score < 50)')
      }
    } catch (dbError) {
      console.warn('⚠️ Celebrity DB query failed:', dbError)
    }

    // =====================================================
    // 6. 응답 구성
    // =====================================================
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['personality', 'wealth_fortune', 'love_fortune', 'health_fortune', 'career_fortune', 'special_features', 'advice', 'full_analysis', 'first_impression_detail', 'compatibility', 'marriage_prediction']
      : []

    const fortuneResponse = {
      fortuneType: 'face-reading',

      // ✅ 무료 공개
      mainFortune: analysisResult.overview.firstImpression,
      luckScore: scoreResult.total,
      scoreBreakdown: scoreResult.breakdown,

      details: {
        // ✅ 무료 공개
        face_type: analysisResult.overview.faceType,
        face_type_element: analysisResult.overview.faceTypeElement,
        overall_fortune: analysisResult.fortunes.overall.summary,

        // ✅ 무료: 눈 분석 1개만 공개
        eye_preview: {
          observation: analysisResult.ogwan.eye.observation,
          interpretation: analysisResult.ogwan.eye.interpretation,
          score: analysisResult.ogwan.eye.score
        },

        // ✅ 무료: 삼정 요약만 공개
        samjeong_summary: {
          balance: analysisResult.samjeong.balance,
          description: analysisResult.samjeong.balanceDescription
        },

        // 🔒 프리미엄
        ogwan: analysisResult.ogwan,
        samjeong: analysisResult.samjeong,
        sibigung: analysisResult.sibigung,
        personality: analysisResult.personality,
        fortunes: analysisResult.fortunes,
        specialFeatures: analysisResult.specialFeatures,
        improvements: analysisResult.improvements,

        // ✅ 무료: 닮은꼴 연예인 (있을 경우만)
        similar_celebrities: similarCelebrities.length > 0 ? similarCelebrities : null,

        // ✅ 무료: 첫인상 점수 (점수만 공개, 설명은 프리미엄)
        first_impression_preview: {
          trustScore: analysisResult.firstImpression?.trustScore || 75,
          approachabilityScore: analysisResult.firstImpression?.approachabilityScore || 75,
          charismaScore: analysisResult.firstImpression?.charismaScore || 75
        },

        // 🔒 프리미엄: 첫인상 상세
        firstImpression: analysisResult.firstImpression,

        // 🔒 프리미엄: 궁합운 (이상형 관상)
        compatibility: analysisResult.compatibility,

        // 🔒 프리미엄: 결혼 적령기 예측
        marriagePrediction: analysisResult.marriagePrediction
      },

      timestamp: new Date().toISOString(),
      isBlurred,
      blurredSections
    }

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'face-reading', scoreResult.total)
    const fortuneResponseWithPercentile = addPercentileToResult(fortuneResponse, percentileData)

    // =====================================================
    // 7. DB 저장
    // =====================================================
    if (userId) {
      const { error: insertError } = await supabase
        .from('fortunes')
        .insert({
          user_id: userId,
          type: 'face-reading',
          result: fortuneResponse,
          metadata: {
            analysis_source,
            has_image: true,
            face_features: analysisResult.userFaceFeatures,
            similar_celebrities_count: similarCelebrities.length
          }
        })

      if (insertError) {
        console.error('Error saving fortune:', insertError)
      }
    }

    return new Response(
      JSON.stringify(fortuneResponseWithPercentile),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json; charset=utf-8'
        }
      }
    )

  } catch (error) {
    console.error('❌ Error in face-reading function:', error)

    return new Response(
      JSON.stringify({
        error: error.message || 'Failed to analyze face',
        details: error.toString()
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json; charset=utf-8'
        }
      }
    )
  }
})
