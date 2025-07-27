import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { OpenAI } from "https://deno.land/x/openai@v4.20.1/mod.ts"

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
    // Initialize Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    // Initialize OpenAI
    const openai = new OpenAI({
      apiKey: Deno.env.get('OPENAI_API_KEY'),
    })

    // Get today's date in KST
    const kstDate = new Date(new Date().toLocaleString("en-US", {timeZone: "Asia/Seoul"}))
    const dateStr = kstDate.toISOString().split('T')[0]

    // Fetch all celebrities
    const { data: celebrities, error: celebritiesError } = await supabaseClient
      .from('celebrity_profiles')
      .select('*')

    if (celebritiesError) {
      throw celebritiesError
    }

    console.log(`Generating fortunes for ${celebrities.length} celebrities on ${dateStr}`)

    // Generate fortune for each celebrity
    const fortunePromises = celebrities.map(async (celebrity) => {
      try {
        // Check if fortune already exists for today
        const { data: existingFortune } = await supabaseClient
          .from('celebrity_daily_fortunes')
          .select('id')
          .eq('celebrity_id', celebrity.id)
          .eq('date', dateStr)
          .single()

        if (existingFortune) {
          console.log(`Fortune already exists for ${celebrity.name} on ${dateStr}`)
          return null
        }

        // Generate fortune using OpenAI
        const completion = await openai.chat.completions.create({
          model: "gpt-4-turbo-preview",
          messages: [
            {
              role: "system",
              content: `당신은 한국의 유명한 운세 전문가입니다. ${celebrity.name}(${celebrity.category}, ${celebrity.birth_date} 출생)의 오늘 운세를 상세하게 작성해주세요.
              
              다음 형식의 JSON으로 응답해주세요:
              {
                "summary": "오늘의 종합 운세 (2-3문장)",
                "todayScore": 오늘 운세 점수 (0-100),
                "weeklyScore": 이번 주 운세 점수 (0-100),
                "monthlyScore": 이번 달 운세 점수 (0-100),
                "predictions": {
                  "love": "연애운 상세 설명",
                  "career": "직업/경력운 상세 설명",
                  "wealth": "재물운 상세 설명",
                  "health": "건강운 상세 설명"
                },
                "luckyTime": "행운의 시간 (예: 오후 3-5시)",
                "luckyColor": "행운의 색상",
                "luckyItem": "행운의 아이템",
                "luckyDirection": "행운의 방향",
                "advice": "오늘의 조언",
                "compatibility": {
                  "best_match": "최고의 궁합 (다른 유명인 이름)",
                  "worst_match": "피해야 할 궁합 (다른 유명인 이름)",
                  "description": "궁합 설명"
                }
              }`
            },
            {
              role: "user",
              content: `${dateStr} ${celebrity.name}의 운세를 작성해주세요.`
            }
          ],
          temperature: 0.8,
          response_format: { type: "json_object" }
        })

        const fortuneData = JSON.parse(completion.choices[0].message.content || '{}')

        // Save fortune to database
        const { error: insertError } = await supabaseClient
          .from('celebrity_daily_fortunes')
          .insert({
            celebrity_id: celebrity.id,
            date: dateStr,
            fortune_data: {
              ...fortuneData,
              celebrity: {
                id: celebrity.id,
                name: celebrity.name,
                category: celebrity.category,
                profile_image: celebrity.profile_image_url,
                zodiac: getZodiacSign(celebrity.birth_date),
                chinese_zodiac: getChineseZodiac(celebrity.birth_date)
              }
            }
          })

        if (insertError) {
          console.error(`Error saving fortune for ${celebrity.name}:`, insertError)
          return { celebrity: celebrity.name, error: insertError.message }
        }

        console.log(`Successfully generated fortune for ${celebrity.name}`)
        return { celebrity: celebrity.name, success: true }

      } catch (error) {
        console.error(`Error generating fortune for ${celebrity.name}:`, error)
        return { celebrity: celebrity.name, error: error.message }
      }
    })

    const results = await Promise.all(fortunePromises)
    const successCount = results.filter(r => r && r.success).length
    const errorCount = results.filter(r => r && r.error).length

    return new Response(
      JSON.stringify({
        success: true,
        date: dateStr,
        totalCelebrities: celebrities.length,
        successCount,
        errorCount,
        results: results.filter(r => r !== null)
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('Error in fortune-celebrity-daily-generator:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    )
  }
})

// Helper function to get zodiac sign
function getZodiacSign(birthDate: string): string {
  const date = new Date(birthDate)
  const month = date.getMonth() + 1
  const day = date.getDate()
  
  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return '양자리'
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return '황소자리'
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) return '쌍둥이자리'
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return '게자리'
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return '사자자리'
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return '처녀자리'
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return '천칭자리'
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) return '전갈자리'
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) return '사수자리'
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return '염소자리'
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return '물병자리'
  return '물고기자리'
}

// Helper function to get Chinese zodiac
function getChineseZodiac(birthDate: string): string {
  const year = new Date(birthDate).getFullYear()
  const zodiacAnimals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양']
  return zodiacAnimals[year % 12]
}