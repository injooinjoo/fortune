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
  MapPin
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

// 임시 데이터
const mockLoveData: LoveFortuneData = {
  todayScore: 85,
  weeklyScore: 72,
  monthlyScore: 88,
  summary: "오늘은 새로운 만남의 기회가 열리는 날입니다. 평소보다 적극적인 모습을 보이면 좋은 결과가 있을 것입니다.",
  advice: "진정성 있는 대화를 나누세요. 상대방의 마음을 이해하려는 노력이 관계를 더욱 깊게 만들어줄 것입니다.",
  luckyTime: "오후 3시 ~ 6시",
  luckyPlace: "카페, 공원",
  luckyColor: "#FF69B4",
  compatibility: {
    best: "물병자리",
    good: ["쌍둥이자리", "천칭자리", "사수자리"],
    avoid: "전갈자리"
  },
  predictions: {
    today: "기존 관계에서 새로운 면을 발견하게 될 것입니다. 솔직한 대화가 관계 발전의 열쇠입니다.",
    thisWeek: "주중에 특별한 만남이 있을 수 있습니다. 금요일 저녁이 특히 좋은 시간대입니다.",
    thisMonth: "이달 말까지 중요한 결정을 내리게 될 가능성이 높습니다. 신중하되 과감하게 행동하세요."
  },
  actionItems: [
    "평소 관심 있던 취미 활동 시작하기",
    "친구들과의 모임에 적극 참여하기", 
    "새로운 스타일에 도전해보기",
    "감사 인사 전하기"
  ]
};

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
  const [data] = useState<LoveFortuneData>(mockLoveData);
  const [selectedPeriod, setSelectedPeriod] = useState<'today' | 'thisWeek' | 'thisMonth'>('today');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  return (
    <>
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
          <Card className="bg-gradient-to-br from-pink-50 to-red-50 border-pink-200">
            <CardHeader className="text-center">
              <div className="flex items-center justify-center gap-2 mb-2">
                <Heart className="w-6 h-6 text-pink-600" />
                <CardTitle className="text-xl text-pink-800">오늘의 연애운</CardTitle>
              </div>
              <motion.div
                className="text-4xl font-bold text-pink-600"
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.5, type: "spring", stiffness: 200 }}
              >
                {data.todayScore}점
              </motion.div>
            </CardHeader>
            <CardContent>
              <Progress value={data.todayScore} className="mb-4" />
              <p className="text-center text-pink-700 leading-relaxed">
                {data.summary}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 점수 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5" />
                기간별 연애운
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-3 gap-4">
                <div className="text-center">
                  <div className="text-2xl font-bold text-pink-600">{data.todayScore}</div>
                  <div className="text-sm text-gray-600">오늘</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-600">{data.weeklyScore}</div>
                  <div className="text-sm text-gray-600">이번 주</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-red-600">{data.monthlyScore}</div>
                  <div className="text-sm text-gray-600">이번 달</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 행운의 정보 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Sparkles className="w-5 h-5" />
                행운의 정보
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="flex items-center gap-3">
                  <Calendar className="w-5 h-5 text-blue-600" />
                  <div>
                    <div className="text-sm text-gray-600">행운의 시간</div>
                    <div className="font-medium">{data.luckyTime}</div>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <MapPin className="w-5 h-5 text-green-600" />
                  <div>
                    <div className="text-sm text-gray-600">행운의 장소</div>
                    <div className="font-medium">{data.luckyPlace}</div>
                  </div>
                </div>
              </div>
              <div className="flex items-center gap-3">
                <div className="w-5 h-5 rounded-full border-2 border-gray-300" style={{ backgroundColor: data.luckyColor }} />
                <div>
                  <div className="text-sm text-gray-600">행운의 색상</div>
                  <div className="font-medium">핑크 계열</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 궁합 정보 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="w-5 h-5" />
                오늘의 궁합
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <div className="text-sm text-gray-600 mb-2">최고 궁합</div>
                <Badge variant="default" className="bg-red-100 text-red-700 hover:bg-red-200">
                  {data.compatibility.best}
                </Badge>
              </div>
              <div>
                <div className="text-sm text-gray-600 mb-2">좋은 궁합</div>
                <div className="flex flex-wrap gap-2">
                  {data.compatibility.good.map((sign) => (
                    <Badge key={sign} variant="secondary" className="bg-pink-100 text-pink-700">
                      {sign}
                    </Badge>
                  ))}
                </div>
              </div>
              <div>
                <div className="text-sm text-gray-600 mb-2">주의할 상대</div>
                <Badge variant="outline" className="border-gray-400 text-gray-600">
                  {data.compatibility.avoid}
                </Badge>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 기간별 예측 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
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
                  className="text-sm text-gray-700 leading-relaxed"
                >
                  {data.predictions[selectedPeriod]}
                </motion.div>
              </AnimatePresence>
            </CardContent>
          </Card>
        </motion.div>

        {/* 조언 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-purple-50 to-pink-50 border-purple-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-purple-800">
                <MessageCircle className="w-5 h-5" />
                오늘의 조언
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-purple-700 leading-relaxed">
                {data.advice}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 실천 항목 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Gift className="w-5 h-5" />
                오늘 실천해볼 것들
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {data.actionItems.map((item, index) => (
                  <motion.div
                    key={index}
                    className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg"
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.8 + index * 0.1 }}
                  >
                    <div className="w-6 h-6 bg-pink-100 rounded-full flex items-center justify-center">
                      <span className="text-xs font-medium text-pink-600">{index + 1}</span>
                    </div>
                    <span className="text-sm text-gray-700">{item}</span>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 액션 버튼 */}
        <motion.div 
          variants={itemVariants}
          className="sticky bottom-16 left-0 right-0 bg-background border-t p-4 flex gap-2"
        >
          <Button className="flex-1 bg-pink-600 hover:bg-pink-700">
            <Heart className="w-4 h-4 mr-2" />
            결과 저장하기
          </Button>
          <Button variant="outline" className="flex-1 border-pink-300 text-pink-600 hover:bg-pink-50">
            공유하기
          </Button>
        </motion.div>
      </motion.div>
    </>
  );
} 