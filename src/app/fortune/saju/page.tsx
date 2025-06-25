"use client";

import React, { useState, useEffect } from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Droplet, Loader2, RefreshCw, Star, TrendingUp, User, Zap } from "lucide-react";
import AppHeader from "@/components/AppHeader";
import { useToast } from "@/hooks/use-toast";
import {
  RadarChart,
  PolarGrid,
  PolarAngleAxis,
  PolarRadiusAxis,
  Radar,
  ResponsiveContainer,
} from "recharts";

// 새로운 운세 시스템 타입 import
import { LifeProfileData, FortuneResponse } from "@/lib/types/fortune-system";

interface SajuPageState {
  data: LifeProfileData | null;
  loading: boolean;
  error: string | null;
  cached: boolean;
  cacheSource?: 'redis' | 'database' | 'fresh';
  generatedAt: string | null;
}

export default function SajuAnalysisPage() {
  const [state, setState] = useState<SajuPageState>({
    data: null,
    loading: true,
    error: null,
    cached: false,
    generatedAt: null
  });
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const { toast } = useToast();

  // 사주 데이터 로드
  const loadSajuData = async (forceRefresh = false) => {
    try {
      setState(prev => ({ ...prev, loading: true, error: null }));

      const response = await fetch('/api/fortune/saju', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        },
        cache: forceRefresh ? 'no-cache' : 'default'
      });

      const result: FortuneResponse<LifeProfileData> = await response.json();

      if (!result.success) {
        // 프로필이 필요한 경우 온보딩으로 리다이렉트
        if (result.error === 'PROFILE_REQUIRED') {
          toast({
            title: "프로필 정보 필요",
            description: "사주팔자를 보려면 먼저 프로필을 설정해주세요.",
            variant: "destructive",
          });
          setTimeout(() => {
            window.location.href = (result as any).redirect || '/onboarding/profile';
          }, 1500);
          return;
        }
        throw new Error(result.error || '데이터 로드 실패');
      }

      setState({
        data: result.data || null,
        loading: false,
        error: null,
        cached: result.cached,
        cacheSource: result.cache_source,
        generatedAt: result.generated_at
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
          title: "새로운 사주 생성 완료",
          description: "AI가 당신만의 사주를 새롭게 분석했습니다.",
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

  // 컴포넌트 마운트 시 바로 데이터 로드 (프로필 체크는 API에서 처리)
  useEffect(() => {
    loadSajuData();
  }, []);

  // 로딩 상태
  if (state.loading) {
    return (
      <>
        <AppHeader 
          title="사주팔자" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center space-y-4">
            <Loader2 className="w-8 h-8 animate-spin mx-auto" />
            <div className="space-y-2">
              <p className="text-lg font-medium">사주팔자 분석 중...</p>
              <p className="text-sm text-muted-foreground">
                {state.cached ? '캐시된 데이터를 불러오는 중...' : 'AI가 당신의 운명을 분석하고 있습니다...'}
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
          title="사주팔자" 
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
            <Button onClick={() => loadSajuData()} className="mt-4">
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
          title="사주팔자" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-center space-y-4">
            <p className="text-lg font-medium">사주 데이터를 찾을 수 없습니다</p>
            <p className="text-sm text-muted-foreground">프로필을 먼저 설정해주세요.</p>
          </div>
        </div>
      </>
    );
  }

  const sajuData = state.data.saju;

  return (
    <>
      <AppHeader 
        title="사주팔자" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <div className="pb-32 min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-yellow-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700">
        {/* 상태 헤더 */}
        <div className="sticky top-16 z-10 bg-background/95 backdrop-blur-sm border-b">
          <div className="px-4 py-3 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Badge variant={state.cached ? "secondary" : "default"}>
                {state.cached ? `캐시됨 (${state.cacheSource})` : '새로 생성됨'}
              </Badge>
              {state.generatedAt && (
                <span className="text-xs text-muted-foreground">
                  {new Date(state.generatedAt).toLocaleString()}
                </span>
              )}
            </div>
            <Button 
              onClick={() => loadSajuData(true)} 
              variant="outline" 
              size="sm"
              disabled={state.loading}
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${state.loading ? 'animate-spin' : ''}`} />
              새로고침
            </Button>
          </div>
        </div>

        <div className="space-y-6 px-4 pt-6">
          {/* 성격 요약 */}
          <div className="bg-gradient-to-r from-blue-500/10 to-purple-500/10 rounded-2xl p-6 text-center">
            <div className="flex items-center justify-center gap-2 mb-3">
              <Star className="w-6 h-6 text-yellow-500" />
              <h2 className="text-xl font-bold">당신의 성격</h2>
            </div>
            <p className="text-lg text-muted-foreground leading-relaxed">
              {sajuData.personality_analysis}
            </p>
          </div>

          {/* 총운 */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="w-5 h-5 text-green-500" />
                총운
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-muted-foreground leading-relaxed">
                {sajuData.life_fortune}
              </p>
            </CardContent>
          </Card>

          {/* 기본정보 */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="flex items-center gap-2">
                <User className="w-5 h-5 text-blue-500" />
                기본정보
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-4">
                <div className="bg-muted/50 rounded-lg p-3">
                  <p className="text-sm text-muted-foreground mb-1">생년</p>
                  <p className="font-semibold">{sajuData.basic_info.birth_year}</p>
                </div>
                <div className="bg-muted/50 rounded-lg p-3">
                  <p className="text-sm text-muted-foreground mb-1">생월</p>
                  <p className="font-semibold">{sajuData.basic_info.birth_month}</p>
                </div>
                <div className="bg-muted/50 rounded-lg p-3">
                  <p className="text-sm text-muted-foreground mb-1">생일</p>
                  <p className="font-semibold">{sajuData.basic_info.birth_day}</p>
                </div>
                {sajuData.basic_info.birth_time && (
                  <div className="bg-muted/50 rounded-lg p-3">
                    <p className="text-sm text-muted-foreground mb-1">생시</p>
                    <p className="font-semibold">{sajuData.basic_info.birth_time}</p>
                  </div>
                )}
              </div>
            </CardContent>
          </Card>

          {/* 사주팔자 */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="flex items-center gap-2">
                <Zap className="w-5 h-5 text-purple-500" />
                사주팔자
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-6">
              {/* 천간 */}
              <div>
                <h4 className="text-sm font-medium text-muted-foreground mb-3 text-center">천간 (天干)</h4>
                <div className="grid grid-cols-4 gap-3">
                  <div className="bg-gradient-to-b from-sky-100 to-sky-50 dark:from-sky-900/50 dark:to-sky-800/30 rounded-xl p-4 text-center border border-sky-200 dark:border-sky-700">
                    <p className="text-2xl font-bold text-sky-700 dark:text-sky-300 mb-1">
                      {sajuData.four_pillars.year_pillar.heavenly}
                    </p>
                    <p className="text-xs text-muted-foreground">년주</p>
                  </div>
                  <div className="bg-gradient-to-b from-emerald-100 to-emerald-50 dark:from-emerald-900/50 dark:to-emerald-800/30 rounded-xl p-4 text-center border border-emerald-200 dark:border-emerald-700">
                    <p className="text-2xl font-bold text-emerald-700 dark:text-emerald-300 mb-1">
                      {sajuData.four_pillars.month_pillar.heavenly}
                    </p>
                    <p className="text-xs text-muted-foreground">월주</p>
                  </div>
                  <div className="bg-gradient-to-b from-orange-100 to-orange-50 dark:from-orange-900/50 dark:to-orange-800/30 rounded-xl p-4 text-center border border-orange-200 dark:border-orange-700">
                    <p className="text-2xl font-bold text-orange-700 dark:text-orange-300 mb-1">
                      {sajuData.four_pillars.day_pillar.heavenly}
                    </p>
                    <p className="text-xs text-muted-foreground">일주</p>
                  </div>
                  <div className="bg-gradient-to-b from-violet-100 to-violet-50 dark:from-violet-900/50 dark:to-violet-800/30 rounded-xl p-4 text-center border border-violet-200 dark:border-violet-700">
                    <p className="text-2xl font-bold text-violet-700 dark:text-violet-300 mb-1">
                      {sajuData.four_pillars.time_pillar?.heavenly || '?'}
                    </p>
                    <p className="text-xs text-muted-foreground">시주</p>
                  </div>
                </div>
              </div>

              {/* 지지 */}
              <div>
                <h4 className="text-sm font-medium text-muted-foreground mb-3 text-center">지지 (地支)</h4>
                <div className="grid grid-cols-4 gap-3">
                  <div className="bg-gradient-to-b from-rose-100 to-rose-50 dark:from-rose-900/50 dark:to-rose-800/30 rounded-xl p-4 text-center border border-rose-200 dark:border-rose-700">
                    <p className="text-2xl font-bold text-rose-700 dark:text-rose-300 mb-1">
                      {sajuData.four_pillars.year_pillar.earthly}
                    </p>
                    <p className="text-xs text-muted-foreground">년주</p>
                  </div>
                  <div className="bg-gradient-to-b from-teal-100 to-teal-50 dark:from-teal-900/50 dark:to-teal-800/30 rounded-xl p-4 text-center border border-teal-200 dark:border-teal-700">
                    <p className="text-2xl font-bold text-teal-700 dark:text-teal-300 mb-1">
                      {sajuData.four_pillars.month_pillar.earthly}
                    </p>
                    <p className="text-xs text-muted-foreground">월주</p>
                  </div>
                  <div className="bg-gradient-to-b from-amber-100 to-amber-50 dark:from-amber-900/50 dark:to-amber-800/30 rounded-xl p-4 text-center border border-amber-200 dark:border-amber-700">
                    <p className="text-2xl font-bold text-amber-700 dark:text-amber-300 mb-1">
                      {sajuData.four_pillars.day_pillar.earthly}
                    </p>
                    <p className="text-xs text-muted-foreground">일주</p>
                  </div>
                  <div className="bg-gradient-to-b from-indigo-100 to-indigo-50 dark:from-indigo-900/50 dark:to-indigo-800/30 rounded-xl p-4 text-center border border-indigo-200 dark:border-indigo-700">
                    <p className="text-2xl font-bold text-indigo-700 dark:text-indigo-300 mb-1">
                      {sajuData.four_pillars.time_pillar?.earthly || '?'}
                    </p>
                    <p className="text-xs text-muted-foreground">시주</p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* 오행분석 */}
          <Card>
            <CardHeader className="pb-3">
              <CardTitle className="flex items-center gap-2">
                <Droplet className="w-5 h-5 text-cyan-500" />
                오행분석
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {/* 오행 점수 차트 */}
                <div className="h-64">
                  <ResponsiveContainer width="100%" height="100%">
                    <RadarChart data={[
                      { element: '목', score: sajuData.five_elements.wood, fullMark: 100 },
                      { element: '화', score: sajuData.five_elements.fire, fullMark: 100 },
                      { element: '토', score: sajuData.five_elements.earth, fullMark: 100 },
                      { element: '금', score: sajuData.five_elements.metal, fullMark: 100 },
                      { element: '수', score: sajuData.five_elements.water, fullMark: 100 }
                    ]}>
                      <PolarGrid />
                      <PolarAngleAxis dataKey="element" />
                      <PolarRadiusAxis angle={90} domain={[0, 100]} />
                      <Radar
                        name="오행"
                        dataKey="score"
                        stroke="#8884d8"
                        fill="#8884d8"
                        fillOpacity={0.6}
                      />
                    </RadarChart>
                  </ResponsiveContainer>
                </div>

                {/* 오행 상세 */}
                <div className="grid grid-cols-5 gap-2">
                  <div className="text-center p-3 bg-green-50 dark:bg-green-900/30 rounded-lg">
                    <p className="text-sm font-medium text-green-700 dark:text-green-300">목</p>
                    <p className="text-lg font-bold">{sajuData.five_elements.wood}</p>
                  </div>
                  <div className="text-center p-3 bg-red-50 dark:bg-red-900/30 rounded-lg">
                    <p className="text-sm font-medium text-red-700 dark:text-red-300">화</p>
                    <p className="text-lg font-bold">{sajuData.five_elements.fire}</p>
                  </div>
                  <div className="text-center p-3 bg-yellow-50 dark:bg-yellow-900/30 rounded-lg">
                    <p className="text-sm font-medium text-yellow-700 dark:text-yellow-300">토</p>
                    <p className="text-lg font-bold">{sajuData.five_elements.earth}</p>
                  </div>
                  <div className="text-center p-3 bg-gray-50 dark:bg-gray-800 rounded-lg">
                    <p className="text-sm font-medium text-gray-700 dark:text-gray-300">금</p>
                    <p className="text-lg font-bold">{sajuData.five_elements.metal}</p>
                  </div>
                  <div className="text-center p-3 bg-blue-50 dark:bg-blue-900/30 rounded-lg">
                    <p className="text-sm font-medium text-blue-700 dark:text-blue-300">수</p>
                    <p className="text-lg font-bold">{sajuData.five_elements.water}</p>
                  </div>
                </div>

                <div className="bg-muted/50 rounded-lg p-4">
                  <h4 className="font-medium mb-2">오행 특징</h4>
                  <p className="text-sm text-muted-foreground leading-relaxed">
                    목(木) 기운이 강하여 성장과 발전의 에너지를 가지고 있습니다. 창의적이고 진취적인 성향이 있으며, 새로운 도전을 즐깁니다.
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* 오늘의 운세 보기 버튼 */}
          <Card className="bg-gradient-to-r from-yellow-50 to-orange-50 border-yellow-200">
            <CardContent className="pt-6">
              <div className="text-center space-y-4">
                <div className="flex items-center justify-center gap-2">
                  <Star className="w-6 h-6 text-yellow-500" />
                  <h3 className="text-xl font-bold">오늘의 사주팔자 운세</h3>
                </div>
                <p className="text-muted-foreground">
                  당신의 사주를 바탕으로 한 오늘의 상세 운세를 확인해보세요
                </p>
                <Button 
                  onClick={() => window.location.href = '/fortune/saju/result'}
                  className="w-full bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 text-white font-medium py-3"
                  size="lg"
                >
                  <TrendingUp className="w-5 h-5 mr-2" />
                  오늘의 운세 보기
                </Button>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </>
  );
}

