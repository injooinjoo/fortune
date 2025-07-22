import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'
import { generateFortuneWithAI } from '../_shared/openai.ts'
import { FortuneRequest, FortuneResponse } from '../_shared/types.ts'
import { getTimeFortuneSystemPrompt, createTimeFortuneUserPrompt } from '../_shared/time-fortune-prompts.ts'

serve(async (req: Request) => {
  console.log('=== FORTUNE-TIME EDGE FUNCTION START ===')
  console.log('Timestamp:', new Date().toISOString())
  console.log('Request method:', req.method)
  console.log('Request headers:', Object.fromEntries(req.headers.entries()))
  
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) {
    console.log('Returning CORS response')
    return corsResponse
  }

  try {
    // Authenticate user
    console.log('Authenticating user...')
    const { user, error: authError } = await authenticateUser(req)
    if (authError) {
      console.error('Authentication failed:', authError)
      return authError
    }
    console.log('User authenticated:', user?.id)

    // Parse request body
    console.log('Parsing request body...')
    const body: FortuneRequest & { period?: string } = await req.json()
    const period = body.period || 'today' // Default to today

    console.log('=== REQUEST DETAILS ===')
    console.log('Period:', period)
    console.log('User ID:', body.userId)
    console.log('User name:', body.name)
    console.log('Birth date:', body.birthDate)
    console.log('MBTI:', body.mbtiType)
    console.log('Zodiac:', body.zodiacSign)
    console.log('Full request body:', JSON.stringify(body, null, 2))

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
    
    console.log('=== AI PROMPT DETAILS ===')
    console.log('System prompt length:', systemPrompt.length)
    console.log('User prompt length:', userPrompt.length)
    console.log('Total prompt length:', systemPrompt.length + userPrompt.length)
    console.log('System prompt preview:', systemPrompt.substring(0, 300) + '...')
    console.log('User prompt preview:', userPrompt.substring(0, 300) + '...')
    
    console.log('Generating new fortune with AI...')
    let fortuneContent
    try {
      fortuneContent = await generateFortuneWithAI(
        `${systemPrompt}\n\n${userPrompt}`,
        'time-fortune'
      )
      console.log('AI generation successful')
      console.log('Response length:', fortuneContent.length)
      console.log('Response preview:', fortuneContent.substring(0, 200) + '...')
    } catch (aiError) {
      console.error('AI generation failed:', aiError)
      console.error('AI error details:', {
        error: aiError.message,
        stack: aiError.stack,
        systemPromptLength: systemPrompt.length,
        userPromptLength: userPrompt.length
      })
      throw new Error(`AI fortune generation failed: ${aiError.message}`)
    }

    // Parse the AI response with retry logic
    let fortune
    let parseAttempts = 0
    const maxParseAttempts = 3
    
    while (parseAttempts < maxParseAttempts) {
      try {
        console.log(`=== JSON PARSING (Attempt ${parseAttempts + 1}/${maxParseAttempts}) ===`)
        console.log('Attempting to parse AI response...')
        console.log('Raw content type:', typeof fortuneContent)
        console.log('First 100 chars:', fortuneContent.substring(0, 100))
        console.log('Last 100 chars:', fortuneContent.substring(fortuneContent.length - 100))
        
        // Check for common JSON issues
        const trimmedContent = fortuneContent.trim()
        if (!trimmedContent.startsWith('{') || !trimmedContent.endsWith('}')) {
          console.error('Response does not look like valid JSON')
          console.error('Starts with:', trimmedContent.substring(0, 10))
          console.error('Ends with:', trimmedContent.substring(trimmedContent.length - 10))
        }
        
        // Check for unterminated strings by counting quotes
        const quoteCount = (trimmedContent.match(/"/g) || []).length
        console.log('Quote count in response:', quoteCount)
        if (quoteCount % 2 !== 0) {
          console.error('Odd number of quotes detected - likely unterminated string')
        }
        
        // Attempt to parse, with sanitization on retry
        if (parseAttempts > 0) {
          console.log('Applying JSON sanitization...')
          fortuneContent = sanitizeJsonString(fortuneContent)
        }
        
        fortune = JSON.parse(fortuneContent)
        console.log('AI response parsed successfully')
        console.log('Parsed fortune keys:', Object.keys(fortune))
        break // Success, exit loop
        
      } catch (parseError) {
        parseAttempts++
        console.error(`=== JSON PARSE ERROR (Attempt ${parseAttempts}/${maxParseAttempts}) ===`)
        console.error('Parse error:', parseError.message)
        console.error('Error type:', parseError.name)
        console.error('Raw AI response length:', fortuneContent.length)
        console.error('First 500 chars:', fortuneContent.substring(0, 500))
        console.error('Last 500 chars:', fortuneContent.substring(fortuneContent.length - 500))
        
        // Try to find the error position
        if (parseError.message.includes('position')) {
          const match = parseError.message.match(/position (\d+)/)
          if (match) {
            const errorPos = parseInt(match[1])
            console.error('Error position:', errorPos)
            console.error('Content around error:', fortuneContent.substring(Math.max(0, errorPos - 50), errorPos + 50))
          }
        }
        
        if (parseAttempts >= maxParseAttempts) {
          console.error('Max parse attempts reached. Giving up.')
          throw new Error(`Invalid fortune format from AI after ${maxParseAttempts} attempts: ${parseError.message}`)
        }
        
        console.log(`Will retry with sanitization...`)
      }
    }

    // Ensure all required fields are present
    console.log('=== FORTUNE VALIDATION ===')
    console.log('Validating and completing fortune fields...')
    
    const completeFortune = {
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
    
    console.log('Fortune validated. Keys:', Object.keys(completeFortune))
    console.log('HexagonScores:', completeFortune.hexagonScores)
    console.log('TimeSpecificFortunes count:', completeFortune.timeSpecificFortunes.length)

    // Cache the result
    const cacheExpiry = getCacheExpiry(period)
    await supabase
      .from('fortune_cache')
      .upsert({
        cache_key: cacheKey,
        user_id: user!.id,
        fortune_type: `time_${period}`,
        fortune_data: { fortune: completeFortune },
        expires_at: new Date(Date.now() + cacheExpiry).toISOString()
      })

    // Save to fortune history
    await supabase
      .from('fortunes')
      .insert({
        user_id: user!.id,
        fortune_type: `time_${period}`,
        fortune_data: completeFortune,
        tokens_used: 0
      })

    // Return response
    const response: FortuneResponse = {
      fortune: completeFortune,
      tokensUsed: 0,
      generatedAt: new Date().toISOString()
    }
    
    console.log('=== FORTUNE GENERATION SUCCESS ===')
    console.log('Response fortune keys:', Object.keys(response.fortune))
    console.log('Returning response to client')

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('=== FORTUNE GENERATION ERROR ===')
    console.error('Error type:', error.constructor.name)
    console.error('Error message:', error.message)
    console.error('Error stack:', error.stack)
    console.error('Timestamp:', new Date().toISOString())
    
    // Log specific error context
    if (error.message.includes('AI')) {
      console.error('This is an AI-related error')
    } else if (error.message.includes('JSON')) {
      console.error('This is a JSON parsing error')
    } else if (error.message.includes('auth')) {
      console.error('This is an authentication error')
    }
    
    return new Response(
      JSON.stringify({ 
        error: 'Internal server error',
        message: error.message || 'Unknown error occurred',
        timestamp: new Date().toISOString()
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Sanitize JSON string to fix common formatting issues
function sanitizeJsonString(jsonString: string): string {
  console.log('Sanitizing JSON string...')
  
  // Remove any trailing commas before closing braces/brackets
  let sanitized = jsonString.replace(/,\s*([\]}])/g, '$1')
  
  // Fix escaped quotes that might be causing issues
  sanitized = sanitized.replace(/\\"/g, '"')
  
  // Remove any null bytes or control characters
  sanitized = sanitized.replace(/[\x00-\x1F\x7F]/g, '')
  
  // Ensure proper quote matching by escaping unescaped quotes within strings
  // This is a simple approach - for production, use a proper JSON parser
  
  console.log('JSON sanitization complete')
  return sanitized
}

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