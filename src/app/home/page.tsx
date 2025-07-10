"use client";

import { logger } from '@/lib/logger';
import { useEffect, useState, useCallback } from "react";
import { motion, AnimatePresence } from "framer-motion";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { getUserProfile, isPremiumUser, saveUserProfile, UserProfile, syncUserProfile } from "@/lib/user-storage";
import { logLocalStorageStatus, cleanupLocalStorage } from "@/lib/db-health-check";
import AdLoadingScreen from "@/components/AdLoadingScreen";
import AppHeader from "@/components/AppHeader";
import ProtectedRoute from "@/components/ProtectedRoute";
import { useBatchFortune } from "@/hooks/use-batch-fortune";
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

function HomePage() {
  const router = useRouter();
  const [name, setName] = useState<string>("사용자");
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [recentFortunes, setRecentFortunes] = useState<RecentFortune[]>([]);
  const [currentTime, setCurrentTime] = useState<Date | null>(null);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const [showAdLoading, setShowAdLoading] = useState(false);
  const [pendingFortune, setPendingFortune] = useState<{ path: string; title: string } | null>(null);
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [lastUpdateDate, setLastUpdateDate] = useState<string | null>(null);

  // 배치 운세 훅 사용 - 조건부로 사용
  const { 
    fortuneData: batchFortuneData, 
    loading: batchLoading, 
    error: batchError,
    generateBatchFortune,
    getFortuneByType,
    refreshFortune: refreshBatchFortune
  } = useBatchFortune({
    fortuneTypes: ['daily', 'today', 'hourly'],
    cacheEnabled: true
  });

  // 자동 업데이트 체크 함수
  const checkForAutoUpdate = useCallback(async () => {
    const today = new Date().toISOString().split('T')[0];
    const stored = localStorage.getItem('fortune_last_update_date');
    
    if (stored !== today) {
      logger.debug('🔄 자동 업데이트 시작 - 새로운 날:', today);
      setLastUpdateDate(today);
      localStorage.setItem('fortune_last_update_date', today);
      
      // 자동으로 배치 운세 생성
      try {
        // 프로필이 있을 때만 배치 운세 생성 시도
        const profile = getUserProfile();
        if (profile && profile.onboarding_completed) {
          await generateBatchFortune();
        }
      } catch (error) {
        logger.error('자동 업데이트 실패:', error);
      }
    } else {
      setLastUpdateDate(stored);
    }
  }, [generateBatchFortune]);

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

  // 사용자 프로필 상태 로컬 스토리지에서 로드
  useEffect(() => {
    const updateUserProfile = () => {
      const localProfile = getUserProfile();
      setUserProfile(localProfile);
    };

    const handleStorageChange = () => {
      const localProfile = getUserProfile();
      setUserProfile(localProfile);
    };
    
    updateUserProfile();

    window.addEventListener('storage', handleStorageChange);
    window.addEventListener('focus', updateUserProfile);

    return () => {
      window.removeEventListener('storage', handleStorageChange);
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
        logger.error('최근 본 운세 로드 실패:', error);
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
      logger.error('최근 본 운세 저장 실패:', error);
    }
  };

// 각 운세 타입별 API 호출 함수들
  const fortuneApiCalls: Record<string, () => Promise<any>> = {
    // 사주 관련
    '/fortune/saju': async () => {
      const response = await fetch('/api/fortune/traditional-saju');
      if (!response.ok) throw new Error('사주 운세 로드 실패');
      return response.json();
    },
    '/fortune/saju-psychology': async () => {
      const response = await fetch('/api/fortune/saju-psychology');
      if (!response.ok) throw new Error('사주 심리분석 로드 실패');
      return response.json();
    },
    
    // 별자리 및 띠
    '/fortune/zodiac': async () => {
      const response = await fetch('/api/fortune/zodiac');
      if (!response.ok) throw new Error('별자리 운세 로드 실패');
      return response.json();
    },
    '/fortune/zodiac-animal': async () => {
      const response = await fetch('/api/fortune/zodiac-animal');
      if (!response.ok) throw new Error('띠 운세 로드 실패');
      return response.json();
    },
    
    // MBTI
    '/fortune/mbti': async () => {
      const response = await fetch('/api/fortune/mbti');
      if (!response.ok) throw new Error('MBTI 운세 로드 실패');
      return response.json();
    },
    
    // 연애/결혼/커리어
    '/fortune/love': async () => {
      const response = await fetch('/api/fortune/love');
      if (!response.ok) throw new Error('연애운 로드 실패');
      return response.json();
    },
    '/fortune/marriage': async () => {
      const response = await fetch('/api/fortune/marriage');
      if (!response.ok) throw new Error('결혼운 로드 실패');
      return response.json();
    },
    '/fortune/career': async () => {
      const response = await fetch('/api/fortune/career');
      if (!response.ok) throw new Error('취업운 로드 실패');
      return response.json();
    },
    
    // 금전운 관련
    '/fortune/wealth': async () => {
      const response = await fetch('/api/fortune/wealth');
      if (!response.ok) throw new Error('금전운 로드 실패');
      return response.json();
    },
    '/fortune/lucky-investment': async () => {
      const response = await fetch('/api/fortune/lucky-investment');
      if (!response.ok) throw new Error('투자운 로드 실패');
      return response.json();
    },
    
    // 행운 아이템
    '/fortune/lucky-color': async () => {
      const response = await fetch('/api/fortune/lucky-color');
      if (!response.ok) throw new Error('행운의 색상 로드 실패');
      return response.json();
    },
    '/fortune/lucky-number': async () => {
      const response = await fetch('/api/fortune/lucky-number');
      if (!response.ok) throw new Error('행운의 숫자 로드 실패');
      return response.json();
    },
    '/fortune/lucky-items': async () => {
      const response = await fetch('/api/fortune/lucky-items');
      if (!response.ok) throw new Error('행운의 아이템 로드 실패');
      return response.json();
    },
    
    // 기타 운세들
    '/fortune/moving': async () => {
      const response = await fetch('/api/fortune/moving');
      if (!response.ok) throw new Error('이사운 로드 실패');
      return response.json();
    },
    '/fortune/business': async () => {
      const response = await fetch('/api/fortune/business');
      if (!response.ok) throw new Error('사업운 로드 실패');
      return response.json();
    },
    '/fortune/palmistry': async () => {
      const response = await fetch('/api/fortune/palmistry');
      if (!response.ok) throw new Error('손금 운세 로드 실패');
      return response.json();
    },
    '/fortune/compatibility': async () => {
      const response = await fetch('/api/fortune/compatibility');
      if (!response.ok) throw new Error('궁합 로드 실패');
      return response.json();
    },
    '/fortune/lucky-hiking': async () => {
      const response = await fetch('/api/fortune/lucky-hiking');
      if (!response.ok) throw new Error('등산 운세 로드 실패');
      return response.json();
    },
    '/fortune/biorhythm': async () => {
      const response = await fetch('/api/fortune/biorhythm');
      if (!response.ok) throw new Error('바이오리듬 로드 실패');
      return response.json();
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

  // 광고 로딩 완료 후 처리
  const handleAdComplete = (fetchedData?: any) => {
    if (pendingFortune) {
      if (pendingFortune.path === 'refresh') {
        // 리프레쉬의 경우 운세 새로고침 수행
        performFortuneRefresh();
        setShowAdLoading(false);
        setPendingFortune(null);
      } else {
        // 페치된 데이터가 있으면 세션 스토리지에 저장
        if (fetchedData) {
          sessionStorage.setItem(`fortune_data_${pendingFortune.path}`, JSON.stringify({
            data: fetchedData,
            timestamp: Date.now()
          }));
        }
        
        // 일반 운세 페이지로 이동
        router.push(pendingFortune.path);
        setTimeout(() => {
          setShowAdLoading(false);
          setPendingFortune(null);
        }, 100);
      }
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
    // 로컬 스토리지 상태는 마운트 시 한 번만 체크
    let hasLoggedStatus = false;
    
    const initializeApp = async () => {
      try {
        // 1. 로컬 스토리지 상태 체크 (개발 환경에서만, 최초 1회)
        if (process.env.NODE_ENV === 'development' && !hasLoggedStatus) {
          hasLoggedStatus = true;
          logLocalStorageStatus();
          
          // 오래된 데이터 정리
          const cleanup = cleanupLocalStorage();
          if (cleanup.cleaned > 0) {
            logger.debug(`🧹 정리 완료: ${cleanup.cleaned}개 항목, ${Math.round(cleanup.freedSpace / 1024)}KB 확보`);
          }
        }
        
        // 2. 프로필 동기화 (Supabase와 로컬)
        const profile = await syncUserProfile();
        
        if (profile && profile.onboarding_completed) {
          setName(profile.name);
          setUserProfile(profile);
          
          // 3. 자동 업데이트 체크 (프로필 로드 후)
          await checkForAutoUpdate();
        } else {
          // 온보딩이 완료되지 않은 경우 메인 페이지로 리다이렉트
          router.push("/");
        }
      } catch (error) {
        logger.error('앱 초기화 실패:', error);
        // 오류 발생시 로컬 스토리지로 fallback
        const existingProfile = getUserProfile();
        if (!existingProfile || !existingProfile.onboarding_completed) {
          router.push("/");
        } else {
          setName(existingProfile.name);
          setUserProfile(existingProfile);
          
          // 오류 상황에서도 자동 업데이트 체크
          await checkForAutoUpdate();
        }
      }
    };

    initializeApp();
  }, [router]); // checkForAutoUpdate 제거하여 무한 루프 방지

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

  // 오늘의 운세 새로고침 - 광고 시청 후 갱신
  const refreshFortune = () => {
    const userProfile = getUserProfile();
    const isPremium = isPremiumUser(userProfile);
    
    if (isPremium) {
      // 프리미엄 사용자는 즉시 새로고침
      performFortuneRefresh();
    } else {
      // 일반 사용자는 광고 시청 후 새로고침
      setPendingFortune({ path: 'refresh', title: '운세 새로고침' });
      setShowAdLoading(true);
    }
  };

  // 실제 운세 새로고침 수행
  const performFortuneRefresh = async () => {
    setIsRefreshing(true);
    try {
      // 캐시를 강제로 무효화하고 새로운 운세 생성
      localStorage.removeItem('fortune_last_update_date');
      await refreshBatchFortune();
      
      // 새로운 날짜로 업데이트
      const today = new Date().toISOString().split('T')[0];
      localStorage.setItem('fortune_last_update_date', today);
      setLastUpdateDate(today);
    } catch (error) {
      logger.error('운세 새로고침 실패:', error);
    } finally {
      setIsRefreshing(false);
    }
  };

  // 배치 운세에서 오늘의 운세 가져오기
  const today = (() => {
    const dailyFortune = getFortuneByType('daily') || getFortuneByType('today');
    
    if (dailyFortune) {
      return {
        score: dailyFortune.score || 75,
        keywords: dailyFortune.keywords || ["행운", "기회", "성장"],
        summary: dailyFortune.content || dailyFortune.summary || "좋은 하루가 될 것 같습니다. 긍정적인 마음으로 하루를 시작하세요.",
        luckyColor: dailyFortune.luckyColor || "#8B5CF6",
        luckyNumber: dailyFortune.luckyNumber || 7,
        energy: dailyFortune.energy || 80,
        mood: dailyFortune.mood || "평온함",
        advice: dailyFortune.advice || "차분하게 하루를 보내세요",
        caution: dailyFortune.caution || "조급하게 서두르지 마세요",
        bestTime: dailyFortune.bestTime || "오후 2시-4시",
        compatibility: dailyFortune.compatibility || "좋은 사람들과 함께",
        elements: dailyFortune.elements || {
          love: 75,
          career: 80,
          money: 70,
          health: 85
        }
      };
    }

    // 기본값 (배치 운세가 아직 로드되지 않은 경우)
    return {
      score: 75,
      keywords: ["행운", "기회", "성장"],
      summary: batchLoading ? "운세를 생성하고 있습니다..." : "좋은 하루가 될 것 같습니다. 긍정적인 마음으로 하루를 시작하세요.",
      luckyColor: "#8B5CF6",
      luckyNumber: 7,
      energy: 80,
      mood: "평온함",
      advice: "차분하게 하루를 보내세요",
      caution: "조급하게 서두르지 마세요",
      bestTime: "오후 2시-4시",
      compatibility: "좋은 사람들과 함께",
      elements: {
        love: 75,
        career: 80,
        money: 70,
        health: 85
      }
    };
  })();

// 광고 로딩 화면 표시 중이면 AdLoadingScreen 렌더링
  if (showAdLoading && pendingFortune) {
    const userProfile = getUserProfile();
    const isPremium = isPremiumUser(userProfile);
    
    // 해당 경로에 대한 API 호출 함수 가져오기
    const fetchData = fortuneApiCalls[pendingFortune.path];
    
    return (
      <AdLoadingScreen
        fortuneType={pendingFortune.path.split('/').pop() || 'fortune'}
        fortuneTitle={pendingFortune.title}
        onComplete={handleAdComplete}
        onSkip={handleUpgradeToPremium}
        isPremium={isPremium}
        fetchData={fetchData}
      />
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      
      {/* 디버깅용 프리미엄 상태 표시 - 제거 */}
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-4"
      >
        {/* 배치 운세 오류 표시 */}
        {batchError && (
          <motion.div 
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-4 p-3 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg"
          >
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 bg-red-500 rounded-full"></div>
              <p className="text-sm text-red-700 dark:text-red-300">
                운세 데이터 로딩 중 오류가 발생했습니다. 기본 운세를 표시합니다.
              </p>
              <Button
                variant="ghost"
                size="sm"
                onClick={refreshFortune}
                className="ml-auto text-red-700 dark:text-red-300 hover:bg-red-100 dark:hover:bg-red-900/30"
              >
                다시 시도
              </Button>
            </div>
          </motion.div>
        )}

        {/* 배치 로딩 상태 표시 */}
        {batchLoading && !batchFortuneData && (
          <motion.div 
            initial={{ opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0 }}
            className="mb-4 p-3 bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg"
          >
            <div className="flex items-center gap-2">
              <motion.div 
                className="w-2 h-2 bg-blue-500 rounded-full"
                animate={{ scale: [1, 1.2, 1] }}
                transition={{ repeat: Infinity, duration: 1.5 }}
              ></motion.div>
              <p className="text-sm text-blue-700 dark:text-blue-300">
                AI가 맞춤형 운세를 생성하고 있습니다...
              </p>
            </div>
          </motion.div>
        )}
        {/* 오늘의 운세 카드 - 심플하게 디자인 */}
        <motion.div variants={itemVariants} className="mb-8">
          <Card className="bg-white border border-gray-200 shadow-sm">

              <CardHeader className="pb-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className="bg-gray-100 rounded-full p-2">
                      <timeInfo.icon className="w-6 h-6 text-gray-700" />
                    </div>
                    <div>
                      <CardTitle className={`${fontClasses.title} font-bold text-gray-900`}>
                        {timeInfo.greeting} 운세
                      </CardTitle>
                      <p className={`${fontClasses.label} text-gray-600`}>
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
                  <button
                    onClick={refreshFortune}
                    className="bg-gray-100 rounded-full p-2 hover:bg-gray-200 transition-colors"
                  >
                    <RefreshCw className={`w-5 h-5 text-gray-700 ${isRefreshing ? 'animate-spin' : ''}`} />
                  </button>
                </div>
              </CardHeader>

              <CardContent className="space-y-4">
                {/* 메인 운세 점수와 기분 */}
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <div className="bg-gray-100 rounded-full px-4 py-2 flex items-center gap-2">
                      <span className={`${fontClasses.title} font-bold text-gray-900`}>{today.score}점</span>
                    </div>
                    <div className="bg-gray-100 rounded-full px-3 py-1">
                      <span className={`${fontClasses.text} font-medium text-gray-700`}>{today.mood}</span>
                    </div>
                  </div>
                  <div className="flex items-center gap-1">
                    <Zap className="w-4 h-4 text-gray-600" />
                    <span className={`${fontClasses.label} text-gray-600`}>에너지 {today.energy}%</span>
                  </div>
                </div>

                {/* 운세 요약 */}
                <div className="bg-gray-50 rounded-lg p-3">
                  <p className={`${fontClasses.text} text-gray-800 leading-relaxed mb-2`}>{today.summary}</p>
                  
                  {/* 키워드 태그 */}
                  <div className="flex flex-wrap gap-2 mb-3">
                    {today.keywords.slice(0, 3).map((keyword) => (
                      <Badge key={keyword} variant="secondary" className={`${fontClasses.label} bg-gray-200 text-gray-700`}>
                        #{keyword}
                      </Badge>
                    ))}
                  </div>

                  {/* 조언과 주의사항 */}
                  <div className="grid grid-cols-1 gap-1">
                    <div className="flex items-start gap-2">
                      <Lightbulb className="w-4 h-4 text-gray-600 flex-shrink-0 mt-0.5" />
                      <span className={`${fontClasses.label} text-gray-700`}>{today.advice}</span>
                    </div>
                    <div className="flex items-start gap-2">
                      <Eye className="w-4 h-4 text-gray-600 flex-shrink-0 mt-0.5" />
                      <span className={`${fontClasses.label} text-gray-700`}>{today.caution}</span>
                    </div>
                  </div>
                </div>

                {/* 운세 세부 영역 - 클릭 가능 */}
                <div className="grid grid-cols-2 gap-3">
                  {Object.entries(today.elements).map(([key, value]) => {
                    const icons = {
                      love: Heart,
                      career: Briefcase,
                      money: Coins,
                      health: Activity
                    };
                    const names = {
                      love: "연애",
                      career: "직업",
                      money: "금전",
                      health: "건강"
                    };
                    const routes = {
                      love: '/fortune/love',
                      career: '/fortune/career',
                      money: '/fortune/wealth',
                      health: '/fortune/biorhythm'
                    };
                    const Icon = icons[key as keyof typeof icons];
                    
                    return (
                      <div
                        key={key}
                        onClick={() => handleFortuneClick(routes[key as keyof typeof routes], `${names[key as keyof typeof names]}운 상세`)}
                        className="bg-gray-50 rounded-lg p-2 cursor-pointer hover:bg-gray-100 transition-colors"
                      >
                        <div className="flex items-center justify-between">
                          <div className="flex items-center gap-2">
                            <Icon className="w-4 h-4 text-gray-700" />
                            <span className={`${fontClasses.label} text-gray-700`}>
                              {names[key as keyof typeof names]}
                            </span>
                          </div>
                          <div className="flex items-center gap-1">
                            <span className={`${fontClasses.label} font-semibold text-gray-900`}>{value}%</span>
                            <ChevronRight className="w-3 h-3 text-gray-400" />
                          </div>
                        </div>
                        <div className="mt-2 bg-gray-200 rounded-full h-1.5 overflow-hidden">
                          <div
                            className="h-full bg-gray-500 rounded-full"
                            style={{ width: `${value}%` }}
                          />
                        </div>
                      </div>
                    );
                  })}
                </div>

                {/* 하단 정보 - 클릭 가능한 항목들 */}
                <div className="grid grid-cols-2 gap-2 pt-3 border-t border-gray-200">
                  {/* 행운의 색 */}
                  <div
                    onClick={() => handleFortuneClick('/fortune/lucky-color', '행운의 색상')}
                    className="bg-gray-50 rounded-lg p-3 cursor-pointer hover:bg-gray-100 transition-colors"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <div 
                          className="w-5 h-5 rounded-full border-2 border-gray-300"
                          style={{ backgroundColor: today.luckyColor }}
                        />
                        <span className={`${fontClasses.label} font-medium text-gray-700`}>행운의 색</span>
                      </div>
                      <ChevronRight className="w-4 h-4 text-gray-400" />
                    </div>
                  </div>
                  
                  {/* 행운의 숫자 */}
                  <div
                    onClick={() => handleFortuneClick('/fortune/lucky-number', '행운의 숫자')}
                    className="bg-gray-50 rounded-lg p-3 cursor-pointer hover:bg-gray-100 transition-colors"
                  >
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-2">
                        <Star className="w-5 h-5 text-gray-700" />
                        <span className={`${fontClasses.label} font-medium text-gray-700`}>행운의 숫자: {today.luckyNumber}</span>
                      </div>
                      <ChevronRight className="w-4 h-4 text-gray-400" />
                    </div>
                  </div>
                </div>

                {/* 최적 시간과 궁합 정보 - 간소화 */}
                <div className="flex justify-between items-center pt-2">
                  <div className="flex items-center gap-3 text-gray-600">
                    <div className="flex items-center gap-1">
                      <Clock className="w-3.5 h-3.5" />
                      <span className={`${fontClasses.label}`}>{today.bestTime}</span>
                    </div>
                    <div className="w-px h-4 bg-gray-200" />
                    <div className="flex items-center gap-1">
                      <Users className="w-3.5 h-3.5" />
                      <span className={`${fontClasses.label}`}>{today.compatibility}</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
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
              <Card className="h-[140px] hover:shadow-lg transition-all duration-300 border-gray-200 hover:border-purple-300 dark:bg-gray-800 dark:border-gray-600 dark:hover:border-purple-500">
                <CardContent className="p-4 flex flex-col items-center text-center h-full justify-center">
                  <div className="bg-purple-100 dark:bg-purple-900/30 rounded-full w-12 h-12 flex items-center justify-center mx-auto mb-2">
                    <item.icon className="w-6 h-6 text-purple-600 dark:text-purple-400" />
                  </div>
                  <h3 className={`${fontClasses.text} font-semibold text-gray-900 dark:text-gray-100 mb-1`}>{item.title}</h3>
                  <p className={`${fontClasses.label} text-gray-600 dark:text-gray-400 text-center`}>{item.desc}</p>
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
            <div className="flex items-center gap-2 mb-4">
              <History className="w-5 h-5 text-gray-600" />
              <h2 className={`${fontClasses.title} font-bold text-gray-900`}>최근에 본 운세</h2>
            </div>
            <div className="space-y-3">
              {recentFortunes.slice(0, 3).map((recent) => {
                const fortuneKey = getFortuneKey(recent.path);
                const info = fortuneInfo[fortuneKey] || { 
                  icon: Star, 
                  title: recent.title, 
                  desc: "운세 정보"
                };
                
                return (
                  <Card key={recent.path} className="hover:shadow-md transition-shadow bg-white border border-gray-200">
                    <CardContent className="p-4">
                      <div className="flex items-center gap-3">
                        <div className="bg-gray-100 rounded-full w-12 h-12 flex items-center justify-center">
                          <info.icon className="w-6 h-6 text-gray-700" />
                        </div>
                        <div className="flex-1 min-w-0">
                          <h3 className={`${fontClasses.text} font-semibold text-gray-900`}>{info.title}</h3>
                          <p className={`${fontClasses.label} text-gray-600`}>{info.desc}</p>
                        </div>
                        <div className="flex items-center gap-2">
                          <Badge variant="secondary" className="bg-gray-100 text-gray-700">
                            {formatTimeAgo(recent.visitedAt)}
                          </Badge>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="p-2 h-auto"
                            onClick={() => handleFortuneClick(recent.path, recent.title)}
                          >
                            <ArrowRight className="w-5 h-5 text-gray-600" />
                          </Button>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                );
              })}
            </div>
          </motion.div>
        )}

        {/* 나만의 맞춤 운세 */}
        <motion.div variants={itemVariants} className="mb-8">
          <h2 className={`${fontClasses.title} font-bold text-gray-900 mb-4`}>
            나만의 맞춤 운세
          </h2>
          <div className="grid grid-cols-1 gap-3">
            {[
              { href: "/fortune/mbti", icon: Zap, title: "MBTI 주간 운세", desc: "성격 유형별 조언", badge: "NEW" },
              { href: "/fortune/zodiac", icon: Star, title: "별자리 월간 운세", desc: "별이 알려주는 흐름", badge: "인기" },
              { href: "/fortune/zodiac-animal", icon: Crown, title: "띠 운세", desc: "12간지로 보는 이달의 운세", badge: "전통" }
            ].map((item) => (
              <Card 
                key={item.href}
                className="h-[80px] hover:shadow-md transition-shadow cursor-pointer bg-white border border-gray-200"
                onClick={() => handleFortuneClick(item.href, item.title)}
              >
                <CardContent className="p-4 h-full flex items-center">
                  <div className="flex items-center gap-3 w-full">
                    <div className="bg-gray-100 rounded-full w-10 h-10 flex items-center justify-center">
                      <item.icon className="w-5 h-5 text-gray-700" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center gap-2 mb-1">
                        <h3 className={`${fontClasses.text} font-medium text-gray-900`}>{item.title}</h3>
                        <Badge variant="secondary" className="bg-gray-100 text-gray-700">
                          {item.badge}
                        </Badge>
                      </div>
                      <p className={`${fontClasses.label} text-gray-600`}>{item.desc}</p>
                    </div>
                    <ArrowRight className="w-4 h-4 text-gray-400" />
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
}

export default function HomePageWrapper() {
  return (
    <ProtectedRoute>
      <HomePage />
    </ProtectedRoute>
  );
}
