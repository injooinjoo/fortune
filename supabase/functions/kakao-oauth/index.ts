import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface KakaoUserInfo {
  id: string
  email: string
  nickname?: string
  profile_image_url?: string
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    const { access_token, refresh_token, user_info } = body
    
    if (!access_token || !user_info) {
      return new Response(
        JSON.stringify({ error: 'Access token and user info are required' }),
        { 
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    const kakaoUser: KakaoUserInfo = user_info
    
    // Kakao 계정에 이메일이 없는 경우 대체 이메일 생성
    if (!kakaoUser.email) {
      kakaoUser.email = `kakao_${kakaoUser.id}@kakao.local`
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
    const { data: { users }, error: userError } = await supabase.auth.admin.listUsers()
    const existingUser = users?.find(u => u.email === kakaoUser.email) || null
    
    let user
    if (existingUser) {
      // 기존 사용자 업데이트
      user = existingUser
      
      // 메타데이터 업데이트
      await supabase.auth.admin.updateUserById(user.id, {
        user_metadata: {
          ...user.user_metadata,
          provider: 'kakao',
          kakao_id: kakaoUser.id,
          name: kakaoUser.nickname || user.user_metadata.name,
          nickname: kakaoUser.nickname || user.user_metadata.nickname,
          profile_image: kakaoUser.profile_image_url || user.user_metadata.profile_image,
          email: kakaoUser.email,
        }
      })
    } else {
      // 새 사용자 생성
      const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
        email: kakaoUser.email,
        password: `kakao_${kakaoUser.id}_${Math.random().toString(36)}`, // 임시 비밀번호
        email_confirm: true, // 이메일 확인됨으로 설정
        user_metadata: {
          provider: 'kakao',
          kakao_id: kakaoUser.id,
          name: kakaoUser.nickname || kakaoUser.email.split('@')[0],
          nickname: kakaoUser.nickname,
          email: kakaoUser.email,
          profile_image: kakaoUser.profile_image_url,
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
      email: kakaoUser.email,
      name: kakaoUser.nickname || kakaoUser.email.split('@')[0],
      profile_image_url: kakaoUser.profile_image_url,
      primary_provider: 'kakao',
      linked_providers: ['kakao'],
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    // Upsert 프로필 정보
    await supabase.from('user_profiles').upsert(profileData, {
      onConflict: 'id'
    })

    // Admin API를 사용하여 매직 링크 생성 후 세션 생성
    try {
      const { data: magicLink, error: linkError } = await supabase.auth.admin.generateLink({
        type: 'magiclink',
        email: kakaoUser.email,
        options: {
          redirectTo: 'com.beyond.fortune://auth-callback'
        }
      })

      if (linkError) {
        console.error('Failed to generate magic link:', linkError)
        throw linkError
      }

      // 매직 링크에서 토큰 추출하여 OTP 검증으로 세션 생성
      if (magicLink?.properties?.hashed_token) {
        const { data: verifyData, error: verifyError } = await supabase.auth.verifyOtp({
          token_hash: magicLink.properties.hashed_token,
          type: 'email'
        })

        if (!verifyError && verifyData?.session) {
          // 세션이 성공적으로 생성됨
          return new Response(
            JSON.stringify({
              success: true,
              user: {
                id: user.id,
                email: kakaoUser.email,
                name: kakaoUser.nickname,
                profile_image: kakaoUser.profile_image_url
              },
              session: {
                access_token: verifyData.session.access_token,
                refresh_token: verifyData.session.refresh_token,
                expires_in: verifyData.session.expires_in,
                token_type: verifyData.session.token_type
              }
            }),
            {
              status: 200,
              headers: { ...corsHeaders, 'Content-Type': 'application/json' }
            }
          )
        }
      }
    } catch (sessionError) {
      console.error('Failed to create session:', sessionError)
    }

    // 세션 생성 실패 시 사용자 정보만 반환
    return new Response(
      JSON.stringify({
        success: true,
        user: {
          id: user.id,
          email: kakaoUser.email,
          name: kakaoUser.nickname,
          profile_image: kakaoUser.profile_image_url
        },
        needsManualAuth: true
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('Kakao OAuth error:', error)
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