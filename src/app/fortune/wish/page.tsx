"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import { DeterministicRandom } from '@/lib/deterministic-random';
import { 
  Star, 
  Heart, 
  Sparkles, 
  Target, 
  TrendingUp, 
  Home as HomeIcon,
  Users,
  GraduationCap,
  Coins,
  Briefcase,
  Plane,
  Crown,
  Calendar,
  Clock,
  Palette,
  MapPin,
  Send,
  CheckCircle,
  Lightbulb
} from "lucide-react";

interface Wish {
  id: string;
  content: string;
  category: string;
  probability: number;
  createdAt: string;
  isGranted: boolean;
}

const categories = [
  { id: "love", name: "연애", icon: Heart, color: "rose", gradient: "from-rose-500 to-pink-500" },
  { id: "career", name: "취업/승진", icon: Briefcase, color: "blue", gradient: "from-blue-500 to-indigo-500" },
  { id: "money", name: "금전", icon: Coins, color: "yellow", gradient: "from-yellow-500 to-orange-500" },
  { id: "health", name: "건강", icon: Target, color: "green", gradient: "from-green-500 to-emerald-500" },
  { id: "family", name: "가족", icon: Users, color: "purple", gradient: "from-purple-500 to-violet-500" },
  { id: "study", name: "학업", icon: GraduationCap, color: "indigo", gradient: "from-indigo-500 to-purple-500" },
  { id: "travel", name: "여행", icon: Plane, color: "cyan", gradient: "from-cyan-500 to-blue-500" },
  { id: "dream", name: "꿈/목표", icon: Crown, color: "amber", gradient: "from-amber-500 to-yellow-500" }
];

export default function WishPage() {
  // Initialize deterministic random for consistent results
  // Get actual user ID from auth context
  const { user } = useAuth();
  const userId = user?.id || 'guest-user';
  const today = new Date().toISOString().split('T')[0];
  const fortuneType = 'page';
  const deterministicRandom = new DeterministicRandom(userId, today, fortuneType);

  const [wishes, setWishes] = useState<Wish[]>([]);
  const [newWish, setNewWish] = useState("");
  const [selectedCategory, setSelectedCategory] = useState("love");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  useEffect(() => {
    const savedWishes = localStorage.getItem("fortune-wishes");
    if (savedWishes) {
      setWishes(JSON.parse(savedWishes));
    }
  }, []);

  const generateProbability = (category: string, content: string): number => {
    const baseProbability = {
      love: 75,
      career: 82,
      money: 68,
      health: 88,
      family: 85,
      study: 78,
      travel: 90,
      dream: 72
    }[category] || 75;

    const wishLength = content.length;
    const lengthBonus = Math.min(wishLength / 10, 5);
    
    return Math.min(95, Math.max(45, baseProbability + lengthBonus + deterministicRandom.random() * 10 - 5));
  };

  const handleSubmitWish = async () => {
    if (!newWish.trim()) return;

    setIsSubmitting(true);
    
    // 소원 제출 시뮬레이션
    await new Promise(resolve => setTimeout(resolve, 1500));

    const probability = generateProbability(selectedCategory, newWish);
    
    const wish: Wish = {
      id: Date.now().toString(),
      content: newWish,
      category: selectedCategory,
      probability: Math.round(probability),
      createdAt: new Date().toISOString(),
      isGranted: false
    };

    const updatedWishes = [wish, ...wishes];
    setWishes(updatedWishes);
    localStorage.setItem("fortune-wishes", JSON.stringify(updatedWishes));

    setNewWish("");
    setIsSubmitting(false);
    setShowSuccess(true);
    
    setTimeout(() => setShowSuccess(false), 3000);
  };

  const todayLuckyInfo = {
    time: "저녁 7시~9시",
    color: "골든 옐로우",
    direction: "남동쪽",
    number: 3,
    day: "목요일"
  };

  const wishTips = [
    "구체적이고 명확한 소원일수록 이루어질 확률이 높아집니다",
    "긍정적인 언어로 표현하면 우주의 에너지가 더 강하게 작용합니다",
    "진심을 담아 쓴 소원은 반드시 당신에게 돌아옵니다",
    "소원을 빌 때는 감사하는 마음을 함께 담아보세요"
  ];

  const successStories = [
    { category: "연애", story: "3개월 만에 운명의 상대를 만났어요!", probability: 89 },
    { category: "취업", story: "꿈꾸던 회사에 합격했습니다!", probability: 95 },
    { category: "건강", story: "건강검진 결과가 완전히 좋아졌어요!", probability: 92 }
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-yellow-50 pt-4">
      <AppHeader 
        title="소원빌기"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <div className="container mx-auto px-4 pb-24 pt-6">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="text-center mb-8"
        >
          <div className="inline-flex items-center gap-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white px-4 py-2 rounded-full text-sm font-medium mb-4">
            <Star className="h-4 w-4" />
            소원빌기
          </div>
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            ✨ 당신의 소원을 들려주세요
          </h1>
          <p className="text-gray-600">
            진심을 담은 소원은 반드시 이루어집니다
          </p>
        </motion.div>

        {/* 소원 작성 섹션 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
        >
          <Card className="mb-6 shadow-lg border-0 bg-white/80 backdrop-blur-sm">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Sparkles className="h-5 w-5 text-purple-500" />
                새로운 소원 빌기
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {/* 카테고리 선택 */}
              <div>
                <label className="text-sm font-medium text-gray-700 mb-3 block">
                  소원 카테고리
                </label>
                <div className="grid grid-cols-4 gap-2">
                  {categories.map((category) => {
                    const Icon = category.icon;
                    return (
                      <button
                        key={category.id}
                        onClick={() => setSelectedCategory(category.id)}
                        className={`p-3 rounded-xl transition-all duration-200 ${
                          selectedCategory === category.id
                            ? `bg-gradient-to-br ${category.gradient} text-white shadow-lg scale-105`
                            : "bg-gray-50 hover:bg-gray-100 text-gray-700"
                        }`}
                      >
                        <Icon className="h-5 w-5 mx-auto mb-1" />
                        <div className="text-xs font-medium">{category.name}</div>
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* 소원 입력 */}
              <div>
                <label className="text-sm font-medium text-gray-700 mb-2 block">
                  소원 내용
                </label>
                <Textarea
                  placeholder="구체적이고 진실한 소원을 적어주세요..."
                  value={newWish}
                  onChange={(e) => setNewWish(e.target.value)}
                  className="min-h-[100px] resize-none border-purple-200 focus:border-purple-400"
                  maxLength={200}
                />
                <div className="text-right text-xs text-gray-500 mt-1">
                  {newWish.length}/200
                </div>
              </div>

              <Button
                onClick={handleSubmitWish}
                disabled={!newWish.trim() || isSubmitting}
                className="w-full bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600 h-12"
              >
                {isSubmitting ? (
                  <div className="flex items-center gap-2">
                    <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                    소원을 우주로 보내는 중...
                  </div>
                ) : (
                  <div className="flex items-center gap-2">
                    <Send className="h-4 w-4" />
                    소원 빌기
                  </div>
                )}
              </Button>
            </CardContent>
          </Card>
        </motion.div>

        {/* 성공 메시지 */}
        <AnimatePresence>
          {showSuccess && (
            <motion.div
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.8 }}
              className="fixed inset-0 flex items-center justify-center z-50 bg-black/20"
            >
              <Card className="mx-4 p-6 bg-white shadow-2xl border-0">
                <div className="text-center">
                  <CheckCircle className="h-12 w-12 text-green-500 mx-auto mb-4" />
                  <h3 className="text-xl font-bold text-gray-900 mb-2">
                    소원이 전달되었습니다! ✨
                  </h3>
                  <p className="text-gray-600">
                    우주가 당신의 소원을 들었습니다
                  </p>
                </div>
              </Card>
            </motion.div>
          )}
        </AnimatePresence>

        {/* 오늘의 행운 정보 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <Card className="mb-6 shadow-lg border-0 bg-gradient-to-br from-yellow-50 to-orange-50">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Star className="h-5 w-5 text-yellow-500" />
                오늘의 소원 성취 행운 정보
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
                <div className="text-center">
                  <Clock className="h-6 w-6 text-yellow-500 mx-auto mb-2" />
                  <div className="text-sm text-gray-600 mb-1">행운의 시간</div>
                  <div className="font-semibold">{todayLuckyInfo.time}</div>
                </div>
                <div className="text-center">
                  <Palette className="h-6 w-6 text-yellow-500 mx-auto mb-2" />
                  <div className="text-sm text-gray-600 mb-1">행운의 색상</div>
                  <div className="font-semibold">{todayLuckyInfo.color}</div>
                </div>
                <div className="text-center">
                  <MapPin className="h-6 w-6 text-yellow-500 mx-auto mb-2" />
                  <div className="text-sm text-gray-600 mb-1">행운의 방향</div>
                  <div className="font-semibold">{todayLuckyInfo.direction}</div>
                </div>
                <div className="text-center">
                  <Crown className="h-6 w-6 text-yellow-500 mx-auto mb-2" />
                  <div className="text-sm text-gray-600 mb-1">행운의 숫자</div>
                  <div className="font-semibold">{todayLuckyInfo.number}</div>
                </div>
                <div className="text-center">
                  <Calendar className="h-6 w-6 text-yellow-500 mx-auto mb-2" />
                  <div className="text-sm text-gray-600 mb-1">행운의 요일</div>
                  <div className="font-semibold">{todayLuckyInfo.day}</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 소원 성취 팁 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <Card className="mb-6 shadow-lg border-0 bg-gradient-to-br from-blue-50 to-purple-50">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Lightbulb className="h-5 w-5 text-blue-500" />
                소원 성취 가이드
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid md:grid-cols-2 gap-4">
                {wishTips.map((tip, index) => (
                  <div key={index} className="flex items-start gap-3 p-3 bg-white/50 rounded-lg">
                    <div className="w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0">
                      {index + 1}
                    </div>
                    <p className="text-sm text-gray-700">{tip}</p>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 성공 사례 */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
        >
          <Card className="mb-6 shadow-lg border-0 bg-gradient-to-br from-green-50 to-emerald-50">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-green-500" />
                최근 이루어진 소원들
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {successStories.map((story, index) => (
                  <div key={index} className="flex items-center gap-4 p-4 bg-white/50 rounded-lg">
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-2">
                        <Badge variant="secondary" className="text-xs">
                          {story.category}
                        </Badge>
                        <div className="text-sm font-semibold text-green-600">
                          성취율 {story.probability}%
                        </div>
                      </div>
                      <p className="text-gray-700">{story.story}</p>
                    </div>
                    <CheckCircle className="h-6 w-6 text-green-500" />
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 내 소원 목록 */}
        {wishes.length > 0 && (
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5 }}
          >
            <Card className="shadow-lg border-0 bg-white/80 backdrop-blur-sm">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Heart className="h-5 w-5 text-rose-500" />
                  내가 빈 소원들
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {wishes.slice(0, 5).map((wish) => {
                    const category = categories.find(c => c.id === wish.category);
                    const Icon = category?.icon || Star;
                    
                    return (
                      <div key={wish.id} className="p-4 border border-gray-200 rounded-lg">
                        <div className="flex items-start justify-between mb-3">
                          <div className="flex items-center gap-2">
                            <Icon className={`h-4 w-4 text-${category?.color}-500`} />
                            <Badge variant="outline" className="text-xs">
                              {category?.name}
                            </Badge>
                          </div>
                          <div className="text-right">
                            <div className="text-sm font-semibold text-purple-600">
                              성취 확률 {wish.probability}%
                            </div>
                            <Progress value={wish.probability} className="w-20 h-2 mt-1" />
                          </div>
                        </div>
                        <p className="text-gray-700 mb-2">{wish.content}</p>
                        <div className="text-xs text-gray-500">
                          {new Date(wish.createdAt).toLocaleDateString('ko-KR', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit'
                          }).replace(/\./g, '').replace(/\s/g, '').replace(/(\d{4})(\d{2})(\d{2})/, '$1년 $2월 $3일')}
                        </div>
                      </div>
                    );
                  })}
                  
                  {wishes.length > 5 && (
                    <div className="text-center text-sm text-gray-500">
                      총 {wishes.length}개의 소원 중 최근 5개만 표시
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}
      </div>
    </div>
  );
} 