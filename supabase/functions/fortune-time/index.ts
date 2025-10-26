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
      birthDate, 
      birthTime,
      gender,
      isLunar,
      mbtiType,
      bloodType,
      zodiacSign,
      zodiacAnimal,
      location,
      period = 'today',
      date
    } = requestData

    // 클라이언트에서 전달받은 날짜 또는 한국 시간대로 현재 날짜 생성
    const targetDate = date 
      ? new Date(date) 
      : new Date(new Date().toLocaleString("en-US", {timeZone: "Asia/Seoul"}))
    
    const dayOfWeek = ['일', '월', '화', '수', '목', '금', '토'][targetDate.getDay()]
    
    // 지역 정보 처리
    const processedLocation = location || '서울'
    
    // 기간별 기본 점수 생성
    const generateBaseScore = () => {
      const baseScore = 70 + Math.floor(Math.random() * 20)
      return Math.min(100, baseScore + (mbtiType === 'ENTJ' ? 5 : 0))
    }

    const overallScore = generateBaseScore()

    // 6각형 차트용 점수 생성
    const generateHexagonScores = () => {
      return {
        love: Math.min(100, overallScore + Math.floor(Math.random() * 10) - 5),
        money: Math.min(100, overallScore + Math.floor(Math.random() * 15) - 7),
        health: Math.min(100, overallScore + Math.floor(Math.random() * 12) - 6),
        work: Math.min(100, overallScore + Math.floor(Math.random() * 8) - 4),
        family: Math.min(100, overallScore + Math.floor(Math.random() * 10) - 5),
        study: Math.min(100, overallScore + Math.floor(Math.random() * 12) - 6)
      }
    }

    // 시간대별 운세 생성 (오늘/내일/hourly용)
    const generateTimeSpecificFortunes = () => {
      if (period !== 'today' && period !== 'tomorrow' && period !== 'hourly') return null
      
      const timeSlots = [
        { time: '06:00-09:00', description: '새벽의 기운' },
        { time: '09:00-12:00', description: '오전의 활력' },
        { time: '12:00-15:00', description: '점심의 균형' },
        { time: '15:00-18:00', description: '오후의 집중' },
        { time: '18:00-21:00', description: '저녁의 휴식' },
        { time: '21:00-24:00', description: '밤의 성찰' }
      ]
      
      return timeSlots.map(slot => ({
        time: slot.time,
        description: slot.description,
        score: Math.min(100, overallScore + Math.floor(Math.random() * 20) - 10),
        advice: `${slot.description} 시간에는 ${Math.random() > 0.5 ? '적극적으로' : '신중하게'} 행동하세요.`
      }))
    }

    // 요일별 운세 생성 (주간용)
    const generateWeeklyFortunes = () => {
      if (period !== 'weekly') return null
      
      const weekdays = [
        { day: '월요일', description: '새로운 시작' },
        { day: '화요일', description: '열정적인 추진' },
        { day: '수요일', description: '균형과 조화' },
        { day: '목요일', description: '성장과 발전' },
        { day: '금요일', description: '완성과 마무리' },
        { day: '토요일', description: '휴식과 재충전' },
        { day: '일요일', description: '평온과 성찰' }
      ]
      
      return weekdays.map(day => ({
        time: day.day,
        description: day.description,
        score: Math.min(100, overallScore + Math.floor(Math.random() * 20) - 10),
        advice: `${day.day}에는 ${day.description}에 집중하세요.`
      }))
    }

    // 월별 운세 생성 (연간용)
    const generateMonthlyFortunes = () => {
      if (period !== 'yearly') return null
      
      const months = [
        { month: '1월', description: '새해의 다짐' },
        { month: '2월', description: '인내와 준비' },
        { month: '3월', description: '새 출발' },
        { month: '4월', description: '성장의 시작' },
        { month: '5월', description: '활기찬 발전' },
        { month: '6월', description: '균형과 조화' },
        { month: '7월', description: '열정적 추진' },
        { month: '8월', description: '강렬한 에너지' },
        { month: '9월', description: '안정과 수확' },
        { month: '10월', description: '성숙한 결실' },
        { month: '11월', description: '차분한 정리' },
        { month: '12월', description: '마무리와 감사' }
      ]
      
      return months.map(month => ({
        time: month.month,
        description: month.description,
        score: Math.min(100, overallScore + Math.floor(Math.random() * 20) - 10),
        advice: `${month.month}에는 ${month.description}을 중점적으로 하세요.`
      }))
    }

    // 띠별 운세 비교 생성
    const generateBirthYearFortunes = () => {
      const animals = ['쥐', '소', '호랑이', '토끼', '용', '뱀', '말', '양', '원숭이', '닭', '개', '돼지']
      
      return animals.map(animal => ({
        year: animal,
        score: Math.min(100, overallScore + Math.floor(Math.random() * 30) - 15),
        description: `${animal}띠는 ${period === 'today' ? '오늘' : period === 'tomorrow' ? '내일' : '이 기간'} ${Math.random() > 0.5 ? '행운' : '신중함'}이 필요합니다.`,
        isUserZodiac: animal === zodiacAnimal
      }))
    }

    // 기간별 특별 조언 생성 (개인화 포함)
    const generatePeriodAdvice = () => {
      const age = birthDate ? calculateAge(birthDate) : null
      const ageGroup = age ? getAgeGroup(age) : null
      const userGender = gender || 'male'
      const demographicKey = age ? `${userGender}_${ageGroup}` : null
      
      // 연령대별 맞춤 조언 데이터베이스
      const personalizedAdvices: { [key: string]: { [key: string]: string } } = {
        'male_20s_late': {
          today: `오늘은 새로운 네트워킹 기회를 만들어보세요. 적극적인 자세가 좋은 결과를 가져올 것입니다.`,
          tomorrow: `내일은 커리어 발전을 위한 구체적인 계획을 세워보는 하루로 만들어보세요.`,
          weekly: `이번 주는 자기계발에 투자하기 좋은 시기입니다. 새로운 스킬을 배워보세요.`,
          monthly: `이번 달은 독립과 성장을 위한 기반을 다지는 중요한 시기입니다.`
        },
        'male_30s_early': {
          today: `오늘은 중요한 결정을 내리기에 좋은 날입니다. 경험과 직감을 믿고 행동하세요.`,
          tomorrow: `내일은 팀워크와 리더십을 발휘할 기회가 있을 것입니다.`,
          weekly: `이번 주는 투자와 미래 계획에 집중하기 좋은 시기입니다.`,
          monthly: `이번 달은 책임감 있는 역할을 맡아 성과를 내는 시기입니다.`
        },
        'male_30s_late': {
          today: `오늘은 후배들과의 소통을 통해 새로운 아이디어를 얻을 수 있습니다.`,
          tomorrow: `내일은 장기적 관점에서 투자 결정을 검토해보세요.`,
          weekly: `이번 주는 일과 가정의 균형을 맞추는 데 집중하세요.`,
          monthly: `이번 달은 안정성과 성장성을 모두 고려한 선택이 중요합니다.`
        },
        'female_20s_late': {
          today: `오늘은 자신의 가치를 인정받을 수 있는 기회가 있습니다. 자신감을 가지세요.`,
          tomorrow: `내일은 전문성 향상을 위한 학습에 시간을 투자해보세요.`,
          weekly: `이번 주는 같은 관심사를 가진 사람들과의 네트워킹이 도움이 될 것입니다.`,
          monthly: `이번 달은 자신만의 커리어 로드맵을 그려보는 시기입니다.`
        },
        'female_30s_early': {
          today: `오늘은 워라밸을 개선할 수 있는 방법을 찾아보세요.`,
          tomorrow: `내일은 자신의 강점을 활용할 수 있는 프로젝트에 집중하세요.`,
          weekly: `이번 주는 개인적 성장과 커리어 발전의 균형을 맞추기 좋은 시기입니다.`,
          monthly: `이번 달은 다양한 선택지 중에서 자신에게 맞는 길을 찾는 시기입니다.`
        },
        'female_30s_late': {
          today: `오늘은 경험을 바탕으로 한 조언이 많은 도움이 될 것입니다.`,
          tomorrow: `내일은 리더십을 발휘하여 팀의 방향성을 제시해보세요.`,
          weekly: `이번 주는 자신만의 브랜드 가치를 높이는 데 집중하세요.`,
          monthly: `이번 달은 지혜로운 판단력을 바탕으로 중요한 결정을 내리는 시기입니다.`
        }
      }
      
      // 기본 조언
      const defaultAdvices = {
        today: `오늘은 ${dayOfWeek}요일입니다. 하루의 시작을 긍정적으로 맞이하세요.`,
        tomorrow: `내일을 위한 준비를 차근차근 해나가세요. 계획적인 접근이 중요합니다.`,
        weekly: `이번 주는 전체적으로 안정적인 흐름을 보입니다. 꾸준한 노력이 성과로 이어질 것입니다.`,
        monthly: `이번 달은 변화와 성장의 시기입니다. 새로운 도전을 두려워하지 마세요.`,
        yearly: `올해는 장기적인 관점에서 목표를 설정하고 실행하는 것이 중요합니다.`,
        hourly: `시간대별로 에너지가 다르게 흐릅니다. 각 시간의 특성을 활용하여 효율적으로 활동하세요.`
      }
      
      // 개인화된 조언 또는 기본 조언 반환
      if (demographicKey && personalizedAdvices[demographicKey] && personalizedAdvices[demographicKey][period]) {
        return personalizedAdvices[demographicKey][period]
      }
      
      return defaultAdvices[period] || '긍정적인 마음으로 앞으로 나아가세요.'
    }

    // 사용자 나이 계산
    const calculateAge = (birthDate: string): number => {
      const birth = new Date(birthDate)
      const now = new Date()
      let age = now.getFullYear() - birth.getFullYear()
      if (now.getMonth() < birth.getMonth() || (now.getMonth() === birth.getMonth() && now.getDate() < birth.getDate())) {
        age--
      }
      return age
    }

    // 연령대 그룹 분류
    const getAgeGroup = (age: number): string => {
      if (age < 25) return '20s_early'
      if (age < 30) return '20s_late'
      if (age < 35) return '30s_early'
      if (age < 40) return '30s_late'
      if (age < 45) return '40s_early'
      if (age < 50) return '40s_late'
      if (age < 55) return '50s_early'
      if (age < 60) return '50s_late'
      return '60plus'
    }

    // 개인화된 AI 인사이트 생성
    const generateAIInsight = () => {
      const age = birthDate ? calculateAge(birthDate) : null
      const ageGroup = age ? getAgeGroup(age) : null
      const userGender = gender || 'male'
      const demographicKey = age ? `${userGender}_${ageGroup}` : null
      
      // 연령대별 맞춤 메시지 데이터베이스
      const personalizedInsights: { [key: string]: { [key: number]: string } } = {
        'male_20s_late': {
          90: `${period === 'today' ? '오늘' : period === 'tomorrow' ? '내일' : '이 기간'}은 새로운 기회를 잡기에 완벽한 타이밍입니다. 망설였던 도전을 시작해보세요.`,
          80: `커리어 발전에 좋은 흐름이 있습니다. 선배나 멘토와의 대화가 큰 도움이 될 것입니다.`,
          70: `꾸준한 노력이 결실을 맺을 시기입니다. 작은 성취도 소중히 여기세요.`,
          60: `급하게 결정하기보다는 신중한 검토가 필요한 시기입니다. 시간을 두고 판단하세요.`,
          50: `어려운 상황이지만 이것도 성장의 과정입니다. 포기하지 말고 한 걸음씩 나아가세요.`
        },
        'male_30s_early': {
          90: `리더십을 발휘할 절호의 기회입니다. 중요한 프로젝트나 결정을 추진해보세요.`,
          80: `경험과 역량이 인정받을 때입니다. 자신감을 갖고 의견을 표현해보세요.`,
          70: `안정적인 성과를 이룰 수 있는 시기입니다. 계획대로 차근차근 진행하세요.`,
          60: `감정보다는 이성적 판단이 중요합니다. 데이터와 사실을 바탕으로 결정하세요.`,
          50: `조급해하지 말고 기초를 다지는 시간으로 활용하세요. 준비된 자에게 기회가 옵니다.`
        },
        'male_30s_late': {
          90: `축적된 경험이 빛을 발할 때입니다. 후배들에게 멘토링을 해보는 것도 좋겠습니다.`,
          80: `장기적 관점에서 투자하고 계획할 좋은 시기입니다. 미래를 위한 준비를 시작하세요.`,
          70: `균형 잡힌 생활이 더욱 중요해집니다. 일과 가정의 조화를 이루도록 노력하세요.`,
          60: `성급한 변화보다는 안정성을 우선시하는 것이 현명합니다.`,
          50: `현재의 어려움은 더 나은 미래를 위한 밑거름입니다. 인내심을 갖고 기다리세요.`
        },
        'female_20s_late': {
          90: `자신만의 색깔을 찾아가는 완벽한 시기입니다. 용기를 내어 새로운 시도를 해보세요.`,
          80: `전문성을 키우기에 좋은 때입니다. 자기계발에 투자하면 큰 성과를 얻을 수 있어요.`,
          70: `주변의 조언도 좋지만, 자신의 직감을 믿는 것이 중요합니다.`,
          60: `완벽을 추구하기보다는 진전에 초점을 맞추세요. 작은 발걸음도 소중합니다.`,
          50: `힘든 시기이지만 이를 통해 더욱 강해질 수 있습니다. 자신을 믿어주세요.`
        },
        'female_30s_early': {
          90: `워라밸을 실현할 수 있는 기회들이 보입니다. 자신에게 맞는 길을 찾아가세요.`,
          80: `개인적인 성장과 커리어 발전 모두에 좋은 흐름이 있습니다.`,
          70: `다양한 선택지가 있는 시기입니다. 신중하지만 과감하게 결정하세요.`,
          60: `모든 것을 혼자 해결하려 하지 마세요. 도움을 요청하는 것도 지혜입니다.`,
          50: `현재의 상황이 어렵더라도 당신만의 속도로 나아가면 됩니다.`
        },
        'female_30s_late': {
          90: `지혜롭고 성숙한 판단력이 빛을 발할 때입니다. 리더십을 발휘해보세요.`,
          80: `경험을 바탕으로 한 조언이 많은 사람들에게 도움이 될 것입니다.`,
          70: `자신만의 브랜드를 구축해나가기에 좋은 시기입니다.`,
          60: `급한 변화보다는 점진적인 개선이 더 효과적일 것입니다.`,
          50: `지금까지의 노력이 헛되지 않습니다. 조금만 더 버티면 전환점이 올 것입니다.`
        }
      }

      // 기본 메시지 (연령/성별 정보가 없는 경우)
      const defaultInsights: { [key: number]: string } = {
        90: `${period === 'today' ? '오늘' : period === 'tomorrow' ? '내일' : '이 기간'}은 정말 특별한 시간입니다! 모든 일이 순조롭게 풀릴 것이니 적극적으로 도전해보세요.`,
        80: `${period === 'today' ? '오늘' : period === 'tomorrow' ? '내일' : '이 기간'}은 좋은 기운이 흐르고 있습니다. 이 기회를 놓치지 마세요.`,
        70: `안정적이고 평온한 시간이 될 것입니다. 꾸준히 노력한다면 좋은 결과를 얻을 수 있어요.`,
        60: `신중하게 행동한다면 무난한 시간을 보낼 수 있습니다. 급하지 않은 결정은 미뤄두세요.`,
        50: `조금 어려운 시기이지만 인내심을 갖고 차근차근 해나간다면 분명 좋은 결과가 있을 것입니다.`
      }

      // 점수대 구간 결정
      const scoreRange = overallScore >= 90 ? 90 : 
                        overallScore >= 80 ? 80 : 
                        overallScore >= 70 ? 70 : 
                        overallScore >= 60 ? 60 : 50

      // 개인화된 메시지 또는 기본 메시지 반환
      if (demographicKey && personalizedInsights[demographicKey]) {
        return personalizedInsights[demographicKey][scoreRange] || defaultInsights[scoreRange]
      }
      
      return defaultInsights[scoreRange]
    }

    // 행운의 아이템 생성
    const generateLuckyItems = () => {
      const colors = ['빨간색', '파란색', '노란색', '초록색', '보라색', '주황색', '분홍색', '하얀색']
      const directions = ['동쪽', '서쪽', '남쪽', '북쪽', '동남쪽', '동북쪽', '서남쪽', '서북쪽']
      
      return {
        color: colors[Math.floor(Math.random() * colors.length)],
        number: Math.floor(Math.random() * 9) + 1,
        direction: directions[Math.floor(Math.random() * directions.length)],
        time: `${Math.floor(Math.random() * 12) + 1}시-${Math.floor(Math.random() * 12) + 13}시`
      }
    }

    // 기간별 제목 생성
    const getPeriodTitle = () => {
      const titles = {
        today: '오늘의 운세',
        tomorrow: '내일의 운세',
        weekly: '이번 주 운세',
        monthly: '이번 달 운세',
        yearly: '올해 운세',
        hourly: '시간대별 운세'
      }
      return titles[period] || '일일운세'
    }

    // 운세 데이터 구성
    const fortune = {
      id: `${Date.now()}-${period}`,
      userId: userId,
      type: 'time_based',
      period: period,
      score: overallScore,
      overall_score: overallScore,
      message: `${name}님의 ${getPeriodTitle()}입니다.`,
      content: generateAIInsight(),
      description: generateAIInsight(),
      greeting: `${name}님, ${targetDate.getFullYear()}년 ${targetDate.getMonth() + 1}월 ${targetDate.getDate()}일 ${dayOfWeek}요일의 ${getPeriodTitle()}를 확인해보세요.`,
      advice: generatePeriodAdvice(),
      caution: period === 'today' || period === 'tomorrow' 
        ? '감정적인 결정보다는 이성적인 판단을 우선시하세요.' 
        : '급한 결정보다는 충분한 검토 후 행동하세요.',
      summary: overallScore >= 80 ? '긍정적이고 활기찬 시기' : '안정적이고 차분한 시기',
      
      // 상세 데이터
      hexagonScores: generateHexagonScores(),
      timeSpecificFortunes: generateTimeSpecificFortunes() || generateWeeklyFortunes() || generateMonthlyFortunes(),
      birthYearFortunes: generateBirthYearFortunes(),
      
      // 행운의 아이템
      luckyItems: generateLuckyItems(),
      lucky_items: generateLuckyItems(),
      luckyColor: generateLuckyItems().color,
      luckyNumber: generateLuckyItems().number,
      luckyDirection: generateLuckyItems().direction,
      bestTime: generateLuckyItems().time,
      
      // 특별 팁
      specialTip: `${getPeriodTitle()}에는 ${zodiacAnimal}띠의 특성을 살려 ${Math.random() > 0.5 ? '적극적으로' : '신중하게'} 행동하는 것이 좋겠습니다.`,
      special_tip: `${getPeriodTitle()}에는 ${zodiacAnimal}띠의 특성을 살려 ${Math.random() > 0.5 ? '적극적으로' : '신중하게'} 행동하는 것이 좋겠습니다.`,
      
      // 메타데이터
      metadata: {
        period: period,
        targetDate: targetDate.toISOString(),
        location: processedLocation,
        generatedAt: new Date().toISOString()
      }
    }

    return new Response(
      JSON.stringify({ 
        fortune,
        cached: false,
        tokensUsed: 0
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 200 
      }
    )

  } catch (error) {
    console.error('Error generating time-based fortune:', error)
    
    return new Response(
      JSON.stringify({ 
        error: 'Failed to generate time-based fortune',
        message: error.message 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json; charset=utf-8' },
        status: 500 
      }
    )
  }
})