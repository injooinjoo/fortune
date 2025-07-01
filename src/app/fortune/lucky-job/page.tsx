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
  Sparkles,
  StarIcon,
  CheckCircleIcon,
  ClockIcon,
  TrendingUpIcon,
  UsersIcon,
  BookOpenIcon,
  LightbulbIcon,
  TargetIcon,
  AlertTriangleIcon,
  UserIcon
} from "lucide-react";

interface JobInfo {
  name: string;
  birth_date: string;
  mbti?: string;
  current_position?: string;
  job_experience?: string;
  preferred_fields?: string[];
  work_style?: string;
  salary_expectations?: string;
  career_goals?: string;
  skills?: string[];
  education?: string;
  location_preference?: string;
}

interface JobFortune {
  overall_luck: number;
  career_luck: number;
  interview_luck: number;
  networking_luck: number;
  learning_luck: number;
  recommended_jobs: {
    best_match: {
      field: string;
      position: string;
      compatibility: number;
      reasons: string[];
    };
    good_matches: Array<{
      field: string;
      position: string;
      compatibility: number;
      strengths: string;
    }>;
    challenging_fields: Array<{
      field: string;
      compatibility: number;
      challenges: string;
    }>;
  };
  lucky_elements: {
    time: string;
    day: string;
    color: string;
    keyword: string;
    network_person: string;
  };
  mbti_analysis?: {
    strengths: string[];
    suitable_environments: string[];
    leadership_style: string;
    communication_style: string;
  };
  skill_recommendations: string[];
  timing_advice: {
    job_search: string;
    interview_period: string;
    career_change: string;
  };
  personalized_advice: {
    strengths: string;
    development_areas: string;
    networking_tips: string;
    interview_tips: string;
  };
  success_factors: string[];
  warning_signs: string[];
}

export default function LuckyJobPage() {
  const [step, setStep] = useState<'input' | 'result'>('input');
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<JobInfo>({
    name: '',
    birth_date: '',
    mbti: '',
    current_position: '',
    job_experience: '',
    preferred_fields: [],
    work_style: '',
    salary_expectations: '',
    career_goals: '',
    skills: [],
    education: '',
    location_preference: ''
  });
  const [result, setResult] = useState<JobFortune | null>(null);

  const analyzeJobFortune = async (): Promise<JobFortune> => {
    try {
      const response = await fetch('/api/fortune/lucky-job', {
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
      console.error('직업 운세 분석 오류:', error);
      
      // 백업 로직
      const baseScore = Math.floor(Math.random() * 25) + 65;
      return {
        overall_luck: baseScore,
        career_luck: Math.max(40, Math.min(95, baseScore + Math.floor(Math.random() * 10) - 5)),
        interview_luck: Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 15) - 7)),
        networking_luck: Math.max(45, Math.min(95, baseScore + Math.floor(Math.random() * 12) - 6)),
        learning_luck: Math.max(55, Math.min(100, baseScore + Math.floor(Math.random() * 8) - 4)),
        recommended_jobs: {
          best_match: {
            field: 'IT/소프트웨어',
            position: '소프트웨어 엔지니어',
            compatibility: 92,
            reasons: ['높은 성장 잠재력', '시장 전망 밝음', '개인 적성 부합', '안정적 수익']
          },
          good_matches: [
            { field: '경영/기획', position: '마케팅 매니저', compatibility: 85, strengths: '창의성과 분석력 활용' },
            { field: '교육/연구', position: '교육 컨설턴트', compatibility: 78, strengths: '소통 능력과 전문성' }
          ],
          challenging_fields: [
            { field: '금융/투자', compatibility: 65, challenges: '추가 자격증 취득 필요' }
          ]
        },
        lucky_elements: {
          time: '오전 10-12시',
          day: '화요일',
          color: '네이비 블루',
          keyword: '전문성',
          network_person: '선배'
        },
        mbti_analysis: formData.mbti ? {
          strengths: ['창의성', '소통력', '분석력'],
          suitable_environments: ['협업 중심', '자율적', '학습 지향'],
          leadership_style: '참여형 리더십',
          communication_style: '개방적이고 협력적'
        } : undefined,
        skill_recommendations: ['데이터 분석', '프로젝트 관리', '커뮤니케이션'],
        timing_advice: {
          job_search: '하반기가 좋은 기회의 시기입니다.',
          interview_period: '봄과 가을이 면접에 유리합니다.',
          career_change: '3-5월이 전직에 적합한 시기입니다.'
        },
        personalized_advice: {
          strengths: '지속적인 학습 의욕과 적응력이 강점입니다.',
          development_areas: '전문성을 더욱 깊이 있게 발전시키세요.',
          networking_tips: '업계 세미나와 커뮤니티를 적극 활용하세요.',
          interview_tips: '구체적인 성과와 경험을 준비하여 어필하세요.'
        },
        success_factors: ['지속적 학습', '전문성 강화', '긍정적 관계', '목표 설정', '트렌드 파악'],
        warning_signs: ['급한 결정 금지', '연봉만 고려 금지', '문화 불일치 주의', '번아웃 방지']
      };
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      const fortune = await analyzeJobFortune();
      setResult(fortune);
      setStep('result');
    } catch (error) {
      console.error('분석 실패:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleFieldChange = (field: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      preferred_fields: checked 
        ? [...(prev.preferred_fields || []), field]
        : (prev.preferred_fields || []).filter(f => f !== field)
    }));
  };

  const handleSkillChange = (skill: string, checked: boolean) => {
    setFormData(prev => ({
      ...prev,
      skills: checked 
        ? [...(prev.skills || []), skill]
        : (prev.skills || []).filter(s => s !== skill)
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
      <div className="min-h-screen bg-gradient-to-br from-teal-50 via-cyan-50 to-emerald-50">
        <AppHeader />

        <motion.div
          className="container mx-auto px-4 pt-4 pb-20"
          variants={containerVariants}
          initial="hidden"
          animate="visible"
        >
          <motion.div variants={itemVariants} className="text-center mb-8">
            <div className="flex items-center justify-center gap-2 mb-4">
              <BriefcaseIcon className="h-8 w-8 text-teal-600" />
              <h1 className="text-3xl font-bold bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
                행운의 직업
              </h1>
            </div>
            <p className="text-gray-600">
              당신에게 가장 적합한 직업과 성공 전략을 알아보세요
            </p>
          </motion.div>

          <motion.div variants={itemVariants}>
            <Card className="max-w-2xl mx-auto">
              <CardHeader>
                <CardTitle className="text-center">직업 적성 정보 입력</CardTitle>
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
                      <Label htmlFor="mbti">MBTI</Label>
                      <Input
                        id="mbti"
                        value={formData.mbti}
                        onChange={(e) => setFormData({...formData, mbti: e.target.value})}
                        placeholder="ENFP"
                        maxLength={4}
                      />
                    </div>
                    <div>
                      <Label htmlFor="job_experience">경력</Label>
                      <Select
                        value={formData.job_experience}
                        onValueChange={(value) => setFormData({...formData, job_experience: value})}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="경력을 선택하세요" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="신입">신입</SelectItem>
                          <SelectItem value="1-3년">1-3년</SelectItem>
                          <SelectItem value="3-5년">3-5년</SelectItem>
                          <SelectItem value="5-10년">5-10년</SelectItem>
                          <SelectItem value="10년 이상">10년 이상</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                  </div>

                  <div>
                    <Label>관심 직업 분야 (복수 선택 가능)</Label>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-2 mt-2">
                      {['IT/소프트웨어', '경영/기획', '금융/투자', '교육/연구', '창작/예술', '의료/건강', '법률/공공', '제조/기술'].map((field) => (
                        <label key={field} className="flex items-center space-x-2">
                          <input
                            type="checkbox"
                            checked={formData.preferred_fields?.includes(field) || false}
                            onChange={(e) => handleFieldChange(field, e.target.checked)}
                            className="rounded"
                          />
                          <span className="text-sm">{field}</span>
                        </label>
                      ))}
                    </div>
                  </div>

                  <div>
                    <Label>보유 스킬 (복수 선택 가능)</Label>
                    <div className="grid grid-cols-2 md:grid-cols-3 gap-2 mt-2">
                      {['커뮤니케이션', '리더십', '데이터 분석', '프로젝트 관리', '외국어', '디자인', '프로그래밍', '마케팅', '영업'].map((skill) => (
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
                    <Label htmlFor="career_goals">희망 커리어 목표</Label>
                    <Textarea
                      id="career_goals"
                      value={formData.career_goals}
                      onChange={(e) => setFormData({...formData, career_goals: e.target.value})}
                      placeholder="5년 후 어떤 모습이 되고 싶으신지 자유롭게 적어주세요"
                      rows={3}
                    />
                  </div>

                  <Button 
                    type="submit" 
                    className="w-full bg-teal-600 hover:bg-teal-700"
                    disabled={loading}
                  >
                    {loading ? '분석 중...' : '직업 운세 분석하기'}
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
    <div className="min-h-screen bg-gradient-to-br from-teal-50 via-cyan-50 to-emerald-50">
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
            <BriefcaseIcon className="h-8 w-8 text-teal-600" />
            <h1 className="text-3xl font-bold bg-gradient-to-r from-teal-600 to-emerald-600 bg-clip-text text-transparent">
              {formData.name}님의 직업 운세
            </h1>
          </div>
          <p className="text-gray-600">
            개인 맞춤 직업 분석 결과입니다
          </p>
        </motion.div>

        {/* 종합 운세 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6 border-teal-200 bg-gradient-to-r from-teal-50 to-cyan-50">
            <CardHeader className="text-center">
              <CardTitle className="flex items-center justify-center gap-2 text-teal-700">
                <Sparkles className="h-5 w-5" />
                종합 직업 적합도
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="text-4xl font-bold text-teal-600 mb-2">{result.overall_luck}점</div>
              <Progress value={result.overall_luck} className="mb-4" />
              <p className="text-sm text-gray-600">
                {result.overall_luck >= 85 ? '매우 밝은 전망입니다' : 
                 result.overall_luck >= 70 ? '좋은 기회가 기다리고 있습니다' : 
                 '꾸준한 준비로 성과를 만들어보세요'}
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
                    <TrendingUpIcon className="h-5 w-5 text-teal-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-teal-600">{result.career_luck}</div>
                  <div className="text-sm text-gray-500">커리어 발전</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <UserIcon className="h-5 w-5 text-cyan-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-cyan-600">{result.interview_luck}</div>
                  <div className="text-sm text-gray-500">면접 성공</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <UsersIcon className="h-5 w-5 text-emerald-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-emerald-600">{result.networking_luck}</div>
                  <div className="text-sm text-gray-500">네트워킹</div>
                </div>
                <div className="text-center">
                  <div className="flex items-center justify-center mb-2">
                    <BookOpenIcon className="h-5 w-5 text-blue-600 mr-1" />
                  </div>
                  <div className="text-xl font-bold text-blue-600">{result.learning_luck}</div>
                  <div className="text-sm text-gray-500">학습 능력</div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 추천 직업 */}
        <motion.div variants={itemVariants}>
          <Card className="mb-6">
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <StarIcon className="h-5 w-5 text-yellow-500" />
                맞춤 직업 추천
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {/* 최고 매칭 */}
                <div className="p-4 bg-gradient-to-r from-green-50 to-emerald-50 rounded-lg border border-green-200">
                  <div className="flex items-center justify-between mb-2">
                    <Badge className="bg-green-600 text-white">최고 매칭</Badge>
                    <span className="font-bold text-green-600">{result.recommended_jobs.best_match.compatibility}점</span>
                  </div>
                  <h4 className="font-bold text-lg mb-1">{result.recommended_jobs.best_match.field}</h4>
                  <p className="text-gray-700 mb-2">{result.recommended_jobs.best_match.position}</p>
                  <div className="text-sm text-gray-600">
                    <strong>추천 이유:</strong>
                    <ul className="list-disc list-inside mt-1">
                      {result.recommended_jobs.best_match.reasons.map((reason, index) => (
                        <li key={index}>{reason}</li>
                      ))}
                    </ul>
                  </div>
                </div>

                {/* 좋은 매칭들 */}
                <div className="space-y-3">
                  {result.recommended_jobs.good_matches.map((job, index) => (
                    <div key={index} className="p-3 bg-blue-50 rounded-lg border border-blue-200">
                      <div className="flex items-center justify-between mb-1">
                        <div>
                          <span className="font-medium">{job.field}</span>
                          <span className="text-gray-600 ml-2">- {job.position}</span>
                        </div>
                        <Badge variant="outline" className="bg-blue-100 text-blue-700">{job.compatibility}점</Badge>
                      </div>
                      <p className="text-sm text-blue-700">{job.strengths}</p>
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
                    <LightbulbIcon className="h-4 w-4 text-yellow-500" />
                    <span className="text-sm font-medium">핵심 키워드:</span>
                    <span className="text-sm text-yellow-600">{result.lucky_elements.keyword}</span>
                  </div>
                </div>
                <div className="space-y-3">
                  <div className="flex items-center gap-2">
                    <StarIcon className="h-4 w-4 text-green-500" />
                    <span className="text-sm font-medium">행운의 요일:</span>
                    <span className="text-sm text-green-600">{result.lucky_elements.day}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <UsersIcon className="h-4 w-4 text-orange-500" />
                    <span className="text-sm font-medium">도움이 되는 사람:</span>
                    <span className="text-sm text-orange-600">{result.lucky_elements.network_person}</span>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* MBTI 분석 */}
        {result.mbti_analysis && (
          <motion.div variants={itemVariants}>
            <Card className="mb-6">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <TargetIcon className="h-5 w-5 text-indigo-500" />
                  MBTI 기반 분석 ({formData.mbti})
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div>
                    <h4 className="font-medium mb-2 text-indigo-800">주요 강점</h4>
                    <ul className="text-sm space-y-1">
                      {result.mbti_analysis.strengths.map((strength, index) => (
                        <li key={index} className="flex items-center gap-2">
                          <CheckCircleIcon className="h-3 w-3 text-green-500" />
                          {strength}
                        </li>
                      ))}
                    </ul>
                  </div>
                  <div>
                    <h4 className="font-medium mb-2 text-indigo-800">적합한 환경</h4>
                    <ul className="text-sm space-y-1">
                      {result.mbti_analysis.suitable_environments.map((env, index) => (
                        <li key={index} className="flex items-center gap-2">
                          <CheckCircleIcon className="h-3 w-3 text-blue-500" />
                          {env}
                        </li>
                      ))}
                    </ul>
                  </div>
                </div>
                <div className="mt-4 pt-4 border-t">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <span className="text-sm font-medium text-gray-700">리더십 스타일: </span>
                      <span className="text-sm text-indigo-600">{result.mbti_analysis.leadership_style}</span>
                    </div>
                    <div>
                      <span className="text-sm font-medium text-gray-700">소통 방식: </span>
                      <span className="text-sm text-indigo-600">{result.mbti_analysis.communication_style}</span>
                    </div>
                  </div>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        )}

        {/* 타이밍 조언 & 개인화 조언 */}
        <motion.div variants={itemVariants}>
          <Tabs defaultValue="timing" className="mb-6">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="timing">타이밍 조언</TabsTrigger>
              <TabsTrigger value="advice">개인 조언</TabsTrigger>
              <TabsTrigger value="skills">추천 스킬</TabsTrigger>
            </TabsList>

            <TabsContent value="timing">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <div className="p-3 bg-green-50 rounded-lg">
                      <h4 className="font-medium text-green-800 mb-1">구직 활동</h4>
                      <p className="text-sm text-green-700">{result.timing_advice.job_search}</p>
                    </div>
                    <div className="p-3 bg-blue-50 rounded-lg">
                      <h4 className="font-medium text-blue-800 mb-1">면접 시기</h4>
                      <p className="text-sm text-blue-700">{result.timing_advice.interview_period}</p>
                    </div>
                    <div className="p-3 bg-purple-50 rounded-lg">
                      <h4 className="font-medium text-purple-800 mb-1">이직 타이밍</h4>
                      <p className="text-sm text-purple-700">{result.timing_advice.career_change}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="advice">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <div className="p-3 bg-amber-50 rounded-lg">
                      <h4 className="font-medium text-amber-800 mb-1">나의 강점</h4>
                      <p className="text-sm text-amber-700">{result.personalized_advice.strengths}</p>
                    </div>
                    <div className="p-3 bg-orange-50 rounded-lg">
                      <h4 className="font-medium text-orange-800 mb-1">발전 방향</h4>
                      <p className="text-sm text-orange-700">{result.personalized_advice.development_areas}</p>
                    </div>
                    <div className="p-3 bg-cyan-50 rounded-lg">
                      <h4 className="font-medium text-cyan-800 mb-1">네트워킹 팁</h4>
                      <p className="text-sm text-cyan-700">{result.personalized_advice.networking_tips}</p>
                    </div>
                    <div className="p-3 bg-rose-50 rounded-lg">
                      <h4 className="font-medium text-rose-800 mb-1">면접 팁</h4>
                      <p className="text-sm text-rose-700">{result.personalized_advice.interview_tips}</p>
                    </div>
                  </div>
                </CardContent>
              </Card>
            </TabsContent>

            <TabsContent value="skills">
              <Card>
                <CardContent className="pt-6">
                  <div className="space-y-4">
                    <h4 className="font-medium mb-3">추천 역량 개발 분야</h4>
                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                      {result.skill_recommendations.map((skill, index) => (
                        <div key={index} className="p-3 bg-gradient-to-r from-teal-50 to-cyan-50 rounded-lg border border-teal-200">
                          <div className="flex items-center gap-2">
                            <BookOpenIcon className="h-4 w-4 text-teal-600" />
                            <span className="font-medium text-teal-800">{skill}</span>
                          </div>
                        </div>
                      ))}
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
            className="border-teal-600 text-teal-600 hover:bg-teal-50"
          >
            다시 분석하기
          </Button>
        </motion.div>
      </motion.div>
    </div>
  );
}
