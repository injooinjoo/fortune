"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
import AdLoadingScreen from "@/components/AdLoadingScreen";
import ProtectedRoute from "@/components/ProtectedRoute";
import { useAuth } from '@/contexts/auth-context';
import {
  Heart,
  TrendingUp,
  Calendar,
  MapPin,
  Clock,
  Star,
  Gift,
  MessageCircle,
  CheckCircle,
  AlertTriangle,
  Sparkles,
  Home,
  DollarSign,
  Gem,
  Palette,
  ArrowRight,
  User
} from "lucide-react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

interface MarriageFortuneData {
  todayScore: number;
  weeklyScore: number;
  monthlyScore: number;
  yearlyScore: number;
  summary: string;
  advice: string;
  luckyTime: string;
  luckyPlace: string;
  luckyColor: string;
  bestMarriageMonth: string[];
  compatibility: {
    bestAge: string;
    goodSeasons: string[];
    idealPartner: string[];
    avoid: string[];
  };
  timeline: {
    engagement: string;
    wedding: string;
    honeymoon: string;
    newHome: string;
  };
  predictions: {
    today: string;
    thisWeek: string;
    thisMonth: string;
    thisYear: string;
  };
  preparation: {
    emotional: string[];
    practical: string[];
    financial: string[];
  };
  warnings: string[];
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

function MarriageFortunePage() {
  const { session } = useAuth();
  const [data, setData] = useState<MarriageFortuneData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedPeriod, setSelectedPeriod] = useState<'today' | 'thisWeek' | 'thisMonth' | 'thisYear'>('today');
  const [selectedPrep, setSelectedPrep] = useState<'emotional' | 'practical' | 'financial'>('emotional');
  const [checkedItems, setCheckedItems] = useState<Record<string, boolean>>({});
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [showLoadingScreen, setShowLoadingScreen] = useState(true);

  const fetchMarriageFortune = async () => {
    try {
      console.log('결혼운 데이터 요청 시작...');
      
      // AuthContext에서 세션 가져오기
      // session은 이미 useAuth()에서 가져왔음
      
      const response = await fetch('/api/fortune/marriage', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...(session?.access_token && {
            'Authorization': `Bearer ${session.access_token}`
          })
        },
      });

      if (!response.ok) {
        throw new Error(`운세 요청 실패: ${response.status}`);
      }

      const result = await response.json();
      console.log('결혼운 API 응답:', result);
      
      if (!result.success) {
        throw new Error(result.error || '결혼운 생성에 실패했습니다');
      }

      // API 응답을 MarriageFortuneData 형식으로 변환
      const marriageData: MarriageFortuneData = {
          todayScore: result.data.current_score || result.data.overall_score || 85,
          weeklyScore: result.data.weekly_score || 80,
          monthlyScore: result.data.monthly_score || 90,
          yearlyScore: result.data.yearly_score || 88,
          summary: result.data.summary || '결혼운이 상승세를 보이고 있습니다.',
          advice: result.data.advice || '신중하게 계획을 세우고 상대방과 소통하세요.',
          luckyTime: result.data.lucky_time || '오후 4시 ~ 7시',
          luckyPlace: result.data.lucky_place || '카페, 레스토랑, 공원',
          luckyColor: result.data.lucky_color || '#FFB6C1',
          bestMarriageMonth: result.data.best_months || ['5월', '6월', '10월'],
          compatibility: {
            bestAge: result.data.compatibility?.best_age || '25-30세',
            goodSeasons: result.data.compatibility?.good_seasons || ['봄', '가을'],
            idealPartner: result.data.compatibility?.ideal_partner || ['안정적인 성격'],
            avoid: result.data.compatibility?.avoid || ['성급한 결정']
          },
          timeline: {
            engagement: result.data.timeline?.engagement || '이번 년도 하반기',
            wedding: result.data.timeline?.wedding || '내년 봄~가을',
            honeymoon: result.data.timeline?.honeymoon || '결혼 후 3개월 이내',
            newHome: result.data.timeline?.new_home || '결혼 전 6개월'
          },
          predictions: {
            today: result.data.predictions?.today || '좋은 소식이 있을 것입니다.',
            thisWeek: result.data.predictions?.this_week || '관계가 깊어질 것입니다.',
            thisMonth: result.data.predictions?.this_month || '중요한 결정의 시기입니다.',
            thisYear: result.data.predictions?.this_year || '인생의 전환점이 될 것입니다.'
          },
          preparation: {
            emotional: result.data.preparation?.emotional || ['마음가짐 정리하기'],
            practical: result.data.preparation?.practical || ['예식장 예약하기'],
            financial: result.data.preparation?.financial || ['결혼 자금 계획하기']
          },
          warnings: result.data.warnings || ['성급한 결정은 금물입니다']
        };

        console.log('결혼운 데이터 설정 완료:', marriageData);
        return marriageData;
        
      } catch (err) {
        console.error('결혼운 데이터 로딩 실패:', err);
        throw err;
      }
    };

  // 광고 로딩 스크린 표시
  if (showLoadingScreen) {
    return (
      <AdLoadingScreen
        fortuneType="marriage"
        fortuneTitle="결혼운"
        fetchData={fetchMarriageFortune}
        onComplete={(fetchedData) => {
          setShowLoadingScreen(false);
          if (fetchedData) {
            setData(fetchedData);
          }
        }}
        onSkip={() => {
          // 프리미엄 페이지로 이동
          window.location.href = '/premium';
        }}
        isPremium={false}
      />
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-pink-50 via-white to-rose-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
        <AppHeader 
          title="결혼운" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center space-y-4 max-w-md mx-auto px-4">
            <Heart className="w-16 h-16 text-red-400 mx-auto" />
            <h2 className="text-xl font-semibold text-gray-900 dark:text-gray-100">운세를 불러올 수 없습니다</h2>
            <p className="text-gray-600 dark:text-gray-400">{error}</p>
            <button 
              onClick={() => window.location.reload()}
              className="px-4 py-2 bg-pink-600 text-white rounded-lg hover:bg-pink-700 transition-colors"
            >
              다시 시도
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (!data) return null;

  const marriageScore = {
    today: data.todayScore,
    week: data.weeklyScore,
    month: data.monthlyScore,
    year: data.yearlyScore
  };

  const luckyInfo = {
    time: data.luckyTime,
    place: data.luckyPlace,
    color: data.luckyColor,
    month: data.bestMarriageMonth.join(", ")
  };

  const marriageConditions = {
    age: data.compatibility.bestAge,
    season: data.compatibility.goodSeasons.join(", "),
    partner: data.compatibility.idealPartner.join(", "),
    compatibility: data.compatibility.avoid.join(", ")
  };

  const timeline = [
    { phase: "약혼", timing: data.timeline.engagement, icon: Heart, color: "pink" },
    { phase: "결혼", timing: data.timeline.wedding, icon: Star, color: "purple" },
    { phase: "신혼여행", timing: data.timeline.honeymoon, icon: Gift, color: "blue" },
    { phase: "신혼집", timing: data.timeline.newHome, icon: CheckCircle, color: "green" }
  ];

  const checklist = {
    mindset: data.preparation.emotional,
    practical: data.preparation.practical,
    financial: data.preparation.financial
  };

  const predictions = {
    today: {
      score: data.todayScore,
      prediction: data.predictions.today,
      advice: data.advice,
      caution: "서두르지 말고 충분히 시간을 가지고 대화하세요."
    },
    thisWeek: {
      score: data.weeklyScore,
      prediction: data.predictions.thisWeek,
      advice: data.advice,
      caution: "예산을 미리 정하고 움직이는 것이 중요합니다."
    },
    thisMonth: {
      score: data.monthlyScore,
      prediction: data.predictions.thisMonth,
      advice: data.advice,
      caution: "격식을 갖추되 자연스럽게 행동하세요."
    },
    thisYear: {
      score: data.yearlyScore,
      prediction: data.predictions.thisYear,
      advice: data.advice,
      caution: "감정적으로 결정하지 말고 신중하게 판단하세요."
    }
  };

  const toggleCheck = (section: string, index: number) => {
    const key = `${section}-${index}`;
    setCheckedItems(prev => ({
      ...prev,
      [key]: !prev[key]
    }));
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
      <AppHeader 
        title="결혼운" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div 
        className="pb-32 px-4 space-y-6 pt-4"
        initial="hidden"
        animate="visible"
        variants={containerVariants}
      >
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-pink-50 to-rose-50 dark:from-pink-900/20 dark:to-rose-900/20 border-pink-200 dark:border-pink-800">
            <CardHeader className="text-center">
              <div className="flex items-center justify-center gap-2 mb-2">
                <Gem className="w-6 h-6 text-pink-600 dark:text-pink-400" />
                <CardTitle className="text-xl text-pink-800 dark:text-pink-200">오늘의 결혼운</CardTitle>
              </div>
              <motion.div
                className="text-4xl font-bold text-pink-600 dark:text-pink-400"
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.5, type: "spring", stiffness: 200 }}
              >
                {data.todayScore}점
              </motion.div>
            </CardHeader>
            <CardContent>
              <Progress value={data.todayScore} className="mb-4" />
              <p className="text-center text-pink-700 dark:text-pink-300 leading-relaxed">
                {data.summary}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <TrendingUp className="w-5 h-5" />
                기간별 결혼운
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-4 gap-3">
                <div className="text-center">
                  <div className="text-2xl font-bold text-pink-600 dark:text-pink-400">{data.todayScore}</div>
                  <div className="text-xs text-gray-600 dark:text-gray-300">오늘</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-600 dark:text-purple-400">{data.weeklyScore}</div>
                  <div className="text-xs text-gray-600 dark:text-gray-300">이번 주</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-red-600 dark:text-red-400">{data.monthlyScore}</div>
                  <div className="text-xs text-gray-600 dark:text-gray-300">이번 달</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-rose-600 dark:text-rose-400">{data.yearlyScore}</div>
                  <div className="text-xs text-gray-600 dark:text-gray-300">올해</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <Sparkles className="w-5 h-5" />
                행운의 정보
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center gap-3">
                  <Clock className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                  <div>
                    <div className="text-sm text-gray-600 dark:text-gray-300">행운의 시간</div>
                    <div className="font-medium text-gray-900 dark:text-gray-100">{data.luckyTime}</div>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <MapPin className="w-5 h-5 text-green-600 dark:text-green-400" />
                  <div>
                    <div className="text-sm text-gray-600 dark:text-gray-300">행운의 장소</div>
                    <div className="font-medium text-gray-900 dark:text-gray-100">{data.luckyPlace}</div>
                  </div>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-5 h-5 rounded-full border-2 border-gray-300 dark:border-gray-600" style={{ backgroundColor: data.luckyColor }} />
                <div>
                  <div className="text-sm text-gray-600 dark:text-gray-300">행운의 색상</div>
                  <div className="font-medium text-gray-900 dark:text-gray-100">핑크 계열</div>
                </div>
              </div>
              <div>
                <div className="text-sm text-gray-600 dark:text-gray-300 mb-2">결혼하기 좋은 달</div>
                <div className="flex flex-wrap gap-2">
                  {data.bestMarriageMonth.map((month, index) => (
                    <Badge key={index} variant="outline" className="text-pink-700 dark:text-pink-300 dark:border-pink-600">
                      {month}
                    </Badge>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <Heart className="w-5 h-5" />
                이상적인 결혼 조건
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <div className="text-sm text-gray-600 dark:text-gray-300 mb-2">적합한 연령대</div>
                <Badge className="bg-pink-100 text-pink-700 dark:bg-pink-900/30 dark:text-pink-300">
                  {data.compatibility.bestAge}
                </Badge>
              </div>
              <div>
                <div className="text-sm text-gray-600 dark:text-gray-300 mb-2">좋은 계절</div>
                <div className="flex flex-wrap gap-2">
                  {data.compatibility.goodSeasons.map((season, index) => (
                    <Badge key={index} variant="outline" className="text-green-700 dark:text-green-300 dark:border-green-600">
                      {season}
                    </Badge>
                  ))}
                </div>
              </div>
              <div>
                <div className="text-sm text-gray-600 dark:text-gray-300 mb-2">이상적인 파트너</div>
                <div className="flex flex-wrap gap-2">
                  {data.compatibility.idealPartner.map((trait, index) => (
                    <Badge key={index} className="bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300">
                      {trait}
                    </Badge>
                  ))}
                </div>
              </div>
              <div>
                <div className="text-sm text-gray-600 dark:text-gray-300 mb-2">피해야 할 것</div>
                <div className="flex flex-wrap gap-2">
                  {data.compatibility.avoid.map((item, index) => (
                    <Badge key={index} className="bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-300">
                      {item}
                    </Badge>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <Calendar className="w-5 h-5" />
                결혼 타임라인 추천
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-3">
                {timeline.map((item, index) => (
                  <motion.div
                    key={item.phase}
                    initial={{ opacity: 0, x: -50 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.5 + index * 0.1 }}
                    className="flex items-center gap-4 p-4 rounded-lg bg-gradient-to-r from-white to-gray-50 dark:from-gray-700/50 dark:to-gray-800/50 border dark:border-gray-600"
                  >
                    <div className={`p-2 rounded-full bg-${item.color}-100 dark:bg-${item.color}-900/30`}>
                      <item.icon className={`w-5 h-5 text-${item.color}-600 dark:text-${item.color}-400`} />
                    </div>
                    <div className="flex-1">
                      <div className="font-medium text-gray-800 dark:text-gray-200">{item.phase}</div>
                      <div className="text-sm text-gray-600 dark:text-gray-300">{item.timing}</div>
                    </div>
                    {index < timeline.length - 1 && (
                      <ArrowRight className="w-4 h-4 text-gray-400 dark:text-gray-500" />
                    )}
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <Star className="w-5 h-5" />
                기간별 예측
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex gap-2 mb-4 overflow-x-auto">
                {[
                  { key: 'today', label: '오늘' },
                  { key: 'thisWeek', label: '이번 주' },
                  { key: 'thisMonth', label: '이번 달' },
                  { key: 'thisYear', label: '올해' }
                ].map((period) => (
                  <Button
                    key={period.key}
                    variant={selectedPeriod === period.key ? "default" : "outline"}
                    size="sm"
                    onClick={() => setSelectedPeriod(period.key as any)}
                    className="whitespace-nowrap"
                  >
                    {period.label}
                  </Button>
                ))}
              </div>
              <AnimatePresence mode="wait">
                <motion.div
                  key={selectedPeriod}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  transition={{ duration: 0.2 }}
                  className="text-sm text-gray-700 dark:text-gray-300 leading-relaxed"
                >
                  {data.predictions[selectedPeriod]}
                </motion.div>
              </AnimatePresence>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <CheckCircle className="w-5 h-5" />
                결혼 준비 체크리스트
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex gap-2 mb-4 overflow-x-auto">
                {[
                  { key: 'emotional', label: '마음가짐', icon: Heart },
                  { key: 'practical', label: '실무준비', icon: CheckCircle },
                  { key: 'financial', label: '재정관리', icon: DollarSign }
                ].map((prep) => (
                  <Button
                    key={prep.key}
                    variant={selectedPrep === prep.key ? "default" : "outline"}
                    size="sm"
                    onClick={() => setSelectedPrep(prep.key as any)}
                    className="whitespace-nowrap flex items-center gap-1"
                  >
                    <prep.icon className="w-3 h-3" />
                    {prep.label}
                  </Button>
                ))}
              </div>
              <AnimatePresence mode="wait">
                <motion.div
                  key={selectedPrep}
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -10 }}
                  transition={{ duration: 0.2 }}
                  className="space-y-3"
                >
                  {data.preparation[selectedPrep].map((item, index) => (
                    <motion.div
                      key={index}
                      className="flex items-start gap-3 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg"
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.1 }}
                    >
                      <div className="w-6 h-6 bg-pink-100 dark:bg-pink-900/30 rounded-full flex items-center justify-center">
                        <span className="text-xs font-medium text-pink-600 dark:text-pink-400">{index + 1}</span>
                      </div>
                      <span className="text-sm text-gray-700 dark:text-gray-300">{item}</span>
                    </motion.div>
                  ))}
                </motion.div>
              </AnimatePresence>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-purple-50 to-pink-50 dark:from-purple-900/20 dark:to-pink-900/20 border-purple-200 dark:border-purple-800">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-purple-800 dark:text-purple-200">
                <MessageCircle className="w-5 h-5" />
                오늘의 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-purple-700 dark:text-purple-300 leading-relaxed">
                {data.advice}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card className="bg-amber-50 dark:bg-amber-900/20 border-amber-200 dark:border-amber-800">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-amber-700 dark:text-amber-300">
                <AlertTriangle className="w-5 h-5" />
                주의사항
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                {data.warnings.map((warning, index) => (
                  <div key={index} className="flex items-start gap-2 text-sm text-amber-700 dark:text-amber-300">
                    <span className="text-amber-400 dark:text-amber-500 mt-1">•</span>
                    <span>{warning}</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
}

export default function MarriageFortunePageWrapper() {
  return (
    <ProtectedRoute>
      <MarriageFortunePage />
    </ProtectedRoute>
  );
} 