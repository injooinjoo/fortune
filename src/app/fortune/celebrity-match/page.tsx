"use client";

import { useToast } from '@/hooks/use-toast';
import { logger } from '@/lib/logger';
import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { DeterministicRandom, getTodayDateString } from '@/lib/deterministic-random';
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
import {
  Select,
  SelectTrigger,
  SelectContent,
  SelectItem,
  SelectValue,
} from "@/components/ui/select";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import AppHeader from "@/components/AppHeader";
import {
  Heart,
  Sparkles,
  Users,
  Star,
  Smile,
  ArrowRight,
  Shuffle,
} from "lucide-react";

interface UserInfo {
  name: string;
  birthDate: string;
  celebrity: string;
}

interface CelebrityResult {
  score: number;
  comment: string;
  luckyColor: string;
  luckyItem: string;
}

const celebrities = [
  "아이유",
  "BTS 정국",
  "블랙핑크 지수",
  "손흥민",
  "유재석",
];

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

const getScoreText = (score: number) => {
  if (score >= 80) return "최고의 케미";
  if (score >= 60) return "좋은 케미";
  if (score >= 40) return "무난한 케미";
  return "웃픈 케미";
};

export default function CelebrityMatchPage() {
  const { toast } = useToast();
  const [step, setStep] = useState<"input" | "result">("input");
  const [loading, setLoading] = useState(false);
  const [info, setInfo] = useState<UserInfo>({
    name: "",
    birthDate: "",
    celebrity: "",
  });
  const [result, setResult] = useState<CelebrityResult | null>(null);

  const analyze = async (): Promise<CelebrityResult> => {
    try {
      const response = await fetch('/api/fortune/celebrity-match', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(info),
      });

      if (!response.ok) {
        throw new Error('연예인 궁합 분석에 실패했습니다.');
      }

      const data = await response.json();
      return data.analysis || data;
    } catch (error) {
      logger.error('GPT 연동 실패, 기본 데이터 사용:', error);
      
      // GPT 실패시 기본 로직
      // Initialize deterministic random for consistent daily results
      const rng = new DeterministicRandom(
        `${info.name}-${info.celebrity}`, // Combine both names for unique seed
        getTodayDateString(),
        'celebrity-match'
      );
      
      const score = rng.randomInt(20, 80); // 20 ~ 80
      const comments = [
        "이 조합, 팬미팅에서 자주 보게 될 운명?!",
        "마치 예능 한 장면 같은 케미입니다.",
        "친구로 지내기 딱 좋은 관계일지도 몰라요.",
        "이렇게 되면 온라인 밈이 될 수도?!",
      ];
      const items = ["마이크", "사인 앨범", "응원봉", "팬레터", "포토카드"];
      const colors = ["#F87171", "#FBBF24", "#34D399", "#60A5FA", "#A78BFA"];

      return {
        score,
        comment: rng.randomElement(comments),
        luckyColor: rng.randomElement(colors),
        luckyItem: rng.randomElement(items),
      };
    }
  };

  const handleSubmit = async () => {
    if (!info.name || !info.birthDate || !info.celebrity) {
      toast({
      title: "모든 정보를 입력해주세요.",
      variant: "default",
    });
      return;
    }
    setLoading(true);
    try {
      await new Promise((r) => setTimeout(r, 1500));
      const res = await analyze();
      setResult(res);
      setStep("result");
    } catch (e) {
      logger.error(e);
      toast({
      title: "분석 중 오류가 발생했습니다.",
      variant: "destructive",
    });
    } finally {
      setLoading(false);
    }
  };

  const handleReset = () => {
    setInfo({ name: "", birthDate: "", celebrity: "" });
    setResult(null);
    setStep("input");
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-white to-pink-50 pb-20">
      <AppHeader title="연예인 궁합" />
      <motion.div variants={containerVariants} initial="hidden" animate="visible" className="px-6 pt-6">
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
                  className="bg-gradient-to-r from-rose-500 to-pink-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Smile className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">연예인 궁합</h1>
                <p className="text-gray-600">최애와 나의 케미를 확인해보세요</p>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card className="border-rose-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-rose-700">
                      <Users className="w-5 h-5" />
                      나의 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="name">이름</Label>
                      <Input
                        id="name"
                        placeholder="이름을 입력하세요"
                        value={info.name}
                        onChange={(e) => setInfo((prev) => ({ ...prev, name: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <KoreanDatePicker
                        label="생년월일"
                        value={info.birthDate}
                        onChange={(date) => setInfo((prev) => ({ ...prev, birthDate: date }))}
                        placeholder="생년월일을 선택하세요"
                        required
                        className="mt-1"
                      />
                    </div>
                    <div>
                      <Label htmlFor="celebrity">좋아하는 연예인</Label>
                      <Select
                        value={info.celebrity}
                        onValueChange={(value) => setInfo((prev) => ({ ...prev, celebrity: value }))}
                      >
                        <SelectTrigger id="celebrity" className="mt-1">
                          <SelectValue placeholder="연예인을 선택하세요" />
                        </SelectTrigger>
                        <SelectContent>
                          {celebrities.map((c) => (
                            <SelectItem key={c} value={c}>
                              {c}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-rose-500 to-pink-500 hover:from-rose-600 hover:to-pink-600 text-white py-6 text-lg font-semibold"
                >
                  {loading ? (
                    <motion.div animate={{ rotate: 360 }} transition={{ repeat: Infinity, duration: 1 }} className="flex items-center gap-2">
                      <Shuffle className="w-5 h-5" />
                      분석 중...
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-5 h-5" />
                      궁합 보기
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
                <Card className="bg-gradient-to-r from-rose-500 to-pink-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <span className="text-xl font-medium">{info.name}</span>
                      <Heart className="w-6 h-6" />
                      <span className="text-xl font-medium">{info.celebrity}</span>
                    </div>
                    <motion.div initial={{ scale: 0 }} animate={{ scale: 1 }} transition={{ delay: 0.3, type: "spring" }} className="text-6xl font-bold mb-2">
                      {result.score}점
                    </motion.div>
                    <p className="text-white/90 text-lg">케미 지수</p>
                    <Badge variant="secondary" className="mt-2 bg-white/20 text-white border-white/30">
                      {getScoreText(result.score)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2">
                      <Star className="w-5 h-5 text-rose-600" />
                      한줄 코멘트
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-gray-700 leading-relaxed">{result.comment}</p>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-rose-600">
                      <Sparkles className="w-5 h-5" />
                      오늘의 행운
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="text-center p-3 bg-pink-50 rounded-lg">
                        <div
                          className="w-8 h-8 rounded-full mx-auto mb-2 border-2 border-white shadow"
                          style={{ backgroundColor: result.luckyColor }}
                        />
                        <p className="text-sm font-medium text-pink-800">행운의 색상</p>
                      </div>
                      <div className="text-center p-3 bg-pink-50 rounded-lg">
                        <div className="text-lg font-bold text-pink-800 mb-1">{result.luckyItem}</div>
                        <p className="text-sm font-medium text-pink-800">행운의 아이템</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button onClick={handleReset} variant="outline" className="w-full border-rose-300 text-rose-600 hover:bg-rose-50 py-3">
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다시 보기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}

