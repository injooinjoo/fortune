"use client";

import { useState } from "react";
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
import {
  Shirt,
  ShoppingBag,
  Sparkles,
  Star,
  ArrowRight,
  Heart,
  Flower,
  Palette,
  Hat,
  Watch
} from "lucide-react";

interface StyleInfo {
  name: string;
  birth_date: string;
  zodiac_sign: string;
  preferred_styles: string[];
  favorite_colors: string[];
  occasion: string;
  notes: string;
}

interface OutfitStyle {
  style: string;
  colors: string[];
  items: string[];
  description: string;
  icon: any;
}

interface OutfitResult {
  main_outfit: OutfitStyle;
  accessory_tips: string[];
  color_message: string;
  styling_tips: string[];
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

const zodiacSigns = [
  "양자리", "황소자리", "쌍둥이자리", "게자리", "사자자리", "처녀자리",
  "천칭자리", "전갈자리", "사수자리", "염소자리", "물병자리", "물고기자리",
];

const styleOptions = [
  "캐주얼", "포멀", "스트릿", "로맨틱", "스포티", "미니멀",
];

const colorOptions = [
  "빨강", "주황", "노랑", "초록", "파랑", "남색", "보라", "분홍", "검정", "흰색",
  "회색", "갈색",
];

const occasionOptions = [
  "데일리", "데이트", "직장", "파티",
];

export default function LuckyOutfitPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<StyleInfo>({
    name: '',
    birth_date: '',
    zodiac_sign: '',
    preferred_styles: [],
    favorite_colors: [],
    occasion: '',
    notes: '',
  });
  const [result, setResult] = useState<OutfitResult | null>(null);

  const analyzeOutfit = async (): Promise<OutfitResult> => {
    const outfits: OutfitStyle[] = [
      {
        style: "모던 시크",
        colors: ["블랙", "화이트"],
        items: ["테일러드 재킷", "슬림 팬츠"],
        description: "세련되고 도회적인 분위기를 연출합니다",
        icon: Shirt,
      },
      {
        style: "로맨틱",
        colors: ["파스텔 핑크", "화이트"],
        items: ["플로럴 블라우스", "미디 스커트"],
        description: "부드럽고 사랑스러운 매력을 강조합니다",
        icon: Flower,
      },
      {
        style: "스트릿",
        colors: ["네온", "블랙"],
        items: ["오버사이즈 후디", "데님 팬츠"],
        description: "자유롭고 개성 넘치는 스타일",
        icon: Hat,
      },
      {
        style: "포멀",
        colors: ["네이비", "그레이"],
        items: ["정장 재킷", "셔츠", "슬랙스"],
        description: "중요한 자리에서 신뢰감을 주는 깔끔한 룩",
        icon: Watch,
      },
    ];

    const selected = outfits[Math.floor(Math.random() * outfits.length)];

    return {
      main_outfit: selected,
      accessory_tips: [
        "상의와 하의의 균형을 맞추는 액세서리를 활용하세요",
        "과한 장식보다는 포인트 아이템 하나로 집중하세요",
      ],
      color_message: `${selected.colors[0]} 색상이 오늘의 행운을 끌어당깁니다`,
      styling_tips: [
        "전체적인 톤을 맞추고, 작은 색상 포인트를 더해보세요",
        "자신감 있는 미소가 최고의 패션 완성입니다",
      ],
    };
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.zodiac_sign) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);

    try {
      await new Promise(resolve => setTimeout(resolve, 2000));
      const analysisResult = await analyzeOutfit();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleCheckboxChange = (
    category: keyof Pick<StyleInfo, 'preferred_styles' | 'favorite_colors'>,
    value: string,
    checked: boolean
  ) => {
    setFormData(prev => ({
      ...prev,
      [category]: checked
        ? [...prev[category], value]
        : prev[category].filter(item => item !== value),
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      zodiac_sign: '',
      preferred_styles: [],
      favorite_colors: [],
      occasion: '',
      notes: '',
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-indigo-50 via-purple-25 to-pink-50 pb-32">
      <AppHeader title="행운의 코디" />

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
                  className="bg-gradient-to-r from-indigo-500 to-pink-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <ShoppingBag className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 코디</h1>
                <p className="text-gray-600">오늘 당신에게 어울리는 패션을 찾아보세요</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-indigo-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-indigo-700">
                      <Star className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="name">이름</Label>
                        <Input
                          id="name"
                          placeholder="이름"
                          value={formData.name}
                          onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <Label htmlFor="birth_date">생년월일</Label>
                        <Input
                          id="birth_date"
                          type="date"
                          value={formData.birth_date}
                          onChange={(e) => setFormData(prev => ({ ...prev, birth_date: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
                    </div>
                    <div>
                      <Label>별자리</Label>
                      <RadioGroup
                        value={formData.zodiac_sign}
                        onValueChange={(value) => setFormData(prev => ({ ...prev, zodiac_sign: value }))}
                        className="mt-2 grid grid-cols-3 gap-2"
                      >
                        {zodiacSigns.map((sign) => (
                          <div key={sign} className="flex items-center space-x-2">
                            <RadioGroupItem value={sign} id={sign} />
                            <Label htmlFor={sign} className="text-sm">{sign}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 선호 스타일 */}
              <motion.div variants={itemVariants}>
                <Card className="border-purple-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-purple-700">
                      <Heart className="w-5 h-5" />
                      선호 스타일
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div>
                      <Label className="text-base font-medium">스타일 (복수 선택)</Label>
                      <div className="grid grid-cols-3 gap-2 mt-2">
                        {styleOptions.map((style) => (
                          <div key={style} className="flex items-center space-x-2">
                            <Checkbox
                              id={`style-${style}`}
                              checked={formData.preferred_styles.includes(style)}
                              onCheckedChange={(checked) =>
                                handleCheckboxChange('preferred_styles', style, checked as boolean)
                              }
                            />
                            <Label htmlFor={`style-${style}`} className="text-sm">{style}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <Label className="text-base font-medium">좋아하는 색상 (복수 선택)</Label>
                      <div className="grid grid-cols-3 gap-2 mt-2">
                        {colorOptions.map((color) => (
                          <div key={color} className="flex items-center space-x-2">
                            <Checkbox
                              id={`color-${color}`}
                              checked={formData.favorite_colors.includes(color)}
                              onCheckedChange={(checked) =>
                                handleCheckboxChange('favorite_colors', color, checked as boolean)
                              }
                            />
                            <Label htmlFor={`color-${color}`} className="text-sm">{color}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 목적 */}
              <motion.div variants={itemVariants}>
                <Card className="border-pink-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-pink-700">
                      <Sparkles className="w-5 h-5" />
                      코디 목적
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>목적</Label>
                      <RadioGroup
                        value={formData.occasion}
                        onValueChange={(value) => setFormData(prev => ({ ...prev, occasion: value }))}
                        className="mt-2 grid grid-cols-4 gap-2"
                      >
                        {occasionOptions.map((item) => (
                          <div key={item} className="flex items-center space-x-2">
                            <RadioGroupItem value={item} id={item} />
                            <Label htmlFor={item} className="text-sm">{item}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label htmlFor="notes">추가 메모</Label>
                      <Textarea
                        id="notes"
                        placeholder="특별히 고려하고 싶은 사항"
                        value={formData.notes}
                        onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
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
                  className="w-full bg-indigo-600 hover:bg-indigo-700 text-white py-3"
                >
                  {loading ? '분석 중...' : '행운의 코디 찾기'}
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
              {/* 메인 코디 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-indigo-500 to-pink-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <result.main_outfit.icon className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 행운 코디</span>
                    </div>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className="mb-4"
                    >
                      <h2 className="text-3xl font-bold mb-2">{result.main_outfit.style}</h2>
                      <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                        {result.main_outfit.items.join(', ')}
                      </Badge>
                    </motion.div>
                    <p className="text-white/90 text-lg">{result.main_outfit.description}</p>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 색상 메시지 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Palette className="w-5 h-5" />
                      행운의 색상
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className="text-gray-700">{result.color_message}</p>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 액세서리 팁 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-indigo-600">
                      <ShoppingBag className="w-5 h-5" />
                      액세서리 팁
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    {result.accessory_tips.map((tip, index) => (
                      <p key={index} className="text-gray-700">
                        - {tip}
                      </p>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 스타일링 팁 */}
              <motion.div variants={itemVariants}>
                <Card className="border-indigo-200">
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-indigo-600">
                      <Sparkles className="w-5 h-5" />
                      스타일링 팁
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-2">
                    {result.styling_tips.map((tip, index) => (
                      <p key={index} className="text-gray-700">
                        {tip}
                      </p>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-indigo-300 text-indigo-600 hover:bg-indigo-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 코디 보기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}

