'use client';

import { useState, useCallback, useEffect } from 'react';
import { BatchFortuneRequest, BatchFortuneResponse } from '@/types/batch-fortune';
import { useUser } from './use-user';

interface UseBatchFortuneOptions {
  packageName?: string;
  fortuneTypes?: string[];
  cacheEnabled?: boolean;
}

interface UseBatchFortuneResult {
  fortuneData: BatchFortuneResponse | null;
  loading: boolean;
  error: string | null;
  generateBatchFortune: (options?: UseBatchFortuneOptions) => Promise<void>;
  getFortuneByType: (type: string) => any | null;
  refreshFortune: () => Promise<void>;
}

export function useBatchFortune(options: UseBatchFortuneOptions = {}): UseBatchFortuneResult {
  const { user, profile } = useUser();
  const [fortuneData, setFortuneData] = useState<BatchFortuneResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const { packageName, fortuneTypes, cacheEnabled = true } = options;

  // 캐시 키 생성
  const getCacheKey = useCallback((types: string[]) => {
    const today = new Date().toISOString().split('T')[0];
    const key = types.sort().join('_');
    return `batch_fortune_${user?.id}_${key}_${today}`;
  }, [user?.id]);

  // 캐시에서 로드
  const loadFromCache = useCallback((types: string[]) => {
    if (!cacheEnabled) return null;
    
    const cacheKey = getCacheKey(types);
    const cached = localStorage.getItem(cacheKey);
    
    if (cached) {
      try {
        const data = JSON.parse(cached);
        const expiresAt = new Date(data.cache_info.expires_at);
        
        if (expiresAt > new Date()) {
          return data;
        }
      } catch (err) {
        console.error('캐시 파싱 오류:', err);
      }
    }
    
    return null;
  }, [cacheEnabled, getCacheKey]);

  // 캐시에 저장
  const saveToCache = useCallback((data: BatchFortuneResponse, types: string[]) => {
    if (!cacheEnabled) return;
    
    const cacheKey = getCacheKey(types);
    try {
      localStorage.setItem(cacheKey, JSON.stringify(data));
    } catch (err) {
      console.error('캐시 저장 오류:', err);
    }
  }, [cacheEnabled, getCacheKey]);

  // 배치 운세 생성
  const generateBatchFortune = useCallback(async (overrideOptions?: UseBatchFortuneOptions) => {
    if (!user || !profile) {
      setError('로그인이 필요합니다.');
      return;
    }

    const finalOptions = { ...options, ...overrideOptions };
    const types = finalOptions.fortuneTypes || fortuneTypes || ['daily'];

    // 캐시 확인
    const cached = loadFromCache(types);
    if (cached) {
      setFortuneData(cached);
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const request: BatchFortuneRequest = {
        request_type: 'user_direct_request',
        user_profile: {
          id: user.id,
          name: profile.name || '사용자',
          birth_date: profile.birth_date || '1990-01-01',
          birth_time: profile.birth_time,
          gender: profile.gender,
          mbti: profile.mbti,
          zodiac_sign: profile.zodiac_sign,
          relationship_status: profile.relationship_status
        },
        fortune_types: types,
        requested_categories: finalOptions.packageName ? [finalOptions.packageName] : undefined,
        target_date: new Date().toISOString().split('T')[0],
        generation_context: {
          cache_duration_hours: 24,
          is_user_initiated: true
        }
      };

      const response = await fetch('/api/fortune/generate-batch', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(request)
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || '운세 생성에 실패했습니다.');
      }

      const data: BatchFortuneResponse = await response.json();
      setFortuneData(data);
      
      // 캐시 저장
      saveToCache(data, types);
    } catch (err) {
      console.error('배치 운세 생성 오류:', err);
      setError(err instanceof Error ? err.message : '알 수 없는 오류가 발생했습니다.');
    } finally {
      setLoading(false);
    }
  }, [user, profile, options, fortuneTypes, loadFromCache, saveToCache]);

  // 특정 타입의 운세 가져오기
  const getFortuneByType = useCallback((type: string) => {
    if (!fortuneData) return null;
    return fortuneData.analysis_results[type] || null;
  }, [fortuneData]);

  // 운세 새로고침
  const refreshFortune = useCallback(async () => {
    // 캐시 무효화
    const types = fortuneTypes || ['daily'];
    const cacheKey = getCacheKey(types);
    localStorage.removeItem(cacheKey);
    
    // 다시 생성
    await generateBatchFortune();
  }, [fortuneTypes, getCacheKey, generateBatchFortune]);

  // 초기 로드
  useEffect(() => {
    if (user && profile && !fortuneData && !loading) {
      generateBatchFortune();
    }
  }, [user, profile, fortuneData, loading, generateBatchFortune]);

  return {
    fortuneData,
    loading,
    error,
    generateBatchFortune,
    getFortuneByType,
    refreshFortune
  };
}