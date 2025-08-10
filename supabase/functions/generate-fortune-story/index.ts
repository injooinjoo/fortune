import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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
    const { 
      userName, 
      userProfile,
      weather, 
      fortune, 
      date, 
      storyConfig 
    } = await req.json()

    // OpenAI API 키가 없으면 기본 스토리 반환
    const openAIApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openAIApiKey) {
      console.log('OpenAI API key not configured, returning default story')
      return new Response(
        JSON.stringify({ 
          segments: createDefaultStory(userName, fortune, userProfile, weather) 
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200 
        }
      )
    }

    // GPT-4로 스토리 생성
    const systemPrompt = `당신은 한국의 전통 운세와 현대적 감성을 결합한 스토리텔러입니다.
사용자의 사주팔자, 현재 날씨, 오늘의 운세를 바탕으로 10페이지 분량의 몰입감 있는 운세 스토리를 만들어주세요.

중요: 절대 "사용자님"이라고 하지 마세요. 반드시 제공된 실제 이름(userName)을 사용하세요.
예를 들어 userName이 "김인주"라면 "김인주님"이라고 호칭하세요.

반드시 JSON 형식으로 응답하세요:
{
  "segments": [
    { "text": "텍스트", "fontSize": 24, "fontWeight": 300 },
    { "text": "텍스트", "fontSize": 24, "fontWeight": 300 },
    ... (총 10개 페이지)
  ]
}

각 페이지는 다음과 같은 구조를 가져야 합니다:
- text: 메인 텍스트 (2-4줄, 시적이고 감성적인 표현)
- fontSize: 폰트 크기 (20-36)
- fontWeight: 폰트 굵기 (200, 300, 400, 500, 600)

스토리는 다음 흐름을 따라야 합니다:
1. 인사 (실제 이름으로 따뜻한 인사, 예: "김인주님")
2. 오늘 날짜와 날잒 (감성적 표현)
3. 오늘의 총평 (운세 점수 기반)
4-6. 운세 상세 (아침, 점심, 저녁으로 나누어)
7. 주의사항
8. 행운의 요소들
9. 오늘의 조언
10. 마무리 메시지 (실제 이름 포함)`

    const userPrompt = `사용자 정보:
- 이름: ${userName} (절대적으로 중요: 이 이름 "${userName}"을 반드시 사용하세요. 절대로 "사용자님"이라고 하지 마세요. 반드시 "${userName}님"으로 호칭하세요)
${userProfile ? `- 생년월일: ${userProfile.birthDate}
- 생시: ${userProfile.birthTime || '모름'}
- 성별: ${userProfile.gender || '비공개'}
- 음력 여부: ${userProfile.isLunar ? '음력' : '양력'}
- 띠: ${userProfile.zodiacAnimal || ''}
- 별자리: ${userProfile.zodiacSign || ''}
- MBTI: ${userProfile.mbti || ''}
- 혈액형: ${userProfile.bloodType || ''}` : ''}

날씨 정보:
- 상태: ${weather.description}
- 온도: ${weather.temperature}°C
- 지역: ${weather.cityName}

운세 정보:
- 점수: ${fortune.score}/100
- 요약: ${fortune.summary || ''}
- 행운의 색: ${fortune.luckyColor || ''}
- 행운의 숫자: ${fortune.luckyNumber || ''}
- 행운의 시간: ${fortune.luckyTime || ''}
- 조언: ${fortune.advice || ''}

10페이지 분량의 운세 스토리를 만들어주세요.
반드시 segments 키 안에 10개의 페이지 배열을 포함하세요.`

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openAIApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4-turbo-preview',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        temperature: 0.8,
        max_tokens: 2000,
        response_format: { type: "json_object" }
      }),
    })

    if (!response.ok) {
      throw new Error(`OpenAI API error: ${response.status}`)
    }

    const data = await response.json()
    const storyContent = JSON.parse(data.choices[0].message.content)

    // segments가 항상 배열로 반환되도록 보장
    let segments = [];
    if (Array.isArray(storyContent)) {
      segments = storyContent;
    } else if (storyContent.segments) {
      // segments 안에 pages가 있는 경우
      if (storyContent.segments.pages && Array.isArray(storyContent.segments.pages)) {
        segments = storyContent.segments.pages;
      } else if (Array.isArray(storyContent.segments)) {
        segments = storyContent.segments;
      } else if (typeof storyContent.segments === 'object') {
        segments = Object.values(storyContent.segments);
      }
    } else if (storyContent.pages && Array.isArray(storyContent.pages)) {
      segments = storyContent.pages;
    } else {
      // 기본 형식으로 변환 시도
      segments = createDefaultStory(userName, fortune, userProfile, weather);
    }
    
    return new Response(
      JSON.stringify({ segments }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Error generating story:', error)
    
    // 에러 시 기본 스토리 반환 (userName이 없을 때만 '사용자' 사용)
    const fallbackName = req.json?.userName || ''
    return new Response(
      JSON.stringify({ 
        segments: createDefaultStory(fallbackName, { score: 75 }, null, null) 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )
  }
})

// 기본 스토리 생성 함수
function createDefaultStory(userName: string, fortune: any, userProfile: any, weather: any) {
  const score = fortune?.score || 75
  const now = new Date()
  
  // Ensure we use the actual name, not '사용자'
  const displayName = (userName && userName !== '사용자') ? `${userName}님` : '오늘의 주인공'
  
  return [
    {
      text: displayName,
      fontSize: 36,
      fontWeight: 200
    },
    {
      text: `${now.getMonth() + 1}월 ${now.getDate()}일\n${getWeekday(now.getDay())}`,
      fontSize: 28,
      fontWeight: 300
    },
    {
      text: score >= 80 ? '특별한 에너지가\n넘치는 날' : 
            score >= 60 ? '차분하고 안정적인\n하루' : 
            '천천히 가도\n괜찮은 날',
      fontSize: 26,
      fontWeight: 300
    },
    {
      text: '오늘 당신에게는\n새로운 기회가\n찾아올 것입니다',
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: '아침에는\n맑은 정신으로\n하루를 시작하세요',
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: '오후에는\n중요한 결정을\n내릴 수 있습니다',
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: '급하게 서두르지 말고\n신중하게 행동하세요',
      fontSize: 22,
      fontWeight: 300
    },
    {
      text: `행운의 색: ${fortune?.luckyColor || '하늘색'}\n행운의 숫자: ${fortune?.luckyNumber || '7'}`,
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: '오늘은 작은 것에서\n큰 의미를 발견하는\n특별한 하루입니다',
      fontSize: 24,
      fontWeight: 300
    },
    {
      text: '좋은 하루 되세요',
      fontSize: 28,
      fontWeight: 300
    }
  ]
}

function getWeekday(day: number): string {
  const weekdays = ['일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일']
  return weekdays[day]
}