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
      fortune_type = 'children',
      child_name,
      child_birth_date,
      child_gender,
      parent_relation,
      number_of_children,
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

    // Create prompt based on fortune type
    let prompt = ''
    const today = new Date().toLocaleDateString('ko-KR', { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric',
      weekday: 'long'
    })

    switch (fortune_type) {
      case 'children':
        prompt = `오늘 ${today} ${child_name || '자녀'}의 운세를 알려주세요.`
        if (child_birth_date) {
          const birthDate = new Date(child_birth_date)
          const age = new Date().getFullYear() - birthDate.getFullYear()
          prompt += ` ${age}살`
          
          // Add zodiac animal
          const zodiacAnimals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양']
          const zodiacAnimal = zodiacAnimals[birthDate.getFullYear() % 12]
          prompt += ` ${zodiacAnimal}띠`
        }
        if (child_gender) {
          prompt += child_gender === 'male' ? ' 아들' : ' 딸'
        }
        prompt += `의 하루 운세입니다.

다음 항목들을 포함해주세요:
1. 오늘의 전반적인 운세
2. 건강운 (주의할 점, 좋은 활동)
3. 학업운/놀이운 (연령에 맞게)
4. 친구운 (대인관계)
5. 가족운 (부모와의 관계)
6. 오늘의 행운 아이템
7. 부모님께 드리는 조언`
        break

      case 'parenting':
        prompt = `오늘 ${today} 육아 운세를 알려주세요.`
        if (child_name) prompt += ` ${child_name}와(과)의 하루를 위한 조언입니다.`
        prompt += `

다음 항목들을 포함해주세요:
1. 오늘의 육아 전반운
2. 아이와의 소통운
3. 훈육 타이밍
4. 놀이/교육 활동 추천
5. 부모의 감정 관리
6. 오늘의 육아 팁
7. 주의사항`
        break

      case 'pregnancy':
        prompt = `오늘 ${today} 태교 운세를 알려주세요.`
        if (parent_relation === 'mother') {
          prompt += ` 예비 엄마를 위한 태교 가이드입니다.`
        } else if (parent_relation === 'father') {
          prompt += ` 예비 아빠를 위한 태교 가이드입니다.`
        }
        prompt += `

다음 항목들을 포함해주세요:
1. 오늘의 태교 운세
2. 태아와의 교감 방법
3. 추천 태교 활동 (음악, 독서, 산책 등)
4. 정서적 안정을 위한 조언
5. 영양/건강 관리 팁
6. 배우자와의 관계 조언
7. 오늘의 태교 명상 문구`
        break

      case 'family-harmony':
        prompt = `오늘 ${today} 가족 화합 운세를 알려주세요.`
        if (number_of_children) {
          prompt += ` ${number_of_children}명의 자녀가 있는 가정입니다.`
        }
        prompt += `

다음 항목들을 포함해주세요:
1. 오늘의 가족 전체 운세
2. 가족 간 소통운
3. 갈등 해결의 기회
4. 함께하면 좋은 활동
5. 각 구성원별 역할 조언
6. 가족 화합을 위한 팁
7. 오늘의 가족 행운 아이템`
        break

      default:
        prompt = `오늘 ${today} 자녀 관련 운세를 알려주세요.`
    }

    // Add parent information if available
    if (profile) {
      prompt += `\n\n부모 정보: ${profile.name || '익명'}, ${profile.gender === 'male' ? '아빠' : profile.gender === 'female' ? '엄마' : '부모'}`
      if (profile.birth_date) {
        const birthDate = new Date(profile.birth_date)
        const zodiacAnimals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양']
        const zodiacAnimal = zodiacAnimals[birthDate.getFullYear() % 12]
        prompt += `, ${zodiacAnimal}띠`
      }
    }

    prompt += '\n\n따뜻하고 격려하는 톤으로, 실용적인 조언을 포함해 작성해주세요.'
    prompt += '\n아이의 성장과 가족의 행복을 중심으로 긍정적인 메시지를 전달해주세요.'

    // Generate fortune
    const fortuneContent = await generateFortuneResponse(
      prompt,
      profile,
      supabaseClient,
      fortune_type
    )

    // Save fortune to database
    const { data: fortune, error: saveError } = await supabaseClient
      .from('fortunes')
      .insert({
        user_id: user.id,
        type: fortune_type,
        content: fortuneContent,
        metadata: {
          child_name,
          child_birth_date,
          child_gender,
          parent_relation,
          number_of_children
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
    console.error('Error in fortune-children function:', error)
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