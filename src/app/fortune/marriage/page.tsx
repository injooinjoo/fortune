"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
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

const mockMarriageData: MarriageFortuneData = {
  todayScore: 88,
  weeklyScore: 82,
  monthlyScore: 91,
  yearlyScore: 85,
  summary: "결혼과 관련된 좋은 소식이나 진전이 있을 수 있는 시기입니다. 가족의 지지와 축복을 받을 수 있습니다.",
  advice: "서두르지 말고 신중하게 계획을 세우세요. 상대방과의 솔직한 대화를 통해 미래에 대한 비전을 공유하는 것이 중요합니다.",
  luckyTime: "오후 4시 ~ 7시",
  luckyPlace: "카페, 레스토랑, 공원",
  luckyColor: "#FFB6C1",
  bestMarriageMonth: ["5월", "6월", "10월", "11월"],
  compatibility: {
    bestAge: "25-30세",
    goodSeasons: ["봄", "가을"],
    idealPartner: ["안정적인 성격", "가족을 중시하는 사람", "책임감 있는 사람"],
    avoid: ["성급한 결정", "경제적 불안정", "가족 반대"]
  },
  timeline: {
    engagement: "이번 년도 하반기가 좋습니다",
    wedding: "내년 봄~가을 사이가 적합합니다",
    honeymoon: "결혼 후 3개월 이내가 좋습니다",
    newHome: "결혼 전 6개월 전부터 준비하세요"
  },
  predictions: {
    today: "결혼과 관련된 좋은 소식을 들을 수 있습니다. 가족이나 지인을 통한 소개가 있을 수 있어요.",
    thisWeek: "파트너와의 관계가 더욱 깊어지는 주입니다. 미래에 대한 구체적인 계획을 세워보세요.",
    thisMonth: "결혼 준비나 약혼과 관련된 중요한 결정을 내리기에 좋은 달입니다.",
    thisYear: "인생의 중요한 전환점이 될 수 있는 해입니다. 진정한 동반자를 만날 가능성이 높습니다."
  },
  preparation: {
    emotional: [
      "결혼에 대한 마음가짐 정리하기",
      "상대방과의 가치관 공유하기",
      "가족 간의 화합 도모하기",
      "스트레스 관리법 익히기"
    ],
    practical: [
      "예식장 및 날짜 예약하기",
      "혼수 및 예물 준비하기",
      "신혼집 마련하기",
      "혼인신고 절차 알아보기"
    ],
    financial: [
      "결혼 자금 계획 세우기",
      "가계부 작성 습관 기르기",
      "보험 가입 검토하기",
      "미래 자녀 교육비 준비하기"
    ]
  },
  warnings: [
    "성급한 결정은 금물입니다",
    "양가 부모님과의 충분한 상의가 필요합니다",
    "경제적 부담을 무리하지 마세요",
    "상대방에게만 의존하지 말고 독립적인 관계를 유지하세요"
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

export default function MarriageFortunePage() {
  const [data] = useState<MarriageFortuneData>(mockMarriageData);
  const [selectedPeriod, setSelectedPeriod] = useState<'today' | 'thisWeek' | 'thisMonth' | 'thisYear'>('today');
  const [selectedPrep, setSelectedPrep] = useState<'emotional' | 'practical' | 'financial'>('emotional');
  const [checkedItems, setCheckedItems] = useState<Record<string, boolean>>({});
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

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
    <>
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
          <Card className="bg-gradient-to-br from-pink-50 to-rose-50 border-pink-200">
            <CardHeader className="text-center">
              <div className="flex items-center justify-center gap-2 mb-2">
                <Gem className="w-6 h-6 text-pink-600" />
                <CardTitle className="text-xl text-pink-800">오늘의 결혼운</CardTitle>
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

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5" />
                기간별 결혼운
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-4 gap-3">
                <div className="text-center">
                  <div className="text-2xl font-bold text-pink-600">{data.todayScore}</div>
                  <div className="text-xs text-gray-600">오늘</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-purple-600">{data.weeklyScore}</div>
                  <div className="text-xs text-gray-600">이번 주</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-red-600">{data.monthlyScore}</div>
                  <div className="text-xs text-gray-600">이번 달</div>
                </div>
                <div className="text-center">
                  <div className="text-2xl font-bold text-rose-600">{data.yearlyScore}</div>
                  <div className="text-xs text-gray-600">올해</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

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
                  <Clock className="w-5 h-5 text-blue-600" />
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
              <div>
                <div className="text-sm text-gray-600 mb-2">결혼하기 좋은 달</div>
                <div className="flex flex-wrap gap-2">
                  {data.bestMarriageMonth.map((month, index) => (
                    <Badge key={index} variant="outline" className="text-pink-700">
                      {month}
                    </Badge>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Heart className="w-5 h-5" />
                이상적인 결혼 조건
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <div className="text-sm text-gray-600 mb-2">적합한 연령대</div>
                <Badge className="bg-pink-100 text-pink-700">
                  {data.compatibility.bestAge}
                </Badge>
              </div>
              <div>
                <div className="text-sm text-gray-600 mb-2">좋은 계절</div>
                <div className="flex flex-wrap gap-2">
                  {data.compatibility.goodSeasons.map((season, index) => (
                    <Badge key={index} variant="outline" className="text-green-700">
                      {season}
                    </Badge>
                  ))}
                </div>
              </div>
              <div>
                <div className="text-sm text-gray-600 mb-2">이상적인 파트너</div>
                <div className="flex flex-wrap gap-2">
                  {data.compatibility.idealPartner.map((trait, index) => (
                    <Badge key={index} className="bg-blue-100 text-blue-700">
                      {trait}
                    </Badge>
                  ))}
                </div>
              </div>
              <div>
                <div className="text-sm text-gray-600 mb-2">피해야 할 것</div>
                <div className="flex flex-wrap gap-2">
                  {data.compatibility.avoid.map((item, index) => (
                    <Badge key={index} className="bg-red-100 text-red-700">
                      {item}
                    </Badge>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
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
                    className="flex items-center gap-4 p-4 rounded-lg bg-gradient-to-r from-white to-gray-50 border"
                  >
                    <div className={`p-2 rounded-full bg-${item.color}-100`}>
                      <item.icon className={`w-5 h-5 text-${item.color}-600`} />
                    </div>
                    <div className="flex-1">
                      <div className="font-medium text-gray-800">{item.phase}</div>
                      <div className="text-sm text-gray-600">{item.timing}</div>
                    </div>
                    {index < timeline.length - 1 && (
                      <ArrowRight className="w-4 h-4 text-gray-400" />
                    )}
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
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
                  className="text-sm text-gray-700 leading-relaxed"
                >
                  {data.predictions[selectedPeriod]}
                </motion.div>
              </AnimatePresence>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
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
                      className="flex items-start gap-3 p-3 bg-gray-50 rounded-lg"
                      initial={{ opacity: 0, x: -20 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: index * 0.1 }}
                    >
                      <div className="w-6 h-6 bg-pink-100 rounded-full flex items-center justify-center">
                        <span className="text-xs font-medium text-pink-600">{index + 1}</span>
                      </div>
                      <span className="text-sm text-gray-700">{item}</span>
                    </motion.div>
                  ))}
                </motion.div>
              </AnimatePresence>
            </CardContent>
          </Card>
        </motion.div>

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

        <motion.div variants={itemVariants}>
          <Card className="bg-amber-50 border-amber-200">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-amber-700">
                <AlertTriangle className="w-5 h-5" />
                주의사항
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                {data.warnings.map((warning, index) => (
                  <div key={index} className="flex items-start gap-2 text-sm text-amber-700">
                    <span className="text-amber-400 mt-1">•</span>
                    <span>{warning}</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </>
  );
} 