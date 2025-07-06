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
  Gift, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Diamond,
  ShoppingBag,
  Heart,
  Crown,
  Gem,
  TreePine,
  Zap,
  Moon,
  Sun,
  Coins,
  Eye,
  Shield,
  Home,
  Car,
  Calendar,
  Clock,
  MapPin,
  TrendingUp,
  Flower,
  Coffee,
  Book,
  Music,
  Briefcase
} from "lucide-react";

import { createDeterministicRandom, getTodayDateString } from "@/lib/deterministic-random";
interface UserInfo {
  name: string;
  birth_date: string;
  zodiac_sign: string;
  color_preferences: string[];
  material_preferences: string[];
  wishes: string[];
  budget_range: string;
  usage_purpose: string;
  notes: string;
}

interface LuckyItem {
  name: string;
  category: string;
  description: string;
  luck_type: string[];
  price_range: string;
  where_to_use: string;
  special_effects: string;
  icon: any;
  color: string;
}

interface LuckyItemsResult {
  main_lucky_item: LuckyItem;
  secondary_items: LuckyItem[];
  color_recommendations: {
    primary_color: string;
    secondary_colors: string[];
    color_meaning: string;
  };
  timing_recommendations: {
    best_purchase_time: string;
    activation_time: string;
    usage_tips: string;
  };
  placement_guide: {
    home: string;
    work: string;
    personal: string;
  };
  maintenance_tips: string[];
  compatibility_score: number;
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

const zodiacSigns = [
  "양자리", "황소자리", "쌍둥이자리", "게자리", "사자자리", "처녀자리",
  "천칭자리", "전갈자리", "사수자리", "염소자리", "물병자리", "물고기자리"
];

const colorPreferences = [
  "빨강", "주황", "노랑", "초록", "파랑", "남색", "보라", "분홍", "검정", "흰색", "회색", "갈색"
];

const materialPreferences = [
  "금", "은", "구리", "크리스털", "자연석", "목재", "가죽", "실크", "면", "울", "플라스틱", "세라믹"
];

const wishCategories = [
  "연애운", "건강운", "재물운", "직장운", "학업운", "인간관계", "가족화합", "집중력 향상", "스트레스 해소", "자신감"
];

export default function LuckyItemsPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<UserInfo>({
    name: '',
    birth_date: '',
    zodiac_sign: '',
    color_preferences: [],
    material_preferences: [],
    wishes: [],
    budget_range: '',
    usage_purpose: '',
    notes: ''
  });
  const [result, setResult] = useState<LuckyItemsResult | null>(null);

  const analyzeLuckyItems = async (): Promise<LuckyItemsResult> => {
    const itemIcons = [Diamond, Gem, Crown, Star, Heart, Sparkles, Gift, TreePine];
    const items = [
      {
        name: "로즈쿼츠 목걸이",
        category: "액세서리",
        description: "사랑과 평화의 에너지를 담은 로즈쿼츠로 만든 목걸이로, 연애운과 인간관계 운을 높여줍니다.",
        luck_type: ["연애운", "인간관계"],
        price_range: "10-30만원",
        where_to_use: "일상생활, 중요한 만남",
        special_effects: "마음의 평화와 사랑의 에너지 증진",
        icon: Heart,
        color: "pink"
      },
      {
        name: "황금 시트린 반지",
        category: "액세서리",
        description: "재물운을 상징하는 시트린 원석이 박힌 황금 반지로, 금전운과 사업운을 향상시킵니다.",
        luck_type: ["재물운", "사업운"],
        price_range: "50-100만원",
        where_to_use: "직장, 사업 미팅",
        special_effects: "풍요로움과 성공의 기운 강화",
        icon: Crown,
        color: "yellow"
      },
      {
        name: "아메시스트 브레이슬릿",
        category: "액세서리",
        description: "집중력과 직관력을 높여주는 아메시스트로 만든 팔찌로, 학업운과 업무능력을 향상시킵니다.",
        luck_type: ["학업운", "집중력"],
        price_range: "20-50만원",
        where_to_use: "공부할 때, 중요한 업무",
        special_effects: "정신력 강화와 스트레스 완화",
        icon: Star,
        color: "purple"
      },
      {
        name: "터키석 부적",
        category: "부적",
        description: "액운을 막고 건강을 지켜주는 터키석 부적으로, 전반적인 행운을 불러옵니다.",
        luck_type: ["건강운", "액막이"],
        price_range: "5-15만원",
        where_to_use: "지갑, 가방 안",
        special_effects: "부정적 에너지 차단과 건강 보호",
        icon: Shield,
        color: "blue"
      },
      {
        name: "크리스털 장식품",
        category: "인테리어",
        description: "공간의 기운을 정화하고 긍정적 에너지를 만드는 크리스털 장식품입니다.",
        luck_type: ["공간정화", "전체운"],
        price_range: "30-80만원",
        where_to_use: "집, 사무실",
        special_effects: "환경 에너지 정화와 조화",
        icon: Diamond,
        color: "white"
      }
    ];

    const selectedMainItem = rng.randomElement(items);
    const remainingItems = items.filter(item => item !== selectedMainItem);
    const selectedSecondaryItems = remainingItems
      .sort(() => 0.5 - rng.random())
      .slice(0, 3);

    return {
      main_lucky_item: selectedMainItem,
      secondary_items: selectedSecondaryItems,
      color_recommendations: {
        primary_color: formData.color_preferences[0] || "초록",
        secondary_colors: formData.color_preferences.slice(1, 3),
        color_meaning: "당신의 선택한 색상은 안정감과 성장의 에너지를 나타내며, 지속적인 발전과 평화로운 마음을 가져다줍니다."
      },
      timing_recommendations: {
        best_purchase_time: "보름달이 뜨는 날이나 새로운 달이 시작되는 날",
        activation_time: "구매 후 3일 동안 매일 손에 들고 소원을 빌어주세요",
        usage_tips: "매일 아침 기상 후와 저녁 취침 전에 잠시 만져보며 긍정적인 마음을 가져보세요"
      },
      placement_guide: {
        home: "현관문에서 가장 가까운 곳이나 침실의 머리맡에 두시면 좋습니다",
        work: "책상 왼쪽 구석이나 자주 보이는 곳에 배치하여 지속적인 에너지를 받으세요",
        personal: "지갑이나 가방 안쪽 주머니에 넣어 항상 함께 다니시기 바랍니다"
      },
      maintenance_tips: [
        "한 달에 한 번 흐르는 물에 깨끗이 씻어주세요",
        "보름달이 뜨는 밤에 달빛에 노출시켜 에너지를 충전하세요",
        "부정적인 기운을 느낄 때는 소금물에 담가 정화해주세요",
        "사용하지 않을 때는 천이나 상자에 정중히 보관하세요"
      ],
      compatibility_score: rng.randomInt(0, 19) + 80
    };
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.zodiac_sign) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeLuckyItems();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleCheckboxChange = (category: keyof Pick<UserInfo, 'color_preferences' | 'material_preferences' | 'wishes'>, value: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      [category]: checked 
        ? [...prev[category], value]
        : prev[category].filter(item => item !== value)
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      zodiac_sign: '',
      color_preferences: [],
      material_preferences: [],
      wishes: [],
      budget_range: '',
      usage_purpose: '',
      notes: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-green-25 to-teal-50 pb-32">
      <AppHeader title="행운의 아이템" />
      
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
                  className="bg-gradient-to-r from-emerald-500 to-green-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Gift className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">행운의 아이템 추천</h1>
                <p className="text-gray-600 dark:text-gray-400">당신만을 위한 특별한 행운의 아이템을 찾아드립니다</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-emerald-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-emerald-700">
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

              {/* 선호도 */}
              <motion.div variants={itemVariants}>
                <Card className="border-green-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-green-700">
                      <Heart className="w-5 h-5" />
                      선호도
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div>
                      <Label className="text-base font-medium">좋아하는 색상 (복수 선택)</Label>
                      <div className="grid grid-cols-3 gap-2 mt-2">
                        {colorPreferences.map((color) => (
                          <div key={color} className="flex items-center space-x-2">
                            <Checkbox
                              id={`color-${color}`}
                              checked={formData.color_preferences.includes(color)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange('color_preferences', color, checked as boolean)
                              }
                            />
                            <Label htmlFor={`color-${color}`} className="text-sm">{color}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <Label className="text-base font-medium">선호하는 소재 (복수 선택)</Label>
                      <div className="grid grid-cols-3 gap-2 mt-2">
                        {materialPreferences.map((material) => (
                          <div key={material} className="flex items-center space-x-2">
                            <Checkbox
                              id={`material-${material}`}
                              checked={formData.material_preferences.includes(material)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange('material_preferences', material, checked as boolean)
                              }
                            />
                            <Label htmlFor={`material-${material}`} className="text-sm">{material}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 소원과 목적 */}
              <motion.div variants={itemVariants}>
                <Card className="border-emerald-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-emerald-700">
                      <Sparkles className="w-5 h-5" />
                      소원과 목적
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label className="text-base font-medium">이루고 싶은 소원 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {wishCategories.map((wish) => (
                          <div key={wish} className="flex items-center space-x-2">
                            <Checkbox
                              id={`wish-${wish}`}
                              checked={formData.wishes.includes(wish)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange('wishes', wish, checked as boolean)
                              }
                            />
                            <Label htmlFor={`wish-${wish}`} className="text-sm">{wish}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <Label>예산 범위</Label>
                      <RadioGroup 
                        value={formData.budget_range} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, budget_range: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="low" id="low" />
                          <Label htmlFor="low">10만원 이하</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="medium" id="medium" />
                          <Label htmlFor="medium">10-50만원</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="high" id="high" />
                          <Label htmlFor="high">50-100만원</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="premium" id="premium" />
                          <Label htmlFor="premium">100만원 이상</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>주요 사용 목적</Label>
                      <RadioGroup 
                        value={formData.usage_purpose} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, usage_purpose: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="daily" id="daily" />
                          <Label htmlFor="daily">일상 착용</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="special" id="special" />
                          <Label htmlFor="special">특별한 날</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="decoration" id="decoration" />
                          <Label htmlFor="decoration">인테리어 장식</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="collection" id="collection" />
                          <Label htmlFor="collection">소장용</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label htmlFor="notes">특별한 요청사항 (선택사항)</Label>
                      <Textarea
                        id="notes"
                        placeholder="특별히 원하는 것이나 피하고 싶은 것이 있다면 자유롭게 적어주세요..."
                        value={formData.notes}
                        onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
                        className="mt-2 min-h-[80px]"
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
                  className="w-full bg-gradient-to-r from-emerald-500 to-green-500 hover:from-emerald-600 hover:to-green-600 text-white py-6 text-lg font-semibold"
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
                      <Gift className="w-5 h-5" />
                      행운의 아이템 찾기
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
              {/* 메인 행운 아이템 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-emerald-500 to-green-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <result.main_lucky_item.icon className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 메인 행운 아이템</span>
                    </div>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className="mb-4"
                    >
                      <h2 className="text-3xl font-bold mb-2">{result.main_lucky_item.name}</h2>
                      <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                        {result.main_lucky_item.category}
                      </Badge>
                    </motion.div>
                    <p className="text-white/90 text-lg">{result.main_lucky_item.description}</p>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 메인 아이템 상세 정보 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-emerald-600">
                      <Star className="w-5 h-5" />
                      아이템 상세 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-4 bg-emerald-50 rounded-lg">
                        <h4 className="font-medium text-emerald-800 mb-2 flex items-center gap-2">
                          <Coins className="w-4 h-4" />
                          가격대
                        </h4>
                        <p className="text-emerald-700">{result.main_lucky_item.price_range}</p>
                      </div>
                      <div className="p-4 bg-green-50 rounded-lg">
                        <h4 className="font-medium text-green-800 mb-2 flex items-center gap-2">
                          <MapPin className="w-4 h-4" />
                          사용 장소
                        </h4>
                        <p className="text-green-700">{result.main_lucky_item.where_to_use}</p>
                      </div>
                    </div>
                    <div className="p-4 bg-teal-50 rounded-lg">
                      <h4 className="font-medium text-teal-800 mb-2 flex items-center gap-2">
                        <Sparkles className="w-4 h-4" />
                        특별한 효과
                      </h4>
                      <p className="text-teal-700">{result.main_lucky_item.special_effects}</p>
                    </div>
                    <div className="p-4 bg-blue-50 rounded-lg">
                      <h4 className="font-medium text-blue-800 mb-2 flex items-center gap-2">
                        <TrendingUp className="w-4 h-4" />
                        행운 분야
                      </h4>
                      <div className="flex flex-wrap gap-2">
                        {result.main_lucky_item.luck_type.map((type, index) => (
                          <Badge key={index} variant="outline" className="text-blue-700 border-blue-300">
                            {type}
                          </Badge>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 보조 아이템들 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <ShoppingBag className="w-5 h-5" />
                      추가 추천 아이템
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="grid gap-4">
                      {result.secondary_items.map((item, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, y: 20 }}
                          animate={{ opacity: 1, y: 0 }}
                          transition={{ delay: 0.4 + index * 0.1 }}
                          className="p-4 border border-gray-200 rounded-lg"
                        >
                          <div className="flex items-start gap-3">
                            <item.icon className="w-6 h-6 text-gray-600 mt-1" />
                            <div className="flex-1">
                              <h4 className="font-medium text-gray-900 mb-1">{item.name}</h4>
                              <p className="text-sm text-gray-600 mb-2">{item.description}</p>
                              <div className="flex items-center gap-4 text-xs text-gray-500">
                                <span>{item.price_range}</span>
                                <span>•</span>
                                <span>{item.category}</span>
                              </div>
                            </div>
                          </div>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 색상 추천 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Flower className="w-5 h-5" />
                      행운의 색상
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="p-4 bg-purple-50 rounded-lg">
                      <h4 className="font-medium text-purple-800 mb-2">주요 행운 색상</h4>
                      <p className="text-lg font-medium text-purple-700 mb-2">{result.color_recommendations.primary_color}</p>
                      <p className="text-purple-600 text-sm">{result.color_recommendations.color_meaning}</p>
                    </div>
                    {result.color_recommendations.secondary_colors.length > 0 && (
                      <div className="p-4 bg-indigo-50 rounded-lg">
                        <h4 className="font-medium text-indigo-800 mb-2">보조 색상</h4>
                        <div className="flex flex-wrap gap-2">
                          {result.color_recommendations.secondary_colors.map((color, index) => (
                            <Badge key={index} variant="outline" className="text-indigo-700 border-indigo-300">
                              {color}
                            </Badge>
                          ))}
                        </div>
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 타이밍 가이드 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-orange-600">
                      <Clock className="w-5 h-5" />
                      타이밍 가이드
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-orange-50 rounded-lg">
                        <h4 className="font-medium text-orange-800 mb-2 flex items-center gap-2">
                          <Calendar className="w-4 h-4" />
                          구매 최적 시기
                        </h4>
                        <p className="text-orange-700">{result.timing_recommendations.best_purchase_time}</p>
                      </div>
                      <div className="p-4 bg-amber-50 rounded-lg">
                        <h4 className="font-medium text-amber-800 mb-2 flex items-center gap-2">
                          <Zap className="w-4 h-4" />
                          활성화 방법
                        </h4>
                        <p className="text-amber-700">{result.timing_recommendations.activation_time}</p>
                      </div>
                      <div className="p-4 bg-yellow-50 rounded-lg">
                        <h4 className="font-medium text-yellow-800 mb-2 flex items-center gap-2">
                          <Sun className="w-4 h-4" />
                          사용 팁
                        </h4>
                        <p className="text-yellow-700">{result.timing_recommendations.usage_tips}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 배치 가이드 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <Home className="w-5 h-5" />
                      배치 가이드
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-blue-50 rounded-lg">
                        <h4 className="font-medium text-blue-800 mb-2 flex items-center gap-2">
                          <Home className="w-4 h-4" />
                          집에서
                        </h4>
                        <p className="text-blue-700">{result.placement_guide.home}</p>
                      </div>
                      <div className="p-4 bg-cyan-50 rounded-lg">
                        <h4 className="font-medium text-cyan-800 mb-2 flex items-center gap-2">
                          <Briefcase className="w-4 h-4" />
                          직장에서
                        </h4>
                        <p className="text-cyan-700">{result.placement_guide.work}</p>
                      </div>
                      <div className="p-4 bg-teal-50 rounded-lg">
                        <h4 className="font-medium text-teal-800 mb-2 flex items-center gap-2">
                          <Eye className="w-4 h-4" />
                          개인적으로
                        </h4>
                        <p className="text-teal-700">{result.placement_guide.personal}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 관리 방법 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <Shield className="w-5 h-5" />
                      관리 및 유지 방법
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-2">
                      {result.maintenance_tips.map((tip, index) => (
                        <motion.div
                          key={index}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: 0.6 + index * 0.1 }}
                          className="flex items-start gap-2"
                        >
                          <Star className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                          <p className="text-gray-700">{tip}</p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 궁합도 */}
              <motion.div variants={itemVariants}>
                <Card className="border-emerald-200">
                  <CardContent className="text-center py-6">
                    <h3 className="text-lg font-medium text-gray-900 mb-4">당신과의 궁합도</h3>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.5, type: "spring" }}
                      className="text-4xl font-bold text-emerald-600 mb-2"
                    >
                      {result.compatibility_score}%
                    </motion.div>
                    <p className="text-gray-600">훌륭한 궁합입니다!</p>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-emerald-300 text-emerald-600 hover:bg-emerald-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 아이템 찾기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 