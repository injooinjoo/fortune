import {
  Image,
  Pressable,
  type ImageSourcePropType,
  View,
} from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

export type SocialAuthPillProvider =
  | 'apple'
  | 'google'
  | 'kakao'
  | 'naver'
  | 'generic';

const providerImageMeta: Partial<
  Record<
    SocialAuthPillProvider,
    { source: ImageSourcePropType; imageHeight: number; mode: 'full-button' | 'icon' }
  >
> = {
  google: {
    source: require('../../assets/social-auth/google-g-20dp.png'),
    imageHeight: 20,
    mode: 'icon',
  },
  kakao: {
    source: require('../../assets/social-auth/kakao-login-large-wide.png'),
    imageHeight: 45,
    mode: 'full-button',
  },
  naver: {
    source: require('../../assets/social-auth/naver-login-light-white-wide-h56.png'),
    imageHeight: 48,
    mode: 'full-button',
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
  const providerImage = providerImageMeta[provider];

  if (providerImage?.mode === 'full-button') {
    return (
      <Pressable
        accessibilityLabel={label}
        accessibilityRole="button"
        disabled={disabled}
        onPress={disabled || !onPress ? undefined : onPress}
        style={({ pressed }) => ({
          justifyContent: 'center',
          minHeight: 52,
          opacity: disabled ? 0.46 : pressed ? 0.84 : 1,
          width: '100%',
        })}
      >
        <Image
          accessibilityIgnoresInvertColors
          resizeMode="contain"
          source={providerImage.source}
          style={{
            height: providerImage.imageHeight,
            width: '100%',
          }}
        />
      </Pressable>
    );
  }

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
          {providerImage?.mode === 'icon' ? (
            <Image
              accessibilityIgnoresInvertColors
              resizeMode="contain"
              source={providerImage.source}
              style={{
                height: providerImage.imageHeight,
                width: providerImage.imageHeight,
              }}
            />
          ) : provider === 'apple' ? (
            <AppText
              variant="labelSmall"
              color={fortuneTheme.colors.background}
              style={{ fontWeight: '800' }}
            >
              A
            </AppText>
          ) : (
            <View
              style={{
                alignItems: 'center',
                borderRadius: fortuneTheme.radius.full,
                height: 24,
                justifyContent: 'center',
                width: 24,
              }}
            >
              <AppText
                variant="labelSmall"
                color={fortuneTheme.colors.background}
                style={{ fontWeight: '800' }}
              >
                •
              </AppText>
            </View>
          )}
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
