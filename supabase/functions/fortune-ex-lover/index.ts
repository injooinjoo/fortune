/**
 * 전 연인 운세 (Ex-Lover Fortune) Edge Function
 *
 * @description 전 연인과의 관계를 사주 기반으로 분석합니다.
 *
 * @endpoint POST /fortune-ex-lover
 *
 * @requestBody
 * - name: string - 사용자 이름
 * - ex_name?: string - 전 연인 이름/닉네임
 * - ex_mbti?: string - 전 연인 MBTI
 * - ex_birth_date?: string - 전 연인 생년월일
 * - relationship_duration: string - 관계 기간
 * - time_since_breakup: string - 이별 후 경과 시간
 * - breakup_initiator: string - 이별 통보자 (me/them/mutual)
 * - contact_status: string - 현재 연락 상태
 * - breakup_reason?: string - 이별 이유 (선택지)
 * - breakup_detail?: string - 이별 이유 상세 (자유 텍스트)
 * - current_emotion: string - 현재 감정
 * - main_curiosity: string - 가장 궁금한 것
 * - chat_history?: string - 카톡/대화 내용
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response ExLoverResponse
 * - reunion_probability: number - 재회 가능성
 * - karma_analysis: string - 인연 분석
 * - emotional_healing: string[] - 감정 치유 조언
 * - future_outlook: string - 향후 전망
 * - advice: string - 조언
 */
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.168.0/crypto/mod.ts'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import {
  extractExLoverCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY')!

const supabase = createClient(supabaseUrl, supabaseKey)

// UTF-8 안전한 해시 생성 함수 (btoa는 Latin1만 지원하여 한글 불가)
async function createHash(text: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(text)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 50)
}

interface ExLoverFortuneRequest {
  fortune_type?: string
  name: string
  // 상대방 정보
  ex_name?: string
  ex_mbti?: string
  ex_birth_date?: string

  // ✅ Step 1: 상담 목표 (가치 제안 선택) - NEW
  primaryGoal: 'healing' | 'reunion_strategy' | 'read_their_mind' | 'new_start'

  // ✅ v3 NEW: 카톡 스크린샷 (base64 인코딩, 최대 3장)
  chat_screenshots?: string[]

  // ✅ Step 2: 이별 시점 - UPDATED
  time_since_breakup: string // very_recent, recent, 1to3months, 3to6months, 6to12months, over_year
  breakup_initiator: string // me, them, mutual

  // ✅ Step 3: 관계 깊이 - NEW
  relationshipDepth: 'casual' | 'moderate' | 'deep' | 'very_deep'

  // ✅ Step 4: 이별 핵심 이유 - NEW
  coreReason: 'values' | 'communication' | 'trust' | 'cheating' | 'distance' | 'family' | 'feelings_changed' | 'personal_issues' | 'unknown'

  // ✅ Step 5: 상세 이야기 (음성/텍스트)
  breakup_detail?: string

  // ✅ Step 6: 현재 상태 (복수 선택) - NEW
  currentState: string[] // cant_sleep, checking_sns, crying, angry, regret, miss_them, relieved, confused, moving_on

  // ✅ Step 7: 연락 상태
  contact_status: string // blocked, noContact, sometimes, often, stillMeeting

  // ✅ Step 8: 목표별 심화 질문 - NEW
  goalSpecific?: {
    // healing: 가장 힘든 순간
    hardestMoment?: 'morning' | 'night' | 'places' | 'alone'
    // reunion: 달라질 것
    whatWillChange?: 'i_changed' | 'they_changed' | 'situation_changed' | 'unsure'
    // read_mind: 상대 특징
    exCharacteristics?: string
    // new_start: 새 연애에서 중요한 것
    newRelationshipPriority?: 'trust_communication' | 'emotional_stability' | 'similar_values' | 'excitement'
  }

  // 기존 필드 (하위 호환성)
  relationship_duration?: string
  breakup_reason?: string
  current_emotion?: string
  main_curiosity?: string
  chat_history?: string
  isPremium?: boolean
}

// 한글 변환 헬퍼 함수들
function getRelationshipDurationKorean(duration: string): string {
  const map: Record<string, string> = {
    'lessThan1Month': '1개월 미만',
    '1to3Months': '1-3개월',
    '3to6Months': '3-6개월',
    '6to12Months': '6개월-1년',
    '1to2Years': '1-2년',
    '2to3Years': '2-3년',
    'moreThan3Years': '3년 이상',
  }
  return map[duration] || duration
}

function getTimeSinceBreakupKorean(time: string): string {
  const map: Record<string, string> = {
    'recent': '1개월 미만 (매우 최근)',
    'short': '1-3개월',
    'medium': '3-6개월',
    'long': '6개월-1년',
    'verylong': '1년 이상',
  }
  return map[time] || time
}

function getBreakupInitiatorKorean(initiator: string): string {
  const map: Record<string, string> = {
    'me': '내가 먼저 이별을 말함',
    'them': '상대가 먼저 이별을 말함',
    'mutual': '서로 합의하에 헤어짐',
  }
  return map[initiator] || initiator
}

function getContactStatusKorean(status: string): string {
  const map: Record<string, string> = {
    'blocked': '완전 차단 상태',
    'noContact': '연락 없음',
    'sometimes': '가끔 연락함',
    'often': '자주 연락함',
    'stillMeeting': '아직 만나고 있음',
  }
  return map[status] || status
}

function getCurrentEmotionKorean(emotion: string): string {
  const map: Record<string, string> = {
    'miss': '그리움 (아직도 그 사람이 보고 싶음)',
    'anger': '분노 (배신감과 분노를 느낌)',
    'sadness': '슬픔 (너무 슬프고 외로움)',
    'relief': '안도 (헤어진 게 다행)',
    'acceptance': '받아들임 (이제는 받아들일 수 있음)',
  }
  return map[emotion] || emotion
}

function getMainCuriosityKorean(curiosity: string): string {
  const map: Record<string, string> = {
    'theirFeelings': '상대방 마음 (그 사람도 나를 생각할까?)',
    'reunionChance': '재회 가능성 (우리 다시 만날 수 있을까?)',
    'newLove': '새로운 사랑 (언제 새로운 사랑을 시작할까?)',
    'healing': '치유 방법 (어떻게 마음을 치유할까?)',
  }
  return map[curiosity] || curiosity
}

// ✅ NEW: 상담 목표 (가치 제안) 한글 변환
function getPrimaryGoalKorean(goal: string): string {
  const map: Record<string, string> = {
    'healing': '감정 정리 + 힐링 (클로저, 마음 치유)',
    'reunion_strategy': '재회 전략 가이드 (액션, 타이밍, 방법)',
    'read_their_mind': '상대방 마음 읽기 (그 사람 감정 분석)',
    'new_start': '새 출발 준비도 확인 (성장, 새 인연 시기)',
  }
  return map[goal] || goal
}

// ✅ NEW: 관계 깊이 한글 변환
function getRelationshipDepthKorean(depth: string): string {
  const map: Record<string, string> = {
    'casual': '가벼운 연애 (몇 달 정도, 썸 단계)',
    'moderate': '보통 관계 (1년 미만, 서로 알아가는 중)',
    'deep': '진지한 관계 (1년 이상, 결혼 이야기 나옴)',
    'very_deep': '매우 깊은 관계 (동거/약혼, 인생의 일부)',
  }
  return map[depth] || depth
}

// ✅ NEW: 이별 핵심 이유 한글 변환
function getCoreReasonKorean(reason: string): string {
  const map: Record<string, string> = {
    'values': '가치관/미래 계획 불일치',
    'communication': '소통 문제/잦은 싸움',
    'trust': '신뢰 문제 (거짓말/의심)',
    'cheating': '외도/바람',
    'distance': '거리/시간 문제 (장거리, 바쁜 일정)',
    'family': '가족 반대/외부 압력',
    'feelings_changed': '감정이 식음 (권태기, 마음 변화)',
    'personal_issues': '개인적 문제 (직장/건강/학업)',
    'unknown': '잘 모르겠음 (이유를 제대로 듣지 못함)',
  }
  return map[reason] || reason
}

// ✅ NEW: 현재 상태 한글 변환 (복수)
function getCurrentStateKorean(states: string[]): string {
  const map: Record<string, string> = {
    'cant_sleep': '😴 잠을 못 자',
    'checking_sns': '📱 SNS 계속 확인해',
    'crying': '😢 자주 울어',
    'angry': '😤 화가 나',
    'regret': '😔 후회돼',
    'miss_them': '💙 너무 보고싶어',
    'relieved': '🕊️ 해방감이 느껴져',
    'confused': '🌀 내 감정을 모르겠어',
    'moving_on': '🌱 극복하고 있어',
  }
  return states.map(s => map[s] || s).join(', ')
}

// ✅ NEW: 이별 시점 상세 한글 변환
function getBreakupTimeDetailKorean(time: string): string {
  const map: Record<string, string> = {
    'very_recent': '1주일 이내 (아주 최근)',
    'recent': '1개월 이내',
    '1to3months': '1-3개월 전',
    '3to6months': '3-6개월 전',
    '6to12months': '6개월-1년 전',
    'over_year': '1년 이상',
  }
  return map[time] || time
}

// ✅ NEW: 목표별 심화 질문 한글 변환
function getGoalSpecificKorean(goalSpecific: any, primaryGoal: string): string {
  if (!goalSpecific) return ''

  switch (primaryGoal) {
    case 'healing':
      const momentMap: Record<string, string> = {
        'morning': '아침에 일어날 때',
        'night': '밤에 잠들기 전',
        'places': '우리 갔던 장소 볼 때',
        'alone': '혼자 있을 때',
      }
      return `가장 힘든 순간: ${momentMap[goalSpecific.hardestMoment] || goalSpecific.hardestMoment || '미입력'}`

    case 'reunion_strategy':
      const changeMap: Record<string, string> = {
        'i_changed': '내가 변했어',
        'they_changed': '상대가 변했을 것 같아',
        'situation_changed': '상황이 달라졌어',
        'unsure': '잘 모르겠어',
      }
      return `재회하면 달라질 것: ${changeMap[goalSpecific.whatWillChange] || goalSpecific.whatWillChange || '미입력'}`

    case 'read_their_mind':
      return `상대방 특징/MBTI: ${goalSpecific.exCharacteristics || '미입력'}`

    case 'new_start':
      const priorityMap: Record<string, string> = {
        'trust_communication': '신뢰와 소통',
        'emotional_stability': '감정적 안정',
        'similar_values': '비슷한 가치관',
        'excitement': '설렘과 열정',
      }
      return `새 연애에서 중요한 것: ${priorityMap[goalSpecific.newRelationshipPriority] || goalSpecific.newRelationshipPriority || '미입력'}`

    default:
      return ''
  }
}

// ✅ v3 NEW: 카톡 스크린샷 분석 함수 (Vision API)
async function analyzeScreenshots(screenshots: string[]): Promise<string> {
  if (!screenshots || screenshots.length === 0) {
    return ''
  }

  console.log(`📸 [ExLover] Analyzing ${screenshots.length} screenshot(s)...`)

  try {
    // Vision 지원 모델 사용 (face-reading과 동일)
    const visionLLM = await LLMFactory.createFromConfigAsync('face-reading')

    // 이미지 콘텐츠 구성
    const imageContents = screenshots.slice(0, 3).map((base64) => ({
      type: 'image_url' as const,
      image_url: {
        url: `data:image/jpeg;base64,${base64}`,
        detail: 'high' as const
      }
    }))

    const analysisPrompt = `아래 카카오톡/문자 대화 스크린샷을 분석해주세요.

분석 요청:
1. **대화 톤과 분위기**: 두 사람의 대화가 어떤 느낌인지 (친밀함/거리감/갈등/냉담함 등)
2. **감정 흐름**: 대화에서 느껴지는 감정의 변화
3. **핵심 대화 내용**: 중요한 메시지나 표현 요약
4. **관계 상태 추측**: 이 대화를 기반으로 한 관계 분석
5. **주목할 패턴**: 상대방의 답장 속도, 말투, 이모티콘 사용 등 패턴

분석 결과를 자연스러운 문장으로 500자 내외로 작성해주세요.
"대화를 보니..." 또는 "스크린샷에서 느껴지는 건..."으로 시작하세요.`

    const response = await visionLLM.generate([
      {
        role: 'system',
        content: '당신은 연애 상담 전문가입니다. 카카오톡 대화 스크린샷을 분석하여 두 사람의 관계 상태와 감정을 파악합니다. 솔직하고 통찰력 있는 분석을 제공하세요.'
      },
      {
        role: 'user',
        content: [
          { type: 'text', text: analysisPrompt },
          ...imageContents
        ]
      }
    ], {
      temperature: 0.7,
      maxTokens: 1024
    })

    console.log(`✅ [ExLover] Screenshot analysis complete: ${response.latency}ms`)
    return response.content || ''
  } catch (error) {
    console.error('❌ [ExLover] Screenshot analysis failed:', error)
    return ''
  }
}

// ✅ NEW: 재회 가능성 현실적 최대값 계산
function calculateReunionCap(coreReason: string, contact_status: string, time_since_breakup: string): number {
  let maxCap = 100

  // 이별 이유별 최대값
  switch (coreReason) {
    case 'cheating': maxCap = Math.min(maxCap, 20); break  // 외도: 최대 20%
    case 'trust': maxCap = Math.min(maxCap, 35); break      // 신뢰 문제: 최대 35%
    case 'feelings_changed': maxCap = Math.min(maxCap, 35); break // 감정 식음: 최대 35%
    case 'values': maxCap = Math.min(maxCap, 40); break     // 가치관 불일치: 최대 40%
    case 'distance': maxCap = Math.min(maxCap, 60); break   // 거리 문제: 최대 60%
    case 'communication': maxCap = Math.min(maxCap, 55); break // 소통 문제: 최대 55%
  }

  // 연락 상태별 최대값
  switch (contact_status) {
    case 'blocked': maxCap = Math.min(maxCap, 25); break    // 차단: 최대 25%
    case 'noContact': maxCap = Math.min(maxCap, 40); break  // 무연락: 최대 40%
  }

  // 이별 기간별 최대값
  switch (time_since_breakup) {
    case 'over_year': maxCap = Math.min(maxCap, 25); break  // 1년 이상: 최대 25%
    case '6to12months': maxCap = Math.min(maxCap, 35); break
  }

  return maxCap
}

/**
 * 재회운 헤더 이미지 프롬프트 생성
 *
 * 현재 감정과 재회 가능성 점수에 따라 감성적인 이미지 프롬프트를 생성합니다.
 * - 한국 전통 연인 테마 (한복, 달빛, 전통 배경)
 * - 감정 상태에 따른 분위기 조절
 * - 재회 희망/치유 메시지 반영
 */
function generateReunionImagePrompt(
  currentEmotion: string,
  reunionScore: number,
  mainCuriosity: string
): string {
  // 감정별 분위기 설정
  const emotionMood = (() => {
    switch (currentEmotion) {
      case 'miss': return {
        mood: '그리움과 애틋함',
        colors: 'soft purple, misty blue, moonlight silver',
        elements: '달빛 아래 기다리는 실루엣, 떨어지는 꽃잎, 빈 그네'
      };
      case 'anger': return {
        mood: '정화와 치유',
        colors: 'calming blue, soft white, gentle lavender',
        elements: '빗물에 씻기는 연꽃, 맑아지는 하늘, 새벽빛'
      };
      case 'sadness': return {
        mood: '위로와 희망',
        colors: 'warm sunset orange, gentle pink, golden light',
        elements: '비 갠 후 무지개, 피어나는 꽃봉오리, 따뜻한 햇살'
      };
      case 'relief': return {
        mood: '평온과 새 출발',
        colors: 'fresh green, sky blue, bright white',
        elements: '탁 트인 풍경, 나비의 비상, 열린 문'
      };
      case 'acceptance': return {
        mood: '성숙과 감사',
        colors: 'golden amber, warm brown, soft cream',
        elements: '노을빛 풍경, 낙엽 위 발자국, 멀리 가는 길'
      };
      default: return {
        mood: '애틋한 그리움',
        colors: 'soft lavender, moonlight blue',
        elements: '달빛 아래 풍경'
      };
    }
  })();

  // 재회 점수에 따른 상징물
  const reunionSymbols = reunionScore >= 70
    ? '두 개의 연결된 붉은 실, 다시 만나는 두 별, 이어지는 다리'
    : reunionScore >= 50
    ? '서서히 가까워지는 두 나비, 같은 달을 바라보는 두 그림자'
    : '각자의 길을 가는 두 사람의 평화로운 실루엣, 감사의 꽃';

  // 궁금증에 따른 포커스
  const curiosityFocus = (() => {
    switch (mainCuriosity) {
      case 'theirFeelings': return '멀리서 바라보는 그리운 시선, 가슴에 손을 얹은 실루엣';
      case 'reunionChance': return '다가오는 두 그림자, 교차하는 운명의 실';
      case 'newLove': return '새벽빛 속 피어나는 새 꽃, 열리는 새로운 문';
      case 'healing': return '따뜻한 빛에 감싸인 마음, 치유의 물결';
      default: return '달빛 아래 서있는 실루엣';
    }
  })();

  return `Korean traditional romantic reunion fortune illustration:

Main elements: ${reunionSymbols}
Emotional focus: ${curiosityFocus}
${emotionMood.elements}

Style requirements:
- Traditional Korean aesthetic (한국 전통 미학)
- Hanbok (한복) silhouette elements for romantic mood
- Moonlit or twilight atmosphere (달빛/황혼 분위기)
- Watercolor + digital art hybrid style
- Color palette: ${emotionMood.colors}
- Dreamy, ethereal quality with soft gradients
- Korean traditional patterns (전통 문양) as subtle accents
- Cherry blossoms (벚꽃) or magnolia (목련) petals floating

Mood: ${emotionMood.mood}
Emotional tone: ${reunionScore >= 70 ? 'Hopeful reunion, warm anticipation' : reunionScore >= 50 ? 'Bittersweet longing, gentle hope' : 'Peaceful acceptance, self-healing journey'}

Aspect ratio: 16:9, cinematic composition
No text, no faces clearly visible, focus on silhouettes and atmosphere
Artistic, emotionally evocative imagery`;
}

serve(async (req) => {
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
    const requestData: ExLoverFortuneRequest = await req.json()
    const {
      name = '',
      ex_name,
      ex_mbti,
      // ✅ v2: 새 필드들
      primaryGoal = 'healing',
      time_since_breakup = '',
      breakup_initiator = '',
      relationshipDepth = 'moderate',
      coreReason = 'unknown',
      breakup_detail,
      currentState = [],
      contact_status = '',
      goalSpecific,
      // 기존 필드 (하위 호환성)
      relationship_duration,
      current_emotion,
      main_curiosity,
      chat_history,
      chat_screenshots, // ✅ v3 NEW: 카톡 스크린샷
      isPremium = false
    } = requestData

    console.log('💎 [ExLover] Premium 상태:', isPremium)
    console.log('📸 [ExLover] 스크린샷 수:', chat_screenshots?.length || 0)
    console.log('🎯 [ExLover] 상담 목표:', primaryGoal)

    // 필수 필드 검증 (v2)
    if (!name) {
      throw new Error('이름을 입력해주세요.')
    }
    if (!primaryGoal) {
      throw new Error('상담 목표를 선택해주세요.')
    }
    if (!time_since_breakup) {
      throw new Error('이별 시점을 선택해주세요.')
    }
    if (!breakup_initiator) {
      throw new Error('이별 통보자를 선택해주세요.')
    }
    if (!contact_status) {
      throw new Error('현재 연락 상태를 선택해주세요.')
    }

    // breakup_detail이 없으면 에러 (단, 선택적으로 변경 가능)
    if (!breakup_detail || breakup_detail.trim() === '') {
      throw new Error('상세 이야기를 입력해주세요.')
    }

    console.log('Ex-lover fortune request:', {
      name,
      primaryGoal,
      coreReason,
      contact_status,
      time_since_breakup
    })

    // ✅ Cohort Pool에서 먼저 조회 (LLM 비용 90% 절감)
    const cohortData = extractExLoverCohort({
      emotionState: current_emotion,
      timeElapsed: time_since_breakup,
      contactStatus: contact_status,
    })
    const cohortHash = await generateCohortHash(cohortData)
    console.log('💝 [Cohort] Cohort 추출:', JSON.stringify(cohortData), '| Hash:', cohortHash)

    const poolResult = await getFromCohortPool(supabase, 'ex-lover', cohortHash)
    if (poolResult) {
      console.log('💝 [Cohort] Pool HIT! - LLM 호출 생략')

      // 개인화 적용
      const personalizedResult = personalize(poolResult, {
        userName: name || '회원님',
        exName: ex_name || '그분',
        breakupReason: coreReason || '',
      })

      // Percentile 적용
      const percentileData = await calculatePercentile(supabase, 'ex-lover', personalizedResult.score || 50)
      const resultWithPercentile = addPercentileToResult(personalizedResult, percentileData)

      return new Response(JSON.stringify({
        success: true,
        data: resultWithPercentile,
        cohortHit: true
      }), {
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      })
    }
    console.log('💝 [Cohort] Pool MISS - LLM 호출 필요')

    // 캐시 키 생성 (v2 - 목표 + 핵심 요소 기반)
    const hash = await createHash(`${name}_${primaryGoal}_${coreReason}_${time_since_breakup}_${breakup_initiator}_${contact_status}_${relationshipDepth}`)
    const cacheKey = `ex-lover_fortune_v2_${hash}`
    const { data: cachedResult } = await supabase
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    let fortuneData: any

    if (cachedResult?.result) {
      console.log('Cache hit for ex-lover fortune')
      fortuneData = cachedResult.result
    } else {
      console.log('Cache miss, calling LLM API')

      // ✅ LLM 모듈 사용 (동적 DB 설정 - A/B 테스트 지원)
      const llm = await LLMFactory.createFromConfigAsync('ex-lover')

      // ✅ "솔직한 조언자" 시스템 프롬프트 (v3 - 풍성한 개인화 분석)
      const systemPrompt = `당신은 25년 경력의 연애 상담 전문가입니다.
"솔직한 친구 같은 조언자" 페르소나로 답변합니다. 듣기 좋은 말보다 진짜 도움이 되는 말을 합니다.

# 핵심 원칙

## 1. 개인화 분석 필수 (CRITICAL - 가장 중요!)
사용자가 입력한 내용을 반드시 결과에 직접 언급하며 분석해야 합니다:

### breakup_detail 분석 (필수)
- 사용자가 입력한 이야기에서 핵심 키워드, 감정, 상황을 추출
- 결과에 "당신이 말씀하신 ~한 상황을 보면..." 형식으로 직접 인용
- 예: "당신이 '갑자기 연락이 줄었다'고 하셨는데, 이건 보통..."

### currentState 기반 공감 (필수)
- 선택한 현재 감정 상태를 구체적으로 언급
- 예: "지금 잠을 못 자고, SNS를 계속 확인하고 계시죠? 그 마음 완전히 이해해요..."

### chat_history 분석 (있는 경우 필수)
- 대화 내용에서 패턴, 톤, 감정 흐름 분석
- 구체적인 대화 내용이나 표현을 인용하며 분석
- 예: "대화를 보니 상대방이 '바쁘다'는 말을 자주 하네요. 이건..."

## 2. 솔직함
- "솔직히 말하면..." / "냉정하게 보면..." / "현실적으로..." 표현 적극 사용
- 재회 가능성이 낮으면 솔직히 말함. 단, 이유와 대안을 함께 제시
- 모호한 예측 절대 금지: "때가 되면 알게 됩니다" → "최소 3개월은 연락하지 마세요. 그 이유는..."

## 3. 목표 중심 맞춤 (primaryGoal에 따라 초점 조정)
- healing (감정 정리): 감정 치유, 자기 돌봄, 클로저에 집중. 재회 가능성은 간략히만
- reunion_strategy (재회 전략): 재회 가능성, 타이밍, 구체적 방법, 절대 하면 안 되는 것에 집중
- read_their_mind (상대방 마음): 상대방 심리 분석, "그 사람도 나를 생각할까?" 에 집중
- new_start (새 출발): 준비도 점수, 미해결 감정, 새 인연 시기, 성장 포인트에 집중

## 4. 재회 가능성 현실적 기준 (reunionCap 참고, 절대 초과 금지!)
- 외도로 헤어진 경우: 최대 20%
- 상대가 차단한 경우: 최대 25%
- 1년 이상 무연락: 최대 25%
- 신뢰 문제/감정 식음: 최대 35%
- 가치관 불일치: 최대 40%
- 소통 문제: 최대 55%
- 거리/상황 문제 + 합의 이별: 최대 60-70%

## 5. "절대 하면 안 되는 것" 반드시 포함
- 연락 폭탄 (여러 번 연속 메시지)
- SNS 스토킹 & 간접 어필 (의미심장한 스토리)
- 술 먹고 연락
- 공동 지인 통한 압박
- "바뀔게" 빈말 (구체적 변화 없이)

# JSON 출력 형식

{
  "title": "솔직하고 공감적인 제목 (예: '냉정하게 말해줄게요, OOO님')",
  "score": 50-90 사이 정수 (전반적 상황 점수, 현실적으로),

  "personalizedAnalysis": {
    "yourStory": "당신이 입력한 상세 이야기(breakup_detail)를 분석한 내용. '당신이 말씀하신 ~' 형식으로 직접 인용하며 분석 (250-300자)",
    "emotionalPattern": "현재 상태(currentState)를 기반으로 한 감정 패턴 분석. '지금 ~하고 계시죠? 그 마음 이해해요...' 형식 (200-250자)",
    "chatAnalysis": "대화 내용(chat_history)이 있으면 분석. 없으면 null. 대화 패턴, 상대방 톤, 감정 흐름 (200-250자)",
    "coreInsight": "모든 정보를 종합한 핵심 인사이트 1가지 (150자)"
  },

  "hardTruth": {
    "headline": "냉정하게 말하면... (핵심 진단 한 문장, 80자 이내)",
    "diagnosis": "현재 상황에 대한 솔직한 진단. 사용자가 입력한 구체적인 상황(breakup_detail, currentState)을 언급하며 분석 (300-400자)",
    "realityCheck": ["현실 체크 포인트 3가지 - 사용자 상황 기반 구체적 분석 (각 100-150자)"],
    "mostImportantAdvice": "가장 중요한 조언 1가지 - 왜 이게 중요한지 이유도 함께 (150-200자)"
  },

  "reunionAssessment": {
    "score": 0-reunionCap 사이 정수 (재회 확률, 현실적으로),
    "keyFactors": ["재회 가능성에 영향을 주는 핵심 요인 3가지 - 각각 왜 그런지 이유 포함 (각 100-150자)"],
    "timing": "적절한 시기와 조건 - 구체적 기간과 조건 명시 (예: '최소 3개월 후, 그것도 ~조건이 충족되면') (150-200자)",
    "approach": "접근 방법 - 재회 목표인 경우 단계별로 상세히, 아니면 왜 추천하지 않는지 (200-300자)",
    "neverDo": ["절대 하면 안 되는 것 3가지 - 왜 안 되는지 이유와 대안 포함 (각 100-150자)"]
  },

  "emotionalPrescription": {
    "currentStateAnalysis": "현재 감정 상태 분석 - 사용자가 선택한 감정을 직접 언급하며 분석 (200-250자)",
    "healingFocus": "치유에 집중해야 할 포인트 - 왜 이게 중요한지 (150-200자)",
    "weeklyActions": ["이번 주 실천할 것 3가지 - 구체적이고 실행 가능한 것 (각 80-100자)"],
    "monthlyMilestone": "한 달 후 목표 상태 - 구체적인 변화 지표 (100-150자)"
  },

  "theirPerspective": {
    "likelyThoughts": "상대방이 지금 느끼고 있을 감정 추측 - 사용자가 입력한 이별 이유, 연락 상태 기반 분석 (200-250자)",
    "doTheyThinkOfYou": "그 사람도 나를 생각할까? 솔직한 분석 - 가능성과 그 이유 (200-250자)",
    "whatTheyNeed": "상대방에게 필요한 것 - 구체적으로 (시간/공간/변화 등) (150-200자)"
  },

  "strategicAdvice": {
    "shortTerm": ["1주일 내 해야 할 것 3가지 - 구체적 액션과 이유 (각 80-100자)"],
    "midTerm": "1개월 내 목표 - 구체적이고 측정 가능한 목표 (150-200자)",
    "longTerm": "3개월 후 체크포인트 - 어떤 상태가 되어야 하는지 (150-200자)"
  },

  "newBeginning": {
    "readinessScore": 0-100 사이 정수 (새 출발 준비도),
    "unresolvedIssues": ["미해결 감정/문제 목록 - 왜 아직 해결 안 됐는지 (각 80-100자)"],
    "growthPoints": ["이 경험에서 얻은/얻을 성장 포인트 (각 80-100자)"],
    "newLoveTiming": "새 인연 가능 시기 - 조건부로 구체적 제시, 왜 그 시기인지 (150-200자)"
  },

  "milestones": {
    "oneWeek": ["1주일 후 체크 항목 2가지 - 구체적이고 측정 가능 (각 60-80자)"],
    "oneMonth": ["1개월 후 체크 항목 2가지 - 구체적이고 측정 가능 (각 60-80자)"],
    "threeMonths": ["3개월 후 체크 항목 2가지 - 구체적이고 측정 가능 (각 60-80자)"]
  },

  "closingMessage": {
    "empathy": "공감 메시지 - 사용자 상황을 직접 언급하며 진심으로 (100-150자)",
    "todayAction": "오늘 당장 할 것 1가지 - 구체적이고 실행 가능한 것 (80-100자)"
  }
}

# 목표별 섹션 우선순위 (응답 시 이 순서로 강조)
- healing: personalizedAnalysis → hardTruth → emotionalPrescription → theirPerspective → reunionAssessment (간략)
- reunion_strategy: personalizedAnalysis → hardTruth → reunionAssessment → strategicAdvice → emotionalPrescription
- read_their_mind: personalizedAnalysis → hardTruth → theirPerspective → reunionAssessment → emotionalPrescription
- new_start: personalizedAnalysis → hardTruth → newBeginning → emotionalPrescription → theirPerspective

# 분량 요구사항 (CRITICAL - 풍성한 결과를 위해 반드시 준수!)
- personalizedAnalysis 전체: 800-1000자 (가장 중요한 개인화 섹션)
- hardTruth: 800-1000자 (진단과 조언을 충분히)
- 각 배열 항목: 80-150자 (구체적인 이유와 함께)
- 긴 분석 필드: 200-400자 (깊이 있는 분석)
- 전체적으로 사용자 상황을 구체적으로 언급하며 분석
- **절대 빈약하게 쓰지 말 것! 충분히 풍성하게 작성**

# 주의사항 (CRITICAL)
- reunionCap 값이 주어지면 reunionAssessment.score는 그 값을 절대 초과하지 않음
- **사용자 입력(breakup_detail, currentState, chat_history)을 반드시 직접 인용하며 분석**
- **"당신이 말씀하신...", "지금 ~하고 계시죠?"와 같이 개인화된 표현 필수**
- 반드시 유효한 JSON 형식으로 출력
- 빈 필드 없이 모든 필드 채움
- goalSpecific 정보도 적극 활용`

      // ✅ 재회 가능성 최대값 계산
      const reunionCap = calculateReunionCap(coreReason, contact_status, time_since_breakup)
      console.log(`📊 [ExLover] reunionCap 계산: ${reunionCap}% (coreReason: ${coreReason}, contact: ${contact_status}, time: ${time_since_breakup})`)

      // ✅ v3 NEW: 스크린샷 분석 (있는 경우에만)
      let screenshotAnalysisResult = ''
      if (chat_screenshots && chat_screenshots.length > 0) {
        screenshotAnalysisResult = await analyzeScreenshots(chat_screenshots)
      }

      // 사용자 프롬프트 생성 (v2 - 8단계 설문 기반)
      let userPromptParts = [
        `# 상담 요청 정보`,
        ``,
        `## 🎯 상담 목표 (가장 중요!)`,
        `**${getPrimaryGoalKorean(primaryGoal)}**`,
        ``,
        `## 📊 재회 가능성 최대값 (CRITICAL: 이 값을 절대 초과하지 마세요!)`,
        `**reunionCap: ${reunionCap}%**`,
        `(이 사용자의 상황에서 재회 가능성은 아무리 높아도 ${reunionCap}%를 넘을 수 없습니다)`,
        ``,
        `## 사용자 정보`,
        `- 이름: ${name}`,
        ``,
        `## 상대방 정보`,
        `- 이름/닉네임: ${ex_name || '그 사람'}`,
        `- MBTI: ${ex_mbti && ex_mbti !== 'unknown' ? ex_mbti : '모름'}`,
        ``,
        `## 이별 정보`,
        `- 이별 시점: ${getBreakupTimeDetailKorean(time_since_breakup)}`,
        `- 이별 통보자: ${getBreakupInitiatorKorean(breakup_initiator)}`,
        `- 관계 깊이: ${getRelationshipDepthKorean(relationshipDepth)}`,
        `- 핵심 이별 이유: ${getCoreReasonKorean(coreReason)}`,
        ``,
        `## 상세 이야기 (음성/텍스트로 입력)`,
        `${breakup_detail || '(미입력)'}`,
        ``,
        `## 현재 상태 (복수 선택)`,
        `${getCurrentStateKorean(currentState)}`,
        ``,
        `## 현재 연락 상태`,
        `${getContactStatusKorean(contact_status)}`,
        ``,
        `## 목표별 심화 정보`,
        `${getGoalSpecificKorean(goalSpecific, primaryGoal)}`,
      ]

      // 대화 내용이 있으면 추가
      if (chat_history && chat_history.trim() !== '') {
        userPromptParts.push(
          ``,
          `## 카톡/대화 내용 (텍스트)`,
          `\`\`\``,
          chat_history,
          `\`\`\``,
          ``,
          `(위 대화 내용을 분석하여 두 사람의 관계 패턴, 숨겨진 감정을 파악해주세요. personalizedAnalysis.chatAnalysis에 반영)`
        )
      }

      // ✅ v3 NEW: 스크린샷 분석 결과가 있으면 추가
      if (screenshotAnalysisResult) {
        userPromptParts.push(
          ``,
          `## 📸 카톡 스크린샷 AI 분석 결과`,
          screenshotAnalysisResult,
          ``,
          `(위 스크린샷 분석 결과를 personalizedAnalysis.chatAnalysis와 전체 분석에 적극 반영해주세요. 스크린샷에서 발견한 패턴과 감정을 구체적으로 언급하세요.)`
        )
      }

      // 목표별 강조 포인트
      const goalEmphasis: Record<string, string> = {
        'healing': `감정 치유와 클로저에 집중해주세요. 재회 가능성은 간략히만 언급하고, emotionalPrescription을 가장 상세하게 작성해주세요.`,
        'reunion_strategy': `재회 전략에 집중해주세요. reunionAssessment와 strategicAdvice를 가장 상세하게 작성하고, 절대 하면 안 되는 것(neverDo)을 반드시 포함해주세요.`,
        'read_their_mind': `상대방 심리 분석에 집중해주세요. theirPerspective를 가장 상세하게 작성하고, "그 사람도 나를 생각할까?"에 대해 솔직하게 답해주세요.`,
        'new_start': `새 출발 준비도에 집중해주세요. newBeginning을 가장 상세하게 작성하고, 미해결 감정과 성장 포인트를 분석해주세요.`,
      }

      userPromptParts.push(
        ``,
        `---`,
        ``,
        `## 💡 요청사항`,
        `1. 반드시 reunionAssessment.score는 ${reunionCap}% 이하로 설정하세요`,
        `2. ${goalEmphasis[primaryGoal] || '사용자 상황에 맞는 맞춤 조언을 제공해주세요.'}`,
        `3. hardTruth.headline은 "냉정하게 말하면..." 또는 "솔직히..." 로 시작하세요`,
        `4. 모호한 표현 금지. 구체적인 기간과 조건을 명시하세요`,
        ``,
        `위 정보를 바탕으로 솔직한 조언자 페르소나로 분석 결과를 JSON 형식으로 제공해주세요.`
      )

      const userPrompt = userPromptParts.join('\n')

      const response = await llm.generate([
        {
          role: 'system',
          content: systemPrompt
        },
        {
          role: 'user',
          content: userPrompt
        }
      ], {
        temperature: 0.9,
        maxTokens: 8192,
        jsonMode: true
      })

      console.log(`✅ LLM 호출 완료: ${response.provider}/${response.model} - ${response.latency}ms`)

      // ✅ LLM 사용량 로깅 (v2 - 새 필드 포함)
      await UsageLogger.log({
        fortuneType: 'ex-lover',
        provider: response.provider,
        model: response.model,
        response: response,
        metadata: {
          name,
          ex_name,
          primaryGoal,
          coreReason,
          relationshipDepth,
          breakup_initiator,
          contact_status,
          time_since_breakup,
          reunionCap,
          currentStateCount: currentState.length,
          has_chat_history: !!chat_history,
          isPremium
        }
      })

      if (!response.content) throw new Error('LLM API 응답을 받을 수 없습니다.')

      const parsedResponse = JSON.parse(response.content)

      // 재회 가능성 점수 추출 (이미지 프롬프트용)
      const reunionScore = parsedResponse.reunionAssessment?.score ?? Math.min(50, reunionCap)

      // ✅ v3 응답 데이터 구조 (풍성한 개인화 분석)
      fortuneData = {
        // 표준화된 필드 (하위 호환성)
        fortuneType: 'ex-lover',
        fortune_type: 'ex-lover',
        score: parsedResponse.score || Math.floor(Math.random() * 20) + 60,
        content: parsedResponse.hardTruth?.headline || '솔직한 조언을 드릴게요.',
        summary: `재회 가능성 ${reunionScore}% - ${parsedResponse.title || '솔직한 조언자가 함께합니다'}`,
        advice: parsedResponse.closingMessage?.todayAction || '오늘은 자신에게 집중하세요.',

        // 메타 정보
        title: parsedResponse.title || `${name}님, 솔직하게 말해줄게요`,
        name,
        primaryGoal,
        coreReason,
        relationshipDepth,
        breakup_initiator,
        contact_status,
        time_since_breakup,
        reunionCap, // ✅ 재회 가능성 최대값 (프론트에서 활용 가능)

        // ✅ v3 NEW: 개인화 분석 섹션 (사용자 입력 기반)
        personalizedAnalysis: parsedResponse.personalizedAnalysis || {
          yourStory: breakup_detail
            ? `당신이 말씀하신 상황을 분석 중입니다... "${breakup_detail.substring(0, 50)}..."에서 느껴지는 감정을 파악하고 있어요.`
            : '상세한 이야기를 입력해주시면 더 정확한 분석이 가능해요.',
          emotionalPattern: currentState.length > 0
            ? `지금 ${getCurrentStateKorean(currentState)} 상태시군요. 이런 감정들이 동시에 느껴지는 건 자연스러운 거예요.`
            : '현재 감정 상태를 선택해주시면 맞춤 분석을 드릴 수 있어요.',
          chatAnalysis: chat_history || screenshotAnalysisResult ? '대화 내용을 분석 중입니다...' : null,
          coreInsight: '더 깊은 분석을 준비 중입니다.'
        },

        // ✅ v3 NEW: 스크린샷 분석 결과 (별도 저장)
        screenshotAnalysis: screenshotAnalysisResult ? {
          hasScreenshots: true,
          analyzedCount: chat_screenshots?.length || 0,
          summary: screenshotAnalysisResult
        } : null,

        // ✅ 헤더 이미지 프롬프트 (목표 기반)
        headerImagePrompt: generateReunionImagePrompt(
          currentState.includes('miss_them') ? 'miss' :
          currentState.includes('angry') ? 'anger' :
          currentState.includes('crying') ? 'sadness' :
          currentState.includes('relieved') ? 'relief' : 'acceptance',
          reunionScore,
          primaryGoal === 'healing' ? 'healing' :
          primaryGoal === 'reunion_strategy' ? 'reunionChance' :
          primaryGoal === 'read_their_mind' ? 'theirFeelings' : 'newLove'
        ),

        // ✅ v2 핵심 섹션: Hard Truth (항상 첫 번째)
        hardTruth: parsedResponse.hardTruth || {
          headline: '냉정하게 말하면, 지금은 정리가 필요한 시간이에요.',
          diagnosis: '현재 상황을 분석 중입니다.',
          realityCheck: ['현실 체크 포인트를 분석 중입니다.'],
          mostImportantAdvice: '가장 중요한 조언을 준비 중입니다.'
        },

        // ✅ v2 재회 평가 (현실적 기준)
        reunionAssessment: {
          ...parsedResponse.reunionAssessment,
          score: Math.min(parsedResponse.reunionAssessment?.score ?? 50, reunionCap), // ✅ reunionCap 강제 적용
          keyFactors: parsedResponse.reunionAssessment?.keyFactors || ['핵심 요인 분석 중'],
          timing: parsedResponse.reunionAssessment?.timing || '적절한 시기 분석 중',
          approach: parsedResponse.reunionAssessment?.approach || '접근 방법 분석 중',
          neverDo: parsedResponse.reunionAssessment?.neverDo || ['연락 폭탄 금지', 'SNS 스토킹 금지', '술 먹고 연락 금지']
        },

        // ✅ v2 감정 처방
        emotionalPrescription: parsedResponse.emotionalPrescription || {
          currentStateAnalysis: '현재 감정 상태 분석 중',
          healingFocus: '치유 포인트 분석 중',
          weeklyActions: ['자기 돌봄에 집중하기'],
          monthlyMilestone: '한 달 후 목표 설정 중'
        },

        // ✅ v2 상대방 관점
        theirPerspective: parsedResponse.theirPerspective || {
          likelyThoughts: '상대방 감정 추측 중',
          doTheyThinkOfYou: '솔직한 분석을 준비 중입니다',
          whatTheyNeed: '분석 중'
        },

        // ✅ v2 전략적 조언
        strategicAdvice: parsedResponse.strategicAdvice || {
          shortTerm: '1주일 내 해야 할 것 분석 중',
          midTerm: '1개월 내 목표 설정 중',
          longTerm: '3개월 후 체크포인트 설정 중'
        },

        // ✅ v2 새 출발
        newBeginning: parsedResponse.newBeginning || {
          readinessScore: 50,
          unresolvedIssues: ['미해결 감정 분석 중'],
          growthPoints: ['성장 포인트 분석 중'],
          newLoveTiming: '새 인연 시기 분석 중'
        },

        // ✅ v2 마일스톤
        milestones: parsedResponse.milestones || {
          oneWeek: ['감정 일기 쓰기', '자기 돌봄 시간 갖기'],
          oneMonth: ['새로운 취미 시작', '자기 성장 점검'],
          threeMonths: ['관계 복기 완료', '미래 계획 세우기']
        },

        // ✅ v2 마무리 메시지
        closingMessage: parsedResponse.closingMessage || {
          empathy: '힘들지... 괜찮아질 거야.',
          todayAction: '오늘은 좋아하는 음악 한 곡 들으며 쉬어요.'
        },

        // 하위 호환성: 기존 필드 매핑
        reunion_possibility: {
          score: Math.min(parsedResponse.reunionAssessment?.score ?? 50, reunionCap),
          analysis: parsedResponse.hardTruth?.diagnosis || '',
          favorable_timing: parsedResponse.reunionAssessment?.timing || '',
          conditions: parsedResponse.reunionAssessment?.keyFactors || [],
          recommendation: parsedResponse.hardTruth?.mostImportantAdvice || ''
        },
        comfort_message: parsedResponse.closingMessage?.empathy || '지금의 아픔은 반드시 지나갑니다.',

        timestamp: new Date().toISOString()
      }

      await supabase.from('fortune_cache').insert({
        cache_key: cacheKey,
        result: fortuneData,
        fortune_type: 'ex-lover',
        expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      })

      // ✅ Cohort Pool에 저장 (비동기, fire-and-forget)
      saveToCohortPool(supabase, 'ex-lover', cohortHash, cohortData, fortuneData)
        .catch(e => console.error('[ExLover] Cohort 저장 오류:', e))
    }

    // ✅ Percentile 계산 추가
    const percentileData = await calculatePercentile(supabase, 'ex-lover', fortuneData.score)
    const fortuneDataWithPercentile = addPercentileToResult(fortuneData, percentileData)

    return new Response(JSON.stringify({ success: true, data: fortuneDataWithPercentile }), {
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })

  } catch (error) {
    console.error('Ex-Lover Fortune Error:', error)
    return new Response(JSON.stringify({
      success: false,
      data: {},
      error: error instanceof Error ? error.message : '재회 인사이트 생성 중 오류가 발생했습니다.'
    }), {
      status: 500,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Access-Control-Allow-Origin': '*',
      },
    })
  }
})
