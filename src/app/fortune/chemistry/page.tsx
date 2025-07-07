"use client";

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
import { DeterministicRandom } from '@/lib/deterministic-random';
import { 
  Flame, 
  Heart, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Users,
  Eye,
  Zap,
  TrendingUp,
  Shield,
  Lock,
  AlertTriangle,
  ThermometerSun,
  Waves,
  Crown,
  Target,
  Calendar
} from "lucide-react";

interface ChemistryInfo {
  person1: {
    name: string;
    age: string;
    sign: string;
    personality_traits: string[];
    intimate_preferences: string;
  };
  person2: {
    name: string;
    age: string;
    sign: string;
    personality_traits: string[];
    intimate_preferences: string;
  };
  relationship_duration: string;
  intimacy_level: string;
  concerns: string;
}

interface ChemistryResult {
  overall_chemistry: number;
  physical_attraction: number;
  emotional_connection: number;
  passion_intensity: number;
  compatibility_level: number;
  intimacy_potential: number;
  insights: {
    strengths: string;
    challenges: string;
    enhancement_tips: string;
  };
  detailed_analysis: {
    physical_chemistry: string;
    emotional_bond: string;
    passion_dynamics: string;
    intimacy_forecast: string;
  };
  recommendations: {
    enhancement_activities: string[];
    communication_tips: string[];
    intimacy_advice: string[];
  };
  warnings: string[];
  compatibility_percentage: number;
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

const getChemistryColor = (score: number) => {
  if (score >= 85) return "text-red-600 bg-red-50";
  if (score >= 70) return "text-pink-600 bg-pink-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-gray-600 bg-gray-50";
};

const getChemistryText = (score: number) => {
  if (score >= 85) return "뜨거운 케미";
  if (score >= 70) return "좋은 케미";
  if (score >= 55) return "보통 케미";
  return "개선 필요";
};

const personalityTraits = [
  "열정적", "로맨틱", "섬세함", "적극적", "배려심", 
  "유머러스", "신중함", "감성적", "자유로움", "안정적"
];

const zodiacSigns = [
  "양자리", "황소자리", "쌍둥이자리", "게자리", "사자자리", "처녀자리",
  "천칭자리", "전갈자리", "사수자리", "염소자리", "물병자리", "물고기자리"
];

export default function ChemistryPage() {
  // Initialize deterministic random for consistent results
  // Get actual user ID from auth context
  const { user } = useAuth();
  const userId = user?.id || 'guest-user';
  const today = new Date().toISOString().split('T')[0];
  const fortuneType = 'page';
  const deterministicRandom = new DeterministicRandom(userId, today, fortuneType);

  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<ChemistryInfo>({
    person1: {
      name: '',
      age: '',
      sign: '',
      personality_traits: [],
      intimate_preferences: ''
    },
    person2: {
      name: '',
      age: '',
      sign: '',
      personality_traits: [],
      intimate_preferences: ''
    },
    relationship_duration: '',
    intimacy_level: '',
    concerns: ''
  });
  const [result, setResult] = useState<ChemistryResult | null>(null);

  const analyzeChemistry = async (): Promise<ChemistryResult> => {
    try {
      const response = await fetch('/api/fortune/chemistry', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error('속궁합 분석에 실패했습니다.');
      }

      const data = await response.json();
      return data.analysis || data;
    } catch (error) {
      console.error('GPT 연동 실패, 기본 데이터 사용:', error);
      
      // GPT 실패시 기본 로직
      const baseScore = deterministicRandom.randomInt(60, 60 + 25 - 1); // 60-85 사이
      
      return {
        overall_chemistry: Math.max(45, Math.min(95, baseScore + Math.floor(deterministicRandom.random() * 15))),
        physical_attraction: Math.max(50, Math.min(100, baseScore + Math.floor(deterministicRandom.random() * 20) - 5)),
        emotional_connection: Math.max(45, Math.min(95, baseScore + Math.floor(deterministicRandom.random() * 20) - 10)),
        passion_intensity: Math.max(55, Math.min(100, baseScore + Math.floor(deterministicRandom.random() * 15))),
        compatibility_level: Math.max(50, Math.min(95, baseScore + Math.floor(deterministicRandom.random() * 20) - 5)),
        intimacy_potential: Math.max(60, Math.min(100, baseScore + Math.floor(deterministicRandom.random() * 15))),
        insights: {
          strengths: "두 분의 에너지가 매우 조화로우며, 서로에 대한 깊은 이해와 신뢰를 바탕으로 한 친밀감이 돋보입니다.",
          challenges: "때로는 감정 표현 방식의 차이로 인해 오해가 생길 수 있으니, 더욱 솔직하고 개방적인 소통이 필요합니다.",
          enhancement_tips: "서로의 욕구와 선호도를 더 깊이 이해하고, 새로운 경험을 함께 시도해보는 것이 관계 발전에 도움이 됩니다."
        },
        detailed_analysis: {
          physical_chemistry: "신체적 매력과 끌림이 강하며, 서로에게 자연스럽게 이끌리는 에너지를 가지고 있습니다.",
          emotional_bond: "감정적으로 깊이 연결되어 있으며, 서로의 마음을 잘 이해하고 공감하는 능력이 뛰어납니다.",
          passion_dynamics: "열정적인 관계를 유지할 수 있는 잠재력이 크며, 서로를 자극하고 발전시키는 역동성이 있습니다.",
          intimacy_forecast: "시간이 지날수록 더욱 깊어질 수 있는 친밀감의 가능성이 높으며, 지속적인 관심과 노력으로 발전할 수 있습니다."
        },
        recommendations: {
          enhancement_activities: [
            "함께하는 새로운 취미나 활동 시도하기",
            "정기적인 데이트 시간 확보하기",
            "서로의 관심사에 대해 더 깊이 알아가기",
            "감정을 솔직하게 표현하는 시간 갖기",
            "로맨틱한 분위기 조성하기"
          ],
          communication_tips: [
            "상대방의 감정을 먼저 이해하려 노력하기",
            "비판보다는 격려와 지지 표현하기",
            "욕구와 바람을 솔직하게 이야기하기",
            "갈등 상황에서도 존중하는 태도 유지하기",
            "정기적인 관계 점검 시간 갖기"
          ],
          intimacy_advice: [
            "서로의 경계와 선호도 존중하기",
            "새로운 경험에 대해 열린 마음 갖기",
            "충분한 시간과 여유 확보하기",
            "감정적 친밀감 먼저 쌓기",
            "상대방의 반응에 세심하게 주의 기울이기"
          ]
        },
        warnings: [
          "성급한 진전보다는 서로를 충분히 이해하는 시간 필요",
          "상대방의 의사를 존중하지 않는 강요는 금물",
          "감정적 상처를 줄 수 있는 말이나 행동 주의",
          "외부 스트레스가 관계에 영향을 주지 않도록 관리"
        ],
        compatibility_percentage: Math.max(55, Math.min(95, baseScore + Math.floor(deterministicRandom.random() * 20)))
      };
    }
  };

  const handleSubmit = async () => {
    if (!formData.person1.name || !formData.person2.name || !formData.relationship_duration || !formData.intimacy_level) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeChemistry();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handlePersonalityChange = (person: 'person1' | 'person2', trait: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      [person]: {
        ...prev[person],
        personality_traits: checked 
          ? [...prev[person].personality_traits, trait]
          : prev[person].personality_traits.filter(t => t !== trait)
      }
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      person1: {
        name: '',
        age: '',
        sign: '',
        personality_traits: [],
        intimate_preferences: ''
      },
      person2: {
        name: '',
        age: '',
        sign: '',
        personality_traits: [],
        intimate_preferences: ''
      },
      relationship_duration: '',
      intimacy_level: '',
      concerns: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-red-50 via-pink-25 to-rose-50 pb-32">
      <AppHeader title="속궁합" />
      
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
              {/* 경고 메시지 */}
              <motion.div variants={itemVariants}>
                <Card className="border-amber-200 bg-amber-50">
                  <CardContent className="py-4">
                    <div className="flex items-start gap-3">
                      <AlertTriangle className="w-5 h-5 text-amber-600 mt-0.5 flex-shrink-0" />
                      <div>
                        <h4 className="font-medium text-amber-800 mb-1">주의사항</h4>
                        <p className="text-amber-700 text-sm">
                          이 분석은 오락 목적으로만 제공되며, 실제 관계에서는 서로에 대한 존중과 소통이 가장 중요합니다. 
                          19세 미만은 이용을 삼가해 주시기 바랍니다.
                        </p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 헤더 */}
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-red-500 to-pink-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Flame className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">속궁합 분석</h1>
                <p className="text-gray-600">은밀하고 깊은 관계의 궁합을 분석해드립니다</p>
              </motion.div>

              {/* 첫 번째 사람 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-red-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-red-700">
                      <Users className="w-5 h-5" />
                      첫 번째 분 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="person1-name">이름</Label>
                        <Input
                          id="person1-name"
                          placeholder="이름"
                          value={formData.person1.name}
                          onChange={(e) => setFormData(prev => ({ 
                            ...prev, 
                            person1: { ...prev.person1, name: e.target.value }
                          }))}
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <Label htmlFor="person1-age">나이</Label>
                        <Input
                          id="person1-age"
                          type="number"
                          placeholder="나이"
                          value={formData.person1.age}
                          onChange={(e) => setFormData(prev => ({ 
                            ...prev, 
                            person1: { ...prev.person1, age: e.target.value }
                          }))}
                          className="mt-1"
                        />
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="person1-sign">별자리</Label>
                      <RadioGroup 
                        value={formData.person1.sign} 
                        onValueChange={(value) => setFormData(prev => ({ 
                          ...prev, 
                          person1: { ...prev.person1, sign: value }
                        }))}
                        className="mt-2 grid grid-cols-3 gap-2"
                      >
                        {zodiacSigns.map((sign) => (
                          <div key={sign} className="flex items-center space-x-2">
                            <RadioGroupItem value={sign} id={`person1-${sign}`} />
                            <Label htmlFor={`person1-${sign}`} className="text-sm">{sign}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>성격 특성 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {personalityTraits.map((trait) => (
                          <div key={trait} className="flex items-center space-x-2">
                            <Checkbox
                              id={`person1-${trait}`}
                              checked={formData.person1.personality_traits.includes(trait)}
                              onCheckedChange={(checked) => 
                                handlePersonalityChange('person1', trait, checked as boolean)
                              }
                            />
                            <Label htmlFor={`person1-${trait}`} className="text-sm">{trait}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="person1-preferences">친밀한 관계에서 중요하게 생각하는 것</Label>
                      <Textarea
                        id="person1-preferences"
                        placeholder="감정적 연결, 신뢰, 로맨스 등..."
                        value={formData.person1.intimate_preferences}
                        onChange={(e) => setFormData(prev => ({ 
                          ...prev, 
                          person1: { ...prev.person1, intimate_preferences: e.target.value }
                        }))}
                        className="mt-1 min-h-[60px]"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 두 번째 사람 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-pink-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-pink-700">
                      <Heart className="w-5 h-5" />
                      두 번째 분 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="person2-name">이름</Label>
                        <Input
                          id="person2-name"
                          placeholder="이름"
                          value={formData.person2.name}
                          onChange={(e) => setFormData(prev => ({ 
                            ...prev, 
                            person2: { ...prev.person2, name: e.target.value }
                          }))}
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <Label htmlFor="person2-age">나이</Label>
                        <Input
                          id="person2-age"
                          type="number"
                          placeholder="나이"
                          value={formData.person2.age}
                          onChange={(e) => setFormData(prev => ({ 
                            ...prev, 
                            person2: { ...prev.person2, age: e.target.value }
                          }))}
                          className="mt-1"
                        />
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="person2-sign">별자리</Label>
                      <RadioGroup 
                        value={formData.person2.sign} 
                        onValueChange={(value) => setFormData(prev => ({ 
                          ...prev, 
                          person2: { ...prev.person2, sign: value }
                        }))}
                        className="mt-2 grid grid-cols-3 gap-2"
                      >
                        {zodiacSigns.map((sign) => (
                          <div key={sign} className="flex items-center space-x-2">
                            <RadioGroupItem value={sign} id={`person2-${sign}`} />
                            <Label htmlFor={`person2-${sign}`} className="text-sm">{sign}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>성격 특성 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {personalityTraits.map((trait) => (
                          <div key={trait} className="flex items-center space-x-2">
                            <Checkbox
                              id={`person2-${trait}`}
                              checked={formData.person2.personality_traits.includes(trait)}
                              onCheckedChange={(checked) => 
                                handlePersonalityChange('person2', trait, checked as boolean)
                              }
                            />
                            <Label htmlFor={`person2-${trait}`} className="text-sm">{trait}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="person2-preferences">친밀한 관계에서 중요하게 생각하는 것</Label>
                      <Textarea
                        id="person2-preferences"
                        placeholder="감정적 연결, 신뢰, 로맨스 등..."
                        value={formData.person2.intimate_preferences}
                        onChange={(e) => setFormData(prev => ({ 
                          ...prev, 
                          person2: { ...prev.person2, intimate_preferences: e.target.value }
                        }))}
                        className="mt-1 min-h-[60px]"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 관계 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-red-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-red-700">
                      <Calendar className="w-5 h-5" />
                      관계 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>관계 지속 기간</Label>
                      <RadioGroup 
                        value={formData.relationship_duration} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, relationship_duration: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="new" id="new" />
                          <Label htmlFor="new">새로운 관계 (1개월 미만)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="developing" id="developing" />
                          <Label htmlFor="developing">발전하는 관계 (1-6개월)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="established" id="established" />
                          <Label htmlFor="established">안정된 관계 (6개월-2년)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="long-term" id="long-term" />
                          <Label htmlFor="long-term">장기 관계 (2년 이상)</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>현재 친밀감 수준</Label>
                      <RadioGroup 
                        value={formData.intimacy_level} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, intimacy_level: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="emotional" id="emotional" />
                          <Label htmlFor="emotional">감정적 친밀감 위주</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="developing-physical" id="developing-physical" />
                          <Label htmlFor="developing-physical">신체적 친밀감 발전 중</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="full-intimacy" id="full-intimacy" />
                          <Label htmlFor="full-intimacy">완전한 친밀감</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="exploring" id="exploring" />
                          <Label htmlFor="exploring">새로운 경험 탐색 중</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label htmlFor="concerns">궁금한 점이나 고민 (선택사항)</Label>
                      <Textarea
                        id="concerns"
                        placeholder="관계에서 궁금하거나 개선하고 싶은 부분이 있다면 자유롭게 적어주세요..."
                        value={formData.concerns}
                        onChange={(e) => setFormData(prev => ({ ...prev, concerns: e.target.value }))}
                        className="mt-2 min-h-[80px]"
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
                  className="w-full bg-gradient-to-r from-red-500 to-pink-500 hover:from-red-600 hover:to-pink-600 text-white py-6 text-lg font-semibold"
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
                      <Flame className="w-5 h-5" />
                      속궁합 분석하기
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
              {/* 전체 속궁합 점수 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-red-500 to-pink-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Flame className="w-6 h-6" />
                      <span className="text-xl font-medium">
                        {formData.person1.name}님 & {formData.person2.name}님
                      </span>
                    </div>
                    <p className="text-white/90 text-lg mb-4">속궁합 지수</p>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className="text-6xl font-bold mb-2"
                    >
                      {result.overall_chemistry}점
                    </motion.div>
                    <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                      {getChemistryText(result.overall_chemistry)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 세부 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <ThermometerSun className="w-5 h-5 text-red-600" />
                      세부 케미 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "신체적 매력", score: result.physical_attraction, icon: Eye, desc: "서로에 대한 시각적, 신체적 끌림" },
                      { label: "감정적 연결", score: result.emotional_connection, icon: Heart, desc: "마음과 감정의 교감" },
                      { label: "열정 강도", score: result.passion_intensity, icon: Flame, desc: "관계의 뜨거움과 강렬함" },
                      { label: "궁합 수준", score: result.compatibility_level, icon: Star, desc: "전반적인 조화와 어울림" },
                      { label: "친밀감 잠재력", score: result.intimacy_potential, icon: Lock, desc: "깊어질 수 있는 친밀감의 가능성" }
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
                              <span className={`px-3 py-1 rounded-full text-sm font-medium ${getChemistryColor(item.score)}`}>
                                {item.score}점
                              </span>
                            </div>
                            <div className="w-full bg-gray-200 rounded-full h-2">
                              <motion.div
                                className="bg-red-500 h-2 rounded-full"
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

              {/* 상세 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-red-600">
                      <Target className="w-5 h-5" />
                      상세 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-red-50 rounded-lg">
                        <h4 className="font-medium text-red-800 mb-2 flex items-center gap-2">
                          <Eye className="w-4 h-4" />
                          신체적 케미스트리
                        </h4>
                        <p className="text-red-700">{result.detailed_analysis.physical_chemistry}</p>
                      </div>
                      <div className="p-4 bg-pink-50 rounded-lg">
                        <h4 className="font-medium text-pink-800 mb-2 flex items-center gap-2">
                          <Heart className="w-4 h-4" />
                          감정적 유대감
                        </h4>
                        <p className="text-pink-700">{result.detailed_analysis.emotional_bond}</p>
                      </div>
                      <div className="p-4 bg-orange-50 rounded-lg">
                        <h4 className="font-medium text-orange-800 mb-2 flex items-center gap-2">
                          <Flame className="w-4 h-4" />
                          열정의 역학
                        </h4>
                        <p className="text-orange-700">{result.detailed_analysis.passion_dynamics}</p>
                      </div>
                      <div className="p-4 bg-purple-50 rounded-lg">
                        <h4 className="font-medium text-purple-800 mb-2 flex items-center gap-2">
                          <Crown className="w-4 h-4" />
                          친밀감 전망
                        </h4>
                        <p className="text-purple-700">{result.detailed_analysis.intimacy_forecast}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 인사이트 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Sparkles className="w-5 h-5" />
                      관계 인사이트
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-green-50 rounded-lg">
                        <h4 className="font-medium text-green-800 mb-2">강점</h4>
                        <p className="text-green-700">{result.insights.strengths}</p>
                      </div>
                      <div className="p-4 bg-amber-50 rounded-lg">
                        <h4 className="font-medium text-amber-800 mb-2">과제</h4>
                        <p className="text-amber-700">{result.insights.challenges}</p>
                      </div>
                      <div className="p-4 bg-blue-50 rounded-lg">
                        <h4 className="font-medium text-blue-800 mb-2">발전 방향</h4>
                        <p className="text-blue-700">{result.insights.enhancement_tips}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 관계 향상 조언 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <TrendingUp className="w-5 h-5" />
                      관계 향상 조언
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Sparkles className="w-4 h-4 text-blue-500" />
                        추천 활동
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.enhancement_activities.map((activity, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.6 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Star className="w-4 h-4 text-blue-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700">{activity}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Waves className="w-4 h-4 text-green-500" />
                        소통 팁
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.communication_tips.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.8 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Heart className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700">{tip}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Lock className="w-4 h-4 text-red-500" />
                        친밀감 조언
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.intimacy_advice.map((advice, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 1.0 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Flame className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700">{advice}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 주의사항 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-amber-600">
                      <Shield className="w-5 h-5" />
                      주의사항
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.warnings.map((warning, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 1.2 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <AlertTriangle className="w-4 h-4 text-amber-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{warning}</p>
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
                  className="w-full border-red-300 text-red-600 hover:bg-red-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 관계 분석하기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}