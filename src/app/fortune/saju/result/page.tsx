"use client";

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import AppHeader from '@/components/AppHeader';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { useToast } from '@/hooks/use-toast';
import { 
  RefreshCw, 
  Loader2, 
  Star,
  TrendingUp,
  Heart,
  DollarSign,
  Briefcase,
  Activity,
  GraduationCap,
  Sparkles
} from 'lucide-react';
import { FortuneResponse, DailyComprehensiveData } from '@/lib/types/fortune-system';

interface TodayFortuneData {
  todayScore: number;
  generalFortune: string;
  wealthFortune: string;
  loveFortune: string;
  businessFortune: string;
  healthFortune: string;
  studyFortune: string;
  timeBasedFortunes: {
    morning: {
      score: number;
      title: string;
      description: string;
      advice: string;
    };
    afternoon: {
      score: number;
      title: string;
      description: string;
      advice: string;
    };
    night: {
      score: number;
      title: string;
      description: string;
      advice: string;
    };
  };
  userInfo: {
    name: string;
    mbti: string;
    gender: string;
  };
}

interface SajuResultPageState {
  data: TodayFortuneData | null;
  loading: boolean;
  error: string | null;
  cached: boolean;
  cacheSource?: 'redis' | 'database' | 'fresh';
  generatedAt: string | null;
}

export default function SajuResultPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [activeTimeTab, setActiveTimeTab] = useState<'general' | 'morning' | 'afternoon' | 'night'>('general');
  const [state, setState] = useState<SajuResultPageState>({
    data: null,
    loading: true,
    error: null,
    cached: false,
    generatedAt: null
  });
  
  const router = useRouter();
  const { toast } = useToast();

    // 사주 기본 데이터를 가져와서 오늘의 운세로 활용
  const loadTodayFortuneData = async (forceRefresh = false) => {
    try {
      setState(prev => ({ ...prev, loading: true, error: null }));

      // 사주 기본 정보 API 호출
      const response = await fetch('/api/fortune/saju', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        },
        cache: forceRefresh ? 'no-cache' : 'default'
      });

      const result = await response.json();

      if (!result.success) {
        // 프로필이 필요한 경우 온보딩으로 리다이렉트
        if (result.error === 'PROFILE_REQUIRED') {
          toast({
            title: "프로필 정보 필요",
            description: "운세를 보려면 먼저 프로필을 설정해주세요.",
            variant: "destructive",
          });
          setTimeout(() => {
            router.push('/onboarding/profile');
          }, 1500);
          return;
        }
        throw new Error(result.error || '데이터 로드 실패');
      }

              // 사주 데이터를 오늘의 운세 형태로 변환
        const sajuData = result.data?.saju;
        const userName = sajuData?.basic_info?.name || "사용자";
        const userMbti = sajuData?.basic_info?.mbti || "ENTJ";
        const userGender = sajuData?.basic_info?.gender || "남성";
        
        const transformedData = {
          todayScore: 55, // 고정값 (실제로는 계산 로직 필요)
          generalFortune: sajuData?.personality_analysis || "감각을 곤두세울 필요가 있는 하루입니다.",
          wealthFortune: "태산을 만들기 위한 티끌을 모을 때입니다. 큰 계획없이 소비생활을 지속해왔다면, 이제는 방향을 바꿔야 합니다.",
          loveFortune: "가장비에 웃이 젖듯 어느새 상대방에게 폭 빠질 수 있겠습니다. 전혀 생각하지도 않았던 사람이 이성으로 보일 듯 합니다.",
          businessFortune: "친절한 모습만 보이는 것이 위험할 수 있습니다. 단호해야 하는 순간에는 당신이 만만치 않다는 것을 보여주는 것이 좋겠습니다.",
          healthFortune: "심신의 기운이 무난한 하루입니다. 건강 문제로 크게 염려해야 하는 부분은 없을 듯 합니다.",
          studyFortune: "잔꾀를 부리면 머지 않아 넘어질 수 밖에 없습니다. 당장 편하고 쉬운 마음에 알맞한 수를 쓴다면 엄는 것 없이 시간만 허비하는 꼴이 됩니다.",
          timeBasedFortunes: {
            morning: {
              score: 72,
              title: `${userName}님의 오전 운세`,
              description: `${userMbti} 성향의 ${userName}님, 오전에는 새로운 시작의 에너지가 강합니다. 계획했던 일들을 차근차근 진행하기에 좋은 시간대입니다.`,
              advice: userMbti.includes('E') 
                ? "외향적인 성격을 활용해 사람들과의 만남이나 회의를 오전에 잡아보세요. 에너지가 가장 높은 시간입니다."
                : "조용한 오전 시간을 활용해 혼자만의 시간으로 중요한 업무에 집중해보세요. 최고의 성과를 낼 수 있습니다."
            },
            afternoon: {
              score: 48,
              title: `${userName}님의 오후 운세`,
              description: `오후에는 약간의 주의가 필요한 시간대입니다. ${userGender === '남성' ? '남성' : '여성'}으로서 감정 기복이 있을 수 있으니 중요한 결정은 피하는 것이 좋겠습니다.`,
              advice: userMbti.includes('T') 
                ? "논리적 사고가 강한 당신이지만, 오후에는 감정적 판단이 섞일 수 있습니다. 데이터를 다시 한번 검토해보세요."
                : "감정이 풍부한 당신의 장점이 오후에는 오히려 혼란을 줄 수 있습니다. 차분히 정리하는 시간을 가져보세요."
            },
            night: {
              score: 61,
              title: `${userName}님의 밤 운세`,
              description: `밤 시간에는 안정적인 운세를 보입니다. 하루를 마무리하며 내일을 준비하기에 좋은 시간입니다. ${userMbti} 특성상 이 시간대가 당신에게 잘 맞습니다.`,
              advice: userMbti.includes('J') 
                ? "계획적인 성격의 당신, 밤에는 내일 일정을 정리하고 차분히 준비하는 시간으로 활용하세요."
                : "유연한 성격의 당신이지만, 밤에는 하루를 되돌아보며 정리하는 시간을 가져보세요. 새로운 아이디어가 떠오를 수 있습니다."
            }
          },
          userInfo: {
            name: userName,
            mbti: userMbti,
            gender: userGender
          }
        };

      setState({
        data: transformedData,
        loading: false,
        error: null,
        cached: result.cached || false,
        cacheSource: result.cache_source,
        generatedAt: result.generated_at || new Date().toISOString()
      });

      // 캐시 상태에 따른 토스트 메시지
      if (result.cached) {
        toast({
          title: "캐시된 데이터 로드",
          description: `${result.cache_source === 'redis' ? 'Redis' : 'Database'}에서 빠르게 불러왔습니다.`,
          duration: 2000
        });
      } else {
        toast({
          title: "개인화된 운세 생성 완료",
          description: `${transformedData.userInfo.name}님의 사주를 바탕으로 오늘의 운세를 분석했습니다.`,
          duration: 3000
        });
      }

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : '알 수 없는 오류';
      setState(prev => ({ 
        ...prev, 
        loading: false, 
        error: errorMessage 
      }));
      
      toast({
        title: "오류 발생",
        description: errorMessage,
        variant: "destructive"
      });
    }
  };

  // 컴포넌트 마운트 시 바로 데이터 로드
  useEffect(() => {
    loadTodayFortuneData();
  }, []);

  // 로딩 상태
  if (state.loading) {
    return (
      <>
        <AppHeader 
          title="오늘의 운세" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center space-y-4">
            <Loader2 className="w-8 h-8 animate-spin mx-auto" />
            <div className="space-y-2">
              <p className="text-lg font-medium">오늘의 운세 분석 중...</p>
              <p className="text-sm text-muted-foreground">
                AI가 당신의 오늘 운세를 분석하고 있습니다...
              </p>
            </div>
          </div>
        </div>
      </>
    );
  }

  // 에러 상태
  if (state.error) {
    return (
      <>
        <AppHeader 
          title="오늘의 운세" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center space-y-4">
            <div className="text-red-500">
              <svg className="w-12 h-12 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.732-.833-2.5 0L3.34 16.5c-.77.833.192 2.5 1.732 2.5z" />
              </svg>
            </div>
            <div className="space-y-2">
              <p className="text-lg font-medium">데이터 로드 실패</p>
              <p className="text-sm text-muted-foreground">{state.error}</p>
            </div>
            <Button onClick={() => loadTodayFortuneData()} className="mt-4">
              <RefreshCw className="w-4 h-4 mr-2" />
              다시 시도
            </Button>
          </div>
        </div>
      </>
    );
  }

  // 데이터가 없는 경우
  if (!state.data) {
    return (
      <>
        <AppHeader 
          title="오늘의 운세" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center space-y-4">
            <p className="text-lg font-medium">운세 데이터를 찾을 수 없습니다</p>
            <p className="text-sm text-muted-foreground">프로필을 먼저 설정해주세요.</p>
          </div>
        </div>
      </>
    );
  }

  const fortuneData = state.data;
  const todayScore = fortuneData?.todayScore || 55; // 임시 점수 (실제로는 데이터에서 계산)

  return (
    <>
      <AppHeader 
        title="오늘의 운세" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32">
        {/* 탭 메뉴 */}
        <div className="sticky top-16 z-10 bg-background/95 backdrop-blur-sm border-b">
          <div className="flex px-4">
            <button className="px-4 py-3 text-sm font-medium border-b-2 border-yellow-500 text-yellow-600">
              오늘의 운세
            </button>
            <button className="px-4 py-3 text-sm font-medium text-muted-foreground">
              띠 운세
            </button>
            <button className="px-4 py-3 text-sm font-medium text-muted-foreground">
              별자리 운세
            </button>
          </div>
        </div>

        <div className="px-4 pt-6 space-y-6">
          {/* 오늘의 운세 점수 */}
          <div className="text-center py-8">
            <div className="relative inline-block">
              <div className="text-8xl font-bold text-gray-800 relative">
                {todayScore}
                <div className="absolute -top-2 -right-6 w-12 h-12 bg-yellow-400 rounded-full"></div>
              </div>
            </div>
            <p className="text-lg text-muted-foreground mt-4">
              {fortuneData?.generalFortune || "감각을 곤두세울 필요가 있는 하루입니다."}
            </p>
          </div>

          {/* 시간대별 운세 탭 */}
          <div className="flex justify-center space-x-6 py-4 border-b">
            <button 
              onClick={() => setActiveTimeTab('general')}
              className={`text-sm font-medium pb-2 transition-colors ${
                activeTimeTab === 'general' 
                  ? 'text-yellow-600 border-b-2 border-yellow-500' 
                  : 'text-muted-foreground hover:text-yellow-500'
              }`}
            >
              총운
            </button>
            <button 
              onClick={() => setActiveTimeTab('morning')}
              className={`text-sm font-medium pb-2 transition-colors ${
                activeTimeTab === 'morning' 
                  ? 'text-yellow-600 border-b-2 border-yellow-500' 
                  : 'text-muted-foreground hover:text-yellow-500'
              }`}
            >
              오전
            </button>
            <button 
              onClick={() => setActiveTimeTab('afternoon')}
              className={`text-sm font-medium pb-2 transition-colors ${
                activeTimeTab === 'afternoon' 
                  ? 'text-yellow-600 border-b-2 border-yellow-500' 
                  : 'text-muted-foreground hover:text-yellow-500'
              }`}
            >
              오후
            </button>
            <button 
              onClick={() => setActiveTimeTab('night')}
              className={`text-sm font-medium pb-2 transition-colors ${
                activeTimeTab === 'night' 
                  ? 'text-yellow-600 border-b-2 border-yellow-500' 
                  : 'text-muted-foreground hover:text-yellow-500'
              }`}
            >
              밤
            </button>
          </div>

          {/* 탭별 운세 내용 */}
          <div className="space-y-4">
            {activeTimeTab === 'general' && (
              <>
                <h3 className="text-xl font-bold">총운</h3>
                <p className="text-muted-foreground leading-relaxed">
                  감각을 곤두세울 필요가 있는 하루입니다. 어서 싸아올린 모래성이 타인에 의해 하루 아침에 한 줄 모래로 사라질 수 있습니다. 꼼꼼하게 계획하고 설계한 일일지라도 여상치 못한 곳에서 혼선이 발생할 수 있는 날입니다. 특히 뒤는 만남보다 실이 되는 만남이 많으므로 문제에 있어서 스스로의 판단력을 믿고 타인의 의견에 휩쓸리지 않아야 합니다. 특히 평소 믿고 의지하던 관계가 손해를 유발할 수 있으므로 정이 아닌 객관적 시선으로 판단을 내리는 것이 중요합니다. 이 때문에 마음이 복잡하다면 다양한 문화생활을 통해 잠시나마 마음을 비우고 여유를 가질 수 있을 것입니다.
                </p>
              </>
            )}

            {activeTimeTab === 'morning' && fortuneData?.timeBasedFortunes.morning && (
              <>
                <div className="flex items-center justify-between">
                  <h3 className="text-xl font-bold">{fortuneData.timeBasedFortunes.morning.title}</h3>
                  <div className="flex items-center gap-2">
                    <span className="text-2xl font-bold text-green-600">
                      {fortuneData.timeBasedFortunes.morning.score}
                    </span>
                    <span className="text-sm text-muted-foreground">점</span>
                  </div>
                </div>
                <div className="bg-gradient-to-r from-green-50 to-emerald-50 rounded-lg p-4 border border-green-200">
                  <p className="text-muted-foreground leading-relaxed mb-3">
                    {fortuneData.timeBasedFortunes.morning.description}
                  </p>
                  <div className="bg-white rounded-lg p-3 border-l-4 border-green-500">
                    <h4 className="font-medium text-green-700 mb-2">🌅 오전 맞춤 조언</h4>
                    <p className="text-sm text-green-600">
                      {fortuneData.timeBasedFortunes.morning.advice}
                    </p>
                  </div>
                </div>
              </>
            )}

            {activeTimeTab === 'afternoon' && fortuneData?.timeBasedFortunes.afternoon && (
              <>
                <div className="flex items-center justify-between">
                  <h3 className="text-xl font-bold">{fortuneData.timeBasedFortunes.afternoon.title}</h3>
                  <div className="flex items-center gap-2">
                    <span className="text-2xl font-bold text-orange-600">
                      {fortuneData.timeBasedFortunes.afternoon.score}
                    </span>
                    <span className="text-sm text-muted-foreground">점</span>
                  </div>
                </div>
                <div className="bg-gradient-to-r from-orange-50 to-yellow-50 rounded-lg p-4 border border-orange-200">
                  <p className="text-muted-foreground leading-relaxed mb-3">
                    {fortuneData.timeBasedFortunes.afternoon.description}
                  </p>
                  <div className="bg-white rounded-lg p-3 border-l-4 border-orange-500">
                    <h4 className="font-medium text-orange-700 mb-2">☀️ 오후 맞춤 조언</h4>
                    <p className="text-sm text-orange-600">
                      {fortuneData.timeBasedFortunes.afternoon.advice}
                    </p>
                  </div>
                </div>
              </>
            )}

            {activeTimeTab === 'night' && fortuneData?.timeBasedFortunes.night && (
              <>
                <div className="flex items-center justify-between">
                  <h3 className="text-xl font-bold">{fortuneData.timeBasedFortunes.night.title}</h3>
                  <div className="flex items-center gap-2">
                    <span className="text-2xl font-bold text-blue-600">
                      {fortuneData.timeBasedFortunes.night.score}
                    </span>
                    <span className="text-sm text-muted-foreground">점</span>
                  </div>
                </div>
                <div className="bg-gradient-to-r from-blue-50 to-indigo-50 rounded-lg p-4 border border-blue-200">
                  <p className="text-muted-foreground leading-relaxed mb-3">
                    {fortuneData.timeBasedFortunes.night.description}
                  </p>
                  <div className="bg-white rounded-lg p-3 border-l-4 border-blue-500">
                    <h4 className="font-medium text-blue-700 mb-2">🌙 밤 맞춤 조언</h4>
                    <p className="text-sm text-blue-600">
                      {fortuneData.timeBasedFortunes.night.advice}
                    </p>
                  </div>
                </div>
              </>
            )}
          </div>

          {/* 오행 레이더 차트 영역 */}
          <Card>
            <CardContent className="pt-6">
              <div className="relative w-full h-64 flex items-center justify-center">
                <div className="relative w-48 h-48">
                  <svg viewBox="0 0 200 200" className="w-full h-full">
                    {/* 오각형 배경 */}
                    <polygon
                      points="100,20 160,60 140,140 60,140 40,60"
                      fill="rgba(34, 197, 94, 0.1)"
                      stroke="rgba(34, 197, 94, 0.3)"
                      strokeWidth="1"
                    />
                    {/* 실제 데이터 오각형 */}
                    <polygon
                      points="100,40 140,70 120,120 80,120 60,70"
                      fill="rgba(34, 197, 94, 0.3)"
                      stroke="rgb(34, 197, 94)"
                      strokeWidth="2"
                    />
                  </svg>
                  {/* 오행 라벨 */}
                  <div className="absolute top-2 left-1/2 transform -translate-x-1/2 text-xs font-medium">목</div>
                  <div className="absolute top-12 right-2 text-xs font-medium">화</div>
                  <div className="absolute bottom-8 right-8 text-xs font-medium">토</div>
                  <div className="absolute bottom-8 left-8 text-xs font-medium">금</div>
                  <div className="absolute top-12 left-2 text-xs font-medium">수</div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* 일별 운세 그래프 */}
          <Card>
            <CardHeader>
              <CardTitle>일별 운세</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="relative h-32 flex items-end justify-center">
                <svg viewBox="0 0 300 80" className="w-full h-full">
                  <path
                    d="M0,60 Q75,20 150,40 T300,60"
                    fill="none"
                    stroke="rgb(34, 197, 94)"
                    strokeWidth="3"
                  />
                  <circle cx="150" cy="40" r="6" fill="rgb(34, 197, 94)" />
                  <text x="150" y="25" textAnchor="middle" className="text-xs fill-current">55</text>
                </svg>
                <div className="absolute bottom-0 left-0 right-0 flex justify-between px-4 text-xs text-muted-foreground">
                  <span>그제</span>
                  <span>어제</span>
                  <span className="font-medium">오늘</span>
                  <span>내일</span>
                  <span>모레</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* 나도 나를 잘 모르겠을 땐? */}
          <Card className="bg-gradient-to-r from-purple-50 to-pink-50">
            <CardContent className="pt-6">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="font-bold text-lg mb-2">나도 나를 잘 모르겠을 땐?</h3>
                  <p className="text-sm text-muted-foreground">내 사주, 나노데이터 분석!</p>
                </div>
                <div className="text-4xl">🔮</div>
              </div>
              <div className="mt-4 p-4 bg-white rounded-lg flex items-center justify-between">
                <div className="flex items-center space-x-2">
                  <span className="text-sm font-medium">신비로운 사주 세계</span>
                  <span className="text-sm text-muted-foreground">지금 분석받기 ➡️</span>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* 재물운 */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <DollarSign className="w-5 h-5 text-green-500" />
                재물운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground leading-relaxed">
                {fortuneData?.wealthFortune || "태산을 만들기 위한 티끌을 모을 때입니다. 큰 계획없이 소비생활을 지속해왔다면, 이제는 방향을 바꿔야 합니다."}
              </p>
            </CardContent>
          </Card>

          {/* 연애운 */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Heart className="w-5 h-5 text-red-500" />
                연애운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground leading-relaxed">
                {fortuneData?.loveFortune || "가장비에 웃이 젖듯 어느새 상대방에게 폭 빠질 수 있겠습니다. 전혀 생각하지도 않았던 사람이 이성으로 보일 듯 합니다."}
              </p>
            </CardContent>
          </Card>

          {/* 사업운 */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Briefcase className="w-5 h-5 text-blue-500" />
                사업운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground leading-relaxed">
                {fortuneData?.businessFortune || "친절한 모습만 보이는 것이 위험할 수 있습니다. 단호해야 하는 순간에는 당신이 만만치 않다는 것을 보여주는 것이 좋겠습니다."}
              </p>
            </CardContent>
          </Card>

          {/* 건강운 */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Activity className="w-5 h-5 text-orange-500" />
                건강운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground leading-relaxed">
                {fortuneData?.healthFortune || "심신의 기운이 무난한 하루입니다. 건강 문제로 크게 염려해야 하는 부분은 없을 듯 합니다."}
              </p>
            </CardContent>
          </Card>

          {/* 학업운 */}
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <GraduationCap className="w-5 h-5 text-purple-500" />
                학업운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground leading-relaxed">
                {fortuneData?.studyFortune || "잔꾀를 부리면 머지 않아 넘어질 수 밖에 없습니다. 당장 편하고 쉬운 마음에 알맞한 수를 쓴다면 엄는 것 없이 시간만 허비하는 꼴이 됩니다."}
              </p>
            </CardContent>
          </Card>

          {/* 행운을 가져오는 것들 */}
          <Card>
            <CardHeader>
              <CardTitle>행운을 가져오는 것들</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="flex flex-wrap gap-2">
                <Badge variant="secondary">초록색</Badge>
                <Badge variant="secondary">멕시칸요리</Badge>
                <Badge variant="secondary">5,8</Badge>
                <Badge variant="secondary">개띠,선배</Badge>
                <Badge variant="secondary">남서쪽</Badge>
                <Badge variant="secondary">화분</Badge>
              </div>
            </CardContent>
          </Card>

          {/* 행운의 코디 */}
          <Card>
            <CardHeader>
              <CardTitle>행운의 코디</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-sm text-muted-foreground mb-4">
                차분하게 상황을 넘길 수 있는 코디
              </p>
              <p className="text-muted-foreground leading-relaxed">
                차분하게 상황을 모면하고 싶다면, 초록색 가족 가방을 착용해보세요. 초록색은 안정감과 균형을 제공하며, 복잡한 상황에서 감정을 잘 조절하고 냉정함을 유지하게 도와줍니다. 가족 가방은 실용적이면서 세련된 아이템으로 프로페셔널한 이미지를 강화하며 신뢰감을 줍니다. 이 코디는 중요한 결정을 내릴 때 필요한 자신감과 침착함을 불어넣어줍니다. 초록색 가족 가방으로 차분하고 세련된 스타일을 완성하고 상황에 유연하게 대처해보세요!
              </p>
            </CardContent>
          </Card>
        </div>
      </div>
    </>
  );
} 