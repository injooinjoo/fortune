import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'
import { generateFortune, getSystemPrompt } from '../_shared/openai.ts'
import { FortuneRequest, FortuneResponse, FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'
import { redisRateLimiters, applyRateLimitHeaders } from '../_shared/redis-rate-limit.ts'
import { checkExistingFortune, getDateRange, CACHE_DURATIONS } from '../_shared/fortune-cache.ts'

const FORTUNE_TYPE = 'daily'
const TOKEN_COST = FORTUNE_TOKEN_COSTS[FORTUNE_TYPE]

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Apply rate limiting
    const rateLimitResponse = await redisRateLimiters.fortune.createMiddleware()(req)
    if (rateLimitResponse) return rateLimitResponse

    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return applyRateLimitHeaders(req, authError)

    // Parse request body
    const body: FortuneRequest = await req.json()

    // Check existing fortune (cache + database)
    const existingCheck = await checkExistingFortune(
      user!.id,
      FORTUNE_TYPE,
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    if (existingCheck.found) {
      const response = new Response(
        JSON.stringify({
          ...existingCheck.data,
          cached: true,
          source: existingCheck.source,
          tokensUsed: 0
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
      return applyRateLimitHeaders(req, response)
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Check token balance
    const { data: tokenData, error: tokenError } = await supabase
      .from('user_tokens')
      .select('balance')
      .eq('user_id', user!.id)
      .single()

    if (tokenError || !tokenData) {
      const response = new Response(
        JSON.stringify({ error: 'Failed to check token balance' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
      return applyRateLimitHeaders(req, response)
    }

    if (tokenData.balance < TOKEN_COST) {
      const response = new Response(
        JSON.stringify({ 
          error: 'Insufficient tokens', 
          required: TOKEN_COST, 
          current: tokenData.balance 
        }),
        { status: 402, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
      return applyRateLimitHeaders(req, response)
    }

    // Generate fortune
    const systemPrompt = getSystemPrompt(FORTUNE_TYPE, body)
    const fortune = await generateFortune(systemPrompt, FORTUNE_TYPE, body)

    // Deduct tokens
    const { error: deductError } = await supabase
      .from('user_tokens')
      .update({ 
        balance: tokenData.balance - TOKEN_COST,
        updated_at: new Date().toISOString()
      })
      .eq('user_id', user!.id)

    if (deductError) {
      console.error('Failed to deduct tokens:', deductError)
    }

    // Record transaction
    await supabase
      .from('token_transactions')
      .insert({
        user_id: user!.id,
        amount: -TOKEN_COST,
        type: 'fortune_generation',
        description: `Generated ${FORTUNE_TYPE} fortune`,
        metadata: { fortune_type: FORTUNE_TYPE }
      })

    // Cache the result
    const { start } = getDateRange(FORTUNE_TYPE)
    const cacheKey = `${FORTUNE_TYPE}_${user!.id}_${start.toISOString().split('T')[0]}`
    const cacheDuration = CACHE_DURATIONS[FORTUNE_TYPE] || CACHE_DURATIONS.default
    
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: fortune,
        created_at: new Date().toISOString(),
        expires_at: new Date(Date.now() + cacheDuration).toISOString()
      })

    // Save to fortunes table
    await supabase
      .from('fortunes')
      .insert({
        user_id: user!.id,
        type: FORTUNE_TYPE,
        content: fortune,
        tokens_used: TOKEN_COST,
        metadata: body
      })

    const response: FortuneResponse = {
      ...fortune,
      tokensUsed: TOKEN_COST,
      remainingTokens: tokenData.balance - TOKEN_COST,
      cached: false
    }

    const httpResponse = new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
    return applyRateLimitHeaders(req, httpResponse)
  } catch (error) {
    console.error('Error in daily fortune function:', error)
    const response = new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
    return applyRateLimitHeaders(req, response)
  }
})