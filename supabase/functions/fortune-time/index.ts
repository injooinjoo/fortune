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

    // 기간별 특별 조언 생성
    const generatePeriodAdvice = () => {
      const periodAdvices = {
        today: `오늘은 ${dayOfWeek}요일입니다. 하루의 시작을 긍정적으로 맞이하세요.`,
        tomorrow: `내일을 위한 준비를 차근차근 해나가세요. 계획적인 접근이 중요합니다.`,
        weekly: `이번 주는 전체적으로 안정적인 흐름을 보입니다. 꾸준한 노력이 성과로 이어질 것입니다.`,
        monthly: `이번 달은 변화와 성장의 시기입니다. 새로운 도전을 두려워하지 마세요.`,
        yearly: `올해는 장기적인 관점에서 목표를 설정하고 실행하는 것이 중요합니다.`,
        hourly: `시간대별로 에너지가 다르게 흐릅니다. 각 시간의 특성을 활용하여 효율적으로 활동하세요.`
      }
      
      return periodAdvices[period] || '긍정적인 마음으로 앞으로 나아가세요.'
    }

    // AI 인사이트 생성
    const generateAIInsight = () => {
      if (overallScore >= 90) {
        return `${period === 'today' ? '오늘' : period === 'tomorrow' ? '내일' : '이 기간'}은 정말 특별한 시간입니다! 모든 일이 순조롭게 풀릴 것이니 적극적으로 도전해보세요.`
      } else if (overallScore >= 80) {
        return `${period === 'today' ? '오늘' : period === 'tomorrow' ? '내일' : '이 기간'}은 좋은 기운이 흐르고 있습니다. 이 기회를 놓치지 마세요.`
      } else if (overallScore >= 70) {
        return `안정적이고 평온한 시간이 될 것입니다. 꾸준히 노력한다면 좋은 결과를 얻을 수 있어요.`
      } else if (overallScore >= 60) {
        return `신중하게 행동한다면 무난한 시간을 보낼 수 있습니다. 급하지 않은 결정은 미뤄두세요.`
      } else {
        return `조금 어려운 시기이지만 인내심을 갖고 차근차근 해나간다면 분명 좋은 결과가 있을 것입니다.`
      }
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
      return titles[period] || '시간별 운세'
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
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
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
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500 
      }
    )
  }
})