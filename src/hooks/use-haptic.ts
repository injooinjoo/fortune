"use client";

import { useCallback, useEffect, useState } from "react";

interface HapticOptions {
  duration?: number;
  intensity?: 'light' | 'medium' | 'heavy';
}

export function useHaptic() {
  const [isSupported, setIsSupported] = useState(false);

  useEffect(() => {
    // 햅틱 피드백 지원 여부 확인
    setIsSupported(
      typeof window !== 'undefined' && 
      'vibrate' in navigator &&
      // 모바일 디바이스 감지 (간단한 방법)
      /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
    );
  }, []);

  const vibrate = useCallback((options: HapticOptions = {}) => {
    if (!isSupported) return;

    const { duration = 50, intensity = 'medium' } = options;

    // 강도별 진동 패턴 정의
    const patterns = {
      light: [duration],
      medium: [duration, 10, duration],
      heavy: [duration, 20, duration, 10, duration]
    };

    try {
      navigator.vibrate(patterns[intensity]);
    } catch (error) {
      console.warn('Haptic feedback failed:', error);
    }
  }, [isSupported]);

  const snapFeedback = useCallback(() => {
    vibrate({ duration: 30, intensity: 'light' });
  }, [vibrate]);

  const selectFeedback = useCallback(() => {
    vibrate({ duration: 50, intensity: 'medium' });
  }, [vibrate]);

  const impactFeedback = useCallback(() => {
    vibrate({ duration: 100, intensity: 'heavy' });
  }, [vibrate]);

  return {
    isSupported,
    vibrate,
    snapFeedback,
    selectFeedback,
    impactFeedback
  };
}