"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
import { 
  Heart, 
  Star, 
  Sparkles, 
  TrendingUp, 
  Calendar,
  User,
  MessageCircle,
  Gift,
  Coffee,
  MapPin,
  CheckCircle2
} from "lucide-react";

interface LoveFortuneData {
  todayScore: number;
  weeklyScore: number;
  monthlyScore: number;
  summary: string;
  advice: string;
  luckyTime: string;
  luckyPlace: string;
  luckyColor: string;
  compatibility: {
    best: string;
    good: string[];
    avoid: string;
  };
  predictions: {
    today: string;
    thisWeek: string;
    thisMonth: string;
  };
  actionItems: string[];
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

export default function LoveFortunePage() {
  const [data, setData] = useState<LoveFortuneData | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedPeriod, setSelectedPeriod] = useState<'today' | 'thisWeek' | 'thisMonth'>('today');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  useEffect(() => {
    const fetchLoveFortune = async () => {
      try {
        setLoading(true);
        console.log('연애운 데이터 요청 시작...');
        
        const response = await fetch('/api/fortune/love', {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        });

        if (!response.ok) {
          throw new Error(`운세 요청 실패: ${response.status}`);
        }

        const result = await response.json();
        console.log('연애운 API 응답:', result);
        
        if (!result.success) {
          throw new Error(result.error || '운세 생성에 실패했습니다');
        }

        // API 응답을 LoveFortuneData 형식으로 변환
        const loveData: LoveFortuneData = {
          todayScore: result.data.love?.current_score || 75,
          weeklyScore: result.data.love?.weekly_score || 70,
          monthlyScore: result.data.love?.monthly_score || 80,
          summary: result.data.love?.summary || '연애운이 상승세를 보이고 있습니다.',
          advice: result.data.love?.advice || '진정성 있는 마음으로 상대방에게 다가가세요.',
          luckyTime: result.data.love?.lucky_time || '오후 3시 ~ 6시',
          luckyPlace: result.data.love?.lucky_place || '카페, 공원',
          luckyColor: result.data.love?.lucky_color || '#FF69B4',
          compatibility: {
            best: result.data.love?.compatibility?.best || '물병자리',
            good: result.data.love?.compatibility?.good || ['쌍둥이자리', '천칭자리'],
            avoid: result.data.love?.compatibility?.avoid || '전갈자리'
          },
          predictions: {
            today: result.data.love?.predictions?.today || '좋은 만남의 기회가 있을 것입니다.',
            thisWeek: result.data.love?.predictions?.this_week || '특별한 인연을 만날 수 있습니다.',
            thisMonth: result.data.love?.predictions?.this_month || '중요한 결정을 내리게 될 것입니다.'
          },
          actionItems: result.data.love?.action_items || [
            '적극적인 자세로 임하기',
            '새로운 활동에 참여하기',
            '진솔한 대화 나누기'
          ]
        };

        setData(loveData);
        console.log('연애운 데이터 설정 완료:', loveData);
        
      } catch (err) {
        console.error('연애운 데이터 로딩 실패:', err);
        setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다');
      } finally {
        setLoading(false);
      }
    };

    fetchLoveFortune();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-rose-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
        <AppHeader 
          title="연애운" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center space-y-4">
            <motion.div
              className="w-16 h-16 border-4 border-pink-200 border-t-pink-600 rounded-full mx-auto"
              animate={{ rotate: 360 }}
              transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
            />
            <p className="text-pink-700 dark:text-pink-300">연애운을 분석하고 있습니다...</p>
          </div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-rose-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
        <AppHeader 
          title="연애운" 
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

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
      <AppHeader 
        title="연애운" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div 
        className="pb-32 px-4 space-y-6 pt-4"
        initial="hidden"
        animate="visible"
        variants={containerVariants}
      >
        {/* 오늘의 연애운 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-pink-50 to-red-50 dark:from-pink-900/30 dark:to-red-900/30 border-pink-200 dark:border-pink-700 dark:bg-gray-800/50">
            <CardHeader className="text-center">
              <div className="flex items-center justify-center gap-2 mb-2">
                <Heart className="w-6 h-6 text-pink-600 dark:text-pink-400" />
                <CardTitle className="text-xl text-pink-800 dark:text-pink-200">오늘의 연애운</CardTitle>
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

        {/* 기간별 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <TrendingUp className="w-5 h-5 text-purple-600 dark:text-purple-400" />
                기간별 연애운
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-3 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-pink-600 dark:text-pink-400">{data.todayScore}</div>
                  <div className="text-sm text-gray-600 dark:text-gray-300">오늘</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-600 dark:text-purple-400">{data.weeklyScore}</div>
                  <div className="text-sm text-gray-600 dark:text-gray-300">이번 주</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-red-600 dark:text-red-400">{data.monthlyScore}</div>
                  <div className="text-sm text-gray-600 dark:text-gray-300">이번 달</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 행운의 정보 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <Sparkles className="w-5 h-5 text-yellow-600 dark:text-yellow-400" />
                행운의 정보
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center gap-3">
                  <Calendar className="w-5 h-5 text-blue-600 dark:text-blue-400" />
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
            </CardContent>
          </Card>
        </motion.div>

        {/* 궁합 정보 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <User className="w-5 h-5" />
                오늘의 궁합
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <div className="text-sm text-gray-600 dark:text-gray-300 mb-2">최고 궁합</div>
                <Badge variant="default" className="bg-red-100 text-red-700 hover:bg-red-200 dark:bg-red-900/30 dark:text-red-300 dark:hover:bg-red-900/50">
                  {data.compatibility.best}
                </Badge>
              </div>
              <div>
                <div className="text-sm text-gray-600 dark:text-gray-300 mb-2">좋은 궁합</div>
                <div className="flex flex-wrap gap-2">
                  {data.compatibility.good.map((sign) => (
                    <Badge key={sign} variant="secondary" className="bg-pink-100 text-pink-700 dark:bg-pink-900/30 dark:text-pink-300">
                      {sign}
                    </Badge>
                  ))}
                </div>
              </div>
              <div>
                <div className="text-sm text-gray-600 dark:text-gray-300 mb-2">주의할 상대</div>
                <Badge variant="outline" className="border-gray-400 text-gray-600 dark:border-gray-600 dark:text-gray-300">
                  {data.compatibility.avoid}
                </Badge>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 예측 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <Star className="w-5 h-5" />
                기간별 예측
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex gap-2 mb-4">
                {[
                  { key: 'today', label: '오늘' },
                  { key: 'thisWeek', label: '이번 주' },
                  { key: 'thisMonth', label: '이번 달' }
                ].map((period) => (
                  <Button
                    key={period.key}
                    variant={selectedPeriod === period.key ? "default" : "outline"}
                    size="sm"
                    onClick={() => setSelectedPeriod(period.key as any)}
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

        {/* 조언 */}
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

        {/* 실천 항목 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm border-gray-200 dark:border-gray-700">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                <Gift className="w-5 h-5" />
                오늘 실천해볼 것들
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {data.actionItems.map((item, index) => (
                  <motion.div
                    key={index}
                    className="flex items-center gap-3 p-3 bg-gray-50 dark:bg-gray-700/50 rounded-lg"
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.8 + index * 0.1 }}
                  >
                    <div className="w-6 h-6 bg-pink-100 dark:bg-pink-900/30 rounded-full flex items-center justify-center">
                      <span className="text-xs font-medium text-pink-600 dark:text-pink-400">{index + 1}</span>
                    </div>
                    <span className="text-sm text-gray-700 dark:text-gray-300">{item}</span>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 액션 버튼 */}
        <motion.div 
          variants={itemVariants}
          className="sticky bottom-16 left-0 right-0 bg-background dark:bg-gray-900 border-t dark:border-gray-700 p-4 flex gap-2"
        >
          <Button className="flex-1 bg-pink-600 hover:bg-pink-700 dark:bg-pink-600 dark:hover:bg-pink-700">
            <Heart className="w-4 h-4 mr-2" />
            결과 저장하기
          </Button>
          <Button variant="outline" className="flex-1 border-pink-300 text-pink-600 hover:bg-pink-50 dark:border-pink-600 dark:text-pink-400 dark:hover:bg-pink-900/20">
            공유하기
          </Button>
        </motion.div>
      </motion.div>
    </div>
  );
} 