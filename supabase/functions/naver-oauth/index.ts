/**
 * 네이버 OAuth (Naver OAuth) Edge Function
 *
 * @description 네이버 소셜 로그인을 처리하고 Supabase 사용자를 생성/업데이트합니다.
 *
 * @endpoint POST /naver-oauth
 *
 * @requestBody
 * - access_token: string - 네이버 액세스 토큰 (필수)
 *
 * @response OAuthResponse
 * - user: object - Supabase 사용자 정보
 * - session: object - Supabase 세션 정보
 * - access_token: string - Supabase 액세스 토큰
 * - refresh_token: string - Supabase 리프레시 토큰
 * - naver_user: object - 네이버 사용자 정보
 *   - id: string - 네이버 사용자 ID
 *   - email?: string - 이메일
 *   - nickname?: string - 닉네임
 *   - name?: string - 이름
 *   - gender?: string - 성별
 *   - birthday?: string - 생일
 *   - birthyear?: string - 출생연도
 *   - profile_image?: string - 프로필 이미지
 *
 * @example
 * // Request
 * {
 *   "access_token": "naver_access_token_xxx"
 * }
 *
 * // Response
 * {
 *   "success": true,
 *   "user": { "id": "...", "email": "..." },
 *   "naver_user": { "id": "123", "nickname": "홍길동" }
 * }
 */
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
    const { access_token } = await req.json()
    
    if (!access_token) {
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
        'Authorization': `Bearer ${access_token}`
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
    
    // 이메일이 없는 경우 네이버 ID를 기반으로 생성
    const email = naverUser.email || `naver_${naverUser.id}@zpzg.co.kr`

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
    const { data: { users } } = await supabase.auth.admin.listUsers()
    const existingUser = users?.find(u => u.email === email)

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
        email: email,
        password: `naver_${naverUser.id}_${Math.random().toString(36)}`, // 임시 비밀번호
        email_confirm: true, // 이메일 확인됨으로 설정
        user_metadata: {
          provider: 'naver',
          naver_id: naverUser.id,
          name: naverUser.name || naverUser.nickname,
          nickname: naverUser.nickname,
          email: email,
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
      email: email,
      name: naverUser.name || naverUser.nickname || email.split('@')[0],
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

    // Create a session for the user
    const { data: sessionData, error: sessionError } = await supabase.auth.admin.generateLink({
      type: 'magiclink',
      email: email,
      options: {
        redirectTo: 'com.beyond.fortune://auth-callback'
      }
    })

    if (sessionError) {
      throw sessionError
    }

    // Try to create session directly - wrap in try-catch for safety
    let session = null
    try {
      // Note: createSession might not be available in all Supabase versions
      // Using generateLink as the primary method is more reliable
      if (supabase.auth.admin.createSession) {
        const { data: sessionResult } = await supabase.auth.admin.createSession({
          user_id: user.id
        })
        session = sessionResult?.session
      }
    } catch (sessionError) {
      console.log('Direct session creation not available or failed:', sessionError.message)
      // Continue without session - will use magic link
    }

    // Return response with magic link as primary method, session as bonus if available
    return new Response(
      JSON.stringify({
        success: true,
        user: {
          id: user.id,
          email: email,
          name: naverUser.name || naverUser.nickname,
          profile_image: naverUser.profile_image
        },
        // Session tokens if we managed to create them
        session: session ? {
          access_token: session.access_token,
          refresh_token: session.refresh_token,
          expires_at: session.expires_at,
          expires_in: session.expires_in
        } : null,
        // Magic link URL as reliable fallback
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
