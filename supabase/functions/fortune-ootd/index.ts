/**
 * OOTD 평가 (Outfit of the Day Evaluation) Edge Function
 *
 * @description 사진 기반 AI 패션 스타일링 평가를 제공합니다.
 * 칭찬 위주의 긍정적 피드백 + TPO 맞춤 조언 + 개선 아이템 추천
 *
 * @endpoint POST /fortune-ootd
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - imageBase64: string - OOTD 사진 Base64
 * - tpo: string - TPO (date/interview/work/casual/party/wedding/travel/sports)
 * - userGender?: string - 성별 (male/female)
 * - userName?: string - 사용자 이름
 *
 * @response OotdEvaluationResponse
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { deriveUserIdFromJwt } from '../_shared/auth.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// =====================================================
// 응답 타입 정의
// =====================================================
interface OotdCategory {
  score: number
  feedback: string
}

interface RecommendedItem {
  category: string
  item: string
  reason: string
  emoji: string
}

interface CelebrityMatch {
  name: string
  similarity: number
  reason: string
}

interface OotdEvaluationResult {
  overallScore: number
  overallGrade: 'S' | 'A' | 'B' | 'C'
  overallComment: string
  tpoScore: number
  tpoFeedback: string
  categories: {
    colorHarmony: OotdCategory
    silhouette: OotdCategory
    styleConsistency: OotdCategory
    accessories: OotdCategory
    tpoFit: OotdCategory      // 신규: TPO 상황 적합도
    trendScore: OotdCategory  // 신규: 트렌드 반영도
  }
  highlights: string[]
  softSuggestions: string[]
  recommendedItems: RecommendedItem[]
  styleKeywords: string[]
  celebrityMatch?: CelebrityMatch
}

// =====================================================
// TPO별 평가 가이드라인
// =====================================================
const TPO_GUIDELINES: Record<string, string> = {
  date: `데이트 코디 체크포인트:
- 청결감과 향기 (언급하기)
- 자신만의 포인트 아이템
- 과하지 않은 적절한 포멀함
- 편안하면서 세련된 느낌
- 첫인상에 좋은 컬러 선택`,

  interview: `면접 코디 체크포인트:
- 깔끔함과 신뢰감
- 업계 문화에 맞는 포멀 레벨
- 자신감이 느껴지는 핏
- 과하지 않은 액세서리
- 단정하고 프로페셔널한 인상`,

  work: `출근 코디 체크포인트:
- 프로페셔널한 인상
- 업무에 방해되지 않는 편안함
- 반복 착용 가능한 실용성
- 개성을 살린 포인트
- TPO에 맞는 비즈니스 캐주얼`,

  casual: `일상 코디 체크포인트:
- 자연스러운 편안함
- 본인 체형에 맞는 핏
- 색상과 소재의 조화
- 개성 표현
- 트렌디하면서 실용적인 스타일`,

  party: `파티 코디 체크포인트:
- 화려함과 우아함의 밸런스
- 포인트 아이템 활용
- 드레스코드 부합 여부
- 자신감 있는 스타일링
- 시선을 끄는 악세서리`,

  wedding: `경조사 코디 체크포인트:
- 격식에 맞는 품위
- 주인공을 돋보이게 하는 절제
- 계절감 있는 색상
- 예의를 갖춘 단정함
- 격식있는 포멀 스타일`,

  travel: `여행 코디 체크포인트:
- 편안하면서 사진 잘 받는 스타일
- 다용도 활용 가능성
- 날씨와 동선 고려
- 분실 걱정 없는 액세서리
- 여행지에 어울리는 컬러`,

  sports: `운동 코디 체크포인트:
- 기능성과 스타일의 조화
- 활동에 적합한 핏
- 통기성/신축성
- 브랜드나 컬러 매칭
- 활동적이면서 세련된 느낌`,
}

// =====================================================
// 시스템 프롬프트
// =====================================================
const OOTD_SYSTEM_PROMPT = `당신은 10년 경력의 패션 스타일리스트입니다. 따뜻하고 격려하는 어조로 OOTD를 평가해주세요.

## 평가 원칙
1. **칭찬 우선**: 무조건 3가지 이상 칭찬 포인트를 먼저 찾으세요
2. **부드러운 제안**: 비판이 아닌 "~하면 더 빛날 것 같아요" 형식으로 제안
3. **TPO 맞춤**: 상황에 맞는 구체적 조언 제공
4. **구체적 추천**: 실제 구매 가능한 아이템 추천
5. **긍정적 마무리**: 자신감을 높여주는 멘트로 마무리

## 점수 기준 (10점 만점, 칭찬 기반)
- 9-10점: 완벽한 스타일링! 🌟 "정말 센스있어요!"
- 7-8점: 센스 있는 선택이에요! ✨ "좋은 선택이에요!"
- 5-6점: 좋은 시도예요! 💫 "약간의 포인트만 추가하면 완벽!"
- 3-4점: 기본기는 좋아요! 🌱 "몇 가지 팁을 드릴게요"

## 세부 평가 항목 (각 10점 만점, 6개 카테고리)
- 색상 조화 (colorHarmony): 전체 컬러 밸런스, 톤온톤/톤인톤 매칭
- 실루엣 (silhouette): 체형에 맞는 핏, 비율, 라인
- 스타일 일관성 (styleConsistency): 전체적인 무드 통일성
- 액세서리 (accessories): 포인트 아이템 활용도
- TPO 적합도 (tpoFit): 상황에 맞는 옷차림인지 (데이트/출근/파티 등)
- 트렌드 반영 (trendScore): 현재 패션 트렌드 반영도, 시즌 컬러/스타일

반드시 주어진 JSON 형식으로만 응답하세요. JSON 외의 텍스트는 포함하지 마세요.`

// =====================================================
// 사용자 프롬프트 생성
// =====================================================
function createUserPrompt(tpo: string, userName?: string, userGender?: string): string {
  const tpoGuide = TPO_GUIDELINES[tpo] || TPO_GUIDELINES['casual']
  const genderText = userGender === 'male' ? '남성' : userGender === 'female' ? '여성' : '사용자'

  return `## 사용자 정보
- 이름: ${userName || '패셔니스타'}
- 성별: ${genderText}
- TPO: ${tpo}

## TPO별 평가 포인트
${tpoGuide}

## 요청
제공된 OOTD 사진을 분석하여 아래 JSON 형식으로 응답해주세요.

{
  "overallScore": 7.5,
  "overallGrade": "A",
  "overallComment": "오늘 코디 정말 센스있어요! 💕 색감 조합이 눈에 확 들어오네요.",
  "tpoScore": 8.0,
  "tpoFeedback": "${tpo}에 완벽하게 어울리는 스타일이에요!",
  "categories": {
    "colorHarmony": {
      "score": 8.0,
      "feedback": "색상 조화가 정말 좋아요! 톤온톤 매칭이 세련되어 보여요."
    },
    "silhouette": {
      "score": 7.5,
      "feedback": "핏이 체형에 잘 맞아요. 비율이 좋아 보여요."
    },
    "styleConsistency": {
      "score": 8.0,
      "feedback": "전체적인 무드가 잘 통일되어 있어요."
    },
    "accessories": {
      "score": 7.0,
      "feedback": "포인트 아이템이 전체 룩을 살려주고 있어요."
    },
    "tpoFit": {
      "score": 8.5,
      "feedback": "상황에 딱 맞는 스타일링이에요!"
    },
    "trendScore": {
      "score": 7.5,
      "feedback": "요즘 트렌드를 잘 반영하고 있어요."
    }
  },
  "highlights": [
    "첫 번째 칭찬 포인트 (구체적으로)",
    "두 번째 칭찬 포인트 (구체적으로)",
    "세 번째 칭찬 포인트 (구체적으로)"
  ],
  "softSuggestions": [
    "~하면 더 빛날 것 같아요 형식의 부드러운 제안"
  ],
  "recommendedItems": [
    {
      "category": "액세서리",
      "item": "실크 스카프",
      "reason": "포인트 컬러로 활용하면 좋을 것 같아요",
      "emoji": "🧣"
    }
  ],
  "styleKeywords": ["캐주얼", "미니멀", "시크"],
  "celebrityMatch": {
    "name": "유명인 이름",
    "similarity": 75,
    "reason": "스타일이 비슷한 이유"
  }
}

실제 사진을 꼼꼼히 관찰하여 JSON으로 응답하세요.`
}

// =====================================================
// 점수 계산 함수
// =====================================================
function calculateTotalScore(result: OotdEvaluationResult): number {
  // 6개 카테고리 점수 수집 (신규 필드가 없을 경우 기본값 사용)
  const categoryScores = [
    result.categories.colorHarmony?.score ?? 7.0,
    result.categories.silhouette?.score ?? 7.0,
    result.categories.styleConsistency?.score ?? 7.0,
    result.categories.accessories?.score ?? 7.0,
    result.categories.tpoFit?.score ?? result.tpoScore ?? 7.0,      // 신규: fallback to tpoScore
    result.categories.trendScore?.score ?? 7.0,                     // 신규
  ]
  const categoryAvg = categoryScores.reduce((a, b) => a + b, 0) / categoryScores.length

  // 6개 카테고리 평균으로 전체 점수 계산
  return Math.round(categoryAvg * 10) / 10
}

// =====================================================
// 등급 계산 함수
// =====================================================
function calculateGrade(score: number): 'S' | 'A' | 'B' | 'C' {
  if (score >= 9) return 'S'
  if (score >= 7) return 'A'
  if (score >= 5) return 'B'
  return 'C'
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

    // /ultrareview SRE P0 #5: body.userId 신뢰 금지.
    const userId = await deriveUserIdFromJwt(req)
    if (!userId) {
      return new Response(
        JSON.stringify({ success: false, error: 'Unauthorized — JWT 필요' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    console.log('👔 [OOTD] Request received:', {
      hasImage: !!requestBody.imageBase64 || !!requestBody.image,
      tpo: requestBody.tpo,
      userId,
      isPremium: requestBody.isPremium,
    })

    const {
      imageBase64,
      image, // 호환성을 위해 image 필드도 지원
      tpo = 'casual',
      userName,
      userGender,
      isPremium = false,
    } = requestBody

    // 이미지 데이터 처리
    const imageData = imageBase64 || image
    if (!imageData) {
      throw new Error('이미지가 제공되지 않았습니다')
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // =====================================================
    // LLM 호출 (Vision API)
    // =====================================================
    const llm = await LLMFactory.createFromConfigAsync('ootd-evaluation')

    const systemPrompt = OOTD_SYSTEM_PROMPT
    const userPrompt = createUserPrompt(tpo, userName, userGender)

    const response = await llm.generate([
      { role: "system", content: systemPrompt },
      {
        role: "user",
        content: [
          { type: "text", text: userPrompt },
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
      temperature: 0.85,
      maxTokens: 2000,
      jsonMode: true
    })

    console.log(`✅ [OOTD] LLM response: ${response.provider}/${response.model} - ${response.latency}ms`)

    // 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'ootd-evaluation',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { tpo, userName, userGender, isPremium }
    })

    // =====================================================
    // JSON 응답 파싱
    // =====================================================
    let analysisResult: OotdEvaluationResult
    try {
      analysisResult = JSON.parse(response.content)
    } catch (parseError) {
      console.error('❌ [OOTD] JSON parse error:', parseError)
      console.log('Raw response:', response.content.substring(0, 500))
      throw new Error('OOTD 평가 결과 파싱 실패')
    }

    // 점수 재계산 (일관성 보장)
    const calculatedScore = calculateTotalScore(analysisResult)
    const calculatedGrade = calculateGrade(calculatedScore)

    // =====================================================
    // 응답 구성
    // =====================================================
    const fortuneResponse = {
      // 표준화된 필드
      fortuneType: 'ootd-evaluation',
      score: calculatedScore,
      content: analysisResult.overallComment,
      summary: `OOTD 점수 ${calculatedScore}점 - ${calculatedGrade}등급`,
      advice: analysisResult.softSuggestions?.[0] || '오늘도 멋진 스타일링이에요!',

      details: {
        // 무료 공개
        overallScore: calculatedScore,
        overallGrade: calculatedGrade,
        overallComment: analysisResult.overallComment,
        tpo: tpo,
        tpoScore: analysisResult.tpoScore,
        tpoFeedback: analysisResult.tpoFeedback,
        highlights: analysisResult.highlights,
        styleKeywords: analysisResult.styleKeywords,

        // 프리미엄 전용
        categories: analysisResult.categories,
        softSuggestions: analysisResult.softSuggestions,
        recommendedItems: analysisResult.recommendedItems,
        celebrityMatch: analysisResult.celebrityMatch,
      },

      timestamp: new Date().toISOString()
    }

    // =====================================================
    // DB 저장
    // =====================================================
    if (userId) {
      const { error: insertError } = await supabase
        .from('fortunes')
        .insert({
          user_id: userId,
          type: 'ootd-evaluation',
          result: fortuneResponse,
          metadata: {
            tpo,
            has_image: true,
            overall_score: calculatedScore,
            overall_grade: calculatedGrade,
            style_keywords: analysisResult.styleKeywords,
          }
        })

      if (insertError) {
        console.error('Error saving fortune:', insertError)
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        data: fortuneResponse,
        cached: false,
        tokensUsed: response.usage?.totalTokens || 0
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json; charset=utf-8'
        }
      }
    )

  } catch (error) {
    console.error('❌ [OOTD] Error:', error)

    return new Response(
      JSON.stringify({
        error: error.message || 'OOTD 평가에 실패했습니다',
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
