"use client";

import { useToast } from '@/hooks/use-toast';
import { logger } from '@/lib/logger';
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import AppHeader from "@/components/AppHeader";
import { 
  DollarSign, 
  TrendingUp, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Users,
  Zap,
  BarChart3,
  Shield,
  Crown,
  Calendar,
  Clock,
  Award,
  Banknote,
  Target,
  PiggyBank,
  Briefcase,
  Activity,
  Eye,
  ThumbsUp,
  Heart,
  MapPin,
  Timer,
  Building,
  CreditCard,
  LineChart,
  Coins,
  Home,
  Landmark,
  Wallet,
  TrendingDown
} from "lucide-react";

import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";
interface InvestmentInfo {
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

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2
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
      stiffness: 100,
      damping: 10
    }
  }
};

const investmentGoals = [
  "재정 자유", "조기 은퇴", "내 집 마련", "자녀 교육비", "노후 준비",
  "결혼 자금", "창업 자금", "여행 자금", "비상금 확보", "부채 상환"
];

const assetTypes = [
  "주식", "부동산", "채권", "예적금", "펀드", "ETF", 
  "암호화폐", "금/귀금속", "외환", "원자재", "P2P 대출", "리츠"
];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "최고의 운";
  if (score >= 70) return "좋은 운";
  if (score >= 55) return "보통의 운";
  return "주의 필요";
};

export default function LuckyInvestmentPage() {
  const { toast } = useToast();
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<InvestmentInfo>({
    name: '',
    birth_date: '',
    current_age: '',
    monthly_income: '',
    investment_experience: '',
    risk_tolerance: '',
    investment_goals: [],
    preferred_assets: [],
    investment_amount: '',
    investment_period: '',
    financial_goal: '',
    current_situation: ''
  });
  const [result, setResult] = useState<InvestmentFortune | null>(null);

  const analyzeInvestmentFortune = async (): Promise<InvestmentFortune> => {
    // Create deterministic random generator based on user and date
    const userId = formData.name || 'guest';
    const dateString = selectedDate ? selectedDate.toISOString().split('T')[0] : getTodayDateString();
    const rng = createDeterministicRandom(userId, dateString, 'page');
    try {
      const response = await fetch('/api/fortune/lucky-investment', {
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
      logger.error('API 호출 중 오류:', error);
      
      // Fallback: 기본 응답 반환
      const baseScore = 70;
      const assets = ["주식", "부동산", "채권", "금/귀금속", "펀드", "ETF", "암호화폐"];
      const shuffledAssets = [...assets].sort(() => 0.5 - rng.random());
      
      return {
        overall_luck: Math.max(50, Math.min(95, baseScore + rng.randomInt(0, 14))),
        investment_luck: Math.max(45, Math.min(100, baseScore + rng.randomInt(0, 19) - 5)),
        trading_luck: Math.max(40, Math.min(95, baseScore + rng.randomInt(0, 19) - 10)),
        profit_luck: Math.max(50, Math.min(100, baseScore + rng.randomInt(0, 14))),
        timing_luck: Math.max(55, Math.min(95, baseScore + rng.randomInt(0, 19) - 5)),
        analysis: {
          strength: "신중하고 분석적인 투자 성향으로 리스크를 잘 관리할 수 있는 능력을 가지고 있습니다.",
          weakness: "때로는 과도한 신중함으로 인해 좋은 기회를 놓칠 수 있으니 적절한 행동력이 필요합니다.",
          opportunity: "시장의 변화를 빠르게 감지하고 새로운 투자 기회를 발견할 수 있는 시기입니다.",
          risk: "감정적인 투자 결정을 내릴 수 있는 위험이 있으니 항상 냉정함을 유지해야 합니다."
        },
        lucky_assets: shuffledAssets.slice(0, 3),
        lucky_timing: {
          best_months: ["3월", "6월", "9월", "12월"].slice(0, 2),
          best_days: ["화요일", "목요일"],
          best_time: "오전 9-11시"
        },
        recommendations: {
          investment_tips: [
            "분산 투자를 통해 리스크를 최소화하세요",
            "장기적인 관점에서 투자 계획을 수립하세요",
            "정기적으로 포트폴리오를 점검하고 리밸런싱하세요"
          ],
          risk_management: [
            "투자 금액의 한도를 미리 정하고 지키세요",
            "손실 한도선을 설정하고 철저히 관리하세요",
            "긴급 자금은 별도로 확보해두세요"
          ],
          timing_strategies: [
            "시장의 과도한 공포나 탐욕 시점을 활용하세요",
            "정기적인 적립식 투자로 시점 분산하세요",
            "경제 지표와 뉴스를 주기적으로 모니터링하세요"
          ],
          portfolio_advice: [
            "안정형과 공격형 자산의 비율을 조절하세요",
            "국내외 자산에 균형있게 투자하세요",
            "생애주기에 맞는 자산 배분을 하세요"
          ]
        },
        future_predictions: {
          this_month: "신중한 접근이 필요한 시기입니다. 기존 투자를 점검하고 새로운 기회를 탐색해보세요.",
          next_quarter: "변동성이 큰 시기가 예상됩니다. 리스크 관리에 더욱 신경 쓰며 안정적인 수익을 추구하세요.",
          this_year: "장기적인 성장이 기대되는 해입니다. 꾸준한 투자와 인내심으로 좋은 결과를 얻을 수 있습니다."
        },
        lucky_numbers: [7, 21, 35, 49, 63],
        warning_signs: [
          "급격한 시장 변동 시 패닉 매도 주의",
          "과도한 레버리지 사용 금지",
          "소문이나 추천에만 의존한 투자 경계",
          "감정적 투자 결정 시 한 박자 쉬기",
          "투자 원금 이상의 손실 방지"
        ]
      };
    }
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.risk_tolerance) {
      toast({
      title: '필수 정보를 모두 입력해주세요.',
      variant: "default",
    });
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeInvestmentFortune();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      logger.error('분석 중 오류:', error);
      toast({
      title: '분석 중 오류가 발생했습니다. 다시 시도해주세요.',
      variant: "destructive",
    });
    } finally {
      setLoading(false);
    }
  };

  const handleCheckboxChange = (value: string, checked: boolean, field: 'investment_goals' | 'preferred_assets') => {
    setFormData(prev => ({
      ...prev,
      [field]: checked 
        ? [...prev[field], value]
        : prev[field].filter(item => item !== value)
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      current_age: '',
      monthly_income: '',
      investment_experience: '',
      risk_tolerance: '',
      investment_goals: [],
      preferred_assets: [],
      investment_amount: '',
      investment_period: '',
      financial_goal: '',
      current_situation: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-yellow-50 via-orange-25 to-amber-50 pb-32">
      <AppHeader title="행운의 재테크" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-6"
      >
        <AnimatePresence mode="wait">
          {step === 'input' && (
            <motion.div
              key="input"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              {/* 헤더 */}
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-yellow-500 to-orange-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.3 }}
                >
                  <DollarSign className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 재테크</h1>
                <p className="text-gray-600">투자와 자산 운용의 황금 비결을 찾아보세요</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-yellow-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-yellow-700">
                      <Users className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="name">이름</Label>
                        <Input
                          id="name"
                          placeholder="이름"
                          value={formData.name}
                          onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <Label htmlFor="birth_date">생년월일</Label>
                        <Input
                          id="birth_date"
                          type="date"
                          value={formData.birth_date}
                          onChange={(e) => setFormData(prev => ({ ...prev, birth_date: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="current_age">현재 나이</Label>
                        <Input
                          id="current_age"
                          type="number"
                          placeholder="나이"
                          value={formData.current_age}
                          onChange={(e) => setFormData(prev => ({ ...prev, current_age: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <Label htmlFor="monthly_income">월 소득 (만원)</Label>
                        <Input
                          id="monthly_income"
                          type="number"
                          placeholder="예: 300"
                          value={formData.monthly_income}
                          onChange={(e) => setFormData(prev => ({ ...prev, monthly_income: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 투자 경험 */}
              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-orange-700">
                      <BarChart3 className="w-5 h-5" />
                      투자 경험 & 성향
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>투자 경험</Label>
                      <RadioGroup 
                        value={formData.investment_experience} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, investment_experience: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="expert" id="expert" />
                          <Label htmlFor="expert">10년 이상 (전문가 수준)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="experienced" id="experienced" />
                          <Label htmlFor="experienced">3-10년 (경험자)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="intermediate" id="intermediate" />
                          <Label htmlFor="intermediate">1-3년 (초급자)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="beginner" id="beginner" />
                          <Label htmlFor="beginner">1년 미만 (초보자)</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>위험 감수 성향</Label>
                      <RadioGroup 
                        value={formData.risk_tolerance} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, risk_tolerance: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="aggressive" id="aggressive" />
                          <Label htmlFor="aggressive">공격투자형 (고위험 고수익)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="balanced" id="balanced" />
                          <Label htmlFor="balanced">균형투자형 (중위험 중수익)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="conservative" id="conservative" />
                          <Label htmlFor="conservative">안정투자형 (저위험 저수익)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="safe" id="safe" />
                          <Label htmlFor="safe">안전투자형 (원금보장 우선)</Label>
                        </div>
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 투자 목표 및 자산 */}
              <motion.div variants={itemVariants}>
                <Card className="border-amber-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-amber-700">
                      <Target className="w-5 h-5" />
                      투자 목표 & 선호 자산
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>투자 목표 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {investmentGoals.map((goal) => (
                          <div key={goal} className="flex items-center space-x-2">
                            <Checkbox
                              id={goal}
                              checked={formData.investment_goals.includes(goal)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange(goal, checked as boolean, 'investment_goals')
                              }
                            />
                            <Label htmlFor={goal} className="text-sm">{goal}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <Label>선호하는 투자 자산 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {assetTypes.map((asset) => (
                          <div key={asset} className="flex items-center space-x-2">
                            <Checkbox
                              id={asset}
                              checked={formData.preferred_assets.includes(asset)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange(asset, checked as boolean, 'preferred_assets')
                              }
                            />
                            <Label htmlFor={asset} className="text-sm">{asset}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 투자 계획 */}
              <motion.div variants={itemVariants}>
                <Card className="border-yellow-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-yellow-700">
                      <PiggyBank className="w-5 h-5" />
                      투자 계획
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="investment_amount">투자 가능 금액 (만원)</Label>
                        <Input
                          id="investment_amount"
                          type="number"
                          placeholder="예: 1000"
                          value={formData.investment_amount}
                          onChange={(e) => setFormData(prev => ({ ...prev, investment_amount: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <Label>투자 기간</Label>
                        <RadioGroup 
                          value={formData.investment_period} 
                          onValueChange={(value) => setFormData(prev => ({ ...prev, investment_period: value }))}
                          className="mt-2"
                        >
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="short" id="short" />
                            <Label htmlFor="short" className="text-sm">단기 (1년 이하)</Label>
                          </div>
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="medium" id="medium" />
                            <Label htmlFor="medium" className="text-sm">중기 (1-5년)</Label>
                          </div>
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="long" id="long" />
                            <Label htmlFor="long" className="text-sm">장기 (5년 이상)</Label>
                          </div>
                        </RadioGroup>
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="financial_goal">구체적인 재정 목표</Label>
                      <Textarea
                        id="financial_goal"
                        placeholder="예: 5년 후 집 계약금 3억원 마련, 10년 후 연 3000만원 배당 수입 등..."
                        value={formData.financial_goal}
                        onChange={(e) => setFormData(prev => ({ ...prev, financial_goal: e.target.value }))}
                        className="mt-1 min-h-[60px]"
                      />
                    </div>
                    <div>
                      <Label htmlFor="current_situation">현재 재정 상황 (선택사항)</Label>
                      <Textarea
                        id="current_situation"
                        placeholder="현재 투자 포트폴리오, 부채 상황, 고민사항 등을 자유롭게 적어주세요..."
                        value={formData.current_situation}
                        onChange={(e) => setFormData(prev => ({ ...prev, current_situation: e.target.value }))}
                        className="mt-1 min-h-[80px]"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-white py-6 text-lg font-semibold"
                >
                  {loading ? (
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ repeat: Infinity, duration: 1 }}
                      className="flex items-center gap-2"
                    >
                      <Shuffle className="w-5 h-5" />
                      분석 중...
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <DollarSign className="w-5 h-5" />
                      재테크 운세 분석하기
                    </div>
                  )}
                </Button>
              </motion.div>
            </motion.div>
          )}

          {step === 'result' && result && (
            <motion.div
              key="result"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -50 }}
              className="space-y-6"
            >
              {/* 전체 운세 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <DollarSign className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 재테크 운세</span>
                    </div>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className="text-6xl font-bold mb-2"
                    >
                      {result.overall_luck}점
                    </motion.div>
                    <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                      {getLuckText(result.overall_luck)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 세부 운세 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-yellow-600">
                      <BarChart3 className="w-5 h-5" />
                      세부 재테크 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "투자운", score: result.investment_luck, icon: TrendingUp, desc: "새로운 투자 기회 발견과 성공" },
                      { label: "거래운", score: result.trading_luck, icon: LineChart, desc: "매매 타이밍과 거래 성공률" },
                      { label: "수익운", score: result.profit_luck, icon: Coins, desc: "수익 실현과 자산 증식" },
                      { label: "타이밍운", score: result.timing_luck, icon: Clock, desc: "최적의 투자 시점 포착" }
                    ].map((item, index) => (
                      <motion.div
                        key={item.label}
                        initial={{ x: -20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.4 + index * 0.1 }}
                        className="space-y-2"
                      >
                        <div className="flex items-center gap-3">
                          <item.icon className="w-5 h-5 text-gray-600" />
                          <div className="flex-1">
                            <div className="flex justify-between items-center mb-1">
                              <div>
                                <span className="font-medium">{item.label}</span>
                                <p className="text-xs text-gray-500">{item.desc}</p>
                              </div>
                              <span className={`px-3 py-1 rounded-full text-sm font-medium ${getLuckColor(item.score)}`}>
                                {item.score}점
                              </span>
                            </div>
                            <div className="w-full bg-gray-200 rounded-full h-2">
                              <motion.div
                                className="bg-yellow-500 h-2 rounded-full"
                                initial={{ width: 0 }}
                                animate={{ width: `${item.score}%` }}
                                transition={{ delay: 0.5 + index * 0.1, duration: 0.8 }}
                              />
                            </div>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              {/* SWOT 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <Activity className="w-5 h-5" />
                      투자 SWOT 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-4 bg-green-50 rounded-lg">
                        <h4 className="font-medium text-green-800 mb-2 flex items-center gap-2">
                          <ThumbsUp className="w-4 h-4" />
                          강점 (Strength)
                        </h4>
                        <p className="text-green-700 text-sm">{result.analysis.strength}</p>
                      </div>
                      <div className="p-4 bg-red-50 rounded-lg">
                        <h4 className="font-medium text-red-800 mb-2 flex items-center gap-2">
                          <Eye className="w-4 h-4" />
                          약점 (Weakness)
                        </h4>
                        <p className="text-red-700 text-sm">{result.analysis.weakness}</p>
                      </div>
                      <div className="p-4 bg-blue-50 rounded-lg">
                        <h4 className="font-medium text-blue-800 mb-2 flex items-center gap-2">
                          <Sparkles className="w-4 h-4" />
                          기회 (Opportunity)
                        </h4>
                        <p className="text-blue-700 text-sm">{result.analysis.opportunity}</p>
                      </div>
                      <div className="p-4 bg-orange-50 rounded-lg">
                        <h4 className="font-medium text-orange-800 mb-2 flex items-center gap-2">
                          <Shield className="w-4 h-4" />
                          위험 (Risk)
                        </h4>
                        <p className="text-orange-700 text-sm">{result.analysis.risk}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 행운의 투자 요소 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Crown className="w-5 h-5" />
                      행운의 투자 요소
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-purple-50 rounded-lg">
                        <h4 className="font-medium text-purple-800 mb-2 flex items-center gap-2">
                          <Star className="w-4 h-4" />
                          행운의 자산
                        </h4>
                        <div className="flex flex-wrap gap-2">
                          {result.lucky_assets.map((asset, index) => (
                            <Badge key={index} variant="secondary" className="bg-purple-100 text-purple-700">
                              {asset}
                            </Badge>
                          ))}
                        </div>
                      </div>
                      <div className="grid grid-cols-2 gap-4">
                        <div className="p-4 bg-indigo-50 rounded-lg">
                          <h4 className="font-medium text-indigo-800 mb-2 flex items-center gap-2">
                            <Calendar className="w-4 h-4" />
                            행운의 달
                          </h4>
                          <p className="text-indigo-700 text-sm">{result.lucky_timing.best_months.join(", ")}</p>
                        </div>
                        <div className="p-4 bg-teal-50 rounded-lg">
                          <h4 className="font-medium text-teal-800 mb-2 flex items-center gap-2">
                            <Clock className="w-4 h-4" />
                            행운의 시간
                          </h4>
                          <p className="text-teal-700 text-sm">{result.lucky_timing.best_time}</p>
                        </div>
                      </div>
                      <div className="p-4 bg-emerald-50 rounded-lg">
                        <h4 className="font-medium text-emerald-800 mb-2 flex items-center gap-2">
                          <Award className="w-4 h-4" />
                          행운의 숫자
                        </h4>
                        <div className="flex flex-wrap gap-2">
                          {result.lucky_numbers.map((num, index) => (
                            <Badge key={index} variant="outline" className="border-emerald-300 text-emerald-700">
                              {num}
                            </Badge>
                          ))}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 맞춤 추천 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <TrendingUp className="w-5 h-5" />
                      맞춤 투자 가이드
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Target className="w-4 h-4 text-blue-500" />
                        투자 팁
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.investment_tips.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.6 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Star className="w-4 h-4 text-blue-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{tip}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Shield className="w-4 h-4 text-red-500" />
                        리스크 관리
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.risk_management.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.8 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Shield className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{tip}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 주의사항 */}
              <motion.div variants={itemVariants}>
                <Card className="border-red-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-red-600">
                      <TrendingDown className="w-5 h-5" />
                      투자 주의사항
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.warning_signs.map((warning, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.0 + index * 0.1 }}
                          className="flex items-start gap-2 p-3 bg-red-50 rounded-lg"
                        >
                          <TrendingDown className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                          <p className="text-red-700 text-sm">{warning}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-yellow-300 text-yellow-600 hover:bg-yellow-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 분석하기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 