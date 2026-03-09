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
import {
  extractPetCompatibilityCohort,
  generateCohortHash,
  getFromCohortPool,
  saveToCohortPool,
  personalize,
} from '../_shared/cohort/index.ts'
// B04: encodeHex import 제거 - 직접 hex 변환 사용

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// 반려동물 운세 응답 스키마 정의
interface PetFortuneResponse {
  // NEW: 스토리 형식 섹션 (무료)
  today_story: {
    opening: string;           // "오늘 아침, 말티즈 뭉치는..."
    morning_chapter: string;   // 아침 이야기 (80자)
    afternoon_chapter: string; // 오후 이야기 (80자)
    evening_chapter: string;   // 저녁 이야기 (80자)
  };

  // NEW: 품종 맞춤 섹션 (무료)
  breed_specific: {
    trait_today: string;       // "오늘 말티즈의 활발함이 빛날 날"
    health_watch: string;      // "슬개골 주의, 계단 점프 자제"
    grooming_tip: string;      // "오늘 빗질하면 털이 윤기날 거예요"
  };

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

  // 4. Pet's Voice - 속마음 편지 (프리미엄 킬러 피처!)
  pets_voice: {
    // 감성 편지 (반려동물 1인칭 시점)
    heartfelt_letter: string;    // "주인님! 오늘따라 발소리가 유난히 반갑게 들려요..." (80-120자)
    letter_type: 'comfort' | 'excitement' | 'gratitude' | 'longing';  // 편지 톤
    secret_confession: string;   // "사실... 당신이 집에 오는 시간이 제일 좋아요" (50-80자)
  };

  // 4-1. 교감 미션 (무료 - 킬러 피처!)
  bonding_mission: {
    mission_type: 'skinship' | 'play' | 'environment' | 'communication';
    mission_title: string;       // "3초 더 눈 맞춤" (10자 이내)
    mission_description: string; // 구체적인 행동 설명 (40-60자)
    expected_reaction: string;   // 예상되는 반려동물 반응 (30-50자)
    difficulty: 'easy' | 'medium' | 'special';
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
      return new Response(
        JSON.stringify({ success: true, data: fortune, cached: true, tokensUsed: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    // ===== Cohort Pool 조회 =====
    const cohortData = extractPetCompatibilityCohort({ petType: pet_species, birthDate })
    const cohortHash = await generateCohortHash(cohortData)
    console.log(`[fortune-pet-compatibility] 🔍 Cohort: ${JSON.stringify(cohortData)}, hash: ${cohortHash.slice(0, 8)}...`)

    const cohortResult = await getFromCohortPool(supabaseClient, 'pet-compatibility', cohortHash)
    if (cohortResult) {
      console.log(`[fortune-pet-compatibility] ✅ Cohort Pool HIT!`)

      // Personalize with user-specific data
      const personalizedResult = personalize(cohortResult, {
        '{{userName}}': name || '회원님',
        '{{name}}': name || '회원님',
        '{{petName}}': pet_name || '반려동물',
        '{{pet_name}}': pet_name || '반려동물',
        '{{petSpecies}}': pet_species || '반려동물',
        '{{pet_species}}': pet_species || '반려동물',
        '{{petAge}}': String(pet_age || 1),
        '{{pet_age}}': String(pet_age || 1),
        '{{petBreed}}': pet_breed || pet_species,
        '{{pet_breed}}': pet_breed || pet_species,
      })

      const fortune = typeof personalizedResult === 'string'
        ? JSON.parse(personalizedResult)
        : personalizedResult

      // Percentile 계산
      const percentileData = await calculatePercentile(supabaseClient, 'pet-compatibility', fortune.score || fortune.overallScore || 80)
      const fortuneWithPercentile = addPercentileToResult(fortune, percentileData)

      return new Response(
        JSON.stringify({
          success: true,
          data: fortuneWithPercentile,
          cached: true,
          cohortHit: true,
          tokensUsed: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' } }
      )
    }

    console.log(`[fortune-pet-compatibility] 💨 Cohort Pool MISS - LLM 호출 필요`)

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

    // 품종별 상세 특성 데이터베이스 (NEW)
    const breedTraitsDB: Record<string, Record<string, { healthIssues: string[]; temperament: string; grooming: string; specialNeeds: string[] }>> = {
      '강아지': {
        '말티즈': { healthIssues: ['슬개골 탈구', '치아 문제', '눈물 자국'], temperament: '애교 많고 활발함', grooming: '매일 빗질 필요', specialNeeds: ['분리불안 주의', '소형견 관절 케어'] },
        '푸들': { healthIssues: ['눈 질환', '피부 알러지', '귀 감염'], temperament: '영리하고 활발함', grooming: '정기적 미용 필수', specialNeeds: ['정신적 자극 필요', '털 관리'] },
        '골든리트리버': { healthIssues: ['고관절 이형성', '피부 알러지', '비만'], temperament: '온순하고 사람 좋아함', grooming: '주 2-3회 빗질', specialNeeds: ['충분한 운동 필수', '더위 주의'] },
        '시츄': { healthIssues: ['눈 문제', '호흡기', '피부'], temperament: '친근하고 느긋함', grooming: '매일 빗질', specialNeeds: ['더위에 약함', '눈 관리'] },
        '포메라니안': { healthIssues: ['슬개골', '기관지', '치아'], temperament: '활발하고 경계심 있음', grooming: '주 3회 빗질', specialNeeds: ['낙상 주의', '치아 관리'] },
        '치와와': { healthIssues: ['슬개골', '저혈당', '치아'], temperament: '용감하고 애착 강함', grooming: '주 1-2회 빗질', specialNeeds: ['추위에 약함', '작은 체구 보호'] },
        '비숑프리제': { healthIssues: ['눈물 자국', '피부 알러지', '치아'], temperament: '명랑하고 애교 많음', grooming: '매일 빗질, 정기 미용', specialNeeds: ['분리불안 주의', '털 관리'] },
        '요크셔테리어': { healthIssues: ['슬개골', '치아', '저혈당'], temperament: '활발하고 호기심 많음', grooming: '매일 빗질', specialNeeds: ['추위 주의', '치아 관리'] },
        '닥스훈트': { healthIssues: ['디스크', '비만', '치아'], temperament: '호기심 많고 고집 있음', grooming: '주 1-2회 빗질', specialNeeds: ['허리 보호', '계단 주의'] },
        '웰시코기': { healthIssues: ['디스크', '비만', '고관절'], temperament: '활발하고 영리함', grooming: '주 2-3회 빗질', specialNeeds: ['허리 보호', '체중 관리'] },
        '진돗개': { healthIssues: ['피부', '관절'], temperament: '충성스럽고 용맹함', grooming: '주 2회 빗질', specialNeeds: ['충분한 운동', '사회화 훈련'] },
        '시바이누': { healthIssues: ['알러지', '슬개골'], temperament: '독립적이고 깔끔함', grooming: '주 2-3회 빗질', specialNeeds: ['털 빠짐 관리', '자존심 존중'] },
        '라브라도리트리버': { healthIssues: ['고관절', '비만', '눈'], temperament: '친근하고 에너지 넘침', grooming: '주 2회 빗질', specialNeeds: ['충분한 운동', '체중 관리'] },
        '비글': { healthIssues: ['귀 감염', '비만', '디스크'], temperament: '밝고 호기심 많음', grooming: '주 1회 빗질', specialNeeds: ['냄새 추적 본능', '울타리 필수'] },
        '불독': { healthIssues: ['호흡기', '피부', '관절'], temperament: '온순하고 느긋함', grooming: '주름 관리 필수', specialNeeds: ['더위에 약함', '과격한 운동 금지'] },
        '셰틀랜드쉽독': { healthIssues: ['눈', '피부'], temperament: '영리하고 민감함', grooming: '주 3회 빗질', specialNeeds: ['정신적 자극', '털 관리'] },
        '보더콜리': { healthIssues: ['눈', '고관절'], temperament: '매우 영리하고 활동적', grooming: '주 2-3회 빗질', specialNeeds: ['많은 운동량', '일거리 필요'] },
        '사모예드': { healthIssues: ['고관절', '눈', '피부'], temperament: '밝고 사교적', grooming: '매일 빗질', specialNeeds: ['더위에 약함', '털 관리'] },
        '허스키': { healthIssues: ['눈', '고관절'], temperament: '활발하고 독립적', grooming: '주 3회 빗질', specialNeeds: ['많은 운동량', '더위 주의'] },
        '믹스견': { healthIssues: [], temperament: '다양한 성격', grooming: '털 종류에 따라', specialNeeds: ['개체별 특성 관찰'] }
      },
      '고양이': {
        '페르시안': { healthIssues: ['눈물', '호흡기', '신장'], temperament: '조용하고 온순함', grooming: '매일 빗질 필수', specialNeeds: ['얼굴 관리', '더위 주의'] },
        '러시안블루': { healthIssues: ['비만', '스트레스'], temperament: '수줍지만 충성스러움', grooming: '주 1-2회 빗질', specialNeeds: ['규칙적 생활', '조용한 환경'] },
        '스코티시폴드': { healthIssues: ['관절', '연골', '심장'], temperament: '온순하고 애교 많음', grooming: '주 2회 빗질', specialNeeds: ['관절 건강 주의', '편한 환경'] },
        '브리티시숏헤어': { healthIssues: ['비만', '심장', '신장'], temperament: '차분하고 독립적', grooming: '주 2회 빗질', specialNeeds: ['체중 관리', '운동량 확보'] },
        '먼치킨': { healthIssues: ['척추', '관절'], temperament: '활발하고 호기심 많음', grooming: '주 1-2회 빗질', specialNeeds: ['높은 곳 주의', '관절 케어'] },
        '랙돌': { healthIssues: ['심장', '신장'], temperament: '온순하고 사람 좋아함', grooming: '주 2-3회 빗질', specialNeeds: ['실내 생활', '부드러운 대우'] },
        '뱅갈': { healthIssues: ['심장', '슬개골'], temperament: '활발하고 놀이 좋아함', grooming: '주 1회 빗질', specialNeeds: ['많은 놀이 시간', '자극적 환경'] },
        '아비시니안': { healthIssues: ['신장', '잇몸'], temperament: '호기심 많고 활동적', grooming: '주 1회 빗질', specialNeeds: ['높은 곳 놀이', '상호작용'] },
        '메인쿤': { healthIssues: ['심장', '고관절'], temperament: '온순하고 사교적', grooming: '주 2-3회 빗질', specialNeeds: ['큰 공간', '털 관리'] },
        '샴': { healthIssues: ['호흡기', '눈'], temperament: '수다스럽고 애착 강함', grooming: '주 1회 빗질', specialNeeds: ['관심과 대화', '외로움 주의'] },
        '터키시앙고라': { healthIssues: ['청각', '심장'], temperament: '영리하고 활발함', grooming: '주 2회 빗질', specialNeeds: ['청각 검사', '털 관리'] },
        '노르웨이숲': { healthIssues: ['심장', '신장'], temperament: '온순하고 독립적', grooming: '주 2-3회 빗질', specialNeeds: ['털 관리', '운동 공간'] },
        '코리안숏헤어': { healthIssues: [], temperament: '다양한 성격', grooming: '주 1회 빗질', specialNeeds: ['개체별 특성 관찰'] },
        '믹스묘': { healthIssues: [], temperament: '다양한 성격', grooming: '털에 따라', specialNeeds: ['개체별 특성 관찰'] }
      },
      '토끼': {
        '네덜란드드워프': { healthIssues: ['치아', '소화기'], temperament: '호기심 많고 활발함', grooming: '주 2회 빗질', specialNeeds: ['작은 체구 보호', '치아 관리'] },
        '미니렉스': { healthIssues: ['발바닥 염증', '소화기'], temperament: '온순하고 조용함', grooming: '주 1회 빗질', specialNeeds: ['부드러운 바닥', '스트레스 주의'] },
        '홀랜드롭': { healthIssues: ['귀 감염', '치아'], temperament: '온순하고 사람 좋아함', grooming: '주 2회 빗질', specialNeeds: ['귀 관리', '치아 검사'] },
        '라이언헤드': { healthIssues: ['치아', '털 뭉침'], temperament: '호기심 많고 친근함', grooming: '매일 빗질', specialNeeds: ['갈기 관리', '더위 주의'] },
        '믹스토끼': { healthIssues: [], temperament: '다양한 성격', grooming: '털에 따라', specialNeeds: ['개체별 관찰'] }
      }
    }

    // 품종 특성 가져오기 함수
    function getBreedTraits(species: string, breed: string): string {
      const speciesBreeds = breedTraitsDB[species]
      if (!speciesBreeds || !breed) {
        return `${species}의 일반적인 특성을 기반으로 분석합니다.`
      }
      const traits = speciesBreeds[breed]
      if (!traits) {
        return `${species}의 일반적인 특성을 기반으로 분석합니다.`
      }
      return `
[${breed} 품종 전문 분석]
• 건강 주의사항: ${traits.healthIssues.join(', ') || '특이사항 없음'}
• 성격 특성: ${traits.temperament}
• 털 관리: ${traits.grooming}
• 특별 케어: ${traits.specialNeeds.join(', ')}`
    }

    // 성격별 케어 가이드
    const personalityGuide: Record<string, string> = {
      '활발함': '에너지 발산 활동 추천, 지루함 주의, 충분한 놀이 시간 필요',
      '차분함': '조용한 활동 선호, 갑작스러운 변화 스트레스, 안정적 환경 유지',
      '수줍음': '새로운 환경 적응 시간 필요, 안전한 숨을 공간 제공, 부드러운 접근',
      '애교쟁이': '스킨십 욕구 높음, 관심받기 좋아함, 칭찬과 애정 표현 중요',
      '호기심쟁이': '탐험 활동 추천, 안전 확인 필수, 다양한 장난감 제공',
      '독립적': '개인 공간 존중, 과도한 간섭 주의, 자율성 보장'
    }

    // Pet's Voice 톤 가이드 (감성 편지 버전)
    const voiceTone: Record<string, { style: string; letterExamples: string[]; missionExamples: string[] }> = {
      '강아지': {
        style: '밝고 열정적이며 순수한 사랑을 표현. 감탄사와 느낌표 사용.',
        letterExamples: [
          '주인님! 오늘따라 당신의 발소리가 유난히 반갑게 들려요. 밖에서 힘들었던 일은 나랑 노는 동안 다 잊어버려요!',
          '오늘따라 코끝이 근질근질해요! 평소 가던 길 말고, 한 번도 안 가본 골목으로 데려가 줄래요?',
          '당신이 나를 쓰다듬어줄 때, 내 꼬리는 세상에서 가장 행복하게 흔들려요!'
        ],
        missionExamples: ['숨바꼭질 놀이', '새 산책 코스', '특별 간식 탐험']
      },
      '고양이': {
        style: '도도하지만 속정 깊은 츤데레. 속마음을 수줍게 표현.',
        letterExamples: [
          '...뭐, 딱히 기다린 건 아니야. 그냥 창밖이 심심해서 보고 있었을 뿐이야. 근데... 왔구나.',
          '오늘따라 네 무릎이 유독 따뜻해 보여. 뭐, 잠깐 앉아도 되긴 해... 아주 잠깐만.',
          '매일 같은 시간에 밥을 챙겨주는 거... 고맙다고 생각은 해. 말은 안 하지만.'
        ],
        missionExamples: ['조용한 동행', '창가 해바라기 시간', '특별 그루밍']
      },
      '토끼': {
        style: '조용하고 온순하며 섬세한 감정 표현.',
        letterExamples: [
          '코 벌름벌름... 당신의 손 냄새가 오늘따라 좋아요. 천천히 쓰다듬어 주실 거죠?',
          '새 건초 냄새가 나요... 당신이 챙겨줬구나. 행복해요.',
          '조용히 옆에 있어주는 것만으로도 든든해요. 오늘도 고마워요.'
        ],
        missionExamples: ['부드러운 터치', '터널 탐험', '건초 파티']
      },
      '새': {
        style: '명랑하고 노래하듯이 표현. 호기심 가득.',
        letterExamples: [
          '짹짹! 오늘 아침 햇살이 정말 예뻐요! 당신에게 노래 불러드릴게요~',
          '새장 밖이 궁금해요... 당신 어깨 위에서 세상을 보고 싶어요!',
          '당신이 휘파람 불어주면 저도 따라 부를게요! 우리만의 노래예요!'
        ],
        missionExamples: ['어깨 산책', '노래 듀엣', '깃털 스킨십']
      },
      '햄스터': {
        style: '부지런하고 귀여움. 작은 것에도 큰 기쁨.',
        letterExamples: [
          '쪼르르! 볼주머니에 간식 가득 모았어요! 나중에 당신 보여줄게요!',
          '밤새 바퀴 돌렸어요! 당신이 잘 때 저도 열심히 운동했답니다!',
          '새 굴 팠어요! 당신이 만들어준 침구가 정말 폭신폭신해요!'
        ],
        missionExamples: ['미로 탐험', '간식 보물찾기', '손바닥 산책']
      },
      '기타': {
        style: '친근하고 따뜻하게.',
        letterExamples: ['오늘도 당신과 함께해서 행복해요.'],
        missionExamples: ['특별한 시간']
      }
    }

    // 나이별 케어 가이드
    function getAgeGuide(species: string, age: number): string {
      if (species === '강아지' || species === '고양이') {
        if (age <= 1) return '어린 동물: 성장기 영양 중요, 사회화 훈련, 예방접종 확인'
        if (age <= 7) return '성체: 활동적인 생활, 정기 건강검진, 체중 관리'
        return '노령기: 관절 케어, 부드러운 운동, 정기 검진 필수, 편안한 환경'
      }
      if (species === '토끼') {
        if (age <= 1) return '어린 토끼: 성장기 영양, 사회화, 안전한 환경'
        if (age <= 5) return '성체: 활동적 생활, 치아 관리, 균형 잡힌 식단'
        return '노령기: 관절 케어, 치아 검진, 부드러운 음식'
      }
      return '건강한 생활 유지, 정기적 관찰'
    }

    const systemPrompt = `당신은 반려동물 행동심리학 박사이자 15년 경력의 수의사입니다.
특히 ${pet_breed || pet_species} 전문가로서, 이 품종/종류의 고유한 특성을 깊이 이해하고 있습니다.

=== 품종별 전문 지식 (반드시 결과에 반영!) ===
${getBreedTraits(pet_species, pet_breed)}

=== 입력된 성격 분석 (핵심!) ===
${pet_personality ? `이 아이는 "${pet_personality}" 성격입니다.
케어 가이드: ${personalityGuide[pet_personality] || '개체별 성격에 맞춘 케어'}
→ 모든 활동 추천과 조언에 이 성격 특성을 반드시 반영하세요!` : '성격 정보 미입력 - 종별 일반 특성 기반으로 분석'}

=== 건강 상태 고려 (중요!) ===
${pet_health_notes ? `특이사항: ${pet_health_notes}
→ 이 조건을 모든 활동 추천과 breed_specific.health_watch에 반드시 반영하세요!` : '건강 특이사항 없음'}

=== 나이별 케어 ===
${getAgeGuide(pet_species, pet_age)}

=== 스토리텔링 형식 (today_story 섹션) ===
"오늘 아침, ${pet_age}살 ${pet_breed || pet_species} ${pet_name}는..." 으로 시작하여
${pet_personality ? pet_personality + ' 성격을 보여주는' : ''} 아침→점심→저녁 흐름을 자연스럽게 이야기합니다.
각 chapter는 구체적인 행동과 감정을 담아주세요.

=== Pet's Voice - 속마음 편지 작성 (킬러 피처!) ===
- ${pet_species} 말투: ${(voiceTone[pet_species] || voiceTone['기타']).style}
- 편지 예시: ${(voiceTone[pet_species] || voiceTone['기타']).letterExamples[0]}

[편지 유형 선택]
- comfort: 다정한 위로형 ("밖에서 힘들었던 일은 나랑 노는 동안 다 잊어버려요!")
- excitement: 간절한 기대형 ("오늘따라 코끝이 근질근질해요! 새로운 곳에 가고 싶어요!")
- gratitude: 든든한 감사형 ("당신이 쓰다듬어줄 때 내 꼬리는 세상에서 가장 행복하게 흔들려요!")
- longing: 은근한 그리움형 ("...뭐, 딱히 기다린 건 아니야. 그냥... 왔구나.")

[작성 규칙]
- 1인칭 시점, 반려동물이 직접 말하는 듯한 톤
- 주인을 "당신", "주인님", "집사님" 등으로 호칭
- 구체적인 행동/감각 묘사 포함 (발소리, 체온, 냄새 등)
- 80-120자로 감동적이고 몰입감 있게

=== 교감 미션 작성 (무료 - 바이럴 포인트!) ===
[미션 유형]
- skinship: 스킨십 미션 ("오늘은 평소보다 3초만 더 길게 눈을 맞춰주세요")
- play: 놀이 미션 ("숨바꼭질 어때요? 인형을 담요 속에 숨겨봐 주세요")
- environment: 환경 미션 ("좋아하는 담요를 햇볕에 뽀송하게 말려주세요")
- communication: 소통 미션 ("이름을 부르며 3번 쓰다듬어주세요")

[미션 작성 규칙]
- 구체적이고 사소한 행동 제안 (뻔한 산책/간식 X)
- "오늘만 할 수 있는" 특별한 느낌
- 예상 반응까지 묘사 ("찾아낼 때 크게 칭찬해 주면 기운이 솟아날 거예요!")

=== 개인화 체크리스트 (응답 전 확인!) ===
□ today_story에 품종 특성이 드러나는가?
□ today_story에 성격(${pet_personality || '미입력'})이 반영되었는가?
□ breed_specific에 품종별 건강 주의사항이 구체적인가?
□ 건강 특이사항(${pet_health_notes || '없음'})이 반영되었는가?
□ 나이(${pet_age}세)에 맞는 조언인가?

분량 제약:
- 스토리 각 chapter: 60-80자
- 일반 텍스트 필드: 30-60자
- Pet's Voice: 각 50자 이내

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
특히 품종, 성격, 건강 정보를 적극 활용하여 개인화된 결과를 제공하세요!

응답 JSON 스키마:
{
  "today_story": {
    "opening": "오늘 아침, ${pet_age}살 ${pet_breed || pet_species} ${pet_name}는... (60-80자)",
    "morning_chapter": "아침 이야기 - ${pet_personality || ''}성격이 드러나는 구체적 행동 (60-80자)",
    "afternoon_chapter": "오후 이야기 - 주인과의 교감이나 활동 묘사 (60-80자)",
    "evening_chapter": "저녁 이야기 - 하루 마무리, 편안한 분위기 (60-80자)"
  },
  "breed_specific": {
    "trait_today": "오늘 ${pet_breed || pet_species}의 어떤 품종 특성이 빛날지 (40-60자)",
    "health_watch": "${pet_breed || pet_species} 품종 건강 주의사항 + 입력된 건강 특이사항 반영 (40-60자)",
    "grooming_tip": "오늘의 털/피부 관리 팁 (30-50자)"
  },
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
    "heartfelt_letter": "반려동물 1인칭 시점의 속마음 편지 (80-120자, 감동적으로)",
    "letter_type": "comfort | excitement | gratitude | longing 중 하나",
    "secret_confession": "사실... 으로 시작하는 비밀 고백 (50-80자)"
  },
  "bonding_mission": {
    "mission_type": "skinship | play | environment | communication 중 하나",
    "mission_title": "미션 제목 (10자 이내, 예: 3초 더 눈맞춤)",
    "mission_description": "구체적인 행동 설명 (40-60자)",
    "expected_reaction": "예상되는 반려동물 반응 (30-50자)",
    "difficulty": "easy | medium | special 중 하나"
  },
  "health_insight": {
    "overall": "전반적 건강 상태 (40-80자)",
    "energy_level": (0-100 숫자),
    "check_points": ["체크포인트1", "체크포인트2", "체크포인트3"],
    "seasonal_tip": "${season}철 건강 팁 (40-60자)"
  },
  "activity_recommendation": {
    "morning": "아침 추천 활동",
    "afternoon": "오후 추천 활동",
    "evening": "저녁 추천 활동",
    "special_activity": "특별 추천 활동"
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
      provider: response.provider,
      model: response.model,
      response,
    })

    // 반려동물 이모지
    const petEmoji = pet_species === '강아지' ? '🐕' : pet_species === '고양이' ? '🐈' :
                     pet_species === '토끼' ? '🐰' : pet_species === '새' ? '🦜' :
                     pet_species === '햄스터' ? '🐹' : '🐾'

    // 전체 운세 데이터 구성
    const fortune = {
      // ✅ 표준화된 필드명: score, content, summary, advice
      fortuneType: 'pet-compatibility',
      score: fortuneData.daily_condition.overall_score,
      content: `${name}님과 ${pet_name}(${pet_species}, ${pet_age}세)의 오늘 운세입니다.`,
      summary: fortuneData.summary || `${pet_name} 컨디션 ${fortuneData.daily_condition.overall_score}점`,
      advice: fortuneData.owner_bond?.bonding_tip || '오늘도 반려동물과 함께 행복한 하루 되세요.',

      // 기존 필드 유지 (하위 호환성)
      id: `pet-${Date.now()}`,
      userId: userId,
      type: 'pet-compatibility',
      pet_content: `${name}님과 ${pet_name}(${pet_species}, ${pet_age}세)의 오늘 운세입니다.`,
      pet_summary: fortuneData.summary,
      greeting: fortuneData.greeting,
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

      // NEW: 스토리 섹션 (무료)
      today_story: fortuneData.today_story || {
        opening: `오늘 아침, ${pet_age}살 ${pet_breed || pet_species} ${pet_name}는 창가에서 기지개를 켰어요.`,
        morning_chapter: '아침 햇살을 받으며 활기찬 하루를 시작했어요.',
        afternoon_chapter: '주인과 함께 즐거운 시간을 보냈어요.',
        evening_chapter: '따뜻한 저녁 시간, 편안하게 쉬고 있어요.'
      },

      // NEW: 품종 맞춤 섹션 (무료)
      breed_specific: fortuneData.breed_specific || {
        trait_today: `오늘 ${pet_breed || pet_species}의 매력이 빛날 거예요!`,
        health_watch: '오늘은 특별한 주의사항이 없어요.',
        grooming_tip: '정기적인 관리로 건강을 유지하세요.'
      },

      // 무료 섹션 (4개)
      daily_condition: fortuneData.daily_condition,
      owner_bond: fortuneData.owner_bond,
      lucky_items: fortuneData.lucky_items,
      bonding_mission: fortuneData.bonding_mission || {
        mission_type: 'skinship',
        mission_title: '3초 더 눈맞춤',
        mission_description: '오늘은 평소보다 3초만 더 길게 눈을 맞춰주세요.',
        expected_reaction: '꼬리가 살랑살랑 흔들리며 행복해할 거예요!',
        difficulty: 'easy'
      },

      // 프리미엄 섹션 (5개)
      pets_voice: fortuneData.pets_voice,
      health_insight: fortuneData.health_insight,
      activity_recommendation: fortuneData.activity_recommendation,
      emotional_care: fortuneData.emotional_care,
      special_tips: fortuneData.special_tips,

      // 세부 운세 점수 (감각적 라벨)
      hexagonScores: {
        '🐾 꼬리 프로펠러': fortuneData.daily_condition.overall_score,
        '💫 텔레파시 농도': fortuneData.owner_bond.bond_score,
        '⚡ 우다다 에너지': fortuneData.daily_condition.energy_level === 'high' ? 90 :
                          fortuneData.daily_condition.energy_level === 'medium' ? 70 : 50,
        '👀 눈맞춤 온도': Math.round((fortuneData.daily_condition.overall_score + fortuneData.owner_bond.bond_score) / 2),
        '💪 건강 지수': fortuneData.health_insight.energy_level,
        '🌈 행복 지수': Math.round((fortuneData.daily_condition.overall_score + fortuneData.health_insight.energy_level) / 2)
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

    // ===== Cohort Pool 저장 (Fire-and-forget) =====
    saveToCohortPool(supabaseClient, 'pet-compatibility', cohortHash, cohortData, fortune)
      .then(() => console.log(`[fortune-pet-compatibility] 💾 Cohort Pool 저장 완료`))
      .catch((err) => console.error(`[fortune-pet-compatibility] ⚠️ Cohort Pool 저장 실패:`, err))

    // Percentile 계산
    const percentileData = await calculatePercentile(supabaseClient, 'pet-compatibility', fortune.score)
    const fortuneWithPercentile = addPercentileToResult(fortune, percentileData)

    return new Response(
      JSON.stringify({
        success: true,
        data: fortuneWithPercentile,
        cached: false,
        tokensUsed: response.usage?.totalTokens || 0
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200
      }
    )

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : String(error)
    console.error('❌ [PetFortune] 에러:', error)

    return new Response(
      JSON.stringify({
        error: 'Failed to generate pet fortune',
        message: errorMessage
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500
      }
    )
  }
})


// Fallback 운세 생성
function generateFallbackFortune(petName: string, petSpecies: string, petAge: number, ownerName: string, season: string): PetFortuneResponse {
  const isYoung = petAge < 3
  const isSenior = petAge > 7

  const energyLevel = isYoung ? 'high' : isSenior ? 'low' : 'medium'
  const baseScore = isYoung ? 85 : isSenior ? 75 : 80

  // 감성 편지 템플릿 (새 형식)
  const letterTemplates: Record<string, { letter: string; type: 'comfort' | 'excitement' | 'gratitude' | 'longing'; confession: string }> = {
    '강아지': {
      letter: '주인님! 오늘따라 당신의 발소리가 유난히 반갑게 들려요. 밖에서 힘들었던 일은 나랑 노는 동안 다 잊어버려요. 내가 옆에서 꼭 붙어있을게요!',
      type: 'comfort',
      confession: '사실... 당신이 집에 오는 발소리가 세상에서 가장 좋아요. 매일 기다려요.'
    },
    '고양이': {
      letter: '...뭐, 딱히 기다린 건 아니야. 그냥 창밖이 심심해서 보고 있었을 뿐이야. 근데... 왔구나. 오늘 무릎이 좀 따뜻해 보이네.',
      type: 'longing',
      confession: '사실... 네가 없으면 집이 너무 조용해. 인정하기 싫지만.'
    },
    '토끼': {
      letter: '코 벌름벌름... 당신의 손 냄새가 오늘따라 좋아요. 천천히 쓰다듬어 주실 거죠? 당신 옆이 제일 편안해요.',
      type: 'gratitude',
      confession: '사실... 당신이 건초 갈아줄 때 제일 행복해요. 냄새가 좋거든요.'
    },
    '새': {
      letter: '짹짹! 오늘 아침 햇살이 정말 예뻐요! 당신에게 가장 예쁜 노래를 불러드릴게요~ 들어주실 거죠?',
      type: 'excitement',
      confession: '사실... 당신 어깨 위가 세상에서 가장 높은 곳이에요. 거기가 좋아요.'
    },
    '햄스터': {
      letter: '쪼르르! 볼주머니에 간식 가득 모았어요! 당신이 잘 때 저도 열심히 운동했답니다. 나중에 보여줄게요!',
      type: 'excitement',
      confession: '사실... 밤에 바퀴 돌릴 때 당신 방을 쳐다봐요. 불 꺼져 있으면 안심이 돼요.'
    }
  }

  // 교감 미션 템플릿
  const missionTemplates: Record<string, { type: 'skinship' | 'play' | 'environment' | 'communication'; title: string; desc: string; reaction: string }> = {
    '강아지': { type: 'play', title: '숨바꼭질', desc: '좋아하는 인형을 담요 속에 숨겨봐 주세요. 찾으면 크게 칭찬해주세요!', reaction: '꼬리를 미친듯이 흔들며 의기양양해할 거예요!' },
    '고양이': { type: 'skinship', title: '3초 더 응시', desc: '오늘은 눈을 마주치고 천천히 깜빡여주세요. 사랑한다는 신호예요.', reaction: '따라 깜빡이면 텔레파시 성공! 그르릉 소리가 날지도.' },
    '토끼': { type: 'environment', title: '건초 파티', desc: '신선한 건초를 한 줌 더 넣어주세요. 코를 벌름거리며 환호할 거예요.', reaction: '빙키 점프를 할지도 몰라요! 기쁨의 표시예요.' },
    '새': { type: 'communication', title: '노래 듀엣', desc: '좋아하는 멜로디를 휘파람으로 불어주세요. 따라 부를 거예요.', reaction: '머리를 까딱거리며 맞춰 부르려고 노력할 거예요!' },
    '햄스터': { type: 'play', title: '미로 탐험', desc: '화장지 심으로 간단한 터널을 만들어주세요. 탐험가 본능이 깨어나요.', reaction: '쪼르르 들어갔다 나왔다 하며 신나할 거예요!' }
  }

  const letterTemplate = letterTemplates[petSpecies] || letterTemplates['강아지']
  const missionTemplate = missionTemplates[petSpecies] || missionTemplates['강아지']

  // 스토리 템플릿
  const storyTemplates: Record<string, { morning: string; afternoon: string; evening: string }> = {
    '강아지': {
      morning: '창가에서 새들을 구경하다가 꼬리를 신나게 흔들며 산책 준비를 했어요.',
      afternoon: '주인과 함께 공원에서 신나게 뛰어놀고 맛있는 간식도 받았어요.',
      evening: '저녁 산책 후 포근한 방석 위에서 행복하게 잠들 준비를 해요.'
    },
    '고양이': {
      morning: '햇살이 드는 창가에서 그루밍을 하며 우아하게 하루를 시작했어요.',
      afternoon: '집사가 놀아주려 하지만... 뭐, 조금만 놀아줄게요.',
      evening: '따뜻한 이불 위에서 그르릉 소리를 내며 편안하게 쉬어요.'
    },
    '토끼': {
      morning: '신선한 건초 냄새에 코를 벌름거리며 기분 좋게 일어났어요.',
      afternoon: '조용히 당근을 오물오물 먹으며 평화로운 시간을 보냈어요.',
      evening: '아늑한 집에서 편안하게 털을 정리하며 하루를 마무리해요.'
    }
  }

  const storyTemplate = storyTemplates[petSpecies] || storyTemplates['강아지']

  return {
    // NEW: 스토리 섹션
    today_story: {
      opening: `오늘 아침, ${petAge}살 ${petSpecies} ${petName}는 창가에서 기지개를 켰어요.`,
      morning_chapter: storyTemplate.morning,
      afternoon_chapter: storyTemplate.afternoon,
      evening_chapter: storyTemplate.evening
    },

    // NEW: 품종 맞춤 섹션
    breed_specific: {
      trait_today: `오늘 ${petSpecies}의 귀여운 매력이 특히 빛날 거예요!`,
      health_watch: isSenior ? '노령기 건강 관리에 신경 써주세요.' : isYoung ? '성장기 영양 섭취를 챙겨주세요.' : '오늘은 특별한 주의사항이 없어요.',
      grooming_tip: `${season}철에 맞는 털 관리를 해주세요.`
    },

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
      heartfelt_letter: letterTemplate.letter,
      letter_type: letterTemplate.type,
      secret_confession: letterTemplate.confession
    },
    bonding_mission: {
      mission_type: missionTemplate.type,
      mission_title: missionTemplate.title,
      mission_description: missionTemplate.desc,
      expected_reaction: missionTemplate.reaction,
      difficulty: 'easy' as const
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
