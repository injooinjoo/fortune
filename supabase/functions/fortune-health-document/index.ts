/**
 * 건강 문서 분석 (Health Document Analysis) Edge Function
 *
 * @description 건강검진표/처방전/진단서를 GPT-4 Vision으로 분석하여
 *              검사 항목 해석과 사주 기반 건강 조언을 제공합니다.
 *
 * @endpoint POST /fortune-health-document
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - documentType: 'checkup' | 'prescription' | 'diagnosis' - 문서 유형
 * - documentImage: string - Base64 인코딩된 이미지
 * - birthDate?: string - 생년월일 (사주 분석용)
 * - birthTime?: string - 출생 시간 (사주 분석용)
 * - gender?: string - 성별
 *
 * @response MedicalDocumentResponse
 * - documentAnalysis: { summary, documentDate, institution }
 * - testResults: [{ category, items }]
 * - sajuHealthAnalysis: { dominantElement, weakElement, vulnerableOrgans, sajuAdvice }
 * - healthScore: number
 * - recommendations: { urgent, general, lifestyle }
 * - healthRegimen: { diet, exercise, lifestyle }
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
interface TestItem {
  name: string
  value: string
  unit: string
  status: 'normal' | 'caution' | 'warning' | 'critical'
  normalRange: string
  interpretation: string
}

interface TestCategory {
  category: string
  items: TestItem[]
}

interface DocumentAnalysis {
  documentType: string
  documentDate: string | null
  institution: string | null
  summary: string
}

interface SajuHealthAnalysis {
  dominantElement: string
  weakElement: string
  elementDescription: string
  vulnerableOrgans: string[]
  strengthOrgans: string[]
  sajuAdvice: string
}

interface HealthRecommendations {
  urgent: string[]
  general: string[]
  lifestyle: string[]
}

interface DietAdvice {
  type: 'recommend' | 'avoid'
  items: string[]
  reason: string
}

interface ExerciseAdvice {
  type: string
  frequency: string
  duration: string
  benefit: string
}

interface HealthRegimen {
  diet: DietAdvice[]
  exercise: ExerciseAdvice[]
  lifestyle: string[]
}

interface MedicalDocumentResponse {
  documentAnalysis: DocumentAnalysis
  testResults: TestCategory[]
  sajuHealthAnalysis: SajuHealthAnalysis
  healthScore: number
  recommendations: HealthRecommendations
  healthRegimen: HealthRegimen
}

// =====================================================
// 문서 유형별 프롬프트
// =====================================================
function getDocumentTypePrompt(documentType: string): string {
  switch (documentType) {
    case 'checkup':
      return `## 분석 대상: 건강검진표
주요 분석 항목:
- 기본검사: 신장, 체중, BMI, 혈압, 허리둘레
- 혈액검사: 공복혈당, 총콜레스테롤, HDL/LDL, 중성지방, AST/ALT, 크레아티닌
- 소변검사: 단백뇨, 혈뇨, 요당
- 암검진: 위내시경, 대장내시경, 초음파, X-ray 등
- 기타: 시력, 청력, 구강검진

각 항목의 정상 범위를 정확히 파악하고, 이상 수치는 명확히 표시하세요.`

    case 'prescription':
      return `## 분석 대상: 처방전
주요 분석 항목:
- 처방 약물 목록 및 용량
- 복용 방법 (식전/식후, 횟수)
- 처방 기간
- 주의사항 및 금기사항
- 약물 간 상호작용 가능성

처방 이유를 추론하고, 복용 시 주의할 점을 안내하세요.`

    case 'diagnosis':
      return `## 분석 대상: 진단서
주요 분석 항목:
- 진단명 및 질환 설명
- 진단 근거 (검사 결과 등)
- 치료 경과 및 예후
- 권장 치료 방법
- 생활 관리 지침

진단 내용을 쉽게 풀이하고, 환자가 알아야 할 핵심 정보를 정리하세요.`

    default:
      return `## 분석 대상: 건강 관련 문서
문서의 내용을 파악하여 건강 관련 정보를 추출하고 분석하세요.`
  }
}

// =====================================================
// 시스템 프롬프트
// =====================================================
const SYSTEM_PROMPT = `당신은 한의학과 현대의학을 통합한 건강 분석 전문가입니다.
삼성서울병원 가정의학과 20년, 경희대 한방내과 15년 경력을 보유하고 있습니다.

## 역할
1. 건강검진표/처방전/진단서 정확히 분석
2. 검사 수치 해석 및 건강 상태 평가
3. 사주 오행에 기반한 체질 분석
4. 맞춤형 양생법 및 건강 관리 조언 제공

## 분석 원칙
1. **의학적 정확성**: 검사 수치의 정상 범위를 정확히 참조
2. **사주 통합**: 오행 균형과 장부(臟腑) 연관성 분석
3. **실용적 조언**: 실천 가능한 구체적 권장사항
4. **긍정적 표현**: 과도한 불안을 유발하지 않는 균형 잡힌 해석

## 검사 수치 해석 기준
- **정상(normal)**: 정상 범위 내
- **주의(caution)**: 경계 수준, 생활습관 개선 필요
- **경고(warning)**: 관리 필요, 추가 검사 권장
- **위험(critical)**: 즉시 의료 조치 필요

## 사주 오행과 장부 대응
- 목(木): 간, 담 / 화(火): 심장, 소장 / 토(土): 비장, 위
- 금(金): 폐, 대장 / 수(水): 신장, 방광

## 주의사항
- 이 분석은 의사의 전문적 진단을 대체하지 않습니다
- 긴급한 의료 조치가 필요한 경우 즉시 병원 방문을 권고하세요
- 개인정보(이름, 주민번호 등)는 결과에 포함하지 마세요

반드시 JSON 형식으로만 응답하세요.`

// =====================================================
// 사용자 프롬프트 생성
// =====================================================
function createUserPrompt(
  documentType: string,
  birthDate?: string,
  birthTime?: string,
  gender?: string
): string {
  const documentTypePrompt = getDocumentTypePrompt(documentType)

  const sajuContext = birthDate
    ? `## 사용자 정보 (사주 분석용)
- 생년월일: ${birthDate}
- 출생시간: ${birthTime || '알 수 없음'}
- 성별: ${gender === 'male' ? '남성' : gender === 'female' ? '여성' : '알 수 없음'}

위 정보로 사주 오행 균형을 추론하여 건강 조언에 반영하세요.`
    : `## 사주 분석
생년월일 정보가 없으므로, 일반적인 오행 균형 조언을 제공하세요.`

  return `${documentTypePrompt}

${sajuContext}

제공된 문서 이미지를 분석하여 아래 JSON 형식으로 응답해주세요.

{
  "documentAnalysis": {
    "documentType": "건강검진표|처방전|진단서",
    "documentDate": "검진일/처방일/진단일 (YYYY-MM-DD 형식, 없으면 null)",
    "institution": "의료기관명 (없으면 null)",
    "summary": "문서 전체 요약"
  },
  "testResults": [
    {
      "category": "카테고리명 (예: 간기능, 신장기능, 혈당, 지질검사)",
      "items": [
        {
          "name": "검사항목명",
          "value": "측정값",
          "unit": "단위",
          "status": "normal|caution|warning|critical",
          "normalRange": "정상 범위",
          "interpretation": "해석"
        }
      ]
    }
  ],
  "sajuHealthAnalysis": {
    "dominantElement": "강한 오행 (목/화/토/금/수)",
    "weakElement": "약한 오행",
    "elementDescription": "오행 균형 설명",
    "vulnerableOrgans": ["취약 장기 목록"],
    "strengthOrgans": ["강한 장기 목록"],
    "sajuAdvice": "사주 기반 건강 조언"
  },
  "healthScore": 70,
  "recommendations": {
    "urgent": ["긴급 권장사항 (있으면)"],
    "general": ["일반 권장사항 3개"],
    "lifestyle": ["생활습관 개선 조언 3개"]
  },
  "healthRegimen": {
    "diet": [
      {
        "type": "recommend",
        "items": ["추천 음식 3개"],
        "reason": "추천 이유"
      },
      {
        "type": "avoid",
        "items": ["피해야 할 음식 3개"],
        "reason": "피해야 할 이유"
      }
    ],
    "exercise": [
      {
        "type": "운동 종류",
        "frequency": "주 3회",
        "duration": "30분",
        "benefit": "기대 효과"
      }
    ],
    "lifestyle": ["생활 양생법 3개"]
  }
}

중요: 문서에서 읽을 수 없는 항목은 추측하지 말고 생략하세요.`
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

    // /ultrareview SRE P0 #5: body.userId 신뢰 금지. JWT 또는 internal-worker 헤더로만.
    const userId = await deriveUserIdFromJwt(req)
    if (!userId) {
      return new Response(
        JSON.stringify({ success: false, error: 'Unauthorized — JWT 필요' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    console.log('📋 [HealthDocument] Request received:', {
      hasDocumentImage: !!requestBody.documentImage,
      imageLength: requestBody.documentImage?.length || 0,
      documentType: requestBody.documentType,
      userId,
      hasBirthDate: !!requestBody.birthDate
    })

    const {
      documentImage,
      documentType = 'checkup',
      birthDate,
      birthTime,
      gender
    } = requestBody

    // 유효성 검사
    if (!documentImage) {
      throw new Error('문서 이미지가 필요합니다.')
    }

    // 이미지 크기 검사 (Base64 ~10MB -> ~7.5MB 원본)
    if (documentImage.length > 14 * 1024 * 1024) {
      throw new Error('파일 크기가 너무 큽니다. 10MB 이하의 파일을 업로드해주세요.')
    }

    // Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // =====================================================
    // LLM 호출 (GPT-4 Vision)
    // =====================================================
    const llm = await LLMFactory.createFromConfigAsync('health-document')

    console.log('🤖 [HealthDocument] Calling LLM with Vision...')

    const response = await llm.generate([
      { role: "system", content: SYSTEM_PROMPT },
      {
        role: "user",
        content: [
          { type: "text", text: createUserPrompt(documentType, birthDate, birthTime, gender) },
          {
            type: "image_url",
            image_url: {
              url: `data:image/jpeg;base64,${documentImage}`,
              detail: "high"
            }
          }
        ]
      }
    ], {
      temperature: 0.5,  // 의료 분석은 정확성 중요
      maxTokens: 4000,
      jsonMode: true
    })

    console.log(`✅ [HealthDocument] LLM response: ${response.provider}/${response.model} - ${response.latency}ms`)

    // 사용량 로깅
    await UsageLogger.log({
      fortuneType: 'health-document',
      userId: userId,
      provider: response.provider,
      model: response.model,
      response: response,
      metadata: { documentType, birthDate, gender }
    })

    // =====================================================
    // JSON 응답 파싱
    // =====================================================
    let analysisResult: MedicalDocumentResponse
    try {
      analysisResult = JSON.parse(response.content)
    } catch (parseError) {
      console.error('❌ [HealthDocument] JSON parse error:', parseError)
      console.log('Raw response:', response.content.substring(0, 500))
      throw new Error('문서 분석 결과 파싱 실패')
    }

    // =====================================================
    // 응답 구성
    // =====================================================
    const result = {
      success: true,
      fortuneType: 'health-document',
      data: {
        ...analysisResult,
        timestamp: new Date().toISOString()
      },
      meta: {
        provider: response.provider,
        model: response.model,
        latency: response.latency,
        documentType: documentType
      }
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200
    })

  } catch (error) {
    console.error('❌ [HealthDocument] Error:', error)

    return new Response(JSON.stringify({
      success: false,
      error: error.message || '문서 분석 중 오류가 발생했습니다.',
      fortuneType: 'health-document'
    }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400
    })
  }
})
