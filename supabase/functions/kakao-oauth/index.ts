/**
 * 카카오 OAuth (Kakao OAuth) Edge Function
 *
 * @description 카카오 소셜 로그인을 처리하고 Supabase 사용자를 생성/업데이트합니다.
 *              클라이언트가 전달한 access_token을 Kakao `/v2/user/me`에 재검증하여
 *              body로 전달된 user_info(= impersonation 소스)를 신뢰하지 않는다.
 *
 * @endpoint POST /kakao-oauth
 *
 * @requestBody
 * - access_token: string - 카카오 액세스 토큰 (필수, 서버가 Kakao API로 검증)
 * - refresh_token?: string - (옵션, 현재는 저장하지 않음)
 * - user_info?: object - (deprecated, 서버는 무시하고 Kakao 응답만 신뢰)
 *
 * @response OAuthResponse
 * - user: object - Supabase 사용자 정보
 * - session: object - Supabase 세션 정보
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const KAKAO_USER_API = 'https://kapi.kakao.com/v2/user/me'

interface VerifiedKakaoUser {
  id: string
  email: string
  nickname: string | null
  profileImageUrl: string | null
}

/**
 * Kakao access_token을 Kakao `/v2/user/me`에 재제시하여 토큰과 사용자 identity를
 * 서버-측에서 검증한다. body.user_info 는 절대 신뢰하지 않는다.
 *
 * 실패 시 null. 성공 시 Kakao가 반환한 검증된 필드만 사용.
 */
async function fetchKakaoUser(accessToken: string): Promise<VerifiedKakaoUser | null> {
  const response = await fetch(KAKAO_USER_API, {
    method: 'GET',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/x-www-form-urlencoded;charset=utf-8',
    },
  })

  if (!response.ok) {
    console.error('[kakao-oauth] Kakao token verification failed:', response.status)
    return null
  }

  let payload: Record<string, unknown>
  try {
    payload = await response.json()
  } catch (e) {
    console.error('[kakao-oauth] Failed to parse Kakao user payload:', e)
    return null
  }

  const rawId = payload.id
  if (rawId === null || rawId === undefined) {
    console.error('[kakao-oauth] Kakao payload missing id')
    return null
  }
  const id = String(rawId)

  const kakaoAccount = (payload.kakao_account as Record<string, unknown> | undefined) ?? {}
  const profile = (kakaoAccount.profile as Record<string, unknown> | undefined) ?? {}
  const properties = (payload.properties as Record<string, unknown> | undefined) ?? {}

  const verifiedEmail = typeof kakaoAccount.email === 'string' && kakaoAccount.email.length > 0
    ? kakaoAccount.email
    : null
  // email 미동의/미보유 시 stable fallback (legacy 호환 유지)
  const email = verifiedEmail ?? `kakao_${id}@kakao.local`

  const nickname =
    (typeof profile.nickname === 'string' && profile.nickname) ||
    (typeof properties.nickname === 'string' && properties.nickname) ||
    null

  const profileImageUrl =
    (typeof profile.profile_image_url === 'string' && profile.profile_image_url) ||
    (typeof properties.profile_image === 'string' && properties.profile_image) ||
    null

  return {
    id,
    email,
    nickname,
    profileImageUrl,
  }
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  try {
    const body = await req.json()
    const { access_token } = body

    if (!access_token || typeof access_token !== 'string') {
      return new Response(
        JSON.stringify({ error: '카카오 인증 정보가 없습니다.' }),
        {
          status: 400,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
    }

    // SECURITY: body.user_info 는 절대 신뢰하지 않는다. Kakao API 로 토큰 검증하여
    // 서버가 직접 identity 를 확정.
    const kakaoUser = await fetchKakaoUser(access_token)

    if (!kakaoUser) {
      return new Response(
        JSON.stringify({ error: '카카오 인증에 실패했습니다.' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' }
        }
      )
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
    const { data: listUsersData, error: userError } = await supabase.auth.admin.listUsers()
    if (userError) {
      throw userError
    }
    const existingUser = listUsersData?.users?.find(u => u.email === kakaoUser.email) || null

    // Existing user 의 linked_providers 를 merge하여 Apple/Naver 등 이전 provider
    // 연결을 지우지 않도록 한다 (naver-oauth 패턴과 정렬).
    const existingLinkedProviders = Array.isArray(existingUser?.user_metadata?.linked_providers)
      ? (existingUser?.user_metadata?.linked_providers as string[])
      : []
    const linkedProviders = Array.from(new Set([...existingLinkedProviders, 'kakao']))

    let user
    if (existingUser) {
      user = existingUser

      // 메타데이터 업데이트 — Kakao 검증된 필드만 사용, primary_provider 는 보존
      await supabase.auth.admin.updateUserById(user.id, {
        user_metadata: {
          ...user.user_metadata,
          provider: 'kakao',
          primary_provider: user.user_metadata?.primary_provider || 'kakao',
          linked_providers: linkedProviders,
          kakao_id: kakaoUser.id,
          name: kakaoUser.nickname || user.user_metadata?.name,
          nickname: kakaoUser.nickname || user.user_metadata?.nickname,
          profile_image: kakaoUser.profileImageUrl || user.user_metadata?.profile_image,
          email: kakaoUser.email,
        }
      })
    } else {
      // 새 사용자 생성
      const { data: newUser, error: createError } = await supabase.auth.admin.createUser({
        email: kakaoUser.email,
        password: `kakao_${kakaoUser.id}_${crypto.randomUUID()}`,
        email_confirm: true,
        user_metadata: {
          provider: 'kakao',
          primary_provider: 'kakao',
          linked_providers: ['kakao'],
          kakao_id: kakaoUser.id,
          name: kakaoUser.nickname || kakaoUser.email.split('@')[0],
          nickname: kakaoUser.nickname,
          email: kakaoUser.email,
          profile_image: kakaoUser.profileImageUrl,
        }
      })

      if (createError) {
        throw createError
      }

      user = newUser.user
    }

    if (!user) {
      throw new Error('Failed to resolve Kakao user in Supabase')
    }

    // 사용자 프로필 정보 업데이트 (user_profiles 테이블) — linked_providers +
    // primary_provider + created_at 기존 값 보존.
    const { data: existingProfile } = await supabase
      .from('user_profiles')
      .select('created_at, linked_providers, primary_provider')
      .eq('id', user.id)
      .maybeSingle()

    const existingProfileProviders = Array.isArray(existingProfile?.linked_providers)
      ? (existingProfile?.linked_providers as string[])
      : []
    const profileLinkedProviders = Array.from(new Set([...existingProfileProviders, 'kakao']))

    const profileData = {
      id: user.id,
      email: kakaoUser.email,
      name: kakaoUser.nickname || kakaoUser.email.split('@')[0],
      profile_image_url: kakaoUser.profileImageUrl,
      primary_provider: existingProfile?.primary_provider || 'kakao',
      linked_providers: profileLinkedProviders,
      created_at: existingProfile?.created_at || new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    await supabase.from('user_profiles').upsert(profileData, {
      onConflict: 'id'
    })

    // Admin API를 사용하여 매직 링크 생성 후 OTP 검증으로 세션 생성
    try {
      const { data: magicLink, error: linkError } = await supabase.auth.admin.generateLink({
        type: 'magiclink',
        email: kakaoUser.email,
        options: {
          redirectTo: 'io.supabase.flutter://login-callback'
        }
      })

      if (linkError) {
        console.error('[kakao-oauth] Failed to generate magic link:', linkError)
        throw linkError
      }

      if (magicLink?.properties?.hashed_token) {
        const { data: verifyData, error: verifyError } = await supabase.auth.verifyOtp({
          token_hash: magicLink.properties.hashed_token,
          type: 'email'
        })

        if (!verifyError && verifyData?.session) {
          return new Response(
            JSON.stringify({
              success: true,
              user: {
                id: user.id,
                email: kakaoUser.email,
                name: kakaoUser.nickname,
                profile_image: kakaoUser.profileImageUrl
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
      console.error('[kakao-oauth] Failed to create session:', sessionError)
    }

    // 세션 생성 실패 시 사용자 정보만 반환
    return new Response(
      JSON.stringify({
        success: true,
        user: {
          id: user.id,
          email: kakaoUser.email,
          name: kakaoUser.nickname,
          profile_image: kakaoUser.profileImageUrl
        },
        needsManualAuth: true
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('[kakao-oauth] error:', error)
    return new Response(
      JSON.stringify({
        // 클라이언트에 상세 원인 leak 방지
        error: '카카오 로그인 처리 중 문제가 발생했습니다.'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})
