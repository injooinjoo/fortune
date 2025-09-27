import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 사주팔자 계산 함수들 (고급 버전)
function calculate천간(birthDate: string): string {
  const year = new Date(birthDate).getFullYear();
  const 천간 = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
  return 천간[(year - 4) % 10];
}

function calculate지지(birthDate: string): string {
  const year = new Date(birthDate).getFullYear();
  const 지지 = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'];
  return 지지[(year - 4) % 12];
}

function calculate오행Balance(birthDate: string, birthTime?: string): Record<string, number> {
  const date = new Date(birthDate);
  const month = date.getMonth() + 1;
  const day = date.getDate();
  const hour = birthTime ? parseInt(birthTime.split(':')[0]) : 12;
  
  const balance = {
    목: 0,
    화: 0,
    토: 0,
    금: 0,
    수: 0
  };
  
  // 계절별 기본 오행 (더 정교하게)
  if (month >= 2 && month <= 4) balance.목 = 3; // 봄
  else if (month >= 5 && month <= 7) balance.화 = 3; // 여름
  else if (month >= 8 && month <= 10) balance.금 = 3; // 가을
  else balance.수 = 3; // 겨울

  // 월별 세분화
  balance.목 += (month === 3 || month === 4) ? 1 : 0;
  balance.화 += (month === 6 || month === 7) ? 1 : 0;
  balance.토 += (month === 6 || month === 9 || month === 12) ? 1 : 0;
  balance.금 += (month === 9 || month === 10) ? 1 : 0;
  balance.수 += (month === 12 || month === 1) ? 1 : 0;
  
  // 시간대별 보정
  if (hour >= 23 || hour < 1) balance.수 += 2; // 자시
  else if (hour >= 1 && hour < 3) balance.토 += 1; // 축시
  else if (hour >= 3 && hour < 5) balance.목 += 2; // 인시
  else if (hour >= 5 && hour < 7) balance.목 += 2; // 묘시
  else if (hour >= 7 && hour < 9) balance.토 += 1; // 진시
  else if (hour >= 9 && hour < 11) balance.화 += 2; // 사시
  else if (hour >= 11 && hour < 13) balance.화 += 2; // 오시
  else if (hour >= 13 && hour < 15) balance.토 += 1; // 미시
  else if (hour >= 15 && hour < 17) balance.금 += 2; // 신시
  else if (hour >= 17 && hour < 19) balance.금 += 2; // 유시
  else if (hour >= 19 && hour < 21) balance.토 += 1; // 술시
  else if (hour >= 21 && hour < 23) balance.수 += 2; // 해시
  
  // 일자별 추가 보정
  balance.목 += (day % 5 === 0) ? 1 : 0;
  balance.화 += (day % 5 === 1) ? 1 : 0;
  balance.토 += (day % 5 === 2) ? 1 : 0;
  balance.금 += (day % 5 === 3) ? 1 : 0;
  balance.수 += (day % 5 === 4) ? 1 : 0;
  
  return balance;
}

function calculateDetailedSaju(birthDate: string, birthTime?: string) {
  const date = new Date(birthDate);
  const year = date.getFullYear();
  const month = date.getMonth() + 1;
  const day = date.getDate();
  const hour = birthTime ? parseInt(birthTime.split(':')[0]) : 12;
  
  const 천간 = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계'];
  const 지지 = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해'];
  
  // 년주 계산
  const yearCheongan = 천간[(year - 4) % 10];
  const yearJiji = 지지[(year - 4) % 12];
  
  // 월주 계산 (실제 사주학에서는 더 복잡하지만 간소화)
  const monthCheongan = 천간[((year - 4) * 12 + month - 1) % 10];
  const monthJiji = 지지[(month + 1) % 12];
  
  // 일주 계산
  const dayCheongan = 천간[((year - 1900) * 365 + Math.floor((year - 1900) / 4) + day) % 10];
  const dayJiji = 지지[((year - 1900) * 365 + Math.floor((year - 1900) / 4) + day) % 12];
  
  // 시주 계산
  const hourCheongan = 천간[(Math.floor(hour / 2) + (year - 4) * 12) % 10];
  const hourJiji = 지지[Math.floor(hour / 2)];
  
  return {
    년주: { 천간: yearCheongan, 지지: yearJiji },
    월주: { 천간: monthCheongan, 지지: monthJiji },
    일주: { 천간: dayCheongan, 지지: dayJiji },
    시주: { 천간: hourCheongan, 지지: hourJiji }
  };
}

function calculateBasicSaju(birthDate: string, birthTime?: string) {
  const 천간 = calculate천간(birthDate);
  const 지지 = calculate지지(birthDate);
  const 오행 = calculate오행Balance(birthDate, birthTime);
  const 상세사주 = calculateDetailedSaju(birthDate, birthTime);
  
  // 부족한 오행 찾기
  const minElement = Object.entries(오행).reduce((min, [key, value]) => 
    value < min.value ? {element: key, value} : min, 
    {element: '목', value: 오행.목}
  );
  
  return {
    기본정보: {
      천간,
      지지,
      간지: `${천간}${지지}`,
      부족한오행: minElement.element
    },
    오행균형: 오행,
    상세사주: 상세사주,
    생성일시: new Date().toIso8601String()
  };
}

function get오행보충방법(element: string): string {
  const methods: Record<string, string> = {
    목: '초록색 옷 착용, 새벽 운동, 동쪽 방향 활동, 식물 키우기',
    화: '붉은색 소품 활용, 따뜻한 음식, 남쪽 방향 중시, 밝은 조명',
    토: '노란색 강조, 달콤한 음식, 중앙 위치 선호, 도자기 소품',
    금: '흰색 의상, 매운 음식, 서쪽 방향 활동, 금속 액세서리',
    수: '검은색 액세서리, 짠 음식, 북쪽 방향 중시, 물가 산책'
  };
  return methods[element] || '';
}

serve(async (req) => {
  console.log('🚀 Calculate-Saju Function invoked:', new Date().toISOString())
  console.log('Method:', req.method)
  
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Supabase 클라이언트 초기화
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 요청 데이터 파싱
    const { birthDate, birthTime, isLunar = false, timezone = 'Asia/Seoul' } = await req.json()
    console.log('📦 Request data:', { birthDate, birthTime, isLunar, timezone })

    // 사용자 인증 확인
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Authorization header is required')
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    
    if (authError || !user) {
      throw new Error('Invalid authorization token')
    }

    console.log('🔐 User authenticated:', user.id)

    // 기존 사주 데이터 확인 (중복 방지)
    const { data: existingSaju, error: checkError } = await supabase
      .from('user_saju')
      .select('*')
      .eq('user_id', user.id)
      .maybeSingle()

    if (checkError && !checkError.message.includes('does not exist')) {
      console.error('❌ Error checking existing saju:', checkError)
      throw new Error(`데이터베이스 조회 오류: ${checkError.message}`)
    }

    if (existingSaju) {
      console.log('✅ Saju already exists, returning cached data')
      return new Response(
        JSON.stringify({
          success: true,
          data: existingSaju,
          cached: true,
          message: '이미 계산된 사주 데이터가 있습니다.'
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200 
        }
      )
    }

    // OpenAI API 키 확인
    const openAIApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openAIApiKey) {
      console.log('⚠️ OpenAI API key not configured, using basic calculation')
      
      // 기본 계산으로 사주 생성
      const basicSaju = calculateBasicSaju(birthDate, birthTime)
      
      const sajuData = {
        user_id: user.id,
        birth_date: birthDate,
        birth_time: birthTime || '12:00',
        is_lunar: isLunar,
        year_cheongan: basicSaju.상세사주.년주.천간,
        year_jiji: basicSaju.상세사주.년주.지지,
        month_cheongan: basicSaju.상세사주.월주.천간,
        month_jiji: basicSaju.상세사주.월주.지지,
        day_cheongan: basicSaju.상세사주.일주.천간,
        day_jiji: basicSaju.상세사주.일주.지지,
        hour_cheongan: basicSaju.상세사주.시주.천간,
        hour_jiji: basicSaju.상세사주.시주.지지,
        element_wood: basicSaju.오행균형.목,
        element_fire: basicSaju.오행균형.화,
        element_earth: basicSaju.오행균형.토,
        element_metal: basicSaju.오행균형.금,
        element_water: basicSaju.오행균형.수,
        weak_element: basicSaju.기본정보.부족한오행,
        enhancement_method: get오행보충방법(basicSaju.기본정보.부족한오행),
        personality_traits: '기본 성격 분석이 필요합니다.',
        fortune_summary: '상세 운세 분석이 필요합니다.',
        created_at: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }

      // 데이터베이스에 저장
      const { data: savedData, error: saveError } = await supabase
        .from('user_saju')
        .insert(sajuData)
        .select()
        .single()

      if (saveError) {
        console.error('❌ Error saving basic saju:', saveError)
        throw new Error(`사주 저장 오류: ${saveError.message}`)
      }

      console.log('✅ Basic saju calculated and saved')
      return new Response(
        JSON.stringify({
          success: true,
          data: savedData,
          cached: false,
          message: '기본 사주가 계산되었습니다.'
        }),
        { 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200 
        }
      )
    }

    // GPT-5 nano로 상세 사주 분석
    console.log('🤖 Calling GPT-5 nano for detailed saju analysis...')
    
    const basicSaju = calculateBasicSaju(birthDate, birthTime)
    
    const systemPrompt = `당신은 한국의 전통 사주명리학 전문가입니다. 
사용자의 생년월일시를 바탕으로 정확하고 깊이 있는 사주팔자 분석을 제공해주세요.

다음 정보를 포함하여 JSON 형식으로 응답해주세요:
{
  "personality_traits": "성격과 기질에 대한 상세 분석 (3-4문장)",
  "fortune_summary": "전반적인 운세와 인생 방향 (4-5문장)",
  "career_fortune": "직업운과 성공 방향 (2-3문장)",
  "wealth_fortune": "재물운과 금전관리 (2-3문장)",
  "love_fortune": "애정운과 인간관계 (2-3문장)",
  "health_fortune": "건강운과 주의사항 (2-3문장)",
  "yearly_forecast": "연도별 운세 흐름 (3-4문장)",
  "life_advice": "인생 조언과 방향 (3-4문장)"
}`

    const userPrompt = `사주 분석 대상:
생년월일: ${birthDate}
생시: ${birthTime || '12:00'}
음력여부: ${isLunar ? '음력' : '양력'}

계산된 기본 사주:
- 년주: ${basicSaju.상세사주.년주.천간}${basicSaju.상세사주.년주.지지}
- 월주: ${basicSaju.상세사주.월주.천간}${basicSaju.상세사주.월주.지지}
- 일주: ${basicSaju.상세사주.일주.천간}${basicSaju.상세사주.일주.지지}
- 시주: ${basicSaju.상세사주.시주.천간}${basicSaju.상세사주.시주.지지}

오행 균형:
- 목: ${basicSaju.오행균형.목}
- 화: ${basicSaju.오행균형.화}
- 토: ${basicSaju.오행균형.토}
- 금: ${basicSaju.오행균형.금}
- 수: ${basicSaju.오행균형.수}
- 부족한 오행: ${basicSaju.기본정보.부족한오행}

위 사주 정보를 바탕으로 상세한 분석을 제공해주세요.`

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openAIApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-oss-20b',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ],
        temperature: 0.7,
        max_tokens: 1500,
        response_format: { type: "json_object" }
      }),
    })

    if (!response.ok) {
      const errorText = await response.text()
      console.error('❌ OpenAI API error:', response.status, errorText)
      throw new Error(`OpenAI API 오류: ${response.status}`)
    }

    const gptData = await response.json()
    const analysis = JSON.parse(gptData.choices[0].message.content)
    
    console.log('✅ GPT analysis completed')

    // 전체 사주 데이터 구성
    const completeSajuData = {
      user_id: user.id,
      birth_date: birthDate,
      birth_time: birthTime || '12:00',
      is_lunar: isLunar,
      year_cheongan: basicSaju.상세사주.년주.천간,
      year_jiji: basicSaju.상세사주.년주.지지,
      month_cheongan: basicSaju.상세사주.월주.천간,
      month_jiji: basicSaju.상세사주.월주.지지,
      day_cheongan: basicSaju.상세사주.일주.천간,
      day_jiji: basicSaju.상세사주.일주.지지,
      hour_cheongan: basicSaju.상세사주.시주.천간,
      hour_jiji: basicSaju.상세사주.시주.지지,
      element_wood: basicSaju.오행균형.목,
      element_fire: basicSaju.오행균형.화,
      element_earth: basicSaju.오행균형.토,
      element_metal: basicSaju.오행균형.금,
      element_water: basicSaju.오행균형.수,
      weak_element: basicSaju.기본정보.부족한오행,
      enhancement_method: get오행보충방법(basicSaju.기본정보.부족한오행),
      personality_traits: analysis.personality_traits,
      fortune_summary: analysis.fortune_summary,
      career_fortune: analysis.career_fortune,
      wealth_fortune: analysis.wealth_fortune,
      love_fortune: analysis.love_fortune,
      health_fortune: analysis.health_fortune,
      yearly_forecast: analysis.yearly_forecast,
      life_advice: analysis.life_advice,
      gpt_analysis: analysis,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    // 데이터베이스에 저장
    const { data: savedData, error: saveError } = await supabase
      .from('user_saju')
      .insert(completeSajuData)
      .select()
      .single()

    if (saveError) {
      console.error('❌ Error saving complete saju:', saveError)
      throw new Error(`사주 저장 오류: ${saveError.message}`)
    }

    console.log('✅ Complete saju calculated and saved with GPT analysis')
    
    return new Response(
      JSON.stringify({
        success: true,
        data: savedData,
        cached: false,
        tokensUsed: gptData.usage?.total_tokens || 0,
        message: 'GPT 분석을 포함한 상세 사주가 계산되었습니다.'
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('❌ Error in calculate-saju:', error)
    
    return new Response(
      JSON.stringify({ 
        success: false,
        error: error.message || '사주 계산 중 오류가 발생했습니다.',
        details: error.toString(),
        timestamp: new Date().toISOString()
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})