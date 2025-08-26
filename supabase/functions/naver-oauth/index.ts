import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface NaverUserResponse {
  resultcode: string
  message: string
  response: {
    id: string
    nickname?: string
    name?: string
    email?: string
    gender?: string
    age?: string
    birthday?: string
    profile_image?: string
    birthyear?: string
    mobile?: string
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  try {
    const { accessToken } = await req.json()
    
    if (!accessToken) {
      return new Response(
        JSON.stringify({ error: 'Access token is required' }),
        { 
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // 네이버 API에서 사용자 정보 가져오기
    const naverResponse = await fetch('https://openapi.naver.com/v1/nid/me', {
      headers: {
        'Authorization': `Bearer ${accessToken}`
      }
    })

    if (!naverResponse.ok) {
      throw new Error(`Naver API error: ${naverResponse.status}`)
    }

    const naverData: NaverUserResponse = await naverResponse.json()
    
    if (naverData.resultcode !== "00") {
      throw new Error(`Naver API failed: ${naverData.message}`)
    }

    const naverUser = naverData.response
    
    if (!naverUser.email) {
      throw new Error('Naver account does not have an email address')
    }

    // Supabase 클라이언트 생성
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })

    // 사용자 존재 여부 확인
    const { data: existingUser } = await supabase.auth.admin.getUserByEmail(naverUser.email)
    
    let user
    if (existingUser) {
      // 기존 사용자 업데이트
      user = existingUser
      
      // 메타데이터 업데이트
      await supabase.auth.admin.updateUserById(user.id, {
        user_metadata: {
          ...user.user_metadata,
          provider: 'naver',
          naver_id: naverUser.id,
          name: naverUser.name || naverUser.nickname || user.user_metadata.name,
          nickname: naverUser.nickname || user.user_metadata.nickname,
          profile_image: naverUser.profile_image || user.user_metadata.profile_image,
        }
      })
    } else {
      // 새 사용자 생성
      const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
        email: naverUser.email,
        password: `naver_${naverUser.id}_${Math.random().toString(36)}`, // 임시 비밀번호
        email_confirm: true, // 이메일 확인됨으로 설정
        user_metadata: {
          provider: 'naver',
          naver_id: naverUser.id,
          name: naverUser.name || naverUser.nickname,
          nickname: naverUser.nickname,
          email: naverUser.email,
          profile_image: naverUser.profile_image,
        }
      })

      if (createError) {
        throw createError
      }
      
      user = newUser
    }

    // 사용자 프로필 정보 업데이트 (user_profiles 테이블)
    const profileData = {
      id: user.id,
      email: naverUser.email,
      name: naverUser.name || naverUser.nickname || naverUser.email.split('@')[0],
      profile_image_url: naverUser.profile_image,
      primary_provider: 'naver',
      linked_providers: ['naver'],
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    // Upsert 프로필 정보
    await supabase.from('user_profiles').upsert(profileData, {
      onConflict: 'id'
    })

    // Access Token 및 Refresh Token 생성
    const { data: sessionData, error: sessionError } = await supabase.auth.admin.generateLink({
      type: 'magiclink',
      email: naverUser.email,
      options: {
        redirectTo: 'com.beyond.fortune://auth-callback'
      }
    })

    if (sessionError) {
      throw sessionError
    }

    return new Response(
      JSON.stringify({
        success: true,
        user: {
          id: user.id,
          email: naverUser.email,
          name: naverUser.name || naverUser.nickname,
          profile_image: naverUser.profile_image
        },
        session_url: sessionData.properties?.action_link
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Naver OAuth error:', error)
    return new Response(
      JSON.stringify({ 
        error: error.message || 'Internal server error',
        details: error.toString()
      }),
      { 
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})