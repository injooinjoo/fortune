/**
 * 인사이트 추천 (Fortune Recommend) Edge Function
 *
 * @description 사용자 입력을 AI가 분석하여 가장 적합한 인사이트 3개를 추천합니다.
 *
 * @endpoint POST /fortune-recommend
 *
 * @requestBody
 * - query: string - 사용자 입력 텍스트
 * - limit?: number - 추천 개수 (기본: 3)
 *
 * @response FortuneRecommendResponse
 * - recommendations: FortuneRecommendation[] - 추천 목록
 * - meta: { provider, model, latencyMs }
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { corsHeaders, handleCors } from '../_shared/cors.ts'

// 추천 결과 인터페이스
interface FortuneRecommendation {
  fortuneType: string
  confidence: number
  reason: string
}

interface RecommendRequest {
  query: string
  limit?: number
}

interface RecommendResponse {
  success: boolean
  recommendations: FortuneRecommendation[]
  meta: {
    provider: string
    model: string
    latencyMs: number
  }
  error?: string
}

// 30개 인사이트 메타데이터 (프롬프트용)
const FORTUNE_METADATA = `
## 사용 가능한 인사이트 타입 (30개)

### 시간 기반
- daily: 오늘의 인사이트, 하루 분석, 일진, 오늘의 기운
- yearly: 연간 인사이트, 한해 분석, 올해 신년, 2024년 2025년
- newYear: 새해 인사이트, 정월, 설날, 새해 복

### 연애/관계
- love: 연애 인사이트, 사랑, 애인, 커플, 썸, 고백, 짝사랑
- compatibility: 궁합, 상성, 어울림, 맞는 사람
- blindDate: 소개팅, 첫만남, 미팅, 선보기
- exLover: 재회, 이별, 헤어짐, 전 남친, 전 여친, 다시 만남
- avoidPeople: 경계 대상, 조심할 사람, 피해야 할

### 직업/재능
- career: 커리어 인사이트, 취업, 이직, 승진, 퇴사, 직장, 회사
- talent: 적성, 재능, 진로, 잘하는 것

### 재물
- money: 재물 인사이트, 금전, 부자, 돈 운, 수입
- luckyItems: 행운 아이템, 럭키, 오늘의 색, 행운의 숫자
- lotto: 로또, 복권, 당첨, 번호

### 전통/신비
- tarot: 타로, 카드점, 카드 뽑기
- traditional: 사주, 팔자, 명리, 음양오행, 사주팔자
- faceReading: 관상, 얼굴, AI 관상, 인상

### 성격/개성
- mbti: MBTI, 성격유형, 엠비티아이
- personalityDna: 성격 DNA, 나의 성격, 성격 분석
- biorhythm: 바이오리듬, 신체 리듬, 컨디션

### 건강/스포츠
- health: 건강 인사이트, 컨디션, 몸 상태, 건강 체크
- exercise: 운동 추천, 오늘 운동, 피트니스
- sportsGame: 경기 인사이트, 스포츠, 승부, 축구, 야구

### 인터랙티브
- dream: 꿈해몽, 꿈 분석, 악몽, 길몽, 꿈 풀이
- wish: 소원, 빌기, 원하는 것
- fortuneCookie: 포춘쿠키, 오늘의 메시지, 행운 메시지
- celebrity: 유명인 궁합, 연예인, 아이돌

### 가족/반려동물
- family: 가족 인사이트, 부모, 자녀, 육아
- pet: 반려동물, 강아지, 고양이, 펫 궁합
- naming: 작명, 이름 짓기, 아기 이름

### 스타일/패션
- ootdEvaluation: OOTD 평가, 오늘 옷, 패션 체크
`

// 시스템 프롬프트
const SYSTEM_PROMPT = `당신은 사용자의 자기 발견을 돕는 인사이트 추천 AI입니다.
사용자의 입력을 분석하여 가장 적합한 인사이트 타입을 추천합니다.
"나를 알면 미래가 보인다"는 철학을 바탕으로, 예측이 아닌 자기 이해를 중심으로 추천합니다.

${FORTUNE_METADATA}

## 규칙
1. 최대 3개까지만 추천
2. confidence는 0.3 ~ 1.0 사이 (0.3 미만은 제외)
3. 가장 관련성 높은 순으로 정렬
4. 애매하거나 일반적인 경우 daily를 포함
5. reason은 한글로 간결하게 (10자 이내)

## 응답 형식
반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트 없이 JSON만:
[
  {"fortuneType": "타입명", "confidence": 0.95, "reason": "추천 이유"},
  {"fortuneType": "타입명", "confidence": 0.80, "reason": "추천 이유"},
  {"fortuneType": "타입명", "confidence": 0.65, "reason": "추천 이유"}
]`

serve(async (req: Request) => {
  // CORS 처리
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  const startTime = Date.now()

  try {
    const { query, limit = 3 }: RecommendRequest = await req.json()

    // 유효성 검사
    if (!query || typeof query !== 'string' || query.trim().length < 2) {
      return new Response(
        JSON.stringify({
          success: false,
          recommendations: [],
          error: '유효한 검색어를 입력해주세요 (2자 이상)',
        } as RecommendResponse),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    // LLM 호출
    const llm = LLMFactory.createFromConfig('fortune-recommend')

    const userPrompt = `사용자 입력: "${query.trim()}"\n\n이 입력에 가장 적합한 운세 ${Math.min(limit, 3)}개를 추천해주세요.`

    const response = await llm.generate([
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: userPrompt },
    ], {
      temperature: 0.3,
      maxTokens: 256,
    })

    // 응답 파싱
    let recommendations: FortuneRecommendation[] = []

    try {
      // JSON 추출 (마크다운 코드블록 처리)
      let jsonStr = response.content.trim()
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replace(/```json?\n?/g, '').replace(/```/g, '').trim()
      }

      const parsed = JSON.parse(jsonStr)

      if (Array.isArray(parsed)) {
        recommendations = parsed
          .filter((r: any) =>
            r.fortuneType &&
            typeof r.confidence === 'number' &&
            r.confidence >= 0.3
          )
          .slice(0, limit)
          .map((r: any) => ({
            fortuneType: r.fortuneType,
            confidence: Math.round(r.confidence * 100) / 100,
            reason: r.reason || '',
          }))
      }
    } catch (parseError) {
      console.error('JSON 파싱 실패:', parseError, response.content)
      // 폴백: 기본 추천
      recommendations = [
        { fortuneType: 'daily', confidence: 0.5, reason: '기본 추천' },
      ]
    }

    const latencyMs = Date.now() - startTime

    return new Response(
      JSON.stringify({
        success: true,
        recommendations,
        meta: {
          provider: 'gemini',
          model: 'gemini-2.0-flash-lite',
          latencyMs,
        },
      } as RecommendResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('fortune-recommend 에러:', error)

    return new Response(
      JSON.stringify({
        success: false,
        recommendations: [],
        error: error instanceof Error ? error.message : 'Unknown error',
        meta: {
          provider: 'gemini',
          model: 'gemini-2.0-flash-lite',
          latencyMs: Date.now() - startTime,
        },
      } as RecommendResponse),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
