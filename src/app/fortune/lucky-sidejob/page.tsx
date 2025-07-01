"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Progress } from "@/components/ui/progress";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  BriefcaseIcon,
  StarIcon,
  ClockIcon,
  MapPinIcon,
  UserIcon,
  CheckCircleIcon,
  AlertCircleIcon,
  DollarSignIcon,
  SparklesIcon,
  TrendingUpIcon,
  TimerIcon,
  NetworkIcon,
  BookOpenIcon,
  PiggyBankIcon,
  TargetIcon,
  AlertTriangleIcon,
  LightbulbIcon
} from "lucide-react";

interface SidejobInfo {
  name: string;
  birth_date: string;
  current_job?: string;
  available_time?: string;
  weekly_hours?: string;
  target_income?: string;
  skills?: string[];
  interests?: string[];
  startup_budget?: string;
  risk_tolerance?: string;
  work_location?: string;
  experience_level?: string;
}

interface SidejobFortune {
  overall_luck: number;
  income_luck: number;
  time_management_luck: number;
  opportunity_luck: number;
  networking_luck: number;
  recommended_sidejobs: {
    top_recommendation: {
      category: string;
      specific_job: string;
      compatibility: number;
      monthly_income_range: string;
      reasons: string[];
      required_skills: string[];
    };
    good_options: Array<{
      category: string;
      specific_job: string;
      compatibility: number;
      income_potential: string;
      time_commitment: string;
    }>;
    challenging_options: Array<{
      category: string;
      compatibility: number;
      challenges: string;
    }>;
  };
  lucky_elements: {
    time: string;
    day: string;
    platform: string;
    color: string;
    partner_type: string;
  };
  timing_advice: {
    start_period: string;
    peak_season: string;
    avoid_period: string;
  };
  skill_development: {
    priority_skills: string[];
    learning_resources: string[];
    certification_recommendations: string[];
  };
  financial_planning: {
    initial_investment: string;
    break_even_timeline: string;
    scaling_strategy: string;
    tax_considerations: string;
  };
  personalized_advice: {
    strengths: string;
    time_optimization: string;
    growth_strategy: string;
    networking_tips: string;
  };
  success_factors: string[];
  warning_signs: string[];
}

export default function LuckySideJobPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<SidejobInfo>({
    name: '',
    birth_date: '',
    current_job: '',
    available_time: '',
    weekly_hours: '',
    target_income: '',
    skills: [],
    interests: [],
    startup_budget: '',
    risk_tolerance: '',
    work_location: '',
    experience_level: ''
  });
  const [result, setResult] = useState<SidejobFortune | null>(null);

  const analyzeSidejobFortune = async (): Promise<SidejobFortune> => {
    try {
      const response = await fetch('/api/fortune/lucky-sidejob', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      if (!response.ok) {
        throw new Error('API 요청 실패');
      }

      const result = await response.json();
      return result;
    } catch (error) {
      console.error('부업 운세 분석 오류:', error);
      
      // 백업 로직
      const baseScore = Math.floor(Math.random() * 25) + 65;
      return {
        overall_luck: baseScore,
        income_luck: Math.max(40, Math.min(95, baseScore + Math.floor(Math.random() * 10) - 5)),
        time_management_luck: Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 12) - 6)),
        opportunity_luck: Math.max(45, Math.min(95, baseScore + Math.floor(Math.random() * 15) - 7)),
        networking_luck: Math.max(55, Math.min(100, baseScore + Math.floor(Math.random() * 8) - 4)),
        recommended_sidejobs: {
          top_recommendation: {
            category: '온라인 비즈니스',
            specific_job: '블로그/유튜브 운영',
            compatibility: 88,
            monthly_income_range: '30-150만원',
            reasons: ['개인 관심사와 높은 연관성', '현재 시장에서 수요 증가', '시간 투자 대비 효율성', '장기적 성장 가능성'],
            required_skills: ['콘텐츠 제작', '마케팅']
          },
          good_options: [
            { category: '프리랜싱', specific_job: '디자인 작업', compatibility: 82, income_potential: '40-180만원', time_commitment: '중간' },
            { category: '오프라인 서비스', specific_job: '과외/학원 강사', compatibility: 75, income_potential: '50-200만원', time_commitment: '높음' }
          ],
          challenging_options: [
            { category: '투자/재테크', compatibility: 65, challenges: '추가 학습과 초기 투자가 필요한 분야' }
          ]
        },
        lucky_elements: {
          time: '저녁 7-9시',
          day: '토요일',
          platform: '인스타그램',
          color: '오렌지',
          partner_type: '친구'
        },
        timing_advice: {
          start_period: '2-3월이 새로운 부업을 시작하기 좋은 시기입니다',
          peak_season: '하반기가 수익 증대의 황금기입니다',
          avoid_period: '연말연시와 휴가철에는 새로운 시도보다 기존 사업 정리에 집중하세요'
        },
        skill_development: {
          priority_skills: ['디지털 마케팅', '시간 관리', '고객 서비스', '재정 관리'],
          learning_resources: ['온라인 강의 플랫폼', '유튜브 무료 강의', '도서관 관련 서적', '업계 블로그'],
          certification_recommendations: ['구글 애널리틱스 자격증', '네이버 검색광고 자격증', '소상공인 창업 교육 수료증']
        },
        financial_planning: {
          initial_investment: '작은 자본으로 시작하여 점진적으로 확장하세요',
          break_even_timeline: '3-6개월 내 손익분기점 달성 가능',
          scaling_strategy: '초기 성과 확인 후 재투자를 통한 단계적 확장 추천',
          tax_considerations: '월 소득 33만원 초과 시 종합소득세 신고 준비 필요'
        },
        personalized_advice: {
          strengths: '꾸준함과 신중함으로 안정적인 성과를 만들 수 있습니다',
          time_optimization: '충분한 시간을 활용하여 다양한 기회를 시도해보세요',
          growth_strategy: '작은 성공을 통해 경험을 쌓고 점진적으로 규모를 키워가세요',
          networking_tips: '온라인 커뮤니티와 오프라인 모임을 적극 활용하여 정보를 교환하세요'
        },
        success_factors: ['꾸준한 시간 투자', '본업과의 균형', '고객 만족도', '시장 트렌드 파악', '재정 관리'],
        warning_signs: ['본업 지장 주의', '초기 투자 회수에 급급하지 마세요', '불법 제안 경계', '무리한 확장 주의']
      };
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const fortune = await analyzeSidejobFortune();
      setResult(fortune);
      setStep('result');
    } catch (error) {
      console.error('분석 실패:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSkillChange = (skill: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      skills: checked 
        ? [...(prev.skills || []), skill]
        : (prev.skills || []).filter(s => s !== skill)
    }));
  };

  const handleInterestChange = (interest: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      interests: checked 
        ? [...(prev.interests || []), interest]
        : (prev.interests || []).filter(i => i !== interest)
    }));
  };

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1
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
        stiffness: 100
      }
    }
  };

  if (step === 'input') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-yellow-50 via-orange-50 to-amber-50">
        <AppHeader />

        <motion.div
          className="container mx-auto px-4 pt-4 pb-20"
          variants={containerVariants}
          initial="hidden"
          animate="visible"
        >
          <motion.div variants={itemVariants} className="text-center mb-8">
            <div className="flex items-center justify-center gap-2 mb-4">
              <BriefcaseIcon className="h-8 w-8 text-yellow-600" />
              <h1 className="text-3xl font-bold bg-gradient-to-r from-yellow-600 to-orange-600 bg-clip-text text-transparent">
                행운의 부업
              </h1>
            </div>
            <p className="text-gray-600">
              당신에게 가장 적합한 부업과 성공 전략을 알아보세요
            </p>
          </motion.div>

          <motion.div variants={itemVariants}>
            <Card className="max-w-2xl mx-auto">
              <CardHeader>
                <CardTitle className="text-center">부업 정보 입력</CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={handleSubmit} className="space-y-6">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="name">이름 *</Label>
                      <Input
                        id="name"
                        value={formData.name}
                        onChange={(e) => setFormData({...formData, name: e.target.value})}
                        placeholder="홍길동"
                        required
                      />
                    </div>
                    <div>
                      <Label htmlFor="birth_date">생년월일 *</Label>
                      <Input
                        id="birth_date"
                        type="date"
                        value={formData.birth_date}
                        onChange={(e) => setFormData({...formData, birth_date: e.target.value})}
                        required
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="weekly_hours">주당 가능 시간</Label>
                      <Select
                        value={formData.weekly_hours}
                        onValueChange={(value) => setFormData({...formData, weekly_hours: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="주당 투입 가능 시간" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="5시간 이하">5시간 이하</SelectItem>
                          <SelectItem value="5-10시간">5-10시간</SelectItem>
                          <SelectItem value="10-15시간">10-15시간</SelectItem>
                          <SelectItem value="15-20시간">15-20시간</SelectItem>
                          <SelectItem value="20시간 이상">20시간 이상</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div>
                      <Label htmlFor="target_income">목표 월수입</Label>
                      <Select
                        value={formData.target_income}
                        onValueChange={(value) => setFormData({...formData, target_income: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="목표 월수입을 선택하세요" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="50만원 이하">50만원 이하</SelectItem>
                          <SelectItem value="50-100만원">50-100만원</SelectItem>
                          <SelectItem value="100-200만원">100-200만원</SelectItem>
                          <SelectItem value="200-300만원">200-300만원</SelectItem>
                          <SelectItem value="300만원 이상">300만원 이상</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <Label htmlFor="startup_budget">시작 예산</Label>
                      <Select
                        value={formData.startup_budget}
                        onValueChange={(value) => setFormData({...formData, startup_budget: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="초기 투자 가능 금액" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="50만원 이하">50만원 이하</SelectItem>
                          <SelectItem value="50-100만원">50-100만원</SelectItem>
                          <SelectItem value="100-200만원">100-200만원</SelectItem>
                          <SelectItem value="200만원 이상">200만원 이상</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div>
                      <Label htmlFor="risk_tolerance">위험 성향</Label>
                      <Select
                        value={formData.risk_tolerance}
                        onValueChange={(value) => setFormData({...formData, risk_tolerance: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="투자 위험 성향" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="안정형">안정형 (확실한 수익 추구)</SelectItem>
                          <SelectItem value="중간형">중간형 (적당한 위험 감수)</SelectItem>
                          <SelectItem value="도전형">도전형 (높은 수익 추구)</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div>
                    <Label>보유 스킬 (복수 선택 가능)</Label>
                    <div className="grid grid-cols-2 md:grid-cols-3 gap-2 mt-2">
                      {['마케팅', '디자인', '글쓰기', '영상편집', '프로그래밍', '외국어', '요리', '사진촬영', '교육'].map((skill) => (
                        <label key={skill} className="flex items-center space-x-2">
                          <input
                            type="checkbox"
                            checked={formData.skills?.includes(skill) || false}
                            onChange={(e) => handleSkillChange(skill, e.target.checked)}
                            className="rounded"
                          />
                          <span className="text-sm">{skill}</span>
                        </label>
                      ))}
                    </div>
                  </div>

                  <div>
                    <Label>관심 분야 (복수 선택 가능)</Label>
                    <div className="grid grid-cols-2 md:grid-cols-3 gap-2 mt-2">
                      {['IT/디지털', '교육/강의', '투자/재테크', '요리/음식', '운동/건강', '여행/문화', '패션/뷰티', '반려동물', '육아/가정'].map((interest) => (
                        <label key={interest} className="flex items-center space-x-2">
                          <input
                            type="checkbox"
                            checked={formData.interests?.includes(interest) || false}
                            onChange={(e) => handleInterestChange(interest, e.target.checked)}
                            className="rounded"
                          />
                          <span className="text-sm">{interest}</span>
                        </label>
                      ))}
                    </div>
                  </div>

                  <Button 
                    type="submit" 
                    className="w-full bg-yellow-600 hover:bg-yellow-700"
                    disabled={loading}
                  >
                    {loading ? '분석 중...' : '부업 운세 분석하기'}
                  </Button>
                </form>
              </CardContent>
            </Card>
          </motion.div>
        </motion.div>
      </div>
    );
  }

  if (!result) return null;

  return (
    <div className="min-h-screen bg-gradient-to-br from-yellow-50 via-orange-50 to-amber-50">
      <AppHeader />

      <motion.div
        className="container mx-auto px-4 pt-4 pb-20"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* 헤더 섹션 */}
        <motion.div variants={itemVariants} className="text-center mb-8">
          <div className="flex items-center justify-center gap-2 mb-4">
            <BriefcaseIcon className="h-8 w-8 text-yellow-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-yellow-600 to-orange-600 bg-clip-text text-transparent">
              {formData.name}님의 부업 운세
            </h1>
          </div>
          <p className="text-gray-600">
            개인 맞춤 부업 분석 결과입니다
          </p>
        </motion.div>

        {/* 종합 부업운 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 border-yellow-200 bg-gradient-to-r from-yellow-50 to-orange-50">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-yellow-700">
                <DollarSignIcon className="h-5 w-5" />
                종합 부업운
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-yellow-600 mb-2">{result.overall_luck}점</div>
              <Progress value={result.overall_luck} className="mb-4" />
              <p className="text-sm text-gray-600">
                {result.overall_luck >= 85 ? '부업 성공 가능성이 매우 높습니다' : 
                 result.overall_luck >= 70 ? '좋은 기회가 많이 기다리고 있습니다' : 
                 '꾸준한 노력으로 좋은 결과를 만들어보세요'}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 세부 운세 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="text-center">세부 분야별 운세</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <DollarSignIcon className="h-5 w-5 text-yellow-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-yellow-600">{result.income_luck}</div>
                  <div className="text-sm text-gray-500">수익 창출</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <TimerIcon className="h-5 w-5 text-orange-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-orange-600">{result.time_management_luck}</div>
                  <div className="text-sm text-gray-500">시간 관리</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <TrendingUpIcon className="h-5 w-5 text-amber-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-amber-600">{result.opportunity_luck}</div>
                  <div className="text-sm text-gray-500">기회 발견</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <NetworkIcon className="h-5 w-5 text-green-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-green-600">{result.networking_luck}</div>
                  <div className="text-sm text-gray-500">네트워킹</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 추천 부업 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <StarIcon className="h-5 w-5 text-yellow-500" />
                맞춤 부업 추천
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {/* 최고 추천 */}
                <div className="p-4 bg-gradient-to-r from-green-50 to-emerald-50 rounded-lg border border-green-200">
                  <div className="flex items-center justify-between mb-2">
                    <Badge className="bg-green-600 text-white">최고 추천</Badge>
                    <span className="font-bold text-green-600">{result.recommended_sidejobs.top_recommendation.compatibility}점</span>
                  </div>
                  <h4 className="font-bold text-lg mb-1">{result.recommended_sidejobs.top_recommendation.category}</h4>
                  <p className="text-gray-700 mb-2">{result.recommended_sidejobs.top_recommendation.specific_job}</p>
                  <p className="text-sm text-gray-600 mb-2">
                    <strong>예상 월수입:</strong> {result.recommended_sidejobs.top_recommendation.monthly_income_range}
                  </p>
                  <div className="text-sm text-gray-600 mb-2">
                    <strong>추천 이유:</strong>
                    <ul className="list-disc list-inside mt-1">
                      {result.recommended_sidejobs.top_recommendation.reasons.map((reason, index) => (
                        <li key={index}>{reason}</li>
                      ))}
                    </ul>
                  </div>
                  <div className="text-sm text-gray-600">
                    <strong>필요 스킬:</strong> {result.recommended_sidejobs.top_recommendation.required_skills.join(', ')}
                  </div>
                </div>

                {/* 좋은 옵션들 */}
                <div className="space-y-3">
                  {result.recommended_sidejobs.good_options.map((job, index) => (
                    <div key={index} className="p-3 bg-blue-50 rounded-lg border border-blue-200">
                      <div className="flex items-center justify-between mb-1">
                        <div>
                          <span className="font-medium">{job.category}</span>
                          <span className="text-gray-600 ml-2">- {job.specific_job}</span>
                        </div>
                        <Badge variant="outline" className="bg-blue-100 text-blue-700">{job.compatibility}점</Badge>
                      </div>
                      <div className="text-sm text-blue-700 grid grid-cols-2 gap-2">
                        <span>예상 수입: {job.income_potential}</span>
                        <span>시간 투입: {job.time_commitment}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 행운 요소 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <ClockIcon className="h-5 w-5 text-purple-500" />
                행운의 요소
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-3">
                  <div className="flex items-center gap-2">
                    <ClockIcon className="h-4 w-4 text-blue-500" />
                    <span className="text-sm font-medium">행운의 시간:</span>
                    <span className="text-sm text-blue-600">{result.lucky_elements.time}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <div className="h-4 w-4 bg-purple-500 rounded-full"></div>
                    <span className="text-sm font-medium">행운의 색상:</span>
                    <span className="text-sm text-purple-600">{result.lucky_elements.color}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <MapPinIcon className="h-4 w-4 text-green-500" />
                    <span className="text-sm font-medium">추천 플랫폼:</span>
                    <span className="text-sm text-green-600">{result.lucky_elements.platform}</span>
                  </div>
                </div>
                <div className="space-y-3">
                  <div className="flex items-center gap-2">
                    <StarIcon className="h-4 w-4 text-yellow-500" />
                    <span className="text-sm font-medium">행운의 요일:</span>
                    <span className="text-sm text-yellow-600">{result.lucky_elements.day}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <UserIcon className="h-4 w-4 text-orange-500" />
                    <span className="text-sm font-medium">협업 파트너:</span>
                    <span className="text-sm text-orange-600">{result.lucky_elements.partner_type}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 상세 조언 탭 */}
        <motion.div variants={itemVariants}>
          <Tabs defaultValue="timing" className="mb-6">
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="timing">타이밍</TabsTrigger>
              <TabsTrigger value="skills">스킬 개발</TabsTrigger>
              <TabsTrigger value="financial">재정 계획</TabsTrigger>
              <TabsTrigger value="advice">개인 조언</TabsTrigger>
            </TabsList>

            <TabsContent value="timing">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <div className="p-3 bg-green-50 rounded-lg">
                      <h4 className="font-medium text-green-800 mb-1">시작 시기</h4>
                      <p className="text-sm text-green-700">{result.timing_advice.start_period}</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-lg">
                      <h4 className="font-medium text-blue-800 mb-1">수익 성장기</h4>
                      <p className="text-sm text-blue-700">{result.timing_advice.peak_season}</p>
                    </div>
                    <div className="p-3 bg-yellow-50 rounded-lg">
                      <h4 className="font-medium text-yellow-800 mb-1">주의 기간</h4>
                      <p className="text-sm text-yellow-700">{result.timing_advice.avoid_period}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="skills">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <div>
                      <h4 className="font-medium mb-3">우선 개발 스킬</h4>
                      <div className="grid grid-cols-2 gap-2">
                        {result.skill_development.priority_skills.map((skill, index) => (
                          <div key={index} className="p-2 bg-teal-50 rounded border border-teal-200">
                            <span className="text-sm font-medium text-teal-800">{skill}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                    <div>
                      <h4 className="font-medium mb-2">학습 리소스</h4>
                      <ul className="text-sm space-y-1">
                        {result.skill_development.learning_resources.map((resource, index) => (
                          <li key={index} className="flex items-center gap-2">
                            <BookOpenIcon className="h-3 w-3 text-blue-500" />
                            {resource}
                          </li>
                        ))}
                      </ul>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="financial">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <div className="p-3 bg-green-50 rounded-lg">
                      <h4 className="font-medium text-green-800 mb-1">초기 투자</h4>
                      <p className="text-sm text-green-700">{result.financial_planning.initial_investment}</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-lg">
                      <h4 className="font-medium text-blue-800 mb-1">손익분기점</h4>
                      <p className="text-sm text-blue-700">{result.financial_planning.break_even_timeline}</p>
                    </div>
                    <div className="p-3 bg-purple-50 rounded-lg">
                      <h4 className="font-medium text-purple-800 mb-1">확장 전략</h4>
                      <p className="text-sm text-purple-700">{result.financial_planning.scaling_strategy}</p>
                    </div>
                    <div className="p-3 bg-amber-50 rounded-lg">
                      <h4 className="font-medium text-amber-800 mb-1">세무 고려사항</h4>
                      <p className="text-sm text-amber-700">{result.financial_planning.tax_considerations}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="advice">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <div className="p-3 bg-emerald-50 rounded-lg">
                      <h4 className="font-medium text-emerald-800 mb-1">나의 강점</h4>
                      <p className="text-sm text-emerald-700">{result.personalized_advice.strengths}</p>
                    </div>
                    <div className="p-3 bg-orange-50 rounded-lg">
                      <h4 className="font-medium text-orange-800 mb-1">시간 최적화</h4>
                      <p className="text-sm text-orange-700">{result.personalized_advice.time_optimization}</p>
                    </div>
                    <div className="p-3 bg-cyan-50 rounded-lg">
                      <h4 className="font-medium text-cyan-800 mb-1">성장 전략</h4>
                      <p className="text-sm text-cyan-700">{result.personalized_advice.growth_strategy}</p>
                    </div>
                    <div className="p-3 bg-rose-50 rounded-lg">
                      <h4 className="font-medium text-rose-800 mb-1">네트워킹 팁</h4>
                      <p className="text-sm text-rose-700">{result.personalized_advice.networking_tips}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>
          </Tabs>
        </motion.div>

        {/* 성공 요인 & 주의사항 */}
        <motion.div variants={itemVariants}>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-green-600">
                  <CheckCircleIcon className="h-5 w-5" />
                  성공 요인
                </CardTitle>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2">
                  {result.success_factors.map((factor, index) => (
                    <li key={index} className="flex items-start gap-2 text-sm">
                      <CheckCircleIcon className="h-4 w-4 text-green-500 mt-0.5 flex-shrink-0" />
                      <span>{factor}</span>
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-orange-600">
                  <AlertTriangleIcon className="h-5 w-5" />
                  주의사항
                </CardTitle>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2">
                  {result.warning_signs.map((warning, index) => (
                    <li key={index} className="flex items-start gap-2 text-sm">
                      <AlertTriangleIcon className="h-4 w-4 text-orange-500 mt-0.5 flex-shrink-0" />
                      <span>{warning}</span>
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          </div>
        </motion.div>

        {/* 다시 분석하기 버튼 */}
        <motion.div variants={itemVariants} className="text-center">
          <Button 
            onClick={() => setStep('input')}
            variant="outline"
            className="border-yellow-600 text-yellow-600 hover:bg-yellow-50"
          >
            다시 분석하기
          </Button>
        </motion.div>
      </motion.div>
    </div>
  );
}
