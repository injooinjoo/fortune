import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'
import { generateFortuneWithAI } from '../_shared/openai.ts'
import { FortuneRequest, FortuneResponse } from '../_shared/types.ts'
import { getTimeFortuneSystemPrompt, createTimeFortuneUserPrompt } from '../_shared/time-fortune-prompts.ts'

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) return authError

    // Parse request body
    const body: FortuneRequest & { period?: string } = await req.json()
    const period = body.period || 'today' // Default to today

    console.log('Generating time fortune for period:', period)
    console.log('User info:', body)

    // Create cache key based on period
    const dateKey = new Date().toISOString().split('T')[0]
    const cacheKey = `time_${period}_${user!.id}_${dateKey}`
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    // Check cache first
    const { data: cached } = await supabase
      .from('fortune_cache')
      .select('fortune_data')
      .eq('cache_key', cacheKey)
      .single()

    if (cached) {
      console.log('Returning cached fortune for:', cacheKey)
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

    // Generate fortune using AI
    const systemPrompt = getTimeFortuneSystemPrompt(period)
    const userPrompt = createTimeFortuneUserPrompt(period, body)
    
    console.log('Generating new fortune with AI...')
    const fortuneContent = await generateFortuneWithAI(
      `${systemPrompt}\n\n${userPrompt}`,
      'time-fortune'
    )

    // Parse the AI response
    let fortune
    try {
      fortune = JSON.parse(fortuneContent)
    } catch (parseError) {
      console.error('Failed to parse AI response:', parseError)
      throw new Error('Invalid fortune format from AI')
    }

    // Ensure all required fields are present
    const completeForune = {
      greeting: fortune.greeting || `${body.name}님, 안녕하세요!`,
      overallScore: fortune.overallScore || 75,
      summary: fortune.summary || '오늘은 평온한 하루가 될 것입니다.',
      description: fortune.description || '',
      hexagonScores: fortune.hexagonScores || {
        총운: 75,
        학업운: 70,
        재물운: 80,
        건강운: 75,
        연애운: 70,
        사업운: 85
      },
      luckyItems: fortune.luckyItems || {
        color: '파란색',
        number: 7,
        direction: '동쪽',
        time: '오전 10시'
      },
      advice: fortune.advice || '',
      caution: fortune.caution || '',
      timeSpecificFortunes: fortune.timeSpecificFortunes || [],
      birthYearFortunes: fortune.birthYearFortunes || [],
      fiveElements: fortune.fiveElements || null,
      specialTip: fortune.specialTip || '',
      period: period,
      generatedAt: new Date().toISOString()
    }

    // Cache the result
    const cacheExpiry = getCacheExpiry(period)
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: user!.id,
        fortune_type: `time_${period}`,
        fortune_data: { fortune: completeForune },
        expires_at: new Date(Date.now() + cacheExpiry).toISOString()
      })

    // Save to fortune history
    await supabase
      .from('fortunes')
      .insert({
        user_id: user!.id,
        fortune_type: `time_${period}`,
        fortune_data: completeForune,
        tokens_used: 0
      })

    // Return response
    const response: FortuneResponse = {
      fortune: completeForune,
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
      JSON.stringify({ 
        error: 'Internal server error',
        message: error.message || 'Unknown error occurred'
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Get cache expiry time based on period
function getCacheExpiry(period: string): number {
  switch (period) {
    case 'today':
    case 'tomorrow':
      return 24 * 60 * 60 * 1000 // 24 hours
    case 'weekly':
      return 7 * 24 * 60 * 60 * 1000 // 7 days
    case 'monthly':
      return 30 * 24 * 60 * 60 * 1000 // 30 days
    case 'yearly':
      return 365 * 24 * 60 * 60 * 1000 // 365 days
    default:
      return 24 * 60 * 60 * 1000 // Default to 24 hours
  }
}