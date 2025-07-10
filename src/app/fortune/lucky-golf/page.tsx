"use client";

import { useToast } from '@/hooks/use-toast';
import { logger } from '@/lib/logger';
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
  CircleDot, 
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
  Target,
  BarChart3,
  Activity,
  Eye,
  ThumbsUp,
  Heart,
  MapPin,
  Timer,
  Wind,
  Mountain,
  TreePine,
  Sun,
  CloudRain,
  Compass,
  Crosshair
} from "lucide-react";

interface GolfInfo {
  name: string;
  birth_date: string;
  handicap: string;
  playing_experience: string;
  play_frequency: string;
  preferred_courses: string[];
  playing_style: string;
  favorite_clubs: string[];
  golf_goals: string;
  biggest_challenge: string;
  memorable_moment: string;
  playing_partners: string;
}

interface GolfFortune {
  overall_luck: number;
  driving_luck: number;
  iron_luck: number;
  putting_luck: number;
  course_management_luck: number;
  analysis: {
    strength: string;
    weakness: string;
    opportunity: string;
    threat: string;
  };
  lucky_elements: {
    course_type: string;
    tee_time: string;
    weather: string;
    playing_direction: string;
  };
  recommendations: {
    driving_tips: string[];
    approach_tips: string[];
    putting_tips: string[];
    mental_tips: string[];
    equipment_advice: string[];
  };
  future_predictions: {
    this_week: string;
    this_month: string;
    this_season: string;
  };
  lucky_holes: number[];
  course_recommendations: string[];
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

const courseTypes = [
  "링크스 코스", "파크랜드 코스", "마운틴 코스", "리조트 코스", "컨트리클럽", 
  "퍼블릭 코스", "프라이빗 코스", "챔피언십 코스"
];

const favoriteClubs = [
  "드라이버", "3우드", "5우드", "하이브리드", "롱아이언(3-4번)", 
  "미드아이언(5-7번)", "숏아이언(8-9번)", "웨지", "퍼터"
];

const playingStyles = [
  "공격적 플레이", "안전한 플레이", "전략적 플레이", "감성적 플레이", 
  "분석적 플레이", "직관적 플레이"
];

const koreanCourses = [
  "스카이72", "베어크리크", "클럽72", "골든베이", "썬힐", "나인브릿지스", 
  "레이크사이드", "오크밸리", "잭니클라우스", "TPC 해슬리나인브릿지"
];

const getLuckColor = (score: number) => {
  if (score >= 85) return "text-green-600 bg-green-50";
  if (score >= 70) return "text-blue-600 bg-blue-50";
  if (score >= 55) return "text-orange-600 bg-orange-50";
  return "text-red-600 bg-red-50";
};

const getLuckText = (score: number) => {
  if (score >= 85) return "이글 찬스";
  if (score >= 70) return "버디 가능";
  if (score >= 55) return "파 세이브";
  return "보기 주의";
};

export default function LuckyGolfPage() {
  const { toast } = useToast();
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<GolfInfo>({
    name: '',
    birth_date: '',
    handicap: '',
    playing_experience: '',
    play_frequency: '',
    preferred_courses: [],
    playing_style: '',
    favorite_clubs: [],
    golf_goals: '',
    biggest_challenge: '',
    memorable_moment: '',
    playing_partners: ''
  });
  const [result, setResult] = useState<GolfFortune | null>(null);

  const analyzeGolfFortune = async (): Promise<GolfFortune> => {
    try {
      const response = await fetch('/api/fortune/lucky-golf', {
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
      logger.error('골프 운세 분석 오류:', error);
      
      // 개선된 백업 로직 (개인화된)
      const birthYear = formData.birth_date ? parseInt(formData.birth_date.substring(0, 4)) : new Date().getFullYear() - 30;
      const birthMonth = formData.birth_date ? parseInt(formData.birth_date.substring(5, 7)) : 6;
      const birthDay = formData.birth_date ? parseInt(formData.birth_date.substring(8, 10)) : 15;
      
      let baseScore = ((birthYear + birthMonth + birthDay) % 25) + 65;
      
      // 핸디캡별 보너스
      const handicapNum = parseFloat(formData.handicap) || 20;
      if (handicapNum <= 10) baseScore += 10;
      else if (handicapNum <= 15) baseScore += 5;
      
      // 경험별 보너스
      if (formData.playing_experience.includes('10년 이상')) baseScore += 12;
      else if (formData.playing_experience.includes('5-10년')) baseScore += 8;
      
      // 클럽 다양성 보너스
      if (formData.favorite_clubs && formData.favorite_clubs.length >= 4) baseScore += 6;
      
      baseScore = Math.max(50, Math.min(95, baseScore));

      return {
        overall_luck: baseScore,
        driving_luck: Math.max(45, Math.min(100, baseScore + 3)),
        iron_luck: Math.max(40, Math.min(95, baseScore)),
        putting_luck: Math.max(50, Math.min(100, baseScore + 2)),
        course_management_luck: Math.max(55, Math.min(95, baseScore)),
        analysis: {
          strength: "차분하고 집중력이 좋아 어려운 상황에서도 안정적인 플레이를 할 수 있습니다.",
          weakness: "가끔 과도한 완벽주의로 인해 긴장하여 실수할 수 있으니 여유로운 마음가짐이 필요합니다.",
          opportunity: "꾸준한 연습과 경험으로 비거리와 정확성을 동시에 향상시킬 수 있는 시기입니다.",
          threat: "날씨나 코스 컨디션에 민감하게 반응할 수 있으니 다양한 상황에 대한 준비가 필요합니다."
        },
        lucky_elements: {
          course_type: courseTypes[birthMonth % courseTypes.length],
          tee_time: ["오전 7-9시", "오전 10-12시", "오후 1-3시", "오후 4-6시"][birthDay % 4],
          weather: ["맑음", "구름 조금", "살짝 바람"][(birthDay + birthMonth) % 3],
          playing_direction: ["북쪽", "동쪽", "남쪽", "서쪽"][birthMonth % 4]
        },
        recommendations: {
          driving_tips: [
            formData.playing_style?.includes('파워') ?
              "파워를 유지하면서도 정확성에 더 집중하세요" :
              "백스윙을 천천히 하여 리듬을 유지하세요",
            "몸의 중심을 안정적으로 유지하세요",
            "임팩트 순간 헤드업을 피하세요",
            "팔로우 스루를 완전히 마무리하세요",
            formData.handicap && parseFloat(formData.handicap) > 15 ?
              "정확성을 우선으로 하여 페어웨이 킵에 집중하세요" :
              "자신의 비거리에 맞는 클럽을 선택하세요"
          ],
          approach_tips: [
            "핀까지의 정확한 거리를 측정하세요",
            "그린의 경사와 바람을 고려하세요",
            formData.playing_style?.includes('안정') ?
              "안전한 플레이를 유지하되 공격적인 샷도 시도해보세요" :
              "여유있는 클럽으로 안전하게 플레이하세요",
            "그린 중앙을 노리는 것이 안전합니다",
            "볼의 라이를 정확히 판단하세요"
          ],
          putting_tips: [
            "그린의 경사를 충분히 읽으세요",
            "일정한 템포로 퍼팅하세요",
            "볼이 굴러가는 라인을 시각화하세요",
            formData.favorite_clubs?.includes('퍼터') ?
              "자신감을 가지고 공격적인 퍼팅을 시도하세요" :
              "숏퍼팅에서는 확신을 가지고 치세요",
            "롱퍼팅에서는 거리 감각에 집중하세요"
          ],
          mental_tips: [
            "각 샷마다 긍정적인 이미지를 그리세요",
            "실수를 했을 때 빨리 잊고 다음 샷에 집중하세요",
            "자신만의 루틴을 만들어 일관성을 유지하세요",
            formData.golf_goals ?
              "목표를 명확히 하되 과도한 압박은 피하세요" :
              "과도한 욕심보다는 현실적인 목표를 설정하세요",
            "라운딩을 즐기는 마음가짐을 가지세요"
          ],
          equipment_advice: [
            "자신의 스윙 속도에 맞는 샤프트를 선택하세요",
            "정기적으로 클럽 그립을 점검하고 교체하세요",
            formData.handicap && parseFloat(formData.handicap) > 15 ?
              "관용성이 높은 클럽을 선택하는 것이 좋습니다" :
              "볼의 압축도를 고려하여 선택하세요",
            "날씨에 맞는 골프웨어를 착용하세요",
            "골프화 스파이크를 주기적으로 확인하세요"
          ]
        },
        future_predictions: {
          this_week: "드라이빙 거리가 늘어날 수 있는 좋은 시기입니다. 기본기 연습에 집중하세요.",
          this_month: "퍼팅 감각이 좋아질 것으로 예상됩니다. 숏게임 연습을 늘려보세요.",
          this_season: "전반적인 스코어 향상이 기대되는 시즌입니다. 꾸준한 라운딩으로 경험을 쌓으세요."
        },
        lucky_holes: [
          ((birthDay + birthMonth) % 18) + 1,
          ((birthDay + birthMonth + 3) % 18) + 1,
          ((birthDay + birthMonth + 6) % 18) + 1
        ],
        course_recommendations: [
          koreanCourses[baseScore % koreanCourses.length],
          koreanCourses[(baseScore + 7) % koreanCourses.length],
          koreanCourses[(baseScore + 14) % koreanCourses.length]
        ]
      };
    }
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.playing_style) {
      toast({
      title: '필수 정보를 모두 입력해주세요.',
      variant: "default",
    });
      return;
    }

    setLoading(true);
    
    try {
      await new Promise(resolve => setTimeout(resolve, 3000));
      const analysisResult = await analyzeGolfFortune();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      logger.error('분석 중 오류:', error);
      toast({
      title: '분석 중 오류가 발생했습니다. 다시 시도해주세요.',
      variant: "destructive",
    });
    } finally {
      setLoading(false);
    }
  };

  const handleCheckboxChange = (value: string, checked: boolean, field: 'preferred_courses' | 'favorite_clubs') => {
    setFormData(prev => ({
      ...prev,
      [field]: checked 
        ? [...prev[field], value]
        : prev[field].filter(item => item !== value)
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      handicap: '',
      playing_experience: '',
      play_frequency: '',
      preferred_courses: [],
      playing_style: '',
      favorite_clubs: [],
      golf_goals: '',
      biggest_challenge: '',
      memorable_moment: '',
      playing_partners: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-lime-50 via-green-25 to-emerald-50 pb-32">
      <AppHeader title="행운의 골프" />
      
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
                  className="bg-gradient-to-r from-lime-500 to-green-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <CircleDot className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className="text-2xl font-bold text-gray-900 mb-2">행운의 골프</h1>
                <p className="text-gray-600">완벽한 라운딩을 위한 골프 운세와 비법</p>
              </motion.div>

              {/* 기본 정보 */}
              <motion.div variants={itemVariants}>
                <Card className="border-lime-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-lime-700">
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
                      <Label htmlFor="handicap">핸디캡</Label>
                      <Input
                        id="handicap"
                        placeholder="예: 15 (없으면 '비기너' 입력)"
                        value={formData.handicap}
                        onChange={(e) => setFormData(prev => ({ ...prev, handicap: e.target.value }))}
                        className="mt-1"
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 골프 경험 */}
              <motion.div variants={itemVariants}>
                <Card className="border-green-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-green-700">
                      <Trophy className="w-5 h-5" />
                      골프 경험
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>골프 경험</Label>
                      <RadioGroup 
                        value={formData.playing_experience} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, playing_experience: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="professional" id="professional" />
                          <Label htmlFor="professional">프로/준프로 수준</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="advanced" id="advanced" />
                          <Label htmlFor="advanced">상급자 (10년 이상)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="intermediate" id="intermediate" />
                          <Label htmlFor="intermediate">중급자 (3-10년)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="beginner" id="beginner" />
                          <Label htmlFor="beginner">초급자 (1-3년)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="newbie" id="newbie" />
                          <Label htmlFor="newbie">입문자 (1년 미만)</Label>
                        </div>
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>플레이 빈도</Label>
                      <RadioGroup 
                        value={formData.play_frequency} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, play_frequency: value }))}
                        className="mt-2"
                      >
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="daily" id="daily" />
                          <Label htmlFor="daily">매일 (연습장 포함)</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="weekly" id="weekly" />
                          <Label htmlFor="weekly">주 1-2회</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="monthly" id="monthly" />
                          <Label htmlFor="monthly">월 1-2회</Label>
                        </div>
                        <div className="flex items-center space-x-2">
                          <RadioGroupItem value="occasionally" id="occasionally" />
                          <Label htmlFor="occasionally">가끔 (분기별)</Label>
                        </div>
                      </RadioGroup>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 플레이 스타일 & 선호도 */}
              <motion.div variants={itemVariants}>
                <Card className="border-emerald-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-emerald-700">
                      <Target className="w-5 h-5" />
                      플레이 스타일 & 선호도
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label>플레이 스타일</Label>
                      <RadioGroup 
                        value={formData.playing_style} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, playing_style: value }))}
                        className="mt-2"
                      >
                        {playingStyles.map((style) => (
                          <div key={style} className="flex items-center space-x-2">
                            <RadioGroupItem value={style} id={style} />
                            <Label htmlFor={style}>{style}</Label>
                          </div>
                        ))}
                      </RadioGroup>
                    </div>
                    <div>
                      <Label>선호하는 코스 타입 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {courseTypes.map((course) => (
                          <div key={course} className="flex items-center space-x-2">
                            <Checkbox
                              id={course}
                              checked={formData.preferred_courses.includes(course)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange(course, checked as boolean, 'preferred_courses')
                              }
                            />
                            <Label htmlFor={course} className="text-sm">{course}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <Label>자신있는 클럽 (복수 선택)</Label>
                      <div className="grid grid-cols-2 gap-2 mt-2">
                        {favoriteClubs.map((club) => (
                          <div key={club} className="flex items-center space-x-2">
                            <Checkbox
                              id={club}
                              checked={formData.favorite_clubs.includes(club)}
                              onCheckedChange={(checked) => 
                                handleCheckboxChange(club, checked as boolean, 'favorite_clubs')
                              }
                            />
                            <Label htmlFor={club} className="text-sm">{club}</Label>
                          </div>
                        ))}
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 골프 목표 & 경험 */}
              <motion.div variants={itemVariants}>
                <Card className="border-lime-200">
                  <CardHeader className="pb-4">
                    <CardTitle className="flex items-center gap-2 text-lime-700">
                      <Star className="w-5 h-5" />
                      골프 목표 & 경험
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div>
                      <Label htmlFor="golf_goals">현재 골프 목표</Label>
                      <Textarea
                        id="golf_goals"
                        placeholder="예: 핸디캡 10 달성, 처음으로 파 브레이크, 드라이빙 거리 250야드 등..."
                        value={formData.golf_goals}
                        onChange={(e) => setFormData(prev => ({ ...prev, golf_goals: e.target.value }))}
                        className="mt-1 min-h-[60px]"
                      />
                    </div>
                    <div>
                      <Label htmlFor="biggest_challenge">가장 어려워하는 부분</Label>
                      <Textarea
                        id="biggest_challenge"
                        placeholder="예: 드라이버 슬라이스, 어프로치 거리 조절, 퍼팅 방향성 등..."
                        value={formData.biggest_challenge}
                        onChange={(e) => setFormData(prev => ({ ...prev, biggest_challenge: e.target.value }))}
                        className="mt-1 min-h-[60px]"
                      />
                    </div>
                    <div>
                      <Label htmlFor="memorable_moment">가장 기억에 남는 골프 순간 (선택사항)</Label>
                      <Textarea
                        id="memorable_moment"
                        placeholder="홀인원, 이글, 첫 파 브레이크 등 특별한 순간을 적어주세요..."
                        value={formData.memorable_moment}
                        onChange={(e) => setFormData(prev => ({ ...prev, memorable_moment: e.target.value }))}
                        className="mt-1 min-h-[60px]"
                      />
                    </div>
                    <div>
                      <Label htmlFor="playing_partners">주로 함께 플레이하는 사람</Label>
                      <Input
                        id="playing_partners"
                        placeholder="예: 직장 동료, 가족, 친구, 혼자서 등..."
                        value={formData.playing_partners}
                        onChange={(e) => setFormData(prev => ({ ...prev, playing_partners: e.target.value }))}
                        className="mt-1"
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
                  className="w-full bg-gradient-to-r from-lime-500 to-green-500 hover:from-lime-600 hover:to-green-600 text-white py-6 text-lg font-semibold"
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
                      <CircleDot className="w-5 h-5" />
                      골프 운세 분석하기
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
                <Card className="bg-gradient-to-r from-lime-500 to-green-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className="flex items-center justify-center gap-2 mb-4">
                      <Trophy className="w-6 h-6" />
                      <span className="text-xl font-medium">{formData.name}님의 골프 운세</span>
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
                    <CardTitle className="flex items-center gap-2 text-lime-600">
                      <BarChart3 className="w-5 h-5" />
                      세부 골프 운세
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "드라이빙운", score: result.driving_luck, icon: Zap, desc: "티샷과 장거리 샷의 운" },
                      { label: "아이언샷운", score: result.iron_luck, icon: Target, desc: "정확성과 어프로치의 운" },
                      { label: "퍼팅운", score: result.putting_luck, icon: CircleDot, desc: "그린에서의 마무리 운" },
                      { label: "코스관리운", score: result.course_management_luck, icon: Compass, desc: "전략적 플레이와 판단력의 운" }
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
                                className="bg-lime-500 h-2 rounded-full"
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
                      골프 SWOT 분석
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
                          <CloudRain className="w-4 h-4" />
                          위협 (Threat)
                        </h4>
                        <p className="text-orange-700 text-sm">{result.analysis.threat}</p>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 행운의 골프 요소 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-purple-600">
                      <Crown className="w-5 h-5" />
                      행운의 골프 요소
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      <div className="p-4 bg-purple-50 rounded-lg">
                        <h4 className="font-medium text-purple-800 mb-2 flex items-center gap-2">
                          <Mountain className="w-4 h-4" />
                          행운의 코스 타입
                        </h4>
                        <p className="text-lg font-semibold text-purple-700">{result.lucky_elements.course_type}</p>
                      </div>
                      <div className="p-4 bg-indigo-50 rounded-lg">
                        <h4 className="font-medium text-indigo-800 mb-2 flex items-center gap-2">
                          <Clock className="w-4 h-4" />
                          행운의 티타임
                        </h4>
                        <p className="text-lg font-semibold text-indigo-700">{result.lucky_elements.tee_time}</p>
                      </div>
                      <div className="p-4 bg-teal-50 rounded-lg">
                        <h4 className="font-medium text-teal-800 mb-2 flex items-center gap-2">
                          <Sun className="w-4 h-4" />
                          행운의 날씨
                        </h4>
                        <p className="text-lg font-semibold text-teal-700">{result.lucky_elements.weather}</p>
                      </div>
                      <div className="p-4 bg-emerald-50 rounded-lg">
                        <h4 className="font-medium text-emerald-800 mb-2 flex items-center gap-2">
                          <Compass className="w-4 h-4" />
                          행운의 방향
                        </h4>
                        <p className="text-lg font-semibold text-emerald-700">{result.lucky_elements.playing_direction} 방향</p>
                      </div>
                    </div>
                    <div className="grid gap-4">
                      <div className="p-4 bg-amber-50 rounded-lg">
                        <h4 className="font-medium text-amber-800 mb-2 flex items-center gap-2">
                          <Flag className="w-4 h-4" />
                          행운의 홀 번호
                        </h4>
                        <div className="flex flex-wrap gap-2">
                          {result.lucky_holes.map((hole, index) => (
                            <Badge key={index} variant="outline" className="border-amber-300 text-amber-700">
                              {hole}번홀
                            </Badge>
                          ))}
                        </div>
                      </div>
                      <div className="p-4 bg-green-50 rounded-lg">
                        <h4 className="font-medium text-green-800 mb-2 flex items-center gap-2">
                          <TreePine className="w-4 h-4" />
                          추천 골프장
                        </h4>
                        <div className="flex flex-wrap gap-2">
                          {result.course_recommendations.map((course, index) => (
                            <Badge key={index} variant="secondary" className="bg-green-100 text-green-700">
                              {course}
                            </Badge>
                          ))}
                        </div>
                      </div>
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 맞춤 골프 팁 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className="flex items-center gap-2 text-blue-600">
                      <TrendingUp className="w-5 h-5" />
                      맞춤 골프 팁
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Zap className="w-4 h-4 text-yellow-500" />
                        드라이빙 팁
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.driving_tips.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.6 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Star className="w-4 h-4 text-yellow-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{tip}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Target className="w-4 h-4 text-blue-500" />
                        어프로치 팁
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.approach_tips.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.8 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Crosshair className="w-4 h-4 text-blue-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{tip}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <CircleDot className="w-4 h-4 text-green-500" />
                        퍼팅 팁
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.putting_tips.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 1.0 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <CircleDot className="w-4 h-4 text-green-500 mt-0.5 flex-shrink-0" />
                            <p className="text-gray-700 text-sm">{tip}</p>
                          </motion.div>
                        ))}
                      </div>
                    </div>

                    <div>
                      <h4 className="font-medium text-gray-800 mb-3 flex items-center gap-2">
                        <Activity className="w-4 h-4 text-purple-500" />
                        멘탈 관리
                      </h4>
                      <div className="space-y-2">
                        {result.recommendations.mental_tips.map((tip, index) => (
                          <motion.div
                            key={index}
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 1.2 + index * 0.1 }}
                            className="flex items-start gap-2"
                          >
                            <Heart className="w-4 h-4 text-purple-500 mt-0.5 flex-shrink-0" />
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
                      골프 운세 예측
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

              {/* 다시 분석하기 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleReset}
                  variant="outline"
                  className="w-full border-lime-300 text-lime-600 hover:bg-lime-50 py-3"
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