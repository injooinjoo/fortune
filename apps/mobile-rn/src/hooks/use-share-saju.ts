import { useCallback } from 'react';

import { Share } from 'react-native';
import type { SajuResult } from '@fortune/saju-engine';

import { captureError } from '../lib/error-reporting';

/**
 * Shares the user's Saju summary via the OS share sheet.
 *
 * Text-only for this sprint — `react-native-view-shot` / `expo-sharing` are
 * not installed, and the contract forbids adding new deps. The builtin
 * `Share.share` delivers good-enough UX across iOS / Android: user can pick
 * messages, mail, etc.
 *
 * Share cancellation throws silently on some platforms; we swallow it so the
 * button press always feels safe.
 */
export function useShareSaju() {
  return useCallback(async (saju: SajuResult) => {
    const p = saju.pillars;
    const e = saju.elements;

    const message =
      `나의 사주 만세력\n` +
      `───────────────\n` +
      `년주: ${p.year.korean} (${p.year.hanja})\n` +
      `월주: ${p.month.korean} (${p.month.hanja})\n` +
      `일주: ${p.day.korean} (${p.day.hanja})\n` +
      `시주: ${p.hour.korean} (${p.hour.hanja})\n\n` +
      `일간: ${saju.dayMaster.korean} (${saju.dayMaster.element})\n` +
      `오행: 木${e.wood} 火${e.fire} 土${e.earth} 金${e.metal} 水${e.water}\n` +
      `강한 오행: ${e.strongest} · 약한 오행: ${e.weakest}\n\n` +
      `Ondo에서 확인한 내 운세`;

    try {
      await Share.share({ message });
    } catch (error) {
      // Share sheet cancellation also lands here on iOS. Log without surfacing.
      void captureError(error, { surface: 'share:my-saju' });
    }
  }, []);
}
