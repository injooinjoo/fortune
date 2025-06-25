"use client";

import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Brain, Star, Check } from "lucide-react";
import { useRouter } from "next/navigation";
import { useToast } from "@/hooks/use-toast";

const MBTI_TYPES = [
  { type: 'INTJ', title: 'Architect', description: '전략적 사고가' },
  { type: 'INTP', title: 'Logician', description: '논리학자' },
  { type: 'ENTJ', title: 'Commander', description: '통솔자' },
  { type: 'ENTP', title: 'Debater', description: '토론가' },
  { type: 'INFJ', title: 'Advocate', description: '옹호자' },
  { type: 'INFP', title: 'Mediator', description: '중재자' },
  { type: 'ENFJ', title: 'Protagonist', description: '주인공' },
  { type: 'ENFP', title: 'Campaigner', description: '활동가' },
  { type: 'ISTJ', title: 'Logistician', description: '관리자' },
  { type: 'ISFJ', title: 'Defender', description: '수호자' },
  { type: 'ESTJ', title: 'Executive', description: '경영자' },
  { type: 'ESFJ', title: 'Consul', description: '집정관' },
  { type: 'ISTP', title: 'Virtuoso', description: '장인' },
  { type: 'ISFP', title: 'Adventurer', description: '모험가' },
  { type: 'ESTP', title: 'Entrepreneur', description: '사업가' },
  { type: 'ESFP', title: 'Entertainer', description: '연예인' },
];

export default function MbtiPage() {
  const [selectedMbti, setSelectedMbti] = useState("");
  const [selectedGender, setSelectedGender] = useState("");
  const [selectedBirthTime, setSelectedBirthTime] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const router = useRouter();
  const { toast } = useToast();

  const handleMbtiSelect = (mbtiType: string) => {
    setSelectedMbti(mbtiType);
    setIsModalOpen(false);
  };

  const handleComplete = () => {
    if (!selectedMbti || !selectedGender || !selectedBirthTime) {
      toast({
        title: "모든 필드를 선택해주세요",
        description: "더 정확한 운세 분석을 위해 필요합니다.",
        variant: "destructive",
      });
      return;
    }

    // 모든 정보를 로컬 스토리지에 저장
    localStorage.setItem("mbti", selectedMbti);
    localStorage.setItem("gender", selectedGender);
    localStorage.setItem("birthTime", selectedBirthTime);
    
    // 홈페이지로 이동
    router.push("/home");
    
    toast({
      title: "온보딩 완료!",
      description: "이제 개인화된 운세를 확인해보세요.",
    });
  };

  const selectedMbtiInfo = MBTI_TYPES.find(type => type.type === selectedMbti);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50 dark:from-gray-900 dark:to-gray-800 flex items-center justify-center p-4">
      <Card className="w-full max-w-md shadow-lg bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
        <CardHeader className="text-center pb-8">
          <div className="mx-auto mb-4 w-16 h-16 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center">
            <Brain className="w-8 h-8 text-blue-600 dark:text-blue-400" />
          </div>
          <CardTitle className="text-2xl font-bold text-gray-900 dark:text-gray-100 mb-2">
            프로필 정보를 알려주세요
          </CardTitle>
          <CardDescription className="text-gray-600 dark:text-gray-400">
            더 정확한 맞춤 운세를 위해 필요합니다
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-6">
          {/* 성별 선택 */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              성별
            </label>
            <select 
              value={selectedGender} 
              onChange={(e) => setSelectedGender(e.target.value)}
              className="w-full p-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-2 focus:ring-purple-500 dark:focus:ring-purple-400 focus:border-purple-500 dark:focus:border-purple-400 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
            >
              <option value="">성별 선택</option>
              <option value="남성">남성</option>
              <option value="여성">여성</option>
              <option value="선택안함">선택안함</option>
            </select>
          </div>

          {/* 출생시간 선택 */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              출생시간
            </label>
            <select 
              value={selectedBirthTime} 
              onChange={(e) => setSelectedBirthTime(e.target.value)}
              className="w-full p-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:ring-2 focus:ring-purple-500 dark:focus:ring-purple-400 focus:border-purple-500 dark:focus:border-purple-400 bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100"
            >
              <option value="">출생시간 선택</option>
              <option value="오전">오전</option>
              <option value="오후">오후</option>
              <option value="모름">모름</option>
            </select>
          </div>

          {/* MBTI 선택 */}
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              MBTI
            </label>
            
            <Dialog open={isModalOpen} onOpenChange={setIsModalOpen}>
              <DialogTrigger asChild>
                <Button 
                  variant="outline" 
                  className="w-full justify-start text-left font-normal bg-white dark:bg-gray-700 border-gray-300 dark:border-gray-600 text-gray-900 dark:text-gray-100 hover:bg-gray-50 dark:hover:bg-gray-600"
                >
                  {selectedMbti || "MBTI 선택"}
                </Button>
              </DialogTrigger>
              <DialogContent className="max-w-lg max-h-[80vh] overflow-y-auto bg-white dark:bg-gray-800 border-gray-200 dark:border-gray-600">
                <DialogHeader>
                  <DialogTitle className="text-center text-gray-900 dark:text-gray-100">MBTI 유형 선택</DialogTitle>
                </DialogHeader>
                <div className="grid grid-cols-2 gap-3">
                  {MBTI_TYPES.map((type) => (
                    <Button
                      key={type.type}
                      variant="outline"
                      className="p-4 h-auto flex flex-col items-start bg-white dark:bg-gray-700 border-gray-200 dark:border-gray-600 text-gray-900 dark:text-gray-100 hover:bg-purple-50 dark:hover:bg-purple-900/30 hover:border-purple-300 dark:hover:border-purple-500"
                      onClick={() => handleMbtiSelect(type.type)}
                    >
                      <div className="font-semibold">{type.type}</div>
                      <div className="text-xs text-gray-600 dark:text-gray-400">{type.description}</div>
                    </Button>
                  ))}
                </div>
              </DialogContent>
            </Dialog>
          </div>

          {/* 선택된 MBTI 결과 표시 */}
          {selectedMbti && (
            <div 
              data-testid="mbti-result"
              className="p-4 bg-purple-50 dark:bg-purple-900/30 rounded-lg border border-purple-200 dark:border-purple-700"
            >
              <div className="text-center">
                <span className="font-semibold text-lg text-purple-800 dark:text-purple-300">{selectedMbti}</span>
              </div>
            </div>
          )}

          <div className="space-y-3">
            <Button 
              onClick={handleComplete}
              className="w-full bg-purple-600 hover:bg-purple-700 dark:bg-purple-500 dark:hover:bg-purple-600 text-white font-medium py-3 rounded-lg shadow-lg transition-colors"
            >
              <Star className="w-4 h-4 mr-2" />
              완료
            </Button>
            
            <Button
              variant="ghost"
              onClick={() => router.back()}
              className="w-full text-gray-600 dark:text-gray-400 hover:text-gray-800 dark:hover:text-gray-200"
            >
              이전으로
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
} 