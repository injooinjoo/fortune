"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
import { 
  Heart, 
  Users, 
  Star, 
  Calendar,
  Sparkles,
  TrendingUp,
  Home,
  Briefcase,
  ArrowRight,
  Shuffle,
  Clock
} from "lucide-react";

interface PersonInfo {
  name: string;
  birthDate: string;
}

interface CompatibilityResult {
  overallScore: number;
  loveScore: number;
  marriageScore: number;
  careerScore: number;
  dailyLifeScore: number;
  personality: {
    person1: string;
    person2: string;
  };
  strengths: string[];
  challenges: string[];
  advice: string;
  luckyElements: {
    color: string;
    number: number;
    direction: string;
    date: string;
  };
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

const getScoreColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 50) return "text-yellow-600 bg-yellow-50";
  return "text-red-600 bg-red-50";
};

const getScoreText = (score: number) => {
  if (score >= 85) return "매우 좋음";
  if (score >= 70) return "좋음";
  if (score >= 50) return "보통";
  return "주의 필요";
};

export default function CompatibilityPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [person1, setPerson1] = useState<PersonInfo>({ name: '', birthDate: '' });
  const [person2, setPerson2] = useState<PersonInfo>({ name: '', birthDate: '' });
  const [result, setResult] = useState<CompatibilityResult | null>(null);
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  const calculateCompatibility = async (): Promise<CompatibilityResult> => {
    const baseScore = Math.floor(Math.random() * 40) + 50;
    
    return {
      overallScore: baseScore + Math.floor(Math.random() * 10),
      loveScore: Math.max(30, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 10)),
      marriageScore: Math.max(30, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 10)),
      careerScore: Math.max(30, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 10)),
      dailyLifeScore: Math.max(30, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 10)),
      personality: {
        person1: "따뜻하고 배려심 많은 성격으로 상대방을 잘 이해합니다.",
        person2: "적극적이고 리더십이 강해 관계를 주도하는 타입입니다."
      },
      strengths: [
        "서로의 부족한 부분을 잘 보완해 줍니다",
        "소통과 이해가 원활한 관계입니다",
        "공통된 가치관과 목표를 가지고 있습니다",
        "서로를 존중하고 배려하는 마음이 깊습니다"
      ],
      challenges: [
        "때로는 의견 차이로 인한 갈등이 있을 수 있습니다",
        "서로 다른 성격으로 인해 오해가 생길 수 있습니다",
        "소통 방식의 차이를 이해하는 노력이 필요합니다"
      ],
      advice: "서로의 다름을 인정하고 존중하는 마음가짐이 중요합니다. 작은 배려와 관심이 더 큰 행복을 만들어 갈 것입니다.",
      luckyElements: {
        color: "#EC4899",
        number: Math.floor(Math.random() * 9) + 1,
        direction: ["동쪽", "서쪽", "남쪽", "북쪽"][Math.floor(Math.random() * 4)],
        date: "매월 7일, 17일, 27일"
      }
    };
  };

  const handleSubmit = async () => {
    if (!person1.name || !person1.birthDate || !person2.name || !person2.birthDate) {
      alert('모든 정보를 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      const compatibilityResult = await calculateCompatibility();
      setResult(compatibilityResult);
      setStep('result');
    } catch (error) {
      console.error('궁합 분석 중 오류:', error);
      alert('궁합 분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setPerson1({ name: '', birthDate: '' });
    setPerson2({ name: '', birthDate: '' });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader 
        title="궁합 보기" 
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
          {step === 'input' && (
            <motion.div
              key="input"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              {/* 헤더 */}
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-rose-500 to-pink-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Users className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">궁합 분석</h1>
                <p className="text-gray-600 dark:text-gray-300">두 사람의 정보를 입력하고 운명적 인연을 확인해보세요</p>
              </motion.div>

              {/* 첫 번째 사람 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-rose-200 dark:border-rose-800 bg-white/80 dark:bg-gray-800/80">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-rose-700 dark:text-rose-300">
                      <Heart className="w-5 h-5" />
                      첫 번째 사람
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="person1-name">이름</Label>
                      <Input
                        id="person1-name"
                        placeholder="이름을 입력하세요"
                        value={person1.name}
                        onChange={(e) => setPerson1(prev => ({ ...prev, name: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="person1-birth">생년월일</Label>
                      <Input
                        id="person1-birth"
                        type="date"
                        value={person1.birthDate}
                        onChange={(e) => setPerson1(prev => ({ ...prev, birthDate: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 연결 아이콘 */}
              <motion.div 
                variants={itemVariants}
                className="flex justify-center"
              >
                <motion.div
                  animate={{ scale: [1, 1.1, 1] }}
                  transition={{ repeat: Infinity, duration: 2 }}
                  className="bg-gradient-to-r from-rose-400 to-pink-400 rounded-full p-3"
                >
                  <Heart className="w-6 h-6 text-white" />
                </motion.div>
              </motion.div>

              {/* 두 번째 사람 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-pink-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-pink-700">
                      <Heart className="w-5 h-5" />
                      두 번째 사람
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="person2-name">이름</Label>
                      <Input
                        id="person2-name"
                        placeholder="이름을 입력하세요"
                        value={person2.name}
                        onChange={(e) => setPerson2(prev => ({ ...prev, name: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="person2-birth">생년월일</Label>
                      <Input
                        id="person2-birth"
                        type="date"
                        value={person2.birthDate}
                        onChange={(e) => setPerson2(prev => ({ ...prev, birthDate: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 text-white py-6 text-lg font-semibold"
                >
                  {loading ? (
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ repeat: Infinity, duration: 1 }}
                      className="flex items-center gap-2"
                    >
                      <Shuffle className="w-5 h-5" />
                      분석 중...
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-5 h-5" />
                      궁합 분석하기
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
              {/* 전체 궁합 점수 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-rose-500 to-pink-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <span className="text-xl font-medium">{person1.name}</span>
                      <Heart className="w-6 h-6" />
                      <span className="text-xl font-medium">{person2.name}</span>
                    </div>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className="text-6xl font-bold mb-2"
                    >
                      {result.overallScore}점
                    </motion.div>
                    <p className="text-white/90 text-lg">전체 궁합 점수</p>
                    <Badge variant="secondary" className="mt-2 bg-white/20 text-white border-white/30">
                      {getScoreText(result.overallScore)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 세부 궁합 점수 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <TrendingUp className="w-5 h-5 text-rose-600" />
                      세부 궁합 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "연애 궁합", score: result.loveScore, icon: Heart },
                      { label: "결혼 궁합", score: result.marriageScore, icon: Home },
                      { label: "사업 궁합", score: result.careerScore, icon: Briefcase },
                      { label: "일상 궁합", score: result.dailyLifeScore, icon: Clock }
                    ].map((item, index) => (
                      <motion.div
                        key={item.label}
                        initial={{ x: -20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.4 + index * 0.1 }}
                        className="flex items-center gap-4"
                      >
                        <item.icon className="w-5 h-5 text-gray-600" />
                        <div className="flex-1">
                          <div className="flex justify-between items-center mb-1">
                            <span className="font-medium">{item.label}</span>
                            <span className={`px-2 py-1 rounded-full text-sm font-medium ${getScoreColor(item.score)}`}>
                              {item.score}점
                            </span>
                          </div>
                          <Progress value={item.score} className="h-2" />
                        </div>
                      </motion.div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 성격 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Users className="w-5 h-5 text-rose-600" />
                      성격 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-rose-50 rounded-lg">
                        <h4 className="font-medium text-rose-800 mb-2">{person1.name}님</h4>
                        <p className="text-gray-700">{result.personality.person1}</p>
                      </div>
                      <div className="p-4 bg-pink-50 rounded-lg">
                        <h4 className="font-medium text-pink-800 mb-2">{person2.name}님</h4>
                        <p className="text-gray-700">{result.personality.person2}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 장점 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <Star className="w-5 h-5" />
                      관계의 장점
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.strengths.map((strength, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.6 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Star className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{strength}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 주의사항 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-amber-600">
                      <Calendar className="w-5 h-5" />
                      주의사항
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.challenges.map((challenge, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.8 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Calendar className="w-4 h-4 text-amber-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{challenge}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 조언 */}
              <motion.div variants={itemVariants}>
                <Card className="border-rose-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-rose-600">
                      <Sparkles className="w-5 h-5" />
                      운세 조언
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-gray-700 leading-relaxed">{result.advice}</p>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 행운 요소 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Sparkles className="w-5 h-5" />
                      행운의 요소
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="text-center p-3 bg-purple-50 rounded-lg">
                        <div 
                          className="w-8 h-8 rounded-full mx-auto mb-2 border-2 border-white shadow"
                          style={{ backgroundColor: result.luckyElements.color }}
                        />
                        <p className="text-sm font-medium text-purple-800">행운의 색상</p>
                      </div>
                      <div className="text-center p-3 bg-purple-50 rounded-lg">
                        <div className="text-2xl font-bold text-purple-800 mb-1">
                          {result.luckyElements.number}
                        </div>
                        <p className="text-sm font-medium text-purple-800">행운의 숫자</p>
                      </div>
                      <div className="text-center p-3 bg-purple-50 rounded-lg">
                        <div className="text-lg font-bold text-purple-800 mb-1">
                          {result.luckyElements.direction}
                        </div>
                        <p className="text-sm font-medium text-purple-800">행운의 방향</p>
                      </div>
                      <div className="text-center p-3 bg-purple-50 rounded-lg">
                        <div className="text-xs font-bold text-purple-800 mb-1">
                          {result.luckyElements.date}
                        </div>
                        <p className="text-sm font-medium text-purple-800">행운의 날</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-rose-300 text-rose-600 hover:bg-rose-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 궁합 보기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 