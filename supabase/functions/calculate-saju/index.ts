import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders, handleCors } from '../_shared/cors.ts'
import { authenticateUser } from '../_shared/auth.ts'
import { generateFortuneWithAI } from '../_shared/openai.ts'

interface SajuRequest {
  birthDate: string
  birthTime?: string
  isLunar?: boolean
  timezone?: string
}

interface SajuPillar {
  stem: string
  branch: string
  stemHanja: string
  branchHanja: string
  element: string
}

serve(async (req: Request) => {
  // Handle CORS
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  try {
    console.log('Calculate-saju function started')
    console.log('Environment check:')
    console.log('- SUPABASE_URL:', Deno.env.get('SUPABASE_URL') ? 'Set' : 'Not set')
    console.log('- SUPABASE_SERVICE_ROLE_KEY:', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ? 'Set' : 'Not set')
    console.log('- OPENAI_API_KEY:', Deno.env.get('OPENAI_API_KEY') ? 'Set' : 'Not set')
    
    // Authenticate user
    const { user, error: authError } = await authenticateUser(req)
    if (authError) {
      console.error('Authentication error:', authError)
      return authError
    }
    console.log('User authenticated:', user?.id)

    // Parse request body
    const body: SajuRequest = await req.json()
    console.log('Request body received:', JSON.stringify(body, null, 2))
    
    // Validate required fields
    if (!body.birthDate) {
      console.error('Missing birthDate in request')
      return new Response(
        JSON.stringify({ error: 'birthDate is required' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )
    
    // Test database connection and table existence
    console.log('Testing database connection...')
    const { error: tableCheckError } = await supabase
      .from('user_saju')
      .select('id')
      .limit(1)
    
    if (tableCheckError) {
      console.error('Database table check error:', tableCheckError)
      if (tableCheckError.message.includes('relation') && tableCheckError.message.includes('does not exist')) {
        throw new Error('user_saju table does not exist. Please run migrations.')
      }
    } else {
      console.log('Database table check passed')
    }

    // Check if Saju already exists for this user
    console.log('Checking for existing Saju data...')
    const { data: existingSaju, error: fetchError } = await supabase
      .from('user_saju')
      .select('*')
      .eq('user_id', user!.id)
      .single()

    if (fetchError && fetchError.code !== 'PGRST116') {
      console.error('Error fetching existing Saju:', fetchError)
    }

    if (existingSaju) {
      console.log('Found existing Saju data, returning cached result')
      // Return existing Saju data
      return new Response(
        JSON.stringify({
          success: true,
          data: existingSaju,
          cached: true
        }),
        { 
          status: 200, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Convert birthTime format if needed
    let formattedBirthTime = body.birthTime
    if (formattedBirthTime && formattedBirthTime.includes('시')) {
      console.log('Converting Korean time format:', formattedBirthTime)
      // Extract time from format like "축시 (01:00 - 03:00)"
      const timeMatch = formattedBirthTime.match(/(\d{2}):(\d{2})/)
      if (timeMatch) {
        formattedBirthTime = `${timeMatch[1]}:${timeMatch[2]}`
        console.log('Converted to:', formattedBirthTime)
      } else {
        // If no exact time, use middle of the period
        const hourMapping: Record<string, string> = {
          '자시': '00:00', '축시': '02:00', '인시': '04:00', '묘시': '06:00',
          '진시': '08:00', '사시': '10:00', '오시': '12:00', '미시': '14:00',
          '신시': '16:00', '유시': '18:00', '술시': '20:00', '해시': '22:00'
        }
        for (const [period, time] of Object.entries(hourMapping)) {
          if (formattedBirthTime.includes(period)) {
            formattedBirthTime = time
            console.log('Mapped period to time:', formattedBirthTime)
            break
          }
        }
      }
    }

    // Calculate Saju using the provided birth information
    console.log('Calculating Saju with:', { 
      birthDate: body.birthDate, 
      birthTime: formattedBirthTime, 
      isLunar: body.isLunar 
    })
    const saju = calculateSaju(body.birthDate, formattedBirthTime, body.isLunar || false)
    
    // Generate AI interpretation using GPT-4.1-nano
    const interpretationPrompt = `
    사용자의 사주팔자 정보:
    - 년주: ${saju.year.stemHanja}${saju.year.branchHanja} (${saju.year.stem}${saju.year.branch})
    - 월주: ${saju.month.stemHanja}${saju.month.branchHanja} (${saju.month.stem}${saju.month.branch})
    - 일주: ${saju.day.stemHanja}${saju.day.branchHanja} (${saju.day.stem}${saju.day.branch})
    ${saju.hour ? `- 시주: ${saju.hour.stemHanja}${saju.hour.branchHanja} (${saju.hour.stem}${saju.hour.branch})` : '- 시주: 정보 없음'}
    
    오행 분포: 목(${saju.elementBalance['목']}), 화(${saju.elementBalance['화']}), 토(${saju.elementBalance['토']}), 금(${saju.elementBalance['금']}), 수(${saju.elementBalance['수']})
    
    다음 형식의 JSON으로 사주 해석을 제공해주세요:
    {
      "interpretation": "전체적인 사주 해석 (300자 이상)",
      "personalityAnalysis": "성격 분석 (200자 이상)",
      "careerGuidance": "직업 및 진로 조언 (200자 이상)",
      "relationshipAdvice": "인간관계 조언 (200자 이상)",
      "dominantElement": "가장 강한 오행",
      "lackingElement": "가장 부족한 오행"
    }
    `

    console.log('=== AI INTERPRETATION START ===')
    console.log('Timestamp:', new Date().toISOString())
    console.log('Prompt being sent to AI:')
    console.log(interpretationPrompt)
    console.log('=== End of prompt ===')
    
    let aiResponse: string
    let interpretation: any
    const aiStartTime = Date.now()
    
    try {
      console.log('About to call generateFortuneWithAI...')
      console.log('Context parameter: saju')
      
      aiResponse = await generateFortuneWithAI(interpretationPrompt, 'saju')
      
      const aiEndTime = Date.now()
      console.log('=== AI RESPONSE RECEIVED ===')
      console.log('Time taken:', aiEndTime - aiStartTime, 'ms')
      console.log('Response type:', typeof aiResponse)
      console.log('Response length:', aiResponse.length)
      console.log('First 500 chars of response:', aiResponse.substring(0, 500))
      console.log('Last 500 chars of response:', aiResponse.substring(Math.max(0, aiResponse.length - 500)))
      
      // JSON 파싱 시도
      console.log('Attempting to parse AI response as JSON...')
      try {
        interpretation = JSON.parse(aiResponse)
        console.log('JSON parsing successful!')
        console.log('Parsed object type:', typeof interpretation)
        console.log('Parsed object keys:', Object.keys(interpretation))
        console.log('Full parsed object:', JSON.stringify(interpretation, null, 2))
        
        // 필수 필드 검증
        const requiredFields = ['interpretation', 'personalityAnalysis', 'careerGuidance', 'relationshipAdvice', 'dominantElement', 'lackingElement']
        const missingFields = requiredFields.filter(field => !interpretation[field])
        if (missingFields.length > 0) {
          console.warn('Warning: Missing fields in AI response:', missingFields)
        }
      } catch (parseError) {
        console.error('JSON parsing failed!')
        console.error('Parse error:', parseError)
        console.error('Parse error message:', parseError.message)
        console.error('Raw response that failed to parse:', aiResponse)
        throw parseError
      }
    } catch (aiError) {
      console.error('=== AI INTERPRETATION ERROR ===')
      console.error('Error timestamp:', new Date().toISOString())
      console.error('Error type:', aiError.constructor.name)
      console.error('Error message:', aiError.message)
      console.error('Error stack:', aiError.stack)
      console.error('Time elapsed before error:', Date.now() - aiStartTime, 'ms')
      
      // 에러 타입별 상세 분석
      if (aiError.message.includes('OpenAI API key not configured')) {
        console.error('API Key issue detected')
      } else if (aiError.message.includes('fetch')) {
        console.error('Network/Fetch error detected')
      } else if (aiError.message.includes('JSON')) {
        console.error('JSON parsing error detected')
      }
      
      // Provide fallback interpretation if AI fails
      console.log('Using fallback interpretation...')
      interpretation = {
        interpretation: '사주팔자 분석 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
        personalityAnalysis: '',
        careerGuidance: '',
        relationshipAdvice: '',
        dominantElement: Object.entries(saju.elementBalance).sort((a: any, b: any) => b[1] - a[1])[0][0],
        lackingElement: Object.entries(saju.elementBalance).sort((a: any, b: any) => a[1] - b[1])[0][0]
      }
      console.log('Fallback interpretation created:', interpretation)
    }
    
    console.log('=== AI INTERPRETATION COMPLETE ===')
    console.log('Final interpretation object:', JSON.stringify(interpretation, null, 2))

    // Prepare data for database
    const sajuData = {
      user_id: user!.id,
      birth_date: body.birthDate,
      birth_time: formattedBirthTime || null,  // Use formatted time
      is_lunar: body.isLunar || false,
      timezone: body.timezone || 'Asia/Seoul',
      
      // Four Pillars
      year_stem: saju.year.stem,
      year_branch: saju.year.branch,
      year_stem_hanja: saju.year.stemHanja,
      year_branch_hanja: saju.year.branchHanja,
      
      month_stem: saju.month.stem,
      month_branch: saju.month.branch,
      month_stem_hanja: saju.month.stemHanja,
      month_branch_hanja: saju.month.branchHanja,
      
      day_stem: saju.day.stem,
      day_branch: saju.day.branch,
      day_stem_hanja: saju.day.stemHanja,
      day_branch_hanja: saju.day.branchHanja,
      
      hour_stem: saju.hour?.stem || null,
      hour_branch: saju.hour?.branch || null,
      hour_stem_hanja: saju.hour?.stemHanja || null,
      hour_branch_hanja: saju.hour?.branchHanja || null,
      
      // Analysis
      element_balance: saju.elementBalance,
      dominant_element: interpretation.dominantElement,
      lacking_element: interpretation.lackingElement,
      ten_gods: saju.tenGods,
      daeun_info: saju.daeunInfo,
      current_daeun: saju.currentDaeun,
      
      // AI Interpretations
      interpretation: interpretation.interpretation,
      personality_analysis: interpretation.personalityAnalysis,
      career_guidance: interpretation.careerGuidance,
      relationship_advice: interpretation.relationshipAdvice,
    }
    
    console.log('Preparing to save Saju data...')
    console.log('Data keys:', Object.keys(sajuData))
    console.log('Birth time data:', {
      birth_time: sajuData.birth_time,
      hour_stem: sajuData.hour_stem,
      hour_branch: sajuData.hour_branch
    })
    
    // Log the full data being saved
    console.log('Full sajuData:', JSON.stringify(sajuData, null, 2))
    
    // Verify service role key is being used
    console.log('Using service role key:', Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ? 'Yes' : 'No')

    // Save to database with upsert to handle potential conflicts
    const { data: savedSaju, error: saveError } = await supabase
      .from('user_saju')
      .upsert(sajuData, { 
        onConflict: 'user_id',
        ignoreDuplicates: false 
      })
      .select()
      .single()

    if (saveError) {
      console.error('=== SAJU SAVE ERROR ===')
      console.error('Error type:', saveError.constructor.name)
      console.error('Error code:', saveError.code)
      console.error('Error message:', saveError.message)
      console.error('Error details:', saveError.details)
      console.error('Error hint:', saveError.hint)
      console.error('Full error object:', JSON.stringify(saveError, null, 2))
      
      // Check if it's a duplicate key error and try to update
      if (saveError.code === '23505') {
        const { data: updatedSaju, error: updateError } = await supabase
          .from('user_saju')
          .update(sajuData)
          .eq('user_id', user!.id)
          .select()
          .single()
          
        if (updateError) {
          console.error('Error updating Saju:', updateError)
          return new Response(
            JSON.stringify({ 
              error: 'Failed to update Saju data',
              details: updateError.message,
              code: updateError.code
            }),
            { 
              status: 500, 
              headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
            }
          )
        }
        
        return new Response(
          JSON.stringify({
            success: true,
            data: updatedSaju,
            cached: false,
            updated: true
          }),
          { 
            status: 200, 
            headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
          }
        )
      }
      
      return new Response(
        JSON.stringify({ 
          error: 'Failed to save Saju data',
          details: saveError.message,
          code: saveError.code
        }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Save to calculation history
    await supabase
      .from('saju_calculation_history')
      .insert({
        user_id: user!.id,
        calculation_type: 'initial',
        request_data: body,
        response_data: savedSaju,
        tokens_used: 1, // GPT-4.1-nano uses minimal tokens
      })

    return new Response(
      JSON.stringify({
        success: true,
        data: savedSaju,
        cached: false
      }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('=== SAJU CALCULATION ERROR ===')
    console.error('Error timestamp:', new Date().toISOString())
    console.error('Error type:', error.constructor.name)
    console.error('Error message:', error.message)
    console.error('Error stack:', error.stack)
    
    // Log the point where error occurred
    if (error.message.includes('OpenAI')) {
      console.error('Error occurred during OpenAI API call')
    } else if (error.message.includes('database') || error.message.includes('relation')) {
      console.error('Error occurred during database operation')
    } else if (error.message.includes('auth')) {
      console.error('Error occurred during authentication')
    }
    
    // Check for specific error types
    let errorMessage = 'Internal server error'
    let errorDetails = ''
    let errorCode = 'UNKNOWN_ERROR'
    
    if (error.message.includes('OpenAI API error')) {
      errorMessage = 'AI 서비스 오류'
      errorDetails = error.message
      errorCode = 'OPENAI_ERROR'
    } else if (error.message.includes('Failed to generate fortune')) {
      errorMessage = '운세 생성 실패'
      errorDetails = 'AI 응답을 처리할 수 없습니다'
      errorCode = 'AI_GENERATION_ERROR'
    } else if (error.message.includes('relation') && error.message.includes('does not exist')) {
      errorMessage = '데이터베이스 테이블 오류'
      errorDetails = 'user_saju 테이블이 존재하지 않습니다'
      errorCode = 'DB_TABLE_ERROR'
    } else if (error.message.includes('Failed to save Saju data')) {
      errorMessage = '사주 데이터 저장 실패'
      errorDetails = error.message
      errorCode = 'DB_SAVE_ERROR'
    } else {
      errorDetails = error.message || 'Unknown error'
    }
    
    console.error('Final error response:', {
      error: errorMessage,
      details: errorDetails,
      code: errorCode
    })
    
    return new Response(
      JSON.stringify({ 
        error: errorMessage,
        details: errorDetails,
        code: errorCode,
        timestamp: new Date().toISOString(),
        debugInfo: {
          errorType: error.constructor.name,
          originalMessage: error.message
        }
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Saju calculation logic (TypeScript version)
function calculateSaju(birthDate: string, birthTime?: string, isLunar: boolean = false) {
  const date = new Date(birthDate)
  
  // Convert lunar to solar if needed (simplified)
  const solarDate = isLunar ? addDays(date, 30) : date
  
  // Calculate pillars
  const yearPillar = calculateYearPillar(solarDate)
  const monthPillar = calculateMonthPillar(solarDate, yearPillar.stemIndex)
  const dayPillar = calculateDayPillar(solarDate)
  const hourPillar = birthTime ? calculateHourPillar(birthTime, dayPillar.stemIndex) : null
  
  // Analyze elements
  const elementBalance = analyzeElements(yearPillar, monthPillar, dayPillar, hourPillar)
  
  // Calculate Ten Gods
  const tenGods = calculateTenGods(dayPillar.stem, yearPillar, monthPillar, hourPillar)
  
  // Calculate Daeun
  const daeunInfo = calculateDaeun(solarDate, monthPillar)
  
  return {
    year: {
      stem: yearPillar.stem,
      branch: yearPillar.branch,
      stemHanja: yearPillar.stemHanja,
      branchHanja: yearPillar.branchHanja,
      element: stemElements[yearPillar.stem],
    },
    month: {
      stem: monthPillar.stem,
      branch: monthPillar.branch,
      stemHanja: monthPillar.stemHanja,
      branchHanja: monthPillar.branchHanja,
      element: stemElements[monthPillar.stem],
    },
    day: {
      stem: dayPillar.stem,
      branch: dayPillar.branch,
      stemHanja: dayPillar.stemHanja,
      branchHanja: dayPillar.branchHanja,
      element: stemElements[dayPillar.stem],
    },
    hour: hourPillar ? {
      stem: hourPillar.stem,
      branch: hourPillar.branch,
      stemHanja: hourPillar.stemHanja,
      branchHanja: hourPillar.branchHanja,
      element: stemElements[hourPillar.stem],
    } : null,
    elementBalance,
    tenGods,
    daeunInfo,
    currentDaeun: `${daeunInfo.stem}${daeunInfo.branch}`,
  }
}

// Constants
const heavenlyStems = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계']
const heavenlyStemsHanja = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸']
const earthlyBranches = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해']
const earthlyBranchesHanja = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥']

const stemElements: Record<string, string> = {
  '갑': '목', '을': '목',
  '병': '화', '정': '화',
  '무': '토', '기': '토',
  '경': '금', '신': '금',
  '임': '수', '계': '수',
}

const branchElements: Record<string, string> = {
  '자': '수', '축': '토', '인': '목', '묘': '목',
  '진': '토', '사': '화', '오': '화', '미': '토',
  '신': '금', '유': '금', '술': '토', '해': '수',
}

// Helper functions
function addDays(date: Date, days: number): Date {
  const result = new Date(date)
  result.setDate(result.getDate() + days)
  return result
}

function calculateYearPillar(date: Date) {
  // Lichun adjustment
  const lichun = new Date(date.getFullYear(), 1, 4) // Feb 4
  const year = date < lichun ? date.getFullYear() - 1 : date.getFullYear()
  
  const stemIndex = (year - 4) % 10
  const branchIndex = (year - 4) % 12
  
  return {
    stem: heavenlyStems[stemIndex],
    branch: earthlyBranches[branchIndex],
    stemHanja: heavenlyStemsHanja[stemIndex],
    branchHanja: earthlyBranchesHanja[branchIndex],
    stemIndex,
    branchIndex,
  }
}

function calculateMonthPillar(date: Date, yearStemIndex: number) {
  const monthIndex = getMonthIndexBySolarTerm(date)
  
  // Month stem calculation based on year stem
  const monthStemStartIndex = [2, 4, 6, 8, 0][yearStemIndex % 5]
  const stemIndex = (monthStemStartIndex + monthIndex) % 10
  const branchIndex = (monthIndex + 2) % 12
  
  return {
    stem: heavenlyStems[stemIndex],
    branch: earthlyBranches[branchIndex],
    stemHanja: heavenlyStemsHanja[stemIndex],
    branchHanja: earthlyBranchesHanja[branchIndex],
    stemIndex,
    branchIndex,
  }
}

function getMonthIndexBySolarTerm(date: Date): number {
  const month = date.getMonth() + 1
  const day = date.getDate()
  
  if (month === 1 || (month === 2 && day < 4)) return 11
  if (month === 2 || (month === 3 && day < 6)) return 0
  if (month === 3 || (month === 4 && day < 5)) return 1
  if (month === 4 || (month === 5 && day < 6)) return 2
  if (month === 5 || (month === 6 && day < 6)) return 3
  if (month === 6 || (month === 7 && day < 7)) return 4
  if (month === 7 || (month === 8 && day < 8)) return 5
  if (month === 8 || (month === 9 && day < 8)) return 6
  if (month === 9 || (month === 10 && day < 8)) return 7
  if (month === 10 || (month === 11 && day < 8)) return 8
  if (month === 11 || (month === 12 && day < 7)) return 9
  return 10
}

function calculateDayPillar(date: Date) {
  const baseDate = new Date(1900, 0, 1) // Jan 1, 1900
  const daysDiff = Math.floor((date.getTime() - baseDate.getTime()) / (1000 * 60 * 60 * 24))
  
  const dayNumber = (daysDiff + 40) % 60 // 갑진일이 40번째
  const stemIndex = dayNumber % 10
  const branchIndex = dayNumber % 12
  
  return {
    stem: heavenlyStems[stemIndex],
    branch: earthlyBranches[branchIndex],
    stemHanja: heavenlyStemsHanja[stemIndex],
    branchHanja: earthlyBranchesHanja[branchIndex],
    stemIndex,
    branchIndex,
  }
}

function calculateHourPillar(birthTime: string, dayStemIndex: number) {
  const [hour, minute] = birthTime.split(':').map(Number)
  const hourIndex = getHourIndex(hour)
  
  const hourStemStartIndex = [0, 2, 4, 6, 8][dayStemIndex % 5]
  const stemIndex = (hourStemStartIndex + hourIndex) % 10
  
  return {
    stem: heavenlyStems[stemIndex],
    branch: earthlyBranches[hourIndex],
    stemHanja: heavenlyStemsHanja[stemIndex],
    branchHanja: earthlyBranchesHanja[hourIndex],
    stemIndex,
    branchIndex: hourIndex,
  }
}

function getHourIndex(hour: number): number {
  if (hour >= 23 || hour < 1) return 0   // 자시
  if (hour >= 1 && hour < 3) return 1    // 축시
  if (hour >= 3 && hour < 5) return 2    // 인시
  if (hour >= 5 && hour < 7) return 3    // 묘시
  if (hour >= 7 && hour < 9) return 4    // 진시
  if (hour >= 9 && hour < 11) return 5   // 사시
  if (hour >= 11 && hour < 13) return 6  // 오시
  if (hour >= 13 && hour < 15) return 7  // 미시
  if (hour >= 15 && hour < 17) return 8  // 신시
  if (hour >= 17 && hour < 19) return 9  // 유시
  if (hour >= 19 && hour < 21) return 10 // 술시
  if (hour >= 21 && hour < 23) return 11 // 해시
  return 0
}

function analyzeElements(year: any, month: any, day: any, hour: any) {
  const elements: Record<string, number> = {'목': 0, '화': 0, '토': 0, '금': 0, '수': 0}
  
  // Count elements from stems and branches
  elements[stemElements[year.stem]]++
  elements[branchElements[year.branch]]++
  elements[stemElements[month.stem]]++
  elements[branchElements[month.branch]]++
  elements[stemElements[day.stem]]++
  elements[branchElements[day.branch]]++
  
  if (hour) {
    elements[stemElements[hour.stem]]++
    elements[branchElements[hour.branch]]++
  }
  
  return elements
}

function calculateTenGods(dayStem: string, year: any, month: any, hour: any) {
  const tenGods: Record<string, string[]> = {}
  
  tenGods.year = [getTenGodRelation(dayStem, year.stem)]
  tenGods.month = [getTenGodRelation(dayStem, month.stem)]
  if (hour) {
    tenGods.hour = [getTenGodRelation(dayStem, hour.stem)]
  }
  
  return tenGods
}

function getTenGodRelation(dayStem: string, targetStem: string): string {
  const dayIndex = heavenlyStems.indexOf(dayStem)
  const targetIndex = heavenlyStems.indexOf(targetStem)
  
  if (dayIndex === targetIndex) return '비견'
  
  const diff = (targetIndex - dayIndex + 10) % 10
  
  const relations = ['비견', '겁재', '식신', '상관', '편재', '정재', '편관', '정관', '편인', '정인']
  return relations[diff]
}

function calculateDaeun(birthDate: Date, monthPillar: any) {
  const now = new Date()
  const age = now.getFullYear() - birthDate.getFullYear()
  
  const daeunStartAge = 10
  const currentDaeunIndex = Math.floor((age - daeunStartAge) / 10)
  const currentDaeunAge = daeunStartAge + (currentDaeunIndex * 10)
  
  const stemIndex = (monthPillar.stemIndex + currentDaeunIndex + 1) % 10
  const branchIndex = (monthPillar.branchIndex + currentDaeunIndex + 1) % 12
  
  return {
    currentAge: age,
    startAge: currentDaeunAge,
    endAge: currentDaeunAge + 9,
    stem: heavenlyStems[stemIndex],
    branch: earthlyBranches[branchIndex],
    stemHanja: heavenlyStemsHanja[stemIndex],
    branchHanja: earthlyBranchesHanja[branchIndex],
  }
}