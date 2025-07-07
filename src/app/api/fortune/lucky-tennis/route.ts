import { NextRequest, NextResponse } from 'next/server';
import { selectGPTModel, callGPTAPI, PROMPT_TEMPLATES } from '@/config/ai-models';

interface TennisInfo {
  name: string;
  birth_date: string;
  dominant_hand: string;
  playing_style: string;
  favorite_surface: string;
  playing_experience: string;
  game_frequency: string;
  tennis_skills: string[];
  lucky_number: string;
  current_goal: string;
  special_memory: string;
}

interface TennisFortune {
  overall_luck: number;
  serve_luck: number;
  return_luck: number;
  volley_luck: number;
  mental_luck: number;
  analysis: {
    strength: string;
    weakness: string;
    opportunity: string;
    challenge: string;
  };
  lucky_racket_tension: string;
  lucky_court_position: string;
  lucky_match_time: string;
  lucky_tournament: string;
  recommendations: {
    training_tips: string[];
    match_strategies: string[];
    equipment_advice: string[];
    mental_preparation: string[];
  };
  future_predictions: {
    this_week: string;
    this_month: string;
    this_season: string;
  };
  compatibility: {
    best_doubles_partner: string;
    ideal_coach_style: string;
    perfect_opponent: string;
  };
}

async function analyzeTennisFortune(info: TennisInfo): Promise<TennisFortune> {
  try {
    // GPT 모델 선택 (기본 텍스트 운세)
    const model = selectGPTModel('daily', 'text');
    
    // 전문 테니스 운세 프롬프트 생성
    const prompt = `
당신은 테니스 전문가이자 운세 상담사입니다. 다음 정보를 바탕으로 테니스 운세를 상세히 분석해주세요.

사용자 정보:
- 생년월일: ${info.birth_date}
- 테니스 경험: ${info.playing_experience || '정보 없음'}
- 경기 빈도: ${info.game_frequency || '정보 없음'}
- 테니스 기술: ${info.tennis_skills?.join(', ') || '정보 없음'}
- 주 사용 손: ${info.dominant_hand || '정보 없음'}
- 플레이 스타일: ${info.playing_style || '정보 없음'}

다음 JSON 형식으로 응답해주세요:
{
  "overall_luck": 85,
  "serve_luck": 78,
  "return_luck": 82,
  "volley_luck": 75,
  "mental_luck": 88,
  "analysis": {
    "strength": "테니스에서의 주요 강점과 장점",
    "weakness": "주의해야 할 약점이나 개선점", 
    "opportunity": "테니스를 통해 얻을 수 있는 기회들",
    "threat": "경기에서 주의해야 할 도전과제들"
  },
  "lucky_elements": {
    "time": "오전 10-12시",
    "court_surface": "클레이 코트",
    "equipment": "새 스트링",
    "partner_type": "경험이 풍부한 파트너"
  },
  "recommendations": {
    "training_focus": "구체적인 훈련 포인트",
    "match_strategy": "경기 전략 조언",
    "equipment_advice": "장비 관련 조언",
    "mental_preparation": "멘탈 준비법"
  },
  "future_predictions": {
    "this_week": "이번 주 테니스 운세",
    "this_month": "이번 달 테니스 운세",
    "season_outlook": "시즌 전망"
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
      const transformedResult: TennisFortune = {
        overall_luck: gptResult.overall_luck,
        serve_luck: gptResult.serve_luck,
        return_luck: gptResult.return_luck,
        volley_luck: gptResult.volley_luck,
        mental_luck: gptResult.mental_luck,
        analysis: {
          strength: gptResult.analysis?.strength || '강한 정신력을 바탕으로 한 안정적인 플레이',
          weakness: gptResult.analysis?.weakness || '때로는 과도한 완벽주의로 인한 부담감',
          opportunity: gptResult.analysis?.opportunity || '지속적인 연습을 통한 기량 향상 기회',
          challenge: gptResult.analysis?.threat || '새로운 기술 습득에 대한 도전'
        },
        lucky_racket_tension: gptResult.lucky_elements?.equipment || generateLuckyTension(new Date().getDate()),
        lucky_court_position: gptResult.lucky_elements?.court_surface || generateLuckyPosition(new Date().getMonth() + 1),
        lucky_match_time: gptResult.lucky_elements?.time || generateLuckyTime(new Date().getDate()),
        lucky_tournament: gptResult.lucky_elements?.partner_type || generateLuckyTournament(gptResult.overall_luck),
        recommendations: {
          training_tips: [gptResult.recommendations?.training_focus || '기본기 강화에 집중하세요'],
          match_strategies: [gptResult.recommendations?.match_strategy || '상대방의 약점을 파악하여 공략하세요'],
          equipment_advice: [gptResult.recommendations?.equipment_advice || '정기적인 장비 점검을 하세요'],
          mental_preparation: [gptResult.recommendations?.mental_preparation || '경기 전 충분한 준비운동을 하세요']
        },
        future_predictions: {
          this_week: gptResult.future_predictions?.this_week || '이번 주는 기술 향상에 좋은 시기입니다',
          this_month: gptResult.future_predictions?.this_month || '이번 달은 새로운 도전에 적극적으로 임하세요',
          this_season: gptResult.future_predictions?.season_outlook || '이번 시즌은 전반적으로 좋은 성과가 기대됩니다'
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
    return generatePersonalizedTennisFortune(info);
  }
}

function generatePersonalizedTennisFortune(info: TennisInfo): TennisFortune {
  // 생년월일 기반 개인화 점수 계산
  const birthYear = info.birth_date ? parseInt(info.birth_date.substring(0, 4)) : new Date().getFullYear() - 25;
  const birthMonth = info.birth_date ? parseInt(info.birth_date.substring(5, 7)) : 6;
  const birthDay = info.birth_date ? parseInt(info.birth_date.substring(8, 10)) : 15;
  
  // 기본 점수 계산 (생년월일 기반)
  let baseScore = ((birthYear + birthMonth + birthDay) % 30) + 65;
  
  // 경험별 보너스
  if (info.playing_experience && info.playing_experience.includes('10년 이상')) baseScore += 15;
  else if (info.playing_experience && info.playing_experience.includes('5-10년')) baseScore += 10;
  else if (info.playing_experience && info.playing_experience.includes('3-5년')) baseScore += 5;
  else if (info.playing_experience && info.playing_experience.includes('1-3년')) baseScore += 2;
  
  // 경기 빈도별 보너스
  if (info.game_frequency && (info.game_frequency.includes('매일') || info.game_frequency.includes('주 5회 이상'))) baseScore += 12;
  else if (info.game_frequency && info.game_frequency.includes('주 3-4회')) baseScore += 8;
  else if (info.game_frequency && info.game_frequency.includes('주 1-2회')) baseScore += 5;
  
  // 기술 다양성 보너스
  if (info.tennis_skills && info.tennis_skills.length >= 6) baseScore += 10;
  else if (info.tennis_skills && info.tennis_skills.length >= 4) baseScore += 5;
  
  // 주 사용 손별 조정 (왼손잡이는 테니스에서 유리)
  if (info.dominant_hand === 'left') baseScore += 8;
  else if (info.dominant_hand === 'both') baseScore += 5;
  
  // 플레이 스타일별 조정
  const styleBonus: Record<string, number> = {
    '공격적 베이스라이너': 8,
    '서브 앤 발리': 10,
    '올코트 플레이어': 12,
    '파워 플레이어': 7,
    '기술적 플레이어': 9
  };
  if (info.playing_style && styleBonus[info.playing_style]) {
    baseScore += styleBonus[info.playing_style];
  }
  
  // 최종 점수 범위 조정
  baseScore = Math.max(50, Math.min(95, baseScore));
  
  // 세부 운세 점수 계산
  const overallLuck = calculateOverallLuck(baseScore, info);
  const serveLuck = calculateServeLuck(baseScore, info);
  const returnLuck = calculateReturnLuck(baseScore, info);
  const volleyLuck = calculateVolleyLuck(baseScore, info);
  const mentalLuck = calculateMentalLuck(baseScore, info);
  
  return {
    overall_luck: overallLuck,
    serve_luck: serveLuck,
    return_luck: returnLuck,
    volley_luck: volleyLuck,
    mental_luck: mentalLuck,
    analysis: generateAnalysis(baseScore, info),
    lucky_racket_tension: generateLuckyTension(birthDay),
    lucky_court_position: generateLuckyPosition(birthMonth),
    lucky_match_time: generateLuckyTime(birthDay),
    lucky_tournament: generateLuckyTournament(baseScore),
    recommendations: generateRecommendations(info),
    future_predictions: generateFuturePredictions(baseScore, info),
    compatibility: generateCompatibility(info)
  };
}

function calculateOverallLuck(baseScore: number, info: TennisInfo): number {
  let score = baseScore;
  
  // 목표의 구체성에 따른 조정
  if (info.current_goal && info.current_goal.length > 10) score += 8;
  
  // 특별한 기억이 있으면 동기부여 보너스
  if (info.special_memory && info.special_memory.length > 5) score += 5;
  
  return Math.max(50, Math.min(95, score));
}

function calculateServeLuck(baseScore: number, info: TennisInfo): number {
  let score = baseScore + 5; // 서브는 기본적으로 조금 높게
  
  // 서브 기술 보유 시 보너스
  if (info.tennis_skills?.includes('서브')) score += 12;
  
  // 파워형 플레이어는 서브 유리
  if (info.playing_style?.includes('파워') || info.playing_style?.includes('서브')) score += 10;
  
  return Math.max(45, Math.min(100, score));
}

function calculateReturnLuck(baseScore: number, info: TennisInfo): number {
  let score = baseScore;
  
  // 리턴 기술 보유 시 보너스
  if (info.tennis_skills?.includes('리턴')) score += 12;
  
  // 수비형 플레이어는 리턴 유리
  if (info.playing_style?.includes('수비') || info.playing_style?.includes('카운터')) score += 10;
  
  return Math.max(40, Math.min(95, score));
}

function calculateVolleyLuck(baseScore: number, info: TennisInfo): number {
  let score = baseScore;
  
  // 발리 기술 보유 시 보너스
  if (info.tennis_skills?.includes('발리')) score += 15;
  
  // 서브앤발리나 올코트 플레이어는 발리 유리
  if (info.playing_style?.includes('발리') || info.playing_style?.includes('올코트')) score += 12;
  
  return Math.max(50, Math.min(100, score));
}

function calculateMentalLuck(baseScore: number, info: TennisInfo): number {
  let score = baseScore + 3; // 멘탈은 기본적으로 조금 높게
  
  // 전술적 사고 기술 보유 시 보너스
  if (info.tennis_skills?.includes('전술적 사고')) score += 10;
  
  // 경험이 많을수록 멘탈 강함
  if (info.playing_experience && info.playing_experience.includes('10년 이상')) score += 8;
  else if (info.playing_experience && info.playing_experience.includes('5-10년')) score += 5;
  
  return Math.max(55, Math.min(95, score));
}

function generateAnalysis(baseScore: number, info: TennisInfo) {
  const analysisOptions = {
    strength: [
      "강한 집중력과 정확한 타이밍으로 중요한 순간에 실력을 발휘하는 능력이 뛰어납니다.",
      "뛰어난 코트 센스와 상황 판단력으로 경기를 리드해 나가는 능력이 있습니다.",
      "꾸준한 체력과 지구력으로 긴 경기에서도 흔들리지 않는 안정감을 보여줍니다.",
      "다양한 기술을 활용하여 상대방을 당황시키는 전략적 플레이가 강점입니다."
    ],
    weakness: [
      "때로는 완벽을 추구하다가 긴장하여 실수할 수 있으니 마음의 여유가 필요합니다.",
      "과도한 자신감으로 인해 기본기를 소홀히 할 수 있으니 꾸준한 연습이 중요합니다.",
      "감정 기복이 심할 때가 있어 일관된 플레이를 유지하는 것이 과제입니다.",
      "새로운 상황에 적응하는데 시간이 걸릴 수 있으니 유연성을 기르는 것이 좋겠습니다."
    ],
    opportunity: [
      "꾸준한 연습과 전략적 사고로 상대방의 약점을 찾아내는 능력이 있습니다.",
      "새로운 기술 습득에 대한 열정이 있어 빠른 발전이 가능한 시기입니다.",
      "좋은 파트너나 코치와의 만남으로 실력 향상의 기회가 열려있습니다.",
      "체계적인 훈련 프로그램을 통해 약점을 보완할 수 있는 최적의 타이밍입니다."
    ],
    challenge: [
      "새로운 기술 습득에 시간이 걸리지만, 인내심을 가지고 연습하면 반드시 개선됩니다.",
      "강한 상대와의 경기에서 위축될 수 있지만, 자신감을 가지고 도전하는 자세가 중요합니다.",
      "부상 위험이 있으니 충분한 준비운동과 컨디션 관리에 신경써야 합니다.",
      "기술적 한계를 극복하기 위해서는 전문가의 도움을 받는 것이 필요할 수 있습니다."
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

function generateLuckyTension(birthDay: number): string {
  const tensions = [48, 50, 52, 54, 56, 58];
  const index = birthDay % tensions.length;
  return `${tensions[index]}파운드`;
}

function generateLuckyPosition(birthMonth: number): string {
  const positions = ["베이스라인", "네트 앞", "서비스 라인", "코트 중앙"];
  const index = birthMonth % positions.length;
  return positions[index];
}

function generateLuckyTime(birthDay: number): string {
  const times = ["오전 10시", "오후 2시", "오후 4시", "오후 6시"];
  const index = birthDay % times.length;
  return times[index];
}

function generateLuckyTournament(baseScore: number): string {
  const tournaments = [
    "윔블던", "프랑스오픈", "US오픈", "호주오픈", "ATP 마스터즈", 
    "WTA 프리미어", "로컬 토너먼트", "클럽 대회"
  ];
  const index = baseScore % tournaments.length;
  return tournaments[index];
}

function generateRecommendations(info: TennisInfo) {
  return {
    training_tips: [
      info.tennis_skills?.includes('서브') ? 
        "서브 기술을 더욱 발전시켜 에이스 확률을 높이세요" :
        "매일 15분씩 서브 연습으로 정확도를 높이세요",
      "풋워크 훈련으로 코트 커버리지를 개선하세요",
      info.dominant_hand === 'left' ?
        "왼손잡이의 장점을 살린 각도 공격을 연습하세요" :
        "백핸드 슬라이스 연습으로 다양성을 키우세요",
      "체력 훈련으로 긴 경기에 대비하세요",
      "정확한 타겟 연습으로 컨트롤을 향상시키세요"
    ],
    match_strategies: [
      "상대방의 약한 쪽을 집중적으로 공략하세요",
      info.playing_style?.includes('공격') ?
        "공격적인 플레이로 상대방에게 압박을 가하세요" :
        "서브의 방향과 스피드를 다양하게 변화시키세요",
      "중요한 포인트에서는 안전한 플레이를 선택하세요",
      "상대방의 리듬을 깨뜨리는 전술을 사용하세요",
      "자신만의 경기 루틴을 만들어 일관성을 유지하세요"
    ],
    equipment_advice: [
      "자신의 플레이 스타일에 맞는 라켓을 선택하세요",
      "그립 사이즈를 정확히 맞춰 부상을 예방하세요",
      info.favorite_surface ?
        `${info.favorite_surface}에 최적화된 신발을 선택하세요` :
        "코트 표면에 적합한 신발을 착용하세요",
      "스트링 텐션을 정기적으로 체크하세요",
      "습도와 온도에 따라 볼의 특성을 고려하세요"
    ],
    mental_preparation: [
      "경기 전 긍정적인 시각화 훈련을 하세요",
      "실수 후에는 빠르게 마음을 리셋하세요",
      "호흡법을 통해 긴장을 완화하세요",
      info.current_goal ?
        "목표를 명확히 하고 집중력을 유지하세요" :
        "자신만의 집중 의식을 만드세요",
      "경기 중 감정 기복을 최소화하세요"
    ]
  };
}

function generateFuturePredictions(baseScore: number, info: TennisInfo) {
  const predictions = {
    week: [
      "새로운 기술을 배우기에 좋은 시기입니다. 기본기를 다지면 큰 향상을 이룰 수 있습니다.",
      "컨디션이 좋아 경기력이 상승하는 시기입니다. 적극적인 플레이를 시도해보세요.",
      "파트너십이 중요한 시기입니다. 복식 경기나 팀 훈련에 집중해보세요.",
      "멘탈 관리가 핵심인 시기입니다. 긍정적인 마인드로 경기에 임하세요."
    ],
    month: [
      "경기력이 안정화되는 시기입니다. 꾸준한 연습으로 자신감을 키워보세요.",
      "새로운 도전이 기다리는 시기입니다. 더 높은 레벨의 상대와 경기해보세요.",
      "기술적 발전이 눈에 띄는 시기입니다. 약점 보완에 집중하면 좋은 결과가 있을 것입니다.",
      "팀워크가 빛나는 시기입니다. 코치나 파트너와의 소통을 늘려보세요."
    ],
    season: [
      "목표 달성에 가까워지는 시기입니다. 끝까지 포기하지 말고 최선을 다하세요.",
      "큰 변화와 성장이 기다리는 시기입니다. 새로운 환경에서 도전해보세요.",
      "실력의 완성도가 높아지는 시기입니다. 자신만의 플레이 스타일을 완성해보세요.",
      "리더십을 발휘할 기회가 많은 시기입니다. 후배나 팀원들을 이끌어보세요."
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

function generateCompatibility(info: TennisInfo) {
  const compatibilityOptions = {
    partner: [
      "차분하고 전략적 사고를 가진 파트너",
      "활발하고 공격적인 플레이를 하는 파트너",
      "안정적이고 신뢰할 수 있는 파트너",
      "창의적이고 변화무쌍한 플레이를 하는 파트너"
    ],
    coach: [
      "체계적이면서도 개인의 특성을 살려주는 코치",
      "열정적이고 동기부여를 잘 해주는 코치",
      "기술적 세부사항에 집중하는 전문적인 코치",
      "멘탈 관리와 전략에 강한 코치"
    ],
    opponent: [
      "페어플레이를 중시하며 서로 발전시켜주는 상대",
      "실력이 비슷하여 치열한 경쟁을 벌일 수 있는 상대",
      "다양한 기술을 구사하여 배울 점이 많은 상대",
      "멘탈이 강하여 심리적 압박을 주는 상대"
    ]
  };
  
  // 플레이 스타일에 따른 호환성 결정
  let partnerIndex = 0;
  let coachIndex = 0;
  let opponentIndex = 0;
  
  if (info.playing_style?.includes('공격')) {
    partnerIndex = 0; // 차분한 파트너가 밸런스 맞춤
    coachIndex = 1; // 열정적인 코치
  } else if (info.playing_style?.includes('수비')) {
    partnerIndex = 1; // 공격적인 파트너로 밸런스
    coachIndex = 0; // 체계적인 코치
  } else if (info.playing_style?.includes('기술')) {
    partnerIndex = 3; // 창의적인 파트너
    coachIndex = 2; // 기술적 코치
  } else {
    partnerIndex = 2; // 안정적인 파트너
    coachIndex = 3; // 전략적 코치
  }
  
  // 경험에 따른 상대 선택
  if (info.playing_experience?.includes('10년 이상')) {
    opponentIndex = 3; // 멘탈이 강한 상대
  } else if (info.playing_experience?.includes('5-10년')) {
    opponentIndex = 2; // 기술이 다양한 상대
  } else {
    opponentIndex = 1; // 비슷한 실력의 상대
  }
  
  return {
    best_doubles_partner: compatibilityOptions.partner[partnerIndex],
    ideal_coach_style: compatibilityOptions.coach[coachIndex],
    perfect_opponent: compatibilityOptions.opponent[opponentIndex]
  };
}

export const POST = withFortuneAuth(async (request: AuthenticatedRequest, fortuneService: FortuneService) => {
  try {
    const body = await request.json();
    
    // 입력 검증
    if (!body.name || !body.birth_date || !body.dominant_hand) {
      return NextResponse.json(
        { error: '필수 정보가 누락되었습니다.' },
        { status: 400 }
      );
    }
    
    const tennisFortune = await analyzeTennisFortune(body as TennisInfo);
    
    return NextResponse.json(tennisFortune);
  } catch (error) {
    console.error('테니스 운세 분석 오류:', error);
    return createSafeErrorResponse(error, '운세 분석 중 오류가 발생했습니다.');
  }
});
