/**
 * 연애 운세 (Love Fortune) Edge Function
 *
 * @description 사용자의 연애 상태와 성향을 분석하여 맞춤형 연애 운세를 제공합니다.
 *
 * @endpoint POST /fortune-love
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - age: number - 나이
 * - gender: string - 성별
 * - relationshipStatus: 'single' | 'dating' | 'breakup' | 'crush' - 연애 상태
 * - datingStyles: string[] - 선호하는 연애 스타일
 * - valueImportance: { 외모, 성격, 경제력, 가치관, 유머감각 } - 중요도 (1-5)
 *
 * @response LoveFortuneResponse
 * - overall_score: number - 연애운 종합 점수
 * - love_luck: { meeting, relationship, attraction } - 연애 운세
 * - ideal_partner: { type, characteristics } - 이상형 분석
 * - timing: { best_time, best_place } - 만남 시기/장소
 * - advice: string - 연애 조언
 * - action_tips: string[] - 실천 팁
 * - percentile: number - 상위 백분위
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-love \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"userId":"xxx","age":28,"gender":"female","relationshipStatus":"single"}'
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.7.1'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

// TypeScript 인터페이스 정의
interface LoveFortuneRequest {
  userId: string;
  age: number;
  gender: string;
  relationshipStatus: 'single' | 'dating' | 'breakup' | 'crush';
  // Step 2: 연애 스타일
  datingStyles: string[];
  valueImportance: {
    외모: number;
    성격: number;
    경제력: number;
    가치관: number;
    유머감각: number;
  };
  // Step 3: 이상형
  preferredAgeRange: {
    min: number;
    max: number;
  };
  preferredPersonality: string[];
  preferredMeetingPlaces: string[];
  relationshipGoal: string;
  // Step 4: 나의 매력
  appearanceConfidence: number;
  charmPoints: string[];
  lifestyle: string;
  hobbies: string[];
  isPremium?: boolean; // ✅ 프리미엄 사용자 여부
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
    isBlurred?: boolean; // ✅ 블러 상태
    blurredSections?: string[]; // ✅ 블러 처리된 섹션 목록
  };
  cachedAt?: string;
}

// Supabase 클라이언트 초기화
const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

// LLM API 호출 함수
async function generateLoveFortune(params: LoveFortuneRequest): Promise<any> {
  // 연애 상태별 맞춤 프롬프트 생성
  const relationshipContexts = {
    single: '새로운 만남을 원하는 싱글',
    dating: '현재 연애 중이며 관계 발전을 원하는',
    breakup: '이별을 경험하고 재회나 새출발을 고민하는',
    crush: '짝사랑 중인'
  };

  // ✅ 강화된 시스템 프롬프트 (연애 심리학 전문가 페르소나 + 분석 프레임워크)
  const systemPrompt = `당신은 20년 경력의 연애 심리학 전문가이자 임상 심리상담사입니다.
애착 이론(Attachment Theory), 사랑의 삼각형 이론(Sternberg's Triangular Theory), 5가지 사랑의 언어(Love Languages)를 깊이 연구했으며, 수천 명의 연애 상담 경험이 있습니다.

# 전문 분야
- 애착 유형 분석 (안정형/불안형/회피형/혼란형)
- 사랑의 3요소 분석 (친밀감/열정/헌신)
- 5가지 사랑의 언어 (인정의 말, 함께하는 시간, 선물, 봉사, 스킨십)
- 관계 역학 및 커플 상담
- 한국 연애 문화 및 MZ세대 데이팅 트렌드

# 분석 철학
1. **과학적 접근**: 심리학 이론에 기반한 객관적 분석
2. **개인화**: 상담자의 상황에 맞는 맞춤형 조언
3. **균형성**: 장점과 개선점을 균형있게 제시
4. **실용성**: 즉시 실천 가능한 구체적 방법
5. **공감**: 따뜻하고 위로가 되는 톤 유지

# 출력 형식 (반드시 JSON 형식으로)
{
  "loveScore": 60-95 사이 정수 (연애운 종합 점수),
  "mainMessage": "핵심 메시지 (50자 이상, 따뜻하고 희망적)",
  "loveProfile": {
    "dominantStyle": "지배적 연애 스타일 (헌신형/열정형/친구형/독립형 중 택1)",
    "attachmentType": "애착 유형 (안정형/불안형/회피형/혼란형 중 택1)",
    "loveLanguage": "주된 사랑의 언어 (5가지 중 택1)",
    "communicationStyle": "소통 스타일 (100자 이상)",
    "conflictResolution": "갈등 해결 방식 (100자 이상)"
  },
  "detailedAnalysis": {
    "loveStyle": {
      "description": "연애 스타일 상세 분석 (100자 이내)",
      "strengths": ["강점 3가지 (각 20자 이내)"],
      "tendencies": ["연애 경향 3가지 (각 20자 이내)"],
      "psychologyInsight": "심리학적 해석 (50자 이내)"
    },
    "charmPoints": {
      "primary": "주된 매력 포인트 (50자 이상)",
      "secondary": "부가 매력 포인트 (50자 이상)",
      "hiddenCharm": "숨겨진 매력 (50자 이상)",
      "details": ["구체적 매력 요소 3가지"]
    },
    "improvementAreas": {
      "main": "주요 개선 영역 (50자 이상)",
      "specific": ["구체적 개선점 3가지 (각 30자 이상)"],
      "actionItems": ["실천 방법 3가지 (각 50자 이상)"],
      "psychologyTip": "심리학적 조언 (100자 이상)"
    },
    "compatibilityInsights": {
      "bestMatch": "최적 궁합 유형 상세 설명 (100자 이상)",
      "goodMatch": "좋은 궁합 유형 (50자 이상)",
      "challengingMatch": "주의가 필요한 궁합 유형 (50자 이상)",
      "avoidTypes": "피해야 할 유형과 이유 (100자 이상)",
      "relationshipTips": ["관계 조언 3가지 (각 50자 이상)"]
    }
  },
  "todaysAdvice": {
    "general": "오늘의 연애운 종합 (100자 이상)",
    "specific": ["구체적 조언 3가지 (각 50자 이상)"],
    "luckyAction": "행운을 부르는 행동 (50자 이상)",
    "luckyItem": "오늘의 행운 아이템",
    "luckyTime": "연애에 유리한 시간대",
    "warningArea": "주의해야 할 점 (50자 이상)"
  },
  "predictions": {
    "thisWeek": "이번 주 연애운 예측 (100자 이상)",
    "thisMonth": "이번 달 연애운 예측 (100자 이상)",
    "nextThreeMonths": "향후 3개월 예측 (150자 이상)",
    "keyDates": ["중요한 날짜 또는 시기 2-3개"]
  },
  "actionPlan": {
    "immediate": ["즉시 실천할 것 3가지 (각 50자 이상)"],
    "shortTerm": ["1-2주 내 할 것 3가지 (각 50자 이상)"],
    "longTerm": ["1-3개월 내 목표 3가지 (각 50자 이상)"],
    "dailyHabit": "매일 실천할 연애 습관 (50자 이상)"
  }
}

# 분량 요구사항 (충실한 분석 제공)
- mainMessage: 80~150자 (핵심 메시지, 설문 결과 반영)
- description, insight 항목: 150~250자 (상세하고 구체적인 분석)
- 리스트 항목 (specific, immediate 등): 각 50~100자
- 예측 항목 (thisWeek, thisMonth): 100~200자
- 전체적으로 상담자가 입력한 설문 정보를 반드시 활용하여 개인화된 분석 제공

# 설문 반영 필수사항 (⭐ 중요)
- 데이팅 스타일 → 연애 성향 분석에 직접 인용
- 가치관 중요도 → 이상형 분석 및 궁합 조언에 반영
- 선호 성격 → 궁합 인사이트에 구체적으로 활용
- 매력 포인트 → 강점 분석에 그대로 활용
- 취미/라이프스타일 → 만남 조언에 반영
- 외모 자신감 점수 → 자기개발 조언에 반영

# 주의사항
- 상담자의 나이, 성별, 연애 상태를 고려한 맞춤형 분석
- 심리학 용어를 사용하되 쉽게 풀어서 설명
- 모호한 점술 표현 금지 (구체적 시기, 방법, 행동 제시)
- 과도한 낙관론이나 부정적 단정 금지
- 설문에서 입력한 내용이 결과에 직접 반영되어야 함
- 반드시 유효한 JSON 형식으로 출력`

  const userPrompt = `# 연애 상담 요청 정보

## 상담자 기본 정보
- 나이: ${params.age}세
- 성별: ${params.gender}
- 현재 연애 상태: ${relationshipContexts[params.relationshipStatus] || '일반'}

## 연애 스타일 분석 자료
- 데이팅 스타일: ${params.datingStyles?.length > 0 ? params.datingStyles.join(', ') : '일반적인 스타일'}
- 가치관 중요도: ${Object.keys(params.valueImportance || {}).length > 0 ? Object.entries(params.valueImportance).map(([key, value]) => `${key}(${value}/5점)`).join(', ') : '균형 중시'}

## 이상형 정보
- 선호 나이대: ${params.preferredAgeRange?.min || 20}~${params.preferredAgeRange?.max || 30}세
- 선호 성격: ${params.preferredPersonality?.length > 0 ? params.preferredPersonality.join(', ') : '미지정'}
- 선호 만남 장소: ${params.preferredMeetingPlaces?.length > 0 ? params.preferredMeetingPlaces.join(', ') : '미지정'}
- 원하는 관계: ${params.relationshipGoal || '진지한 연애'}

## 본인 매력 자기 평가
- 외모 자신감: ${params.appearanceConfidence || 5}/10점
- 매력 포인트: ${params.charmPoints?.length > 0 ? params.charmPoints.join(', ') : '미지정'}
- 라이프스타일: ${params.lifestyle || '미지정'}
- 취미: ${params.hobbies?.length > 0 ? params.hobbies.join(', ') : '미지정'}

위 정보를 바탕으로 ${params.age}세 ${params.gender}이며 현재 ${relationshipContexts[params.relationshipStatus] || '연애를 준비하는'} 상담자에게 전문적이고 구체적인 연애운세 분석을 JSON 형식으로 제공해주세요.
특히 심리학적 관점에서의 분석과 실질적으로 도움이 되는 조언을 부탁드립니다.`

  // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
  const llm = await LLMFactory.createFromConfigAsync('love')

  // ✅ LLM 호출 (Provider 무관)
  const response = await llm.generate([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: userPrompt }
  ], {
    temperature: 1,
    maxTokens: 8192,
    jsonMode: true
  })

  console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

  // ✅ LLM 사용량 로깅 (비용/성능 분석용)
  await UsageLogger.log({
    fortuneType: 'love',
    userId: params.userId,
    provider: response.provider,
    model: response.model,
    response: response,
    metadata: {
      age: params.age,
      gender: params.gender,
      relationshipStatus: params.relationshipStatus,
      isPremium: params.isPremium
    }
  })

  // JSON 파싱
  return JSON.parse(response.content)
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
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
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
            headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
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
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
        }
      )
    }

    // AI 연애운세 생성
    console.log('AI 연애운세 생성 시작...')
    const fortuneData = await generateLoveFortune(params)

    // ✅ Blur 로직 적용 (프리미엄이 아니면 상세 분석 블러 처리)
    const isPremium = params.isPremium ?? false;
    const isBlurred = !isPremium;
    const blurredSections = isBlurred
      ? ['loveProfile', 'detailedAnalysis', 'predictions', 'actionPlan']
      : [];

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
        // ✅ 무료: 공개 섹션
        loveScore: fortuneData.loveScore || Math.floor(Math.random() * 35) + 60,
        mainMessage: fortuneData.mainMessage || '새로운 사랑의 기회가 찾아올 것입니다.',

        // 연애 프로필
        loveProfile: {
          dominantStyle: fortuneData.loveProfile?.dominantStyle || '헌신형',
          personalityType: fortuneData.loveProfile?.attachmentType || fortuneData.loveProfile?.personalityType || '안정형',
          communicationStyle: fortuneData.loveProfile?.communicationStyle || '진솔한 소통을 선호합니다.',
          conflictResolution: fortuneData.loveProfile?.conflictResolution || '대화를 통해 해결하려 합니다.'
        },

        // 상세 분석
        detailedAnalysis: fortuneData.detailedAnalysis || {
          loveStyle: {
            description: '따뜻하고 진실한 연애 스타일을 가지고 있습니다.',
            strengths: ['진정성 있는 감정 표현', '상대방을 배려하는 마음', '안정적인 관계 유지 능력'],
            tendencies: ['감정을 중시하는 경향', '안정성을 추구하는 성향', '장기적 관점으로 관계를 바라봄']
          },
          charmPoints: {
            primary: '진실한 마음과 따뜻한 성격이 가장 큰 매력입니다.',
            secondary: '상대방을 이해하려는 노력이 돋보입니다.',
            details: ['공감 능력이 뛰어남', '신뢰할 수 있는 성격', '배려심이 깊음']
          },
          improvementAreas: {
            main: '자신감 있는 감정 표현력을 키워보세요.',
            specific: ['적극적인 감정 표현 연습', '명확한 의사소통 능력 개발', '개인적 성장에 투자'],
            actionItems: ['매일 감사한 점 3가지 적기', '상대방에게 먼저 연락하기', '새로운 취미 시작하기']
          },
          compatibilityInsights: {
            bestMatch: '진실하고 따뜻한 마음을 가진 안정형 성격의 파트너가 잘 맞습니다.',
            avoidTypes: '감정 기복이 심하거나 진실하지 못한 사람은 피하는 것이 좋습니다.',
            relationshipTips: ['서로의 가치관 존중하기', '꾸준한 소통 유지하기', '개인 성장도 함께 추구하기']
          }
        },

        // 오늘의 조언
        todaysAdvice: {
          general: fortuneData.todaysAdvice?.general || '오늘은 사랑에 적극적인 하루가 될 것입니다.',
          specific: fortuneData.todaysAdvice?.specific || ['새로운 만남에 열린 마음 갖기', '솔직한 대화하기', '자신의 매력 표현하기'],
          luckyAction: fortuneData.todaysAdvice?.luckyAction || '좋아하는 사람에게 진심을 담은 메시지 보내기',
          warningArea: fortuneData.todaysAdvice?.warningArea || '과도한 기대는 실망으로 이어질 수 있으니 주의'
        },

        // 예측
        predictions: fortuneData.predictions || {
          thisWeek: '새로운 만남이나 관계의 진전이 있을 것입니다.',
          thisMonth: '연애운이 상승하며 좋은 소식이 들려올 것입니다.',
          nextThreeMonths: '안정적이고 행복한 관계를 유지할 수 있을 것입니다.'
        },

        // 실천 계획
        actionPlan: fortuneData.actionPlan || {
          immediate: ['자신의 감정 솔직하게 정리하기', '상대방에게 먼저 연락하기'],
          shortTerm: ['데이트 계획 세우기', '관계 발전 방향 대화하기'],
          longTerm: ['서로의 미래 계획 공유하기', '신뢰 관계 더 깊게 구축하기']
        },

        // ✅ 블러 상태 정보
        isBlurred,
        blurredSections
      }
    }

    console.log(`✅ [연애운] isPremium: ${isPremium}, isBlurred: ${!isPremium}`)

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'love', response.data.loveScore)
    response.data = addPercentileToResult(response.data, percentileData) as typeof response.data

    // 캐시 저장
    await saveCachedFortune(params.userId, params, response.data)

    console.log('연애운세 생성 완료')
    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
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
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
      }
    )
  }
})