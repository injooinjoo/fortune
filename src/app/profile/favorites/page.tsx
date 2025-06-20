"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Switch } from "@/components/ui/switch";
import AppHeader from "@/components/AppHeader";
import { 
  ArrowLeft, 
  Heart, 
  Star, 
  Sun, 
  Moon,
  Crown,
  Briefcase,
  Coins,
  Home,
  TrendingUp,
  Users,
  Calendar,
  Zap,
  Mountain,
  Activity
} from "lucide-react";

interface FavoriteItem {
  id: string;
  name: string;
  description: string;
  icon: any;
  color: string;
  enabled: boolean;
  category: string;
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

export default function FavoritesPage() {
  const router = useRouter();
  const [favorites, setFavorites] = useState<FavoriteItem[]>([
    {
      id: 'daily',
      name: '일일 운세',
      description: '매일 확인하는 기본 운세',
      icon: Sun,
      color: 'orange',
      enabled: true,
      category: '기본'
    },
    {
      id: 'love',
      name: '연애운',
      description: '사랑과 인연의 흐름',
      icon: Heart,
      color: 'pink',
      enabled: true,
      category: '관계'
    },
    {
      id: 'career',
      name: '취업운',
      description: '커리어와 성공의 길',
      icon: Briefcase,
      color: 'blue',
      enabled: true,
      category: '직업'
    },
    {
      id: 'wealth',
      name: '금전운',
      description: '재물과 투자의 운',
      icon: Coins,
      color: 'yellow',
      enabled: false,
      category: '재물'
    },
    {
      id: 'moving',
      name: '이사운',
      description: '새로운 보금자리의 운',
      icon: Home,
      color: 'emerald',
      enabled: false,
      category: '생활'
    },
    {
      id: 'business',
      name: '사업운',
      description: '창업과 사업 성공의 운',
      icon: TrendingUp,
      color: 'indigo',
      enabled: false,
      category: '직업'
    },
    {
      id: 'compatibility',
      name: '궁합',
      description: '둘의 운명적 만남',
      icon: Users,
      color: 'rose',
      enabled: false,
      category: '관계'
    },
    {
      id: 'mbti',
      name: 'MBTI 운세',
      description: '성격 유형별 조언',
      icon: Zap,
      color: 'violet',
      enabled: false,
      category: '성격'
    },
    {
      id: 'lucky-hiking',
      name: '행운의 등산',
      description: '등산을 통해 보는 운세',
      icon: Mountain,
      color: 'green',
      enabled: false,
      category: '취미'
    }
  ]);

  const toggleFavorite = (id: string) => {
    setFavorites(prev => 
      prev.map(item => 
        item.id === id ? { ...item, enabled: !item.enabled } : item
      )
    );
  };

  const getColorClasses = (color: string, enabled: boolean) => {
    if (!enabled) return 'text-gray-400 bg-gray-50 dark:bg-gray-800';
    
    switch (color) {
      case 'orange': return 'text-orange-600 bg-orange-50 dark:bg-orange-900/20';
      case 'pink': return 'text-pink-600 bg-pink-50 dark:bg-pink-900/20';
      case 'blue': return 'text-blue-600 bg-blue-50 dark:bg-blue-900/20';
      case 'yellow': return 'text-yellow-600 bg-yellow-50 dark:bg-yellow-900/20';
      case 'emerald': return 'text-emerald-600 bg-emerald-50 dark:bg-emerald-900/20';
      case 'indigo': return 'text-indigo-600 bg-indigo-50 dark:bg-indigo-900/20';
      case 'rose': return 'text-rose-600 bg-rose-50 dark:bg-rose-900/20';
      case 'violet': return 'text-violet-600 bg-violet-50 dark:bg-violet-900/20';
      case 'green': return 'text-green-600 bg-green-50 dark:bg-green-900/20';
      default: return 'text-gray-600 bg-gray-50 dark:bg-gray-800';
    }
  };

  const categories = [...new Set(favorites.map(item => item.category))];
  const enabledCount = favorites.filter(item => item.enabled).length;

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-25 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="즐겨찾기 관리" />

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6"
      >
        {/* 선택 개수 표시 */}
        <motion.div variants={itemVariants} className="mb-6">
          <div className="flex items-center justify-between">
            <div>
              <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">
                자주 보는 운세 선택
              </h2>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                홈에서 우선적으로 표시됩니다
              </p>
            </div>
            <Badge variant="secondary" className="text-xs">
              {enabledCount}개 선택
            </Badge>
          </div>
        </motion.div>
        {/* 요약 카드 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white border-0">
            <CardContent className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <h2 className="text-lg font-semibold mb-1">나의 즐겨찾기</h2>
                  <p className="text-white/80 text-sm">
                    선택한 운세들이 홈 화면에 우선 표시됩니다
                  </p>
                </div>
                <div className="text-right">
                  <div className="text-2xl font-bold">{enabledCount}</div>
                  <div className="text-white/60 text-xs">개 운세</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 카테고리별 운세 목록 */}
        {categories.map((category, categoryIndex) => (
          <motion.div key={category} variants={itemVariants}>
            <Card>
              <CardHeader className="pb-4">
                <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                  <Star className="w-5 h-5 text-yellow-500" />
                  {category} 운세
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {favorites
                  .filter(item => item.category === category)
                  .map((item, index) => (
                    <motion.div
                      key={item.id}
                      initial={{ x: -20, opacity: 0 }}
                      animate={{ x: 0, opacity: 1 }}
                      transition={{ delay: categoryIndex * 0.1 + index * 0.05 }}
                      className={`flex items-center justify-between p-4 rounded-lg border transition-all duration-200 ${
                        item.enabled 
                          ? 'border-purple-200 dark:border-purple-700 bg-purple-50/50 dark:bg-purple-900/10' 
                          : 'border-gray-200 dark:border-gray-700 bg-gray-50/50 dark:bg-gray-800/50'
                      }`}
                    >
                      <div className="flex items-center gap-3">
                        <div className={`w-10 h-10 rounded-full flex items-center justify-center ${getColorClasses(item.color, item.enabled)}`}>
                          <item.icon className="w-5 h-5" />
                        </div>
                        <div>
                          <h3 className={`font-medium ${item.enabled ? 'text-gray-900 dark:text-gray-100' : 'text-gray-500 dark:text-gray-400'}`}>
                            {item.name}
                          </h3>
                          <p className={`text-sm ${item.enabled ? 'text-gray-600 dark:text-gray-300' : 'text-gray-400 dark:text-gray-500'}`}>
                            {item.description}
                          </p>
                        </div>
                      </div>
                      <Switch
                        checked={item.enabled}
                        onCheckedChange={() => toggleFavorite(item.id)}
                      />
                    </motion.div>
                  ))}
              </CardContent>
            </Card>
          </motion.div>
        ))}

        {/* 도움말 */}
        <motion.div variants={itemVariants}>
          <Card className="border-blue-200 dark:border-blue-700 bg-blue-50/50 dark:bg-blue-900/10">
            <CardContent className="p-4">
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Star className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                </div>
                <div>
                  <h3 className="font-medium text-blue-900 dark:text-blue-100 mb-1">
                    즐겨찾기 활용 팁
                  </h3>
                  <ul className="text-sm text-blue-700 dark:text-blue-300 space-y-1">
                    <li>• 자주 보는 운세를 선택하면 홈 화면에서 쉽게 찾을 수 있어요</li>
                    <li>• 최대 5개까지 선택하는 것을 권장합니다</li>
                    <li>• 언제든지 변경할 수 있어요</li>
                  </ul>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
} 