import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { generateFortuneResponse } from '../_shared/openai.ts'
import { authenticateUser } from '../_shared/auth.ts'
import { corsHeaders } from '../_shared/cors.ts'

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: req.headers.get('Authorization')! },
        },
      }
    )

    // Authenticate user
    const { data: { user }, error: authError } = await authenticateUser(req, supabaseClient)
    if (authError || !user) {
      throw new Error('Authentication failed')
    }

    // Get request data
    const requestData = await req.json()
    const { 
      pet_type = 'general',
      pet_name = '반려동물',
      pet_breed,
      pet_age,
      pet_personality,
      user_profile 
    } = requestData

    // Fetch user profile if not provided
    let profile = user_profile
    if (!profile) {
      const { data: profileData } = await supabaseClient
        .from('user_profiles')
        .select('*')
        .eq('user_id', user.id)
        .single()
      profile = profileData
    }

    // Create prompt based on pet type
    let prompt = ''
    
    if (pet_type === 'dog') {
      prompt = `오늘 ${pet_name}(반려견)의 운세를 알려주세요.`
      if (pet_breed) prompt += ` ${pet_breed} 품종의 특성을 고려해주세요.`
      if (pet_age) prompt += ` ${pet_age}살의 나이를 고려해주세요.`
      if (pet_personality) {
        const personalityMap: Record<string, string> = {
          'active': '활발한',
          'calm': '차분한',
          'timid': '소심한',
          'friendly': '친화적인',
          'independent': '독립적인'
        }
        prompt += ` ${personalityMap[pet_personality] || pet_personality} 성격을 가지고 있습니다.`
      }
      prompt += `

다음 항목들을 포함해주세요:
1. 오늘의 전반적인 운세
2. 건강운 (특히 주의해야 할 점)
3. 산책운 (좋은 산책 시간대와 코스)
4. 사회성운 (다른 강아지들과의 만남)
5. 주인과의 교감운
6. 오늘의 행운의 간식
7. 주의사항`
    } else if (pet_type === 'cat') {
      prompt = `오늘 ${pet_name}(반려묘)의 운세를 알려주세요.`
      if (pet_breed) prompt += ` ${pet_breed} 품종의 특성을 고려해주세요.`
      if (pet_age) prompt += ` ${pet_age}살의 나이를 고려해주세요.`
      if (pet_personality) {
        const personalityMap: Record<string, string> = {
          'active': '활발한',
          'calm': '차분한',
          'timid': '소심한',
          'friendly': '친화적인',
          'independent': '독립적인'
        }
        prompt += ` ${personalityMap[pet_personality] || pet_personality} 성격을 가지고 있습니다.`
      }
      prompt += `

다음 항목들을 포함해주세요:
1. 오늘의 전반적인 운세
2. 건강운 (특히 주의해야 할 점)
3. 놀이운 (좋은 놀이 시간과 활동)
4. 휴식운 (편안한 휴식 장소)
5. 주인과의 교감운
6. 오늘의 행운의 간식
7. 주의사항`
    } else {
      // General pet fortune
      prompt = `오늘 ${pet_name}(반려동물)의 운세를 알려주세요.

다음 항목들을 포함해주세요:
1. 오늘의 전반적인 운세
2. 건강운
3. 활동운
4. 주인과의 교감운
5. 오늘의 행운 아이템
6. 주의사항`
    }

    // Add owner information if available
    if (profile) {
      prompt += `\n\n주인 정보: ${profile.name || '익명'}, ${profile.gender === 'male' ? '남성' : profile.gender === 'female' ? '여성' : '성별 미상'}`
      if (profile.birth_date) {
        const birthDate = new Date(profile.birth_date)
        const zodiacAnimals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양']
        const zodiacAnimal = zodiacAnimals[birthDate.getFullYear() % 12]
        prompt += `, ${zodiacAnimal}띠`
      }
    }

    prompt += '\n\n반려동물과 주인의 관계, 오늘 하루를 함께 보내는 방법에 대한 조언도 포함해주세요.'
    prompt += '\n따뜻하고 애정 어린 톤으로 작성해주세요.'

    // Generate fortune
    const fortuneContent = await generateFortuneResponse(
      prompt,
      profile,
      supabaseClient,
      'pet'
    )

    // Save fortune to database
    const { data: fortune, error: saveError } = await supabaseClient
      .from('fortunes')
      .insert({
        user_id: user.id,
        type: pet_type === 'dog' ? 'pet-dog' : pet_type === 'cat' ? 'pet-cat' : 'pet',
        content: fortuneContent,
        metadata: {
          pet_name,
          pet_type,
          pet_breed,
          pet_age,
          pet_personality
        }
      })
      .select()
      .single()

    if (saveError) {
      console.error('Error saving fortune:', saveError)
      throw saveError
    }

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          id: fortune.id,
          type: fortune.type,
          content: fortuneContent,
          created_at: fortune.created_at,
          metadata: fortune.metadata
        }
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Error in fortune-pet function:', error)
    return new Response(
      JSON.stringify({
        success: false,
        error: error.message || 'Internal server error'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: error.message === 'Authentication failed' ? 401 : 500,
      }
    )
  }
})