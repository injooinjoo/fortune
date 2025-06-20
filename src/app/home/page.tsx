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
  Building
} from "lucide-react";

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
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-indigo-50 pb-20">
      <AppHeader title="Fortune" />
      
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
                  <CardTitle className="text-xl font-bold">오늘의 운세</CardTitle>
                  <motion.div 
                    className="bg-white/20 rounded-full px-3 py-1"
                    animate={{ scale: [1, 1.05, 1] }}
                    transition={{ repeat: Infinity, duration: 3 }}
                  >
                    <span className="text-sm font-semibold">{today.score}점</span>
                  </motion.div>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">
                <p className="text-white/90 leading-relaxed">{today.summary}</p>
                
                <div className="flex flex-wrap gap-2">
                  {today.keywords.map((keyword, index) => (
                    <motion.div
                      key={keyword}
                      initial={{ scale: 0, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      transition={{ delay: 0.6 + index * 0.1 }}
                    >
                      <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
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
                    <span className="text-sm">행운의 색상</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <motion.div
                      animate={{ rotate: [0, 10, -10, 0] }}
                      transition={{ repeat: Infinity, duration: 2 }}
                    >
                      <Star className="w-4 h-4" />
                    </motion.div>
                    <span className="text-sm">행운의 숫자: {today.luckyNumber}</span>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        </motion.div>

        {/* 주요 메뉴 */}
        <motion.div variants={itemVariants} className="mb-8">
          <motion.h2 
            className="text-xl font-bold text-gray-900 mb-4"
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
              { href: "/interactive/tarot", icon: Sparkles, title: "타로 리딩", desc: "카드가 주는 메시지", color: "indigo" },
              { href: "/fortune/wish", icon: Star, title: "소원빌기", desc: "진심을 담은 소원", color: "purple" }
            ].map((item, index) => (
              <motion.div
                key={item.href}
                variants={itemVariants}
                whileHover="hover"
                whileTap={{ scale: 0.95 }}
              >
                <Link href={item.href}>
                  <motion.div variants={cardVariants}>
                    <Card className={`h-full hover:shadow-lg transition-all duration-300 border-${item.color}-200 hover:border-${item.color}-300`}>
                      <CardContent className="p-6 text-center">
                        <motion.div 
                          className={`bg-${item.color}-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-3`}
                          whileHover={{ rotate: 360 }}
                          transition={{ duration: 0.5 }}
                        >
                          <item.icon className={`w-8 h-8 text-${item.color}-600`} />
                        </motion.div>
                        <h3 className="font-semibold text-gray-900 mb-1">{item.title}</h3>
                        <p className="text-sm text-gray-600">{item.desc}</p>
                      </CardContent>
                    </Card>
                  </motion.div>
                </Link>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* 분야별 운세 */}
        <motion.div variants={itemVariants} className="mb-8">
          <motion.h2 
            className="text-xl font-bold text-gray-900 mb-4"
            initial={{ x: -20, opacity: 0 }}
            animate={{ x: 0, opacity: 1 }}
            transition={{ delay: 0.7 }}
          >
            분야별 운세
          </motion.h2>
          <motion.div className="space-y-3" variants={containerVariants}>
            {[
              { href: "/fortune/love", icon: Heart, title: "연애운", desc: "사랑과 인연의 흐름", color: "pink", gradient: "from-pink-50 to-red-50" },
              { href: "/fortune/marriage", icon: Heart, title: "결혼운", desc: "평생의 동반자 운세", color: "rose", gradient: "from-rose-50 to-pink-50" },
              { href: "/fortune/career", icon: Briefcase, title: "취업운", desc: "커리어와 성공의 길", color: "blue", gradient: "from-blue-50 to-indigo-50" },
              { href: "/fortune/wealth", icon: Coins, title: "금전운", desc: "재물과 투자의 운", color: "yellow", gradient: "from-yellow-50 to-orange-50" },
              { href: "/fortune/moving", icon: Home, title: "이사운", desc: "새로운 보금자리의 운", color: "emerald", gradient: "from-emerald-50 to-green-50" },
              { href: "/fortune/business", icon: TrendingUp, title: "사업운", desc: "창업과 사업 성공의 운", color: "indigo", gradient: "from-indigo-50 to-purple-50" },
              { href: "/fortune/palmistry", icon: Hand, title: "손금", desc: "손에 새겨진 운명의 선", color: "amber", gradient: "from-amber-50 to-yellow-50" },
              { href: "/fortune/saju-psychology", icon: Brain, title: "사주 심리분석", desc: "성격과 관계 심층 탐구", color: "teal", gradient: "from-teal-50 to-cyan-50" },
              { href: "/fortune/compatibility", icon: Users, title: "궁합", desc: "둘의 운명적 만남", color: "rose", gradient: "from-rose-50 to-pink-50" },
              { href: "/fortune/ex-lover", icon: HeartCrack, title: "헤어진 애인", desc: "지난 사랑과의 인연", color: "slate", gradient: "from-slate-50 to-gray-50" },
              { href: "/fortune/blind-date", icon: Coffee, title: "소개팅", desc: "새로운 만남의 가능성", color: "orange", gradient: "from-orange-50 to-amber-50" },
              { href: "/fortune/hourly", icon: Clock, title: "시간대별 운세", desc: "매 시간의 운기 변화", color: "indigo", gradient: "from-indigo-50 to-purple-50" },
              { href: "/fortune/chemistry", icon: Flame, title: "속궁합", desc: "은밀하고 깊은 관계의 궁합", color: "red", gradient: "from-red-50 to-pink-50" },
              { href: "/fortune/lucky-items", icon: Gift, title: "행운의 아이템", desc: "당신만의 행운을 부르는 물건", color: "emerald", gradient: "from-emerald-50 to-green-50" },
              { href: "/fortune/biorhythm", icon: Activity, title: "바이오리듬", desc: "건강, 감성, 지성의 주기 분석", color: "cyan", gradient: "from-cyan-50 to-blue-50" },
              { href: "/fortune/lucky-baseball", icon: Target, title: "행운의 야구", desc: "야구를 통해 보는 당신의 운세", color: "amber", gradient: "from-amber-50 to-yellow-50" },
              { href: "/fortune/lucky-tennis", icon: Zap, title: "행운의 테니스", desc: "테니스를 통해 보는 당신의 운세와 승리 비결", color: "emerald", gradient: "from-emerald-50 to-green-50" },
              { href: "/fortune/lucky-hiking", icon: Mountain, title: "행운의 등산", desc: "등산을 통해 보는 당신의 운세와 안전한 완주 비결", color: "green", gradient: "from-green-50 to-emerald-50" },
              { href: "/fortune/lucky-fishing", icon: Fish, title: "행운의 낚시", desc: "낚시를 통해 보는 당신의 운세와 대박 조황의 비결", color: "cyan", gradient: "from-cyan-50 to-blue-50" },
              { href: "/fortune/lucky-investment", icon: DollarSign, title: "행운의 재테크", desc: "투자와 자산 운용의 황금 비결", color: "yellow", gradient: "from-yellow-50 to-orange-50" },
              { href: "/fortune/lucky-golf", icon: CircleDot, title: "행운의 골프", desc: "완벽한 라운딩을 위한 골프 운세", color: "lime", gradient: "from-lime-50 to-green-50" },

              { href: "/fortune/lucky-cycling", icon: Bike, title: "행운의 자전거", desc: "오늘의 라이딩 코스 운세", color: "teal", gradient: "from-teal-50 to-cyan-50" },
              { href: "/fortune/lucky-color", icon: Palette, title: "행운의 색깔", desc: "마음을 위로하는 당신만의 색깔", color: "purple", gradient: "from-purple-50 to-blue-50" },
              { href: "/fortune/lucky-swim", icon: Waves, title: "행운의 수영", desc: "물의 기운으로 즐기는 건강 수영", color: "sky", gradient: "from-sky-50 to-blue-50" },
              { href: "/fortune/lucky-running", icon: Footprints, title: "행운의 마라톤", desc: "달리기 운세와 최적의 컨디션", color: "cyan", gradient: "from-cyan-50 to-blue-50" },

              { href: "/fortune/lucky-realestate", icon: Building2, title: "행운의 부동산", desc: "성공적인 부동산 투자의 비밀", color: "violet", gradient: "from-violet-50 to-purple-50" },
              { href: "/fortune/lucky-number", icon: Dice5, title: "행운의 번호", desc: "로또처럼 뽑는 6개 번호", color: "sky", gradient: "from-sky-50 to-blue-50" },
              { href: "/fortune/lucky-food", icon: UtensilsCrossed, title: "행운의 음식", desc: "맛있는 행운을 불러오는 음식 운세", color: "rose", gradient: "from-rose-50 to-pink-50" },
              { href: "/fortune/lucky-exam", icon: GraduationCap, title: "행운의 시험일자", desc: "합격을 부르는 최적의 시험 날짜", color: "emerald", gradient: "from-emerald-50 to-green-50" },

              { href: "/fortune/lucky-outfit", icon: Shirt, title: "행운의 코디", desc: "운을 부르는 패션 스타일", color: "fuchsia", gradient: "from-fuchsia-50 to-pink-50" },

              { href: "/fortune/lucky-job", icon: Briefcase, title: "행운의 직업", desc: "사주로 보는 성공 직업 추천", color: "teal", gradient: "from-teal-50 to-emerald-50" },

              // 누락된 페이지들 추가
              { href: "/fortune/avoid-people", icon: UserX, title: "피해야 할 사람", desc: "주의해야 할 인연과 관계 운세", color: "gray", gradient: "from-gray-50 to-slate-50" },
              { href: "/fortune/birthdate", icon: CakeSlice, title: "생년월일 운세", desc: "태어난 날로 보는 운명 분석", color: "pink", gradient: "from-pink-50 to-rose-50" },
              { href: "/fortune/birthstone", icon: Gem, title: "탄생석 운세", desc: "당신만의 탄생석이 주는 힘", color: "purple", gradient: "from-purple-50 to-violet-50" },
              { href: "/fortune/birth-season", icon: CloudSnow, title: "태어난 계절", desc: "계절이 결정하는 성격과 운명", color: "blue", gradient: "from-blue-50 to-cyan-50" },
              { href: "/fortune/blood-type", icon: Droplets, title: "혈액형 운세", desc: "혈액형별 성격과 운세 분석", color: "red", gradient: "from-red-50 to-pink-50" },
              { href: "/fortune/celebrity-match", icon: Star, title: "연예인 궁합", desc: "최애 연예인과의 궁합도", color: "yellow", gradient: "from-yellow-50 to-amber-50" },
              { href: "/fortune/couple-match", icon: Users2, title: "커플 매칭", desc: "완벽한 커플이 되는 비결", color: "rose", gradient: "from-rose-50 to-pink-50" },
              { href: "/fortune/daily", icon: Sun, title: "일일 운세", desc: "매일 달라지는 운의 흐름", color: "orange", gradient: "from-orange-50 to-yellow-50" },
              { href: "/fortune/destiny", icon: ScrollIcon, title: "운명 분석", desc: "타고난 운명의 길을 찾아보세요", color: "indigo", gradient: "from-indigo-50 to-purple-50" },
              { href: "/fortune/employment", icon: Building, title: "취업 운세", desc: "취업과 경력 발전의 운", color: "blue", gradient: "from-blue-50 to-indigo-50" },
              { href: "/fortune/five-blessings", icon: Gift, title: "오복 운세", desc: "다섯 가지 복을 받을 운세", color: "emerald", gradient: "from-emerald-50 to-green-50" },
              { href: "/fortune/lucky-sidejob", icon: Coins, title: "행운의 부업", desc: "성공적인 부업 아이템 추천", color: "yellow", gradient: "from-yellow-50 to-orange-50" },
              { href: "/fortune/moving-date", icon: MapPin, title: "이사 날짜", desc: "최적의 이사 타이밍 찾기", color: "green", gradient: "from-green-50 to-emerald-50" },
              { href: "/fortune/network-report", icon: Users, title: "인맥 리포트", desc: "당신 주변 인맥의 힘", color: "blue", gradient: "from-blue-50 to-cyan-50" },
              { href: "/fortune/new-year", icon: Sparkles, title: "신년 운세", desc: "새해 한 해 전체 운세", color: "gold", gradient: "from-amber-50 to-yellow-50" },
              { href: "/fortune/past-life", icon: Scroll, title: "전생 분석", desc: "과거생에서 온 인연과 업", color: "purple", gradient: "from-purple-50 to-indigo-50" },
              { href: "/fortune/salpuli", icon: Shield, title: "살풀이", desc: "액운을 막고 복을 부르는 방법", color: "red", gradient: "from-red-50 to-orange-50" },
              { href: "/fortune/startup", icon: Rocket, title: "창업 운세", desc: "사업 시작의 최적 타이밍", color: "blue", gradient: "from-blue-50 to-indigo-50" },
              { href: "/fortune/talent", icon: Lightbulb, title: "재능 분석", desc: "숨겨진 재능과 능력 발견", color: "yellow", gradient: "from-yellow-50 to-amber-50" },
              { href: "/fortune/talisman", icon: Star, title: "부적", desc: "당신에게 맞는 행운의 부적", color: "purple", gradient: "from-purple-50 to-violet-50" },
              { href: "/fortune/timeline", icon: LineChart, title: "타임라인 운세", desc: "인생 전체의 운세 흐름", color: "indigo", gradient: "from-indigo-50 to-purple-50" },
              { href: "/fortune/today", icon: Sunrise, title: "오늘의 운세", desc: "지금 이 순간의 운세", color: "orange", gradient: "from-orange-50 to-red-50" },
              { href: "/fortune/tojeong", icon: ScrollText, title: "토정 운세", desc: "전통 토정비결로 보는 운세", color: "amber", gradient: "from-amber-50 to-yellow-50" },
              { href: "/fortune/tomorrow", icon: Sunset, title: "내일의 운세", desc: "다가올 내일의 운기", color: "purple", gradient: "from-purple-50 to-pink-50" },
              { href: "/fortune/traditional-compatibility", icon: Heart, title: "전통 궁합", desc: "전통 명리학 궁합 분석", color: "rose", gradient: "from-rose-50 to-red-50" },
              { href: "/fortune/traditional-saju", icon: ScrollText, title: "전통 사주", desc: "정통 사주명리학 풀이", color: "amber", gradient: "from-amber-50 to-orange-50" }

            ].map((item, index) => (
              <motion.div
                key={item.href}
                variants={itemVariants}
                whileHover={{ scale: 1.02, x: 5 }}
                whileTap={{ scale: 0.98 }}
              >
                <Link href={item.href}>
                  <Card className={`hover:shadow-md transition-shadow bg-gradient-to-r ${item.gradient} border-${item.color}-200`}>
                    <CardContent className="p-4 flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <motion.div 
                          className={`bg-${item.color}-100 rounded-full w-12 h-12 flex items-center justify-center`}
                          whileHover={{ rotate: 360 }}
                          transition={{ duration: 0.5 }}
                        >
                          <item.icon className={`w-6 h-6 text-${item.color}-600`} />
                        </motion.div>
                        <div>
                          <h3 className="font-semibold text-gray-900">{item.title}</h3>
                          <p className="text-sm text-gray-600">{item.desc}</p>
                        </div>
                      </div>
                      <motion.div
                        animate={{ x: [0, 5, 0] }}
                        transition={{ repeat: Infinity, duration: 2 }}
                      >
                        <TrendingUp className={`w-5 h-5 text-${item.color}-600`} />
                      </motion.div>
                    </CardContent>
                  </Card>
                </Link>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>

        {/* 맞춤 운세 */}
        <motion.div variants={itemVariants} className="mb-8">
          <motion.h2 
            className="text-xl font-bold text-gray-900 mb-4"
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
                <Link href={item.href}>
                  <Card className={`hover:shadow-md transition-shadow border-${item.color}-200`}>
                    <CardContent className="p-4 flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <motion.div 
                          className={`bg-${item.color}-100 rounded-full w-10 h-10 flex items-center justify-center`}
                          whileHover={{ rotate: 360 }}
                          transition={{ duration: 0.5 }}
                        >
                          <item.icon className={`w-5 h-5 text-${item.color}-600`} />
                        </motion.div>
                        <div>
                          <h3 className="font-medium text-gray-900">{item.title}</h3>
                          <p className="text-sm text-gray-600">{item.desc}</p>
                        </div>
                      </div>
                      <motion.div
                        whileHover={{ scale: 1.1 }}
                        whileTap={{ scale: 0.9 }}
                      >
                        <Badge variant="secondary" className={`bg-${item.color}-100 text-${item.color}-700`}>
                          {item.badge}
                        </Badge>
                      </motion.div>
                    </CardContent>
                  </Card>
                </Link>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>
      </motion.div>
    </div>
  );
}
