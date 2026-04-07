import { Pressable, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

export type SocialAuthPillProvider =
  | 'apple'
  | 'google'
  | 'kakao'
  | 'naver'
  | 'generic';

const providerBadgeMeta: Record<
  SocialAuthPillProvider,
  { background: string; foreground: string; mark: string }
> = {
  apple: {
    background: fortuneTheme.colors.accentLight,
    foreground: fortuneTheme.colors.textPrimary,
    mark: 'A',
  },
  google: {
    background: fortuneTheme.colors.chipBlue,
    foreground: fortuneTheme.colors.accentSecondary,
    mark: 'G',
  },
  kakao: {
    background: fortuneTheme.colors.chipPeach,
    foreground: fortuneTheme.colors.accentTertiary,
    mark: 'K',
  },
  naver: {
    background: fortuneTheme.colors.chipGreen,
    foreground: fortuneTheme.colors.success,
    mark: 'N',
  },
  generic: {
    background: fortuneTheme.colors.accentLight,
    foreground: fortuneTheme.colors.textPrimary,
    mark: '•',
  },
};

export function SocialAuthPillButton({
  disabled = false,
  label,
  onPress,
  provider = 'generic',
}: {
  disabled?: boolean;
  label: string;
  onPress?: () => void;
  provider?: SocialAuthPillProvider;
}) {
  const badge = providerBadgeMeta[provider];

  return (
    <Pressable
      accessibilityLabel={label}
      accessibilityRole="button"
      disabled={disabled}
      onPress={disabled || !onPress ? undefined : onPress}
      style={({ pressed }) => ({
        backgroundColor: fortuneTheme.colors.textPrimary,
        borderRadius: fortuneTheme.radius.full,
        justifyContent: 'center',
        minHeight: 52,
        opacity: disabled ? 0.46 : pressed ? 0.84 : 1,
        paddingHorizontal: 14,
        width: '100%',
      })}
    >
      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          width: '100%',
        }}
      >
        <View
          style={{
            alignItems: 'center',
            justifyContent: 'center',
            width: 24,
          }}
        >
          <View
            style={{
              alignItems: 'center',
              backgroundColor: badge.background,
              borderRadius: fortuneTheme.radius.full,
              height: 24,
              justifyContent: 'center',
              width: 24,
            }}
          >
            <AppText
              variant="labelSmall"
              color={badge.foreground}
              style={{ fontWeight: '800' }}
            >
              {badge.mark}
            </AppText>
          </View>
        </View>
        <View style={{ flex: 1 }}>
          <AppText
            variant="labelLarge"
            color={fortuneTheme.colors.background}
            style={{ textAlign: 'center' }}
          >
            {label}
          </AppText>
        </View>
        <View style={{ width: 24 }} />
      </View>
    </Pressable>
  );
}
