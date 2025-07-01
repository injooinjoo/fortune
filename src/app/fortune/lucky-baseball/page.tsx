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
import AppHeader from "@/components/AppHeader";
import { 
  Target, 
  Trophy, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Users,
  Zap,
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

interface BaseballInfo {
  name: string;
  birth_date: string;
  favorite_team: string;
  favorite_position: string;
  playing_experience: string;
  game_frequency: string;
  baseball_knowledge: string[];
  lucky_number: string;
  current_goal: string;
  special_memory: string;
}

interface BaseballFortune {
  overall_luck: number;
  batting_luck: number;
  pitching_luck: number;
  fielding_luck: number;
  team_luck: number;
  analysis: {
    strength: string;
    weakness: string;
    opportunity: string;
    challenge: string;
  };
  lucky_position: string;
  lucky_uniform_number: number;
  lucky_game_time: string;
  lucky_stadium: string;
  recommendations: {
    training_tips: string[];
    game_strategies: string[];
    team_building: string[];
    mental_preparation: string[];
  };
  future_predictions: {
    this_week: string;
    this_month: string;
    this_season: string;
  };
  compatibility: {
    best_teammate_type: string;
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

const koreanTeams = [
  "두산 베어스", "KIA 타이거즈", "LG 트윈스", "NC 다이노스", "삼성 라이온즈",
  "롯데 자이언츠", "SSG 랜더스", "키움 히어로즈", "한화 이글스", "KT 위즈"
];

const mlbTeams = [
  "LA 다저스", "뉴욕 양키스", "보스턴 레드삭스", "샌프란시스코 자이언츠", "시카고 컵스",
  "애틀랜타 브레이브스", "휴스턴 애스트로스", "토론토 블루제이스", "기타"
];

const positions = [
  "투수", "포수", "1루수", "2루수", "3루수", "유격수", "좌익수", "중견수", "우익수", "지명타자"
];

const knowledgeAreas = [
  "규칙과 전술", "선수 통계", "팀 역사", "경기 분석", "장비 지식", 
  "트레이닝 방법", "부상 예방", "멘탈 관리", "야구 문화", "국제 야구"
];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "최고의 운";
  if (score >= 70) return "좋은 운";
  if (score >= 55) return "보통의 운";
  return "주의 필요";
};

export default function LuckyBaseballPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<BaseballInfo>({
    name: '',
    birth_date: '',
    favorite_team: '',
    favorite_position: '',
    playing_experience: '',
    game_frequency: '',
    baseball_knowledge: [],
    lucky_number: '',
    current_goal: '',
    special_memory: ''
  });
  const [result, setResult] = useState<BaseballFortune | null>(null);

  const analyzeBaseballFortune = async (): Promise<BaseballFortune> => {
    try {
      const response = await fetch('/api/fortune/lucky-baseball', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error('API 요청 실패');
      }

      const data = await response.json();
      return data;
    } catch (error) {
      console.error('API 호출 실패, 백업 로직 사용:', error);
      
      // 개선된 백업 로직 - 생년월일 기반 개인화
      const birth = new Date(formData.birth_date);
      const birthSum = birth.getFullYear() + birth.getMonth() + birth.getDate();
      const nameSum = formData.name.split('').reduce((sum, char) => sum + char.charCodeAt(0), 0);
      const personalSeed = (birthSum + nameSum) % 100;
      
      // 경험에 따른 보너스
      let experienceBonus = 0;
      if (formData.playing_experience === '10년 이상') experienceBonus = 15;
      else if (formData.playing_experience === '5-10년') experienceBonus = 10;
      else if (formData.playing_experience === '2-5년') experienceBonus = 5;
      
      // 경기 빈도에 따른 보너스
      let frequencyBonus = 0;
      if (formData.game_frequency === '주 3회 이상') frequencyBonus = 12;
      else if (formData.game_frequency === '주 1-2회') frequencyBonus = 8;
      else if (formData.game_frequency === '월 2-3회') frequencyBonus = 4;
      
      // 지식 다양성 보너스
      const knowledgeBonus = formData.baseball_knowledge.length >= 6 ? 10 : 
                            formData.baseball_knowledge.length >= 4 ? 5 : 0;
      
      // 포지션별 특성
      const positionBonus = {
        '포수': 12, '유격수': 10, '중견수': 9, '투수': 8, '3루수': 7,
        '2루수': 6, '1루수': 5, '좌익수': 4, '우익수': 4, '지명타자': 3
      }[formData.favorite_position] || 0;
      
      const baseScore = Math.max(50, Math.min(85, 65 + (personalSeed % 20) + experienceBonus + frequencyBonus + knowledgeBonus + positionBonus));
      
      // 포지션별 운세 특성
      const getPositionBasedLuck = (base: number, position: string) => {
        const adjustments = {
          '투수': { pitching: 15, batting: -5, fielding: 5, team: 10 },
          '포수': { pitching: 10, batting: 0, fielding: 15, team: 12 },
          '내야수': { pitching: -5, batting: 5, fielding: 12, team: 8 },
          '외야수': { pitching: -8, batting: 8, fielding: 10, team: 5 }
        };
        
        const posType = ['투수'].includes(position) ? '투수' :
                       ['포수'].includes(position) ? '포수' :
                       ['1루수', '2루수', '3루수', '유격수'].includes(position) ? '내야수' : '외야수';
        
        return adjustments[posType] || { pitching: 0, batting: 0, fielding: 0, team: 0 };
      };
      
      const positionAdj = getPositionBasedLuck(baseScore, formData.favorite_position);
      
      // 행운의 번호 기반 추가 랜덤
      const luckyBonus = formData.lucky_number ? (parseInt(formData.lucky_number) % 10) : 0;

      return {
        overall_luck: Math.max(50, Math.min(95, baseScore + luckyBonus)),
        batting_luck: Math.max(45, Math.min(100, baseScore + positionAdj.batting + (personalSeed % 15) - 5)),
        pitching_luck: Math.max(40, Math.min(95, baseScore + positionAdj.pitching + (personalSeed % 20) - 10)),
        fielding_luck: Math.max(50, Math.min(100, baseScore + positionAdj.fielding + (personalSeed % 15))),
        team_luck: Math.max(55, Math.min(95, baseScore + positionAdj.team + (personalSeed % 18) - 5)),
        analysis: {
          strength: "강한 정신력과 끈기를 바탕으로 어려운 상황에서도 포기하지 않는 투지를 가지고 있습니다.",
          weakness: "때로는 완벽을 추구하다가 과도한 스트레스를 받을 수 있으니 적당한 휴식이 필요합니다.",
          opportunity: "팀워크를 중시하는 성향으로 인해 동료들과 좋은 시너지를 만들어낼 수 있습니다.",
          challenge: "새로운 기술이나 전술을 익히는 데 시간이 걸릴 수 있지만, 꾸준히 노력하면 극복할 수 있습니다."
        },
        lucky_position: positions[(personalSeed + nameSum) % positions.length],
        lucky_uniform_number: ((personalSeed + parseInt(formData.lucky_number || '7')) % 99) + 1,
        lucky_game_time: ["오후 2시", "오후 6시", "오후 7시"][(personalSeed + birthSum) % 3],
        lucky_stadium: ["잠실야구장", "고척스카이돔", "창원NC파크", "사직야구장"][(personalSeed + nameSum) % 4],
        recommendations: {
          training_tips: [
            "매일 기본기 연습에 30분 이상 투자하세요",
            "몸의 유연성을 위해 스트레칭을 꾸준히 하세요",
            "정확한 폼을 익히기 위해 천천히 연습하세요",
            "체력 관리를 위한 유산소 운동을 병행하세요",
            "부상 예방을 위해 충분한 워밍업을 하세요"
          ],
          game_strategies: [
            "상대방의 패턴을 관찰하고 분석하세요",
            "자신의 강점을 최대한 활용하는 전략을 세우세요",
            "팀원들과의 소통을 자주하여 호흡을 맞추세요",
            "경기 상황에 따라 유연하게 대응하세요",
            "실수를 두려워하지 말고 적극적으로 플레이하세요"
          ],
          team_building: [
            "팀원들과 함께하는 식사 시간을 가져보세요",
            "서로의 강점을 칭찬하고 인정해주세요",
            "어려운 상황에서 서로를 격려해주세요",
            "팀의 목표를 함께 설정하고 공유하세요",
            "경기 후에는 함께 경기를 되돌아보세요"
          ],
          mental_preparation: [
            "경기 전 긍정적인 이미지 트레이닝을 하세요",
            "심호흡을 통해 마음을 안정시키세요",
            "실패를 두려워하지 말고 도전하세요",
            "집중력 향상을 위한 명상을 해보세요",
            "자신만의 루틴을 만들어 심리적 안정감을 가지세요"
          ]
        },
        future_predictions: {
          this_week: "새로운 기술을 배우기에 좋은 시기입니다. 기본기에 충실하면 큰 발전을 이룰 수 있습니다.",
          this_month: "팀워크가 중요한 시기입니다. 동료들과의 호흡을 맞추는데 집중하면 좋은 결과가 있을 것입니다.",
          this_season: "꾸준한 노력이 결실을 맺는 시기입니다. 포기하지 않고 계속 도전하면 목표를 달성할 수 있습니다."
        },
        compatibility: {
          best_teammate_type: "긍정적이고 서로를 격려해주는 동료",
          ideal_coach_style: "체계적이면서도 선수 개인을 배려하는 코치",
          perfect_opponent: "실력이 비슷하면서 페어플레이를 중시하는 상대"
        }
      };
    }
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.favorite_position) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeBaseballFortune();
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
      baseball_knowledge: checked 
        ? [...prev.baseball_knowledge, value]
        : prev.baseball_knowledge.filter(item => item !== value)
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      favorite_team: '',
      favorite_position: '',
      playing_experience: '',
      game_frequency: '',
      baseball_knowledge: [],
      lucky_number: '',
      current_goal: '',
      special_memory: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-yellow-25 to-orange-50 pb-32">
      <AppHeader title="행운의 야구" />
      
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
                  className="bg-gradient-to-r from-amber-500 to-orange-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Target className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 야구</h1>
                <p className="text-gray-600">야구를 통해 보는 당신의 운세와 성공 비결</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-amber-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-amber-700">
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
                        <Label htmlFor="birth_date">생년월일</Label>
                        <Input
                          id="birth_date"
                          type="date"
                          value={formData.birth_date}
                          onChange={(e) => setFormData(prev => ({ ...prev, birth_date: e.target.value }))}
                          className="mt-1"
                        />
                      </div>
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
                  </CardContent>
                </Card>
              </motion.div>

              {/* 야구 선호도 */}
              <motion.div variants={itemVariants}>
                <Card className="border-orange-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-orange-700">
                      <Trophy className="w-5 h-5" />
                      야구 선호도
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>좋아하는 국내 팀</Label>
                      <RadioGroup 
                        value={formData.favorite_team} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, favorite_team: value }))}
                        className="mt-2 grid grid-cols-2 gap-2"
                      >
                        {koreanTeams.map((team) => (
                          <div key={team} className="flex items-center space-x-2">
                            <RadioGroupItem value={team} id={team} />
                            <Label htmlFor={team} className="text-sm">{team}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>선호하는 포지션</Label>
                      <RadioGroup 
                        value={formData.favorite_position} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, favorite_position: value }))}
                        className="mt-2 grid grid-cols-2 gap-2"
                      >
                        {positions.map((position) => (
                          <div key={position} className="flex items-center space-x-2">
                            <RadioGroupItem value={position} id={position} />
                            <Label htmlFor={position} className="text-sm">{position}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 야구 경험 */}
              <motion.div variants={itemVariants}>
                <Card className="border-yellow-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-yellow-700">
                      <PlayCircle className="w-5 h-5" />
                      야구 경험
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>야구 경험</Label>
                      <RadioGroup 
                        value={formData.playing_experience} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, playing_experience: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="professional" id="professional" />
                          <Label htmlFor="professional">프로/실업팀 경험</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="amateur" id="amateur" />
                          <Label htmlFor="amateur">아마추어 리그 참여</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="casual" id="casual" />
                          <Label htmlFor="casual">취미로 즐김</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="spectator" id="spectator" />
                          <Label htmlFor="spectator">관람만 함</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>경기 관람/참여 빈도</Label>
                      <RadioGroup 
                        value={formData.game_frequency} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, game_frequency: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="weekly" id="weekly" />
                          <Label htmlFor="weekly">주 1회 이상</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="monthly" id="monthly" />
                          <Label htmlFor="monthly">월 1-2회</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="seasonal" id="seasonal" />
                          <Label htmlFor="seasonal">시즌 중 몇 번</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="rarely" id="rarely" />
                          <Label htmlFor="rarely">거의 없음</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>야구 지식 분야 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {knowledgeAreas.map((area) => (
                          <div key={area} className="flex items-center space-x-2">
                            <Checkbox
                              id={area}
                              checked={formData.baseball_knowledge.includes(area)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange(area, checked as boolean)
                              }
                            />
                            <Label htmlFor={area} className="text-sm">{area}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 목표와 추억 */}
              <motion.div variants={itemVariants}>
                <Card className="border-amber-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-amber-700">
                      <Star className="w-5 h-5" />
                      목표와 추억
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="current_goal">현재 야구 관련 목표</Label>
                      <Textarea
                        id="current_goal"
                        placeholder="예: 타율 3할 달성, 좋아하는 팀 직관 가기, 야구 동호회 가입 등..."
                        value={formData.current_goal}
                        onChange={(e) => setFormData(prev => ({ ...prev, current_goal: e.target.value }))}
                        className="mt-1 min-h-[60px]"
                      />
                    </div>
                    <div>
                      <Label htmlFor="special_memory">특별한 야구 추억 (선택사항)</Label>
                      <Textarea
                        id="special_memory"
                        placeholder="가장 기억에 남는 야구 경험이나 순간을 적어주세요..."
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
                  className="w-full bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white py-6 text-lg font-semibold"
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
                      <Target className="w-5 h-5" />
                      야구 운세 분석하기
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
                <Card className="bg-gradient-to-r from-amber-500 to-orange-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Trophy className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 야구 운세</span>
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
                    <CardTitle className="flex items-center gap-2 text-amber-600">
                      <BarChart3 className="w-5 h-5" />
                      세부 야구 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "타격운", score: result.batting_luck, icon: Crosshair, desc: "안타와 홈런의 운" },
                      { label: "투구운", score: result.pitching_luck, icon: Target, desc: "스트라이크와 삼진의 운" },
                      { label: "수비운", score: result.fielding_luck, icon: Shield, desc: "실책 없는 완벽한 수비의 운" },
                      { label: "팀워크운", score: result.team_luck, icon: Users, desc: "동료들과의 호흡과 협력의 운" }
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
                                className="bg-amber-500 h-2 rounded-full"
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
                    <CardTitle className="flex items-center gap-2 text-green-600">
                      <Activity className="w-5 h-5" />
                      야구 SWOT 분석
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
                          <MapPin className="w-4 h-4" />
                          행운의 포지션
                        </h4>
                        <p className="text-lg font-semibold text-purple-700">{result.lucky_position}</p>
                      </div>
                      <div className="p-4 bg-indigo-50 rounded-lg">
                        <h4 className="font-medium text-indigo-800 mb-2 flex items-center gap-2">
                          <Award className="w-4 h-4" />
                          행운의 등번호
                        </h4>
                        <p className="text-lg font-semibold text-indigo-700">{result.lucky_uniform_number}번</p>
                      </div>
                      <div className="p-4 bg-teal-50 rounded-lg">
                        <h4 className="font-medium text-teal-800 mb-2 flex items-center gap-2">
                          <Clock className="w-4 h-4" />
                          행운의 경기 시간
                        </h4>
                        <p className="text-lg font-semibold text-teal-700">{result.lucky_game_time}</p>
                      </div>
                      <div className="p-4 bg-emerald-50 rounded-lg">
                        <h4 className="font-medium text-emerald-800 mb-2 flex items-center gap-2">
                          <Flag className="w-4 h-4" />
                          행운의 야구장
                        </h4>
                        <p className="text-lg font-semibold text-emerald-700">{result.lucky_stadium}</p>
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
                        {result.recommendations.game_strategies.map((strategy, index) => (
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
                        <Users className="w-4 h-4 text-green-500" />
                        팀워크 구축
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.team_building.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 1.0 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Heart className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{tip}</p>
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
                      야구 궁합 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid gap-4">
                      <div className="p-4 bg-pink-50 rounded-lg">
                        <h4 className="font-medium text-pink-800 mb-2">최고의 팀동료 유형</h4>
                        <p className="text-pink-700 text-sm">{result.compatibility.best_teammate_type}</p>
                      </div>
                      <div className="p-4 bg-rose-50 rounded-lg">
                        <h4 className="font-medium text-rose-800 mb-2">이상적인 코치 스타일</h4>
                        <p className="text-rose-700 text-sm">{result.compatibility.ideal_coach_style}</p>
                      </div>
                      <div className="p-4 bg-red-50 rounded-lg">
                        <h4 className="font-medium text-red-800 mb-2">완벽한 상대팀</h4>
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
                  className="w-full border-amber-300 text-amber-600 hover:bg-amber-50 py-3"
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