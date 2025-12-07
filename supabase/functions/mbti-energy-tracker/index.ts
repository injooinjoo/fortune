/**
 * MBTI 에너지 트래커 (MBTI Energy Tracker) Edge Function
 *
 * @description MBTI 유형별 일일 에너지 흐름과 활동 추천을 생성합니다.
 *
 * @endpoint POST /mbti-energy-tracker
 *
 * @requestBody
 * - mbti_type: string - MBTI 유형 (필수, 예: INTJ, ENFP)
 * - user_id?: string - 사용자 ID
 * - date?: string - 대상 날짜 (기본값: 오늘)
 *
 * @response MbtiEnergyResponse
 * - mbti_type: string - MBTI 유형
 * - date: string - 날짜
 * - energy_flow: object - 시간대별 에너지 흐름
 *   - morning: number - 아침 에너지 (0-100)
 *   - afternoon: number - 오후 에너지 (0-100)
 *   - evening: number - 저녁 에너지 (0-100)
 * - peak_hours: string[] - 최고 에너지 시간대
 * - recommended_activities: object - 추천 활동
 *   - work: string[] - 업무 관련
 *   - social: string[] - 사회적 활동
 *   - self_care: string[] - 자기 관리
 * - warnings: string[] - 주의사항
 * - tips: string[] - 에너지 관리 팁
 *
 * @example
 * // Request
 * {
 *   "mbti_type": "INTJ",
 *   "date": "2024-01-15"
 * }
 *
 * // Response
 * {
 *   "mbti_type": "INTJ",
 *   "energy_flow": { "morning": 85, "afternoon": 70, "evening": 60 },
 *   "peak_hours": ["09:00-11:00", "14:00-16:00"],
 *   "recommended_activities": { "work": ["전략 수립", "분석 업무"] }
 * }
 */
import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { corsHeaders } from '../_shared/cors.ts'

interface MbtiEnergyRequest {
  mbti_type: string;
  user_id?: string;
  date?: string;
}

serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { mbti_type, user_id, date } = await req.json() as MbtiEnergyRequest;
    
    if (!mbti_type || mbti_type.length !== 4) {
      throw new Error('Valid MBTI type is required (e.g., INTJ, ENFP)')
    }

    const targetDate = date ? new Date(date) : new Date();
    const mbtiData = generateMbtiEnergyData(mbti_type, targetDate, user_id);

    return new Response(
      JSON.stringify(mbtiData),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ 
        error: error.message || 'Failed to generate MBTI energy data',
        details: error.toString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400
      }
    )
  }
})

function generateMbtiEnergyData(mbtiType: string, date: Date, userId?: string) {
  const seed = date.getFullYear() * 10000 + date.getMonth() * 100 + date.getDate() + mbtiType.charCodeAt(0);
  const random = (min: number, max: number) => {
    const x = Math.sin(seed) * 10000;
    return Math.floor((x - Math.floor(x)) * (max - min + 1)) + min;
  };

  // MBTI 분석
  const [e_i, s_n, t_f, j_p] = mbtiType.split('');
  const isExtrovert = e_i === 'E';
  const isIntuitive = s_n === 'N';
  const isThinking = t_f === 'T';
  const isJudging = j_p === 'J';

  // 바이오리듬 계산 (28일 주기)
  const dayInCycle = Math.floor((date.getTime() - new Date(date.getFullYear(), 0, 1).getTime()) / (1000 * 60 * 60 * 24)) % 28;
  const biorhythm = Math.sin(2 * Math.PI * dayInCycle / 28);

  // 1. 에너지 레벨 계산
  const energyLevels = calculateEnergyLevels(mbtiType, date, biorhythm, isExtrovert);
  
  // 2. 인지기능 날씨
  const cognitiveWeather = generateCognitiveWeather(mbtiType, date);
  
  // 3. 시너지 맵
  const synergyMap = generateSynergyMap(mbtiType, date);
  
  // 4. 일일 퀘스트
  const dailyQuests = generateDailyQuests(mbtiType, date, energyLevels);
  
  // 5. 무드 트래커
  const moodInsights = generateMoodInsights(mbtiType, date, biorhythm);
  
  // 6. 시간대별 조언
  const timeBasedAdvice = generateTimeBasedAdvice(mbtiType, date, energyLevels);

  return {
    mbtiType,
    date: date.toISOString().split('T')[0],
    energyLevels,
    cognitiveWeather,
    synergyMap,
    dailyQuests,
    moodInsights,
    timeBasedAdvice,
    overallScore: Math.round((energyLevels.totalEnergy + moodInsights.stabilityScore) / 2),
    mainMessage: generateMainMessage(mbtiType, energyLevels, cognitiveWeather),
    luckyElements: generateLuckyElements(mbtiType, date)
  };
}

function calculateEnergyLevels(mbtiType: string, date: Date, biorhythm: number, isExtrovert: boolean) {
  const seed = date.getTime() + mbtiType.charCodeAt(0);
  const random = (min: number, max: number) => {
    const x = Math.sin(seed) * 10000;
    return Math.floor((x - Math.floor(x)) * (max - min + 1)) + min;
  };

  // 소셜 배터리
  let socialBattery = isExtrovert ? 
    70 + biorhythm * 15 + random(-5, 10) :
    40 + biorhythm * 10 + random(-5, 10);

  // 혼자 시간 배터리
  let aloneBattery = !isExtrovert ?
    70 + biorhythm * 15 + random(-5, 10) :
    40 + biorhythm * 10 + random(-5, 10);

  // 요일별 보정
  const weekday = date.getDay();
  if (weekday === 0 || weekday === 6) { // 주말
    aloneBattery += 10;
    socialBattery -= 5;
  } else { // 평일
    socialBattery += 5;
    aloneBattery -= 5;
  }

  // 시간대별 에너지 패턴
  const patterns = getEnergyPatterns(mbtiType);
  const hour = new Date().getHours();
  let currentTimeEnergy = 50;
  
  if (hour >= 6 && hour < 12) {
    currentTimeEnergy = patterns.morning;
  } else if (hour >= 12 && hour < 17) {
    currentTimeEnergy = patterns.afternoon;
  } else if (hour >= 17 && hour < 22) {
    currentTimeEnergy = patterns.evening;
  } else {
    currentTimeEnergy = patterns.night;
  }

  const totalEnergy = Math.round((socialBattery + aloneBattery + currentTimeEnergy) / 3);
  
  // 번아웃 위험도 계산
  const burnoutRisk = calculateBurnoutRisk(totalEnergy, biorhythm);

  return {
    socialBattery: Math.min(100, Math.max(0, Math.round(socialBattery))),
    aloneBattery: Math.min(100, Math.max(0, Math.round(aloneBattery))),
    focusEnergy: Math.min(100, Math.max(0, Math.round(currentTimeEnergy + random(-10, 10)))),
    flexibilityEnergy: Math.min(100, Math.max(0, Math.round(60 + biorhythm * 20 + random(-10, 10)))),
    totalEnergy: Math.min(100, Math.max(0, totalEnergy)),
    burnoutRisk,
    peakTime: getPeakTime(patterns),
    lowTime: getLowTime(patterns),
    currentTimeScore: currentTimeEnergy
  };
}

function getEnergyPatterns(mbtiType: string) {
  const patterns: { [key: string]: any } = {
    'INTJ': { morning: 70, afternoon: 80, evening: 90, night: 60 },
    'INTP': { morning: 50, afternoon: 70, evening: 80, night: 90 },
    'ENTJ': { morning: 90, afternoon: 80, evening: 60, night: 40 },
    'ENTP': { morning: 60, afternoon: 80, evening: 90, night: 70 },
    'INFJ': { morning: 80, afternoon: 60, evening: 70, night: 50 },
    'INFP': { morning: 60, afternoon: 70, evening: 80, night: 70 },
    'ENFJ': { morning: 80, afternoon: 90, evening: 70, night: 50 },
    'ENFP': { morning: 70, afternoon: 80, evening: 90, night: 60 },
    'ISTJ': { morning: 90, afternoon: 80, evening: 60, night: 40 },
    'ISFJ': { morning: 80, afternoon: 70, evening: 60, night: 40 },
    'ESTJ': { morning: 90, afternoon: 80, evening: 60, night: 30 },
    'ESFJ': { morning: 80, afternoon: 90, evening: 70, night: 40 },
    'ISTP': { morning: 70, afternoon: 80, evening: 70, night: 60 },
    'ISFP': { morning: 60, afternoon: 70, evening: 80, night: 60 },
    'ESTP': { morning: 70, afternoon: 90, evening: 80, night: 60 },
    'ESFP': { morning: 70, afternoon: 80, evening: 90, night: 70 }
  };
  
  return patterns[mbtiType] || patterns['INFP'];
}

function getPeakTime(patterns: any) {
  const times = ['morning', 'afternoon', 'evening', 'night'];
  const labels = ['오전 (6-12시)', '오후 (12-17시)', '저녁 (17-22시)', '밤 (22시 이후)'];
  let maxTime = times[0];
  let maxValue = patterns[times[0]];
  
  times.forEach(time => {
    if (patterns[time] > maxValue) {
      maxValue = patterns[time];
      maxTime = time;
    }
  });
  
  return labels[times.indexOf(maxTime)];
}

function getLowTime(patterns: any) {
  const times = ['morning', 'afternoon', 'evening', 'night'];
  const labels = ['오전 (6-12시)', '오후 (12-17시)', '저녁 (17-22시)', '밤 (22시 이후)'];
  let minTime = times[0];
  let minValue = patterns[times[0]];
  
  times.forEach(time => {
    if (patterns[time] < minValue) {
      minValue = patterns[time];
      minTime = time;
    }
  });
  
  return labels[times.indexOf(minTime)];
}

function calculateBurnoutRisk(totalEnergy: number, biorhythm: number): string {
  const risk = (100 - totalEnergy) + (1 - biorhythm) * 30;
  
  if (risk < 30) return '낮음';
  if (risk < 60) return '보통';
  if (risk < 80) return '주의';
  return '위험';
}

function generateCognitiveWeather(mbtiType: string, date: Date) {
  const seed = date.getTime() + mbtiType.charCodeAt(1);
  const random = (min: number, max: number) => {
    const x = Math.sin(seed) * 10000;
    return Math.floor((x - Math.floor(x)) * (max - min + 1)) + min;
  };

  // MBTI별 인지기능 정의
  const cognitiveFunctions: { [key: string]: string[] } = {
    'INTJ': ['Ni', 'Te', 'Fi', 'Se'],
    'INTP': ['Ti', 'Ne', 'Si', 'Fe'],
    'ENTJ': ['Te', 'Ni', 'Se', 'Fi'],
    'ENTP': ['Ne', 'Ti', 'Fe', 'Si'],
    'INFJ': ['Ni', 'Fe', 'Ti', 'Se'],
    'INFP': ['Fi', 'Ne', 'Si', 'Te'],
    'ENFJ': ['Fe', 'Ni', 'Se', 'Ti'],
    'ENFP': ['Ne', 'Fi', 'Te', 'Si'],
    'ISTJ': ['Si', 'Te', 'Fi', 'Ne'],
    'ISFJ': ['Si', 'Fe', 'Ti', 'Ne'],
    'ESTJ': ['Te', 'Si', 'Ne', 'Fi'],
    'ESFJ': ['Fe', 'Si', 'Ne', 'Ti'],
    'ISTP': ['Ti', 'Se', 'Ni', 'Fe'],
    'ISFP': ['Fi', 'Se', 'Ni', 'Te'],
    'ESTP': ['Se', 'Ti', 'Fe', 'Ni'],
    'ESFP': ['Se', 'Fi', 'Te', 'Ni']
  };

  const functions = cognitiveFunctions[mbtiType] || cognitiveFunctions['INFP'];
  const weatherIcons = ['☀️', '🌤️', '⛅', '🌧️'];
  const weatherLabels = ['맑음', '구름 조금', '흐림', '비'];
  
  const functionWeather = functions.map((func, index) => {
    // 주도 기능일수록 날씨가 좋을 확률이 높음
    const baseScore = 100 - (index * 25);
    const variation = random(-15, 15);
    const score = Math.min(100, Math.max(0, baseScore + variation));
    
    let weatherIndex = 0;
    if (score >= 75) weatherIndex = 0;
    else if (score >= 50) weatherIndex = 1;
    else if (score >= 25) weatherIndex = 2;
    else weatherIndex = 3;
    
    return {
      function: func,
      name: getFunctionName(func),
      weather: weatherIcons[weatherIndex],
      label: weatherLabels[weatherIndex],
      score,
      advice: getFunctionAdvice(func, weatherIndex)
    };
  });

  return {
    functions: functionWeather,
    dominantToday: functionWeather[0].function,
    challengeToday: functionWeather[3].function,
    overallWeather: getOverallWeather(functionWeather)
  };
}

function getFunctionName(func: string): string {
  const names: { [key: string]: string } = {
    'Ni': '내향 직관',
    'Ne': '외향 직관',
    'Si': '내향 감각',
    'Se': '외향 감각',
    'Ti': '내향 사고',
    'Te': '외향 사고',
    'Fi': '내향 감정',
    'Fe': '외향 감정'
  };
  return names[func] || func;
}

function getFunctionAdvice(func: string, weatherIndex: number): string {
  const goodAdvice: { [key: string]: string } = {
    'Ni': '직관력이 뛰어난 날! 큰 그림을 그리기 좋습니다',
    'Ne': '창의력이 샘솟는 날! 브레인스토밍에 최적입니다',
    'Si': '세부사항 파악에 유리한 날! 꼼꼼한 작업을 해보세요',
    'Se': '현재에 집중하기 좋은 날! 운동이나 야외활동 추천',
    'Ti': '논리적 사고가 명확한 날! 분석 작업에 적합합니다',
    'Te': '실행력이 강한 날! 계획을 행동으로 옮기세요',
    'Fi': '자기 성찰의 시간! 내면의 목소리에 귀기울여보세요',
    'Fe': '공감 능력이 높은 날! 대인관계 활동에 좋습니다'
  };

  const badAdvice: { [key: string]: string } = {
    'Ni': '직관이 흐려진 날, 중요한 결정은 미루세요',
    'Ne': '아이디어가 막힌 날, 루틴 작업에 집중하세요',
    'Si': '디테일을 놓치기 쉬운 날, 더블체크 필수',
    'Se': '감각이 둔한 날, 무리한 활동은 피하세요',
    'Ti': '논리가 꼬이는 날, 단순한 작업 위주로',
    'Te': '실행력이 떨어지는 날, 계획 수정이 필요할 수 있어요',
    'Fi': '감정 기복이 있는 날, 자기 관리에 신경쓰세요',
    'Fe': '타인과의 소통이 어려운 날, 혼자만의 시간을 가지세요'
  };

  return weatherIndex <= 1 ? goodAdvice[func] || '' : badAdvice[func] || '';
}

function getOverallWeather(functionWeather: any[]): string {
  const avgScore = functionWeather.reduce((sum, f) => sum + f.score, 0) / functionWeather.length;
  
  if (avgScore >= 70) return '인지기능 최상! 무엇이든 도전하세요 🌈';
  if (avgScore >= 50) return '평균적인 컨디션, 일상적인 활동에 적합해요 ⛅';
  if (avgScore >= 30) return '에너지 관리가 필요한 날이에요 🌦️';
  return '충분한 휴식이 필요합니다 🌧️';
}

function generateSynergyMap(mbtiType: string, date: Date) {
  const seed = date.getTime() + mbtiType.charCodeAt(2);
  const random = (min: number, max: number) => {
    const x = Math.sin(seed) * 10000;
    return Math.floor((x - Math.floor(x)) * (max - min + 1)) + min;
  };

  // MBTI 궁합 매트릭스 (기본 궁합)
  const compatibilityMatrix: { [key: string]: { [key: string]: number } } = {
    'INTJ': { 'ENFP': 90, 'ENTP': 85, 'INFJ': 80, 'ENTJ': 75 },
    'INTP': { 'ENTJ': 90, 'ENFJ': 85, 'INTJ': 80, 'ENTP': 75 },
    'ENTJ': { 'INTP': 90, 'INFP': 85, 'INTJ': 80, 'ENTP': 75 },
    'ENTP': { 'INFJ': 90, 'INTJ': 85, 'ENFJ': 80, 'INTP': 75 },
    'INFJ': { 'ENTP': 90, 'ENFP': 85, 'INTJ': 80, 'INFP': 75 },
    'INFP': { 'ENFJ': 90, 'ENTJ': 85, 'INFJ': 80, 'ENFP': 75 },
    'ENFJ': { 'INFP': 90, 'ISFP': 85, 'INTP': 80, 'ENFP': 75 },
    'ENFP': { 'INFJ': 90, 'INTJ': 85, 'ENFJ': 80, 'INFP': 75 }
  };

  const allTypes = ['INTJ', 'INTP', 'ENTJ', 'ENTP', 'INFJ', 'INFP', 'ENFJ', 'ENFP',
                    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ', 'ISTP', 'ISFP', 'ESTP', 'ESFP'];

  const todaysSynergy = allTypes.map(type => {
    const baseScore = compatibilityMatrix[mbtiType]?.[type] || 
                     compatibilityMatrix[type]?.[mbtiType] || 
                     50 + random(-10, 10);
    
    // 오늘의 변동 적용
    const todayVariation = random(-15, 15);
    const finalScore = Math.min(100, Math.max(0, baseScore + todayVariation));
    
    return {
      type,
      score: finalScore,
      trend: todayVariation > 0 ? '상승' : todayVariation < 0 ? '하락' : '유지',
      advice: getSynergyAdvice(mbtiType, type, finalScore)
    };
  });

  // 베스트/워스트 찾기
  const sorted = [...todaysSynergy].sort((a, b) => b.score - a.score);
  
  return {
    allTypes: todaysSynergy,
    bestMatch: sorted[0],
    challengingMatch: sorted[sorted.length - 1],
    recommendedPartner: sorted[1], // 두 번째로 좋은 매치 (더 현실적)
    averageScore: Math.round(todaysSynergy.reduce((sum, t) => sum + t.score, 0) / todaysSynergy.length)
  };
}

function getSynergyAdvice(myType: string, otherType: string, score: number): string {
  if (score >= 80) {
    return `${otherType}와 환상의 케미! 서로의 강점이 시너지를 만듭니다`;
  } else if (score >= 60) {
    return `${otherType}와 좋은 관계 가능. 서로의 차이를 인정하면 더 좋아집니다`;
  } else if (score >= 40) {
    return `${otherType}와는 노력이 필요해요. 인내심을 갖고 대화하세요`;
  } else {
    return `${otherType}와는 거리를 두는 게 좋을 수 있어요. 충돌 주의!`;
  }
}

function generateDailyQuests(mbtiType: string, date: Date, energyLevels: any) {
  const seed = date.getTime() + mbtiType.charCodeAt(3);
  const random = (min: number, max: number) => {
    const x = Math.sin(seed) * 10000;
    return Math.floor((x - Math.floor(x)) * (max - min + 1)) + min;
  };

  const [e_i, s_n, t_f, j_p] = mbtiType.split('');
  
  // 퀘스트 풀
  const questPool = {
    challengeQuests: getChallengeQuests(mbtiType),
    growthQuests: getGrowthQuests(mbtiType),
    balanceQuests: getBalanceQuests(e_i, s_n, t_f, j_p),
    socialQuests: getSocialQuests(e_i === 'E', energyLevels.socialBattery),
    relaxQuests: getRelaxQuests(energyLevels.burnoutRisk)
  };

  // 오늘의 퀘스트 선택 (3개)
  const selectedQuests = [];
  
  // 1. 도전 퀘스트 (열등 기능 관련)
  selectedQuests.push({
    type: 'challenge',
    icon: '🎯',
    title: questPool.challengeQuests[random(0, questPool.challengeQuests.length - 1)],
    reward: '성장 포인트 +10',
    difficulty: '어려움'
  });

  // 2. 성장 퀘스트
  selectedQuests.push({
    type: 'growth',
    icon: '🌱',
    title: questPool.growthQuests[random(0, questPool.growthQuests.length - 1)],
    reward: '경험치 +5',
    difficulty: '보통'
  });

  // 3. 밸런스 or 소셜 or 휴식 퀘스트 (컨디션에 따라)
  let thirdQuest;
  if (energyLevels.burnoutRisk === '위험' || energyLevels.burnoutRisk === '주의') {
    thirdQuest = {
      type: 'relax',
      icon: '🧘',
      title: questPool.relaxQuests[random(0, questPool.relaxQuests.length - 1)],
      reward: '에너지 회복 +20',
      difficulty: '쉬움'
    };
  } else if (energyLevels.socialBattery < 30) {
    thirdQuest = {
      type: 'social',
      icon: '👥',
      title: questPool.socialQuests[random(0, questPool.socialQuests.length - 1)],
      reward: '소셜 포인트 +8',
      difficulty: '보통'
    };
  } else {
    thirdQuest = {
      type: 'balance',
      icon: '⚖️',
      title: questPool.balanceQuests[random(0, questPool.balanceQuests.length - 1)],
      reward: '균형 포인트 +7',
      difficulty: '쉬움'
    };
  }
  selectedQuests.push(thirdQuest);

  return {
    quests: selectedQuests,
    completionBonus: '모든 퀘스트 완료 시 특별 인사이트 해금!',
    todaysFocus: getQuestFocus(mbtiType, energyLevels)
  };
}

function getChallengeQuests(mbtiType: string): string[] {
  // 각 MBTI의 열등 기능 관련 도전 과제
  const challenges: { [key: string]: string[] } = {
    'INTJ': ['30분 동안 즉흥적으로 행동하기', '오감을 활용한 활동하기 (요리, 운동 등)', '지금 이 순간에 집중하기'],
    'INTP': ['누군가에게 감사 인사 전하기', '감정 일기 쓰기', '친구와 깊은 대화 나누기'],
    'ENTJ': ['30분 동안 아무 계획 없이 보내기', '예술 작품 감상하기', '자신의 감정 들여다보기'],
    'ENTP': ['루틴한 작업 1시간 집중하기', '과거의 좋은 기억 떠올리기', '디테일한 계획 세우기']
  };
  
  return challenges[mbtiType] || challenges['INTJ'];
}

function getGrowthQuests(mbtiType: string): string[] {
  return [
    '새로운 관점에서 문제 바라보기',
    '오늘의 작은 성취 3가지 기록하기',
    '다른 MBTI 유형의 장점 배우기',
    '평소와 다른 방식으로 일하기',
    '새로운 스킬 15분 연습하기'
  ];
}

function getBalanceQuests(e_i: string, s_n: string, t_f: string, j_p: string): string[] {
  const quests = [];
  
  if (e_i === 'E') {
    quests.push('혼자만의 시간 30분 갖기', '명상 10분하기');
  } else {
    quests.push('누군가와 대화 나누기', '소셜 활동 참여하기');
  }
  
  if (s_n === 'S') {
    quests.push('미래 계획 상상해보기', '추상적인 아이디어 탐구하기');
  } else {
    quests.push('현실적인 목표 하나 세우기', '구체적인 실행 계획 만들기');
  }
  
  return quests;
}

function getSocialQuests(isExtrovert: boolean, socialBattery: number): string[] {
  if (isExtrovert) {
    return [
      '새로운 사람과 대화하기',
      '그룹 활동 참여하기',
      '친구에게 먼저 연락하기',
      'SNS에 일상 공유하기'
    ];
  } else {
    return [
      '친한 친구와 1:1 대화하기',
      '온라인으로 소통하기',
      '짧은 메시지 보내기',
      '소규모 모임 참여하기'
    ];
  }
}

function getRelaxQuests(burnoutRisk: string): string[] {
  return [
    '10분 산책하기',
    '좋아하는 음악 듣기',
    '스트레칭 5분하기',
    '심호흡 10회하기',
    '취미 활동 30분하기',
    '낮잠 20분 자기'
  ];
}

function getQuestFocus(mbtiType: string, energyLevels: any): string {
  if (energyLevels.burnoutRisk === '위험' || energyLevels.burnoutRisk === '주의') {
    return '오늘은 휴식과 회복에 집중하세요';
  }
  
  if (energyLevels.totalEnergy > 70) {
    return '에너지가 충만한 날! 도전적인 과제에 시도해보세요';
  }
  
  if (energyLevels.socialBattery < 30) {
    return '소셜 에너지 충전이 필요한 날입니다';
  }
  
  return '균형잡힌 하루를 보내기 좋은 날이에요';
}

function generateMoodInsights(mbtiType: string, date: Date, biorhythm: number) {
  const seed = date.getTime() + mbtiType.charCodeAt(0) * 2;
  const random = (min: number, max: number) => {
    const x = Math.sin(seed) * 10000;
    return Math.floor((x - Math.floor(x)) * (max - min + 1)) + min;
  };

  const moodScore = 50 + biorhythm * 30 + random(-20, 20);
  const stabilityScore = 60 + random(-20, 20);
  
  // MBTI별 스트레스 시그널
  const stressSignals = getStressSignals(mbtiType);
  const currentStress = random(0, stressSignals.length - 1);
  
  // 회복 처방
  const recoveryMethods = getRecoveryMethods(mbtiType);
  const recommendedRecovery = recoveryMethods[random(0, recoveryMethods.length - 1)];
  
  // 감정 패턴
  const emotionalPattern = {
    morning: 50 + random(-20, 20),
    afternoon: 60 + random(-20, 20),
    evening: 55 + random(-20, 20),
    night: 45 + random(-20, 20)
  };
  
  return {
    currentMood: getMoodLabel(moodScore),
    moodScore: Math.round(moodScore),
    stabilityScore: Math.round(stabilityScore),
    stressSignal: stressSignals[currentStress],
    recoveryMethod: recommendedRecovery,
    emotionalPattern,
    moodAdvice: getMoodAdvice(mbtiType, moodScore),
    triggerWarning: getTriggerWarning(mbtiType)
  };
}

function getStressSignals(mbtiType: string): string[] {
  const signals: { [key: string]: string[] } = {
    'INTJ': ['과도한 완벽주의', '타인에 대한 비판 증가', '고립감'],
    'INTP': ['논리적 오류에 대한 집착', '사회적 철수', '무기력감'],
    'ENTJ': ['과도한 통제욕', '인내심 부족', '타인 무시'],
    'ENTP': ['산만함 증가', '논쟁적 태도', '지루함']
  };
  
  return signals[mbtiType] || ['피로감', '집중력 저하', '감정 기복'];
}

function getRecoveryMethods(mbtiType: string): string[] {
  const [e_i] = mbtiType.split('');
  
  if (e_i === 'E') {
    return [
      '친구와 수다 떨기',
      '새로운 활동 시도하기',
      '사람들과 함께 운동하기',
      '파티나 모임 참여하기'
    ];
  } else {
    return [
      '혼자만의 조용한 시간',
      '독서나 영화 감상',
      '자연 속 산책',
      '창의적인 취미 활동'
    ];
  }
}

function getMoodLabel(score: number): string {
  if (score >= 80) return '최상 😊';
  if (score >= 60) return '좋음 🙂';
  if (score >= 40) return '보통 😐';
  if (score >= 20) return '저조 😔';
  return '주의 필요 😟';
}

function getMoodAdvice(mbtiType: string, moodScore: number): string {
  if (moodScore >= 70) {
    return '기분이 좋은 날! 이 에너지를 생산적인 활동에 활용해보세요';
  } else if (moodScore >= 40) {
    return '평온한 상태입니다. 일상적인 루틴을 유지하세요';
  } else {
    return '에너지가 낮은 상태. 무리하지 말고 충분한 휴식을 취하세요';
  }
}

function getTriggerWarning(mbtiType: string): string {
  const warnings: { [key: string]: string } = {
    'INTJ': '예상치 못한 변화에 주의',
    'INTP': '감정적 대화 상황 주의',
    'ENTJ': '통제 불가능한 상황 주의',
    'ENTP': '반복적인 루틴 작업 주의'
  };
  
  return warnings[mbtiType] || '스트레스 상황 주의';
}

function generateTimeBasedAdvice(mbtiType: string, date: Date, energyLevels: any) {
  const hour = new Date().getHours();
  const patterns = getEnergyPatterns(mbtiType);
  
  let currentPeriod = 'morning';
  let currentAdvice = '';
  
  if (hour >= 6 && hour < 12) {
    currentPeriod = 'morning';
    currentAdvice = getMorningAdvice(mbtiType, patterns.morning);
  } else if (hour >= 12 && hour < 17) {
    currentPeriod = 'afternoon';
    currentAdvice = getAfternoonAdvice(mbtiType, patterns.afternoon);
  } else if (hour >= 17 && hour < 22) {
    currentPeriod = 'evening';
    currentAdvice = getEveningAdvice(mbtiType, patterns.evening);
  } else {
    currentPeriod = 'night';
    currentAdvice = getNightAdvice(mbtiType, patterns.night);
  }
  
  return {
    currentPeriod,
    currentAdvice,
    nextPeriodTip: getNextPeriodTip(currentPeriod, mbtiType),
    todayScheduleSuggestion: getScheduleSuggestion(mbtiType, energyLevels, patterns)
  };
}

function getMorningAdvice(mbtiType: string, energy: number): string {
  if (energy >= 70) {
    return '아침 에너지가 최고! 중요한 업무를 지금 처리하세요';
  } else if (energy >= 50) {
    return '평범한 아침입니다. 가볍게 시작하세요';
  } else {
    return '느린 아침이 필요해요. 충분한 준비 시간을 가지세요';
  }
}

function getAfternoonAdvice(mbtiType: string, energy: number): string {
  if (energy >= 70) {
    return '오후 집중력이 최고조! 창의적인 작업에 도전하세요';
  } else if (energy >= 50) {
    return '안정적인 오후입니다. 루틴 업무에 적합해요';
  } else {
    return '오후 슬럼프 주의! 짧은 휴식을 취하세요';
  }
}

function getEveningAdvice(mbtiType: string, energy: number): string {
  if (energy >= 70) {
    return '저녁 에너지가 충만! 사교 활동이나 취미를 즐기세요';
  } else if (energy >= 50) {
    return '편안한 저녁 시간. 가벼운 활동이 좋습니다';
  } else {
    return '휴식이 필요한 저녁. 일찍 쉬는 것을 고려하세요';
  }
}

function getNightAdvice(mbtiType: string, energy: number): string {
  if (energy >= 70) {
    return '밤에도 에너지가 넘쳐요! 창의적인 활동을 해보세요';
  } else if (energy >= 50) {
    return '적당한 밤 에너지. 내일을 위한 준비를 하세요';
  } else {
    return '충분한 수면이 필요합니다. 일찍 잠자리에 드세요';
  }
}

function getNextPeriodTip(currentPeriod: string, mbtiType: string): string {
  const nextPeriod: { [key: string]: string } = {
    'morning': 'afternoon',
    'afternoon': 'evening',
    'evening': 'night',
    'night': 'morning'
  };
  
  const next = nextPeriod[currentPeriod];
  const patterns = getEnergyPatterns(mbtiType);
  
  if (patterns[next] >= 70) {
    return `다음 시간대(${getKoreanPeriodName(next)})에 에너지가 상승할 예정입니다!`;
  } else if (patterns[next] >= 50) {
    return `다음 시간대(${getKoreanPeriodName(next)})는 평균적인 에너지가 예상됩니다`;
  } else {
    return `다음 시간대(${getKoreanPeriodName(next)})는 휴식이 필요할 수 있어요`;
  }
}

function getKoreanPeriodName(period: string): string {
  const names: { [key: string]: string } = {
    'morning': '오전',
    'afternoon': '오후',
    'evening': '저녁',
    'night': '밤'
  };
  return names[period] || period;
}

function getScheduleSuggestion(mbtiType: string, energyLevels: any, patterns: any): string {
  const suggestions = [];
  
  // 피크 타임 활용
  if (energyLevels.peakTime) {
    suggestions.push(`${energyLevels.peakTime}에 중요한 일정을 배치하세요`);
  }
  
  // 저에너지 시간 대비
  if (energyLevels.lowTime) {
    suggestions.push(`${energyLevels.lowTime}에는 가벼운 업무나 휴식을 계획하세요`);
  }
  
  // 번아웃 위험 관리
  if (energyLevels.burnoutRisk === '위험' || energyLevels.burnoutRisk === '주의') {
    suggestions.push('오늘은 무리하지 말고 충분한 휴식을 포함시키세요');
  }
  
  return suggestions.join('. ');
}

function generateMainMessage(mbtiType: string, energyLevels: any, cognitiveWeather: any): string {
  const messages = [
    `${mbtiType}님, 오늘의 총 에너지는 ${energyLevels.totalEnergy}%입니다.`,
    `${cognitiveWeather.dominantToday} 기능이 활발한 날이에요!`,
    energyLevels.peakTime ? `${energyLevels.peakTime}가 최적의 활동 시간입니다.` : '',
    energyLevels.burnoutRisk === '위험' ? '번아웃 주의! 충분한 휴식이 필요해요.' : ''
  ].filter(msg => msg);
  
  return messages.join(' ');
}

function generateLuckyElements(mbtiType: string, date: Date) {
  const seed = date.getTime() + mbtiType.charCodeAt(0) * 3;
  const random = (min: number, max: number) => {
    const x = Math.sin(seed) * 10000;
    return Math.floor((x - Math.floor(x)) * (max - min + 1)) + min;
  };

  const colors = ['빨강', '파랑', '초록', '노랑', '보라', '주황', '하늘색', '분홍'];
  const numbers = [1, 3, 4, 7, 8, 9, 11, 13, 21, 22];
  const directions = ['동쪽', '서쪽', '남쪽', '북쪽', '남동쪽', '북서쪽'];
  const times = ['새벽', '아침', '점심', '오후', '저녁', '밤'];
  const items = ['펜', '노트', '커피', '음악', '향초', '식물', '책', '시계'];
  
  return {
    color: colors[random(0, colors.length - 1)],
    number: numbers[random(0, numbers.length - 1)],
    direction: directions[random(0, directions.length - 1)],
    time: times[random(0, times.length - 1)],
    item: items[random(0, items.length - 1)]
  };
}