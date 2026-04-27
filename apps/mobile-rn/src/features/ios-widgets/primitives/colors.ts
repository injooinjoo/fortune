/**
 * WIDGET_COLORS — Ondo 위젯 벤치마크 팔레트.
 *
 * fortuneTheme.colors와 의미론적으로 겹치는 값도 있지만, iOS 위젯의
 * 벤치마크 충실도를 위해 명시적으로 정의. fortuneTheme에 없는 pink/lavender/
 * wine은 이 파일에서만 참조.
 */

export const WIDGET_COLORS = {
  /** 메인 violet (#8B7BE8 ≈ ctaBackground) */
  violet: '#8B7BE8',
  /** 진한 violet (카드 배경 그라디언트용) */
  violetDeep: '#6B5BC8',
  /** 연한 sky (#8FB8FF ≈ accentSecondary) */
  sky: '#8FB8FF',
  /** amber / 금색 (#E0A76B ≈ accentTertiary) */
  amber: '#E0A76B',
  /** green (mint) (#C9FFDC ≈ chipGreen) */
  green: '#C9FFDC',
  /** pink (토큰 없음) */
  pink: '#FFB8C8',
  /** lavender (토큰 없음) */
  lavender: '#B8B0FF',
  /** peach (#FFE8D6 ≈ chipPeach) */
  peach: '#FFE8D6',
  /** wine (lucky color swatch) */
  wine: '#5C1F2B',
  /** 위젯 기본 배경 (어두운 반투명) */
  surface: 'rgba(22,22,28,0.86)',
  surfaceOpaque: 'rgba(22,22,28,0.9)',
  surfaceDense: 'rgba(22,22,28,0.92)',
  tarotSurface: 'rgba(17,14,28,0.95)',
  starSurface: 'rgba(14,18,35,0.92)',
  /** 밝은 텍스트 (#F5F6FB = textPrimary) */
  textBright: '#F5F6FB',
  /** 반투명 흰색들 (투명도) */
  whiteStrong: 'rgba(245,246,251,0.85)',
  whiteMid: 'rgba(245,246,251,0.75)',
  whiteSoft: 'rgba(245,246,251,0.55)',
  whiteFaint: 'rgba(245,246,251,0.45)',
  whiteDim: 'rgba(245,246,251,0.35)',
  whiteGhost: 'rgba(245,246,251,0.22)',
  /** hairline 보더 */
  border: 'rgba(255,255,255,0.06)',
  borderSoft: 'rgba(255,255,255,0.08)',
  borderFaint: 'rgba(255,255,255,0.10)',
  /** 트랙 (Ring 배경 등) */
  track: 'rgba(255,255,255,0.12)',
  trackSoft: 'rgba(255,255,255,0.08)',
  trackFaint: 'rgba(255,255,255,0.04)',
} as const;

export type WidgetColorKey = keyof typeof WIDGET_COLORS;
