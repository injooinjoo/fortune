import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { person1, person2, status, duration, concern } = body;

    if (!person1?.name || !person1?.birthDate || !person2?.name || !person2?.birthDate) {
      return NextResponse.json(
        { error: '두 사람의 이름과 생년월일이 모두 필요합니다.' },
        { status: 400 }
      );
    }

    // GPT 프롬프트 생성
    const prompt = `당신은 전문 연애 상담사이자 사주명리학자입니다. 다음 커플의 정보를 바탕으로 짝궁합을 분석해주세요.

커플 정보:
- 첫 번째 사람: ${person1.name} (${person1.birthDate})
- 두 번째 사람: ${person2.name} (${person2.birthDate})
- 현재 관계: ${status || '미입력'}
- 만난 기간: ${duration || '미입력'}
- 현재 고민: ${concern || '없음'}

다음 JSON 형식으로 상세한 짝궁합 분석을 제공해주세요:

{
  "currentFlow": 40-95 사이의 현재 관계 흐름 점수,
  "futurePotential": 50-100 사이의 미래 발전 가능성 점수,
  "advice1": "첫 번째 핵심 조언",
  "advice2": "두 번째 핵심 조언",
  "tips": [
    "관계 개선 팁 1",
    "관계 개선 팁 2",
    "관계 개선 팁 3"
  ]
}

- 모든 텍스트는 한국어로 작성
- 생년월일과 관계 상황을 고려한 개인화된 분석
- 현실적이면서도 희망적인 조언
- 구체적이고 실행 가능한 팁 제공`;

    // OpenAI API 호출 (실제 구현시)
    const mockResponse = {
      currentFlow: generateCurrentFlow(status, duration, concern),
      futurePotential: generateFuturePotential(person1, person2, status, duration),
      advice1: generateAdvice1(person1.name, person2.name, status, concern),
      advice2: generateAdvice2(status, duration, concern),
      tips: generateTips(status, duration, concern)
    };

    return NextResponse.json({
      success: true,
      analysis: mockResponse,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Couple match fortune API error:', error);
    return NextResponse.json(
      { error: '짝궁합 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

function generateCurrentFlow(status: string, duration: string, concern: string): number {
  let baseScore = 70;
  
  // 관계 상태에 따른 점수
  if (status.includes('연애') || status.includes('사귀')) baseScore += 15;
  else if (status.includes('썸') || status.includes('호감')) baseScore += 5;
  else if (status.includes('친구')) baseScore -= 5;
  
  // 만난 기간에 따른 점수
  if (duration.includes('년') || duration.includes('1년')) baseScore += 10;
  else if (duration.includes('개월') && !duration.includes('1개월')) baseScore += 5;
  else if (duration.includes('1개월') || duration.includes('주')) baseScore -= 5;
  
  // 고민 여부에 따른 점수
  if (concern && concern.length > 10) baseScore -= 10;
  else if (!concern || concern.length < 5) baseScore += 5;
  
  return Math.max(40, Math.min(95, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generateFuturePotential(person1: any, person2: any, status: string, duration: string): number {
  let baseScore = 75;
  
  // 이름 궁합 (간단한 로직)
  const name1Length = person1.name.length;
  const name2Length = person2.name.length;
  if (Math.abs(name1Length - name2Length) <= 1) baseScore += 5;
  
  // 관계 안정성에 따른 점수
  if (status.includes('연애') && duration.includes('개월')) baseScore += 10;
  else if (status.includes('썸')) baseScore -= 5;
  
  // 날짜 기반 간단한 궁합 (월일 기준)
  const birth1 = new Date(person1.birthDate);
  const birth2 = new Date(person2.birthDate);
  const monthDiff = Math.abs(birth1.getMonth() - birth2.getMonth());
  if (monthDiff <= 2 || monthDiff >= 10) baseScore += 8;
  
  return Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generateAdvice1(name1: string, name2: string, status: string, concern: string): string {
  if (concern.includes('소통') || concern.includes('대화')) {
    return `${name1}님과 ${name2}님은 서로의 마음을 더 적극적으로 표현하고, 상대방의 이야기에 귀 기울이는 시간을 늘려보세요.`;
  } else if (concern.includes('미래') || concern.includes('계획')) {
    return `두 분의 관계가 발전하려면 서로의 미래에 대한 솔직한 대화와 공통된 목표를 설정하는 것이 중요합니다.`;
  } else if (concern.includes('거리') || concern.includes('시간')) {
    return `물리적 거리나 시간의 제약이 있어도, 서로를 위한 작은 배려와 관심이 관계를 더욱 돈독하게 만들 것입니다.`;
  } else if (status.includes('썸')) {
    return `현재 서로에 대한 마음이 확실하다면, 좀 더 적극적으로 감정을 표현하고 관계를 발전시켜 나가는 것이 좋겠습니다.`;
  } else {
    return `${name1}님과 ${name2}님은 서로를 이해하고 존중하는 마음을 바탕으로 더욱 깊은 신뢰 관계를 구축해 나가세요.`;
  }
}

function generateAdvice2(status: string, duration: string, concern: string): string {
  if (status.includes('연애') && duration.includes('년')) {
    return '오랜 시간 함께한 만큼 서로의 새로운 모습을 발견하려는 노력과 관계에 신선함을 더해보는 것이 필요합니다.';
  } else if (status.includes('연애') && duration.includes('개월')) {
    return '아직 서로를 알아가는 단계이므로 성급하게 결론을 내리지 말고 충분한 시간을 갖고 관계를 발전시켜 나가세요.';
  } else if (concern.includes('성격') || concern.includes('차이')) {
    return '서로 다른 점들을 단점으로 보지 말고, 상호 보완할 수 있는 매력적인 요소로 받아들이려는 마음가짐이 중요합니다.';
  } else {
    return '진정한 사랑은 조건 없는 수용과 이해에서 시작됩니다. 있는 그대로의 상대방을 인정하고 사랑해 주세요.';
  }
}

function generateTips(status: string, duration: string, concern: string): string[] {
  const tips = [];
  
  if (status.includes('썸')) {
    tips.push('솔직한 감정 표현으로 관계를 명확히 하기');
    tips.push('자연스러운 스킨십으로 친밀감 높이기');
  } else if (status.includes('연애')) {
    tips.push('정기적인 데이트로 특별한 추억 만들기');
    tips.push('서로의 가족과 친구들에게 소개하기');
  } else {
    tips.push('함께 할 수 있는 공통 관심사 찾기');
  }
  
  if (concern.includes('소통')) {
    tips.push('매일 안부를 묻는 작은 습관 만들기');
  } else if (concern.includes('시간')) {
    tips.push('바쁜 일상 속에서도 서로를 위한 시간 확보하기');
  } else {
    tips.push('서로의 취미나 관심사에 관심 보이기');
  }
  
  // 기본 팁들 추가
  const defaultTips = [
    '작은 선물이나 편지로 마음 표현하기',
    '서로의 고민을 들어주고 격려해주기',
    '미래에 대한 꿈과 계획 함께 이야기하기',
    '갈등이 생겼을 때 차분히 대화로 해결하기',
    '서로의 개인 시간과 공간도 존중하기'
  ];
  
  // 중복 제거하고 3개만 선택
  const allTips = [...tips, ...defaultTips];
  const uniqueTips = allTips.filter((tip, index) => allTips.indexOf(tip) === index);
  
  return uniqueTips.slice(0, 3);
} 