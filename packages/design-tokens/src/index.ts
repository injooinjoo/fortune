export type FortuneColorMode = 'dark' | 'light';

export const fortuneColors = {
  dark: {
    accent: '#F5F6FB',
    accentHover: '#D0D4E0',
    accentLight: 'rgba(255,255,255,0.07)',
    accentSecondary: '#8FB8FF',
    accentTertiary: '#E0A76B',
    background: '#0B0B10',
    backgroundSecondary: '#1A1A1A',
    backgroundTertiary: '#151821',
    surface: '#1A1A1A',
    surfaceSecondary: '#23232B',
    surfaceElevated: '#17171D',
    textPrimary: '#F5F6FB',
    textSecondary: '#9198AA',
    textTertiary: '#9EA3B3',
    textSubtitle: '#D0D4E0',
    border: 'rgba(255,255,255,0.08)',
    borderOpaque: '#2C2C2E',
    divider: '#2C2C2E',
    userBubble: '#2C2C2E',
    ctaBackground: '#8B7BE8',
    ctaForeground: '#F5F6FB',
    secondaryBackground: '#23232B',
    secondaryForeground: '#F5F6FB',
    success: '#34C759',
    warning: '#FFCC00',
    error: '#FF3B30',
    overlay: 'rgba(0,0,0,0.6)',
    chipBlue: '#E7F1FF',
    chipGreen: '#C9FFDC',
    chipPeach: '#FFE8D6',
    chipLavender: '#E8E0FF',
    chipText: '#122031',
    accentPressed: '#D0D4E0',
    accentSubtle: 'rgba(245,246,251,0.14)',
    elemental: {
      wood: '#5FA66B',
      fire: '#E26464',
      earth: '#D4A857',
      metal: '#9FA4B0',
      water: '#4A7AB8',
    },
  },
  light: {
    accent: '#14161A',
    accentHover: '#C8401A',
    accentLight: '#FFF3EE',
    accentSecondary: '#C8401A',
    accentTertiary: '#8A2E12',
    background: '#FAFAFB',
    backgroundSecondary: '#F4F5F7',
    backgroundTertiary: '#ECEEF1',
    surface: '#FFFFFF',
    surfaceSecondary: '#F4F5F7',
    surfaceElevated: '#FFFFFF',
    textPrimary: '#14161A',
    textSecondary: '#454A52',
    textTertiary: '#6E747E',
    textSubtitle: '#2F3339',
    border: '#E6E8EC',
    borderOpaque: '#D3D7DE',
    divider: '#E6E8EC',
    userBubble: '#ECEEF1',
    ctaBackground: '#C8401A',
    ctaForeground: '#FFFFFF',
    secondaryBackground: '#FFFFFF',
    secondaryForeground: '#14161A',
    success: '#248A3D',
    warning: '#A86400',
    error: '#C53131',
    overlay: 'rgba(20,22,26,0.42)',
    chipBlue: '#EAF1FA',
    chipGreen: '#E7F3EB',
    chipPeach: '#FFF0EA',
    chipLavender: '#F0ECFA',
    chipText: '#20252B',
    accentPressed: '#9E3113',
    accentSubtle: 'rgba(200,64,26,0.09)',
    elemental: {
      wood: '#5FA66B',
      fire: '#E26464',
      earth: '#D4A857',
      metal: '#9FA4B0',
      water: '#4A7AB8',
    },
  },
} as const;

export const fortuneSpacing = {
  xxs: 2,
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 40,
  xxxl: 48,
  xxxxl: 64,
  pageHorizontal: 20,
  pageVertical: 16,
  cardPadding: 16,
  cardPaddingLarge: 24,
  stackGap: 16,
  inlineGap: 8,
  buttonGap: 12,
} as const;

export const fortuneRadius = {
  xs: 4,
  sm: 6,
  md: 12,
  lg: 16,
  xl: 24,
  xxl: 28,
  full: 9999,
  card: 16,
  modal: 28,
  chip: 9999,
  messageBubble: 18,
  inputArea: 24,
} as const;

export const fortuneTypography = {
  displayLarge: { fontSize: 40, lineHeight: 42, fontWeight: '800' },
  displayMedium: { fontSize: 34, lineHeight: 38, fontWeight: '800' },
  displaySmall: { fontSize: 28, lineHeight: 36, fontWeight: '800' },
  heading1: { fontSize: 28, lineHeight: 34, fontWeight: '800' },
  heading2: { fontSize: 22, lineHeight: 27, fontWeight: '800' },
  heading3: { fontSize: 20, lineHeight: 24, fontWeight: '500' },
  heading4: { fontSize: 18, lineHeight: 22, fontWeight: '800' },
  bodyLarge: { fontSize: 16, lineHeight: 25, fontWeight: '400' },
  bodyMedium: { fontSize: 15, lineHeight: 23, fontWeight: '400' },
  bodySmall: { fontSize: 14, lineHeight: 21, fontWeight: '400' },
  labelLarge: { fontSize: 14, lineHeight: 18, fontWeight: '700' },
  labelMedium: { fontSize: 13, lineHeight: 18, fontWeight: '400' },
  labelSmall: { fontSize: 12, lineHeight: 16, fontWeight: '500' },
  caption: { fontSize: 11, lineHeight: 15, fontWeight: '400' },
  // Ondo signature — uppercase kicker label for section accents (10px, 1.8 letter-spacing, 700).
  // Use for result-card kickers, section headers, or small eyebrow labels.
  kicker: { fontSize: 10, lineHeight: 14, fontWeight: '700', letterSpacing: 1.8 },
  // Emoji display scale — use AppText variant for emoji-only nodes instead of
  // inline fontSize. Four tiers cover the common sizes across fortune results:
  // inline chip (20), card avatar (32), hero accent (48), hero display (72).
  emojiInline: { fontSize: 20, lineHeight: 24, fontWeight: '400' },
  emojiCard: { fontSize: 32, lineHeight: 36, fontWeight: '400' },
  emojiHero: { fontSize: 48, lineHeight: 52, fontWeight: '400' },
  emojiDisplay: { fontSize: 72, lineHeight: 76, fontWeight: '400' },
  calligraphyTitle: { fontSize: 24, lineHeight: 36, fontWeight: '700' },
  calligraphyBody: { fontSize: 17, lineHeight: 31, fontWeight: '400' },
  // Oracle voice — ZEN Serif typeface, used ONLY for fortune-telling content
  // (fortune result titles/bodies, character oracle messages). AppText routes
  // these variants to the ZenSerif family; other variants stay on the system
  // sans. Rule of thumb: if it's prose the character says as a seer, it's
  // oracle*. If it's UI chrome, it's NOT oracle.
  oracleTitle: { fontSize: 22, lineHeight: 30, fontWeight: '700' },
  oracleBody: { fontSize: 16, lineHeight: 26, fontWeight: '400' },
} as const;

export const fortuneShadows = {
  card: {
    shadowColor: '#000000',
    shadowOpacity: 0.2,
    shadowRadius: 16,
    shadowOffset: { width: 0, height: 8 },
    elevation: 8,
  },
  raised: {
    shadowColor: '#000000',
    shadowOpacity: 0.32,
    shadowRadius: 32,
    shadowOffset: { width: 0, height: 16 },
    elevation: 10,
  },
} as const;

export function createFortuneTheme(mode: FortuneColorMode = 'dark') {
  return {
    mode,
    colors: fortuneColors[mode],
    spacing: fortuneSpacing,
    radius: fortuneRadius,
    typography: fortuneTypography,
    shadows: fortuneShadows,
  };
}
