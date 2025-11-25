import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)

// UTF-8 안전한 해시 생성 함수 (btoa는 Latin1만 지원하여 한글 불가)
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

interface ExamFortuneRequest {
  fortune_type?: string
  exam_type: string
  exam_date: string
  study_period: string
  confidence: string
  difficulty?: string
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
  // 🆕 리뉴얼된 필드
  exam_category?: string // 시험 카테고리
  exam_sub_type?: string // 세부 시험 종류
  target_score?: string // 목표 점수
  preparation_status?: string // 준비 상태
  time_point?: string // 시험 시점 (preparation, intensive, final_week, test_day)
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    const requestData: ExamFortuneRequest = await req.json()
    const {
      exam_type = '',
      exam_date = '',
      study_period = '',
      confidence = '',
      difficulty = '',
      isPremium = false, // ✅ 프리미엄 사용자 여부
      // 🆕 리뉴얼된 필드
      exam_category = '',
      exam_sub_type,
      target_score,
      preparation_status = '준비중',
      time_point = 'preparation'
    } = requestData

    if (!exam_category || !exam_date) {
      throw new Error('시험 카테고리와 시험 날짜를 입력해주세요.')
    }

    console.log('💎 [Exam] Premium 상태:', isPremium)
    console.log('🆕 [Exam] Renewal Request:', {
      category: exam_category,
      subType: exam_sub_type,
      date: exam_date,
      timePoint: time_point,
      targetScore: target_score,
      prepStatus: preparation_status
    })

    // 🆕 캐시 키에 새 필드 포함
    const cacheString = [
      exam_category,
      exam_sub_type || '',
      exam_date,
      time_point,
      preparation_status,
      target_score || ''
    ].join('_')
    const hash = await createHash(cacheString)
    const cacheKey = `exam_fortune_v2_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for exam fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling OpenAI API')

      // 🆕 시점별 맞춤 조언 생성
      const timePointAdvice = {
        preparation: '장기 준비 단계입니다. 체계적인 학습 계획을 세우고, 약점을 파악하여 보완하는 시기입니다.',
        intensive: '집중 준비 단계입니다. 복습을 강화하고, 실전 모의고사를 통해 실력을 점검하세요.',
        final_week: '마지막 주입니다. 컨디션 관리와 심리적 안정이 가장 중요합니다. 새로운 것보다는 복습에 집중하세요.',
        test_day: '시험 당일입니다. 긴장을 풀고, 최선을 다하세요. 당신이 준비한 만큼 좋은 결과가 있을 것입니다.'
      }[time_point] || timePointAdvice.preparation

      // 🆕 시험 카테고리별 특화 조언
      const categoryContext = {
        '대학입시': '인생의 중요한 전환점입니다. 과목별 균형잡힌 학습과 실전 감각이 중요합니다.',
        '공무원': '장기전입니다. 끈기와 꾸준함이 핵심입니다. 과락 방지와 평균 점수 올리기에 집중하세요.',
        '자격증': '실무 역량을 인정받는 기회입니다. 핵심 개념 이해와 반복 학습이 중요합니다.',
        '어학': '꾸준한 연습이 실력을 만듭니다. 섹션별 시간 배분과 실전 감각이 중요합니다.',
        '면접': '첫인상과 답변의 진정성이 핵심입니다. 자신감과 겸손함의 균형을 유지하세요.',
        '승진': '실무 경험과 이론의 균형이 중요합니다. 조직 이해도를 바탕으로 준비하세요.',
        '기타': '목표를 명확히 하고, 체계적으로 준비하세요.'
      }[exam_category] || '목표를 명확히 하고, 체계적으로 준비하세요.'

      const examDisplay = exam_sub_type || exam_category
      const targetScoreInfo = target_score ? `\n목표 점수: ${target_score}` : ''

      const prompt = `당신은 한국의 전문 시험운세 전문가입니다. 다음 정보를 바탕으로 구체적이고 실용적인 맞춤형 시험 조언을 제공해주세요.

🎯 시험 정보:
- 시험 카테고리: "${exam_category}"
- 세부 시험: "${examDisplay}"
- 시험 날짜: ${exam_date}${targetScoreInfo}

⏰ 시험 시점: ${time_point}
${timePointAdvice}

📚 준비 상태: ${preparation_status}

🎓 시험 특성:
${categoryContext}

다음 정보를 포함하여 상세한 시험운을 JSON 형식으로 제공해주세요:

1. 전반적인시험운: 시험 결과에 대한 전체적인 운세 (2-3문장, 긍정적이고 동기부여되는 메시지)
2. 합격가능성: 합격 가능성과 조건 (구체적이고 희망적인 메시지)
3. 집중과목: 특히 집중해야 할 과목/영역/섹션 (시험 카테고리에 맞게)
4. 주의사항: 시험 준비 시 주의할 점 (배열, 3가지)
5. 추천학습법: 효과적인 학습 방법 (배열, 3가지, ${time_point} 시점에 맞게)
6. 디데이조언: 시험 당일 주의사항 (${time_point === 'test_day' ? '당일 조언' : '시험 전 준비사항'})
7. 행운의시간: 공부하기 좋은 시간대 또는 시험 응시 시간대
8. 시험운키워드: 시험운을 한 단어로 표현 (예: "합격", "성공", "도전")
9. 강점강조: 당신의 강점 3가지 (준비 상태 ${preparation_status}를 고려)
10. 긍정메시지: 시험을 앞둔 수험생에게 전하는 따뜻하고 격려하는 메시지 (2-3문장)

긍정적이면서도 현실적인 관점으로 조언해주세요. ${time_point} 시점에 가장 필요한 조언을 제공하세요.`

      // ✅ LLM 모듈 사용
      const llm = LLMFactory.createFromConfig('exam')

      const response = await llm.generate([
        {
          role: 'system',
          content: '당신은 한국의 전문 시험운세 전문가입니다. 항상 한국어로 응답하며, 실용적이고 동기부여가 되는 조언을 제공합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ], {
        temperature: 1,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      if (!response.content) throw new Error('LLM API 응답을 받을 수 없습니다.')

      const parsedResponse = JSON.parse(response.content)

      // ✅ Blur 로직 적용 (기존 + 새 섹션)
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['pass_possibility', 'focus_subject', 'cautions', 'study_methods', 'dday_advice', 'lucky_hours', 'exam_keyword', 'strengths', 'positive_message']
        : []

      fortuneData = {
        title: `${examDisplay} 시험운`,
        fortune_type: 'exam',
        // 기존 필드 (하위 호환)
        exam_type: examDisplay,
        exam_date,
        study_period,
        confidence,
        // 🆕 새 필드
        exam_category,
        exam_sub_type,
        target_score,
        preparation_status,
        time_point,

        // 운세 데이터
        score: Math.floor(Math.random() * 30) + 70, // ✅ 무료: 공개
        overall_fortune: parsedResponse.전반적인시험운 || parsedResponse.overall_fortune || '좋은 결과가 예상됩니다.', // ✅ 무료: 공개

        // 🔒 블러 처리 섹션
        pass_possibility: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.합격가능성 || parsedResponse.pass_possibility || '충분히 합격 가능합니다.'),
        focus_subject: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.집중과목 || parsedResponse.focus_subject || '취약 부분에 집중하세요.'),
        cautions: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (parsedResponse.주의사항 || parsedResponse.cautions || ['컨디션 관리', '시간 배분', '실수 방지']),
        study_methods: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (parsedResponse.추천학습법 || parsedResponse.study_methods || ['반복 학습', '문제 풀이', '요약 정리']),
        dday_advice: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.디데이조언 || parsedResponse.dday_advice || '충분한 휴식을 취하세요.'),
        lucky_hours: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.행운의시간 || parsedResponse.lucky_hours || '오전 시간대'),
        exam_keyword: isBlurred ? '🔒' : (parsedResponse.시험운키워드 || parsedResponse.exam_keyword || '합격'),

        // 🆕 새 섹션
        strengths: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : (parsedResponse.강점강조 || parsedResponse.strengths || ['준비 성실', '집중력', '끈기']),
        positive_message: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : (parsedResponse.긍정메시지 || parsedResponse.positive_message || '당신은 충분히 준비했습니다. 자신감을 가지세요!'),

        timestamp: new Date().toISOString(),
        isBlurred, // ✅ 블러 상태
        blurredSections // ✅ 블러된 섹션 목록
      }

      await supabase.from('fortune_cache').insert({
        cache_key: cacheKey,
        result: fortuneData,
        fortune_type: 'exam',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      })
    }

    return new Response(JSON.stringify({ success: true, data: fortuneData }), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Exam Fortune Error:', error)
    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '시험운 생성 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
