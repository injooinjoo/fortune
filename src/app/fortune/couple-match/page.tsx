"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import { Textarea } from "@/components/ui/textarea";
import AppHeader from "@/components/AppHeader";
import { Heart, Users, Sparkles, ArrowRight, Shuffle, TrendingUp } from "lucide-react";

interface CoupleForm {
  person1: { name: string; birthDate: string };
  person2: { name: string; birthDate: string };
  status: string;
  duration: string;
  concern: string;
}

interface CoupleResult {
  currentFlow: number;
  futurePotential: number;
  advice1: string;
  advice2: string;
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

const getScoreColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 50) return "text-yellow-600 bg-yellow-50";
  return "text-red-600 bg-red-50";
};

const getScoreText = (score: number) => {
  if (score >= 85) return "매우 좋음";
  if (score >= 70) return "좋음";
  if (score >= 50) return "보통";
  return "주의 필요";
};

export default function CoupleMatchPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<CoupleForm>({
    person1: { name: '', birthDate: '' },
    person2: { name: '', birthDate: '' },
    status: '',
    duration: '',
    concern: ''
  });
  const [result, setResult] = useState<CoupleResult | null>(null);

  const analyzeCouple = async (): Promise<CoupleResult> => {
    const base = Math.floor(Math.random() * 40) + 50;
    return {
      currentFlow: Math.max(40, Math.min(95, base + Math.floor(Math.random() * 20) - 10)),
      futurePotential: Math.max(50, Math.min(100, base + Math.floor(Math.random() * 20))),
      advice1: "상대방의 입장을 먼저 생각하고 대화를 이어가면 관계가 더욱 안정됩니다.",
      advice2: "솔직한 감정 표현이 서로의 신뢰를 높여 줄 것입니다.",
      tips: [
        "함께 즐길 수 있는 취미를 찾아보세요",
        "주기적으로 서로의 고민을 나누는 시간을 가지세요",
        "작은 선물이나 이벤트로 마음을 표현해 보세요"
      ]
    };
  };

  const handleSubmit = async () => {
    if (!formData.person1.name || !formData.person1.birthDate || !formData.person2.name || !formData.person2.birthDate) {
      alert('모든 정보를 입력해주세요.');
      return;
    }

    setLoading(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      const res = await analyzeCouple();
      setResult(res);
      setStep('result');
    } catch (err) {
      console.error('분석 오류:', err);
      alert('분석 중 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setStep('input');
    setFormData({
      person1: { name: '', birthDate: '' },
      person2: { name: '', birthDate: '' },
      status: '',
      duration: '',
      concern: ''
    });
    setResult(null);
  };

  const overall = result ? Math.round((result.currentFlow + result.futurePotential) / 2) : 0;

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-white to-pink-50 pb-20">
      <AppHeader title="짝궁합" />

      <motion.div variants={containerVariants} initial="hidden" animate="visible" className="px-6 pt-6">
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
                  className="bg-gradient-to-r from-rose-500 to-pink-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Users className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">짝궁합 분석</h1>
                <p className="text-gray-600">두 사람의 현재 흐름과 앞으로의 가능성을 확인해보세요</p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-rose-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-rose-700">
                      <Heart className="w-5 h-5" />
                      첫 번째 사람
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="p1-name">이름</Label>
                      <Input
                        id="p1-name"
                        value={formData.person1.name}
                        onChange={e => setFormData(prev => ({ ...prev, person1: { ...prev.person1, name: e.target.value } }))}
                        placeholder="이름"
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="p1-birth">생년월일</Label>
                      <Input
                        id="p1-birth"
                        type="date"
                        value={formData.person1.birthDate}
                        onChange={e => setFormData(prev => ({ ...prev, person1: { ...prev.person1, birthDate: e.target.value } }))}
                        className="mt-1"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="flex justify-center">
                <motion.div
                  animate={{ scale: [1, 1.1, 1] }}
                  transition={{ repeat: Infinity, duration: 2 }}
                  className="bg-gradient-to-r from-rose-400 to-pink-400 rounded-full p-3"
                >
                  <Heart className="w-6 h-6 text-white" />
                </motion.div>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-pink-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-pink-700">
                      <Heart className="w-5 h-5" />
                      두 번째 사람
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="p2-name">이름</Label>
                      <Input
                        id="p2-name"
                        value={formData.person2.name}
                        onChange={e => setFormData(prev => ({ ...prev, person2: { ...prev.person2, name: e.target.value } }))}
                        placeholder="이름"
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="p2-birth">생년월일</Label>
                      <Input
                        id="p2-birth"
                        type="date"
                        value={formData.person2.birthDate}
                        onChange={e => setFormData(prev => ({ ...prev, person2: { ...prev.person2, birthDate: e.target.value } }))}
                        className="mt-1"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-rose-600">
                      <Sparkles className="w-5 h-5" />
                      관계 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="status">현재 관계</Label>
                      <Input
                        id="status"
                        value={formData.status}
                        onChange={e => setFormData(prev => ({ ...prev, status: e.target.value }))}
                        placeholder="예: 연애 중, 썸 타는 중"
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="duration">만난 기간</Label>
                      <Input
                        id="duration"
                        value={formData.duration}
                        onChange={e => setFormData(prev => ({ ...prev, duration: e.target.value }))}
                        placeholder="예: 3개월"
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="concern">현재 고민</Label>
                      <Textarea
                        id="concern"
                        value={formData.concern}
                        onChange={e => setFormData(prev => ({ ...prev, concern: e.target.value }))}
                        placeholder="고민이나 궁금한 점"
                        className="mt-1"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 text-white py-6 text-lg font-semibold"
                >
                  {loading ? (
                    <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1 }} className="flex items-center gap-2">
                      <Shuffle className="w-5 h-5" />
                      분석 중...
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-5 h-5" />
                      관계 분석하기
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
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-rose-500 to-pink-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <span className="text-xl font-medium">{formData.person1.name}</span>
                      <Heart className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.person2.name}</span>
                    </div>
                    <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 0.3, type: "spring" }} className="text-6xl font-bold mb-2">
                      {overall}점
                    </motion.div>
                    <p className="text-white/90 text-lg">현재 관계 지수</p>
                    <Badge variant="secondary" className="mt-2 bg-white/20 text-white border-white/30">
                      {getScoreText(overall)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <TrendingUp className="w-5 h-5 text-rose-600" />
                      상세 지표
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[{ label: '현재 흐름', score: result.currentFlow }, { label: '미래 가능성', score: result.futurePotential }].map((item, index) => (
                      <motion.div key={item.label} initial={{ x: -20, opacity: 0 }} animate={{ x: 0, opacity: 1 }} transition={{ delay: 0.4 + index * 0.1 }} className="flex items-center gap-4">
                        <div className="flex-1">
                          <div className="flex justify-between items-center mb-1">
                            <span className="font-medium">{item.label}</span>
                            <span className={`px-2 py-1 rounded-full text-sm font-medium ${getScoreColor(item.score)}`}>{item.score}점</span>
                          </div>
                          <Progress value={item.score} className="h-2" />
                        </div>
                      </motion.div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-pink-600">
                      <Users className="w-5 h-5" />
                      개인별 조언
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-rose-50 rounded-lg">
                      <h4 className="font-medium text-rose-800 mb-2">{formData.person1.name}님에게</h4>
                      <p className="text-gray-700">{result.advice1}</p>
                    </div>
                    <div className="p-4 bg-pink-50 rounded-lg">
                      <h4 className="font-medium text-pink-800 mb-2">{formData.person2.name}님에게</h4>
                      <p className="text-gray-700">{result.advice2}</p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Sparkles className="w-5 h-5" />
                      관계를 위한 팁
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.tips.map((tip, index) => (
                        <motion.div key={index} initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.6 + index * 0.1 }} className="flex items-start gap-2">
                          <Sparkles className="w-4 h-4 text-purple-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{tip}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button onClick={handleReset} variant="outline" className="w-full border-rose-300 text-rose-600 hover:bg-rose-50 py-3">
                  <ArrowRight className="w-4 h-4 mr-2" />
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

