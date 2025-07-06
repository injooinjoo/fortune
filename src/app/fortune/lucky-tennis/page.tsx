"use client";

import { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import { KoreanDatePicker } from "@/components/ui/korean-date-picker";
import AppHeader from "@/components/AppHeader";
import { 
  Zap, 
  Trophy, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Users,
  Target,
  TrendingUp,
  Shield,
  Crown,
  Calendar,
  Clock,
  Award,
  Flag,
  PlayCircle,
  BarChart3,
  Activity,
  Eye,
  ThumbsUp,
  Heart,
  MapPin,
  Timer,
  Crosshair,
  Flame
} from "lucide-react";

interface TennisInfo {
  name: string;
  birth_date: string;
  dominant_hand: string;
  playing_style: string;
  favorite_surface: string;
  playing_experience: string;
  game_frequency: string;
  tennis_skills: string[];
  lucky_number: string;
  current_goal: string;
  special_memory: string;
}

interface TennisFortune {
  overall_luck: number;
  serve_luck: number;
  return_luck: number;
  volley_luck: number;
  mental_luck: number;
  analysis: {
    strength: string;
    weakness: string;
    opportunity: string;
    challenge: string;
  };
  lucky_racket_tension: string;
  lucky_court_position: string;
  lucky_match_time: string;
  lucky_tournament: string;
  recommendations: {
    training_tips: string[];
    match_strategies: string[];
    equipment_advice: string[];
    mental_preparation: string[];
  };
  future_predictions: {
    this_week: string;
    this_month: string;
    this_season: string;
  };
  compatibility: {
    best_doubles_partner: string;
    ideal_coach_style: string;
    perfect_opponent: string;
  };
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

const playingStyles = [
  "공격적 베이스라이너", "수비적 베이스라이너", "서브 앤 발리", 
  "올코트 플레이어", "카운터 펀처", "파워 플레이어", "기술적 플레이어"
];

const surfaces = [
  "하드코트", "클레이코트", "잔디코트", "인도어 하드", "실외 하드", "상관없음"
];

const skillAreas = [
  "서브", "리턴", "포핸드", "백핸드", "발리", "스매시",
  "드롭샷", "로브", "어프로치샷", "패싱샷", "풋워크", "전술적 사고"
];

const tournaments = [
  "윔블던", "프랑스오픈", "US오픈", "호주오픈", "ATP 마스터즈", 
  "WTA 프리미어", "로컬 토너먼트", "클럽 대회"
];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "에이스급 운";
  if (score >= 70) return "윈너샷 운";
  if (score >= 55) return "안정적인 운";
  return "더블폴트 주의";
};

export default function LuckyTennisPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<TennisInfo>({
    name: '',
    birth_date: '',
    dominant_hand: '',
    playing_style: '',
    favorite_surface: '',
    playing_experience: '',
    game_frequency: '',
    tennis_skills: [],
    lucky_number: '',
    current_goal: '',
    special_memory: ''
  });
  const [result, setResult] = useState<TennisFortune | null>(null);

  const analyzeTennisFortune = async (): Promise<TennisFortune> => {
    try {
      const response = await fetch('/api/fortune/lucky-tennis', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error('API 호출 실패');
      }

      return await response.json();
    } catch (error) {
      console.error('테니스 운세 분석 오류:', error);
      
      // 개선된 백업 로직 (개인화된)
      const birthYear = formData.birth_date ? parseInt(formData.birth_date.substring(0, 4)) : new Date().getFullYear() - 25;
      const birthMonth = formData.birth_date ? parseInt(formData.birth_date.substring(5, 7)) : 6;
      const birthDay = formData.birth_date ? parseInt(formData.birth_date.substring(8, 10)) : 15;
      
      let baseScore = ((birthYear + birthMonth + birthDay) % 30) + 65;
      
      // 경험별 보너스
      if (formData.playing_experience.includes('10년 이상')) baseScore += 15;
      else if (formData.playing_experience.includes('5-10년')) baseScore += 10;
      
      // 기술 다양성 보너스
      if (formData.tennis_skills && formData.tennis_skills.length >= 6) baseScore += 10;
      
      // 왼손잡이 보너스
      if (formData.dominant_hand === 'left') baseScore += 8;
      
      baseScore = Math.max(50, Math.min(95, baseScore));

      return {
        overall_luck: baseScore,
        serve_luck: Math.max(45, Math.min(100, baseScore + 5)),
        return_luck: Math.max(40, Math.min(95, baseScore)),
        volley_luck: Math.max(50, Math.min(100, baseScore + 3)),
        mental_luck: Math.max(55, Math.min(95, baseScore + 3)),
        analysis: {
          strength: "강한 집중력과 정확한 타이밍으로 중요한 순간에 실력을 발휘하는 능력이 뛰어납니다.",
          weakness: "때로는 완벽을 추구하다가 긴장하여 실수할 수 있으니 마음의 여유가 필요합니다.",
          opportunity: "꾸준한 연습과 전략적 사고로 상대방의 약점을 찾아내는 능력이 있습니다.",
          challenge: "새로운 기술 습득에 시간이 걸리지만, 인내심을 가지고 연습하면 반드시 개선됩니다."
        },
        lucky_racket_tension: `${48 + (birthDay % 11)}파운드`,
        lucky_court_position: ["베이스라인", "네트 앞", "서비스 라인", "코트 중앙"][birthMonth % 4],
        lucky_match_time: ["오전 10시", "오후 2시", "오후 4시", "오후 6시"][birthDay % 4],
        lucky_tournament: tournaments[baseScore % tournaments.length],
        recommendations: {
          training_tips: [
            formData.tennis_skills?.includes('서브') ? 
              "서브 기술을 더욱 발전시켜 에이스 확률을 높이세요" :
              "매일 15분씩 서브 연습으로 정확도를 높이세요",
            "풋워크 훈련으로 코트 커버리지를 개선하세요",
            formData.dominant_hand === 'left' ?
              "왼손잡이의 장점을 살린 각도 공격을 연습하세요" :
              "백핸드 슬라이스 연습으로 다양성을 키우세요",
            "체력 훈련으로 긴 경기에 대비하세요",
            "정확한 타겟 연습으로 컨트롤을 향상시키세요"
          ],
          match_strategies: [
            "상대방의 약한 쪽을 집중적으로 공략하세요",
            formData.playing_style?.includes('공격') ?
              "공격적인 플레이로 상대방에게 압박을 가하세요" :
              "서브의 방향과 스피드를 다양하게 변화시키세요",
            "중요한 포인트에서는 안전한 플레이를 선택하세요",
            "상대방의 리듬을 깨뜨리는 전술을 사용하세요",
            "자신만의 경기 루틴을 만들어 일관성을 유지하세요"
          ],
          equipment_advice: [
            "자신의 플레이 스타일에 맞는 라켓을 선택하세요",
            "그립 사이즈를 정확히 맞춰 부상을 예방하세요",
            formData.favorite_surface ?
              `${formData.favorite_surface}에 최적화된 신발을 선택하세요` :
              "코트 표면에 적합한 신발을 착용하세요",
            "스트링 텐션을 정기적으로 체크하세요",
            "습도와 온도에 따라 볼의 특성을 고려하세요"
          ],
          mental_preparation: [
            "경기 전 긍정적인 시각화 훈련을 하세요",
            "실수 후에는 빠르게 마음을 리셋하세요",
            "호흡법을 통해 긴장을 완화하세요",
            formData.current_goal ?
              "목표를 명확히 하고 집중력을 유지하세요" :
              "자신만의 집중 의식을 만드세요",
            "경기 중 감정 기복을 최소화하세요"
          ]
        },
        future_predictions: {
          this_week: "새로운 기술을 배우기에 좋은 시기입니다. 기본기를 다지면 큰 향상을 이룰 수 있습니다.",
          this_month: "경기력이 안정화되는 시기입니다. 꾸준한 연습으로 자신감을 키워보세요.",
          this_season: "목표 달성에 가까워지는 시기입니다. 끝까지 포기하지 말고 최선을 다하세요."
        },
        compatibility: {
          best_doubles_partner: formData.playing_style?.includes('공격') ? 
            "차분하고 전략적 사고를 가진 파트너" :
            "활발하고 공격적인 플레이를 하는 파트너",
          ideal_coach_style: "체계적이면서도 개인의 특성을 살려주는 코치",
          perfect_opponent: "페어플레이를 중시하며 서로 발전시켜주는 상대"
        }
      };
    }
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.dominant_hand) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeTennisFortune();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleCheckboxChange = (value: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      tennis_skills: checked 
        ? [...prev.tennis_skills, value]
        : prev.tennis_skills.filter(item => item !== value)
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      dominant_hand: '',
      playing_style: '',
      favorite_surface: '',
      playing_experience: '',
      game_frequency: '',
      tennis_skills: [],
      lucky_number: '',
      current_goal: '',
      special_memory: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-emerald-25 to-teal-50 pb-32">
      <AppHeader title="행운의 테니스" />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-6"
      >
        <AnimatePresence mode="wait">
          {step === 'input' && (
            <motion.div
              key="input"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              {/* 헤더 */}
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-green-500 to-emerald-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Zap className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 테니스</h1>
                <p className="text-gray-600">테니스를 통해 보는 당신의 운세와 승리의 비결</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-green-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-green-700">
                      <Users className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label htmlFor="name">이름</Label>
                        <Input
                          id="name"
                          placeholder="이름"
                          value={formData.name}
                          onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
                      <div>
                        <KoreanDatePicker
                          label="생년월일"
                          value={formData.birth_date}
                          onChange={(date) => setFormData(prev => ({ ...prev, birth_date: date }))}
                          placeholder="생년월일을 선택하세요"
                          required
                          className="mt-1"
                        />
                      </div>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div>
                        <Label>주 사용 손</Label>
                        <RadioGroup 
                          value={formData.dominant_hand} 
                          onValueChange={(value) => setFormData(prev => ({ ...prev, dominant_hand: value }))}
                          className="mt-2"
                        >
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="right" id="right" />
                            <Label htmlFor="right">오른손</Label>
                          </div>
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="left" id="left" />
                            <Label htmlFor="left">왼손</Label>
                          </div>
                          <div className="flex items-center space-x-2">
                            <RadioGroupItem value="both" id="both" />
                            <Label htmlFor="both">양손</Label>
                          </div>
                        </RadioGroup>
                      </div>
                      <div>
                        <Label htmlFor="lucky_number">행운의 번호 (1-99)</Label>
                        <Input
                          id="lucky_number"
                          type="number"
                          min="1"
                          max="99"
                          placeholder="좋아하는 번호"
                          value={formData.lucky_number}
                          onChange={(e) => setFormData(prev => ({ ...prev, lucky_number: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 플레이 스타일 */}
              <motion.div variants={itemVariants}>
                <Card className="border-emerald-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-emerald-700">
                      <Trophy className="w-5 h-5" />
                      플레이 스타일
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>선호하는 플레이 스타일</Label>
                      <RadioGroup 
                        value={formData.playing_style} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, playing_style: value }))}
                        className="mt-2 grid grid-cols-1 gap-2"
                      >
                        {playingStyles.map((style) => (
                          <div key={style} className="flex items-center space-x-2">
                            <RadioGroupItem value={style} id={style} />
                            <Label htmlFor={style} className="text-sm">{style}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>선호하는 코트 표면</Label>
                      <RadioGroup 
                        value={formData.favorite_surface} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, favorite_surface: value }))}
                        className="mt-2 grid grid-cols-2 gap-2"
                      >
                        {surfaces.map((surface) => (
                          <div key={surface} className="flex items-center space-x-2">
                            <RadioGroupItem value={surface} id={surface} />
                            <Label htmlFor={surface} className="text-sm">{surface}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 테니스 경험 */}
              <motion.div variants={itemVariants}>
                <Card className="border-teal-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-teal-700">
                      <PlayCircle className="w-5 h-5" />
                      테니스 경험
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>테니스 경험</Label>
                      <RadioGroup 
                        value={formData.playing_experience} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, playing_experience: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="professional" id="professional" />
                          <Label htmlFor="professional">프로/선수 경험</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="competitive" id="competitive" />
                          <Label htmlFor="competitive">대회 출전 경험</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="recreational" id="recreational" />
                          <Label htmlFor="recreational">레크리에이션 레벨</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="beginner" id="beginner" />
                          <Label htmlFor="beginner">초보자</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>게임 빈도</Label>
                      <RadioGroup 
                        value={formData.game_frequency} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, game_frequency: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="daily" id="daily" />
                          <Label htmlFor="daily">매일</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="weekly" id="weekly" />
                          <Label htmlFor="weekly">주 2-3회</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="monthly" id="monthly" />
                          <Label htmlFor="monthly">월 몇 회</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="rarely" id="rarely" />
                          <Label htmlFor="rarely">가끔</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>강점 기술 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {skillAreas.map((skill) => (
                          <div key={skill} className="flex items-center space-x-2">
                            <Checkbox
                              id={skill}
                              checked={formData.tennis_skills.includes(skill)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange(skill, checked as boolean)
                              }
                            />
                            <Label htmlFor={skill} className="text-sm">{skill}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 목표와 추억 */}
              <motion.div variants={itemVariants}>
                <Card className="border-green-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-green-700">
                      <Star className="w-5 h-5" />
                      목표와 추억
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="current_goal">현재 테니스 목표</Label>
                      <Textarea
                        id="current_goal"
                        placeholder="예: 대회 우승, 랭킹 상승, 새로운 기술 습득 등..."
                        value={formData.current_goal}
                        onChange={(e) => setFormData(prev => ({ ...prev, current_goal: e.target.value }))}
                        className="mt-1 min-h-[60px]"
                      />
                    </div>
                    <div>
                      <Label htmlFor="special_memory">특별한 테니스 추억 (선택사항)</Label>
                      <Textarea
                        id="special_memory"
                        placeholder="가장 기억에 남는 테니스 경험이나 순간을 적어주세요..."
                        value={formData.special_memory}
                        onChange={(e) => setFormData(prev => ({ ...prev, special_memory: e.target.value }))}
                        className="mt-1 min-h-[80px]"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleSubmit}
                  disabled={loading}
                  className="w-full bg-gradient-to-r from-green-500 to-emerald-500 hover:from-green-600 hover:to-emerald-600 text-white py-6 text-lg font-semibold"
                >
                  {loading ? (
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ repeat: Infinity, duration: 1 }}
                      className="flex items-center gap-2"
                    >
                      <Shuffle className="w-5 h-5" />
                      분석 중...
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      <Zap className="w-5 h-5" />
                      테니스 운세 분석하기
                    </div>
                  )}
                </Button>
              </motion.div>
            </motion.div>
          )}

          {step === 'result' && result && (
            <motion.div
              key="result"
              initial={{ opacity: 0, x: 50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -50 }}
              className="space-y-6"
            >
              {/* 전체 운세 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-green-500 to-emerald-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Trophy className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 테니스 운세</span>
                    </div>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className="text-6xl font-bold mb-2"
                    >
                      {result.overall_luck}점
                    </motion.div>
                    <Badge variant="secondary" className="bg-white/20 text-white border-white/30">
                      {getLuckText(result.overall_luck)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 세부 운세 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <BarChart3 className="w-5 h-5" />
                      세부 테니스 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "서브운", score: result.serve_luck, icon: Target, desc: "에이스와 서비스 게임의 운" },
                      { label: "리턴운", score: result.return_luck, icon: Crosshair, desc: "리턴 에이스와 브레이크의 운" },
                      { label: "발리운", score: result.volley_luck, icon: Shield, desc: "네트 플레이와 마무리의 운" },
                      { label: "멘탈운", score: result.mental_luck, icon: Users, desc: "집중력과 압박감 극복의 운" }
                    ].map((item, index) => (
                      <motion.div
                        key={item.label}
                        initial={{ x: -20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.4 + index * 0.1 }}
                        className="space-y-2"
                      >
                        <div className="flex items-center gap-3">
                          <item.icon className="w-5 h-5 text-gray-600" />
                          <div className="flex-1">
                            <div className="flex justify-between items-center mb-1">
                              <div>
                                <span className="font-medium">{item.label}</span>
                                <p className="text-xs text-gray-500">{item.desc}</p>
                              </div>
                              <span className={`px-3 py-1 rounded-full text-sm font-medium ${getLuckColor(item.score)}`}>
                                {item.score}점
                              </span>
                            </div>
                            <div className="w-full bg-gray-200 rounded-full h-2">
                              <motion.div
                                className="bg-green-500 h-2 rounded-full"
                                initial={{ width: 0 }}
                                animate={{ width: `${item.score}%` }}
                                transition={{ delay: 0.5 + index * 0.1, duration: 0.8 }}
                              />
                            </div>
                          </div>
                        </div>
                      </motion.div>
                    ))}
                  </CardContent>
                </Card>
              </motion.div>

              {/* SWOT 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <Activity className="w-5 h-5" />
                      테니스 SWOT 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-4 bg-green-50 rounded-lg">
                        <h4 className="font-medium text-green-800 mb-2 flex items-center gap-2">
                          <ThumbsUp className="w-4 h-4" />
                          강점 (Strength)
                        </h4>
                        <p className="text-green-700 text-sm">{result.analysis.strength}</p>
                      </div>
                      <div className="p-4 bg-red-50 rounded-lg">
                        <h4 className="font-medium text-red-800 mb-2 flex items-center gap-2">
                          <Eye className="w-4 h-4" />
                          약점 (Weakness)
                        </h4>
                        <p className="text-red-700 text-sm">{result.analysis.weakness}</p>
                      </div>
                      <div className="p-4 bg-blue-50 rounded-lg">
                        <h4 className="font-medium text-blue-800 mb-2 flex items-center gap-2">
                          <Sparkles className="w-4 h-4" />
                          기회 (Opportunity)
                        </h4>
                        <p className="text-blue-700 text-sm">{result.analysis.opportunity}</p>
                      </div>
                      <div className="p-4 bg-orange-50 rounded-lg">
                        <h4 className="font-medium text-orange-800 mb-2 flex items-center gap-2">
                          <Flame className="w-4 h-4" />
                          도전 (Threat)
                        </h4>
                        <p className="text-orange-700 text-sm">{result.analysis.challenge}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 행운의 요소들 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Crown className="w-5 h-5" />
                      행운의 요소들
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-4 bg-purple-50 rounded-lg">
                        <h4 className="font-medium text-purple-800 mb-2 flex items-center gap-2">
                          <Target className="w-4 h-4" />
                          행운의 라켓 텐션
                        </h4>
                        <p className="text-lg font-semibold text-purple-700">{result.lucky_racket_tension}</p>
                      </div>
                      <div className="p-4 bg-indigo-50 rounded-lg">
                        <h4 className="font-medium text-indigo-800 mb-2 flex items-center gap-2">
                          <MapPin className="w-4 h-4" />
                          행운의 코트 포지션
                        </h4>
                        <p className="text-lg font-semibold text-indigo-700">{result.lucky_court_position}</p>
                      </div>
                      <div className="p-4 bg-teal-50 rounded-lg">
                        <h4 className="font-medium text-teal-800 mb-2 flex items-center gap-2">
                          <Clock className="w-4 h-4" />
                          행운의 경기 시간
                        </h4>
                        <p className="text-lg font-semibold text-teal-700">{result.lucky_match_time}</p>
                      </div>
                      <div className="p-4 bg-emerald-50 rounded-lg">
                        <h4 className="font-medium text-emerald-800 mb-2 flex items-center gap-2">
                          <Flag className="w-4 h-4" />
                          행운의 토너먼트
                        </h4>
                        <p className="text-lg font-semibold text-emerald-700">{result.lucky_tournament}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 맞춤 추천 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <TrendingUp className="w-5 h-5" />
                      맞춤 추천사항
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Target className="w-4 h-4 text-red-500" />
                        훈련 팁
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.training_tips.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.6 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Star className="w-4 h-4 text-red-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{tip}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Zap className="w-4 h-4 text-blue-500" />
                        경기 전략
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.match_strategies.map((strategy, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.8 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Trophy className="w-4 h-4 text-blue-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{strategy}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Shield className="w-4 h-4 text-green-500" />
                        장비 조언
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.equipment_advice.map((advice, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 1.0 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Award className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{advice}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Activity className="w-4 h-4 text-purple-500" />
                        멘탈 준비
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.mental_preparation.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 1.2 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Sparkles className="w-4 h-4 text-purple-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{tip}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 미래 예측 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-indigo-600">
                      <Calendar className="w-5 h-5" />
                      미래 예측
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-blue-50 rounded-lg">
                        <h4 className="font-medium text-blue-800 mb-2 flex items-center gap-2">
                          <Timer className="w-4 h-4" />
                          이번 주
                        </h4>
                        <p className="text-blue-700 text-sm">{result.future_predictions.this_week}</p>
                      </div>
                      <div className="p-4 bg-indigo-50 rounded-lg">
                        <h4 className="font-medium text-indigo-800 mb-2 flex items-center gap-2">
                          <Calendar className="w-4 h-4" />
                          이번 달
                        </h4>
                        <p className="text-indigo-700 text-sm">{result.future_predictions.this_month}</p>
                      </div>
                      <div className="p-4 bg-purple-50 rounded-lg">
                        <h4 className="font-medium text-purple-800 mb-2 flex items-center gap-2">
                          <Crown className="w-4 h-4" />
                          이번 시즌
                        </h4>
                        <p className="text-purple-700 text-sm">{result.future_predictions.this_season}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 궁합 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-pink-600">
                      <Heart className="w-5 h-5" />
                      테니스 궁합 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-pink-50 rounded-lg">
                        <h4 className="font-medium text-pink-800 mb-2">최고의 복식 파트너</h4>
                        <p className="text-pink-700 text-sm">{result.compatibility.best_doubles_partner}</p>
                      </div>
                      <div className="p-4 bg-rose-50 rounded-lg">
                        <h4 className="font-medium text-rose-800 mb-2">이상적인 코치 스타일</h4>
                        <p className="text-rose-700 text-sm">{result.compatibility.ideal_coach_style}</p>
                      </div>
                      <div className="p-4 bg-red-50 rounded-lg">
                        <h4 className="font-medium text-red-800 mb-2">완벽한 상대</h4>
                        <p className="text-red-700 text-sm">{result.compatibility.perfect_opponent}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 다시 분석하기 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-green-300 text-green-600 hover:bg-green-50 py-3"
                >
                  <ArrowRight className="w-4 h-4 mr-2" />
                  다른 분석하기
                </Button>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
} 