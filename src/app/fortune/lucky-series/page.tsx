"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { getUserProfile, isPremiumUser } from "@/lib/user-storage";
import AdLoadingScreen from "@/components/AdLoadingScreen";
import { 
  Sparkles, 
  Calendar,
  Star,
  Trophy,
  Droplet,
  Zap,
  BookOpen,
  Heart,
  Gem,
  Shirt,
  Briefcase,
  Coins,
  UtensilsCrossed,
  Mountain,
  Bike,
  Fish,
  GraduationCap,
  ChevronLeft,
  ChevronRight,
  TrendingUp,
  Clock,
  Target,
  Gift,
  Palette
} from "lucide-react";

// 행운 시리즈 유형 정의
interface LuckySeriesType {
  id: string;
  title: string;
  description: string;
  icon: any;
  route: string;
  color: string;
  gradient: string;
  badge?: string;
  category: string;
  preview: {
    score: number;
    keyword: string;
    tip: string;
  };
}

// 행운 시리즈 데이터
const luckySeriesData: LuckySeriesType[] = [
  {
    id: "lucky-food",
    title: "행운의 음식",
    description: "오늘 먹으면 좋은 행운의 음식과 식단",
    icon: UtensilsCrossed,
    route: "/fortune/lucky-food",
    color: "orange",
    gradient: "from-orange-50 to-yellow-50",
    badge: "맛집",
    category: "생활",
    preview: {
      score: 88,
      keyword: "영양 균형",
      tip: "따뜻한 국물 요리가 행운을 가져다줍니다"
    }
  },
  {
    id: "lucky-outfit",
    title: "행운의 옷차림",
    description: "오늘 입으면 좋은 행운의 스타일과 색상",
    icon: Shirt,
    route: "/fortune/lucky-outfit",
    color: "pink",
    gradient: "from-pink-50 to-rose-50",
    badge: "패션",
    category: "생활",
    preview: {
      score: 92,
      keyword: "우아한 스타일",
      tip: "파스텔 톤 컬러가 인상을 좋게 만듭니다"
    }
  },
  {
    id: "lucky-color",
    title: "행운의 색깔",
    description: "마음을 위로하는 당신만의 특별한 색깔",
    icon: Palette,
    route: "/fortune/lucky-color",
    color: "purple",
    gradient: "from-purple-50 to-blue-50",
    badge: "치유",
    category: "생활",
    preview: {
      score: 85,
      keyword: "차분한 블루",
      tip: "파란색 계열이 마음의 평화를 가져다줍니다"
    }
  },
  {
    id: "lucky-number",
    title: "행운의 숫자",
    description: "오늘의 행운을 부르는 특별한 숫자",
    icon: Star,
    route: "/fortune/lucky-number",
    color: "indigo",
    gradient: "from-indigo-50 to-purple-50",
    badge: "숫자",
    category: "생활",
    preview: {
      score: 90,
      keyword: "7, 14, 21",
      tip: "7의 배수가 특별한 의미를 가집니다"
    }
  },
  {
    id: "lucky-items",
    title: "행운의 아이템",
    description: "당신에게 행운을 가져다 줄 특별한 아이템",
    icon: Gem,
    route: "/fortune/lucky-items",
    color: "emerald",
    gradient: "from-emerald-50 to-teal-50",
    badge: "아이템",
    category: "생활",
    preview: {
      score: 87,
      keyword: "크리스털 액세서리",
      tip: "투명한 크리스털이 긍정적 에너지를 증폭시킵니다"
    }
  },
  {
    id: "lucky-exam",
    title: "행운의 시험",
    description: "시험 합격을 위한 운세와 학습 전략",
    icon: GraduationCap,
    route: "/fortune/lucky-exam",
    color: "blue",
    gradient: "from-blue-50 to-indigo-50",
    badge: "학업",
    category: "학업·취업",
    preview: {
      score: 93,
      keyword: "집중력 상승",
      tip: "오전 시간대 학습이 가장 효과적입니다"
    }
  },
  {
    id: "lucky-job",
    title: "행운의 직업",
    description: "당신에게 맞는 행운의 직업과 업종",
    icon: Briefcase,
    route: "/fortune/lucky-job",
    color: "teal",
    gradient: "from-teal-50 to-cyan-50",
    badge: "직업",
    category: "학업·취업",
    preview: {
      score: 89,
      keyword: "창의적 분야",
      tip: "예술이나 디자인 관련 직종이 유리합니다"
    }
  },
  {
    id: "lucky-sidejob",
    title: "행운의 부업",
    description: "성공할 수 있는 부업과 수익 창출 방법",
    icon: Coins,
    route: "/fortune/lucky-sidejob",
    color: "yellow",
    gradient: "from-yellow-50 to-orange-50",
    badge: "부업",
    category: "재물·투자",
    preview: {
      score: 84,
      keyword: "온라인 사업",
      tip: "인터넷을 활용한 사업이 좋은 결과를 가져다줍니다"
    }
  },
  {
    id: "lucky-investment",
    title: "행운의 투자",
    description: "당신에게 유리한 투자 분야와 타이밍",
    icon: TrendingUp,
    route: "/fortune/lucky-investment",
    color: "green",
    gradient: "from-green-50 to-emerald-50",
    badge: "재테크",
    category: "재물·투자",
    preview: {
      score: 91,
      keyword: "안정적 투자",
      tip: "장기 투자가 단기보다 유리한 시기입니다"
    }
  },
  {
    id: "lucky-hiking",
    title: "행운의 등산",
    description: "등산을 통해 보는 운세와 안전한 완주",
    icon: Mountain,
    route: "/fortune/lucky-hiking",
    color: "green",
    gradient: "from-green-50 to-emerald-50",
    badge: "스포츠",
    category: "건강·스포츠",
    preview: {
      score: 86,
      keyword: "체력 증진",
      tip: "완만한 코스부터 시작하는 것이 좋습니다"
    }
  },
  {
    id: "lucky-running",
    title: "행운의 러닝",
    description: "달리기로 만나는 건강과 목표 달성",
    icon: Zap,
    route: "/fortune/lucky-running",
    color: "red",
    gradient: "from-red-50 to-orange-50",
    badge: "스포츠",
    category: "건강·스포츠",
    preview: {
      score: 88,
      keyword: "지구력 향상",
      tip: "꾸준한 페이스 유지가 성공의 열쇠입니다"
    }
  },
  {
    id: "lucky-cycling",
    title: "행운의 자전거",
    description: "자전거로 만나는 행운과 건강한 라이딩",
    icon: Bike,
    route: "/fortune/lucky-cycling",
    color: "blue",
    gradient: "from-blue-50 to-cyan-50",
    badge: "스포츠",
    category: "건강·스포츠",
    preview: {
      score: 90,
      keyword: "자유로운 라이딩",
      tip: "새로운 코스 탐험이 좋은 기운을 가져다줍니다"
    }
  }
];

// 날짜 생성 함수 (오늘부터 7일)
const generateDates = () => {
  const dates = [];
  const today = new Date();
  
  for (let i = 0; i < 7; i++) {
    const date = new Date(today);
    date.setDate(today.getDate() + i);
    dates.push({
      date: date,
      dateString: date.toISOString().split('T')[0],
      displayDate: date.toLocaleDateString('ko-KR', { 
        month: 'short', 
        day: 'numeric',
        weekday: 'short'
      }),
      isToday: i === 0
    });
  }
  
  return dates;
};

// 애니메이션 variants
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

const cardVariants = {
  hidden: { scale: 0.9, opacity: 0 },
  visible: {
    scale: 1,
    opacity: 1,
    transition: {
      type: "spring" as const,
      stiffness: 100,
      damping: 15
    }
  },
  hover: {
    scale: 1.02,
    y: -5,
    transition: {
      type: "spring" as const,
      stiffness: 300,
      damping: 20
    }
  }
};

export default function LuckySeriesPage() {
  const router = useRouter();
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [selectedDate, setSelectedDate] = useState<string>('');
  const [dates, setDates] = useState<any[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [showAdLoading, setShowAdLoading] = useState(false);
  const [pendingFortune, setPendingFortune] = useState<{ route: string; title: string } | null>(null);

  // 폰트 크기 클래스 매핑
  const getFontSizeClasses = (size: 'small' | 'medium' | 'large') => {
    switch (size) {
      case 'small':
        return {
          text: 'text-sm',
          title: 'text-lg',
          heading: 'text-xl',
          label: 'text-xs'
        };
      case 'large':
        return {
          text: 'text-lg',
          title: 'text-2xl',
          heading: 'text-3xl',
          label: 'text-base'
        };
      default: // medium
        return {
          text: 'text-base',
          title: 'text-xl',
          heading: 'text-2xl',
          label: 'text-sm'
        };
    }
  };

  const fontClasses = getFontSizeClasses(fontSize);

  // 초기화
  useEffect(() => {
    const generatedDates = generateDates();
    setDates(generatedDates);
    setSelectedDate(generatedDates[0].dateString); // 오늘 날짜를 기본값으로
  }, []);

  // 운세 클릭 핸들러
  const handleFortuneClick = (route: string, title: string) => {
    const userProfile = getUserProfile();
    const isPremium = isPremiumUser(userProfile);
    
    // 선택된 날짜를 쿼리 파라미터로 추가
    const routeWithDate = `${route}?date=${selectedDate}`;
    
    if (isPremium) {
      router.push(routeWithDate);
    } else {
      setPendingFortune({ route: routeWithDate, title });
      setShowAdLoading(true);
    }
  };

  // 광고 로딩 완료 후 이동
  const handleAdComplete = () => {
    if (pendingFortune) {
      router.push(pendingFortune.route);
      setTimeout(() => {
        setShowAdLoading(false);
        setPendingFortune(null);
      }, 100);
    }
  };

  // 프리미엄 업그레이드
  const handleUpgradeToPremium = () => {
    setShowAdLoading(false);
    setPendingFortune(null);
    router.push('/membership');
  };

  // 카테고리 필터링
  const categories = ['all', '생활', '학업·취업', '재물·투자', '건강·스포츠'];
  const filteredSeries = selectedCategory === 'all' 
    ? luckySeriesData 
    : luckySeriesData.filter(item => item.category === selectedCategory);

  // 광고 로딩 화면
  if (showAdLoading && pendingFortune) {
    return (
      <AdLoadingScreen
        fortuneType="lucky-series"
        fortuneTitle={pendingFortune.title}
        onComplete={handleAdComplete}
        onSkip={handleUpgradeToPremium}
      />
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-indigo-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 pb-20">
      <AppHeader 
        title="행운 시리즈" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-4"
      >
        {/* 헤더 */}
        <motion.div variants={itemVariants} className="mb-6">
          <div className="text-center">
            <motion.h1 
              className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}
              initial={{ y: -20, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
            >
              행운 시리즈
            </motion.h1>
            <motion.p 
              className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}
              initial={{ y: -10, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.1 }}
            >
              일상 속 다양한 행운 운세를 날짜별로 확인하세요
            </motion.p>
          </div>
        </motion.div>

        {/* 날짜 선택 */}
        <motion.div variants={itemVariants} className="mb-6">
          <Card className="dark:bg-gray-800 dark:border-gray-700">
            <CardHeader className="pb-3">
              <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-600 dark:text-purple-400`}>
                <Calendar className="w-5 h-5" />
                날짜 선택
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex gap-2 overflow-x-auto pb-2">
                {dates.map((dateInfo, index) => (
                  <motion.button
                    key={dateInfo.dateString}
                    onClick={() => setSelectedDate(dateInfo.dateString)}
                    className={`flex-shrink-0 px-4 py-3 rounded-lg border-2 transition-all ${
                      selectedDate === dateInfo.dateString
                        ? 'border-purple-500 bg-purple-50 dark:bg-purple-900/30 text-purple-700 dark:text-purple-300'
                        : 'border-gray-200 dark:border-gray-600 bg-white dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:border-purple-300 dark:hover:border-purple-500'
                    }`}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: index * 0.1 }}
                  >
                    <div className="text-center">
                      <div className={`${fontClasses.label} font-medium`}>
                        {dateInfo.displayDate}
                      </div>
                      {dateInfo.isToday && (
                        <div className={`${fontClasses.label} text-purple-600 dark:text-purple-400 font-semibold`}>
                          오늘
                        </div>
                      )}
                    </div>
                  </motion.button>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 카테고리 필터 */}
        <motion.div variants={itemVariants} className="mb-6">
          <div className="flex gap-2 overflow-x-auto pb-2">
            {categories.map((category, index) => (
              <motion.button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`flex-shrink-0 px-4 py-2 rounded-full text-sm font-medium transition-all ${
                  selectedCategory === category
                    ? 'bg-purple-500 text-white'
                    : 'bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 hover:bg-purple-100 dark:hover:bg-purple-900/30'
                }`}
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.05 }}
              >
                {category === 'all' ? '전체' : category}
              </motion.button>
            ))}
          </div>
        </motion.div>

        {/* 행운 시리즈 목록 */}
        <motion.div variants={containerVariants} className="grid grid-cols-1 gap-4">
          {filteredSeries.map((item, index) => (
            <motion.div
              key={item.id}
              variants={itemVariants}
              whileHover="hover"
              whileTap={{ scale: 0.98 }}
            >
              <motion.div
                variants={cardVariants}
                onClick={() => handleFortuneClick(item.route, item.title)}
                className="cursor-pointer"
              >
                <Card className={`hover:shadow-lg transition-all duration-300 bg-gradient-to-r ${item.gradient} dark:bg-gradient-to-r dark:from-${item.color}-900/20 dark:to-${item.color}-800/10 border-${item.color}-200 dark:border-${item.color}-700`}>
                  <CardContent className="p-6">
                    <div className="flex items-start justify-between">
                      {/* 왼쪽: 아이콘과 기본 정보 */}
                      <div className="flex items-start gap-4 flex-1">
                        <motion.div 
                          className={`bg-${item.color}-100 dark:bg-${item.color}-900/30 rounded-full w-14 h-14 flex items-center justify-center flex-shrink-0`}
                          whileHover={{ rotate: 360 }}
                          transition={{ duration: 0.5 }}
                        >
                          <item.icon className={`w-7 h-7 text-${item.color}-600 dark:text-${item.color}-400`} />
                        </motion.div>
                        
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-2">
                            <h3 className={`${fontClasses.title} font-bold text-gray-900 dark:text-gray-100`}>
                              {item.title}
                            </h3>
                            {item.badge && (
                              <Badge 
                                variant="secondary" 
                                className={`${fontClasses.label} bg-${item.color}-100 dark:bg-${item.color}-900/50 text-${item.color}-700 dark:text-${item.color}-300`}
                              >
                                {item.badge}
                              </Badge>
                            )}
                          </div>
                          <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400 mb-3`}>
                            {item.description}
                          </p>
                          
                          {/* 미리보기 정보 */}
                          <div className={`bg-white/50 dark:bg-gray-800/50 rounded-lg p-3 backdrop-blur-sm`}>
                            <div className="flex items-center justify-between mb-2">
                              <div className="flex items-center gap-2">
                                <Star className={`w-4 h-4 text-${item.color}-600 dark:text-${item.color}-400`} />
                                <span className={`${fontClasses.label} font-semibold text-${item.color}-700 dark:text-${item.color}-300`}>
                                  {item.preview.score}점
                                </span>
                              </div>
                              <Badge 
                                variant="outline" 
                                className={`${fontClasses.label} border-${item.color}-300 dark:border-${item.color}-600 text-${item.color}-700 dark:text-${item.color}-300`}
                              >
                                {item.preview.keyword}
                              </Badge>
                            </div>
                            <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400 leading-relaxed`}>
                              💡 {item.preview.tip}
                            </p>
                          </div>
                        </div>
                      </div>
                      
                      {/* 오른쪽: 화살표 */}
                      <motion.div
                        className="ml-4 flex-shrink-0"
                        animate={{ x: [0, 5, 0] }}
                        transition={{ repeat: Infinity, duration: 2 }}
                      >
                        <ChevronRight className={`w-6 h-6 text-${item.color}-600 dark:text-${item.color}-400`} />
                      </motion.div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            </motion.div>
          ))}
        </motion.div>

        {/* 하단 안내 */}
        <motion.div variants={itemVariants} className="mt-8 text-center">
          <p className={`${fontClasses.label} text-gray-500 dark:text-gray-400`}>
            💫 각 운세는 선택하신 날짜에 맞춰 개인화된 결과를 제공합니다
          </p>
        </motion.div>
      </motion.div>
    </div>
  );
} 