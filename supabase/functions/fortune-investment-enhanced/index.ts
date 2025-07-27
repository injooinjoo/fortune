// @ts-ignore
import { serve } from "https://deno.land/std@0.131.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { Redis } from "https://deno.land/x/redis@v0.31.0/mod.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('No authorization header')
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    
    if (authError || !user) {
      throw new Error('Invalid token')
    }

    const { 
      userId,
      name,
      birthDate,
      gender,
      birthTime,
      riskTolerance,
      investmentExperience,
      investmentGoal,
      investmentHorizon,
      selectedSectors,
      sectorPriorities,
      wantPortfolioReview,
      wantMarketTiming,
      wantLuckyNumbers,
      wantRiskAnalysis,
      specificQuestion
    } = await req.json()

    // Generate comprehensive investment fortune analysis
    const fortuneData = await generateEnhancedInvestmentFortune({
      user: { name, birthDate, gender, birthTime },
      profile: {
        riskTolerance,
        investmentExperience,
        investmentGoal,
        investmentHorizon
      },
      sectors: {
        selected: selectedSectors,
        priorities: sectorPriorities
      },
      analysis: {
        wantPortfolioReview,
        wantMarketTiming,
        wantLuckyNumbers,
        wantRiskAnalysis,
        specificQuestion
      }
    })

    // Save fortune result
    const { data: fortune, error: insertError } = await supabase
      .from('fortunes')
      .insert({
        user_id: userId,
        type: 'investment-enhanced',
        data: fortuneData,
        created_at: new Date().toISOString()
      })
      .select()
      .single()

    if (insertError) {
      throw insertError
    }

    // Cache the result
    try {
      const redis = new Redis({
        url: Deno.env.get('REDIS_URL') ?? '',
        token: Deno.env.get('REDIS_TOKEN') ?? '',
      })
      
      const cacheKey = `fortune:investment-enhanced:${userId}:${new Date().toISOString().split('T')[0]}`
      await redis.set(cacheKey, JSON.stringify(fortune), { ex: 3600 })
      await redis.quit()
    } catch (cacheError) {
      console.error('Cache error:', cacheError)
    }

    return new Response(
      JSON.stringify(fortune),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      },
    )
  }
})

async function generateEnhancedInvestmentFortune(params: any) {
  const { user, profile, sectors, analysis } = params
  
  // Calculate overall investment fortune score
  const overallScore = calculateInvestmentScore(user.birthDate, profile, sectors)
  
  // Generate sector-specific fortunes
  const sectorFortune = {}
  for (const sector of sectors.selected || []) {
    sectorFortune[sector] = generateSectorFortune(sector, user.birthDate, profile)
  }
  
  // Generate market timing analysis
  const marketTiming = analysis.wantMarketTiming ? generateMarketTiming(user.birthDate) : null
  
  // Generate lucky information
  const luckyInfo = analysis.wantLuckyNumbers ? generateLuckyInfo(user.birthDate) : null
  
  // Generate risk analysis
  const riskAnalysis = analysis.wantRiskAnalysis ? generateRiskAnalysis(profile, sectors) : null
  
  // Answer specific question if provided
  const specificAnswer = analysis.specificQuestion ? 
    await generateSpecificAnswer(analysis.specificQuestion, user, profile) : null
  
  // Generate comprehensive analysis
  const overallAnalysis = generateOverallAnalysis(user, profile, sectors, overallScore)

  return {
    overallScore,
    summary: generateSummary(overallScore, profile, sectors),
    overallAnalysis,
    sectorFortune,
    marketTiming,
    luckyInfo,
    riskAnalysis,
    specificAnswer,
    generatedAt: new Date().toISOString()
  }
}

function calculateInvestmentScore(birthDate: string, profile: any, sectors: any): number {
  // Complex calculation based on Korean fortune telling principles
  const today = new Date()
  const birth = new Date(birthDate)
  
  // Calculate base score from birth date
  let score = 70
  
  // Adjust based on lunar calendar (simplified)
  const dayOfMonth = today.getDate()
  const birthDay = birth.getDate()
  
  if (dayOfMonth % 6 === birthDay % 6) {
    score += 10
  }
  
  // Adjust based on risk tolerance
  if (profile.riskTolerance === 'aggressive' && dayOfMonth > 15) {
    score += 5
  } else if (profile.riskTolerance === 'conservative' && dayOfMonth < 15) {
    score += 5
  }
  
  // Adjust based on selected sectors
  const sectorCount = sectors.selected?.length || 0
  if (sectorCount >= 3 && sectorCount <= 5) {
    score += 5 // Good diversification
  }
  
  return Math.min(Math.max(score, 0), 100)
}

function generateSectorFortune(sector: string, birthDate: string, profile: any) {
  const sectorScores = {
    stocks: 75,
    realestate: 80,
    crypto: 65,
    auction: 70,
    lottery: 45,
    funds: 78,
    gold: 82,
    bonds: 85,
    startup: 60,
    art: 68
  }
  
  const baseScore = sectorScores[sector] || 70
  const birth = new Date(birthDate)
  const today = new Date()
  
  // Adjust score based on birth date and current date
  let adjustedScore = baseScore
  if (birth.getMonth() === today.getMonth()) {
    adjustedScore += 5
  }
  
  // Generate recommendation
  let recommendation = '보통'
  if (adjustedScore >= 80) recommendation = '매수'
  else if (adjustedScore >= 70) recommendation = '관망'
  else if (adjustedScore < 50) recommendation = '매도'
  
  // Generate analysis based on sector
  const analyses = {
    stocks: '주식 시장이 변동성이 크지만 장기적으로는 긍정적입니다.',
    realestate: '부동산 시장이 안정적이며 투자 적기입니다.',
    crypto: '암호화폐 시장은 변동성이 크니 주의가 필요합니다.',
    auction: '경매 시장에서 좋은 기회를 찾을 수 있습니다.',
    lottery: '행운보다는 계획적인 투자를 권합니다.',
    funds: '펀드 투자로 안정적인 수익을 기대할 수 있습니다.',
    gold: '금 투자는 안전자산으로 좋은 선택입니다.',
    bonds: '채권 투자로 안정적인 수익을 얻을 수 있습니다.',
    startup: '스타트업 투자는 신중한 검토가 필요합니다.',
    art: '예술품 투자는 장기적 관점이 필요합니다.'
  }
  
  // Generate tips
  const tips = generateSectorTips(sector, profile)
  
  return {
    score: adjustedScore,
    recommendation,
    analysis: analyses[sector] || '신중한 투자를 권합니다.',
    tips
  }
}

function generateSectorTips(sector: string, profile: any): string {
  const tipsMap = {
    stocks: '분산 투자를 통해 리스크를 관리하세요.',
    realestate: '입지와 교통을 꼼꼼히 확인하세요.',
    crypto: '투자금의 10% 이내로 제한하세요.',
    auction: '사전 조사를 철저히 하세요.',
    lottery: '여유 자금으로만 구매하세요.',
    funds: '수수료와 운용 실적을 확인하세요.',
    gold: '장기 보유를 권장합니다.',
    bonds: '신용등급을 확인하세요.',
    startup: '사업 모델을 꼼꼼히 검토하세요.',
    art: '진품 여부를 반드시 확인하세요.'
  }
  
  return tipsMap[sector] || '충분한 조사 후 투자하세요.'
}

function generateMarketTiming(birthDate: string) {
  const today = new Date()
  const dayOfWeek = today.getDay()
  const dayOfMonth = today.getDate()
  
  // Generate timing based on Korean fortune principles
  const todayTiming = {
    action: dayOfMonth % 3 === 0 ? 'buy' : dayOfMonth % 5 === 0 ? 'sell' : 'hold',
    strength: dayOfMonth < 10 ? 'strong' : dayOfMonth < 20 ? 'medium' : 'weak',
    description: '오늘은 시장을 관찰하며 기회를 엿보는 것이 좋습니다.'
  }
  
  const weekTiming = {
    action: dayOfWeek < 3 ? 'buy' : 'hold',
    strength: 'medium',
    description: '이번 주는 신중한 투자가 필요한 시기입니다.'
  }
  
  const monthTiming = {
    action: today.getMonth() % 2 === 0 ? 'buy' : 'sell',
    strength: 'medium',
    description: '이번 달은 장기 투자를 시작하기 좋은 시기입니다.'
  }
  
  // Lucky days this month
  const luckyDays = []
  for (let i = 1; i <= 31; i++) {
    if (i % 6 === new Date(birthDate).getDate() % 6) {
      luckyDays.push(i)
    }
  }
  
  return {
    today: todayTiming,
    week: weekTiming,
    month: monthTiming,
    luckyDays
  }
}

function generateLuckyInfo(birthDate: string) {
  const birth = new Date(birthDate)
  const birthDay = birth.getDate()
  const birthMonth = birth.getMonth() + 1
  
  // Generate lotto numbers based on birth date
  const lottoNumbers = []
  lottoNumbers.push(birthDay)
  lottoNumbers.push(birthMonth)
  lottoNumbers.push((birthDay * 2) % 45 + 1)
  lottoNumbers.push((birthMonth * 3) % 45 + 1)
  lottoNumbers.push((birthDay + birthMonth) % 45 + 1)
  lottoNumbers.push(((birthDay * birthMonth) % 45) + 1)
  
  // Ensure unique numbers
  const uniqueLotto = [...new Set(lottoNumbers)].slice(0, 6)
  while (uniqueLotto.length < 6) {
    uniqueLotto.push(Math.floor(Math.random() * 45) + 1)
  }
  
  // General lucky numbers
  const generalNumbers = [
    birthDay % 10 || 9,
    birthMonth,
    (birthDay + birthMonth) % 10 || 7
  ]
  
  // Lucky colors based on birth date
  const colorMap = ['red', 'gold', 'green', 'blue', 'purple']
  const luckyColors = [
    colorMap[birthDay % 5],
    colorMap[birthMonth % 5],
    colorMap[(birthDay + birthMonth) % 5]
  ]
  
  // Lucky directions
  const directionMap = ['동쪽', '서쪽', '남쪽', '북쪽', '중앙', '남동쪽', '남서쪽', '북동쪽', '북서쪽']
  const luckyDirections = [
    directionMap[birthDay % 9],
    directionMap[birthMonth % 9]
  ]
  
  return {
    numbers: {
      lotto: uniqueLotto.sort((a, b) => a - b),
      general: generalNumbers
    },
    colors: [...new Set(luckyColors)],
    directions: [...new Set(luckyDirections)]
  }
}

function generateRiskAnalysis(profile: any, sectors: any) {
  const risks = []
  
  // Analyze based on risk tolerance
  if (profile.riskTolerance === 'aggressive' && profile.investmentExperience === 'beginner') {
    risks.push({
      level: 'high',
      title: '경험 대비 높은 위험',
      description: '투자 경험에 비해 위험 성향이 높습니다. 단계적으로 투자를 늘려가세요.'
    })
  }
  
  // Analyze based on sector concentration
  const sectorPriorities = sectors.priorities || {}
  for (const [sector, priority] of Object.entries(sectorPriorities)) {
    if (priority > 50) {
      risks.push({
        level: 'medium',
        title: `${sector} 집중도 높음`,
        description: `${sector} 섹터에 ${priority}% 집중되어 있습니다. 분산 투자를 고려하세요.`
      })
    }
  }
  
  // Analyze based on investment horizon
  if (profile.investmentHorizon < 12 && sectors.selected?.includes('realestate')) {
    risks.push({
      level: 'medium',
      title: '부동산 단기 투자 위험',
      description: '부동산은 장기 투자가 적합합니다. 투자 기간을 재고려하세요.'
    })
  }
  
  // Add general risk advice
  risks.push({
    level: 'low',
    title: '일반 투자 원칙',
    description: '여유 자금으로만 투자하고, 손실을 감당할 수 있는 범위에서 투자하세요.'
  })
  
  return { risks }
}

async function generateSpecificAnswer(question: string, user: any, profile: any): Promise<string> {
  // Generate personalized answer based on the question
  const baseAnswers = {
    부동산: '현재 부동산 시장은 관망세입니다. 입지가 좋은 중소형 아파트를 중심으로 검토해보세요.',
    주식: '변동성이 큰 시기입니다. 우량주 중심의 분산 투자를 권합니다.',
    코인: '암호화폐는 고위험 투자입니다. 전체 자산의 5-10% 이내로 제한하세요.',
    금: '안전자산으로서의 금 투자는 포트폴리오의 10-20%가 적당합니다.',
    로또: '로또는 투자가 아닌 오락으로 접근하세요. 여유 자금으로만 구매하세요.'
  }
  
  // Check if question contains keywords
  for (const [keyword, answer] of Object.entries(baseAnswers)) {
    if (question.includes(keyword)) {
      return `${user.name}님의 투자 성향을 고려할 때, ${answer}`
    }
  }
  
  // Default answer
  return `${user.name}님의 생년월일과 투자 성향을 분석한 결과, 신중하면서도 기회를 놓치지 않는 투자를 권합니다. 충분한 조사와 분석 후 결정하세요.`
}

function generateOverallAnalysis(user: any, profile: any, sectors: any, score: number) {
  // Generate personality analysis
  const personalityMap = {
    'conservative-beginner': '신중한 초보 투자자',
    'conservative-intermediate': '안정 추구형 투자자',
    'conservative-expert': '보수적 전문 투자자',
    'moderate-beginner': '균형잡힌 초보 투자자',
    'moderate-intermediate': '중도적 투자자',
    'moderate-expert': '균형잡힌 전문 투자자',
    'aggressive-beginner': '도전적 초보 투자자',
    'aggressive-intermediate': '적극적 투자자',
    'aggressive-expert': '공격적 전문 투자자'
  }
  
  const personalityKey = `${profile.riskTolerance}-${profile.investmentExperience}`
  const personality = personalityMap[personalityKey] || '일반 투자자'
  
  // Generate today's fortune
  const todaysFortune = score >= 80 
    ? '오늘은 투자에 매우 좋은 날입니다. 계획했던 투자를 실행해보세요.'
    : score >= 60
    ? '평범한 투자운입니다. 신중하게 접근하세요.'
    : '투자보다는 시장 관찰이 필요한 날입니다.'
  
  // Generate warnings
  const warnings = []
  if (profile.riskTolerance === 'aggressive') {
    warnings.push('과도한 레버리지 사용은 피하세요.')
  }
  if (sectors.selected?.includes('crypto')) {
    warnings.push('암호화폐의 변동성에 주의하세요.')
  }
  warnings.push('투자 전 충분한 조사를 하세요.')
  
  // Portfolio recommendation
  const portfolioRecommendation = generatePortfolioRecommendation(profile, sectors)
  
  return {
    personality: `${user.name}님은 ${personality}입니다. ${getPersonalityAdvice(personality)}`,
    todaysFortune,
    warnings: warnings.join(' '),
    portfolio: portfolioRecommendation
  }
}

function getPersonalityAdvice(personality: string): string {
  const adviceMap = {
    '신중한 초보 투자자': '안정적인 투자 상품부터 시작하여 경험을 쌓아가세요.',
    '안정 추구형 투자자': '채권과 우량주 중심의 포트폴리오를 구성하세요.',
    '보수적 전문 투자자': '리스크 관리에 집중하며 안정적인 수익을 추구하세요.',
    '균형잡힌 초보 투자자': '다양한 자산에 분산 투자하며 경험을 쌓아가세요.',
    '중도적 투자자': '성장주와 가치주를 균형있게 배분하세요.',
    '균형잡힌 전문 투자자': '시장 상황에 따라 유연하게 포트폴리오를 조정하세요.',
    '도전적 초보 투자자': '높은 수익을 추구하되 리스크 관리를 잊지 마세요.',
    '적극적 투자자': '성장 가능성이 높은 섹터에 집중하되 손절선을 정하세요.',
    '공격적 전문 투자자': '레버리지를 활용하되 리스크 관리를 철저히 하세요.'
  }
  
  return adviceMap[personality] || '자신의 투자 성향에 맞는 전략을 수립하세요.'
}

function generatePortfolioRecommendation(profile: any, sectors: any) {
  const basePortfolio = {
    conservative: {
      bonds: 40,
      stocks: 30,
      gold: 20,
      cash: 10
    },
    moderate: {
      stocks: 50,
      bonds: 20,
      realestate: 15,
      gold: 10,
      cash: 5
    },
    aggressive: {
      stocks: 60,
      crypto: 10,
      startup: 10,
      realestate: 15,
      cash: 5
    }
  }
  
  return basePortfolio[profile.riskTolerance] || basePortfolio.moderate
}

function generateSummary(score: number, profile: any, sectors: any): string {
  const selectedCount = sectors.selected?.length || 0
  const riskLevel = profile.riskTolerance === 'aggressive' ? '공격적' 
                  : profile.riskTolerance === 'conservative' ? '보수적' 
                  : '중립적'
  
  return `오늘의 투자 운세는 ${score}점입니다. ${riskLevel} 투자자인 당신에게 ${selectedCount}개 섹터에 대한 맞춤형 분석을 제공합니다.`
}