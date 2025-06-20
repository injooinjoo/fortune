import { useState, useEffect, useCallback } from 'react';
import { DailyFortuneService } from '@/lib/daily-fortune-service';
import { DailyFortuneData, FortuneResult } from '@/lib/schemas';
import { useToast } from './use-toast';

interface UseDailyFortuneProps {
  fortuneType: string;
  enabled?: boolean; // 자동 로딩 여부
}

interface UseDailyFortuneReturn {
  // 상태
  todayFortune: DailyFortuneData | null;
  isLoading: boolean;
  isGenerating: boolean;
  error: string | null;
  
  // 메서드
  loadTodayFortune: () => Promise<void>;
  saveFortune: (fortuneData: FortuneResult) => Promise<boolean>;
  regenerateFortune: (fortuneData: FortuneResult) => Promise<boolean>;
  clearError: () => void;
  
  // 헬퍼
  hasTodayFortune: boolean;
  canRegenerate: boolean;
}

export function useDailyFortune({ 
  fortuneType, 
  enabled = true 
}: UseDailyFortuneProps): UseDailyFortuneReturn {
  const [todayFortune, setTodayFortune] = useState<DailyFortuneData | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [isGenerating, setIsGenerating] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { toast } = useToast();

  // 오늘 운세 로드
  const loadTodayFortune = useCallback(async () => {
    if (!enabled) return;
    
    setIsLoading(true);
    setError(null);
    
    try {
      const userId = await DailyFortuneService.getUserId();
      const fortune = await DailyFortuneService.getTodayFortune(userId, fortuneType);
      setTodayFortune(fortune);
    } catch (err) {
      const errorMessage = '오늘 운세를 불러오는데 실패했습니다.';
      setError(errorMessage);
      console.error('오늘 운세 로드 실패:', err);
    } finally {
      setIsLoading(false);
    }
  }, [fortuneType, enabled]);

  // 새 운세 저장
  const saveFortune = useCallback(async (fortuneData: FortuneResult): Promise<boolean> => {
    setIsGenerating(true);
    setError(null);
    
    try {
      const userId = await DailyFortuneService.getUserId();
      const savedFortune = await DailyFortuneService.saveTodayFortune(
        userId, 
        fortuneType, 
        fortuneData
      );
      
      if (savedFortune) {
        setTodayFortune(savedFortune);
        toast({
          title: "운세 저장 완료",
          description: "오늘의 운세가 저장되었습니다.",
        });
        return true;
      } else {
        throw new Error('운세 저장에 실패했습니다.');
      }
    } catch (err) {
      const errorMessage = '운세 저장에 실패했습니다.';
      setError(errorMessage);
      toast({
        title: "저장 실패",
        description: errorMessage,
        variant: "destructive",
      });
      console.error('운세 저장 실패:', err);
      return false;
    } finally {
      setIsGenerating(false);
    }
  }, [fortuneType, toast]);

  // 운세 재생성 (업데이트)
  const regenerateFortune = useCallback(async (fortuneData: FortuneResult): Promise<boolean> => {
    if (!todayFortune?.id) {
      return saveFortune(fortuneData);
    }
    
    setIsGenerating(true);
    setError(null);
    
    try {
      const updatedFortune = await DailyFortuneService.updateTodayFortune(
        todayFortune.id, 
        fortuneData
      );
      
      if (updatedFortune) {
        setTodayFortune(updatedFortune);
        toast({
          title: "운세 재생성 완료",
          description: "새로운 운세가 생성되었습니다.",
        });
        return true;
      } else {
        throw new Error('운세 재생성에 실패했습니다.');
      }
    } catch (err) {
      const errorMessage = '운세 재생성에 실패했습니다.';
      setError(errorMessage);
      toast({
        title: "재생성 실패",
        description: errorMessage,
        variant: "destructive",
      });
      console.error('운세 재생성 실패:', err);
      return false;
    } finally {
      setIsGenerating(false);
    }
  }, [todayFortune, fortuneType, toast, saveFortune]);

  // 에러 클리어
  const clearError = useCallback(() => {
    setError(null);
  }, []);

  // 초기 로드
  useEffect(() => {
    if (enabled) {
      loadTodayFortune();
    }
  }, [loadTodayFortune, enabled]);

  // 헬퍼 값들
  const hasTodayFortune = todayFortune !== null;
  const canRegenerate = hasTodayFortune && !isGenerating;

  return {
    // 상태
    todayFortune,
    isLoading,
    isGenerating,
    error,
    
    // 메서드
    loadTodayFortune,
    saveFortune,
    regenerateFortune,
    clearError,
    
    // 헬퍼
    hasTodayFortune,
    canRegenerate,
  };
}

// 운세 기록 조회를 위한 별도 훅
export function useFortuneHistory(fortuneType?: string, limit: number = 10) {
  const [history, setHistory] = useState<DailyFortuneData[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadHistory = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      const userId = await DailyFortuneService.getUserId();
      const historyData = await DailyFortuneService.getFortuneHistory(
        userId, 
        fortuneType, 
        limit
      );
      setHistory(historyData);
    } catch (err) {
      setError('운세 기록을 불러오는데 실패했습니다.');
      console.error('운세 기록 로드 실패:', err);
    } finally {
      setIsLoading(false);
    }
  }, [fortuneType, limit]);

  useEffect(() => {
    loadHistory();
  }, [loadHistory]);

  return {
    history,
    isLoading,
    error,
    reload: loadHistory,
  };
} 