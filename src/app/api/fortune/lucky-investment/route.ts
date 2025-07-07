import { NextRequest, NextResponse } from 'next/server';
import { selectGPTModel, callGPTAPI } from '@/config/ai-models';
import { withAuth, AuthenticatedRequest } from '@/middleware/auth';
import { createSuccessResponse, createErrorResponse, createFortuneResponse, handleApiError } from '@/lib/api-response-utils';

import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";
interface InvestmentRequest {
  name: string;
  birth_date: string;
  current_age: string;
  monthly_income: string;
  investment_experience: string;
  risk_tolerance: string;
  investment_goals: string[];
  preferred_assets: string[];
  investment_amount: string;
  investment_period: string;
  financial_goal: string;
  current_situation: string;
}

interface InvestmentFortune {
  overall_luck: number;
  investment_luck: number;
  trading_luck: number;
  profit_luck: number;
  timing_luck: number;
  analysis: {
    strength: string;
    weakness: string;
    opportunity: string;
    risk: string;
  };
  lucky_assets: string[];
  lucky_timing: {
    best_months: string[];
    best_days: string[];
    best_time: string;
  };
  recommendations: {
    investment_tips: string[];
    risk_management: string[];
    timing_strategies: string[];
    portfolio_advice: string[];
  };
  future_predictions: {
    this_month: string;
    next_quarter: string;
    this_year: string;
  };
  lucky_numbers: number[];
  warning_signs: string[];
}

function generateOverallLuck(request: InvestmentRequest): number {
  let baseScore = 70;
  
  // 투자 경험에 따른 점수
  if (request.investment_experience.includes('10년 이상')) baseScore += 15;
  else if (request.investment_experience.includes('5-10년')) baseScore += 10;
  else if (request.investment_experience.includes('3-5년')) baseScore += 5;
  else if (request.investment_experience.includes('초보')) baseScore -= 5;
  
  // 위험 성향에 따른 점수
  if (request.risk_tolerance.includes('안정형')) baseScore += 8;
  else if (request.risk_tolerance.includes('중위험')) baseScore += 5;
  else if (request.risk_tolerance.includes('고위험')) baseScore -= 3;
  
  // 투자 목표 다양성
  if (request.investment_goals.length >= 3) baseScore += 5;
  
  // deterministic random 사용
  const rng = createDeterministicRandom(request.name, getTodayDateString(), 'overall-luck');
  return Math.max(50, Math.min(95, baseScore + rng.randomInt(0, 14) - 7));
}

function generateInvestmentLuck(request: InvestmentRequest): number {
  let baseScore = 75;
  
  // 투자 금액 적정성
  const income = parseInt(request.monthly_income.replace(/[^0-9]/g, '')) || 0;
  const amount = parseInt(request.investment_amount.replace(/[^0-9]/g, '')) || 0;
  if (income > 0 && amount <= income * 0.3) baseScore += 10;
  else if (amount > income * 0.5) baseScore -= 10;
  
  // 투자 기간
  if (request.investment_period.includes('10년') || request.investment_period.includes('장기')) baseScore += 10;
  else if (request.investment_period.includes('5년')) baseScore += 5;
  else if (request.investment_period.includes('1년 이하')) baseScore -= 5;
  
  // deterministic random 사용
  const rng = createDeterministicRandom(request.name, getTodayDateString(), 'investment-luck');
  return Math.max(45, Math.min(100, baseScore + rng.randomInt(0, 19) - 10));
}

function generateTradingLuck(request: InvestmentRequest): number {
  let baseScore = 65;
  
  // 투자 경험과 트레이딩 능력
  if (request.investment_experience.includes('10년 이상')) baseScore += 20;
  else if (request.investment_experience.includes('5-10년')) baseScore += 15;
  else if (request.investment_experience.includes('3-5년')) baseScore += 8;
  
  // 위험 성향 (트레이딩은 어느 정도 위험 감수 필요)
  if (request.risk_tolerance.includes('고위험')) baseScore += 10;
  else if (request.risk_tolerance.includes('중위험')) baseScore += 5;
  else if (request.risk_tolerance.includes('안정형')) baseScore -= 5;
  
  // deterministic random 사용
  const rng = createDeterministicRandom(request.name, getTodayDateString(), 'trading-luck');
  return Math.max(40, Math.min(95, baseScore + rng.randomInt(0, 19) - 10));
}

function generateProfitLuck(request: InvestmentRequest): number {
  let baseScore = 70;
  
  // 다양한 자산 선호도
  if (request.preferred_assets.includes('주식') && request.preferred_assets.includes('부동산')) baseScore += 10;
  if (request.preferred_assets.includes('ETF') || request.preferred_assets.includes('펀드')) baseScore += 5;
  
  // 재정 목표의 현실성
  if (request.financial_goal.includes('안정') || request.financial_goal.includes('꾸준')) baseScore += 8;
  else if (request.financial_goal.includes('단기') || request.financial_goal.includes('급격')) baseScore -= 5;
  
  // deterministic random 사용
  const rng = createDeterministicRandom(request.name, getTodayDateString(), 'profit-luck');
  return Math.max(50, Math.min(100, baseScore + rng.randomInt(0, 14) - 7));
}

function generateTimingLuck(request: InvestmentRequest): number {
  let baseScore = 65;
  
  // 생년월일 기반 간단한 타이밍 운
  const birthDate = new Date(request.birth_date);
  const month = birthDate.getMonth() + 1;
  const day = birthDate.getDate();
  
  // 특정 월에 태어난 경우 타이밍 운 보너스
  if ([3, 6, 9, 12].includes(month)) baseScore += 8;
  if (day % 7 === 0) baseScore += 5; // 7의 배수
  
  // 현재 상황에 따른 조정
  if (request.current_situation.includes('안정') || request.current_situation.includes('여유')) baseScore += 10;
  else if (request.current_situation.includes('어려움') || request.current_situation.includes('급함')) baseScore -= 5;
  
  // deterministic random 사용
  const rng = createDeterministicRandom(request.name, getTodayDateString(), 'timing-luck');
  return Math.max(55, Math.min(95, baseScore + rng.randomInt(0, 19) - 10));
}

function generateLuckyAssets(request: InvestmentRequest): string[] {
  const allAssets = ["주식", "부동산", "채권", "금/귀금속", "펀드", "ETF", "암호화폐", "REIT", "원자재"];
  
  // 사용자 선호 자산을 우선으로 하되, 추가 추천
  let recommendations = [...request.preferred_assets];
  
  // 위험 성향에 따른 추천
  if (request.risk_tolerance.includes('안정형')) {
    if (!recommendations.includes('채권')) recommendations.push('채권');
    if (!recommendations.includes('금/귀금속')) recommendations.push('금/귀금속');
  } else if (request.risk_tolerance.includes('고위험')) {
    if (!recommendations.includes('주식')) recommendations.push('주식');
    if (!recommendations.includes('암호화폐')) recommendations.push('암호화폐');
  }
  
  // 3개까지 제한
  return recommendations.slice(0, 3);
}

function generateLuckyTiming(request: InvestmentRequest) {
  const birthDate = new Date(request.birth_date);
  const birthMonth = birthDate.getMonth() + 1;
  
  // 생월 기준 행운의 월 계산
  const luckyMonths = [];
  luckyMonths.push(`${birthMonth}월`);
  luckyMonths.push(`${(birthMonth + 6) % 12 || 12}월`);
  
  // 투자 경험에 따른 요일 추천
  const experienceDays = request.investment_experience.includes('10년 이상') 
    ? ['화요일', '목요일'] 
    : ['수요일', '금요일'];
  
  // 나이에 따른 시간대
  const age = parseInt(request.current_age) || 30;
  const timeSlot = age >= 40 ? '오전 9-11시' : '오후 2-4시';
  
  return {
    best_months: luckyMonths,
    best_days: experienceDays,
    best_time: timeSlot
  };
}

function generateAnalysis(request: InvestmentRequest) {
  const experience = request.investment_experience;
  const riskLevel = request.risk_tolerance;
  
  let strength = "신중하고 분석적인 투자 성향";
  let weakness = "과도한 신중함으로 기회 상실 가능성";
  let opportunity = "시장 변화 감지 및 새로운 기회 발견";
  let risk = "감정적 투자 결정의 위험성";
  
  if (experience.includes('10년 이상')) {
    strength = "풍부한 경험을 바탕으로 한 안정적인 투자 판단력과 시장 사이클에 대한 깊은 이해";
    opportunity = "축적된 노하우를 활용하여 신규 투자자들이 놓치는 기회를 선점할 수 있는 시기";
  } else if (experience.includes('초보')) {
    weakness = "투자 경험 부족으로 인한 시장 변동성에 대한 과민 반응 가능성";
    risk = "투자 지식 부족으로 인한 잘못된 정보나 추천에 의존할 위험성";
  }
  
  if (riskLevel.includes('고위험')) {
    opportunity = "높은 위험 감수 능력을 바탕으로 고수익 기회를 적극적으로 활용할 수 있는 시기";
    risk = "과도한 위험 추구로 인한 큰 손실 가능성, 레버리지 사용 시 특히 주의 필요";
  } else if (riskLevel.includes('안정형')) {
    strength = "안정적인 투자 성향으로 급격한 시장 변동에도 흔들리지 않는 강한 멘털";
    weakness = "과도한 보수성으로 인해 성장 기회를 놓칠 수 있어 적절한 공격성 필요";
  }
  
  return { strength, weakness, opportunity, risk };
}

function generateRecommendations(request: InvestmentRequest) {
  const investmentTips = [
    "분산 투자를 통해 리스크를 최소화하세요",
    "장기적인 관점에서 투자 계획을 수립하세요",
    "정기적으로 포트폴리오를 점검하고 리밸런싱하세요"
  ];
  
  const riskManagement = [
    "투자 금액의 한도를 미리 정하고 지키세요",
    "손실 한도선을 설정하고 철저히 관리하세요",
    "긴급 자금은 별도로 확보해두세요"
  ];
  
  const timingStrategies = [
    "시장의 과도한 공포나 탐욕 시점을 활용하세요",
    "정기적인 적립식 투자로 시점 분산하세요",
    "경제 지표와 뉴스를 주기적으로 모니터링하세요"
  ];
  
  const portfolioAdvice = [
    "안정형과 공격형 자산의 비율을 조절하세요",
    "국내외 자산에 균형있게 투자하세요",
    "생애주기에 맞는 자산 배분을 하세요"
  ];
  
  return {
    investment_tips: investmentTips,
    risk_management: riskManagement,
    timing_strategies: timingStrategies,
    portfolio_advice: portfolioAdvice
  };
}

function generateFuturePredictions(request: InvestmentRequest) {
  const experience = request.investment_experience;
  
  let thisMonth = "신중한 접근이 필요한 시기입니다. 기존 투자를 점검하고 새로운 기회를 탐색해보세요.";
  let nextQuarter = "변동성이 큰 시기가 예상됩니다. 리스크 관리에 더욱 신경 쓰며 안정적인 수익을 추구하세요.";
  let thisYear = "장기적인 성장이 기대되는 해입니다. 꾸준한 투자와 인내심으로 좋은 결과를 얻을 수 있습니다.";
  
  if (experience.includes('10년 이상')) {
    thisMonth = "풍부한 경험을 바탕으로 시장의 기회를 포착할 수 있는 시기입니다. 적극적인 투자를 고려해보세요.";
    nextQuarter = "시장 전문가로서의 직감을 믿고 과감한 결정을 내릴 수 있는 분기입니다.";
    thisYear = "투자 포트폴리오의 완성도를 높이고 새로운 투자 영역으로의 확장을 시도해볼 해입니다.";
  } else if (experience.includes('초보')) {
    thisMonth = "기초를 다지는 시기입니다. 안전한 투자부터 시작하여 경험을 쌓아가세요.";
    nextQuarter = "투자 지식을 꾸준히 학습하며 소액으로 다양한 투자를 경험해보는 분기입니다.";
    thisYear = "투자의 기본기를 마스터하고 본격적인 투자자로 성장할 수 있는 중요한 해입니다.";
  }
  
  return {
    this_month: thisMonth,
    next_quarter: nextQuarter,
    this_year: thisYear
  };
}

function generateLuckyNumbers(birthDate: string): number[] {
  const date = new Date(birthDate);
  const seed = date.getFullYear() + date.getMonth() + date.getDate();
  
  const numbers = [];
  for (let i = 0; i < 5; i++) {
    numbers.push((seed * (i + 1) * 7) % 100 + 1);
  }
  
  return numbers;
}

function generateWarningSignsAndFuturePredictions(request: InvestmentRequest) {
  const baseWarnings = [
    "급격한 시장 변동 시 패닉 매도 주의",
    "과도한 레버리지 사용 금지",
    "소문이나 추천에만 의존한 투자 경계",
    "감정적 투자 결정 시 한 박자 쉬기",
    "투자 원금 이상의 손실 방지"
  ];
  
  let warningSignsToShow = [...baseWarnings];
  
  if (request.risk_tolerance.includes('고위험')) {
    warningSignsToShow[1] = "고위험 투자 성향이므로 레버리지 사용 시 극도로 주의";
    warningSignsToShow.push("높은 수익률 추구 시 리스크 관리 소홀 주의");
  }
  
  if (request.investment_experience.includes('초보')) {
    warningSignsToShow[2] = "투자 초보자는 검증되지 않은 정보나 추천 투자 절대 금지";
    warningSignsToShow.push("복잡한 금융 상품보다는 단순하고 이해하기 쉬운 투자부터 시작");
  }
  
  return warningSignsToShow.slice(0, 5);
}

async function analyzeInvestmentFortune(request: InvestmentRequest): Promise<InvestmentFortune> {
  try {
    // GPT 모델 선택 (투자 상담용)
    const model = selectGPTModel('daily', 'text');
    
    // 전문 투자 운세 프롬프트 생성
    const prompt = `
당신은 투자 전문가이자 운세 상담사입니다. 다음 정보를 바탕으로 투자 운세를 상세히 분석해주세요.

사용자 정보:
- 이름: ${request.name}
- 생년월일: ${request.birth_date}
- 나이: ${request.current_age}세
- 월 소득: ${request.monthly_income}
- 투자 경험: ${request.investment_experience}
- 위험 성향: ${request.risk_tolerance}
- 투자 목표: ${request.investment_goals.join(', ')}
- 선호 자산: ${request.preferred_assets.join(', ')}
- 투자 금액: ${request.investment_amount}
- 투자 기간: ${request.investment_period}
- 재정 목표: ${request.financial_goal}
- 현재 상황: ${request.current_situation}

다음 JSON 형식으로 응답해주세요:
{
  "overall_luck": 85,
  "investment_luck": 78,
  "trading_luck": 82,
  "profit_luck": 75,
  "timing_luck": 88,
  "analysis": {
    "strength": "투자에서의 주요 강점",
    "weakness": "주의해야 할 약점",
    "opportunity": "투자 기회",
    "risk": "주의해야 할 위험"
  },
  "future_predictions": {
    "this_month": "이번 달 투자 운세",
    "next_quarter": "다음 분기 투자 운세",
    "this_year": "올해 투자 운세"
  }
}
`;

    // GPT API 호출
    const gptResult = await callGPTAPI(prompt, model);
    
    // GPT 응답이 올바른 형식인지 검증 및 변환
    if (gptResult && typeof gptResult === 'object' && 
        typeof gptResult.overall_luck === 'number') {
      console.log('GPT API 호출 성공');
      
      return {
        overall_luck: gptResult.overall_luck,
        investment_luck: gptResult.investment_luck,
        trading_luck: gptResult.trading_luck,
        profit_luck: gptResult.profit_luck,
        timing_luck: gptResult.timing_luck,
        analysis: gptResult.analysis || generateAnalysis(request),
        lucky_assets: generateLuckyAssets(request),
        lucky_timing: generateLuckyTiming(request),
        recommendations: generateRecommendations(request),
        future_predictions: gptResult.future_predictions || generateFuturePredictions(request),
        lucky_numbers: generateLuckyNumbers(request.birth_date),
        warning_signs: generateWarningSignsAndFuturePredictions(request)
      };
    } else {
      throw new Error('GPT 응답 형식 오류');
    }
    
  } catch (error) {
    console.error('GPT API 호출 실패, 백업 로직 사용:', error);
    
    // 백업 로직: 기존 알고리즘 실행
    return generatePersonalizedInvestmentFortune(request);
  }
}

function generatePersonalizedInvestmentFortune(request: InvestmentRequest): InvestmentFortune {
  return {
    overall_luck: generateOverallLuck(request),
    investment_luck: generateInvestmentLuck(request),
    trading_luck: generateTradingLuck(request),
    profit_luck: generateProfitLuck(request),
    timing_luck: generateTimingLuck(request),
    analysis: generateAnalysis(request),
    lucky_assets: generateLuckyAssets(request),
    lucky_timing: generateLuckyTiming(request),
    recommendations: generateRecommendations(request),
    future_predictions: generateFuturePredictions(request),
    lucky_numbers: generateLuckyNumbers(request.birth_date),
    warning_signs: generateWarningSignsAndFuturePredictions(request)
  };
}

export async function POST(request: NextRequest) {
  return withAuth(request, async (req: AuthenticatedRequest) => {
    try {
      // 인증된 사용자만 접근 가능
      if (!req.userId || req.userId === 'guest' || req.userId === 'system') {
        return createErrorResponse('로그인이 필요합니다.', undefined, undefined, 401);
      }

      const body: InvestmentRequest = await request.json();
      
      // 필수 필드 검증
      if (!body.name || !body.birth_date || !body.risk_tolerance) {
        return createErrorResponse('필수 정보가 누락되었습니다.', undefined, undefined, 400);
      }

      // Mock 응답 (GPT 연동 시 실제 응답으로 대체)
      const fortuneResult = await analyzeInvestmentFortune(body);

      return NextResponse.json(fortuneResult);
      
    } catch (error) {
      console.error('Lucky investment API error:', error);
      return createErrorResponse('투자운 분석 중 오류가 발생했습니다.', undefined, undefined, 500);
    }
  });
} 