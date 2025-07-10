"use client";

import { useToast } from '@/hooks/use-toast';
import { logger } from '@/lib/logger';
import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { FortuneResult } from "@/lib/schemas";
import { callGPTFortuneAPI, validateUserInput, FORTUNE_REQUIRED_FIELDS, FortuneServiceError } from "@/lib/fortune-utils";
import { FortuneErrorBoundary } from "@/components/FortuneErrorBoundary";
import {
  Brain, 
  Star, 
  Shuffle,
  RotateCcw,
  CheckCircle,
  ArrowLeft,
  MessageCircle,
  BookOpen,
  Users
} from "lucide-react";
import { 
  getYearOptions, 
  getMonthOptions, 
  getDayOptions, 
  formatKoreanDate,
  koreanToIsoDate,
} from "@/lib/utils";

interface PsychologyTestInfo {
  name: string;
  birthYear: string;
  birthMonth: string;
  birthDay: string;
  answers: { [key: string]: string };
}

interface PsychologyTestFortune {
  overall_luck: number;
  test_result_type: string;
  result_summary: string;
  result_details: string;
  advice: string;
  lucky_elements: string[];
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

// 하드코딩된 심리테스트 질문들 제거됨 - GPT API에서 동적 질문 제공 예정
// 임시 질문들 - GPT API 구현 전까지 사용
const psychologyQuestions = [
  {
    id: 'q1',
    question: '새로운 환경에 놓였을 때 당신의 반응은?',
    options: [
      { value: 'a', label: '적극적으로 탐색하고 새로운 사람들과 어울린다' },
      { value: 'b', label: '조심스럽게 관찰하며 천천히 적응한다' },
      { value: 'c', label: '익숙한 것을 찾아 안정감을 찾는다' },
      { value: 'd', label: '불안하지만 필요한 것만 빠르게 파악한다' }
    ]
  },
  {
    id: 'q2',
    question: '스트레스를 받을 때 주로 어떻게 해소하나요?',
    options: [
      { value: 'a', label: '운동이나 활동적인 취미로 해소한다' },
      { value: 'b', label: '혼자만의 시간을 가지며 휴식한다' },
      { value: 'c', label: '친구나 가족과 대화를 나눈다' },
      { value: 'd', label: '취미 활동에 몰두한다' }
    ]
  },
  {
    id: 'q3',
    question: '중요한 결정을 내릴 때 당신의 방식은?',
    options: [
      { value: 'a', label: '직감과 감정을 따른다' },
      { value: 'b', label: '논리적으로 분석하고 계산한다' },
      { value: 'c', label: '다른 사람들의 조언을 구한다' },
      { value: 'd', label: '과거 경험을 바탕으로 판단한다' }
    ]
  }
];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 dark:text-green-400 bg-green-50 dark:bg-green-900/30";
  if (score >= 70) return "text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30";
  if (score >= 55) return "text-orange-600 dark:text-orange-400 bg-orange-50 dark:bg-orange-900/30";
  return "text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/30";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "매우 긍정적";
  if (score >= 70) return "긍정적";
  if (score >= 55) return "보통";
  return "노력 필요";
};

export default function PsychologyTestPage() {
  const { toast } = useToast();
  const [step, setStep] = useState<'form' | 'result'>('form');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [isGenerating, setIsGenerating] = useState(false);
  const [formData, setFormData] = useState<PsychologyTestInfo>({
    name: '',
    birthYear: '',
    birthMonth: '',
    birthDay: '',
    answers: {},
  });
  const [result, setResult] = useState<PsychologyTestFortune | null>(null);
  const [error, setError] = useState<Error | null>(null);
  
  useFortuneStream();
  
  const {
    todayFortune,
    isLoading: isDailyLoading,
    isGenerating: isDailyGenerating,
    hasTodayFortune,
    saveFortune,
    regenerateFortune,
    canRegenerate
  } = useDailyFortune({ fortuneType: 'psychology-test' });

  useEffect(() => {
    if (hasTodayFortune && todayFortune && step === 'form') {
      const savedData = todayFortune.fortune_data as any;
      const metadata = savedData.metadata || {};
      
      setFormData({
        name: savedData.user_info?.name || '',
        birthYear: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[0] : '',
        birthMonth: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[1] : '',
        birthDay: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[2] : '',
        answers: metadata.answers || {},
      });
      
      if (savedData.fortune_scores) {
        // 운세 데이터가 불완전하면 에러 발생
        if (!savedData.fortune_scores.overall_luck || !savedData.insights?.test_result_type || 
            !savedData.insights?.result_summary || !savedData.insights?.result_details || 
            !savedData.insights?.advice || !savedData.lucky_items?.lucky_elements) {
          throw new FortuneServiceError('psychology-test');
        }
        
        const restoredResult: PsychologyTestFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          test_result_type: savedData.insights.test_result_type,
          result_summary: savedData.insights.result_summary,
          result_details: savedData.insights.result_details,
          advice: savedData.insights.advice,
          lucky_elements: savedData.lucky_items.lucky_elements,
        };
        setResult(restoredResult);
        setStep('result');
      }
    }
  }, [hasTodayFortune, todayFortune, step]);

  const getFontSizeClasses = (size: 'small' | 'medium' | 'large') => {
    switch (size) {
      case 'small':
        return {
          text: 'text-sm',
          title: 'text-lg',
          heading: 'text-xl',
          score: 'text-4xl',
          label: 'text-xs'
        };
      case 'large':
        return {
          text: 'text-lg',
          title: 'text-2xl',
          heading: 'text-3xl',
          score: 'text-8xl',
          label: 'text-base'
        };
      default: // medium
        return {
          text: 'text-base',
          title: 'text-xl',
          heading: 'text-2xl',
          score: 'text-6xl',
          label: 'text-sm'
        };
    }
  };

  const fontClasses = getFontSizeClasses(fontSize);

  const analyzePsychologyTestFortune = async (): Promise<PsychologyTestFortune> => {
    // 입력 검증
    if (!validateUserInput(formData, FORTUNE_REQUIRED_FIELDS['psychology-test'])) {
      throw new Error('필수 입력 정보가 부족합니다.');
    }

    // GPT API 호출 (현재는 에러를 발생시켜 가짜 데이터 생성 방지)
    const gptResult = await callGPTFortuneAPI({
      type: 'psychology-test',
      userInfo: {
        name: formData.name,
        birth_date: `${formData.birthYear}-${formData.birthMonth}-${formData.birthDay}`,
        answers: formData.answers
      }
    });

    return gptResult;
  };

  const yearOptions = getYearOptions();
  const monthOptions = getMonthOptions();
  const dayOptions = getDayOptions(
    formData.birthYear ? parseInt(formData.birthYear) : undefined,
    formData.birthMonth ? parseInt(formData.birthMonth) : undefined
  );

  const handleRegenerate = useCallback(async (): Promise<void> => {
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzePsychologyTestFortune();
      
      const fortuneResult: FortuneResult = {
        user_info: {
          name: formData.name,
          birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
        },
        fortune_scores: {
          overall_luck: analysisResult.overall_luck,
        },
        insights: {
          test_result_type: analysisResult.test_result_type,
          result_summary: analysisResult.result_summary,
          result_details: analysisResult.result_details,
          advice: analysisResult.advice,
        },
        lucky_items: {
          lucky_elements: analysisResult.lucky_elements,
        },
        metadata: {
          answers: formData.answers,
        }
      };

      const success = await regenerateFortune(fortuneResult);
      if (success) {
        setResult(analysisResult);
      }
    } catch (error) {
      logger.error('재생성 중 오류:', error);
      
      // FortuneServiceError인 경우 에러 상태로 설정
      if (error instanceof FortuneServiceError) {
        setError(error);
      } else {
        toast({
      title: '운세 재생성에 실패했습니다. 다시 시도해주세요.',
      variant: "destructive",
    });
      }
    }
  }, [formData, regenerateFortune]);

  const handleAnswerChange = (questionId: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      answers: {
        ...prev.answers,
        [questionId]: value,
      },
    }));
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birthYear || !formData.birthMonth || !formData.birthDay) {
      toast({
      title: '이름과 생년월일을 입력해주세요.',
      variant: "default",
    });
      return;
    }

    setIsGenerating(true);

    try {
      const birthDate = koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay);
      
      if (hasTodayFortune && todayFortune) {
        const savedData = todayFortune.fortune_data as any;
        // 운세 데이터가 불완전하면 에러 발생
        if (!savedData.fortune_scores?.overall_luck || !savedData.insights?.test_result_type || 
            !savedData.insights?.result_summary || !savedData.insights?.result_details || 
            !savedData.insights?.advice || !savedData.lucky_items?.lucky_elements) {
          throw new FortuneServiceError('psychology-test');
        }
        
        const restoredResult: PsychologyTestFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          test_result_type: savedData.insights.test_result_type,
          result_summary: savedData.insights.result_summary,
          result_details: savedData.insights.result_details,
          advice: savedData.insights.advice,
          lucky_elements: savedData.lucky_items.lucky_elements,
        };
        setResult(restoredResult);
      } else {
        const fortuneResult = await analyzePsychologyTestFortune();
        setResult(fortuneResult);
        
        const fortuneData: FortuneResult = {
          user_info: {
            name: formData.name,
            birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
          },
          fortune_scores: {
            overall_luck: fortuneResult.overall_luck,
          },
          insights: {
            test_result_type: fortuneResult.test_result_type,
            result_summary: fortuneResult.result_summary,
            result_details: fortuneResult.result_details,
            advice: fortuneResult.advice,
          },
          lucky_items: {
            lucky_elements: fortuneResult.lucky_elements,
          },
          metadata: {
            answers: formData.answers,
          }
        };
        
        await saveFortune(fortuneData);
      }
      
      setStep('result');
    } catch (error) {
      logger.error('심리 테스트 분석 실패:', error);
      
      // FortuneServiceError인 경우 에러 상태로 설정
      if (error instanceof FortuneServiceError) {
        setError(error);
      } else {
        toast({
      title: '심리 테스트 분석 중 오류가 발생했습니다. 다시 시도해주세요.',
      variant: "destructive",
    });
      }
    } finally {
      setIsGenerating(false);
    }
  };

  const handleReset = () => {
    setStep('form');
    setResult(null);
    setFormData({
      name: '',
      birthYear: '',
      birthMonth: '',
      birthDay: '',
      answers: {},
    });
  };

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-teal-50 to-blue-50 dark:from-gray-900 dark:via-green-900 dark:to-gray-800 pb-20">
        <AppHeader 
          title="심리 테스트" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <FortuneErrorBoundary 
          error={error} 
          reset={() => setError(null)}
          fallbackMessage="심리 테스트 서비스는 현재 준비 중입니다. 실제 AI 분석을 곧 제공할 예정입니다."
        />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-teal-50 to-blue-50 dark:from-gray-900 dark:via-green-900 dark:to-gray-800 pb-20">
      <AppHeader 
        title="심리 테스트" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-6"
      >
        <AnimatePresence mode="wait">
          {step === 'form' && (
            <motion.div
              key="form"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              {/* 헤더 */}
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-green-500 to-teal-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Brain className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}>심리 테스트</h1>
                <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>간단한 질문으로 당신의 심리 유형을 분석해드립니다.</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-green-200 dark:border-green-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-green-700 dark:text-green-400`}>
                      <Users className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="name" className={`${fontClasses.text} dark:text-gray-300`}>이름</Label>
                      <Textarea
                        id="name"
                        placeholder="이름"
                        value={formData.name}
                        onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                        className={`${fontClasses.text} mt-1`}
                      />
                    </div>

                    {/* 년도 선택 */}
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>생년</Label>
                      <select 
                        value={formData.birthYear} 
                        onChange={(e) => setFormData(prev => ({ ...prev, birthYear: e.target.value }))}
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm`}
                      >
                        <option value="">년도 선택</option>
                        {yearOptions.map((year) => (
                          <option key={year} value={year.toString()}>
                            {year}년
                          </option>
                        ))}
                      </select>
                    </div>

                    {/* 월 선택 */}
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>생월</Label>
                      <select 
                        value={formData.birthMonth} 
                        onChange={(e) => setFormData(prev => ({ ...prev, birthMonth: e.target.value }))}
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm`}
                      >
                        <option value="">월 선택</option>
                        {monthOptions.map((month) => (
                          <option key={month} value={month.toString()}>
                            {month}월
                          </option>
                        ))}
                      </select>
                    </div>

                    {/* 일 선택 */}
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>생일</Label>
                      <select 
                        value={formData.birthDay} 
                        onChange={(e) => setFormData(prev => ({ ...prev, birthDay: e.target.value }))}
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-green-500 focus:ring-green-500 sm:text-sm`}
                      >
                        <option value="">일 선택</option>
                        {dayOptions.map((day) => (
                          <option key={day} value={day.toString()}>
                            {day}일
                          </option>
                        ))}
                      </select>
                    </div>

                    {/* 선택된 생년월일 표시 */}
                    {formData.birthYear && formData.birthMonth && formData.birthDay && (
                      <div className="p-3 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-700">
                        <p className={`${fontClasses.text} font-medium text-green-800 dark:text-green-300 text-center`}>
                          {formatKoreanDate(formData.birthYear, formData.birthMonth, formData.birthDay)}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 심리 테스트 질문 */}
              <motion.div variants={itemVariants}>
                <Card className="border-teal-200 dark:border-teal-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-teal-700 dark:text-teal-400`}>
                      <MessageCircle className="w-5 h-5" />
                      심리 테스트 질문
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    {psychologyQuestions.map((q) => (
                      <div key={q.id} className="space-y-2">
                        <Label className={`${fontClasses.text} dark:text-gray-300`}>{q.question}</Label>
                        <RadioGroup 
                          value={formData.answers[q.id] || ''} 
                          onValueChange={(value) => handleAnswerChange(q.id, value)}
                          className="grid grid-cols-1 gap-2"
                        >
                          {q.options.map((option) => (
                            <div key={option.value} className="flex items-center space-x-2">
                              <RadioGroupItem value={option.value} id={`${q.id}-${option.value}`} />
                              <Label htmlFor={`${q.id}-${option.value}`} className={`${fontClasses.label} dark:text-gray-300`}>{option.label}</Label>
                            </div>
                          ))}
                        </RadioGroup>
                      </div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={isGenerating || isDailyGenerating}
                  className={`w-full bg-gradient-to-r from-green-500 to-teal-500 hover:from-green-600 hover:to-teal-600 text-white py-6 ${fontClasses.title} font-semibold`}
                >
                  {(isGenerating || isDailyGenerating) ? (
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ repeat: Infinity, duration: 1 }}
                      className="flex items-center gap-2"
                    >
                      <Shuffle className="w-5 h-5" />
                      {hasTodayFortune ? '불러오는 중...' : '분석 중...'}
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      {hasTodayFortune ? (
                        <>
                          <CheckCircle className="w-5 h-5" />
                          오늘의 심리 테스트 결과 보기
                        </>
                      ) : (
                        <>
                          <Brain className="w-5 h-5" />
                          심리 테스트 분석하기
                        </>
                      )}
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
                <Card className="bg-gradient-to-r from-green-500 to-teal-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className={`flex items-center justify-center gap-2 mb-4`}>
                      <Brain className="w-6 h-6" />
                      <span className={`${fontClasses.title} font-medium`}>{formData.name}님의 심리 테스트 결과</span>
                    </div>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className={`${fontClasses.score} font-bold mb-2`}
                    >
                      {result.overall_luck}점
                    </motion.div>
                    <Badge variant="secondary" className={`${fontClasses.text} bg-white/20 text-white border-white/30`}>
                      {getLuckText(result.overall_luck)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 결과 요약 및 상세 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-green-600 dark:text-green-400`}>
                      <BookOpen className="w-5 h-5" />
                      결과 요약 및 상세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-green-50 dark:bg-green-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-green-800 dark:text-green-300 mb-2 flex items-center gap-2`}>
                        <MessageCircle className="w-4 h-4" />
                        결과 유형
                      </h4>
                      <p className={`${fontClasses.text} text-green-700 dark:text-green-400`}>{result.test_result_type}</p>
                    </div>
                    <div className="p-4 bg-teal-50 dark:bg-teal-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-teal-800 dark:text-teal-300 mb-2 flex items-center gap-2`}>
                        <BookOpen className="w-4 h-4" />
                        결과 요약
                      </h4>
                      <p className={`${fontClasses.text} text-teal-700 dark:text-teal-400`}>{result.result_summary}</p>
                    </div>
                    <div className="p-4 bg-blue-50 dark:bg-blue-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-blue-800 dark:text-blue-300 mb-2 flex items-center gap-2`}>
                        <Users className="w-4 h-4" />
                        결과 상세
                      </h4>
                      <p className={`${fontClasses.text} text-blue-700 dark:text-blue-400`}>{result.result_details}</p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 조언 및 행운 요소 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-600 dark:text-purple-400`}>
                      <Star className="w-5 h-5" />
                      조언 및 행운 요소
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-purple-50 dark:bg-purple-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-purple-800 dark:text-purple-300 mb-2 flex items-center gap-2`}>
                        <MessageCircle className="w-4 h-4" />
                        조언
                      </h4>
                      <p className={`${fontClasses.text} text-purple-700 dark:text-purple-400`}>{result.advice}</p>
                    </div>
                    {result.lucky_elements && result.lucky_elements.length > 0 && (
                      <div className="p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-gray-800 dark:text-gray-300 mb-2 flex items-center gap-2`}>
                          <Star className="w-4 h-4" />
                          행운 요소
                        </h4>
                        <p className={`${fontClasses.title} font-semibold text-gray-700 dark:text-gray-400`}>
                          {result.lucky_elements.join(', ')}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 및 재생성 버튼 */}
              <motion.div variants={itemVariants} className="pt-4 space-y-3">
                {canRegenerate && (
                  <Button
                    onClick={() => void handleRegenerate()}
                    disabled={isGenerating}
                    className={`w-full bg-gradient-to-r from-purple-500 to-indigo-500 hover:from-purple-600 hover:to-indigo-600 text-white py-3 ${fontClasses.text}`}
                  >
                    {isGenerating ? (
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ repeat: Infinity, duration: 1 }}
                        className="flex items-center gap-2"
                      >
                        <Shuffle className="w-4 h-4" />
                        재생성 중...
                      </motion.div>
                    ) : (
                      <div className="flex items-center gap-2">
                        <RotateCcw className="w-4 h-4" />
                        오늘 운세 다시 생성하기
                      </div>
                    )}
                  </Button>
                )}
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className={`w-full border-green-300 dark:border-green-700 text-green-600 dark:text-green-400 hover:bg-green-50 dark:hover:bg-green-900/30 py-3 ${fontClasses.text}`}
                >
                  <ArrowLeft className="w-4 h-4 mr-2" />
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