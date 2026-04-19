import { DarkTheme, type Theme } from '@react-navigation/native';
import { createFortuneTheme } from '@fortune/design-tokens';

export const fortuneTheme = createFortuneTheme('dark');

/**
 * Lerp from default dark background to warm pink-dark based on romance score (0-100).
 * The transition is subtle — designed for dark mode.
 */
export function romanceTintBackground(score: number): string {
  const t = Math.max(0, Math.min(1, score / 100));
  // #0B0B10 (cold dark) → #2A1228 (warm pink dark)
  const r = Math.round(11 + t * 31);  // 0B → 2A
  const g = Math.round(11 - t * 5);   // 0B → 06 (green drops slightly)
  const b = Math.round(16 + t * 24);  // 10 → 28
  return `rgb(${r}, ${g}, ${b})`;
}

/**
 * Convert a hex color (`#RRGGBB` or `#RGB`) to `rgba(r,g,b,a)`.
 * Replaces inline tint hacks like `${color}15`, `${color}20` across result screens.
 * Falls back to the input string if it's not a recognizable hex.
 */
export function withAlpha(color: string, opacity: number): string {
  const alpha = Math.max(0, Math.min(1, opacity));
  const trimmed = color.trim();

  if (!trimmed.startsWith('#')) {
    return color;
  }

  const hex = trimmed.slice(1);
  const expanded =
    hex.length === 3
      ? hex
          .split('')
          .map((c) => c + c)
          .join('')
      : hex;

  if (expanded.length !== 6) {
    return color;
  }

  const r = Number.parseInt(expanded.slice(0, 2), 16);
  const g = Number.parseInt(expanded.slice(2, 4), 16);
  const b = Number.parseInt(expanded.slice(4, 6), 16);

  if ([r, g, b].some((value) => Number.isNaN(value))) {
    return color;
  }

  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

export const navigationTheme: Theme = {
  ...DarkTheme,
  dark: true,
  colors: {
    ...DarkTheme.colors,
    primary: fortuneTheme.colors.ctaBackground,
    background: fortuneTheme.colors.background,
    card: fortuneTheme.colors.surface,
    text: fortuneTheme.colors.textPrimary,
    border: fortuneTheme.colors.borderOpaque,
    notification: fortuneTheme.colors.accentTertiary,
  },
};
