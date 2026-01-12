/**
 * 궁합 운세 (Compatibility Fortune) Edge Function
 *
 * @description 두 사람의 생년월일을 기반으로 사주 궁합을 분석합니다.
 *
 * @endpoint POST /fortune-compatibility
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - person1: { name: string, birthDate: string, gender: string, birthTime?: string }
 * - person2: { name: string, birthDate: string, gender: string, birthTime?: string }
 * - compatibilityType?: 'love' | 'friendship' | 'business' - 궁합 유형
 *
 * @response CompatibilityResponse
 * - overall_score: number (1-100) - 종합 궁합 점수
 * - compatibility_grade: string - 궁합 등급 (천생연분, 좋음, 보통, 노력필요)
 * - categories: { emotion, values, lifestyle, future } - 카테고리별 점수
 * - strengths: string[] - 장점
 * - challenges: string[] - 과제
 * - advice: string - 조언
 * - percentile: number - 상위 백분위
 *
 * @example
 * curl -X POST https://xxx.supabase.co/functions/v1/fortune-compatibility \
 *   -H "Authorization: Bearer <token>" \
 *   -d '{"userId":"xxx","person1":{...},"person2":{...}}'
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractCompatibilityCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

// 환경 변수 설정
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

// Supabase 클라이언트 생성
const supabase = createClient(supabaseUrl, supabaseKey)

// UTF-8 안전한 해시 생성 함수 (btoa는 Latin1만 지원하여 한글 불가)
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

// 이름 궁합 숫자 계산 (한글 자음/모음 개수)
function calculateNameCompatibility(name1: string, name2: string): number {
  const countChars = (name: string): number => {
    const chars = name.split('')
    return chars.reduce((count, char) => {
      const code = char.charCodeAt(0)
      if (code >= 0xAC00 && code <= 0xD7A3) {
        // 한글 음절 분해
        const syllable = code - 0xAC00
        const jong = syllable % 28
        return count + (jong === 0 ? 2 : 3) // 받침 없으면 2, 있으면 3
      }
      return count + 1
    }, 0)
  }

  const combined = countChars(name1) + countChars(name2)
  return combined % 100 // 0-99 범위
}

// 12띠 계산
function getZodiacAnimal(birthDate: string): string {
  const year = parseInt(birthDate.substring(0, 4))
  const animals = ['원숭이', '닭', '개', '돼지', '쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양']
  return animals[year % 12]
}

// 띠 궁합 평가
function getZodiacCompatibility(animal1: string, animal2: string): { score: number; message: string } {
  const compatibility: Record<string, Record<string, { score: number; message: string }>> = {
    '쥐': { '소': { score: 90, message: '최고의 궁합' }, '용': { score: 95, message: '천생연분' }, '원숭이': { score: 90, message: '대길' } },
    '소': { '쥐': { score: 90, message: '최고의 궁합' }, '뱀': { score: 95, message: '천생연분' }, '닭': { score: 90, message: '대길' } },
    '호랑이': { '말': { score: 90, message: '최고의 궁합' }, '개': { score: 95, message: '천생연분' } },
    '토끼': { '양': { score: 90, message: '최고의 궁합' }, '돼지': { score: 95, message: '천생연분' }, '개': { score: 85, message: '좋음' } },
    '용': { '쥐': { score: 95, message: '천생연분' }, '원숭이': { score: 90, message: '대길' }, '닭': { score: 85, message: '좋음' } },
    '뱀': { '소': { score: 95, message: '천생연분' }, '닭': { score: 90, message: '대길' } },
    '말': { '호랑이': { score: 90, message: '최고의 궁합' }, '양': { score: 85, message: '좋음' }, '개': { score: 90, message: '대길' } },
    '양': { '토끼': { score: 90, message: '최고의 궁합' }, '말': { score: 85, message: '좋음' }, '돼지': { score: 90, message: '대길' } },
    '원숭이': { '쥐': { score: 90, message: '대길' }, '용': { score: 90, message: '최고의 궁합' } },
    '닭': { '소': { score: 90, message: '대길' }, '뱀': { score: 90, message: '최고의 궁합' }, '용': { score: 85, message: '좋음' } },
    '개': { '호랑이': { score: 95, message: '천생연분' }, '토끼': { score: 85, message: '좋음' }, '말': { score: 90, message: '대길' } },
    '돼지': { '토끼': { score: 95, message: '천생연분' }, '양': { score: 90, message: '대길' } }
  }

  return compatibility[animal1]?.[animal2] || { score: 70, message: '무난함' }
}

// 별자리 계산
function getZodiacSign(birthDate: string): string {
  const month = parseInt(birthDate.substring(5, 7))
  const day = parseInt(birthDate.substring(8, 10))

  if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return '양자리'
  if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return '황소자리'
  if ((month === 5 && day >= 21) || (month === 6 && day <= 21)) return '쌍둥이자리'
  if ((month === 6 && day >= 22) || (month === 7 && day <= 22)) return '게자리'
  if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return '사자자리'
  if ((month === 8 && day >= 23) || (month === 9 && day <= 23)) return '처녀자리'
  if ((month === 9 && day >= 24) || (month === 10 && day <= 22)) return '천칭자리'
  if ((month === 10 && day >= 23) || (month === 11 && day <= 22)) return '전갈자리'
  if ((month === 11 && day >= 23) || (month === 12 && day <= 21)) return '사수자리'
  if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return '염소자리'
  if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return '물병자리'
  return '물고기자리'
}

// 별자리 궁합 평가
function getStarSignCompatibility(sign1: string, sign2: string): { score: number; message: string } {
  const compatibility: Record<string, Record<string, { score: number; message: string }>> = {
    '양자리': { '사자자리': { score: 95, message: '불꽃 튀는 열정' }, '사수자리': { score: 90, message: '최고의 케미' } },
    '황소자리': { '처녀자리': { score: 95, message: '안정적 관계' }, '염소자리': { score: 90, message: '현실적 파트너' } },
    '쌍둥이자리': { '천칭자리': { score: 95, message: '완벽한 소통' }, '물병자리': { score: 90, message: '자유로운 사랑' } },
    '게자리': { '전갈자리': { score: 95, message: '깊은 교감' }, '물고기자리': { score: 90, message: '감성적 조화' } },
    '사자자리': { '양자리': { score: 95, message: '불꽃 튀는 열정' }, '사수자리': { score: 90, message: '밝은 에너지' } },
    '처녀자리': { '황소자리': { score: 95, message: '안정적 관계' }, '염소자리': { score: 90, message: '현실적 파트너' } },
    '천칭자리': { '쌍둥이자리': { score: 95, message: '완벽한 소통' }, '물병자리': { score: 90, message: '이상적 관계' } },
    '전갈자리': { '게자리': { score: 95, message: '깊은 교감' }, '물고기자리': { score: 90, message: '신비로운 인연' } },
    '사수자리': { '양자리': { score: 90, message: '최고의 케미' }, '사자자리': { score: 90, message: '밝은 에너지' } },
    '염소자리': { '황소자리': { score: 90, message: '현실적 파트너' }, '처녀자리': { score: 90, message: '안정적 관계' } },
    '물병자리': { '쌍둥이자리': { score: 90, message: '자유로운 사랑' }, '천칭자리': { score: 90, message: '이상적 관계' } },
    '물고기자리': { '게자리': { score: 90, message: '감성적 조화' }, '전갈자리': { score: 90, message: '신비로운 인연' } }
  }

  return compatibility[sign1]?.[sign2] || { score: 75, message: '노력하면 좋아짐' }
}

// 생일 숫자 합 계산
function calculateBirthNumberSum(birthDate: string): number {
  const digits = birthDate.replace(/\D/g, '').split('').map(Number)
  let sum = digits.reduce((a, b) => a + b, 0)

  // 한 자리 될 때까지 반복
  while (sum >= 10) {
    sum = sum.toString().split('').map(Number).reduce((a, b) => a + b, 0)
  }

  return sum
}

// 운명 숫자 해석
function getDestinyNumberMeaning(num: number): string {
  const meanings: Record<number, string> = {
    1: '리더십형 관계',
    2: '조화로운 파트너',
    3: '창의적 커플',
    4: '안정적 관계',
    5: '자유로운 사랑',
    6: '책임감 있는 사랑',
    7: '신비로운 인연',
    8: '성공적 파트너십',
    9: '이상주의적 사랑'
  }
  return meanings[num] || '특별한 인연'
}

// 나이 차이 분석
function getAgeDifference(date1: string, date2: string): { years: number; message: string } {
  const year1 = parseInt(date1.substring(0, 4))
  const year2 = parseInt(date2.substring(0, 4))
  const diff = Math.abs(year1 - year2)

  let message = ''
  if (diff === 0) message = '동갑 커플, 같은 눈높이'
  else if (diff === 1) message = '한 살 차이, 친구 같은 연인'
  else if (diff === 3) message = '세 살 차이, 서로 배려'
  else if (diff === 5) message = '다섯 살 차이, 든든한 파트너'
  else if (diff >= 10) message = '큰 나이 차이, 서로 배움'
  else message = `${diff}살 차이, 적당한 거리감`

  return { years: diff, message }
}

// 계절 계산
function getSeason(birthDate: string): string {
  const month = parseInt(birthDate.substring(5, 7))
  if (month >= 3 && month <= 5) return '봄'
  if (month >= 6 && month <= 8) return '여름'
  if (month >= 9 && month <= 11) return '가을'
  return '겨울'
}

// 계절 궁합
function getSeasonCompatibility(season1: string, season2: string): string {
  if (season1 === season2) return '같은 계절, 비슷한 성향'
  if ((season1 === '봄' && season2 === '가을') || (season1 === '가을' && season2 === '봄')) {
    return '정반대 매력'
  }
  if ((season1 === '여름' && season2 === '겨울') || (season1 === '겨울' && season2 === '여름')) {
    return '서로 다른 온도'
  }
  return '보완적 관계'
}

// 요청 인터페이스
interface CompatibilityFortuneRequest {
  fortune_type?: string
  person1_name: string
  person1_birth_date: string
  person2_name: string
  person2_birth_date: string
  isPremium?: boolean // ✅ 프리미엄 사용자 여부
}

// 메인 핸들러
serve(async (req) => {
  // CORS 헤더 설정
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      },
    })
  }

  try {
    // 요청 데이터 파싱
    const requestData = await req.json()

    // 두 가지 형식 지원: flat fields (person1_name) 또는 nested objects (person1.name)
    const person1_name = requestData.person1_name || requestData.person1?.name || ''
    const person1_birth_date = requestData.person1_birth_date || requestData.person1?.birth_date || ''
    const person2_name = requestData.person2_name || requestData.person2?.name || ''
    const person2_birth_date = requestData.person2_birth_date || requestData.person2?.birth_date || ''
    const isPremium = requestData.isPremium ?? false

    console.log(`[Compatibility] Request - Premium: ${isPremium}`)
    console.log(`[Compatibility] Parsed - person1: ${person1_name}, person2: ${person2_name}`)

    if (!person1_name || !person2_name) {
      throw new Error('두 사람의 이름을 모두 입력해주세요.')
    }

    console.log('Compatibility fortune request:', {
      person1_name,
      person2_name
    })

    // ✅ Cohort Pool 조회 (API 비용 90% 절감)
    const cohortData = extractCompatibilityCohort({
      person1_birth_date,
      person2_birth_date,
      person1_gender: requestData.person1_gender || 'male',
      person2_gender: requestData.person2_gender || 'female',
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`[Compatibility] Cohort: ${JSON.stringify(cohortData)} -> ${cohortHash.slice(0, 8)}...`)

    const poolResult = await getFromCohortPool(supabase, 'compatibility', cohortHash)
    if (poolResult) {
      console.log('[Compatibility] ✅ Cohort Pool 히트!')
      // 개인화 (이름 치환)
      const personalizedResult = personalize(poolResult, {
        person1_name,
        person2_name,
      }) as Record<string, unknown>

      // 퍼센타일 추가
      const score = (personalizedResult.score as number) || 75
      const percentileData = await calculatePercentile(supabase, 'compatibility', score)
      const resultWithPercentile = addPercentileToResult(personalizedResult, percentileData)

      // Blur 처리 (Premium 여부)
      resultWithPercentile.isBlurred = !isPremium
      resultWithPercentile.blurredSections = !isPremium
        ? ['detailed_scores', 'analysis', 'advice']
        : []

      return new Response(JSON.stringify({ success: true, data: resultWithPercentile }), {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      })
    }
    console.log('[Compatibility] Cohort Pool miss, LLM 호출 필요')

    // 캐시 확인 (UTF-8 안전한 SHA-256 해시)
    const hash = await createHash(`${person1_name}_${person1_birth_date}_${person2_name}_${person2_birth_date}`)
    const cacheKey = `compatibility_fortune_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for compatibility fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling OpenAI API')

      // OpenAI API 호출을 위한 프롬프트 생성
      const prompt = `당신은 한국의 전문 궁합 전문가입니다. 다음 정보를 바탕으로 구체적이고 실용적인 궁합 분석을 제공해주세요.

첫 번째 사람: "${person1_name}" (생년월일: ${person1_birth_date})
두 번째 사람: "${person2_name}" (생년월일: ${person2_birth_date})

다음 JSON 형식으로 궁합 분석을 제공해주세요:

## 분량 요구사항 (카드 UI 스크롤 방지)
- 모든 텍스트 필드: **반드시 100자 이내**
- 배열 항목: **각 50자 이내**
- 핵심만 간결하게 작성

\`\`\`json
{
  "전반적인궁합": "전체 궁합 분석",
  "궁합점수": 0-100,
  "성격궁합": "성격 조화 분석",
  "애정궁합": "애정 관계 분석",
  "결혼궁합": "결혼 생활 조화",
  "소통궁합": "소통과 이해도",
  "강점": ["강점1", "강점2", "강점3"],
  "주의점": ["주의점1", "주의점2", "주의점3"],
  "조언": ["조언1", "조언2", "조언3"],
  "한줄평": "두 사람의 관계를 20자 내외로 감성적으로 표현. 예: '서로를 비추는 거울 같은 인연', '파도처럼 밀고 당기는 운명적 만남'",
  "연애스타일": {
    "person1": "스타일명",
    "person2": "스타일명",
    "조합분석": "스타일 조합 분석"
  }
}
\`\`\`

⚠️ 중요: 절대로 "(xx자 이내)" 같은 글자수 지시문을 출력에 포함하지 마세요.
긍정적이면서 현실적인 관점으로 작성해주세요. 반드시 JSON 형식으로만 응답하세요.`

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      const llm = await LLMFactory.createFromConfigAsync('compatibility')

      const response = await llm.generate([
        {
          role: 'system',
          content: '당신은 한국의 전문 궁합 전문가입니다. 항상 한국어로 응답하며, 실용적이고 긍정적인 조언을 제공합니다.'
        },
        {
          role: 'user',
          content: prompt
        }
      ], {
        temperature: 1,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      // ✅ LLM 사용량 로깅 (비용/성능 분석용)
      await UsageLogger.log({
        fortuneType: 'compatibility',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: {
          person1_name,
          person2_name,
          isPremium
        }
      })

      if (!response.content) {
        throw new Error('LLM API 응답을 받을 수 없습니다.')
      }

      // JSON 파싱
      let parsedResponse: any
      try {
        parsedResponse = JSON.parse(response.content)
      } catch (error) {
        console.error('JSON parsing error:', error)
        throw new Error('API 응답 형식이 올바르지 않습니다.')
      }

      // ✅ Premium 여부에 따라 Blur 처리
      const isBlurred = !isPremium
      const blurredSections = isBlurred
        ? ['detailed_scores', 'analysis', 'advice']  // Flutter UI의 sectionKey와 일치
        : []

      console.log(`[Compatibility] 🔐 Blur 처리 - isPremium: ${isPremium}, isBlurred: ${isBlurred}, blurredSections: ${blurredSections.length}개`)

      // 조언 데이터 처리 (List → String 변환)
      const adviceData = parsedResponse.조언 || parsedResponse.advice || ['서로 배려', '대화 자주', '함께 시간']
      const adviceString = Array.isArray(adviceData)
        ? adviceData.join('\n• ')
        : adviceData

      console.log(`[Compatibility] 📝 조언 데이터 처리 완료 - 길이: ${adviceString?.length || 0}자`)

      // ✅ 새로운 궁합 항목 계산
      const nameCompatibility = calculateNameCompatibility(person1_name, person2_name)

      const zodiacAnimal1 = getZodiacAnimal(person1_birth_date)
      const zodiacAnimal2 = getZodiacAnimal(person2_birth_date)
      const zodiacCompat = getZodiacCompatibility(zodiacAnimal1, zodiacAnimal2)

      const starSign1 = getZodiacSign(person1_birth_date)
      const starSign2 = getZodiacSign(person2_birth_date)
      const starCompat = getStarSignCompatibility(starSign1, starSign2)

      const birthNumber1 = calculateBirthNumberSum(person1_birth_date)
      const birthNumber2 = calculateBirthNumberSum(person2_birth_date)
      const destinyNumber = (birthNumber1 + birthNumber2) % 9 || 9

      const ageDiff = getAgeDifference(person1_birth_date, person2_birth_date)

      const season1 = getSeason(person1_birth_date)
      const season2 = getSeason(person2_birth_date)
      const seasonCompat = getSeasonCompatibility(season1, season2)

      // 응답 데이터 구조화
      const overallCompatibilityText = parsedResponse.전반적인궁합 || parsedResponse.overall_compatibility || '좋은 궁합입니다.'
      const compatibilityScore = parsedResponse.궁합점수 || Math.floor(Math.random() * 30) + 70

      // 조언 데이터 처리 (List → String 변환) - 위에서 이미 처리됨

      fortuneData = {
        // ✅ 표준화된 필드명: score, content, summary, advice
        fortuneType: 'compatibility',
        score: compatibilityScore,
        content: overallCompatibilityText,
        summary: parsedResponse.한줄평 || parsedResponse.궁합키워드 || parsedResponse.compatibility_keyword || '운명처럼 만난 두 사람',
        advice: parsedResponse.조언?.[0] || parsedResponse.advice?.[0] || '서로를 존중하고 배려하세요',
        // 기존 필드 유지 (하위 호환성)
        title: `${person1_name}♥${person2_name} 궁합`,
        fortune_type: 'compatibility',
        person1: { name: person1_name, birth_date: person1_birth_date },
        person2: { name: person2_name, birth_date: person2_birth_date },
        overall_compatibility: overallCompatibilityText, // ✅ 무료: 공개
        // ✅ 블러 처리: 빈 문자열 대신 실제 데이터 저장 (UnifiedBlurWrapper가 처리)
        personality_match: parsedResponse.성격궁합 || parsedResponse.personality_match || '성격이 잘 맞습니다.',
        love_match: parsedResponse.애정궁합 || parsedResponse.love_match || '애정이 깊습니다.',
        marriage_match: parsedResponse.결혼궁합 || parsedResponse.marriage_match || '결혼에 적합합니다.',
        communication_match: parsedResponse.소통궁합 || parsedResponse.communication_match || '소통이 원활합니다.',
        strengths: parsedResponse.강점 || parsedResponse.strengths || ['서로 이해', '존중', '배려'],
        cautions: parsedResponse.주의점 || parsedResponse.cautions || ['작은 갈등 주의', '대화 중요', '서로 존중'],
        detailed_advice: `• ${adviceString}`, // 상세 조언 (블러 대상)
        compatibility_keyword: parsedResponse.한줄평 || parsedResponse.궁합키워드 || parsedResponse.compatibility_keyword || '운명처럼 만난 두 사람', // ✅ 무료: 공개
        // score는 위에서 표준 필드로 이미 설정됨
        love_style: parsedResponse.연애스타일 || parsedResponse.love_style || null, // 연애 스타일 (LLM 생성)
        // ✅ 새로운 궁합 항목들 (무료 공개)
        name_compatibility: nameCompatibility, // 이름 궁합 숫자 (0-99)
        zodiac_animal: {
          person1: zodiacAnimal1,
          person2: zodiacAnimal2,
          score: zodiacCompat.score,
          message: zodiacCompat.message
        },
        star_sign: {
          person1: starSign1,
          person2: starSign2,
          score: starCompat.score,
          message: starCompat.message
        },
        destiny_number: {
          number: destinyNumber,
          meaning: getDestinyNumberMeaning(destinyNumber)
        },
        age_difference: ageDiff,
        season: {
          person1: season1,
          person2: season2,
          message: seasonCompat
        },
        timestamp: new Date().toISOString(),
        isBlurred, // ✅ Blur 상태
        blurredSections, // ✅ Blur 처리된 섹션 목록
      }

      console.log(`[Compatibility] ✅ 응답 데이터 구조화 완료`)
      console.log(`[Compatibility]   📊 전체 궁합 점수: ${fortuneData.score}점`)
      console.log(`[Compatibility]   💑 전반적인 궁합: ${fortuneData.overall_compatibility?.substring(0, 50)}...`)
      console.log(`[Compatibility]   👥 성격 궁합: ${fortuneData.personality_match?.substring(0, 30)}...`)
      console.log(`[Compatibility]   💘 애정 궁합: ${fortuneData.love_match?.substring(0, 30)}...`)
      console.log(`[Compatibility]   💍 결혼 궁합: ${fortuneData.marriage_match?.substring(0, 30)}...`)
      console.log(`[Compatibility]   💬 소통 궁합: ${fortuneData.communication_match?.substring(0, 30)}...`)
      console.log(`[Compatibility]   ✨ 강점: ${fortuneData.strengths?.length}개`)
      console.log(`[Compatibility]   ⚠️  주의점: ${fortuneData.cautions?.length}개`)
      console.log(`[Compatibility]   💡 조언: ${fortuneData.advice?.length}자`)
      console.log(`[Compatibility]   🆕 새 궁합 항목:`)
      console.log(`[Compatibility]     - 이름 궁합: ${fortuneData.name_compatibility}%`)
      console.log(`[Compatibility]     - 띠 궁합: ${fortuneData.zodiac_animal.person1} × ${fortuneData.zodiac_animal.person2} (${fortuneData.zodiac_animal.score}점)`)
      console.log(`[Compatibility]     - 별자리: ${fortuneData.star_sign.person1} × ${fortuneData.star_sign.person2} (${fortuneData.star_sign.score}점)`)
      console.log(`[Compatibility]     - 운명수: ${fortuneData.destiny_number.number}`)
      console.log(`[Compatibility]     - 나이차: ${fortuneData.age_difference.years}살`)
      console.log(`[Compatibility]     - 계절: ${fortuneData.season.person1} × ${fortuneData.season.person2}`)
      console.log(`[Compatibility]   🔐 Blur: ${isBlurred}, Sections: ${blurredSections.length}개`)

      // 결과 캐싱
      await supabase
        .from('fortune_cache')
        .insert({
          cache_key: cacheKey,
          result: fortuneData,
          fortune_type: 'compatibility',
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24시간 캐시
        })

      // ✅ Cohort Pool에 저장 (fire-and-forget)
      saveToCohortPool(supabase, 'compatibility', cohortHash, cohortData, fortuneData)
        .catch(e => console.error('[Compatibility] Cohort 저장 오류:', e))
    }

    // ✅ 퍼센타일 계산
    const percentileData = await calculatePercentile(supabase, 'compatibility', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    // 성공 응답
    const response = {
      success: true,
      data: fortuneDataWithPercentile
    }

    return new Response(JSON.stringify(response), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Compatibility Fortune Error:', error)

    const errorResponse = {
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '궁합 분석 중 오류가 발생했습니다.'
    }

    return new Response(JSON.stringify(errorResponse), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
