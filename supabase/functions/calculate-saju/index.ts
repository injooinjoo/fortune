import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ============================================================================
// 기본 데이터 정의
// ============================================================================

const TIAN_GAN = ['갑', '을', '병', '정', '무', '기', '경', '신', '임', '계']
const DI_ZHI = ['자', '축', '인', '묘', '진', '사', '오', '미', '신', '유', '술', '해']
const ZODIAC_ANIMALS = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지']

// 천간 → 오행 매핑
const TIAN_GAN_WUXING: Record<string, string> = {
  '갑': '목', '을': '목',
  '병': '화', '정': '화',
  '무': '토', '기': '토',
  '경': '금', '신': '금',
  '임': '수', '계': '수'
}

// 지지 → 오행 매핑
const DI_ZHI_WUXING: Record<string, string> = {
  '자': '수', '축': '토', '인': '목', '묘': '목',
  '진': '토', '사': '화', '오': '화', '미': '토',
  '신': '금', '유': '금', '술': '토', '해': '수'
}

// 지장간 데이터
const JI_JANG_GAN: Record<string, Array<{stem: string, type: string, ratio: number}>> = {
  '자': [{stem: '계', type: 'main', ratio: 100}],
  '축': [{stem: '기', type: 'main', ratio: 60}, {stem: '신', type: 'middle', ratio: 30}, {stem: '계', type: 'remnant', ratio: 10}],
  '인': [{stem: '갑', type: 'main', ratio: 60}, {stem: '병', type: 'middle', ratio: 30}, {stem: '무', type: 'remnant', ratio: 10}],
  '묘': [{stem: '을', type: 'main', ratio: 100}],
  '진': [{stem: '무', type: 'main', ratio: 60}, {stem: '을', type: 'middle', ratio: 30}, {stem: '계', type: 'remnant', ratio: 10}],
  '사': [{stem: '병', type: 'main', ratio: 60}, {stem: '무', type: 'middle', ratio: 30}, {stem: '경', type: 'remnant', ratio: 10}],
  '오': [{stem: '정', type: 'main', ratio: 70}, {stem: '기', type: 'middle', ratio: 30}],
  '미': [{stem: '기', type: 'main', ratio: 60}, {stem: '정', type: 'middle', ratio: 30}, {stem: '을', type: 'remnant', ratio: 10}],
  '신': [{stem: '경', type: 'main', ratio: 60}, {stem: '임', type: 'middle', ratio: 30}, {stem: '무', type: 'remnant', ratio: 10}],
  '유': [{stem: '신', type: 'main', ratio: 100}],
  '술': [{stem: '무', type: 'main', ratio: 60}, {stem: '신', type: 'middle', ratio: 30}, {stem: '정', type: 'remnant', ratio: 10}],
  '해': [{stem: '임', type: 'main', ratio: 70}, {stem: '갑', type: 'middle', ratio: 30}]
}

// 12운성 장생지 (양간 기준)
const TWELVE_STAGES_START: Record<string, number> = {
  '갑': 11, // 해
  '병': 2,  // 인
  '무': 2,  // 인
  '경': 5,  // 사
  '임': 8   // 신
}

const TWELVE_STAGES = ['장생', '목욕', '관대', '건록', '제왕', '쇠', '병', '사', '묘', '절', '태', '양']

// 상생 관계
const SHENG_RELATION: Record<string, string> = {
  '목': '화', '화': '토', '토': '금', '금': '수', '수': '목'
}

// 상극 관계
const KE_RELATION: Record<string, string> = {
  '목': '토', '화': '금', '토': '수', '금': '목', '수': '화'
}

// ============================================================================
// 사주 계산 함수들
// ============================================================================

// 년주 계산 (입춘 기준)
function calculateYearPillar(birthDate: Date): { cheongan: string, jiji: string } {
  let year = birthDate.getFullYear()

  // 입춘 전이면 전년도로 계산 (대략 2월 4일)
  const lichun = new Date(year, 1, 4)
  if (birthDate < lichun) {
    year -= 1
  }

  const ganIndex = (year - 4) % 10
  const zhiIndex = (year - 4) % 12

  return {
    cheongan: TIAN_GAN[ganIndex < 0 ? ganIndex + 10 : ganIndex],
    jiji: DI_ZHI[zhiIndex < 0 ? zhiIndex + 12 : zhiIndex]
  }
}

// 월주 계산 (절기 기준)
function calculateMonthPillar(birthDate: Date, yearCheongan: string): { cheongan: string, jiji: string } {
  const month = birthDate.getMonth() + 1
  const day = birthDate.getDate()

  // 절기 기준 월 결정 (대략적)
  const solarTermDays = [6, 4, 6, 5, 6, 6, 7, 8, 8, 8, 7, 7]
  let lunarMonth = month
  if (day < solarTermDays[month - 1]) {
    lunarMonth = month - 1
    if (lunarMonth === 0) lunarMonth = 12
  }

  // 월지 결정 (인월 = 1월)
  const monthZhiIndex = (lunarMonth + 1) % 12

  // 월간 결정 (연두법)
  const yearGanIndex = TIAN_GAN.indexOf(yearCheongan)
  const baseMonthGan = [2, 4, 6, 8, 0] // 병, 무, 경, 임, 갑
  const monthGanIndex = (baseMonthGan[Math.floor(yearGanIndex / 2)] + lunarMonth - 1) % 10

  return {
    cheongan: TIAN_GAN[monthGanIndex],
    jiji: DI_ZHI[monthZhiIndex]
  }
}

// 일주 계산
function calculateDayPillar(birthDate: Date): { cheongan: string, jiji: string } {
  // 기준일: 1900년 1월 1일 = 갑진일
  const baseDate = new Date(1900, 0, 1)
  const baseDayGanIndex = 0  // 갑
  const baseDayZhiIndex = 4  // 진

  const daysDiff = Math.floor((birthDate.getTime() - baseDate.getTime()) / (1000 * 60 * 60 * 24))

  const ganIndex = ((baseDayGanIndex + daysDiff) % 10 + 10) % 10
  const zhiIndex = ((baseDayZhiIndex + daysDiff) % 12 + 12) % 12

  return {
    cheongan: TIAN_GAN[ganIndex],
    jiji: DI_ZHI[zhiIndex]
  }
}

// 시주 계산
function calculateHourPillar(birthTime: string, dayCheongan: string): { cheongan: string, jiji: string } | null {
  if (!birthTime) return null

  let hour: number

  // "축시 (01:00-03:00)" 형식 처리
  if (birthTime.includes('시')) {
    const shiMap: Record<string, number> = {
      '자시': 0, '축시': 1, '인시': 3, '묘시': 5,
      '진시': 7, '사시': 9, '오시': 11, '미시': 13,
      '신시': 15, '유시': 17, '술시': 19, '해시': 21
    }
    const shiName = birthTime.split(' ')[0]
    hour = shiMap[shiName] ?? 12
  } else {
    // "01:00" 형식
    hour = parseInt(birthTime.split(':')[0])
  }

  // 시지 결정
  const hourZhiIndex = Math.floor((hour + 1) / 2) % 12

  // 시간 결정 (일간 기준)
  const dayGanIndex = TIAN_GAN.indexOf(dayCheongan)
  const baseHourGan = [0, 2, 4, 6, 8] // 갑, 병, 무, 경, 임
  const hourGanIndex = (baseHourGan[Math.floor(dayGanIndex / 2)] + hourZhiIndex) % 10

  return {
    cheongan: TIAN_GAN[hourGanIndex],
    jiji: DI_ZHI[hourZhiIndex]
  }
}

// 오행 균형 계산
function calculateWuxingBalance(pillars: any): Record<string, number> {
  const balance = { 목: 0, 화: 0, 토: 0, 금: 0, 수: 0 }

  // 천간 오행 카운트
  const gans = [pillars.year.cheongan, pillars.month.cheongan, pillars.day.cheongan]
  if (pillars.hour) gans.push(pillars.hour.cheongan)

  gans.forEach(gan => {
    if (gan && TIAN_GAN_WUXING[gan]) {
      balance[TIAN_GAN_WUXING[gan] as keyof typeof balance] += 1
    }
  })

  // 지지 오행 카운트 (지장간 포함)
  const zhis = [pillars.year.jiji, pillars.month.jiji, pillars.day.jiji]
  if (pillars.hour) zhis.push(pillars.hour.jiji)

  zhis.forEach(zhi => {
    if (zhi && JI_JANG_GAN[zhi]) {
      JI_JANG_GAN[zhi].forEach(jjg => {
        const wuxing = TIAN_GAN_WUXING[jjg.stem]
        if (wuxing) {
          balance[wuxing as keyof typeof balance] += jjg.ratio / 100
        }
      })
    }
  })

  return balance
}

// 십신 계산
function calculateTenshin(ilGan: string, targetGan: string): string {
  const ilGanWuxing = TIAN_GAN_WUXING[ilGan]
  const targetWuxing = TIAN_GAN_WUXING[targetGan]

  const ilGanIndex = TIAN_GAN.indexOf(ilGan)
  const targetGanIndex = TIAN_GAN.indexOf(targetGan)
  const isSameYinYang = (ilGanIndex % 2) === (targetGanIndex % 2)

  if (ilGanWuxing === targetWuxing) {
    return isSameYinYang ? '비견' : '겁재'
  } else if (SHENG_RELATION[ilGanWuxing] === targetWuxing) {
    return isSameYinYang ? '식신' : '상관'
  } else if (SHENG_RELATION[targetWuxing] === ilGanWuxing) {
    return isSameYinYang ? '편인' : '정인'
  } else if (KE_RELATION[ilGanWuxing] === targetWuxing) {
    return isSameYinYang ? '편재' : '정재'
  } else {
    return isSameYinYang ? '편관' : '정관'
  }
}

// 12운성 계산
function calculateTwelveStages(dayCheongan: string, zhis: string[]): Record<string, string> {
  const dayGanIndex = TIAN_GAN.indexOf(dayCheongan)
  const isYangGan = dayGanIndex % 2 === 0

  // 양간의 장생지 찾기
  let startZhi: number
  if (isYangGan) {
    startZhi = TWELVE_STAGES_START[dayCheongan] ?? 0
  } else {
    // 음간은 양간의 장생지에서 역행
    const yangGan = TIAN_GAN[dayGanIndex - 1]
    startZhi = TWELVE_STAGES_START[yangGan] ?? 0
  }

  const result: Record<string, string> = {}
  const keys = ['year', 'month', 'day', 'hour']

  zhis.forEach((zhi, idx) => {
    if (!zhi) return
    const zhiIndex = DI_ZHI.indexOf(zhi)
    let stageIndex: number

    if (isYangGan) {
      stageIndex = (zhiIndex - startZhi + 12) % 12
    } else {
      stageIndex = (startZhi - zhiIndex + 12) % 12
    }

    result[keys[idx]] = TWELVE_STAGES[stageIndex]
  })

  return result
}

// 공망 계산
function calculateGongmang(dayCheongan: string, dayJiji: string): string[] {
  const ganIndex = TIAN_GAN.indexOf(dayCheongan)
  const zhiIndex = DI_ZHI.indexOf(dayJiji)

  // 순(旬) 시작점 계산
  const xunStartZhi = ((zhiIndex - ganIndex) % 12 + 12) % 12

  // 공망은 순 시작점의 +10, +11 위치
  const gongmang1 = DI_ZHI[(xunStartZhi + 10) % 12]
  const gongmang2 = DI_ZHI[(xunStartZhi + 11) % 12]

  return [gongmang1, gongmang2]
}

// 합충형파해 계산
function calculateRelations(pillars: any): any {
  const relations = {
    cheongan_hap: [] as string[],
    jiji_yukhap: [] as string[],
    jiji_samhap: [] as string[],
    chung: [] as string[],
    hyung: [] as string[],
    pa: [] as string[],
    hae: [] as string[]
  }

  const gans = [pillars.year.cheongan, pillars.month.cheongan, pillars.day.cheongan]
  const zhis = [pillars.year.jiji, pillars.month.jiji, pillars.day.jiji]
  if (pillars.hour) {
    gans.push(pillars.hour.cheongan)
    zhis.push(pillars.hour.jiji)
  }

  // 천간합 체크
  const tianGanHap = [['갑', '기', '토'], ['을', '경', '금'], ['병', '신', '수'], ['정', '임', '목'], ['무', '계', '화']]
  tianGanHap.forEach(([a, b, result]) => {
    if (gans.includes(a) && gans.includes(b)) {
      relations.cheongan_hap.push(`${a}${b}합${result}`)
    }
  })

  // 지지육합 체크
  const jiZhiYukhap = [['자', '축', '토'], ['인', '해', '목'], ['묘', '술', '화'], ['진', '유', '금'], ['사', '신', '수'], ['오', '미', '토']]
  jiZhiYukhap.forEach(([a, b, result]) => {
    if (zhis.includes(a) && zhis.includes(b)) {
      relations.jiji_yukhap.push(`${a}${b}합${result}`)
    }
  })

  // 충 체크
  const chungPairs = [['자', '오'], ['축', '미'], ['인', '신'], ['묘', '유'], ['진', '술'], ['사', '해']]
  chungPairs.forEach(([a, b]) => {
    if (zhis.includes(a) && zhis.includes(b)) {
      relations.chung.push(`${a}${b}충`)
    }
  })

  return relations
}

// 신살 계산
function calculateSinsal(yearJiji: string, dayJiji: string): { gilsin: string[], hyungsin: string[] } {
  const gilsin: string[] = []
  const hyungsin: string[] = []

  // 역마살 (년지/일지 기준)
  const yeokma: Record<string, string> = {
    '인': '신', '오': '신', '술': '신',
    '해': '사', '묘': '사', '미': '사',
    '신': '인', '자': '인', '진': '인',
    '사': '해', '유': '해', '축': '해'
  }
  if (yeokma[yearJiji]) {
    hyungsin.push(`역마살(${yeokma[yearJiji]})`)
  }

  // 도화살
  const dohwa: Record<string, string> = {
    '인': '묘', '오': '묘', '술': '묘',
    '해': '자', '묘': '자', '미': '자',
    '신': '유', '자': '유', '진': '유',
    '사': '오', '유': '오', '축': '오'
  }
  if (dohwa[yearJiji]) {
    hyungsin.push(`도화살(${dohwa[yearJiji]})`)
  }

  // 천을귀인 (간단 버전)
  gilsin.push('천을귀인')

  return { gilsin, hyungsin }
}

// 오행 보충 방법
function getEnhancementMethod(element: string): string {
  const methods: Record<string, string> = {
    '목': '초록색 옷 착용, 새벽 운동, 동쪽 방향 활동, 식물 키우기',
    '화': '붉은색 소품 활용, 따뜻한 음식, 남쪽 방향 중시, 밝은 조명',
    '토': '노란색 강조, 달콤한 음식, 중앙 위치 선호, 도자기 소품',
    '금': '흰색 의상, 매운 음식, 서쪽 방향 활동, 금속 액세서리',
    '수': '검은색 액세서리, 짠 음식, 북쪽 방향 중시, 물가 산책'
  }
  return methods[element] || ''
}

// ============================================================================
// 메인 핸들러
// ============================================================================

serve(async (req) => {
  console.log('🚀 Calculate-Saju V2 Function invoked:', new Date().toISOString())

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    const { birthDate, birthTime, isLunar = false, timezone = 'Asia/Seoul' } = await req.json()
    console.log('📦 Request data:', { birthDate, birthTime, isLunar, timezone })

    // 사용자 인증
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Authorization header is required')
    }

    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabase.auth.getUser(token)

    if (authError || !user) {
      throw new Error('Invalid authorization token')
    }

    console.log('🔐 User authenticated:', user.id)

    // 기존 사주 데이터 확인
    const { data: existingSaju } = await supabase
      .from('user_saju')
      .select('*')
      .eq('user_id', user.id)
      .maybeSingle()

    if (existingSaju && existingSaju.calculation_version === 'v2.0') {
      console.log('✅ Saju v2.0 already exists, returning cached data')
      return new Response(
        JSON.stringify({ success: true, data: existingSaju, cached: true }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // 사주팔자 계산
    const date = new Date(birthDate)
    console.log('🔮 Calculating Saju for:', date.toISOString())

    // 4주 계산
    const yearPillar = calculateYearPillar(date)
    const monthPillar = calculateMonthPillar(date, yearPillar.cheongan)
    const dayPillar = calculateDayPillar(date)
    const hourPillar = calculateHourPillar(birthTime, dayPillar.cheongan)

    const pillars = {
      year: yearPillar,
      month: monthPillar,
      day: dayPillar,
      hour: hourPillar
    }

    console.log('📊 Calculated pillars:', pillars)

    // 오행 균형
    const wuxingBalance = calculateWuxingBalance(pillars)
    const sortedWuxing = Object.entries(wuxingBalance).sort((a, b) => a[1] - b[1])
    const weakElement = sortedWuxing[0][0]
    const strongElement = sortedWuxing[sortedWuxing.length - 1][0]

    // 십신 계산
    const ilGan = dayPillar.cheongan
    const tenshin = {
      year: {
        cheongan: calculateTenshin(ilGan, yearPillar.cheongan),
        jiji: calculateTenshin(ilGan, JI_JANG_GAN[yearPillar.jiji][0].stem)
      },
      month: {
        cheongan: calculateTenshin(ilGan, monthPillar.cheongan),
        jiji: calculateTenshin(ilGan, JI_JANG_GAN[monthPillar.jiji][0].stem)
      },
      day: {
        jiji: calculateTenshin(ilGan, JI_JANG_GAN[dayPillar.jiji][0].stem)
      },
      hour: hourPillar ? {
        cheongan: calculateTenshin(ilGan, hourPillar.cheongan),
        jiji: calculateTenshin(ilGan, JI_JANG_GAN[hourPillar.jiji][0].stem)
      } : null
    }

    // 지장간
    const jijanggan = {
      year: JI_JANG_GAN[yearPillar.jiji],
      month: JI_JANG_GAN[monthPillar.jiji],
      day: JI_JANG_GAN[dayPillar.jiji],
      hour: hourPillar ? JI_JANG_GAN[hourPillar.jiji] : null
    }

    // 12운성
    const zhis = [yearPillar.jiji, monthPillar.jiji, dayPillar.jiji, hourPillar?.jiji].filter(Boolean) as string[]
    const twelveStages = calculateTwelveStages(ilGan, zhis)

    // 공망
    const gongmang = calculateGongmang(dayPillar.cheongan, dayPillar.jiji)

    // 합충형파해
    const relations = calculateRelations(pillars)

    // 신살
    const sinsal = calculateSinsal(yearPillar.jiji, dayPillar.jiji)

    // LLM 분석 (선택적)
    let gptAnalysis = null
    const openAIApiKey = Deno.env.get('OPENAI_API_KEY')

    if (openAIApiKey) {
      try {
        const llm = await LLMFactory.createFromConfigAsync('saju')

        const systemPrompt = `당신은 한국의 전통 사주명리학 전문가입니다.
주어진 사주 정보를 바탕으로 깊이 있는 분석을 JSON으로 제공하세요.
절대로 "분석 중", "알 수 없음" 같은 표현을 사용하지 마세요.
반드시 구체적이고 긍정적인 내용으로 작성하세요.`

        const userPrompt = `사주 분석:
- 년주: ${yearPillar.cheongan}${yearPillar.jiji}
- 월주: ${monthPillar.cheongan}${monthPillar.jiji}
- 일주: ${dayPillar.cheongan}${dayPillar.jiji}
- 시주: ${hourPillar ? `${hourPillar.cheongan}${hourPillar.jiji}` : '미상'}
- 일간(나): ${ilGan} (${TIAN_GAN_WUXING[ilGan]})
- 오행균형: 목${wuxingBalance.목.toFixed(1)}, 화${wuxingBalance.화.toFixed(1)}, 토${wuxingBalance.토.toFixed(1)}, 금${wuxingBalance.금.toFixed(1)}, 수${wuxingBalance.수.toFixed(1)}
- 부족한오행: ${weakElement}
- 12운성: ${JSON.stringify(twelveStages)}
- 공망: ${gongmang.join(', ')}

JSON 형식으로 응답: {personality_traits, fortune_summary, career_fortune, wealth_fortune, love_fortune, health_fortune, yearly_forecast, life_advice}`

        const response = await llm.generate([
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt }
        ], { temperature: 0.7, maxTokens: 4096, jsonMode: true })

        if (response.content) {
          gptAnalysis = JSON.parse(response.content)
          console.log('✅ GPT analysis completed')

          await UsageLogger.log({
            fortuneType: 'calculate-saju-v2',
            userId: user.id,
            provider: response.provider,
            model: response.model,
            response: response
          })
        }
      } catch (e) {
        console.log('⚠️ GPT analysis failed, using defaults:', e)
      }
    }

    // 천간/지지 한자 매핑
    const ganjaHanja: Record<string, string> = {
      '갑': '甲', '을': '乙', '병': '丙', '정': '丁', '무': '戊',
      '기': '己', '경': '庚', '신': '辛', '임': '壬', '계': '癸',
      '자': '子', '축': '丑', '인': '寅', '묘': '卯', '진': '辰',
      '사': '巳', '오': '午', '미': '未', '신': '申', '유': '酉',
      '술': '戌', '해': '亥'
    }

    // 완전한 사주 데이터 구성 (기존 스키마 + v2.0 확장)
    const completeSajuData = {
      user_id: user.id,
      birth_date: birthDate,
      birth_time: birthTime || null,
      birth_time_type: birthTime?.includes('시') ? birthTime.split(' ')[0] : null,
      is_lunar: isLunar,
      timezone: timezone,

      // 4주8자 (기존 스키마: year_stem, year_branch 사용)
      year_stem: yearPillar.cheongan,
      year_branch: yearPillar.jiji,
      month_stem: monthPillar.cheongan,
      month_branch: monthPillar.jiji,
      day_stem: dayPillar.cheongan,
      day_branch: dayPillar.jiji,
      hour_stem: hourPillar?.cheongan || null,
      hour_branch: hourPillar?.jiji || null,

      // 한자 표기
      year_stem_hanja: ganjaHanja[yearPillar.cheongan] || '',
      year_branch_hanja: ganjaHanja[yearPillar.jiji] || '',
      month_stem_hanja: ganjaHanja[monthPillar.cheongan] || '',
      month_branch_hanja: ganjaHanja[monthPillar.jiji] || '',
      day_stem_hanja: ganjaHanja[dayPillar.cheongan] || '',
      day_branch_hanja: ganjaHanja[dayPillar.jiji] || '',
      hour_stem_hanja: hourPillar ? ganjaHanja[hourPillar.cheongan] || '' : null,
      hour_branch_hanja: hourPillar ? ganjaHanja[hourPillar.jiji] || '' : null,

      // 기존 스키마 호환 (element_balance JSONB)
      element_balance: {
        목: Math.round(wuxingBalance.목 * 10) / 10,
        화: Math.round(wuxingBalance.화 * 10) / 10,
        토: Math.round(wuxingBalance.토 * 10) / 10,
        금: Math.round(wuxingBalance.금 * 10) / 10,
        수: Math.round(wuxingBalance.수 * 10) / 10
      },
      dominant_element: strongElement,
      lacking_element: weakElement,

      // 기존 스키마 호환 (ten_gods)
      ten_gods: {
        year: [tenshin.year.cheongan],
        month: [tenshin.month.cheongan],
        hour: hourPillar ? [tenshin.hour!.cheongan] : []
      },

      // 기존 스키마 호환 (spirits)
      spirits: [...sinsal.gilsin, ...sinsal.hyungsin],

      // 오행
      element_wood: Math.round(wuxingBalance.목 * 10) / 10,
      element_fire: Math.round(wuxingBalance.화 * 10) / 10,
      element_earth: Math.round(wuxingBalance.토 * 10) / 10,
      element_metal: Math.round(wuxingBalance.금 * 10) / 10,
      element_water: Math.round(wuxingBalance.수 * 10) / 10,
      weak_element: weakElement,
      strong_element: strongElement,
      enhancement_method: getEnhancementMethod(weakElement),

      // 십신
      tenshin_year: tenshin.year,
      tenshin_month: tenshin.month,
      tenshin_day: tenshin.day,
      tenshin_hour: tenshin.hour,

      // 지장간
      jijanggan_year: jijanggan.year,
      jijanggan_month: jijanggan.month,
      jijanggan_day: jijanggan.day,
      jijanggan_hour: jijanggan.hour,

      // 12운성
      twelve_stages: twelveStages,

      // 관계
      relations: relations,

      // 신살
      sinsal_gilsin: sinsal.gilsin,
      sinsal_hyungsin: sinsal.hyungsin,

      // 공망
      gongmang: gongmang,

      // LLM 분석 (v2.0 스키마)
      personality_traits: gptAnalysis?.personality_traits || `${ilGan}일간의 특성으로 ${TIAN_GAN_WUXING[ilGan]}의 기운이 강합니다.`,
      fortune_summary: gptAnalysis?.fortune_summary || `${weakElement}의 보충이 필요하며, ${strongElement}의 기운을 활용하면 좋습니다.`,
      career_fortune: gptAnalysis?.career_fortune || null,
      wealth_fortune: gptAnalysis?.wealth_fortune || null,
      love_fortune: gptAnalysis?.love_fortune || null,
      health_fortune: gptAnalysis?.health_fortune || null,
      yearly_forecast: gptAnalysis?.yearly_forecast || null,
      life_advice: gptAnalysis?.life_advice || null,
      gpt_analysis: gptAnalysis,

      // 기존 스키마 호환 (v1.0 컬럼)
      interpretation: gptAnalysis?.fortune_summary || `${ilGan}일간의 사주로, ${strongElement}의 기운이 강하고 ${weakElement}이 부족합니다.`,
      personality_analysis: gptAnalysis?.personality_traits || `${TIAN_GAN_WUXING[ilGan]}의 성정을 가진 ${ilGan}일간입니다.`,
      career_guidance: gptAnalysis?.career_fortune || `${strongElement}의 기운을 활용한 직업이 적합합니다.`,
      relationship_advice: gptAnalysis?.love_fortune || `${TIAN_GAN_WUXING[ilGan]}의 성향에 맞는 관계를 추구하세요.`,

      calculation_version: 'v2.0',
      updated_at: new Date().toISOString()
    }

    // 데이터베이스 저장 (upsert)
    const { data: savedData, error: saveError } = await supabase
      .from('user_saju')
      .upsert(completeSajuData, { onConflict: 'user_id' })
      .select()
      .single()

    if (saveError) {
      console.error('❌ Error saving saju:', saveError)
      throw new Error(`사주 저장 오류: ${saveError.message}`)
    }

    // user_profiles 업데이트
    await supabase
      .from('user_profiles')
      .update({ saju_calculated: true, updated_at: new Date().toISOString() })
      .eq('id', user.id)

    console.log('✅ Complete saju v2.0 calculated and saved')

    return new Response(
      JSON.stringify({ success: true, data: savedData, cached: false, version: 'v2.0' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Error:', error)
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 500 }
    )
  }
})
