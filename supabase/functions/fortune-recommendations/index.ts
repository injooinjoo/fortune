import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4'
import { corsHeaders } from '../_shared/cors.ts'

interface FortuneCardScore {
  fortune_type: string
  title: string
  description: string
  route: string
  category: string
  popularity_score: number
  personal_score: number
  total_score: number
  recommendation_reason: string
  recommendation_type: string
  user_visit_count?: number
  last_user_visit?: string
  total_visit_count?: number
  weekly_trend?: number
  is_new?: boolean
  is_premium?: boolean
  last_updated: string
}

interface FortunePopularity {
  fortune_type: string
  visit_count: number
  weekly_trend: number
  seasonal_boost: number
}

interface UserFortuneVisit {
  fortune_type: string
  visit_count: number
  last_visited: string
}

// Fortune metadata mapping
const FORTUNE_METADATA = {
  'love': { title: '연애운', description: '사랑과 연애의 운세', route: '/fortune/relationship?type=love', category: 'love' },
  'chemistry': { title: '케미 운세', description: '상대방과의 특별한 연결', route: '/fortune/chemistry', category: 'love' },
  'marriage': { title: '결혼운', description: '운명의 반쪽을 만날 시기', route: '/fortune/marriage', category: 'love' },
  'compatibility': { title: '궁합', description: '두 사람의 궁합 보기', route: '/fortune/relationship?type=compatibility', category: 'love' },
  'ex-lover': { title: '헤어진 애인', description: '헤어진 연인과의 재회 가능성', route: '/fortune/ex-lover-enhanced', category: 'love' },
  'career': { title: '커리어 운세', description: '취업/직업/사업/창업 종합', route: '/fortune/career', category: 'career' },
  'business': { title: '사업운', description: '사업 번창의 비밀', route: '/fortune/business', category: 'career' },
  'study': { title: '시험 운세', description: '시험과 자격증 합격 운세', route: '/fortune/career?type=exam', category: 'career' },
  'investment': { title: '투자 운세', description: '재물/부동산/주식/암호화폐/로또', route: '/fortune/investment', category: 'money' },
  'money': { title: '금전운', description: '통장이 두둑해지는 날', route: '/fortune/wealth', category: 'money' },
  'daily': { title: '오늘의 운세', description: '오늘 하루의 운세', route: '/fortune/time', category: 'lifestyle' },
  'time': { title: '시간별 운세', description: '오늘/내일/주간/월간/연간 운세', route: '/fortune/time', category: 'lifestyle' },
  'saju': { title: '사주팔자', description: '정통 사주 풀이', route: '/fortune/saju', category: 'traditional' },
  'tarot': { title: '타로 카드', description: '카드가 전하는 오늘의 메시지', route: '/fortune/tarot', category: 'traditional' },
  'dream': { title: '꿈해몽', description: '꿈이 전하는 숨겨진 의미', route: '/fortune/dream', category: 'traditional' },
  'traditional': { title: '전통 운세', description: '사주/토정비결', route: '/fortune/traditional', category: 'traditional' },
  'personality': { title: '성격 운세', description: 'MBTI/혈액형', route: '/fortune/personality', category: 'lifestyle' },
  'biorhythm': { title: '바이오리듬', description: '신체, 감정, 지성 리듬 분석', route: '/fortune/lifestyle?type=biorhythm', category: 'health' },
  'health': { title: '건강 & 운동', description: '건강/피트니스/요가/스포츠', route: '/fortune/health-sports', category: 'health' },
  'lucky_items': { title: '행운 아이템', description: '색깔/숫자/음식/아이템', route: '/fortune/lucky-items', category: 'lifestyle' },
  'fortune-cookie': { title: '포춘 쿠키', description: '오늘의 행운 메시지', route: '/fortune/interactive?type=fortune-cookie', category: 'interactive' },
  'celebrity': { title: '유명인 운세', description: '좋아하는 유명인과 나의 오늘 운세', route: '/fortune/celebrity', category: 'interactive' },
  'pet': { title: '반려동물 운세', description: '반려동물/반려견/반려묘/궁합', route: '/fortune/pet', category: 'petFamily' },
  'family': { title: '가족 운세', description: '자녀/육아/태교/가족화합', route: '/fortune/family', category: 'petFamily' },
}

// Get current season
function getCurrentSeason(): string {
  const month = new Date().getMonth() + 1
  if (month >= 3 && month <= 5) return 'spring'
  if (month >= 6 && month <= 8) return 'summer'
  if (month >= 9 && month <= 11) return 'autumn'
  return 'winter'
}

// Calculate popularity score
function calculatePopularityScore(
  popularity: FortunePopularity | null,
  isNew: boolean,
  season: string
): number {
  let score = 0.5 // Base score

  if (!popularity) return score

  // Visit count factor (0-0.3)
  const visitFactor = Math.min(popularity.visit_count / 10000, 0.3)
  score += visitFactor

  // Weekly trend factor (0-0.2)
  if (popularity.weekly_trend > 0) {
    const trendFactor = Math.min(popularity.weekly_trend / 100, 0.2)
    score += trendFactor
  }

  // Seasonal boost (0-0.2)
  if (popularity.seasonal_boost > 1) {
    score += 0.2
  }

  // New fortune boost (0.3)
  if (isNew) {
    score += 0.3
  }

  return Math.min(score, 1.0)
}

// Calculate personal score
function calculatePersonalScore(
  userVisit: UserFortuneVisit | null,
  userProfile: any,
  fortuneType: string,
  category: string
): number {
  let score = 0.5 // Base score

  // Visit history factor (0-0.3)
  if (userVisit) {
    const visitScore = Math.min(userVisit.visit_count / 10, 0.2)
    score += visitScore

    // Recency factor (0-0.2)
    const daysSinceVisit = Math.floor(
      (Date.now() - new Date(userVisit.last_visited).getTime()) / (1000 * 60 * 60 * 24)
    )
    if (daysSinceVisit > 7) {
      score += 0.2 // Boost if haven't visited in a while
    } else if (daysSinceVisit < 1) {
      score -= 0.1 // Reduce if visited very recently
    }
  } else {
    score += 0.1 // Discovery boost for never visited
  }

  // Profile-based scoring (0-0.3)
  if (userProfile) {
    // MBTI match
    if (userProfile.mbti_type && fortuneType === 'personality') {
      score += 0.3
    }

    // Zodiac match
    if (userProfile.chinese_zodiac && fortuneType === 'zodiac') {
      score += 0.3
    }

    // Gender-based preferences
    if (userProfile.gender === 'female' && category === 'love') {
      score += 0.1
    } else if (userProfile.gender === 'male' && category === 'career') {
      score += 0.1
    }

    // Age-based preferences
    if (userProfile.birth_date) {
      const age = new Date().getFullYear() - new Date(userProfile.birth_date).getFullYear()
      if (age < 30 && category === 'career') score += 0.1
      if (age >= 25 && age <= 35 && category === 'love') score += 0.1
      if (age > 40 && category === 'health') score += 0.1
    }
  }

  return Math.min(score, 1.0)
}

// Get recommendation reason
function getRecommendationReason(
  popularityScore: number,
  personalScore: number,
  isNew: boolean,
  weeklyTrend: number,
  userVisitCount: number
): { reason: string; type: string } {
  if (isNew) return { reason: '신규 운세', type: 'new' }
  if (weeklyTrend > 50) return { reason: '인기 급상승', type: 'trending' }
  if (personalScore > 0.8) return { reason: '맞춤 추천', type: 'personalized' }
  if (popularityScore > 0.8) return { reason: '인기 운세', type: 'popular' }
  if (userVisitCount === 0) return { reason: '아직 안 본 운세', type: 'discovery' }
  return { reason: '추천', type: 'general' }
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get auth header
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: 'No authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Get user from auth header
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)
    
    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get user profile
    const { data: userProfile } = await supabase
      .from('user_profiles')
      .select('*')
      .eq('user_id', user.id)
      .single()

    // Get all fortune popularity data
    const { data: popularityData } = await supabase
      .from('fortune_popularity')
      .select('*')

    // Create popularity map
    const popularityMap = new Map<string, FortunePopularity>()
    if (popularityData) {
      popularityData.forEach(item => {
        popularityMap.set(item.fortune_type, item)
      })
    }

    // Get user's fortune visit history
    const { data: userVisits } = await supabase
      .from('user_fortune_visits')
      .select('*')
      .eq('user_id', user.id)

    // Create user visit map
    const userVisitMap = new Map<string, UserFortuneVisit>()
    if (userVisits) {
      userVisits.forEach(item => {
        userVisitMap.set(item.fortune_type, item)
      })
    }

    // Calculate scores for all fortune types
    const currentSeason = getCurrentSeason()
    const recommendations: FortuneCardScore[] = []

    // Define which fortunes are new (you can adjust this list)
    const newFortunes = ['time', 'personality', 'tarot', 'dream', 'ex-lover', 'celebrity', 'fortune-cookie', 'pet', 'family']

    for (const [fortuneType, metadata] of Object.entries(FORTUNE_METADATA)) {
      const popularity = popularityMap.get(fortuneType) || null
      const userVisit = userVisitMap.get(fortuneType) || null
      const isNew = newFortunes.includes(fortuneType)

      const popularityScore = calculatePopularityScore(popularity, isNew, currentSeason)
      const personalScore = calculatePersonalScore(userVisit, userProfile, fortuneType, metadata.category)
      const totalScore = (popularityScore * 0.5) + (personalScore * 0.5)

      const { reason, type } = getRecommendationReason(
        popularityScore,
        personalScore,
        isNew,
        popularity?.weekly_trend || 0,
        userVisit?.visit_count || 0
      )

      recommendations.push({
        fortune_type: fortuneType,
        title: metadata.title,
        description: metadata.description,
        route: metadata.route,
        category: metadata.category,
        popularity_score: popularityScore,
        personal_score: personalScore,
        total_score: totalScore,
        recommendation_reason: reason,
        recommendation_type: type,
        user_visit_count: userVisit?.visit_count || 0,
        last_user_visit: userVisit?.last_visited,
        total_visit_count: popularity?.visit_count || 0,
        weekly_trend: popularity?.weekly_trend || 0,
        is_new: isNew,
        is_premium: false, // You can add premium logic here
        last_updated: new Date().toISOString()
      })
    }

    // Sort by total score
    recommendations.sort((a, b) => b.total_score - a.total_score)

    // Return top recommendations (default 20)
    const limit = parseInt(req.url.split('limit=')[1]?.split('&')[0] || '20')
    const topRecommendations = recommendations.slice(0, limit)

    return new Response(
      JSON.stringify({
        recommendations: topRecommendations,
        total_count: recommendations.length,
        generated_at: new Date().toISOString()
      }),
      {
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      }
    )
  } catch (error) {
    console.error('Error in fortune-recommendations:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          'Content-Type': 'application/json',
        },
      }
    )
  }
})