import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser, checkTokenBalance, deductTokens } from '../_shared/auth.ts'
import { generateFortune, getSystemPrompt } from '../_shared/openai.ts'
import { FortuneRequest, FortuneResponse, FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'
import { getZodiacAnimal, formatZodiacAgeKey, generateZodiacAgeCacheKey } from '../_shared/zodiac-utils.ts'

const FORTUNE_TYPE = 'zodiac-animal'
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

    // Check token balance
    const { hasBalance, balance, error: balanceError } = await checkTokenBalance(
      user!.id,
      TOKEN_COST
    )

    if (balanceError) {
      return new Response(
        JSON.stringify({ error: balanceError }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    if (!hasBalance) {
      return new Response(
        JSON.stringify({ 
          error: 'Insufficient token balance',
          required: TOKEN_COST,
          current: balance
        }),
        { 
          status: 402, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )
    
    // First check user-specific cache
    const userCacheKey = `${FORTUNE_TYPE}_${user!.id}_${new Date().toISOString().split('T')[0]}`
    const { data: userCached } = await supabase
      .from('fortune_cache')
      .select('fortune_data')
      .eq('cache_key', userCacheKey)
      .single()

    if (userCached) {
      return new Response(
        JSON.stringify({
          ...userCached.fortune_data,
          cached: true,
          tokensUsed: 0
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }
    
    // Try to get age-based fortune from system cache
    let fortune = null
    let isSystemCached = false
    
    if (body.birthDate) {
      const birthYear = new Date(body.birthDate).getFullYear()
      const currentYear = new Date().getFullYear()
      const age = currentYear - birthYear
      const zodiacAnimal = getZodiacAnimal(birthYear)
      
      // Check system cache for age-based fortune
      const systemCacheKey = generateZodiacAgeCacheKey(zodiacAnimal, currentYear, new Date())
      const { data: systemCached } = await supabase
        .from('system_fortune_cache')
        .select('fortune_data')
        .eq('cache_key', systemCacheKey)
        .gte('expires_at', new Date().toISOString())
        .single()
      
      if (systemCached && systemCached.fortune_data) {
        const ageKey = formatZodiacAgeKey(zodiacAnimal, age)
        const ageFortune = systemCached.fortune_data[ageKey]
        
        if (ageFortune) {
          // Personalize the system fortune with user's name
          fortune = {
            ...ageFortune,
            description: body.name 
              ? ageFortune.description.replace(/당신/g, `${body.name}님`)
              : ageFortune.description,
            personalized: true,
            zodiac_animal: `${zodiacAnimal}띠`,
            birth_year: birthYear,
            current_age: age
          }
          isSystemCached = true
        }
      }
    }
    
    // If no system cache, generate new fortune
    if (!fortune) {
      // Generate fortune
      const systemPrompt = getSystemPrompt(FORTUNE_TYPE)
      fortune = await generateFortune(FORTUNE_TYPE, body, systemPrompt)
    }

    // Only deduct tokens if not using system cache
    if (!isSystemCached) {
      const { success: deductSuccess, error: deductError } = await deductTokens(
        user!.id,
        TOKEN_COST,
        `Zodiac-animal fortune generation`
      )

      if (!deductSuccess) {
        return new Response(
          JSON.stringify({ error: deductError || 'Failed to deduct tokens' }),
          { 
            status: 500, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }
    }

    // Cache the result
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: userCacheKey,
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
        tokens_used: isSystemCached ? 0 : TOKEN_COST
      })

    // Return response
    const response: FortuneResponse = {
      fortune: {
        ...fortune,
        generatedAt: new Date().toISOString()
      },
      tokensUsed: isSystemCached ? 0 : TOKEN_COST,
      generatedAt: new Date().toISOString(),
      systemCached: isSystemCached
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