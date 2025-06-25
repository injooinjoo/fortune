"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
import {
  Brain,
  Heart,
  Users,
  Lightbulb,
  Target,
  Sparkles,
  ArrowRight,
  ArrowLeft,
  RotateCcw,
} from "lucide-react";

interface Question {
  id: number;
  text: string;
  options: {
    text: string;
    value: string;
  }[];
}

interface TestResult {
  type: string;
  title: string;
  description: string;
  characteristics: string[];
  advice: string;
  compatibility: string[];
  color: string;
}

const questions: Question[] = [
  {
    id: 1,
    text: "친구들과 모임에서 당신은 주로?",
    options: [
      { text: "분위기를 이끌고 대화를 주도한다", value: "E" },
      { text: "조용히 듣고 필요할 때만 이야기한다", value: "I" },
      { text: "상황에 따라 다르게 행동한다", value: "N" },
      { text: "편한 사람들과만 활발히 대화한다", value: "S" },
    ],
  },
  {
    id: 2,
    text: "새로운 프로젝트를 시작할 때?",
    options: [
      { text: "전체적인 큰 그림부터 그린다", value: "N" },
      { text: "구체적인 계획을 세세하게 세운다", value: "S" },
      { text: "일단 시작하고 진행하면서 조정한다", value: "P" },
      { text: "비슷한 경험을 참고해서 계획한다", value: "J" },
    ],
  },
  {
    id: 3,
    text: "중요한 결정을 내릴 때?",
    options: [
      { text: "논리적으로 분석해서 결정한다", value: "T" },
      { text: "직감과 감정을 중요하게 생각한다", value: "F" },
      { text: "다른 사람들의 의견을 많이 듣는다", value: "E" },
      { text: "혼자 충분히 고민한 후 결정한다", value: "I" },
    ],
  },
  {
    id: 4,
    text: "스트레스를 받을 때?",
    options: [
      { text: "친구들과 만나서 이야기한다", value: "E" },
      { text: "혼자만의 시간을 갖는다", value: "I" },
      { text: "운동이나 취미활동을 한다", value: "S" },
      { text: "원인을 분석하고 해결책을 찾는다", value: "T" },
    ],
  },
  {
    id: 5,
    text: "여행을 계획할 때?",
    options: [
      { text: "미리 상세한 일정을 짠다", value: "J" },
      { text: "대략적인 계획만 세우고 즉흥적으로", value: "P" },
      { text: "유명한 관광지 위주로 계획한다", value: "S" },
      { text: "특별하고 독특한 경험을 찾는다", value: "N" },
    ],
  },
];

const resultTypes: Record<string, TestResult> = {
  leader: {
    type: "leader",
    title: "타고난 리더",
    description: "당신은 자연스럽게 사람들을 이끌고 영감을 주는 리더십을 가지고 있습니다.",
    characteristics: ["결단력 있음", "책임감 강함", "추진력 있음", "소통 능력 뛰어남"],
    advice: "때로는 다른 사람의 의견에도 귀 기울이고, 완벽주의에서 벗어나 여유를 가져보세요.",
    compatibility: ["창의적 사고자", "감정적 공감자"],
    color: "#F59E0B",
  },
  creative: {
    type: "creative",
    title: "창의적 사고자",
    description: "독창적인 아이디어와 예술적 감각을 가진 창의적인 사람입니다.",
    characteristics: ["상상력 풍부", "예술적 감각", "독창적 사고", "자유로운 영혼"],
    advice: "아이디어를 실현하는 실행력을 기르고, 체계적인 계획 세우기를 연습해보세요.",
    compatibility: ["타고난 리더", "분석적 사고자"],
    color: "#8B5CF6",
  },
  analytical: {
    type: "analytical",
    title: "분석적 사고자",
    description: "논리적이고 체계적인 사고로 문제를 해결하는 능력이 뛰어납니다.",
    characteristics: ["논리적 사고", "문제 해결 능력", "체계적", "신중함"],
    advice: "감정적인 측면도 고려하고, 때로는 직감을 믿어보는 것도 좋습니다.",
    compatibility: ["창의적 사고자", "감정적 공감자"],
    color: "#06B6D4",
  },
  empathetic: {
    type: "empathetic",
    title: "감정적 공감자",
    description: "다른 사람의 감정을 잘 이해하고 따뜻한 마음을 가진 사람입니다.",
    characteristics: ["공감 능력", "배려심", "따뜻함", "소통 능력"],
    advice: "자신의 감정도 소중히 여기고, 때로는 객관적인 판단도 필요합니다.",
    compatibility: ["타고난 리더", "분석적 사고자"],
    color: "#EF4444",
  },
  adventurer: {
    type: "adventurer",
    title: "모험가 정신",
    description: "새로운 경험을 즐기고 변화를 두려워하지 않는 자유로운 영혼입니다.",
    characteristics: ["호기심 많음", "적응력 좋음", "도전 정신", "자유로움"],
    advice: "장기적인 목표도 세워보고, 안정성과 모험 사이의 균형을 찾아보세요.",
    compatibility: ["창의적 사고자", "타고난 리더"],
    color: "#10B981",
  },
};

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
};

const itemVariants = {
  hidden: { y: 20, opacity: 0 },
  visible: {
    y: 0,
    opacity: 1,
    transition: {
      type: "spring" as const,
      stiffness: 100,
      damping: 10,
    },
  },
};

export default function PsychologyTestPage() {
  const [step, setStep] = useState<"intro" | "test" | "result">("intro");
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [answers, setAnswers] = useState<string[]>([]);
  const [result, setResult] = useState<TestResult | null>(null);

  const analyzeResult = (): TestResult => {
    const counts = answers.reduce((acc, answer) => {
      acc[answer] = (acc[answer] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // 간단한 분석 로직
    if (counts.E >= 2 && counts.T >= 2) return resultTypes.leader;
    if (counts.N >= 2 && counts.P >= 2) return resultTypes.creative;
    if (counts.T >= 3) return resultTypes.analytical;
    if (counts.F >= 2 && counts.E >= 2) return resultTypes.empathetic;
    return resultTypes.adventurer;
  };

  const handleAnswer = (value: string) => {
    const newAnswers = [...answers, value];
    setAnswers(newAnswers);

    if (currentQuestion < questions.length - 1) {
      setCurrentQuestion(currentQuestion + 1);
    } else {
      const testResult = analyzeResult();
      setResult(testResult);
      setStep("result");
    }
  };

  const handlePrevious = () => {
    if (currentQuestion > 0) {
      setCurrentQuestion(currentQuestion - 1);
      setAnswers(answers.slice(0, -1));
    }
  };

  const handleReset = () => {
    setStep("intro");
    setCurrentQuestion(0);
    setAnswers([]);
    setResult(null);
  };

  const progress = ((currentQuestion + 1) / questions.length) * 100;

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-indigo-50 dark:from-gray-900 dark:via-purple-900/20 dark:to-indigo-900/20">
      <AppHeader />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="container mx-auto px-4 pt-4 pb-20"
      >
        <AnimatePresence mode="wait">
          {step === "intro" && (
            <motion.div
              key="intro"
              variants={itemVariants}
              initial="hidden"
              animate="visible"
              exit="hidden"
              className="text-center space-y-6"
            >
              <div className="flex items-center justify-center gap-2 mb-4">
                <Brain className="h-8 w-8 text-purple-600 dark:text-purple-400" />
                <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 dark:from-purple-400 dark:to-pink-400 bg-clip-text text-transparent">
                  심리 성향 테스트
                </h1>
              </div>
              <p className="text-gray-600 dark:text-gray-400 text-lg">
                5가지 간단한 질문으로 당신의 성향을 알아보세요
              </p>
              
              <Card className="max-w-md mx-auto bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
                <CardHeader>
                  <CardTitle className="flex items-center justify-center gap-2 text-gray-900 dark:text-gray-100">
                    <Sparkles className="h-5 w-5 text-purple-600 dark:text-purple-400" />
                    테스트 안내
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="text-center p-3 bg-purple-50 dark:bg-purple-900/30 rounded-lg">
                      <Heart className="h-6 w-6 text-purple-600 dark:text-purple-400 mx-auto mb-2" />
                      <div className="text-sm font-medium text-gray-900 dark:text-gray-100">감정</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400">감정적 패턴</div>
                    </div>
                    <div className="text-center p-3 bg-pink-50 dark:bg-pink-900/30 rounded-lg">
                      <Users className="h-6 w-6 text-pink-600 dark:text-pink-400 mx-auto mb-2" />
                      <div className="text-sm font-medium text-gray-900 dark:text-gray-100">사회성</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400">대인관계 스타일</div>
                    </div>
                    <div className="text-center p-3 bg-indigo-50 dark:bg-indigo-900/30 rounded-lg">
                      <Lightbulb className="h-6 w-6 text-indigo-600 dark:text-indigo-400 mx-auto mb-2" />
                      <div className="text-sm font-medium text-gray-900 dark:text-gray-100">사고</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400">사고 방식</div>
                    </div>
                    <div className="text-center p-3 bg-yellow-50 dark:bg-yellow-900/30 rounded-lg">
                      <Target className="h-6 w-6 text-yellow-600 dark:text-yellow-400 mx-auto mb-2" />
                      <div className="text-sm font-medium text-gray-900 dark:text-gray-100">목표</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400">목표 지향성</div>
                    </div>
                  </div>
                  
                  <div className="text-center space-y-2">
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      소요시간: 약 3분
                    </p>
                    <Button 
                      onClick={() => setStep("test")}
                      className="w-full bg-purple-600 hover:bg-purple-700 dark:bg-purple-500 dark:hover:bg-purple-600 text-white"
                    >
                      테스트 시작하기
                      <ArrowRight className="w-4 h-4 ml-2" />
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          )}

          {step === "test" && (
            <motion.div
              key="test"
              variants={itemVariants}
              initial="hidden"
              animate="visible"
              exit="hidden"
              className="max-w-2xl mx-auto"
            >
              <div className="mb-6">
                <div className="flex items-center justify-between mb-2">
                  <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
                    질문 {currentQuestion + 1} / {questions.length}
                  </h2>
                  <Badge variant="outline" className="bg-purple-50 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300 border-purple-200 dark:border-purple-600">
                    {Math.round(((currentQuestion + 1) / questions.length) * 100)}%
                  </Badge>
                </div>
                <Progress 
                  value={((currentQuestion + 1) / questions.length) * 100} 
                  className="h-2"
                />
              </div>

              <Card className="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
                <CardHeader>
                  <CardTitle className="text-xl text-gray-900 dark:text-gray-100">
                    {questions[currentQuestion].text}
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {questions[currentQuestion].options.map((option, index) => (
                    <motion.div
                      key={index}
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                    >
                      <Button
                        variant="outline"
                        onClick={() => handleAnswer(option.value)}
                        className="w-full p-4 h-auto text-left justify-start bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600 text-gray-900 dark:text-gray-100 hover:bg-purple-50 dark:hover:bg-purple-900/30 hover:border-purple-300 dark:hover:border-purple-500"
                      >
                        <span className="font-medium mr-3 text-purple-600 dark:text-purple-400">
                          {String.fromCharCode(65 + index)}.
                        </span>
                        {option.text}
                      </Button>
                    </motion.div>
                  ))}
                </CardContent>
              </Card>

              {currentQuestion > 0 && (
                <motion.div 
                  variants={itemVariants}
                  className="mt-4"
                >
                  <Button
                    variant="ghost"
                    onClick={handlePrevious}
                    className="text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200"
                  >
                    <ArrowLeft className="w-4 h-4 mr-2" />
                    이전 질문
                  </Button>
                </motion.div>
              )}
            </motion.div>
          )}

          {step === "result" && result && (
            <motion.div
              key="result"
              variants={itemVariants}
              initial="hidden"
              animate="visible"
              exit="hidden"
              className="max-w-2xl mx-auto space-y-6"
            >
              <div className="text-center">
                <h1 className="text-3xl font-bold bg-gradient-to-r from-purple-600 to-pink-600 dark:from-purple-400 dark:to-pink-400 bg-clip-text text-transparent mb-2">
                  테스트 완료!
                </h1>
                <p className="text-gray-600 dark:text-gray-400">
                  당신의 심리 성향 결과입니다
                </p>
              </div>

              <Card 
                className="bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600"
                style={{ 
                  background: `linear-gradient(135deg, ${result.color}10, ${result.color}05)` 
                }}
              >
                <CardHeader className="text-center pb-4">
                  <div 
                    className="w-20 h-20 rounded-full mx-auto mb-4 flex items-center justify-center"
                    style={{ backgroundColor: `${result.color}20` }}
                  >
                    <Sparkles 
                      className="w-10 h-10" 
                      style={{ color: result.color }}
                    />
                  </div>
                  <CardTitle className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                    {result.title}
                  </CardTitle>
                  <p className="text-gray-600 dark:text-gray-400 mt-2">
                    {result.description}
                  </p>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div>
                    <h3 className="font-semibold mb-3 flex items-center gap-2 text-gray-900 dark:text-gray-100">
                      <Users className="w-4 h-4" style={{ color: result.color }} />
                      주요 특성
                    </h3>
                    <div className="grid grid-cols-2 gap-2">
                      {result.characteristics.map((trait, index) => (
                        <Badge 
                          key={index} 
                          variant="outline"
                          className="justify-center bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600 text-gray-900 dark:text-gray-100"
                        >
                          {trait}
                        </Badge>
                      ))}
                    </div>
                  </div>

                  <div>
                    <h3 className="font-semibold mb-3 flex items-center gap-2 text-gray-900 dark:text-gray-100">
                      <Lightbulb className="w-4 h-4" style={{ color: result.color }} />
                      성장 조언
                    </h3>
                    <p className="text-gray-600 dark:text-gray-400 text-sm leading-relaxed">
                      {result.advice}
                    </p>
                  </div>

                  <div>
                    <h3 className="font-semibold mb-3 flex items-center gap-2 text-gray-900 dark:text-gray-100">
                      <Heart className="w-4 h-4" style={{ color: result.color }} />
                      잘 맞는 성향
                    </h3>
                    <div className="flex flex-wrap gap-2">
                      {result.compatibility.map((comp, index) => (
                        <Badge 
                          key={index}
                          className="bg-green-50 dark:bg-green-900/30 text-green-700 dark:text-green-300 border-green-200 dark:border-green-600"
                        >
                          {comp}
                        </Badge>
                      ))}
                    </div>
                  </div>

                  <div className="pt-4 space-y-3">
                    <Button 
                      onClick={handleReset}
                      variant="outline"
                      className="w-full bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600 text-gray-900 dark:text-gray-100 hover:bg-gray-50 dark:hover:bg-gray-600"
                    >
                      <RotateCcw className="w-4 h-4 mr-2" />
                      다시 테스트하기
                    </Button>
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