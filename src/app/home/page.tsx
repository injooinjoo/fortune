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
  Zap
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
        className="px-6"
      >
        {/* 헤더 */}
        <motion.header variants={itemVariants} className="py-8 text-center">
          <div className="mb-2">
            <motion.h1 
              className="text-3xl font-bold text-gray-900 mb-2"
              initial={{ scale: 0.9, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.3, type: "spring" }}
            >
              안녕하세요, <span className="text-purple-600">{name}</span>님!
            </motion.h1>
            <motion.p 
              className="text-gray-600"
              initial={{ y: 10, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.4 }}
            >
              오늘도 좋은 하루 되세요 ✨
            </motion.p>
          </div>
        </motion.header>

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
              { href: "/tarot", icon: Sparkles, title: "타로 리딩", desc: "카드가 주는 메시지", color: "indigo" },
              { href: "/dream", icon: Moon, title: "꿈해몽", desc: "꿈이 전하는 의미", color: "emerald" }
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
              { href: "/fortune/career", icon: Briefcase, title: "취업운", desc: "커리어와 성공의 길", color: "blue", gradient: "from-blue-50 to-indigo-50" },
              { href: "/fortune/wealth", icon: Coins, title: "금전운", desc: "재물과 투자의 운", color: "yellow", gradient: "from-yellow-50 to-orange-50" }
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
              { href: "/fortune/zodiac", icon: Star, title: "별자리 월간 운세", desc: "별이 알려주는 흐름", badge: "인기", color: "cyan" }
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
