"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
import {
  Star,
  Sparkles,
  Trophy,
  Heart,
  Search,
  TrendingUp,
  Calendar,
  Gift,
  ArrowRight,
  Shuffle,
} from "lucide-react";

interface CelebrityInfo {
  name: string;
  category: string;
}

interface CelebrityFortuneResult {
  celebrity: {
    name: string;
    category: string;
    description: string;
    emoji: string;
  };
  todayScore: number;
  weeklyScore: number;
  monthlyScore: number;
  summary: string;
  luckyTime: string;
  luckyColor: string;
  luckyItem: string;
  advice: string;
  predictions: {
    love: string;
    career: string;
    wealth: string;
    health: string;
  };
}

const popularCelebrities = [
  "아이유", "BTS", "블랙핑크", "손흥민", "박서준", "김고은", "유재석", "강호동",
  "태연", "뉴진스", "aespa", "스트레이키즈", "김연아", "박세리", "이병헌", "전지현"
];

export default function CelebrityFortunePage() {
  const [step, setStep] = useState<"input" | "result">("input");
  const [loading, setLoading] = useState(false);
  const [celebrityInfo, setCelebrityInfo] = useState<CelebrityInfo>({
    name: "",
    category: "",
  });
  const [result, setResult] = useState<CelebrityFortuneResult | null>(null);

  const generateFortune = async (info: CelebrityInfo): Promise<CelebrityFortuneResult> => {
    try {
      const response = await fetch('/api/fortune/celebrity', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          celebrity_name: info.name,
          user_name: "게스트",
          birth_date: new Date().toISOString().split('T')[0],
          category: info.category,
        }),
      });

      if (!response.ok) {
        throw new Error('운세 생성에 실패했습니다.');
      }

      const data = await response.json();
      return data.fortune || data;
    } catch (error) {
      console.error('GPT 연동 실패, 기본 데이터 사용:', error);
      
      // GPT 실패시 기본 로직
      const getCategory = (name: string): string => {
        if (name.includes("BTS") || name.includes("블랙핑크") || name.includes("뉴진스") || name.includes("aespa") || name.includes("스트레이키즈")) return "K-POP 그룹";
        if (["아이유", "태연", "박효신", "이승기"].includes(name)) return "가수";
        if (["손흥민", "김연아", "박세리", "류현진"].includes(name)) return "스포츠 스타";
        if (["박서준", "김고은", "이병헌", "전지현", "송중기", "박보영"].includes(name)) return "배우";
        if (["유재석", "강호동", "박나래", "김구라"].includes(name)) return "방송인";
        return "연예인";
      };

      const category = info.category || getCategory(info.name);
      
      const getEmoji = (category: string): string => {
        switch (category) {
          case "K-POP 그룹": return "🎤";
          case "가수": return "🎵";
          case "스포츠 스타": return "🏆";
          case "배우": return "🎭";
          case "방송인": return "📺";
          default: return "⭐";
        }
      };

      const descriptions = [
        "창의적이고 열정적인 에너지가 넘치는 시기입니다.",
        "안정적이고 꾸준한 성장을 이어가는 단계입니다.",
        "새로운 도전과 변화가 기다리는 흥미진진한 때입니다.",
        "내면의 힘을 발견하고 잠재력을 발휘하는 시기입니다.",
        "주변과의 조화를 이루며 영향력을 확대하는 단계입니다."
      ];

      return {
        celebrity: {
          name: info.name,
          category,
          description: descriptions[Math.floor(Math.random() * descriptions.length)],
          emoji: getEmoji(category),
        },
        todayScore: Math.floor(Math.random() * 30) + 70,
        weeklyScore: Math.floor(Math.random() * 30) + 70,
        monthlyScore: Math.floor(Math.random() * 30) + 70,
        summary: `${info.name}님의 운세는 전반적으로 상승세를 보이고 있습니다. 특히 창의적인 활동에서 좋은 결과를 얻을 수 있을 것입니다.`,
        luckyTime: "오후 3시 ~ 6시",
        luckyColor: "#FFD700",
        luckyItem: "골드 액세서리",
        advice: `${info.name}님처럼 꾸준한 노력과 진정성 있는 태도로 목표를 향해 나아가세요. 팬들과의 소통을 소중히 여기는 마음이 더 큰 성공을 가져다줄 것입니다.`,
        predictions: {
          love: "진정한 사랑을 만날 수 있는 기회가 생기며, 기존 관계에서도 더 깊은 유대감을 느낄 것입니다.",
          career: "새로운 프로젝트나 협업 기회가 찾아오며, 창의적인 아이디어가 큰 호응을 얻을 것입니다.",
          wealth: "꾸준한 활동의 결실로 안정적인 수입이 보장되고, 새로운 수익원도 생길 것입니다.",
          health: "규칙적인 생활과 적절한 휴식으로 컨디션이 좋아지며, 스트레스 관리가 중요합니다.",
        },
      };
    }
  };

  const handleSubmit = async () => {
    if (!celebrityInfo.name.trim()) {
      alert("유명인 이름을 입력해주세요.");
      return;
    }

    setLoading(true);
    try {
      await new Promise((r) => setTimeout(r, 2000));
      const res = await generateFortune(celebrityInfo);
      setResult(res);
      setStep("result");
    } catch (e) {
      console.error(e);
      alert("운세 분석 중 오류가 발생했습니다.");
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setStep("input");
    setResult(null);
    setCelebrityInfo({ name: "", category: "" });
  };

  const handlePopularCelebrity = (name: string) => {
    setCelebrityInfo(prev => ({ ...prev, name }));
  };

  return (
    <>
      <AppHeader title="유명인 운세" />
      <div className="pb-32 px-4 space-y-6 pt-4">
        <AnimatePresence mode="wait">
          {step === "input" && (
            <motion.div
              key="input"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.3 }}
              className="space-y-6"
            >
              <div className="text-center mb-6">
                <h1 className="text-2xl font-bold text-gray-800 mb-2">
                  유명인 운세
                </h1>
                <p className="text-gray-600">
                  좋아하는 유명인의 오늘 운세를 확인해보세요
                </p>
              </div>

              <Card className="border-blue-200">
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-blue-700">
                    <Search className="w-5 h-5" />
                    유명인 검색
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label htmlFor="celebrityName">
                      유명인 이름 <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      id="celebrityName"
                      placeholder="예: 아이유, BTS, 손흥민, 박서준..."
                      value={celebrityInfo.name}
                      onChange={(e) => setCelebrityInfo(prev => ({ ...prev, name: e.target.value }))}
                    />
                  </div>

                  {/* 인기 유명인 빠른 선택 */}
                  <div>
                    <Label className="text-sm text-gray-600 mb-2 block">
                      인기 유명인 빠른 선택
                    </Label>
                    <div className="flex flex-wrap gap-2">
                      {popularCelebrities.map((name) => (
                        <Badge
                          key={name}
                          variant="outline"
                          className="cursor-pointer hover:bg-blue-50 hover:border-blue-300"
                          onClick={() => handlePopularCelebrity(name)}
                        >
                          {name}
                        </Badge>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Button
                onClick={handleSubmit}
                disabled={loading}
                className="w-full bg-gradient-to-r from-blue-500 to-indigo-500 hover:from-blue-600 hover:to-indigo-600 text-white py-3 text-lg"
              >
                {loading ? (
                  <div className="flex items-center gap-2">
                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                    운세 분석 중...
                  </div>
                ) : (
                  <div className="flex items-center gap-2">
                    운세 보기
                    <ArrowRight className="w-5 h-5" />
                  </div>
                )}
              </Button>
            </motion.div>
          )}

          {step === "result" && result && (
            <motion.div
              key="result"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
              transition={{ duration: 0.3 }}
              className="space-y-6"
            >
              {/* 유명인 정보 */}
              <Card className="bg-gradient-to-br from-purple-50 to-pink-50 border-purple-200">
                <CardHeader className="text-center">
                  <div className="text-6xl mb-4">{result.celebrity.emoji}</div>
                  <CardTitle className="text-2xl text-purple-800">
                    {result.celebrity.name}
                  </CardTitle>
                  <Badge className="bg-purple-100 text-purple-700">
                    {result.celebrity.category}
                  </Badge>
                </CardHeader>
                <CardContent className="text-center">
                  <p className="text-purple-700 leading-relaxed">
                    {result.celebrity.description}
                  </p>
                </CardContent>
              </Card>

              {/* 종합 운세 점수 */}
              <Card className="bg-gradient-to-br from-yellow-50 to-orange-50 border-yellow-200">
                <CardHeader className="text-center">
                  <CardTitle className="flex items-center justify-center gap-2 text-yellow-800">
                    <Star className="w-6 h-6" />
                    오늘의 종합 운세
                  </CardTitle>
                  <div className="text-4xl font-bold text-yellow-600">
                    {result.todayScore}점
                  </div>
                </CardHeader>
                <CardContent>
                  <Progress value={result.todayScore} className="mb-4" />
                  <p className="text-center text-yellow-700 leading-relaxed">
                    {result.summary}
                  </p>
                </CardContent>
              </Card>

              {/* 기간별 점수 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <TrendingUp className="w-5 h-5" />
                    기간별 운세
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="grid grid-cols-3 gap-4 text-center">
                    <div>
                      <div className="text-2xl font-bold text-blue-600">{result.todayScore}</div>
                      <div className="text-sm text-gray-600">오늘</div>
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-purple-600">{result.weeklyScore}</div>
                      <div className="text-sm text-gray-600">이번 주</div>
                    </div>
                    <div>
                      <div className="text-2xl font-bold text-pink-600">{result.monthlyScore}</div>
                      <div className="text-sm text-gray-600">이번 달</div>
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* 행운의 정보 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Sparkles className="w-5 h-5 text-yellow-600" />
                    행운의 정보
                  </CardTitle>
                </CardHeader>
                <CardContent className="grid grid-cols-2 gap-4">
                  <div className="text-center p-3 bg-yellow-50 rounded-lg">
                    <Calendar className="w-5 h-5 mx-auto mb-2 text-yellow-600" />
                    <div className="text-sm text-gray-600 mb-1">행운의 시간</div>
                    <div className="font-medium">{result.luckyTime}</div>
                  </div>
                  <div className="text-center p-3 bg-blue-50 rounded-lg">
                    <Gift className="w-5 h-5 mx-auto mb-2 text-blue-600" />
                    <div className="text-sm text-gray-600 mb-1">행운의 아이템</div>
                    <div className="font-medium">{result.luckyItem}</div>
                  </div>
                </CardContent>
              </Card>

              {/* 조언 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2">
                    <Heart className="w-5 h-5 text-red-500" />
                    오늘의 조언
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="leading-relaxed text-gray-700">{result.advice}</p>
                </CardContent>
              </Card>

              {/* 분야별 예측 */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-pink-600">
                      <Heart className="w-4 h-4" />
                      연애운
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm leading-relaxed">{result.predictions.love}</p>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <Trophy className="w-4 h-4" />
                      사업운
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm leading-relaxed">{result.predictions.career}</p>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <Star className="w-4 h-4" />
                      재물운
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm leading-relaxed">{result.predictions.wealth}</p>
                  </CardContent>
                </Card>

                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-orange-600">
                      <Sparkles className="w-4 h-4" />
                      건강운
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm leading-relaxed">{result.predictions.health}</p>
                  </CardContent>
                </Card>
              </div>

              {/* 다시하기 버튼 */}
              <Button
                onClick={handleReset}
                variant="outline"
                className="w-full"
              >
                <Shuffle className="w-4 h-4 mr-2" />
                다른 유명인 운세 보기
              </Button>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </>
  );
} 