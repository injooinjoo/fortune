"use client";

import { logger } from '@/lib/logger';
import React, { useState, useCallback, useEffect } from "react";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import {
  Clock,
  Star,
  Heart,
  Briefcase,
  Coins,
  HeartPulse,
  Sun,
  Moon,
  Sunrise,
  Sunset,
  Loader2,
  RefreshCw,
  User,
  Calendar,
  Sparkles,
  TrendingUp,
  TrendingDown,
  Minus,
  Activity,
  Coffee,
  Home
} from "lucide-react";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import toast from "react-hot-toast";

interface HourlyFortuneForm {
  name: string;
  birth_date: string;
  mbti?: string;
  zodiac?: string;
}

interface HourlyFortuneResult {
  hourly: {
    date: string;
    hours: Array<{
      hour: number;
      period: string;
      overall_luck: number;
      love_fortune: number;
      work_fortune: number;
      health_fortune: number;
      money_fortune: number;
      fortune_text: string;
      recommendations: string[];
      warnings: string[];
      best_activities: string[];
      energy_level: number;
      favorable_time: boolean;
    }>;
    best_hours: number[];
    caution_hours: number[];
    daily_peak: number;
    daily_summary: string;
  };
}

// 애니메이션 variants
const containerVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1, transition: { staggerChildren: 0.05 } }
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 }
};

const getTimeIcon = (hour: number) => {
  if (hour >= 6 && hour < 12) return Sunrise;
  if (hour >= 12 && hour < 18) return Sun;
  if (hour >= 18 && hour < 24) return Sunset;
  return Moon;
};

const getTimePeriod = (hour: number) => {
  if (hour >= 6 && hour < 12) return { name: "오전", color: "yellow", bg: "from-yellow-50 to-amber-50" };
  if (hour >= 12 && hour < 18) return { name: "오후", color: "orange", bg: "from-orange-50 to-red-50" };
  if (hour >= 18 && hour < 24) return { name: "저녁", color: "purple", bg: "from-purple-50 to-pink-50" };
  return { name: "새벽", color: "indigo", bg: "from-indigo-50 to-blue-50" };
};

const getLuckColor = (score: number) => {
  if (score >= 80) return "text-green-600 bg-green-50 border-green-200";
  if (score >= 60) return "text-blue-600 bg-blue-50 border-blue-200";
  if (score >= 40) return "text-orange-600 bg-orange-50 border-orange-200";
  return "text-red-600 bg-red-50 border-red-200";
};

const getLuckText = (score: number) => {
  if (score >= 80) return "매우 좋음";
  if (score >= 60) return "좋음";
  if (score >= 40) return "보통";
  return "주의";
};

const getLuckIcon = (score: number) => {
  if (score >= 60) return TrendingUp;
  if (score >= 40) return Minus;
  return TrendingDown;
};

export default function HourlyFortunePage() {
  const [fontSize, setFontSize] = useState<'small'|'medium'|'large'>('medium');
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [result, setResult] = useState<HourlyFortuneResult | null>(null);
  const [selectedHour, setSelectedHour] = useState<number | null>(null);
  const [currentHour, setCurrentHour] = useState(0);

  // React Hook Form 설정
  const { register, handleSubmit, setValue, watch, formState: { errors } } = useForm<HourlyFortuneForm>({
    defaultValues: {
      name: '',
      birth_date: '',
      mbti: '',
      zodiac: ''
    }
  });

  // 현재 시간 설정
  useEffect(() => {
    const now = new Date();
    setCurrentHour(now.getHours());
    setSelectedHour(now.getHours());
  }, []);

  // 운세 스트림 훅 사용
  const { generateFortune, isGenerating } = useFortuneStream();

  // 폼 제출 처리
  const onSubmit = useCallback(async (data: HourlyFortuneForm) => {
    if (!data.name.trim() || !data.birth_date) {
      toast.error('이름과 생년월일을 입력해주세요.');
      return;
    }

    const loadingToast = toast.loading('24시간 운세를 분석하고 있습니다...');

    try {
      const requestData = {
        category: 'hourly',
        userInfo: {
          name: data.name.trim(),
          birthDate: data.birth_date,
          mbti: data.mbti || '미입력',
          zodiac: data.zodiac || '미입력'
        },
        packageType: 'single' as const
      };

      const fortuneResult = await generateFortune(requestData);
      
      if (fortuneResult.hourly) {
        setResult(fortuneResult as HourlyFortuneResult);
        setStep('result');
        toast.success('24시간 운세 분석이 완료되었습니다!', { id: loadingToast });
      } else {
        throw new Error('운세 데이터를 받지 못했습니다.');
      }
    } catch (error) {
      logger.error('운세 생성 오류:', error);
      toast.error('운세 분석 중 오류가 발생했습니다. 다시 시도해주세요.', { id: loadingToast });
    }
  }, [generateFortune]);

  // 다시하기 함수
  const handleReset = useCallback(() => {
    setStep('input');
    setResult(null);
    setSelectedHour(currentHour);
  }, [currentHour]);

  // 새로고침 함수  
  const handleRefresh = useCallback(async () => {
    const formData = watch();
    await onSubmit(formData);
  }, [onSubmit, watch]);

  // 시간 포맷 함수
  const formatHour = (hour: number) => {
    const ampm = hour < 12 ? '오전' : '오후';
    const displayHour = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour;
    return `${ampm} ${displayHour}시`;
  };

  return (
    <div className="min-h-screen pb-32 px-4 space-y-6 bg-gradient-to-br from-gray-50 to-slate-50 dark:from-gray-900 dark:to-gray-800">
      <AppHeader title="시간별 운세" onFontSizeChange={setFontSize} currentFontSize={fontSize} />
      
      <motion.div
        className="max-w-6xl mx-auto"
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
                  <div className="p-3 bg-gradient-to-r from-gray-500 to-slate-500 rounded-full">
                    <Clock className="w-8 h-8 text-white" />
                  </div>
                  <h1 className="text-4xl font-bold bg-gradient-to-r from-gray-600 to-slate-600 bg-clip-text text-transparent">
                    시간별 운세
                  </h1>
                </div>
                <p className="text-lg text-gray-600 dark:text-gray-400 mb-6">
                  오늘 24시간 동안의 당신만의 운세를 시간대별로 확인해보세요
                </p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="shadow-lg border-0 bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm">
                  <CardHeader className="text-center">
                    <CardTitle className="text-2xl text-gray-800 dark:text-gray-200 flex items-center justify-center gap-2">
                      <Sparkles className="w-6 h-6 text-gray-500" />
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
                              className="pl-10 border-gray-200 dark:border-gray-600 focus:border-gray-400 dark:focus:border-gray-500"
                            />
                          </div>
                          {errors.name && (
                            <p className="text-red-500 text-sm">{errors.name.message}</p>
                          )}
                        </div>

                        <div className="space-y-2">
                          <KoreanDatePicker
                            label="생년월일"
                            value={watch("birth_date")}
                            onChange={(date) => setValue("birth_date", date)}
                            placeholder="생년월일을 선택하세요"
                            required
                          />
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
                            <SelectTrigger className="border-gray-200 dark:border-gray-600 focus:border-gray-400">
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
                            <SelectTrigger className="border-gray-200 dark:border-gray-600 focus:border-gray-400">
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
                        className="w-full bg-gradient-to-r from-gray-500 to-slate-500 hover:from-gray-600 hover:to-slate-600 text-white py-3 text-lg font-medium shadow-lg"
                      >
                        {isGenerating ? (
                          <div className="flex items-center gap-2">
                            <Loader2 className="w-5 h-5 animate-spin" />
                            24시간 운세 분석 중...
                          </div>
                        ) : (
                          <div className="flex items-center gap-2">
                            <Clock className="w-5 h-5" />
                            시간별 운세 보기
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
                  <Clock className="w-6 h-6 text-gray-600" />
                  <h2 className="text-2xl font-bold text-gray-800 dark:text-gray-200">
                    {result.hourly.date} 시간별 운세
                  </h2>
                </div>
                <p className="text-gray-600 dark:text-gray-400">
                  현재 시간: {formatHour(currentHour)} - {result.hourly.daily_summary}
                </p>
              </motion.div>

              {/* 일일 요약 */}
              <motion.div variants={itemVariants}>
                <Card className="border-gray-200 dark:border-gray-700 bg-gradient-to-br from-gray-50 to-slate-50 dark:from-gray-800 dark:to-gray-700">
                  <CardContent className="text-center py-6">
                    <div className="text-4xl font-bold text-gray-600 dark:text-gray-400 mb-2">
                      오늘의 피크 타임: {formatHour(result.hourly.daily_peak)}
                    </div>
                    <div className="flex justify-center gap-4 mb-4">
                      <div className="text-center">
                        <div className="text-sm text-gray-500">최고 운세 시간</div>
                        <div className="flex gap-1">
                          {result.hourly.best_hours.map((hour, index) => (
                            <Badge key={index} className="bg-green-100 text-green-800">
                              {formatHour(hour)}
                            </Badge>
                          ))}
                        </div>
                      </div>
                      <div className="text-center">
                        <div className="text-sm text-gray-500">주의 시간</div>
                        <div className="flex gap-1">
                          {result.hourly.caution_hours.map((hour, index) => (
                            <Badge key={index} className="bg-amber-100 text-amber-800">
                              {formatHour(hour)}
                            </Badge>
                          ))}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 24시간 타임라인 */}
              <motion.div variants={itemVariants}>
                <h3 className="text-lg font-semibold mb-4 text-gray-900 dark:text-gray-100">24시간 타임라인</h3>
                <div className="grid grid-cols-6 md:grid-cols-12 gap-2 mb-6">
                  {result.hourly.hours.map((hourData) => {
                    const TimeIcon = getTimeIcon(hourData.hour);
                    const isSelected = selectedHour === hourData.hour;
                    const isCurrent = currentHour === hourData.hour;
                    const period = getTimePeriod(hourData.hour);
                    
                    return (
                      <motion.button
                        key={hourData.hour}
                        onClick={() => setSelectedHour(hourData.hour)}
                        className={`
                          relative p-3 rounded-lg border-2 transition-all text-center
                          ${isSelected 
                            ? 'border-gray-500 bg-gray-100 dark:bg-gray-700' 
                            : 'border-gray-200 hover:border-gray-300 bg-white dark:bg-gray-800'
                          }
                          ${isCurrent ? 'ring-2 ring-blue-400' : ''}
                        `}
                        whileHover={{ scale: 1.05 }}
                        whileTap={{ scale: 0.95 }}
                      >
                        {isCurrent && (
                          <div className="absolute -top-1 -right-1 w-3 h-3 bg-blue-500 rounded-full"></div>
                        )}
                        <TimeIcon className="w-4 h-4 mx-auto mb-1 text-gray-600" />
                        <div className="text-xs font-medium text-gray-700 dark:text-gray-300">
                          {hourData.hour}시
                        </div>
                        <div className={`text-xs px-1 rounded mt-1 ${getLuckColor(hourData.overall_luck)}`}>
                          {hourData.overall_luck}
                        </div>
                      </motion.button>
                    );
                  })}
                </div>
              </motion.div>

              {/* 선택된 시간 상세 정보 */}
              {selectedHour !== null && (
                <motion.div variants={itemVariants}>
                  {(() => {
                    const hourData = result.hourly.hours.find(h => h.hour === selectedHour);
                    if (!hourData) return null;

                    const TimeIcon = getTimeIcon(hourData.hour);
                    const period = getTimePeriod(hourData.hour);
                    const LuckIcon = getLuckIcon(hourData.overall_luck);

                    return (
                      <Card className={`border-gray-200 dark:border-gray-700 bg-gradient-to-br ${period.bg} dark:from-gray-800 dark:to-gray-700`}>
                        <CardHeader>
                          <CardTitle className="flex items-center gap-3">
                            <TimeIcon className="w-6 h-6 text-gray-600" />
                            <span>{formatHour(hourData.hour)} {hourData.period}</span>
                            <div className={`flex items-center gap-1 px-2 py-1 rounded-full text-sm ${getLuckColor(hourData.overall_luck)}`}>
                              <LuckIcon className="w-4 h-4" />
                              {getLuckText(hourData.overall_luck)} ({hourData.overall_luck}점)
                            </div>
                          </CardTitle>
                        </CardHeader>
                        <CardContent className="space-y-6">
                          {/* 운세 설명 */}
                          <div className="text-center">
                            <p className="text-lg text-gray-700 dark:text-gray-300 leading-relaxed">
                              {hourData.fortune_text}
                            </p>
                          </div>

                          {/* 세부 운세 */}
                          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                            {[
                              { icon: Heart, label: "애정운", score: hourData.love_fortune },
                              { icon: Briefcase, label: "직업운", score: hourData.work_fortune },
                              { icon: Coins, label: "금전운", score: hourData.money_fortune },
                              { icon: HeartPulse, label: "건강운", score: hourData.health_fortune }
                            ].map((item) => (
                              <div key={item.label} className="text-center p-3 bg-white/50 dark:bg-gray-800/50 rounded-lg">
                                <item.icon className="w-5 h-5 mx-auto mb-2 text-gray-600" />
                                <div className="text-sm text-gray-600 dark:text-gray-400">{item.label}</div>
                                <div className={`text-lg font-bold ${getLuckColor(item.score).split(' ')[0]}`}>
                                  {item.score}점
                                </div>
                              </div>
                            ))}
                          </div>

                          {/* 추천사항 */}
                          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div className="bg-green-50 dark:bg-green-900/20 rounded-lg p-4">
                              <h4 className="font-semibold text-green-800 dark:text-green-400 mb-2 flex items-center gap-2">
                                <Activity className="w-4 h-4" />
                                추천 활동
                              </h4>
                              <ul className="space-y-1 text-sm text-green-700 dark:text-green-300">
                                {hourData.best_activities.map((activity, index) => (
                                  <li key={index}>• {activity}</li>
                                ))}
                              </ul>
                            </div>
                            
                            <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4">
                              <h4 className="font-semibold text-blue-800 dark:text-blue-400 mb-2 flex items-center gap-2">
                                <Star className="w-4 h-4" />
                                권장사항
                              </h4>
                              <ul className="space-y-1 text-sm text-blue-700 dark:text-blue-300">
                                {hourData.recommendations.map((rec, index) => (
                                  <li key={index}>• {rec}</li>
                                ))}
                              </ul>
                            </div>
                            
                            <div className="bg-amber-50 dark:bg-amber-900/20 rounded-lg p-4">
                              <h4 className="font-semibold text-amber-800 dark:text-amber-400 mb-2 flex items-center gap-2">
                                <Coffee className="w-4 h-4" />
                                주의사항
                              </h4>
                              <ul className="space-y-1 text-sm text-amber-700 dark:text-amber-300">
                                {hourData.warnings.map((warning, index) => (
                                  <li key={index}>• {warning}</li>
                                ))}
                              </ul>
                            </div>
                          </div>
                        </CardContent>
                      </Card>
                    );
                  })()}
                </motion.div>
              )}

              {/* 액션 버튼 */}
              <motion.div variants={itemVariants} className="flex justify-center gap-4 pt-6">
                <Button
                  onClick={handleRefresh}
                  disabled={isGenerating}
                  variant="outline"
                  className="border-gray-300 text-gray-700 hover:bg-gray-50 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-700"
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
                <Button asChild variant="outline" className="border-gray-300 text-gray-700 hover:bg-gray-50 dark:border-gray-600 dark:text-gray-300 dark:hover:bg-gray-700">
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