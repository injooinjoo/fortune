import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { person1, person2, relationship_duration, intimacy_level, concerns } = body;

    if (!person1?.name || !person2?.name || !relationship_duration || !intimacy_level) {
      return NextResponse.json(
        { error: '필수 정보(이름, 관계 기간, 친밀도 단계)를 모두 입력해주세요.' },
        { status: 400 }
      );
    }

    // GPT 프롬프트 생성
    const prompt = `당신은 전문 연애 상담사이자 성심리학자입니다. 다음 커플의 정보를 바탕으로 속궁합(케미)을 상세 분석해주세요.

커플 정보:
- 첫 번째 사람: ${person1.name} (나이: ${person1.age || '미입력'}, 별자리: ${person1.sign || '미입력'})
- 성격 특성: ${person1.personality_traits?.join(', ') || '미입력'}
- 선호도: ${person1.intimate_preferences || '미입력'}

- 두 번째 사람: ${person2.name} (나이: ${person2.age || '미입력'}, 별자리: ${person2.sign || '미입력'})
- 성격 특성: ${person2.personality_traits?.join(', ') || '미입력'}
- 선호도: ${person2.intimate_preferences || '미입력'}

관계 정보:
- 관계 기간: ${relationship_duration}
- 현재 친밀도 단계: ${intimacy_level}
- 고민사항: ${concerns || '없음'}

다음 JSON 형식으로 상세한 속궁합 분석을 제공해주세요:

{
  "overall_chemistry": 45-95 사이의 종합 케미 점수,
  "physical_attraction": 50-100 사이의 신체적 매력 점수,
  "emotional_connection": 45-95 사이의 감정적 연결 점수,
  "passion_intensity": 55-100 사이의 열정 강도 점수,
  "compatibility_level": 50-95 사이의 궁합 점수,
  "intimacy_potential": 60-100 사이의 친밀감 잠재력 점수,
  "insights": {
    "strengths": "관계의 강점",
    "challenges": "극복해야 할 과제",
    "enhancement_tips": "관계 발전을 위한 핵심 팁"
  },
  "detailed_analysis": {
    "physical_chemistry": "신체적 케미 분석",
    "emotional_bond": "감정적 유대감 분석",
    "passion_dynamics": "열정의 역동성 분석",
    "intimacy_forecast": "친밀감 발전 전망"
  },
  "recommendations": {
    "enhancement_activities": ["관계 향상 활동 5개"],
    "communication_tips": ["소통 개선 팁 5개"],
    "intimacy_advice": ["친밀감 조언 5개"]
  },
  "warnings": ["주의사항 4개"],
  "compatibility_percentage": 55-95 사이의 전체 궁합률
}

- 모든 텍스트는 한국어로 작성
- 성격, 나이, 별자리, 관계 기간을 고려한 개인화된 분석
- 건전하면서도 로맨틱한 조언
- 실용적이고 실행 가능한 팁 제공`;

    // OpenAI API 호출 (실제 구현시)
    const mockResponse = {
      overall_chemistry: generateOverallChemistry(person1, person2, relationship_duration, intimacy_level),
      physical_attraction: generatePhysicalAttraction(person1, person2, intimacy_level),
      emotional_connection: generateEmotionalConnection(person1, person2, relationship_duration),
      passion_intensity: generatePassionIntensity(person1, person2, intimacy_level),
      compatibility_level: generateCompatibilityLevel(person1, person2),
      intimacy_potential: generateIntimacyPotential(relationship_duration, intimacy_level, concerns),
      insights: generateInsights(person1, person2, concerns),
      detailed_analysis: generateDetailedAnalysis(person1, person2, relationship_duration, intimacy_level),
      recommendations: generateRecommendations(relationship_duration, intimacy_level, concerns),
      warnings: generateWarnings(relationship_duration, intimacy_level, concerns),
      compatibility_percentage: generateCompatibilityPercentage(person1, person2, relationship_duration, intimacy_level)
    };

    return NextResponse.json({
      success: true,
      analysis: mockResponse,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Chemistry fortune API error:', error);
    return NextResponse.json(
      { error: '속궁합 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

function generateOverallChemistry(person1: any, person2: any, duration: string, intimacy: string): number {
  let baseScore = 70;
  
  // 성격 궁합
  const traits1 = person1.personality_traits || [];
  const traits2 = person2.personality_traits || [];
  const commonTraits = traits1.filter((trait: string) => traits2.includes(trait));
  if (commonTraits.length >= 2) baseScore += 10;
  
  // 관계 기간별 점수
  if (duration.includes('년')) baseScore += 8;
  else if (duration.includes('개월') && !duration.includes('1개월')) baseScore += 5;
  
  // 친밀도 단계별 점수
  if (intimacy.includes('깊은') || intimacy.includes('완전')) baseScore += 12;
  else if (intimacy.includes('중간') || intimacy.includes('보통')) baseScore += 5;
  
  return Math.max(45, Math.min(95, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generatePhysicalAttraction(person1: any, person2: any, intimacy: string): number {
  let baseScore = 75;
  
  // 나이 차이 고려
  const age1 = parseInt(person1.age) || 25;
  const age2 = parseInt(person2.age) || 25;
  const ageDiff = Math.abs(age1 - age2);
  if (ageDiff <= 3) baseScore += 8;
  else if (ageDiff <= 7) baseScore += 3;
  
  // 친밀도에 따른 점수
  if (intimacy.includes('깊은') || intimacy.includes('완전')) baseScore += 15;
  else if (intimacy.includes('시작')) baseScore -= 5;
  
  return Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generateEmotionalConnection(person1: any, person2: any, duration: string): number {
  let baseScore = 65;
  
  // 감성적 성격 특성 확인
  const emotionalTraits = ['감성적', '섬세함', '배려심', '로맨틱'];
  const traits1 = person1.personality_traits || [];
  const traits2 = person2.personality_traits || [];
  
  const emotional1 = traits1.some((trait: string) => emotionalTraits.includes(trait));
  const emotional2 = traits2.some((trait: string) => emotionalTraits.includes(trait));
  
  if (emotional1 && emotional2) baseScore += 15;
  else if (emotional1 || emotional2) baseScore += 8;
  
  // 관계 기간에 따른 감정적 연결
  if (duration.includes('년') || duration.includes('1년')) baseScore += 12;
  
  return Math.max(45, Math.min(95, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generatePassionIntensity(person1: any, person2: any, intimacy: string): number {
  let baseScore = 75;
  
  // 열정적 성격 특성 확인
  const passionateTraits = ['열정적', '적극적', '자유로움'];
  const traits1 = person1.personality_traits || [];
  const traits2 = person2.personality_traits || [];
  
  const passionate1 = traits1.some((trait: string) => passionateTraits.includes(trait));
  const passionate2 = traits2.some((trait: string) => passionateTraits.includes(trait));
  
  if (passionate1 && passionate2) baseScore += 15;
  else if (passionate1 || passionate2) baseScore += 7;
  
  // 친밀도 단계에 따른 열정 점수
  if (intimacy.includes('깊은')) baseScore += 12;
  else if (intimacy.includes('중간')) baseScore += 5;
  
  return Math.max(55, Math.min(100, baseScore + Math.floor(Math.random() * 12) - 6));
}

function generateCompatibilityLevel(person1: any, person2: any): number {
  let baseScore = 70;
  
  // 별자리 궁합 (간단 로직)
  const fire = ['양자리', '사자자리', '사수자리'];
  const earth = ['황소자리', '처녀자리', '염소자리'];
  const air = ['쌍둥이자리', '천칭자리', '물병자리'];
  const water = ['게자리', '전갈자리', '물고기자리'];
  
  const sign1 = person1.sign;
  const sign2 = person2.sign;
  
  if (sign1 && sign2) {
    if ((fire.includes(sign1) && air.includes(sign2)) || 
        (earth.includes(sign1) && water.includes(sign2)) ||
        (air.includes(sign1) && fire.includes(sign2)) ||
        (water.includes(sign1) && earth.includes(sign2))) {
      baseScore += 10;
    } else if ((fire.includes(sign1) && fire.includes(sign2)) ||
               (earth.includes(sign1) && earth.includes(sign2)) ||
               (air.includes(sign1) && air.includes(sign2)) ||
               (water.includes(sign1) && water.includes(sign2))) {
      baseScore += 5;
    }
  }
  
  return Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generateIntimacyPotential(duration: string, intimacy: string, concerns: string): number {
  let baseScore = 75;
  
  if (duration.includes('년')) baseScore += 10;
  if (intimacy.includes('깊은') || intimacy.includes('완전')) baseScore += 8;
  if (!concerns || concerns.length < 10) baseScore += 5;
  
  return Math.max(60, Math.min(100, baseScore + Math.floor(Math.random() * 12) - 6));
}

function generateInsights(person1: any, person2: any, concerns: string): any {
  const insights = {
    strengths: "",
    challenges: "",
    enhancement_tips: ""
  };
  
  if (concerns.includes('소통')) {
    insights.strengths = "서로에 대한 관심과 애정이 깊어 관계 발전의 기초가 탄탄합니다.";
    insights.challenges = "감정 표현과 소통 방식에서 차이가 있어 서로를 이해하는 시간이 필요합니다.";
    insights.enhancement_tips = "정기적인 대화 시간을 갖고 서로의 감정을 솔직하게 표현하는 연습을 해보세요.";
  } else if (concerns.includes('친밀')) {
    insights.strengths = "서로에 대한 신뢰와 애정이 깊어 더욱 친밀한 관계로 발전할 가능성이 높습니다.";
    insights.challenges = "친밀감의 속도나 방식에서 개인차가 있을 수 있어 서로의 페이스를 맞춰가는 과정이 필요합니다.";
    insights.enhancement_tips = "서로의 경계를 존중하면서도 새로운 경험을 함께 시도해보는 것이 도움이 됩니다.";
  } else {
    insights.strengths = "두 분의 에너지가 매우 조화로우며, 서로에 대한 깊은 이해와 신뢰를 바탕으로 한 친밀감이 돋보입니다.";
    insights.challenges = "때로는 감정 표현 방식의 차이로 인해 오해가 생길 수 있으니, 더욱 솔직하고 개방적인 소통이 필요합니다.";
    insights.enhancement_tips = "서로의 욕구와 선호도를 더 깊이 이해하고, 새로운 경험을 함께 시도해보는 것이 관계 발전에 도움이 됩니다.";
  }
  
  return insights;
}

function generateDetailedAnalysis(person1: any, person2: any, duration: string, intimacy: string): any {
  return {
    physical_chemistry: `${person1.name}님과 ${person2.name}님은 서로에게 자연스럽게 끌리는 강한 매력을 가지고 있으며, 신체적으로도 조화로운 에너지를 보여줍니다.`,
    emotional_bond: `감정적으로 깊이 연결되어 있으며, 서로의 마음을 잘 이해하고 공감하는 능력이 뛰어나 장기적인 관계 발전에 매우 유리합니다.`,
    passion_dynamics: duration.includes('년') ? 
      "오랜 시간 함께하면서도 여전히 서로를 향한 열정을 유지하고 있어, 지속 가능한 사랑의 모습을 보여줍니다." :
      "새로운 관계의 설렘과 열정이 가득하며, 서로를 더 알아가면서 더욱 깊어질 수 있는 잠재력이 큽니다.",
    intimacy_forecast: intimacy.includes('깊은') ?
      "이미 깊은 친밀감을 바탕으로 더욱 성숙하고 안정적인 관계로 발전할 수 있는 기반이 마련되어 있습니다." :
      "시간이 지날수록 더욱 깊어질 수 있는 친밀감의 가능성이 높으며, 지속적인 관심과 노력으로 발전할 수 있습니다."
  };
}

function generateRecommendations(duration: string, intimacy: string, concerns: string): any {
  const recommendations = {
    enhancement_activities: [] as string[],
    communication_tips: [] as string[],
    intimacy_advice: [] as string[]
  };
  
  if (duration.includes('년')) {
    recommendations.enhancement_activities = [
      "새로운 취미나 여행지를 함께 도전해보기",
      "서로의 꿈과 목표에 대해 다시 이야기해보기",
      "추억을 되돌아보며 관계의 의미 재확인하기",
      "커플만의 특별한 전통이나 의식 만들기",
      "서로의 성장과 변화에 대해 인정하고 격려하기"
    ];
  } else {
    recommendations.enhancement_activities = [
      "함께하는 새로운 취미나 활동 시도하기",
      "정기적인 데이트 시간 확보하기",
      "서로의 관심사에 대해 더 깊이 알아가기",
      "감정을 솔직하게 표현하는 시간 갖기",
      "로맨틱한 분위기 조성하기"
    ];
  }
  
  recommendations.communication_tips = [
    "상대방의 감정을 먼저 이해하려 노력하기",
    "비판보다는 격려와 지지 표현하기",
    "욕구와 바람을 솔직하게 이야기하기",
    "갈등 상황에서도 존중하는 태도 유지하기",
    "정기적인 관계 점검 시간 갖기"
  ];
  
  recommendations.intimacy_advice = [
    "서로의 경계와 선호도 존중하기",
    "새로운 경험에 대해 열린 마음 갖기",
    "충분한 시간과 여유 확보하기",
    "감정적 친밀감 먼저 쌓기",
    "상대방의 반응에 세심하게 주의 기울이기"
  ];
  
  return recommendations;
}

function generateWarnings(duration: string, intimacy: string, concerns: string): string[] {
  const warnings = [];
  
  if (intimacy.includes('시작') || duration.includes('주') || duration.includes('1개월')) {
    warnings.push("성급한 진전보다는 서로를 충분히 이해하는 시간이 필요합니다");
  }
  
  warnings.push("상대방의 의사를 존중하지 않는 강요는 관계에 해가 됩니다");
  
  if (concerns.includes('소통')) {
    warnings.push("감정적 상처를 줄 수 있는 말이나 행동에 특히 주의해야 합니다");
  } else {
    warnings.push("감정적 상처를 줄 수 있는 말이나 행동 주의가 필요합니다");
  }
  
  warnings.push("외부 스트레스가 관계에 영향을 주지 않도록 관리해야 합니다");
  
  return warnings;
}

function generateCompatibilityPercentage(person1: any, person2: any, duration: string, intimacy: string): number {
  let baseScore = 70;
  
  if (duration.includes('년')) baseScore += 10;
  if (intimacy.includes('깊은')) baseScore += 8;
  
  const traits1 = person1.personality_traits || [];
  const traits2 = person2.personality_traits || [];
  const commonTraits = traits1.filter((trait: string) => traits2.includes(trait));
  if (commonTraits.length >= 2) baseScore += 8;
  
  return Math.max(55, Math.min(95, baseScore + Math.floor(Math.random() * 15) - 7));
} 