"use client";

import { useEffect, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { auth } from "@/lib/supabase";
import AppHeader from "@/components/AppHeader";
import { 
  Sparkles, 
  Camera, 
  BookOpen, 
  Star, 
  Moon, 
  Sun,
  Heart,
  Briefcase,
  Coins,
  Calendar,
  TrendingUp,
  Zap,
  Crown,
  Home,
  Hand,
  Users,
  HeartCrack,
  Coffee,
  Clock,
  Flame,
  Brain,
  Gift,
  Activity,
  Target,
  DollarSign,
  CircleDot,
  Bike,
  Footprints,
  Building2,
  UtensilsCrossed,
  GraduationCap,
  Dice5,
  Shirt,
  Waves,
  Fish,
  Mountain,
  UserX,
  CakeSlice,
  Gem,
  CloudSnow,
  Droplets,
  Users2,
  MapPin,
  Megaphone,
  Rocket,
  Palette,
  Shield,
  LineChart,
  Lightbulb,
  Scroll,
  Timer,
  ScrollText,
  Sunrise,
  Sunset,
  ScrollIcon,
  HelpCircle,
  Building,
  History,
  ArrowRight
} from "lucide-react";

// 운세 카테고리 정보 매핑
const fortuneInfo: Record<string, { icon: any; title: string; desc: string; color: string; gradient: string }> = {
  "saju": { icon: Sun, title: "사주팔자", desc: "정통 사주 풀이", color: "orange", gradient: "from-orange-50 to-yellow-50" },
  "love": { icon: Heart, title: "연애운", desc: "사랑과 인연의 흐름", color: "pink", gradient: "from-pink-50 to-red-50" },
  "marriage": { icon: Heart, title: "결혼운", desc: "평생의 동반자 운세", color: "rose", gradient: "from-rose-50 to-pink-50" },
  "career": { icon: Briefcase, title: "취업운", desc: "커리어와 성공의 길", color: "blue", gradient: "from-blue-50 to-indigo-50" },
  "wealth": { icon: Coins, title: "금전운", desc: "재물과 투자의 운", color: "yellow", gradient: "from-yellow-50 to-orange-50" },
  "moving": { icon: Home, title: "이사운", desc: "새로운 보금자리의 운", color: "emerald", gradient: "from-emerald-50 to-green-50" },
  "business": { icon: TrendingUp, title: "사업운", desc: "창업과 사업 성공의 운", color: "indigo", gradient: "from-indigo-50 to-purple-50" },
  "palmistry": { icon: Hand, title: "손금", desc: "손에 새겨진 운명의 선", color: "amber", gradient: "from-amber-50 to-yellow-50" },
  "saju-psychology": { icon: Brain, title: "사주 심리분석", desc: "성격과 관계 심층 탐구", color: "teal", gradient: "from-teal-50 to-cyan-50" },
  "compatibility": { icon: Users, title: "궁합", desc: "둘의 운명적 만남", color: "rose", gradient: "from-rose-50 to-pink-50" },
  "lucky-hiking": { icon: Mountain, title: "행운의 등산", desc: "등산을 통해 보는 당신의 운세", color: "green", gradient: "from-green-50 to-emerald-50" },
  "daily": { icon: Sun, title: "일일 운세", desc: "매일 달라지는 운의 흐름", color: "orange", gradient: "from-orange-50 to-yellow-50" },
  "mbti": { icon: Zap, title: "MBTI 운세", desc: "성격 유형별 조언", color: "violet", gradient: "from-violet-50 to-purple-50" },
  "zodiac": { icon: Star, title: "별자리 운세", desc: "별이 알려주는 흐름", color: "cyan", gradient: "from-cyan-50 to-blue-50" },
  "zodiac-animal": { icon: Crown, title: "띠 운세", desc: "12간지로 보는 운세", color: "orange", gradient: "from-orange-50 to-yellow-50" }
};

// 최근 본 운세 타입
interface RecentFortune {
  path: string;
  title: string;
  visitedAt: number;
}

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

export default function HomePage() {
  const router = useRouter();
  const [name, setName] = useState<string>("사용자");
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [recentFortunes, setRecentFortunes] = useState<RecentFortune[]>([]);

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

  // 최근 본 운세 불러오기
  useEffect(() => {
    const loadRecentFortunes = () => {
      try {
        const stored = localStorage.getItem('recentFortunes');
        if (stored) {
          const parsed = JSON.parse(stored);
          // 최신순으로 정렬하고 최대 5개까지만 표시
          const sorted = parsed.sort((a: RecentFortune, b: RecentFortune) => b.visitedAt - a.visitedAt).slice(0, 5);
          setRecentFortunes(sorted);
        }
      } catch (error) {
        console.error('최근 본 운세 로드 실패:', error);
      }
    };

    loadRecentFortunes();
  }, []);

  // 최근 본 운세 추가/업데이트
  const addToRecentFortunes = (path: string, title: string) => {
    try {
      const stored = localStorage.getItem('recentFortunes');
      let fortunes: RecentFortune[] = stored ? JSON.parse(stored) : [];
      
      // 기존에 같은 path가 있으면 제거
      fortunes = fortunes.filter(f => f.path !== path);
      
      // 새로운 항목을 맨 앞에 추가
      fortunes.unshift({
        path,
        title,
        visitedAt: Date.now()
      });
      
      // 최대 10개까지만 저장
      fortunes = fortunes.slice(0, 10);
      
      localStorage.setItem('recentFortunes', JSON.stringify(fortunes));
      setRecentFortunes(fortunes.slice(0, 5)); // UI에는 5개까지만 표시
    } catch (error) {
      console.error('최근 본 운세 저장 실패:', error);
    }
  };

  // 운세 페이지로 이동할 때 최근 본 운세에 추가
  const handleFortuneClick = (path: string, title: string) => {
    addToRecentFortunes(path, title);
    router.push(path);
  };

  // 운세 경로에서 키 추출
  const getFortuneKey = (path: string) => {
    const match = path.match(/\/fortune\/([^\/]+)/);
    return match ? match[1] : '';
  };

  useEffect(() => {
    const { data: { subscription } } = auth.onAuthStateChanged((currentUser: any) => {
      if (!currentUser) {
        router.push("/auth/selection");
      } else {
        const stored = localStorage.getItem("userProfile");
        if (stored) {
          try {
            const profile = JSON.parse(stored);
            setName(profile.name);
          } catch {
            setName(currentUser.user_metadata?.name || "사용자");
          }
        } else {
          setName(currentUser.user_metadata?.name || "사용자");
        }
      }
    });

    return () => subscription?.unsubscribe();
  }, [router]);

  const today = {
    score: 85,
    keywords: ["도전", "결실", "행운"],
    summary: "새로운 시도가 좋은 결과로 이어지는 날입니다.",
    luckyColor: "#8B5CF6",
    luckyNumber: 7
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-indigo-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 pb-20">
      <AppHeader 
        title="Fortune" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-4"
      >
        {/* 오늘의 운세 카드 */}
        <motion.div variants={itemVariants} className="mb-8">
          <motion.div
            variants={cardVariants}
            whileHover="hover"
            whileTap={{ scale: 0.98 }}
          >
            <Card className="bg-gradient-to-r from-purple-500 to-indigo-600 text-white shadow-xl overflow-hidden">
              <CardHeader className="pb-4">
                <div className="flex items-center justify-between">
                  <CardTitle className={`${fontClasses.title} font-bold`}>오늘의 운세</CardTitle>
                  <motion.div 
                    className="bg-white/20 rounded-full px-3 py-1"
                    animate={{ scale: [1, 1.05, 1] }}
                    transition={{ repeat: Infinity, duration: 3 }}
                  >
                    <span className={`${fontClasses.label} font-semibold`}>{today.score}점</span>
                  </motion.div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className={`${fontClasses.text} text-white/90 leading-relaxed`}>{today.summary}</p>
                
                <div className="flex flex-wrap gap-2">
                  {today.keywords.map((keyword, index) => (
                    <motion.div
                      key={keyword}
                      initial={{ scale: 0, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      transition={{ delay: 0.6 + index * 0.1 }}
                    >
                      <Badge variant="secondary" className={`${fontClasses.label} bg-white/20 text-white border-white/30`}>
                        #{keyword}
                      </Badge>
                    </motion.div>
                  ))}
                </div>

                <div className="flex items-center justify-between pt-2 border-t border-white/20">
                  <div className="flex items-center gap-2">
                    <motion.div 
                      className="w-4 h-4 rounded-full border-2 border-white"
                      style={{ backgroundColor: today.luckyColor }}
                      animate={{ rotate: 360 }}
                      transition={{ repeat: Infinity, duration: 10, ease: "linear" }}
                    />
                    <span className={fontClasses.label}>행운의 색상</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <motion.div
                      animate={{ rotate: [0, 10, -10, 0] }}
                      transition={{ repeat: Infinity, duration: 2 }}
                    >
                      <Star className="w-4 h-4" />
                    </motion.div>
                    <span className={fontClasses.label}>행운의 숫자: {today.luckyNumber}</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </motion.div>

        {/* 주요 메뉴 */}
        <motion.div variants={itemVariants} className="mb-8">
          <motion.h2 
            className={`${fontClasses.title} font-bold text-gray-900 dark:text-gray-100 mb-4`}
            initial={{ x: -20, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            transition={{ delay: 0.5 }}
          >
            운세 서비스
          </motion.h2>
          <motion.div 
            className="grid grid-cols-2 gap-4 mb-6"
            variants={containerVariants}
          >
            {[
              { href: "/fortune/saju", icon: Sun, title: "사주팔자", desc: "정통 사주 풀이", color: "orange" },
              { href: "/physiognomy", icon: Camera, title: "AI 관상", desc: "얼굴로 보는 운세", color: "purple" },
              { href: "/premium", icon: Sparkles, title: "프리미엄사주", desc: "만화로 보는 사주", color: "indigo" },
              { href: "/fortune", icon: Star, title: "전체 운세", desc: "모든 운세 보기", color: "purple" }
            ].map((item, index) => (
              <motion.div
                key={item.href}
                variants={itemVariants}
                whileHover="hover"
                whileTap={{ scale: 0.95 }}
              >
                <div onClick={() => handleFortuneClick(item.href, item.title)} className="cursor-pointer">
                  <motion.div variants={cardVariants}>
                    <Card className={`h-full hover:shadow-lg transition-all duration-300 border-${item.color}-200 hover:border-${item.color}-300 dark:bg-gray-800 dark:border-gray-700`}>
                      <CardContent className="p-6 text-center">
                        <motion.div 
                          className={`bg-${item.color}-100 dark:bg-${item.color}-900/30 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-3`}
                          whileHover={{ rotate: 360 }}
                          transition={{ duration: 0.5 }}
                        >
                          <item.icon className={`w-8 h-8 text-${item.color}-600 dark:text-${item.color}-400`} />
                        </motion.div>
                        <h3 className={`${fontClasses.text} font-semibold text-gray-900 dark:text-gray-100 mb-1`}>{item.title}</h3>
                        <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400`}>{item.desc}</p>
                      </CardContent>
                    </Card>
                  </motion.div>
                </div>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* 최근에 본 운세 */}
        {recentFortunes.length > 0 && (
          <motion.div variants={itemVariants} className="mb-8">
            <motion.div
              className="flex items-center gap-2 mb-4"
              initial={{ x: -20, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              transition={{ delay: 0.7 }}
            >
              <History className="w-5 h-5 text-gray-600 dark:text-gray-400" />
              <h2 className={`${fontClasses.title} font-bold text-gray-900 dark:text-gray-100`}>최근에 본 운세</h2>
            </motion.div>
            <motion.div className="space-y-3" variants={containerVariants}>
              {recentFortunes.map((fortune, index) => {
                const fortuneKey = getFortuneKey(fortune.path);
                const info = fortuneInfo[fortuneKey];
                
                if (!info) return null;

                return (
                  <motion.div
                    key={`${fortune.path}-${fortune.visitedAt}`}
                    variants={itemVariants}
                    whileHover={{ scale: 1.02, x: 5 }}
                    whileTap={{ scale: 0.98 }}
                  >
                    <div onClick={() => handleFortuneClick(fortune.path, fortune.title)} className="cursor-pointer">
                      <Card className={`hover:shadow-md transition-shadow bg-gradient-to-r ${info.gradient} dark:bg-gradient-to-r dark:from-${info.color}-900/20 dark:to-${info.color}-800/10 border-${info.color}-200 dark:border-${info.color}-700`}>
                        <CardContent className="p-4 flex items-center justify-between">
                          <div className="flex items-center gap-3">
                            <motion.div 
                              className={`bg-${info.color}-100 dark:bg-${info.color}-900/30 rounded-full w-12 h-12 flex items-center justify-center`}
                              whileHover={{ rotate: 360 }}
                              transition={{ duration: 0.5 }}
                            >
                              <info.icon className={`w-6 h-6 text-${info.color}-600 dark:text-${info.color}-400`} />
                            </motion.div>
                            <div>
                              <h3 className={`${fontClasses.text} font-semibold text-gray-900 dark:text-gray-100`}>{info.title}</h3>
                              <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400`}>{info.desc}</p>
                            </div>
                          </div>
                          <div className="flex items-center gap-2">
                            <Badge variant="secondary" className={`${fontClasses.label} bg-${info.color}-100 dark:bg-${info.color}-900/50 text-${info.color}-700 dark:text-${info.color}-300`}>
                              최근
                            </Badge>
                            <motion.div
                              animate={{ x: [0, 5, 0] }}
                              transition={{ repeat: Infinity, duration: 2 }}
                            >
                              <ArrowRight className={`w-5 h-5 text-${info.color}-600 dark:text-${info.color}-400`} />
                            </motion.div>
                          </div>
                        </CardContent>
                      </Card>
                    </div>
                  </motion.div>
                );
              })}
            </motion.div>
          </motion.div>
        )}

        {/* 나만의 맞춤 운세 */}
        <motion.div variants={itemVariants} className="mb-8">
          <motion.h2 
            className={`${fontClasses.title} font-bold text-gray-900 dark:text-gray-100 mb-4`}
            initial={{ x: -20, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            transition={{ delay: 0.9 }}
          >
            나만의 맞춤 운세
          </motion.h2>
          <motion.div className="grid grid-cols-1 gap-3" variants={containerVariants}>
            {[
              { href: "/fortune/mbti", icon: Zap, title: "MBTI 주간 운세", desc: "성격 유형별 조언", badge: "새로움", color: "violet" },
              { href: "/fortune/zodiac", icon: Star, title: "별자리 월간 운세", desc: "별이 알려주는 흐름", badge: "인기", color: "cyan" },
              { href: "/fortune/zodiac-animal", icon: Crown, title: "띠 운세", desc: "12간지로 보는 이달의 운세", badge: "전통", color: "orange" }
            ].map((item, index) => (
              <motion.div
                key={item.href}
                variants={itemVariants}
                whileHover={{ scale: 1.02, y: -2 }}
                whileTap={{ scale: 0.98 }}
              >
                <div onClick={() => handleFortuneClick(item.href, item.title)} className="cursor-pointer">
                  <Card className={`hover:shadow-md transition-shadow border-${item.color}-200 dark:border-${item.color}-700 dark:bg-gray-800`}>
                    <CardContent className="p-4 flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <motion.div 
                          className={`bg-${item.color}-100 dark:bg-${item.color}-900/30 rounded-full w-10 h-10 flex items-center justify-center`}
                          whileHover={{ rotate: 360 }}
                          transition={{ duration: 0.5 }}
                        >
                          <item.icon className={`w-5 h-5 text-${item.color}-600 dark:text-${item.color}-400`} />
                        </motion.div>
                        <div>
                          <h3 className={`${fontClasses.text} font-medium text-gray-900 dark:text-gray-100`}>{item.title}</h3>
                          <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400`}>{item.desc}</p>
                        </div>
                      </div>
                      <motion.div
                        whileHover={{ scale: 1.1 }}
                        whileTap={{ scale: 0.9 }}
                      >
                        <Badge variant="secondary" className={`${fontClasses.label} bg-${item.color}-100 dark:bg-${item.color}-900/50 text-${item.color}-700 dark:text-${item.color}-300`}>
                          {item.badge}
                        </Badge>
                      </motion.div>
                    </CardContent>
                  </Card>
                </div>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>
      </motion.div>
    </div>
  );
}
