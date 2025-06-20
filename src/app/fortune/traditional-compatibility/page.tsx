"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Progress } from "@/components/ui/progress";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import AppHeader from "@/components/AppHeader";
import {
  Users,
  Sparkles,
  Heart,
  Home,
  Briefcase,
  ArrowRight,
} from "lucide-react";

interface PersonInfo {
  name: string;
  birthDate: string;
  birthTime: string;
}

interface FiveElement {
  element: string;
  score: number;
}

interface TenGod {
  relation: string;
  description: string;
}

interface TraditionalCompatibilityResult {
  overallScore: number;
  summary: string;
  fiveElements: FiveElement[];
  tenGods: TenGod[];
  loveScore: number;
  marriageScore: number;
  businessScore: number;
  advice: string;
}

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
  return "주의";
};

export default function TraditionalCompatibilityPage() {
  const [step, setStep] = useState<"input" | "result">("input");
  const [loading, setLoading] = useState(false);
  const [person1, setPerson1] = useState<PersonInfo>({
    name: "",
    birthDate: "",
    birthTime: "",
  });
  const [person2, setPerson2] = useState<PersonInfo>({
    name: "",
    birthDate: "",
    birthTime: "",
  });
  const [result, setResult] = useState<TraditionalCompatibilityResult | null>(
    null,
  );
  const [tab, setTab] = useState("summary");

  const analyze = async (): Promise<TraditionalCompatibilityResult> => {
    const base = Math.floor(Math.random() * 40) + 60;
    const randScore = () =>
      Math.max(40, Math.min(100, base + Math.floor(Math.random() * 20) - 10));
    return {
      overallScore: randScore(),
      summary:
        "두 분의 사주가 조화를 이루어 안정적인 관계를 기대할 수 있습니다.",
      fiveElements: [
        { element: "木", score: randScore() },
        { element: "火", score: randScore() },
        { element: "土", score: randScore() },
        { element: "金", score: randScore() },
        { element: "水", score: randScore() },
      ],
      tenGods: [
        {
          relation: "비견",
          description: "서로의 기질이 비슷해 의지가 잘 맞습니다.",
        },
        {
          relation: "식신",
          description: "함께 있을 때 즐거움을 느끼며 창의력이 올라갑니다.",
        },
        {
          relation: "정재",
          description: "경제적인 부분에서 서로에게 도움을 줄 수 있습니다.",
        },
        {
          relation: "편관",
          description: "가끔은 고집이 부딪칠 수 있으니 배려가 필요합니다.",
        },
      ],
      loveScore: randScore(),
      marriageScore: randScore(),
      businessScore: randScore(),
      advice:
        "오행의 균형을 맞추고 서로의 차이를 존중한다면 좋은 인연으로 발전할 것입니다.",
    };
  };

  const handleSubmit = async () => {
    if (
      !person1.name ||
      !person1.birthDate ||
      !person2.name ||
      !person2.birthDate
    ) {
      alert("모든 정보를 입력해주세요.");
      return;
    }

    setLoading(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 2000));
      const data = await analyze();
      setResult(data);
      setStep("result");
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setStep("input");
    setResult(null);
    setPerson1({ name: "", birthDate: "", birthTime: "" });
    setPerson2({ name: "", birthDate: "", birthTime: "" });
    setTab("summary");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-violet-50 via-white to-pink-50 pb-20">
      <AppHeader title="정통궁합" />
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-6"
      >
        <AnimatePresence mode="wait">
          {step === "input" && (
            <motion.div
              key="input"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-violet-500 to-pink-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Users className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">
                  정통궁합 분석
                </h1>
                <p className="text-gray-600">
                  사주 기반으로 두 사람의 깊은 인연을 살펴봅니다
                </p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-violet-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-violet-700">
                      <Heart className="w-5 h-5" />첫 번째 사람
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="p1-name">이름</Label>
                      <Input
                        id="p1-name"
                        placeholder="이름을 입력하세요"
                        value={person1.name}
                        onChange={(e) =>
                          setPerson1((prev) => ({
                            ...prev,
                            name: e.target.value,
                          }))
                        }
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="p1-birth">생년월일</Label>
                      <Input
                        id="p1-birth"
                        type="date"
                        value={person1.birthDate}
                        onChange={(e) =>
                          setPerson1((prev) => ({
                            ...prev,
                            birthDate: e.target.value,
                          }))
                        }
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="p1-time">출생 시간 (선택)</Label>
                      <Input
                        id="p1-time"
                        type="time"
                        value={person1.birthTime}
                        onChange={(e) =>
                          setPerson1((prev) => ({
                            ...prev,
                            birthTime: e.target.value,
                          }))
                        }
                        className="mt-1"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div
                variants={itemVariants}
                className="flex justify-center"
              >
                <motion.div
                  animate={{ scale: [1, 1.1, 1] }}
                  transition={{ repeat: Infinity, duration: 2 }}
                  className="bg-gradient-to-r from-violet-400 to-pink-400 rounded-full p-3"
                >
                  <Heart className="w-6 h-6 text-white" />
                </motion.div>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-pink-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-pink-700">
                      <Heart className="w-5 h-5" />두 번째 사람
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="p2-name">이름</Label>
                      <Input
                        id="p2-name"
                        placeholder="이름을 입력하세요"
                        value={person2.name}
                        onChange={(e) =>
                          setPerson2((prev) => ({
                            ...prev,
                            name: e.target.value,
                          }))
                        }
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="p2-birth">생년월일</Label>
                      <Input
                        id="p2-birth"
                        type="date"
                        value={person2.birthDate}
                        onChange={(e) =>
                          setPerson2((prev) => ({
                            ...prev,
                            birthDate: e.target.value,
                          }))
                        }
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="p2-time">출생 시간 (선택)</Label>
                      <Input
                        id="p2-time"
                        type="time"
                        value={person2.birthTime}
                        onChange={(e) =>
                          setPerson2((prev) => ({
                            ...prev,
                            birthTime: e.target.value,
                          }))
                        }
                        className="mt-1"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-violet-500 to-pink-500 hover:from-violet-600 hover:to-pink-600 text-white py-6 text-lg font-semibold"
                >
                  {loading ? (
                    "분석 중..."
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

          {step === "result" && result && (
            <motion.div
              key="result"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -50 }}
              className="space-y-6"
            >
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-violet-500 to-pink-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <span className="text-xl font-medium">
                        {person1.name}
                      </span>
                      <Heart className="w-6 h-6" />
                      <span className="text-xl font-medium">
                        {person2.name}
                      </span>
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
                    <div
                      className={`mt-2 inline-block px-3 py-1 rounded-full text-sm font-medium ${getScoreColor(result.overallScore)}`}
                    >
                      {getScoreText(result.overallScore)}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Tabs value={tab} onValueChange={setTab} className="w-full">
                  <TabsList className="grid grid-cols-4 w-full">
                    <TabsTrigger value="summary">총평</TabsTrigger>
                    <TabsTrigger value="elements">오행</TabsTrigger>
                    <TabsTrigger value="gods">십성</TabsTrigger>
                    <TabsTrigger value="scores">관계</TabsTrigger>
                  </TabsList>

                  <TabsContent value="summary" className="mt-4">
                    <p className="text-sm leading-relaxed text-gray-700">
                      {result.summary}
                    </p>
                    <p className="text-sm leading-relaxed text-gray-700 mt-2">
                      {result.advice}
                    </p>
                  </TabsContent>

                  <TabsContent value="elements" className="mt-4 space-y-3">
                    {result.fiveElements.map((el) => (
                      <div key={el.element} className="space-y-1">
                        <div className="flex justify-between items-center">
                          <span className="font-medium">{el.element}</span>
                          <span
                            className={`px-2 py-1 rounded-full text-sm font-medium ${getScoreColor(el.score)}`}
                          >
                            {el.score}점
                          </span>
                        </div>
                        <Progress value={el.score} className="h-2" />
                      </div>
                    ))}
                  </TabsContent>

                  <TabsContent value="gods" className="mt-4 space-y-3">
                    {result.tenGods.map((g) => (
                      <div
                        key={g.relation}
                        className="p-3 rounded-md bg-gray-50"
                      >
                        <h4 className="font-medium mb-1">{g.relation}</h4>
                        <p className="text-sm text-gray-700 leading-relaxed">
                          {g.description}
                        </p>
                      </div>
                    ))}
                  </TabsContent>

                  <TabsContent value="scores" className="mt-4 space-y-3">
                    {[
                      { label: "연애운", score: result.loveScore, icon: Heart },
                      {
                        label: "결혼운",
                        score: result.marriageScore,
                        icon: Home,
                      },
                      {
                        label: "동업운",
                        score: result.businessScore,
                        icon: Briefcase,
                      },
                    ].map((item, idx) => (
                      <div key={item.label} className="flex items-center gap-4">
                        <item.icon className="w-5 h-5 text-gray-600" />
                        <div className="flex-1">
                          <div className="flex justify-between items-center mb-1">
                            <span className="font-medium">{item.label}</span>
                            <span
                              className={`px-2 py-1 rounded-full text-sm font-medium ${getScoreColor(item.score)}`}
                            >
                              {item.score}점
                            </span>
                          </div>
                          <Progress value={item.score} className="h-2" />
                        </div>
                      </div>
                    ))}
                  </TabsContent>
                </Tabs>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-violet-300 text-violet-600 hover:bg-violet-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다시 분석하기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}
