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
      birthDate,
      family_type,
      family_members,
      relationship,
      child_name,
      child_age,
      child_gender,
      spouse_name,
      parent_type,
      sibling_count
    } = requestData

    // 가족 유형별 운세 생성
    const generateFamilyFortune = (type: string) => {
      const fortunes = {
        'parent-child': {
          title: '부모-자녀 관계 운세',
          focus: '자녀와의 소통과 성장',
          keywords: ['소통', '교육', '성장', '이해', '사랑']
        },
        'couple': {
          title: '부부 관계 운세',
          focus: '배우자와의 조화와 사랑',
          keywords: ['사랑', '이해', '소통', '화합', '행복']
        },
        'siblings': {
          title: '형제자매 관계 운세',
          focus: '형제간 우애와 화합',
          keywords: ['우애', '협력', '이해', '지지', '성장']
        },
        'extended': {
          title: '대가족 관계 운세',
          focus: '세대간 소통과 화합',
          keywords: ['존중', '전통', '소통', '화합', '지혜']
        },
        'single-parent': {
          title: '한부모 가정 운세',
          focus: '특별한 유대와 성장',
          keywords: ['강인함', '사랑', '지지', '성장', '희망']
        }
      }
      
      return fortunes[type] || fortunes['parent-child']
    }

    // 가족 화합도 계산
    const calculateHarmonyScore = () => {
      const baseScore = 70
      const randomBonus = Math.floor(Math.random() * 20)
      const dayBonus = new Date().getDay() === 0 || new Date().getDay() === 6 ? 10 : 0 // 주말 보너스
      
      return Math.min(100, baseScore + randomBonus + dayBonus)
    }

    // 구성원별 개별 운세
    const generateMemberFortunes = (members: any[]) => {
      const fortunes = {}
      const roles = ['아버지', '어머니', '자녀', '조부모']
      const moods = ['활기찬', '평온한', '도전적인', '성장하는', '행복한']
      
      members?.forEach((member, index) => {
        const mood = moods[Math.floor(Math.random() * moods.length)]
        fortunes[member.name || roles[index]] = {
          mood: mood,
          energy: Math.floor(Math.random() * 30) + 70,
          advice: `오늘은 ${mood} 에너지가 가득한 날입니다. 가족과 함께 시간을 보내세요.`,
          luckyTime: `${Math.floor(Math.random() * 12) + 1}시`
        }
      })
      
      return fortunes
    }

    // 오늘의 가족 활동 추천
    const generateFamilyActivities = (type: string) => {
      const activities = {
        'parent-child': [
          { 
            activity: '함께 요리하기',
            description: '아이와 함께 간단한 요리를 만들며 추억을 쌓아보세요',
            difficulty: '쉬움',
            duration: '1시간',
            benefit: '협동심과 창의력 향상'
          },
          {
            activity: '독서 시간 갖기',
            description: '잠자리에서 함께 책을 읽으며 상상력을 키워주세요',
            difficulty: '쉬움',
            duration: '30분',
            benefit: '정서적 안정과 어휘력 향상'
          },
          {
            activity: '산책하며 대화하기',
            description: '가벼운 산책을 하며 아이의 하루를 들어주세요',
            difficulty: '쉬움',
            duration: '30분',
            benefit: '신체 건강과 소통 증진'
          }
        ],
        'couple': [
          {
            activity: '데이트 타임',
            description: '둘만의 특별한 시간을 가져보세요',
            difficulty: '쉬움',
            duration: '2시간',
            benefit: '로맨스 회복과 친밀감 증진'
          },
          {
            activity: '함께 운동하기',
            description: '부부가 함께 운동하며 건강을 챙기세요',
            difficulty: '보통',
            duration: '1시간',
            benefit: '건강 증진과 동기부여'
          },
          {
            activity: '미래 계획 세우기',
            description: '함께 앞으로의 계획을 이야기해보세요',
            difficulty: '쉬움',
            duration: '1시간',
            benefit: '목표 공유와 유대감 강화'
          }
        ],
        'siblings': [
          {
            activity: '게임 대결',
            description: '보드게임이나 비디오게임으로 건전한 경쟁을',
            difficulty: '쉬움',
            duration: '1시간',
            benefit: '스트레스 해소와 유대감 형성'
          },
          {
            activity: '추억 공유하기',
            description: '어린 시절 사진을 보며 추억을 나누세요',
            difficulty: '쉬움',
            duration: '30분',
            benefit: '정서적 유대감 강화'
          },
          {
            activity: '함께 프로젝트 하기',
            description: '공동의 목표를 위해 협력해보세요',
            difficulty: '보통',
            duration: '2시간',
            benefit: '협력과 성취감'
          }
        ],
        'extended': [
          {
            activity: '가족 식사',
            description: '온 가족이 모여 식사를 함께 하세요',
            difficulty: '쉬움',
            duration: '1시간',
            benefit: '세대간 소통과 화합'
          },
          {
            activity: '가족 역사 듣기',
            description: '어르신들의 이야기를 들어보세요',
            difficulty: '쉬움',
            duration: '1시간',
            benefit: '가족 정체성과 지혜 전수'
          },
          {
            activity: '전통 놀이',
            description: '전통 놀이를 함께 즐겨보세요',
            difficulty: '쉬움',
            duration: '1시간',
            benefit: '문화 전승과 즐거움'
          }
        ],
        'single-parent': [
          {
            activity: '특별한 시간',
            description: '아이와 단둘이 특별한 시간을 보내세요',
            difficulty: '쉬움',
            duration: '1시간',
            benefit: '깊은 유대감과 안정감'
          },
          {
            activity: '감사 일기 쓰기',
            description: '하루의 감사한 일을 함께 적어보세요',
            difficulty: '쉬움',
            duration: '15분',
            benefit: '긍정적 사고와 감사함'
          },
          {
            activity: '목표 설정하기',
            description: '함께 이루고 싶은 목표를 정해보세요',
            difficulty: '쉬움',
            duration: '30분',
            benefit: '동기부여와 희망'
          }
        ]
      }
      
      const typeActivities = activities[type] || activities['parent-child']
      return typeActivities[Math.floor(Math.random() * typeActivities.length)]
    }

    // 관계 개선 조언
    const generateRelationshipAdvice = (type: string) => {
      const advices = {
        'parent-child': [
          '아이의 눈높이에서 대화를 시작해보세요',
          '실수를 인정하고 사과하는 모습을 보여주세요',
          '아이의 감정을 먼저 인정해주세요',
          '하루 10분이라도 온전히 아이에게 집중하세요',
          '긍정적인 말로 하루를 시작하고 마무리하세요'
        ],
        'couple': [
          '작은 감사 표현을 잊지 마세요',
          '서로의 개인 시간을 존중해주세요',
          '대화할 때 휴대폰을 내려놓으세요',
          '서로의 사랑의 언어를 이해하세요',
          '함께하는 새로운 경험을 만들어보세요'
        ],
        'siblings': [
          '비교하지 말고 각자의 개성을 인정하세요',
          '어린 시절 추억을 함께 회상해보세요',
          '서로의 성공을 진심으로 축하해주세요',
          '갈등이 있다면 직접 대화로 해결하세요',
          '부모님을 함께 돌보며 협력하세요'
        ],
        'extended': [
          '세대 차이를 인정하고 존중하세요',
          '정기적인 가족 모임을 가져보세요',
          '어르신의 지혜를 귀담아 들으세요',
          '젊은 세대의 새로운 시각을 수용하세요',
          '가족의 전통을 함께 만들어가세요'
        ],
        'single-parent': [
          '완벽하지 않아도 괜찮다고 스스로를 격려하세요',
          '도움을 요청하는 것을 부끄러워하지 마세요',
          '자신을 위한 시간도 중요합니다',
          '아이와 팀이 되어 함께 성장하세요',
          '작은 성취도 함께 축하하세요'
        ]
      }
      
      const typeAdvices = advices[type] || advices['parent-child']
      return typeAdvices[Math.floor(Math.random() * typeAdvices.length)]
    }

    // 가족 갈등 예방 팁
    const generateConflictPrevention = () => {
      const tips = [
        {
          situation: '의견 충돌 시',
          prevention: '각자의 의견을 충분히 들어준 후 공통점을 찾아보세요',
          solution: '잠시 휴식을 갖고 감정이 진정된 후 대화를 재개하세요'
        },
        {
          situation: '세대 갈등',
          prevention: '서로의 시대적 배경과 가치관을 이해하려 노력하세요',
          solution: '중재자 역할을 할 수 있는 가족 구성원의 도움을 받으세요'
        },
        {
          situation: '경제적 스트레스',
          prevention: '가족 회의를 통해 투명하게 상황을 공유하세요',
          solution: '함께 절약 계획을 세우고 서로를 격려하세요'
        },
        {
          situation: '시간 부족',
          prevention: '가족과의 시간을 우선순위에 두고 계획하세요',
          solution: '짧은 시간이라도 질 높은 시간을 보내도록 노력하세요'
        }
      ]
      
      return tips[Math.floor(Math.random() * tips.length)]
    }

    // 특별한 날 이벤트
    const generateSpecialEvents = () => {
      const today = new Date()
      const dayOfWeek = today.getDay()
      const date = today.getDate()
      
      const events = {
        weekend: dayOfWeek === 0 || dayOfWeek === 6,
        monthStart: date <= 7,
        monthEnd: date >= 24,
        score: Math.floor(Math.random() * 30) + 70
      }
      
      let specialEvent = null
      if (events.weekend) {
        specialEvent = '주말은 가족과 함께 특별한 추억을 만들기 좋은 날입니다'
      } else if (events.monthStart) {
        specialEvent = '새로운 한 달의 시작, 가족 목표를 세워보세요'
      } else if (events.monthEnd) {
        specialEvent = '한 달을 마무리하며 가족과 함께한 시간을 돌아보세요'
      }
      
      return {
        hasSpecialEvent: specialEvent !== null,
        event: specialEvent,
        eventScore: events.score
      }
    }

    // 주간 가족 운세 트렌드
    const generateWeeklyTrend = () => {
      const days = ['월', '화', '수', '목', '금', '토', '일']
      const trend = {}
      
      days.forEach(day => {
        trend[day] = {
          score: Math.floor(Math.random() * 30) + 60,
          keyword: ['화합', '소통', '성장', '휴식', '도전', '즐거움', '사랑'][Math.floor(Math.random() * 7)]
        }
      })
      
      return trend
    }

    const familyInfo = generateFamilyFortune(family_type || 'parent-child')
    const harmonyScore = calculateHarmonyScore()
    const memberFortunes = generateMemberFortunes(family_members || [])
    const todayActivity = generateFamilyActivities(family_type || 'parent-child')
    const relationshipAdvice = generateRelationshipAdvice(family_type || 'parent-child')
    const conflictTip = generateConflictPrevention()
    const specialEvents = generateSpecialEvents()
    const weeklyTrend = generateWeeklyTrend()

    // 메인 운세 메시지 생성
    const generateMainMessage = () => {
      const messages = [
        `오늘은 가족 간의 ${familyInfo.keywords[0]}이 특히 중요한 날입니다. ${relationshipAdvice}`,
        `가족 화합도가 ${harmonyScore}%로 ${harmonyScore > 80 ? '매우 좋은' : harmonyScore > 60 ? '좋은' : '평범한'} 상태입니다. ${todayActivity.activity}를 통해 더욱 가까워질 수 있습니다.`,
        `${familyInfo.focus}에 집중하기 좋은 날입니다. 서로를 이해하고 존중하는 마음으로 대화를 나누어보세요.`,
        `가족 구성원 모두가 ${familyInfo.keywords[1]}의 에너지로 가득한 날입니다. 함께하는 시간을 소중히 여기세요.`
      ]
      
      return messages[Math.floor(Math.random() * messages.length)]
    }

    // 운세 데이터 구성
    const fortune = {
      id: `family-${Date.now()}`,
      userId: userId,
      type: 'family-harmony',
      content: generateMainMessage(),
      
      // 가족 운세 정보
      family_info: {
        type: family_type,
        title: familyInfo.title,
        focus: familyInfo.focus,
        keywords: familyInfo.keywords
      },
      
      // 화합도
      harmony: {
        score: harmonyScore,
        level: harmonyScore > 80 ? '최상' : harmonyScore > 60 ? '양호' : '보통',
        description: `오늘의 가족 화합도는 ${harmonyScore}%입니다. ${harmonyScore > 80 ? '서로를 향한 사랑과 이해가 넘치는 날입니다.' : harmonyScore > 60 ? '평온하고 안정적인 가족 분위기가 조성됩니다.' : '조금 더 서로에게 관심을 가져보세요.'}`
      },
      
      // 구성원별 운세
      member_fortunes: memberFortunes,
      
      // 오늘의 활동
      today_activity: todayActivity,
      
      // 관계 조언
      relationship: {
        advice: relationshipAdvice,
        tip: '서로의 다름을 인정하고 존중할 때 진정한 화합이 시작됩니다'
      },
      
      // 갈등 예방
      conflict_prevention: conflictTip,
      
      // 특별 이벤트
      special_events: specialEvents,
      
      // 주간 트렌드
      weekly_trend: weeklyTrend,
      
      // 행운 요소
      lucky_elements: {
        time: `${Math.floor(Math.random() * 12) + 1}시`,
        place: ['거실', '식탁', '정원', '공원', '카페'][Math.floor(Math.random() * 5)],
        activity: familyInfo.keywords[0],
        color: ['노란색', '하늘색', '연두색', '분홍색', '주황색'][Math.floor(Math.random() * 5)],
        food: ['함께 만든 음식', '전통 음식', '새로운 요리', '간식', '과일'][Math.floor(Math.random() * 5)]
      },
      
      // 카테고리별 점수
      categories: {
        communication: {
          score: Math.floor(Math.random() * 30) + 70,
          advice: '대화할 때 경청하는 자세를 가져보세요'
        },
        affection: {
          score: Math.floor(Math.random() * 30) + 70,
          advice: '스킨십과 따뜻한 말로 애정을 표현하세요'
        },
        cooperation: {
          score: Math.floor(Math.random() * 30) + 70,
          advice: '가족 구성원 모두가 참여하는 활동을 계획하세요'
        },
        growth: {
          score: Math.floor(Math.random() * 30) + 70,
          advice: '함께 성장하고 발전하는 가족이 되세요'
        }
      },
      
      // 추천사항
      recommendations: [
        todayActivity.activity,
        relationshipAdvice,
        '가족 사진을 찍어 추억을 남겨보세요',
        '감사한 마음을 표현하는 시간을 가져보세요'
      ],
      
      // 주의사항
      warnings: [
        conflictTip.prevention,
        '서두르지 말고 충분한 시간을 가지세요',
        '비판보다는 격려의 말을 사용하세요'
      ],
      
      overallScore: harmonyScore,
      createdAt: new Date().toISOString()
    }

    // ✅ Percentile 계산 추가
    const percentileData = await calculatePercentile(supabaseClient, 'family-harmony', harmonyScore)
    const fortuneWithPercentile = addPercentileToResult(fortune, percentileData)

    // Edge Function 응답
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
    console.error('Error generating family harmony fortune:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Failed to generate family harmony fortune',
        message: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500 
      }
    )
  }
})