import { NextRequest, NextResponse } from 'next/server';
import { selectGPTModel, callGPTAPI } from '@/config/ai-models';

interface GolfInfo {
  name: string;
  birth_date: string;
  handicap: string;
  playing_experience: string;
  play_frequency: string;
  preferred_courses: string[];
  playing_style: string;
  favorite_clubs: string[];
  golf_goals: string;
  biggest_challenge: string;
  memorable_moment: string;
  playing_partners: string;
}

interface GolfFortune {
  overall_luck: number;
  driving_luck: number;
  iron_luck: number;
  putting_luck: number;
  course_management_luck: number;
  analysis: {
    strength: string;
    weakness: string;
    opportunity: string;
    threat: string;
  };
  lucky_elements: {
    course_type: string;
    tee_time: string;
    weather: string;
    playing_direction: string;
  };
  recommendations: {
    driving_tips: string[];
    approach_tips: string[];
    putting_tips: string[];
    mental_tips: string[];
    equipment_advice: string[];
  };
  future_predictions: {
    this_week: string;
    this_month: string;
    this_season: string;
  };
  lucky_holes: number[];
  course_recommendations: string[];
}

async function analyzeGolfFortune(info: GolfInfo): Promise<GolfFortune> {
  try {
    // GPT 모델 선택 (기본 텍스트 운세)
    const model = selectGPTModel('daily', 'text');
    
    // 전문 골프 운세 프롬프트 생성
    const prompt = `
당신은 골프 전문가이자 운세 상담사입니다. 다음 정보를 바탕으로 골프 운세를 상세히 분석해주세요.

사용자 정보:
- 생년월일: ${info.birth_date}
- 핸디캡: ${info.handicap || '정보 없음'}
- 골프 경험: ${info.playing_experience || '정보 없음'}
- 플레이 빈도: ${info.play_frequency || '정보 없음'}
- 선호 코스: ${info.preferred_courses?.join(', ') || '정보 없음'}
- 플레이 스타일: ${info.playing_style || '정보 없음'}
- 선호 클럽: ${info.favorite_clubs?.join(', ') || '정보 없음'}
- 골프 목표: ${info.golf_goals || '정보 없음'}
- 가장 큰 도전: ${info.biggest_challenge || '정보 없음'}

다음 JSON 형식으로 응답해주세요:
{
  "overall_luck": 85,
  "driving_luck": 78,
  "iron_luck": 82,
  "putting_luck": 75,
  "course_management_luck": 88,
  "analysis": {
    "strength": "골프에서의 주요 강점과 장점",
    "weakness": "주의해야 할 약점이나 개선점",
    "opportunity": "골프를 통해 얻을 수 있는 기회들",
    "threat": "라운딩에서 주의해야 할 도전과제들"
  },
  "lucky_elements": {
    "course_type": "행운의 코스 유형",
    "tee_time": "행운의 티타임",
    "weather": "행운의 날씨",
    "playing_direction": "행운의 플레이 방향"
  },
  "recommendations": {
    "driving_tips": ["구체적인 드라이빙 조언들"],
    "approach_tips": ["어프로치 샷 조언들"],
    "putting_tips": ["퍼팅 조언들"],
    "mental_tips": ["멘탈 관리 조언들"],
    "equipment_advice": ["장비 관련 조언들"]
  },
  "future_predictions": {
    "this_week": "이번 주 골프 운세",
    "this_month": "이번 달 골프 운세",
    "this_season": "이번 시즌 골프 운세"
  }
}
`;

    // GPT API 호출
    const gptResult = await callGPTAPI(prompt, model);
    
    // GPT 응답이 올바른 형식인지 검증 및 변환
    if (gptResult && typeof gptResult === 'object' && 
        typeof gptResult.overall_luck === 'number') {
      console.log('GPT API 호출 성공');
      
      // GPT 응답을 기존 인터페이스 형식으로 변환
      const transformedResult: GolfFortune = {
        overall_luck: gptResult.overall_luck,
        driving_luck: gptResult.driving_luck,
        iron_luck: gptResult.iron_luck,
        putting_luck: gptResult.putting_luck,
        course_management_luck: gptResult.course_management_luck,
        analysis: {
          strength: gptResult.analysis?.strength || '차분하고 집중력이 좋아 안정적인 플레이가 가능합니다',
          weakness: gptResult.analysis?.weakness || '때로는 과도한 완벽주의로 인한 부담감이 있을 수 있습니다',
          opportunity: gptResult.analysis?.opportunity || '꾸준한 연습을 통해 기량 향상의 기회가 있습니다',
          threat: gptResult.analysis?.threat || '컨디션 관리와 멘탈 관리에 주의가 필요합니다'
        },
        lucky_elements: {
          course_type: gptResult.lucky_elements?.course_type || generateLuckyElements(new Date().getDate(), new Date().getMonth() + 1).course_type,
          tee_time: gptResult.lucky_elements?.tee_time || generateLuckyElements(new Date().getDate(), new Date().getMonth() + 1).tee_time,
          weather: gptResult.lucky_elements?.weather || generateLuckyElements(new Date().getDate(), new Date().getMonth() + 1).weather,
          playing_direction: gptResult.lucky_elements?.playing_direction || generateLuckyElements(new Date().getDate(), new Date().getMonth() + 1).playing_direction
        },
        recommendations: {
          driving_tips: gptResult.recommendations?.driving_tips || ['백스윙을 천천히 하여 리듬을 유지하세요'],
          approach_tips: gptResult.recommendations?.approach_tips || ['핀까지의 정확한 거리를 측정하세요'],
          putting_tips: gptResult.recommendations?.putting_tips || ['그린의 경사를 충분히 읽으세요'],
          mental_tips: gptResult.recommendations?.mental_tips || ['각 샷마다 긍정적인 이미지를 그리세요'],
          equipment_advice: gptResult.recommendations?.equipment_advice || ['자신의 스윙 속도에 맞는 샤프트를 선택하세요']
        },
        future_predictions: {
          this_week: gptResult.future_predictions?.this_week || '이번 주는 드라이빙 거리가 늘어날 수 있는 좋은 시기입니다',
          this_month: gptResult.future_predictions?.this_month || '이번 달은 퍼팅 감각이 좋아질 것으로 예상됩니다',
          this_season: gptResult.future_predictions?.this_season || '이번 시즌은 전반적인 스코어 향상이 기대됩니다'
        },
        lucky_holes: generateLuckyHoles(new Date().getDate(), new Date().getMonth() + 1),
        course_recommendations: generateCourseRecommendations(gptResult.overall_luck)
      };
      
      return transformedResult;
    } else {
      throw new Error('GPT 응답 형식 오류');
    }
    
  } catch (error) {
    console.error('GPT API 호출 실패, 백업 로직 사용:', error);
    
    // 백업 로직: 개선된 개인화 알고리즘
    return generatePersonalizedGolfFortune(info);
  }
}

function generatePersonalizedGolfFortune(info: GolfInfo): GolfFortune {
  // 생년월일 기반 개인화 점수 계산
  const birthYear = info.birth_date ? parseInt(info.birth_date.substring(0, 4)) : new Date().getFullYear() - 30;
  const birthMonth = info.birth_date ? parseInt(info.birth_date.substring(5, 7)) : 6;
  const birthDay = info.birth_date ? parseInt(info.birth_date.substring(8, 10)) : 15;
  
  // 기본 점수 계산 (생년월일 기반)
  let baseScore = ((birthYear + birthMonth + birthDay) % 25) + 65;
  
  // 핸디캡별 보너스 (낮을수록 실력이 좋음)
  const handicapNum = parseFloat(info.handicap) || 20;
  if (handicapNum <= 5) baseScore += 15;
  else if (handicapNum <= 10) baseScore += 10;
  else if (handicapNum <= 15) baseScore += 5;
  else if (handicapNum <= 20) baseScore += 2;
  
  // 경험별 보너스
  if (info.playing_experience.includes('10년 이상')) baseScore += 12;
  else if (info.playing_experience.includes('5-10년')) baseScore += 8;
  else if (info.playing_experience.includes('3-5년')) baseScore += 5;
  else if (info.playing_experience.includes('1-3년')) baseScore += 2;
  
  // 플레이 빈도별 보너스
  if (info.play_frequency.includes('주 3회 이상')) baseScore += 10;
  else if (info.play_frequency.includes('주 1-2회')) baseScore += 7;
  else if (info.play_frequency.includes('월 2-3회')) baseScore += 4;
  
  // 선호 코스 다양성 보너스
  if (info.preferred_courses && info.preferred_courses.length >= 3) baseScore += 8;
  else if (info.preferred_courses && info.preferred_courses.length >= 2) baseScore += 4;
  
  // 클럽 다양성 보너스
  if (info.favorite_clubs && info.favorite_clubs.length >= 4) baseScore += 6;
  else if (info.favorite_clubs && info.favorite_clubs.length >= 2) baseScore += 3;
  
  // 최종 점수 범위 조정
  baseScore = Math.max(50, Math.min(95, baseScore));
  
  return {
    overall_luck: baseScore,
    driving_luck: calculateDrivingLuck(baseScore, info),
    iron_luck: calculateIronLuck(baseScore, info),
    putting_luck: calculatePuttingLuck(baseScore, info),
    course_management_luck: calculateCourseManagementLuck(baseScore, info),
    analysis: generateAnalysis(baseScore, info),
    lucky_elements: generateLuckyElements(birthDay, birthMonth),
    recommendations: generateRecommendations(info),
    future_predictions: generateFuturePredictions(baseScore, info),
    lucky_holes: generateLuckyHoles(birthDay, birthMonth),
    course_recommendations: generateCourseRecommendations(baseScore)
  };
}

function calculateDrivingLuck(baseScore: number, info: GolfInfo): number {
  let score = baseScore + 3; // 드라이빙은 기본적으로 조금 높게
  
  // 파워형 플레이어는 드라이빙 유리
  if (info.playing_style?.includes('파워') || info.playing_style?.includes('장타')) score += 10;
  
  // 드라이버가 선호 클럽이면 보너스
  if (info.favorite_clubs?.includes('드라이버')) score += 8;
  
  return Math.max(45, Math.min(100, score));
}

function calculateIronLuck(baseScore: number, info: GolfInfo): number {
  let score = baseScore;
  
  // 정확성 플레이어는 아이언 유리
  if (info.playing_style?.includes('정확') || info.playing_style?.includes('안정')) score += 10;
  
  // 아이언이 선호 클럽이면 보너스
  if (info.favorite_clubs?.includes('아이언')) score += 8;
  
  return Math.max(40, Math.min(95, score));
}

function calculatePuttingLuck(baseScore: number, info: GolfInfo): number {
  let score = baseScore + 2; // 퍼팅은 기본적으로 조금 높게
  
  // 퍼터가 선호 클럽이면 보너스
  if (info.favorite_clubs?.includes('퍼터')) score += 12;
  
  // 숏게임 플레이어는 퍼팅 유리
  if (info.playing_style?.includes('숏게임') || info.playing_style?.includes('정밀')) score += 10;
  
  return Math.max(50, Math.min(100, score));
}

function calculateCourseManagementLuck(baseScore: number, info: GolfInfo): number {
  let score = baseScore;
  
  // 경험이 많을수록 코스 매니지먼트 유리
  if (info.playing_experience.includes('10년 이상')) score += 12;
  else if (info.playing_experience.includes('5-10년')) score += 8;
  
  // 전략적 플레이어는 코스 매니지먼트 유리
  if (info.playing_style?.includes('전략') || info.playing_style?.includes('안정')) score += 10;
  
  return Math.max(55, Math.min(95, score));
}

function generateAnalysis(baseScore: number, info: GolfInfo) {
  const analysisOptions = {
    strength: [
      "차분하고 집중력이 좋아 어려운 상황에서도 안정적인 플레이를 할 수 있습니다.",
      "뛰어난 거리 감각과 파워로 롱홀에서 유리한 위치를 만들 수 있습니다.",
      "정확한 아이언 샷과 어프로치로 핀 근처에 볼을 붙이는 능력이 뛰어납니다.",
      "훌륭한 퍼팅 감각으로 중요한 순간에 버디를 잡을 수 있는 능력이 있습니다."
    ],
    weakness: [
      "가끔 과도한 완벽주의로 인해 긴장하여 실수할 수 있으니 여유로운 마음가짐이 필요합니다.",
      "비거리에 대한 욕심으로 스윙이 커질 때가 있어 정확성이 떨어질 수 있습니다.",
      "어려운 상황에서 무리한 샷을 시도하려는 경향이 있으니 안전한 플레이가 필요합니다.",
      "컨디션에 따른 기복이 있을 수 있으니 일관된 루틴 유지가 중요합니다."
    ],
    opportunity: [
      "꾸준한 연습과 경험으로 비거리와 정확성을 동시에 향상시킬 수 있는 시기입니다.",
      "새로운 기술이나 장비를 도입하여 약점을 보완할 수 있는 좋은 기회입니다.",
      "좋은 골프 파트너나 프로와의 만남으로 실력 향상의 기회가 열려있습니다.",
      "체계적인 연습 계획을 통해 단기간에 큰 발전을 이룰 수 있는 시기입니다."
    ],
    threat: [
      "날씨나 코스 컨디션에 민감하게 반응할 수 있으니 다양한 상황에 대한 준비가 필요합니다.",
      "과도한 연습으로 인한 부상 위험이 있으니 적절한 휴식과 스트레칭이 필요합니다.",
      "스코어에 대한 부담감으로 실력 발휘에 어려움이 있을 수 있으니 즐기는 마음이 중요합니다.",
      "기술적 한계를 극복하기 위해서는 전문가의 도움이 필요할 수 있습니다."
    ]
  };
  
  const strengthIndex = Math.abs(baseScore) % analysisOptions.strength.length;
  const weaknessIndex = Math.abs(baseScore + 1) % analysisOptions.weakness.length;
  const opportunityIndex = Math.abs(baseScore + 2) % analysisOptions.opportunity.length;
  const threatIndex = Math.abs(baseScore + 3) % analysisOptions.threat.length;
  
  return {
    strength: analysisOptions.strength[strengthIndex],
    weakness: analysisOptions.weakness[weaknessIndex],
    opportunity: analysisOptions.opportunity[opportunityIndex],
    threat: analysisOptions.threat[threatIndex]
  };
}

function generateLuckyElements(birthDay: number, birthMonth: number) {
  const courseTypes = ["파크랜드", "링크스", "마운틴", "리조트", "퍼블릭", "멤버십"];
  const teeTimes = ["오전 7-9시", "오전 10-12시", "오후 1-3시", "오후 4-6시"];
  const weathers = ["맑음", "구름 조금", "살짝 바람"];
  const directions = ["북쪽", "동쪽", "남쪽", "서쪽"];
  
  return {
    course_type: courseTypes[birthMonth % courseTypes.length],
    tee_time: teeTimes[birthDay % teeTimes.length],
    weather: weathers[(birthDay + birthMonth) % weathers.length],
    playing_direction: directions[birthMonth % directions.length]
  };
}

function generateRecommendations(info: GolfInfo) {
  return {
    driving_tips: [
      info.playing_style?.includes('파워') ?
        "파워를 유지하면서도 정확성에 더 집중하세요" :
        "백스윙을 천천히 하여 리듬을 유지하세요",
      "몸의 중심을 안정적으로 유지하세요",
      "임팩트 순간 헤드업을 피하세요",
      "팔로우 스루를 완전히 마무리하세요",
      info.handicap && parseFloat(info.handicap) > 15 ?
        "정확성을 우선으로 하여 페어웨이 킵에 집중하세요" :
        "자신의 비거리에 맞는 클럽을 선택하세요"
    ],
    approach_tips: [
      "핀까지의 정확한 거리를 측정하세요",
      "그린의 경사와 바람을 고려하세요",
      info.playing_style?.includes('안정') ?
        "안전한 플레이를 유지하되 공격적인 샷도 시도해보세요" :
        "여유있는 클럽으로 안전하게 플레이하세요",
      "그린 중앙을 노리는 것이 안전합니다",
      "볼의 라이를 정확히 판단하세요"
    ],
    putting_tips: [
      "그린의 경사를 충분히 읽으세요",
      "일정한 템포로 퍼팅하세요",
      "볼이 굴러가는 라인을 시각화하세요",
      info.favorite_clubs?.includes('퍼터') ?
        "자신감을 가지고 공격적인 퍼팅을 시도하세요" :
        "숏퍼팅에서는 확신을 가지고 치세요",
      "롱퍼팅에서는 거리 감각에 집중하세요"
    ],
    mental_tips: [
      "각 샷마다 긍정적인 이미지를 그리세요",
      "실수를 했을 때 빨리 잊고 다음 샷에 집중하세요",
      "자신만의 루틴을 만들어 일관성을 유지하세요",
      info.golf_goals ?
        "목표를 명확히 하되 과도한 압박은 피하세요" :
        "과도한 욕심보다는 현실적인 목표를 설정하세요",
      "라운딩을 즐기는 마음가짐을 가지세요"
    ],
    equipment_advice: [
      "자신의 스윙 속도에 맞는 샤프트를 선택하세요",
      "정기적으로 클럽 그립을 점검하고 교체하세요",
      info.handicap && parseFloat(info.handicap) > 15 ?
        "관용성이 높은 클럽을 선택하는 것이 좋습니다" :
        "볼의 압축도를 고려하여 선택하세요",
      "날씨에 맞는 골프웨어를 착용하세요",
      "골프화 스파이크를 주기적으로 확인하세요"
    ]
  };
}

function generateFuturePredictions(baseScore: number, info: GolfInfo) {
  const predictions = {
    week: [
      "드라이빙 거리가 늘어날 수 있는 좋은 시기입니다. 기본기 연습에 집중하세요.",
      "아이언 샷의 정확도가 향상될 것으로 예상됩니다. 어프로치 연습을 늘려보세요.",
      "새로운 기술을 습득하기 좋은 시기입니다. 프로 레슨을 받아보는 것도 좋겠습니다.",
      "컨디션이 좋아 라운딩 성과가 기대되는 시기입니다."
    ],
    month: [
      "퍼팅 감각이 좋아질 것으로 예상됩니다. 숏게임 연습을 늘려보세요.",
      "코스 매니지먼트 능력이 향상되는 시기입니다. 다양한 코스에 도전해보세요.",
      "드라이빙 정확도가 개선되어 스코어 향상이 기대됩니다.",
      "멘탈이 강해져 중요한 라운드에서 좋은 성과를 낼 수 있을 것입니다."
    ],
    season: [
      "전반적인 스코어 향상이 기대되는 시즌입니다. 꾸준한 라운딩으로 경험을 쌓으세요.",
      "새로운 도전을 통해 큰 발전을 이룰 수 있는 시즌입니다.",
      "골프에 대한 이해도가 깊어져 더욱 즐겁게 플레이할 수 있을 것입니다.",
      "목표 달성에 가까워지는 의미있는 시즌이 될 것입니다."
    ]
  };
  
  const weekIndex = baseScore % predictions.week.length;
  const monthIndex = (baseScore + 1) % predictions.month.length;
  const seasonIndex = (baseScore + 2) % predictions.season.length;
  
  return {
    this_week: predictions.week[weekIndex],
    this_month: predictions.month[monthIndex],
    this_season: predictions.season[seasonIndex]
  };
}

function generateLuckyHoles(birthDay: number, birthMonth: number): number[] {
  const holes = [];
  for (let i = 0; i < 3; i++) {
    holes.push(((birthDay + birthMonth + i * 3) % 18) + 1);
  }
  return holes;
}

function generateCourseRecommendations(baseScore: number): string[] {
  const koreanCourses = [
    "남서울CC", "부산CC", "용평리조트GC", "제주샤인빌GC", "레이크사이드CC",
    "뉴서울CC", "잭니클라우스GC", "라데나GC", "화순CC", "해슬래CC"
  ];
  
  const recommendations = [];
  for (let i = 0; i < 3; i++) {
    const index = (baseScore + i * 7) % koreanCourses.length;
    recommendations.push(koreanCourses[index]);
  }
  
  return recommendations;
}

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body = await request.json();
    
    // 입력 검증
    if (!body.name || !body.birth_date || !body.playing_style) {
      return NextResponse.json(
        { error: '필수 정보가 누락되었습니다.' },
        { status: 400 }
      );
    }
    
    const golfFortune = await analyzeGolfFortune(body as GolfInfo);
    
    return NextResponse.json(golfFortune);
  } catch (error) {
    console.error('골프 운세 분석 오류:', error);
    return createSafeErrorResponse(error, '운세 분석 중 오류가 발생했습니다.');
  }
});
