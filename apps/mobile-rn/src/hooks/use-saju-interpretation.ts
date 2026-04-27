/**
 * useSajuInterpretation — SajuResult를 Edge Function `manseryeok-interpret`에
 * 전달해 AI 해석을 받아오는 훅.
 *
 * 핵심 정책:
 *  - 초기 데이터로 클라이언트 사이드 fallback을 **즉시** 반환 (로딩 상태 없이).
 *  - 동시에 Edge Function을 background에서 시도.
 *  - 성공 시 data 교체, 실패 시 fallback 유지 (에러는 조용히 무시).
 *  - 사용자에겐 항상 해석이 보임.
 *
 * - 네트워크: `supabase.functions.invoke('manseryeok-interpret')`
 * - sajuData.pillars의 4주 한글(korean) 조합 변경 시만 재요청
 */

import { useCallback, useEffect, useRef, useState } from 'react';

import type { SajuResult } from '@fortune/saju-engine';

import { generateFallbackInterpretation } from '../lib/saju-interpretation-fallback';
import { supabase } from '../lib/supabase';

export interface PersonalityInterpretation {
  summary: string;
  strengths: string[];
  challenges: string[];
}
export interface CareerInterpretation {
  summary: string;
  suitableFields: string[];
  advice: string;
}
export interface WealthInterpretation {
  summary: string;
  bestPeriods: string[];
  caution: string;
}
export interface LoveInterpretation {
  summary: string;
  compatibleTypes: string[];
  advice: string;
}
export interface HealthInterpretation {
  summary: string;
  weakPoints: string[];
  advice: string;
}
export interface DailyInterpretation {
  oneLiner: string;
  luckyColor: string;
  luckyDirection: string;
}
export interface LuckCycleInterpretation {
  ageRange: string;
  theme: string;
  summary: string;
}

export interface SajuInterpretationData {
  overallSummary: string;
  personality: PersonalityInterpretation;
  career: CareerInterpretation;
  wealth: WealthInterpretation;
  love: LoveInterpretation;
  health: HealthInterpretation;
  daily: DailyInterpretation;
  luckCycles: LuckCycleInterpretation[];
}

interface UseSajuInterpretationResult {
  data: SajuInterpretationData | null;
  /** Edge Function이 아직 응답 전인지 (fallback 사용 중) */
  isEnhancing: boolean;
  /** 남겨진 호환성 — fallback이 있으면 false */
  isLoading: boolean;
  error: string | null;
  refetch: () => void;
}

interface EdgeResponseShape {
  success: boolean;
  data?: SajuInterpretationData;
  error?: string;
}

/** 4주 조합으로 캐시/재요청 키 생성 — 동일 사주면 재호출 없음 */
function sajuFingerprint(saju: SajuResult | null): string | null {
  if (!saju) return null;
  const p = saju.pillars;
  return [
    p.year.korean,
    p.month.korean,
    p.day.korean,
    p.hour.korean,
  ].join('-');
}

export function useSajuInterpretation(
  sajuData: SajuResult | null,
): UseSajuInterpretationResult {
  // 초기 상태: sajuData가 있으면 즉시 fallback
  const [data, setData] = useState<SajuInterpretationData | null>(() =>
    sajuData ? generateFallbackInterpretation(sajuData) : null,
  );
  const [isEnhancing, setIsEnhancing] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const fingerprint = sajuFingerprint(sajuData);
  const abortRef = useRef<AbortController | null>(null);

  const fetchInterpretation = useCallback(async () => {
    if (!sajuData) return;

    // fallback 먼저 보장
    setData((prev) => prev ?? generateFallbackInterpretation(sajuData));

    // supabase 미설정 → fallback 유지
    if (!supabase) return;

    // 진행 중인 요청 취소
    abortRef.current?.abort();
    const controller = new AbortController();
    abortRef.current = controller;

    setIsEnhancing(true);
    setError(null);
    try {
      const { data: res, error: invokeError } = await supabase.functions.invoke<
        EdgeResponseShape
      >('manseryeok-interpret', {
        body: { sajuData },
      });

      if (controller.signal.aborted) return;

      if (invokeError) throw invokeError;
      if (!res) throw new Error('empty response');
      if (!res.success || !res.data) {
        throw new Error(res.error ?? 'interpretation failed');
      }

      // Edge Function 성공 → fallback을 AI 결과로 교체
      setData(res.data);
    } catch (e: unknown) {
      if (controller.signal.aborted) return;
      // 에러는 조용히 무시, fallback 유지
      const message = e instanceof Error ? e.message : String(e);
      setError(message);
    } finally {
      if (!controller.signal.aborted) {
        setIsEnhancing(false);
      }
    }
  }, [sajuData]);

  useEffect(() => {
    if (fingerprint && sajuData) {
      // fingerprint 변경 시 우선 fallback 반영
      setData(generateFallbackInterpretation(sajuData));
      void fetchInterpretation();
    } else {
      setData(null);
      setError(null);
      setIsEnhancing(false);
    }
    return () => {
      abortRef.current?.abort();
    };
    // fingerprint만 의존성 — 동일 사주는 재호출 없음.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [fingerprint]);

  return {
    data,
    isEnhancing,
    isLoading: false,
    error,
    refetch: fetchInterpretation,
  };
}
