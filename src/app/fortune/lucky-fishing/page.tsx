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
import { 
  Fish, 
  Trophy, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Users,
  Target,
  TrendingUp,
  Shield,
  Crown,
  Calendar,
  Clock,
  Award,
  Flag,
  PlayCircle,
  BarChart3,
  Activity,
  Eye,
  ThumbsUp,
  Heart,
  MapPin,
  Timer,
  Waves,
  Flame,
  Anchor
} from "lucide-react";

import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";
interface FishingInfo {
  name: string;
  birth_date: string;
  fishing_type: string;
  favorite_location: string;
  experience_level: string;
  fishing_frequency: string;
  fishing_techniques: string[];
  lucky_number: string;
  current_goal: string;
  special_memory: string;
}

interface FishingFortune {
  overall_luck: number;
  catch_luck: number;
  location_luck: number;
  weather_luck: number;
  equipment_luck: number;
  analysis: {
    strength: string;
    weakness: string;
    opportunity: string;
    challenge: string;
  };
  lucky_bait: string;
  lucky_fishing_spot: string;
  lucky_fishing_time: string;
  lucky_weather: string;
  recommendations: {
    technique_tips: string[];
    location_advice: string[];
    equipment_suggestions: string[];
    timing_strategies: string[];
  };
  future_predictions: {
    this_week: string;
    this_month: string;
    this_season: string;
  };
  compatibility: {
    best_fishing_buddy: string;
    ideal_guide_style: string;
    perfect_fishing_environment: string;
  };
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

const fishingTypes = [
  "바다낚시", "민물낚시", "루어낚시", "플라이낚시", 
  "선상낚시", "갯바위낚시", "계곡낚시", "저수지낚시"
];

const locations = [
  "동해", "서해", "남해", "제주도", "한강", "낙동강", 
  "금강", "영산강", "계곡", "저수지", "연못", "양식장"
];

const techniques = [
  "원투낚시", "찌낚시", "루어낚시", "플라이낚시", "견지낚시", 
  "갯바위낚시", "선상낚시", "트롤링", "지깅", "에깅", "텍사스리그", "캐롤라이나리그"
];

const baits = [
  "지렁이", "새우", "크릴", "미끼고기", "루어", "플라이", 
  "빵", "옥수수", "떡밥", "붕어빵"
];

const fishingSpots = [
  "부산 해운대", "제주 성산포", "강릉 사천진", "여수 금오도", 
  "청양 칠갑산", "가평 청평호", "춘천 의암호", "경포대"
];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "대박 조황";
  if (score >= 70) return "좋은 입질";
  if (score >= 55) return "평범한 조황";
  return "꽝 주의";
};

export default function LuckyFishingPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<FishingInfo>({
    name: '',
    birth_date: '',
    fishing_type: '',
    favorite_location: '',
    experience_level: '',
    fishing_frequency: '',
    fishing_techniques: [],
    lucky_number: '',
    current_goal: '',
    special_memory: ''
  });
  const [result, setResult] = useState<FishingFortune | null>(null);

  const analyzeFishingFortune = async ():
    // Create deterministic random generator based on user and date
    const userId = formData.name || 'guest';
    const dateString = selectedDate ? selectedDate.toISOString().split('T')[0] : getTodayDateString();
    const rng = createDeterministicRandom(userId, dateString, 'page');
     Promise<FishingFortune> => {
    const baseScore = rng.randomInt(0, 24) + 60;

    return {
      overall_luck: Math.max(50, Math.min(95, baseScore + rng.randomInt(0, 14))),
      catch_luck: Math.max(45, Math.min(100, baseScore + rng.randomInt(0, 19) - 5)),
      location_luck: Math.max(40, Math.min(95, baseScore + rng.randomInt(0, 19) - 10)),
      weather_luck: Math.max(50, Math.min(100, baseScore + rng.randomInt(0, 14))),
      equipment_luck: Math.max(55, Math.min(95, baseScore + rng.randomInt(0, 19) - 5)),
      analysis: {
        strength: "침착하고 끈기 있는 성격으로 큰 고기를 낚을 때까지 기다릴 수 있는 인내력이 뛰어납니다.",
        weakness: "때로는 욕심이 과해서 욕심부리다가 놓치는 경우가 있으니 적당한 선에서 만족하는 것이 좋습니다.",
        opportunity: "자연과 조화를 이루는 능력이 뛰어나 좋은 포인트를 찾아내는 감각이 있습니다.",
        challenge: "날씨 변화에 민감할 수 있지만, 경험을 쌓으면서 다양한 상황에 적응할 수 있습니다."
      },
      lucky_bait: rng.randomElement(baits),
      lucky_fishing_spot: rng.randomElement(fishingSpots),
      lucky_fishing_time: ["새벽 5시", "오전 7시", "오후 5시", "일몰 시간"][rng.randomInt(0, 3)],
      lucky_weather: ["맑음", "흐림", "비온 후", "바람 없는 날"][rng.randomInt(0, 3)],
      recommendations: {
        technique_tips: [
          "미끼를 자주 바꿔주어 물고기의 관심을 끌어보세요",
          "조용히 움직여서 물고기를 놀라게 하지 마세요",
          "물때와 조류를 잘 파악해서 타이밍을 맞추세요"
        ],
        location_advice: [
          "물고기가 많이 모이는 구조물 근처를 노려보세요",
          "바람이 불어오는 방향을 등지고 앉아보세요",
          "수심 변화가 있는 지점을 찾아서 낚시해보세요"
        ],
        equipment_suggestions: [
          "낚싯대는 목적에 맞는 적절한 강도로 선택하세요",
          "릴의 드랙을 미리 조정해서 라인이 터지지 않게 하세요",
          "다양한 크기의 바늘을 준비해서 상황에 맞게 사용하세요"
        ],
        timing_strategies: [
          "해가 뜨기 전 새벽 시간대가 가장 좋습니다",
          "비가 온 후 맑아지는 날을 노려보세요",
          "조금 때보다는 사리 때가 더 유리합니다"
        ]
      },
      future_predictions: {
        this_week: "새로운 포인트를 개척하기 좋은 시기입니다. 평소 가보지 않은 곳에 도전해보세요.",
        this_month: "큰 고기를 낚을 수 있는 기회가 있습니다. 장비를 점검하고 준비를 철저히 하세요.",
        this_season: "낚시 실력이 한 단계 업그레이드되는 시기입니다. 꾸준히 연습하면 목표를 달성할 수 있습니다."
      },
      compatibility: {
        best_fishing_buddy: "차분하고 인내심이 강한 낚시 동반자",
        ideal_guide_style: "경험이 풍부하면서도 세심하게 가르쳐주는 가이드",
        perfect_fishing_environment: "조용하고 평화로우며 자연과 하나 될 수 있는 환경"
      }
    };
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.fishing_type) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeFishingFortune();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleCheckboxChange = (value: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      fishing_techniques: checked 
        ? [...prev.fishing_techniques, value]
        : prev.fishing_techniques.filter(item => item !== value)
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      fishing_type: '',
      favorite_location: '',
      experience_level: '',
      fishing_frequency: '',
      fishing_techniques: [],
      lucky_number: '',
      current_goal: '',
      special_memory: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-cyan-25 to-teal-50 pb-32">
      <AppHeader title="행운의 낚시" />
      
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
                  className="bg-gradient-to-r from-blue-500 to-cyan-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Fish className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 낚시</h1>
                <p className="text-gray-600">낚시를 통해 보는 당신의 운세와 대박 조황의 비결</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-blue-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-blue-700">
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
                      <Label htmlFor="lucky_number">행운의 번호 (1-99)</Label>
                      <Input
                        id="lucky_number"
                        type="number"
                        min="1"
                        max="99"
                        placeholder="좋아하는 번호"
                        value={formData.lucky_number}
                        onChange={(e) => setFormData(prev => ({ ...prev, lucky_number: e.target.value }))}
                        className="mt-1"
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
                  className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600 text-white py-6 text-lg font-semibold"
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
                      <Fish className="w-5 h-5" />
                      낚시 운세 분석하기
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
                <Card className="bg-gradient-to-r from-blue-500 to-cyan-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Fish className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 낚시 운세</span>
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

              {/* 다시 분석하기 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-blue-300 text-blue-600 hover:bg-blue-50 py-3"
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