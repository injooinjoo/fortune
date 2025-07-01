"use client";

import React, { useState, useCallback } from "react";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";
import {
  Star,
  Heart,
  Briefcase,
  Coins,
  HeartPulse,
  Palette,
  Gift,
  Hash,
  Moon,
  Loader2,
  RefreshCw,
  User,
  Calendar,
  Sparkles
} from "lucide-react";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import toast from "react-hot-toast";

interface TomorrowFortuneForm {
  name: string;
  birth_date: string;
  mbti?: string;
  zodiac?: string;
}

interface TomorrowFortuneResult {
  tomorrow: {
    date: string;
    overall_score: number;
    love_score: number;
    career_score: number;
    wealth_score: number;
    health_score: number;
    summary: string;
    keywords: string[];
    lucky_color: string;
    lucky_number: number;
    lucky_item: string;
    advice: string[];
    energy_level: number;
    mood_forecast: string;
    opportunities: string[];
    challenges: string[];
    recommendations: string[];
    preparation_tips: string[];
  };
}

// 애니메이션 variants
const containerVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { staggerChildren: 0.1 } }
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 }
};

export default function TomorrowFortunePage() {
  const [fontSize, setFontSize] = useState<'small'|'medium'|'large'>('medium');
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [result, setResult] = useState<TomorrowFortuneResult | null>(null);

  // React Hook Form 설정
  const { register, handleSubmit, setValue, watch, formState: { errors } } = useForm<TomorrowFortuneForm>({
    defaultValues: {
      name: '',
      birth_date: '',
      mbti: '',
      zodiac: ''
    }
  });

  // 운세 스트림 훅 사용
  const { generateFortune, isGenerating } = useFortuneStream();

  // 폼 제출 처리
  const onSubmit = useCallback(async (data: TomorrowFortuneForm) => {
    if (!data.name.trim() || !data.birth_date) {
      toast.error('이름과 생년월일을 입력해주세요.');
      return;
    }

    const loadingToast = toast.loading('내일의 운세를 분석하고 있습니다...');

    try {
      const requestData = {
        category: 'tomorrow',
        userInfo: {
          name: data.name.trim(),
          birthDate: data.birth_date,
          mbti: data.mbti || '미입력',
          zodiac: data.zodiac || '미입력'
        },
        packageType: 'single' as const
      };

      const fortuneResult = await generateFortune(requestData);
      
      if (fortuneResult.tomorrow) {
        setResult(fortuneResult as TomorrowFortuneResult);
        setStep('result');
        toast.success('내일의 운세 분석이 완료되었습니다!', { id: loadingToast });
      } else {
        throw new Error('운세 데이터를 받지 못했습니다.');
      }
    } catch (error) {
      console.error('운세 생성 오류:', error);
      toast.error('운세 분석 중 오류가 발생했습니다. 다시 시도해주세요.', { id: loadingToast });
    }
  }, [generateFortune]);

  // 다시하기 함수
  const handleReset = useCallback(() => {
    setStep('input');
    setResult(null);
  }, []);

  // 새로고침 함수  
  const handleRefresh = useCallback(async () => {
    const formData = watch();
    await onSubmit(formData);
  }, [onSubmit, watch]);

  // 내일 날짜 계산
  const getTomorrowDate = () => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return tomorrow.toLocaleDateString('ko-KR', { 
      year: 'numeric', 
      month: 'long', 
      day: 'numeric', 
      weekday: 'long' 
    });
  };

  return (
    <div className="min-h-screen pb-32 px-4 space-y-6 bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-gray-900 dark:to-gray-800">
      <AppHeader title="내일의 운세" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
      
      <motion.div
        className="max-w-4xl mx-auto"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        <AnimatePresence mode="wait">
          {step === 'input' && (
            <motion.div
              key="input"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              transition={{ duration: 0.3 }}
            >
              <motion.div variants={itemVariants} className="text-center mb-8">
                <div className="flex items-center justify-center gap-3 mb-4">
                  <div className="p-3 bg-gradient-to-r from-blue-500 to-indigo-500 rounded-full">
                    <Moon className="w-8 h-8 text-white" />
                  </div>
                  <h1 className="text-4xl font-bold bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">
                    내일의 운세
                  </h1>
                </div>
                <p className="text-lg text-gray-600 dark:text-gray-400 mb-6">
                  {getTomorrowDate()}의 당신만의 운세를 미리 확인해보세요
                </p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="shadow-lg border-0 bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm">
                  <CardHeader className="text-center">
                    <CardTitle className="text-2xl text-gray-800 dark:text-gray-200 flex items-center justify-center gap-2">
                      <Sparkles className="w-6 h-6 text-blue-500" />
                      정보 입력
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
                      {/* 기본 정보 */}
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <Label htmlFor="name" className="text-gray-700 dark:text-gray-300 font-medium">
                            이름 <span className="text-red-500">*</span>
                          </Label>
                          <div className="relative">
                            <User className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                            <Input
                              {...register("name", { required: "이름을 입력해주세요" })}
                              placeholder="이름을 입력하세요"
                              className="pl-10 border-gray-200 dark:border-gray-600 focus:border-blue-400 dark:focus:border-blue-500"
                            />
                          </div>
                          {errors.name && (
                            <p className="text-red-500 text-sm">{errors.name.message}</p>
                          )}
                        </div>

                        <div className="space-y-2">
                          <Label htmlFor="birth_date" className="text-gray-700 dark:text-gray-300 font-medium">
                            생년월일 <span className="text-red-500">*</span>
                          </Label>
                          <div className="relative">
                            <Calendar className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400" />
                            <Input
                              {...register("birth_date", { required: "생년월일을 입력해주세요" })}
                              type="date"
                              className="pl-10 border-gray-200 dark:border-gray-600 focus:border-blue-400 dark:focus:border-blue-500"
                            />
                          </div>
                          {errors.birth_date && (
                            <p className="text-red-500 text-sm">{errors.birth_date.message}</p>
                          )}
                        </div>
                      </div>

                      {/* 선택 정보 */}
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="space-y-2">
                          <Label className="text-gray-700 dark:text-gray-300 font-medium">
                            MBTI (선택)
                          </Label>
                          <Select onValueChange={(value) => setValue("mbti", value)}>
                            <SelectTrigger className="border-gray-200 dark:border-gray-600 focus:border-blue-400">
                              <SelectValue placeholder="MBTI를 선택하세요" />
                            </SelectTrigger>
                            <SelectContent>
                              {['INTJ', 'INTP', 'ENTJ', 'ENTP', 'INFJ', 'INFP', 'ENFJ', 'ENFP', 
                                'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ', 'ISTP', 'ISFP', 'ESTP', 'ESFP'].map((type) => (
                                <SelectItem key={type} value={type}>{type}</SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                        </div>

                        <div className="space-y-2">
                          <Label className="text-gray-700 dark:text-gray-300 font-medium">
                            별자리 (선택)
                          </Label>
                          <Select onValueChange={(value) => setValue("zodiac", value)}>
                            <SelectTrigger className="border-gray-200 dark:border-gray-600 focus:border-blue-400">
                              <SelectValue placeholder="별자리를 선택하세요" />
                            </SelectTrigger>
                            <SelectContent>
                              {['양자리', '황소자리', '쌍둥이자리', '게자리', '사자자리', '처녀자리',
                                '천칭자리', '전갈자리', '사수자리', '염소자리', '물병자리', '물고기자리'].map((sign) => (
                                <SelectItem key={sign} value={sign}>{sign}</SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                        </div>
                      </div>

                      <Button
                        type="submit"
                        disabled={isGenerating}
                        className="w-full bg-gradient-to-r from-blue-500 to-indigo-500 hover:from-blue-600 hover:to-indigo-600 text-white py-3 text-lg font-medium shadow-lg"
                      >
                        {isGenerating ? (
                          <div className="flex items-center gap-2">
                            <Loader2 className="w-5 h-5 animate-spin" />
                            운세 분석 중...
                          </div>
                        ) : (
                          <div className="flex items-center gap-2">
                            <Moon className="w-5 h-5" />
                            내일의 운세 보기
                          </div>
                        )}
                      </Button>
                    </form>
                  </CardContent>
                </Card>
              </motion.div>
            </motion.div>
          )}

          {step === 'result' && result && (
            <motion.div
              key="result"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              transition={{ duration: 0.3 }}
              className="space-y-6"
            >
              {/* 헤더 */}
              <motion.div variants={itemVariants} className="text-center">
                <div className="flex items-center justify-center gap-2 mb-2">
                  <Moon className="w-6 h-6 text-blue-600" />
                  <h2 className="text-2xl font-bold text-gray-800 dark:text-gray-200">
                    {result.tomorrow.date}
                  </h2>
                </div>
                <p className="text-gray-600 dark:text-gray-400">
                  {result.tomorrow.mood_forecast} 에너지가 기다리는 내일
                </p>
              </motion.div>

              {/* 종합 점수 */}
              <motion.div variants={itemVariants}>
                <Card className="border-blue-200 dark:border-gray-700 bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-gray-800 dark:to-gray-700">
                  <CardContent className="text-center py-8">
                    <div className="text-6xl font-bold text-blue-600 dark:text-blue-400 mb-4">
                      {result.tomorrow.overall_score}점
                    </div>
                    <div className="flex justify-center space-x-2 mb-4">
                      {result.tomorrow.keywords.map((keyword, index) => (
                        <Badge key={index} className="bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
                          {keyword}
                        </Badge>
                      ))}
                    </div>
                    <p className="text-lg text-gray-700 dark:text-gray-300 leading-relaxed">
                      {result.tomorrow.summary}
                    </p>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 세부 운세 분석 */}
              <motion.div variants={itemVariants}>
                <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">세부 운세 분석</h3>
                <Accordion type="single" collapsible className="bg-white/60 dark:bg-gray-800/60 rounded-lg border border-blue-200 dark:border-gray-700">
                  {[
                    { id: "general", title: "총운", score: result.tomorrow.overall_score, description: result.tomorrow.summary, icon: Star },
                    { id: "love", title: "애정운", score: result.tomorrow.love_score, description: "사랑과 인연의 흐름", icon: Heart },
                    { id: "career", title: "직업운", score: result.tomorrow.career_score, description: "업무와 성장의 기회", icon: Briefcase },
                    { id: "money", title: "금전운", score: result.tomorrow.wealth_score, description: "재물과 투자의 운", icon: Coins },
                    { id: "health", title: "건강운", score: result.tomorrow.health_score, description: "몸과 마음의 컨디션", icon: HeartPulse }
                  ].map((detail) => {
                    const Icon = detail.icon;
                    return (
                      <AccordionItem key={detail.id} value={detail.id} className="border-blue-100 dark:border-gray-700">
                        <AccordionTrigger className="text-left hover:bg-blue-50 dark:hover:bg-gray-700 px-4">
                          <div className="flex items-center space-x-2">
                            <Icon className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                            <span className="text-gray-900 dark:text-gray-100">{detail.title}</span>
                            <span className="ml-2 text-sm text-blue-600 dark:text-blue-400 font-medium">
                              {detail.score}점
                            </span>
                          </div>
                        </AccordionTrigger>
                        <AccordionContent className="px-4">
                          <p className="text-sm text-gray-600 dark:text-gray-300">
                            {detail.description}
                          </p>
                        </AccordionContent>
                      </AccordionItem>
                    );
                  })}
                </Accordion>
              </motion.div>

              {/* 내일의 조언 */}
              <motion.div variants={itemVariants}>
                <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">내일의 조언</h3>
                <div className="bg-white/60 dark:bg-gray-800/60 rounded-lg border border-blue-200 dark:border-gray-700 p-4">
                  <ul className="list-disc pl-5 space-y-2 text-sm text-gray-600 dark:text-gray-300">
                    {result.tomorrow.advice.map((advice, index) => (
                      <li key={index}>{advice}</li>
                    ))}
                  </ul>
                </div>
              </motion.div>

              {/* 준비 사항 */}
              {result.tomorrow.preparation_tips && result.tomorrow.preparation_tips.length > 0 && (
                <motion.div variants={itemVariants}>
                  <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">내일을 위한 준비</h3>
                  <div className="bg-purple-50 dark:bg-purple-900/20 rounded-lg border border-purple-200 dark:border-purple-700 p-4">
                    <ul className="space-y-2 text-sm text-purple-700 dark:text-purple-300">
                      {result.tomorrow.preparation_tips.map((tip, index) => (
                        <li key={index} className="flex items-start gap-2">
                          <span className="text-purple-500 mt-1">•</span>
                          <span>{tip}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                </motion.div>
              )}

              {/* 기회와 도전 */}
              <motion.div variants={itemVariants}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-700 p-4">
                    <h4 className="font-semibold text-green-800 dark:text-green-400 mb-2">내일의 기회</h4>
                    <ul className="space-y-1 text-sm text-green-700 dark:text-green-300">
                      {result.tomorrow.opportunities.map((opportunity, index) => (
                        <li key={index}>• {opportunity}</li>
                      ))}
                    </ul>
                  </div>
                  <div className="bg-amber-50 dark:bg-amber-900/20 rounded-lg border border-amber-200 dark:border-amber-700 p-4">
                    <h4 className="font-semibold text-amber-800 dark:text-amber-400 mb-2">주의할 점</h4>
                    <ul className="space-y-1 text-sm text-amber-700 dark:text-amber-300">
                      {result.tomorrow.challenges.map((challenge, index) => (
                        <li key={index}>• {challenge}</li>
                      ))}
                    </ul>
                  </div>
                </div>
              </motion.div>

              {/* 행운 아이템 */}
              <motion.div variants={itemVariants}>
                <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">행운을 더해줄 아이템</h3>
                <div className="bg-white/60 dark:bg-gray-800/60 rounded-lg border border-blue-200 dark:border-gray-700 p-4">
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 text-sm">
                    <div className="flex items-center space-x-3">
                      <Palette className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                      <span className="text-gray-900 dark:text-gray-100 font-medium">색상:</span>
                      <span className="text-blue-700 dark:text-blue-300 font-semibold">{result.tomorrow.lucky_color}</span>
                    </div>
                    <div className="flex items-center space-x-3">
                      <Hash className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                      <span className="text-gray-900 dark:text-gray-100 font-medium">숫자:</span>
                      <span className="text-blue-700 dark:text-blue-300 font-semibold">{result.tomorrow.lucky_number}</span>
                    </div>
                    <div className="flex items-center space-x-3">
                      <Gift className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                      <span className="text-gray-900 dark:text-gray-100 font-medium">아이템:</span>
                      <span className="text-blue-700 dark:text-blue-300 font-semibold">{result.tomorrow.lucky_item}</span>
                    </div>
                  </div>
                </div>
              </motion.div>

              {/* 액션 버튼 */}
              <motion.div variants={itemVariants} className="flex justify-center gap-4 pt-6">
                <Button
                  onClick={handleRefresh}
                  disabled={isGenerating}
                  variant="outline"
                  className="border-blue-300 text-blue-700 hover:bg-blue-50 dark:border-blue-600 dark:text-blue-300 dark:hover:bg-blue-900/20"
                >
                  <RefreshCw className="w-4 h-4 mr-2" />
                  새로고침
                </Button>
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="border-gray-300 text-gray-700 hover:bg-gray-50 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-700"
                >
                  다시하기
                </Button>
                <Button asChild variant="outline" className="border-blue-300 text-blue-700 hover:bg-blue-50 dark:border-blue-600 dark:text-blue-300 dark:hover:bg-blue-900/20">
                  <Link href="/fortune">목록으로</Link>
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}
