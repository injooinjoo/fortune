"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { 
  ArrowLeft, 
  Star, 
  Send,
  ThumbsUp,
  ThumbsDown,
  MessageSquare,
  Heart,
  Award,
  Sparkles,
  CheckCircle
} from "lucide-react";

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

export default function FeedbackPage() {
  const router = useRouter();
  const [rating, setRating] = useState(0);
  const [hoveredRating, setHoveredRating] = useState(0);
  const [feedback, setFeedback] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string>("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

  const categories = [
    { id: "accuracy", name: "운세 정확도", icon: Star },
    { id: "ui", name: "사용자 인터페이스", icon: Sparkles },
    { id: "features", name: "기능 및 서비스", icon: Award },
    { id: "performance", name: "앱 성능", icon: ThumbsUp },
    { id: "suggestion", name: "개선 제안", icon: MessageSquare },
    { id: "other", name: "기타", icon: Heart }
  ];

  const handleSubmit = async () => {
    if (rating === 0 || !selectedCategory) return;
    
    setIsSubmitting(true);
    
    // 실제로는 API 호출
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    setIsSubmitting(false);
    setIsSubmitted(true);
  };

  const getRatingText = (rating: number) => {
    switch (rating) {
      case 1: return "매우 불만족";
      case 2: return "불만족";
      case 3: return "보통";
      case 4: return "만족";
      case 5: return "매우 만족";
      default: return "평가해주세요";
    }
  };

  if (isSubmitted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-25 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
        <AppHeader title="평가 및 리뷰" />

        <div className="flex items-center justify-center min-h-[60vh] p-6">
          <motion.div
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            transition={{ type: "spring", stiffness: 100 }}
          >
            <Card className="text-center max-w-md mx-auto">
              <CardContent className="p-8">
                <motion.div
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
                  className="w-16 h-16 bg-green-100 dark:bg-green-900/30 rounded-full flex items-center justify-center mx-auto mb-4"
                >
                  <CheckCircle className="w-8 h-8 text-green-600 dark:text-green-400" />
                </motion.div>
                <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100 mb-2">
                  소중한 의견 감사합니다!
                </h2>
                <p className="text-gray-600 dark:text-gray-400 mb-6">
                  여러분의 피드백은 더 나은 서비스를 만드는 데 큰 도움이 됩니다.
                </p>
                <Button onClick={() => router.back()} className="w-full">
                  프로필로 돌아가기
                </Button>
              </CardContent>
            </Card>
          </motion.div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-25 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="평가 및 리뷰" />

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6"
      >
        {/* 전체 만족도 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Star className="w-5 h-5 text-yellow-500" />
                전체 만족도
              </CardTitle>
            </CardHeader>
            <CardContent className="text-center">
              <div className="mb-4">
                <div className="flex justify-center gap-2 mb-3">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <motion.button
                      key={star}
                      whileHover={{ scale: 1.1 }}
                      whileTap={{ scale: 0.9 }}
                      onClick={() => setRating(star)}
                      onMouseEnter={() => setHoveredRating(star)}
                      onMouseLeave={() => setHoveredRating(0)}
                      className="p-1"
                    >
                      <Star
                        className={`w-8 h-8 transition-colors ${
                          star <= (hoveredRating || rating)
                            ? 'fill-yellow-400 text-yellow-400'
                            : 'text-gray-300 dark:text-gray-600'
                        }`}
                      />
                    </motion.button>
                  ))}
                </div>
                <p className="text-lg font-medium text-gray-900 dark:text-gray-100">
                  {getRatingText(hoveredRating || rating)}
                </p>
                {rating > 0 && (
                  <motion.div
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                  >
                    <Badge variant="secondary" className="mt-2">
                      {rating}점 / 5점
                    </Badge>
                  </motion.div>
                )}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 카테고리 선택 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <MessageSquare className="w-5 h-5 text-blue-500" />
                어떤 부분에 대한 의견인가요?
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-2 gap-3">
                {categories.map((category) => (
                  <motion.button
                    key={category.id}
                    whileHover={{ scale: 1.02 }}
                    whileTap={{ scale: 0.98 }}
                    onClick={() => setSelectedCategory(category.id)}
                    className={`p-4 rounded-lg border transition-all duration-200 text-left ${
                      selectedCategory === category.id
                        ? 'border-purple-300 dark:border-purple-600 bg-purple-50 dark:bg-purple-900/20'
                        : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <div className={`w-8 h-8 rounded-full flex items-center justify-center ${
                        selectedCategory === category.id
                          ? 'bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400'
                          : 'bg-gray-100 dark:bg-gray-800 text-gray-500 dark:text-gray-400'
                      }`}>
                        <category.icon className="w-4 h-4" />
                      </div>
                      <span className={`text-sm font-medium ${
                        selectedCategory === category.id
                          ? 'text-purple-900 dark:text-purple-100'
                          : 'text-gray-700 dark:text-gray-300'
                      }`}>
                        {category.name}
                      </span>
                    </div>
                  </motion.button>
                ))}
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 상세 의견 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Heart className="w-5 h-5 text-red-500" />
                상세 의견 (선택사항)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <Textarea
                placeholder="구체적인 의견이나 개선사항을 자유롭게 작성해주세요..."
                value={feedback}
                onChange={(e) => setFeedback(e.target.value)}
                className="min-h-[120px] resize-none"
                maxLength={500}
              />
              <div className="flex justify-between items-center mt-2">
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  익명으로 전송되며, 개인정보는 수집되지 않습니다.
                </p>
                <p className="text-xs text-gray-400">
                  {feedback.length}/500
                </p>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 제출 버튼 */}
        <motion.div variants={itemVariants}>
          <Button
            onClick={handleSubmit}
            disabled={rating === 0 || !selectedCategory || isSubmitting}
            className="w-full h-12 text-base"
            size="lg"
          >
            {isSubmitting ? (
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
                전송 중...
              </div>
            ) : (
              <div className="flex items-center gap-2">
                <Send className="w-4 h-4" />
                의견 보내기
              </div>
            )}
          </Button>
        </motion.div>

        {/* 안내 메시지 */}
        <motion.div variants={itemVariants}>
          <Card className="border-blue-200 dark:border-blue-700 bg-blue-50/50 dark:bg-blue-900/10">
            <CardContent className="p-4">
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Heart className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                </div>
                <div>
                  <h3 className="font-medium text-blue-900 dark:text-blue-100 mb-1">
                    여러분의 의견이 소중합니다
                  </h3>
                  <ul className="text-sm text-blue-700 dark:text-blue-300 space-y-1">
                    <li>• 모든 피드백은 신중히 검토하여 서비스 개선에 반영됩니다</li>
                    <li>• 개인정보는 수집되지 않으며 익명으로 처리됩니다</li>
                    <li>• 긍정적인 의견도 개선 의견도 모두 환영합니다</li>
                  </ul>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
} 