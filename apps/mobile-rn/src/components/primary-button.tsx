import { type PropsWithChildren, type ReactNode } from 'react';

import {
  ActivityIndicator,
  Pressable,
  View,
  type PressableProps,
  type StyleProp,
  type ViewStyle,
} from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

/**
 * Ondo Pill — the single canonical CTA shape for the app.
 *
 * Three variants: primary (violet), secondary (surface + border), ghost
 * (transparent text-only). Two sizes: md (44px) for inline / compact
 * contexts, lg (52px) for full-width hero CTAs. `loading` swaps the label
 * for an ActivityIndicator. `tone` is kept as a backward-compatible alias
 * for `variant` so existing call sites (that passed tone="primary" or
 * tone="secondary") keep working.
 */
type Variant = 'primary' | 'secondary' | 'ghost';
type Size = 'md' | 'lg';

interface PrimaryButtonProps
  extends Omit<PressableProps, 'style' | 'children'> {
  /** Explicit variant. Overrides `tone` when both are set. */
  variant?: Variant;
  /** Legacy alias for `variant`. Kept to avoid breaking existing call sites. */
  tone?: 'primary' | 'secondary';
  size?: Size;
  loading?: boolean;
  fullWidth?: boolean;
  leftIcon?: ReactNode;
  style?: StyleProp<ViewStyle>;
}

const HEIGHT: Record<Size, number> = { md: 44, lg: 52 };
const PAD_X: Record<Size, number> = { md: 18, lg: 24 };

export function PrimaryButton({
  children,
  variant,
  tone,
  size = 'lg',
  loading = false,
  fullWidth = false,
  leftIcon,
  disabled,
  onPress,
  style,
  ...rest
}: PropsWithChildren<PrimaryButtonProps>) {
  const resolved: Variant = variant ?? (tone as Variant) ?? 'primary';
  const isInert = disabled || loading;
  const labelColor =
    resolved === 'primary'
      ? fortuneTheme.colors.ctaForeground
      : fortuneTheme.colors.textPrimary;

  return (
    <Pressable
      {...rest}
      accessibilityRole="button"
      disabled={isInert}
      onPress={isInert ? undefined : onPress}
      style={({ pressed }) => [
        {
          height: HEIGHT[size],
          paddingHorizontal: PAD_X[size],
          borderRadius: fortuneTheme.radius.full,
          alignItems: 'center',
          justifyContent: 'center',
          width: fullWidth ? '100%' : undefined,
          opacity: disabled ? 0.45 : pressed ? 0.85 : 1,
          backgroundColor:
            resolved === 'primary'
              ? fortuneTheme.colors.ctaBackground
              : resolved === 'secondary'
                ? fortuneTheme.colors.secondaryBackground
                : 'transparent',
          borderWidth: resolved === 'secondary' ? 1 : 0,
          borderColor:
            resolved === 'secondary'
              ? fortuneTheme.colors.border
              : 'transparent',
        },
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator
          color={
            resolved === 'primary'
              ? fortuneTheme.colors.ctaForeground
              : fortuneTheme.colors.textPrimary
          }
        />
      ) : (
        <View style={{ flexDirection: 'row', alignItems: 'center' }}>
          {leftIcon ? (
            <View style={{ marginRight: fortuneTheme.spacing.sm }}>
              {leftIcon}
            </View>
          ) : null}
          <AppText
            variant={size === 'lg' ? 'labelLarge' : 'labelMedium'}
            color={labelColor}
            style={{ fontWeight: '700', letterSpacing: -0.2 }}
          >
            {children}
          </AppText>
        </View>
      )}
    </Pressable>
  );
}
