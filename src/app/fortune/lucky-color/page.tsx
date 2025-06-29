"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { FortuneResult } from "@/lib/schemas";
import { 
  Palette, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Heart,
  Crown,
  Sun,
  Moon,
  Home,
  Shirt,
  Share2,
  RotateCcw,
  CheckCircle
} from "lucide-react";

interface UserInfo {
  name: string;
  birth_date: string;
  current_mood: string;
  goals: string[];
  worries: string[];
}

interface LuckyColor {
  name: string;
  hex_code: string;
  description: string;
  luck_type: string[];
  best_time: string;
  emotional_effect: string;
  icon: any;
  element: string;
}

interface LuckyColorResult {
  main_lucky_color: LuckyColor;
  secondary_colors: LuckyColor[];
  color_combinations: {
    outfit: string[];
    home_decor: string[];
    accessories: string[];
  };
  compatibility_score: number;
  ai_insights: string;
}

export default function LuckyColorPage() {
  const [formData, setFormData] = useState<UserInfo>({
    name: "",
    birth_date: "",
    current_mood: "",
    goals: [],
    worries: []
  });
  
  const [result, setResult] = useState<LuckyColorResult | null>(null);
  
  // 최근 본 운세 추가를 위한 hook
  useFortuneStream();
  
  // 데일리 운세 관리를 위한 hook
  const {
    todayFortune,
    isLoading: isDailyLoading,
    isGenerating,
    hasTodayFortune,
    saveFortune,
    regenerateFortune,
    canRegenerate
  } = useDailyFortune({ fortuneType: 'lucky-color' });

  // 기존 운세가 있으면 자동으로 복원
  useEffect(() => {
    if (hasTodayFortune && todayFortune && !result) {
      const savedData = todayFortune.fortune_data as any;
      const metadata = savedData.metadata || {};
      
      // 저장된 폼 데이터 복원
      setFormData({
        name: savedData.user_info?.name || '',
        birth_date: savedData.user_info?.birth_date || '',
        current_mood: metadata.current_mood || '',
        goals: metadata.goals || [],
        worries: metadata.worries || []
      });
      
      // 운세 결과 복원
      if (metadata.complete_result) {
        setResult(metadata.complete_result);
      }
    }
  }, [hasTodayFortune, todayFortune, result]);

  const getZodiacSign = (birthDate: string) => {
    const date = new Date(birthDate);
    const month = date.getMonth() + 1;
    const day = date.getDate();
    
    if ((month === 3 && day >= 21) || (month === 4 && day <= 19)) return '양자리';
    if ((month === 4 && day >= 20) || (month === 5 && day <= 20)) return '황소자리';
    if ((month === 5 && day >= 21) || (month === 6 && day <= 20)) return '쌍둥이자리';
    if ((month === 6 && day >= 21) || (month === 7 && day <= 22)) return '게자리';
    if ((month === 7 && day >= 23) || (month === 8 && day <= 22)) return '사자자리';
    if ((month === 8 && day >= 23) || (month === 9 && day <= 22)) return '처녀자리';
    if ((month === 9 && day >= 23) || (month === 10 && day <= 22)) return '천칭자리';
    if ((month === 10 && day >= 23) || (month === 11 && day <= 21)) return '전갈자리';
    if ((month === 11 && day >= 22) || (month === 12 && day <= 21)) return '사수자리';
    if ((month === 12 && day >= 22) || (month === 1 && day <= 19)) return '염소자리';
    if ((month === 1 && day >= 20) || (month === 2 && day <= 18)) return '물병자리';
    return '물고기자리';
  };

  const zodiacColors: Record<string, { color: string; emotion: string; element: string }> = {
    '양자리': { color: '#FF6B6B', emotion: '열정적인', element: '불' },
    '황소자리': { color: '#4ECDC4', emotion: '안정적인', element: '땅' },
    '쌍둥이자리': { color: '#45B7D1', emotion: '활발한', element: '공기' },
    '게자리': { color: '#F9CA24', emotion: '따뜻한', element: '물' },
    '사자자리': { color: '#F0932B', emotion: '당당한', element: '불' },
    '처녀자리': { color: '#DDA0DD', emotion: '세심한', element: '땅' },
    '천칭자리': { color: '#FFB6C1', emotion: '우아한', element: '공기' },
    '전갈자리': { color: '#8E44AD', emotion: '신비로운', element: '물' },
    '사수자리': { color: '#E17055', emotion: '모험적인', element: '불' },
    '염소자리': { color: '#6C5CE7', emotion: '진중한', element: '땅' },
    '물병자리': { color: '#00B894', emotion: '독창적인', element: '공기' },
    '물고기자리': { color: '#81ECEC', emotion: '감성적인', element: '물' }
  };

  const moodColors: Record<string, string> = {
    '기쁨': 'bright',
    '우울': 'warm', 
    '불안': 'calm',
    '화남': 'cool',
    '설렘': 'pastel',
    '피곤': 'energetic',
    '외로움': 'comforting',
    '평온': 'natural'
  };

  const analyzeColors = (): LuckyColorResult => {
    const zodiac = getZodiacSign(formData.birth_date);
    const zodiacInfo = zodiacColors[zodiac];

    const emotionalColors: LuckyColor[] = [
      {
        name: "사랑의 로즈 핑크",
        hex_code: "#FFB6C1",
        description: `${formData.name}님의 마음을 따뜻하게 감싸주는 색깔이에요. 외로움을 달래고 사랑받는 느낌을 줄 거예요.`,
        luck_type: ["사랑운", "인연운", "위로"],
        best_time: "외로움을 느낄 때, 사랑이 필요할 때",
        emotional_effect: "따뜻함과 안전함, 사랑받는 느낌",
        icon: Heart,
        element: "감정"
      },
      {
        name: "희망의 햇살 옐로우",
        hex_code: "#FFD93D",
        description: `꿈을 향해 나아가는 ${formData.name}님에게 희망과 용기를 주는 색깔이에요. 포기하지 마세요, 충분히 빛날 수 있어요.`,
        luck_type: ["성공운", "자신감", "희망"],
        best_time: "용기가 필요할 때, 꿈을 품을 때",
        emotional_effect: "희망과 용기, 긍정적 에너지",
        icon: Sun,
        element: "의지"
      },
      {
        name: "평온한 바다 블루",
        hex_code: zodiacInfo.color,
        description: `${zodiac} ${formData.name}님의 ${zodiacInfo.emotion} 성격에 딱 맞는 색깔이에요. 마음의 평화와 안정을 찾을 수 있을 거예요.`,
        luck_type: ["안정운", "평화", "집중력"],
        best_time: "집중이 필요할 때, 마음의 평화가 필요할 때",
        emotional_effect: "차분함과 집중력, 내적 평화",
        icon: Moon,
        element: zodiacInfo.element
      }
    ];

    let mainColor = emotionalColors[0];
    if (formData.goals.includes('자신감') || formData.goals.includes('성공')) {
      mainColor = emotionalColors[1];
    } else if (formData.goals.includes('평화') || formData.goals.includes('안정')) {
      mainColor = emotionalColors[2];
    }

    const baseScore = 88;
    const moodBonus = Object.keys(moodColors).includes(formData.current_mood) ? 5 : 0;
    const goalBonus = formData.goals.length * 2;
    const compatibilityScore = Math.min(99, baseScore + moodBonus + goalBonus);

    return {
      main_lucky_color: mainColor,
      secondary_colors: emotionalColors.filter(c => c !== mainColor),
      color_combinations: {
        outfit: [
          `${mainColor.name} 상의 + 화이트 하의`,
          `${mainColor.name} 액세서리 + 네이비 옷`,
          `${mainColor.name} 가방 + 베이지 톤 코디`
        ],
        home_decor: [
          `${mainColor.name} 쿠션이나 담요`,
          `${mainColor.name} 꽃이나 소품`,
          `${mainColor.name} 조명이나 캔들`
        ],
        accessories: [
          `${mainColor.name} 스카프나 목도리`,
          `${mainColor.name} 폰케이스`,
          `${mainColor.name} 머리끈이나 헤어핀`
        ]
      },
      compatibility_score: compatibilityScore,
      ai_insights: `${formData.name}님은 ${zodiac}로 ${zodiacInfo.emotion} 성향을 가지고 계시네요. 현재 ${formData.current_mood} 상태이시군요. ${mainColor.name}은 당신의 마음을 따뜻하게 위로해주고 앞으로 나아가는 데 도움이 될 것입니다. 걱정하지 마세요, 당신은 충분히 사랑받을 자격이 있고 빛날 수 있어요! 💝`
    };
  };

  const handleAnalyze = async () => {
    if (!formData.name || !formData.birth_date || !formData.current_mood) {
      alert('이름, 생년월일, 현재 기분을 모두 입력해주세요.');
      return;
    }

    try {
      // 기존 운세가 있으면 불러오기
      if (hasTodayFortune && todayFortune) {
        const savedData = todayFortune.fortune_data as any;
        const metadata = savedData.metadata || {};
        
        if (metadata.complete_result) {
          setResult(metadata.complete_result);
          return;
        }
      }

      // 새로운 운세 생성
      await new Promise(resolve => setTimeout(resolve, 1500));
      const colorResult = analyzeColors();
      
      // FortuneResult 형식으로 변환
      const fortuneResult: FortuneResult = {
        user_info: {
          name: formData.name,
          birth_date: formData.birth_date,
        },
        fortune_scores: {
          compatibility_score: colorResult.compatibility_score
        },
        insights: {
          ai_insights: colorResult.ai_insights,
          main_color: colorResult.main_lucky_color.name,
          main_color_description: colorResult.main_lucky_color.description
        },
        lucky_items: {
          main_color: colorResult.main_lucky_color.name,
          main_color_hex: colorResult.main_lucky_color.hex_code,
          outfit_suggestions: colorResult.color_combinations.outfit.join(', '),
          home_decor_suggestions: colorResult.color_combinations.home_decor.join(', '),
          accessories_suggestions: colorResult.color_combinations.accessories.join(', ')
        },
        metadata: {
          current_mood: formData.current_mood,
          goals: formData.goals,
          worries: formData.worries,
          complete_result: colorResult
        }
      };

      // DB에 저장
      const success = await saveFortune(fortuneResult);
      if (success) {
        setResult(colorResult);
      } else {
        alert('운세 저장에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  };

  const handleReset = () => {
    setResult(null);
    setFormData({
      name: "",
      birth_date: "",
      current_mood: "",
      goals: [],
      worries: []
    });
  };

  const handleShare = () => {
    if (result) {
      const shareText = `🎨 ${formData.name}님의 위로 색깔: ${result.main_lucky_color.name}\n${result.ai_insights}`;
      navigator.clipboard.writeText(shareText);
      alert('결과가 클립보드에 복사되었습니다!');
    }
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

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-indigo-100 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700">
      <AppHeader />
      
      <div className="container mx-auto px-4 pt-20 pb-8">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="max-w-4xl mx-auto"
        >
          <motion.div className="text-center mb-8">
            <div className="flex items-center justify-center gap-3 mb-4">
              <div className="p-3 bg-gradient-to-r from-purple-500 to-blue-500 rounded-full">
                <Palette className="w-8 h-8 text-white" />
              </div>
              <h1 className="text-4xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
                마음을 위로하는 색깔
              </h1>
            </div>
            <p className="text-gray-600 dark:text-gray-400 mb-2">요즘 마음이 복잡하고 불안하신가요?</p>
            <p className="text-gray-500 dark:text-gray-400 text-sm">당신만의 특별한 색깔이 따뜻한 위로를 전해드릴게요 💝</p>
          </motion.div>

          <AnimatePresence mode="wait">
            {!result ? (
              <motion.div
                key="form"
                variants={containerVariants}
                initial="hidden"
                animate="visible"
                exit="hidden"
                className="space-y-6"
              >
                <motion.div variants={itemVariants}>
                  <Card className="shadow-lg border-0 bg-white/80 dark:bg-gray-800/80 backdrop-blur-sm dark:border-gray-700">
                    <CardHeader>
                      <CardTitle className="flex items-center gap-2 text-purple-700 dark:text-purple-400">
                        <Star className="w-5 h-5" />
                        기본 정보
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                          <Label htmlFor="name" className="dark:text-gray-300">이름</Label>
                          <Input
                            id="name"
                            value={formData.name}
                            onChange={(e) => setFormData({...formData, name: e.target.value})}
                            placeholder="당신의 이름을 알려주세요"
                            className="border-purple-200 focus:border-purple-400"
                          />
                        </div>
                        <div>
                          <Label htmlFor="birth_date" className="dark:text-gray-300">생년월일</Label>
                          <Input
                            id="birth_date"
                            type="date"
                            value={formData.birth_date}
                            onChange={(e) => setFormData({...formData, birth_date: e.target.value})}
                            className="border-purple-200 focus:border-purple-400"
                          />
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>

                <motion.div variants={itemVariants}>
                  <Card className="shadow-lg border-0 bg-white/80 backdrop-blur-sm">
                    <CardHeader>
                      <CardTitle className="flex items-center gap-2 text-blue-700">
                        <Heart className="w-5 h-5" />
                        현재 마음 상태
                      </CardTitle>
                    </CardHeader>
                    <CardContent>
                      <Label className="text-sm text-gray-600 mb-3 block">지금 어떤 기분이신가요?</Label>
                      <RadioGroup 
                        value={formData.current_mood} 
                        onValueChange={(value) => setFormData({...formData, current_mood: value})}
                        className="grid grid-cols-2 md:grid-cols-4 gap-3"
                      >
                        {Object.keys(moodColors).map((mood) => (
                          <div key={mood} className="flex items-center space-x-2">
                            <RadioGroupItem value={mood} id={mood} />
                            <Label htmlFor={mood} className="text-sm">{mood}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </CardContent>
                  </Card>
                </motion.div>

                <motion.div variants={itemVariants}>
                  <Card className="shadow-lg border-0 bg-white/80 backdrop-blur-sm">
                    <CardHeader>
                      <CardTitle className="flex items-center gap-2 text-green-700">
                        <Sparkles className="w-5 h-5" />
                        바라는 것들
                      </CardTitle>
                    </CardHeader>
                    <CardContent className="space-y-4">
                      <div>
                        <Label className="text-sm text-gray-600 mb-3 block">요즘 이루고 싶은 목표가 있나요?</Label>
                        <div className="grid grid-cols-2 md:grid-cols-3 gap-3">
                          {['사랑', '성공', '건강', '평화', '자신감', '행복'].map((goal) => (
                            <div key={goal} className="flex items-center space-x-2">
                              <Checkbox
                                id={goal}
                                checked={formData.goals.includes(goal)}
                                onCheckedChange={(checked) => {
                                  if (checked) {
                                    setFormData({...formData, goals: [...formData.goals, goal]});
                                  } else {
                                    setFormData({...formData, goals: formData.goals.filter(g => g !== goal)});
                                  }
                                }}
                              />
                              <Label htmlFor={goal} className="text-sm">{goal}</Label>
                            </div>
                          ))}
                        </div>
                      </div>
                      
                      <div>
                        <Label htmlFor="worries">마음의 걱정거리 (선택사항)</Label>
                        <Textarea
                          id="worries"
                          placeholder="혹시 마음에 걱정이 있다면 편하게 적어주세요..."
                          value={formData.worries.join('\n')}
                          onChange={(e) => setFormData({...formData, worries: e.target.value.split('\n').filter(w => w.trim())})}
                          className="border-purple-200 focus:border-purple-400 resize-none"
                          rows={3}
                        />
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>

                <motion.div variants={itemVariants} className="text-center">
                  <Button 
                    onClick={handleAnalyze} 
                    disabled={isGenerating || isDailyLoading}
                    className="bg-gradient-to-r from-purple-500 to-blue-500 hover:from-purple-600 hover:to-blue-600 text-white px-8 py-3 rounded-full text-lg font-semibold shadow-lg"
                  >
                    {(isGenerating || isDailyLoading) ? (
                      <div className="flex items-center gap-2">
                        <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                        {hasTodayFortune ? '오늘의 색깔 불러오는 중...' : '당신만의 색깔을 찾는 중...'}
                      </div>
                    ) : (
                      <div className="flex items-center gap-2">
                        {hasTodayFortune ? (
                          <>
                            <CheckCircle className="w-5 h-5" />
                            오늘의 위로 색깔 보기
                          </>
                        ) : (
                          <>
                            <Sparkles className="w-5 h-5" />
                            나의 위로 색깔 찾기
                            <ArrowRight className="w-5 h-5" />
                          </>
                        )}
                      </div>
                    )}
                  </Button>
                </motion.div>
              </motion.div>
            ) : (
              <motion.div
                key="result"
                variants={containerVariants}
                initial="hidden"
                animate="visible"
                className="space-y-6"
              >
                <motion.div variants={itemVariants} className="text-center">
                  <div className="inline-flex items-center gap-2 bg-white/90 backdrop-blur-sm px-6 py-3 rounded-full shadow-lg mb-6">
                    <Crown className="w-6 h-6 text-yellow-500" />
                    <span className="font-semibold text-gray-800">호환도 {result.compatibility_score}%</span>
                    <Sparkles className="w-6 h-6 text-purple-500" />
                  </div>
                </motion.div>

                <motion.div variants={itemVariants}>
                  <Card className="shadow-xl border-0 bg-white/90 backdrop-blur-sm overflow-hidden">
                    <div 
                      className="h-32 relative"
                      style={{ backgroundColor: result.main_lucky_color.hex_code }}
                    >
                      <div className="absolute inset-0 bg-black/20"></div>
                      <div className="absolute bottom-4 left-6 right-6">
                        <h2 className="text-2xl font-bold text-white drop-shadow-lg">
                          {result.main_lucky_color.name}
                        </h2>
                        <p className="text-white/90 drop-shadow">{result.main_lucky_color.element} 원소</p>
                      </div>
                      <result.main_lucky_color.icon className="absolute top-4 right-6 w-8 h-8 text-white/80" />
                    </div>
                    <CardContent className="p-6">
                      <p className="text-lg text-gray-600 mb-4 leading-relaxed">{result.main_lucky_color.description}</p>
                      <div className="flex justify-center gap-2 mb-4 flex-wrap">
                        {result.main_lucky_color.luck_type.map((type) => (
                          <Badge key={type} variant="secondary">{type}</Badge>
                        ))}
                      </div>
                      <p className="text-sm text-gray-500 mb-2">언제: {result.main_lucky_color.best_time}</p>
                      <p className="text-sm text-gray-500">효과: {result.main_lucky_color.emotional_effect}</p>
                    </CardContent>
                  </Card>
                </motion.div>

                <motion.div variants={itemVariants}>
                  <Card className="shadow-lg border-0 bg-white/80 backdrop-blur-sm">
                    <CardHeader>
                      <CardTitle className="flex items-center gap-2 text-purple-600">
                        <Palette className="w-5 h-5" />
                        색깔 활용 가이드
                      </CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                        <div>
                          <h4 className="font-semibold mb-3 flex items-center gap-2">
                            <Shirt className="w-4 h-4" />
                            옷차림
                          </h4>
                          <ul className="space-y-2">
                            {result.color_combinations.outfit.map((outfit, index) => (
                              <li key={index} className="text-sm text-gray-600">• {outfit}</li>
                            ))}
                          </ul>
                        </div>
                        <div>
                          <h4 className="font-semibold mb-3 flex items-center gap-2">
                            <Home className="w-4 h-4" />
                            공간 꾸미기
                          </h4>
                          <ul className="space-y-2">
                            {result.color_combinations.home_decor.map((decor, index) => (
                              <li key={index} className="text-sm text-gray-600">• {decor}</li>
                            ))}
                          </ul>
                        </div>
                        <div>
                          <h4 className="font-semibold mb-3 flex items-center gap-2">
                            <Star className="w-4 h-4" />
                            액세서리
                          </h4>
                          <ul className="space-y-2">
                            {result.color_combinations.accessories.map((accessory, index) => (
                              <li key={index} className="text-sm text-gray-600">• {accessory}</li>
                            ))}
                          </ul>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>

                <motion.div variants={itemVariants}>
                  <Card className="shadow-lg border-0 bg-gradient-to-r from-purple-50 to-blue-50">
                    <CardHeader>
                      <CardTitle className="flex items-center gap-2 text-indigo-700">
                        <Heart className="w-5 h-5" />
                        AI가 전하는 따뜻한 메시지
                      </CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="bg-white/70 rounded-lg p-4 border border-indigo-200">
                        <p className="text-gray-700 leading-relaxed italic">
                          "{result.ai_insights}"
                        </p>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>

                <motion.div variants={itemVariants} className="flex gap-3 justify-center flex-wrap">
                  {canRegenerate && (
                    <Button
                      onClick={async () => {
                        try {
                          await new Promise(resolve => setTimeout(resolve, 1500));
                          const colorResult = analyzeColors();
                          
                          const fortuneResult: FortuneResult = {
                            user_info: {
                              name: formData.name,
                              birth_date: formData.birth_date,
                            },
                            fortune_scores: {
                              compatibility_score: colorResult.compatibility_score
                            },
                            insights: {
                              ai_insights: colorResult.ai_insights,
                              main_color: colorResult.main_lucky_color.name,
                              main_color_description: colorResult.main_lucky_color.description
                            },
                            lucky_items: {
                              main_color: colorResult.main_lucky_color.name,
                              main_color_hex: colorResult.main_lucky_color.hex_code,
                              outfit_suggestions: colorResult.color_combinations.outfit.join(', '),
                              home_decor_suggestions: colorResult.color_combinations.home_decor.join(', '),
                              accessories_suggestions: colorResult.color_combinations.accessories.join(', ')
                            },
                            metadata: {
                              current_mood: formData.current_mood,
                              goals: formData.goals,
                              worries: formData.worries,
                              complete_result: colorResult
                            }
                          };

                          const success = await regenerateFortune(fortuneResult);
                          if (success) {
                            setResult(colorResult);
                          }
                        } catch (error) {
                          console.error('재생성 중 오류:', error);
                          alert('색깔 재생성에 실패했습니다. 다시 시도해주세요.');
                        }
                      }}
                      disabled={isGenerating}
                      className="bg-gradient-to-r from-indigo-500 to-purple-500 hover:from-indigo-600 hover:to-purple-600 text-white flex items-center gap-2"
                    >
                      {isGenerating ? (
                        <>
                          <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                          재생성 중...
                        </>
                      ) : (
                        <>
                          <RotateCcw className="w-4 h-4" />
                          오늘 색깔 다시 생성하기
                        </>
                      )}
                    </Button>
                  )}
                  <Button 
                    onClick={handleReset}
                    variant="outline" 
                    className="flex items-center gap-2"
                  >
                    <Shuffle className="w-4 h-4" />
                    다시 분석하기
                  </Button>
                  <Button 
                    onClick={handleShare}
                    className="bg-gradient-to-r from-purple-500 to-blue-500 hover:from-purple-600 hover:to-blue-600 text-white flex items-center gap-2"
                  >
                    <Share2 className="w-4 h-4" />
                    결과 공유하기
                  </Button>
                </motion.div>
              </motion.div>
            )}
          </AnimatePresence>
        </motion.div>
      </div>
    </div>
  );
}
