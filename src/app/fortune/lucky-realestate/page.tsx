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
  Building2, 
  TrendingUp, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Users,
  Zap,
  Shield,
  Crown,
  Calendar,
  Clock,
  Award,
  MapPin,
  Target,
  BarChart3,
  Activity,
  Eye,
  ThumbsUp,
  Heart,
  Timer,
  Landmark,
  Home,
  Building,
  DollarSign,
  LineChart,
  Coins,
  Calculator,
  Search,
  Banknote,
  TrendingDown
} from "lucide-react";

import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";
interface RealEstateInfo {
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

const investmentPurposes = [
  "거주 목적", "임대 수익", "시세 차익", "절세 효과", "자산 보전",
  "은퇴 준비", "자녀 증여", "사업 확장", "안전 자산", "포트폴리오 다변화"
];

const preferredAreas = [
  "강남구", "서초구", "송파구", "강동구", "마포구", "용산구", "성동구", "광진구",
  "분당", "일산", "평촌", "산본", "중동", "수원", "성남", "고양", "부천", "안산",
  "부산 해운대", "부산 서면", "대구 수성구", "대전 유성구", "기타 지역"
];

const propertyTypes = [
  "아파트", "빌라/연립", "단독주택", "오피스텔", "상가", "토지",
  "펜트하우스", "타운하우스", "복합시설", "재건축 예정", "리모델링 예정", "신축"
];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "대박 운세";
  if (score >= 70) return "상승 운세";
  if (score >= 55) return "안정 운세";
  return "신중 필요";
};

export default function LuckyRealEstatePage() {
  const { toast } = useToast();
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<RealEstateInfo>({
    name: '',
    birth_date: '',
    current_age: '',
    investment_experience: '',
    budget_range: '',
    investment_purpose: [],
    preferred_areas: [],
    property_types: [],
    investment_timeline: '',
    current_situation: '',
    concerns: ''
  });
  const [result, setResult] = useState<RealEstateFortune | null>(null);

  const analyzeRealEstateFortune = async (): Promise<RealEstateFortune> => {
    // Create deterministic random generator based on user and date
    const userId = formData.name || 'guest';
    const dateString = selectedDate ? selectedDate.toISOString().split('T')[0] : getTodayDateString();
    const rng = createDeterministicRandom(userId, dateString, 'page');
    try {
      const response = await fetch('/api/fortune/lucky-realestate', {
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
      const preferredAreas = ["강남구", "서초구", "송파구", "마포구", "성동구"];
      const propertyTypes = ["아파트", "오피스텔", "주택"];
      
      return {
        overall_luck: Math.max(50, Math.min(95, baseScore + rng.randomInt(0, 14))),
        buying_luck: Math.max(45, Math.min(100, baseScore + rng.randomInt(0, 19) - 5)),
        selling_luck: Math.max(40, Math.min(95, baseScore + rng.randomInt(0, 19) - 10)),
        rental_luck: Math.max(50, Math.min(100, baseScore + rng.randomInt(0, 14))),
        location_luck: Math.max(55, Math.min(95, baseScore + rng.randomInt(0, 19) - 5)),
        analysis: {
          strength: "부동산 시장에 대한 직감이 좋고, 장기적인 안목으로 투자할 수 있는 인내심을 가지고 있습니다.",
          weakness: "때로는 과도한 신중함으로 인해 좋은 기회를 놓칠 수 있으니 적절한 결단력이 필요합니다.",
          opportunity: "정부 정책과 시장 변화를 잘 파악하여 새로운 투자 기회를 발견할 수 있는 시기입니다.",
          risk: "감정적인 투자 결정을 내릴 수 있는 위험이 있으니 항상 객관적인 분석을 바탕으로 해야 합니다."
        },
        lucky_elements: {
          areas: preferredAreas.slice(0, 3),
          property_types: propertyTypes.slice(0, 2),
          timing: "봄철(3-5월)",
          direction: "남향",
          floor_preference: "중층(5-10층)"
        },
        recommendations: {
          investment_tips: [
            "장기 보유를 전제로 한 투자 계획을 세우세요",
            "입지와 교통 편의성을 최우선으로 고려하세요",
            "레버리지 비율을 적절히 조절하여 리스크를 관리하세요"
          ],
          timing_strategies: [
            "시장 과열기보다는 조정기에 투자 기회를 찾으세요",
            "금리 변동과 부동산 정책을 주시하여 타이밍을 잡으세요",
            "계절적 요인을 고려하여 매매 시점을 조절하세요"
          ],
          location_advice: [
            "교통 개발 계획이 있는 지역을 주목하세요",
            "학군과 생활 인프라가 우수한 지역을 우선 고려하세요",
            "재개발이나 재건축 계획이 있는 지역을 체크하세요"
          ],
          risk_management: [
            "투자 금액의 한도를 미리 정하고 준수하세요",
            "대출 비율을 소득 대비 적정 수준으로 유지하세요",
            "여러 지역이나 물건 유형으로 분산 투자하세요"
          ]
        },
        future_predictions: {
          this_month: "신중한 검토가 필요한 시기입니다. 서두르지 말고 충분히 조사한 후 결정하세요.",
          next_quarter: "좋은 투자 기회가 나타날 수 있습니다. 평소 관심 지역의 시장 동향을 주의깊게 살펴보세요.",
          this_year: "장기적인 관점에서 안정적인 수익을 기대할 수 있는 해입니다. 꾸준한 투자로 자산을 늘려가세요."
        },
        warning_signs: [
          "과도한 레버리지 투자는 피하세요",
          "감정적 판단보다는 객관적 데이터에 의존하세요",
          "유행이나 소문에만 의존한 투자는 위험합니다",
          "단기 차익을 노린 무리한 투자는 자제하세요",
          "본인의 재정 능력을 넘어서는 투자는 금물입니다"
        ]
      };
    }
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.investment_experience) {
      toast({
      title: '필수 정보를 모두 입력해주세요.',
      variant: "default",
    });
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeRealEstateFortune();
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

  const handleCheckboxChange = (value: string, checked: boolean, field: 'investment_purpose' | 'preferred_areas' | 'property_types') => {
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
      investment_experience: '',
      budget_range: '',
      investment_purpose: [],
      preferred_areas: [],
      property_types: [],
      investment_timeline: '',
      current_situation: '',
      concerns: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-violet-50 via-purple-25 to-indigo-50 pb-32">
      <AppHeader title="행운의 부동산" />
      
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
                  className="bg-gradient-to-r from-violet-500 to-purple-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.3 }}
                >
                  <Building2 className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 부동산</h1>
                <p className="text-gray-600">성공적인 부동산 투자의 비밀을 찾아보세요</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-violet-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-violet-700">
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
                  </CardContent>
                </Card>
              </motion.div>

              {/* 투자 경험 */}
              <motion.div variants={itemVariants}>
                <Card className="border-purple-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-purple-700">
                      <BarChart3 className="w-5 h-5" />
                      부동산 투자 경험
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>부동산 투자 경험</Label>
                      <RadioGroup 
                        value={formData.investment_experience} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, investment_experience: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="expert" id="expert" />
                          <Label htmlFor="expert">전문가 수준 (10건 이상)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="experienced" id="experienced" />
                          <Label htmlFor="experienced">경험자 (3-10건)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="intermediate" id="intermediate" />
                          <Label htmlFor="intermediate">초보자 (1-3건)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="beginner" id="beginner" />
                          <Label htmlFor="beginner">입문자 (첫 투자)</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label htmlFor="budget_range">투자 예산 범위 (억원)</Label>
                      <Input
                        id="budget_range"
                        placeholder="예: 5억원"
                        value={formData.budget_range}
                        onChange={(e) => setFormData(prev => ({ ...prev, budget_range: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label>투자 기간</Label>
                      <RadioGroup 
                        value={formData.investment_timeline} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, investment_timeline: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="short" id="short" />
                          <Label htmlFor="short">단기 (1-3년)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="medium" id="medium" />
                          <Label htmlFor="medium">중기 (3-10년)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="long" id="long" />
                          <Label htmlFor="long">장기 (10년 이상)</Label>
                        </div>
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 투자 목적 및 선호도 */}
              <motion.div variants={itemVariants}>
                <Card className="border-indigo-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-indigo-700">
                      <Target className="w-5 h-5" />
                      투자 목적 & 선호도
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>투자 목적 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {investmentPurposes.map((purpose) => (
                          <div key={purpose} className="flex items-center space-x-2">
                            <Checkbox
                              id={purpose}
                              checked={formData.investment_purpose.includes(purpose)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange(purpose, checked as boolean, 'investment_purpose')
                              }
                            />
                            <Label htmlFor={purpose} className="text-sm">{purpose}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <Label>선호 지역 (복수 선택)</Label>
                      <div className="grid grid-cols-3 gap-2 mt-2 max-h-40 overflow-y-auto">
                        {preferredAreas.map((area) => (
                          <div key={area} className="flex items-center space-x-2">
                            <Checkbox
                              id={area}
                              checked={formData.preferred_areas.includes(area)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange(area, checked as boolean, 'preferred_areas')
                              }
                            />
                            <Label htmlFor={area} className="text-sm">{area}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <Label>관심 부동산 유형 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {propertyTypes.map((type) => (
                          <div key={type} className="flex items-center space-x-2">
                            <Checkbox
                              id={type}
                              checked={formData.property_types.includes(type)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange(type, checked as boolean, 'property_types')
                              }
                            />
                            <Label htmlFor={type} className="text-sm">{type}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 현황 및 고민 */}
              <motion.div variants={itemVariants}>
                <Card className="border-violet-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-violet-700">
                      <Search className="w-5 h-5" />
                      현재 상황 & 고민사항
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="current_situation">현재 부동산 보유 현황</Label>
                      <Textarea
                        id="current_situation"
                        placeholder="예: 거주용 아파트 1채 보유, 전세로 거주 중, 임대용 오피스텔 보유 등..."
                        value={formData.current_situation}
                        onChange={(e) => setFormData(prev => ({ ...prev, current_situation: e.target.value }))}
                        className="mt-1 min-h-[60px]"
                      />
                    </div>
                    <div>
                      <Label htmlFor="concerns">부동산 투자 관련 고민이나 질문</Label>
                      <Textarea
                        id="concerns"
                        placeholder="투자 지역 선택, 매매 타이밍, 대출 활용, 세금 문제 등 궁금한 점을 적어주세요..."
                        value={formData.concerns}
                        onChange={(e) => setFormData(prev => ({ ...prev, concerns: e.target.value }))}
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
                  className="w-full bg-gradient-to-r from-violet-500 to-purple-500 hover:from-violet-600 hover:to-purple-600 text-white py-6 text-lg font-semibold"
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
                      <Building2 className="w-5 h-5" />
                      부동산 운세 분석하기
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
                <Card className="bg-gradient-to-r from-violet-500 to-purple-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Building2 className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 부동산 운세</span>
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
                    <CardTitle className="flex items-center gap-2 text-violet-600">
                      <BarChart3 className="w-5 h-5" />
                      세부 부동산 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "매수운", score: result.buying_luck, icon: TrendingUp, desc: "좋은 물건을 적정가에 매수하는 운" },
                      { label: "매도운", score: result.selling_luck, icon: Coins, desc: "높은 가격에 매도할 수 있는 운" },
                      { label: "임대운", score: result.rental_luck, icon: Home, desc: "안정적인 임대 수익을 얻는 운" },
                      { label: "입지운", score: result.location_luck, icon: MapPin, desc: "미래 가치가 상승할 지역을 찾는 운" }
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
                                className="bg-violet-500 h-2 rounded-full"
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
                      부동산 투자 SWOT 분석
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

              {/* 행운의 부동산 요소 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Crown className="w-5 h-5" />
                      행운의 부동산 요소
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-purple-50 rounded-lg">
                        <h4 className="font-medium text-purple-800 mb-2 flex items-center gap-2">
                          <MapPin className="w-4 h-4" />
                          행운의 지역
                        </h4>
                        <div className="flex flex-wrap gap-2">
                          {result.lucky_elements.areas.map((area, index) => (
                            <Badge key={index} variant="secondary" className="bg-purple-100 text-purple-700">
                              {area}
                            </Badge>
                          ))}
                        </div>
                      </div>
                      <div className="grid grid-cols-2 gap-4">
                        <div className="p-4 bg-indigo-50 rounded-lg">
                          <h4 className="font-medium text-indigo-800 mb-2 flex items-center gap-2">
                            <Building className="w-4 h-4" />
                            행운의 부동산 유형
                          </h4>
                          <div className="space-y-1">
                            {result.lucky_elements.property_types.map((type, index) => (
                              <p key={index} className="text-indigo-700 text-sm">{type}</p>
                            ))}
                          </div>
                        </div>
                        <div className="p-4 bg-teal-50 rounded-lg">
                          <h4 className="font-medium text-teal-800 mb-2 flex items-center gap-2">
                            <Clock className="w-4 h-4" />
                            행운의 타이밍
                          </h4>
                          <p className="text-teal-700 text-sm">{result.lucky_elements.timing}</p>
                        </div>
                      </div>
                      <div className="grid grid-cols-2 gap-4">
                        <div className="p-4 bg-emerald-50 rounded-lg">
                          <h4 className="font-medium text-emerald-800 mb-2 flex items-center gap-2">
                            <Target className="w-4 h-4" />
                            행운의 방향
                          </h4>
                          <p className="text-emerald-700 text-sm">{result.lucky_elements.direction}</p>
                        </div>
                        <div className="p-4 bg-amber-50 rounded-lg">
                          <h4 className="font-medium text-amber-800 mb-2 flex items-center gap-2">
                            <Landmark className="w-4 h-4" />
                            행운의 층수
                          </h4>
                          <p className="text-amber-700 text-sm">{result.lucky_elements.floor_preference}</p>
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 투자 전략 및 조언 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <LineChart className="w-5 h-5" />
                      맞춤 투자 전략
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <DollarSign className="w-4 h-4 text-green-500" />
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
                            <Star className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{tip}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Timer className="w-4 h-4 text-blue-500" />
                        타이밍 전략
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.timing_strategies.map((strategy, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.8 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Clock className="w-4 h-4 text-blue-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{strategy}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <MapPin className="w-4 h-4 text-purple-500" />
                        입지 선정 조언
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.location_advice.map((advice, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 1.0 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <MapPin className="w-4 h-4 text-purple-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{advice}</p>
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
                      부동산 투자 주의사항
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.warning_signs.map((warning, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.2 + index * 0.1 }}
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

              {/* 미래 전망 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-indigo-600">
                      <Calendar className="w-5 h-5" />
                      부동산 운세 전망
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-blue-50 rounded-lg">
                        <h4 className="font-medium text-blue-800 mb-2 flex items-center gap-2">
                          <Timer className="w-4 h-4" />
                          이번 달
                        </h4>
                        <p className="text-blue-700 text-sm">{result.future_predictions.this_month}</p>
                      </div>
                      <div className="p-4 bg-indigo-50 rounded-lg">
                        <h4 className="font-medium text-indigo-800 mb-2 flex items-center gap-2">
                          <Calendar className="w-4 h-4" />
                          다음 분기
                        </h4>
                        <p className="text-indigo-700 text-sm">{result.future_predictions.next_quarter}</p>
                      </div>
                      <div className="p-4 bg-purple-50 rounded-lg">
                        <h4 className="font-medium text-purple-800 mb-2 flex items-center gap-2">
                          <Crown className="w-4 h-4" />
                          올해
                        </h4>
                        <p className="text-purple-700 text-sm">{result.future_predictions.this_year}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-violet-300 text-violet-600 hover:bg-violet-50 py-3"
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