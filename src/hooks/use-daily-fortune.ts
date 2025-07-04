'use client';

import { useState } from 'react';
import { z } from 'zod';
import { 
    UserProfileSchema, 
    LifeProfileResultSchema, 
    ComprehensiveDailyFortuneResultSchema, 
    InteractiveFortuneResultSchema 
} from '@/lib/types/fortune-schemas';

type FortuneResult<T> = T | null;
type FortuneError = Error | null;

const callFortuneApi = async (flowType: string, input: any) => {
  const response = await fetch('/api/fortune/generate', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ flowType, ...input }),
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(errorData.error || `API call failed with status: ${response.status}`);
  }
  return response.json();
};

export function useDailyFortune(userProfile: z.infer<typeof UserProfileSchema> | null) {
  const [isGenerating, setIsGenerating] = useState<boolean>(false);
  const [error, setError] = useState<FortuneError>(null);

  const [lifeProfile, setLifeProfile] = useState<FortuneResult<z.infer<typeof LifeProfileResultSchema>>>(null);
  const [dailyFortune, setDailyFortune] = useState<FortuneResult<z.infer<typeof ComprehensiveDailyFortuneResultSchema>>>(null);
  const [interactiveFortune, setInteractiveFortune] = useState<FortuneResult<z.infer<typeof InteractiveFortuneResultSchema>>>(null);

  const handleGeneration = async (flowType: string, input: any) => {
    if (!userProfile) {
      const err = new Error('User profile is not available.');
      setError(err);
      return;
    }

    setIsGenerating(true);
    setError(null);
    try {
      const result = await callFortuneApi(flowType, { userProfile, ...input });
      
      switch (flowType) {
        case 'generateLifeProfile':
          setLifeProfile(result);
          break;
        case 'generateComprehensiveDailyFortune':
          setDailyFortune(result);
          break;
        case 'generateInteractiveFortune':
          setInteractiveFortune(result);
          break;
      }
      return result;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setIsGenerating(false);
    }
  };

  const generateLifePackage = () => {
    return handleGeneration('generateLifeProfile', {});
  };
  
  const generateDailyPackage = (date: string) => {
    return handleGeneration('generateComprehensiveDailyFortune', { date });
  };
  
  const generateInteractivePackage = (category: string, input: Record<string, any>) => {
    return handleGeneration('generateInteractiveFortune', { category, input });
  };


  return {
    isGenerating,
    error,
    lifeProfile,
    dailyFortune,
    interactiveFortune,
    generateLifePackage,
    generateDailyPackage,
    generateInteractivePackage,
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
    loadHistory,
  };
} 