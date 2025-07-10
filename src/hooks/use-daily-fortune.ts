'use client';

import { logger } from '@/lib/logger';
import { useState, useCallback, useEffect } from 'react';
import { z } from 'zod';
import { 
    UserProfileSchema, 
    LifeProfileResultSchema, 
    ComprehensiveDailyFortuneResultSchema, 
    InteractiveFortuneResultSchema 
} from '@/lib/types/fortune-schemas';

type FortuneResult<T> = T | null;
type FortuneError = Error | null;

// 배치 응답을 로컬 캐시에 저장하는 헬퍼 함수
const saveBatchToLocalCache = (batchData: any) => {
  if (!batchData || !batchData.analysis_results) return;
  
  const expiresAt = batchData.cache_info?.expires_at || 
    new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString();
  
  // 각 운세 타입별로 개별 저장
  Object.entries(batchData.analysis_results).forEach(([fortuneType, data]) => {
    const cacheKey = `fortune_cache_${batchData.user_id}_${fortuneType}_${new Date().toISOString().split('T')[0]}`;
    const cacheData = {
      data,
      fortuneType,
      generatedAt: batchData.generated_at,
      expiresAt,
      fromBatch: true,
      batchId: batchData.request_id
    };
    
    try {
      localStorage.setItem(cacheKey, JSON.stringify(cacheData));
    } catch (error) {
      logger.error(`Failed to cache ${fortuneType}:`, error);
    }
  });
};

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

const callBatchFortuneApi = async (requestType: string, userProfile: any, fortuneTypes?: string[], targetDate?: string) => {
  const response = await fetch('/api/fortune/generate-batch', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      request_type: requestType,
      user_profile: userProfile,
      fortune_types: fortuneTypes,
      target_date: targetDate,
      generation_context: {
        cache_duration_hours: requestType === 'daily_refresh' ? 24 : 72
      }
    }),
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(errorData.error || `Batch API call failed with status: ${response.status}`);
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
      const result = await callFortuneApi(flowType, { ...userProfile, ...input });
      
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

  // 배치 운세 생성 함수들
  const refreshDailyFortune = useCallback(async () => {
    if (!userProfile) {
      setError(new Error('User profile is not available.'));
      return;
    }

    setIsGenerating(true);
    setError(null);
    
    try {
      const batchData = await callBatchFortuneApi(
        'daily_refresh',
        userProfile,
        ['daily', 'hourly', 'today', 'tomorrow'],
        new Date().toISOString().split('T')[0]
      );
      
      // 개별 운세 데이터 추출 및 상태 업데이트
      if (batchData.analysis_results?.daily) {
        setDailyFortune(batchData.analysis_results.daily);
      }
      
      // 로컬 캐시에 저장
      saveBatchToLocalCache(batchData);
      
      return batchData;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setIsGenerating(false);
    }
  }, [userProfile]);

  const generateCompleteFortune = useCallback(async () => {
    if (!userProfile) {
      setError(new Error('User profile is not available.'));
      return;
    }

    setIsGenerating(true);
    setError(null);
    
    try {
      const batchData = await callBatchFortuneApi(
        'onboarding_complete',
        userProfile,
        ['saju', 'traditional-saju', 'tojeong', 'salpuli', 'past-life']
      );
      
      // 평생 운세 데이터 처리
      if (batchData.analysis_results) {
        // 첫 번째 결과를 lifeProfile로 설정
        const firstFortuneType = Object.keys(batchData.analysis_results)[0];
        if (firstFortuneType) {
          setLifeProfile(batchData.analysis_results[firstFortuneType]);
        }
      }
      
      saveBatchToLocalCache(batchData);
      
      return batchData;
    } catch (err: any) {
      setError(err);
      throw err;
    } finally {
      setIsGenerating(false);
    }
  }, [userProfile]);

  return {
    isGenerating,
    error,
    lifeProfile,
    dailyFortune,
    interactiveFortune,
    generateLifePackage,
    generateDailyPackage,
    generateInteractivePackage,
    // 새로운 배치 함수들
    refreshDailyFortune,
    generateCompleteFortune,
  };
}

// 운세 기록 조회를 위한 별도 훅
export function useFortuneHistory(fortuneType?: string, limit: number = 10) {
  const [history, setHistory] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const loadHistory = useCallback(async () => {
    setIsLoading(true);
    setError(null);
    
    try {
      // 로컬 스토리지에서 운세 기록 조회
      const keys = Object.keys(localStorage).filter(key => key.startsWith('demo_completion_'));
      const historyData = keys
        .map(key => {
          try {
            return JSON.parse(localStorage.getItem(key) || '{}');
          } catch {
            return null;
          }
        })
        .filter(item => item && (!fortuneType || item.fortune_type === fortuneType))
        .sort((a, b) => new Date(b.started_at).getTime() - new Date(a.started_at).getTime())
        .slice(0, limit);
      
      setHistory(historyData);
    } catch (err) {
      setError('운세 기록을 불러오는데 실패했습니다.');
      logger.error('운세 기록 로드 실패:', err);
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