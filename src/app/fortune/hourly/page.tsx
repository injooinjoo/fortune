"use client";

import { useState, useEffect } from "react";
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
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50 pb-32">
      <AppHeader title="시간대별 운세" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-6"
      >
        {/* 헤더 */}
        <motion.div variants={itemVariants} className="text-center mb-8">
          <motion.div
            className="bg-gradient-to-r from-indigo-500 to-purple-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
            whileHover={{ rotate: 360 }}
            transition={{ duration: 0.8 }}
          >
            <Clock className="w-10 h-10 text-white" />
          </motion.div>
          <h1 className="text-2xl font-bold text-gray-900 mb-2">시간대별 운세</h1>
          <p className="text-gray-600">매 시간마다 변화하는 당신의 운세를 확인해보세요</p>
          <div className="flex items-center justify-center gap-2 mt-4">
            <Clock className="w-4 h-4 text-indigo-600" />
            <span className="text-sm text-indigo-600 font-medium">
              현재 시간: {formatHour(currentHour)}
            </span>
          </div>
        </motion.div>

        {/* 새로고침 버튼 */}
        <motion.div variants={itemVariants} className="text-center mb-6">
          <Button
            onClick={refreshFortunes}
            variant="outline"
            className="border-indigo-300 text-indigo-600 hover:bg-indigo-50"
          >
            <RefreshCw className="w-4 h-4 mr-2" />
            운세 새로고침
          </Button>
        </motion.div>

        {/* 시간 선택 그리드 */}
        <motion.div variants={itemVariants} className="mb-8">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-indigo-700">
                <Calendar className="w-5 h-5" />
                시간 선택
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-4 gap-2">
                {fortunes.map((fortune, index) => {
                  const IconComponent = fortune.icon;
                  const isSelected = selectedHour === index;
                  const isCurrent = currentHour === index;
                  
                  return (
                    <motion.button
                      key={index}
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                      onClick={() => setSelectedHour(index)}
                      className={`
                        relative p-3 rounded-lg border-2 transition-all duration-200
                        ${isSelected 
                          ? 'border-indigo-500 bg-indigo-50' 
                          : 'border-gray-200 hover:border-indigo-300 hover:bg-indigo-25'
                        }
                        ${isCurrent ? 'ring-2 ring-amber-400 ring-offset-2' : ''}
                      `}
                    >
                      {isCurrent && (
                        <div className="absolute -top-1 -right-1">
                          <div className="w-3 h-3 bg-amber-400 rounded-full animate-pulse" />
                        </div>
                      )}
                      <div className="flex flex-col items-center gap-1">
                        <IconComponent className={`w-4 h-4 text-${fortune.color}-600`} />
                        <span className="text-xs font-medium text-gray-700">
                          {index === 0 ? '12' : index > 12 ? index - 12 : index}
                        </span>
                        <div className={`w-2 h-2 rounded-full ${getLuckColor(fortune.overall_luck).split(' ')[1]}`} />
                      </div>
                    </motion.button>
                  );
                })}
              </div>
              <div className="mt-4 text-center">
                <div className="flex items-center justify-center gap-4 text-xs text-gray-500">
                  <div className="flex items-center gap-1">
                    <div className="w-2 h-2 rounded-full bg-amber-400" />
                    <span>현재 시간</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <div className="w-2 h-2 rounded-full bg-green-400" />
                    <span>좋음</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <div className="w-2 h-2 rounded-full bg-orange-400" />
                    <span>보통</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <div className="w-2 h-2 rounded-full bg-red-400" />
                    <span>주의</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 선택된 시간대 운세 */}
        <AnimatePresence mode="wait">
          {selectedFortune && (
            <motion.div
              key={selectedHour}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              className="space-y-6"
            >
              {/* 전체 운세 */}
              <motion.div variants={itemVariants}>
                <Card className={`bg-gradient-to-r ${selectedFortune.gradient} border-${selectedFortune.color}-200`}>
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <selectedFortune.icon className={`w-6 h-6 text-${selectedFortune.color}-600`} />
                      <span className="text-xl font-medium text-gray-900">
                        {formatHour(selectedHour!)} ({selectedFortune.period})
                      </span>
                    </div>
                    <p className="text-gray-700 text-lg mb-4">전체 운세</p>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className="text-5xl font-bold mb-2 text-gray-900"
                    >
                      {selectedFortune.overall_luck}점
                    </motion.div>
                    <Badge variant="secondary" className={`${getLuckColor(selectedFortune.overall_luck)} border-0`}>
                      {getLuckText(selectedFortune.overall_luck)}
                    </Badge>
                    <p className="text-gray-700 mt-4 text-base">
                      {selectedFortune.fortune_text}
                    </p>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 세부 운세 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Star className="w-5 h-5 text-indigo-600" />
                      세부 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "연애운", score: selectedFortune.love_fortune, icon: Heart, desc: "사랑과 인간관계" },
                      { label: "직장운", score: selectedFortune.work_fortune, icon: Briefcase, desc: "업무와 성과" },
                      { label: "건강운", score: selectedFortune.health_fortune, icon: Activity, desc: "몸과 마음의 컨디션" },
                      { label: "재물운", score: selectedFortune.money_fortune, icon: TrendingUp, desc: "금전과 투자" }
                    ].map((item, index) => {
                      const LuckIcon = getLuckIcon(item.score);
                      return (
                        <motion.div
                          key={item.label}
                          initial={{ x: -20, opacity: 0 }}
                          animate={{ x: 0, opacity: 1 }}
                          transition={{ delay: 0.4 + index * 0.1 }}
                          className="space-y-2"
                        >
                          <div className="flex items-center gap-3">
                            <item.icon className="w-5 h-5 text-gray-600" />
                            <div className="flex-1">
                              <div className="flex justify-between items-center mb-1">
                                <div>
                                  <span className="font-medium">{item.label}</span>
                                  <p className="text-xs text-gray-500">{item.desc}</p>
                                </div>
                                <div className="flex items-center gap-2">
                                  <LuckIcon className={`w-4 h-4 ${getLuckColor(item.score).split(' ')[0]}`} />
                                  <span className={`px-3 py-1 rounded-full text-sm font-medium ${getLuckColor(item.score)}`}>
                                    {item.score}점
                                  </span>
                                </div>
                              </div>
                              <div className="w-full bg-gray-200 rounded-full h-2">
                                <motion.div
                                  className={`bg-${selectedFortune.color}-500 h-2 rounded-full`}
                                  initial={{ width: 0 }}
                                  animate={{ width: `${item.score}%` }}
                                  transition={{ delay: 0.5 + index * 0.1, duration: 0.8 }}
                                />
                              </div>
                            </div>
                          </div>
                        </motion.div>
                      );
                    })}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 추천 활동 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <Lightbulb className="w-5 h-5" />
                      추천 활동
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {selectedFortune.best_activities.map((activity, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.6 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Sparkles className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{activity}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 조언 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <Star className="w-5 h-5" />
                      조언
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      <div className="p-4 bg-blue-50 rounded-lg">
                        <h4 className="font-medium text-blue-800 mb-2 flex items-center gap-2">
                          <TrendingUp className="w-4 h-4" />
                          권장사항
                        </h4>
                        <div className="space-y-1">
                          {selectedFortune.recommendations.map((rec, index) => (
                            <p key={index} className="text-blue-700 text-sm">• {rec}</p>
                          ))}
                        </div>
                      </div>
                      <div className="p-4 bg-amber-50 rounded-lg">
                        <h4 className="font-medium text-amber-800 mb-2 flex items-center gap-2">
                          <AlertTriangle className="w-4 h-4" />
                          주의사항
                        </h4>
                        <div className="space-y-1">
                          {selectedFortune.warnings.map((warning, index) => (
                            <p key={index} className="text-amber-700 text-sm">• {warning}</p>
                          ))}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 