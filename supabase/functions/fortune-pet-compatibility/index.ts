import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { calculatePercentile, addPercentileToResult } from '../_shared/percentile/calculator.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
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
      name,
      pet_name,
      pet_species,
      pet_age,
      birthDate,
      birthTime,
      gender,
      mbtiType,
      bloodType,
      zodiacSign,
      zodiacAnimal,
      isPremium = false // ✅ 프리미엄 사용자 여부
    } = requestData

    console.log('💎 [PetCompatibility] Premium 상태:', isPremium)

    // 반려동물 궁합 점수 계산 (강화된 버전)
    const calculateCompatibilityScore = (petSpecies: string, petAge: number, userMbti: string, userZodiac: string) => {
      let baseScore = 70

      // 동물별 기본 점수
      const speciesScores = {
        '강아지': 85,
        '고양이': 80,
        '토끼': 75,
        '새': 70,
        '햄스터': 65,
        '기타': 60
      }
      baseScore = speciesScores[petSpecies] || speciesScores['기타']

      // 나이에 따른 조정
      if (petAge >= 1 && petAge <= 3) {
        baseScore += 8 // 어린 반려동물은 활발함
      } else if (petAge >= 4 && petAge <= 10) {
        baseScore += 10 // 성숙한 반려동물은 안정적
      } else {
        baseScore += 5 // 고령 반려동물은 차분함
      }

      // MBTI에 따른 조정
      if (userMbti) {
        if (userMbti.includes('E')) {
          if (petSpecies === '강아지') baseScore += 8
        } else {
          if (petSpecies === '고양이') baseScore += 8
        }
        
        if (userMbti.includes('F')) {
          baseScore += 5 // 감정형은 반려동물과 유대감 높음
        }
      }

      // 띠에 따른 조정
      const compatibleZodiacs = {
        '강아지': ['개', '토끼', '말'],
        '고양이': ['호랑이', '토끼', '용'],
        '토끼': ['개', '돼지', '양'],
        '새': ['닭', '원숭이', '뱀'],
        '햄스터': ['쥐', '소', '돼지'],
      }

      if (userZodiac && compatibleZodiacs[petSpecies]?.includes(userZodiac)) {
        baseScore += 10
      }

      return Math.min(100, Math.max(0, baseScore))
    }

    // 오늘의 건강 운세 생성
    const generateHealthFortune = (petSpecies: string, petAge: number) => {
      const healthScores = {
        energy: Math.floor(Math.random() * 30) + 70,
        appetite: Math.floor(Math.random() * 30) + 70,
        mood: Math.floor(Math.random() * 30) + 70,
        activity: Math.floor(Math.random() * 30) + 70
      }

      const healthTips = {
        '강아지': [
          '산책 시 발바닥 상태를 확인해주세요',
          '충분한 수분 섭취가 중요한 날입니다',
          '관절 건강에 신경 써주세요',
          '치아 관리에 특별히 주의하세요'
        ],
        '고양이': [
          '털뭉치 배출에 신경 써주세요',
          '화장실 청결 상태를 점검해주세요',
          '스트레스 신호를 잘 관찰하세요',
          '발톱 상태를 확인해주세요'
        ],
        '토끼': [
          '건초 섭취량을 확인해주세요',
          '이빨 길이를 체크해주세요',
          '온도 변화에 주의하세요',
          '운동량이 충분한지 확인하세요'
        ],
        '새': [
          '깃털 상태를 관찰해주세요',
          '충분한 일광욕이 필요합니다',
          '발톱과 부리 상태를 확인하세요',
          '적절한 습도를 유지해주세요'
        ],
        '햄스터': [
          '체중 변화를 관찰해주세요',
          '이빨 길이를 확인하세요',
          '피부 상태를 점검해주세요',
          '충분한 운동을 시켜주세요'
        ]
      }

      const tips = healthTips[petSpecies] || healthTips['강아지']
      const todaysTip = tips[Math.floor(Math.random() * tips.length)]

      return {
        scores: healthScores,
        mainAdvice: todaysTip,
        checkPoints: [
          petAge > 7 ? '노령기 건강 검진을 고려하세요' : '정기 건강 검진을 잊지 마세요',
          '식욕과 배변 상태를 체크하세요',
          '평소와 다른 행동이 있는지 관찰하세요'
        ]
      }
    }

    // 오늘의 활동 운세 생성
    const generateActivityFortune = (petSpecies: string) => {
      const activities = {
        '강아지': {
          morning: ['짧은 산책으로 하루를 시작하세요', '아침 햇빛을 쬐며 스트레칭하세요'],
          afternoon: ['공놀이로 에너지를 발산시켜주세요', '새로운 산책 코스를 탐험해보세요'],
          evening: ['차분한 마사지로 하루를 마무리하세요', '조용한 시간을 함께 보내세요'],
          special: '오늘은 새로운 간식이나 장난감을 선물하기 좋은 날입니다'
        },
        '고양이': {
          morning: ['창가에서 햇빛욕을 즐기게 해주세요', '털 빗질로 하루를 시작하세요'],
          afternoon: ['사냥놀이로 본능을 충족시켜주세요', '캣닢 장난감으로 즐거운 시간을'],
          evening: ['조용한 음악과 함께 휴식을', '부드러운 쓰다듬기로 교감하세요'],
          special: '오늘은 새로운 스크래처나 캣타워 위치를 바꿔보세요'
        },
        '토끼': {
          morning: ['신선한 채소로 아침을 시작하세요', '케이지 밖에서 자유시간을'],
          afternoon: ['터널 놀이로 호기심을 충족시켜주세요', '부드러운 브러싱을 해주세요'],
          evening: ['조용한 환경에서 휴식을', '건초를 충분히 준비해주세요'],
          special: '오늘은 새로운 채소를 소량 시도해보기 좋은 날입니다'
        },
        '새': {
          morning: ['새장 밖에서 날개 운동을', '신선한 과일을 준비해주세요'],
          afternoon: ['음악이나 소리 놀이를 즐겨보세요', '장난감을 교체해주세요'],
          evening: ['조용한 환경을 만들어주세요', '충분한 수면 시간을 보장하세요'],
          special: '오늘은 새로운 지저귐을 가르치기 좋은 날입니다'
        },
        '햄스터': {
          morning: ['신선한 물과 먹이를 준비하세요', '베딩 상태를 확인하세요'],
          afternoon: ['낮잠을 방해하지 마세요', '저녁 활동을 위한 준비를'],
          evening: ['운동 바퀴에서 충분한 운동을', '미로 놀이로 두뇌 자극을'],
          special: '오늘은 새로운 은신처를 만들어주기 좋은 날입니다'
        }
      }

      const petActivities = activities[petSpecies] || activities['강아지']
      const timeOfDay = new Date().getHours()
      let recommendedActivity = ''

      if (timeOfDay < 12) {
        recommendedActivity = petActivities.morning[Math.floor(Math.random() * petActivities.morning.length)]
      } else if (timeOfDay < 18) {
        recommendedActivity = petActivities.afternoon[Math.floor(Math.random() * petActivities.afternoon.length)]
      } else {
        recommendedActivity = petActivities.evening[Math.floor(Math.random() * petActivities.evening.length)]
      }

      return {
        recommended: recommendedActivity,
        special: petActivities.special,
        bestTime: timeOfDay < 12 ? '오전' : timeOfDay < 18 ? '오후' : '저녁',
        energy: Math.floor(Math.random() * 30) + 70
      }
    }

    // 감정 상태 분석
    const generateEmotionalState = (petSpecies: string) => {
      const emotions = {
        '강아지': ['애정 넘치는', '충성스러운', '활발한', '호기심 많은', '보호적인'],
        '고양이': ['독립적인', '우아한', '신비로운', '까다로운', '애교있는'],
        '토끼': ['온순한', '예민한', '조용한', '호기심있는', '평화로운'],
        '새': ['명랑한', '똑똑한', '사교적인', '활발한', '민감한'],
        '햄스터': ['부지런한', '귀여운', '호기심많은', '활동적인', '조심스러운']
      }

      const petEmotions = emotions[petSpecies] || emotions['강아지']
      const todaysEmotion = petEmotions[Math.floor(Math.random() * petEmotions.length)]
      const moodScore = Math.floor(Math.random() * 30) + 70

      return {
        primary: todaysEmotion,
        score: moodScore,
        advice: moodScore > 85 
          ? '오늘은 특별히 기분이 좋은 날이니 함께 특별한 시간을 보내세요'
          : moodScore > 70
          ? '평온한 하루를 보내고 있으니 일상적인 루틴을 유지하세요'
          : '조금 예민할 수 있으니 편안한 환경을 만들어주세요'
      }
    }

    // 특별 이벤트 적합도
    const generateSpecialEvents = () => {
      const events = {
        grooming: {
          score: Math.floor(Math.random() * 30) + 70,
          advice: '털 관리나 목욕을 하기에 적당한 날입니다'
        },
        vetVisit: {
          score: Math.floor(Math.random() * 30) + 70,
          advice: '병원 방문이 필요하다면 오늘이 좋습니다'
        },
        training: {
          score: Math.floor(Math.random() * 30) + 70,
          advice: '새로운 것을 가르치기 좋은 날입니다'
        },
        socializing: {
          score: Math.floor(Math.random() * 30) + 70,
          advice: '다른 동물이나 사람과 만나기 좋은 날입니다'
        }
      }

      return events
    }

    // 반려동물 종류별 특성 생성
    const generatePetCharacteristics = (species: string) => {
      const characteristics = {
        '강아지': {
          personality: ['충성스러운', '활발한', '사교적인', '보호본능이 강한'],
          traits: '주인에 대한 무한한 사랑과 충성심으로 가득한 마음을 가지고 있습니다.',
          compatibility_tips: '함께 산책하고 놀아주는 시간을 늘리면 더욱 깊은 유대감을 형성할 수 있습니다.'
        },
        '고양이': {
          personality: ['독립적인', '우아한', '신비로운', '직감적인'],
          traits: '자유롭고 독립적인 성격으로 자신만의 공간과 시간을 소중히 여깁니다.',
          compatibility_tips: '고양이의 독립적인 성격을 존중하면서도 꾸준한 관심과 애정을 보여주세요.'
        },
        '토끼': {
          personality: ['온순한', '조용한', '깔끔한', '예민한'],
          traits: '평화로운 환경을 좋아하며 조용하고 안정적인 생활을 선호합니다.',
          compatibility_tips: '조용하고 평화로운 환경을 만들어주면 더욱 편안해합니다.'
        },
        '새': {
          personality: ['똑똑한', '호기심 많은', '사회적인', '활발한'],
          traits: '높은 지능과 호기심으로 새로운 것에 대한 학습능력이 뛰어납니다.',
          compatibility_tips: '다양한 장난감과 자극을 제공하여 지적 호기심을 채워주세요.'
        },
        '햄스터': {
          personality: ['작고 귀여운', '활동적인', '저장을 좋아하는', '야행성인'],
          traits: '작지만 활발하며 자신만의 공간을 꾸미는 것을 좋아합니다.',
          compatibility_tips: '밤에 활발해지는 특성을 고려하여 생활패턴을 맞춰주세요.'
        }
      }
      return characteristics[species] || characteristics['강아지']
    }

    // 궁합 점수에 따른 메시지 생성
    const generateCompatibilityMessage = (score: number, petName: string, petSpecies: string) => {
      let level = ''
      let message = ''
      let advice = ''

      if (score >= 90) {
        level = '최고의 궁합'
        message = `${petName}와 당신은 천생연분입니다! 서로를 완벽하게 이해하고 보완하는 관계입니다.`
        advice = '이미 완벽한 조화를 이루고 있으니, 현재의 사랑을 더욱 깊게 나누세요.'
      } else if (score >= 80) {
        level = '아주 좋은 궁합'
        message = `${petName}와 당신은 서로에게 큰 행복과 위안을 주는 관계입니다.`
        advice = '서로의 특성을 더 깊이 이해하고 존중한다면 더욱 완벽한 관계가 될 것입니다.'
      } else if (score >= 70) {
        level = '좋은 궁합'
        message = `${petName}와 당신은 서로에게 좋은 영향을 미치는 관계입니다.`
        advice = '꾸준한 관심과 사랑으로 더욱 깊은 유대감을 만들어가세요.'
      } else if (score >= 60) {
        level = '보통 궁합'
        message = `${petName}와 당신은 서로 다른 매력을 가진 관계입니다.`
        advice = '차이점을 인정하고 서로를 이해하려 노력한다면 더 좋은 관계로 발전할 수 있습니다.'
      } else {
        level = '노력이 필요한 궁합'
        message = `${petName}와 당신은 서로 다른 특성을 가지고 있어 특별한 관심이 필요합니다.`
        advice = '인내심을 갖고 꾸준히 소통하며 서로를 이해해나간다면 의미 있는 관계를 만들 수 있습니다.'
      }

      return { level, message, advice }
    }

    const compatibilityScore = calculateCompatibilityScore(pet_species, pet_age, mbtiType, zodiacAnimal)
    const petCharacteristics = generatePetCharacteristics(pet_species)
    const compatibilityResult = generateCompatibilityMessage(compatibilityScore, pet_name, pet_species)
    const healthFortune = generateHealthFortune(pet_species, pet_age)
    const activityFortune = generateActivityFortune(pet_species)
    const emotionalState = generateEmotionalState(pet_species)
    const specialEvents = generateSpecialEvents()

    // 행운 아이템 생성 (강화된 버전)
    const generateLuckyItems = (species: string) => {
      const items = {
        '강아지': {
          color: '골드',
          item: '산책용 목줄',
          activity: '함께 달리기',
          food: '닭고기 간식',
          toy: '터그 로프',
          spot: '공원 산책로',
          time: '오전 7시'
        },
        '고양이': {
          color: '실버',
          item: '고양이 타워',
          activity: '햇빛 쬐기',
          food: '참치 간식',
          toy: '깃털 장난감',
          spot: '창가 쿠션',
          time: '오후 2시'
        },
        '토끼': {
          color: '연두색',
          item: '부드러운 침대',
          activity: '조용한 놀이',
          food: '당근과 건초',
          toy: '터널',
          spot: '조용한 방',
          time: '오전 10시'
        },
        '새': {
          color: '하늘색',
          item: '다양한 장난감',
          activity: '노래 들려주기',
          food: '씨앗 믹스',
          toy: '거울',
          spot: '밝은 창가',
          time: '아침 8시'
        },
        '햄스터': {
          color: '베이지',
          item: '운동 바퀴',
          activity: '터널 놀이',
          food: '견과류 간식',
          toy: '나무 블록',
          spot: '조용한 구석',
          time: '저녁 8시'
        }
      }
      return items[species] || items['강아지']
    }

    const luckyItems = generateLuckyItems(pet_species)

    // 오늘의 케어 포인트 생성
    const generateCarePoints = (species: string, age: number) => {
      const points = []
      
      // 나이별 케어 포인트
      if (age < 1) {
        points.push('어린 시기이므로 사회화 교육이 중요합니다')
        points.push('면역력 강화를 위한 영양 관리가 필요합니다')
      } else if (age < 7) {
        points.push('활발한 시기이므로 충분한 운동이 필요합니다')
        points.push('정기적인 건강 검진을 잊지 마세요')
      } else {
        points.push('노령기 관절 건강에 특별히 신경 써주세요')
        points.push('소화가 잘되는 음식으로 식단을 조절하세요')
      }

      // 종별 특별 케어
      const speciesCare = {
        '강아지': '발톱과 치아 관리를 정기적으로 해주세요',
        '고양이': '화장실 모래는 항상 깨끗하게 유지하세요',
        '토끼': '이빨이 과도하게 자라지 않도록 관리하세요',
        '새': '깃털 상태와 발톱 길이를 확인하세요',
        '햄스터': '체온 유지를 위한 적절한 베딩을 제공하세요'
      }

      points.push(speciesCare[species] || speciesCare['강아지'])
      
      return points
    }

    const carePoints = generateCarePoints(pet_species, pet_age)

    // ✅ Blur 로직 적용
    const isBlurred = !isPremium
    const blurredSections = isBlurred
      ? ['health_fortune', 'activity_fortune', 'emotional_state', 'special_events', 'care_points', 'recommendations', 'warnings', 'special_tip']
      : []

    // 운세 데이터 구성 (강화된 버전)
    const fortune = {
      id: `pet-${Date.now()}`,
      userId: userId,
      type: 'pet-compatibility',
      content: `${name}님과 ${pet_name}(${pet_species}, ${pet_age}세)의 오늘 운세를 종합적으로 분석했습니다.`,
      summary: `${compatibilityResult.level} (${compatibilityScore}점)`,
      greeting: `${name}님과 사랑스러운 ${pet_name}의 특별한 하루를 예측해드립니다.`,
      score: compatibilityScore,
      overallScore: compatibilityScore,
      
      // 반려동물 궁합 전용 필드
      pet_info: {
        name: pet_name,
        species: pet_species,
        age: pet_age,
        characteristics: petCharacteristics,
        emoji: pet_species === '강아지' ? '🐕' : pet_species === '고양이' ? '🐈' : 
               pet_species === '토끼' ? '🐰' : pet_species === '새' ? '🦜' : 
               pet_species === '햄스터' ? '🐹' : '🐾'
      },
      
      // 궁합 결과 (✅ 무료: 공개)
      compatibility_result: {
        score: compatibilityScore,
        level: compatibilityResult.level,
        message: compatibilityResult.message,
        detailed_analysis: `${pet_name}는 ${petCharacteristics.traits} ${compatibilityResult.message}`,
        advice: compatibilityResult.advice
      },

      // 건강 운세 (🔒 유료)
      health_fortune: isBlurred ? {
        scores: { energy: 0, appetite: 0, mood: 0, activity: 0 },
        mainAdvice: '🔒 프리미엄 결제 후 확인 가능합니다',
        checkPoints: ['🔒 프리미엄 결제 후 확인 가능합니다'],
        energy: 0,
        appetite: 0,
        mood: 0,
        activity: 0
      } : {
        scores: healthFortune.scores,
        mainAdvice: healthFortune.mainAdvice,
        checkPoints: healthFortune.checkPoints,
        energy: healthFortune.scores.energy,
        appetite: healthFortune.scores.appetite,
        mood: healthFortune.scores.mood,
        activity: healthFortune.scores.activity
      },

      // 활동 운세 (🔒 유료)
      activity_fortune: isBlurred ? {
        recommended: '🔒 프리미엄 결제 후 확인 가능합니다',
        special: '🔒 프리미엄 결제 후 확인 가능합니다',
        bestTime: '🔒',
        energy: 0
      } : {
        recommended: activityFortune.recommended,
        special: activityFortune.special,
        bestTime: activityFortune.bestTime,
        energy: activityFortune.energy
      },

      // 감정 상태 (🔒 유료)
      emotional_state: isBlurred ? {
        primary: '🔒',
        score: 0,
        advice: '🔒 프리미엄 결제 후 확인 가능합니다'
      } : {
        primary: emotionalState.primary,
        score: emotionalState.score,
        advice: emotionalState.advice
      },

      // 특별 이벤트 적합도 (🔒 유료)
      special_events: isBlurred ? {
        grooming: { score: 0, advice: '🔒 프리미엄 결제 후 확인 가능합니다' },
        vetVisit: { score: 0, advice: '🔒 프리미엄 결제 후 확인 가능합니다' },
        training: { score: 0, advice: '🔒 프리미엄 결제 후 확인 가능합니다' },
        socializing: { score: 0, advice: '🔒 프리미엄 결제 후 확인 가능합니다' }
      } : specialEvents,

      // 오늘의 케어 포인트 (🔒 유료)
      care_points: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : carePoints,

      // 행운 아이템 (✅ 무료: 공개)
      lucky_items: {
        color: luckyItems.color,
        item: luckyItems.item,
        activity: luckyItems.activity,
        food: luckyItems.food,
        toy: luckyItems.toy,
        spot: luckyItems.spot,
        time: luckyItems.time
      },

      // 추천사항과 주의사항 (🔒 유료)
      recommendations: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : [
        activityFortune.recommended,
        healthFortune.mainAdvice,
        emotionalState.advice
      ],

      warnings: isBlurred ? ['🔒 프리미엄 결제 후 확인 가능합니다'] : [
        `${pet_name}의 ${petCharacteristics.personality.join(', ')} 성격을 고려하여 접근해주세요`,
        ...healthFortune.checkPoints.slice(0, 2)
      ],

      special_tip: isBlurred ? '🔒 프리미엄 결제 후 확인 가능합니다' : petCharacteristics.compatibility_tips,
      
      // 카테고리별 점수 (UI용)
      categories: {
        harmony: {
          score: compatibilityScore,
          advice: compatibilityResult.advice
        },
        health: {
          score: healthFortune.scores.energy,
          advice: healthFortune.mainAdvice
        },
        activity: {
          score: activityFortune.energy,
          advice: activityFortune.recommended
        },
        emotion: {
          score: emotionalState.score,
          advice: emotionalState.advice
        }
      },
      
      // 육각형 차트용 점수
      hexagonScores: {
        '애정': compatibilityScore,
        '건강': healthFortune.scores.energy,
        '활동': activityFortune.energy,
        '감정': emotionalState.score,
        '교감': Math.max(60, compatibilityScore - 10),
        '성장': Math.max(60, compatibilityScore - 12)
      },

      createdAt: new Date().toISOString(),
      isBlurred, // ✅ 블러 상태
      blurredSections // ✅ 블러된 섹션 목록
    }

    // ✅ Percentile 계산 추가
    const percentileData = await calculatePercentile(supabaseClient, 'pet-compatibility', compatibilityScore)
    const fortuneWithPercentile = addPercentileToResult(fortune, percentileData)

    // Edge Function 응답 형식에 맞춰 반환
    return new Response(
      JSON.stringify({
        fortune: fortuneWithPercentile,
        tokensUsed: 0
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Error generating pet compatibility fortune:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Failed to generate pet compatibility fortune',
        message: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500 
      }
    )
  }
})