"use client";

import { useEffect, useState, useCallback, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { auth } from "@/lib/supabase";
import { getUserProfile, isPremiumUser, saveUserProfile, getUserInfo } from "@/lib/user-storage";
import { checkFortuneProfileCompleteness } from "@/lib/profile-completeness";
import AdLoadingScreen from "@/components/AdLoadingScreen";
import AppHeader from "@/components/AppHeader";
import { FortuneErrorBoundary } from "@/components/FortuneErrorBoundary";
import { FortuneServiceError } from "@/lib/fortune-utils";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
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
  ArrowRight,
  Thermometer,
  Wind,
  Eye,
  Compass,
  RefreshCw,
  ChevronRight
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
  const [currentTime, setCurrentTime] = useState<Date | null>(null);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [showAdLoading, setShowAdLoading] = useState(false);
  const [pendingFortune, setPendingFortune] = useState<{ path: string; title: string } | null>(null);
  const [userProfile, setUserProfile] = useState<any>(null);
  const [todayFortuneError, setTodayFortuneError] = useState<Error | null>(null);
  const [todayFortune, setTodayFortune] = useState<any>(null);
  const loadingRef = useRef<boolean>(false);

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

  // 실시간 시간 업데이트 (클라이언트에서만)
  useEffect(() => {
    // 초기 시간 설정
    setCurrentTime(new Date());
    
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  // 사용자 프로필 상태 실시간 업데이트
  useEffect(() => {
    const updateUserProfile = () => {
      const profile = getUserProfile();
      if (profile) {
        setUserProfile(profile);
      }
    };

    // 초기 로드
    updateUserProfile();

    // storage 이벤트 리스너 (다른 탭에서 변경 시)
    window.addEventListener('storage', updateUserProfile);
    
    // 포커스 시 업데이트 (같은 탭에서 프로필 페이지에서 돌아올 때)
    window.addEventListener('focus', updateUserProfile);

    return () => {
      window.removeEventListener('storage', updateUserProfile);
      window.removeEventListener('focus', updateUserProfile);
    };
  }, []);

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
    const userProfile = getUserProfile();
    const isPremium = isPremiumUser(userProfile);
    
    addToRecentFortunes(path, title);
    
    // 프리미엄, 일반 사용자 모두 로딩 화면 표시 (분석하는 척)
    setPendingFortune({ path, title });
    setShowAdLoading(true);
  };

  // 광고 로딩 완료 후 운세 페이지로 이동
  const handleAdComplete = () => {
    if (pendingFortune) {
      // 먼저 페이지 이동을 시작하고
      router.push(pendingFortune.path);
      // 그 다음에 상태 정리 (이렇게 하면 중간에 홈 페이지가 보이지 않음)
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

  // 운세 경로에서 키 추출
  const getFortuneKey = (path: string) => {
    const pathParts = path.split('/');
    return pathParts[pathParts.length - 1] || 'unknown';
  };

  // 시간차이를 한국어로 표시하는 함수
  const formatTimeAgo = (timestamp: number) => {
    const now = Date.now();
    const diff = now - timestamp;
    const minutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(diff / (1000 * 60 * 60));
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days > 0) return `${days}일 전`;
    if (hours > 0) return `${hours}시간 전`;
    if (minutes > 0) return `${minutes}분 전`;
    return '방금 전';
  };

  useEffect(() => {
    const { data: { subscription } } = auth.onAuthStateChanged((currentUser: any) => {
      if (!currentUser) {
        router.push("/");
      } else {
        // 기존 사용자 프로필 확인
        const existingProfile = getUserProfile();
        
        // 사용자 프로필 생성 또는 업데이트 (기존 설정 유지)
        const userProfile = {
          id: currentUser.id,
          email: currentUser.email || 'user@example.com',
          name: currentUser.user_metadata?.full_name || currentUser.user_metadata?.name || '사용자',
          avatar_url: currentUser.user_metadata?.avatar_url || currentUser.user_metadata?.picture,
          provider: currentUser.app_metadata?.provider || 'google',
          created_at: currentUser.created_at,
          // 기존 프로필이 있으면 구독 상태 유지, 없으면 무료로 시작
          subscription_status: existingProfile?.subscription_status || 'free' as const,
          fortune_count: existingProfile?.fortune_count || 0,
          favorite_fortune_types: existingProfile?.favorite_fortune_types || []
        };
        
        // 로컬 스토리지에 저장
        saveUserProfile(userProfile);
        setName(userProfile.name);
        setUserProfile(userProfile);
      }
    });

    return () => subscription?.unsubscribe();
  }, [router]);

  // 시간대별 인사말과 아이콘
  const getTimeGreeting = () => {
    if (!currentTime) return { greeting: "오늘", icon: Sun, color: "orange" };
    
    const hour = currentTime.getHours();
    if (hour < 6) return { greeting: "새벽", icon: Moon, color: "indigo" };
    if (hour < 12) return { greeting: "아침", icon: Sunrise, color: "orange" };
    if (hour < 18) return { greeting: "오후", icon: Sun, color: "yellow" };
    return { greeting: "저녁", icon: Sunset, color: "purple" };
  };

  const timeInfo = getTimeGreeting();

  // 오늘의 운세 로드 (중복 요청 방지)
  const loadTodayFortune = useCallback(async () => {
    // 이미 로딩 중이면 중복 요청 방지
    if (loadingRef.current) {
      console.log('🔄 이미 로딩 중 - 중복 요청 방지');
      return;
    }
    
    try {
      loadingRef.current = true;
      setIsRefreshing(true);
      setTodayFortuneError(null);
      
      // 사용자 프로필 정보 확인
      const userInfo = getUserInfo();
      const { isComplete } = checkFortuneProfileCompleteness(userInfo, 'today');
      
      let response;
      
      if (!isComplete) {
        // 프로필 정보가 부족한 경우 - 기본 프로필로 체험 운세 제공
        console.log('📝 프로필 정보 부족 - 체험 운세 제공');
        response = await fetch('/api/fortune/today', {
          method: 'GET', // 기본 프로필 사용
          headers: {
            'Content-Type': 'application/json',
          },
        });
      } else {
        // 완전한 프로필 정보가 있는 경우 - 개인화된 운세 제공
        console.log('✅ 완전한 프로필 - 개인화된 운세 제공');
        response = await fetch('/api/fortune/today', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            userInfo: userInfo
          }),
        });
      }
      
      if (!response.ok) {
        throw new Error(`API 오류: ${response.status}`);
      }
      
      const result = await response.json();
      
      if (!result.success) {
        throw new Error(result.error || '운세 데이터를 가져오는데 실패했습니다.');
      }
      
      // 성공적으로 운세 데이터 로드
      const fortuneData = {
        ...result.data,
        isPersonalized: isComplete, // 개인화 여부 표시
        // 필수 필드 기본값 보장
        overall_score: result.data?.overall_score || result.data?.overall_luck || 75,
        love_score: result.data?.love_score || result.data?.love_luck || 70,
        career_score: result.data?.career_score || result.data?.work_luck || 70,
        money_score: result.data?.money_score || result.data?.money_luck || 70,
        health_score: result.data?.health_score || result.data?.health_luck || 70,
        summary: result.data?.summary || '오늘 하루의 운세가 준비되었습니다.',
        advice: result.data?.advice || '긍정적인 마음가짐으로 하루를 시작하세요.',
        lucky_items: result.data?.lucky_items || ['행운의 색깔', '작은 선물']
      };
      setTodayFortune(fortuneData);
      console.log('✅ 오늘의 운세 로드 성공:', result.cached ? '캐시됨' : '새로 생성됨', isComplete ? '(개인화됨)' : '(체험용)');
      console.log('📊 운세 데이터 구조:', fortuneData);
      
    } catch (error) {
      console.error('❌ 오늘의 운세 로드 실패:', error);
      setTodayFortuneError(error instanceof Error ? error : new Error('알 수 없는 오류가 발생했습니다.'));
    } finally {
      setIsRefreshing(false);
      loadingRef.current = false;
    }
  }, []);

  // 페이지 로드 시 오늘의 운세 시도 (중복 방지)
  useEffect(() => {
    loadTodayFortune();
  }, [loadTodayFortune]);

  // 오늘의 운세 새로고침
  const refreshFortune = useCallback(async () => {
    setTodayFortuneError(null);
    await loadTodayFortune();
  }, [loadTodayFortune]);

// 광고 로딩 화면 표시 중이면 AdLoadingScreen 렌더링
  if (showAdLoading && pendingFortune) {
    const userProfile = getUserProfile();
    const isPremium = isPremiumUser(userProfile);
    
    return (
      <AdLoadingScreen
        fortuneType={pendingFortune.path.split('/').pop() || 'fortune'}
        fortuneTitle={pendingFortune.title}
        onComplete={handleAdComplete}
        onSkip={handleUpgradeToPremium}
        isPremium={isPremium}
      />
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-indigo-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 pb-20">
      
      {/* 디버깅용 프리미엄 상태 표시 */}
      {userProfile && (
        <div className="fixed top-20 right-4 z-50">
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            className={`px-3 py-1 rounded-full text-xs font-medium shadow-lg ${
              isPremiumUser(userProfile) 
                ? 'bg-gradient-to-r from-purple-500 to-indigo-500 text-white' 
                : 'bg-gray-100 dark:bg-gray-800 text-gray-700 dark:text-gray-300'
            }`}
          >
            {isPremiumUser(userProfile) ? '프리미엄' : '무료'}
          </motion.div>
        </div>
      )}
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-4"
      >
        {/* 오늘의 운세 카드 */}
        <motion.div variants={itemVariants} className="mb-8">
          {todayFortuneError ? (
            <motion.div
              variants={cardVariants}
              whileHover="hover"
              whileTap={{ scale: 0.98 }}
            >
              <Card className="bg-gradient-to-br from-gray-100 via-gray-50 to-gray-100 dark:from-gray-800 dark:via-gray-700 dark:to-gray-800 shadow-2xl overflow-hidden relative border-dashed border-2 border-gray-300 dark:border-gray-600">
                {/* 배경 패턴 */}
                <div className="absolute inset-0 opacity-5">
                  <div className="absolute top-4 right-4 w-32 h-32 rounded-full border border-gray-400"></div>
                  <div className="absolute bottom-4 left-4 w-24 h-24 rounded-full border border-gray-400"></div>
                  <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-40 h-40 rounded-full border border-gray-300"></div>
                </div>

                <CardHeader className="pb-4 relative z-10">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                        className="bg-gray-200 dark:bg-gray-600 rounded-full p-2"
                      >
                        <timeInfo.icon className="w-6 h-6 text-gray-500 dark:text-gray-400" />
                      </motion.div>
                      <div>
                        <CardTitle className={`${fontClasses.title} font-bold text-gray-700 dark:text-gray-300`}>
                          {timeInfo.greeting} 운세
                        </CardTitle>
                        <p className={`${fontClasses.label} text-gray-500 dark:text-gray-400`}>
                          {currentTime ? (
                            <>
                              {currentTime.toLocaleDateString('ko-KR', { 
                                month: 'long', 
                                day: 'numeric',
                                weekday: 'short'
                              })} • {currentTime.toLocaleTimeString('ko-KR', { 
                                hour: '2-digit', 
                                minute: '2-digit'
                              })}
                            </>
                          ) : (
                            '로딩 중...'
                          )}
                        </p>
                      </div>
                    </div>
                    <motion.button
                      onClick={refreshFortune}
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                      className="bg-gray-200 dark:bg-gray-600 rounded-full p-2 hover:bg-gray-300 dark:hover:bg-gray-500 transition-colors"
                      disabled={isRefreshing}
                    >
                      <motion.div
                        animate={isRefreshing ? { rotate: 360 } : {}}
                        transition={{ duration: 1, repeat: isRefreshing ? Infinity : 0 }}
                      >
                        <RefreshCw className="w-5 h-5 text-gray-600 dark:text-gray-400" />
                      </motion.div>
                    </motion.button>
                  </div>
                </CardHeader>

                <CardContent className="space-y-6 relative z-10">
                  <FortuneErrorBoundary 
                    error={todayFortuneError} 
                    reset={() => {
                      setTodayFortuneError(null);
                      loadTodayFortune();
                    }}
                    fallbackMessage={todayFortuneError.message}
                  />
                </CardContent>
              </Card>
            </motion.div>
          ) : todayFortune && typeof todayFortune.overall_score === 'number' ? (
            // 성공적으로 운세 데이터를 불러온 경우
            <motion.div
              variants={cardVariants}
              whileHover="hover"
              whileTap={{ scale: 0.98 }}
            >
              <Card className="bg-gradient-to-br from-purple-600 via-indigo-600 to-blue-700 text-white shadow-2xl overflow-hidden relative">
                {/* 배경 장식 */}
                <div className="absolute inset-0 opacity-10">
                  <div className="absolute top-4 right-4 w-32 h-32 rounded-full border border-white"></div>
                  <div className="absolute bottom-4 left-4 w-24 h-24 rounded-full border border-white"></div>
                  <div className="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-40 h-40 rounded-full border border-white/50"></div>
                </div>

                <CardHeader className="pb-4 relative z-10">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
                        className="bg-white/20 rounded-full p-2"
                      >
                        <timeInfo.icon className="w-6 h-6 text-white" />
                      </motion.div>
                      <div>
                        <CardTitle className={`${fontClasses.title} font-bold text-white`}>
                          {timeInfo.greeting} 운세
                        </CardTitle>
                        <p className={`${fontClasses.label} text-white/80`}>
                          {currentTime ? (
                            <>
                              {currentTime.toLocaleDateString('ko-KR', { 
                                month: 'long', 
                                day: 'numeric',
                                weekday: 'short'
                              })} • {currentTime.toLocaleTimeString('ko-KR', { 
                                hour: '2-digit', 
                                minute: '2-digit'
                              })}
                            </>
                          ) : (
                            '로딩 중...'
                          )}
                        </p>
                      </div>
                    </div>
                    <motion.button
                      onClick={refreshFortune}
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                      className="bg-white/20 rounded-full p-2 hover:bg-white/30 transition-colors"
                      disabled={isRefreshing}
                    >
                      <motion.div
                        animate={isRefreshing ? { rotate: 360 } : {}}
                        transition={{ duration: 1, repeat: isRefreshing ? Infinity : 0 }}
                      >
                        <RefreshCw className="w-5 h-5 text-white" />
                      </motion.div>
                    </motion.button>
                  </div>
                </CardHeader>

                <CardContent className="space-y-6 relative z-10">
                  {/* 개인화 안내 */}
                  {!todayFortune.isPersonalized && (
                    <div className="bg-white/10 border border-white/20 rounded-lg p-3">
                      <p className={`${fontClasses.label} text-white/90 text-center`}>
                        🌟 체험용 운세입니다. <Link href="/profile/edit" className="underline font-medium">프로필을 완성</Link>하면 더 정확한 개인화된 운세를 받을 수 있어요!
                      </p>
                    </div>
                  )}
                  
                  {/* 전체 운세 점수 */}
                  <div className="text-center">
                    <div className="text-4xl font-bold mb-2 text-white">
                      {todayFortune.overall_score}점
                    </div>
                    <p className={`${fontClasses.text} text-white/90`}>
                      {todayFortune.summary || '오늘 하루의 전체적인 운세입니다.'}
                    </p>
                  </div>

                  {/* 세부 운세 */}
                  <div className="grid grid-cols-2 gap-3">
                    {[
                      { key: 'love', label: '연애운', icon: Heart, score: todayFortune.love_score || 70 },
                      { key: 'career', label: '직업운', icon: Briefcase, score: todayFortune.career_score || 70 },
                      { key: 'money', label: '금전운', icon: Coins, score: todayFortune.money_score || 70 },
                      { key: 'health', label: '건강운', icon: Shield, score: todayFortune.health_score || 70 }
                    ].map((item) => (
                      <div key={item.key} className="bg-white/10 rounded-lg p-3">
                        <div className="flex items-center gap-2 mb-2">
                          <item.icon className="w-4 h-4 text-white/80" />
                          <span className={`${fontClasses.label} font-medium text-white/90`}>
                            {item.label}
                          </span>
                        </div>
                        <div className="text-lg font-bold text-white">
                          {item.score}점
                        </div>
                      </div>
                    ))}
                  </div>

                  {/* 오늘의 조언 */}
                  {todayFortune.advice && (
                    <div className="bg-white/10 rounded-lg p-4">
                      <h4 className={`${fontClasses.text} font-semibold text-white mb-2`}>
                        오늘의 조언
                      </h4>
                      <p className={`${fontClasses.label} text-white/90`}>
                        {todayFortune.advice}
                      </p>
                    </div>
                  )}

                  {/* 행운 아이템 */}
                  {todayFortune.lucky_items && Array.isArray(todayFortune.lucky_items) && todayFortune.lucky_items.length > 0 && (
                    <div className="flex items-center gap-2">
                      <Sparkles className="w-4 h-4 text-yellow-300" />
                      <span className={`${fontClasses.label} text-white/90`}>
                        행운 아이템: {todayFortune.lucky_items.join(', ')}
                      </span>
                    </div>
                  )}
                </CardContent>
              </Card>
            </motion.div>
          ) : isRefreshing ? (
            // 로딩 중일 때
            <motion.div
              variants={cardVariants}
              whileHover="hover"
              whileTap={{ scale: 0.98 }}
            >
              <Card className="bg-gradient-to-br from-purple-600 via-indigo-600 to-blue-700 text-white shadow-2xl overflow-hidden relative">
                <CardContent className="p-6">
                  <div className="text-center py-8">
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ duration: 2, repeat: Infinity }}
                      className="inline-block mb-4"
                    >
                      <Sparkles className="w-8 h-8 text-white" />
                    </motion.div>
                    <p className={`${fontClasses.text} text-white/90`}>
                      개인화된 운세를 생성하고 있습니다...
                    </p>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          ) : (
            // 초기 로딩 상태
            <motion.div
              variants={cardVariants}
              whileHover="hover"
              whileTap={{ scale: 0.98 }}
            >
              <Card className="bg-gradient-to-br from-purple-600 via-indigo-600 to-blue-700 text-white shadow-2xl overflow-hidden relative">
                <CardContent className="p-6">
                  <div className="text-center py-8">
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ duration: 2, repeat: Infinity }}
                      className="inline-block mb-4"
                    >
                      <Sparkles className="w-8 h-8 text-white" />
                    </motion.div>
                    <p className={`${fontClasses.text} text-white/90`}>
                      운세 데이터를 불러오는 중...
                    </p>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          )}
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
          { href: "/fortune/saju", icon: Sun, title: "사주팔자", desc: "정통 사주 풀이", color: "orange", needsAd: true },
          { href: "/physiognomy", icon: Camera, title: "AI 관상", desc: "얼굴로 보는 운세", color: "purple", needsAd: true },
          { href: "/premium", icon: Sparkles, title: "프리미엄사주", desc: "만화로 보는 사주", color: "indigo", needsAd: true },
          { href: "/fortune", icon: Star, title: "전체 운세", desc: "모든 운세 보기", color: "purple", needsAd: false }
        ].map((item, index) => (
          <motion.div
            key={item.href}
            variants={itemVariants}
            whileHover="hover"
            whileTap={{ scale: 0.95 }}
          >
            <div onClick={() => item.needsAd ? handleFortuneClick(item.href, item.title) : router.push(item.href)} className="cursor-pointer">
              <Card className="h-full hover:shadow-lg transition-all duration-300 border-gray-200 hover:border-purple-300 dark:bg-gray-800 dark:border-gray-600 dark:hover:border-purple-500">
                <CardContent className="p-6 flex flex-col items-center text-center h-full">
                  <div className="bg-purple-100 dark:bg-purple-900/30 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-3">
                    <item.icon className="w-8 h-8 text-purple-600 dark:text-purple-400" />
                  </div>
                  <h3 className={`${fontClasses.text} font-semibold text-gray-900 dark:text-gray-100 mb-1`}>{item.title}</h3>
                  <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400`}>{item.desc}</p>
                  {item.needsAd && (
                    <Badge variant="secondary" className={`${fontClasses.label} mt-2 bg-orange-100 dark:bg-orange-900/50 text-orange-700 dark:text-orange-300`}>
                      광고 후 이용
                    </Badge>
                  )}
                </CardContent>
              </Card>
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
              {recentFortunes.slice(0, 3).map((recent, index) => {
                const fortuneKey = getFortuneKey(recent.path);
                const info = fortuneInfo[fortuneKey] || { 
                  icon: Star, 
                  title: recent.title, 
                  desc: "운세 정보", 
                  color: "purple",
                  gradient: "from-purple-50 to-indigo-50"
                };
                
                return (
                  <motion.div key={recent.path} variants={itemVariants}>
                    <Card className="hover:shadow-md transition-shadow bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600 hover:border-purple-300 dark:hover:border-purple-500">
                      <CardContent className="p-4">
                        <div className="flex items-center gap-3">
                          <div className="bg-purple-100 dark:bg-purple-900/30 rounded-full w-12 h-12 flex items-center justify-center">
                            <info.icon className="w-6 h-6 text-purple-600 dark:text-purple-400" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <h3 className={`${fontClasses.text} font-semibold text-gray-900 dark:text-gray-100`}>{info.title}</h3>
                            <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400`}>{info.desc}</p>
                          </div>
                          <div className="flex items-center gap-2">
                            <Badge variant="secondary" className="bg-purple-100 dark:bg-purple-900/50 text-purple-700 dark:text-purple-300">
                              {formatTimeAgo(recent.visitedAt)}
                            </Badge>
                            <Button
                              variant="ghost"
                              size="sm"
                              className="p-2 h-auto"
                              onClick={() => handleFortuneClick(recent.path, recent.title)}
                            >
                              <ArrowRight className="w-5 h-5 text-purple-600 dark:text-purple-400" />
                            </Button>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
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
                <Card 
                  className="hover:shadow-lg transition-all duration-300 cursor-pointer bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600 hover:border-purple-300 dark:hover:border-purple-500"
                  onClick={() => handleFortuneClick(item.href, item.title)}
                >
                  <CardContent className="p-6">
                    <div className="flex items-center gap-4">
                      <div className="bg-purple-100 dark:bg-purple-900/30 rounded-full w-10 h-10 flex items-center justify-center">
                        <item.icon className="w-5 h-5 text-purple-600 dark:text-purple-400" />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-1">
                          <h3 className={`${fontClasses.text} font-medium text-gray-900 dark:text-gray-100`}>{item.title}</h3>
                          <Badge variant="secondary" className="bg-purple-100 dark:bg-purple-900/50 text-purple-700 dark:text-purple-300">
                            {item.badge}
                          </Badge>
                        </div>
                        <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400`}>{item.desc}</p>
                      </div>
                      <ArrowRight className="w-4 h-4 text-gray-400 dark:text-gray-500" />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>
            ))}
          </motion.div>
        </motion.div>
      </motion.div>
    </div>
  );
}
