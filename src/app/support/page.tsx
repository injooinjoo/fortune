"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { 
  ArrowLeft, 
  HelpCircle, 
  Send,
  MessageSquare,
  Phone,
  Mail,
  Clock,
  CheckCircle,
  AlertCircle,
  FileText,
  Lightbulb,
  Bug,
  CreditCard,
  Settings,
  Star,
  Search
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

export default function SupportPage() {
  const router = useRouter();
  const [selectedCategory, setSelectedCategory] = useState("");
  const [email, setEmail] = useState("");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isSubmitted, setIsSubmitted] = useState(false);

  const categories = [
    { id: "technical", name: "기술적 문제", icon: Bug, description: "앱 오류, 로딩 문제 등" },
    { id: "account", name: "계정 관련", icon: Settings, description: "로그인, 회원가입 문제" },
    { id: "payment", name: "결제 문의", icon: CreditCard, description: "구독, 환불 관련" },
    { id: "fortune", name: "운세 서비스", icon: Star, description: "운세 정확도, 서비스 문의" },
    { id: "suggestion", name: "개선 제안", icon: Lightbulb, description: "새로운 기능 제안" },
    { id: "other", name: "기타", icon: MessageSquare, description: "기타 문의사항" }
  ];

  const faqs = [
    {
      question: "운세가 정확하지 않은 것 같아요",
      answer: "운세는 참고용으로 제공되며, 개인의 노력과 선택이 더 중요합니다. 정확한 생년월일과 시간을 입력했는지 확인해보세요."
    },
    {
      question: "프리미엄 구독을 취소하고 싶어요",
      answer: "프로필 > 구독 관리에서 언제든지 취소할 수 있습니다. 취소 후에도 현재 결제 주기가 끝날 때까지 서비스를 이용할 수 있어요."
    },
    {
      question: "앱이 자주 종료돼요",
      answer: "앱을 최신 버전으로 업데이트하고, 기기를 재시작해보세요. 문제가 지속되면 기기 정보와 함께 문의해주세요."
    },
    {
      question: "개인정보는 안전한가요?",
      answer: "모든 개인정보는 암호화되어 안전하게 보관되며, 운세 생성 목적 외에는 사용되지 않습니다."
    }
  ];

  const handleSubmit = async () => {
    if (!selectedCategory || !email || !subject || !message) return;
    
    setIsSubmitting(true);
    
    // 실제로는 API 호출
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    setIsSubmitting(false);
    setIsSubmitted(true);
  };

  if (isSubmitted) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-25 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
        <AppHeader title="고객센터" />

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
                  문의가 접수되었습니다
                </h2>
                <p className="text-gray-600 dark:text-gray-400 mb-4">
                  24시간 내에 답변을 드리겠습니다.
                </p>
                <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4 mb-6">
                  <p className="text-sm text-blue-700 dark:text-blue-300">
                    문의번호: <span className="font-mono">FT-{Date.now().toString().slice(-6)}</span>
                  </p>
                </div>
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
      <AppHeader title="고객센터" />

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6 space-y-6"
      >
        {/* 연락 방법 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Phone className="w-5 h-5 text-blue-500" />
                연락 방법
              </CardTitle>
            </CardHeader>
            <CardContent className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="text-center p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                <Mail className="w-8 h-8 text-blue-600 dark:text-blue-400 mx-auto mb-2" />
                <h3 className="font-medium text-gray-900 dark:text-gray-100 mb-1">이메일</h3>
                <p className="text-sm text-gray-600 dark:text-gray-400">support@fortune-app.com</p>
                <Badge variant="secondary" className="mt-2 text-xs">24시간 내 답변</Badge>
              </div>
              
              <div className="text-center p-4 bg-green-50 dark:bg-green-900/20 rounded-lg">
                <MessageSquare className="w-8 h-8 text-green-600 dark:text-green-400 mx-auto mb-2" />
                <h3 className="font-medium text-gray-900 dark:text-gray-100 mb-1">채팅 상담</h3>
                <p className="text-sm text-gray-600 dark:text-gray-400">실시간 상담</p>
                <Badge variant="secondary" className="mt-2 text-xs">평일 9-18시</Badge>
              </div>
              
              <div className="text-center p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
                <Clock className="w-8 h-8 text-purple-600 dark:text-purple-400 mx-auto mb-2" />
                <h3 className="font-medium text-gray-900 dark:text-gray-100 mb-1">운영시간</h3>
                <p className="text-sm text-gray-600 dark:text-gray-400">평일 09:00-18:00</p>
                <Badge variant="secondary" className="mt-2 text-xs">주말/공휴일 휴무</Badge>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 자주 묻는 질문 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Search className="w-5 h-5 text-green-500" />
                자주 묻는 질문
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {faqs.map((faq, index) => (
                <motion.div
                  key={index}
                  initial={{ x: -20, opacity: 0 }}
                  animate={{ x: 0, opacity: 1 }}
                  transition={{ delay: 0.3 + index * 0.1 }}
                  className="border border-gray-200 dark:border-gray-700 rounded-lg p-4"
                >
                  <h3 className="font-medium text-gray-900 dark:text-gray-100 mb-2 flex items-start gap-2">
                    <HelpCircle className="w-4 h-4 text-blue-500 mt-0.5 flex-shrink-0" />
                    {faq.question}
                  </h3>
                  <p className="text-sm text-gray-600 dark:text-gray-400 ml-6">
                    {faq.answer}
                  </p>
                </motion.div>
              ))}
            </CardContent>
          </Card>
        </motion.div>

        {/* 문의하기 폼 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <MessageSquare className="w-5 h-5 text-purple-500" />
                문의하기
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              {/* 문의 유형 */}
              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">
                  문의 유형 *
                </label>
                <div className="grid grid-cols-2 gap-3">
                  {categories.map((category) => (
                    <motion.button
                      key={category.id}
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                      onClick={() => setSelectedCategory(category.id)}
                      className={`p-3 rounded-lg border transition-all duration-200 text-left ${
                        selectedCategory === category.id
                          ? 'border-purple-300 dark:border-purple-600 bg-purple-50 dark:bg-purple-900/20'
                          : 'border-gray-200 dark:border-gray-700 hover:border-gray-300 dark:hover:border-gray-600'
                      }`}
                    >
                      <div className="flex items-center gap-3 mb-1">
                        <div className={`w-6 h-6 rounded-full flex items-center justify-center ${
                          selectedCategory === category.id
                            ? 'bg-purple-100 dark:bg-purple-900/30 text-purple-600 dark:text-purple-400'
                            : 'bg-gray-100 dark:bg-gray-800 text-gray-500 dark:text-gray-400'
                        }`}>
                          <category.icon className="w-3 h-3" />
                        </div>
                        <span className={`text-sm font-medium ${
                          selectedCategory === category.id
                            ? 'text-purple-900 dark:text-purple-100'
                            : 'text-gray-700 dark:text-gray-300'
                        }`}>
                          {category.name}
                        </span>
                      </div>
                      <p className={`text-xs ${
                        selectedCategory === category.id
                          ? 'text-purple-600 dark:text-purple-400'
                          : 'text-gray-500 dark:text-gray-500'
                      }`}>
                        {category.description}
                      </p>
                    </motion.button>
                  ))}
                </div>
              </div>

              {/* 이메일 */}
              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">
                  이메일 주소 *
                </label>
                <Input
                  type="email"
                  placeholder="답변을 받을 이메일 주소를 입력하세요"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                />
              </div>

              {/* 제목 */}
              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">
                  제목 *
                </label>
                <Input
                  placeholder="문의 제목을 입력하세요"
                  value={subject}
                  onChange={(e) => setSubject(e.target.value)}
                />
              </div>

              {/* 내용 */}
              <div>
                <label className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2 block">
                  문의 내용 *
                </label>
                <Textarea
                  placeholder="자세한 문의 내용을 작성해주세요. 오류 발생 시 기기 정보와 함께 상황을 구체적으로 설명해주시면 더 빠른 해결이 가능합니다."
                  value={message}
                  onChange={(e) => setMessage(e.target.value)}
                  className="min-h-[120px] resize-none"
                  maxLength={1000}
                />
                <p className="text-xs text-gray-400 mt-1 text-right">
                  {message.length}/1000
                </p>
              </div>

              {/* 제출 버튼 */}
              <Button
                onClick={handleSubmit}
                disabled={!selectedCategory || !email || !subject || !message || isSubmitting}
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
                    문의하기
                  </div>
                )}
              </Button>
            </CardContent>
          </Card>
        </motion.div>

        {/* 안내 메시지 */}
        <motion.div variants={itemVariants}>
          <Card className="border-blue-200 dark:border-blue-700 bg-blue-50/50 dark:bg-blue-900/10">
            <CardContent className="p-4">
              <div className="flex items-start gap-3">
                <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <AlertCircle className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                </div>
                <div>
                  <h3 className="font-medium text-blue-900 dark:text-blue-100 mb-1">
                    문의 전 확인사항
                  </h3>
                  <ul className="text-sm text-blue-700 dark:text-blue-300 space-y-1">
                    <li>• 앱 버전을 최신으로 업데이트했는지 확인해주세요</li>
                    <li>• 기술적 문제는 기기 정보(OS, 버전)를 함께 알려주세요</li>
                    <li>• 평일 기준 24시간 내에 답변을 드립니다</li>
                    <li>• 긴급한 문의는 이메일로 직접 연락해주세요</li>
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