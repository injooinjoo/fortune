import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'

// TypeScript 인터페이스 정의
interface LoveFortuneRequest {
  userId: string;
  age: number;
  gender: string;
  relationshipStatus: 'single' | 'dating' | 'breakup' | 'crush';
  datingStyles: string[];
  valueImportance: {
    외모: number;
    성격: number;
    경제력: number;
    가치관: number;
    유머감각: number;
  };
  personalityTypes: string[];
  loveGoals: string[];
  communicationStyles: string[];
  conflictStyles: string[];
}

interface LoveFortuneResponse {
  success: boolean;
  data: {
    fortuneType: string;
    personalInfo: {
      age: number;
      gender: string;
      relationshipStatus: string;
    };
    loveScore: number;
    mainMessage: string;
    loveProfile: {
      dominantStyle: string;
      personalityType: string;
      communicationStyle: string;
      conflictResolution: string;
    };
    detailedAnalysis: {
      loveStyle: {
        description: string;
        strengths: string[];
        tendencies: string[];
      };
      charmPoints: {
        primary: string;
        secondary: string;
        details: string[];
      };
      improvementAreas: {
        main: string;
        specific: string[];
        actionItems: string[];
      };
      compatibilityInsights: {
        bestMatch: string;
        avoidTypes: string;
        relationshipTips: string[];
      };
    };
    todaysAdvice: {
      general: string;
      specific: string[];
      luckyAction: string;
      warningArea: string;
    };
    predictions: {
      thisWeek: string;
      thisMonth: string;
      nextThreeMonths: string;
    };
    actionPlan: {
      immediate: string[];
      shortTerm: string[];
      longTerm: string[];
    };
  };
  cachedAt?: string;
}

// Supabase 클라이언트 초기화
const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

// OpenAI API 호출 함수
async function generateLoveFortune(params: LoveFortuneRequest): Promise<any> {
  const openAIApiKey = Deno.env.get('OPENAI_API_KEY')
  if (!openAIApiKey) {
    throw new Error('OpenAI API key not found')
  }

  // 연애 상태별 맞춤 프롬프트 생성
  const relationshipContexts = {
    single: '새로운 만남을 원하는 싱글',
    dating: '현재 연애 중이며 관계 발전을 원하는',
    breakup: '이별을 경험하고 재회나 새출발을 고민하는',
    crush: '짝사랑 중인'
  };

  const prompt = `당신은 30년 경력의 전문 연애 상담사이자 심리학자입니다. 다음 정보를 바탕으로 전문적이고 구체적인 연애운세를 제공해주세요.

**상담자 정보:**
- 나이: ${params.age}세
- 성별: ${params.gender}
- 연애 상태: ${relationshipContexts[params.relationshipStatus]}
- 연애 스타일: ${params.datingStyles.join(', ')}
- 가치관 중요도: ${Object.entries(params.valueImportance).map(([key, value]) => `${key}(${value}/5점)`).join(', ')}
- 성격 유형: ${params.personalityTypes?.join(', ') || '미지정'}
- 연애 목표: ${params.loveGoals?.join(', ') || '미지정'}
- 소통 스타일: ${params.communicationStyles?.join(', ') || '미지정'}
- 갈등 해결 방식: ${params.conflictStyles?.join(', ') || '미지정'}

**분석 요청 사항:**
1. 전체적인 연애운 점수 (1-100점)와 핵심 메시지
2. 연애 스타일과 성격 분석
3. 매력 포인트와 개선이 필요한 부분
4. 상대방과의 궁합 및 관계 조언
5. 오늘 및 향후 연애운 예측
6. 구체적인 실천 방안

**응답 형식:**
반드시 JSON 형태로 응답하되, 한국의 연애 문화와 현대적 감성을 반영하여 작성해주세요.
전문적이면서도 따뜻하고 실용적인 조언을 제공하되, 과도한 낙관론이나 부정적인 표현은 피해주세요.`;

  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${openAIApiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'gpt-5-nano-2025-08-07',
      messages: [
        {
          role: 'system',
          content: '당신은 전문 연애 상담사이자 심리학자입니다. 한국의 연애 문화를 깊이 이해하고 있으며, 과학적이면서도 따뜻한 조언을 제공합니다. 응답은 반드시 유효한 JSON 형식이어야 합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ],
      max_tokens: 3000,
      temperature: 0.7,
      response_format: { type: "json_object" }
    }),
  })

  if (!response.ok) {
    const errorText = await response.text()
    console.error('OpenAI API 오류:', errorText)
    throw new Error(`OpenAI API 호출 실패: ${response.status}`)
  }

  const data = await response.json()
  return JSON.parse(data.choices[0].message.content)
}

// 캐시 조회 함수
async function getCachedFortune(userId: string, params: LoveFortuneRequest) {
  try {
    const cacheKey = `love_${userId}_${JSON.stringify({
      age: params.age,
      gender: params.gender,
      relationshipStatus: params.relationshipStatus,
      datingStyles: params.datingStyles.sort(),
      valueImportance: params.valueImportance
    })}`

    const { data, error } = await supabase
      .from('fortune_cache')
      .select('result, created_at')
      .eq('cache_key', cacheKey)
      .gte('created_at', new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
      .order('created_at', { ascending: false })
      .limit(1)
      .single()

    if (error) {
      console.log('캐시 조회 결과 없음:', error.message)
      return null
    }

    console.log('캐시된 연애운세 조회 성공')
    return {
      ...data.result,
      cachedAt: data.created_at
    }
  } catch (error) {
    console.error('캐시 조회 오류:', error)
    return null
  }
}

// 캐시 저장 함수
async function saveCachedFortune(userId: string, params: LoveFortuneRequest, result: any) {
  try {
    const cacheKey = `love_${userId}_${JSON.stringify({
      age: params.age,
      gender: params.gender,
      relationshipStatus: params.relationshipStatus,
      datingStyles: params.datingStyles.sort(),
      valueImportance: params.valueImportance
    })}`

    const { error } = await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: userId,
        fortune_type: 'love',
        result: result,
        created_at: new Date().toISOString()
      })

    if (error) {
      console.error('캐시 저장 오류:', error)
    } else {
      console.log('연애운세 캐시 저장 완료')
    }
  } catch (error) {
    console.error('캐시 저장 중 예외:', error)
  }
}

// 메인 핸들러
serve(async (req) => {
  // CORS 헤더 설정
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  }

  // OPTIONS 요청 처리
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  try {
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ success: false, error: 'POST 메소드만 허용됩니다' }),
        {
          status: 405,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const requestBody = await req.json()
    console.log('연애운세 요청 데이터:', requestBody)

    // 필수 필드 검증
    const requiredFields = ['userId', 'age', 'gender', 'relationshipStatus', 'datingStyles', 'valueImportance']
    for (const field of requiredFields) {
      if (!requestBody[field]) {
        return new Response(
          JSON.stringify({ success: false, error: `필수 필드 누락: ${field}` }),
          {
            status: 400,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          }
        )
      }
    }

    const params: LoveFortuneRequest = requestBody

    // 캐시 확인
    const cachedResult = await getCachedFortune(params.userId, params)
    if (cachedResult) {
      return new Response(
        JSON.stringify({
          success: true,
          data: cachedResult,
          cached: true
        }),
        {
          status: 200,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // AI 연애운세 생성
    console.log('AI 연애운세 생성 시작...')
    const fortuneData = await generateLoveFortune(params)

    // 응답 데이터 구조화
    const response: LoveFortuneResponse = {
      success: true,
      data: {
        fortuneType: 'love',
        personalInfo: {
          age: params.age,
          gender: params.gender,
          relationshipStatus: params.relationshipStatus
        },
        loveScore: fortuneData.loveScore || Math.floor(Math.random() * 30) + 60, // 60-90 사이
        mainMessage: fortuneData.mainMessage || '새로운 사랑의 기회가 찾아올 것입니다.',
        loveProfile: {
          dominantStyle: fortuneData.loveProfile?.dominantStyle || params.datingStyles[0] || '감성적',
          personalityType: fortuneData.loveProfile?.personalityType || params.personalityTypes?.[0] || '이해심 많은',
          communicationStyle: fortuneData.loveProfile?.communicationStyle || params.communicationStyles?.[0] || '직접적',
          conflictResolution: fortuneData.loveProfile?.conflictResolution || params.conflictStyles?.[0] || '협력적'
        },
        detailedAnalysis: fortuneData.detailedAnalysis || {
          loveStyle: {
            description: '따뜻하고 진실한 연애 스타일을 가지고 있습니다.',
            strengths: ['진정성', '배려심', '소통능력'],
            tendencies: ['감정 중시', '안정성 추구', '장기적 관점']
          },
          charmPoints: {
            primary: '진실한 마음과 따뜻한 성격',
            secondary: '상대방을 이해하려는 노력',
            details: ['공감 능력이 뛰어남', '신뢰할 수 있는 성격', '유머 감각이 있음']
          },
          improvementAreas: {
            main: '자신감 있는 표현력',
            specific: ['적극적인 감정 표현', '명확한 의사소통', '개인적 성장'],
            actionItems: ['자신의 감정을 솔직하게 표현하기', '상대방과의 소통 시간 늘리기', '개인적 취미 개발하기']
          },
          compatibilityInsights: {
            bestMatch: '진실하고 따뜻한 마음을 가진 사람',
            avoidTypes: '감정적으로 불안정하거나 진실하지 못한 사람',
            relationshipTips: ['서로의 가치관을 존중하기', '꾸준한 소통 유지하기', '개인의 성장도 중요시하기']
          }
        },
        todaysAdvice: fortuneData.todaysAdvice || {
          general: '오늘은 사랑에 적극적인 하루가 될 것입니다.',
          specific: ['새로운 만남에 열린 마음 갖기', '기존 관계에서는 솔직한 대화하기', '자신의 매력을 표현하기'],
          luckyAction: '좋아하는 사람에게 진심을 담은 메시지 보내기',
          warningArea: '과도한 기대는 실망으로 이어질 수 있으니 주의'
        },
        predictions: fortuneData.predictions || {
          thisWeek: '새로운 만남이나 관계의 진전이 있을 것입니다.',
          thisMonth: '연애운이 상승하며 좋은 소식이 들려올 것입니다.',
          nextThreeMonths: '안정적이고 행복한 관계를 유지할 수 있을 것입니다.'
        },
        actionPlan: fortuneData.actionPlan || {
          immediate: ['자신의 감정 정리하기', '상대방과의 소통 늘리기'],
          shortTerm: ['데이트 계획 세우기', '관계 발전 방향 논의하기'],
          longTerm: ['서로의 미래 계획 공유하기', '지속 가능한 관계 구축하기']
        }
      }
    }

    // 캐시 저장
    await saveCachedFortune(params.userId, params, response.data)

    console.log('연애운세 생성 완료')
    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('연애운세 생성 오류:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: '연애운세 생성 중 오류가 발생했습니다: ' + error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})