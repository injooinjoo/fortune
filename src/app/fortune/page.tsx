"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { useRouter } from "next/navigation";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { getUserProfile, isPremiumUser } from "@/lib/user-storage";
import AdLoadingScreen from "@/components/AdLoadingScreen";
import { 
  Heart, 
  Star,
  Calendar,
  Briefcase,
  Coins,
  Brain,
  Sparkles,
  TrendingUp,
  Users,
  User,
  Droplet,
  Zap,
  Cake,
  PartyPopper,
  Crown,
  Home,
  BookOpen,
  AlertTriangle,
  Gem,
  ShieldAlert,
  ScrollText,
  Sunrise,
  CalendarCheck,
  Rocket,
  Filter,
  Trophy,
  ArrowRight
} from "lucide-react";

// 운세 카테고리 타입 정의
type FortuneCategoryType = 'all' | 'love' | 'career' | 'money' | 'health' | 'traditional' | 'lifestyle';

interface FortuneCategory {
  id: string;
  title: string;
  description: string;
  icon: React.ComponentType<{ className?: string }>;
  route: string;
  color: string;
  gradient: string;
  badge?: string;
  category: FortuneCategoryType;
}

// 필터 카테고리 정의
const filterCategories = [
  { id: 'all', name: '전체', icon: Star, color: 'purple' },
  { id: 'love', name: '연애·인연', icon: Heart, color: 'pink' },
  { id: 'career', name: '취업·사업', icon: Briefcase, color: 'blue' },
  { id: 'money', name: '재물·투자', icon: Coins, color: 'yellow' },
  { id: 'health', name: '건강·라이프', icon: Sparkles, color: 'green' },
  { id: 'traditional', name: '전통·사주', icon: ScrollText, color: 'amber' },
  { id: 'lifestyle', name: '생활·운세', icon: Calendar, color: 'teal' }
] as const;

const fortuneCategories: FortuneCategory[] = [
  // 연애·인연
  {
    id: "love",
    title: "연애운",
    description: "사랑과 인연의 흐름을 확인하세요",
    icon: Heart,
    route: "/fortune/love",
    color: "pink",
    gradient: "from-pink-50 to-red-50",
    badge: "인기",
    category: "love"
  },
  {
    id: "marriage",
    title: "결혼운",
    description: "평생의 동반자와의 인연을 확인하세요",
    icon: Heart,
    route: "/fortune/marriage",
    color: "rose",
    gradient: "from-rose-50 to-pink-50",
    badge: "특별",
    category: "love"
  },
  {
    id: "compatibility",
    title: "궁합",
    description: "두 사람의 궁합을 확인하세요",
    icon: Users,
    route: "/fortune/compatibility",
    color: "pink",
    gradient: "from-pink-50 to-rose-50",
    category: "love"
  },
  // 취업·사업
  {
    id: "career",
    title: "취업운",
    description: "커리어와 성공의 길을 찾아보세요",
    icon: Briefcase,
    route: "/fortune/career",
    color: "blue",
    gradient: "from-blue-50 to-indigo-50",
    category: "career"
  },
  {
    id: "business",
    title: "사업운",
    description: "성공적인 창업과 사업 운영을 위한 운세를 확인하세요",
    icon: TrendingUp,
    route: "/fortune/business",
    color: "indigo",
    gradient: "from-indigo-50 to-purple-50",
    badge: "추천",
    category: "career"
  },
  // 재물·투자
  {
    id: "wealth",
    title: "금전운",
    description: "재물과 투자의 운을 살펴보세요",
    icon: Coins,
    route: "/fortune/wealth",
    color: "yellow",
    gradient: "from-yellow-50 to-orange-50",
    category: "money"
  },
  {
    id: "lucky-investment",
    title: "행운의 투자",
    description: "투자 성공을 위한 운세를 확인하세요",
    icon: TrendingUp,
    route: "/fortune/lucky-investment",
    color: "green",
    gradient: "from-green-50 to-emerald-50",
    category: "money"
  },
  {
    id: "lucky-realestate",
    title: "행운의 부동산",
    description: "부동산 투자와 거래의 운을 확인하세요",
    icon: Home,
    route: "/fortune/lucky-realestate",
    color: "emerald",
    gradient: "from-emerald-50 to-teal-50",
    category: "money"
  },
  // 건강·라이프
  {
    id: "biorhythm",
    title: "바이오리듬",
    description: "신체, 감정, 지적 리듬을 확인하세요",
    icon: Zap,
    route: "/fortune/biorhythm",
    color: "green",
    gradient: "from-green-50 to-emerald-50",
    category: "health"
  },
  {
    id: "lucky-hiking",
    title: "행운의 등산",
    description: "등산을 통해 보는 당신의 운세와 안전한 완주의 비결",
    icon: Crown,
    route: "/fortune/lucky-hiking",
    color: "green",
    gradient: "from-green-50 to-emerald-50",
    category: "health"
  },
  {
    id: "lucky-cycling",
    title: "행운의 자전거",
    description: "자전거로 만나는 행운과 건강한 라이딩 코스",
    icon: Zap,
    route: "/fortune/lucky-cycling",
    color: "blue",
    gradient: "from-blue-50 to-cyan-50",
    category: "health"
  },
  {
    id: "moving",
    title: "이사운",
    description: "새로운 보금자리로의 행복한 이주를 확인하세요",
    icon: Home,
    route: "/fortune/moving",
    color: "emerald",
    gradient: "from-emerald-50 to-green-50",
    badge: "인기",
    category: "health"
  },
  // 전통·사주
  {
    id: "saju",
    title: "사주팔자",
    description: "정통 사주로 인생의 큰 흐름을 파악하세요",
    icon: Calendar,
    route: "/fortune/saju",
    color: "purple",
    gradient: "from-purple-50 to-indigo-50",
    badge: "정통",
    category: "traditional"
  },
  {
    id: "saju-psychology",
    title: "사주 심리분석",
    description: "타고난 성격과 관계를 심층 탐구",
    icon: Brain,
    route: "/fortune/saju-psychology",
    color: "teal",
    gradient: "from-teal-50 to-cyan-50",
    badge: "신규",
    category: "traditional"
  },
  {
    id: "tojeong",
    title: "토정비결",
    description: "144괘로 풀이하는 신년 길흉",
    icon: ScrollText,
    route: "/fortune/tojeong",
    color: "amber",
    gradient: "from-amber-50 to-orange-50",
    badge: "전통",
    category: "traditional"
  },
  {
    id: "salpuli",
    title: "살풀이",
    description: "흉살을 알고 대비하는 길을 찾아보세요",
    icon: ShieldAlert,
    route: "/fortune/salpuli",
    color: "red",
    gradient: "from-red-50 to-pink-50",
    badge: "조화",
    category: "traditional"
  },
  {
    id: "palmistry",
    title: "손금",
    description: "손에 새겨진 인생의 지도를 읽어보세요",
    icon: Zap,
    route: "/fortune/palmistry",
    color: "amber",
    gradient: "from-amber-50 to-yellow-50",
    badge: "전통",
    category: "traditional"
  },

  // 생활·운세
  {
    id: "daily",
    title: "오늘의 운세",
    description: "총운, 애정운, 재물운, 건강운을 한 번에",
    icon: Star,
    route: "/fortune/today",
    color: "emerald",
    gradient: "from-emerald-50 to-teal-50",
    category: "lifestyle"
  },
  {
    id: "tomorrow",
    title: "내일의 운세",
    description: "내일의 흐름을 미리 살펴보세요",
    icon: Sunrise,
    route: "/fortune/tomorrow",
    color: "sky",
    gradient: "from-sky-50 to-blue-50",
    category: "lifestyle"
  },
  {
    id: "new-year",
    title: "신년운세",
    description: "새해 한 해의 흐름을 미리 확인하세요",
    icon: PartyPopper,
    route: "/fortune/new-year",
    color: "indigo",
    gradient: "from-indigo-50 to-blue-50",
    badge: "2025",
    category: "lifestyle"
  },
  {
    id: "birthdate",
    title: "생년월일 운세",
    description: "간단한 생년월일 운세를 확인하세요",
    icon: Cake,
    route: "/fortune/birthdate",
    color: "cyan",
    gradient: "from-cyan-50 to-blue-50",
    badge: "NEW",
    category: "lifestyle"
  },
  {
    id: "mbti",
    title: "MBTI 운세",
    description: "성격 유형별 맞춤 운세를 받아보세요",
    icon: User,
    route: "/fortune/mbti",
    color: "violet",
    gradient: "from-violet-50 to-purple-50",
    badge: "새로움",
    category: "lifestyle"
  },
  {
    id: "blood-type",
    title: "혈액형 궁합",
    description: "혈액형으로 보는 성격 궁합",
    icon: Droplet,
    route: "/fortune/blood-type",
    color: "red",
    gradient: "from-red-50 to-rose-50",
    badge: "NEW",
    category: "lifestyle"
  },
  {
    id: "zodiac-animal",
    title: "띠 운세",
    description: "12간지로 보는 이달의 운세를 확인하세요",
    icon: Crown,
    route: "/fortune/zodiac-animal",
    color: "orange",
    gradient: "from-orange-50 to-yellow-50",
    badge: "전통",
    category: "lifestyle"
  },
  {
    id: "lucky-color",
    title: "행운의 색깔",
    description: "마음을 위로하는 당신만의 색깔을 찾아보세요",
    icon: Sparkles,
    route: "/fortune/lucky-color",
    color: "purple",
    gradient: "from-purple-50 to-blue-50",
    badge: "치유",
    category: "lifestyle"
  },
  {
    id: "five-blessings",
    title: "천생복덕운",
    description: "타고난 오복의 균형을 살펴보세요",
    icon: Gem,
    route: "/fortune/five-blessings",
    color: "teal",
    gradient: "from-teal-50 to-emerald-50",
    badge: "추천",
    category: "lifestyle"
  },
  {
    id: "past-life",
    title: "전생운",
    description: "과거 생의 직업과 성격을 알아보세요",
    icon: BookOpen,
    route: "/fortune/past-life",
    color: "indigo",
    gradient: "from-indigo-50 to-purple-50",
    badge: "신비",
    category: "lifestyle"
  },
  {
    id: "talent",
    title: "능력 평가",
    description: "사주로 알아보는 나의 숨은 재능",
    icon: Sparkles,
    route: "/fortune/talent",
    color: "green",
    gradient: "from-green-50 to-emerald-50",
    badge: "신규",
    category: "lifestyle"
  },
  {
    id: "talisman",
    title: "행운의 부적",
    description: "원하는 소망을 담은 부적을 만들어보세요",
    icon: Coins,
    route: "/fortune/talisman",
    color: "yellow",
    gradient: "from-yellow-50 to-orange-50",
    badge: "신규",
    category: "lifestyle"
  },
  {
    id: "birthstone",
    title: "탄생석",
    description: "생일로 알아보는 행운의 보석",
    icon: Gem,
    route: "/fortune/birthstone",
    color: "sky",
    gradient: "from-sky-50 to-indigo-50",
    badge: "신규",
    category: "lifestyle"
  },
  {
    id: "avoid-people",
    title: "피해야 할 상대",
    description: "갈등을 줄이기 위해 조심해야 할 상대를 알아보세요",
    icon: AlertTriangle,
    route: "/fortune/avoid-people",
    color: "red",
    gradient: "from-red-50 to-orange-50",
    badge: "주의",
    category: "lifestyle"
  },
  // 추가 운세들
  {
    id: "celebrity",
    title: "유명인 운세",
    description: "당신과 닮은 유명인의 운세를 확인해보세요",
    icon: Star,
    route: "/fortune/celebrity",
    color: "purple",
    gradient: "from-purple-50 to-indigo-50",
    badge: "NEW",
    category: "lifestyle"
  },
  {
    id: "celebrity-match",
    title: "연예인 궁합",
    description: "최애와 나의 케미를 확인해보세요",
    icon: Heart,
    route: "/fortune/celebrity-match",
    color: "rose",
    gradient: "from-rose-50 to-pink-50",
    badge: "인기",
    category: "love"
  },
  {
    id: "blind-date",
    title: "소개팅운",
    description: "새로운 만남의 가능성을 확인하세요",
    icon: Users,
    route: "/fortune/blind-date",
    color: "pink",
    gradient: "from-pink-50 to-rose-50",
    category: "love"
  },
  {
    id: "ex-lover",
    title: "전애인 운세",
    description: "과거 연인과의 인연을 살펴보세요",
    icon: Heart,
    route: "/fortune/ex-lover",
    color: "gray",
    gradient: "from-gray-50 to-slate-50",
    category: "love"
  },
  {
    id: "chemistry",
    title: "케미 운세",
    description: "상대방과의 케미를 확인해보세요",
    icon: Sparkles,
    route: "/fortune/chemistry",
    color: "cyan",
    gradient: "from-cyan-50 to-blue-50",
    category: "love"
  },
  {
    id: "hourly",
    title: "시간별 운세",
    description: "오늘 하루 시간대별 운세를 확인하세요",
    icon: Calendar,
    route: "/fortune/hourly",
    color: "indigo",
    gradient: "from-indigo-50 to-purple-50",
    category: "lifestyle"
  },
  {
    id: "today",
    title: "오늘의 운세",
    description: "오늘 하루의 종합 운세를 확인하세요",
    icon: Star,
    route: "/fortune/today",
    color: "emerald",
    gradient: "from-emerald-50 to-teal-50",
    category: "lifestyle"
  },
  {
    id: "zodiac",
    title: "별자리 운세",
    description: "12별자리로 보는 이달의 운세",
    icon: Star,
    route: "/fortune/zodiac",
    color: "purple",
    gradient: "from-purple-50 to-indigo-50",
    category: "lifestyle"
  },
  {
    id: "birth-season",
    title: "태어난 계절 운세",
    description: "태어난 계절로 보는 성격과 운세",
    icon: Sparkles,
    route: "/fortune/birth-season",
    color: "green",
    gradient: "from-green-50 to-emerald-50",
    category: "lifestyle"
  },
  {
    id: "personality",
    title: "성격 운세",
    description: "타고난 성격으로 보는 운세",
    icon: Brain,
    route: "/fortune/personality",
    color: "blue",
    gradient: "from-blue-50 to-indigo-50",
    category: "lifestyle"
  },
  {
    id: "traditional-saju",
    title: "전통 사주",
    description: "정통 사주팔자로 보는 운명",
    icon: ScrollText,
    route: "/fortune/traditional-saju",
    color: "amber",
    gradient: "from-amber-50 to-orange-50",
    badge: "정통",
    category: "traditional"
  },
  {
    id: "timeline",
    title: "인생 타임라인",
    description: "인생의 중요한 시기를 확인하세요",
    icon: Calendar,
    route: "/fortune/timeline",
    color: "teal",
    gradient: "from-teal-50 to-cyan-50",
    category: "lifestyle"
  },
  {
    id: "wish",
    title: "소원 운세",
    description: "간절한 소원이 이루어질 가능성을 확인하세요",
    icon: Sparkles,
    route: "/fortune/wish",
    color: "yellow",
    gradient: "from-yellow-50 to-orange-50",
    badge: "특별",
    category: "lifestyle"
  },
  {
    id: "network-report",
    title: "인맥 리포트",
    description: "주변 인맥과의 관계를 분석해보세요",
    icon: Users,
    route: "/fortune/network-report",
    color: "blue",
    gradient: "from-blue-50 to-cyan-50",
    category: "lifestyle"
  },
  {
    id: "moving-date",
    title: "이사 날짜",
    description: "이사하기 좋은 날을 찾아보세요",
    icon: Home,
    route: "/fortune/moving-date",
    color: "green",
    gradient: "from-green-50 to-emerald-50",
    category: "health"
  },
  // 행운 시리즈 (통합)
  {
    id: "lucky-series",
    title: "행운 시리즈",
    description: "일상 속 다양한 행운 운세를 날짜별로 확인하세요",
    icon: Sparkles,
    route: "/fortune/lucky-series",
    color: "purple",
    gradient: "from-purple-50 to-indigo-50",
    badge: "인기",
    category: "lifestyle"
  }
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

export default function FortunePage() {
  const router = useRouter();
  const [fontSize, setFontSize] = useState<"small" | "medium" | "large">("medium");
  const [selectedCategory, setSelectedCategory] = useState<FortuneCategoryType>('all');
  const [showAdLoading, setShowAdLoading] = useState(false);
  const [pendingFortune, setPendingFortune] = useState<{ route: string; title: string } | null>(null);
  
  // 최근 본 운세 추가를 위한 hook
  useFortuneStream();

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

  // 필터링된 운세 카테고리
  const filteredCategories = selectedCategory === 'all' 
    ? fortuneCategories 
    : fortuneCategories.filter(category => category.category === selectedCategory);

const handleCategoryClick = (route: string, title: string) => {
    // 프리미엄, 일반 사용자 모두 로딩 화면 표시 (분석하는 척)
    setPendingFortune({ route, title });
    setShowAdLoading(true);
  };

  // 광고 로딩 완료 후 운세 페이지로 이동
  const handleAdComplete = () => {
    if (pendingFortune) {
      // 먼저 페이지 이동을 시작하고
      router.push(pendingFortune.route);
      // 그 다음에 상태 정리 (이렇게 하면 중간에 운세 페이지가 보이지 않음)
      setTimeout(() => {
        setShowAdLoading(false);
        setPendingFortune(null);
      }, 100);
    }
  };

  // 프리미엄 업그레이드 페이지로 이동
  const handleUpgradeToPremium = () => {
    setShowAdLoading(false);
    setPendingFortune(null);
    router.push('/membership');
  };

// 광고 로딩 화면 표시 중이면 AdLoadingScreen 렌더링
  if (showAdLoading && pendingFortune) {
    const userProfile = getUserProfile();
    const isPremium = isPremiumUser(userProfile);
    
    return (
      <AdLoadingScreen
        fortuneType={pendingFortune.route.split('/').pop() || 'fortune'}
        fortuneTitle={pendingFortune.title}
        onComplete={handleAdComplete}
        onSkip={handleUpgradeToPremium}
        isPremium={isPremium}
      />
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-25 to-indigo-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700">
      <AppHeader
        title="운세"
        showBack={false}
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div
        className="pb-32 px-4 space-y-6 pt-4"
        initial="hidden"
        animate="visible"
        variants={containerVariants}
      >
        {/* 헤더 섹션 */}
        <motion.div variants={itemVariants} className="text-center space-y-2">
          <div className="flex items-center justify-center gap-2 mb-4">
            <motion.div
              animate={{ rotate: 360 }}
              transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
            >
              <Sparkles className="w-8 h-8 text-purple-600" />
            </motion.div>
            <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100`}>운세 서비스</h1>
          </div>
          <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400 leading-relaxed`}>
            다양한 분야의 운세를 통해 오늘의 운명을 확인해보세요
          </p>
        </motion.div>

        {/* 오늘의 추천 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-purple-50 to-pink-50 dark:from-purple-900/30 dark:to-pink-900/30 border-purple-200 dark:border-purple-700 dark:bg-gray-800">
            <CardHeader>
              <div className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-purple-600 dark:text-purple-400" />
                <CardTitle className={`${fontClasses.title} text-purple-800 dark:text-purple-300`}>오늘의 추천</CardTitle>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div>
                  <h3 className={`${fontClasses.text} font-semibold text-purple-900 dark:text-purple-200 mb-1`}>연애운</h3>
                  <p className={`${fontClasses.label} text-purple-700 dark:text-purple-400`}>
                    새로운 만남의 기회가 열리는 날입니다
                  </p>
                </div>
                <Badge className={`${fontClasses.label} bg-purple-100 dark:bg-purple-900/50 text-purple-700 dark:text-purple-300 hover:bg-purple-200 dark:hover:bg-purple-900/70`}>
                  85점
                </Badge>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 운세 카테고리 */}
        <motion.div variants={itemVariants}>
          <h2 className={`${fontClasses.title} font-bold text-gray-900 dark:text-gray-100 mb-6`}>분야별 운세</h2>
          
          {/* 필터 탭 */}
          <div className="mb-6">
            <div className="flex flex-wrap gap-2">
              {filterCategories.map((category) => {
                const isSelected = selectedCategory === category.id;
                const buttonClasses = isSelected 
                  ? `bg-purple-500 border-purple-500 text-white shadow-lg`
                  : `bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600 text-gray-700 dark:text-gray-300 hover:bg-purple-50 dark:hover:bg-purple-900/30 hover:border-purple-300 dark:hover:border-purple-500 hover:shadow-sm`;
                
                return (
                  <motion.button
                    key={category.id}
                    onClick={() => setSelectedCategory(category.id as FortuneCategoryType)}
                    className={`${fontClasses.label} px-4 py-2.5 rounded-full border-2 transition-all duration-200 flex items-center gap-2 font-medium ${buttonClasses}`}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: category.id === 'all' ? 0 : 0.1 }}
                  >
                    <category.icon className={`w-4 h-4 ${
                      isSelected ? 'text-white' : 'text-purple-600 dark:text-purple-400'
                    }`} />
                    <span>{category.name}</span>
                    {isSelected && (
                      <motion.div
                        initial={{ scale: 0 }}
                        animate={{ scale: 1 }}
                        className="bg-white/20 text-white rounded-full px-2 py-0.5 text-xs font-semibold"
                      >
                        {filteredCategories.length}
                      </motion.div>
                    )}
                  </motion.button>
                );
              })}
            </div>
          </div>

          {/* 운세 목록 */}
          <motion.div
            key={selectedCategory}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3 }}
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                {selectedCategory !== 'all' && (
                  <motion.div
                    initial={{ scale: 0 }}
                    animate={{ scale: 1 }}
                    className={`w-3 h-3 rounded-full bg-${filterCategories.find(c => c.id === selectedCategory)?.color}-500`}
                  />
                )}
                <span className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>
                  {selectedCategory === 'all' ? '전체 운세' : filterCategories.find(c => c.id === selectedCategory)?.name}
                </span>
                <Badge variant="secondary" className={`${fontClasses.label}`}>
                  {filteredCategories.length}개
                </Badge>
              </div>
              
              {selectedCategory !== 'all' && (
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => setSelectedCategory('all')}
                  className={`${fontClasses.label} text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-300`}
                >
                  전체 보기
                </Button>
              )}
            </div>
            
            <div className="grid grid-cols-1 gap-4">
              {filteredCategories.map((category, index) => (
                <motion.div
                  key={category.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05 }}
                  whileHover={{ scale: 1.02, y: -2 }}
                  whileTap={{ scale: 0.98 }}
                  onClick={() => handleCategoryClick(category.route, category.title)}
                  className="cursor-pointer"
                >
                  <Card className="hover:shadow-md transition-all duration-300 bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600 hover:border-purple-300 dark:hover:border-purple-500">
                    <CardContent className="p-6">
                      <div className="flex items-center gap-4">
                        <div className="bg-purple-100 dark:bg-purple-900/30 rounded-full w-12 h-12 flex items-center justify-center flex-shrink-0">
                          <category.icon className="w-6 h-6 text-purple-600 dark:text-purple-400" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-1">
                            <h3 className={`${fontClasses.text} font-semibold text-gray-900 dark:text-gray-100 truncate`}>
                              {category.title}
                            </h3>
                            {category.badge && (
                              <Badge 
                                variant="secondary" 
                                className="bg-purple-100 dark:bg-purple-900/50 text-purple-700 dark:text-purple-300 text-xs"
                              >
                                {category.badge}
                              </Badge>
                            )}
                          </div>
                          <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400 leading-relaxed`}>
                            {category.description}
                          </p>
                        </div>
                        <div className="flex items-center">
                          <ArrowRight className="w-5 h-5 text-gray-400 dark:text-gray-500" />
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                </motion.div>
              ))}
            </div>
          </motion.div>
        </motion.div>

        {/* 특별 서비스 */}
        <motion.div variants={itemVariants}>
          <h2 className={`${fontClasses.title} font-bold text-gray-900 dark:text-gray-100 mb-4`}>특별 서비스</h2>
          <div className="grid grid-cols-2 gap-4">
            <Card
              className="cursor-pointer hover:shadow-md transition-shadow bg-gradient-to-br from-indigo-50 to-purple-50 dark:bg-gradient-to-br dark:from-indigo-900/20 dark:to-purple-900/20 border-indigo-200 dark:border-indigo-700"
              onClick={() => router.push("/premium")}
            >
              <CardContent className="p-4 text-center">
                <motion.div
                  className="bg-indigo-100 dark:bg-indigo-900/30 rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-3"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.5 }}
                >
                  <Sparkles className="w-6 h-6 text-indigo-600 dark:text-indigo-400" />
                </motion.div>
                <h3 className={`${fontClasses.text} font-semibold text-gray-900 dark:text-gray-100 mb-1`}>프리미엄사주</h3>
                <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400`}>만화로 보는 사주</p>
              </CardContent>
            </Card>

            <Card
              className="cursor-pointer hover:shadow-md transition-shadow bg-gradient-to-br from-green-50 to-emerald-50 dark:bg-gradient-to-br dark:from-green-900/20 dark:to-emerald-900/20 border-green-200 dark:border-green-700"
              onClick={() => router.push("/physiognomy")}
            >
              <CardContent className="p-4 text-center">
                <motion.div
                  className="bg-green-100 dark:bg-green-900/30 rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-3"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.5 }}
                >
                  <User className="w-6 h-6 text-green-600 dark:text-green-400" />
                </motion.div>
                <h3 className={`${fontClasses.text} font-semibold text-gray-900 dark:text-gray-100 mb-1`}>AI 관상</h3>
                <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400`}>얼굴로 보는 운세</p>
              </CardContent>
            </Card>
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
}
