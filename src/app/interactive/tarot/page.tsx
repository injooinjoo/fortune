"use client";

import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { FortuneResult } from "@/lib/schemas";
import { callGPTFortuneAPI, validateUserInput, FORTUNE_REQUIRED_FIELDS, FortuneServiceError } from "@/lib/fortune-utils";
import { FortuneErrorBoundary } from "@/components/FortuneErrorBoundary";
import {
  Sparkles, 
  Star, 
  ArrowRight,
  Shuffle,
  Users,
  Crown,
  BarChart3,
  Activity,
  Shield,
  RotateCcw,
  CheckCircle,
  ArrowLeft,
  MessageCircle,
  BookOpen
} from "lucide-react";
import { 
  getYearOptions, 
  getMonthOptions, 
  getDayOptions, 
  formatKoreanDate,
  koreanToIsoDate,
} from "@/lib/utils";

interface TarotInfo {
  name: string;
  birthYear: string;
  birthMonth: string;
  birthDay: string;
  question: string;
  spreadType: string;
}

interface TarotFortune {
  overall_luck: number;
  spread_type: string;
  question: string;
  cards: { position: string; card_name: string; is_reversed: boolean; interpretation: string; }[];
  overall_message: string;
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

// 하드코딩된 타로 카드 스프레드 타입과 카드 이름 제거됨 - GPT API에서 동적 제공
const spreadTypes = ["원 카드 스프레드", "투 카드 스프레드", "쓰리 카드 스프레드", "켈틱 크로스 스프레드"];

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
  return "주의 필요";
};

export default function TarotPage() {
  const [step, setStep] = useState<'form' | 'result'>('form');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [isGenerating, setIsGenerating] = useState(false);
  const [formData, setFormData] = useState<TarotInfo>({
    name: '',
    birthYear: '',
    birthMonth: '',
    birthDay: '',
    question: '',
    spreadType: '쓰리 카드 스프레드',
  });
  const [result, setResult] = useState<TarotFortune | null>(null);
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
  } = useDailyFortune({ fortuneType: 'tarot' });

  useEffect(() => {
    if (hasTodayFortune && todayFortune && step === 'form') {
      const savedData = todayFortune.fortune_data as any;
      const metadata = savedData.metadata || {};
      
      setFormData({
        name: savedData.user_info?.name || '',
        birthYear: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[0] : '',
        birthMonth: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[1] : '',
        birthDay: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[2] : '',
        question: metadata.question || '',
        spreadType: metadata.spread_type || '쓰리 카드 스프레드',
      });
      
      if (savedData.fortune_scores) {
        // 운세 데이터가 불완전하면 에러 발생
        if (!savedData.fortune_scores.overall_luck || !savedData.spread_type || 
            !savedData.question || !savedData.cards || !savedData.overall_message) {
          throw new FortuneServiceError('tarot');
        }
        
        const restoredResult: TarotFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          spread_type: savedData.spread_type,
          question: savedData.question,
          cards: savedData.cards,
          overall_message: savedData.overall_message,
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

  const analyzeTarotFortune = async (): Promise<TarotFortune> => {
    // 입력 검증
    if (!validateUserInput(formData, FORTUNE_REQUIRED_FIELDS['tarot'])) {
      throw new Error('필수 입력 정보가 부족합니다.');
    }

    // GPT API 호출 (현재는 에러를 발생시켜 가짜 데이터 생성 방지)
    const gptResult = await callGPTFortuneAPI({
      type: 'tarot',
      userInfo: {
        name: formData.name,
        birth_date: `${formData.birthYear}-${formData.birthMonth}-${formData.birthDay}`,
        question: formData.question,
        spread_type: formData.spreadType
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
      const analysisResult = await analyzeTarotFortune();
      
      const fortuneResult: FortuneResult = {
        user_info: {
          name: formData.name,
          birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
        },
        fortune_scores: {
          overall_luck: analysisResult.overall_luck,
        },
        insights: {
          spread_type: analysisResult.spread_type,
          question: analysisResult.question,
          overall_message: analysisResult.overall_message,
        },
        metadata: {
          cards: analysisResult.cards,
        }
      };

      const success = await regenerateFortune(fortuneResult);
      if (success) {
        setResult(analysisResult);
      }
    } catch (error) {
      console.error('재생성 중 오류:', error);
      
      // FortuneServiceError인 경우 에러 상태로 설정
      if (error instanceof FortuneServiceError) {
        setError(error);
      } else {
        alert('운세 재생성에 실패했습니다. 다시 시도해주세요.');
      }
    }
  }, [formData, regenerateFortune]);

  const handleSubmit = async () => {
    if (!formData.name || !formData.birthYear || !formData.birthMonth || !formData.birthDay || !formData.question) {
      alert('이름, 생년월일, 질문을 모두 입력해주세요.');
      return;
    }

    setIsGenerating(true);

    try {
      const birthDate = koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay);
      
      if (hasTodayFortune && todayFortune) {
        const savedData = todayFortune.fortune_data as any;
        // 운세 데이터가 불완전하면 에러 발생
        if (!savedData.fortune_scores?.overall_luck || !savedData.spread_type || 
            !savedData.question || !savedData.cards || !savedData.overall_message) {
          throw new FortuneServiceError('tarot');
        }
        
        const restoredResult: TarotFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          spread_type: savedData.spread_type,
          question: savedData.question,
          cards: savedData.cards,
          overall_message: savedData.overall_message,
        };
        setResult(restoredResult);
      } else {
        const fortuneResult = await analyzeTarotFortune();
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
            spread_type: fortuneResult.spread_type,
            question: fortuneResult.question,
            overall_message: fortuneResult.overall_message,
          },
          metadata: {
            cards: fortuneResult.cards,
          }
        };
        
        await saveFortune(fortuneData);
      }
      
      setStep('result');
    } catch (error) {
      console.error('타로 운세 분석 실패:', error);
      
      // FortuneServiceError인 경우 에러 상태로 설정
      if (error instanceof FortuneServiceError) {
        setError(error);
      } else {
        alert('운세 분석 중 오류가 발생했습니다. 다시 시도해주세요.');
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
      question: '',
      spreadType: '쓰리 카드 스프레드',
    });
  };

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-rose-50 dark:from-gray-900 dark:via-purple-900 dark:to-gray-800 pb-20">
        <AppHeader 
          title="타로 운세" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <FortuneErrorBoundary 
          error={error} 
          reset={() => setError(null)}
          fallbackMessage="타로 운세 서비스는 현재 준비 중입니다. 실제 AI 분석을 곧 제공할 예정입니다."
        />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-rose-50 dark:from-gray-900 dark:via-purple-900 dark:to-gray-800 pb-20">
      <AppHeader 
        title="타로 운세" 
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
                  className="bg-gradient-to-r from-purple-500 to-pink-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Sparkles className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}>타로 운세</h1>
                <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>타로 카드가 당신의 질문에 대한 깊은 통찰을 제공합니다.</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-purple-200 dark:border-purple-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-700 dark:text-purple-400`}>
                      <Users className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="name" className={`${fontClasses.text} dark:text-gray-300`}>이름</Label>
                      <Input
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
                      <Select 
                        value={formData.birthYear} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, birthYear: value }))}
                      >
                        <SelectTrigger className={`${fontClasses.text} mt-1`}>
                          <SelectValue placeholder="년도 선택" />
                        </SelectTrigger>
                        <SelectContent>
                          {yearOptions.map((year) => (
                            <SelectItem key={year} value={year.toString()}>
                              {year}년
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    {/* 월 선택 */}
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>생월</Label>
                      <Select 
                        value={formData.birthMonth} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, birthMonth: value }))}
                      >
                        <SelectTrigger className={`${fontClasses.text} mt-1`}>
                          <SelectValue placeholder="월 선택" />
                        </SelectTrigger>
                        <SelectContent>
                          {monthOptions.map((month) => (
                            <SelectItem key={month} value={month.toString()}>
                              {month}월
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    {/* 일 선택 */}
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>생일</Label>
                      <Select 
                        value={formData.birthDay} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, birthDay: value }))}
                      >
                        <SelectTrigger className={`${fontClasses.text} mt-1`}>
                          <SelectValue placeholder="일 선택" />
                        </SelectTrigger>
                        <SelectContent>
                          {dayOptions.map((day) => (
                            <SelectItem key={day} value={day.toString()}>
                              {day}일
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    {/* 선택된 생년월일 표시 */}
                    {formData.birthYear && formData.birthMonth && formData.birthDay && (
                      <div className="p-3 bg-purple-50 dark:bg-purple-900/20 rounded-lg border border-purple-200 dark:border-purple-700">
                        <p className={`${fontClasses.text} font-medium text-purple-800 dark:text-purple-300 text-center`}>
                          {formatKoreanDate(formData.birthYear, formData.birthMonth, formData.birthDay)}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 질문 및 스프레드 선택 */}
              <motion.div variants={itemVariants}>
                <Card className="border-pink-200 dark:border-pink-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-pink-700 dark:text-pink-400`}>
                      <MessageCircle className="w-5 h-5" />
                      질문 및 스프레드
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="question" className={`${fontClasses.text} dark:text-gray-300`}>타로에게 물어볼 질문</Label>
                      <Input
                        id="question"
                        placeholder="예: 저의 연애운은 어떻게 될까요?"
                        value={formData.question}
                        onChange={(e) => setFormData(prev => ({ ...prev, question: e.target.value }))}
                        className={`${fontClasses.text} mt-1`}
                      />
                    </div>
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>스프레드 방식</Label>
                      <Select 
                        value={formData.spreadType} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, spreadType: value }))}
                      >
                        <SelectTrigger className={`${fontClasses.text} mt-1`}>
                          <SelectValue placeholder="스프레드 방식 선택" />
                        </SelectTrigger>
                        <SelectContent>
                          {spreadTypes.map((type) => (
                            <SelectItem key={type} value={type}>
                              {type}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={isGenerating || isDailyGenerating}
                  className={`w-full bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 text-white py-6 ${fontClasses.title} font-semibold`}
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
                          오늘의 타로 운세 보기
                        </>
                      ) : (
                        <>
                          <Sparkles className="w-5 h-5" />
                          타로 운세 분석하기
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
                <Card className="bg-gradient-to-r from-purple-500 to-pink-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className={`flex items-center justify-center gap-2 mb-4`}>
                      <Sparkles className="w-6 h-6" />
                      <span className={`${fontClasses.title} font-medium`}>{formData.name}님의 타로 운세</span>
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

              {/* 질문 및 전체 메시지 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-600 dark:text-purple-400`}>
                      <MessageCircle className="w-5 h-5" />
                      질문 및 전체 메시지
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-purple-50 dark:bg-purple-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-purple-800 dark:text-purple-300 mb-2 flex items-center gap-2`}>
                        <BookOpen className="w-4 h-4" />
                        질문
                      </h4>
                      <p className={`${fontClasses.text} text-purple-700 dark:text-purple-400`}>{result.question}</p>
                    </div>
                    <div className="p-4 bg-pink-50 dark:bg-pink-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-pink-800 dark:text-pink-300 mb-2 flex items-center gap-2`}>
                        <Sparkles className="w-4 h-4" />
                        전체 메시지
                      </h4>
                      <p className={`${fontClasses.text} text-pink-700 dark:text-pink-400`}>{result.overall_message}</p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 카드 해석 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-indigo-600 dark:text-indigo-400`}>
                      <BookOpen className="w-5 h-5" />
                      카드 해석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {result.cards.map((card, index) => (
                      <motion.div
                        key={index}
                        initial={{ x: -20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.4 + index * 0.1 }}
                        className="p-4 bg-indigo-50 dark:bg-indigo-900/30 rounded-lg space-y-2"
                      >
                        <h4 className={`${fontClasses.text} font-medium text-indigo-800 dark:text-indigo-300 flex items-center gap-2`}>
                          {card.position} - {card.card_name} {card.is_reversed ? '(역방향)' : '(정방향)'}
                        </h4>
                        <p className={`${fontClasses.text} text-indigo-700 dark:text-indigo-400`}>{card.interpretation}</p>
                      </motion.div>
                    ))}
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
                  className={`w-full border-purple-300 dark:border-purple-700 text-purple-600 dark:text-purple-400 hover:bg-purple-50 dark:hover:bg-purple-900/30 py-3 ${fontClasses.text}`}
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