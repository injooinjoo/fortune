import { NextRequest, NextResponse } from 'next/server';
import { selectGPTModel, callGPTAPI } from '@/config/ai-models';

interface BaseballInfo {
  name: string;
  birth_date: string;
  favorite_team: string;
  favorite_position: string;
  playing_experience: string;
  game_frequency: string;
  baseball_knowledge: string[];
  lucky_number: string;
  current_goal: string;
  special_memory: string;
}

interface BaseballFortune {
  overall_luck: number;
  batting_luck: number;
  pitching_luck: number;
  fielding_luck: number;
  team_luck: number;
  analysis: {
    strength: string;
    weakness: string;
    opportunity: string;
    challenge: string;
  };
  lucky_position: string;
  lucky_uniform_number: number;
  lucky_game_time: string;
  lucky_stadium: string;
  recommendations: {
    training_tips: string[];
    game_strategies: string[];
    team_building: string[];
    mental_preparation: string[];
  };
  future_predictions: {
    this_week: string;
    this_month: string;
    this_season: string;
  };
  compatibility: {
    best_teammate_type: string;
    ideal_coach_style: string;
    perfect_opponent: string;
  };
}

async function analyzeBaseballFortune(info: BaseballInfo): Promise<BaseballFortune> {
  try {
    // GPT 모델 선택 (기본 텍스트 운세)
    const model = selectGPTModel('daily', 'text');
    
    // 전문 야구 운세 프롬프트 생성
    const prompt = `
당신은 야구 전문가이자 운세 상담사입니다. 다음 정보를 바탕으로 야구 운세를 상세히 분석해주세요.

사용자 정보:
- 생년월일: ${info.birth_date}
- 선호 팀: ${info.favorite_team || '정보 없음'}
- 선호 포지션: ${info.favorite_position || '정보 없음'}
- 야구 경험: ${info.playing_experience || '정보 없음'}
- 경기 빈도: ${info.game_frequency || '정보 없음'}
- 야구 지식: ${info.baseball_knowledge?.join(', ') || '정보 없음'}
- 행운 번호: ${info.lucky_number || '정보 없음'}
- 현재 목표: ${info.current_goal || '정보 없음'}

다음 JSON 형식으로 응답해주세요:
{
  "overall_luck": 85,
  "batting_luck": 78,
  "pitching_luck": 82,
  "fielding_luck": 75,
  "team_luck": 88,
  "analysis": {
    "strength": "야구에서의 주요 강점과 장점",
    "weakness": "주의해야 할 약점이나 개선점", 
    "opportunity": "야구를 통해 얻을 수 있는 기회들",
    "challenge": "경기에서 주의해야 할 도전과제들"
  },
  "lucky_elements": {
    "position": "행운의 포지션",
    "number": "행운의 등번호",
    "game_time": "행운의 경기 시간",
    "stadium": "행운의 구장"
  },
  "recommendations": {
    "training_tips": ["구체적인 훈련 포인트들"],
    "game_strategies": ["경기 전략 조언들"],
    "team_building": ["팀빌딩 조언들"],
    "mental_preparation": ["멘탈 준비법들"]
  },
  "future_predictions": {
    "this_week": "이번 주 야구 운세",
    "this_month": "이번 달 야구 운세",
    "this_season": "이번 시즌 운세"
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
      const transformedResult: BaseballFortune = {
        overall_luck: gptResult.overall_luck,
        batting_luck: gptResult.batting_luck,
        pitching_luck: gptResult.pitching_luck,
        fielding_luck: gptResult.fielding_luck,
        team_luck: gptResult.team_luck,
        analysis: {
          strength: gptResult.analysis?.strength || '강한 정신력과 끈기를 바탕으로 한 안정적인 플레이',
          weakness: gptResult.analysis?.weakness || '때로는 과도한 완벽주의로 인한 부담감',
          opportunity: gptResult.analysis?.opportunity || '지속적인 연습을 통한 기량 향상 기회',
          challenge: gptResult.analysis?.challenge || '새로운 기술 습득에 대한 도전'
        },
        lucky_position: gptResult.lucky_elements?.position || generateLuckyPosition(new Date().getMonth() + 1),
        lucky_uniform_number: parseInt(gptResult.lucky_elements?.number) || generateLuckyNumber(new Date().getDate(), info.lucky_number),
        lucky_game_time: gptResult.lucky_elements?.game_time || generateLuckyGameTime(new Date().getDate()),
        lucky_stadium: gptResult.lucky_elements?.stadium || generateLuckyStadium(gptResult.overall_luck),
        recommendations: {
          training_tips: gptResult.recommendations?.training_tips || ['기본기 강화에 집중하세요'],
          game_strategies: gptResult.recommendations?.game_strategies || ['상대방의 약점을 파악하여 공략하세요'],
          team_building: gptResult.recommendations?.team_building || ['팀원들과의 소통을 늘리세요'],
          mental_preparation: gptResult.recommendations?.mental_preparation || ['경기 전 충분한 준비운동을 하세요']
        },
        future_predictions: {
          this_week: gptResult.future_predictions?.this_week || '이번 주는 기량 향상에 좋은 시기입니다',
          this_month: gptResult.future_predictions?.this_month || '이번 달은 새로운 도전에 적극적으로 임하세요',
          this_season: gptResult.future_predictions?.this_season || '이번 시즌은 전반적으로 좋은 성과가 기대됩니다'
        },
        compatibility: generateCompatibility(info)
      };
      
      return transformedResult;
    } else {
      throw new Error('GPT 응답 형식 오류');
    }
    
  } catch (error) {
    console.error('GPT API 호출 실패, 백업 로직 사용:', error);
    
    // 백업 로직: 개선된 개인화 알고리즘
    return generatePersonalizedBaseballFortune(info);
  }
}

function generatePersonalizedBaseballFortune(info: BaseballInfo): BaseballFortune {
  // 생년월일 기반 개인화 점수 계산
  const birthYear = info.birth_date ? parseInt(info.birth_date.substring(0, 4)) : new Date().getFullYear() - 25;
  const birthMonth = info.birth_date ? parseInt(info.birth_date.substring(5, 7)) : 6;
  const birthDay = info.birth_date ? parseInt(info.birth_date.substring(8, 10)) : 15;
  
  // 기본 점수 계산 (생년월일 기반)
  let baseScore = ((birthYear + birthMonth + birthDay) % 25) + 65;
  
  // 경험별 보너스
  if (info.playing_experience.includes('10년 이상')) baseScore += 15;
  else if (info.playing_experience.includes('5-10년')) baseScore += 10;
  else if (info.playing_experience.includes('3-5년')) baseScore += 5;
  else if (info.playing_experience.includes('1-3년')) baseScore += 2;
  
  // 경기 빈도별 보너스
  if (info.game_frequency.includes('주 3회 이상')) baseScore += 12;
  else if (info.game_frequency.includes('주 1-2회')) baseScore += 8;
  else if (info.game_frequency.includes('월 2-3회')) baseScore += 5;
  
  // 야구 지식 다양성 보너스
  if (info.baseball_knowledge && info.baseball_knowledge.length >= 6) baseScore += 10;
  else if (info.baseball_knowledge && info.baseball_knowledge.length >= 4) baseScore += 6;
  else if (info.baseball_knowledge && info.baseball_knowledge.length >= 2) baseScore += 3;
  
  // 포지션별 특성 보너스
  const positionBonus: Record<string, number> = {
    '투수': 8,
    '포수': 12, // 게임의 지휘자 역할
    '1루수': 6,
    '2루수': 7,
    '3루수': 8,
    '유격수': 10, // 많은 플레이에 관여
    '좌익수': 5,
    '중견수': 9, // 넓은 수비 범위
    '우익수': 6
  };
  
  if (info.favorite_position && positionBonus[info.favorite_position]) {
    baseScore += positionBonus[info.favorite_position];
  }
  
  // 최종 점수 범위 조정
  baseScore = Math.max(50, Math.min(95, baseScore));
  
  return {
    overall_luck: baseScore,
    batting_luck: calculateBattingLuck(baseScore, info),
    pitching_luck: calculatePitchingLuck(baseScore, info),
    fielding_luck: calculateFieldingLuck(baseScore, info),
    team_luck: calculateTeamLuck(baseScore, info),
    analysis: generateAnalysis(baseScore, info),
    lucky_position: generateLuckyPosition(birthMonth),
    lucky_uniform_number: generateLuckyNumber(birthDay, info.lucky_number),
    lucky_game_time: generateLuckyGameTime(birthDay),
    lucky_stadium: generateLuckyStadium(baseScore),
    recommendations: generateRecommendations(info),
    future_predictions: generateFuturePredictions(baseScore, info),
    compatibility: generateCompatibility(info)
  };
}

function calculateBattingLuck(baseScore: number, info: BaseballInfo): number {
  let score = baseScore + 2;
  
  if (info.favorite_position && !info.favorite_position.includes('투수')) score += 8;
  if (info.baseball_knowledge?.includes('타격 이론')) score += 10;
  if (info.baseball_knowledge?.includes('주루 플레이')) score += 5;
  
  return Math.max(45, Math.min(100, score));
}

function calculatePitchingLuck(baseScore: number, info: BaseballInfo): number {
  let score = baseScore;
  
  if (info.favorite_position?.includes('투수')) score += 15;
  if (info.baseball_knowledge?.includes('투구 이론')) score += 12;
  if (info.baseball_knowledge?.includes('구종별 특성')) score += 8;
  
  return Math.max(40, Math.min(95, score));
}

function calculateFieldingLuck(baseScore: number, info: BaseballInfo): number {
  let score = baseScore + 3;
  
  const fieldingPositions = ['포수', '유격수', '중견수', '3루수'];
  if (info.favorite_position && fieldingPositions.includes(info.favorite_position)) {
    score += 10;
  }
  
  if (info.baseball_knowledge?.includes('수비 전술')) score += 10;
  if (info.baseball_knowledge?.includes('포지션별 역할')) score += 6;
  
  return Math.max(50, Math.min(100, score));
}

function calculateTeamLuck(baseScore: number, info: BaseballInfo): number {
  let score = baseScore + 1;
  
  if (info.baseball_knowledge?.includes('팀워크')) score += 12;
  if (info.baseball_knowledge?.includes('리더십')) score += 8;
  
  if (info.playing_experience.includes('10년 이상')) score += 10;
  else if (info.playing_experience.includes('5-10년')) score += 6;
  
  return Math.max(55, Math.min(95, score));
}

function generateAnalysis(baseScore: number, info: BaseballInfo) {
  const analysisOptions = {
    strength: [
      "강한 정신력과 끈기를 바탕으로 어려운 상황에서도 포기하지 않는 투지를 가지고 있습니다.",
      "뛰어난 집중력과 상황 판단력으로 중요한 순간에 최적의 플레이를 선택할 수 있습니다.",
      "팀워크를 중시하는 성향으로 동료들과 좋은 호흡을 맞추며 시너지를 만들어냅니다.",
      "꾸준한 연습과 노력으로 기본기가 탄탄하여 안정적인 경기력을 보여줍니다."
    ],
    weakness: [
      "때로는 완벽을 추구하다가 과도한 스트레스를 받을 수 있으니 적당한 휴식이 필요합니다.",
      "승부욕이 강해 감정적으로 플레이할 때가 있어 냉정함을 유지하는 것이 중요합니다.",
      "새로운 기술을 습득하는데 시간이 걸릴 수 있지만 인내심을 가지고 연습하면 극복됩니다.",
      "압박감이 클 때 실력 발휘에 어려움이 있을 수 있으니 멘탈 관리가 필요합니다."
    ],
    opportunity: [
      "체계적인 훈련과 분석을 통해 약점을 보완하고 강점을 더욱 발전시킬 수 있는 시기입니다.",
      "좋은 코치나 선배와의 만남으로 기술적, 정신적 성장의 기회가 열려있습니다.",
      "팀 내에서 리더십을 발휘할 기회가 많아져 개인과 팀 모두 발전할 수 있습니다.",
      "새로운 전술이나 기법을 배워 플레이의 다양성을 높일 수 있는 좋은 시기입니다."
    ],
    challenge: [
      "강한 상대와의 경기에서 위축되지 않고 자신의 실력을 발휘하는 것이 과제입니다.",
      "부상 위험이 있으니 충분한 준비운동과 컨디션 관리에 신경써야 합니다.",
      "기술적 한계를 극복하기 위해서는 꾸준한 노력과 전문가의 조언이 필요합니다.",
      "팀 내 경쟁에서 살아남기 위해 지속적인 자기 개발이 요구됩니다."
    ]
  };
  
  const strengthIndex = Math.abs(baseScore) % analysisOptions.strength.length;
  const weaknessIndex = Math.abs(baseScore + 1) % analysisOptions.weakness.length;
  const opportunityIndex = Math.abs(baseScore + 2) % analysisOptions.opportunity.length;
  const challengeIndex = Math.abs(baseScore + 3) % analysisOptions.challenge.length;
  
  return {
    strength: analysisOptions.strength[strengthIndex],
    weakness: analysisOptions.weakness[weaknessIndex],
    opportunity: analysisOptions.opportunity[opportunityIndex],
    challenge: analysisOptions.challenge[challengeIndex]
  };
}

function generateLuckyPosition(birthMonth: number): string {
  const positions = [
    "투수", "포수", "1루수", "2루수", "3루수", "유격수", "좌익수", "중견수", "우익수"
  ];
  const index = birthMonth % positions.length;
  return positions[index];
}

function generateLuckyNumber(birthDay: number, luckyNumber: string): number {
  if (luckyNumber && parseInt(luckyNumber) >= 1 && parseInt(luckyNumber) <= 99) {
    return parseInt(luckyNumber);
  }
  return (birthDay % 99) + 1;
}

function generateLuckyGameTime(birthDay: number): string {
  const times = ["오후 2시", "오후 6시", "오후 7시"];
  const index = birthDay % times.length;
  return times[index];
}

function generateLuckyStadium(baseScore: number): string {
  const stadiums = [
    "잠실야구장", "고척스카이돔", "창원NC파크", "사직야구장", 
    "대구삼성라이온즈파크", "인천SSG랜더스필드", "수원KT위즈파크", 
    "광주기아챔피언스필드", "대전한화생명이글스파크", "문학야구장"
  ];
  const index = baseScore % stadiums.length;
  return stadiums[index];
}

function generateRecommendations(info: BaseballInfo) {
  return {
    training_tips: [
      info.baseball_knowledge?.includes('기본기') ?
        "기본기를 더욱 정교하게 다듬어 완성도를 높이세요" :
        "매일 기본기 연습에 30분 이상 투자하세요",
      "몸의 유연성을 위해 스트레칭을 꾸준히 하세요",
      info.favorite_position?.includes('투수') ?
        "투구 폼의 일관성을 위해 반복 연습하세요" :
        "정확한 폼을 익히기 위해 천천히 연습하세요",
      "체력 관리를 위한 유산소 운동을 병행하세요",
      "부상 예방을 위해 충분한 워밍업을 하세요"
    ],
    game_strategies: [
      "상대방의 패턴을 관찰하고 분석하세요",
      info.favorite_position?.includes('포수') ?
        "게임을 읽고 투수를 잘 리드하는 능력을 기르세요" :
        "자신의 강점을 최대한 활용하는 전략을 세우세요",
      "팀원들과의 소통을 자주하여 호흡을 맞추세요",
      "경기 상황에 따라 유연하게 대응하세요",
      info.baseball_knowledge?.includes('전술 이해') ?
        "다양한 전술을 상황에 맞게 활용하세요" :
        "실수를 두려워하지 말고 적극적으로 플레이하세요"
    ],
    team_building: [
      "팀원들과 함께하는 식사 시간을 가져보세요",
      "서로의 강점을 칭찬하고 인정해주세요",
      info.baseball_knowledge?.includes('리더십') ?
        "팀의 분위기를 이끌어가는 역할을 해보세요" :
        "어려운 상황에서 서로를 격려해주세요",
      "팀의 목표를 함께 설정하고 공유하세요",
      "경기 후에는 함께 경기를 되돌아보세요"
    ],
    mental_preparation: [
      "경기 전 긍정적인 이미지 트레이닝을 하세요",
      "심호흡을 통해 마음을 안정시키세요",
      info.current_goal ?
        "목표를 명확히 하고 한 단계씩 달성해나가세요" :
        "실패를 두려워하지 말고 도전하세요",
      "집중력 향상을 위한 명상을 해보세요",
      "자신만의 루틴을 만들어 심리적 안정감을 가지세요"
    ]
  };
}

function generateFuturePredictions(baseScore: number, info: BaseballInfo) {
  const predictions = {
    week: [
      "새로운 기술을 배우기에 좋은 시기입니다. 기본기에 충실하면 큰 발전을 이룰 수 있습니다.",
      "컨디션이 좋아져 평소보다 향상된 경기력을 보일 수 있는 시기입니다.",
      "팀워크에 집중하기 좋은 시기입니다. 동료들과의 호흡을 맞추는데 집중하세요.",
      "멘탈 관리가 중요한 시기입니다. 긍정적인 마인드로 경기에 임하세요."
    ],
    month: [
      "기술적 발전이 눈에 띄는 시기입니다. 꾸준한 연습의 결과가 나타날 것입니다.",
      "새로운 도전을 시도하기 좋은 시기입니다. 더 높은 목표를 설정해보세요.",
      "팀 내에서 중요한 역할을 맡게 될 가능성이 높은 시기입니다.",
      "경기 감각이 예리해져 좋은 성과를 낼 수 있는 시기입니다."
    ],
    season: [
      "꾸준한 노력이 결실을 맺는 시기입니다. 포기하지 않고 계속 도전하면 목표를 달성할 수 있습니다.",
      "큰 변화와 성장이 기다리는 시기입니다. 새로운 환경에서도 잘 적응할 수 있을 것입니다.",
      "리더십을 발휘할 기회가 많은 시기입니다. 팀을 이끌어가는 역할에 도전해보세요.",
      "자신만의 플레이 스타일이 완성되는 의미있는 시기가 될 것입니다."
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

function generateCompatibility(info: BaseballInfo) {
  const compatibilityOptions = {
    teammate: [
      "긍정적이고 서로를 격려해주는 동료",
      "열정적이고 경쟁심이 강한 동료",
      "차분하고 분석적인 사고를 가진 동료",
      "경험이 풍부하고 조언을 잘 해주는 동료"
    ],
    coach: [
      "체계적이면서도 선수 개인을 배려하는 코치",
      "열정적이고 동기부여를 잘 해주는 코치",
      "기술적 세부사항에 집중하는 전문적인 코치",
      "멘탈 관리와 전술에 강한 코치"
    ],
    opponent: [
      "실력이 비슷하면서 페어플레이를 중시하는 상대",
      "강한 실력으로 자극을 주는 상대",
      "다양한 기술을 구사하여 배울 점이 많은 상대",
      "치열한 경쟁을 통해 서로 발전시켜주는 상대"
    ]
  };
  
  let teammateIndex = 0;
  let coachIndex = 0;
  let opponentIndex = 0;
  
  if (info.favorite_position?.includes('투수')) {
    teammateIndex = 2;
    coachIndex = 2;
  } else if (info.favorite_position?.includes('포수')) {
    teammateIndex = 3;
    coachIndex = 3;
  } else {
    teammateIndex = 0;
    coachIndex = 0;
  }
  
  if (info.playing_experience?.includes('10년 이상')) {
    opponentIndex = 3;
  } else if (info.playing_experience?.includes('5-10년')) {
    opponentIndex = 2;
  } else {
    opponentIndex = 0;
  }
  
  return {
    best_teammate_type: compatibilityOptions.teammate[teammateIndex],
    ideal_coach_style: compatibilityOptions.coach[coachIndex],
    perfect_opponent: compatibilityOptions.opponent[opponentIndex]
  };
}

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body = await request.json();
    
    if (!body.name || !body.birth_date || !body.favorite_position) {
      return NextResponse.json(
        { error: '필수 정보가 누락되었습니다.' },
        { status: 400 }
      );
    }
    
    const baseballFortune = await analyzeBaseballFortune(body as BaseballInfo);
    
    return NextResponse.json(baseballFortune);
  } catch (error) {
    console.error('야구 운세 분석 오류:', error);
    return createSafeErrorResponse(error, '운세 분석 중 오류가 발생했습니다.');
  }
});
