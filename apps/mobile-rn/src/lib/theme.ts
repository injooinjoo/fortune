import { DarkTheme, type Theme } from '@react-navigation/native';
import { createFortuneTheme } from '@fortune/design-tokens';

export const fortuneTheme = createFortuneTheme('dark');

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
