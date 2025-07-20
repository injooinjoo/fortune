import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'
import { generateFortune, getSystemPrompt } from '../_shared/openai.ts'
import { FortuneRequest, FortuneResponse, FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'

const FORTUNE_TYPE = 'daily'
const TOKEN_COST = FORTUNE_TOKEN_COSTS[FORTUNE_TYPE]

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    // Parse request body
    const body: FortuneRequest = await req.json()


    // Check cache first
    const cacheKey = `${FORTUNE_TYPE}_${user!.id}_${new Date().toISOString().split('T')[0]}`
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { data: cached } = await supabase
      .from('fortune_cache')
      .select('fortune_data')
      .eq('cache_key', cacheKey)
      .single()

    if (cached) {
      return new Response(
        JSON.stringify({
          ...cached.fortune_data,
          cached: true,
          tokensUsed: 0
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Generate fortune
    const systemPrompt = getSystemPrompt(FORTUNE_TYPE)
    const fortune = await generateFortune(FORTUNE_TYPE, body, systemPrompt)


    // Cache the result
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: { fortune },
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      })

    // Save to fortune history
    await supabase
      .from('fortunes')
      .insert({
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: fortune,
        tokens_used: 0
      })

    // Return response
    const response: FortuneResponse = {
      fortune: {
        ...fortune,
        generatedAt: new Date().toISOString()
      },
      tokensUsed: 0,
      generatedAt: new Date().toISOString()
    }

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Fortune generation error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})