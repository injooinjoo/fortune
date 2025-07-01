import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { 
      name, 
      relationship_duration, 
      breakup_reason, 
      time_since_breakup, 
      feelings 
    } = body;

    if (!name || !relationship_duration || !breakup_reason || !time_since_breakup) {
      return NextResponse.json(
        { error: '필수 정보(이름, 교제기간, 이별사유, 이별후 시간)를 모두 입력해주세요.' },
        { status: 400 }
      );
    }

    // GPT 프롬프트 생성
    const prompt = `당신은 전문 심리상담사이자 연애 전문가입니다. 다음 헤어진 연인에 대한 정보를 바탕으로 현재 상황을 분석하고 치유 조언을 제공해주세요.

관계 정보:
- 헤어진 애인 이름: ${name}
- 교제 기간: ${relationship_duration}
- 이별 사유: ${breakup_reason}
- 이별 후 경과 시간: ${time_since_breakup}
- 현재 감정: ${feelings || '미입력'}

다음 JSON 형식으로 상세한 분석을 제공해주세요:

{
  "closure_score": 20-100 사이의 감정 정리 점수,
  "reconciliation_chance": 10-90 사이의 재결합 가능성,
  "emotional_healing": 30-100 사이의 감정 치유 정도,
  "future_relationship_impact": 25-95 사이의 향후 연애에 미치는 영향도,
  "insights": {
    "current_status": "현재 감정 상태에 대한 구체적 분석",
    "emotional_state": "내면의 감정 상태와 심리적 위치",
    "advice": "전문가로서 제공하는 구체적 조언"
  },
  "closure_activities": [
    "감정 정리를 위한 활동 1",
    "감정 정리를 위한 활동 2",
    "감정 정리를 위한 활동 3",
    "감정 정리를 위한 활동 4",
    "감정 정리를 위한 활동 5"
  ],
  "warning_signs": [
    "주의해야 할 신호 1",
    "주의해야 할 신호 2",
    "주의해야 할 신호 3",
    "주의해야 할 신호 4"
  ],
  "positive_aspects": [
    "이 관계에서 얻은 긍정적 측면 1",
    "이 관계에서 얻은 긍정적 측면 2",
    "이 관계에서 얻은 긍정적 측면 3",
    "이 관계에서 얻은 긍정적 측면 4"
  ],
  "timeline": {
    "healing_phase": "현재 치유 단계 설명",
    "duration": "예상 치유 기간",
    "next_steps": "다음 단계 조언"
  }
}

- 모든 텍스트는 한국어로 작성
- 교제 기간과 이별 사유를 고려한 개인화된 분석
- 심리학적 근거를 바탕으로 한 전문적 조언
- 치유와 성장에 초점을 맞춘 긍정적 방향성 제시`;

    // OpenAI API 호출 (실제 구현시)
    const mockResponse = {
      closure_score: generateClosureScore(time_since_breakup, breakup_reason),
      reconciliation_chance: generateReconciliationChance(breakup_reason, time_since_breakup),
      emotional_healing: generateHealingScore(time_since_breakup, feelings),
      future_relationship_impact: generateFutureImpact(relationship_duration, breakup_reason),
      insights: {
        current_status: generateCurrentStatus(name, time_since_breakup, breakup_reason),
        emotional_state: generateEmotionalState(feelings, time_since_breakup),
        advice: generateAdvice(relationship_duration, breakup_reason, time_since_breakup)
      },
      closure_activities: generateClosureActivities(breakup_reason, time_since_breakup),
      warning_signs: generateWarningSigns(time_since_breakup, feelings),
      positive_aspects: generatePositiveAspects(relationship_duration, name),
      timeline: generateTimeline(time_since_breakup, breakup_reason)
    };

    return NextResponse.json({
      success: true,
      analysis: mockResponse,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Ex-lover fortune API error:', error);
    return NextResponse.json(
      { error: '헤어진 애인 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

function generateClosureScore(timeSince: string, reason: string): number {
  let baseScore = 50;
  
  // 시간에 따른 점수
  if (timeSince.includes('1년 이상')) baseScore += 30;
  else if (timeSince.includes('6개월-1년')) baseScore += 20;
  else if (timeSince.includes('3-6개월')) baseScore += 10;
  else baseScore -= 10; // 3개월 미만
  
  // 이별 사유에 따른 점수
  if (reason.includes('자연스러운') || reason.includes('합의')) baseScore += 15;
  else if (reason.includes('바람') || reason.includes('배신')) baseScore -= 20;
  
  return Math.max(20, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 10));
}

function generateReconciliationChance(reason: string, timeSince: string): number {
  let baseChance = 30;
  
  // 이별 사유에 따른 가능성
  if (reason.includes('오해') || reason.includes('의사소통')) baseChance += 25;
  else if (reason.includes('거리') || reason.includes('환경')) baseChance += 15;
  else if (reason.includes('바람') || reason.includes('배신')) baseChance -= 20;
  else if (reason.includes('성격차이')) baseChance -= 10;
  
  // 시간에 따른 조정
  if (timeSince.includes('1년 이상')) baseChance -= 15;
  else if (timeSince.includes('1개월 미만')) baseChance += 10;
  
  return Math.max(10, Math.min(90, baseChance + Math.floor(Math.random() * 20) - 10));
}

function generateHealingScore(timeSince: string, feelings: string): number {
  let baseScore = 60;
  
  // 시간에 따른 치유
  if (timeSince.includes('1년 이상')) baseScore += 25;
  else if (timeSince.includes('6개월-1년')) baseScore += 15;
  else if (timeSince.includes('3-6개월')) baseScore += 5;
  
  // 감정에 따른 조정
  if (feelings.includes('그립') || feelings.includes('미련')) baseScore -= 15;
  else if (feelings.includes('원망') || feelings.includes('분노')) baseScore -= 10;
  else if (feelings.includes('담담') || feelings.includes('괜찮')) baseScore += 15;
  
  return Math.max(30, Math.min(100, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generateFutureImpact(duration: string, reason: string): number {
  let baseScore = 70;
  
  // 교제 기간에 따른 영향
  if (duration.includes('3년 이상')) baseScore += 15;
  else if (duration.includes('1-3년')) baseScore += 10;
  else if (duration.includes('1-6개월')) baseScore -= 5;
  
  // 이별 사유에 따른 영향
  if (reason.includes('성장') || reason.includes('자연스러운')) baseScore += 15;
  else if (reason.includes('바람') || reason.includes('배신')) baseScore -= 15;
  
  return Math.max(25, Math.min(95, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generateCurrentStatus(name: string, timeSince: string, reason: string): string {
  if (timeSince.includes('1년 이상')) {
    return `${name}님과의 관계는 이미 과거가 되어 감정적 정리가 상당 부분 완료된 상태입니다. 새로운 삶에 집중할 준비가 되어있습니다.`;
  } else if (timeSince.includes('6개월-1년')) {
    return `${name}님과의 추억은 여전히 마음 한편에 남아있지만, 점차 객관적으로 바라볼 수 있게 되었습니다.`;
  } else if (timeSince.includes('3-6개월')) {
    return `${name}님과의 이별 아픔이 많이 줄어들었지만, 아직 완전히 정리되지 않은 감정들이 남아있는 상태입니다.`;
  } else {
    return `${name}님과의 이별이 아직 생생하여 다양한 감정들이 혼재되어 있는 시기입니다.`;
  }
}

function generateEmotionalState(feelings: string, timeSince: string): string {
  if (feelings.includes('그립') || feelings.includes('미련')) {
    return '여전히 그리움과 아쉬움이 크지만, 이는 소중했던 관계에 대한 자연스러운 감정입니다. 시간이 흐르며 점차 정리될 것입니다.';
  } else if (feelings.includes('원망') || feelings.includes('분노')) {
    return '상처받은 마음과 분노가 남아있지만, 이러한 감정을 건전하게 표현하고 정리하는 과정이 필요합니다.';
  } else if (feelings.includes('담담') || feelings.includes('괜찮')) {
    return '감정적으로 많이 안정되어 과거를 객관적으로 바라볼 수 있는 성숙한 상태에 도달했습니다.';
  } else {
    return '복잡하고 다양한 감정들이 공존하고 있는 자연스러운 과정을 겪고 있습니다.';
  }
}

function generateAdvice(duration: string, reason: string, timeSince: string): string {
  const baseAdvice = '과거의 관계를 통해 배운 것들을 소중히 여기면서도, 현재와 미래에 집중하는 것이 중요합니다.';
  
  if (reason.includes('바람') || reason.includes('배신')) {
    return '배신당한 상처는 깊지만, 이 경험이 앞으로 더 건강한 관계를 구별하는 안목을 키워줄 것입니다. ' + baseAdvice;
  } else if (reason.includes('성격차이')) {
    return '성격 차이로 인한 이별은 서로를 더 이해하고 성장할 수 있는 기회였습니다. ' + baseAdvice;
  } else {
    return '모든 관계는 성장의 기회이며, 이 경험을 통해 더 성숙한 사람이 되셨습니다. ' + baseAdvice;
  }
}

function generateClosureActivities(reason: string, timeSince: string): string[] {
  const activities = ['일기 쓰기로 감정 정리하기', '새로운 취미나 관심사 찾기'];
  
  if (timeSince.includes('1개월 미만') || timeSince.includes('1-3개월')) {
    activities.push('함께했던 추억의 물건 정리하기', '편지 쓰기 (보내지 않고 태우기)');
  } else {
    activities.push('자기계발과 성장에 집중하기', '새로운 환경에서 활동해보기');
  }
  
  activities.push('친구들과의 시간 늘리기');
  
  return activities;
}

function generateWarningSigns(timeSince: string, feelings: string): string[] {
  const warnings = ['지나친 SNS 스토킹'];
  
  if (timeSince.includes('1개월 미만')) {
    warnings.push('연락을 시도하고 싶은 강한 충동', '공통 지인들을 통한 과도한 소식 확인');
  } else {
    warnings.push('비슷한 유형의 사람에게만 관심', '새로운 관계에 대한 지나친 비교');
  }
  
  warnings.push('이별 이유에 대한 반복적 반추');
  
  return warnings;
}

function generatePositiveAspects(duration: string, name: string): string[] {
  const aspects = [`${name}님과의 관계를 통해 사랑하는 방법을 배웠습니다`];
  
  if (duration.includes('3년 이상') || duration.includes('1-3년')) {
    aspects.push('깊이 있는 관계를 경험하며 성숙해졌습니다', '서로를 이해하고 배려하는 법을 익혔습니다');
  } else {
    aspects.push('새로운 경험을 통해 자신에 대해 더 알게 되었습니다');
  }
  
  aspects.push('앞으로 더 건강한 관계를 맺을 수 있는 기반을 마련했습니다');
  
  return aspects;
}

function generateTimeline(timeSince: string, reason: string): object {
  if (timeSince.includes('1년 이상')) {
    return {
      healing_phase: '회복 완료 단계',
      duration: '이미 충분한 시간이 지났습니다',
      next_steps: '새로운 관계를 시작할 준비가 되어있습니다'
    };
  } else if (timeSince.includes('6개월-1년')) {
    return {
      healing_phase: '안정화 단계',
      duration: '2-4개월 더 필요할 것 같습니다',
      next_steps: '천천히 새로운 만남에 마음을 열어보세요'
    };
  } else {
    return {
      healing_phase: '초기 회복 단계',
      duration: '3-6개월 정도 더 필요합니다',
      next_steps: '자신을 돌보고 성장에 집중하는 시기입니다'
    };
  }
} 