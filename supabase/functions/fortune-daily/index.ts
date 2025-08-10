import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const requestData = await req.json()
    const { 
      userId,
      name,
      birthDate, 
      birthTime,
      gender,
      isLunar,
      mbtiType,
      bloodType,
      zodiacSign,
      zodiacAnimal
    } = requestData

    // 오늘 날짜
    const today = new Date()
    const dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][today.getDay()]
    
    // 운세 점수 생성 (사주 정보 기반)
    const baseScore = 70 + Math.floor(Math.random() * 20)
    const score = Math.min(100, baseScore + (mbtiType === 'ENTJ' ? 5 : 0))
    
    // 운세 내용 생성
    const fortune = {
      advice: '오늘은 자신의 강점을 믿고 적극적으로 나아가며, 중요한 순간에는 침착함을 유지하세요.',
      caution: '오후 5시 이후에는 감정이 격해질 수 있으니, 과도한 감정적 반응이나 충동적인 결정은 피하세요.',
      summary: score >= 80 ? '자신감 넘치는 하루, 성공의 기회 기대하세요' : '차분하고 안정적인 하루가 될 것입니다',
      greeting: `${name}님, 오늘은 ${today.getFullYear()}년 ${today.getMonth() + 1}월 ${today.getDate()}일 ${dayOfWeek}요일, 맑고 활기찬 기운이 가득한 하루입니다.`,
      description: `오늘 ${name}님께서는 오전에 차분한 성찰과 계획 세우기에 좋은 시간입니다. 특히, 중요한 업무나 프로젝트에 집중하면 좋은 성과를 얻을 수 있습니다. 오후로 갈수록 자신감이 높아지고, 리더십이 발휘될 시기입니다.`,
      lucky_items: {
        time: '오후 2시에서 4시',
        color: '청록색',
        number: 8,
        direction: '남동쪽'
      },
      special_tip: `오늘은 ${zodiacSign}의 세밀함과 ${mbtiType}의 추진력을 활용하여, 작은 디테일에 집착하는 동시에 큰 그림을 그리세요.`,
      overall_score: score
    }
    
    // 스토리 세그먼트 생성 (10페이지)
    const storySegments = [
      {
        text: `${name}님, 환영합니다.\n오늘의 이야기가\n당신에게 작은 빛이 되기를.`,
        fontSize: 24,
        fontWeight: 400
      },
      {
        text: `${today.getMonth() + 1}월 ${today.getDate()}일 ${dayOfWeek}요일\n하늘은 맑고\n당신의 마음도 맑기를.`,
        fontSize: 24,
        fontWeight: 300
      },
      {
        text: `오늘의 점수는 ${score}\n${score >= 80 ? '자신감으로 가득 찬' : '차분하고 안정적인'}\n특별한 하루입니다.`,
        fontSize: 26,
        fontWeight: 500
      },
      {
        text: `아침의 햇살처럼\n새로운 시작을 알리는\n긍정의 에너지가 당신과 함께.`,
        fontSize: 22,
        fontWeight: 300
      },
      {
        text: `점심 무렵\n중요한 결정의 순간이 온다면\n침착함을 잃지 마세요.`,
        fontSize: 22,
        fontWeight: 300
      },
      {
        text: `저녁이 되면\n하루의 성취를 돌아보며\n스스로를 격려해주세요.`,
        fontSize: 22,
        fontWeight: 300
      },
      {
        text: `주의할 점\n감정의 기복이 있을 수 있으니\n마음의 중심을 잡으세요.`,
        fontSize: 24,
        fontWeight: 400
      },
      {
        text: `행운의 색: ${fortune.lucky_items.color}\n행운의 숫자: ${fortune.lucky_items.number}\n행운의 시간: ${fortune.lucky_items.time}`,
        fontSize: 24,
        fontWeight: 400
      },
      {
        text: `오늘의 당부\n자신의 강점을 믿고\n명확한 소통으로 나아가세요.`,
        fontSize: 24,
        fontWeight: 400
      },
      {
        text: `좋은 하루 되세요\n${name}님의 하루가\n빛나기를 바랍니다.`,
        fontSize: 24,
        fontWeight: 400
      }
    ]
    
    // 운세와 스토리를 함께 반환
    return new Response(
      JSON.stringify({ 
        fortune,
        storySegments,
        cached: false,
        tokensUsed: 0
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Error generating fortune:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Failed to generate fortune',
        message: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})