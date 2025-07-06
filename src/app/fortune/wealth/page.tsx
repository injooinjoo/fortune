"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  DollarSignIcon,
  PiggyBankIcon,
  TrendingUpIcon,
  CreditCardIcon,
  StarIcon,
  CheckCircleIcon,
  AlertTriangleIcon,
  ClockIcon,
  CompassIcon,
  LightbulbIcon,
  TargetIcon,
  CalendarIcon,
  BarChart3Icon,
  ShieldIcon
} from "lucide-react";

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

export default function WealthPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<WealthInfo>({
    name: '',
    birth_date: '',
    current_income: '',
    monthly_expenses: '',
    savings_amount: '',
    debt_amount: '',
    investment_experience: '',
    risk_tolerance: '',
    financial_goals: [],
    spending_habits: '',
    income_sources: [],
    financial_stress_level: ''
  });
  const [result, setResult] = useState<WealthFortune | null>(null);

  // 개선된 백업 로직 함수
  const generateBackupWealthFortune = (data: WealthInfo): WealthFortune => {
    // 생년월일 기반 개인화 점수 계산
    const birthYear = data.birth_date ? parseInt(data.birth_date.substring(0, 4)) : new Date().getFullYear() - 30;
    const birthMonth = data.birth_date ? parseInt(data.birth_date.substring(5, 7)) : 6;
    const birthDay = data.birth_date ? parseInt(data.birth_date.substring(8, 10)) : 15;
    
    const baseScore = ((birthYear + birthMonth + birthDay) % 30) + 65;
    
    // 재정 상태별 점수 조정
    let financialBonus = 0;
    
    // 저축률 기반 보너스
    if (data.current_income && data.monthly_expenses && data.savings_amount) {
      const income = parseFloat(data.current_income) || 0;
      const expenses = parseFloat(data.monthly_expenses) || 0;
      const savings = parseFloat(data.savings_amount) || 0;
      
      if (income > 0) {
        const savingRate = savings / (income * 12); // 연간 저축률
        if (savingRate >= 0.3) financialBonus += 15;
        else if (savingRate >= 0.2) financialBonus += 10;
        else if (savingRate >= 0.1) financialBonus += 5;
      }
    }
    
    // 투자 경험별 보너스
    const experienceBonus = {
      '10년 이상': 15,
      '5-10년': 10,
      '1-5년': 5,
      '1년 이하': 0,
      '경험 없음': -5
    }[data.investment_experience || ''] || 0;
    
    // 위험 성향별 보너스 (금전운에서는 안정형이 유리)
    const riskBonus = {
      '안정형': 8,
      '중간형': 5,
      '공격형': 0
    }[data.risk_tolerance || ''] || 0;
    
    // 스트레스 수준별 조정
    const stressBonus = {
      '낮음': 10,
      '보통': 5,
      '높음': -5,
      '매우 높음': -10
    }[data.financial_stress_level || ''] || 0;
    
    const overallLuck = Math.max(45, Math.min(98, baseScore + financialBonus + experienceBonus + riskBonus + stressBonus));
    
    // 행운 요소 계산
    const luckyElements = {
      time: ['오전 10-12시', '오후 2-4시', '저녁 6-8시', '오후 1-3시'][birthDay % 4],
      day: ['화요일', '목요일', '금요일', '수요일'][birthMonth % 4],
      color: ['골드', '브라운', '그린', '네이비'][birthDay % 4],
      direction: ['남동쪽', '남서쪽', '동쪽', '북쪽'][(birthDay + birthMonth) % 4],
      lucky_numbers: [
        (birthDay % 9) + 1,
        (birthMonth % 9) + 1,
        ((birthDay + birthMonth) % 9) + 1,
        ((birthDay * birthMonth) % 9) + 1,
        ((birthDay + birthMonth * 2) % 9) + 1
      ]
    };
    
    // 개인화된 재정 조언
    const isHighIncome = parseFloat(data.current_income || '0') >= 500;
    const isExperienced = ['5-10년', '10년 이상'].includes(data.investment_experience || '');
    const riskProfile = data.risk_tolerance || '중간형';
    
    return {
      overall_luck: overallLuck,
      income_luck: Math.max(40, Math.min(95, overallLuck + (birthDay % 10) - 5)),
      saving_luck: Math.max(50, Math.min(100, overallLuck + (birthMonth % 12) - 6)),
      investment_luck: Math.max(45, Math.min(95, overallLuck + ((birthDay + birthMonth) % 15) - 7)),
      debt_management_luck: Math.max(55, Math.min(100, overallLuck + (birthYear % 8) - 4)),
      financial_planning: {
        monthly_analysis: {
          recommended_saving_rate: isHighIncome ? '25-35%' : '15-25%',
          expense_optimization: [
            '고정비 재검토 (통신비, 보험료, 구독 서비스)',
            '외식비 및 배달비 줄이기',
            '불필요한 멤버십 해지',
            '쇼핑 전 24시간 고민 원칙 적용'
          ],
          income_improvement_tips: [
            isExperienced ? '전문성을 활용한 컨설팅 업무' : '새로운 기술 습득과 자격증 취득',
            isHighIncome ? '투자 수익 극대화' : '부업 또는 사이드 프로젝트',
            '네트워킹을 통한 기회 확장',
            '성과 평가 시스템 적극 활용'
          ]
        },
        investment_advice: {
          suitable_products: riskProfile === '안정형' ? [
            { category: '예금/적금', risk_level: '낮음', expected_return: '3-5%', recommendation_reason: '안전한 기초 자산' },
            { category: '채권형 펀드', risk_level: '낮음', expected_return: '4-7%', recommendation_reason: '안정적 수익 추구' },
            { category: 'CMA/MMF', risk_level: '낮음', expected_return: '2-4%', recommendation_reason: '유동성과 안전성' }
          ] : riskProfile === '공격형' ? [
            { category: '주식형 펀드', risk_level: '높음', expected_return: '8-15%', recommendation_reason: '적극적 자산 증식' },
            { category: '해외 ETF', risk_level: '중간', expected_return: '6-12%', recommendation_reason: '글로벌 분산투자' },
            { category: '성장주 투자', risk_level: '높음', expected_return: '10-20%', recommendation_reason: '고성장 기업 투자' }
          ] : [
            { category: '혼합형 펀드', risk_level: '중간', expected_return: '5-10%', recommendation_reason: '균형잡힌 포트폴리오' },
            { category: 'ETF', risk_level: '중간', expected_return: '4-8%', recommendation_reason: '분산투자와 비용 효율성' },
            { category: '리츠(REITs)', risk_level: '중간', expected_return: '6-9%', recommendation_reason: '부동산 간접투자' }
          ],
          portfolio_allocation: riskProfile === '안정형' 
            ? { conservative: 70, moderate: 25, aggressive: 5 }
            : riskProfile === '공격형'
            ? { conservative: 20, moderate: 40, aggressive: 40 }
            : { conservative: 40, moderate: 45, aggressive: 15 }
        },
        debt_strategy: {
          priority_debts: data.debt_amount && parseFloat(data.debt_amount) > 0 
            ? ['고금리 카드대출', '기타 소액대출', '학자금 대출', '주택담보대출']
            : ['신용카드 잔액 관리', '예방적 신용 관리'],
          repayment_strategy: data.debt_amount && parseFloat(data.debt_amount) > 0
            ? '고금리 부채 우선 상환 후 낮은 금리 순으로 체계적 정리'
            : '부채 발생 예방과 건전한 신용 유지 중심',
          consolidation_advice: '금리 7% 이상 부채는 통합대출 검토 권장'
        }
      },
      lucky_elements: luckyElements,
      wealth_timing: {
        best_earning_period: birthMonth <= 6 ? 
          '하반기가 수입 증대의 황금기입니다' :
          '상반기에 적극적인 수입 활동을 추진하세요',
        investment_timing: isExperienced ?
          '시장 조정기를 기회로 활용한 전략적 투자' :
          '점진적이고 꾸준한 분할투자가 효과적',
        saving_focus_period: '연초 목표 설정과 연말 결산이 중요한 시기',
        debt_payoff_timing: '보너스나 임시 수입이 있을 때 부채 상환에 집중'
      },
      personalized_advice: {
        strengths: overallLuck >= 80 ? 
          '뛰어난 재정 관리 능력과 투자 감각을 보유하고 계십니다' :
          '안정적이고 신중한 재정 운용 스타일이 강점입니다',
        improvement_areas: isHighIncome ?
          '고소득을 활용한 적극적 자산 증식과 세무 전략이 필요합니다' :
          '수입원 다변화와 체계적인 저축 습관 형성이 중요합니다',
        goal_achievement_strategy: '명확한 단계별 목표 설정과 정기적인 성과 점검을 통한 지속적 개선',
        emergency_fund_advice: data.savings_amount && parseFloat(data.savings_amount) > 0 ?
          '비상금을 월 지출의 6개월분 이상으로 늘려 안정성을 확보하세요' :
          '우선 월 지출의 3개월분 비상금 마련부터 시작하세요'
      },
      monthly_action_plan: {
        week1: [
          `${data.name || '본인'}님 맞춤 월간 예산 계획 수립`,
          '고정 지출 항목 세부 점검 및 최적화',
          '투자 포트폴리오 수익률 현황 분석'
        ],
        week2: [
          '일일 지출 기록과 변동비 모니터링',
          `${isHighIncome ? '투자 수익' : '부업'} 기회 적극 탐색`,
          '재정 목표 대비 진행상황 중간 점검'
        ],
        week3: [
          '투자 상품별 성과 분석 및 리밸런싱 검토',
          '불필요한 지출 항목 정리와 절약 포인트 발굴',
          '다음 달 재정 계획 초안 작성'
        ],
        week4: [
          '월간 수입/지출 정산 및 저축률 확인',
          '목표 달성도 평가와 개선점 도출',
          '다음 달 예산 조정안 최종 확정'
        ]
      },
      success_factors: [
        '체계적인 가계부 작성과 지출 패턴 분석',
        '구체적이고 달성 가능한 재정 목표 설정',
        `${riskProfile}에 맞는 안전한 투자 전략`,
        '건전한 신용 관리와 부채 최소화',
        '지속 가능한 다양한 수입원 확보'
      ],
      warning_signs: [
        '감정적 투자 결정과 단기 수익에 현혹되지 마세요',
        '과도한 수익률을 보장하는 상품은 의심해보세요',
        `${data.debt_amount ? '추가 대출보다는 기존 부채 정리에 집중' : '불필요한 대출 발생 예방'}`,
        '투자 원금 손실 위험이 큰 상품은 신중히 검토',
        '허위 정보나 투자 권유에 현혹되지 마세요'
      ]
    };
  };

  const analyzeWealthFortune = async (): Promise<WealthFortune> => {
    try {
      const response = await fetch('/api/fortune/wealth', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error('API 요청 실패');
      }

      const result = await response.json();
      return result;
    } catch (error) {
      console.error('금전운 분석 오류:', error);
      
      // 개선된 백업 로직 - 사용자 데이터 기반 개인화
      return generateBackupWealthFortune(formData);
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const fortune = await analyzeWealthFortune();
      setResult(fortune);
      setStep('result');
    } catch (error) {
      console.error('분석 실패:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleGoalChange = (goal: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      financial_goals: checked 
        ? [...(prev.financial_goals || []), goal]
        : (prev.financial_goals || []).filter(g => g !== goal)
    }));
  };

  const handleIncomeSourceChange = (source: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      income_sources: checked 
        ? [...(prev.income_sources || []), source]
        : (prev.income_sources || []).filter(s => s !== source)
    }));
  };

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
      }
    }
  };

  const itemVariants = {
    hidden: { y: 20, opacity: 0 },
    visible: {
      y: 0,
      opacity: 1,
      transition: {
        type: "spring" as const,
        stiffness: 100
      }
    }
  };

  if (step === 'input') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-emerald-50 to-teal-50">
        <AppHeader />

        <motion.div
          className="container mx-auto px-4 pt-4 pb-20"
          variants={containerVariants}
          initial="hidden"
          animate="visible"
        >
          <motion.div variants={itemVariants} className="text-center mb-8">
            <div className="flex items-center justify-center gap-2 mb-4">
              <DollarSignIcon className="h-8 w-8 text-green-600" />
              <h1 className="text-3xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
                금전운
              </h1>
            </div>
            <p className="text-gray-600">
              당신의 재정 상황과 금전운을 분석하여 맞춤 조언을 제공합니다
            </p>
          </motion.div>

          <motion.div variants={itemVariants}>
            <Card className="max-w-2xl mx-auto">
              <CardHeader>
                <CardTitle className="text-center">재정 정보 입력</CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmit} className="space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="name">이름 *</Label>
                      <Input
                        id="name"
                        value={formData.name}
                        onChange={(e) => setFormData({...formData, name: e.target.value})}
                        placeholder="홍길동"
                        required
                      />
                    </div>
                    <div>
                      <KoreanDatePicker
                        label="생년월일"
                        value={formData.birth_date}
                        onChange={(date) => setFormData({...formData, birth_date: date})}
                        placeholder="생년월일을 선택하세요"
                        required
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="current_income">월 수입 (만원)</Label>
                      <Input
                        id="current_income"
                        value={formData.current_income}
                        onChange={(e) => setFormData({...formData, current_income: e.target.value})}
                        placeholder="300"
                        type="number"
                      />
                    </div>
                    <div>
                      <Label htmlFor="monthly_expenses">월 지출 (만원)</Label>
                      <Input
                        id="monthly_expenses"
                        value={formData.monthly_expenses}
                        onChange={(e) => setFormData({...formData, monthly_expenses: e.target.value})}
                        placeholder="200"
                        type="number"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="savings_amount">현재 저축액 (만원)</Label>
                      <Input
                        id="savings_amount"
                        value={formData.savings_amount}
                        onChange={(e) => setFormData({...formData, savings_amount: e.target.value})}
                        placeholder="1000"
                        type="number"
                      />
                    </div>
                    <div>
                      <Label htmlFor="debt_amount">부채 금액 (만원)</Label>
                      <Input
                        id="debt_amount"
                        value={formData.debt_amount}
                        onChange={(e) => setFormData({...formData, debt_amount: e.target.value})}
                        placeholder="0"
                        type="number"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="investment_experience">투자 경험</Label>
                      <Select
                        value={formData.investment_experience}
                        onValueChange={(value) => setFormData({...formData, investment_experience: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="투자 경험을 선택하세요" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="경험 없음">경험 없음</SelectItem>
                          <SelectItem value="1년 이하">1년 이하</SelectItem>
                          <SelectItem value="1-5년">1-5년</SelectItem>
                          <SelectItem value="5-10년">5-10년</SelectItem>
                          <SelectItem value="10년 이상">10년 이상</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div>
                      <Label htmlFor="risk_tolerance">투자 성향</Label>
                      <Select
                        value={formData.risk_tolerance}
                        onValueChange={(value) => setFormData({...formData, risk_tolerance: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="투자 성향을 선택하세요" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="안정형">안정형 (원금 보장 중시)</SelectItem>
                          <SelectItem value="중간형">중간형 (적당한 위험 감수)</SelectItem>
                          <SelectItem value="공격형">공격형 (높은 수익 추구)</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div>
                    <Label htmlFor="financial_stress_level">재정 스트레스 수준</Label>
                    <Select
                      value={formData.financial_stress_level}
                      onValueChange={(value) => setFormData({...formData, financial_stress_level: value})}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="현재 재정적 스트레스 수준" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="낮음">낮음 (여유로움)</SelectItem>
                        <SelectItem value="보통">보통 (적당함)</SelectItem>
                        <SelectItem value="높음">높음 (부담스러움)</SelectItem>
                        <SelectItem value="매우 높음">매우 높음 (심각함)</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>재정 목표 (복수 선택 가능)</Label>
                    <div className="grid grid-cols-2 md:grid-cols-3 gap-2 mt-2">
                      {['주택 구매', '은퇴 준비', '자녀 교육비', '여행 자금', '창업 자금', '비상금 마련', '부채 상환', '투자 수익', '노후 대비'].map((goal) => (
                        <label key={goal} className="flex items-center space-x-2">
                          <input
                            type="checkbox"
                            checked={formData.financial_goals?.includes(goal) || false}
                            onChange={(e) => handleGoalChange(goal, e.target.checked)}
                            className="rounded"
                          />
                          <span className="text-sm">{goal}</span>
                        </label>
                      ))}
                    </div>
                  </div>

                  <div>
                    <Label>수입원 (복수 선택 가능)</Label>
                    <div className="grid grid-cols-2 md:grid-cols-3 gap-2 mt-2">
                      {['직장 월급', '부업 수입', '투자 수익', '임대 수입', '프리랜싱', '사업 수입', '연금', '기타'].map((source) => (
                        <label key={source} className="flex items-center space-x-2">
                          <input
                            type="checkbox"
                            checked={formData.income_sources?.includes(source) || false}
                            onChange={(e) => handleIncomeSourceChange(source, e.target.checked)}
                            className="rounded"
                          />
                          <span className="text-sm">{source}</span>
                        </label>
                      ))}
                    </div>
                  </div>

                  <Button 
                    type="submit" 
                    className="w-full bg-green-600 hover:bg-green-700"
                    disabled={loading}
                  >
                    {loading ? '분석 중...' : '금전운 분석하기'}
                  </Button>
                </form>
              </CardContent>
            </Card>
          </motion.div>
        </motion.div>
      </div>
    );
  }

  if (!result) return null;

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-emerald-50 to-teal-50">
      <AppHeader />

      <motion.div
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* 헤더 섹션 */}
        <motion.div variants={itemVariants} className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <DollarSignIcon className="h-8 w-8 text-green-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-green-600 to-emerald-600 bg-clip-text text-transparent">
              {formData.name}님의 금전운
            </h1>
          </div>
          <p className="text-gray-600">
            개인 맞춤 재정 분석 결과입니다
          </p>
        </motion.div>

        {/* 종합 금전운 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 border-green-200 bg-gradient-to-r from-green-50 to-emerald-50">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-green-700">
                <DollarSignIcon className="h-5 w-5" />
                종합 금전운
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-green-600 mb-2">{result.overall_luck}점</div>
              <Progress value={result.overall_luck} className="mb-4" />
              <p className="text-sm text-gray-600">
                {result.overall_luck >= 85 ? '재정 관리와 투자에 매우 유리한 시기입니다' : 
                 result.overall_luck >= 70 ? '안정적인 재정 운영이 가능합니다' : 
                 '신중한 계획으로 재정 안정성을 높여보세요'}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 세부 운세 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="text-center">세부 분야별 운세</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <TrendingUpIcon className="h-5 w-5 text-green-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-green-600">{result.income_luck}</div>
                  <div className="text-sm text-gray-500">수입운</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <PiggyBankIcon className="h-5 w-5 text-blue-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-blue-600">{result.saving_luck}</div>
                  <div className="text-sm text-gray-500">저축운</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <BarChart3Icon className="h-5 w-5 text-purple-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-purple-600">{result.investment_luck}</div>
                  <div className="text-sm text-gray-500">투자운</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <ShieldIcon className="h-5 w-5 text-orange-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-orange-600">{result.debt_management_luck}</div>
                  <div className="text-sm text-gray-500">부채 관리</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 행운 요소 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <StarIcon className="h-5 w-5 text-yellow-500" />
                행운의 요소
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-3">
                  <div className="flex items-center gap-2">
                    <ClockIcon className="h-4 w-4 text-blue-500" />
                    <span className="text-sm font-medium">행운의 시간:</span>
                    <span className="text-sm text-blue-600">{result.lucky_elements.time}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <CalendarIcon className="h-4 w-4 text-green-500" />
                    <span className="text-sm font-medium">행운의 요일:</span>
                    <span className="text-sm text-green-600">{result.lucky_elements.day}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="h-4 w-4 bg-yellow-500 rounded-full"></div>
                    <span className="text-sm font-medium">행운의 색상:</span>
                    <span className="text-sm text-yellow-600">{result.lucky_elements.color}</span>
                  </div>
                </div>
                <div className="space-y-3">
                  <div className="flex items-center gap-2">
                    <CompassIcon className="h-4 w-4 text-purple-500" />
                    <span className="text-sm font-medium">행운의 방향:</span>
                    <span className="text-sm text-purple-600">{result.lucky_elements.direction}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <TargetIcon className="h-4 w-4 text-orange-500" />
                    <span className="text-sm font-medium">행운의 숫자:</span>
                    <span className="text-sm text-orange-600">{result.lucky_elements.lucky_numbers.join(', ')}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 재정 계획 및 조언 탭 */}
        <motion.div variants={itemVariants}>
          <Tabs defaultValue="planning" className="mb-6">
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="planning">재정 계획</TabsTrigger>
              <TabsTrigger value="timing">타이밍</TabsTrigger>
              <TabsTrigger value="advice">개인 조언</TabsTrigger>
              <TabsTrigger value="action">실행 계획</TabsTrigger>
            </TabsList>

            <TabsContent value="planning">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-6">
                    {/* 월 분석 */}
                    <div>
                      <h4 className="font-medium mb-3 text-green-800">월별 재정 관리</h4>
                      <div className="bg-green-50 p-4 rounded-lg">
                        <div className="mb-3">
                          <span className="font-medium">권장 저축률: </span>
                          <span className="text-green-700">{result.financial_planning.monthly_analysis.recommended_saving_rate}</span>
                        </div>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                          <div>
                            <h5 className="text-sm font-medium mb-2">지출 최적화</h5>
                            <ul className="text-xs space-y-1">
                              {result.financial_planning.monthly_analysis.expense_optimization.map((tip, index) => (
                                <li key={index} className="flex items-start gap-1">
                                  <CheckCircleIcon className="h-3 w-3 text-green-500 mt-0.5 flex-shrink-0" />
                                  <span>{tip}</span>
                                </li>
                              ))}
                            </ul>
                          </div>
                          <div>
                            <h5 className="text-sm font-medium mb-2">수입 향상</h5>
                            <ul className="text-xs space-y-1">
                              {result.financial_planning.monthly_analysis.income_improvement_tips.map((tip, index) => (
                                <li key={index} className="flex items-start gap-1">
                                  <TrendingUpIcon className="h-3 w-3 text-blue-500 mt-0.5 flex-shrink-0" />
                                  <span>{tip}</span>
                                </li>
                              ))}
                            </ul>
                          </div>
                        </div>
                      </div>
                    </div>

                    {/* 투자 조언 */}
                    <div>
                      <h4 className="font-medium mb-3 text-purple-800">투자 가이드</h4>
                      <div className="bg-purple-50 p-4 rounded-lg">
                        <div className="mb-4">
                          <h5 className="text-sm font-medium mb-2">포트폴리오 구성</h5>
                          <div className="grid grid-cols-3 gap-2 text-center">
                            <div className="bg-green-100 p-2 rounded">
                              <div className="text-sm font-bold text-green-700">{result.financial_planning.investment_advice.portfolio_allocation.conservative}%</div>
                              <div className="text-xs text-green-600">안전 자산</div>
                            </div>
                            <div className="bg-blue-100 p-2 rounded">
                              <div className="text-sm font-bold text-blue-700">{result.financial_planning.investment_advice.portfolio_allocation.moderate}%</div>
                              <div className="text-xs text-blue-600">중위험 자산</div>
                            </div>
                            <div className="bg-red-100 p-2 rounded">
                              <div className="text-sm font-bold text-red-700">{result.financial_planning.investment_advice.portfolio_allocation.aggressive}%</div>
                              <div className="text-xs text-red-600">고위험 자산</div>
                            </div>
                          </div>
                        </div>
                        <div className="space-y-2">
                          {result.financial_planning.investment_advice.suitable_products.map((product, index) => (
                            <div key={index} className="bg-white p-3 rounded border">
                              <div className="flex justify-between items-start mb-1">
                                <span className="font-medium text-sm">{product.category}</span>
                                <Badge 
                                  variant="outline" 
                                  className={
                                    product.risk_level === '낮음' ? 'bg-green-100 text-green-700' :
                                    product.risk_level === '중간' ? 'bg-blue-100 text-blue-700' :
                                    'bg-red-100 text-red-700'
                                  }
                                >
                                  {product.risk_level}
                                </Badge>
                              </div>
                              <div className="text-xs text-gray-600">
                                예상수익: {product.expected_return} | {product.recommendation_reason}
                              </div>
                            </div>
                          ))}
                        </div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="timing">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <div className="p-3 bg-green-50 rounded-lg">
                      <h4 className="font-medium text-green-800 mb-1">수입 증대 시기</h4>
                      <p className="text-sm text-green-700">{result.wealth_timing.best_earning_period}</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-lg">
                      <h4 className="font-medium text-blue-800 mb-1">투자 타이밍</h4>
                      <p className="text-sm text-blue-700">{result.wealth_timing.investment_timing}</p>
                    </div>
                    <div className="p-3 bg-purple-50 rounded-lg">
                      <h4 className="font-medium text-purple-800 mb-1">저축 집중 기간</h4>
                      <p className="text-sm text-purple-700">{result.wealth_timing.saving_focus_period}</p>
                    </div>
                    <div className="p-3 bg-orange-50 rounded-lg">
                      <h4 className="font-medium text-orange-800 mb-1">부채 상환 시기</h4>
                      <p className="text-sm text-orange-700">{result.wealth_timing.debt_payoff_timing}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="advice">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <div className="p-3 bg-emerald-50 rounded-lg">
                      <h4 className="font-medium text-emerald-800 mb-1">나의 강점</h4>
                      <p className="text-sm text-emerald-700">{result.personalized_advice.strengths}</p>
                    </div>
                    <div className="p-3 bg-amber-50 rounded-lg">
                      <h4 className="font-medium text-amber-800 mb-1">개선 영역</h4>
                      <p className="text-sm text-amber-700">{result.personalized_advice.improvement_areas}</p>
                    </div>
                    <div className="p-3 bg-cyan-50 rounded-lg">
                      <h4 className="font-medium text-cyan-800 mb-1">목표 달성 전략</h4>
                      <p className="text-sm text-cyan-700">{result.personalized_advice.goal_achievement_strategy}</p>
                    </div>
                    <div className="p-3 bg-rose-50 rounded-lg">
                      <h4 className="font-medium text-rose-800 mb-1">비상금 조언</h4>
                      <p className="text-sm text-rose-700">{result.personalized_advice.emergency_fund_advice}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="action">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <h4 className="font-medium mb-3">월별 실행 계획</h4>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="space-y-3">
                        <div className="bg-blue-50 p-3 rounded-lg">
                          <h5 className="font-medium text-blue-800 mb-2">1주차</h5>
                          <ul className="text-xs space-y-1">
                            {result.monthly_action_plan.week1.map((action, index) => (
                              <li key={index} className="flex items-start gap-1">
                                <CheckCircleIcon className="h-3 w-3 text-blue-500 mt-0.5 flex-shrink-0" />
                                <span>{action}</span>
                              </li>
                            ))}
                          </ul>
                        </div>
                        <div className="bg-purple-50 p-3 rounded-lg">
                          <h5 className="font-medium text-purple-800 mb-2">3주차</h5>
                          <ul className="text-xs space-y-1">
                            {result.monthly_action_plan.week3.map((action, index) => (
                              <li key={index} className="flex items-start gap-1">
                                <CheckCircleIcon className="h-3 w-3 text-purple-500 mt-0.5 flex-shrink-0" />
                                <span>{action}</span>
                              </li>
                            ))}
                          </ul>
                        </div>
                      </div>
                      <div className="space-y-3">
                        <div className="bg-green-50 p-3 rounded-lg">
                          <h5 className="font-medium text-green-800 mb-2">2주차</h5>
                          <ul className="text-xs space-y-1">
                            {result.monthly_action_plan.week2.map((action, index) => (
                              <li key={index} className="flex items-start gap-1">
                                <CheckCircleIcon className="h-3 w-3 text-green-500 mt-0.5 flex-shrink-0" />
                                <span>{action}</span>
                              </li>
                            ))}
                          </ul>
                        </div>
                        <div className="bg-orange-50 p-3 rounded-lg">
                          <h5 className="font-medium text-orange-800 mb-2">4주차</h5>
                          <ul className="text-xs space-y-1">
                            {result.monthly_action_plan.week4.map((action, index) => (
                              <li key={index} className="flex items-start gap-1">
                                <CheckCircleIcon className="h-3 w-3 text-orange-500 mt-0.5 flex-shrink-0" />
                                <span>{action}</span>
                              </li>
                            ))}
                          </ul>
                        </div>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </motion.div>

        {/* 성공 요인 & 주의사항 */}
        <motion.div variants={itemVariants}>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-green-600">
                  <CheckCircleIcon className="h-5 w-5" />
                  성공 요인
                </CardTitle>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2">
                  {result.success_factors.map((factor, index) => (
                    <li key={index} className="flex items-start gap-2 text-sm">
                      <CheckCircleIcon className="h-4 w-4 text-green-500 mt-0.5 flex-shrink-0" />
                      <span>{factor}</span>
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-orange-600">
                  <AlertTriangleIcon className="h-5 w-5" />
                  주의사항
                </CardTitle>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2">
                  {result.warning_signs.map((warning, index) => (
                    <li key={index} className="flex items-start gap-2 text-sm">
                      <AlertTriangleIcon className="h-4 w-4 text-orange-500 mt-0.5 flex-shrink-0" />
                      <span>{warning}</span>
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          </div>
        </motion.div>

        {/* 다시 분석하기 버튼 */}
        <motion.div variants={itemVariants} className="text-center">
          <Button 
            onClick={() => setStep('input')}
            variant="outline"
            className="border-green-600 text-green-600 hover:bg-green-50"
          >
            다시 분석하기
          </Button>
        </motion.div>
      </motion.div>
    </div>
  );
} 