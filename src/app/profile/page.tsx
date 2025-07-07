"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { useTheme } from "next-themes";
import { motion } from "framer-motion";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import AppHeader from "@/components/AppHeader";
import {
  Bell,
  Crown,
  HelpCircle,
  FileText,
  ChevronRight,
  Moon,
  Sun,
  Palette,
  Settings,
  Star,
  Gift,
  Heart,
  Users,
  BarChart3,
  Calendar,
  Shield,
  Smartphone,
  Globe,
  Zap
} from "lucide-react";
import { getUserProfile, saveUserProfile, syncUserProfile } from "@/lib/user-storage";
import { type UserProfile } from "@/lib/supabase";
import { cn } from "@/lib/utils";

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

export default function ProfilePage() {
  const router = useRouter();
  const { theme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);
  const [user, setUser] = useState<UserProfile | null>(null);
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [emailNotifications, setEmailNotifications] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [isPremiumDebug, setIsPremiumDebug] = useState(false);

  // 컴포넌트가 마운트된 후에만 테마 관련 UI를 보여줌 (hydration 오류 방지)
  useEffect(() => {
    setMounted(true);
    loadUserProfile();
    // 로컬 스토리지에서 디버그 프리미엄 상태 로드
    const storedProfile = getUserProfile();
    if (storedProfile) {
      setIsPremiumDebug(storedProfile.subscription_status === 'premium' || storedProfile.subscription_status === 'premium_plus');
    }
  }, []);

  const loadUserProfile = async () => {
    try {
      console.log('🔍 프로필 로드 시작');
      
      // user-storage.ts의 syncUserProfile 사용하여 자동 동기화
      const profile = await syncUserProfile();
      
      if (profile && profile.onboarding_completed) {
        console.log('✅ 프로필 로드 성공:', profile.name);
        setUser(profile);
      } else if (profile && !profile.onboarding_completed) {
        console.log('⚠️ 온보딩 미완료, 온보딩 페이지로 이동');
        router.push('/onboarding');
      } else {
        console.log('❌ 프로필 없음, 메인 페이지로 이동');
        router.push('/');
      }
    } catch (error) {
      console.error('🚨 프로필 로드 실패:', error);
      router.push('/');
    } finally {
      setIsLoading(false);
    }
  };

  const getSubscriptionBadge = (status?: string) => {
    switch (status) {
      case 'premium':
        return <Badge variant="default" className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white">프리미엄</Badge>;
      case 'premium_plus':
        return <Badge variant="default" className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white">프리미엄 플러스</Badge>;
      default:
        return <Badge variant="secondary">무료</Badge>;
    }
  };

  const getProviderBadge = (user: UserProfile) => {
    // 로그인된 사용자만 Google 배지 표시
    return <Badge variant="outline" className="text-blue-600 border-blue-200">Google</Badge>;
  };

  const handleEditProfile = () => {
    router.push("/profile/edit");
  };

  const handleSubscription = () => {
    router.push("/membership"); // 구독 멤버십 페이지로 이동
  };

  const handleSupport = () => {
    router.push("/support");
  };

  const handlePolicy = () => {
    router.push("/policy");
  };

  const handleLogout = async () => {
    try {
      console.log('🚪 로그아웃 시작');
      
      // user-storage.ts의 함수들을 통해 안전하게 로그아웃 처리
      const currentUser = getUserProfile();
      
      // Supabase 로그아웃 시도 (게스트가 아닌 경우만)
      if (currentUser && !isGuestUser(currentUser)) {
        try {
          const supabase = (await import('@/lib/supabase')).supabase;
          await supabase.auth.signOut();
          console.log('✅ Supabase 로그아웃 성공');
        } catch (error) {
          console.error('Supabase 로그아웃 오류:', error);
        }
      }
      
      // 로컬 스토리지 정리
      saveUserProfile(null);
      localStorage.removeItem('daily_fortunes');
      localStorage.removeItem('fortune_history');
      
      console.log('✅ 로그아웃 완료');
      router.push("/");
    } catch (error) {
      console.error('🚨 로그아웃 실패:', error);
      // 실패해도 로컬 데이터는 정리하고 메인 페이지로 이동
      saveUserProfile(null);
      router.push("/");
    }
  };

  const handleFortuneHistory = () => {
    router.push("/history");
  };

  const handleNotificationSettings = () => {
    router.push("/profile/notifications");
  };

  // 디버깅용 프리미엄 상태 토글
  const togglePremiumDebug = (enabled: boolean) => {
    setIsPremiumDebug(enabled);
    
    // 로컬 스토리지의 사용자 프로필 업데이트
    const currentProfile = getUserProfile();
    if (currentProfile) {
      const updatedProfile = {
        ...currentProfile,
        subscription_status: enabled ? 'premium' as const : 'free' as const
      };
      saveUserProfile(updatedProfile);
      
      // 현재 표시되는 사용자 정보도 업데이트
      setUser(prev => prev ? {
        ...prev,
        subscription_status: enabled ? 'premium' : 'free'
      } : null);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background text-foreground pb-20">
        <div className="p-6 space-y-6">
          <div className="animate-pulse space-y-4">
            <div className="flex items-center space-x-4">
              <div className="w-16 h-16 bg-gray-200 dark:bg-gray-700 rounded-full"></div>
              <div className="space-y-2">
                <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-32"></div>
                <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-48"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="min-h-screen bg-background text-foreground pb-20">
        <div className="p-6 text-center">
          <p className="text-gray-900 dark:text-gray-100">사용자 정보를 불러올 수 없습니다.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-50 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 pb-20">
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6"
      >
        {/* 사용자 정보 카드 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white border-0">
            <CardContent className="p-6">
              <div className="flex items-center space-x-4">
                <motion.div
                  whileHover={{ scale: 1.05 }}
                  transition={{ type: "spring", stiffness: 300 }}
                >
                  <Avatar className="w-16 h-16 border-2 border-white/20">
                    <AvatarImage src={user.avatar_url} alt={user.name} />
                    <AvatarFallback className="bg-white/20 text-white text-lg font-semibold">
                      {user.name.charAt(0).toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                </motion.div>
                <div className="flex-1 space-y-2">
                  <div className="flex items-center gap-2">
                    <h2 className="text-xl font-bold">{user.name}</h2>
                    {getProviderBadge(user)}
                  </div>
                  <p className="text-white/80 text-sm">{user.email || '게스트 사용자'}</p>
                  <div className="flex items-center gap-2">
                    {getSubscriptionBadge(user.subscription_status)}
                    <span className="text-white/60 text-xs">
                      • {user.created_at ? new Date(user.created_at).getFullYear() : new Date().getFullYear()}년 가입
                    </span>
                  </div>
                </div>
                <Button 
                  variant="secondary" 
                  size="sm" 
                  onClick={handleEditProfile}
                  className="bg-white/20 text-white border-white/30 hover:bg-white/30"
                >
                  수정
                </Button>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 활동 통계 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <BarChart3 className="w-5 h-5" />
                나의 활동
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-4">
                <div className="text-center p-3 bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-800 dark:to-gray-700 rounded-xl border border-gray-200 dark:border-gray-600">
                  <div className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                    {user.fortune_count || 0}
                  </div>
                  <div className="text-sm text-gray-600 dark:text-gray-300">운세 조회</div>
                </div>
                <div className="text-center p-3 bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-800 dark:to-gray-700 rounded-xl border border-gray-200 dark:border-gray-600">
                  <div className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                    {user.favorite_fortune_types?.length || 0}
                  </div>
                  <div className="text-sm text-gray-600 dark:text-gray-300">선호 운세</div>
                </div>
                <div className="text-center p-3 bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-800 dark:to-gray-700 rounded-xl border border-gray-200 dark:border-gray-600">
                  <div className="text-2xl font-bold text-gray-900 dark:text-gray-100">7</div>
                  <div className="text-sm text-gray-600 dark:text-gray-300">연속 일수</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 설정 메뉴 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Settings className="w-5 h-5" />
                설정
              </CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <div className="divide-y divide-gray-100 dark:divide-gray-700">
                {/* 테마 설정 */}
                {mounted && (
                  <div className="flex items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                    <div className="flex items-center space-x-3">
                      {theme === 'dark' ? (
                        <Moon className="h-5 w-5 text-gray-700 dark:text-gray-300" />
                      ) : (
                        <Sun className="h-5 w-5 text-gray-700 dark:text-gray-300" />
                      )}
                      <span className="text-sm font-medium text-gray-900 dark:text-gray-100">다크 모드</span>
                    </div>
                    <Switch
                      checked={theme === 'dark'}
                      onCheckedChange={(checked) => setTheme(checked ? 'dark' : 'light')}
                    />
                  </div>
                )}

                {/* 알림 설정 */}
                <div className="flex items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                  <div className="flex items-center space-x-3">
                    <Bell className="h-5 w-5 text-gray-700 dark:text-gray-300" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">푸시 알림</span>
                  </div>
                  <Switch
                    checked={notificationsEnabled}
                    onCheckedChange={setNotificationsEnabled}
                  />
                </div>

                {/* 이메일 알림 */}
                <div className="flex items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors">
                  <div className="flex items-center space-x-3">
                    <Globe className="h-5 w-5 text-gray-700 dark:text-gray-300" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">이메일 알림</span>
                  </div>
                  <Switch
                    checked={emailNotifications}
                    onCheckedChange={setEmailNotifications}
                  />
                </div>

                {/* 디버깅용 프리미엄 토글 */}
                <div className="flex items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors border-t-2 border-dashed border-orange-200 dark:border-orange-800">
                  <div className="flex items-center space-x-3">
                    <Zap className="h-5 w-5 text-orange-500" />
                    <div className="flex flex-col">
                      <span className="text-sm font-medium text-gray-900 dark:text-gray-100">프리미엄 모드 (디버그)</span>
                      <span className="text-xs text-gray-600 dark:text-gray-300">개발/테스트용 - 광고 스킵</span>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    <Badge variant={isPremiumDebug ? "default" : "secondary"} className="text-xs">
                      {isPremiumDebug ? "프리미엄" : "무료"}
                    </Badge>
                    <Switch
                      checked={isPremiumDebug}
                      onCheckedChange={togglePremiumDebug}
                    />
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 메뉴 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardContent className="p-0">
              <div className="divide-y divide-gray-100 dark:divide-gray-700">
                {/* 프리미엄 구독 관리 */}
                <button
                  type="button"
                  onClick={handleSubscription}
                  className="flex w-full items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <Crown className="h-5 w-5 text-purple-500" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">구독 멤버십 관리</span>
                    {user.subscription_status === 'free' && (
                      <Badge variant="outline" className="text-xs">업그레이드</Badge>
                    )}
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                </button>

                {/* 나의 운세 기록 */}
                <button
                  type="button"
                  onClick={handleFortuneHistory}
                  className="flex w-full items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <Calendar className="h-5 w-5 text-indigo-500" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">나의 운세 기록</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                </button>

                {/* 즐겨찾기 관리 */}
                <button
                  type="button"
                  onClick={() => router.push("/profile/favorites")}
                  className="flex w-full items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <Heart className="h-5 w-5 text-red-500" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">즐겨찾기 관리</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                </button>

                {/* 알림 상세 설정 */}
                <button
                  type="button"
                  onClick={handleNotificationSettings}
                  className="flex w-full items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <Smartphone className="h-5 w-5 text-blue-500" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">알림 상세 설정</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                </button>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 지원 및 정보 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <HelpCircle className="w-5 h-5" />
                지원 및 정보
              </CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <div className="divide-y divide-gray-100 dark:divide-gray-700">
                <button
                  type="button"
                  onClick={handleSupport}
                  className="flex w-full items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <HelpCircle className="h-5 w-5 text-green-500" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">고객센터 / 문의하기</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                </button>

                <button
                  type="button"
                  onClick={() => router.push("/feedback")}
                  className="flex w-full items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <Star className="h-5 w-5 text-yellow-500" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">평가 및 리뷰</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                </button>

                <button
                  type="button"
                  onClick={handlePolicy}
                  className="flex w-full items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <FileText className="h-5 w-5 text-gray-600 dark:text-gray-400" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">이용약관 및 개인정보 처리방침</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                </button>

                <button
                  type="button"
                  onClick={() => router.push("/about")}
                  className="flex w-full items-center justify-between px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-800 transition-colors"
                >
                  <div className="flex items-center space-x-3">
                    <Shield className="h-5 w-5 text-blue-500" />
                    <span className="text-sm font-medium text-gray-900 dark:text-gray-100">앱 정보</span>
                  </div>
                  <ChevronRight className="h-4 w-4 text-gray-500 dark:text-gray-400" />
                </button>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 로그아웃 */}
        <motion.div variants={itemVariants} className="pt-4">
          <div className="text-center">
            <button
              type="button"
              onClick={handleLogout}
              className="text-gray-500 dark:text-gray-400 hover:text-gray-700 dark:hover:text-gray-200 text-sm underline transition-colors"
            >
              로그아웃
            </button>
          </div>
        </motion.div>

        {/* 앱 버전 정보 */}
        <motion.div variants={itemVariants} className="pb-4">
          <div className="text-center text-xs text-gray-400 dark:text-gray-500">
            행운 v1.0.0 • Made with ❤️
          </div>
        </motion.div>
      </motion.div>
    </div>
  );
}
