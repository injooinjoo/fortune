import { fortuneTheme } from '../lib/theme';

import { Text, type TextProps, type TextStyle } from 'react-native';

type Variant = keyof typeof fortuneTheme.typography;

interface AppTextProps extends TextProps {
  variant?: Variant;
  color?: string;
}

// Variants that render in ZEN Serif for the oracle / fortune voice. Everything
// else stays on the system sans (Noto Sans KR on Korean locales). See the
// design spec in `packages/design-tokens/src/index.ts` for the rule.
const ORACLE_VARIANTS = new Set<Variant>([
  'oracleTitle',
  'oracleBody',
  'calligraphyTitle',
  'calligraphyBody',
]);

export function AppText({
  variant = 'bodyMedium',
  color,
  style,
  ...props
}: AppTextProps) {
  const textStyle = fortuneTheme.typography[variant] as TextStyle;
  const fontFamily = ORACLE_VARIANTS.has(variant) ? 'ZenSerif' : 'System';

  return (
    <Text
      {...props}
      style={[
        {
          color: color ?? fortuneTheme.colors.textPrimary,
          fontFamily,
        },
        textStyle,
        style,
      ]}
    />
  );
}
