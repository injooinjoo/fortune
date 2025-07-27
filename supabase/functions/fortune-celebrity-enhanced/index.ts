import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser, checkTokenBalance, deductTokens } from '../_shared/auth.ts'
import { FortuneResponse, FORTUNE_TOKEN_COSTS } from '../_shared/types.ts'

const FORTUNE_TYPE = 'celebrity'
const TOKEN_COST = FORTUNE_TOKEN_COSTS[FORTUNE_TYPE]

interface CelebrityFortuneRequest {
  celebrity_id: string
  user_birth_date?: string
  user_birth_time?: string
}

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    // Parse request body
    const body: CelebrityFortuneRequest = await req.json()

    if (!body.celebrity_id) {
      return new Response(
        JSON.stringify({ error: 'celebrity_id is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

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

    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Get today's date
    const today = new Date()
    const todayStr = today.toISOString().split('T')[0]

    // Check user's daily cache first
    const cacheKey = `${FORTUNE_TYPE}_${user!.id}_${body.celebrity_id}_${todayStr}`
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

    // Get pre-generated celebrity fortune for today
    const { data: dailyFortune, error: fortuneError } = await supabase
      .from('celebrity_daily_fortunes')
      .select('fortune_data')
      .eq('celebrity_id', body.celebrity_id)
      .eq('date', todayStr)
      .single()

    if (fortuneError || !dailyFortune) {
      // If no pre-generated fortune, return error
      return new Response(
        JSON.stringify({ 
          error: 'Celebrity fortune not available for today. Please try again later.',
          details: fortuneError?.message
        }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Get celebrity information
    const { data: celebrity, error: celebrityError } = await supabase
      .from('celebrity_profiles')
      .select('*')
      .eq('id', body.celebrity_id)
      .single()

    if (celebrityError || !celebrity) {
      return new Response(
        JSON.stringify({ error: 'Celebrity not found' }),
        { 
          status: 404, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Personalize the fortune if user birth info is provided
    let personalizedFortune = dailyFortune.fortune_data
    if (body.user_birth_date) {
      // Add personalization based on user's birth date
      personalizedFortune = {
        ...dailyFortune.fortune_data,
        personalized: true,
        userCompatibility: calculateCompatibility(celebrity.birth_date, body.user_birth_date)
      }
    }

    // Deduct tokens
    const { success: deductSuccess, error: deductError } = await deductTokens(
      user!.id,
      TOKEN_COST,
      `Celebrity fortune: ${celebrity.name}`
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

    // Cache the result for this user
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: user!.id,
        fortune_type: FORTUNE_TYPE,
        fortune_data: personalizedFortune,
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
      })

    // Save to user's fortune history
    await supabase
      .from('user_celebrity_fortune_history')
      .insert({
        user_id: user!.id,
        celebrity_id: body.celebrity_id,
        fortune_data: personalizedFortune
      })

    // Return response
    const response: FortuneResponse = {
      fortune: {
        ...personalizedFortune,
        generatedAt: new Date().toISOString()
      },
      tokensUsed: TOKEN_COST,
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
    console.error('Celebrity fortune error:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Simple compatibility calculation based on zodiac signs
function calculateCompatibility(celebrityBirthDate: string, userBirthDate: string): number {
  const celebrityZodiac = getZodiacIndex(new Date(celebrityBirthDate))
  const userZodiac = getZodiacIndex(new Date(userBirthDate))
  
  // Simple compatibility matrix (can be expanded)
  const compatibility = [
    [90, 75, 85, 60, 80, 70, 85, 65, 90, 70, 80, 75], // Aries
    [75, 90, 70, 85, 65, 80, 70, 85, 65, 90, 70, 80], // Taurus
    [85, 70, 90, 75, 85, 65, 80, 70, 85, 65, 90, 70], // Gemini
    [60, 85, 75, 90, 70, 85, 65, 80, 70, 85, 65, 90], // Cancer
    [80, 65, 85, 70, 90, 75, 85, 65, 80, 70, 85, 65], // Leo
    [70, 80, 65, 85, 75, 90, 70, 85, 65, 80, 70, 85], // Virgo
    [85, 70, 80, 65, 85, 70, 90, 75, 85, 65, 80, 70], // Libra
    [65, 85, 70, 80, 65, 85, 75, 90, 70, 85, 65, 80], // Scorpio
    [90, 65, 85, 70, 80, 65, 85, 70, 90, 75, 85, 65], // Sagittarius
    [70, 90, 65, 85, 70, 80, 65, 85, 75, 90, 70, 85], // Capricorn
    [80, 70, 90, 65, 85, 70, 80, 65, 85, 70, 90, 75], // Aquarius
    [75, 80, 70, 90, 65, 85, 70, 80, 65, 85, 75, 90], // Pisces
  ]
  
  return compatibility[celebrityZodiac][userZodiac]
}

function getZodiacIndex(date: Date): number {
  const month = date.getMonth() + 1
  const day = date.getDate()
  
  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return 0 // Aries
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return 1 // Taurus
  if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) return 2 // Gemini
  if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return 3 // Cancer
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return 4 // Leo
  if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return 5 // Virgo
  if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return 6 // Libra
  if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) return 7 // Scorpio
  if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) return 8 // Sagittarius
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return 9 // Capricorn
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return 10 // Aquarius
  return 11 // Pisces
}