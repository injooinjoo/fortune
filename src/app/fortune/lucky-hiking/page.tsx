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
import AppHeader from "@/components/AppHeader";
import { 
  Mountain, 
  Star, 
  ArrowRight,
  Shuffle,
  Users,
  Crown,
  Clock,
  BarChart3,
  Activity,
  Shield,
  CloudRain,
  Compass,
  TreePine
} from "lucide-react";

interface HikingInfo {
  name: string;
  birth_date: string;
  hiking_level: string;
  current_goal: string;
}

interface HikingFortune {
  overall_luck: number;
  summit_luck: number;
  weather_luck: number;
  safety_luck: number;
  endurance_luck: number;
  lucky_trail: string;
  lucky_mountain: string;
  lucky_hiking_time: string;
  lucky_weather: string;
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

const hikingLevels = [
  "초급 (1-3시간)", "중급 (3-6시간)", "고급 (6-12시간)", 
  "전문가 (12시간 이상)", "암벽등반", "빙벽등반"
];

const trails = ["능선길", "계곡길", "임도", "샛길", "암릉길"];
const mountains = ["지리산", "설악산", "한라산", "북한산", "계룡산"];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "완등 확실";
  if (score >= 70) return "순조로운 산행";
  if (score >= 55) return "보통 산행";
  return "조심스런 산행";
};

export default function LuckyHikingPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<HikingInfo>({
    name: '',
    birth_date: '',
    hiking_level: '',
    current_goal: ''
  });
  const [result, setResult] = useState<HikingFortune | null>(null);

  const analyzeHikingFortune = async (): Promise<HikingFortune> => {
    const baseScore = Math.floor(Math.random() * 25) + 60;

    return {
      overall_luck: Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 15))),
      summit_luck: Math.max(45, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 5)),
      weather_luck: Math.max(40, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 10)),
      safety_luck: Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 15))),
      endurance_luck: Math.max(55, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 5)),
      lucky_trail: trails[Math.floor(Math.random() * trails.length)],
      lucky_mountain: mountains[Math.floor(Math.random() * mountains.length)],
      lucky_hiking_time: ["새벽 출발", "오전 출발", "이른 아침", "해뜨기 전"][Math.floor(Math.random() * 4)],
      lucky_weather: ["맑음", "약간 흐림", "선선한 날", "바람 없는 날"][Math.floor(Math.random() * 4)]
    };
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.hiking_level) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeHikingFortune();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      hiking_level: '',
      current_goal: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-emerald-25 to-teal-50 pb-32">
      <AppHeader title="행운의 등산" />
      
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
                  className="bg-gradient-to-r from-green-500 to-emerald-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Mountain className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 등산</h1>
                <p className="text-gray-600">등산을 통해 보는 당신의 운세와 안전한 완주의 비결</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-green-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-green-700">
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
                  </CardContent>
                </Card>
              </motion.div>

              {/* 등산 레벨 */}
              <motion.div variants={itemVariants}>
                <Card className="border-emerald-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-emerald-700">
                      <Mountain className="w-5 h-5" />
                      등산 레벨
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>현재 등산 수준</Label>
                      <RadioGroup 
                        value={formData.hiking_level} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, hiking_level: value }))}
                        className="mt-2 grid grid-cols-1 gap-2"
                      >
                        {hikingLevels.map((level) => (
                          <div key={level} className="flex items-center space-x-2">
                            <RadioGroupItem value={level} id={level} />
                            <Label htmlFor={level} className="text-sm">{level}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 목표 */}
              <motion.div variants={itemVariants}>
                <Card className="border-green-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-green-700">
                      <Star className="w-5 h-5" />
                      등산 목표
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="current_goal">현재 등산 목표</Label>
                      <Textarea
                        id="current_goal"
                        placeholder="예: 백두대간 완주, 한라산 등반, 암벽등반 도전 등..."
                        value={formData.current_goal}
                        onChange={(e) => setFormData(prev => ({ ...prev, current_goal: e.target.value }))}
                        className="mt-1 min-h-[60px]"
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
                  className="w-full bg-gradient-to-r from-green-500 to-emerald-500 hover:from-green-600 hover:to-emerald-600 text-white py-6 text-lg font-semibold"
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
                      <Mountain className="w-5 h-5" />
                      등산 운세 분석하기
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
                <Card className="bg-gradient-to-r from-green-500 to-emerald-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Mountain className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 등산 운세</span>
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
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <BarChart3 className="w-5 h-5" />
                      세부 등산 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "완등운", score: result.summit_luck, icon: Mountain, desc: "정상에 도달하는 운" },
                      { label: "날씨운", score: result.weather_luck, icon: CloudRain, desc: "좋은 날씨를 만나는 운" },
                      { label: "안전운", score: result.safety_luck, icon: Shield, desc: "사고 없이 안전한 산행의 운" },
                      { label: "체력운", score: result.endurance_luck, icon: Activity, desc: "체력이 지속되는 운" }
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
                                className="bg-green-500 h-2 rounded-full"
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

              {/* 행운의 요소들 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Crown className="w-5 h-5" />
                      행운의 요소들
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-4 bg-purple-50 rounded-lg">
                        <h4 className="font-medium text-purple-800 mb-2 flex items-center gap-2">
                          <Compass className="w-4 h-4" />
                          행운의 등산로
                        </h4>
                        <p className="text-lg font-semibold text-purple-700">{result.lucky_trail}</p>
                      </div>
                      <div className="p-4 bg-indigo-50 rounded-lg">
                        <h4 className="font-medium text-indigo-800 mb-2 flex items-center gap-2">
                          <Mountain className="w-4 h-4" />
                          행운의 산
                        </h4>
                        <p className="text-lg font-semibold text-indigo-700">{result.lucky_mountain}</p>
                      </div>
                      <div className="p-4 bg-teal-50 rounded-lg">
                        <h4 className="font-medium text-teal-800 mb-2 flex items-center gap-2">
                          <Clock className="w-4 h-4" />
                          행운의 출발 시간
                        </h4>
                        <p className="text-lg font-semibold text-teal-700">{result.lucky_hiking_time}</p>
                      </div>
                      <div className="p-4 bg-emerald-50 rounded-lg">
                        <h4 className="font-medium text-emerald-800 mb-2 flex items-center gap-2">
                          <CloudRain className="w-4 h-4" />
                          행운의 날씨
                        </h4>
                        <p className="text-lg font-semibold text-emerald-700">{result.lucky_weather}</p>
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
                  className="w-full border-green-300 text-green-600 hover:bg-green-50 py-3"
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