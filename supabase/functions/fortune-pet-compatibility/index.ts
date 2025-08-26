import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

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
      zodiacAnimal
    } = requestData

    // 반려동물 궁합 점수 계산
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

    // 행운 아이템 생성
    const generateLuckyItems = (species: string) => {
      const items = {
        '강아지': {
          color: '골드',
          item: '산책용 목줄',
          activity: '함께 달리기',
          food: '닭고기 간식'
        },
        '고양이': {
          color: '실버',
          item: '고양이 타워',
          activity: '햇빛 쬐기',
          food: '참치 간식'
        },
        '토끼': {
          color: '연두색',
          item: '부드러운 침대',
          activity: '조용한 놀이',
          food: '당근과 건초'
        },
        '새': {
          color: '하늘색',
          item: '다양한 장난감',
          activity: '노래 들려주기',
          food: '씨앗 믹스'
        },
        '햄스터': {
          color: '베이지',
          item: '운동 바퀴',
          activity: '터널 놀이',
          food: '견과류 간식'
        }
      }
      return items[species] || items['강아지']
    }

    const luckyItems = generateLuckyItems(pet_species)
    
    // 운세 데이터 구성
    const fortune = {
      id: `pet-${Date.now()}`,
      userId: userId,
      type: 'pet-compatibility',
      content: `${name}님과 ${pet_name}(${pet_species}, ${pet_age}세)의 궁합을 분석했습니다.`,
      summary: `${compatibilityResult.level} (${compatibilityScore}점)`,
      greeting: `${name}님과 사랑스러운 ${pet_name}의 특별한 인연을 살펴보겠습니다.`,
      score: compatibilityScore,
      overallScore: compatibilityScore,
      
      // 반려동물 궁합 전용 필드
      pet_info: {
        name: pet_name,
        species: pet_species,
        age: pet_age,
        characteristics: petCharacteristics
      },
      
      compatibility_result: {
        score: compatibilityScore,
        level: compatibilityResult.level,
        message: compatibilityResult.message,
        detailed_analysis: `${pet_name}는 ${petCharacteristics.traits} ${compatibilityResult.message}`
      },
      
      advice: compatibilityResult.advice,
      caution: `${pet_name}의 ${petCharacteristics.personality.join(', ')} 성격을 고려하여 접근해주세요.`,
      
      lucky_items: {
        color: luckyItems.color,
        item: luckyItems.item,
        activity: luckyItems.activity,
        food: luckyItems.food
      },
      
      special_tip: petCharacteristics.compatibility_tips,
      
      // 호환성을 위한 기본 운세 필드
      categories: {
        harmony: {
          score: compatibilityScore,
          advice: compatibilityResult.advice
        },
        communication: {
          score: Math.max(60, compatibilityScore - 10),
          advice: '꾸준한 관심과 애정 표현이 중요합니다.'
        },
        care: {
          score: Math.max(70, compatibilityScore - 5),
          advice: `${pet_species}의 특성에 맞는 돌봄이 필요합니다.`
        },
        total: {
          score: compatibilityScore,
          advice: compatibilityResult.advice
        }
      },
      
      hexagonScores: {
        '애정': compatibilityScore,
        '소통': Math.max(60, compatibilityScore - 10),
        '돌봄': Math.max(70, compatibilityScore - 5),
        '이해': Math.max(65, compatibilityScore - 8),
        '즐거움': Math.max(75, compatibilityScore - 3),
        '성장': Math.max(60, compatibilityScore - 12)
      },
      
      createdAt: new Date().toISOString()
    }

    // Edge Function 응답 형식에 맞춰 반환
    return new Response(
      JSON.stringify({ 
        fortune,
        tokensUsed: 0
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})