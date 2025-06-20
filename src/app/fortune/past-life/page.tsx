"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Sparkles, User, BookOpenText, RefreshCw } from "lucide-react";

interface PastLifeForm {
  year: string;
  month: string;
  day: string;
  hour: string;
}

interface PastLifeResult {
  summary: string;
  profession: string;
  personality: string;
  influence: string;
  advice: string[];
}

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.1, delayChildren: 0.2 }
  }
};

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
    transition: { type: "spring" as const, stiffness: 100, damping: 10 }
  }
};

function generateMockResult(form: PastLifeForm): PastLifeResult {
  return {
    summary: `${form.year}년 ${form.month}월 ${form.day}일 ${form.hour}시에 태어난 당신의 전생을 들여다봅니다.`,
    profession: "고대 도서관을 지키던 현자",
    personality: "지식을 갈망하고 침착함을 잃지 않는 성품",
    influence: "끊임없이 배우려는 태도와 사람들을 편안하게 하는 카리스마가 현생에도 이어집니다.",
    advice: [
      "책과 가까이 지내면 운이 트입니다",
      "지혜를 나누면 좋은 인연이 찾아옵니다",
      "마음의 평정심을 유지하세요"
    ]
  };
}

export default function PastLifePage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState<PastLifeForm>({ year: '', month: '', day: '', hour: '' });
  const [result, setResult] = useState<PastLifeResult | null>(null);

  const handleSubmit = async () => {
    if (!form.year || !form.month || !form.day || !form.hour) {
      alert('모든 정보를 입력해주세요.');
      return;
    }
    setLoading(true);
    await new Promise(resolve => setTimeout(resolve, 1500));
    setResult(generateMockResult(form));
    setStep('result');
    setLoading(false);
  };

  const handleReset = () => {
    setForm({ year: '', month: '', day: '', hour: '' });
    setResult(null);
    setStep('input');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-indigo-50 pb-20">
      <AppHeader title="전생운" />
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
                  className="bg-gradient-to-r from-purple-500 to-indigo-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Sparkles className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">전생을 알아보세요</h1>
                <p className="text-gray-600">사주 정보를 입력하면 당신의 전생 이야기를 들려드립니다</p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-purple-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-purple-700">
                      <User className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <Label htmlFor="year">출생 연도</Label>
                        <Input id="year" placeholder="YYYY" value={form.year} onChange={(e) => setForm({ ...form, year: e.target.value })} className="mt-1" />
                      </div>
                      <div>
                        <Label htmlFor="month">월</Label>
                        <Input id="month" placeholder="MM" value={form.month} onChange={(e) => setForm({ ...form, month: e.target.value })} className="mt-1" />
                      </div>
                      <div>
                        <Label htmlFor="day">일</Label>
                        <Input id="day" placeholder="DD" value={form.day} onChange={(e) => setForm({ ...form, day: e.target.value })} className="mt-1" />
                      </div>
                      <div>
                        <Label htmlFor="hour">시간</Label>
                        <Select value={form.hour} onValueChange={(v) => setForm({ ...form, hour: v })}>
                          <SelectTrigger className="mt-1">
                            <SelectValue placeholder="시간" />
                          </SelectTrigger>
                          <SelectContent>
                            {Array.from({ length: 24 }).map((_, i) => (
                              <SelectItem key={i} value={`${i}`}>{i}시</SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                    </div>
                    <Button onClick={handleSubmit} disabled={loading} className="w-full mt-4">
                      {loading ? '분석 중...' : '전생 알아보기'}
                    </Button>
                  </CardContent>
                </Card>
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
              <motion.div variants={itemVariants} className="text-center mb-6">
                <h2 className="text-xl font-bold text-purple-700">{result.summary}</h2>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-indigo-200 bg-gradient-to-r from-indigo-50 to-purple-50">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-indigo-700">
                      <BookOpenText className="w-5 h-5" />
                      전생 스토리
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4 text-sm text-gray-700">
                    <p><strong>직업:</strong> {result.profession}</p>
                    <p><strong>성격:</strong> {result.personality}</p>
                    <p><strong>현생에 미치는 영향:</strong> {result.influence}</p>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-purple-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-700">
                      <Sparkles className="w-5 h-5" />
                      전생이 주는 조언
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <ul className="list-disc pl-5 space-y-1 text-sm text-gray-700">
                      {result.advice.map((a, idx) => (
                        <li key={idx}>{a}</li>
                      ))}
                    </ul>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="flex gap-2 pt-2">
                <Button className="flex-1" onClick={handleReset}>
                  <RefreshCw className="w-4 h-4 mr-1" /> 다시 분석하기
                </Button>
                <Button variant="outline" className="flex-1" onClick={handleReset}>
                  공유하기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}

