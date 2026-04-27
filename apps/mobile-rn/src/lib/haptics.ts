/**
 * Centralized haptic feedback service.
 *
 * 4-Tier hierarchy (scarcity principle):
 *   Tier 1 - Magical Moments: rare, multi-phase patterns (reveals, unlocks, jackpots)
 *   Tier 2 - Important Transitions: single medium/success hits (selections, completions)
 *   Tier 3 - General Interactions: light/selection taps (buttons, navigation, toggles)
 *   Tier 4 - Silent: scrolling, typing, hover (no haptic)
 *
 * All methods are safe to call on any platform — they silently no-op when
 * the native haptic module is unavailable (e.g. web, simulators).
 */

import * as Haptics from 'expo-haptics';
import { Platform } from 'react-native';

const isHapticPlatform = Platform.OS === 'ios' || Platform.OS === 'android';

function safe(fn: () => Promise<void>) {
  if (!isHapticPlatform) return;
  fn().catch(() => undefined);
}

function delay(ms: number) {
  return new Promise<void>((resolve) => setTimeout(resolve, ms));
}

// ---------------------------------------------------------------------------
// Tier 3 — General Interactions (light feedback)
// ---------------------------------------------------------------------------

/** Generic button tap */
export function tapLight() {
  safe(() => Haptics.selectionAsync());
}

/** Page / scroll snap, navigation transition */
export function pageSnap() {
  safe(() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light));
}

/** Toggle switch, checkbox, radio */
export function toggleSelect() {
  safe(() => Haptics.selectionAsync());
}

/** Bottom sheet open */
export function sheetOpen() {
  safe(() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light));
}

/** Bottom sheet dismiss */
export function sheetDismiss() {
  safe(() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Soft));
}

/** Swipe complete */
export function swipeComplete() {
  safe(() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light));
}

// ---------------------------------------------------------------------------
// Tier 2 — Important Transitions (meaningful state changes)
// ---------------------------------------------------------------------------

/** Card selection, analysis start, section complete */
export function confirmAction() {
  safe(() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium));
}

/** Form submission, save, date/time confirm */
export function formSubmit() {
  safe(() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium));
}

/** Loading / async operation complete */
export function loadingComplete() {
  safe(() => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success));
}

/** Share action */
export function shareAction() {
  safe(() => Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium));
}

/** Authentication success */
export function authSuccess() {
  safe(() => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success));
}

/** Purchase confirmed */
export function purchaseSuccess() {
  safe(async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    await delay(100);
    await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  });
}

/** Warning state */
export function warning() {
  safe(() => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning));
}

/** Error state */
export function error() {
  safe(() => Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error));
}

// ---------------------------------------------------------------------------
// Tier 1 — Magical Moments (rare, special occasions)
// ---------------------------------------------------------------------------

/** Score-based reveal — intensity scales with score */
export function scoreReveal(score: number) {
  safe(async () => {
    if (score >= 90) {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
      await delay(100);
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      await delay(100);
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } else if (score >= 80) {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } else if (score >= 70) {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    } else if (score >= 50) {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    } else {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Soft);
    }
  });
}

/** Compatibility score reveal */
export function compatibilityReveal(score: number) {
  safe(async () => {
    if (score >= 90) {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      await delay(100);
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    } else if (score >= 70) {
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } else {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    }
  });
}

/** Tarot card flip — mystical 3-phase pattern */
export function tarotReveal() {
  safe(async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Soft);
    await delay(150);
    await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    await delay(100);
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
  });
}

/** Premium content unlock — crescendo pattern */
export function premiumUnlock() {
  safe(async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Soft);
    await delay(80);
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    await delay(80);
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    await delay(80);
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
    await delay(100);
    await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  });
}

/** Top 1% jackpot — triple celebration */
export function jackpot() {
  safe(async () => {
    for (let i = 0; i < 3; i++) {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      if (i < 2) await delay(300);
    }
  });
}

/** Love / romance fortune — heartbeat pattern */
export function loveHeartbeat() {
  safe(async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
    await delay(100);
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
  });
}

/** Investment fortune — coin drop pattern */
export function investmentCoin() {
  safe(async () => {
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Rigid);
    await delay(80);
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Rigid);
    await delay(80);
    await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Rigid);
  });
}

/**
 * Fortune result reveal — 운세 결과 카드/풀뷰가 사용자 앞에 "등장"하는 순간.
 *
 * 라우팅:
 *   - love / match-insight / compatibility  → 하트비트
 *   - tarot                                 → 카드 드로우 3-phase
 *   - wealth / investment                   → 동전 drop
 *   - score 있으면                           → scoreReveal(score)
 *   - 기본                                   → confirmAction (Medium)
 *
 * fortuneType 은 자유 문자열이라 매칭 실패 시 soft fallback.
 */
export function resultReveal(fortuneType?: string, score?: number) {
  const type = (fortuneType ?? '').toLowerCase();

  if (
    type.includes('love') ||
    type.includes('match') ||
    type === 'compatibility'
  ) {
    loveHeartbeat();
    return;
  }

  if (type.includes('tarot')) {
    tarotReveal();
    return;
  }

  if (type.includes('wealth') || type.includes('invest')) {
    investmentCoin();
    return;
  }

  if (typeof score === 'number' && Number.isFinite(score)) {
    scoreReveal(score);
    return;
  }

  confirmAction();
}

/** Streak celebration — scales with streak length */
export function streak(days: number) {
  safe(async () => {
    if (days >= 30) {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
      await delay(100);
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
      await delay(100);
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } else if (days >= 7) {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      await delay(100);
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } else if (days >= 3) {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
      await delay(100);
      await Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    } else {
      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }
  });
}
