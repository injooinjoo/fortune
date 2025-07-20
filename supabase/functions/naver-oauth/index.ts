import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

interface NaverTokenResponse {
  access_token: string
  refresh_token: string
  token_type: string
  expires_in: number
}

interface NaverUserInfo {
  resultcode: string
  message: string
  response: {
    id: string
    email?: string
    name?: string
    nickname?: string
    profile_image?: string
    age?: string
    gender?: string
    birthday?: string
    birthyear?: string
    mobile?: string
  }
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { accessToken } = await req.json()
    
    if (!accessToken) {
      throw new Error('Access token is required')
    }

    // Get Naver user info
    const userInfoResponse = await fetch('https://openapi.naver.com/v1/nid/me', {
      headers: {
        'Authorization': `Bearer ${accessToken}`,
      },
    })

    if (!userInfoResponse.ok) {
      throw new Error('Failed to get user info from Naver')
    }

    const userInfo: NaverUserInfo = await userInfoResponse.json()
    
    if (userInfo.resultcode !== '00') {
      throw new Error(`Naver API error: ${userInfo.message}`)
    }

    const naverUser = userInfo.response
    
    // Initialize Supabase Admin Client
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    )

    // Check if user exists
    const email = naverUser.email || `${naverUser.id}@naver.local`
    
    const { data: existingUser } = await supabaseAdmin
      .from('user_profiles')
      .select('id')
      .eq('email', email)
      .single()

    let userId: string

    if (existingUser) {
      // User exists, get the user ID
      userId = existingUser.id
    } else {
      // Create new user using Supabase Admin API
      const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
        email,
        email_confirm: true,
        user_metadata: {
          provider: 'naver',
          provider_id: naverUser.id,
          full_name: naverUser.name || naverUser.nickname,
          avatar_url: naverUser.profile_image,
        },
        app_metadata: {
          provider: 'naver',
          providers: ['naver'],
        },
      })

      if (createError) {
        throw createError
      }

      userId = newUser.user.id

      // Create user profile
      const { error: profileError } = await supabaseAdmin
        .from('user_profiles')
        .insert({
          id: userId,
          email,
          name: naverUser.name || naverUser.nickname || email.split('@')[0],
          profile_image_url: naverUser.profile_image,
          primary_provider: 'naver',
          linked_providers: ['naver'],
          created_at: new Date().toISOString(),
          updated_at: new Date().toISOString(),
        })

      if (profileError && !profileError.message.includes('duplicate')) {
        console.error('Profile creation error:', profileError)
      }
    }

    // Generate access token for the user
    const { data: session, error: sessionError } = await supabaseAdmin.auth.admin.generateLink({
      type: 'magiclink',
      email,
      options: {
        redirectTo: `${req.headers.get('origin')}/auth/callback`,
      },
    })

    if (sessionError) {
      throw sessionError
    }

    // Create a session for the user
    const { data: { session: userSession }, error: signInError } = await supabaseAdmin.auth.admin.createSession({
      userId,
    })

    if (signInError) {
      throw signInError
    }

    return new Response(
      JSON.stringify({
        access_token: userSession.access_token,
        refresh_token: userSession.refresh_token,
        expires_in: userSession.expires_in,
        token_type: 'bearer',
        user: userSession.user,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )
  } catch (error) {
    console.error('Naver OAuth error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})