"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
import {
  Waves,
  Droplet,
  Calendar,
  Clock,
  HeartPulse,
  Sparkles,
  ArrowRight,
} from "lucide-react";

interface SwimInfo {
  name: string;
  birth_date: string;
  swim_style: string;
  experience: string;
  goal: string;
}

interface SwimFortune {
  water_score: number;
  water_energy: string;
  best_days: string[];
  lucky_time: string;
  health_tips: string[];
  lucky_color: string;
  recommended_laps: number;
}

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
};

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
    transition: {
      type: "spring" as const,
      stiffness: 100,
      damping: 10,
    },
  },
};

const swimStyles = ["자유형", "배영", "평영", "접영"];
const experienceLevels = ["초보", "중급", "상급"];
const goals = ["건강", "다이어트", "대회 준비", "취미"];
const healthTipPool = [
  "수영 전후로 충분한 스트레칭을 하세요",
  "호흡 리듬에 맞춰 천천히 페이스를 유지하세요",
  "수분을 자주 섭취해 탈수를 예방하세요",
  "몸에 맞는 온도의 물에서 운동하세요",
  "근력 강화를 위해 꾸준히 킥 연습을 해보세요",
];
const colors = ["파란색", "민트색", "남색", "하늘색"];
const times = ["이른 아침", "오후", "저녁"];
const weekDays = ["월", "화", "수", "목", "금", "토", "일"];

function calculateWaterScore(date: string) {
  const day = new Date(date).getDate();
  return 50 + (day % 50); // 50-99
}

function getWaterEnergy(score: number) {
  if (score >= 85) return "물이 넘치는 날";
  if (score >= 70) return "물 기운이 좋은 날";
  if (score >= 55) return "보통";
  return "건조한 날";
}

export default function LuckySwimPage() {
  const [step, setStep] = useState<"input" | "result">("input");
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<SwimInfo>({
    name: "",
    birth_date: "",
    swim_style: "",
    experience: "",
    goal: "",
  });
  const [result, setResult] = useState<SwimFortune | null>(null);

  const analyzeSwimFortune = async (): Promise<SwimFortune> => {
    const score = calculateWaterScore(formData.birth_date);
    const shuffledDays = weekDays.sort(() => 0.5 - Math.random());
    return {
      water_score: score,
      water_energy: getWaterEnergy(score),
      best_days: shuffledDays.slice(0, 3),
      lucky_time: times[Math.floor(Math.random() * times.length)],
      health_tips: healthTipPool.sort(() => 0.5 - Math.random()).slice(0, 3),
      lucky_color: colors[Math.floor(Math.random() * colors.length)],
      recommended_laps: Math.floor(Math.random() * 20) + 10,
    };
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.swim_style) {
      alert("필수 정보를 모두 입력해주세요.");
      return;
    }
    setLoading(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 1500));
      const data = await analyzeSwimFortune();
      setResult(data);
      setStep("result");
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setFormData({ name: "", birth_date: "", swim_style: "", experience: "", goal: "" });
    setResult(null);
    setStep("input");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-sky-50 via-blue-100 to-teal-50 pb-32">
      <AppHeader title="행운의 수영" />
      <motion.div variants={containerVariants} initial="hidden" animate="visible" className="px-6 pt-6">
        <AnimatePresence mode="wait">
          {step === "input" && (
            <motion.div key="input" initial={{ opacity: 0, x: -50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 50 }} className="space-y-6">
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div className="bg-gradient-to-r from-sky-400 to-blue-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4" whileHover={{ rotate: 360 }} transition={{ duration: 0.8 }}>
                  <Waves className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 수영</h1>
                <p className="text-gray-600">물의 기운으로 건강을 채워보세요</p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-sky-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-sky-700">
                      <Droplet className="w-5 h-5" /> 기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="name">이름</Label>
                        <Input id="name" value={formData.name} placeholder="이름" onChange={(e) => setFormData((p) => ({ ...p, name: e.target.value }))} className="mt-1" />
                      </div>
                      <div>
                        <Label htmlFor="birth">생년월일</Label>
                        <Input id="birth" type="date" value={formData.birth_date} onChange={(e) => setFormData((p) => ({ ...p, birth_date: e.target.value }))} className="mt-1" />
                      </div>
                    </div>
                    <div>
                      <Label>수영 수준</Label>
                      <RadioGroup value={formData.experience} onValueChange={(v) => setFormData((p) => ({ ...p, experience: v }))} className="mt-2 flex gap-2">
                        {experienceLevels.map((level) => (
                          <div key={level} className="flex items-center space-x-2">
                            <RadioGroupItem id={level} value={level} />
                            <Label htmlFor={level} className="text-sm">
                              {level}
                            </Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>주요 영법</Label>
                      <RadioGroup value={formData.swim_style} onValueChange={(v) => setFormData((p) => ({ ...p, swim_style: v }))} className="mt-2 flex gap-2">
                        {swimStyles.map((style) => (
                          <div key={style} className="flex items-center space-x-2">
                            <RadioGroupItem id={style} value={style} />
                            <Label htmlFor={style} className="text-sm">
                              {style}
                            </Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>목표</Label>
                      <RadioGroup value={formData.goal} onValueChange={(v) => setFormData((p) => ({ ...p, goal: v }))} className="mt-2 flex gap-2">
                        {goals.map((g) => (
                          <div key={g} className="flex items-center space-x-2">
                            <RadioGroupItem id={g} value={g} />
                            <Label htmlFor={g} className="text-sm">
                              {g}
                            </Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-2">
                <Button onClick={handleSubmit} className="w-full bg-sky-600 hover:bg-sky-700 text-white">
                  <Sparkles className="w-4 h-4 mr-2" /> 운세 보기
                </Button>
              </motion.div>
            </motion.div>
          )}

          {step === "result" && result && (
            <motion.div key="result" initial={{ opacity: 0, x: 50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -50 }} className="space-y-6">
              <motion.div variants={itemVariants}>
                <Card className="border-sky-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-sky-700">
                      <Droplet className="w-5 h-5" /> 물의 기운
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-3">
                    <div className="flex items-center gap-2">
                      <Badge variant="outline" className="text-sky-700 border-sky-300">
                        {result.water_energy}
                      </Badge>
                      <span className="text-sm text-gray-600">({result.water_score}점)</span>
                    </div>
                    <Progress value={result.water_score} />
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-blue-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-700">
                      <Calendar className="w-5 h-5" /> 수영하기 좋은 날
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="flex gap-2">
                    {result.best_days.map((d) => (
                      <Badge key={d} className="bg-blue-100 text-blue-700">
                        {d}요일
                      </Badge>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-teal-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-teal-700">
                      <Clock className="w-5 h-5" /> 행운의 시간
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-gray-700">{result.lucky_time}에 수영하면 활력이 높아집니다.</p>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-indigo-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-indigo-700">
                      <HeartPulse className="w-5 h-5" /> 건강운을 높이는 팁
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    {result.health_tips.map((tip, idx) => (
                      <div key={idx} className="text-sm text-gray-700 flex items-start gap-2">
                        <ArrowRight className="w-3 h-3 mt-1 text-indigo-500" /> {tip}
                      </div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-cyan-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-cyan-700">
                      <Sparkles className="w-5 h-5" /> 행운 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <p className="text-gray-700">행운의 수영복 색상: <span className="font-medium text-cyan-700">{result.lucky_color}</span></p>
                    <p className="text-gray-700">추천 랩 수: <span className="font-medium text-cyan-700">{result.recommended_laps} 랩</span></p>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button onClick={handleReset} variant="outline" className="w-full border-sky-300 text-sky-600 hover:bg-sky-50 py-3">
                  다시 분석하기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}
