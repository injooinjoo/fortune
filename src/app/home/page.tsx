"use client";

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { auth } from '@/lib/supabase'; // Supabase auth 객체 가져오기
import type { User } from '@supabase/supabase-js';
import { FortuneCompassIcon } from '@/components/icons/fortune-compass-icon';
import { Gem, Heart, Briefcase, Star, Calendar, User as UserIcon, Home, Settings, BookOpen, TrendingUp } from 'lucide-react';

interface UserProfile {
  name: string;
  birthdate: string;
  mbti: string;
  gender: string;
  birthTime: string;
}

interface FortuneCategory {
  id: string;
  title: string;
  description: string;
  icon: React.ComponentType<any>;
  color: string;
  route: string;
}

interface NavItem {
  id: string;
  title: string;
  icon: React.ComponentType<any>;
  route: string;
  active?: boolean;
}

const fortuneCategories: FortuneCategory[] = [
  {
    id: 'saju',
    title: '사주팔자',
    description: '태어난 시간으로 보는 운명',
    icon: Calendar,
    color: 'text-purple-600',
    route: '/fortune/saju'
  },
  {
    id: 'mbti',
    title: 'MBTI 운세',
    description: '성격 유형별 오늘의 운세',
    icon: UserIcon,
    color: 'text-blue-600',
    route: '/fortune/mbti'
  },
  {
    id: 'love',
    title: '연애운',
    description: '사랑과 인연의 흐름',
    icon: Heart,
    color: 'text-pink-600',
    route: '/fortune/love'
  },
  {
    id: 'career',
    title: '취업운',
    description: '직업과 성공의 기회',
    icon: Briefcase,
    color: 'text-green-600',
    route: '/fortune/career'
  },
  {
    id: 'daily',
    title: '오늘의 총운',
    description: '하루 전체적인 운세',
    icon: Star,
    color: 'text-yellow-600',
    route: '/fortune/daily'
  },
  {
    id: 'wealth',
    title: '금전운',
    description: '재물과 투자의 운',
    icon: Gem,
    color: 'text-amber-600',
    route: '/fortune/wealth'
  }
];

const navItems: NavItem[] = [
  {
    id: 'home',
    title: '홈',
    icon: Home,
    route: '/home',
    active: true
  },
  {
    id: 'fortune',
    title: '운세',
    icon: Star,
    route: '/fortune'
  },
  {
    id: 'learn',
    title: '학습',
    icon: BookOpen,
    route: '/learn'
  },
  {
    id: 'stats',
    title: '통계',
    icon: TrendingUp,
    route: '/stats'
  },
  {
    id: 'profile',
    title: '프로필',
    icon: Settings,
    route: '/profile'
  }
];

export default function HomePage() {
  const router = useRouter();
  const [user, setUser] = useState<User | null>(null);
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);
  const [todayFortune, setTodayFortune] = useState<string>('');

  useEffect(() => {
    const { data: { subscription } } = auth.onAuthStateChanged((currentUser: any) => {
      setUser(currentUser);
      setLoading(false);
      
      if (!currentUser) {
        // 로그인하지 않은 사용자는 인증 페이지로 리디렉션
        router.push('/auth/selection');
      } else {
        // 로그인 성공 후 로컬스토리지에서 프로필 정보 불러오기
        const savedProfile = localStorage.getItem('userProfile');
        if (savedProfile) {
          try {
            const profile = JSON.parse(savedProfile);
            setUserProfile(profile);
            generateTodayFortune(profile);
          } catch (error) {
            console.error('프로필 정보 파싱 실패:', error);
          }
        }
      }
    });

    return () => subscription?.unsubscribe();
  }, [router]);

  const generateTodayFortune = (profile: UserProfile) => {
    const fortunes = [
      '오늘은 새로운 기회가 찾아올 날입니다.',
      '인간관계에서 좋은 소식이 있을 것 같습니다.',
      '계획했던 일이 순조롭게 풀릴 예정입니다.',
      '작은 행운이 연속으로 찾아올 것 같습니다.',
      '창의적인 아이디어가 떠오를 하루입니다.',
      '중요한 결정을 내리기에 좋은 날입니다.'
    ];
    
    const today = new Date().getDate();
    const randomIndex = (today + profile.name.length) % fortunes.length;
    setTodayFortune(fortunes[randomIndex]);
  };

  const handleCategoryClick = (category: FortuneCategory) => {
    if (!userProfile) {
      router.push('/');
      return;
    }
    
    // 임시로 토스트 메시지 표시 (실제로는 해당 운세 페이지로 이동)
    alert(`${category.title} 기능 개발 중입니다.`);
  };

  const handleNavClick = (item: NavItem) => {
    if (item.route === '/home') {
      // 이미 홈 페이지에 있음
      return;
    }
    
    if (item.route === '/profile') {
      router.push('/');
      return;
    }
    
    // 다른 페이지들은 개발 중
    alert(`${item.title} 페이지 개발 중입니다.`);
  };

  const handleLogout = async () => {
    try {
      await auth.signOut();
      // 로그아웃시 저장된 프로필 정보도 삭제
      localStorage.removeItem('userProfile');
      router.push('/auth/selection'); // 로그아웃 후 로그인 선택 페이지로 이동
    } catch (error) {
      console.error("로그아웃 실패:", error);
    }
  };

  const getUserDisplayName = () => {
    if (userProfile?.name) {
      return userProfile.name;
    }
    return user?.user_metadata?.name || user?.user_metadata?.user_email || '사용자';
  };

  if (loading) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-background text-foreground p-4">
        <FortuneCompassIcon className="h-12 w-12 text-primary animate-spin mb-4" />
        <p className="text-muted-foreground">사용자 정보 확인 중...</p>
      </div>
    );
  }

  if (!user) {
    // 이 경우는 useEffect에서 router.push로 처리되지만, 만약을 위한 방어 코드
    return null; 
  }

  return (
    <div className="min-h-screen bg-background text-foreground pb-20">
      {/* 헤더 */}
      <header className="bg-gradient-to-r from-purple-600 to-indigo-600 text-white p-6">
        <div className="max-w-md mx-auto">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center space-x-3">
              <FortuneCompassIcon className="h-8 w-8" />
              <h1 className="text-xl font-bold">운세 탐험</h1>
            </div>
            <Button onClick={handleLogout} variant="ghost" size="sm" className="text-white hover:text-white/80">
              로그아웃
            </Button>
          </div>
          <div>
            <h2 className="text-2xl font-bold mb-1">{getUserDisplayName()}님</h2>
            <p className="text-white/90">안녕하세요! 오늘도 좋은 하루 되세요.</p>
          </div>
        </div>
      </header>

      <main className="max-w-md mx-auto p-4 space-y-6">
        {/* 프로필 요약 카드 */}
        {userProfile && (
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="text-lg">내 프로필</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <div className="grid grid-cols-2 gap-4 text-sm">
                <div>
                  <span className="text-muted-foreground">MBTI:</span>
                  <span className="ml-2 font-medium">{userProfile.mbti}</span>
                </div>
                <div>
                  <span className="text-muted-foreground">성별:</span>
                  <span className="ml-2 font-medium">{userProfile.gender}</span>
                </div>
                <div className="col-span-2">
                  <span className="text-muted-foreground">생년월일:</span>
                  <span className="ml-2 font-medium">
                    {new Date(userProfile.birthdate).toLocaleDateString('ko-KR')}
                  </span>
                </div>
              </div>
              <Button 
                onClick={() => router.push('/')} 
                variant="outline" 
                size="sm" 
                className="w-full mt-3"
              >
                프로필 수정
              </Button>
            </CardContent>
          </Card>
        )}

        {/* 오늘의 운세 */}
        {todayFortune && (
          <Card className="bg-gradient-to-r from-yellow-50 to-orange-50 border-yellow-200">
            <CardHeader className="pb-3">
              <CardTitle className="text-lg flex items-center">
                <Star className="h-5 w-5 text-yellow-600 mr-2" />
                오늘의 운세
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-foreground/90">{todayFortune}</p>
            </CardContent>
          </Card>
        )}

        {/* 운세 카테고리 */}
        <div>
          <h3 className="text-xl font-bold mb-4">운세 보기</h3>
          <div className="grid grid-cols-2 gap-3">
            {fortuneCategories.map((category) => {
              const IconComponent = category.icon;
              return (
                <Card 
                  key={category.id} 
                  className="cursor-pointer hover:shadow-md transition-shadow duration-200"
                  onClick={() => handleCategoryClick(category)}
                >
                  <CardContent className="p-4 text-center">
                    <IconComponent className={`h-8 w-8 mx-auto mb-2 ${category.color}`} />
                    <h4 className="font-semibold text-sm mb-1">{category.title}</h4>
                    <p className="text-xs text-muted-foreground">{category.description}</p>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        </div>

        {/* 빠른 액션 */}
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-lg">빠른 메뉴</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <Button 
              onClick={() => router.push('/mbti')} 
              variant="outline" 
              className="w-full justify-start"
            >
              <UserIcon className="h-4 w-4 mr-2" />
              MBTI 유형별 정보 보기
            </Button>
            <Button 
              onClick={() => router.push('/physiognomy')} 
              variant="outline" 
              className="w-full justify-start"
            >
              <Gem className="h-4 w-4 mr-2" />
              관상 분석하기
            </Button>
          </CardContent>
        </Card>
      </main>

      {/* 하단 네비게이션 */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 px-4 py-2">
        <div className="max-w-md mx-auto">
          <div className="flex justify-around">
            {navItems.map((item) => {
              const IconComponent = item.icon;
              const isActive = item.active;
              
              return (
                <button
                  key={item.id}
                  onClick={() => handleNavClick(item)}
                  className={`flex flex-col items-center py-2 px-3 rounded-lg transition-colors duration-200 ${
                    isActive 
                      ? 'text-purple-600 bg-purple-50' 
                      : 'text-gray-500 hover:text-gray-700 hover:bg-gray-50'
                  }`}
                >
                  <IconComponent className={`h-5 w-5 mb-1 ${isActive ? 'text-purple-600' : ''}`} />
                  <span className="text-xs font-medium">{item.title}</span>
                </button>
              );
            })}
          </div>
        </div>
      </nav>

      <footer className="py-8 text-center text-xs text-muted-foreground">
        <p>&copy; 운세 탐험. 모든 운명은 당신의 선택에 달려있습니다.</p>
      </footer>
    </div>
  );
}
