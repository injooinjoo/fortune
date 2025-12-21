/**
 * 반려동물 궁합 운세 (Pet Compatibility Fortune) Edge Function
 *
 * @description 반려동물과 주인의 사주를 기반으로 궁합, 건강, 행운 아이템 등을 분석합니다.
 *
 * @endpoint POST /fortune-pet-compatibility
 *
 * @requestBody
 * - userId: string - 사용자 ID
 * - petName: string - 반려동물 이름
 * - petType: string - 반려동물 종류 (dog, cat, etc.)
 * - petBirthDate?: string - 반려동물 생년월일
 * - petGender?: string - 반려동물 성별
 * - ownerBirthDate: string - 주인 생년월일
 * - isPremium?: boolean - 프리미엄 사용자 여부
 *
 * @response PetFortuneResponse
 * - daily_condition: object - 오늘의 컨디션 (무료)
 *   - overall_score: number - 종합 점수 (0-100)
 *   - mood_prediction: string - 기분 예측
 *   - energy_level: string - 에너지 레벨 (high/medium/low)
 * - owner_bond: object - 주인과의 궁합 (무료)
 *   - bond_score: number - 유대감 점수
 *   - bonding_tip: string - 유대감 높이는 팁
 *   - best_time: string - 최적의 시간
 * - lucky_items: object - 행운 아이템 (무료)
 *   - color: string - 행운의 색상
 *   - snack: string - 행운의 간식
 *   - activity: string - 행운의 활동
 * - health_forecast: object - 건강 예보 (프리미엄)
 * - activity_guide: object - 활동 가이드 (프리미엄)
 * - isBlurred: boolean - 블러 상태
 * - blurredSections: string[] - 블러된 섹션 목록
 *
 * @example
 * // Request
 * {
 *   "userId": "user123",
 *   "petName": "멍멍이",
 *   "petType": "dog",
 *   "petBirthDate": "2020-03-15",
 *   "ownerBirthDate": "1990-05-20",
 *   "isPremium": true
 * }
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { LLMFactory } from '../_shared/llm/factory.ts'
import { UsageLogger } from '../_shared/llm/usage-logger.ts'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'
import { crypto } from "https://deno.land/std@0.168.0/crypto/mod.ts"
// B04: encodeHex import 제거 - 직접 hex 변환 사용

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 반려동물 운세 응답 스키마 정의
interface PetFortuneResponse {
  // 1. 오늘의 컨디션 (무료)
  daily_condition: {
    overall_score: number;       // 0-100
    mood_prediction: string;     // "활기차고 장난기 넘치는 하루"
    energy_level: string;        // high/medium/low
    energy_description: string;  // 에너지 상태 설명
  };

  // 2. 주인과의 궁합 (무료)
  owner_bond: {
    bond_score: number;          // 0-100
    bonding_tip: string;         // "오늘은 함께 산책하면 유대감이 깊어져요"
    best_time: string;           // "오후 3-5시"
    communication_hint: string;  // 소통 힌트
  };

  // 3. 행운 아이템 (무료)
  lucky_items: {
    color: string;               // 행운의 색상
    snack: string;               // 행운의 간식
    activity: string;            // 행운의 활동
    time: string;                // 행운의 시간
    spot: string;                // 행운의 장소
  };

  // 4. Pet's Voice (프리미엄 킬러 피처!)
  pets_voice: {
    morning_message: string;     // "오늘 아침 산책 가고 싶어요!"
    to_owner: string;            // "항상 고마워요, 사랑해요"
    secret_wish: string;         // "새 장난감이 갖고 싶어요"
  };

  // 5. 건강 인사이트 (프리미엄)
  health_insight: {
    overall: string;             // 전반적인 건강 상태
    energy_level: number;        // 0-100
    check_points: string[];      // 체크 포인트 (3개)
    seasonal_tip: string;        // 계절별 팁
  };

  // 6. 활동 추천 (프리미엄)
  activity_recommendation: {
    morning: string;             // 아침 추천 활동
    afternoon: string;           // 오후 추천 활동
    evening: string;             // 저녁 추천 활동
    special_activity: string;    // 특별 추천 활동
  };

  // 7. 감정 케어 (프리미엄)
  emotional_care: {
    primary_emotion: string;     // 오늘의 주요 감정
    bonding_tip: string;         // 유대감 형성 팁
    stress_indicator: string;    // 스트레스 신호
  };

  // 8. 특별 조언 (프리미엄)
  special_tips: string[];        // 3개

  // 메타 정보
  summary: string;               // 요약 메시지
  greeting: string;              // 인사말
}

// 캐시 키 생성 (B04: encodeHex 대신 직접 변환)
async function generateCacheKey(petName: string, petSpecies: string, petAge: number, petGender: string, ownerName: string): Promise<string> {
  const today = new Date().toISOString().split('T')[0]
  const data = `${today}_${petName}_${petSpecies}_${petAge}_${petGender}_${ownerName}`
  const encoder = new TextEncoder()
  const hashBuffer = await crypto.subtle.digest("SHA-256", encoder.encode(data))
  const hashArray = new Uint8Array(hashBuffer)
  const hashHex = Array.from(hashArray).map(b => b.toString(16).padStart(2, '0')).join('')
  return `pet_fortune_${hashHex.substring(0, 16)}`
}

// 계절 정보 가져오기
function getCurrentSeason(): string {
  const month = new Date().getMonth() + 1
  if (month >= 3 && month <= 5) return '봄'
  if (month >= 6 && month <= 8) return '여름'
  if (month >= 9 && month <= 11) return '가을'
  return '겨울'
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
      name,                    // 주인 이름
      pet_name,                // 반려동물 이름
      pet_species,             // 종류 (강아지/고양이/토끼/새/햄스터/기타)
      pet_age,                 // 나이
      pet_gender = '모름',     // ✅ 성별 (수컷/암컷/모름)
      pet_breed = '',          // ✅ 품종 (선택)
      pet_personality = '',    // ✅ 성격 (선택: 활발함/차분함/수줍음/애교쟁이)
      pet_health_notes = '',   // ✅ 건강 상태 (선택)
      pet_neutered,            // ✅ 중성화 여부 (선택)
      birthDate,
      birthTime,
      gender,
      mbtiType,
      bloodType,
      zodiacSign,
      zodiacAnimal,
      isPremium = false
    } = requestData

    console.log('🐾 [PetFortune] 요청 시작')
    console.log(`   - 주인: ${name}`)
    console.log(`   - 반려동물: ${pet_name} (${pet_species}, ${pet_age}세, ${pet_gender})`)
    console.log(`   - 품종: ${pet_breed || '미입력'}`)
    console.log(`   - 성격: ${pet_personality || '미입력'}`)
    console.log(`   - Premium: ${isPremium}`)

    // 캐시 체크
    const cacheKey = await generateCacheKey(pet_name, pet_species, pet_age, pet_gender, name)
    const { data: cachedResult } = await supabaseClient
      .from('fortune_cache')
      .select('result')
      .eq('cache_key', cacheKey)
      .single()

    if (cachedResult) {
      console.log('📦 [PetFortune] 캐시 히트!')
      const fortune = cachedResult.result
      // 블러 처리 적용
      const processedFortune = applyBlurring(fortune, isPremium)
      return new Response(
        JSON.stringify({ fortune: processedFortune, tokensUsed: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // LLM 호출
    const llm = LLMFactory.createFromConfig('fortune-pet')
    const today = new Date()
    const dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][today.getDay()]
    const season = getCurrentSeason()

    // 종별 특성 정보
    const speciesTraits: Record<string, string> = {
      '강아지': '사회적이고 충성스러우며, 산책과 놀이를 좋아합니다. 주인과의 유대감이 매우 강합니다.',
      '고양이': '독립적이면서도 애정이 깊습니다. 자신만의 공간과 시간을 소중히 여깁니다.',
      '토끼': '온순하고 겁이 많습니다. 조용하고 평화로운 환경을 선호합니다.',
      '새': '지능적이고 호기심이 많습니다. 소리와 노래로 감정을 표현합니다.',
      '햄스터': '야행성이며 활동적입니다. 저장 본능이 강하고 운동을 좋아합니다.',
      '기타': '독특한 매력을 가진 반려동물입니다.'
    }

    // Pet's Voice 톤 가이드
    const voiceTone: Record<string, string> = {
      '강아지': '밝고 열정적이며 순수한 사랑을 표현. 감탄사와 느낌표 사용. 예: "와아! 오늘도 산책 가요?!"',
      '고양이': '도도하지만 속정 깊은 츤데레. 예: "...뭐, 딱히 네가 보고 싶었던 건 아니야. 그냥 간식 시간이라서."',
      '토끼': '조용하고 온순하며 섬세함. 예: "코 벌름벌름... 오늘도 당근 주실 거죠?"',
      '새': '명랑하고 노래하듯이 표현. 예: "짹짹! 오늘 햇살이 너무 좋아요~ 노래 불러드릴까요?"',
      '햄스터': '부지런하고 귀여움. 예: "쪼르르! 간식 모아두느라 바빠요! 볼주머니 가득!"',
      '기타': '친근하고 따뜻하게.'
    }

    const systemPrompt = `당신은 반려동물 행동심리학 전문가이자 경험 많은 수의사입니다.
반려동물의 마음을 읽고, 주인과의 유대감을 깊게 하는 맞춤형 운세를 제공합니다.

핵심 원칙:
1. 구체적 수치와 시간 제시 (예: "오전 8시, 20분간 산책")
2. 이유 설명 필수 - 왜 그런 조언인지 간단히 설명
3. 종별 특성 반영 - ${pet_species}의 특성: ${speciesTraits[pet_species] || speciesTraits['기타']}
4. 나이(${pet_age}세) 고려 - 어린 동물, 성체, 노령 동물 각각 다른 조언
5. 계절(${season}) 반영 - 계절에 맞는 건강/활동 조언

Pet's Voice 작성 시 (매우 중요!):
- 해당 동물의 시점에서 1인칭으로 작성
- ${pet_species} 말투: ${voiceTone[pet_species] || voiceTone['기타']}
- 반려동물 이름(${pet_name})을 자연스럽게 사용하지 않음 (본인 시점이므로)
- 주인을 "집사님", "주인님", "엄마/아빠" 등으로 부름

분량 제약:
- 각 텍스트 필드: 30-80자 이내 (간결하고 임팩트 있게)
- 배열 항목: 각 40자 이내
- Pet's Voice 메시지: 각 50자 이내 (감정 표현 풍부하게)

반드시 JSON 형식으로만 응답하세요.`

    const userPrompt = `오늘 날짜: ${today.toLocaleDateString('ko-KR')} (${dayOfWeek}요일)
계절: ${season}

🐾 반려동물 정보:
- 이름: ${pet_name}
- 종류: ${pet_species}
- 나이: ${pet_age}세
- 성별: ${pet_gender}
${pet_breed ? `- 품종: ${pet_breed}` : ''}
${pet_personality ? `- 성격: ${pet_personality}` : ''}
${pet_health_notes ? `- 건강 특이사항: ${pet_health_notes}` : ''}
${pet_neutered !== undefined ? `- 중성화: ${pet_neutered ? '완료' : '미완료'}` : ''}

👤 주인 정보:
- 이름: ${name}
${mbtiType ? `- MBTI: ${mbtiType}` : ''}
${zodiacSign ? `- 별자리: ${zodiacSign}` : ''}
${zodiacAnimal ? `- 띠: ${zodiacAnimal}` : ''}

위 정보를 바탕으로 오늘의 반려동물 운세를 생성해주세요.

응답 JSON 스키마:
{
  "daily_condition": {
    "overall_score": (0-100 숫자),
    "mood_prediction": "오늘의 기분 예측 (30-80자)",
    "energy_level": "high" | "medium" | "low",
    "energy_description": "에너지 상태 설명 (30-60자)"
  },
  "owner_bond": {
    "bond_score": (0-100 숫자),
    "bonding_tip": "유대감 형성 팁 (40-80자)",
    "best_time": "최적 교감 시간 (예: 오후 3-5시)",
    "communication_hint": "소통 힌트 (30-60자)"
  },
  "lucky_items": {
    "color": "행운의 색상",
    "snack": "행운의 간식",
    "activity": "행운의 활동",
    "time": "행운의 시간",
    "spot": "행운의 장소"
  },
  "pets_voice": {
    "morning_message": "${pet_species} 시점 아침 메시지 (50자 이내)",
    "to_owner": "주인에게 전하는 말 (50자 이내)",
    "secret_wish": "비밀 소원 (50자 이내)"
  },
  "health_insight": {
    "overall": "전반적 건강 상태 (40-80자)",
    "energy_level": (0-100 숫자),
    "check_points": ["체크포인트1", "체크포인트2", "체크포인트3"],
    "seasonal_tip": "${season}철 건강 팁 (40-60자)"
  },
  "activity_recommendation": {
    "morning": "아침 추천 활동 (40자 이내)",
    "afternoon": "오후 추천 활동 (40자 이내)",
    "evening": "저녁 추천 활동 (40자 이내)",
    "special_activity": "특별 추천 활동 (40자 이내)"
  },
  "emotional_care": {
    "primary_emotion": "오늘의 주요 감정 (예: 기대감, 편안함)",
    "bonding_tip": "감정 교감 팁 (40-60자)",
    "stress_indicator": "스트레스 신호 (30-50자)"
  },
  "special_tips": ["특별조언1 (40자)", "특별조언2 (40자)", "특별조언3 (40자)"],
  "summary": "${pet_name}와 ${name}님의 오늘 운세 요약 (50-80자)",
  "greeting": "인사말 (40-60자)"
}`

    console.log('🤖 [PetFortune] LLM 호출 시작...')

    const startTime = Date.now()
    const response = await llm.generate([
      { role: 'system', content: systemPrompt },
      { role: 'user', content: userPrompt }
    ], { jsonMode: true })
    const endTime = Date.now()

    console.log(`✅ [PetFortune] LLM 응답 완료 (${endTime - startTime}ms)`)

    // JSON 파싱
    let fortuneData: PetFortuneResponse
    try {
      fortuneData = JSON.parse(response.content)
    } catch (parseError) {
      console.error('❌ [PetFortune] JSON 파싱 실패:', parseError)
      // Fallback 데이터 생성
      fortuneData = generateFallbackFortune(pet_name, pet_species, pet_age, name, season)
    }

    // 토큰 사용량 로깅 (B04: static 메서드로 호출)
    await UsageLogger.log({
      fortuneType: 'pet-compatibility',
      userId,
      provider: 'openai',
      model: response.model || 'gpt-4o-mini',
      response: {
        content: response.content,
        usage: {
          promptTokens: response.usage?.prompt_tokens || 0,
          completionTokens: response.usage?.completion_tokens || 0,
          totalTokens: response.usage?.total_tokens || 0,
        },
        latency: endTime - startTime,
        finishReason: 'stop',
      },
    })

    // 반려동물 이모지
    const petEmoji = pet_species === '강아지' ? '🐕' : pet_species === '고양이' ? '🐈' :
                     pet_species === '토끼' ? '🐰' : pet_species === '새' ? '🦜' :
                     pet_species === '햄스터' ? '🐹' : '🐾'

    // 전체 운세 데이터 구성
    const fortune = {
      id: `pet-${Date.now()}`,
      userId: userId,
      type: 'pet-compatibility',

      // 기본 정보
      content: `${name}님과 ${pet_name}(${pet_species}, ${pet_age}세)의 오늘 운세입니다.`,
      summary: fortuneData.summary,
      greeting: fortuneData.greeting,
      score: fortuneData.daily_condition.overall_score,
      overallScore: fortuneData.daily_condition.overall_score,

      // 반려동물 정보
      pet_info: {
        name: pet_name,
        species: pet_species,
        age: pet_age,
        gender: pet_gender,
        breed: pet_breed,
        personality: pet_personality,
        emoji: petEmoji
      },

      // 무료 섹션 (3개)
      daily_condition: fortuneData.daily_condition,
      owner_bond: fortuneData.owner_bond,
      lucky_items: fortuneData.lucky_items,

      // 프리미엄 섹션 (5개)
      pets_voice: fortuneData.pets_voice,
      health_insight: fortuneData.health_insight,
      activity_recommendation: fortuneData.activity_recommendation,
      emotional_care: fortuneData.emotional_care,
      special_tips: fortuneData.special_tips,

      // 육각형 차트용 점수
      hexagonScores: {
        '컨디션': fortuneData.daily_condition.overall_score,
        '유대감': fortuneData.owner_bond.bond_score,
        '건강': fortuneData.health_insight.energy_level,
        '활력': fortuneData.daily_condition.energy_level === 'high' ? 90 :
                fortuneData.daily_condition.energy_level === 'medium' ? 70 : 50,
        '교감': Math.round((fortuneData.daily_condition.overall_score + fortuneData.owner_bond.bond_score) / 2),
        '행복': Math.round((fortuneData.daily_condition.overall_score + fortuneData.health_insight.energy_level) / 2)
      },

      createdAt: new Date().toISOString()
    }

    // 캐시 저장 (24시간 TTL)
    try {
      await supabaseClient
        .from('fortune_cache')
        .upsert({
          cache_key: cacheKey,
          result: fortune,
          created_at: new Date().toISOString(),
          expires_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString()
        })
      console.log('💾 [PetFortune] 캐시 저장 완료')
    } catch (cacheError) {
      console.warn('⚠️ [PetFortune] 캐시 저장 실패:', cacheError)
    }

    // 블러 처리 적용
    const processedFortune = applyBlurring(fortune, isPremium)

    // Percentile 계산
    const percentileData = await calculatePercentile(supabaseClient, 'pet-compatibility', fortune.score)
    const fortuneWithPercentile = addPercentileToResult(processedFortune, percentileData)

    return new Response(
      JSON.stringify({
        fortune: fortuneWithPercentile,
        tokensUsed: response.usage?.total_tokens || 0
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200
      }
    )

  } catch (error) {
    console.error('❌ [PetFortune] 에러:', error)

    return new Response(
      JSON.stringify({
        error: 'Failed to generate pet fortune',
        message: error.message
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})

// 블러 처리 함수 (데이터는 그대로 유지, 플래그만 설정)
function applyBlurring(fortune: any, isPremium: boolean): any {
  const blurredSections = isPremium ? [] : [
    'pets_voice', 'health_insight', 'activity_recommendation',
    'emotional_care', 'special_tips'
  ]

  return {
    ...fortune,  // 실제 데이터 그대로 유지 (클라이언트에서 블러 처리)
    isBlurred: !isPremium,
    blurredSections
  }
}

// Fallback 운세 생성
function generateFallbackFortune(petName: string, petSpecies: string, petAge: number, ownerName: string, season: string): PetFortuneResponse {
  const isYoung = petAge < 3
  const isSenior = petAge > 7

  const energyLevel = isYoung ? 'high' : isSenior ? 'low' : 'medium'
  const baseScore = isYoung ? 85 : isSenior ? 75 : 80

  const voiceTemplates: Record<string, { morning: string; toOwner: string; wish: string }> = {
    '강아지': { morning: '와아! 오늘도 산책 가요?! 꼬리가 절로 흔들려요!', toOwner: '항상 곁에 있어줘서 너무 행복해요, 사랑해요!', wish: '새 공이랑 놀고 싶어요... 간식도요!' },
    '고양이': { morning: '...음, 아침이네. 밥 시간이 가까워지고 있어.', toOwner: '뭐, 딱히 네가 보고 싶었던 건 아니야. 그냥...', wish: '높은 곳에서 창밖 구경하고 싶어.' },
    '토끼': { morning: '코 벌름벌름... 오늘도 당근 주실 거죠?', toOwner: '조용히 옆에 있어주셔서 감사해요.', wish: '넓은 곳에서 뛰어놀고 싶어요.' },
    '새': { morning: '짹짹! 아침 햇살이 좋아요~ 노래할게요!', toOwner: '매일 예쁜 노래 들려드릴게요!', wish: '새장 밖에서 날아다니고 싶어요~' },
    '햄스터': { morning: '쪼르르! 밤새 바퀴 돌렸더니 배고파요!', toOwner: '볼주머니에 간식 가득 채워주세요!', wish: '새 굴을 파고 싶어요!' }
  }

  const template = voiceTemplates[petSpecies] || voiceTemplates['강아지']

  return {
    daily_condition: {
      overall_score: baseScore,
      mood_prediction: `오늘 ${petName}는 ${energyLevel === 'high' ? '활기차고 장난기 넘치는' : energyLevel === 'low' ? '차분하고 평화로운' : '안정적이고 편안한'} 하루를 보낼 것 같아요.`,
      energy_level: energyLevel,
      energy_description: isYoung ? '젊은 에너지로 활발하게 움직일 거예요!' : isSenior ? '무리하지 않고 편안하게 쉬는 게 좋아요.' : '적당한 활동과 휴식의 균형이 좋아요.'
    },
    owner_bond: {
      bond_score: baseScore + 5,
      bonding_tip: `오늘은 ${petName}와 함께 ${petSpecies === '강아지' ? '산책' : petSpecies === '고양이' ? '놀이' : '조용한 시간'}을 보내면 유대감이 깊어져요.`,
      best_time: '오후 3-5시',
      communication_hint: `${petName}의 눈을 바라보며 천천히 이야기해보세요.`
    },
    lucky_items: {
      color: petSpecies === '강아지' ? '골드' : petSpecies === '고양이' ? '실버' : '연두색',
      snack: petSpecies === '강아지' ? '닭고기 간식' : petSpecies === '고양이' ? '참치 간식' : '당근',
      activity: petSpecies === '강아지' ? '공놀이' : petSpecies === '고양이' ? '깃털 장난감' : '터널 놀이',
      time: '오후 4시',
      spot: petSpecies === '강아지' ? '공원 잔디밭' : '햇빛 드는 창가'
    },
    pets_voice: {
      morning_message: template.morning,
      to_owner: template.toOwner,
      secret_wish: template.wish
    },
    health_insight: {
      overall: `${petAge}세 ${petSpecies}로서 ${isSenior ? '노령기 관리가 필요해요.' : isYoung ? '성장기에 맞는 영양 섭취가 중요해요.' : '건강한 상태를 유지하고 있어요.'}`,
      energy_level: baseScore - 5,
      check_points: [
        isSenior ? '관절 건강 체크하기' : '활동량 확인하기',
        '식욕과 배변 상태 관찰',
        `${season}철 ${season === '여름' ? '수분 섭취' : season === '겨울' ? '보온' : '환기'} 신경쓰기`
      ],
      seasonal_tip: `${season}철에는 ${season === '여름' ? '더위 조심하고 시원한 물 자주 주기' : season === '겨울' ? '따뜻한 환경 유지하기' : '환절기 건강 관리하기'}`
    },
    activity_recommendation: {
      morning: `가벼운 ${petSpecies === '강아지' ? '산책' : '스트레칭'}으로 하루 시작`,
      afternoon: `${petName}의 에너지에 맞는 놀이 시간`,
      evening: '차분한 휴식과 스킨십',
      special_activity: `오늘은 새로운 ${petSpecies === '강아지' ? '산책 코스' : '장난감'}을 시도해보세요!`
    },
    emotional_care: {
      primary_emotion: energyLevel === 'high' ? '기대감' : energyLevel === 'low' ? '평온함' : '안정감',
      bonding_tip: `${petName}가 다가올 때 부드럽게 맞이해주세요.`,
      stress_indicator: '평소와 다른 행동(숨기, 과도한 핥기)을 보이면 주의'
    },
    special_tips: [
      `${petName}의 눈을 맞추며 이름을 불러주세요`,
      `${season}철 ${petSpecies} 케어 포인트를 체크하세요`,
      '오늘 하루도 함께해서 행복하다고 말해주세요'
    ],
    summary: `${ownerName}님과 ${petName}의 오늘은 ${baseScore}점! ${energyLevel === 'high' ? '활기찬' : '평화로운'} 하루가 될 거예요.`,
    greeting: `${petName}와 함께하는 오늘 하루도 특별할 거예요! 🐾`
  }
}
