"use client";

import { useToast } from '@/hooks/use-toast';
import { logger } from '@/lib/logger';
import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { FortuneResult } from "@/lib/schemas";
import { callGPTFortuneAPI, validateUserInput, FORTUNE_REQUIRED_FIELDS, FortuneServiceError } from "@/lib/fortune-utils";
import { FortuneErrorBoundary } from "@/components/FortuneErrorBoundary";
import {
  Baby, 
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

interface TaemongInfo {
  name: string;
  birthYear: string;
  birthMonth: string;
  birthDay: string;
  taemongContent: string;
}

interface TaemongFortune {
  overall_luck: number;
  taemong_summary: string;
  taemong_interpretation: string;
  child_gender_prediction: string;
  child_characteristics: string[];
  lucky_advice: string;
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

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 dark:text-green-400 bg-green-50 dark:bg-green-900/30";
  if (score >= 70) return "text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30";
  if (score >= 55) return "text-orange-600 dark:text-orange-400 bg-orange-50 dark:bg-orange-900/30";
  return "text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/30";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "매우 길한 태몽";
  if (score >= 70) return "길한 태몽";
  if (score >= 55) return "보통 태몽";
  return "주의 필요";
};

export default function TaemongPage() {
  const { toast } = useToast();
  const [step, setStep] = useState<'form' | 'result'>('form');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [isGenerating, setIsGenerating] = useState(false);
  const [formData, setFormData] = useState<TaemongInfo>({
    name: '',
    birthYear: '',
    birthMonth: '',
    birthDay: '',
    taemongContent: '',
  });
  const [result, setResult] = useState<TaemongFortune | null>(null);
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
  } = useDailyFortune({ fortuneType: 'taemong' });

  useEffect(() => {
    if (hasTodayFortune && todayFortune && step === 'form') {
      const savedData = todayFortune.fortune_data as any;
      const metadata = savedData.metadata || {};
      
      setFormData({
        name: savedData.user_info?.name || '',
        birthYear: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[0] : '',
        birthMonth: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[1] : '',
        birthDay: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[2] : '',
        taemongContent: metadata.taemong_content || '',
      });
      
      if (savedData.fortune_scores) {
        // 운세 데이터가 불완전하면 에러 발생
        if (!savedData.fortune_scores.overall_luck || !savedData.insights?.taemong_summary || 
            !savedData.insights?.taemong_interpretation || !savedData.insights?.child_gender_prediction || 
            !savedData.insights?.child_characteristics || !savedData.insights?.lucky_advice) {
          throw new FortuneServiceError('taemong');
        }
        
        const restoredResult: TaemongFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          taemong_summary: savedData.insights.taemong_summary,
          taemong_interpretation: savedData.insights.taemong_interpretation,
          child_gender_prediction: savedData.insights.child_gender_prediction,
          child_characteristics: savedData.insights.child_characteristics,
          lucky_advice: savedData.insights.lucky_advice,
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

  const analyzeTaemongFortune = async (): Promise<TaemongFortune> => {
    // 입력 검증
    if (!validateUserInput(formData, FORTUNE_REQUIRED_FIELDS['taemong'])) {
      throw new Error('필수 입력 정보가 부족합니다.');
    }

    // GPT API 호출 (현재는 에러를 발생시켜 가짜 데이터 생성 방지)
    const gptResult = await callGPTFortuneAPI({
      type: 'taemong',
      userInfo: {
        name: formData.name,
        birth_date: `${formData.birthYear}-${formData.birthMonth}-${formData.birthDay}`,
        taemong_content: formData.taemongContent
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
      const analysisResult = await analyzeTaemongFortune();
      
      const fortuneResult: FortuneResult = {
        user_info: {
          name: formData.name,
          birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
        },
        fortune_scores: {
          overall_luck: analysisResult.overall_luck,
        },
        insights: {
          taemong_summary: analysisResult.taemong_summary,
          taemong_interpretation: analysisResult.taemong_interpretation,
          child_gender_prediction: analysisResult.child_gender_prediction,
          child_characteristics: analysisResult.child_characteristics,
          lucky_advice: analysisResult.lucky_advice,
        },
        metadata: {
          taemong_content: formData.taemongContent,
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

  const handleSubmit = async () => {
    if (!formData.name || !formData.birthYear || !formData.birthMonth || !formData.birthDay || !formData.taemongContent) {
      toast({
      title: '이름, 생년월일, 태몽 내용을 모두 입력해주세요.',
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
        if (!savedData.fortune_scores?.overall_luck || !savedData.insights?.taemong_summary || 
            !savedData.insights?.taemong_interpretation || !savedData.insights?.child_gender_prediction || 
            !savedData.insights?.child_characteristics || !savedData.insights?.lucky_advice) {
          throw new FortuneServiceError('taemong');
        }
        
        const restoredResult: TaemongFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          taemong_summary: savedData.insights.taemong_summary,
          taemong_interpretation: savedData.insights.taemong_interpretation,
          child_gender_prediction: savedData.insights.child_gender_prediction,
          child_characteristics: savedData.insights.child_characteristics,
          lucky_advice: savedData.insights.lucky_advice,
        };
        setResult(restoredResult);
      } else {
        const fortuneResult = await analyzeTaemongFortune();
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
            taemong_summary: fortuneResult.taemong_summary,
            taemong_interpretation: fortuneResult.taemong_interpretation,
            child_gender_prediction: fortuneResult.child_gender_prediction,
            child_characteristics: fortuneResult.child_characteristics,
            lucky_advice: fortuneResult.lucky_advice,
          },
          metadata: {
            taemong_content: formData.taemongContent,
          }
        };
        
        await saveFortune(fortuneData);
      }
      
      setStep('result');
    } catch (error) {
      logger.error('태몽 분석 실패:', error);
      
      // FortuneServiceError인 경우 에러 상태로 설정
      if (error instanceof FortuneServiceError) {
        setError(error);
      } else {
        toast({
      title: '태몽 분석 중 오류가 발생했습니다. 다시 시도해주세요.',
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
      taemongContent: '',
    });
  };

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-pink-50 via-rose-50 to-red-50 dark:from-gray-900 dark:via-pink-900 dark:to-gray-800 pb-20">
        <AppHeader 
          title="태몽" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <FortuneErrorBoundary 
          error={error} 
          reset={() => setError(null)}
          fallbackMessage="태몽 해석 서비스는 현재 준비 중입니다. 실제 AI 분석을 곧 제공할 예정입니다."
        />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-pink-50 via-rose-50 to-red-50 dark:from-gray-900 dark:via-pink-900 dark:to-gray-800 pb-20">
      <AppHeader 
        title="태몽" 
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
                  className="bg-gradient-to-r from-pink-500 to-rose-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Baby className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}>태몽</h1>
                <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>당신의 태몽에 숨겨진 의미를 AI가 해석해드립니다.</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-pink-200 dark:border-pink-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-pink-700 dark:text-pink-400`}>
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
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-pink-500 focus:ring-pink-500 sm:text-sm`}
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
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-pink-500 focus:ring-pink-500 sm:text-sm`}
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
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-pink-500 focus:ring-pink-500 sm:text-sm`}
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
                      <div className="p-3 bg-pink-50 dark:bg-pink-900/20 rounded-lg border border-pink-200 dark:border-pink-700">
                        <p className={`${fontClasses.text} font-medium text-pink-800 dark:text-pink-300 text-center`}>
                          {formatKoreanDate(formData.birthYear, formData.birthMonth, formData.birthDay)}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 태몽 내용 입력 */}
              <motion.div variants={itemVariants}>
                <Card className="border-rose-200 dark:border-rose-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-rose-700 dark:text-rose-400`}>
                      <BookOpen className="w-5 h-5" />
                      태몽 내용 입력
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="taemong-content" className={`${fontClasses.text} dark:text-gray-300`}>태몽 내용을 자세히 입력해주세요.</Label>
                      <Textarea
                        id="taemong-content"
                        placeholder="예: 하늘에서 용이 내려와 품에 안기는 꿈을 꾸었습니다."
                        value={formData.taemongContent}
                        onChange={(e) => setFormData(prev => ({ ...prev, taemongContent: e.target.value }))}
                        className={`${fontClasses.text} mt-1 min-h-[120px]`}
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={isGenerating || isDailyGenerating}
                  className={`w-full bg-gradient-to-r from-pink-500 to-rose-500 hover:from-pink-600 hover:to-rose-600 text-white py-6 ${fontClasses.title} font-semibold`}
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
                          오늘의 태몽 보기
                        </>
                      ) : (
                        <>
                          <Baby className="w-5 h-5" />
                          태몽 분석하기
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
                <Card className="bg-gradient-to-r from-pink-500 to-rose-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className={`flex items-center justify-center gap-2 mb-4`}>
                      <Baby className="w-6 h-6" />
                      <span className={`${fontClasses.title} font-medium`}>{formData.name}님의 태몽</span>
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

              {/* 태몽 요약 및 해석 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-pink-600 dark:text-pink-400`}>
                      <BookOpen className="w-5 h-5" />
                      태몽 요약 및 해석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-pink-50 dark:bg-pink-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-pink-800 dark:text-pink-300 mb-2 flex items-center gap-2`}>
                        <MessageCircle className="w-4 h-4" />
                        태몽 요약
                      </h4>
                      <p className={`${fontClasses.text} text-pink-700 dark:text-pink-400`}>{result.taemong_summary}</p>
                    </div>
                    <div className="p-4 bg-rose-50 dark:bg-rose-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-rose-800 dark:text-rose-400 mb-2 flex items-center gap-2`}>
                        <BookOpen className="w-4 h-4" />
                        태몽 해석
                      </h4>
                      <p className={`${fontClasses.text} text-rose-700 dark:text-rose-400`}>{result.taemong_interpretation}</p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 아이 성별 예측 및 특징, 조언 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-red-600 dark:text-red-400`}>
                      <Baby className="w-5 h-5" />
                      아이 예측 및 조언
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-red-50 dark:bg-red-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-red-800 dark:text-red-300 mb-2 flex items-center gap-2`}>
                        <Users className="w-4 h-4" />
                        아이 성별 예측
                      </h4>
                      <p className={`${fontClasses.title} font-semibold text-red-700 dark:text-red-400`}>
                        {result.child_gender_prediction}
                      </p>
                    </div>
                    {result.child_characteristics && result.child_characteristics.length > 0 && (
                      <div className="p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-gray-800 dark:text-gray-300 mb-2 flex items-center gap-2`}>
                          <Star className="w-4 h-4" />
                          아이 특징
                        </h4>
                        <p className={`${fontClasses.title} font-semibold text-gray-700 dark:text-gray-400`}>
                          {result.child_characteristics.join(', ')}
                        </p>
                      </div>
                    )}
                    <div className="p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-gray-800 dark:text-gray-300 mb-2 flex items-center gap-2`}>
                        <MessageCircle className="w-4 h-4" />
                        행운 조언
                      </h4>
                      <p className={`${fontClasses.text} text-gray-700 dark:text-gray-400`}>{result.lucky_advice}</p>
                    </div>
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
                  className={`w-full border-pink-300 dark:border-pink-700 text-pink-600 dark:text-pink-400 hover:bg-pink-50 dark:hover:bg-pink-900/30 py-3 ${fontClasses.text}`}
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