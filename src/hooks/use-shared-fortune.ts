'use client';

import { logger } from '@/lib/logger';
import { useState, useCallback } from 'react';
import { z } from 'zod';
import { GroupFortuneInputSchema, GroupFortuneOutputSchema } from '@/lib/types/fortune-schemas';
import { SharedFortuneService, SharedFortuneData } from '@/lib/shared-fortune-service';

type GroupKey = string | null;
type FortuneType = z.infer<typeof GroupFortuneInputSchema>['fortuneType'];

const callGroupFortuneApi = async (input: z.infer<typeof GroupFortuneInputSchema>) => {
  const response = await fetch('/api/fortune/generate', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ flowType: 'generateGroupFortune', ...input }),
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(errorData.error || `API call failed with status: ${response.status}`);
  }
  return response.json();
};

export function useSharedFortune(fortuneType: FortuneType) {
  const [data, setData] = useState<z.infer<typeof GroupFortuneOutputSchema> | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [activeGroupKey, setActiveGroupKey] = useState<GroupKey>(null);

  const fetchFortune = useCallback(async (groupKey: string) => {
    if (!groupKey) {
      setData(null);
      return;
    }

    setActiveGroupKey(groupKey);
    setIsLoading(true);
    setError(null);

    try {
      const today = new Date().toISOString().split('T')[0];
      const existingFortune: SharedFortuneData | null = await SharedFortuneService.getSharedFortune(groupKey, fortuneType, today);

      if (existingFortune) {
        setData(existingFortune.fortune_data as z.infer<typeof GroupFortuneOutputSchema>);
      } else {
        const input = { fortuneType, groupKey, date: today };
        const generatedData = await callGroupFortuneApi(input);
        
        const savedResult = await SharedFortuneService.saveSharedFortune(groupKey, fortuneType, today, generatedData);
        if (savedResult) {
          setData(savedResult.fortune_data as z.infer<typeof GroupFortuneOutputSchema>);
        }
      }
    } catch (err: any) {
      const errorMessage = `운세 정보를 가져오는 데 실패했습니다: ${err.message}`;
      logger.error(errorMessage, err);
      setError(errorMessage);
    } finally {
      setIsLoading(false);
    }
  }, [fortuneType]);

  return {
    data,
    isLoading,
    error,
    activeGroupKey,
    fetchFortune,
  };
} 