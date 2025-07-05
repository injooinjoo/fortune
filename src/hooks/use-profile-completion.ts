"use client";

import { useState, useCallback } from "react";
import { FortuneCategory } from "@/lib/types/fortune-system";
import { getUserInfo } from "@/lib/user-storage";
import { checkFortuneProfileCompleteness } from "@/lib/profile-completeness";

export function useProfileCompletion() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [currentFortune, setCurrentFortune] = useState<{
    category: FortuneCategory;
    title?: string;
  } | null>(null);

  // 특정 운세에 필요한 프로필이 완성되었는지 확인
  const checkProfileCompletion = useCallback((fortuneCategory: FortuneCategory) => {
    const userInfo = getUserInfo();
    const completeness = checkFortuneProfileCompleteness(userInfo, fortuneCategory);
    return {
      isComplete: completeness.isComplete,
      missingFields: completeness.missingFields,
      completionPercentage: completeness.completionPercentage
    };
  }, []);

  // 프로필이 부족한 경우 모달을 열고, 완성된 경우 콜백 실행
  const requireProfileCompletion = useCallback((
    fortuneCategory: FortuneCategory,
    fortuneTitle: string,
    onComplete: () => void
  ) => {
    const { isComplete } = checkProfileCompletion(fortuneCategory);
    
    if (isComplete) {
      // 프로필이 완성된 경우 바로 실행
      onComplete();
    } else {
      // 프로필이 부족한 경우 모달 오픈
      setCurrentFortune({ category: fortuneCategory, title: fortuneTitle });
      setIsModalOpen(true);
    }
  }, [checkProfileCompletion]);

  // 모달에서 프로필 완성 후 호출될 콜백
  const handleProfileComplete = useCallback(() => {
    setIsModalOpen(false);
    // 완성 후 추가 작업이 있다면 여기서 처리
  }, []);

  // 모달 닫기
  const closeModal = useCallback(() => {
    setIsModalOpen(false);
    setCurrentFortune(null);
  }, []);

  return {
    isModalOpen,
    currentFortune,
    checkProfileCompletion,
    requireProfileCompletion,
    handleProfileComplete,
    closeModal
  };
}