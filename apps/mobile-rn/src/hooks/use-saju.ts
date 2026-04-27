/**
 * useMySaju — 프로필의 생년월일시를 바탕으로 만세력(4주+상세)을 계산.
 *
 * 결정적(deterministic) 계산 — 네트워크 없음, 캐시 없음. 메모화로 재계산 최소화.
 * Sprint 1 기준: profile.gender 필드가 아직 없음 → 기본값 'male'.
 * Sprint 2에서 UI가 이 훅을 소비할 예정.
 */

import { useMemo } from 'react';
import {
  calculateSaju,
  type SajuInput,
  type SajuResult,
  type Gender,
} from '@fortune/saju-engine';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

/** 기본 gender — 프로필에 gender 필드가 없는 경우 */
const DEFAULT_GENDER: Gender = 'male';

export interface UseSajuOptions {
  /** 강제 gender override */
  gender?: Gender;
  /** 현재 기준 연도 (세운 계산) */
  referenceYear?: number;
}

/**
 * 내 프로필 기준 만세력 결과.
 * birthDate가 없으면 null 반환.
 */
export function useMySaju(options: UseSajuOptions = {}): SajuResult | null {
  const { state } = useMobileAppState();
  const birthDate = state.profile.birthDate;
  const birthTime = state.profile.birthTime || '00:00';
  const gender = options.gender ?? DEFAULT_GENDER;
  const referenceYear = options.referenceYear;

  return useMemo<SajuResult | null>(() => {
    const trimmed = (birthDate ?? '').trim();
    if (!trimmed || !/^\d{4}-\d{2}-\d{2}$/.test(trimmed)) return null;
    const normalizedTime = /^\d{2}:\d{2}$/.test((birthTime ?? '').trim())
      ? birthTime.trim()
      : '00:00';
    const input: SajuInput = {
      birthDate: trimmed,
      birthTime: normalizedTime,
      isLunar: false,
      gender,
      ...(referenceYear !== undefined ? { referenceYear } : {}),
    };
    try {
      return calculateSaju(input);
    } catch (err) {
      console.warn('[useMySaju] calculateSaju failed:', err, { input });
      return null;
    }
  }, [birthDate, birthTime, gender, referenceYear]);
}

/** 임의의 입력으로 사주 계산 (친구/캐릭터용) */
export function useSajuFor(input: SajuInput | null): SajuResult | null {
  return useMemo<SajuResult | null>(() => {
    if (!input) return null;
    try {
      return calculateSaju(input);
    } catch {
      return null;
    }
  }, [input]);
}
