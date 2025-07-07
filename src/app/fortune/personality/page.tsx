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
import { DeterministicRandom } from '@/lib/deterministic-random';
import { 
  Brain, 
  Star, 
  Sparkles,
  ArrowRight,
  Shuffle,
  Heart,
  Target,
  Users,
  TrendingUp,
  Shield,
  Lightbulb,
  Zap,
  Eye,
  Compass,
  Crown,
  TreePine,
  Sun,
  Moon,
  Coffee,
  Book
} from "lucide-react";

interface UserInfo {
  name: string;
  birth_date: string;
  zodiac_sign: string;
  mbti_type: string;
  life_goals: string[];
  stress_triggers: string[];
  favorite_activities: string[];
  relationship_style: string;
  work_style: string;
  communication_style: string;
  notes: string;
}

interface PersonalityTrait {
  name: string;
  score: number;
  description: string;
  strengths: string[];
  areas_for_growth: string[];
  icon: any;
  color: string;
}

interface PersonalityResult {
  personality_type: string;
  core_traits: PersonalityTrait[];
  strengths: string[];
  challenges: string[];
  career_recommendations: string[];
  relationship_advice: string[];
  personal_growth_tips: string[];
  lucky_elements: {
    color: string;
    number: number;
    direction: string;
    time: string;
  };
  compatibility_analysis: {
    [key: string]: number;
  };
  life_advice: string;
  overall_score: number;
}

const zodiacSigns = [
  "양자리", "황소자리", "쌍둥이자리", "게자리", "사자자리", "처녀자리",
  "천칭자리", "전갈자리", "사수자리", "염소자리", "물병자리", "물고기자리"
];

const mbtiTypes = [
  "INTJ", "INTP", "ENTJ", "ENTP", "INFJ", "INFP", "ENFJ", "ENFP",
  "ISTJ", "ISFJ", "ESTJ", "ESFJ", "ISTP", "ISFP", "ESTP", "ESFP"
];

const lifeGoals = [
  "경제적 안정", "자아실현", "가족 행복", "사회적 성공", "건강한 삶", "인간관계", "학습과 성장", "창조적 활동"
];

const stressTriggers = [
  "시간 압박", "대인관계 갈등", "불확실성", "변화", "과도한 책임", "비판", "단조로움", "완벽주의"
];

const activities = [
  "독서", "운동", "음악감상", "여행", "요리", "게임", "영화관람", "친구모임", "혼자만의 시간", "새로운 도전"
];

const relationshipStyles = [
  "친밀하고 깊은 관계 선호", "다양한 사람들과 넓은 인맥", "소수의 진실한 친구", "새로운 만남을 즐김"
];

const workStyles = [
  "체계적이고 계획적", "창의적이고 자유로운", "협력적이고 팀워크 중시", "독립적이고 자율적"
];

const communicationStyles = [
  "직설적이고 명확한", "부드럽고 배려하는", "논리적이고 분석적", "감정적이고 공감하는"
];

export default function PersonalityPage() {
  // Initialize deterministic random for consistent results
  // Get actual user ID from auth context
  const { user } = useAuth();
  const userId = user?.id || 'guest-user';
  const today = new Date().toISOString().split('T')[0];
  const fortuneType = 'page';
  const deterministicRandom = new DeterministicRandom(userId, today, fortuneType);

  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<UserInfo>({
    name: '',
    birth_date: '',
    zodiac_sign: '',
    mbti_type: '',
    life_goals: [],
    stress_triggers: [],
    favorite_activities: [],
    relationship_style: '',
    work_style: '',
    communication_style: '',
    notes: ''
  });
  const [result, setResult] = useState<PersonalityResult | null>(null);

  const analyzePersonality = async (): Promise<PersonalityResult> => {
    // Mock data - 실제로는 GPT-4.1 Nano API 호출
    const traits = [
      {
        name: "창의성",
        score: deterministicRandom.randomInt(60, 60 + 40 - 1),
        description: "새로운 아이디어를 생각해내고 독창적인 해결책을 찾는 능력",
        strengths: ["혁신적 사고", "문제해결력", "예술적 감각"],
        areas_for_growth: ["실행력 향상", "세부사항 관리"],
        icon: Lightbulb,
        color: "#FFD700"
      },
      {
        name: "리더십",
        score: deterministicRandom.randomInt(60, 60 + 40 - 1),
        description: "다른 사람들을 이끌고 영감을 주는 자연스러운 능력",
        strengths: ["결정력", "비전 제시", "동기부여"],
        areas_for_growth: ["경청 능력", "팀원 배려"],
        icon: Crown,
        color: "#8A2BE2"
      },
      {
        name: "공감능력",
        score: deterministicRandom.randomInt(60, 60 + 40 - 1),
        description: "타인의 감정을 이해하고 공감하는 뛰어난 능력",
        strengths: ["인간관계", "소통능력", "갈등조정"],
        areas_for_growth: ["객관적 판단", "경계설정"],
        icon: Heart,
        color: "#FF69B4"
      },
      {
        name: "분석력",
        score: deterministicRandom.randomInt(60, 60 + 40 - 1),
        description: "복잡한 정보를 체계적으로 분석하고 패턴을 파악하는 능력",
        strengths: ["논리적 사고", "문제 진단", "데이터 해석"],
        areas_for_growth: ["직감 활용", "빠른 결정"],
        icon: Eye,
        color: "#4169E1"
      },
      {
        name: "적응력",
        score: deterministicRandom.randomInt(60, 60 + 40 - 1),
        description: "변화하는 환경에 유연하게 적응하는 능력",
        strengths: ["변화 수용", "빠른 학습", "스트레스 관리"],
        areas_for_growth: ["일관성 유지", "장기 계획"],
        icon: TreePine,
        color: "#228B22"
      }
    ];

    return {
      personality_type: "창의적 리더형",
      core_traits: traits,
      strengths: [
        "뛰어난 창의적 사고력",
        "강한 리더십과 추진력",
        "우수한 인간관계 능력",
        "빠른 학습능력과 적응력"
      ],
      challenges: [
        "완벽주의적 성향으로 인한 스트레스",
        "세부사항보다 큰 그림에 집중",
        "감정적 결정을 내리는 경향",
        "루틴한 업무에 대한 지루함"
      ],
      career_recommendations: [
        "창업가, CEO",
        "크리에이티브 디렉터",
        "컨설턴트",
        "프로젝트 매니저",
        "작가, 아티스트",
        "심리상담사"
      ],
      relationship_advice: [
        "개인적 공간과 시간을 존중해주는 파트너를 찾으세요",
        "깊이 있는 대화를 나눌 수 있는 관계를 추구하세요",
        "상대방의 의견을 경청하는 노력을 기울이세요",
        "감정 표현을 더욱 솔직하게 해보세요"
      ],
      personal_growth_tips: [
        "명상이나 요가로 내면의 평화를 찾으세요",
        "새로운 도전을 통해 성장 동력을 얻으세요",
        "피드백을 적극적으로 수용하세요",
        "작은 목표들을 설정하고 달성해보세요",
        "감사 일기를 써보세요"
      ],
      lucky_elements: {
        color: "골드",
        number: 7,
        direction: "동쪽",
        time: "오전 9-11시"
      },
      compatibility_analysis: {
        "직장동료": 85,
        "연인관계": 78,
        "친구관계": 92,
        "가족관계": 80,
        "리더역할": 88
      },
      life_advice: "당신은 타고난 리더이면서 동시에 창의적인 영혼을 가지고 있습니다. 자신의 비전을 믿고 꾸준히 나아가되, 주변 사람들의 의견도 귀 기울여 듣는 것이 중요합니다. 완벽을 추구하기보다는 진전에 집중하며, 실패를 두려워하지 말고 새로운 도전을 계속해나가세요.",
      overall_score: deterministicRandom.randomInt(80, 80 + 20 - 1)
    };
  };

  const handleSubmit = async () => {
    if (!formData.name || !formData.birth_date || !formData.zodiac_sign) {
      alert('필수 정보를 모두 입력해주세요.');
      return;
    }

    setLoading(true);
    try {
      const analysisResult = await analyzePersonality();
      setResult(analysisResult);
      setStep('result');
    } catch (error) {
      console.error('Error analyzing personality:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setLoading(false);
    }
  };

  const handleCheckboxChange = (category: keyof Pick<UserInfo, 'life_goals' | 'stress_triggers' | 'favorite_activities'>, value: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      [category]: checked 
        ? [...prev[category], value]
        : prev[category].filter(item => item !== value)
    }));
  };

  const handleReset = () => {
    setStep('input');
    setResult(null);
    setFormData({
      name: '',
      birth_date: '',
      zodiac_sign: '',
      mbti_type: '',
      life_goals: [],
      stress_triggers: [],
      favorite_activities: [],
      relationship_style: '',
      work_style: '',
      communication_style: '',
      notes: ''
    });
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-100">
      <AppHeader />
      
      <div className="container mx-auto px-4 pt-20 pb-8">
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="max-w-4xl mx-auto"
        >
          <motion.div className="text-center mb-8">
            <div className="flex items-center justify-center gap-3 mb-4">
              <div className="p-3 bg-gradient-to-r from-blue-500 to-purple-500 rounded-full">
                <Brain className="w-8 h-8 text-white" />
              </div>
              <h1 className="text-4xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
                성격 분석
              </h1>
            </div>
            <p className="text-lg text-gray-600 mb-6">
              당신의 숨겨진 성격과 잠재력을 깊이 있게 분석해드립니다
            </p>
          </motion.div>

          <AnimatePresence mode="wait">
            {step === 'input' && (
              <motion.div
                key="input"
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                transition={{ duration: 0.3 }}
              >
                <Card className="shadow-lg border-0 bg-white/70 backdrop-blur-sm">
                  <CardHeader className="text-center">
                    <CardTitle className="text-2xl text-gray-800 flex items-center justify-center gap-2">
                      <Sparkles className="w-6 h-6 text-blue-500" />
                      성격 분석 정보 입력
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    {/* 기본 정보 */}
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <div className="space-y-2">
                        <Label htmlFor="name">이름 *</Label>
                        <Input
                          id="name"
                          value={formData.name}
                          onChange={(e) => setFormData(prev => ({ ...prev, name: e.target.value }))}
                          placeholder="이름을 입력하세요"
                        />
                      </div>
                      <div className="space-y-2">
                        <KoreanDatePicker
                          label="생년월일"
                          value={formData.birth_date}
                          onChange={(date) => setFormData(prev => ({ ...prev, birth_date: date }))}
                          placeholder="생년월일을 선택하세요"
                          required
                        />
                      </div>
                    </div>

                    {/* 별자리 */}
                    <div className="space-y-3">
                      <Label>별자리 *</Label>
                      <RadioGroup 
                        value={formData.zodiac_sign} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, zodiac_sign: value }))}
                      >
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-2">
                          {zodiacSigns.map((sign) => (
                            <div key={sign} className="flex items-center space-x-2">
                              <RadioGroupItem value={sign} id={sign} />
                              <Label htmlFor={sign} className="text-sm">{sign}</Label>
                            </div>
                          ))}
                        </div>
                      </RadioGroup>
                    </div>

                    {/* MBTI */}
                    <div className="space-y-3">
                      <Label>MBTI 유형 (선택사항)</Label>
                      <RadioGroup 
                        value={formData.mbti_type} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, mbti_type: value }))}
                      >
                        <div className="grid grid-cols-4 md:grid-cols-8 gap-2">
                          {mbtiTypes.map((type) => (
                            <div key={type} className="flex items-center space-x-2">
                              <RadioGroupItem value={type} id={type} />
                              <Label htmlFor={type} className="text-sm">{type}</Label>
                            </div>
                          ))}
                        </div>
                      </RadioGroup>
                    </div>

                    {/* 인생 목표 */}
                    <div className="space-y-3">
                      <Label>인생에서 중요하게 생각하는 것 (복수 선택 가능)</Label>
                      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                        {lifeGoals.map((goal) => (
                          <div key={goal} className="flex items-center space-x-2">
                            <Checkbox
                              id={goal}
                              checked={formData.life_goals.includes(goal)}
                              onCheckedChange={(checked) => handleCheckboxChange('life_goals', goal, checked as boolean)}
                            />
                            <Label htmlFor={goal} className="text-sm">{goal}</Label>
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* 스트레스 요인 */}
                    <div className="space-y-3">
                      <Label>스트레스를 받는 상황 (복수 선택 가능)</Label>
                      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                        {stressTriggers.map((trigger) => (
                          <div key={trigger} className="flex items-center space-x-2">
                            <Checkbox
                              id={trigger}
                              checked={formData.stress_triggers.includes(trigger)}
                              onCheckedChange={(checked) => handleCheckboxChange('stress_triggers', trigger, checked as boolean)}
                            />
                            <Label htmlFor={trigger} className="text-sm">{trigger}</Label>
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* 좋아하는 활동 */}
                    <div className="space-y-3">
                      <Label>좋아하는 활동 (복수 선택 가능)</Label>
                      <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
                        {activities.map((activity) => (
                          <div key={activity} className="flex items-center space-x-2">
                            <Checkbox
                              id={activity}
                              checked={formData.favorite_activities.includes(activity)}
                              onCheckedChange={(checked) => handleCheckboxChange('favorite_activities', activity, checked as boolean)}
                            />
                            <Label htmlFor={activity} className="text-sm">{activity}</Label>
                          </div>
                        ))}
                      </div>
                    </div>

                    {/* 관계 스타일 */}
                    <div className="space-y-3">
                      <Label>인간관계 스타일</Label>
                      <RadioGroup 
                        value={formData.relationship_style} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, relationship_style: value }))}
                      >
                        <div className="space-y-2">
                          {relationshipStyles.map((style) => (
                            <div key={style} className="flex items-center space-x-2">
                              <RadioGroupItem value={style} id={style} />
                              <Label htmlFor={style} className="text-sm">{style}</Label>
                            </div>
                          ))}
                        </div>
                      </RadioGroup>
                    </div>

                    {/* 업무 스타일 */}
                    <div className="space-y-3">
                      <Label>업무 스타일</Label>
                      <RadioGroup 
                        value={formData.work_style} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, work_style: value }))}
                      >
                        <div className="space-y-2">
                          {workStyles.map((style) => (
                            <div key={style} className="flex items-center space-x-2">
                              <RadioGroupItem value={style} id={style} />
                              <Label htmlFor={style} className="text-sm">{style}</Label>
                            </div>
                          ))}
                        </div>
                      </RadioGroup>
                    </div>

                    {/* 소통 스타일 */}
                    <div className="space-y-3">
                      <Label>소통 스타일</Label>
                      <RadioGroup 
                        value={formData.communication_style} 
                        onValueChange={(value) => setFormData(prev => ({ ...prev, communication_style: value }))}
                      >
                        <div className="space-y-2">
                          {communicationStyles.map((style) => (
                            <div key={style} className="flex items-center space-x-2">
                              <RadioGroupItem value={style} id={style} />
                              <Label htmlFor={style} className="text-sm">{style}</Label>
                            </div>
                          ))}
                        </div>
                      </RadioGroup>
                    </div>

                    {/* 추가 메모 */}
                    <div className="space-y-2">
                      <Label htmlFor="notes">추가로 알려주고 싶은 것</Label>
                      <Textarea
                        id="notes"
                        value={formData.notes}
                        onChange={(e) => setFormData(prev => ({ ...prev, notes: e.target.value }))}
                        placeholder="성격이나 특성에 대해 더 알려주고 싶은 내용이 있다면 적어주세요"
                        rows={3}
                      />
                    </div>

                    <Button 
                      onClick={handleSubmit}
                      disabled={loading}
                      className="w-full bg-gradient-to-r from-blue-500 to-purple-500 hover:from-blue-600 hover:to-purple-600 text-white py-3 text-lg font-semibold"
                    >
                      {loading ? (
                        <div className="flex items-center gap-2">
                          <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                          성격 분석 중...
                        </div>
                      ) : (
                        <div className="flex items-center gap-2">
                          <Brain className="w-5 h-5" />
                          나의 성격 분석 시작하기
                          <ArrowRight className="w-5 h-5" />
                        </div>
                      )}
                    </Button>
                  </CardContent>
                </Card>
              </motion.div>
            )}

            {step === 'result' && result && (
              <motion.div
                key="result"
                initial={{ opacity: 0, x: 20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ duration: 0.3 }}
                className="space-y-6"
              >
                {/* 성격 유형 */}
                <Card className="shadow-lg border-0 bg-white/70 backdrop-blur-sm">
                  <CardHeader className="text-center">
                    <CardTitle className="text-3xl text-gray-800 flex items-center justify-center gap-2">
                      <Crown className="w-8 h-8 text-purple-500" />
                      {formData.name}님은 {result.personality_type}
                    </CardTitle>
                    <div className="text-2xl font-bold text-purple-600 mt-2">
                      전체 점수: {result.overall_score}점
                    </div>
                  </CardHeader>
                  <CardContent>
                    <div className="text-center text-lg text-gray-600 leading-relaxed">
                      {result.life_advice}
                    </div>
                  </CardContent>
                </Card>

                {/* 핵심 성격 특성 */}
                <Card className="shadow-lg border-0 bg-white/70 backdrop-blur-sm">
                  <CardHeader>
                    <CardTitle className="text-xl text-gray-800 flex items-center gap-2">
                      <Star className="w-5 h-5" />
                      핵심 성격 특성
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      {result.core_traits.map((trait, index) => (
                        <div key={index} className="p-4 rounded-lg bg-gray-50">
                          <div className="flex items-center justify-between mb-3">
                            <div className="flex items-center gap-3">
                              <trait.icon className="w-6 h-6" style={{ color: trait.color }} />
                              <h4 className="font-bold text-lg">{trait.name}</h4>
                            </div>
                            <div className="text-2xl font-bold" style={{ color: trait.color }}>
                              {trait.score}점
                            </div>
                          </div>
                          <p className="text-gray-600 mb-3">{trait.description}</p>
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                              <h5 className="font-semibold text-green-600 mb-2">강점</h5>
                              <ul className="text-sm space-y-1">
                                {trait.strengths.map((strength, idx) => (
                                  <li key={idx} className="text-gray-600 dark:text-gray-400">• {strength}</li>
                                ))}
                              </ul>
                            </div>
                            <div>
                              <h5 className="font-semibold text-orange-600 dark:text-orange-400 mb-2">성장 포인트</h5>
                              <ul className="text-sm space-y-1">
                                {trait.areas_for_growth.map((area, idx) => (
                                  <li key={idx} className="text-gray-600 dark:text-gray-400">• {area}</li>
                                ))}
                              </ul>
                            </div>
                          </div>
                          <div className="mt-3">
                            <div className="w-full bg-gray-200 rounded-full h-2">
                              <div 
                                className="h-2 rounded-full transition-all duration-1000"
                                style={{ 
                                  width: `${trait.score}%`, 
                                  backgroundColor: trait.color 
                                }}
                              />
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>

                {/* 강점과 도전과제 */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <Card className="shadow-lg border-0 bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm">
                    <CardHeader>
                      <CardTitle className="text-xl text-gray-800 dark:text-gray-200 flex items-center gap-2">
                        <TrendingUp className="w-5 h-5 text-green-500 dark:text-green-400" />
                        주요 강점
                      </CardTitle>
                    </CardHeader>
                    <CardContent>
                      <ul className="space-y-2">
                        {result.strengths.map((strength, index) => (
                          <li key={index} className="flex items-start gap-2 text-gray-600 dark:text-gray-400">
                            <Zap className="w-4 h-4 text-green-500 dark:text-green-400 mt-1 flex-shrink-0" />
                            {strength}
                          </li>
                        ))}
                      </ul>
                    </CardContent>
                  </Card>

                  <Card className="shadow-lg border-0 bg-white/70 dark:bg-gray-800/70 backdrop-blur-sm">
                    <CardHeader>
                      <CardTitle className="text-xl text-gray-800 dark:text-gray-200 flex items-center gap-2">
                        <Target className="w-5 h-5 text-orange-500 dark:text-orange-400" />
                        도전과제
                      </CardTitle>
                    </CardHeader>
                    <CardContent>
                      <ul className="space-y-2">
                        {result.challenges.map((challenge, index) => (
                          <li key={index} className="flex items-start gap-2 text-gray-600 dark:text-gray-400">
                            <Shield className="w-4 h-4 text-orange-500 dark:text-orange-400 mt-1 flex-shrink-0" />
                            {challenge}
                          </li>
                        ))}
                      </ul>
                    </CardContent>
                  </Card>
                </div>

                <div className="flex gap-3 pt-4">
                  <Button 
                    onClick={handleReset}
                    variant="outline"
                    className="flex-1"
                  >
                    <Shuffle className="w-4 h-4 mr-2" />
                    다시 분석하기
                  </Button>
                  <Button 
                    onClick={() => window.print()}
                    className="flex-1 bg-gradient-to-r from-blue-500 to-purple-500 hover:from-blue-600 hover:to-purple-600"
                  >
                    결과 저장하기
                  </Button>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </motion.div>
      </div>
    </div>
  );
} 