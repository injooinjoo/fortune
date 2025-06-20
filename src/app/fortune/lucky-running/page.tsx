"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import AppHeader from "@/components/AppHeader";
import {
  Footprints,
  Users,
  Activity,
  Clock,
  Wind,
  MapPin,
  Sun,
  TrendingUp,
  Trophy
} from "lucide-react";

interface RunningInfo {
  name: string;
  birth_date: string;
  experience: string;
  frequency: string;
  goal: string;
}

interface RunningFortune {
  overall_luck: number;
  stamina_luck: number;
  speed_luck: number;
  injury_risk: number;
  best_days: string[];
  lucky_direction: string;
  lucky_time: string;
  lucky_weather: string;
  tips: string[];
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

const experiences = [
  "전문 러너",
  "상급 (3년 이상)",
  "중급 (1-3년)",
  "초급 (6개월-1년)",
  "입문 (6개월 미만)"
];

const frequencies = [
  "매일",
  "주 3-5회",
  "주 1-2회",
  "가끔"
];

const goals = [
  "풀코스 마라톤",
  "하프 마라톤",
  "10km",
  "5km 건강 달리기"
];

const calculateBiorhythm = (birthDate: Date, targetDate: Date) => {
  const daysDiff = Math.floor(
    (targetDate.getTime() - birthDate.getTime()) / (1000 * 60 * 60 * 24)
  );
  return {
    physical: Math.sin((2 * Math.PI * daysDiff) / 23) * 100,
    emotional: Math.sin((2 * Math.PI * daysDiff) / 28) * 100,
    intellectual: Math.sin((2 * Math.PI * daysDiff) / 33) * 100
  };
};

const formatDate = (dateString: string): string => {
  const date = new Date(dateString);
  return `${date.getMonth() + 1}월 ${date.getDate()}일`;
};

export default function LuckyRunningPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<RunningInfo>({
    name: '',
    birth_date: '',
    experience: '',
    frequency: '',
    goal: ''
  });
  const [result, setResult] = useState<RunningFortune | null>(null);

  const analyzeRunningFortune = async (): Promise<RunningFortune> => {
    const birth = new Date(formData.birth_date);
    const today = new Date();
    const forecast = [] as { date: string; physical: number; emotional: number }[];
    for (let i = 1; i <= 14; i++) {
      const d = new Date(today);
      d.setDate(d.getDate() + i);
      const b = calculateBiorhythm(birth, d);
      forecast.push({ date: d.toISOString(), physical: b.physical, emotional: b.emotional });
    }
    const bestDays = forecast
      .filter(day => (day.physical + day.emotional) / 2 > 50)
      .slice(0, 3)
      .map(day => formatDate(day.date));

    const base = 60 + Math.floor(Math.random() * 25);
    return {
      overall_luck: base,
      stamina_luck: Math.min(100, base + Math.floor(Math.random() * 10 - 5)),
      speed_luck: Math.min(100, base + Math.floor(Math.random() * 10 - 5)),
      injury_risk: Math.max(0, 100 - (base + Math.floor(Math.random() * 10))),
      best_days: bestDays,
      lucky_direction: ["북쪽", "동쪽", "남쪽", "서쪽"][Math.floor(Math.random() * 4)],
      lucky_time: ["이른 아침", "오전", "오후", "저녁"][Math.floor(Math.random() * 4)],
      lucky_weather: ["맑은 날", "흐린 날", "바람 부는 날", "선선한 날"][Math.floor(Math.random() * 4)],
      tips: [
        "충분한 수분 섭취와 스트레칭을 잊지 마세요",
        "호흡 리듬을 일정하게 유지하세요",
        "달리기 전후로 가벼운 근력운동을 해보세요",
        "규칙적인 수면으로 컨디션을 관리하세요",
        "몸 상태에 맞게 페이스를 조절하세요"
      ].sort(() => 0.5 - Math.random()).slice(0, 3)
    };
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.experience) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }
    setLoading(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      const analysisResult = await analyzeRunningFortune();
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
    setFormData({ name: '', birth_date: '', experience: '', frequency: '', goal: '' });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-cyan-50 via-green-25 to-blue-50 pb-32">
      <AppHeader title="행운의 마라톤" />
      <motion.div variants={containerVariants} initial="hidden" animate="visible" className="px-6 pt-6">
        <AnimatePresence mode="wait">
          {step === 'input' && (
            <motion.div key="input" initial={{ opacity: 0, x: -50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 50 }} className="space-y-6">
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div className="bg-gradient-to-r from-cyan-500 to-blue-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4" whileHover={{ rotate: 360 }} transition={{ duration: 0.8 }}>
                  <Footprints className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 마라톤</h1>
                <p className="text-gray-600">달리기 운세와 최적의 컨디션을 확인하세요</p>
              </motion.div>
              <motion.div variants={itemVariants}>
                <Card className="border-cyan-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-cyan-700">
                      <Users className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="name">이름</Label>
                        <Input id="name" placeholder="이름" value={formData.name} onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))} className="mt-1" />
                      </div>
                      <div>
                        <Label htmlFor="birth_date">생년월일</Label>
                        <Input id="birth_date" type="date" value={formData.birth_date} onChange={(e) => setFormData(prev => ({ ...prev, birth_date: e.target.value }))} className="mt-1" />
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
              <motion.div variants={itemVariants}>
                <Card className="border-blue-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-blue-700">
                      <Activity className="w-5 h-5" />
                      러닝 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>러닝 경험</Label>
                      <RadioGroup value={formData.experience} onValueChange={(value) => setFormData(prev => ({ ...prev, experience: value }))} className="mt-2 grid grid-cols-2 gap-2">
                        {experiences.map((exp) => (
                          <div key={exp} className="flex items-center space-x-2">
                            <RadioGroupItem value={exp} id={exp} />
                            <Label htmlFor={exp} className="text-sm">{exp}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>훈련 빈도</Label>
                      <RadioGroup value={formData.frequency} onValueChange={(value) => setFormData(prev => ({ ...prev, frequency: value }))} className="mt-2 grid grid-cols-2 gap-2">
                        {frequencies.map((frq) => (
                          <div key={frq} className="flex items-center space-x-2">
                            <RadioGroupItem value={frq} id={frq} />
                            <Label htmlFor={frq} className="text-sm">{frq}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>목표</Label>
                      <RadioGroup value={formData.goal} onValueChange={(value) => setFormData(prev => ({ ...prev, goal: value }))} className="mt-2 grid grid-cols-2 gap-2">
                        {goals.map((g) => (
                          <div key={g} className="flex items-center space-x-2">
                            <RadioGroupItem value={g} id={g} />
                            <Label htmlFor={g} className="text-sm">{g}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
              <motion.div variants={itemVariants} className="text-center pt-4">
                <Button onClick={handleSubmit} disabled={loading} className="w-full">
                  {loading ? '분석 중...' : '운세 확인하기'}
                </Button>
              </motion.div>
            </motion.div>
          )}
          {step === 'result' && result && (
            <motion.div key="result" initial={{ opacity: 0, x: 50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -50 }} className="space-y-6">
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-cyan-500 to-blue-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Trophy className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 러닝 운세</span>
                    </div>
                    <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 0.3, type: 'spring' }} className="text-6xl font-bold mb-2">
                      {result.overall_luck}점
                    </motion.div>
                    <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                      오늘의 컨디션
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <TrendingUp className="w-5 h-5" />
                      세부 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: '지구력', score: result.stamina_luck, icon: Wind },
                      { label: '속도', score: result.speed_luck, icon: Clock },
                      { label: '부상 위험', score: 100 - result.injury_risk, icon: Activity }
                    ].map((item, index) => (
                      <motion.div key={item.label} initial={{ x: -20, opacity: 0 }} animate={{ x: 0, opacity: 1 }} transition={{ delay: 0.4 + index * 0.1 }} className="space-y-2">
                        <div className="flex items-center gap-3">
                          <item.icon className="w-5 h-5 text-gray-600" />
                          <div className="flex-1">
                            <div className="flex justify-between items-center mb-1">
                              <span className="font-medium">{item.label}</span>
                              <span className="px-3 py-1 rounded-full text-sm font-medium bg-blue-50 text-blue-600">
                                {item.score}점
                              </span>
                            </div>
                            <div className="w-full bg-gray-200 rounded-full h-2">
                              <motion.div className="bg-cyan-500 h-2 rounded-full" initial={{ width: 0 }} animate={{ width: `${item.score}%` }} transition={{ delay: 0.5 + index * 0.1, duration: 0.8 }} />
                            </div>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-emerald-600">
                      <MapPin className="w-5 h-5" />
                      행운 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-4 bg-teal-50 rounded-lg text-center">
                        <h4 className="font-medium text-teal-800 mb-1">행운의 방향</h4>
                        <p className="text-lg font-semibold text-teal-700">{result.lucky_direction}</p>
                      </div>
                      <div className="p-4 bg-indigo-50 rounded-lg text-center">
                        <h4 className="font-medium text-indigo-800 mb-1">행운의 시간대</h4>
                        <p className="text-lg font-semibold text-indigo-700">{result.lucky_time}</p>
                      </div>
                      <div className="p-4 bg-yellow-50 rounded-lg text-center">
                        <h4 className="font-medium text-yellow-800 mb-1">행운의 날씨</h4>
                        <p className="text-lg font-semibold text-yellow-700">{result.lucky_weather}</p>
                      </div>
                      <div className="p-4 bg-blue-50 rounded-lg text-center">
                        <h4 className="font-medium text-blue-800 mb-1">달리기 좋은 날</h4>
                        <div className="flex flex-wrap gap-2 justify-center">
                          {result.best_days.map((d, idx) => (
                            <Badge key={idx} variant="outline" className="border-blue-300 text-blue-700">
                              {d}
                            </Badge>
                          ))}
                        </div>
                      </div>
                    </div>
                    <div className="p-4 bg-green-50 rounded-lg">
                      <h4 className="font-medium text-green-800 mb-2 flex items-center gap-2">
                        <Sun className="w-4 h-4" />
                        컨디션 관리 팁
                      </h4>
                      <ul className="list-disc pl-4 space-y-1 text-sm text-green-700">
                        {result.tips.map((tip, idx) => (
                          <li key={idx}>{tip}</li>
                        ))}
                      </ul>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
              <motion.div variants={itemVariants} className="text-center pt-4">
                <Button onClick={handleReset} className="w-full">다시 입력하기</Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}
