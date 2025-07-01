import { NextRequest, NextResponse } from 'next/server';

interface SidejobInfo {
  name: string;
  birth_date: string;
  current_job?: string;
  available_time?: string;
  weekly_hours?: string;
  target_income?: string;
  skills?: string[];
  interests?: string[];
  startup_budget?: string;
  risk_tolerance?: string;
  work_location?: string;
  experience_level?: string;
}

interface SidejobFortune {
  overall_luck: number;
  income_luck: number;
  time_management_luck: number;
  opportunity_luck: number;
  networking_luck: number;
  recommended_sidejobs: {
    top_recommendation: {
      category: string;
      specific_job: string;
      compatibility: number;
      monthly_income_range: string;
      reasons: string[];
      required_skills: string[];
    };
    good_options: Array<{
      category: string;
      specific_job: string;
      compatibility: number;
      income_potential: string;
      time_commitment: string;
    }>;
    challenging_options: Array<{
      category: string;
      compatibility: number;
      challenges: string;
    }>;
  };
  lucky_elements: {
    time: string;
    day: string;
    platform: string;
    color: string;
    partner_type: string;
  };
  timing_advice: {
    start_period: string;
    peak_season: string;
    avoid_period: string;
  };
  skill_development: {
    priority_skills: string[];
    learning_resources: string[];
    certification_recommendations: string[];
  };
  financial_planning: {
    initial_investment: string;
    break_even_timeline: string;
    scaling_strategy: string;
    tax_considerations: string;
  };
  personalized_advice: {
    strengths: string;
    time_optimization: string;
    growth_strategy: string;
    networking_tips: string;
  };
  success_factors: string[];
  warning_signs: string[];
}

export async function POST(request: NextRequest) {
  try {
    const sidejobInfo: SidejobInfo = await request.json();
    
    // 필수 필드 검증
    if (!sidejobInfo.name || !sidejobInfo.birth_date) {
      return NextResponse.json(
        { error: '이름과 생년월일은 필수 항목입니다.' },
        { status: 400 }
      );
    }

    const sidejobFortune = await analyzeSidejobFortune(sidejobInfo);
    return NextResponse.json(sidejobFortune);
    
  } catch (error) {
    console.error('Lucky sidejob API error:', error);
    return NextResponse.json(
      { error: '부업 운세 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

async function analyzeSidejobFortune(info: SidejobInfo): Promise<SidejobFortune> {
  // 생년월일 기반 기본 점수 계산
  const birthYear = parseInt(info.birth_date.substring(0, 4));
  const birthMonth = parseInt(info.birth_date.substring(5, 7));
  const birthDay = parseInt(info.birth_date.substring(8, 10));
  
  const baseScore = ((birthYear + birthMonth + birthDay) % 30) + 65;
  
  // 사용 가능 시간별 점수 조정
  let timeBonus = 0;
  switch (info.weekly_hours) {
    case '20시간 이상':
      timeBonus = 15;
      break;
    case '15-20시간':
      timeBonus = 10;
      break;
    case '10-15시간':
      timeBonus = 5;
      break;
    case '5-10시간':
      timeBonus = 0;
      break;
    case '5시간 이하':
      timeBonus = -5;
      break;
    default:
      timeBonus = 0;
  }

  // 목표 수입별 현실성 조정
  let incomeBonus = 0;
  switch (info.target_income) {
    case '50만원 이하':
      incomeBonus = 10; // 현실적
      break;
    case '50-100만원':
      incomeBonus = 8;
      break;
    case '100-200만원':
      incomeBonus = 5;
      break;
    case '200-300만원':
      incomeBonus = 0;
      break;
    case '300만원 이상':
      incomeBonus = -5; // 도전적
      break;
    default:
      incomeBonus = 0;
  }

  // 위험 성향별 조정
  let riskBonus = 0;
  switch (info.risk_tolerance) {
    case '안정형':
      riskBonus = 8; // 부업에 적합
      break;
    case '중간형':
      riskBonus = 5;
      break;
    case '도전형':
      riskBonus = 0;
      break;
    default:
      riskBonus = 0;
  }

  // 스킬 보유 보너스
  const skillBonus = info.skills ? Math.min(info.skills.length * 3, 12) : 0;

  // 관심 분야 다양성 보너스
  const interestBonus = info.interests ? Math.min(info.interests.length * 2, 8) : 0;

  const overallLuck = Math.max(45, Math.min(98, baseScore + timeBonus + incomeBonus + riskBonus + skillBonus + interestBonus));

  // 추천 부업 생성
  const recommendedSidejobs = generateSidejobRecommendations(info, overallLuck);

  // 행운 요소 계산
  const luckyElements = calculateSidejobLuckyElements(birthDay, birthMonth);

  // 타이밍 조언
  const timingAdvice = generateSidejobTimingAdvice(birthMonth, info.available_time);

  // 스킬 개발 조언
  const skillDevelopment = generateSkillDevelopment(info);

  // 재정 계획
  const financialPlanning = generateFinancialPlanning(info);

  return {
    overall_luck: overallLuck,
    income_luck: Math.max(40, Math.min(95, overallLuck + Math.floor(Math.random() * 10) - 5)),
    time_management_luck: Math.max(50, Math.min(100, overallLuck + Math.floor(Math.random() * 12) - 6)),
    opportunity_luck: Math.max(45, Math.min(95, overallLuck + Math.floor(Math.random() * 15) - 7)),
    networking_luck: Math.max(55, Math.min(100, overallLuck + Math.floor(Math.random() * 8) - 4)),
    recommended_sidejobs: recommendedSidejobs,
    lucky_elements: luckyElements,
    timing_advice: timingAdvice,
    skill_development: skillDevelopment,
    financial_planning: financialPlanning,
    personalized_advice: generateSidejobPersonalizedAdvice(info, overallLuck),
    success_factors: generateSidejobSuccessFactors(info),
    warning_signs: generateSidejobWarningSignsForJob(info)
  };
}

function generateSidejobRecommendations(info: SidejobInfo, luck: number): SidejobFortune['recommended_sidejobs'] {
  const sidejobCategories = [
    {
      category: '온라인 비즈니스',
      jobs: [
        { name: '블로그/유튜브 운영', income: '30-150만원', skills: ['콘텐츠 제작', '마케팅'] },
        { name: '온라인 쇼핑몰', income: '50-300만원', skills: ['상품 기획', '고객 서비스'] },
        { name: '디지털 마케팅 대행', income: '40-200만원', skills: ['SNS 마케팅', 'SEO'] },
        { name: '온라인 강의 제작', income: '20-100만원', skills: ['전문 지식', '영상 편집'] }
      ]
    },
    {
      category: '프리랜싱',
      jobs: [
        { name: '디자인 작업', income: '40-180만원', skills: ['그래픽 디자인', '포토샵'] },
        { name: '번역/통역', income: '30-120만원', skills: ['외국어', '번역 스킬'] },
        { name: '개발/프로그래밍', income: '60-400만원', skills: ['프로그래밍', '문제해결'] },
        { name: '글쓰기/편집', income: '25-100만원', skills: ['글쓰기', '편집'] }
      ]
    },
    {
      category: '오프라인 서비스',
      jobs: [
        { name: '과외/학원 강사', income: '50-200만원', skills: ['교육', '소통'] },
        { name: '펜션/민박 운영', income: '30-150만원', skills: ['서비스', '관리'] },
        { name: '배달/운송 서비스', income: '40-120만원', skills: ['운전', '시간관리'] },
        { name: '핸드메이드 제품 판매', income: '20-80만원', skills: ['수공예', '마케팅'] }
      ]
    },
    {
      category: '투자/재테크',
      jobs: [
        { name: '부동산 임대업', income: '50-500만원', skills: ['부동산 지식', '관리'] },
        { name: '주식/코인 투자', income: '0-무제한', skills: ['투자 분석', '리스크 관리'] },
        { name: 'P2P 투자', income: '10-50만원', skills: ['재테크', '위험관리'] },
        { name: '중고거래', income: '20-100만원', skills: ['시장 분석', '협상'] }
      ]
    }
  ];

  // 사용자 관심사와 스킬에 맞는 카테고리 우선순위 결정
  let preferredCategories = sidejobCategories;
  
  if (info.interests?.includes('IT/디지털')) {
    preferredCategories = [sidejobCategories[0], sidejobCategories[1], sidejobCategories[2], sidejobCategories[3]];
  } else if (info.interests?.includes('교육/강의')) {
    preferredCategories = [sidejobCategories[2], sidejobCategories[1], sidejobCategories[0], sidejobCategories[3]];
  } else if (info.interests?.includes('투자/재테크')) {
    preferredCategories = [sidejobCategories[3], sidejobCategories[0], sidejobCategories[1], sidejobCategories[2]];
  }

  const topCategory = preferredCategories[0];
  const topJob = topCategory.jobs[Math.floor(Math.random() * topCategory.jobs.length)];

  return {
    top_recommendation: {
      category: topCategory.category,
      specific_job: topJob.name,
      compatibility: Math.max(85, Math.min(98, luck + Math.floor(Math.random() * 10))),
      monthly_income_range: topJob.income,
      reasons: [
        '개인 관심사와 높은 연관성',
        '현재 시장에서 수요 증가',
        '시간 투자 대비 효율성',
        '장기적 성장 가능성'
      ],
      required_skills: topJob.skills
    },
    good_options: preferredCategories.slice(1, 3).map(category => {
      const job = category.jobs[Math.floor(Math.random() * category.jobs.length)];
      return {
        category: category.category,
        specific_job: job.name,
        compatibility: Math.max(70, Math.min(90, luck + Math.floor(Math.random() * 8) - 5)),
        income_potential: job.income,
        time_commitment: info.weekly_hours === '20시간 이상' ? '높음' : info.weekly_hours === '5시간 이하' ? '낮음' : '중간'
      };
    }),
    challenging_options: preferredCategories.slice(3, 4).map(category => ({
      category: category.category,
      compatibility: Math.max(50, Math.min(75, luck - Math.floor(Math.random() * 15))),
      challenges: '추가 학습과 초기 투자가 필요한 분야'
    }))
  };
}

function calculateSidejobLuckyElements(day: number, month: number): SidejobFortune['lucky_elements'] {
  const times = ['저녁 7-9시', '주말 오후', '새벽 6-8시', '점심시간', '주중 밤 9-11시'];
  const days = ['토요일', '일요일', '수요일', '금요일', '목요일'];
  const platforms = ['인스타그램', '유튜브', '블로그', '온라인 마켓', '네이버 카페'];
  const colors = ['오렌지', '골드', '그린', '블루', '레드'];
  const partners = ['친구', '동료', '온라인 파트너', '가족', '업계 전문가'];

  return {
    time: times[day % times.length],
    day: days[month % days.length],
    platform: platforms[(day + month) % platforms.length],
    color: colors[(day * month) % colors.length],
    partner_type: partners[(day + month * 2) % partners.length]
  };
}

function generateSidejobTimingAdvice(birthMonth: number, availableTime?: string): SidejobFortune['timing_advice'] {
  const isLimitedTime = availableTime === '5시간 이하' || availableTime === '5-10시간';
  
  return {
    start_period: isLimitedTime ? 
      '작은 것부터 시작하여 3개월 후 본격 진행하세요' :
      '2-3월이 새로운 부업을 시작하기 좋은 시기입니다',
    peak_season: birthMonth <= 6 ? 
      '하반기가 수익 증대의 황금기입니다' :
      '상반기에 큰 성과를 기대할 수 있습니다',
    avoid_period: '연말연시와 휴가철에는 새로운 시도보다 기존 사업 정리에 집중하세요'
  };
}

function generateSkillDevelopment(info: SidejobInfo): SidejobFortune['skill_development'] {
  const currentSkills = info.skills || [];
  
  const essentialSkills = ['디지털 마케팅', '시간 관리', '고객 서비스', '재정 관리'];
  const advancedSkills = ['데이터 분석', '콘텐츠 제작', '네트워킹', '브랜딩'];
  
  const prioritySkills = essentialSkills
    .filter(skill => !currentSkills.includes(skill))
    .concat(advancedSkills.filter(skill => !currentSkills.includes(skill)))
    .slice(0, 4);

  return {
    priority_skills: prioritySkills,
    learning_resources: [
      '온라인 강의 플랫폼 (유데미, 인프런)',
      '유튜브 무료 강의',
      '도서관 관련 서적',
      '업계 블로그 및 뉴스레터'
    ],
    certification_recommendations: [
      '구글 애널리틱스 자격증',
      '네이버 검색광고 자격증',
      '소상공인 창업 교육 수료증',
      '디지털 마케팅 관련 자격증'
    ]
  };
}

function generateFinancialPlanning(info: SidejobInfo): SidejobFortune['financial_planning'] {
  const budget = info.startup_budget || '50만원 이하';
  
  return {
    initial_investment: budget === '200만원 이상' ? 
      '충분한 자본으로 안정적 시작이 가능합니다' :
      '작은 자본으로 시작하여 점진적으로 확장하세요',
    break_even_timeline: info.target_income === '50만원 이하' ? 
      '3-6개월 내 손익분기점 달성 가능' :
      '6-12개월의 인내심이 필요합니다',
    scaling_strategy: '초기 성과 확인 후 재투자를 통한 단계적 확장 추천',
    tax_considerations: '월 소득 33만원 초과 시 종합소득세 신고 준비 필요'
  };
}

function generateSidejobPersonalizedAdvice(info: SidejobInfo, luck: number): SidejobFortune['personalized_advice'] {
  const isHighLuck = luck >= 80;
  const isLimitedTime = info.weekly_hours === '5시간 이하' || info.weekly_hours === '5-10시간';

  return {
    strengths: isHighLuck ? 
      '높은 성공 가능성과 좋은 타이밍을 가지고 있습니다' :
      '꾸준함과 신중함으로 안정적인 성과를 만들 수 있습니다',
    time_optimization: isLimitedTime ?
      '제한된 시간을 최대한 활용하는 효율적 전략이 필요합니다' :
      '충분한 시간을 활용하여 다양한 기회를 시도해보세요',
    growth_strategy: '작은 성공을 통해 경험을 쌓고 점진적으로 규모를 키워가세요',
    networking_tips: '온라인 커뮤니티와 오프라인 모임을 적극 활용하여 정보를 교환하세요'
  };
}

function generateSidejobSuccessFactors(info: SidejobInfo): string[] {
  const factors = [
    '꾸준한 시간 투자와 일정 관리',
    '본업과의 균형 유지',
    '고객 만족도 최우선 고려',
    '시장 트렌드 지속적 모니터링',
    '재정 관리와 세무 준비',
    '네트워킹과 마케팅 활동',
    '품질 유지를 위한 학습',
    '장기적 관점의 사업 계획'
  ];

  return factors.sort(() => 0.5 - Math.random()).slice(0, 5);
}

function generateSidejobWarningSignsForJob(info: SidejobInfo): string[] {
  return [
    '본업에 지장을 주는 과도한 시간 투자 금지',
    '초기 투자 회수에만 급급하지 마세요',
    '불법적이거나 의심스러운 제안 경계',
    '무리한 확장으로 인한 품질 저하 주의',
    '세무 신고 의무 소홀히 하지 마세요',
    '고객 클레임 대응 소홀 금지',
    '경쟁업체 무분별한 모방 자제',
    '건강과 개인 시간 무시하지 마세요'
  ];
} 