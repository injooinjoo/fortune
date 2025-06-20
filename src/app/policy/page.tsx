"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import AppHeader from "@/components/AppHeader";
import { 
  ArrowLeft, 
  FileText, 
  Shield,
  Eye,
  Lock,
  Users,
  Calendar,
  AlertTriangle,
  CheckCircle,
  Download,
  Mail
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

export default function PolicyPage() {
  const router = useRouter();
  const [activeTab, setActiveTab] = useState("terms");

  const lastUpdated = "2024년 1월 15일";

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-indigo-25 to-blue-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900 pb-20">
      <AppHeader title="이용약관 및 개인정보처리방침" />

      <motion.div
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="p-6"
      >
        {/* 업데이트 정보 */}
        <motion.div variants={itemVariants} className="mb-6">
          <Card className="border-blue-200 dark:border-blue-700 bg-blue-50/50 dark:bg-blue-900/10">
            <CardContent className="p-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-8 h-8 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
                    <Calendar className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div>
                    <h3 className="font-medium text-blue-900 dark:text-blue-100">
                      최종 업데이트
                    </h3>
                    <p className="text-sm text-blue-700 dark:text-blue-300">
                      {lastUpdated}
                    </p>
                  </div>
                </div>
                <Badge variant="secondary" className="bg-blue-100 dark:bg-blue-900/50 text-blue-700 dark:text-blue-300">
                  v1.0
                </Badge>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        {/* 탭 메뉴 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardContent className="p-6">
              <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
                <TabsList className="grid w-full grid-cols-2">
                  <TabsTrigger value="terms" className="flex items-center gap-2">
                    <FileText className="w-4 h-4" />
                    이용약관
                  </TabsTrigger>
                  <TabsTrigger value="privacy" className="flex items-center gap-2">
                    <Shield className="w-4 h-4" />
                    개인정보처리방침
                  </TabsTrigger>
                </TabsList>

                {/* 이용약관 */}
                <TabsContent value="terms" className="mt-6 space-y-6">
                  <div className="space-y-4">
                    <div className="flex items-center gap-2 mb-4">
                      <FileText className="w-5 h-5 text-purple-600 dark:text-purple-400" />
                      <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100">
                        Fortune 서비스 이용약관
                      </h2>
                    </div>

                    <div className="prose dark:prose-invert max-w-none">
                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          제1조 (목적)
                        </h3>
                        <p className="text-gray-700 dark:text-gray-300 leading-relaxed">
                          본 약관은 Fortune(이하 "회사")이 제공하는 운세 및 관련 서비스(이하 "서비스")의 이용과 관련하여 
                          회사와 이용자 간의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정함을 목적으로 합니다.
                        </p>
                      </section>

                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          제2조 (정의)
                        </h3>
                        <div className="space-y-2 text-gray-700 dark:text-gray-300">
                          <p>1. "서비스"란 회사가 제공하는 운세, 사주, 관상 등의 점술 서비스를 의미합니다.</p>
                          <p>2. "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 받는 회원 및 비회원을 말합니다.</p>
                          <p>3. "회원"이란 회사에 개인정보를 제공하여 회원등록을 한 자로서, 회사의 정보를 지속적으로 제공받으며 회사가 제공하는 서비스를 계속적으로 이용할 수 있는 자를 말합니다.</p>
                        </div>
                      </section>

                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          제3조 (서비스의 내용)
                        </h3>
                        <div className="space-y-2 text-gray-700 dark:text-gray-300">
                          <p>회사가 제공하는 서비스는 다음과 같습니다:</p>
                          <ul className="list-disc list-inside ml-4 space-y-1">
                            <li>일일, 주간, 월간 운세 제공</li>
                            <li>사주팔자 분석 서비스</li>
                            <li>AI 관상 분석 서비스</li>
                            <li>궁합 및 인간관계 분석</li>
                            <li>MBTI 기반 성격 분석</li>
                            <li>기타 회사가 정하는 부가 서비스</li>
                          </ul>
                        </div>
                      </section>

                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          제4조 (서비스의 제한)
                        </h3>
                        <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-700 rounded-lg p-4">
                          <div className="flex items-start gap-3">
                            <AlertTriangle className="w-5 h-5 text-yellow-600 dark:text-yellow-400 mt-0.5 flex-shrink-0" />
                            <div className="text-yellow-800 dark:text-yellow-200">
                              <p className="font-medium mb-2">중요 고지사항</p>
                              <ul className="text-sm space-y-1">
                                <li>• 본 서비스는 오락 및 참고 목적으로만 제공됩니다.</li>
                                <li>• 운세 결과는 절대적이지 않으며, 개인의 판단과 선택이 우선됩니다.</li>
                                <li>• 중요한 결정은 전문가와 상담 후 내리시기 바랍니다.</li>
                                <li>• 미성년자는 보호자의 동의 하에 서비스를 이용해야 합니다.</li>
                              </ul>
                            </div>
                          </div>
                        </div>
                      </section>

                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          제5조 (이용자의 의무)
                        </h3>
                        <div className="space-y-2 text-gray-700 dark:text-gray-300">
                          <p>이용자는 다음 행위를 하여서는 안 됩니다:</p>
                          <ul className="list-disc list-inside ml-4 space-y-1">
                            <li>타인의 정보 도용</li>
                            <li>회사 서비스의 정보를 이용한 영리행위</li>
                            <li>회사의 지적재산권을 침해하는 행위</li>
                            <li>기타 불법적이거나 부당한 행위</li>
                          </ul>
                        </div>
                      </section>
                    </div>
                  </div>
                </TabsContent>

                {/* 개인정보처리방침 */}
                <TabsContent value="privacy" className="mt-6 space-y-6">
                  <div className="space-y-4">
                    <div className="flex items-center gap-2 mb-4">
                      <Shield className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                      <h2 className="text-xl font-bold text-gray-900 dark:text-gray-100">
                        개인정보처리방침
                      </h2>
                    </div>

                    <div className="prose dark:prose-invert max-w-none">
                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          1. 개인정보의 처리목적
                        </h3>
                        <div className="space-y-2 text-gray-700 dark:text-gray-300">
                          <p>Fortune은 다음의 목적을 위하여 개인정보를 처리합니다:</p>
                          <ul className="list-disc list-inside ml-4 space-y-1">
                            <li>서비스 제공 및 계약의 이행</li>
                            <li>회원 관리 및 본인확인</li>
                            <li>운세 서비스 제공을 위한 개인정보 활용</li>
                            <li>고객상담 및 불만처리</li>
                            <li>서비스 개선 및 신규 서비스 개발</li>
                          </ul>
                        </div>
                      </section>

                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          2. 처리하는 개인정보의 항목
                        </h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                          <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-700 rounded-lg p-4">
                            <div className="flex items-center gap-2 mb-3">
                              <CheckCircle className="w-4 h-4 text-green-600 dark:text-green-400" />
                              <h4 className="font-medium text-green-900 dark:text-green-100">필수정보</h4>
                            </div>
                            <ul className="text-sm text-green-800 dark:text-green-200 space-y-1">
                              <li>• 이름</li>
                              <li>• 생년월일</li>
                              <li>• 출생시간 (선택)</li>
                              <li>• 성별</li>
                              <li>• 이메일 주소</li>
                            </ul>
                          </div>
                          
                          <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-700 rounded-lg p-4">
                            <div className="flex items-center gap-2 mb-3">
                              <Eye className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                              <h4 className="font-medium text-blue-900 dark:text-blue-100">자동수집정보</h4>
                            </div>
                            <ul className="text-sm text-blue-800 dark:text-blue-200 space-y-1">
                              <li>• IP 주소</li>
                              <li>• 쿠키</li>
                              <li>• 서비스 이용기록</li>
                              <li>• 접속 로그</li>
                              <li>• 기기정보</li>
                            </ul>
                          </div>
                        </div>
                      </section>

                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          3. 개인정보의 보유 및 이용기간
                        </h3>
                        <div className="space-y-3">
                          <div className="bg-gray-50 dark:bg-gray-800/50 rounded-lg p-4">
                            <p className="text-gray-700 dark:text-gray-300">
                              <strong>회원정보:</strong> 회원탈퇴 시까지 (단, 관계법령에 따라 보존이 필요한 경우 해당 기간까지)
                            </p>
                          </div>
                          <div className="bg-gray-50 dark:bg-gray-800/50 rounded-lg p-4">
                            <p className="text-gray-700 dark:text-gray-300">
                              <strong>서비스 이용기록:</strong> 1년
                            </p>
                          </div>
                          <div className="bg-gray-50 dark:bg-gray-800/50 rounded-lg p-4">
                            <p className="text-gray-700 dark:text-gray-300">
                              <strong>결제정보:</strong> 5년 (전자상거래법)
                            </p>
                          </div>
                        </div>
                      </section>

                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          4. 개인정보의 안전성 확보조치
                        </h3>
                        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                          <div className="flex items-start gap-3 p-4 bg-purple-50 dark:bg-purple-900/20 rounded-lg">
                            <Lock className="w-5 h-5 text-purple-600 dark:text-purple-400 mt-0.5 flex-shrink-0" />
                            <div>
                              <h4 className="font-medium text-purple-900 dark:text-purple-100 mb-1">기술적 보호조치</h4>
                              <ul className="text-sm text-purple-800 dark:text-purple-200 space-y-1">
                                <li>• 개인정보 암호화</li>
                                <li>• 해킹 방지 시스템</li>
                                <li>• 보안프로그램 설치</li>
                              </ul>
                            </div>
                          </div>
                          
                          <div className="flex items-start gap-3 p-4 bg-indigo-50 dark:bg-indigo-900/20 rounded-lg">
                            <Users className="w-5 h-5 text-indigo-600 dark:text-indigo-400 mt-0.5 flex-shrink-0" />
                            <div>
                              <h4 className="font-medium text-indigo-900 dark:text-indigo-100 mb-1">관리적 보호조치</h4>
                              <ul className="text-sm text-indigo-800 dark:text-indigo-200 space-y-1">
                                <li>• 개인정보 취급자 교육</li>
                                <li>• 접근권한 관리</li>
                                <li>• 개인정보보호 책임자 지정</li>
                              </ul>
                            </div>
                          </div>
                        </div>
                      </section>

                      <section className="mb-6">
                        <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-3">
                          5. 개인정보보호 책임자
                        </h3>
                        <div className="bg-gray-50 dark:bg-gray-800/50 rounded-lg p-4">
                          <div className="space-y-2 text-gray-700 dark:text-gray-300">
                            <p><strong>책임자:</strong> 개인정보보호팀</p>
                            <p><strong>연락처:</strong> privacy@fortune-app.com</p>
                            <p><strong>전화:</strong> 02-1234-5678</p>
                          </div>
                        </div>
                      </section>
                    </div>
                  </div>
                </TabsContent>
              </Tabs>
            </CardContent>
          </Card>
        </motion.div>

        {/* 연락처 및 다운로드 */}
        <motion.div variants={itemVariants} className="mt-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-gray-800 dark:text-gray-200">
                <Mail className="w-5 h-5 text-green-500" />
                문의 및 다운로드
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="flex flex-col sm:flex-row gap-4">
                <div className="flex-1 text-center p-4 bg-green-50 dark:bg-green-900/20 rounded-lg">
                  <Mail className="w-8 h-8 text-green-600 dark:text-green-400 mx-auto mb-2" />
                  <h3 className="font-medium text-gray-900 dark:text-gray-100 mb-1">약관 문의</h3>
                  <p className="text-sm text-gray-600 dark:text-gray-400">legal@fortune-app.com</p>
                </div>
                
                <div className="flex-1 text-center p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
                  <Download className="w-8 h-8 text-blue-600 dark:text-blue-400 mx-auto mb-2" />
                  <h3 className="font-medium text-gray-900 dark:text-gray-100 mb-1">PDF 다운로드</h3>
                  <Button variant="outline" size="sm" className="mt-2">
                    약관 다운로드
                  </Button>
                </div>
              </div>
              
              <div className="text-center text-sm text-gray-500 dark:text-gray-400 pt-4 border-t border-gray-200 dark:border-gray-700">
                본 약관은 {lastUpdated}부터 적용됩니다.
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </div>
  );
} 