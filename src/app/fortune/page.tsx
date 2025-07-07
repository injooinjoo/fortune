"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { useRouter } from "next/navigation";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import AppHeader from "@/components/AppHeader";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useHaptic } from "@/hooks/use-haptic";
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
  detailedDescription?: string; // 포커스 시 표시될 상세 설명
  theme?: {
    concept: string;
    primaryColor: string;
    secondaryColor: string;
    accentColor: string;
    focusGradient: string;
    backgroundGradient: string;
    emoji: string;
    cardShape?: string; // clip-path or custom shape
    specialEffect?: string; // unique effect type
    animation?: string; // custom animation
  };
}

// 기본 테마 정의 함수 (카드 모양 통일)
const getDefaultTheme = (category: FortuneCategoryType) => {
  const themes = {
    love: {
      concept: "사랑과 인연의 기운",
      primaryColor: "#ec4899",
      secondaryColor: "#f9a8d4", 
      accentColor: "#fbbf24",
      focusGradient: "from-pink-100 via-rose-100 to-red-100",
      backgroundGradient: "from-pink-50/80 via-rose-50/60 to-red-50/40",
      emoji: "💖",
      specialEffect: "heart-particles",
      animation: "love-pulse"
    },
    career: {
      concept: "성공과 발전의 기운",
      primaryColor: "#3b82f6",
      secondaryColor: "#93c5fd",
      accentColor: "#c0c7d1",
      focusGradient: "from-blue-100 via-indigo-100 to-slate-100",
      backgroundGradient: "from-blue-50/80 via-indigo-50/60 to-slate-50/40",
      emoji: "🚀",
      specialEffect: "success-particles",
      animation: "success-rise"
    },
    money: {
      concept: "풍요와 번영의 기운",
      primaryColor: "#f59e0b",
      secondaryColor: "#fcd34d",
      accentColor: "#10b981",
      focusGradient: "from-yellow-100 via-amber-100 to-orange-100",
      backgroundGradient: "from-yellow-50/80 via-amber-50/60 to-orange-50/40",
      emoji: "💰",
      specialEffect: "coin-particles",
      animation: "wealth-shine"
    },
    health: {
      concept: "자연과 생명의 기운",
      primaryColor: "#10b981",
      secondaryColor: "#6ee7b7",
      accentColor: "#3b82f6",
      focusGradient: "from-green-100 via-emerald-100 to-teal-100",
      backgroundGradient: "from-green-50/80 via-emerald-50/60 to-teal-50/40",
      emoji: "🌿",
      specialEffect: "energy-particles",
      animation: "nature-breathe"
    },
    traditional: {
      concept: "전통과 신비의 기운",
      primaryColor: "#d97706",
      secondaryColor: "#fbbf24",
      accentColor: "#7c3aed",
      focusGradient: "from-amber-100 via-orange-100 to-yellow-100",
      backgroundGradient: "from-amber-50/80 via-orange-50/60 to-yellow-50/40",
      emoji: "🏛️",
      specialEffect: "mystical-particles",
      animation: "traditional-rotate"
    },
    lifestyle: {
      concept: "일상의 마법과 행복",
      primaryColor: "#8b5cf6",
      secondaryColor: "#c4b5fd",
      accentColor: "#06b6d4",
      focusGradient: "from-violet-100 via-purple-100 to-indigo-100",
      backgroundGradient: "from-violet-50/80 via-purple-50/60 to-indigo-50/40",
      emoji: "✨",
      specialEffect: "magic-particles",
      animation: "sparkle-twinkle"
    }
  };
  return themes[category] || themes.lifestyle;
};

// 각 운세별 상세 설명 텍스트
const getDetailedDescription = (category: FortuneCategoryType, title: string) => {
  const descriptions: Record<string, string> = {
    // 연애·인연
    love: "새로운 사랑의 시작과 기존 관계의 발전 가능성을 살펴봅니다. 당신의 마음이 열리고 상대방과의 깊은 연결을 느낄 수 있는 시기입니다.",
    marriage: "평생의 동반자를 만날 수 있는 운명적 만남의 시기와 결혼 생활의 행복도를 확인해보세요.",
    // 취업·사업  
    career: "직업적 성장과 새로운 기회의 문이 열리는 시기입니다. 당신의 능력이 인정받고 성공으로 이어질 가능성을 살펴봅니다.",
    business: "창업이나 사업 확장에 유리한 시기와 투자 타이밍을 확인할 수 있습니다.",
    // 재물·투자
    wealth: "금전적 풍요와 재물 증식의 기회가 찾아올 시기입니다. 현명한 투자와 저축으로 안정적인 미래를 준비하세요.",
    // 건강·라이프
    biorhythm: "몸과 마음의 자연스러운 리듬을 이해하고 최적의 컨디션을 유지할 수 있는 방법을 알려드립니다.",
    moving: "새로운 환경에서의 행복한 시작과 긍정적인 변화를 맞이할 수 있는 최적의 시기를 찾아보세요.",
    // 전통·사주
    saju: "타고난 운명과 사주에 담긴 깊은 의미를 통해 인생의 방향을 찾고 현명한 선택을 할 수 있도록 도와드립니다.",
    tojeong: "전통 토정비결의 지혜로 새해의 길흉을 미리 살펴보고 준비할 수 있습니다.",
    // 생활·운세
    today: "오늘 하루를 더욱 의미있게 보낼 수 있는 조언과 긍정적인 에너지를 받아보세요.",
    hourly: "시간대별로 달라지는 운의 흐름을 파악하여 중요한 일정을 최적의 시간에 배치하세요."
  };
  
  return descriptions[title.toLowerCase()] || descriptions[category] || "당신만을 위한 특별한 운세 해석을 통해 더 나은 미래를 준비하세요.";
};

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
    description: "💕 사랑과 인연의 흐름을 확인하세요",
    icon: Heart,
    route: "/fortune/love",
    color: "pink",
    gradient: "from-pink-50 to-red-50",
    badge: "인기",
    category: "love",
    detailedDescription: "새로운 사랑의 시작과 기존 관계의 발전 가능성을 살펴봅니다. 당신의 마음이 열리고 상대방과의 깊은 연결을 느낄 수 있는 시기입니다.",
    theme: {
      concept: "로맨틱한 설렘과 따뜻한 사랑",
      primaryColor: "#ec4899", // pink-500
      secondaryColor: "#f9a8d4", // pink-300
      accentColor: "#fbbf24", // amber-400 (황금)
      focusGradient: "from-pink-100 via-rose-100 to-red-100",
      backgroundGradient: "from-pink-50/80 via-rose-50/60 to-red-50/40",
      emoji: "💖",
      specialEffect: "heart-particles",
      animation: "love-pulse"
    }
  },
  {
    id: "marriage",
    title: "결혼운",
    description: "💍 평생의 동반자와의 인연을 확인하세요",
    icon: Heart,
    route: "/fortune/marriage",
    color: "rose",
    gradient: "from-rose-50 to-pink-50",
    badge: "특별",
    category: "love",
    detailedDescription: "평생의 동반자를 만날 수 있는 운명적 만남의 시기와 결혼 생활의 행복도를 확인해보세요.",
    theme: {
      concept: "영원한 사랑과 약속",
      primaryColor: "#f43f5e", // rose-500
      secondaryColor: "#fda4af", // rose-300
      accentColor: "#fbbf24", // amber-400 (황금)
      focusGradient: "from-rose-100 via-pink-100 to-red-100",
      backgroundGradient: "from-rose-50/80 via-pink-50/60 to-red-50/40",
      emoji: "💍",
      specialEffect: "ring-sparkle",
      animation: "wedding-bells"
    }
  },
  {
    id: "compatibility",
    title: "궁합",
    description: "💑 두 사람의 궁합을 확인하세요",
    icon: Users,
    route: "/fortune/compatibility",
    color: "pink",
    gradient: "from-pink-50 to-rose-50",
    category: "love",
    theme: {
      concept: "조화로운 인연의 만남",
      primaryColor: "#ec4899", // pink-500
      secondaryColor: "#f9a8d4", // pink-300
      accentColor: "#8b5cf6", // violet-500
      focusGradient: "from-pink-100 via-rose-100 to-violet-100",
      backgroundGradient: "from-pink-50/80 via-rose-50/60 to-violet-50/40",
      emoji: "💑"
    }
  },
  // 취업·사업
  {
    id: "career",
    title: "취업운",
    description: "💼 커리어와 성공의 길을 찾아보세요",
    icon: Briefcase,
    route: "/fortune/career",
    color: "blue",
    gradient: "from-blue-50 to-indigo-50",
    category: "career",
    detailedDescription: "직업적 성장과 새로운 기회의 문이 열리는 시기입니다. 당신의 능력이 인정받고 성공으로 이어질 가능성을 살펴봅니다.",
    theme: {
      concept: "전문성과 성공의 상승",
      primaryColor: "#3b82f6", // blue-500
      secondaryColor: "#93c5fd", // blue-300
      accentColor: "#c0c7d1", // slate-300 (실버)
      focusGradient: "from-blue-100 via-indigo-100 to-slate-100",
      backgroundGradient: "from-blue-50/80 via-indigo-50/60 to-slate-50/40",
      emoji: "🚀",
      specialEffect: "stair-climb",
      animation: "success-rise"
    }
  },
  {
    id: "business",
    title: "사업운",
    description: "📈 성공적인 창업과 사업 운영을 위한 운세를 확인하세요",
    icon: TrendingUp,
    route: "/fortune/business",
    color: "indigo",
    gradient: "from-indigo-50 to-purple-50",
    badge: "추천",
    category: "career",
    theme: {
      concept: "야망과 혁신의 도전",
      primaryColor: "#6366f1", // indigo-500
      secondaryColor: "#a5b4fc", // indigo-300
      accentColor: "#c0c7d1", // slate-300 (실버)
      focusGradient: "from-indigo-100 via-purple-100 to-slate-100",
      backgroundGradient: "from-indigo-50/80 via-purple-50/60 to-slate-50/40",
      emoji: "💪"
    }
  },
  // 재물·투자
  {
    id: "wealth",
    title: "금전운",
    description: "💰 재물과 투자의 운을 살펴보세요",
    icon: Coins,
    route: "/fortune/wealth",
    color: "yellow",
    gradient: "from-yellow-50 to-orange-50",
    category: "money",
    detailedDescription: "금전적 풍요와 재물 증식의 기회가 찾아올 시기입니다. 현명한 투자와 저축으로 안정적인 미래를 준비하세요.",
    theme: {
      concept: "황금빛 풍요와 번영",
      primaryColor: "#f59e0b", // amber-500
      secondaryColor: "#fcd34d", // amber-300
      accentColor: "#10b981", // emerald-500
      focusGradient: "from-yellow-100 via-amber-100 to-orange-100",
      backgroundGradient: "from-yellow-50/80 via-amber-50/60 to-orange-50/40",
      emoji: "✨",
      specialEffect: "coin-waterfall",
      animation: "wealth-shine"
    }
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
  const [isProcessing, setIsProcessing] = useState(false); // 중복 클릭 방지용 상태
  
  // 최근 본 운세 추가를 위한 hook
  useFortuneStream();
  
  // 햅틱 피드백 훅
  const { selectFeedback } = useHaptic();

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
    // 이미 처리 중이면 클릭 무시
    if (isProcessing) {
      console.log('이미 처리 중입니다. 중복 클릭 방지됨.');
      return;
    }
    
    // 중복 클릭 방지 플래그 설정
    setIsProcessing(true);
    
    // 프리미엄, 일반 사용자 모두 로딩 화면 표시 (분석하는 척)
    selectFeedback(); // 선택 햅틱 피드백
    
    // 바로 운세 페이지로 이동 (각 운세 페이지에서 광고 화면 처리)
    setTimeout(() => {
      router.push(route);
    }, 100); // 짧은 지연
  };

  // 광고 로딩 화면은 이제 각 운세 페이지에서 직접 처리
  
  return (
    <div className="min-h-screen bg-gray-50">
      <AppHeader
        title="운세"
        showBack={false}
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div
        className="pb-32 pt-16 px-4 max-w-4xl mx-auto"
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
          <Card className="bg-white border border-gray-200">
            <CardHeader>
              <div className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-gray-700" />
                <CardTitle className={`${fontClasses.title} text-gray-900`}>오늘의 추천</CardTitle>
              </div>
            </CardHeader>
            <CardContent>
              <div className="flex items-center justify-between">
                <div>
                  <h3 className={`${fontClasses.text} font-semibold text-gray-900 mb-1`}>연애운</h3>
                  <p className={`${fontClasses.label} text-gray-600`}>
                    새로운 만남의 기회가 열리는 날입니다
                  </p>
                </div>
                <Badge className={`${fontClasses.label} bg-gray-100 text-gray-700`}>
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
            
            <div className="grid grid-cols-2 gap-4">
              {filteredCategories.map((category, index) => {

                return (
                  <motion.div
                    key={category.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ 
                      opacity: 1, 
                      y: 0
                    }}
                    transition={{ 
                      delay: index * 0.05
                    }}
                    whileHover={{ y: -4 }}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => handleCategoryClick(category.route, category.title)}
                    className="cursor-pointer"
                  >
                    <Card 
                      className="bg-white hover:shadow-md transition-all duration-200 border border-gray-200 overflow-hidden rounded-lg aspect-square"
                    >
                      <CardContent className="p-4 relative h-full flex flex-col justify-between">
                        {/* 상단 영역: 아이콘과 제목 */}
                        <div className="flex flex-col items-center text-center">
                          <div className="bg-gray-100 rounded-full w-16 h-16 flex items-center justify-center mb-3">
                            <category.icon className="w-8 h-8 text-gray-700" />
                          </div>
                          <h3 className={`${fontClasses.title} font-bold text-gray-900 mb-1`}>
                            {category.title}
                          </h3>
                          {category.badge && (
                            <Badge variant="secondary" className="text-xs mb-2">
                              {category.badge}
                            </Badge>
                          )}
                        </div>
                        
                        {/* 중앙 영역: 설명 */}
                        <p className={`${fontClasses.label} text-gray-600 text-center px-2 line-clamp-2`}>
                          {category.description}
                        </p>
                        
                        {/* 하단 영역: 화살표 */}
                        <div className="flex justify-center">
                          <ArrowRight className="w-4 h-4 text-gray-400" />
                        </div>
                      </CardContent>
                    </Card>
                  </motion.div>
                );
              })}
            </div>
          </motion.div>
        </motion.div>

        {/* 특별 서비스 */}
        <motion.div variants={itemVariants}>
          <h2 className={`${fontClasses.title} font-bold text-gray-900 mb-4`}>특별 서비스</h2>
          <div className="grid grid-cols-2 gap-4">
            <Card
              className="cursor-pointer hover:shadow-md transition-shadow bg-white border border-gray-200 aspect-square"
              onClick={() => router.push("/premium")}
            >
              <CardContent className="p-4 h-full flex flex-col items-center justify-center text-center">
                <div className="bg-gray-100 rounded-full w-16 h-16 flex items-center justify-center mb-3">
                  <Sparkles className="w-8 h-8 text-gray-700" />
                </div>
                <h3 className={`${fontClasses.text} font-semibold text-gray-900 mb-1`}>프리미엄사주</h3>
                <p className={`${fontClasses.label} text-gray-600`}>만화로 보는 사주</p>
              </CardContent>
            </Card>

            <Card
              className="cursor-pointer hover:shadow-md transition-shadow bg-white border border-gray-200 aspect-square"
              onClick={() => router.push("/physiognomy")}
            >
              <CardContent className="p-4 h-full flex flex-col items-center justify-center text-center">
                <div className="bg-gray-100 rounded-full w-16 h-16 flex items-center justify-center mb-3">
                  <User className="w-8 h-8 text-gray-700" />
                </div>
                <h3 className={`${fontClasses.text} font-semibold text-gray-900 mb-1`}>AI 관상</h3>
                <p className={`${fontClasses.label} text-gray-600`}>얼굴로 보는 운세</p>
              </CardContent>
            </Card>
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
}
