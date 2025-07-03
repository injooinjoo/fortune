"use client";

import { useState, useEffect } from "react";
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
import {
  Gem, 
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

interface WorryBeadInfo {
  name: string;
  birthYear: string;
  birthMonth: string;
  birthDay: string;
  worry: string;
}

interface WorryBeadFortune {
  overall_luck: number;
  worry_analysis: string;
  solution_advice: string;
  lucky_elements: string[];
  peace_score: number;
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
  if (score >= 85) return "마음의 평화";
  if (score >= 70) return "긍정적 해결";
  if (score >= 55) return "해결 가능성";
  return "노력 필요";
};

export default function WorryBeadPage() {
  const [step, setStep] = useState<'form' | 'result'>('form');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [isGenerating, setIsGenerating] = useState(false);
  const [formData, setFormData] = useState<WorryBeadInfo>({
    name: '',
    birthYear: '',
    birthMonth: '',
    birthDay: '',
    worry: '',
  });
  const [result, setResult] = useState<WorryBeadFortune | null>(null);
  
  useFortuneStream();
  
  const {
    todayFortune,
    isLoading: isDailyLoading,
    isGenerating: isDailyGenerating,
    hasTodayFortune,
    saveFortune,
    regenerateFortune,
    canRegenerate
  } = useDailyFortune({ fortuneType: 'worry-bead' });

  useEffect(() => {
    if (hasTodayFortune && todayFortune && step === 'form') {
      const savedData = todayFortune.fortune_data as any;
      const metadata = savedData.metadata || {};
      
      setFormData({
        name: savedData.user_info?.name || '',
        birthYear: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[0] : '',
        birthMonth: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[1] : '',
        birthDay: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[2] : '',
        worry: metadata.worry_content || '',
      });
      
      if (savedData.fortune_scores) {
        const restoredResult: WorryBeadFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          worry_analysis: savedData.insights?.worry_analysis || '',
          solution_advice: savedData.insights?.solution_advice || '',
          lucky_elements: savedData.lucky_items?.lucky_elements || [],
          peace_score: savedData.fortune_scores.peace_score || 0,
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

  const analyzeWorryBeadFortune = async (): Promise<WorryBeadFortune> => {
    const baseScore = Math.floor(Math.random() * 25) + 60;
    const luckyElements = ["명상", "산책", "대화", "휴식"];

    return {
      overall_luck: Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 15))),
      worry_analysis: `'${formData.worry.substring(0, 20)}...' 고민에 대한 분석입니다.`, 
      solution_advice: `이 고민은 당신의 성장에 필요한 과정입니다. 다음 조언을 통해 해결책을 찾아보세요.`, 
      lucky_elements: Array.from({ length: 2 }, () => luckyElements[Math.floor(Math.random() * luckyElements.length)]),
      peace_score: Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 10))),
    };
  };

  const yearOptions = getYearOptions();
  const monthOptions = getMonthOptions();
  const dayOptions = getDayOptions(
    formData.birthYear ? parseInt(formData.birthYear) : undefined,
    formData.birthMonth ? parseInt(formData.birthMonth) : undefined
  );

  const handleSubmit = async () => {
    if (!formData.name || !formData.birthYear || !formData.birthMonth || !formData.birthDay || !formData.worry) {
      alert('이름, 생년월일, 고민 내용을 모두 입력해주세요.');
      return;
    }

    setIsGenerating(true);

    try {
      const birthDate = koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay);
      
      if (hasTodayFortune && todayFortune) {
        const savedData = todayFortune.fortune_data as any;
        const restoredResult: WorryBeadFortune = {
          overall_luck: savedData.fortune_scores?.overall_luck || 0,
          worry_analysis: savedData.insights?.worry_analysis || '',
          solution_advice: savedData.insights?.solution_advice || '',
          lucky_elements: savedData.lucky_items?.lucky_elements || [],
          peace_score: savedData.fortune_scores?.peace_score || 0,
        };
        setResult(restoredResult);
      } else {
        const fortuneResult = await analyzeWorryBeadFortune();
        setResult(fortuneResult);
        
        const fortuneData: FortuneResult = {
          user_info: {
            name: formData.name,
            birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
          },
          fortune_scores: {
            overall_luck: fortuneResult.overall_luck,
            peace_score: fortuneResult.peace_score,
          },
          insights: {
            worry_analysis: fortuneResult.worry_analysis,
            solution_advice: fortuneResult.solution_advice,
          },
          lucky_items: {
            lucky_elements: fortuneResult.lucky_elements,
          },
          metadata: {
            worry_content: formData.worry,
          }
        };
        
        await saveFortune(fortuneData);
      }
      
      setStep('result');
    } catch (error) {
      console.error('고민 구슬 분석 실패:', error);
      alert('고민 구슬 분석 중 오류가 발생했습니다. 다시 시도해주세요.');
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
      worry: '',
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-yellow-50 via-orange-50 to-red-50 dark:from-gray-900 dark:via-yellow-900 dark:to-gray-800 pb-20">
      <AppHeader 
        title="고민 구슬" 
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
                  className="bg-gradient-to-r from-yellow-500 to-orange-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Gem className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}>고민 구슬</h1>
                <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>당신의 고민을 입력하면 해결책을 찾아드립니다.</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-yellow-200 dark:border-yellow-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-yellow-700 dark:text-yellow-400`}>
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
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-yellow-500 focus:ring-yellow-500 sm:text-sm`}
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
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-yellow-500 focus:ring-yellow-500 sm:text-sm`}
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
                        className={`${fontClasses.text} mt-1 block w-full rounded-md border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-700 py-2 px-3 shadow-sm focus:border-yellow-500 focus:ring-yellow-500 sm:text-sm`}
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
                      <div className="p-3 bg-yellow-50 dark:bg-yellow-900/20 rounded-lg border border-yellow-200 dark:border-yellow-700">
                        <p className={`${fontClasses.text} font-medium text-yellow-800 dark:text-yellow-300 text-center`}>
                          {formatKoreanDate(formData.birthYear, formData.birthMonth, formData.birthDay)}
                        </p>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 고민 내용 입력 */}
              <motion.div variants={itemVariants}>
                <Card className="border-orange-200 dark:border-orange-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-orange-700 dark:text-orange-400`}>
                      <MessageCircle className="w-5 h-5" />
                      고민 내용 입력
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="worry-content" className={`${fontClasses.text} dark:text-gray-300`}>당신의 고민을 자세히 입력해주세요.</Label>
                      <Textarea
                        id="worry-content"
                        placeholder="예: 직장에서의 인간관계 문제로 스트레스를 받고 있습니다."
                        value={formData.worry}
                        onChange={(e) => setFormData(prev => ({ ...prev, worry: e.target.value }))}
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
                  className={`w-full bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-white py-6 ${fontClasses.title} font-semibold`}
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
                          오늘의 고민 구슬 보기
                        </>
                      ) : (
                        <>
                          <Gem className="w-5 h-5" />
                          고민 구슬 분석하기
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
                <Card className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className={`flex items-center justify-center gap-2 mb-4`}>
                      <Gem className="w-6 h-6" />
                      <span className={`${fontClasses.title} font-medium`}>{formData.name}님의 고민 구슬</span>
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

              {/* 고민 분석 및 해결 조언 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-yellow-600 dark:text-yellow-400`}>
                      <BookOpen className="w-5 h-5" />
                      고민 분석 및 해결 조언
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-yellow-50 dark:bg-yellow-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-yellow-800 dark:text-yellow-300 mb-2 flex items-center gap-2`}>
                        <MessageCircle className="w-4 h-4" />
                        고민 분석
                      </h4>
                      <p className={`${fontClasses.text} text-yellow-700 dark:text-yellow-400`}>{result.worry_analysis}</p>
                    </div>
                    <div className="p-4 bg-orange-50 dark:bg-orange-900/30 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-orange-800 dark:text-orange-300 mb-2 flex items-center gap-2`}>
                        <BookOpen className="w-4 h-4" />
                        해결 조언
                      </h4>
                      <p className={`${fontClasses.text} text-orange-700 dark:text-orange-400`}>{result.solution_advice}</p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 행운 요소 및 평화 점수 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-red-600 dark:text-red-400`}>
                      <Star className="w-5 h-5" />
                      행운 요소 및 평화 점수
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {result.lucky_elements && result.lucky_elements.length > 0 && (
                      <div className="p-4 bg-red-50 dark:bg-red-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-red-800 dark:text-red-300 mb-2 flex items-center gap-2`}>
                          <Star className="w-4 h-4" />
                          행운 요소
                        </h4>
                        <p className={`${fontClasses.title} font-semibold text-red-700 dark:text-red-400`}>
                          {result.lucky_elements.join(', ')}
                        </p>
                      </div>
                    )}
                    <div className="p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
                      <h4 className={`${fontClasses.text} font-medium text-gray-800 dark:text-gray-300 mb-2 flex items-center gap-2`}>
                        <Gem className="w-4 h-4" />
                        마음의 평화 점수
                      </h4>
                      <p className={`${fontClasses.title} font-semibold ${getLuckColor(result.peace_score)}`}>
                        {result.peace_score}점
                      </p>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 및 재생성 버튼 */}
              <motion.div variants={itemVariants} className="pt-4 space-y-3">
                {canRegenerate && (
                  <Button
                    onClick={async () => {
                      try {
                        await new Promise(resolve => setTimeout(resolve, 3000));
                        const analysisResult = await analyzeWorryBeadFortune();
                        
                        const fortuneResult: FortuneResult = {
                          user_info: {
                            name: formData.name,
                            birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
                          },
                          fortune_scores: {
                            overall_luck: analysisResult.overall_luck,
                            peace_score: analysisResult.peace_score,
                          },
                          insights: {
                            worry_analysis: analysisResult.worry_analysis,
                            solution_advice: analysisResult.solution_advice,
                          },
                          lucky_items: {
                            lucky_elements: analysisResult.lucky_elements,
                          },
                          metadata: {
                            worry_content: formData.worry,
                          }
                        };

                        const success = await regenerateFortune(fortuneResult);
                        if (success) {
                          setResult(analysisResult);
                        }
                      } catch (error) {
                        console.error('재생성 중 오류:', error);
                        alert('운세 재생성에 실패했습니다. 다시 시도해주세요.');
                      }
                    }}
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
                  className={`w-full border-yellow-300 dark:border-yellow-700 text-yellow-600 dark:text-yellow-400 hover:bg-yellow-50 dark:hover:bg-yellow-900/30 py-3 ${fontClasses.text}`}
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