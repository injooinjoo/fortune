"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Checkbox } from "@/components/ui/checkbox";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Badge } from "@/components/ui/badge";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import {
  Rocket,
  Briefcase,
  Calendar,
  Users,
  Lightbulb,
  CheckCircle,
  AlertTriangle,
  ArrowRight,
  Shuffle
} from "lucide-react";

interface StartupInfo {
  name: string;
  birth_date: string;
  mbti: string;
  capital: string;
  experience: string;
  interests: string[];
}

interface StartupFortune {
  score: number;
  best_industries: string[];
  best_start_time: string;
  partners: string[];
  tips: string[];
  cautions: string[];
}

const industries = ["IT", "푸드", "패션", "교육", "헬스케어", "컨설팅", "콘텐츠", "소매"];

const mbtiMap: Record<string, string[]> = {
  E: ["마케팅", "소매", "푸드"],
  I: ["IT", "콘텐츠", "교육"],
  S: ["소매", "푸드", "패션"],
  N: ["IT", "컨설팅", "헬스케어"],
  T: ["IT", "헬스케어", "컨설팅"],
  F: ["패션", "교육", "콘텐츠"],
  J: ["교육", "컨설팅", "헬스케어"],
  P: ["콘텐츠", "소매", "푸드"]
};

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

export default function StartupFortunePage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<StartupInfo>({
    name: '',
    birth_date: '',
    mbti: '',
    capital: '',
    experience: '',
    interests: []
  });
  const [result, setResult] = useState<StartupFortune | null>(null);

  const handleCheckbox = (value: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      interests: checked
        ? [...prev.interests, value]
        : prev.interests.filter(i => i !== value)
    }));
  };

  const analyze = async (): Promise<StartupFortune> => {
    try {
      const response = await fetch('/api/fortune/startup', {
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
      console.error('API 호출 중 오류:', error);
      
      // Fallback: 기본 응답 반환
      const score = Math.floor(Math.random() * 30) + 60;
      const mbtiKey = formData.mbti.charAt(0).toUpperCase();
      const recIndustries = mbtiMap[mbtiKey] || industries.slice(0, 3);
      const startMonth = ['3월', '5월', '8월', '10월'][Math.floor(Math.random() * 4)];
      const startTime = `${new Date().getFullYear() + 1}년 ${startMonth}`;
      
      return {
        score,
        best_industries: recIndustries.slice(0, 2),
        best_start_time: startTime,
        partners: ['ENFP', 'ISTJ', 'ENTJ'].slice(0, 2),
        tips: [
          '시장 조사를 철저히 하세요',
          '초기 자금 관리를 신중히 하세요',
          '네트워크를 적극 활용하세요'
        ],
        cautions: [
          '과도한 확장에 주의',
          '파트너와의 갈등 관리 필요'
        ]
      };
    }
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.mbti) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    try {
      await new Promise(r => setTimeout(r, 1500));
      const res = await analyze();
      setResult(res);
      setStep('result');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({ name: '', birth_date: '', mbti: '', capital: '', experience: '', interests: [] });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-orange-50 via-amber-50 to-yellow-50 pb-32">
      <AppHeader title="행운의 창업" />

      <motion.div variants={containerVariants} initial="hidden" animate="visible" className="px-6 pt-6">
        <AnimatePresence mode="wait">
          {step === 'input' && (
            <motion.div key="input" initial={{ opacity: 0, x: -50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 50 }} className="space-y-6">
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div className="bg-gradient-to-r from-orange-500 to-amber-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4" whileHover={{ scale: 1.1 }} transition={{ duration: 0.3 }}>
                  <Rocket className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 창업</h1>
                <p className="text-gray-600">성공적인 창업 시기와 업종을 확인해보세요</p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-orange-700">
                      <Users className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="name">이름</Label>
                        <Input id="name" placeholder="이름" value={formData.name} onChange={e => setFormData(prev => ({ ...prev, name: e.target.value }))} className="mt-1" />
                      </div>
                      <div>
                        <KoreanDatePicker
                          label="생년월일"
                          value={formData.birth_date}
                          onChange={(date) => setFormData(prev => ({ ...prev, birth_date: date }))}
                          placeholder="생년월일을 선택하세요"
                          required
                          className="mt-1"
                        />
                      </div>
                    </div>
                    <div>
                      <Label htmlFor="mbti">MBTI</Label>
                      <Input id="mbti" placeholder="예: ENFP" value={formData.mbti} onChange={e => setFormData(prev => ({ ...prev, mbti: e.target.value.toUpperCase() }))} className="mt-1" />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-amber-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-amber-700">
                      <Briefcase className="w-5 h-5" />
                      창업 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="capital">예상 자본금 (만원)</Label>
                        <Input id="capital" type="number" placeholder="예: 5000" value={formData.capital} onChange={e => setFormData(prev => ({ ...prev, capital: e.target.value }))} className="mt-1" />
                      </div>
                      <div>
                        <Label>창업 경험</Label>
                        <RadioGroup value={formData.experience} onValueChange={v => setFormData(prev => ({ ...prev, experience: v }))} className="mt-2">
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="none" id="none" />
                            <Label htmlFor="none" className="text-sm">없음</Label>
                          </div>
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="little" id="little" />
                            <Label htmlFor="little" className="text-sm">소규모 경험</Label>
                          </div>
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="expert" id="expert" />
                            <Label htmlFor="expert" className="text-sm">풍부한 경험</Label>
                          </div>
                        </RadioGroup>
                      </div>
                    </div>
                    <div>
                      <Label>관심 분야 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {industries.map(ind => (
                          <div key={ind} className="flex items-center space-x-2">
                            <Checkbox id={ind} checked={formData.interests.includes(ind)} onCheckedChange={checked => handleCheckbox(ind, checked as boolean)} />
                            <Label htmlFor={ind} className="text-sm">{ind}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button onClick={handleSubmit} disabled={loading} className="w-full bg-gradient-to-r from-orange-500 to-amber-500 hover:from-orange-600 hover:to-amber-600 text-white py-6 text-lg font-semibold">
                  {loading ? (
                    <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1 }} className="flex items-center gap-2">
                      <Shuffle className="w-5 h-5" />
                      분석 중...
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Rocket className="w-5 h-5" />
                      창업 운세 분석하기
                    </div>
                  )}
                </Button>
              </motion.div>
            </motion.div>
          )}

          {step === 'result' && result && (
            <motion.div key="result" initial={{ opacity: 0, x: 50 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -50 }} className="space-y-6">
              <motion.div variants={itemVariants} className="text-center mb-8">
                <div className="bg-gradient-to-r from-orange-500 to-amber-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4">
                  <Lightbulb className="w-10 h-10 text-white" />
                </div>
                <h2 className="text-3xl font-bold mb-2">{result.score}점</h2>
                <p className="text-gray-700">창업 운세 점수입니다</p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-orange-700">
                      <Briefcase className="w-5 h-5" />
                      추천 업종
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="flex flex-wrap gap-2">
                      {result.best_industries.map(ind => (
                        <Badge key={ind} variant="outline" className="border-orange-300 text-orange-700">
                          {ind}
                        </Badge>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-amber-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-amber-700">
                      <Calendar className="w-5 h-5" />
                      시작하기 좋은 시기
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-amber-700 font-medium text-lg">{result.best_start_time}</p>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-lime-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-lime-700">
                      <Users className="w-5 h-5" />
                      잘 맞는 파트너 유형
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="flex flex-wrap gap-2">
                      {result.partners.map(p => (
                        <Badge key={p} variant="outline" className="border-lime-300 text-lime-700">
                          {p}
                        </Badge>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-700">
                      <CheckCircle className="w-5 h-5" />
                      창업 성공 팁
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    {result.tips.map((tip, idx) => (
                      <p key={idx} className="text-sm text-gray-700">• {tip}</p>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-red-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-red-700">
                      <AlertTriangle className="w-5 h-5" />
                      주의할 점
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    {result.cautions.map((c, idx) => (
                      <p key={idx} className="text-sm text-red-700">• {c}</p>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button onClick={handleReset} variant="outline" className="w-full border-orange-300 text-orange-600 hover:bg-orange-50 py-3">
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

