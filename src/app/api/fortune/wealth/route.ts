import { NextRequest, NextResponse } from 'next/server';
import { selectGPTModel, callGPTAPI } from '@/config/ai-models';

interface WealthInfo {
  name: string;
  birth_date: string;
  current_income?: string;
  monthly_expenses?: string;
  savings_amount?: string;
  debt_amount?: string;
  investment_experience?: string;
  risk_tolerance?: string;
  financial_goals?: string[];
  spending_habits?: string;
  income_sources?: string[];
  financial_stress_level?: string;
}

interface WealthFortune {
  overall_luck: number;
  income_luck: number;
  saving_luck: number;
  investment_luck: number;
  debt_management_luck: number;
  financial_planning: {
    monthly_analysis: {
      recommended_saving_rate: string;
      expense_optimization: string[];
      income_improvement_tips: string[];
    };
    investment_advice: {
      suitable_products: Array<{
        category: string;
        risk_level: string;
        expected_return: string;
        recommendation_reason: string;
      }>;
      portfolio_allocation: {
        conservative: number;
        moderate: number;
        aggressive: number;
      };
    };
    debt_strategy: {
      priority_debts: string[];
      repayment_strategy: string;
      consolidation_advice: string;
    };
  };
  lucky_elements: {
    time: string;
    day: string;
    color: string;
    direction: string;
    lucky_numbers: number[];
  };
  wealth_timing: {
    best_earning_period: string;
    investment_timing: string;
    saving_focus_period: string;
    debt_payoff_timing: string;
  };
  personalized_advice: {
    strengths: string;
    improvement_areas: string;
    goal_achievement_strategy: string;
    emergency_fund_advice: string;
  };
  monthly_action_plan: {
    week1: string[];
    week2: string[];
    week3: string[];
    week4: string[];
  };
  success_factors: string[];
  warning_signs: string[];
}

export async function POST(request: NextRequest) {
  try {
    const wealthInfo: WealthInfo = await request.json();
    
    // 필수 필드 검증
    if (!wealthInfo.name || !wealthInfo.birth_date) {
      return NextResponse.json(
        { error: '이름과 생년월일은 필수 항목입니다.' },
        { status: 400 }
      );
    }

    const wealthFortune = await analyzeWealthFortune(wealthInfo);
    return NextResponse.json(wealthFortune);
    
  } catch (error) {
    console.error('Wealth API error:', error);
    return NextResponse.json(
      { error: '금전운 분석 중 오류가 발생했습니다.' },
      { status: 500 }
    );
  }
}

async function analyzeWealthFortune(info: WealthInfo): Promise<WealthFortune> {
  try {
    // GPT 모델 선택 (재정 상담용)
    const model = selectGPTModel('daily', 'text');
    
    // GPT API 호출을 위한 프롬프트 생성
    const prompt = `
당신은 전문 재정 컨설턴트입니다. 다음 사용자 정보를 바탕으로 개인화된 금전운과 재정 조언을 제공해주세요.

사용자 정보:
- 이름: ${info.name}
- 생년월일: ${info.birth_date}
- 월 수입: ${info.current_income || '정보 없음'}만원
- 월 지출: ${info.monthly_expenses || '정보 없음'}만원
- 현재 저축액: ${info.savings_amount || '정보 없음'}만원
- 부채 금액: ${info.debt_amount || '0'}만원
- 투자 경험: ${info.investment_experience || '정보 없음'}
- 위험 성향: ${info.risk_tolerance || '정보 없음'}
- 재정 목표: ${info.financial_goals?.join(', ') || '정보 없음'}
- 수입원: ${info.income_sources?.join(', ') || '정보 없음'}
- 재정 스트레스: ${info.financial_stress_level || '정보 없음'}

다음 JSON 형식으로 응답해주세요:
{
  "overall_luck": 85,
  "income_luck": 78,
  "saving_luck": 82,
  "investment_luck": 75,
  "debt_management_luck": 88,
  "personalized_advice": {
    "strengths": "재정 관리의 주요 강점",
    "improvement_areas": "개선이 필요한 영역",
    "goal_achievement_strategy": "목표 달성 전략",
    "emergency_fund_advice": "비상금 조언"
  },
  "future_predictions": {
    "this_week": "이번 주 금전운",
    "this_month": "이번 달 금전운",
    "this_season": "이번 시즌 금전운"
  }
}
`;

    // GPT API 호출
    const gptResult = await callGPTAPI(prompt, model);
    
    // GPT 응답이 올바른 형식인지 검증 및 변환
    if (gptResult && typeof gptResult === 'object' && 
        typeof gptResult.overall_luck === 'number') {
      console.log('GPT API 호출 성공');
      
      // GPT 응답을 기반으로 종합 결과 생성
      const birthYear = parseInt(info.birth_date.substring(0, 4));
      const birthMonth = parseInt(info.birth_date.substring(5, 7));
      const birthDay = parseInt(info.birth_date.substring(8, 10));
      
      return {
        overall_luck: gptResult.overall_luck,
        income_luck: gptResult.income_luck,
        saving_luck: gptResult.saving_luck,
        investment_luck: gptResult.investment_luck,
        debt_management_luck: gptResult.debt_management_luck,
        financial_planning: generateFinancialPlanning(info, gptResult.overall_luck),
        lucky_elements: calculateWealthLuckyElements(birthDay, birthMonth),
        wealth_timing: generateWealthTiming(birthMonth, info.investment_experience),
        personalized_advice: gptResult.personalized_advice || {
          strengths: '신중하고 안정적인 재정 운용이 강점입니다',
          improvement_areas: '수입원 다변화와 절약을 통한 저축률 증대가 중요합니다',
          goal_achievement_strategy: '단계별 목표 설정과 정기적인 점검을 통해 착실히 진행하세요',
          emergency_fund_advice: '먼저 월 지출의 3개월분 비상금부터 만들어보세요'
        },
        monthly_action_plan: generateMonthlyActionPlan(info),
        success_factors: generateWealthSuccessFactors(info),
        warning_signs: generateWealthWarningSignsForJob(info)
      };
    } else {
      throw new Error('GPT 응답 형식 오류');
    }
    
  } catch (error) {
    console.error('GPT API 호출 실패, 백업 로직 사용:', error);
    
    // 백업 로직: 기존 알고리즘 실행
    return generatePersonalizedWealthFortune(info);
  }
}

function generatePersonalizedWealthFortune(info: WealthInfo): WealthFortune {
  // 생년월일 기반 기본 점수 계산
  const birthYear = parseInt(info.birth_date.substring(0, 4));
  const birthMonth = parseInt(info.birth_date.substring(5, 7));
  const birthDay = parseInt(info.birth_date.substring(8, 10));
  
  const baseScore = ((birthYear + birthMonth + birthDay) % 30) + 65;
  
  // 재정 상태별 점수 조정
  let financialBonus = 0;
  
  // 저축률 계산 및 보너스
  if (info.current_income && info.monthly_expenses && info.savings_amount) {
    const income = parseFloat(info.current_income.replace(/[^\d]/g, '')) || 0;
    const expenses = parseFloat(info.monthly_expenses.replace(/[^\d]/g, '')) || 0;
    const savings = parseFloat(info.savings_amount.replace(/[^\d]/g, '')) || 0;
    
    if (income > 0) {
      const savingRate = savings / (income * 12); // 연간 저축률
      if (savingRate >= 0.3) financialBonus += 15; // 30% 이상
      else if (savingRate >= 0.2) financialBonus += 10; // 20% 이상
      else if (savingRate >= 0.1) financialBonus += 5; // 10% 이상
      
      const expenseRatio = expenses / income;
      if (expenseRatio <= 0.6) financialBonus += 10; // 지출 60% 이하
      else if (expenseRatio <= 0.8) financialBonus += 5; // 지출 80% 이하
    }
  }
  
  // 투자 경험별 보너스
  let investmentBonus = 0;
  switch (info.investment_experience) {
    case '10년 이상':
      investmentBonus = 15;
      break;
    case '5-10년':
      investmentBonus = 10;
      break;
    case '1-5년':
      investmentBonus = 5;
      break;
    case '1년 이하':
      investmentBonus = 0;
      break;
    case '경험 없음':
      investmentBonus = -5;
      break;
    default:
      investmentBonus = 0;
  }
  
  // 위험 성향별 조정
  let riskBonus = 0;
  switch (info.risk_tolerance) {
    case '안정형':
      riskBonus = 8; // 금전운에서는 안정형이 유리
      break;
    case '중간형':
      riskBonus = 5;
      break;
    case '공격형':
      riskBonus = 0;
      break;
    default:
      riskBonus = 0;
  }
  
  // 재정 스트레스 수준별 조정
  let stressBonus = 0;
  switch (info.financial_stress_level) {
    case '낮음':
      stressBonus = 10;
      break;
    case '보통':
      stressBonus = 5;
      break;
    case '높음':
      stressBonus = -5;
      break;
    case '매우 높음':
      stressBonus = -10;
      break;
    default:
      stressBonus = 0;
  }
  
  const overallLuck = Math.max(45, Math.min(98, baseScore + financialBonus + investmentBonus + riskBonus + stressBonus));
  
  // 개인화된 세부 점수 계산 (Math.random 제거)
  const incomeVariation = (birthDay % 10) - 5;
  const savingVariation = (birthMonth % 12) - 6;
  const investmentVariation = ((birthDay + birthMonth) % 15) - 7;
  const debtVariation = (birthYear % 8) - 4;
  
  // 재정 계획 생성
  const financialPlanning = generateFinancialPlanning(info, overallLuck);
  
  // 행운 요소 계산
  const luckyElements = calculateWealthLuckyElements(birthDay, birthMonth);
  
  // 타이밍 조언
  const wealthTiming = generateWealthTiming(birthMonth, info.investment_experience);
  
  // 월별 액션 플랜
  const monthlyActionPlan = generateMonthlyActionPlan(info);

  return {
    overall_luck: overallLuck,
    income_luck: Math.max(40, Math.min(95, overallLuck + incomeVariation)),
    saving_luck: Math.max(50, Math.min(100, overallLuck + savingVariation)),
    investment_luck: Math.max(45, Math.min(95, overallLuck + investmentVariation)),
    debt_management_luck: Math.max(55, Math.min(100, overallLuck + debtVariation)),
    financial_planning: financialPlanning,
    lucky_elements: luckyElements,
    wealth_timing: wealthTiming,
    personalized_advice: generateWealthPersonalizedAdvice(info, overallLuck),
    monthly_action_plan: monthlyActionPlan,
    success_factors: generateWealthSuccessFactors(info),
    warning_signs: generateWealthWarningSignsForJob(info)
  };
}

function generateFinancialPlanning(info: WealthInfo, luck: number): WealthFortune['financial_planning'] {
  // 월 분석
  const monthlyAnalysis = {
    recommended_saving_rate: info.current_income ? 
      (parseFloat(info.current_income.replace(/[^\d]/g, '')) >= 500 ? '20-30%' : '10-20%') : '20%',
    expense_optimization: [
      '고정비 재검토 (통신비, 보험료, 구독 서비스)',
      '외식비 및 배달비 줄이기',
      '불필요한 멤버십 해지',
      '쇼핑 전 24시간 고민 원칙 적용'
    ],
    income_improvement_tips: [
      '부업 또는 사이드 프로젝트 시작',
      '전문성 향상을 위한 교육 투자',
      '네트워킹 활동 강화',
      '성과급 협상 준비'
    ]
  };

  // 투자 조언
  const riskLevel = info.risk_tolerance || '중간형';
  const investmentProducts = [
    {
      category: '예금/적금',
      risk_level: '낮음',
      expected_return: '2-4%',
      recommendation_reason: '안전한 기초 자산으로 활용'
    },
    {
      category: riskLevel === '안정형' ? '채권형 펀드' : '주식형 펀드',
      risk_level: riskLevel === '안정형' ? '낮음' : '중간',
      expected_return: riskLevel === '안정형' ? '3-6%' : '5-10%',
      recommendation_reason: '중장기 자산 증식을 위한 핵심 투자'
    },
    {
      category: 'ETF',
      risk_level: '중간',
      expected_return: '4-8%',
      recommendation_reason: '분산투자와 비용 효율성'
    }
  ];

  const portfolioAllocation = riskLevel === '안정형' 
    ? { conservative: 70, moderate: 25, aggressive: 5 }
    : riskLevel === '공격형'
    ? { conservative: 20, moderate: 40, aggressive: 40 }
    : { conservative: 40, moderate: 45, aggressive: 15 };

  // 부채 전략
  const debtStrategy = {
    priority_debts: ['고금리 카드대출', '기타 소액대출', '학자금 대출', '주택담보대출'],
    repayment_strategy: info.debt_amount ? 
      '고금리 부채 우선 상환 후 낮은 금리 순으로 정리' :
      '현재 부채가 적어 예방 중심의 관리 필요',
    consolidation_advice: '금리 7% 이상 부채는 통합대출 검토 권장'
  };

  return {
    monthly_analysis: monthlyAnalysis,
    investment_advice: {
      suitable_products: investmentProducts,
      portfolio_allocation: portfolioAllocation
    },
    debt_strategy: debtStrategy
  };
}

function calculateWealthLuckyElements(day: number, month: number): WealthFortune['lucky_elements'] {
  const times = ['오전 10-12시', '오후 2-4시', '저녁 6-8시', '오후 1-3시', '오전 9-11시'];
  const days = ['화요일', '목요일', '금요일', '수요일', '월요일'];
  const colors = ['골드', '브라운', '그린', '네이비', '실버'];
  const directions = ['남동쪽', '남서쪽', '동쪽', '북쪽', '서쪽'];
  
  const luckyNumbers = [
    (day % 9) + 1,
    (month % 9) + 1,
    ((day + month) % 9) + 1,
    ((day * month) % 9) + 1,
    ((day + month * 2) % 9) + 1
  ];

  return {
    time: times[day % times.length],
    day: days[month % days.length],
    color: colors[(day + month) % colors.length],
    direction: directions[(day * month) % directions.length],
    lucky_numbers: luckyNumbers
  };
}

function generateWealthTiming(birthMonth: number, experience?: string): WealthFortune['wealth_timing'] {
  const isExperienced = experience === '5-10년' || experience === '10년 이상';
  
  return {
    best_earning_period: birthMonth <= 6 ? 
      '하반기가 수입 증대의 기회입니다' :
      '상반기에 적극적인 수입 활동을 추진하세요',
    investment_timing: isExperienced ?
      '시장 조정기를 기회로 활용하세요' :
      '점진적이고 꾸준한 투자가 효과적입니다',
    saving_focus_period: '연초와 연말이 저축 계획 점검의 적기입니다',
    debt_payoff_timing: '보너스나 임시 수입이 있을 때 부채 상환에 집중하세요'
  };
}

function generateMonthlyActionPlan(info: WealthInfo): WealthFortune['monthly_action_plan'] {
  return {
    week1: [
      '월 예산 계획 수립 및 목표 설정',
      '고정 지출 항목 점검',
      '투자 포트폴리오 현황 확인'
    ],
    week2: [
      '변동 지출 모니터링',
      '추가 수입원 탐색',
      '재정 목표 진행상황 체크'
    ],
    week3: [
      '투자 상품 수익률 점검',
      '불필요한 지출 항목 정리',
      '다음 달 계획 준비'
    ],
    week4: [
      '월간 수입/지출 결산',
      '저축 목표 달성도 확인',
      '다음 달 예산 조정안 마련'
    ]
  };
}

function generateWealthPersonalizedAdvice(info: WealthInfo, luck: number): WealthFortune['personalized_advice'] {
  const isHighLuck = luck >= 80;
  const hasHighIncome = info.current_income && parseFloat(info.current_income.replace(/[^\d]/g, '')) >= 500;

  return {
    strengths: isHighLuck ? 
      '재정 관리 능력이 뛰어나며 투자 감각이 좋습니다' :
      '신중하고 안정적인 재정 운용이 강점입니다',
    improvement_areas: hasHighIncome ?
      '고소득을 활용한 적극적인 자산 증식 전략이 필요합니다' :
      '수입원 다변화와 절약을 통한 저축률 증대가 중요합니다',
    goal_achievement_strategy: '단계별 목표 설정과 정기적인 점검을 통해 착실히 진행하세요',
    emergency_fund_advice: info.savings_amount ?
      '비상금은 월 지출의 6개월분 이상 유지하는 것이 안전합니다' :
      '먼저 월 지출의 3개월분 비상금부터 만들어보세요'
  };
}

function generateWealthSuccessFactors(info: WealthInfo): string[] {
  const factors = [
    '꾸준한 가계부 작성과 지출 관리',
    '명확한 재정 목표 설정과 실행',
    '리스크 관리를 통한 안전한 투자',
    '부채 최소화와 신용 관리',
    '다양한 수입원 확보 노력',
    '장기적 관점의 자산 증식',
    '정기적인 재정 상황 점검',
    '전문가 조언 활용과 학습'
  ];

  return factors.sort(() => 0.5 - Math.random()).slice(0, 5);
}

function generateWealthWarningSignsForJob(info: WealthInfo): string[] {
  return [
    '감정적 투자 결정 피하기',
    '고수익 보장 상품 의심하기',
    '과도한 대출이나 레버리지 자제',
    '투자 원금보다 큰 손실 방지',
    '허위 정보나 소문에 현혹되지 마세요',
    '급작스러운 대규모 지출 신중히 고려',
    '신용카드 과다 사용 주의',
    '재정 계획 없는 투자 금지'
  ];
} 