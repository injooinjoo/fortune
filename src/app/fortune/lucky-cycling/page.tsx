"use client";

import { useToast } from '@/hooks/use-toast';
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Bike, MapPin, Shield, Palette, Clock, Sparkles } from "lucide-react";

import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";
interface CyclingInfo {
  name: string;
  birth_date: string;
}

interface CyclingFortune {
  score: number;
  course: { name: string; desc: string };
  luckyColor: string;
  bestTime: string;
  safetyTips: string[];
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

const courses = [
  { name: "한강 자전거길", desc: "평탄한 강변을 달리며 상쾌함을 느껴보세요" },
  { name: "남산 순환 코스", desc: "도심 속 가벼운 업힐과 멋진 전망을 즐겨보세요" },
  { name: "산악 트레일", desc: "자연을 만끽할 수 있는 오프로드 코스" },
  { name: "해안 도로", desc: "시원한 바닷바람을 맞으며 달리는 코스" },
];

const colors = ["레드", "블루", "그린", "옐로우", "화이트", "블랙", "퍼플"];
const times = ["이른 아침", "오후", "해질 무렵", "밤 시간"];
const safetyTipsBase = [
  "헬멧과 장갑을 꼭 착용하세요",
  "교차로에서는 반드시 속도를 줄이세요",
  "야간 라이딩 시 라이트와 반사 도구를 사용하세요",
  "충분한 수분과 간단한 간식을 챙기세요",
  "출발 전 자전거 상태를 점검하세요",
];

function shuffle<T>(array: T[]): T[] {
  return array
    .map((value) => ({ value, sort: rng.random() }))
    .sort((a, b) => a.sort - b.sort)
    .map(({ value }) => value);
}

export default function LuckyCyclingPage() {
  const { toast } = useToast();
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<CyclingInfo>({ name: '', birth_date: '' });
  const [result, setResult] = useState<CyclingFortune | null>(null);

  const generateFortune = (): CyclingFortune => {
    const day = new Date(formData.birth_date).getDate() || 1;
    const rand = rng.randomInt(0, 19);
    const score = Math.max(50, Math.min(95, 60 + ((day + rand) % 30)));
    const course = courses[(day + rand) % courses.length];
    const luckyColor = colors[(day * rand) % colors.length];
    const bestTime = times[(day + rand) % times.length];
    const safetyTips = shuffle(safetyTipsBase).slice(0, 3);
    return { score, course, luckyColor, bestTime, safetyTips };
  };

  const handleSubmit = async () => {
    if (!formData.birth_date) {
      toast({
      title: '생년월일을 입력해주세요.',
      variant: "default",
    });
      return;
    }
    setLoading(true);
    await new Promise((res) => setTimeout(res, 1000));
    setResult(generateFortune());
    setStep('result');
    setLoading(false);
  };

  const handleReset = () => {
    setFormData({ name: '', birth_date: '' });
    setResult(null);
    setStep('input');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-teal-50 via-cyan-50 to-blue-50 pb-32">
      <AppHeader title="행운의 자전거" />
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
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-teal-500 to-cyan-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Bike className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 자전거</h1>
                <p className="text-gray-600">라이딩 운세와 안전 팁을 알려드립니다</p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-teal-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-teal-700">
                      <Sparkles className="w-5 h-5" /> 기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="name">이름 (선택)</Label>
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
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="text-center pt-4">
                <Button onClick={handleSubmit} disabled={loading} className="w-full">
                  {loading ? '분석 중...' : '운세 보기'}
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
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-teal-500 to-cyan-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Bike className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name || '당신'}님의 라이딩 운세</span>
                    </div>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: 'spring' }}
                      className="text-6xl font-bold mb-2"
                    >
                      {result.score}점
                    </motion.div>
                    <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                      오늘의 행운 점수
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-cyan-700">
                      <MapPin className="w-5 h-5" /> 추천 코스
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    <p className="font-medium text-gray-800">{result.course.name}</p>
                    <p className="text-sm text-gray-600">{result.course.desc}</p>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-teal-700">
                      <Shield className="w-5 h-5" /> 안전 조언
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc pl-5 space-y-1 text-sm text-gray-600">
                      {result.safetyTips.map((tip, idx) => (
                        <li key={idx}>{tip}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-700">
                      <Palette className="w-5 h-5" /> 행운 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2 text-sm text-gray-600">
                    <div className="flex items-center gap-2">
                      <span>행운의 색상:</span>
                      <span className="font-medium">{result.luckyColor}</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Clock className="w-4 h-4" />
                      <span>추천 시간: {result.bestTime}</span>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="flex gap-2 pt-2">
                <Button className="flex-1" variant="outline" onClick={handleReset}>
                  다시 보기
                </Button>
                <Button className="flex-1" asChild>
                  <a href="/fortune">목록으로</a>
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}

