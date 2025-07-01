"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import AppHeader from "@/components/AppHeader";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import { Handshake, Users, AlertTriangle, Sparkles, CheckCircle } from "lucide-react";

interface NetworkReportData {
  score: number;
  summary: string;
  benefactors: string[];
  challengers: string[];
  advice: string;
  actionItems: string[];
  lucky: {
    color: string;
    number: number;
    direction: string;
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

export default function NetworkReportPage() {
  const [fontSize, setFontSize] = useState<'small' | 'medium' | 'large'>('medium');
  const [data, setData] = useState<NetworkReportData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchNetworkReport = async () => {
      try {
        setLoading(true);
        const response = await fetch(`/api/fortune/network-report?userId=guest_${Date.now()}`);
        const result = await response.json();
        
        if (result.success && result.data) {
          setData(result.data);
        } else {
          // 기본 데이터 설정
          setData({
            score: 75,
            summary: '인맥보고서를 불러오는 중입니다.',
            benefactors: ['분석 중입니다'],
            challengers: ['분석 중입니다'],
            advice: '잠시 후 다시 확인해주세요.',
            actionItems: ['데이터를 준비 중입니다'],
            lucky: { color: '#FFD700', number: 7, direction: '동쪽' }
          });
        }
      } catch (error) {
        console.error('인맥보고서 로딩 실패:', error);
        setData({
          score: 75,
          summary: '인맥보고서를 불러오는 중 오류가 발생했습니다.',
          benefactors: ['다시 시도해주세요'],
          challengers: ['다시 시도해주세요'],
          advice: '잠시 후 다시 확인해주세요.',
          actionItems: ['새로고침 후 재시도'],
          lucky: { color: '#FFD700', number: 7, direction: '동쪽' }
        });
      } finally {
        setLoading(false);
      }
    };

    fetchNetworkReport();
  }, []);

  if (loading || !data) {
    return (
      <>
        <AppHeader
          title="인맥보고서"
          onFontSizeChange={setFontSize}
          currentFontSize={fontSize}
        />
        <div className="pb-32 px-4 pt-4 min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50">
          <div className="text-center py-8">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-indigo-600 mx-auto"></div>
            <p className="mt-4 text-gray-600">인맥보고서를 분석 중입니다...</p>
          </div>
        </div>
      </>
    );
  }

  const fontClasses = {
    small: "text-sm",
    medium: "text-base",
    large: "text-lg"
  };

  return (
    <>
      <AppHeader
        title="인맥보고서"
        onFontSizeChange={setFontSize}
        currentFontSize={fontSize}
      />
      <motion.div
        className="pb-32 px-4 space-y-6 pt-4 min-h-screen bg-gradient-to-br from-indigo-50 via-white to-purple-50"
        variants={containerVariants}
        initial="hidden"
        animate="visible"
      >
        {/* 전체 점수 */}
        <motion.div variants={itemVariants}>
          <Card className="bg-gradient-to-r from-indigo-200 to-purple-300 border-indigo-300 text-gray-900">
            <CardHeader className="flex items-center gap-2">
              <Users className="w-5 h-5 text-indigo-700" />
              <CardTitle className="text-indigo-800">인맥 운세 점수</CardTitle>
            </CardHeader>
            <CardContent className="text-center space-y-4">
              <div className="text-4xl font-bold text-indigo-700">{data.score}점</div>
              <Progress value={data.score} />
              <p className={`${fontClasses[fontSize]} text-indigo-800 leading-relaxed`}>
                {data.summary}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 귀인 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader className="flex items-center gap-2">
              <Handshake className="w-5 h-5 text-green-600" />
              <CardTitle className="text-green-700">귀인이 되어줄 사람</CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="list-disc pl-5 space-y-1 text-sm text-gray-700">
                {data.benefactors.map((item: string, idx: number) => (
                  <li key={idx}>{item}</li>
                ))}
              </ul>
            </CardContent>
          </Card>
        </motion.div>

        {/* 악연 / 주의 인물 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader className="flex items-center gap-2">
              <AlertTriangle className="w-5 h-5 text-red-600" />
              <CardTitle className="text-red-700">주의해야 할 인물</CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="list-disc pl-5 space-y-1 text-sm text-gray-700">
                {data.challengers.map((item: string, idx: number) => (
                  <li key={idx}>{item}</li>
                ))}
              </ul>
            </CardContent>
          </Card>
        </motion.div>

        {/* 관계 조언 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader className="flex items-center gap-2">
              <Sparkles className="w-5 h-5 text-purple-600" />
              <CardTitle className="text-purple-700">관계 조언</CardTitle>
            </CardHeader>
            <CardContent>
              <p className={`${fontClasses[fontSize]} leading-relaxed text-gray-700`}>
                {data.advice}
              </p>
            </CardContent>
          </Card>
        </motion.div>

        {/* 실천 항목 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader className="flex items-center gap-2">
              <CheckCircle className="w-5 h-5 text-indigo-600" />
              <CardTitle className="text-indigo-700">오늘의 실천</CardTitle>
            </CardHeader>
            <CardContent>
              <ul className="list-disc pl-5 space-y-1 text-sm text-gray-700">
                {data.actionItems.map((item: string, idx: number) => (
                  <li key={idx}>{item}</li>
                ))}
              </ul>
            </CardContent>
          </Card>
        </motion.div>

        {/* 행운 요소 */}
        <motion.div variants={itemVariants}>
          <Card>
            <CardHeader className="flex items-center gap-2">
              <Sparkles className="w-5 h-5 text-yellow-500" />
              <CardTitle className="text-yellow-600">행운 정보</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-4 text-sm text-gray-700">
                <div className="flex flex-col items-center">
                  <span className="mb-1">색상</span>
                  <span className="w-4 h-4 rounded-full" style={{ backgroundColor: data.lucky.color }} />
                </div>
                <div className="flex flex-col items-center">
                  <span className="mb-1">숫자</span>
                  <span>{data.lucky.number}</span>
                </div>
                <div className="flex flex-col items-center">
                  <span className="mb-1">방향</span>
                  <span>{data.lucky.direction}</span>
                </div>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </motion.div>
    </>
  );
}

