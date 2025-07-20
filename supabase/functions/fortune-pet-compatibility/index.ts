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
      owner_name,
      owner_birth_date,
      owner_zodiac_animal,
      pet_type = 'dog',
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

    // Calculate zodiac animal if birth date is provided but zodiac animal is not
    let zodiacAnimal = owner_zodiac_animal
    if (owner_birth_date && !zodiacAnimal) {
      const birthDate = new Date(owner_birth_date)
      const zodiacAnimals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양']
      zodiacAnimal = zodiacAnimals[birthDate.getFullYear() % 12]
    }

    // Use profile data if owner info not provided
    const ownerInfo = {
      name: owner_name || profile?.name || '주인',
      zodiacAnimal: zodiacAnimal || (profile?.birth_date ? (() => {
        const birthDate = new Date(profile.birth_date)
        const zodiacAnimals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양']
        return zodiacAnimals[birthDate.getFullYear() % 12]
      })() : null)
    }

    // Create compatibility analysis prompt
    let prompt = `${ownerInfo.name}님과 ${pet_name}(${pet_type === 'dog' ? '반려견' : pet_type === 'cat' ? '반려묘' : '반려동물'})의 궁합을 분석해주세요.`

    // Add owner information
    if (ownerInfo.zodiacAnimal) {
      prompt += `\n주인: ${ownerInfo.zodiacAnimal}띠`
    }

    // Add pet information
    prompt += `\n반려동물: ${pet_name}`
    if (pet_type) {
      const petTypeMap: Record<string, string> = {
        'dog': '강아지',
        'cat': '고양이',
        'other': '반려동물'
      }
      prompt += ` (${petTypeMap[pet_type] || pet_type})`
    }
    if (pet_breed) prompt += `, ${pet_breed}`
    if (pet_age) prompt += `, ${pet_age}살`
    if (pet_personality) {
      const personalityMap: Record<string, string> = {
        'active': '활발한',
        'calm': '차분한',
        'timid': '소심한',
        'friendly': '친화적인',
        'independent': '독립적인'
      }
      prompt += `, ${personalityMap[pet_personality] || pet_personality} 성격`
    }

    prompt += `

다음 항목들을 포함해 상세히 분석해주세요:

1. 전체 궁합 점수 (100점 만점)
2. 성격 궁합
3. 생활 패턴 궁합
4. 정서적 교감도
5. 서로에게 주는 긍정적 영향
6. 주의해야 할 점
7. 관계 발전을 위한 조언
8. 오늘의 특별 활동 추천`

    // Add specific analysis based on zodiac compatibility if available
    if (ownerInfo.zodiacAnimal) {
      prompt += `\n\n${ownerInfo.zodiacAnimal}띠의 특성을 고려하여 반려동물과의 궁합을 분석해주세요.`
      
      // Add zodiac-specific insights
      const zodiacTraits: Record<string, string> = {
        '쥐': '영리하고 적응력이 뛰어난',
        '소': '인내심이 강하고 신중한',
        '호랑이': '용감하고 독립적인',
        '토끼': '온화하고 섬세한',
        '용': '카리스마 있고 열정적인',
        '뱀': '지혜롭고 직관적인',
        '말': '자유롭고 활동적인',
        '양': '예술적이고 온순한',
        '원숭이': '재치 있고 호기심 많은',
        '닭': '부지런하고 정확한',
        '개': '충성스럽고 정직한',
        '돼지': '너그럽고 정이 많은'
      }
      
      if (zodiacTraits[ownerInfo.zodiacAnimal.replace('띠', '')]) {
        prompt += `\n${zodiacTraits[ownerInfo.zodiacAnimal.replace('띠', '')]} ${ownerInfo.zodiacAnimal} 주인의 성격 특성을 반영해주세요.`
      }
    }

    prompt += '\n\n따뜻하고 긍정적인 톤으로, 실용적인 조언을 포함해 작성해주세요.'
    prompt += '\n주인과 반려동물 모두의 행복을 위한 구체적인 제안을 해주세요.'

    // Generate fortune
    const fortuneContent = await generateFortuneResponse(
      prompt,
      profile,
      supabaseClient,
      'pet-compatibility'
    )

    // Save fortune to database
    const { data: fortune, error: saveError } = await supabaseClient
      .from('fortunes')
      .insert({
        user_id: user.id,
        type: 'pet-compatibility',
        content: fortuneContent,
        metadata: {
          owner_name: ownerInfo.name,
          owner_zodiac_animal: ownerInfo.zodiacAnimal,
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
    console.error('Error in fortune-pet-compatibility function:', error)
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