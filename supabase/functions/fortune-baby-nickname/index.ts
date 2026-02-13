/**
 * 태명 분석 (Baby Nickname Fortune) Edge Function
 *
 * @description 태명과 태몽을 기반으로 아기가 부모에게 전하는 메시지 생성
 * 결과 방식: 아기 시점 메시지형 - 태아가 부모에게 직접 말하는 1인칭 시점
 *
 * @endpoint POST /fortune-baby-nickname
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - nickname: string - 태명 (예: 튼튼이, 사랑이)
 * - babyDream: string - 태몽 내용 (선택)
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

// TypeScript 인터페이스 정의
interface BabyNicknameRequest {
  userId: string;
  nickname: string;
  babyDream?: string;
}

interface BabyNicknameResponse {
  success: boolean;
  data: {
    fortuneType: string;
    babyMessage: string;       // 아기가 전하는 메시지 (1인칭)
    todayMission: string;      // 오늘의 태담 미션
    luckyKeywords: string[];   // 행운 키워드 3개
    dreamInterpretation?: string; // 태몽 해석 (태몽이 있을 때만)
  };
}

// LLM API 호출 함수
async function generateBabyNicknameFortune(params: BabyNicknameRequest): Promise<any> {
  const systemPrompt = `당신은 엄마 배 속에 있는 아기입니다.
부모님이 지어준 태명으로 불리며, 엄마 아빠의 사랑을 듬뿍 받고 있어요.

당신의 역할은 태아의 시점에서 부모님께 따뜻한 메시지를 전하는 것입니다.

## 말투 가이드
- 아기 말투로 귀엽고 사랑스럽게 말해요
- "엄마! 아빠!" 로 시작하면 좋아요
- 반말이지만 존댓말 섞어도 괜찮아요
- 이모티콘은 사용하지 않아요
- 50-80자 정도로 짧고 임팩트 있게!

## 태몽이 있을 때
- 태몽의 상징적 의미를 아기 관점에서 해석해주세요
- "그 꿈은 제가 보낸 거예요!" 같은 느낌으로

## 출력 형식 (반드시 JSON)
{
  "babyMessage": "엄마! 아빠! 저를 '튼튼이'라고 불러주실 때마다 제 심장이 콩닥콩닥 더 힘차게 뛰어요. 저를 기다려주시는 마음이 여기까지 다 전해져요. 건강하게 잘 자라고 있을게요!",
  "todayMission": "오늘은 배를 쓰다듬으며 '세상에서 가장 사랑해'라고 3번 속삭여주세요",
  "luckyKeywords": ["따뜻함", "건강", "사랑"],
  "dreamInterpretation": "그 꿈 속 용은 제가 엄마한테 보낸 인사였어요! 저 튼튼하게 잘 자라고 있다고 알려드리고 싶었거든요."
}

## 주의사항
- dreamInterpretation은 태몽이 있을 때만 포함
- babyMessage는 감동적이고 따뜻하게
- todayMission은 실천 가능한 태담/태교 활동으로
- luckyKeywords는 태명에서 연상되는 긍정적 키워드 3개`;

  const userPrompt = `# 태명 분석 요청

## 태명
${params.nickname}

${params.babyDream ? `## 태몽
${params.babyDream}` : '(태몽 없음)'}

---

태명 "${params.nickname}"으로 불리는 아기가 부모님께 전하는 메시지를 작성해주세요.
${params.babyDream ? '태몽도 아기 관점에서 해석해주세요.' : ''}`;

  // LLM 호출
  const llm = await LLMFactory.createFromConfigAsync('baby-nickname')

  const response = await llm.generate([
    { role: 'system', content: systemPrompt },
    { role: 'user', content: userPrompt }
  ], {
    temperature: 0.9,
    maxTokens: 1024,
    jsonMode: true
  })

  console.log(`LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

  // 사용량 로깅
  await UsageLogger.log({
    fortuneType: 'baby-nickname',
    userId: params.userId,
    provider: response.provider,
    model: response.model,
    response: response,
    metadata: {
      nickname: params.nickname,
      hasBabyDream: !!params.babyDream
    }
  })

  return JSON.parse(response.content)
}

// 메인 핸들러
serve(async (req) => {
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
  }

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
    console.log('태명 분석 요청 데이터:', requestBody)

    // 필수 필드 검증
    if (!requestBody.userId || !requestBody.nickname) {
      return new Response(
        JSON.stringify({ success: false, error: '필수 필드 누락: userId, nickname' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
        }
      )
    }

    const params: BabyNicknameRequest = requestBody

    // AI 태명 분석 생성
    console.log('AI 태명 분석 시작...')
    const fortuneData = await generateBabyNicknameFortune(params)

    // 응답 데이터 구조화
    const response: BabyNicknameResponse = {
      success: true,
      data: {
        fortuneType: 'babyNickname',
        babyMessage: fortuneData.babyMessage || `엄마! 아빠! 저를 '${params.nickname}'라고 불러주셔서 너무 행복해요!`,
        todayMission: fortuneData.todayMission || '오늘은 배를 쓰다듬으며 "사랑해"라고 속삭여주세요',
        luckyKeywords: fortuneData.luckyKeywords || ['사랑', '행복', '건강'],
        dreamInterpretation: params.babyDream ? fortuneData.dreamInterpretation : undefined
      }
    }

    console.log('태명 분석 완료')
    return new Response(
      JSON.stringify(response),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
      }
    )

  } catch (error) {
    console.error('태명 분석 오류:', error)

    return new Response(
      JSON.stringify({
        success: false,
        error: '태명 분석 중 오류가 발생했습니다: ' + error.message
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' }
      }
    )
  }
})
