"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { useRouter } from "next/navigation";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import {
  Heart,
  Star,
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
  Zap,
  PartyPopper,
  Crown,
  Home,
  BookOpen
  Gem
  AlertTriangle
  Rocket
} from "lucide-react";

interface FortuneCategory {
  id: string;
  title: string;
  description: string;
  icon: React.ComponentType<{ className?: string }>;
  route: string;
  color: string;
  gradient: string;
  badge?: string;
}

const fortuneCategories: FortuneCategory[] = [
  {
    id: "love",
    title: "연애운",
    description: "사랑과 인연의 흐름을 확인하세요",
    icon: Heart,
    route: "/fortune/love",
    color: "pink",
    gradient: "from-pink-50 to-red-50",
    badge: "인기"
  },
  {
    id: "destiny",
    title: "인연운",
    description: "앞으로 만나게 될 인연의 흐름을 알아보세요",
    icon: Users,
    route: "/fortune/destiny",
    color: "fuchsia",
    gradient: "from-fuchsia-50 to-rose-50",
    badge: "NEW"
  },
  {
    id: "career",
    title: "취업운",
    description: "커리어와 성공의 길을 찾아보세요",
    icon: Briefcase,
    route: "/fortune/career",
    color: "blue",
    gradient: "from-blue-50 to-indigo-50"
  },
  {
    id: "wealth",
    title: "금전운",
    description: "재물과 투자의 운을 살펴보세요",
    icon: Coins,
    route: "/fortune/wealth",
    color: "yellow",
    gradient: "from-yellow-50 to-orange-50"
  },
  {
    id: "saju",
    title: "사주팔자",
    description: "정통 사주로 인생의 큰 흐름을 파악하세요",
    icon: Calendar,
    route: "/fortune/saju",
    color: "purple",
    gradient: "from-purple-50 to-indigo-50",
    badge: "정통"
  },
  {
    id: "saju-psychology",
    title: "사주 심리분석",
    description: "타고난 성격과 관계를 심층 탐구",
    icon: Brain,
    route: "/fortune/saju-psychology",
    color: "teal",
    gradient: "from-teal-50 to-cyan-50",
    badge: "신규"
  },
  {
    id: "daily",
    title: "오늘의 운세",
    description: "총운, 애정운, 재물운, 건강운을 한 번에",
    icon: Star,
    route: "/fortune/daily",
    color: "emerald",
    gradient: "from-emerald-50 to-teal-50"
  },
  {
    id: "new-year",
    title: "신년운세",
    description: "새해 한 해의 흐름을 미리 확인하세요",
    icon: PartyPopper,
    route: "/fortune/new-year",
    color: "indigo",
    gradient: "from-indigo-50 to-blue-50",
    badge: "2025"
  },
  {
    id: "mbti",
    title: "MBTI 운세",
    description: "성격 유형별 맞춤 운세를 받아보세요",
    icon: User,
    route: "/fortune/mbti",
    color: "violet",
    gradient: "from-violet-50 to-purple-50",
    badge: "새로움"
  },
  {
    id: "zodiac-animal",
    title: "띠 운세",
    description: "12간지로 보는 이달의 운세를 확인하세요",
    icon: Crown,
    route: "/fortune/zodiac-animal",
    color: "orange",
    gradient: "from-orange-50 to-yellow-50",
    badge: "전통"
  },
  {
    id: "marriage",
    title: "결혼운",
    description: "평생의 동반자와의 인연을 확인하세요",
    icon: Heart,
    route: "/fortune/marriage",
    color: "rose",
    gradient: "from-rose-50 to-pink-50",
    badge: "특별"
  },
  {
    id: "couple-match",
    title: "짝궁합",
    description: "현재 연인의 관계 흐름과 미래를 알아보세요",
    icon: Heart,
    route: "/fortune/couple-match",
    color: "rose",
    gradient: "from-rose-50 to-pink-50",
    badge: "NEW"
  },
  {
    id: "moving",
    title: "이사운",
    description: "새로운 보금자리로의 행복한 이주를 확인하세요",
    icon: Home,
    route: "/fortune/moving",
    color: "emerald",
    gradient: "from-emerald-50 to-green-50",
    badge: "인기"
  },
  {
    id: "business",
    title: "사업운",
    description: "성공적인 창업과 사업 운영을 위한 운세를 확인하세요",
    icon: TrendingUp,
    route: "/fortune/business",
    color: "indigo",
    gradient: "from-indigo-50 to-purple-50",
    badge: "추천"
  },
  {
    id: "past-life",
    title: "전생운",
    description: "과거 생의 직업과 성격을 알아보세요",
    icon: BookOpen,
    route: "/fortune/past-life",
    color: "indigo",
    gradient: "from-indigo-50 to-purple-50",
    badge: "신비"
  },{
    id: "startup",
    title: "행운의 창업",
    description: "어떤 업종이 잘 맞는지, 시작 시기를 알아보세요",
    icon: Rocket,
    route: "/fortune/startup",
    color: "orange",
    gradient: "from-orange-50 to-amber-50",
    badge: "NEW"
  },
  {
    id: "palmistry",
    title: "손금",
    description: "손에 새겨진 인생의 지도를 읽어보세요",
    icon: Zap,
    route: "/fortune/palmistry",
    color: "amber",
    gradient: "from-amber-50 to-yellow-50",
    badge: "전통"
  },
  {
    id: "birthstone",
    title: "탄생석",
    description: "생일로 알아보는 행운의 보석",
    icon: Gem,
    route: "/fortune/birthstone",
    color: "sky",
    gradient: "from-sky-50 to-indigo-50",
    badge: "신규"
    id: "avoid-people",
    title: "피해야 할 상대",
    description: "갈등을 줄이기 위해 조심해야 할 상대를 알아보세요",
    icon: AlertTriangle,
    route: "/fortune/avoid-people",
    color: "red",
    gradient: "from-red-50 to-orange-50",
    badge: "주의"
  }
];

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

export default function FortunePage() {
  const router = useRouter();
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');

  const handleCategoryClick = (route: string) => {
    router.push(route);
  };

  return (
    <>
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
            <h1 className="text-2xl font-bold text-gray-900">운세 서비스</h1>
          </div>
          <p className="text-gray-600 leading-relaxed">
            다양한 분야의 운세를 통해 오늘의 운명을 확인해보세요
          </p>
        </motion.div>

        {/* 오늘의 추천 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-purple-50 to-pink-50 border-purple-200">
            <CardHeader>
              <div className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-purple-600" />
                <CardTitle className="text-purple-800">오늘의 추천</CardTitle>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="font-semibold text-purple-900 mb-1">연애운</h3>
                  <p className="text-sm text-purple-700">새로운 만남의 기회가 열리는 날입니다</p>
                </div>
                <Badge className="bg-purple-100 text-purple-700 hover:bg-purple-200">
                  85점
                </Badge>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 운세 카테고리 */}
        <motion.div variants={itemVariants}>
          <h2 className="text-xl font-bold text-gray-900 mb-4">분야별 운세</h2>
          <div className="grid grid-cols-1 gap-4">
            {fortuneCategories.map((category, index) => (
              <motion.div
                key={category.id}
                variants={itemVariants}
                whileHover={{ scale: 1.02, y: -2 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => handleCategoryClick(category.route)}
                className="cursor-pointer"
              >
                <Card className={`hover:shadow-md transition-all duration-300 bg-gradient-to-r ${category.gradient} border-${category.color}-200`}>
                  <CardContent className="p-4">
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-4">
                        <motion.div 
                          className={`bg-${category.color}-100 rounded-full w-12 h-12 flex items-center justify-center`}
                          whileHover={{ rotate: 360 }}
                          transition={{ duration: 0.5 }}
                        >
                          <category.icon className={`w-6 h-6 text-${category.color}-600`} />
                        </motion.div>
                        <div>
                          <div className="flex items-center gap-2 mb-1">
                            <h3 className="font-semibold text-gray-900">{category.title}</h3>
                            {category.badge && (
                              <Badge variant="secondary" className={`bg-${category.color}-100 text-${category.color}-700 text-xs`}>
                                {category.badge}
                              </Badge>
                            )}
                          </div>
                          <p className="text-sm text-gray-600">{category.description}</p>
                        </div>
                      </div>
                      <motion.div
                        animate={{ x: [0, 5, 0] }}
                        transition={{ repeat: Infinity, duration: 2 }}
                      >
                        <Zap className={`w-5 h-5 text-${category.color}-600`} />
                      </motion.div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </div>
        </motion.div>

        {/* 특별 서비스 */}
        <motion.div variants={itemVariants}>
          <h2 className="text-xl font-bold text-gray-900 mb-4">특별 서비스</h2>
          <div className="grid grid-cols-2 gap-4">
            <Card 
              className="cursor-pointer hover:shadow-md transition-shadow bg-gradient-to-br from-indigo-50 to-purple-50 border-indigo-200"
              onClick={() => router.push('/interactive/tarot')}
            >
              <CardContent className="p-4 text-center">
                <motion.div 
                  className="bg-indigo-100 rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-3"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.5 }}
                >
                  <Sparkles className="w-6 h-6 text-indigo-600" />
                </motion.div>
                <h3 className="font-semibold text-gray-900 mb-1">타로 리딩</h3>
                <p className="text-xs text-gray-600">카드가 주는 메시지</p>
              </CardContent>
            </Card>
            
            <Card 
              className="cursor-pointer hover:shadow-md transition-shadow bg-gradient-to-br from-green-50 to-emerald-50 border-green-200"
              onClick={() => router.push('/physiognomy')}
            >
              <CardContent className="p-4 text-center">
                <motion.div 
                  className="bg-green-100 rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-3"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.5 }}
                >
                  <User className="w-6 h-6 text-green-600" />
                </motion.div>
                <h3 className="font-semibold text-gray-900 mb-1">AI 관상</h3>
                <p className="text-xs text-gray-600">얼굴로 보는 운세</p>
              </CardContent>
            </Card>
          </div>
        </motion.div>
      </motion.div>
    </>
  );
} 