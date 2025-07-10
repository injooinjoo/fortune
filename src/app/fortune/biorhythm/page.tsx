"use client";

import { useToast } from '@/hooks/use-toast';
import { logger } from '@/lib/logger';
import { useState, useMemo } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import { 
  Activity, 
  Heart, 
  Brain,
  Zap,
  ArrowRight,
  Calendar,
  TrendingUp,
  TrendingDown,
  Minus,
  Star,
  Target,
  AlertCircle,
  CheckCircle,
  RefreshCw,
  BarChart3,
  LineChart,
  Info
} from "lucide-react";

interface BiorhythmData {
  date: string;
  physical: number;
  emotional: number;
  intellectual: number;
}

interface BiorhythmAnalysis {
  current: BiorhythmData;
  forecast: BiorhythmData[];
  analysis: {
    physical: {
      status: 'high' | 'medium' | 'low' | 'critical';
      description: string;
      advice: string;
    };
    emotional: {
      status: 'high' | 'medium' | 'low' | 'critical';
      description: string;
      advice: string;
    };
    intellectual: {
      status: 'high' | 'medium' | 'low' | 'critical';
      description: string;
      advice: string;
    };
  };
  bestDays: string[];
  cautionDays: string[];
  recommendations: string[];
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

const calculateBiorhythm = (birthDate: Date, targetDate: Date) => {
  const daysDiff = Math.floor((targetDate.getTime() - birthDate.getTime()) / (1000 * 60 * 60 * 24));
  
  return {
    physical: Math.sin((2 * Math.PI * daysDiff) / 23) * 100,
    emotional: Math.sin((2 * Math.PI * daysDiff) / 28) * 100,
    intellectual: Math.sin((2 * Math.PI * daysDiff) / 33) * 100
  };
};

const getStatusInfo = (value: number) => {
  if (value > 70) return { status: 'high' as const, color: 'text-green-600 bg-green-50', icon: CheckCircle };
  if (value > 20) return { status: 'medium' as const, color: 'text-blue-600 bg-blue-50', icon: Info };
  if (value > -20) return { status: 'low' as const, color: 'text-orange-600 bg-orange-50', icon: Minus };
  return { status: 'critical' as const, color: 'text-red-600 bg-red-50', icon: AlertCircle };
};

const getStatusText = (status: 'high' | 'medium' | 'low' | 'critical') => {
  switch (status) {
    case 'high': return '최고';
    case 'medium': return '양호';
    case 'low': return '주의';
    case 'critical': return '위험';
  }
};

const getTrendIcon = (value: number) => {
  if (value > 10) return TrendingUp;
  if (value < -10) return TrendingDown;
  return Minus;
};

// 날짜 포맷팅 함수 추가
const formatKoreanDate = (dateString: string): string => {
  if (!dateString) return '';
  const date = new Date(dateString);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}년 ${month}월 ${day}일`;
};

export default function BiorhythmPage() {
  const { toast } = useToast();
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [birthDate, setBirthDate] = useState('');
  const [targetDate, setTargetDate] = useState(new Date().toISOString().split('T')[0]);
  const [result, setResult] = useState<BiorhythmAnalysis | null>(null);

  const analyzeBiorhythm = (birth: string, target: string): BiorhythmAnalysis => {
    const birthDateTime = new Date(birth);
    const targetDateTime = new Date(target);
    
    const current = calculateBiorhythm(birthDateTime, targetDateTime);
    
    // 7일간의 예측 데이터
    const forecast: BiorhythmData[] = [];
    for (let i = 0; i < 7; i++) {
      const forecastDate = new Date(targetDateTime);
      forecastDate.setDate(forecastDate.getDate() + i);
      const biorhythm = calculateBiorhythm(birthDateTime, forecastDate);
      forecast.push({
        date: forecastDate.toISOString().split('T')[0],
        ...biorhythm
      });
    }

    // 분석 정보
    const physicalStatus = getStatusInfo(current.physical);
    const emotionalStatus = getStatusInfo(current.emotional);
    const intellectualStatus = getStatusInfo(current.intellectual);

    const analysis = {
      physical: {
        status: physicalStatus.status,
        description: getPhysicalDescription(current.physical),
        advice: getPhysicalAdvice(current.physical)
      },
      emotional: {
        status: emotionalStatus.status,
        description: getEmotionalDescription(current.emotional),
        advice: getEmotionalAdvice(current.emotional)
      },
      intellectual: {
        status: intellectualStatus.status,
        description: getIntellectualDescription(current.intellectual),
        advice: getIntellectualAdvice(current.intellectual)
      }
    };

    // 최적의 날과 주의할 날 찾기
    const bestDays: string[] = [];
    const cautionDays: string[] = [];
    
    forecast.forEach(day => {
      const total = day.physical + day.emotional + day.intellectual;
      if (total > 150) {
        bestDays.push(formatDate(day.date));
      } else if (total < -100) {
        cautionDays.push(formatDate(day.date));
      }
    });

    return {
      current: {
        date: target,
        ...current
      },
      forecast,
      analysis,
      bestDays,
      cautionDays,
      recommendations: getRecommendations(current)
    };
  };

  const getPhysicalDescription = (value: number): string => {
    if (value > 70) return "신체 에너지가 최고조에 달했습니다. 활력이 넘치고 체력이 왕성한 시기입니다.";
    if (value > 20) return "신체 컨디션이 양호합니다. 적당한 운동과 활동에 좋은 시기입니다.";
    if (value > -20) return "신체 에너지가 다소 저하된 상태입니다. 무리하지 말고 휴식을 취하세요.";
    return "신체 컨디션이 좋지 않습니다. 충분한 휴식과 건강 관리가 필요합니다.";
  };

  const getEmotionalDescription = (value: number): string => {
    if (value > 70) return "감정적으로 매우 안정되고 긍정적인 상태입니다. 대인관계가 원활한 시기입니다.";
    if (value > 20) return "감정 상태가 양호합니다. 창의적 활동이나 소통에 좋은 때입니다.";
    if (value > -20) return "감정 기복이 있을 수 있습니다. 스트레스 관리에 주의가 필요합니다.";
    return "감정적으로 불안정할 수 있습니다. 마음의 평화를 찾는 시간이 필요합니다.";
  };

  const getIntellectualDescription = (value: number): string => {
    if (value > 70) return "지적 능력이 최고조입니다. 학습, 기획, 분석 업무에 최적의 시기입니다.";
    if (value > 20) return "사고력과 집중력이 좋습니다. 중요한 결정이나 학습에 좋은 때입니다.";
    if (value > -20) return "집중력이 다소 떨어질 수 있습니다. 복잡한 업무는 피하는 것이 좋습니다.";
    return "지적 능력이 저하된 상태입니다. 중요한 판단은 미루고 휴식을 취하세요.";
  };

  const getPhysicalAdvice = (value: number): string => {
    if (value > 70) return "운동이나 신체 활동을 늘리기 좋은 시기입니다. 새로운 운동에 도전해보세요.";
    if (value > 20) return "규칙적인 운동과 건강한 식습관을 유지하세요.";
    if (value > -20) return "가벼운 스트레칭이나 산책 정도의 운동이 적당합니다.";
    return "충분한 수면과 영양 섭취에 집중하고 무리한 활동은 피하세요.";
  };

  const getEmotionalAdvice = (value: number): string => {
    if (value > 70) return "사람들과의 만남이나 새로운 관계 형성에 좋은 시기입니다.";
    if (value > 20) return "취미 활동이나 여가를 즐기며 긍정적인 마음을 유지하세요.";
    if (value > -20) return "명상이나 음악 감상 등으로 마음의 안정을 찾으세요.";
    return "스트레스 요인을 피하고 가족이나 친구와 대화하며 마음을 달래세요.";
  };

  const getIntellectualAdvice = (value: number): string => {
    if (value > 70) return "중요한 프로젝트나 학습 계획을 세우기 좋은 시기입니다.";
    if (value > 20) return "독서나 새로운 지식 습득에 투자하세요.";
    if (value > -20) return "간단한 업무부터 차근차근 처리하며 집중력을 회복하세요.";
    return "복잡한 사고를 요하는 일은 피하고 단순한 일부터 시작하세요.";
  };

  const getRecommendations = (biorhythm: { physical: number; emotional: number; intellectual: number }): string[] => {
    const recommendations = [];
    
    if (biorhythm.physical > 50) {
      recommendations.push("새로운 운동이나 신체 활동에 도전해보세요");
    } else if (biorhythm.physical < -50) {
      recommendations.push("충분한 휴식과 수면을 취하세요");
    }

    if (biorhythm.emotional > 50) {
      recommendations.push("사람들과의 만남이나 사교 활동을 늘려보세요");
    } else if (biorhythm.emotional < -50) {
      recommendations.push("명상이나 요가로 마음의 평화를 찾으세요");
    }

    if (biorhythm.intellectual > 50) {
      recommendations.push("중요한 결정이나 계획을 세우기 좋은 시기입니다");
    } else if (biorhythm.intellectual < -50) {
      recommendations.push("복잡한 업무보다는 단순한 일에 집중하세요");
    }

    if (recommendations.length === 0) {
      recommendations.push("현재 상태를 유지하며 균형잡힌 생활을 하세요");
    }

    return recommendations;
  };

  const formatDate = (dateString: string): string => {
    const date = new Date(dateString);
    return `${String(date.getFullYear()).padStart(4, '0')}년 ${String(date.getMonth() + 1).padStart(2, '0')}월 ${String(date.getDate()).padStart(2, '0')}일`;
  };

  const handleSubmit = async () => {
    if (!birthDate) {
      toast({
      title: '생년월일을 입력해주세요.',
      variant: "default",
    });
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      const analysisResult = analyzeBiorhythm(birthDate, targetDate);
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      logger.error('분석 중 오류:', error);
      toast({
      title: '분석 중 오류가 발생했습니다. 다시 시도해주세요.',
      variant: "destructive",
    });
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setBirthDate('');
    setTargetDate(new Date().toISOString().split('T')[0]);
  };

  const biorhythmChart = useMemo(() => {
    if (!result) return null;

    return (
      <div className="mt-4">
        <div className="h-64 bg-gray-50 rounded-lg p-4 relative overflow-hidden">
          <svg width="100%" height="100%" viewBox="0 0 400 200" className="overflow-visible">
            {/* 격자 */}
            <defs>
              <pattern id="grid" width="40" height="20" patternUnits="userSpaceOnUse">
                <path d="M 40 0 L 0 0 0 20" fill="none" stroke="#e5e7eb" strokeWidth="1"/>
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#grid)" />
            
            {/* 중앙선 */}
            <line x1="0" y1="100" x2="400" y2="100" stroke="#9ca3af" strokeWidth="2"/>
            
            {/* 바이오리듬 곡선 */}
            {result.forecast.map((_, index) => {
              if (index === 0) return null;
              const x1 = (index - 1) * 57;
              const x2 = index * 57;
              const prev = result.forecast[index - 1];
              const curr = result.forecast[index];
              
              const y1Physical = 100 - (prev.physical * 0.8);
              const y2Physical = 100 - (curr.physical * 0.8);
              const y1Emotional = 100 - (prev.emotional * 0.8);
              const y2Emotional = 100 - (curr.emotional * 0.8);
              const y1Intellectual = 100 - (prev.intellectual * 0.8);
              const y2Intellectual = 100 - (curr.intellectual * 0.8);
              
              return (
                <g key={index}>
                  {/* 신체 리듬 */}
                  <line 
                    x1={x1} y1={y1Physical} x2={x2} y2={y2Physical} 
                    stroke="#ef4444" strokeWidth="3" 
                  />
                  {/* 감성 리듬 */}
                  <line 
                    x1={x1} y1={y1Emotional} x2={x2} y2={y2Emotional} 
                    stroke="#3b82f6" strokeWidth="3" 
                  />
                  {/* 지성 리듬 */}
                  <line 
                    x1={x1} y1={y1Intellectual} x2={x2} y2={y2Intellectual} 
                    stroke="#10b981" strokeWidth="3" 
                  />
                </g>
              );
            })}
            
            {/* 점 표시 */}
            {result.forecast.map((day, index) => {
              const x = index * 57;
              const yPhysical = 100 - (day.physical * 0.8);
              const yEmotional = 100 - (day.emotional * 0.8);
              const yIntellectual = 100 - (day.intellectual * 0.8);
              
              return (
                <g key={index}>
                  <circle cx={x} cy={yPhysical} r="4" fill="#ef4444" />
                  <circle cx={x} cy={yEmotional} r="4" fill="#3b82f6" />
                  <circle cx={x} cy={yIntellectual} r="4" fill="#10b981" />
                </g>
              );
            })}
          </svg>
          
          {/* 범례 */}
          <div className="absolute bottom-2 left-2 flex gap-4 text-xs">
            <div className="flex items-center gap-1">
              <div className="w-3 h-3 bg-red-500 rounded-full"></div>
              <span>신체</span>
            </div>
            <div className="flex items-center gap-1">
              <div className="w-3 h-3 bg-blue-500 rounded-full"></div>
              <span>감성</span>
            </div>
            <div className="flex items-center gap-1">
              <div className="w-3 h-3 bg-green-500 rounded-full"></div>
              <span>지성</span>
            </div>
          </div>
        </div>
      </div>
    );
  }, [result]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-indigo-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 pb-20">
      <AppHeader title="바이오리듬" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-4"
      >
        {step === 'input' && (
          <motion.div className="space-y-6">
            {/* 헤더 */}
            <motion.div variants={itemVariants} className="text-center">
              <motion.div
                className="inline-flex items-center justify-center w-16 h-16 bg-gradient-to-r from-blue-500 to-indigo-600 rounded-full mb-4"
                animate={{ rotate: 360 }}
                transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
              >
                <Activity className="w-8 h-8 text-white" />
              </motion.div>
              <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
                바이오리듬 분석
              </h1>
              <p className="text-gray-600 dark:text-gray-400">
                신체, 감정, 지적 리듬을 분석하여 최적의 컨디션을 확인해보세요
              </p>
            </motion.div>

            {/* 입력 폼 */}
            <motion.div variants={itemVariants}>
              <Card className="border-blue-200 dark:border-blue-700 dark:bg-gray-800">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-blue-700 dark:text-blue-400">
                    <Calendar className="w-5 h-5" />
                    정보 입력
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-6">
                  <KoreanDatePicker
                    value={birthDate}
                    onChange={setBirthDate}
                    label="생년월일"
                    placeholder="태어난 날짜를 선택해주세요"
                    required={true}
                  />
                  
                  <KoreanDatePicker
                    value={targetDate}
                    onChange={setTargetDate}
                    label="분석할 날짜"
                    placeholder="분석하고 싶은 날짜를 선택해주세요"
                    required={true}
                  />
                  
                  {/* 분석 설명 */}
                  <motion.div
                    className="p-4 bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-xl border border-blue-200 dark:border-blue-700"
                    whileHover={{ scale: 1.02 }}
                  >
                    <div className="flex items-start gap-3">
                      <div className="flex-shrink-0 w-8 h-8 bg-blue-100 dark:bg-blue-800 rounded-full flex items-center justify-center">
                        <Brain className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-blue-900 dark:text-blue-100 mb-1">
                          바이오리듬이란?
                        </h3>
                        <p className="text-sm text-blue-700 dark:text-blue-300 leading-relaxed">
                          생체 리듬의 주기적 변화를 분석하여 신체(23일), 감정(28일), 지적(33일) 상태를 예측하는 이론입니다.
                        </p>
                      </div>
                    </div>
                  </motion.div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 분석 버튼 */}
            <motion.div variants={itemVariants}>
              <motion.div
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
              >
                <Button
                  onClick={handleSubmit}
                  disabled={!birthDate || loading}
                  className="w-full py-4 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-semibold rounded-xl shadow-lg transition-all duration-200"
                >
                  {loading ? (
                    <div className="flex items-center gap-2">
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 1, repeat: Infinity }}
                      >
                        <Activity className="w-5 h-5" />
                      </motion.div>
                      분석 중...
                    </div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Zap className="w-5 h-5" />
                      바이오리듬 분석하기
                    </div>
                  )}
                </Button>
              </motion.div>
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
            {/* 현재 바이오리듬 */}
            <motion.div variants={itemVariants}>
              <Card className="bg-gradient-to-r from-cyan-500 to-blue-500 text-white">
                <CardContent className="text-center py-8">
                  <div className="flex items-center justify-center gap-2 mb-4">
                    <Activity className="w-6 h-6" />
                    <span className="text-xl font-medium">
                      {formatKoreanDate(result.current.date)} 바이오리듬
                    </span>
                  </div>
                  <div className="grid grid-cols-3 gap-4 mt-6">
                    <div>
                      <Heart className="w-6 h-6 mx-auto mb-2" />
                      <p className="text-sm opacity-90">신체</p>
                      <p className="text-2xl font-bold">{Math.round(result.current.physical)}%</p>
                    </div>
                    <div>
                      <Star className="w-6 h-6 mx-auto mb-2" />
                      <p className="text-sm opacity-90">감성</p>
                      <p className="text-2xl font-bold">{Math.round(result.current.emotional)}%</p>
                    </div>
                    <div>
                      <Brain className="w-6 h-6 mx-auto mb-2" />
                      <p className="text-sm opacity-90">지성</p>
                      <p className="text-2xl font-bold">{Math.round(result.current.intellectual)}%</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 바이오리듬 차트 */}
            <motion.div variants={itemVariants}>
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-blue-600">
                    <LineChart className="w-5 h-5" />
                    7일간 바이오리듬 변화
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  {biorhythmChart}
                  <div className="mt-4 grid grid-cols-7 gap-1 text-xs text-center">
                    {result.forecast.map((day, index) => (
                      <div key={index} className="p-1">
                        {formatKoreanDate(day.date)}
                      </div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 상세 분석 */}
            <motion.div variants={itemVariants}>
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-green-600">
                    <Target className="w-5 h-5" />
                    상세 분석
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid gap-4">
                    {/* 신체 리듬 */}
                    <div className="p-4 bg-red-50 rounded-lg">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-red-800 flex items-center gap-2">
                          <Heart className="w-4 h-4" />
                          신체 리듬
                        </h4>
                        <div className="flex items-center gap-2">
                          <Badge className={getStatusInfo(result.current.physical).color}>
                            {getStatusText(result.analysis.physical.status)}
                          </Badge>
                          {(() => {
                            const TrendIcon = getTrendIcon(result.current.physical);
                            return <TrendIcon className="w-4 h-4 text-red-600" />;
                          })()}
                        </div>
                      </div>
                      <p className="text-red-700 text-sm mb-2">{result.analysis.physical.description}</p>
                      <p className="text-red-600 text-xs font-medium">조언: {result.analysis.physical.advice}</p>
                    </div>

                    {/* 감성 리듬 */}
                    <div className="p-4 bg-blue-50 rounded-lg">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-blue-800 flex items-center gap-2">
                          <Star className="w-4 h-4" />
                          감성 리듬
                        </h4>
                        <div className="flex items-center gap-2">
                          <Badge className={getStatusInfo(result.current.emotional).color}>
                            {getStatusText(result.analysis.emotional.status)}
                          </Badge>
                          {(() => {
                            const TrendIcon = getTrendIcon(result.current.emotional);
                            return <TrendIcon className="w-4 h-4 text-blue-600" />;
                          })()}
                        </div>
                      </div>
                      <p className="text-blue-700 text-sm mb-2">{result.analysis.emotional.description}</p>
                      <p className="text-blue-600 text-xs font-medium">조언: {result.analysis.emotional.advice}</p>
                    </div>

                    {/* 지성 리듬 */}
                    <div className="p-4 bg-green-50 rounded-lg">
                      <div className="flex items-center justify-between mb-2">
                        <h4 className="font-medium text-green-800 flex items-center gap-2">
                          <Brain className="w-4 h-4" />
                          지성 리듬
                        </h4>
                        <div className="flex items-center gap-2">
                          <Badge className={getStatusInfo(result.current.intellectual).color}>
                            {getStatusText(result.analysis.intellectual.status)}
                          </Badge>
                          {(() => {
                            const TrendIcon = getTrendIcon(result.current.intellectual);
                            return <TrendIcon className="w-4 h-4 text-green-600" />;
                          })()}
                        </div>
                      </div>
                      <p className="text-green-700 text-sm mb-2">{result.analysis.intellectual.description}</p>
                      <p className="text-green-600 text-xs font-medium">조언: {result.analysis.intellectual.advice}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 최적의 날과 주의할 날 */}
            <motion.div variants={itemVariants}>
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-purple-600">
                    <Calendar className="w-5 h-5" />
                    주요 일정 가이드
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {result.bestDays.length > 0 && (
                    <div className="p-4 bg-green-50 rounded-lg">
                      <h4 className="font-medium text-green-800 mb-2 flex items-center gap-2">
                        <CheckCircle className="w-4 h-4" />
                        최적의 날
                      </h4>
                      <div className="flex flex-wrap gap-2">
                        {result.bestDays.map((day, index) => (
                          <Badge key={index} variant="outline" className="text-green-700 border-green-300">
                            {day}
                          </Badge>
                        ))}
                      </div>
                      <p className="text-green-600 text-xs mt-2">중요한 일정이나 새로운 도전에 좋은 시기입니다.</p>
                    </div>
                  )}
                  
                  {result.cautionDays.length > 0 && (
                    <div className="p-4 bg-amber-50 rounded-lg">
                      <h4 className="font-medium text-amber-800 mb-2 flex items-center gap-2">
                        <AlertCircle className="w-4 h-4" />
                        주의할 날
                      </h4>
                      <div className="flex flex-wrap gap-2">
                        {result.cautionDays.map((day, index) => (
                          <Badge key={index} variant="outline" className="text-amber-700 border-amber-300">
                            {day}
                          </Badge>
                        ))}
                      </div>
                      <p className="text-amber-600 text-xs mt-2">휴식을 취하고 무리한 일정은 피하는 것이 좋습니다.</p>
                    </div>
                  )}
                </CardContent>
              </Card>
            </motion.div>

            {/* 추천사항 */}
            <motion.div variants={itemVariants}>
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-indigo-600">
                    <Zap className="w-5 h-5" />
                    맞춤 추천사항
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {result.recommendations.map((recommendation, index) => (
                      <motion.div
                        key={index}
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.6 + index * 0.1 }}
                        className="flex items-start gap-2"
                      >
                        <Star className="w-4 h-4 text-indigo-500 mt-0.5 flex-shrink-0" />
                        <p className="text-gray-700">{recommendation}</p>
                      </motion.div>
                    ))}
                  </div>
                </CardContent>
              </Card>
            </motion.div>

            {/* 다시 분석하기 버튼 */}
            <motion.div variants={itemVariants} className="pt-4">
              <Button
                onClick={handleReset}
                variant="outline"
                className="w-full border-cyan-300 text-cyan-600 hover:bg-cyan-50 py-3"
              >
                <ArrowRight className="w-4 h-4 mr-2" />
                다른 날짜 분석하기
              </Button>
            </motion.div>
          </motion.div>
        )}
      </motion.div>
    </div>
  );
}