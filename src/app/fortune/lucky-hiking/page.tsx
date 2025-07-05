"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Textarea } from "@/components/ui/textarea";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { FortuneResult } from "@/lib/schemas";
import { callGPTFortuneAPI, validateUserInput, FORTUNE_REQUIRED_FIELDS, FortuneServiceError } from "@/lib/fortune-utils";
import { FortuneErrorBoundary } from "@/components/FortuneErrorBoundary";
import { 
  Mountain, 
  Star, 
  ArrowRight,
  Shuffle,
  Users,
  Crown,
  Clock,
  BarChart3,
  Activity,
  Shield,
  CloudRain,
  Compass,
  TreePine,
  RotateCcw,
  CheckCircle,
  ArrowLeft,
  MapPin,
  Sunrise
} from "lucide-react";
import { 
  getYearOptions, 
  getMonthOptions, 
  getDayOptions, 
  formatKoreanDate,
  koreanToIsoDate,
  TIME_PERIODS
} from "@/lib/utils";

interface HikingInfo {
  name: string;
  birthYear: string;
  birthMonth: string;
  birthDay: string;
  birthTimePeriod: string;
  hiking_level: string;
  current_goal: string;
}

interface HikingFortune {
  overall_luck: number;
  summit_luck: number;
  weather_luck: number;
  safety_luck: number;
  endurance_luck: number;
  lucky_trail: string;
  lucky_mountain: string;
  lucky_hiking_time: string;
  lucky_weather: string;
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

const hikingLevels = [
  "초급 (1-3시간)", "중급 (3-6시간)", "고급 (6-12시간)", 
  "전문가 (12시간 이상)", "암벽등반", "빙벽등반"
];

// 하드코딩된 배열 제거됨 - GPT API에서 데이터 제공

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 dark:text-green-400 bg-green-50 dark:bg-green-900/30";
  if (score >= 70) return "text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30";
  if (score >= 55) return "text-orange-600 dark:text-orange-400 bg-orange-50 dark:bg-orange-900/30";
  return "text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/30";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "완등 확실";
  if (score >= 70) return "순조로운 산행";
  if (score >= 55) return "보통 산행";
  return "조심스런 산행";
};

export default function LuckyHikingPage() {
  const [step, setStep] = useState<'form' | 'result'>('form');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [isGenerating, setIsGenerating] = useState(false);
  const [formData, setFormData] = useState<HikingInfo>({
    name: '',
    birthYear: '',
    birthMonth: '',
    birthDay: '',
    birthTimePeriod: '',
    hiking_level: '',
    current_goal: ''
  });
  const [result, setResult] = useState<HikingFortune | null>(null);
  const [error, setError] = useState<Error | null>(null);
  
  // 최근 본 운세 추가를 위한 hook
  useFortuneStream();
  
  // 데일리 운세 관리를 위한 hook
  const {
    todayFortune,
    isLoading: isDailyLoading,
    isGenerating: isDailyGenerating,
    hasTodayFortune,
    saveFortune,
    regenerateFortune,
    canRegenerate
  } = useDailyFortune({ fortuneType: 'lucky-hiking' });

  // 기존 운세가 있으면 자동으로 복원
  useEffect(() => {
    if (hasTodayFortune && todayFortune && step === 'form') {
      const savedData = todayFortune.fortune_data as any;
      const metadata = savedData.metadata || {};
      
      // 저장된 폼 데이터 복원
      setFormData({
        name: savedData.user_info?.name || '',
        birthYear: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[0] : '',
        birthMonth: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[1] : '',
        birthDay: savedData.user_info?.birth_date ? savedData.user_info.birth_date.split('-')[2] : '',
        birthTimePeriod: metadata.birth_time_period || '',
        hiking_level: metadata.hiking_level || '',
        current_goal: metadata.current_goal || ''
      });
      
      // 운세 결과 복원
      if (savedData.fortune_scores) {
        // 운세 데이터가 불완전하면 에러 발생
        if (!savedData.fortune_scores.overall_luck || !savedData.fortune_scores.summit_luck || 
            !savedData.fortune_scores.weather_luck || !savedData.fortune_scores.safety_luck || 
            !savedData.fortune_scores.endurance_luck || !savedData.lucky_items?.lucky_trail || 
            !savedData.lucky_items?.lucky_mountain || !savedData.lucky_items?.lucky_hiking_time || 
            !savedData.lucky_items?.lucky_weather) {
          throw new FortuneServiceError('lucky-hiking');
        }
        
        const restoredResult: HikingFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          summit_luck: savedData.fortune_scores.summit_luck,
          weather_luck: savedData.fortune_scores.weather_luck,
          safety_luck: savedData.fortune_scores.safety_luck,
          endurance_luck: savedData.fortune_scores.endurance_luck,
          lucky_trail: savedData.lucky_items.lucky_trail,
          lucky_mountain: savedData.lucky_items.lucky_mountain,
          lucky_hiking_time: savedData.lucky_items.lucky_hiking_time,
          lucky_weather: savedData.lucky_items.lucky_weather
        };
        setResult(restoredResult);
        setStep('result');
      }
    }
  }, [hasTodayFortune, todayFortune, step]);

  // 폰트 크기 클래스 매핑
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

  const analyzeHikingFortune = async (): Promise<HikingFortune> => {
    // 입력 검증
    if (!validateUserInput(formData, FORTUNE_REQUIRED_FIELDS['lucky-hiking'])) {
      throw new Error('필수 입력 정보가 부족합니다.');
    }

    // GPT API 호출 (현재는 에러를 발생시켜 가짜 데이터 생성 방지)
    const gptResult = await callGPTFortuneAPI({
      type: 'lucky-hiking',
      userInfo: {
        name: formData.name,
        birth_date: `${formData.birthYear}-${formData.birthMonth}-${formData.birthDay}`,
        birth_time_period: formData.birthTimePeriod,
        hiking_level: formData.hiking_level,
        current_goal: formData.current_goal
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

  const handleSubmit = async () => {
    if (!formData.name || !formData.birthYear || !formData.birthMonth || !formData.birthDay) {
      alert('이름과 생년월일을 모두 입력해주세요.');
      return;
    }

    setIsGenerating(true);

    try {
      // 한국식 날짜를 ISO 형식으로 변환
      const birthDate = koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay);
      
      if (hasTodayFortune && todayFortune) {
        // 기존 운세 데이터를 HikingFortune 형식으로 변환
        const savedData = todayFortune.fortune_data as any;
        
        // 운세 데이터가 불완전하면 에러 발생
        if (!savedData.fortune_scores?.overall_luck || !savedData.fortune_scores?.summit_luck || 
            !savedData.fortune_scores?.weather_luck || !savedData.fortune_scores?.safety_luck || 
            !savedData.fortune_scores?.endurance_luck || !savedData.lucky_items?.lucky_trail || 
            !savedData.lucky_items?.lucky_mountain || !savedData.lucky_items?.lucky_hiking_time || 
            !savedData.lucky_items?.lucky_weather) {
          throw new FortuneServiceError('lucky-hiking');
        }
        
        const restoredResult: HikingFortune = {
          overall_luck: savedData.fortune_scores.overall_luck,
          summit_luck: savedData.fortune_scores.summit_luck,
          weather_luck: savedData.fortune_scores.weather_luck,
          safety_luck: savedData.fortune_scores.safety_luck,
          endurance_luck: savedData.fortune_scores.endurance_luck,
          lucky_trail: savedData.lucky_items.lucky_trail,
          lucky_mountain: savedData.lucky_items.lucky_mountain,
          lucky_hiking_time: savedData.lucky_items.lucky_hiking_time,
          lucky_weather: savedData.lucky_items.lucky_weather
        };
        setResult(restoredResult);
      } else {
        const fortuneResult = await analyzeHikingFortune();
        setResult(fortuneResult);
        
        // FortuneResult 형식으로 변환하여 저장
        const fortuneData: FortuneResult = {
          user_info: {
            name: formData.name,
            birth_date: koreanToIsoDate(formData.birthYear, formData.birthMonth, formData.birthDay),
          },
          fortune_scores: {
            overall_luck: fortuneResult.overall_luck,
            summit_luck: fortuneResult.summit_luck,
            weather_luck: fortuneResult.weather_luck,
            safety_luck: fortuneResult.safety_luck,
            endurance_luck: fortuneResult.endurance_luck,
          },
          lucky_items: {
            lucky_trail: fortuneResult.lucky_trail,
            lucky_mountain: fortuneResult.lucky_mountain,
            lucky_hiking_time: fortuneResult.lucky_hiking_time,
            lucky_weather: fortuneResult.lucky_weather,
          },
          metadata: {
            hiking_level: formData.hiking_level,
            current_goal: formData.current_goal,
            birth_time_period: formData.birthTimePeriod,
          }
        };
        
        // 오늘의 운세로 저장
        await saveFortune(fortuneData);
      }
      
      setStep('result');
    } catch (error) {
      console.error('등산 운세 분석 실패:', error);
      
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
      birthTimePeriod: '',
      hiking_level: '',
      current_goal: ''
    });
  };

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-green-50 via-emerald-50 to-teal-50 dark:from-gray-900 dark:via-green-900 dark:to-gray-800 pb-20">
        <AppHeader 
          title="행운의 등산" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <FortuneErrorBoundary 
          error={error} 
          reset={() => setError(null)}
          fallbackMessage="행운의 등산 운세 서비스는 현재 준비 중입니다. 실제 AI 분석을 곧 제공할 예정입니다."
        />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-emerald-50 to-teal-50 dark:from-gray-900 dark:via-green-900 dark:to-gray-800 pb-20">
      <AppHeader 
        title="행운의 등산" 
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
                  className="bg-gradient-to-r from-green-500 to-emerald-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Mountain className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}>행운의 등산</h1>
                <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>등산을 통해 보는 당신의 운세와 안전한 완주의 비결</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-green-200 dark:border-green-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-green-700 dark:text-green-400`}>
                      <Mountain className="w-5 h-5" />
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

                    {/* 시진 선택 (선택사항) */}
                    <div>
                      <div className="flex items-center gap-2 mb-2">
                        <Clock className="w-4 h-4 text-gray-600 dark:text-gray-400" />
                        <Label className={`${fontClasses.text} dark:text-gray-300`}>태어난 시진 (선택사항)</Label>
                      </div>
                      <p className={`${fontClasses.label} text-gray-500 dark:text-gray-400 mb-2`}>
                        더 정확한 등산 운세를 위해 태어난 시간대를 선택해주세요
                      </p>
                      <Select 
                        value={formData.birthTimePeriod} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, birthTimePeriod: value }))}
                      >
                        <SelectTrigger className={`${fontClasses.text} mt-1`}>
                          <SelectValue placeholder="시진 선택" />
                        </SelectTrigger>
                        <SelectContent>
                          {TIME_PERIODS.map((period) => (
                            <SelectItem key={period.value} value={period.value}>
                              <div className="flex flex-col">
                                <span className="font-medium">{period.label}</span>
                                <span className="text-xs text-gray-500">{period.description}</span>
                              </div>
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    {/* 선택된 생년월일 표시 */}
                    {formData.birthYear && formData.birthMonth && formData.birthDay && (
                      <div className="p-3 bg-green-50 dark:bg-green-900/20 rounded-lg border border-green-200 dark:border-green-700">
                        <p className={`${fontClasses.text} font-medium text-green-800 dark:text-green-300 text-center`}>
                          {formatKoreanDate(formData.birthYear, formData.birthMonth, formData.birthDay)}
                        </p>
                        {formData.birthTimePeriod && (
                          <p className={`${fontClasses.label} text-green-600 dark:text-green-400 text-center mt-1`}>
                            {TIME_PERIODS.find(p => p.value === formData.birthTimePeriod)?.label}
                          </p>
                        )}
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 등산 레벨 */}
              <motion.div variants={itemVariants}>
                <Card className="border-emerald-200 dark:border-emerald-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-emerald-700 dark:text-emerald-400`}>
                      <Mountain className="w-5 h-5" />
                      등산 레벨
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label className={`${fontClasses.text} dark:text-gray-300`}>현재 등산 수준</Label>
                      <RadioGroup 
                        value={formData.hiking_level} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, hiking_level: value }))}
                        className="mt-2 grid grid-cols-1 gap-2"
                      >
                        {hikingLevels.map((level) => (
                          <div key={level} className="flex items-center space-x-2">
                            <RadioGroupItem value={level} id={level} />
                            <Label htmlFor={level} className={`${fontClasses.label} dark:text-gray-300`}>{level}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 목표 */}
              <motion.div variants={itemVariants}>
                <Card className="border-green-200 dark:border-green-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-green-700 dark:text-green-400`}>
                      <Star className="w-5 h-5" />
                      등산 목표
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="current_goal" className={`${fontClasses.text} dark:text-gray-300`}>현재 등산 목표</Label>
                      <Textarea
                        id="current_goal"
                        placeholder="예: 백두대간 완주, 한라산 등반, 암벽등반 도전 등..."
                        value={formData.current_goal}
                        onChange={(e) => setFormData(prev => ({ ...prev, current_goal: e.target.value }))}
                        className={`${fontClasses.text} mt-1 min-h-[60px]`}
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
                  className={`w-full bg-gradient-to-r from-green-500 to-emerald-500 hover:from-green-600 hover:to-emerald-600 text-white py-6 ${fontClasses.title} font-semibold`}
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
                          오늘의 등산 운세 보기
                        </>
                      ) : (
                        <>
                          <Mountain className="w-5 h-5" />
                          등산 운세 분석하기
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
                <Card className="bg-gradient-to-r from-green-500 to-emerald-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className={`flex items-center justify-center gap-2 mb-4`}>
                      <Mountain className="w-6 h-6" />
                      <span className={`${fontClasses.title} font-medium`}>{formData.name}님의 등산 운세</span>
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

              {/* 세부 운세 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-green-600 dark:text-green-400`}>
                      <BarChart3 className="w-5 h-5" />
                      세부 등산 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "완등운", score: result.summit_luck, icon: Mountain, desc: "정상에 도달하는 운" },
                      { label: "날씨운", score: result.weather_luck, icon: CloudRain, desc: "좋은 날씨를 만나는 운" },
                      { label: "안전운", score: result.safety_luck, icon: Shield, desc: "사고 없이 안전한 산행의 운" },
                      { label: "체력운", score: result.endurance_luck, icon: Activity, desc: "체력이 지속되는 운" }
                    ].map((item, index) => (
                      <motion.div
                        key={item.label}
                        initial={{ x: -20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.4 + index * 0.1 }}
                        className="space-y-2"
                      >
                        <div className="flex items-center gap-3">
                          <item.icon className="w-5 h-5 text-gray-600 dark:text-gray-400" />
                          <div className="flex-1">
                            <div className="flex justify-between items-center mb-1">
                              <div>
                                <span className={`${fontClasses.text} font-medium dark:text-gray-200`}>{item.label}</span>
                                <p className={`${fontClasses.label} text-gray-500 dark:text-gray-400`}>{item.desc}</p>
                              </div>
                              <span className={`px-3 py-1 rounded-full ${fontClasses.label} font-medium ${getLuckColor(item.score)}`}>
                                {item.score}점
                              </span>
                            </div>
                            <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                              <motion.div
                                className="bg-green-500 dark:bg-green-400 h-2 rounded-full"
                                initial={{ width: 0 }}
                                animate={{ width: `${item.score}%` }}
                                transition={{ delay: 0.5 + index * 0.1, duration: 0.8 }}
                              />
                            </div>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 행운의 요소들 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-600 dark:text-purple-400`}>
                      <Crown className="w-5 h-5" />
                      행운의 요소들
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-4 bg-purple-50 dark:bg-purple-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-purple-800 dark:text-purple-300 mb-2 flex items-center gap-2`}>
                          <Compass className="w-4 h-4" />
                          행운의 등산로
                        </h4>
                        <p className={`${fontClasses.title} font-semibold text-purple-700 dark:text-purple-400`}>{result.lucky_trail}</p>
                      </div>
                      <div className="p-4 bg-indigo-50 dark:bg-indigo-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-indigo-800 dark:text-indigo-300 mb-2 flex items-center gap-2`}>
                          <Mountain className="w-4 h-4" />
                          행운의 산
                        </h4>
                        <p className={`${fontClasses.title} font-semibold text-indigo-700 dark:text-indigo-400`}>{result.lucky_mountain}</p>
                      </div>
                      <div className="p-4 bg-teal-50 dark:bg-teal-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-teal-800 dark:text-teal-300 mb-2 flex items-center gap-2`}>
                          <Clock className="w-4 h-4" />
                          행운의 출발 시간
                        </h4>
                        <p className={`${fontClasses.title} font-semibold text-teal-700 dark:text-teal-400`}>{result.lucky_hiking_time}</p>
                      </div>
                      <div className="p-4 bg-emerald-50 dark:bg-emerald-900/30 rounded-lg">
                        <h4 className={`${fontClasses.text} font-medium text-emerald-800 dark:text-emerald-300 mb-2 flex items-center gap-2`}>
                          <CloudRain className="w-4 h-4" />
                          행운의 날씨
                        </h4>
                        <p className={`${fontClasses.title} font-semibold text-emerald-700 dark:text-emerald-400`}>{result.lucky_weather}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 및 재생성 버튼 */}
              <motion.div variants={itemVariants} className="pt-4 space-y-3">
                {canRegenerate && (
                  <Button
                    onClick={() => void (async () => {
                      try {
                        await new Promise(resolve => setTimeout(resolve, 3000));
                        const analysisResult = await analyzeHikingFortune();
                        
                        const fortuneResult: FortuneResult = {
                          user_info: {
                            name: formData.name,
                            birth_date: formData.birthYear + '-' + formData.birthMonth + '-' + formData.birthDay,
                          },
                          fortune_scores: {
                            overall_luck: analysisResult.overall_luck,
                            summit_luck: analysisResult.summit_luck,
                            weather_luck: analysisResult.weather_luck,
                            safety_luck: analysisResult.safety_luck,
                            endurance_luck: analysisResult.endurance_luck,
                          },
                          lucky_items: {
                            lucky_trail: analysisResult.lucky_trail,
                            lucky_mountain: analysisResult.lucky_mountain,
                            lucky_hiking_time: analysisResult.lucky_hiking_time,
                            lucky_weather: analysisResult.lucky_weather,
                          },
                          metadata: {
                            hiking_level: formData.hiking_level,
                            current_goal: formData.current_goal,
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
                    })()}
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