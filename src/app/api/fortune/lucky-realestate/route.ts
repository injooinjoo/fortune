import { NextRequest, NextResponse } from 'next/server';

interface RealEstateRequest {
  name: string;
  birth_date: string;
  current_age: string;
  investment_experience: string;
  budget_range: string;
  investment_purpose: string[];
  preferred_areas: string[];
  property_types: string[];
  investment_timeline: string;
  current_situation: string;
  concerns: string;
}

interface RealEstateFortune {
  overall_luck: number;
  buying_luck: number;
  selling_luck: number;
  rental_luck: number;
  location_luck: number;
  analysis: {
    strength: string;
    weakness: string;
    opportunity: string;
    risk: string;
  };
  lucky_elements: {
    areas: string[];
    property_types: string[];
    timing: string;
    direction: string;
    floor_preference: string;
  };
  recommendations: {
    investment_tips: string[];
    timing_strategies: string[];
    location_advice: string[];
    risk_management: string[];
  };
  future_predictions: {
    this_month: string;
    next_quarter: string;
    this_year: string;
  };
  warning_signs: string[];
}

function generateOverallLuck(request: RealEstateRequest): number {
  let baseScore = 70;
  
  // 투자 경험에 따른 점수
  if (request.investment_experience.includes('10년 이상')) baseScore += 15;
  else if (request.investment_experience.includes('5-10년')) baseScore += 10;
  else if (request.investment_experience.includes('3-5년')) baseScore += 5;
  else if (request.investment_experience.includes('초보')) baseScore -= 5;
  
  // 투자 목적 다양성
  if (request.investment_purpose.includes('자가거주') && request.investment_purpose.includes('투자')) baseScore += 8;
  else if (request.investment_purpose.length >= 2) baseScore += 5;
  
  // 예산 범위 적정성
  if (request.budget_range.includes('5억-10억') || request.budget_range.includes('3억-5억')) baseScore += 5;
  
  return Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generateBuyingLuck(request: RealEstateRequest): number {
  let baseScore = 75;
  
  // 투자 타임라인에 따른 점수
  if (request.investment_timeline.includes('2-3년') || request.investment_timeline.includes('장기')) baseScore += 10;
  else if (request.investment_timeline.includes('1년 이내')) baseScore -= 10;
  
  // 선호 지역 다양성
  if (request.preferred_areas.length >= 3) baseScore += 8;
  else if (request.preferred_areas.length >= 2) baseScore += 5;
  
  // 현재 상황 고려
  if (request.current_situation.includes('안정') || request.current_situation.includes('여유')) baseScore += 10;
  else if (request.current_situation.includes('급함') || request.current_situation.includes('어려움')) baseScore -= 5;
  
  return Math.max(45, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 10));
}

function generateSellingLuck(request: RealEstateRequest): number {
  let baseScore = 65;
  
  // 투자 경험에 따른 판매 능력
  if (request.investment_experience.includes('10년 이상')) baseScore += 20;
  else if (request.investment_experience.includes('5-10년')) baseScore += 15;
  else if (request.investment_experience.includes('3-5년')) baseScore += 8;
  
  // 투자 목적에 따른 판매 전략
  if (request.investment_purpose.includes('단기수익')) baseScore += 10;
  else if (request.investment_purpose.includes('장기보유')) baseScore -= 5;
  
  return Math.max(40, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 10));
}

function generateRentalLuck(request: RealEstateRequest): number {
  let baseScore = 70;
  
  // 임대 목적 여부
  if (request.investment_purpose.includes('임대수익')) baseScore += 15;
  
  // 지역 선택의 임대 적합성
  if (request.preferred_areas.includes('강남구') || 
      request.preferred_areas.includes('마포구') || 
      request.preferred_areas.includes('성동구')) baseScore += 10;
  
  // 건물 유형의 임대 적합성
  if (request.property_types.includes('오피스텔') || 
      request.property_types.includes('원룸')) baseScore += 8;
  
  return Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 15) - 7));
}

function generateLocationLuck(request: RealEstateRequest): number {
  let baseScore = 65;
  
  // 생년월일 기반 방향 운
  const birthDate = new Date(request.birth_date);
  const month = birthDate.getMonth() + 1;
  const day = birthDate.getDate();
  
  // 특정 월에 태어난 경우 위치 운 보너스
  if ([3, 6, 9, 12].includes(month)) baseScore += 8;
  if (day <= 10) baseScore += 5; // 초순 출생
  
  // 투자 경험에 따른 입지 선택 능력
  if (request.investment_experience.includes('10년 이상')) baseScore += 12;
  else if (request.investment_experience.includes('5-10년')) baseScore += 8;
  
  return Math.max(55, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 10));
}

function generateLuckyElements(request: RealEstateRequest) {
  // 기본 지역 목록
  const allAreas = [
    "강남구", "서초구", "송파구", "강동구", "마포구", 
    "성동구", "용산구", "종로구", "중구", "영등포구",
    "분당구", "일산서구", "평촌", "산본", "중동"
  ];
  
  // 사용자 선호 지역 우선, 추가 추천
  let recommendedAreas = [...request.preferred_areas];
  if (recommendedAreas.length < 3) {
    const additionalAreas = allAreas.filter(area => !recommendedAreas.includes(area));
    recommendedAreas = [...recommendedAreas, ...additionalAreas.slice(0, 3 - recommendedAreas.length)];
  }
  
  // 건물 유형 추천
  let recommendedTypes = [...request.property_types];
  if (request.investment_purpose.includes('임대수익') && !recommendedTypes.includes('오피스텔')) {
    recommendedTypes.push('오피스텔');
  }
  if (request.investment_purpose.includes('자가거주') && !recommendedTypes.includes('아파트')) {
    recommendedTypes.push('아파트');
  }
  
  // 생월 기반 타이밍
  const birthDate = new Date(request.birth_date);
  const birthMonth = birthDate.getMonth() + 1;
  let timing = "봄철(3-5월)";
  if ([6, 7, 8].includes(birthMonth)) timing = "여름철(6-8월)";
  else if ([9, 10, 11].includes(birthMonth)) timing = "가을철(9-11월)";
  else if ([12, 1, 2].includes(birthMonth)) timing = "겨울철(12-2월)";
  
  // 방향 추천 (생년 기준)
  const birthYear = birthDate.getFullYear();
  const directions = ["남향", "동남향", "남서향", "동향"];
  const direction = directions[birthYear % 4];
  
  // 층수 추천 (나이 기준)
  const age = parseInt(request.current_age) || 30;
  let floorPreference = "중층(5-10층)";
  if (age >= 50) floorPreference = "저층(1-5층)";
  else if (age <= 30) floorPreference = "고층(10층 이상)";
  
  return {
    areas: recommendedAreas.slice(0, 3),
    property_types: recommendedTypes.slice(0, 2),
    timing,
    direction,
    floor_preference: floorPreference
  };
}

function generateAnalysis(request: RealEstateRequest) {
  const experience = request.investment_experience;
  const purpose = request.investment_purpose;
  
  let strength = "부동산 시장에 대한 직감이 좋고, 장기적인 안목으로 투자할 수 있는 인내심";
  let weakness = "때로는 과도한 신중함으로 인해 좋은 기회를 놓칠 수 있어 적절한 결단력 필요";
  let opportunity = "정부 정책과 시장 변화를 잘 파악하여 새로운 투자 기회를 발견할 수 있는 시기";
  let risk = "감정적인 투자 결정을 내릴 수 있는 위험이 있으니 항상 객관적인 분석 필요";
  
  if (experience.includes('10년 이상')) {
    strength = "풍부한 부동산 투자 경험을 바탕으로 한 안정적인 판단력과 시장 사이클에 대한 깊은 이해";
    opportunity = "축적된 노하우를 활용하여 초보 투자자들이 놓치는 프리미엄 기회를 선점할 수 있는 시기";
  } else if (experience.includes('초보')) {
    weakness = "부동산 투자 경험 부족으로 인한 시장 변동성에 대한 과민 반응 및 정보 부족 우려";
    risk = "투자 지식 부족으로 인한 잘못된 정보나 추천에 의존할 위험성, 충분한 학습 후 투자 권장";
  }
  
  if (purpose.includes('단기수익')) {
    opportunity = "시장 타이밍을 잘 활용하여 단기간 내 상당한 수익을 올릴 수 있는 기회 포착 가능";
    risk = "단기 수익 추구로 인한 급등락 위험과 세금 부담 증가, 시장 변동성에 따른 손실 가능성 주의";
  } else if (purpose.includes('장기보유')) {
    strength = "장기 보유 전략으로 안정적인 자산 증식과 임대 수익을 통한 꾸준한 현금 흐름 창출 능력";
    weakness = "장기 투자 성향으로 인해 단기 차익 실현 기회를 놓칠 수 있어 유연한 전략 조정 필요";
  }
  
  return { strength, weakness, opportunity, risk };
}

function generateRecommendations(request: RealEstateRequest) {
  const investmentTips = [
    "장기 보유를 전제로 한 투자 계획을 세우세요",
    "입지와 교통 편의성을 최우선으로 고려하세요",
    "레버리지 비율을 적절히 조절하여 리스크를 관리하세요"
  ];
  
  const timingStrategies = [
    "시장 과열기보다는 조정기에 투자 기회를 찾으세요",
    "금리 변동과 부동산 정책을 주시하여 타이밍을 잡으세요",
    "계절적 요인을 고려하여 매매 시점을 조절하세요"
  ];
  
  const locationAdvice = [
    "교통 개발 계획이 있는 지역을 주목하세요",
    "학군과 생활 인프라가 우수한 지역을 우선 고려하세요",
    "재개발이나 재건축 계획이 있는 지역을 체크하세요"
  ];
  
  const riskManagement = [
    "투자 금액의 한도를 미리 정하고 준수하세요",
    "대출 비율을 소득 대비 적정 수준으로 유지하세요",
    "여러 지역이나 물건 유형으로 분산 투자하세요"
  ];
  
  return {
    investment_tips: investmentTips,
    timing_strategies: timingStrategies,
    location_advice: locationAdvice,
    risk_management: riskManagement
  };
}

function generateFuturePredictions(request: RealEstateRequest) {
  const experience = request.investment_experience;
  const timeline = request.investment_timeline;
  
  let thisMonth = "신중한 검토가 필요한 시기입니다. 서두르지 말고 충분히 조사한 후 결정하세요.";
  let nextQuarter = "좋은 투자 기회가 나타날 수 있습니다. 평소 관심 지역의 시장 동향을 주의깊게 살펴보세요.";
  let thisYear = "장기적인 관점에서 안정적인 수익을 기대할 수 있는 해입니다. 꾸준한 투자로 자산을 늘려가세요.";
  
  if (experience.includes('10년 이상')) {
    thisMonth = "풍부한 경험을 바탕으로 시장의 기회를 포착할 수 있는 시기입니다. 적극적인 투자를 고려해보세요.";
    nextQuarter = "부동산 전문가로서의 직감을 믿고 과감한 결정을 내릴 수 있는 분기입니다.";
    thisYear = "포트폴리오의 완성도를 높이고 새로운 투자 영역으로의 확장을 시도해볼 해입니다.";
  } else if (experience.includes('초보')) {
    thisMonth = "기초를 다지는 시기입니다. 안전한 투자부터 시작하여 경험을 쌓아가세요.";
    nextQuarter = "부동산 지식을 꾸준히 학습하며 소액으로 다양한 투자를 경험해보는 분기입니다.";
    thisYear = "부동산 투자의 기본기를 마스터하고 본격적인 투자자로 성장할 수 있는 중요한 해입니다.";
  }
  
  if (timeline.includes('1년 이내')) {
    thisMonth = "단기 투자 목표에 맞는 적절한 물건을 신중히 선별하는 시기입니다.";
    nextQuarter = "시장 변동성에 주의하면서도 빠른 의사결정이 필요한 분기입니다.";
  }
  
  return {
    this_month: thisMonth,
    next_quarter: nextQuarter,
    this_year: thisYear
  };
}

function generateWarningSignsAndFuturePredictions(request: RealEstateRequest) {
  const baseWarnings = [
    "과도한 레버리지 투자는 피하세요",
    "감정적 판단보다는 객관적 데이터에 의존하세요",
    "유행이나 소문에만 의존한 투자는 위험합니다",
    "단기 차익을 노린 무리한 투자는 자제하세요",
    "본인의 재정 능력을 넘어서는 투자는 금물입니다"
  ];
  
  let warningSignsToShow = [...baseWarnings];
  
  if (request.investment_purpose.includes('단기수익')) {
    warningSignsToShow[3] = "단기 수익 추구 시 세금 부담과 시장 변동성 리스크 특히 주의";
    warningSignsToShow.push("급등하는 지역의 고점 매수 위험성 경계");
  }
  
  if (request.investment_experience.includes('초보')) {
    warningSignsToShow[2] = "부동산 투자 초보자는 검증되지 않은 정보나 추천 투자 절대 금지";
    warningSignsToShow.push("복잡한 부동산 상품보다는 단순하고 이해하기 쉬운 투자부터 시작");
  }
  
  if (request.budget_range.includes('10억 이상')) {
    warningSignsToShow[0] = "고액 투자 시 대출 비율과 이자 부담 능력 철저히 검토";
    warningSignsToShow.push("고가 부동산의 유동성 위험과 보유세 부담 고려");
  }
  
  return warningSignsToShow.slice(0, 5);
}

export async function POST(request: NextRequest) {
  try {
    const body: RealEstateRequest = await request.json();
    
    // 필수 필드 검증
    if (!body.name || !body.birth_date || !body.investment_experience) {
      return NextResponse.json(
        { error: '필수 정보가 누락되었습니다.' },
        { status: 400 }
      );
    }

    // GPT API 호출을 위한 프롬프트 생성 (실제 구현 시 사용)
    const prompt = `
사용자 정보:
- 이름: ${body.name}
- 생년월일: ${body.birth_date}
- 나이: ${body.current_age}세
- 투자 경험: ${body.investment_experience}
- 예산 범위: ${body.budget_range}
- 투자 목적: ${body.investment_purpose.join(', ')}
- 선호 지역: ${body.preferred_areas.join(', ')}
- 선호 건물 유형: ${body.property_types.join(', ')}
- 투자 타임라인: ${body.investment_timeline}
- 현재 상황: ${body.current_situation}
- 고민 사항: ${body.concerns}

위 정보를 바탕으로 개인화된 부동산 투자운을 분석해주세요.
`;

    // Mock 응답 (GPT 연동 시 실제 응답으로 대체)
    const fortuneResult: RealEstateFortune = {
      overall_luck: generateOverallLuck(body),
      buying_luck: generateBuyingLuck(body),
      selling_luck: generateSellingLuck(body),
      rental_luck: generateRentalLuck(body),
      location_luck: generateLocationLuck(body),
      analysis: generateAnalysis(body),
      lucky_elements: generateLuckyElements(body),
      recommendations: generateRecommendations(body),
      future_predictions: generateFuturePredictions(body),
      warning_signs: generateWarningSignsAndFuturePredictions(body)
    };

    return NextResponse.json(fortuneResult);
    
  } catch (error) {
    console.error('Lucky realestate API error:', error);
    return NextResponse.json(
      { error: '부동산운 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
} 