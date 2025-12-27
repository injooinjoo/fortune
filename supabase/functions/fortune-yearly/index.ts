/**
 * 연간 운세 (Yearly Fortune) Edge Function
 *
 * @description 사용자의 생년월일, 사주 정보를 바탕으로 AI 기반 연간 운세를 생성합니다.
 *
 * @endpoint POST /fortune-yearly
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - name?: string - 사용자 이름
 * - birthDate: string - 생년월일 (YYYY-MM-DD)
 * - birthTime?: string - 출생 시간
 * - gender: 'male' | 'female' - 성별
 * - isLunar?: boolean - 음력 여부
 * - zodiacSign?: string - 별자리
 * - zodiacAnimal?: string - 띠
 * - targetYear?: number - 운세를 볼 연도 (기본값: 현재 연도)
 * - focusArea?: string - 집중 분야 (종합/재물/연애/건강/직업)
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response YearlyFortuneResponse
 * - score: number (1-100) - 연간 종합 운세 점수
 * - content: string - 연간 운세 요약
 * - summary: string - 한줄 요약
 * - advice: string - 연간 조언
 * - monthlyForecast: Array - 월별 운세
 * - quarterlyOverview: Object - 분기별 개요
 * - luckyItems: Object - 행운 아이템
 * - keyDates: Array - 주요 길일
 * - percentile: number - 상위 백분위
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile } from '../_shared/percentile/calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// UTF-8 안전한 해시 생성 함수
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

// 시드 기반 난수 생성 함수
function seededRandom(seed: number): number {
  const x = Math.sin(seed) * 10000
  return x - Math.floor(x)
}

// 띠 계산
function getZodiacAnimal(birthYear: number): string {
  const animals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양']
  return animals[birthYear % 12]
}

// 별자리 계산
function getZodiacSign(month: number, day: number): string {
  const signs = [
    { name: '염소자리', start: [1, 1], end: [1, 19] },
    { name: '물병자리', start: [1, 20], end: [2, 18] },
    { name: '물고기자리', start: [2, 19], end: [3, 20] },
    { name: '양자리', start: [3, 21], end: [4, 19] },
    { name: '황소자리', start: [4, 20], end: [5, 20] },
    { name: '쌍둥이자리', start: [5, 21], end: [6, 21] },
    { name: '게자리', start: [6, 22], end: [7, 22] },
    { name: '사자자리', start: [7, 23], end: [8, 22] },
    { name: '처녀자리', start: [8, 23], end: [9, 22] },
    { name: '천칭자리', start: [9, 23], end: [10, 22] },
    { name: '전갈자리', start: [10, 23], end: [11, 21] },
    { name: '사수자리', start: [11, 22], end: [12, 21] },
    { name: '염소자리', start: [12, 22], end: [12, 31] },
  ]

  for (const sign of signs) {
    const [startMonth, startDay] = sign.start
    const [endMonth, endDay] = sign.end

    if (
      (month === startMonth && day >= startDay) ||
      (month === endMonth && day <= endDay)
    ) {
      return sign.name
    }
  }

  return '염소자리'
}

// 월별 테마
const monthlyThemes: Record<number, string> = {
  1: '새해 시작과 계획',
  2: '겨울의 마무리와 정리',
  3: '봄의 시작과 새로운 도전',
  4: '성장과 발전의 시기',
  5: '풍요와 활력의 계절',
  6: '여름 준비와 에너지 충전',
  7: '본격적인 활동의 시기',
  8: '열정과 성취의 계절',
  9: '가을 수확과 결실',
  10: '변화와 전환의 시기',
  11: '감사와 정리의 시간',
  12: '한 해 마무리와 성찰'
}

serve(async (req) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    )

    const requestData = await req.json()
    const {
      userId,
      name = '사용자',
      birthDate,
      birthTime,
      gender,
      isLunar = false,
      zodiacSign: inputZodiacSign,
      zodiacAnimal: inputZodiacAnimal,
      targetYear,
      focusArea = '종합',
      isPremium = false,
      saju
    } = requestData

    console.log('📅 [Yearly] 연간 운세 요청:', { userId, name, birthDate, targetYear, focusArea, isPremium })

    if (!userId || !birthDate) {
      return new Response(
        JSON.stringify({ error: 'userId와 birthDate는 필수입니다.' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 연도 설정
    const currentYear = new Date().getFullYear()
    const year = targetYear || currentYear

    // 생년월일 파싱
    const birthDateObj = new Date(birthDate)
    const birthYear = birthDateObj.getFullYear()
    const birthMonth = birthDateObj.getMonth() + 1
    const birthDay = birthDateObj.getDate()

    // 띠와 별자리 계산
    const zodiacAnimal = inputZodiacAnimal || getZodiacAnimal(birthYear)
    const zodiacSign = inputZodiacSign || getZodiacSign(birthMonth, birthDay)

    // 시드 생성 (연도 + 생년월일 기반으로 일관된 결과)
    const combinedSeed = birthYear * 10000 + birthMonth * 100 + birthDay + year

    // 캐시 확인
    const today = new Date().toISOString().split('T')[0]
    const cacheKey = await createHash(`yearly-${userId}-${year}-${focusArea}-${today}`)

    const { data: cachedData } = await supabaseClient
      .from('fortune_cache')
      .select('*')
      .eq('cache_key', cacheKey)
      .eq('fortune_type', 'yearly')
      .single()

    if (cachedData?.fortune_data) {
      console.log('✅ [Yearly] 캐시된 결과 반환')
      return new Response(
        JSON.stringify({ success: true, data: cachedData.fortune_data, cached: true, tokensUsed: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 연간 점수 생성 (60-95점 범위, 띠와 연도에 따라 변동)
    const yearAnimalIndex = year % 12
    const birthAnimalIndex = birthYear % 12
    const animalCompatibility = Math.abs(yearAnimalIndex - birthAnimalIndex)
    const baseScore = 70 + Math.floor(seededRandom(combinedSeed) * 20)
    const compatibilityBonus = animalCompatibility <= 3 ? 5 : (animalCompatibility >= 6 ? -5 : 0)
    const overallScore = Math.min(95, Math.max(60, baseScore + compatibilityBonus))

    // 월별 운세 생성
    const monthlyForecast = Array.from({ length: 12 }, (_, i) => {
      const month = i + 1
      const monthSeed = combinedSeed + month * 100
      const monthScore = 55 + Math.floor(seededRandom(monthSeed) * 40)

      return {
        month,
        monthName: `${month}월`,
        score: monthScore,
        theme: monthlyThemes[month],
        luckyDay: Math.floor(seededRandom(monthSeed + 1) * 28) + 1,
        advice: generateMonthlyAdvice(month, monthScore, monthSeed),
        highlight: getMonthHighlight(monthScore)
      }
    })

    // 분기별 개요
    const quarterlyOverview = {
      Q1: {
        months: '1~3월',
        score: Math.round((monthlyForecast[0].score + monthlyForecast[1].score + monthlyForecast[2].score) / 3),
        theme: '새로운 시작과 계획 수립의 시기',
        advice: '연초의 에너지를 활용해 큰 목표를 세우고 첫걸음을 내딛으세요.'
      },
      Q2: {
        months: '4~6월',
        score: Math.round((monthlyForecast[3].score + monthlyForecast[4].score + monthlyForecast[5].score) / 3),
        theme: '성장과 발전의 시기',
        advice: '봄의 활력으로 새로운 도전과 학습에 집중하세요.'
      },
      Q3: {
        months: '7~9월',
        score: Math.round((monthlyForecast[6].score + monthlyForecast[7].score + monthlyForecast[8].score) / 3),
        theme: '열정과 실행의 시기',
        advice: '여름의 에너지로 중요한 프로젝트를 추진하세요.'
      },
      Q4: {
        months: '10~12월',
        score: Math.round((monthlyForecast[9].score + monthlyForecast[10].score + monthlyForecast[11].score) / 3),
        theme: '수확과 마무리의 시기',
        advice: '한 해를 정리하고 다음 해를 준비하는 시간입니다.'
      }
    }

    // 행운 아이템
    const luckyColors = ['레드', '블루', '그린', '옐로우', '퍼플', '오렌지', '핑크', '화이트', '블랙', '골드']
    const luckyDirections = ['동쪽', '서쪽', '남쪽', '북쪽', '동남쪽', '동북쪽', '서남쪽', '서북쪽']
    const luckyNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]

    const luckyItems = {
      color: luckyColors[Math.floor(seededRandom(combinedSeed + 100) * luckyColors.length)],
      direction: luckyDirections[Math.floor(seededRandom(combinedSeed + 200) * luckyDirections.length)],
      number: luckyNumbers[Math.floor(seededRandom(combinedSeed + 300) * luckyNumbers.length)],
      month: monthlyForecast.reduce((best, m) => m.score > best.score ? m : best).month,
      item: getLuckyItem(combinedSeed)
    }

    // 주요 길일
    const keyDates = generateKeyDates(year, monthlyForecast, combinedSeed)

    // 카테고리별 운세
    const categories = {
      love: {
        score: 50 + Math.floor(seededRandom(combinedSeed + 1000) * 45),
        outlook: generateCategoryOutlook('love', combinedSeed + 1000),
        bestMonth: monthlyForecast.reduce((best, m, i) =>
          seededRandom(combinedSeed + 1000 + i) > seededRandom(combinedSeed + 1000 + (best.month - 1)) ? m : best
        ).month
      },
      money: {
        score: 50 + Math.floor(seededRandom(combinedSeed + 2000) * 45),
        outlook: generateCategoryOutlook('money', combinedSeed + 2000),
        bestMonth: monthlyForecast.reduce((best, m, i) =>
          seededRandom(combinedSeed + 2000 + i) > seededRandom(combinedSeed + 2000 + (best.month - 1)) ? m : best
        ).month
      },
      health: {
        score: 50 + Math.floor(seededRandom(combinedSeed + 3000) * 45),
        outlook: generateCategoryOutlook('health', combinedSeed + 3000),
        bestMonth: monthlyForecast.reduce((best, m, i) =>
          seededRandom(combinedSeed + 3000 + i) > seededRandom(combinedSeed + 3000 + (best.month - 1)) ? m : best
        ).month
      },
      career: {
        score: 50 + Math.floor(seededRandom(combinedSeed + 4000) * 45),
        outlook: generateCategoryOutlook('career', combinedSeed + 4000),
        bestMonth: monthlyForecast.reduce((best, m, i) =>
          seededRandom(combinedSeed + 4000 + i) > seededRandom(combinedSeed + 4000 + (best.month - 1)) ? m : best
        ).month
      }
    }

    // 연간 주요 테마
    const yearlyThemes = generateYearlyThemes(year, zodiacAnimal, overallScore, combinedSeed)

    // 조언 생성
    const yearlyAdvice = generateYearlyAdvice(overallScore, zodiacAnimal, year)

    // 요약 생성
    const summary = `${year}년 ${name}님의 운세 종합점수 ${overallScore}점, ${zodiacAnimal}띠의 ${getScoreGrade(overallScore)} 운세`
    const content = `${year}년은 ${name}님에게 ${yearlyThemes[0]}의 해가 될 것입니다. ` +
      `특히 ${luckyItems.month}월에 가장 좋은 운이 기대되며, ` +
      `${luckyItems.color} 컬러와 ${luckyItems.direction} 방향이 행운을 불러올 것입니다.`

    // 블러 처리 (비프리미엄 사용자)
    const isBlurred = !isPremium
    const blurredSections = isBlurred ? ['monthlyForecast', 'keyDates', 'categories'] : []

    // 퍼센타일 계산
    const percentileData = await calculatePercentile(supabaseClient, 'yearly', overallScore)
    console.log(`📊 [Yearly] Percentile: ${percentileData.isPercentileValid ? `상위 ${percentileData.percentile}%` : '데이터 부족'}`)

    // 응답 데이터 구성
    const fortuneData = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'yearly',
      score: overallScore,
      content,
      summary,
      advice: yearlyAdvice,

      // 기존 필드 유지 (하위 호환성)
      id: `yearly-${year}-${Date.now()}`,
      userId,
      type: 'yearly',
      year,
      name,
      birthDate,
      gender,
      zodiacAnimal,
      zodiacSign,
      focusArea,

      // 연간 운세 상세
      overallScore,
      yearlyThemes,
      monthlyForecast: isBlurred ? monthlyForecast.map(m => ({ ...m, advice: '프리미엄 전용 콘텐츠입니다.' })) : monthlyForecast,
      quarterlyOverview,
      categories: isBlurred ? {
        love: { ...categories.love, outlook: '프리미엄 전용 콘텐츠입니다.' },
        money: { ...categories.money, outlook: '프리미엄 전용 콘텐츠입니다.' },
        health: { ...categories.health, outlook: '프리미엄 전용 콘텐츠입니다.' },
        career: { ...categories.career, outlook: '프리미엄 전용 콘텐츠입니다.' }
      } : categories,
      luckyItems,
      keyDates: isBlurred ? keyDates.slice(0, 2) : keyDates,

      // 블러 및 퍼센타일 정보
      isBlurred,
      blurredSections,
      percentile: percentileData.percentile,
      totalViewers: percentileData.totalTodayViewers,
      isPercentileValid: percentileData.isPercentileValid,

      // 메타데이터
      timestamp: new Date().toISOString(),
      generatedAt: new Date().toISOString()
    }

    // 캐시 저장 (1년간 유효)
    try {
      await supabaseClient.from('fortune_cache').upsert({
        cache_key: cacheKey,
        user_id: userId,
        fortune_type: 'yearly',
        fortune_data: fortuneData,
        overall_score: overallScore,
        created_at: new Date().toISOString(),
        expires_at: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString()
      })
      console.log('💾 [Yearly] 캐시 저장 완료')
    } catch (cacheError) {
      console.warn('⚠️ [Yearly] 캐시 저장 실패 (무시):', cacheError)
    }

    return new Response(
      JSON.stringify({
        success: true,
        data: fortuneData,
        cached: false,
        tokensUsed: 0
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
    )

  } catch (error) {
    console.error('❌ [Yearly] Error:', error)
    return new Response(
      JSON.stringify({ error: 'Failed to generate yearly fortune', message: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

// 월별 조언 생성
function generateMonthlyAdvice(month: number, score: number, seed: number): string {
  const advices = {
    high: [
      '적극적으로 새로운 도전을 시도해보세요.',
      '중요한 결정을 내리기에 좋은 시기입니다.',
      '기회가 찾아올 때 망설이지 마세요.',
      '인간관계에서 좋은 소식이 있을 것입니다.'
    ],
    medium: [
      '꾸준한 노력이 성과로 이어질 것입니다.',
      '차분하게 계획을 실행해 나가세요.',
      '작은 성취에도 감사하는 마음을 가지세요.',
      '균형 잡힌 생활을 유지하세요.'
    ],
    low: [
      '무리하지 말고 휴식을 취하세요.',
      '신중한 판단이 필요한 시기입니다.',
      '주변 사람들의 조언에 귀 기울이세요.',
      '내면의 힘을 기르는 데 집중하세요.'
    ]
  }

  const level = score >= 75 ? 'high' : (score >= 55 ? 'medium' : 'low')
  const adviceList = advices[level]
  return adviceList[Math.floor(seededRandom(seed) * adviceList.length)]
}

// 월별 하이라이트
function getMonthHighlight(score: number): string {
  if (score >= 85) return '대길'
  if (score >= 75) return '길'
  if (score >= 60) return '평'
  return '주의'
}

// 행운 아이템
function getLuckyItem(seed: number): string {
  const items = ['열쇠', '거울', '시계', '책', '펜', '지갑', '반지', '목걸이', '수첩', '향수']
  return items[Math.floor(seededRandom(seed + 500) * items.length)]
}

// 주요 길일 생성
function generateKeyDates(year: number, monthlyForecast: any[], seed: number): any[] {
  const keyDates = []
  const topMonths = [...monthlyForecast].sort((a, b) => b.score - a.score).slice(0, 4)

  for (const month of topMonths) {
    const day = Math.floor(seededRandom(seed + month.month * 50) * 25) + 1
    keyDates.push({
      date: `${year}-${String(month.month).padStart(2, '0')}-${String(day).padStart(2, '0')}`,
      type: month.score >= 80 ? '대길일' : '길일',
      description: `${month.month}월의 가장 좋은 날`,
      recommendation: month.score >= 80 ? '중요한 일을 시작하기 좋은 날입니다.' : '새로운 시도에 적합한 날입니다.'
    })
  }

  return keyDates
}

// 카테고리별 전망
function generateCategoryOutlook(category: string, seed: number): string {
  const outlooks = {
    love: [
      '새로운 인연이 찾아올 가능성이 높습니다.',
      '현재 관계가 더욱 깊어질 수 있는 해입니다.',
      '솔직한 감정 표현이 좋은 결과를 가져올 것입니다.',
      '연인과의 소통을 중요시하세요.'
    ],
    money: [
      '재물운이 상승하는 해입니다.',
      '투자보다는 저축에 집중하세요.',
      '새로운 수입원이 생길 수 있습니다.',
      '계획적인 소비가 중요합니다.'
    ],
    health: [
      '건강 관리에 더욱 신경 써야 합니다.',
      '규칙적인 운동이 도움이 될 것입니다.',
      '스트레스 관리가 중요한 해입니다.',
      '정기 검진을 잊지 마세요.'
    ],
    career: [
      '경력 발전의 기회가 있을 것입니다.',
      '새로운 프로젝트에서 성과를 낼 수 있습니다.',
      '인맥 관리가 중요한 해입니다.',
      '자기계발에 투자하세요.'
    ]
  }

  const list = outlooks[category] || outlooks.career
  return list[Math.floor(seededRandom(seed) * list.length)]
}

// 연간 테마 생성
function generateYearlyThemes(year: number, zodiacAnimal: string, score: number, seed: number): string[] {
  const themes = [
    '성장과 발전', '안정과 평화', '새로운 시작', '인연과 소통',
    '도전과 성취', '지혜와 통찰', '풍요와 번영', '변화와 적응'
  ]

  const selectedThemes = []
  const indices = new Set<number>()

  while (selectedThemes.length < 3) {
    const index = Math.floor(seededRandom(seed + selectedThemes.length * 10) * themes.length)
    if (!indices.has(index)) {
      indices.add(index)
      selectedThemes.push(themes[index])
    }
  }

  return selectedThemes
}

// 연간 조언 생성
function generateYearlyAdvice(score: number, zodiacAnimal: string, year: number): string {
  if (score >= 85) {
    return `${year}년은 ${zodiacAnimal}띠에게 매우 좋은 해입니다. 자신감을 가지고 적극적으로 도전하세요. 기회가 왔을 때 주저하지 마시고, 주변 사람들과의 관계도 소중히 여기세요.`
  } else if (score >= 70) {
    return `${year}년은 꾸준한 노력이 결실을 맺는 해입니다. 급하게 서두르기보다는 차근차근 목표를 향해 나아가세요. 작은 성취들이 모여 큰 성과가 될 것입니다.`
  } else if (score >= 55) {
    return `${year}년은 내면을 다지는 시기입니다. 외부의 성과보다는 자기 자신을 돌아보고 성장하는 데 집중하세요. 인내심을 가지고 기다리면 좋은 결과가 올 것입니다.`
  } else {
    return `${year}년은 신중함이 필요한 해입니다. 큰 변화보다는 현재 상태를 안정적으로 유지하는 것이 좋습니다. 건강과 인간관계에 특별히 신경 쓰세요.`
  }
}

// 점수 등급
function getScoreGrade(score: number): string {
  if (score >= 90) return '대길'
  if (score >= 80) return '길'
  if (score >= 70) return '중길'
  if (score >= 60) return '평'
  return '소길'
}
