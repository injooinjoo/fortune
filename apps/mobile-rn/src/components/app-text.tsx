import { fortuneTheme } from '../lib/theme';

import { Text, type TextProps, type TextStyle } from 'react-native';

type Variant = keyof typeof fortuneTheme.typography;

interface AppTextProps extends TextProps {
  variant?: Variant;
  color?: string;
}

export function AppText({
  variant = 'bodyMedium',
  color,
  style,
  ...props
}: AppTextProps) {
  const textStyle = fortuneTheme.typography[variant] as TextStyle;

  return (
    <Text
      {...props}
      style={[
        {
          color: color ?? fortuneTheme.colors.textPrimary,
          fontFamily: 'System',
        },
        textStyle,
        style,
      ]}
    />
  );
}
