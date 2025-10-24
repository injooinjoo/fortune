import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)

interface ExamFortuneRequest {
  fortune_type?: string
  exam_type: string
  exam_date: string
  study_period: string
  confidence: string
  difficulty?: string
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
      difficulty = ''
    } = requestData

    if (!exam_type || !exam_date) {
      throw new Error('시험 종류와 시험 날짜를 입력해주세요.')
    }

    console.log('Exam fortune request:', { exam_type, exam_date })

    const cacheKey = `exam_fortune_${btoa(`${exam_type}_${exam_date}_${study_period}_${confidence}`).slice(0, 50)}`
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

      const prompt = `당신은 한국의 전문 시험운세 전문가입니다. 다음 정보를 바탕으로 구체적이고 실용적인 시험 조언을 제공해주세요.

시험 종류: "${exam_type}"
시험 날짜: ${exam_date}
준비 기간: ${study_period}
자신감: ${confidence}
난이도: ${difficulty}

다음 정보를 포함하여 상세한 시험운을 제공해주세요:

1. 전반적인 시험운: 시험 결과에 대한 전체적인 운
2. 합격 가능성: 합격 가능성과 조건
3. 집중 과목: 특히 집중해야 할 과목이나 영역
4. 주의사항: 시험 준비 시 주의할 점 3가지
5. 추천 학습법: 효과적인 학습 방법 3가지
6. D-day 조언: 시험 당일 주의사항
7. 행운의 시간: 공부하기 좋은 시간대
8. 시험운 키워드: 시험운을 한 단어로 표현

긍정적이면서도 현실적인 관점으로 조언해주세요.`

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

      fortuneData = {
        title: `${exam_type} 시험운`,
        fortune_type: 'exam',
        exam_type,
        exam_date,
        study_period,
        confidence,
        overall_fortune: parsedResponse.전반적인시험운 || parsedResponse.overall_fortune || '좋은 결과가 예상됩니다.',
        pass_possibility: parsedResponse.합격가능성 || parsedResponse.pass_possibility || '충분히 합격 가능합니다.',
        focus_subject: parsedResponse.집중과목 || parsedResponse.focus_subject || '취약 부분에 집중하세요.',
        cautions: parsedResponse.주의사항 || parsedResponse.cautions || ['컨디션 관리', '시간 배분', '실수 방지'],
        study_methods: parsedResponse.추천학습법 || parsedResponse.study_methods || ['반복 학습', '문제 풀이', '요약 정리'],
        dday_advice: parsedResponse.디데이조언 || parsedResponse.dday_advice || '충분한 휴식을 취하세요.',
        lucky_hours: parsedResponse.행운의시간 || parsedResponse.lucky_hours || '오전 시간대',
        exam_keyword: parsedResponse.시험운키워드 || parsedResponse.exam_keyword || '합격',
        score: Math.floor(Math.random() * 30) + 70,
        timestamp: new Date().toISOString()
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
        'Content-Type': 'application/json',
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
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
