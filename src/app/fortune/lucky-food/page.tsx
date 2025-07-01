"use client";

import { useState, useEffect } from "react";
// import { useSearchParams } from "next/navigation";
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
  UtensilsCrossed, 
  ChefHat, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Heart,
  Clock,
  Award,
  Apple,
  Coffee,
  Cookie,
  Fish,
  Pizza,
  Soup,
  Salad,
  Beef,
  Carrot,
  Cherry,
  Calendar
} from "lucide-react";

interface FoodInfo {
  name: string;
  birth_date: string;
  favorite_cuisines: string[];
  disliked_foods: string[];
  dietary_restrictions: string[];
  meal_frequency: string;
  cooking_level: string;
  favorite_flavors: string[];
  meal_timing: string[];
  health_goals: string[];
  budget_preference: string;
  special_occasions: string;
  food_wishes: string;
}

interface FoodFortune {
  overall_luck: number;
  health_luck: number;
  wealth_luck: number;
  love_luck: number;
  career_luck: number;
  lucky_foods: {
    main_dish: string;
    side_dish: string;
    beverage: string;
    dessert: string;
    snack: string;
  };
  lucky_ingredients: string[];
  lucky_cooking_methods: string[];
  meal_timing_guide: {
    breakfast: string;
    lunch: string;
    dinner: string;
    snack_time: string;
  };
  weekly_menu: {
    [key: string]: {
      breakfast: string;
      lunch: string;
      dinner: string;
      special_note: string;
    };
  };
  food_rituals: string[];
  health_benefits: string[];
  wealth_foods: string[];
  love_foods: string[];
  avoid_foods: string[];
}

const cuisineTypes = [
  "한식", "중식", "일식", "양식", "이탈리안", "프렌치", "멕시칸", "인도", 
  "태국", "베트남", "브라질", "스페인", "터키", "모로코", "퓨전", "베이커리"
];

const dietaryRestrictions = [
  "없음", "채식주의", "비건", "할랄", "코셔", "글루텐프리", "유당불내증", 
  "견과류 알레르기", "해산물 알레르기", "저염식", "저당식", "키토제닉"
];

const favoriteFlavorProfiles = [
  "달콤한", "짠맛", "매운맛", "신맛", "쓴맛", "감칠맛", "고소한", "상큼한",
  "진한", "담백한", "향신료", "허브", "발효", "훈제", "구이", "찜"
];

const healthGoals = [
  "체중감량", "근육증가", "면역력강화", "피부개선", "소화개선", "스트레스해소",
  "에너지증진", "집중력향상", "수면개선", "항산화", "해독", "혈관건강"
];

const mealTimings = [
  "새벽(5-7시)", "아침(7-9시)", "오전(9-11시)", "점심(11-14시)", 
  "오후(14-17시)", "저녁(17-20시)", "밤(20-23시)", "심야(23-2시)"
];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 dark:text-green-400 bg-green-50 dark:bg-green-900/30";
  if (score >= 70) return "text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30";
  if (score >= 55) return "text-orange-600 dark:text-orange-400 bg-orange-50 dark:bg-orange-900/30";
  return "text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/30";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "맛있는 대운";
  if (score >= 70) return "풍성한 운세";
  if (score >= 55) return "안정적 식복";
  return "신중한 식단";
};

export default function LuckyFoodPage() {
  // const searchParams = useSearchParams();
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [formData, setFormData] = useState<FoodInfo>({
    name: '',
    birth_date: '',
    favorite_cuisines: [],
    disliked_foods: [],
    dietary_restrictions: [],
    meal_frequency: '',
    cooking_level: '',
    favorite_flavors: [],
    meal_timing: [],
    health_goals: [],
    budget_preference: '',
    special_occasions: '',
    food_wishes: ''
  });
  const [result, setResult] = useState<FoodFortune | null>(null);

  // URL에서 날짜 파라미터 가져오기 (임시 비활성화)
  useEffect(() => {
    // const dateParam = searchParams?.get('date');
    // if (dateParam) {
    //   setSelectedDate(dateParam);
    // } else {
      // 기본값은 오늘 날짜
      const today = new Date().toISOString().split('T')[0];
      setSelectedDate(today);
    // }
  }, []);

  const analyzeFoodFortune = async (): Promise<FoodFortune> => {
    const baseScore = Math.floor(Math.random() * 25) + 65;
    
    const luckyMainDishes = ["삼겹살", "갈비찜", "김치찌개", "파스타", "스테이크", "초밥", "짜장면", "카레"];
    const luckySideDishes = ["김치", "나물", "샐러드", "버섯볶음", "두부조림", "계란찜", "마카로니"];
    const luckyBeverages = ["녹차", "커피", "와인", "맥주", "스무디", "허브티", "생강차", "석류차"];
    const luckyDesserts = ["티라미수", "초콜릿케이크", "아이스크림", "과일타르트", "마카롱", "푸딩"];
    const luckySnacks = ["견과류", "과일", "요거트", "치즈", "다크초콜릿", "팝콘", "과자"];

    return {
      overall_luck: Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 15))),
      health_luck: Math.max(45, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 5)),
      wealth_luck: Math.max(40, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 10)),
      love_luck: Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 15))),
      career_luck: Math.max(55, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 5)),
      lucky_foods: {
        main_dish: luckyMainDishes[Math.floor(Math.random() * luckyMainDishes.length)],
        side_dish: luckySideDishes[Math.floor(Math.random() * luckySideDishes.length)],
        beverage: luckyBeverages[Math.floor(Math.random() * luckyBeverages.length)],
        dessert: luckyDesserts[Math.floor(Math.random() * luckyDesserts.length)],
        snack: luckySnacks[Math.floor(Math.random() * luckySnacks.length)]
      },
      lucky_ingredients: ["마늘", "생강", "고추", "참기름", "꿀", "레몬"].slice().sort(() => 0.5 - Math.random()).slice(0, 3),
      lucky_cooking_methods: ["볶음", "찜", "구이", "조림", "무침"].slice().sort(() => 0.5 - Math.random()).slice(0, 2),
      meal_timing_guide: {
        breakfast: "가벼운 과일과 견과류로 시작하세요",
        lunch: "든든한 식사로 에너지를 충전하세요",
        dinner: "소화 잘 되는 음식으로 마무리하세요",
        snack_time: "오후 3시경 달콤한 간식이 좋아요"
      },
      weekly_menu: {
        "월요일": {
          breakfast: "과일 요거트",
          lunch: "김치찌개",
          dinner: "생선구이",
          special_note: "새로운 한 주를 위한 에너지 충전"
        },
        "화요일": {
          breakfast: "토스트",
          lunch: "파스타",
          dinner: "샐러드",
          special_note: "가벼운 식단으로 몸의 균형 맞추기"
        },
        "수요일": {
          breakfast: "스무디",
          lunch: "비빔밥",
          dinner: "스테이크",
          special_note: "중간점검, 풍성한 영양 섭취"
        }
      },
      food_rituals: [
        "식사 전 감사 인사하기",
        "천천히 씹어서 먹기",
        "가족과 함께 식사하기",
        "새로운 요리 도전하기",
        "제철 식재료 사용하기"
      ],
      health_benefits: [
        "면역력 강화를 위한 비타민 C 섭취",
        "소화 개선을 위한 프로바이오틱스",
        "항산화 효과가 있는 베리류 섭취",
        "혈관 건강을 위한 오메가3",
        "뼈 건강을 위한 칼슘 보충"
      ],
      wealth_foods: ["견과류", "꿀", "포도", "닭고기", "계란"],
      love_foods: ["딸기", "초콜릿", "와인", "아보카도", "석류"],
      avoid_foods: ["과도한 카페인", "기름진 음식", "과당음료", "인스턴트식품"]
    };
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || formData.favorite_cuisines.length === 0) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeFoodFortune();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleCheckboxChange = (value: string, checked: boolean, field: keyof Pick<FoodInfo, 'favorite_cuisines' | 'disliked_foods' | 'dietary_restrictions' | 'favorite_flavors' | 'meal_timing' | 'health_goals'>) => {
    setFormData(prev => ({
      ...prev,
      [field]: checked 
        ? [...prev[field], value]
        : prev[field].filter(item => item !== value)
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      favorite_cuisines: [],
      disliked_foods: [],
      dietary_restrictions: [],
      meal_frequency: '',
      cooking_level: '',
      favorite_flavors: [],
      meal_timing: [],
      health_goals: [],
      budget_preference: '',
      special_occasions: '',
      food_wishes: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-pink-25 to-red-50 pb-32">
      <AppHeader title="행운의 음식" />
      
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
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
              <div className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-rose-500 to-pink-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ scale: 1.1 }}
                  transition={{ duration: 0.3 }}
                >
                  <UtensilsCrossed className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">행운의 음식</h1>
                <p className="text-gray-600 dark:text-gray-400">맛있는 행운을 불러오는 당신만의 음식 운세</p>
                {selectedDate && (
                  <div className="mt-3 inline-flex items-center gap-2 px-4 py-2 bg-rose-100 dark:bg-rose-900/30 rounded-full">
                    <Calendar className="w-4 h-4 text-rose-600 dark:text-rose-400" />
                    <span className="text-sm font-medium text-rose-700 dark:text-rose-300">
                      {new Date(selectedDate).toLocaleDateString('ko-KR', { 
                        year: 'numeric', 
                        month: 'long', 
                        day: 'numeric',
                        weekday: 'short'
                      })} 운세
                    </span>
                  </div>
                )}
              </div>

              {/* 기본 정보 */}
              <Card className="border-rose-200">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-rose-700">
                    <Apple className="w-5 h-5" />
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
                </CardContent>
              </Card>

              {/* 음식 취향 */}
              <Card className="border-pink-200">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-pink-700">
                    <Heart className="w-5 h-5" />
                    음식 취향
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label>선호하는 요리 종류 (복수 선택)</Label>
                    <div className="grid grid-cols-3 gap-2 mt-2">
                      {cuisineTypes.map((cuisine) => (
                        <div key={cuisine} className="flex items-center space-x-2">
                          <Checkbox
                            id={cuisine}
                            checked={formData.favorite_cuisines.includes(cuisine)}
                            onCheckedChange={(checked) => 
                              handleCheckboxChange(cuisine, checked as boolean, 'favorite_cuisines')
                            }
                          />
                          <Label htmlFor={cuisine} className="text-sm">{cuisine}</Label>
                        </div>
                      ))}
                    </div>
                  </div>
                  <div>
                    <Label>선호하는 맛 (복수 선택)</Label>
                    <div className="grid grid-cols-3 gap-2 mt-2">
                      {favoriteFlavorProfiles.map((flavor) => (
                        <div key={flavor} className="flex items-center space-x-2">
                          <Checkbox
                            id={flavor}
                            checked={formData.favorite_flavors.includes(flavor)}
                            onCheckedChange={(checked) => 
                              handleCheckboxChange(flavor, checked as boolean, 'favorite_flavors')
                            }
                          />
                          <Label htmlFor={flavor} className="text-sm">{flavor}</Label>
                        </div>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* 식습관 */}
              <Card className="border-red-200">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-red-700">
                    <Clock className="w-5 h-5" />
                    식습관 & 건강 목표
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label>하루 식사 횟수</Label>
                    <RadioGroup 
                      value={formData.meal_frequency} 
                      onValueChange={(value) => setFormData(prev => ({ ...prev, meal_frequency: value }))}
                      className="mt-2"
                    >
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="2meals" id="2meals" />
                        <Label htmlFor="2meals">2끼 (아침 거르기)</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="3meals" id="3meals" />
                        <Label htmlFor="3meals">3끼 (규칙적)</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="5meals" id="5meals" />
                        <Label htmlFor="5meals">5끼 (간식 포함)</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="irregular" id="irregular" />
                        <Label htmlFor="irregular">불규칙적</Label>
                      </div>
                    </RadioGroup>
                  </div>
                  <div>
                    <Label>요리 실력</Label>
                    <RadioGroup 
                      value={formData.cooking_level} 
                      onValueChange={(value) => setFormData(prev => ({ ...prev, cooking_level: value }))}
                      className="mt-2"
                    >
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="professional" id="professional" />
                        <Label htmlFor="professional">전문가 수준</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="advanced" id="advanced" />
                        <Label htmlFor="advanced">고급자</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="intermediate" id="intermediate" />
                        <Label htmlFor="intermediate">중급자</Label>
                      </div>
                      <div className="flex items-center space-x-2">
                        <RadioGroupItem value="beginner" id="beginner" />
                        <Label htmlFor="beginner">초보자</Label>
                      </div>
                    </RadioGroup>
                  </div>
                  <div>
                    <Label>건강 목표 (복수 선택)</Label>
                    <div className="grid grid-cols-3 gap-2 mt-2">
                      {healthGoals.map((goal) => (
                        <div key={goal} className="flex items-center space-x-2">
                          <Checkbox
                            id={goal}
                            checked={formData.health_goals.includes(goal)}
                            onCheckedChange={(checked) => 
                              handleCheckboxChange(goal, checked as boolean, 'health_goals')
                            }
                          />
                          <Label htmlFor={goal} className="text-sm">{goal}</Label>
                        </div>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* 추가 정보 */}
              <Card className="border-rose-200">
                <CardHeader className="pb-4">
                  <CardTitle className="flex items-center gap-2 text-rose-700">
                    <ChefHat className="w-5 h-5" />
                    추가 정보
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <Label htmlFor="special_occasions">특별한 날 선호 음식</Label>
                    <Input
                      id="special_occasions"
                      placeholder="예: 생일에는 케이크, 기념일에는 스테이크..."
                      value={formData.special_occasions}
                      onChange={(e) => setFormData(prev => ({ ...prev, special_occasions: e.target.value }))}
                      className="mt-1"
                    />
                  </div>
                  <div>
                    <Label htmlFor="food_wishes">음식과 관련된 소원이나 목표</Label>
                    <Textarea
                      id="food_wishes"
                      placeholder="건강한 식습관 만들기, 새로운 요리 배우기, 맛집 탐방 등..."
                      value={formData.food_wishes}
                      onChange={(e) => setFormData(prev => ({ ...prev, food_wishes: e.target.value }))}
                      className="mt-1 min-h-[80px]"
                    />
                  </div>
                </CardContent>
              </Card>

              {/* 분석 버튼 */}
              <div className="pt-4">
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
                      <UtensilsCrossed className="w-5 h-5" />
                      음식 운세 분석하기
                    </div>
                  )}
                </Button>
              </div>
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
              {/* 전체 운세 */}
              <Card className="bg-gradient-to-r from-rose-500 to-pink-500 text-white">
                <CardContent className="text-center py-8">
                  <div className="flex items-center justify-center gap-2 mb-4">
                    <UtensilsCrossed className="w-6 h-6" />
                    <span className="text-xl font-medium">{formData.name}님의 음식 운세</span>
                  </div>
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    transition={{ delay: 0.3, type: "spring" }}
                    className="text-6xl font-bold mb-2"
                  >
                    {result.overall_luck}점
                  </motion.div>
                  <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                    {getLuckText(result.overall_luck)}
                  </Badge>
                </CardContent>
              </Card>

              {/* 세부 운세 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-rose-600">
                    <Star className="w-5 h-5" />
                    음식별 세부 운세
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  {[
                    { label: "건강운", score: result.health_luck, icon: Apple, desc: "몸에 좋은 음식을 통한 건강 증진" },
                    { label: "재물운", score: result.wealth_luck, icon: Cherry, desc: "음식 사업이나 투자를 통한 재운" },
                    { label: "연애운", score: result.love_luck, icon: Heart, desc: "음식을 통한 인연과 사랑의 운" },
                    { label: "사업운", score: result.career_luck, icon: ChefHat, desc: "요리나 음식 관련 일에서의 성공운" }
                  ].map((item, index) => (
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
                            <span className={`px-3 py-1 rounded-full text-sm font-medium ${getLuckColor(item.score)}`}>
                              {item.score}점
                            </span>
                          </div>
                          <div className="w-full bg-gray-200 rounded-full h-2">
                            <motion.div
                              className="bg-rose-500 h-2 rounded-full"
                              initial={{ width: 0 }}
                              animate={{ width: `${item.score}%` }}
                              transition={{ delay: 0.5 + index * 0.1, duration: 0.8 }}
                            />
                          </div>
                        </div>
                      </div>
                    </motion.div>
                  ))}
                </CardContent>
              </Card>

              {/* 행운의 음식 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-pink-600">
                    <Award className="w-5 h-5" />
                    행운의 음식 라인업
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    {[
                      { label: "메인 요리", food: result.lucky_foods.main_dish, icon: Beef },
                      { label: "사이드 디시", food: result.lucky_foods.side_dish, icon: Salad },
                      { label: "음료", food: result.lucky_foods.beverage, icon: Coffee },
                      { label: "디저트", food: result.lucky_foods.dessert, icon: Cookie }
                    ].map((item, index) => (
                      <motion.div
                        key={item.label}
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.6 + index * 0.1 }}
                        className="p-4 bg-gradient-to-br from-pink-50 to-rose-50 rounded-lg"
                      >
                        <div className="flex items-center gap-2 mb-2">
                          <item.icon className="w-5 h-5 text-pink-600" />
                          <span className="font-medium text-pink-800">{item.label}</span>
                        </div>
                        <p className="text-gray-700 font-semibold">{item.food}</p>
                      </motion.div>
                    ))}
                  </div>
                  <div className="p-4 bg-gradient-to-r from-orange-50 to-yellow-50 rounded-lg">
                    <div className="flex items-center gap-2 mb-2">
                      <Sparkles className="w-5 h-5 text-orange-600" />
                      <span className="font-medium text-orange-800">특별 간식</span>
                    </div>
                    <p className="text-gray-700 font-semibold">{result.lucky_foods.snack}</p>
                  </div>
                </CardContent>
              </Card>

              {/* 행운의 재료 & 조리법 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-green-600">
                    <Carrot className="w-5 h-5" />
                    행운의 재료 & 조리법
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div>
                    <h4 className="font-medium text-gray-800 mb-2">행운의 재료</h4>
                    <div className="flex flex-wrap gap-2">
                      {result.lucky_ingredients.map((ingredient, index) => (
                        <Badge key={index} variant="secondary" className="bg-green-100 text-green-700">
                          {ingredient}
                        </Badge>
                      ))}
                    </div>
                  </div>
                  <div>
                    <h4 className="font-medium text-gray-800 mb-2">행운의 조리법</h4>
                    <div className="flex flex-wrap gap-2">
                      {result.lucky_cooking_methods.map((method, index) => (
                        <Badge key={index} variant="secondary" className="bg-blue-100 text-blue-700">
                          {method}
                        </Badge>
                      ))}
                    </div>
                  </div>
                </CardContent>
              </Card>

              {/* 식사 타이밍 가이드 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-indigo-600">
                    <Clock className="w-5 h-5" />
                    최적의 식사 타이밍
                  </CardTitle>
                </CardHeader>
                <CardContent className="space-y-3">
                  {Object.entries(result.meal_timing_guide).map(([time, guide], index) => (
                    <motion.div
                      key={time}
                      initial={{ opacity: 0, x: -10 }}
                      animate={{ opacity: 1, x: 0 }}
                      transition={{ delay: 0.8 + index * 0.1 }}
                      className="p-3 bg-indigo-50 rounded-lg"
                    >
                      <div className="flex items-center gap-2 mb-1">
                        <Clock className="w-4 h-4 text-indigo-600" />
                        <span className="font-medium text-indigo-800 capitalize">
                          {time === 'breakfast' ? '아침' : 
                           time === 'lunch' ? '점심' : 
                           time === 'dinner' ? '저녁' : '간식 시간'}
                        </span>
                      </div>
                      <p className="text-indigo-700 text-sm">{guide}</p>
                    </motion.div>
                  ))}
                </CardContent>
              </Card>

              {/* 음식 리추얼 */}
              <Card>
                <CardHeader>
                  <CardTitle className="flex items-center gap-2 text-purple-600">
                    <Sparkles className="w-5 h-5" />
                    행운을 부르는 음식 의식
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="space-y-2">
                    {result.food_rituals.map((ritual, index) => (
                      <motion.div
                        key={index}
                        initial={{ opacity: 0, x: -10 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 1.0 + index * 0.1 }}
                        className="flex items-start gap-2 p-3 bg-purple-50 rounded-lg"
                      >
                        <Star className="w-4 h-4 text-purple-500 mt-0.5 flex-shrink-0" />
                        <p className="text-purple-700 text-sm">{ritual}</p>
                      </motion.div>
                    ))}
                  </div>
                </CardContent>
              </Card>

              {/* 다시 분석하기 버튼 */}
              <div className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-rose-300 text-rose-600 hover:bg-rose-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 분석하기
                </Button>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 