import { serve } from 'https://deno.land/std@0.208.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'
import { generateFortuneWithAI } from '../_shared/openai.ts'
import { 
  ZODIAC_ANIMALS, 
  getMajorAgeGroupsForZodiac, 
  generateZodiacAgeCacheKey,
  formatZodiacAgeKey,
  type ZodiacAnimal 
} from '../_shared/zodiac-utils.ts'

// Generate age-based zodiac fortune prompt
function generateZodiacAgePrompt(zodiacAnimal: ZodiacAnimal, currentYear: number): string {
  const ageGroups = getMajorAgeGroupsForZodiac(zodiacAnimal, currentYear);
  
  const ageGroupsInfo = ageGroups.map(group => 
    `- ${group.age}세 (${group.birthYear}년생): ${group.ageGroup}, 주요 관심사: ${group.concerns}`
  ).join('\n');

  return `
당신은 동양 십이지 전문가이자 인생 상담사입니다.
현재 ${currentYear}년을 기준으로, ${zodiacAnimal}띠의 나이별 운세를 작성해주세요.

${zodiacAnimal}띠 연령 분포:
${ageGroupsInfo}

각 연령대별로 다음 형식의 JSON으로 작성해주세요:
{
  "${formatZodiacAgeKey(zodiacAnimal, ageGroups[0].age)}": {
    "summary": "올해 운세 핵심 요약 (20자 내외)",
    "age_context": "${ageGroups[0].age}세, ${ageGroups[0].ageGroup}의 주요 시기",
    "overall_score": 운세 점수 (0-100),
    "description": "${currentYear}년 ${ageGroups[0].age}세 ${zodiacAnimal}띠의 상세 운세 (300자 이상)",
    "career_fortune": "이 나이대의 직업/학업 운세",
    "love_fortune": "이 나이대의 연애/가족 운세",
    "health_fortune": "이 나이대의 건강 운세",
    "financial_fortune": "이 나이대의 재물 운세",
    "lucky_months": ["행운의 달 3개"],
    "caution_months": ["주의할 달 2개"],
    "special_advice": "이 나이대에 특별히 중요한 조언"
  },
  ... (모든 연령대에 대해 작성)
}

중요 지침:
1. 각 연령대의 실제 고민과 상황을 정확히 반영하세요
2. ${currentYear}년의 시대적 상황을 고려하세요 (경제, 취업시장, 사회 트렌드 등)
3. 나이대별로 차별화된 구체적인 조언을 제공하세요
4. 희망적이면서도 현실적인 톤으로 작성하세요
5. 각 운세는 해당 나이대가 실제로 공감할 수 있는 내용이어야 합니다
`;
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    // Parse request
    const { action = 'generate_daily', year = new Date().getFullYear() } = await req.json()

    if (action !== 'generate_daily') {
      return new Response(
        JSON.stringify({ error: 'Invalid action' }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    const currentDate = new Date()
    const results = []
    let totalTokensUsed = 0
    const startTime = Date.now()

    // Generate fortunes for all zodiac animals
    for (const zodiacAnimal of ZODIAC_ANIMALS) {
      try {
        console.log(`Generating age-based fortunes for ${zodiacAnimal}띠...`)
        
        // Check if already exists in cache
        const cacheKey = generateZodiacAgeCacheKey(zodiacAnimal, year, currentDate)
        
        const { data: existing } = await supabase
          .from('system_fortune_cache')
          .select('*')
          .eq('cache_key', cacheKey)
          .gte('expires_at', currentDate.toISOString())
          .single()

        if (existing) {
          console.log(`Cache hit for ${zodiacAnimal}띠`)
          results.push({
            zodiac: zodiacAnimal,
            status: 'cached',
            cache_key: cacheKey
          })
          continue
        }

        // Generate new fortune
        const prompt = generateZodiacAgePrompt(zodiacAnimal, year)
        const fortuneData = await generateFortuneWithAI(prompt, 'zodiac_age_batch')
        const parsedData = JSON.parse(fortuneData)

        // Calculate expiration (24 hours from now)
        const expiresAt = new Date(currentDate)
        expiresAt.setHours(expiresAt.getHours() + 24)

        // Save to cache
        const { error: insertError } = await supabase
          .from('system_fortune_cache')
          .upsert({
            cache_key: cacheKey,
            fortune_type: 'zodiac_age',
            period: 'daily',
            fortune_data: parsedData,
            expires_at: expiresAt.toISOString(),
            hit_count: 0
          })

        if (insertError) {
          console.error(`Error saving ${zodiacAnimal}띠:`, insertError)
          throw insertError
        }

        totalTokensUsed += 100 // Estimate tokens used

        results.push({
          zodiac: zodiacAnimal,
          status: 'generated',
          cache_key: cacheKey,
          age_groups: Object.keys(parsedData).length
        })

      } catch (error) {
        console.error(`Error processing ${zodiacAnimal}띠:`, error)
        results.push({
          zodiac: zodiacAnimal,
          status: 'error',
          error: error.message
        })
      }
    }

    const executionTime = Date.now() - startTime

    // Save statistics
    await supabase
      .from('system_fortune_stats')
      .insert({
        fortune_type: 'zodiac_age',
        period: 'daily',
        types_count: ZODIAC_ANIMALS.length,
        tokens_used: totalTokensUsed,
        generation_time_ms: executionTime
      })

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Daily zodiac age fortunes generated',
        year,
        date: currentDate.toISOString(),
        results,
        stats: {
          total_zodiacs: ZODIAC_ANIMALS.length,
          successful: results.filter(r => r.status !== 'error').length,
          failed: results.filter(r => r.status === 'error').length,
          cached: results.filter(r => r.status === 'cached').length,
          generated: results.filter(r => r.status === 'generated').length,
          execution_time_ms: executionTime,
          tokens_used: totalTokensUsed
        }
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    console.error('Scheduler error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})

// Export function for retrieving age-based zodiac fortune
export async function getZodiacAgeFortune(
  supabase: any,
  zodiacAnimal: ZodiacAnimal,
  age: number,
  currentYear: number
): Promise<any> {
  const cacheKey = generateZodiacAgeCacheKey(zodiacAnimal, currentYear, new Date())
  
  const { data: cached } = await supabase
    .from('system_fortune_cache')
    .select('fortune_data')
    .eq('cache_key', cacheKey)
    .gte('expires_at', new Date().toISOString())
    .single()

  if (cached && cached.fortune_data) {
    const ageKey = formatZodiacAgeKey(zodiacAnimal, age)
    return cached.fortune_data[ageKey] || null
  }

  return null
}