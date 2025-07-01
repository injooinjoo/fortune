import { NextRequest, NextResponse } from 'next/server';

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { 
      name, 
      age, 
      job, 
      personality, 
      ideal_type, 
      experience_level, 
      preferred_location, 
      preferred_activity, 
      concerns 
    } = body;

    if (!name || !age || !experience_level || !preferred_activity) {
      return NextResponse.json(
        { error: '필수 정보(이름, 나이, 소개팅 경험, 선호하는 활동)를 모두 입력해주세요.' },
        { status: 400 }
      );
    }

    // GPT 프롬프트 생성
    const prompt = `당신은 전문 연애 상담사이자 소개팅 코치입니다. 다음 정보를 바탕으로 소개팅 성공률을 분석하고 맞춤 조언을 제공해주세요.

개인 정보:
- 이름: ${name}
- 나이: ${age}세
- 직업: ${job || '미입력'}
- 성격: ${personality.length > 0 ? personality.join(', ') : '미입력'}
- 이상형: ${ideal_type || '미입력'}
- 소개팅 경험: ${experience_level}
- 선호 장소: ${preferred_location || '미입력'}
- 선호 활동: ${preferred_activity}
- 고민사항: ${concerns || '없음'}

다음 JSON 형식으로 상세한 소개팅 분석을 제공해주세요:

{
  "success_rate": 45-95 사이의 소개팅 성공률,
  "chemistry_score": 50-100 사이의 케미 점수,
  "conversation_score": 45-95 사이의 대화 점수,
  "impression_score": 55-100 사이의 첫인상 점수,
  "insights": {
    "personality_analysis": "성격과 매력 포인트 분석",
    "strengths": "소개팅에서 발휘할 수 있는 장점",
    "areas_to_improve": "개선하면 좋을 점들"
  },
  "recommendations": {
    "ideal_venues": ["추천 장소 1", "추천 장소 2", "추천 장소 3", "추천 장소 4", "추천 장소 5"],
    "conversation_topics": ["대화 주제 1", "대화 주제 2", "대화 주제 3", "대화 주제 4", "대화 주제 5"],
    "style_tips": ["스타일 팁 1", "스타일 팁 2", "스타일 팁 3", "스타일 팁 4"],
    "behavior_tips": ["행동 팁 1", "행동 팁 2", "행동 팁 3", "행동 팁 4", "행동 팁 5"]
  },
  "timeline": {
    "best_timing": "최적의 만남 시간대",
    "preparation_period": "준비 기간 조언",
    "success_indicators": ["성공 신호 1", "성공 신호 2", "성공 신호 3", "성공 신호 4"]
  },
  "warnings": ["주의사항 1", "주의사항 2", "주의사항 3", "주의사항 4"]
}

- 모든 텍스트는 한국어로 작성
- 개인의 특성을 반영한 구체적인 조언
- 실용적이고 실행 가능한 팁 제공
- 긍정적이면서도 현실적인 분석`;

    // OpenAI API 호출 (실제 구현시)
    const mockResponse = {
      success_rate: Math.floor(Math.random() * 51) + 45, // 45-95
      chemistry_score: Math.floor(Math.random() * 51) + 50, // 50-100
      conversation_score: Math.floor(Math.random() * 51) + 45, // 45-95
      impression_score: Math.floor(Math.random() * 46) + 55, // 55-100
      insights: {
        personality_analysis: `${name}님은 ${personality.length > 0 ? personality.join(', ') : '진솔하고 매력적인'} 성격을 가지고 있어 상대방에게 긍정적인 인상을 줄 수 있는 분입니다. 특히 ${age}세의 성숙함과 ${job ? `${job} 분야의 전문성이` : '풍부한 경험이'} 매력 포인트가 될 것입니다.`,
        strengths: generateStrengths(personality, job, experience_level),
        areas_to_improve: generateImprovementAreas(concerns, experience_level)
      },
      recommendations: {
        ideal_venues: generateVenues(preferred_location, preferred_activity),
        conversation_topics: generateTopics(job, personality, ideal_type),
        style_tips: generateStyleTips(age, job),
        behavior_tips: [
          "첫 만남에서는 진솔한 모습을 보여주세요",
          "상대방의 이야기에 집중하고 적극적으로 공감해주세요",
          "자연스러운 아이컨택과 미소로 친근감을 표현하세요",
          "휴대폰은 잠시 멀리 두고 대화에 집중하세요",
          "상대방의 관심사에 진심으로 관심을 보여주세요"
        ]
      },
      timeline: {
        best_timing: getBestTiming(preferred_activity),
        preparation_period: `소개팅 1주일 전부터 컨디션 관리와 ${preferred_activity}에 대한 준비를 시작하세요`,
        success_indicators: [
          "대화가 자연스럽게 이어지고 웃음이 많아짐",
          "서로에 대해 더 알고 싶어하는 질문이 늘어남",
          "시간 가는 줄 모르고 대화에 빠져듦",
          "다음 만남에 대한 자연스러운 언급이 나옴"
        ]
      },
      warnings: getWarnings(experience_level, concerns)
    };

    return NextResponse.json({
      success: true,
      analysis: mockResponse,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Blind date fortune API error:', error);
    return NextResponse.json(
      { error: '소개팅 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

function generateStrengths(personality: string[], job: string, experience: string): string {
  const strengths = [];
  
  if (personality.includes('외향적') || personality.includes('활발함')) {
    strengths.push('활발하고 에너지 넘치는 모습으로 분위기를 밝게 만드는 능력');
  }
  if (personality.includes('유머러스')) {
    strengths.push('자연스러운 유머 감각으로 상대방을 즐겁게 해주는 매력');
  }
  if (personality.includes('배려심 많음') || personality.includes('신중함')) {
    strengths.push('상대방을 배려하고 세심하게 신경 쓰는 따뜻한 마음');
  }
  
  if (job) {
    strengths.push(`${job} 분야의 전문성과 다양한 경험담`);
  }
  
  if (experience === '많음') {
    strengths.push('풍부한 소개팅 경험으로 여유롭고 자연스러운 태도');
  }
  
  return strengths.length > 0 ? strengths.join(', ') + '이 큰 장점입니다.' 
    : '진솔하고 자연스러운 매력이 상대방에게 좋은 인상을 줄 것입니다.';
}

function generateImprovementAreas(concerns: string, experience: string): string {
  if (concerns.includes('긴장') || experience === '없음') {
    return '첫 만남에서의 긴장감을 줄이고 자신감을 가지는 것이 중요합니다. 미리 대화 주제를 준비하고 편안한 마음가짐을 갖도록 노력해보세요.';
  }
  if (concerns.includes('대화')) {
    return '대화를 이어가는 것에 대한 부담을 줄이고, 상대방의 이야기를 들어주는 것부터 시작해보세요.';
  }
  return '자신만의 매력을 자신있게 표현하고, 상대방과의 자연스러운 소통에 집중하면 좋겠습니다.';
}

function generateVenues(location: string, activity: string): string[] {
  const venues: string[] = [];
  
  if (activity.includes('커피') || activity.includes('카페')) {
    venues.push('아늑한 카페나 티하우스', '루프탑 카페', '북카페');
  }
  if (activity.includes('식사') || activity.includes('음식')) {
    venues.push('브런치 레스토랑', '맛집 탐방', '파인다이닝');
  }
  if (activity.includes('문화') || activity.includes('전시')) {
    venues.push('미술관이나 전시회', '박물관', '갤러리');
  }
  if (activity.includes('산책') || activity.includes('야외')) {
    venues.push('공원에서 산책', '한강 걷기', '동네 탐방');
  }
  
  // 기본 추천 장소들 추가
  const defaultVenues = ['조용한 카페', '브런치 카페', '문화 공간', '공원 산책로', '북카페'];
  venues.push(...defaultVenues.filter(v => !venues.some(existing => existing.includes(v.split(' ')[0]))));
  
  return venues.slice(0, 5);
}

function generateTopics(job: string, personality: string[], idealType: string): string[] {
  const topics = [
    '취미와 관심사에 대한 이야기',
    '여행 경험과 가고 싶은 곳',
    '좋아하는 음식과 맛집 이야기'
  ];
  
  if (job) {
    topics.push(`${job} 분야의 흥미로운 경험담`);
  } else {
    topics.push('일상 속 소소한 재미있는 이야기');
  }
  
  if (personality.includes('문화적') || idealType.includes('문화')) {
    topics.push('최근에 본 영화나 읽은 책');
  } else {
    topics.push('최근에 본 드라마나 예능 프로그램');
  }
  
  return topics;
}

function generateStyleTips(age: string, job: string): string[] {
  const tips = ['깔끔하고 단정한 옷차림'];
  
  const ageNum = parseInt(age);
  if (ageNum >= 30) {
    tips.push('성숙하면서도 세련된 스타일');
  } else {
    tips.push('밝고 활기찬 느낌의 스타일');
  }
  
  if (job && (job.includes('회사') || job.includes('사무'))) {
    tips.push('비즈니스 캐주얼 느낌의 품격있는 의상');
  } else {
    tips.push('편안하면서도 매너있는 캐주얼 의상');
  }
  
  tips.push('상황에 맞는 적절한 액세서리로 포인트 주기');
  
  return tips;
}

function getBestTiming(activity: string): string {
  if (activity.includes('커피') || activity.includes('브런치')) {
    return '오후 2-4시 (브런치) 또는 오후 3-5시 (커피)';
  }
  if (activity.includes('저녁') || activity.includes('식사')) {
    return '저녁 6-8시';
  }
  if (activity.includes('산책') || activity.includes('야외')) {
    return '오후 3-5시 또는 저녁 6-7시';
  }
  return '오후 2-4시 또는 저녁 6-8시';
}

function getWarnings(experience: string, concerns: string): string[] {
  const warnings = ['과도한 기대는 금물입니다'];
  
  if (experience === '없음') {
    warnings.push('첫 소개팅이니 너무 부담갖지 마세요');
    warnings.push('자연스러운 모습을 보여주는 것이 가장 중요합니다');
  }
  
  if (concerns.includes('외모') || concerns.includes('스타일')) {
    warnings.push('외모보다 진정성 있는 대화에 집중하세요');
  }
  
  warnings.push('첫 만남에서 너무 개인적인 질문은 피해주세요');
  
  return warnings;
} 