"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { 
  Clock, 
  Star, 
  Sparkles,
  ArrowRight,
  Sun,
  Moon,
  Sunrise,
  Sunset,
  Coffee,
  Briefcase,
  Heart,
  Home,
  Activity,
  AlertTriangle,
  TrendingUp,
  TrendingDown,
  Minus,
  Lightbulb,
  Calendar,
  RefreshCw
} from "lucide-react";

interface HourlyFortune {
  hour: number;
  period: string;
  icon: typeof Sun;
  overall_luck: number;
  fortune_text: string;
  love_fortune: number;
  work_fortune: number;
  health_fortune: number;
  money_fortune: number;
  recommendations: string[];
  warnings: string[];
  best_activities: string[];
  color: string;
  gradient: string;
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
  if (score >= 80) return "text-green-600 bg-green-50";
  if (score >= 60) return "text-blue-600 bg-blue-50";
  if (score >= 40) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
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

const generateHourlyFortunes = (): HourlyFortune[] => {
  const periods = [
    { range: [6, 11], name: "오전", icon: Sunrise, color: "yellow", gradient: "from-yellow-50 to-amber-50" },
    { range: [12, 17], name: "오후", icon: Sun, color: "orange", gradient: "from-orange-50 to-red-50" },
    { range: [18, 23], name: "저녁", icon: Sunset, color: "purple", gradient: "from-purple-50 to-pink-50" },
    { range: [0, 5], name: "새벽", icon: Moon, color: "indigo", gradient: "from-indigo-50 to-blue-50" }
  ];

  const fortunes: HourlyFortune[] = [];

  for (let hour = 0; hour < 24; hour++) {
    const period = periods.find(p => 
      (p.range[0] <= p.range[1] && hour >= p.range[0] && hour <= p.range[1]) ||
      (p.range[0] > p.range[1] && (hour >= p.range[0] || hour <= p.range[1]))
    ) || periods[3];

    const baseLuck = Math.floor(Math.random() * 40) + 40; // 40-80 기본 점수
    const variance = Math.floor(Math.random() * 30) - 15; // -15 ~ +15 변동

    const overall_luck = Math.max(20, Math.min(100, baseLuck + variance));
    
    const fortuneTexts = [
      "새로운 기회가 찾아올 수 있는 시간입니다.",
      "인간관계에서 좋은 소식이 들려올 것 같습니다.",
      "창의적인 아이디어가 떠오르기 쉬운 시간대입니다.",
      "재정적인 면에서 긍정적인 변화가 있을 수 있습니다.",
      "건강 관리에 특별히 신경 써야 할 시간입니다.",
      "가족이나 연인과의 시간을 소중히 여기세요.",
      "업무나 학습에 집중하기 좋은 시간대입니다.",
      "휴식과 재충전이 필요한 시간입니다.",
      "사교활동이나 네트워킹에 좋은 시간입니다.",
      "내면의 성찰과 명상에 적합한 시간대입니다."
    ];

    const recommendations = [
      "긍정적인 마음가짐 유지하기",
      "새로운 도전을 시작해보기",
      "소중한 사람과 시간 보내기",
      "건강한 식단과 운동하기",
      "창작 활동이나 취미 즐기기",
      "독서나 학습 시간 갖기",
      "명상이나 요가로 마음 다스리기",
      "자연 속에서 산책하기",
      "감사 인사나 안부 전하기",
      "정리정돈과 계획 세우기"
    ];

    const warnings = [
      "급한 결정은 피하는 것이 좋습니다",
      "감정적인 대화나 논쟁 주의하세요",
      "금전 관리에 신중함이 필요합니다",
      "과로나 스트레스 관리에 주의하세요",
      "교통안전과 안전사고 예방하세요",
      "소문이나 가십에 휘둘리지 마세요",
      "충동구매나 과소비 주의하세요",
      "건강 이상 신호를 무시하지 마세요"
    ];

    const activities = [
      "카페에서 여유로운 시간 보내기",
      "공원이나 산책로 걷기",
      "좋아하는 음악 감상하기",
      "친구나 가족과 전화하기",
      "독서나 글쓰기",
      "요리나 베이킹 도전하기",
      "온라인 강의 수강하기",
      "정리정돈과 청소하기",
      "운동이나 스트레칭",
      "영화나 드라마 감상하기"
    ];

    fortunes.push({
      hour,
      period: period.name,
      icon: period.icon,
      overall_luck,
      fortune_text: fortuneTexts[Math.floor(Math.random() * fortuneTexts.length)],
      love_fortune: Math.max(20, Math.min(100, overall_luck + Math.floor(Math.random() * 20) - 10)),
      work_fortune: Math.max(20, Math.min(100, overall_luck + Math.floor(Math.random() * 20) - 10)),
      health_fortune: Math.max(20, Math.min(100, overall_luck + Math.floor(Math.random() * 20) - 10)),
      money_fortune: Math.max(20, Math.min(100, overall_luck + Math.floor(Math.random() * 20) - 10)),
      recommendations: [
        recommendations[Math.floor(Math.random() * recommendations.length)],
        recommendations[Math.floor(Math.random() * recommendations.length)]
      ].filter((item, index, arr) => arr.indexOf(item) === index),
      warnings: [
        warnings[Math.floor(Math.random() * warnings.length)]
      ],
      best_activities: [
        activities[Math.floor(Math.random() * activities.length)],
        activities[Math.floor(Math.random() * activities.length)],
        activities[Math.floor(Math.random() * activities.length)]
      ].filter((item, index, arr) => arr.indexOf(item) === index),
      color: period.color,
      gradient: period.gradient
    });
  }

  return fortunes;
};

export default function HourlyFortunePage() {
  const [currentHour, setCurrentHour] = useState(0);
  const [fortunes, setFortunes] = useState<HourlyFortune[]>([]);
  const [selectedHour, setSelectedHour] = useState<number | null>(null);

  useEffect(() => {
    const now = new Date();
    const hour = now.getHours();
    setCurrentHour(hour);
    setSelectedHour(hour);
    setFortunes(generateHourlyFortunes());
  }, []);

  const refreshFortunes = () => {
    setFortunes(generateHourlyFortunes());
  };

  const formatHour = (hour: number) => {
    if (hour === 0) return "오전 12시";
    if (hour < 12) return `오전 ${hour}시`;
    if (hour === 12) return "오후 12시";
    return `오후 ${hour - 12}시`;
  };

  const selectedFortune = selectedHour !== null ? fortunes[selectedHour] : null;

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50 dark:from-gray-900 dark:via-blue-900/20 dark:to-purple-900/20">
      <AppHeader />
      
      <motion.div 
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* 헤더 섹션 */}
        <motion.div variants={itemVariants} className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <Clock className="h-8 w-8 text-blue-600 dark:text-blue-400" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 dark:from-blue-400 dark:to-purple-400 bg-clip-text text-transparent">
              시간별 운세
            </h1>
          </div>
          <p className="text-gray-600 dark:text-gray-400">
            24시간 동안의 운세 흐름을 확인해보세요
          </p>
          <Button 
            onClick={refreshFortunes}
            variant="outline"
            size="sm"
            className="mt-4 bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600 text-gray-900 dark:text-gray-100 hover:bg-gray-50 dark:hover:bg-gray-600"
          >
            <RefreshCw className="w-4 h-4 mr-2" />
            새로고침
          </Button>
        </motion.div>

        {/* 현재 시간 하이라이트 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 bg-gradient-to-r from-blue-50 to-purple-50 dark:from-blue-900/30 dark:to-purple-900/30 border-blue-200 dark:border-blue-700 dark:bg-gray-800">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="bg-blue-100 dark:bg-blue-900/30 p-3 rounded-full">
                    <Clock className="w-6 h-6 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div>
                    <h3 className="font-bold text-blue-900 dark:text-blue-300">
                      현재 시간: {formatHour(currentHour)}
                    </h3>
                    <p className="text-sm text-blue-700 dark:text-blue-400">
                      {fortunes[currentHour]?.period} 시간대
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">
                    {fortunes[currentHour]?.overall_luck}점
                  </div>
                  <div className="text-sm text-blue-700 dark:text-blue-400">
                    {getLuckText(fortunes[currentHour]?.overall_luck || 0)}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 시간별 운세 목록 */}
        <motion.div variants={itemVariants}>
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-6 gap-3 mb-6">
            {fortunes.map((fortune, index) => {
              const IconComponent = fortune.icon;
              const isCurrentHour = index === currentHour;
              const isSelected = selectedHour === index;
              
              return (
                <motion.div
                  key={index}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  className={`cursor-pointer ${isCurrentHour ? 'ring-2 ring-blue-500 dark:ring-blue-400' : ''}`}
                  onClick={() => setSelectedHour(isSelected ? null : index)}
                >
                  <Card className={`h-full transition-all duration-200 ${
                    isSelected 
                      ? 'bg-blue-50 dark:bg-blue-900/30 border-blue-300 dark:border-blue-600' 
                      : 'bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600 hover:border-blue-200 dark:hover:border-blue-700'
                  }`}>
                    <CardContent className="p-3 text-center">
                      <IconComponent className={`w-5 h-5 mx-auto mb-2 ${
                        fortune.color === 'yellow' ? 'text-yellow-500 dark:text-yellow-400' :
                        fortune.color === 'orange' ? 'text-orange-500 dark:text-orange-400' :
                        fortune.color === 'purple' ? 'text-purple-500 dark:text-purple-400' :
                        'text-indigo-500 dark:text-indigo-400'
                      }`} />
                      <div className="text-xs font-medium text-gray-900 dark:text-gray-100 mb-1">
                        {formatHour(fortune.hour)}
                      </div>
                      <div className="text-xs text-gray-600 dark:text-gray-400 mb-1">
                        {fortune.period}
                      </div>
                      <Badge 
                        variant="outline" 
                        className={`text-xs px-1 py-0 ${getLuckColor(fortune.overall_luck)} border-0`}
                      >
                        {fortune.overall_luck}
                      </Badge>
                    </CardContent>
                  </Card>
                </motion.div>
              );
            })}
          </div>
        </motion.div>

        {/* 선택된 시간의 상세 운세 */}
        <AnimatePresence>
          {selectedHour !== null && (
            <motion.div
              initial={{ opacity: 0, height: 0 }}
              animate={{ opacity: 1, height: "auto" }}
              exit={{ opacity: 0, height: 0 }}
              transition={{ duration: 0.3 }}
            >
              <Card className="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <CardTitle className="flex items-center gap-2 text-gray-900 dark:text-gray-100">
                      {React.createElement(fortunes[selectedHour].icon, { 
                        className: `w-6 h-6 ${
                          fortunes[selectedHour].color === 'yellow' ? 'text-yellow-500 dark:text-yellow-400' :
                          fortunes[selectedHour].color === 'orange' ? 'text-orange-500 dark:text-orange-400' :
                          fortunes[selectedHour].color === 'purple' ? 'text-purple-500 dark:text-purple-400' :
                          'text-indigo-500 dark:text-indigo-400'
                        }` 
                      })}
                      {formatHour(fortunes[selectedHour].hour)} 상세 운세
                    </CardTitle>
                    <Badge 
                      variant="outline"
                      className={`${getLuckColor(fortunes[selectedHour].overall_luck)} border-0`}
                    >
                      {getLuckText(fortunes[selectedHour].overall_luck)}
                    </Badge>
                  </div>
                </CardHeader>
                <CardContent className="space-y-6">
                  {/* 운세 메시지 */}
                  <div className={`p-4 rounded-lg bg-gradient-to-r ${fortunes[selectedHour].gradient} dark:from-gray-700 dark:to-gray-600`}>
                    <p className="text-gray-800 dark:text-gray-200 leading-relaxed">
                      {fortunes[selectedHour].fortune_text}
                    </p>
                  </div>

                  {/* 분야별 운세 */}
                  <div className="grid grid-cols-2 gap-4">
                    <div className="flex items-center justify-between p-3 bg-red-50 dark:bg-red-900/30 rounded-lg">
                      <div className="flex items-center gap-2">
                        <Heart className="w-4 h-4 text-red-500 dark:text-red-400" />
                        <span className="text-sm font-medium text-gray-900 dark:text-gray-100">애정운</span>
                      </div>
                      <span className="font-bold text-red-600 dark:text-red-400">
                        {fortunes[selectedHour].love_fortune}점
                      </span>
                    </div>
                    
                    <div className="flex items-center justify-between p-3 bg-blue-50 dark:bg-blue-900/30 rounded-lg">
                      <div className="flex items-center gap-2">
                        <Briefcase className="w-4 h-4 text-blue-500 dark:text-blue-400" />
                        <span className="text-sm font-medium text-gray-900 dark:text-gray-100">업무운</span>
                      </div>
                      <span className="font-bold text-blue-600 dark:text-blue-400">
                        {fortunes[selectedHour].work_fortune}점
                      </span>
                    </div>
                    
                    <div className="flex items-center justify-between p-3 bg-green-50 dark:bg-green-900/30 rounded-lg">
                      <div className="flex items-center gap-2">
                        <Activity className="w-4 h-4 text-green-500 dark:text-green-400" />
                        <span className="text-sm font-medium text-gray-900 dark:text-gray-100">건강운</span>
                      </div>
                      <span className="font-bold text-green-600 dark:text-green-400">
                        {fortunes[selectedHour].health_fortune}점
                      </span>
                    </div>
                    
                    <div className="flex items-center justify-between p-3 bg-yellow-50 dark:bg-yellow-900/30 rounded-lg">
                      <div className="flex items-center gap-2">
                        <Star className="w-4 h-4 text-yellow-500 dark:text-yellow-400" />
                        <span className="text-sm font-medium text-gray-900 dark:text-gray-100">금전운</span>
                      </div>
                      <span className="font-bold text-yellow-600 dark:text-yellow-400">
                        {fortunes[selectedHour].money_fortune}점
                      </span>
                    </div>
                  </div>

                  {/* 추천 활동 */}
                  <div>
                    <h4 className="font-semibold mb-3 flex items-center gap-2 text-gray-900 dark:text-gray-100">
                      <Lightbulb className="w-4 h-4 text-yellow-500 dark:text-yellow-400" />
                      추천 활동
                    </h4>
                    <div className="flex flex-wrap gap-2">
                      {fortunes[selectedHour].best_activities.map((activity, index) => (
                        <Badge 
                          key={index} 
                          variant="outline"
                          className="bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-300 border-green-200 dark:border-green-600"
                        >
                          {activity}
                        </Badge>
                      ))}
                    </div>
                  </div>

                  {/* 주의사항 */}
                  {fortunes[selectedHour].warnings.length > 0 && (
                    <div>
                      <h4 className="font-semibold mb-3 flex items-center gap-2 text-gray-900 dark:text-gray-100">
                        <AlertTriangle className="w-4 h-4 text-orange-500 dark:text-orange-400" />
                        주의사항
                      </h4>
                      <div className="space-y-2">
                        {fortunes[selectedHour].warnings.map((warning, index) => (
                          <div 
                            key={index}
                            className="p-2 bg-orange-50 dark:bg-orange-900/30 rounded text-sm text-orange-800 dark:text-orange-300"
                          >
                            {warning}
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  {/* 행운 조언 */}
                  <div>
                    <h4 className="font-semibold mb-3 flex items-center gap-2 text-gray-900 dark:text-gray-100">
                      <Sparkles className="w-4 h-4 text-purple-500 dark:text-purple-400" />
                      행운 조언
                    </h4>
                    <div className="space-y-2">
                      {fortunes[selectedHour].recommendations.map((rec, index) => (
                        <div 
                          key={index}
                          className="p-2 bg-purple-50 dark:bg-purple-900/30 rounded text-sm text-purple-800 dark:text-purple-300"
                        >
                          • {rec}
                        </div>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 