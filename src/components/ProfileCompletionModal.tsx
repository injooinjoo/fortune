"use client";

import { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import {
  User,
  Calendar,
  Clock,
  Heart,
  Star,
  Droplets,
  Briefcase,
  MapPin,
  CheckCircle2,
  AlertCircle,
  ChevronRight
} from "lucide-react";
import { FortuneCategory } from "@/lib/types/fortune-system";
import { UserInfo, getUserInfo, saveUserInfo } from "@/lib/user-storage";
import { 
  checkFortuneProfileCompleteness, 
  getRequiredFieldLabels, 
  getMissingFieldLabels,
  getFortuneGuideMessage,
  FIELD_LABELS 
} from "@/lib/profile-completeness";

interface ProfileCompletionModalProps {
  isOpen: boolean;
  onClose: () => void;
  onComplete: () => void;
  fortuneCategory: FortuneCategory;
  fortuneTitle?: string;
}

const fieldIcons: Record<keyof UserInfo, React.ReactNode> = {
  name: <User className="w-4 h-4" />,
  birthDate: <Calendar className="w-4 h-4" />,
  birthTime: <Clock className="w-4 h-4" />,
  gender: <Heart className="w-4 h-4" />,
  mbti: <Star className="w-4 h-4" />,
  bloodType: <Droplets className="w-4 h-4" />,
  zodiacSign: <Star className="w-4 h-4" />,
  job: <Briefcase className="w-4 h-4" />,
  location: <MapPin className="w-4 h-4" />
};

export default function ProfileCompletionModal({
  isOpen,
  onClose,
  onComplete,
  fortuneCategory,
  fortuneTitle
}: ProfileCompletionModalProps) {
  const [userInfo, setUserInfo] = useState<UserInfo>({
    name: '',
    birthDate: '',
    birthTime: '',
    gender: '',
    mbti: '',
    bloodType: '',
    zodiacSign: '',
    job: '',
    location: ''
  });
  const [missingFields, setMissingFields] = useState<(keyof UserInfo)[]>([]);
  const [currentFieldIndex, setCurrentFieldIndex] = useState(0);
  const [completionProgress, setCompletionProgress] = useState(0);
  const [isSaving, setIsSaving] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);

  useEffect(() => {
    if (isOpen) {
      // 현재 프로필 정보 로드
      const currentInfo = getUserInfo();
      setUserInfo(currentInfo);
      
      // 필요한 필드 확인
      const completeness = checkFortuneProfileCompleteness(currentInfo, fortuneCategory);
      setMissingFields(completeness.missingFields);
      setCurrentFieldIndex(0);
      setCompletionProgress(0);
      setShowSuccess(false);
    }
  }, [isOpen, fortuneCategory]);

  // 진행률 계산
  useEffect(() => {
    if (missingFields.length > 0) {
      const progress = (currentFieldIndex / missingFields.length) * 100;
      setCompletionProgress(progress);
    }
  }, [currentFieldIndex, missingFields.length]);

  const handleFieldUpdate = (field: keyof UserInfo, value: string) => {
    setUserInfo(prev => ({ ...prev, [field]: value }));
  };

  const handleNext = () => {
    if (currentFieldIndex < missingFields.length - 1) {
      setCurrentFieldIndex(prev => prev + 1);
    } else {
      handleComplete();
    }
  };

  const handleComplete = async () => {
    setIsSaving(true);
    try {
      // 정보 저장
      saveUserInfo(userInfo);
      
      // 성공 애니메이션 표시
      setShowSuccess(true);
      
      // 잠시 후 완료 처리
      setTimeout(() => {
        onComplete();
        onClose();
      }, 1500);
    } catch (error) {
      console.error('프로필 저장 실패:', error);
      alert('정보 저장에 실패했습니다. 다시 시도해주세요.');
    } finally {
      setIsSaving(false);
    }
  };

  const isCurrentFieldValid = () => {
    if (missingFields.length === 0) return true;
    const currentField = missingFields[currentFieldIndex];
    const value = userInfo[currentField];
    return value && value.trim() !== '';
  };

  const renderFieldInput = (field: keyof UserInfo) => {
    const value = userInfo[field];
    const label = FIELD_LABELS[field];

    switch (field) {
      case 'name':
        return (
          <Input
            value={value}
            onChange={(e) => handleFieldUpdate(field, e.target.value)}
            placeholder="이름을 입력하세요"
            className="text-lg p-4"
            autoFocus
          />
        );

      case 'birthDate':
        return (
          <Input
            type="date"
            value={value}
            onChange={(e) => handleFieldUpdate(field, e.target.value)}
            className="text-lg p-4"
          />
        );

      case 'birthTime':
        return (
          <Select value={value} onValueChange={(val) => handleFieldUpdate(field, val)}>
            <SelectTrigger className="text-lg p-4">
              <SelectValue placeholder="출생시간을 선택하세요" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="자시">자시 (23:30-01:30)</SelectItem>
              <SelectItem value="축시">축시 (01:30-03:30)</SelectItem>
              <SelectItem value="인시">인시 (03:30-05:30)</SelectItem>
              <SelectItem value="묘시">묘시 (05:30-07:30)</SelectItem>
              <SelectItem value="진시">진시 (07:30-09:30)</SelectItem>
              <SelectItem value="사시">사시 (09:30-11:30)</SelectItem>
              <SelectItem value="오시">오시 (11:30-13:30)</SelectItem>
              <SelectItem value="미시">미시 (13:30-15:30)</SelectItem>
              <SelectItem value="신시">신시 (15:30-17:30)</SelectItem>
              <SelectItem value="유시">유시 (17:30-19:30)</SelectItem>
              <SelectItem value="술시">술시 (19:30-21:30)</SelectItem>
              <SelectItem value="해시">해시 (21:30-23:30)</SelectItem>
            </SelectContent>
          </Select>
        );

      case 'gender':
        return (
          <Select value={value} onValueChange={(val) => handleFieldUpdate(field, val)}>
            <SelectTrigger className="text-lg p-4">
              <SelectValue placeholder="성별을 선택하세요" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="남성">남성</SelectItem>
              <SelectItem value="여성">여성</SelectItem>
              <SelectItem value="선택 안함">선택 안함</SelectItem>
            </SelectContent>
          </Select>
        );

      case 'mbti':
        return (
          <Select value={value} onValueChange={(val) => handleFieldUpdate(field, val)}>
            <SelectTrigger className="text-lg p-4">
              <SelectValue placeholder="MBTI를 선택하세요" />
            </SelectTrigger>
            <SelectContent>
              {['ENFP', 'ENFJ', 'ENTP', 'ENTJ', 'ESFP', 'ESFJ', 'ESTP', 'ESTJ',
                'INFP', 'INFJ', 'INTP', 'INTJ', 'ISFP', 'ISFJ', 'ISTP', 'ISTJ'].map(type => (
                <SelectItem key={type} value={type}>{type}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        );

      case 'bloodType':
        return (
          <Select value={value} onValueChange={(val) => handleFieldUpdate(field, val)}>
            <SelectTrigger className="text-lg p-4">
              <SelectValue placeholder="혈액형을 선택하세요" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="A형">A형</SelectItem>
              <SelectItem value="B형">B형</SelectItem>
              <SelectItem value="AB형">AB형</SelectItem>
              <SelectItem value="O형">O형</SelectItem>
            </SelectContent>
          </Select>
        );

      case 'job':
        return (
          <Input
            value={value}
            onChange={(e) => handleFieldUpdate(field, e.target.value)}
            placeholder="직업을 입력하세요"
            className="text-lg p-4"
          />
        );

      case 'location':
        return (
          <Input
            value={value}
            onChange={(e) => handleFieldUpdate(field, e.target.value)}
            placeholder="거주지를 입력하세요"
            className="text-lg p-4"
          />
        );

      default:
        return (
          <Input
            value={value}
            onChange={(e) => handleFieldUpdate(field, e.target.value)}
            placeholder={`${label}을(를) 입력하세요`}
            className="text-lg p-4"
          />
        );
    }
  };

  if (missingFields.length === 0) {
    return null; // 필요한 정보가 모두 있으면 모달을 표시하지 않음
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-md mx-auto">
        <AnimatePresence mode="wait">
          {showSuccess ? (
            <motion.div
              key="success"
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.8 }}
              className="text-center py-8"
            >
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
                className="mx-auto w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mb-4"
              >
                <CheckCircle2 className="w-8 h-8 text-green-600" />
              </motion.div>
              <h3 className="text-lg font-semibold mb-2">정보 저장 완료!</h3>
              <p className="text-gray-600">이제 {fortuneTitle || '운세'}를 확인할 수 있습니다.</p>
            </motion.div>
          ) : (
            <motion.div
              key="form"
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -20 }}
            >
              <DialogHeader className="pb-4">
                <div className="flex items-center gap-2 mb-2">
                  <AlertCircle className="w-5 h-5 text-amber-500" />
                  <DialogTitle className="text-lg">추가 정보 필요</DialogTitle>
                </div>
                <DialogDescription>
                  {fortuneTitle || '운세'}를 확인하기 위해 몇 가지 정보가 더 필요합니다.
                </DialogDescription>
              </DialogHeader>

              {/* 진행률 */}
              <div className="mb-6">
                <div className="flex items-center justify-between mb-2">
                  <span className="text-sm text-gray-600">
                    {currentFieldIndex + 1} / {missingFields.length}
                  </span>
                  <Badge variant="outline" className="text-xs">
                    {Math.round(completionProgress)}% 완료
                  </Badge>
                </div>
                <Progress value={completionProgress} className="h-2" />
              </div>

              {/* 현재 필드 입력 */}
              {missingFields.length > 0 && (
                <motion.div
                  key={currentFieldIndex}
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-4"
                >
                  <div className="space-y-3">
                    <div className="flex items-center gap-2">
                      {fieldIcons[missingFields[currentFieldIndex]]}
                      <Label className="text-base font-medium">
                        {FIELD_LABELS[missingFields[currentFieldIndex]]}
                      </Label>
                    </div>
                    {renderFieldInput(missingFields[currentFieldIndex])}
                  </div>

                  {/* 버튼 */}
                  <div className="flex gap-2 pt-4">
                    <Button
                      onClick={onClose}
                      variant="outline"
                      className="flex-1"
                    >
                      나중에
                    </Button>
                    <Button
                      onClick={handleNext}
                      disabled={!isCurrentFieldValid() || isSaving}
                      className="flex-1 bg-gradient-to-r from-purple-500 to-indigo-500 hover:from-purple-600 hover:to-indigo-600"
                    >
                      {isSaving ? (
                        '저장 중...'
                      ) : currentFieldIndex === missingFields.length - 1 ? (
                        '완료'
                      ) : (
                        <div className="flex items-center gap-1">
                          다음
                          <ChevronRight className="w-4 h-4" />
                        </div>
                      )}
                    </Button>
                  </div>
                </motion.div>
              )}
            </motion.div>
          )}
        </AnimatePresence>
      </DialogContent>
    </Dialog>
  );
}