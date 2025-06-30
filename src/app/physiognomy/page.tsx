"use client";

import { useState, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import AppHeader from "@/components/AppHeader";
import AdLoadingScreen from "@/components/AdLoadingScreen";
import { useFortuneStream } from "@/hooks/use-fortune-stream";
import { useDailyFortune } from "@/hooks/use-daily-fortune";
import { FortuneResult } from "@/lib/schemas";
import { getUserProfile, isPremiumUser } from "@/lib/user-storage";
import { 
  Eye, 
  Star, 
  Upload,
  Camera,
  Shuffle,
  RotateCcw,
  CheckCircle,
  Sparkles,
  Crown,
  Heart,
  Coins,
  Brain,
  Shield,
  TrendingUp,
  User,
  AlertCircle,
  Download,
  Share2
} from "lucide-react";

interface PhysiognomyAnalysis {
  overall_score: number;
  personality_traits: {
    leadership: number;
    creativity: number;
    sociability: number;
    wisdom: number;
    kindness: number;
  };
  face_parts: {
    forehead: { score: number; description: string; meaning: string };
    eyebrows: { score: number; description: string; meaning: string };
    eyes: { score: number; description: string; meaning: string };
    nose: { score: number; description: string; meaning: string };
    mouth: { score: number; description: string; meaning: string };
    chin: { score: number; description: string; meaning: string };
  };
  fortune_aspects: {
    wealth_luck: number;
    career_luck: number;
    love_luck: number;
    health_luck: number;
    social_luck: number;
  };
  overall_interpretation: string;
  life_advice: string[];
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

const getScoreColor = (score: number) => {
  if (score >= 85) return "text-purple-600 bg-purple-50";
  if (score >= 70) return "text-indigo-600 bg-indigo-50";
  if (score >= 55) return "text-blue-600 bg-blue-50";
  return "text-gray-600 bg-gray-50";
};

const getScoreText = (score: number) => {
  if (score >= 85) return "매우 길상";
  if (score >= 70) return "길상";
  if (score >= 55) return "보통";
  return "주의 필요";
};

export default function PhysiognomyPage() {
  const [step, setStep] = useState<'upload' | 'result' | 'analyzing'>('upload');
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [selectedImage, setSelectedImage] = useState<string | null>(null);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [result, setResult] = useState<PhysiognomyAnalysis | null>(null);
  const [userName, setUserName] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);
  
  // 최근 본 운세 추가를 위한 hook
  useFortuneStream();
  
  // 데일리 운세 관리를 위한 hook
  const {
    todayFortune,
    isLoading: isDailyLoading,
    isGenerating,
    hasTodayFortune,
    saveFortune,
    regenerateFortune,
    canRegenerate
  } = useDailyFortune({ fortuneType: 'physiognomy' });

  // 폰트 크기 클래스 매핑
  const getFontSizeClasses = (size: 'small' | 'medium' | 'large') => {
    switch (size) {
      case 'small':
        return {
          text: 'text-sm',
          title: 'text-lg',
          heading: 'text-xl',
          score: 'text-4xl',
          label: 'text-xs'
        };
      case 'large':
        return {
          text: 'text-lg',
          title: 'text-2xl',
          heading: 'text-3xl',
          score: 'text-8xl',
          label: 'text-base'
        };
      default: // medium
        return {
          text: 'text-base',
          title: 'text-xl',
          heading: 'text-2xl',
          score: 'text-6xl',
          label: 'text-sm'
        };
    }
  };

  const fontClasses = getFontSizeClasses(fontSize);

  const analyzePhysiognomy = async (): Promise<PhysiognomyAnalysis> => {
    const baseScore = Math.floor(Math.random() * 25) + 60;
    
    const facePartDescriptions = {
      forehead: [
        { desc: "넓고 평평한 이마", meaning: "지혜롭고 포용력이 큰 성격" },
        { desc: "높고 둥근 이마", meaning: "창의적이고 직관력이 뛰어남" },
        { desc: "각진 이마", meaning: "결단력 있고 리더십이 강함" }
      ],
      eyebrows: [
        { desc: "진하고 일자형 눈썹", meaning: "의지가 강하고 끈기가 있음" },
        { desc: "아치형 눈썹", meaning: "감정이 풍부하고 예술적 재능" },
        { desc: "촘촘한 눈썹", meaning: "꼼꼼하고 신중한 성격" }
      ],
      eyes: [
        { desc: "크고 또렷한 눈", meaning: "총명하고 관찰력이 뛰어남" },
        { desc: "가늘고 긴 눈", meaning: "침착하고 판단력이 우수함" },
        { desc: "쌍꺼풀이 있는 눈", meaning: "사교적이고 매력적인 성격" }
      ],
      nose: [
        { desc: "오똑하고 높은 콧대", meaning: "자존심이 강하고 재물운이 좋음" },
        { desc: "둥근 콧날", meaning: "온화하고 인정이 많음" },
        { desc: "날렵한 콧날", meaning: "예민하고 감각이 뛰어남" }
      ],
      mouth: [
        { desc: "도톰하고 균형 잡힌 입술", meaning: "인간관계가 원만하고 복이 많음" },
        { desc: "작고 예쁜 입", meaning: "섬세하고 조심스러운 성격" },
        { desc: "큰 입", meaning: "활발하고 표현력이 뛰어남" }
      ],
      chin: [
        { desc: "둥글고 살집 있는 턱", meaning: "복이 많고 인복이 좋음" },
        { desc: "각진 턱", meaning: "의지가 강하고 추진력이 있음" },
        { desc: "뾰족한 턱", meaning: "예민하고 감성적인 성격" }
      ]
    };

    const getRandomDescription = (part: keyof typeof facePartDescriptions) => {
      const options = facePartDescriptions[part];
      return options[Math.floor(Math.random() * options.length)];
    };

    const forehead = getRandomDescription('forehead');
    const eyebrows = getRandomDescription('eyebrows');
    const eyes = getRandomDescription('eyes');
    const nose = getRandomDescription('nose');
    const mouth = getRandomDescription('mouth');
    const chin = getRandomDescription('chin');

    return {
      overall_score: Math.max(60, Math.min(95, baseScore + Math.floor(Math.random() * 15))),
      personality_traits: {
        leadership: Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 20) - 5)),
        creativity: Math.max(45, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 10)),
        sociability: Math.max(55, Math.min(100, baseScore + Math.floor(Math.random() * 15))),
        wisdom: Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 20))),
        kindness: Math.max(60, Math.min(100, baseScore + Math.floor(Math.random() * 15) + 5))
      },
      face_parts: {
        forehead: { 
          score: Math.max(60, Math.min(95, baseScore + Math.floor(Math.random() * 15))), 
          description: forehead.desc, 
          meaning: forehead.meaning 
        },
        eyebrows: { 
          score: Math.max(55, Math.min(90, baseScore + Math.floor(Math.random() * 20) - 5)), 
          description: eyebrows.desc, 
          meaning: eyebrows.meaning 
        },
        eyes: { 
          score: Math.max(65, Math.min(100, baseScore + Math.floor(Math.random() * 15) + 5)), 
          description: eyes.desc, 
          meaning: eyes.meaning 
        },
        nose: { 
          score: Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 20))), 
          description: nose.desc, 
          meaning: nose.meaning 
        },
        mouth: { 
          score: Math.max(60, Math.min(100, baseScore + Math.floor(Math.random() * 15) + 5)), 
          description: mouth.desc, 
          meaning: mouth.meaning 
        },
        chin: { 
          score: Math.max(55, Math.min(90, baseScore + Math.floor(Math.random() * 20))), 
          description: chin.desc, 
          meaning: chin.meaning 
        }
      },
      fortune_aspects: {
        wealth_luck: Math.max(50, Math.min(95, baseScore + Math.floor(Math.random() * 20) - 5)),
        career_luck: Math.max(55, Math.min(100, baseScore + Math.floor(Math.random() * 15))),
        love_luck: Math.max(45, Math.min(90, baseScore + Math.floor(Math.random() * 25) - 10)),
        health_luck: Math.max(60, Math.min(95, baseScore + Math.floor(Math.random() * 15) + 5)),
        social_luck: Math.max(50, Math.min(100, baseScore + Math.floor(Math.random() * 20)))
      },
      overall_interpretation: "당신의 관상은 전체적으로 균형이 잘 잡혀 있으며, 특히 인간관계와 사회생활에서 좋은 운을 가지고 있습니다. 타고난 매력과 지혜로움이 돋보이며, 꾸준한 노력을 통해 큰 성취를 이룰 수 있는 관상입니다.",
      life_advice: [
        "자신의 직감을 믿고 과감한 도전을 해보세요",
        "인간관계를 소중히 여기면 더 큰 기회가 찾아올 것입니다",
        "꾸준한 자기계발로 타고난 재능을 발전시키세요",
        "건강 관리에 신경쓰면서 균형 잡힌 생활을 유지하세요"
      ]
    };
  };

  const handleImageUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const imageUrl = URL.createObjectURL(file);
      setSelectedImage(imageUrl);
      setImageFile(file);
    }
  };

const handleAnalyze = async () => {
    if (!selectedImage || !userName.trim()) {
      alert('이름을 입력하고 사진을 선택해주세요.');
      return;
    }

    // 기존 운세가 있으면 불러오기
    if (hasTodayFortune && todayFortune) {
      const savedResult = todayFortune.fortune_data as any;
      if (savedResult.face_parts) {
        setResult(savedResult);
        setStep('result');
        return;
      }
    }

    // 로딩 화면 표시
    setStep('analyzing');
  };

  const handleAnalysisComplete = async () => {
    try {
      // 새로운 분석 생성
      const analysisResult = await analyzePhysiognomy();
      
      // FortuneResult 형식으로 변환
      const fortuneResult: FortuneResult = {
        user_info: {
          name: userName,
          birth_date: new Date().toISOString().split('T')[0],
        },
        fortune_scores: {
          overall_luck: analysisResult.overall_score,
          ...analysisResult.fortune_aspects,
        },
        lucky_items: {
          overall_interpretation: analysisResult.overall_interpretation,
          life_advice: analysisResult.life_advice.join(', '),
        },
        metadata: {
          personality_traits: analysisResult.personality_traits,
          face_parts: analysisResult.face_parts,
        }
      };

      // DB에 저장
      const success = await saveFortune(fortuneResult);
      if (success) {
        setResult(analysisResult);
        setStep('result');
      } else {
        alert('분석 결과 저장에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (error) {
      console.error('분석 중 오류:', error);
      alert('분석 중 오류가 발생했습니다. 다시 시도해주세요.');
    }
  };

const handleReset = () => {
    setStep('upload');
    setResult(null);
    setSelectedImage(null);
    setImageFile(null);
    setUserName('');
  };

  // 분석 화면에서 프리미엄 사용자 확인
  if (step === 'analyzing') {
    const userProfile = getUserProfile();
    const isPremium = isPremiumUser(userProfile);
    
    return (
      <AdLoadingScreen
        fortuneType="physiognomy"
        fortuneTitle="AI 관상 분석"
        onComplete={handleAnalysisComplete}
        isPremium={isPremium}
      />
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-25 to-pink-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700 pb-32">
      <AppHeader 
        title="AI 관상 분석" 
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      
      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="px-6 pt-6"
      >
        <AnimatePresence mode="wait">
          {step === 'upload' && (
            <motion.div
              key="upload"
              initial={{ opacity: 0, x: -50 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 50 }}
              className="space-y-6"
            >
              {/* 헤더 */}
              <motion.div variants={itemVariants} className="text-center mb-8">
                <motion.div
                  className="bg-gradient-to-r from-purple-500 to-indigo-500 rounded-full w-20 h-20 flex items-center justify-center mx-auto mb-4"
                  whileHover={{ rotate: 360 }}
                  transition={{ duration: 0.8 }}
                >
                  <Eye className="w-10 h-10 text-white" />
                </motion.div>
                <h1 className={`${fontClasses.heading} font-bold text-gray-900 dark:text-gray-100 mb-2`}>AI 관상 분석</h1>
                <p className={`${fontClasses.text} text-gray-600 dark:text-gray-400`}>당신의 얼굴에서 읽어내는 운명과 성격의 비밀</p>
              </motion.div>

              {/* 이름 입력 */}
              <motion.div variants={itemVariants}>
                <Card className="border-purple-200 dark:border-purple-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-700 dark:text-purple-400`}>
                      <User className="w-5 h-5" />
                      기본 정보
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div>
                      <label className={`${fontClasses.text} font-medium text-gray-700 dark:text-gray-300 block mb-2`}>
                        이름을 입력해주세요
                      </label>
                      <input
                        type="text"
                        placeholder="이름"
                        value={userName}
                        onChange={(e) => setUserName(e.target.value)}
                        className={`w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent ${fontClasses.text}`}
                      />
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 이미지 업로드 */}
              <motion.div variants={itemVariants}>
                <Card className="border-indigo-200 dark:border-indigo-700 dark:bg-gray-800">
                  <CardHeader className="pb-4">
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-indigo-700 dark:text-indigo-400`}>
                      <Camera className="w-5 h-5" />
                      사진 업로드
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    {!selectedImage ? (
                      <motion.div
                        className="border-2 border-dashed border-purple-300 dark:border-purple-600 rounded-lg p-8 text-center bg-purple-25 dark:bg-purple-900/20 hover:bg-purple-50 dark:hover:bg-purple-900/30 transition-colors cursor-pointer"
                        whileHover={{ scale: 1.02 }}
                        whileTap={{ scale: 0.98 }}
                        onClick={() => fileInputRef.current?.click()}
                      >
                        <Upload className="w-12 h-12 text-purple-400 dark:text-purple-300 mx-auto mb-4" />
                        <p className={`${fontClasses.text} text-purple-600 dark:text-purple-400 font-medium mb-2`}>
                          얼굴이 잘 보이는 사진을 업로드하세요
                        </p>
                        <p className={`${fontClasses.label} text-purple-400 dark:text-purple-300`}>
                          JPG, PNG 파일을 지원합니다
                        </p>
                        <input
                          ref={fileInputRef}
                          type="file"
                          accept="image/*"
                          onChange={handleImageUpload}
                          className="hidden"
                        />
                      </motion.div>
                    ) : (
                      <div className="space-y-4">
                        <div className="relative rounded-lg overflow-hidden">
                          <img
                            src={selectedImage}
                            alt="업로드된 사진"
                            className="w-full h-auto max-h-80 object-cover"
                          />
                        </div>
                        <Button
                          onClick={() => fileInputRef.current?.click()}
                          variant="outline"
                          className={`w-full border-purple-300 text-purple-600 hover:bg-purple-50 ${fontClasses.text}`}
                        >
                          <Camera className="w-4 h-4 mr-2" />
                          다른 사진 선택
                        </Button>
                        <input
                          ref={fileInputRef}
                          type="file"
                          accept="image/*"
                          onChange={handleImageUpload}
                          className="hidden"
                        />
                      </div>
                    )}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 주의사항 */}
              <motion.div variants={itemVariants}>
                <Alert className="border-amber-200 bg-amber-50">
                  <AlertCircle className="h-4 w-4 text-amber-600" />
                  <AlertDescription className={`${fontClasses.label} text-amber-700`}>
                    <strong>분석 팁:</strong> 정면을 바라보는 자연스러운 표정의 사진이 가장 정확한 결과를 제공합니다.
                  </AlertDescription>
                </Alert>
              </motion.div>

              {/* 분석 버튼 */}
              <motion.div variants={itemVariants} className="pt-4">
                <Button
                  onClick={handleAnalyze}
                  disabled={!selectedImage || !userName.trim() || isGenerating || isDailyLoading}
                  className={`w-full bg-gradient-to-r from-purple-500 to-indigo-500 hover:from-purple-600 hover:to-indigo-600 text-white py-6 ${fontClasses.title} font-semibold`}
                >
                  {(isGenerating || isDailyLoading) ? (
                    <motion.div
                      animate={{ rotate: 360 }}
                      transition={{ repeat: Infinity, duration: 1 }}
                      className="flex items-center gap-2"
                    >
                      <Shuffle className="w-5 h-5" />
                      {hasTodayFortune ? '불러오는 중...' : 'AI 분석 중...'}
                    </motion.div>
                  ) : (
                    <div className="flex items-center gap-2">
                      {hasTodayFortune ? (
                        <>
                          <CheckCircle className="w-5 h-5" />
                          오늘의 관상 분석 보기
                        </>
                      ) : (
                        <>
                          <Sparkles className="w-5 h-5" />
                          AI 관상 분석 시작
                        </>
                      )}
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
              {/* 종합 점수 */}
              <motion.div variants={itemVariants}>
                <Card className="bg-gradient-to-r from-purple-500 to-indigo-500 text-white">
                  <CardContent className="text-center py-8">
                    <div className={`flex items-center justify-center gap-2 mb-4`}>
                      <Crown className="w-6 h-6" />
                      <span className={`${fontClasses.title} font-medium`}>{userName}님의 관상 분석</span>
                    </div>
                    <motion.div
                      initial={{ scale: 0 }}
                      animate={{ scale: 1 }}
                      transition={{ delay: 0.3, type: "spring" }}
                      className={`${fontClasses.score} font-bold mb-2`}
                    >
                      {result.overall_score}점
                    </motion.div>
                    <Badge variant="secondary" className={`${fontClasses.text} bg-white/20 text-white border-white/30`}>
                      {getScoreText(result.overall_score)}
                    </Badge>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 성격 특성 */}
              <motion.div variants={itemVariants}>
                <Card className="dark:bg-gray-800 dark:border-gray-700">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-600 dark:text-purple-400`}>
                      <Brain className="w-5 h-5" />
                      성격 특성 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {[
                      { label: "리더십", score: result.personality_traits.leadership, icon: Crown },
                      { label: "창의성", score: result.personality_traits.creativity, icon: Sparkles },
                      { label: "사교성", score: result.personality_traits.sociability, icon: Heart },
                      { label: "지혜", score: result.personality_traits.wisdom, icon: Brain },
                      { label: "친화력", score: result.personality_traits.kindness, icon: Shield }
                    ].map((trait, index) => (
                      <motion.div
                        key={trait.label}
                        initial={{ x: -20, opacity: 0 }}
                        animate={{ x: 0, opacity: 1 }}
                        transition={{ delay: 0.4 + index * 0.1 }}
                        className="space-y-2"
                      >
                        <div className="flex items-center gap-3">
                          <trait.icon className="w-5 h-5 text-gray-600" />
                          <div className="flex-1">
                            <div className="flex justify-between items-center mb-1">
                              <span className={`${fontClasses.text} font-medium`}>{trait.label}</span>
                              <span className={`px-3 py-1 rounded-full ${fontClasses.label} font-medium ${getScoreColor(trait.score)}`}>
                                {trait.score}점
                              </span>
                            </div>
                            <div className="w-full bg-gray-200 rounded-full h-2">
                              <motion.div
                                className="bg-purple-500 h-2 rounded-full"
                                initial={{ width: 0 }}
                                animate={{ width: `${trait.score}%` }}
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

              {/* 얼굴 부위별 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-indigo-600`}>
                      <Eye className="w-5 h-5" />
                      얼굴 부위별 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    {Object.entries(result.face_parts).map(([part, analysis], index) => {
                      const partNames: Record<string, string> = {
                        forehead: "이마",
                        eyebrows: "눈썹",
                        eyes: "눈",
                        nose: "코",
                        mouth: "입",
                        chin: "턱"
                      };
                      
                      return (
                        <motion.div
                          key={part}
                          initial={{ y: 20, opacity: 0 }}
                          animate={{ y: 0, opacity: 1 }}
                          transition={{ delay: 0.6 + index * 0.1 }}
                          className="p-4 border border-gray-200 rounded-lg bg-gray-50"
                        >
                          <div className="flex justify-between items-start mb-2">
                            <h4 className={`${fontClasses.text} font-semibold text-gray-800`}>
                              {partNames[part]}
                            </h4>
                            <Badge className={`${fontClasses.label} ${getScoreColor(analysis.score)}`}>
                              {analysis.score}점
                            </Badge>
                          </div>
                          <p className={`${fontClasses.text} text-gray-700 mb-2`}>
                            {analysis.description}
                          </p>
                          <p className={`${fontClasses.label} text-gray-600`}>
                            💫 {analysis.meaning}
                          </p>
                        </motion.div>
                      );
                    })}
                  </CardContent>
                </Card>
              </motion.div>

              {/* 운세 분석 */}
              <motion.div variants={itemVariants}>
                <Card>
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-green-600`}>
                      <TrendingUp className="w-5 h-5" />
                      운세 분석
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-4">
                    <div className="grid grid-cols-2 gap-4">
                      {[
                        { label: "재물운", score: result.fortune_aspects.wealth_luck, icon: Coins, color: "yellow" },
                        { label: "직업운", score: result.fortune_aspects.career_luck, icon: TrendingUp, color: "blue" },
                        { label: "애정운", score: result.fortune_aspects.love_luck, icon: Heart, color: "pink" },
                        { label: "건강운", score: result.fortune_aspects.health_luck, icon: Shield, color: "green" },
                        { label: "인복", score: result.fortune_aspects.social_luck, icon: User, color: "purple" }
                      ].map((fortune, index) => (
                        <motion.div
                          key={fortune.label}
                          initial={{ scale: 0 }}
                          animate={{ scale: 1 }}
                          transition={{ delay: 0.8 + index * 0.1 }}
                          className={`p-4 bg-${fortune.color}-50 rounded-lg`}
                        >
                          <div className="flex items-center gap-2 mb-2">
                            <fortune.icon className={`w-4 h-4 text-${fortune.color}-600`} />
                            <span className={`${fontClasses.text} font-medium text-${fortune.color}-800`}>
                              {fortune.label}
                            </span>
                          </div>
                          <p className={`${fontClasses.title} font-bold text-${fortune.color}-700`}>
                            {fortune.score}점
                          </p>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 종합 해석 */}
              <motion.div variants={itemVariants}>
                <Card className="border-purple-200">
                  <CardHeader>
                    <CardTitle className={`${fontClasses.title} flex items-center gap-2 text-purple-600`}>
                      <Star className="w-5 h-5" />
                      종합 해석
                    </CardTitle>
                  </CardHeader>
                  <CardContent>
                    <p className={`${fontClasses.text} text-gray-700 leading-relaxed mb-4`}>
                      {result.overall_interpretation}
                    </p>
                    <div className="space-y-2">
                      <h4 className={`${fontClasses.text} font-semibold text-gray-800 mb-2`}>💎 인생 조언</h4>
                      {result.life_advice.map((advice, index) => (
                        <motion.div
                          key={index}
                          initial={{ x: -20, opacity: 0 }}
                          animate={{ x: 0, opacity: 1 }}
                          transition={{ delay: 1.0 + index * 0.1 }}
                          className={`flex items-start gap-2 ${fontClasses.label} text-gray-600`}
                        >
                          <span className="text-purple-500 mt-1">•</span>
                          <span>{advice}</span>
                        </motion.div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </motion.div>

              {/* 액션 버튼들 */}
              <motion.div variants={itemVariants} className="pt-4 space-y-3">
                {canRegenerate && (
                  <Button
                    onClick={async () => {
                      try {
                        await new Promise(resolve => setTimeout(resolve, 3000));
                        const analysisResult = await analyzePhysiognomy();
                        
                        const fortuneResult: FortuneResult = {
                          user_info: {
                            name: userName,
                            birth_date: new Date().toISOString().split('T')[0],
                          },
                          fortune_scores: {
                            overall_luck: analysisResult.overall_score,
                            ...analysisResult.fortune_aspects,
                          },
                          lucky_items: {
                            overall_interpretation: analysisResult.overall_interpretation,
                            life_advice: analysisResult.life_advice.join(', '),
                          },
                          metadata: {
                            personality_traits: analysisResult.personality_traits,
                            face_parts: analysisResult.face_parts,
                          }
                        };

                        const success = await regenerateFortune(fortuneResult);
                        if (success) {
                          setResult(analysisResult);
                        }
                      } catch (error) {
                        console.error('재분석 중 오류:', error);
                        alert('재분석에 실패했습니다. 다시 시도해주세요.');
                      }
                    }}
                    disabled={isGenerating}
                    className={`w-full bg-gradient-to-r from-indigo-500 to-purple-500 hover:from-indigo-600 hover:to-purple-600 text-white py-3 ${fontClasses.text}`}
                  >
                    {isGenerating ? (
                      <motion.div
                        animate={{ rotate: 360 }}
                        transition={{ repeat: Infinity, duration: 1 }}
                        className="flex items-center gap-2"
                      >
                        <Shuffle className="w-4 h-4" />
                        재분석 중...
                      </motion.div>
                    ) : (
                      <div className="flex items-center gap-2">
                        <RotateCcw className="w-4 h-4" />
                        오늘 관상 다시 분석하기
                      </div>
                    )}
                  </Button>
                )}
                
                <div className="grid grid-cols-2 gap-3">
                  <Button
                    onClick={handleReset}
                    variant="outline"
                    className={`border-purple-300 text-purple-600 hover:bg-purple-50 py-3 ${fontClasses.text}`}
                  >
                    <Camera className="w-4 h-4 mr-2" />
                    다른 사진 분석
                  </Button>
                  <Button
                    variant="outline"
                    className={`border-gray-300 text-gray-600 hover:bg-gray-50 py-3 ${fontClasses.text}`}
                  >
                    <Share2 className="w-4 h-4 mr-2" />
                    결과 공유
                  </Button>
                </div>
              </motion.div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>
    </div>
  );
}
