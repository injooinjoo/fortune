"use client";

import { logger } from '@/lib/logger';
import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import AppHeader from "@/components/AppHeader";
import AdLoadingScreen from "@/components/AdLoadingScreen";
import ProtectedRoute from "@/components/ProtectedRoute";
import { useAuth } from '@/contexts/auth-context';
import { getSupabaseBrowserClient } from '@/lib/supabase-browser';
import { 
  Heart, 
  Star, 
  Sparkles, 
  TrendingUp, 
  Calendar,
  User,
  MessageCircle,
  Gift,
  Coffee,
  MapPin,
  CheckCircle2
} from "lucide-react";

interface LoveFortuneData {
  todayScore: number;
  weeklyScore: number;
  monthlyScore: number;
  summary: string;
  emotionalTagline: string;
  advice: string;
  luckyTime: string;
  luckyPlace: string;
  luckyColor: string;
  compatibility: {
    best: string;
    good: string[];
    avoid: string;
  };
  predictions: {
    today: string;
    thisWeek: string;
    thisMonth: string;
  };
  actionItems: string[];
  soloFortune: {
    newMeetingStars: number;
    newMeetingDetail: string;
    charmAppeal: string;
    personToWatch: string;
  };
  coupleFortune: {
    relationshipStars: number;
    relationshipDetail: string;
    conflictWarning: string;
    relationshipTip: string;
  };
  reunionFortune: {
    reconciliationStars: number;
    reconciliationDetail: string;
    approachAdvice: string;
  };
  luckyBooster: {
    timeDetail: string;
    placeDetail: string;
    colorDetail: string;
  };
  actionMission: {
    action: string;
    meaning: string;
  }[];
  deeperAdvice: string;
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

function LoveFortunePage() {
  const { session } = useAuth();
  const [data, setData] = useState<LoveFortuneData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [showLoadingScreen, setShowLoadingScreen] = useState(true);

  // 별점 렌더링 함수
  const renderStars = (rating: number) => {
    const stars = [];
    for (let i = 1; i <= 5; i++) {
      stars.push(
        <span key={i} className={i <= rating ? "text-yellow-400" : "text-gray-300"}>
          ★
        </span>
      );
    }
    return stars;
  };

  const fetchLoveFortune = async () => {
    try {
      logger.debug('연애운 데이터 요청 시작...');
      
      // Supabase 클라이언트에서 세션 가져오기
      const supabase = getSupabaseBrowserClient();
      const { data: { session } } = await supabase.auth.getSession();
      
      logger.debug('세션 상태:', session ? '로그인됨' : '미로그인');
      if (session) {
        logger.debug('세션 토큰:', session.access_token?.substring(0, 20) + '...');
      }
      
      const response = await fetch('/api/fortune/love', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          ...(session?.access_token && {
            'Authorization': `Bearer ${session.access_token}`
          })
        },
      });

      if (!response.ok) {
        // 네트워크 상태에 따른 친화적인 에러 메시지
        if (response.status === 404) {
          throw new Error('운세 서비스를 찾을 수 없습니다. 잠시 후 다시 시도해주세요.');
        } else if (response.status === 500) {
          throw new Error('서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.');
        } else if (response.status === 429) {
          throw new Error('너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요.');
        } else {
          throw new Error('운세를 불러오는 중 문제가 발생했습니다.');
        }
      }

      const result = await response.json();
      logger.debug('연애운 API 응답:', result);
      
      if (!result.success) {
        throw new Error(result.error || '운세 생성에 실패했습니다. 다시 시도해주세요.');
      }

      // API 응답을 LoveFortuneData 형식으로 변환
      const loveData: LoveFortuneData = {
        todayScore: result.overall_score || result.love_score || 75,
        weeklyScore: result.weekly_score || 70,
        monthlyScore: result.monthly_score || 80,
        summary: result.summary || '연애운이 상승세를 보이고 있습니다.',
        emotionalTagline: result.emotional_tagline || '진심이 이끄는 설레는 하루',
        advice: result.advice || '진정성 있는 마음으로 상대방에게 다가가세요.',
        luckyTime: result.lucky_time || '오후 3시 ~ 6시',
        luckyPlace: result.lucky_place || '카페, 공원',
        luckyColor: result.lucky_color || '#FF69B4',
        compatibility: {
          best: result.compatibility?.best || '물병자리',
          good: result.compatibility?.good || ['쌍둥이자리', '천칭자리'],
          avoid: result.compatibility?.avoid || '전갈자리'
        },
        predictions: {
          today: result.predictions?.today || '좋은 만남의 기회가 있을 것입니다.',
          thisWeek: result.predictions?.this_week || '특별한 인연을 만날 수 있습니다.',
          thisMonth: result.predictions?.this_month || '중요한 결정을 내리게 될 것입니다.'
        },
        actionItems: result.action_items || [
          '적극적인 자세로 임하기',
          '새로운 활동에 참여하기',
          '진솔한 대화 나누기'
        ],
        soloFortune: {
          newMeetingStars: result.solo_fortune?.new_meeting_stars || 4,
          newMeetingDetail: result.solo_fortune?.new_meeting_detail || '새로운 만남의 기회가 다가오고 있습니다.',
          charmAppeal: result.solo_fortune?.charm_appeal || '자연스러운 매력을 발산해보세요.',
          personToWatch: result.solo_fortune?.person_to_watch || '따뜻한 미소를 가진 사람에게 주목하세요.'
        },
        coupleFortune: {
          relationshipStars: result.couple_fortune?.relationship_stars || 4,
          relationshipDetail: result.couple_fortune?.relationship_detail || '안정적인 관계가 유지되고 있습니다.',
          conflictWarning: result.couple_fortune?.conflict_warning || '작은 오해가 생길 수 있으니 소통을 더욱 늘려보세요.',
          relationshipTip: result.couple_fortune?.relationship_tip || '함께하는 시간을 더욱 의미있게 만들어보세요.'
        },
        reunionFortune: {
          reconciliationStars: result.reunion_fortune?.reconciliation_stars || 3,
          reconciliationDetail: result.reunion_fortune?.reconciliation_detail || '과거의 인연과 다시 연결될 기회가 있습니다.',
          approachAdvice: result.reunion_fortune?.approach_advice || '진솔한 마음으로 천천히 다가가보세요.'
        },
        luckyBooster: {
          timeDetail: result.lucky_booster?.time_detail || '이 시간에 연락하면 좋은 반응을 얻을 수 있어요!',
          placeDetail: result.lucky_booster?.place_detail || '편안하고 자연스러운 대화가 가능한 곳이에요.',
          colorDetail: result.lucky_booster?.color_detail || '따뜻하고 매력적인 분위기를 연출해줍니다.'
        },
        actionMission: result.action_mission || [
          {
            action: '새로운 활동에 참여하기',
            meaning: '예상치 못한 기회가 숨어있어요'
          },
          {
            action: '진솔한 대화 나누기',
            meaning: '마음의 거리가 가까워져요'
          },
          {
            action: '나를 위한 작은 선물 사기',
            meaning: '자존감이 가장 강력한 매력이에요!'
          }
        ],
        deeperAdvice: result.deeper_advice || '오늘은 자신을 사랑하는 마음에서 시작하여 진정성 있는 인연을 만들어가는 날입니다. 스스로를 아끼는 마음이 좋은 사람들을 끌어당기는 가장 큰 힘이 됩니다.'
      };

      logger.debug('연애운 데이터 설정 완료:', loveData);
      return loveData;
      
    } catch (err) {
      logger.error('연애운 데이터 로딩 실패:', err);
      throw err;
    }
  };

  // 로딩 스크린 표시
  if (showLoadingScreen) {
    return (
      <AdLoadingScreen
        fortuneType="love"
        fortuneTitle="연애운"
        fetchData={fetchLoveFortune}
        onComplete={(fetchedData) => {
          setShowLoadingScreen(false);
          if (fetchedData) {
            setData(fetchedData);
          }
        }}
        onSkip={() => {
          // 프리미엄 페이지로 이동
          window.location.href = '/premium';
        }}
        isPremium={false}
      />
    );
  }


  if (error) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-rose-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
        <AppHeader 
          title="연애운" 
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <motion.div 
          className="flex items-center justify-center min-h-[60vh]"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
        >
          <Card className="max-w-md w-full mx-4 shadow-lg">
            <CardContent className="text-center space-y-6 p-8">
              <motion.div
                animate={{ scale: [1, 1.1, 1] }}
                transition={{ duration: 2, repeat: Infinity }}
              >
                <Heart className="w-20 h-20 text-pink-500 mx-auto mb-4" />
              </motion.div>
              
              <div className="space-y-3">
                <h2 className="text-2xl font-bold text-gray-900 dark:text-gray-100">
                  잠시만 기다려주세요 💕
                </h2>
                <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                  {error}
                </p>
              </div>
              
              <div className="space-y-3 pt-4">
                <Button 
                  onClick={() => window.location.reload()}
                  className="w-full bg-gradient-to-r from-pink-500 to-rose-500 hover:from-pink-600 hover:to-rose-600 text-white font-medium py-3"
                >
                  <Sparkles className="w-4 h-4 mr-2" />
                  다시 시도하기
                </Button>
                
                <Button 
                  variant="outline"
                  onClick={() => window.history.back()}
                  className="w-full border-pink-300 text-pink-600 hover:bg-pink-50"
                >
                  이전 페이지로 돌아가기
                </Button>
              </div>
              
              <p className="text-sm text-gray-500 dark:text-gray-400 pt-4">
                계속 문제가 발생한다면 잠시 후 다시 시도해주세요
              </p>
            </CardContent>
          </Card>
        </motion.div>
      </div>
    );
  }

  if (!data) return null;

  return (
    <div className="min-h-screen bg-gradient-to-br from-rose-50 via-white to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
      <AppHeader 
        title="연애운" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div 
        className="pb-32 px-4 space-y-6 pt-4"
        initial="hidden"
        animate="visible"
        variants={containerVariants}
      >
        {/* 💖 오늘의 연애 지수 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-pink-50 to-red-50 dark:from-pink-900/30 dark:to-red-900/30 border-pink-200 dark:border-pink-700">
            <CardHeader className="text-center">
              <div className="flex items-center justify-center gap-2 mb-2">
                <Heart className="w-6 h-6 text-pink-600 dark:text-pink-400" />
                <CardTitle className="text-xl text-pink-800 dark:text-pink-200">💖 오늘의 연애 지수</CardTitle>
              </div>
              <motion.div
                className="text-4xl font-bold text-pink-600 dark:text-pink-400"
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.5, type: "spring", stiffness: 200 }}
              >
                {data.todayScore}점
              </motion.div>
              <p className="text-lg text-pink-700 dark:text-pink-300 mt-2 font-medium">
                {data.emotionalTagline}
              </p>
            </CardHeader>
          </Card>
        </motion.div>


        {/* 📱 솔로를 위한 조언 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 border-blue-200 dark:border-blue-800">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-blue-800 dark:text-blue-200">
                <Sparkles className="w-5 h-5" />
                📱 솔로를 위한 조언
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <h4 className="font-semibold text-sm text-blue-700 dark:text-blue-300 mb-2">✨ 새로운 만남 운: {renderStars(data.soloFortune.newMeetingStars)}</h4>
                <p className="text-sm text-blue-600 dark:text-blue-300 leading-relaxed bg-blue-50 dark:bg-blue-900/20 p-3 rounded-lg">
                  {data.soloFortune.newMeetingDetail}
                </p>
              </div>
              <div>
                <h4 className="font-semibold text-sm text-blue-700 dark:text-blue-300 mb-2">🎯 매력 어필 포인트:</h4>
                <p className="text-sm text-blue-600 dark:text-blue-300 leading-relaxed bg-blue-50 dark:bg-blue-900/20 p-3 rounded-lg">
                  {data.soloFortune.charmAppeal}
                </p>
              </div>
              <div>
                <h4 className="font-semibold text-sm text-blue-700 dark:text-blue-300 mb-2">🔍 주목! 이런 사람:</h4>
                <p className="text-sm text-blue-600 dark:text-blue-300 leading-relaxed bg-blue-50 dark:bg-blue-900/20 p-3 rounded-lg">
                  {data.soloFortune.personToWatch}
                </p>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 💑 커플을 위한 조언 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-rose-50 to-pink-50 dark:from-rose-900/20 dark:to-pink-900/20 border-rose-200 dark:border-rose-800">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-rose-800 dark:text-rose-200">
                <Heart className="w-5 h-5" />
                💑 커플을 위한 조언
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <h4 className="font-semibold text-sm text-rose-700 dark:text-rose-300 mb-2">💞 애정 전선: {renderStars(data.coupleFortune.relationshipStars)}</h4>
                <p className="text-sm text-rose-600 dark:text-rose-300 leading-relaxed bg-rose-50 dark:bg-rose-900/20 p-3 rounded-lg">
                  {data.coupleFortune.relationshipDetail}
                </p>
              </div>
              <div>
                <h4 className="font-semibold text-sm text-rose-700 dark:text-rose-300 mb-2">🚨 갈등 주의보:</h4>
                <p className="text-sm text-rose-600 dark:text-rose-300 leading-relaxed bg-rose-50 dark:bg-rose-900/20 p-3 rounded-lg">
                  {data.coupleFortune.conflictWarning}
                </p>
              </div>
              <div>
                <h4 className="font-semibold text-sm text-rose-700 dark:text-rose-300 mb-2">💡 관계 플러스 팁:</h4>
                <p className="text-sm text-rose-600 dark:text-rose-300 leading-relaxed bg-rose-50 dark:bg-rose-900/20 p-3 rounded-lg">
                  {data.coupleFortune.relationshipTip}
                </p>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 💫 재회·썸을 위한 조언 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-purple-50 to-violet-50 dark:from-purple-900/20 dark:to-violet-900/20 border-purple-200 dark:border-purple-800">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-purple-800 dark:text-purple-200">
                <Sparkles className="w-5 h-5" />
                💫 재회·썸을 위한 조언
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div>
                <h4 className="font-semibold text-sm text-purple-700 dark:text-purple-300 mb-2">💫 재회/설레임 운: {renderStars(data.reunionFortune.reconciliationStars)}</h4>
                <p className="text-sm text-purple-600 dark:text-purple-300 leading-relaxed bg-purple-50 dark:bg-purple-900/20 p-3 rounded-lg">
                  {data.reunionFortune.reconciliationDetail}
                </p>
              </div>
              <div>
                <h4 className="font-semibold text-sm text-purple-700 dark:text-purple-300 mb-2">💝 어프로치 조언:</h4>
                <p className="text-sm text-purple-600 dark:text-purple-300 leading-relaxed bg-purple-50 dark:bg-purple-900/20 p-3 rounded-lg">
                  {data.reunionFortune.approachAdvice}
                </p>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* ✨ 오늘의 행운 부스터 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-yellow-50 to-orange-50 dark:from-yellow-900/20 dark:to-orange-900/20 border-yellow-200 dark:border-yellow-800">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-yellow-800 dark:text-yellow-200">
                <Star className="w-5 h-5" />
                ✨ 오늘의 행운 부스터 (Lucky Booster)
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid gap-3">
                <div className="flex items-center gap-3">
                  <Calendar className="w-5 h-5 text-yellow-600 dark:text-yellow-400" />
                  <div>
                    <div className="text-sm font-medium text-yellow-700 dark:text-yellow-300">시간: {data.luckyTime}</div>
                    <div className="text-xs text-yellow-600 dark:text-yellow-400">({data.luckyBooster.timeDetail})</div>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <MapPin className="w-5 h-5 text-yellow-600 dark:text-yellow-400" />
                  <div>
                    <div className="text-sm font-medium text-yellow-700 dark:text-yellow-300">장소: {data.luckyPlace}</div>
                    <div className="text-xs text-yellow-600 dark:text-yellow-400">({data.luckyBooster.placeDetail})</div>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-5 h-5 rounded-full border-2 border-yellow-300 dark:border-yellow-600" style={{ backgroundColor: data.luckyColor }} />
                  <div>
                    <div className="text-sm font-medium text-yellow-700 dark:text-yellow-300">색상: 핑크 계열</div>
                    <div className="text-xs text-yellow-600 dark:text-yellow-400">({data.luckyBooster.colorDetail})</div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 🎯 오늘의 실천 미션 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-green-50 to-emerald-50 dark:from-green-900/20 dark:to-emerald-900/20 border-green-200 dark:border-green-800">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-green-800 dark:text-green-200">
                <CheckCircle2 className="w-5 h-5" />
                🎯 오늘의 실천 미션 (Action Mission)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {data.actionMission.map((mission, index) => (
                  <motion.div
                    key={index}
                    className="flex items-start gap-3 p-3 bg-green-50 dark:bg-green-900/20 rounded-lg"
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.8 + index * 0.1 }}
                  >
                    <div className="w-6 h-6 bg-green-100 dark:bg-green-900/30 rounded-sm flex items-center justify-center mt-0.5">
                      <span className="text-xs font-medium text-green-600 dark:text-green-400">☐</span>
                    </div>
                    <div className="flex-1">
                      <div className="text-sm font-medium text-green-700 dark:text-green-300">{mission.action}</div>
                      <div className="text-xs text-green-600 dark:text-green-400 mt-1">({mission.meaning})</div>
                    </div>
                  </motion.div>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 🔮 심층 심리 조언 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-br from-indigo-50 to-purple-50 dark:from-indigo-900/20 dark:to-purple-900/20 border-indigo-200 dark:border-indigo-800">
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-indigo-800 dark:text-indigo-200">
                <MessageCircle className="w-5 h-5" />
                🔮 심층 심리 조언 (Deeper Advice)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-indigo-700 dark:text-indigo-300 leading-relaxed">
                {data.deeperAdvice}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 액션 버튼 */}
        <motion.div 
          variants={itemVariants}
          className="sticky bottom-16 left-0 right-0 bg-background dark:bg-gray-900 border-t dark:border-gray-700 p-4 flex gap-2"
        >
          <Button className="flex-1 bg-pink-600 hover:bg-pink-700 dark:bg-pink-600 dark:hover:bg-pink-700">
            <Heart className="w-4 h-4 mr-2" />
            결과 저장하기
          </Button>
          <Button variant="outline" className="flex-1 border-pink-300 text-pink-600 hover:bg-pink-50 dark:border-pink-600 dark:text-pink-400 dark:hover:bg-pink-900/20">
            공유하기
          </Button>
        </motion.div>
      </motion.div>
    </div>
  );
}

export default function LoveFortunePageWrapper() {
  return (
    <ProtectedRoute>
      <LoveFortunePage />
    </ProtectedRoute>
  );
} 