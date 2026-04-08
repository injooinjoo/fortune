import { Ionicons } from '@expo/vector-icons';
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

type ProviderVisual = {
  backgroundColor: string;
  iconHeight?: number;
  iconSource?: ImageSourcePropType;
  iconWidth?: number;
  labelColor: string;
  logoName?: keyof typeof Ionicons.glyphMap;
};

const BUTTON_HEIGHT = 52;
const ICON_SLOT_WIDTH = 24;

const providerVisuals: Record<SocialAuthPillProvider, ProviderVisual> = {
  apple: {
    backgroundColor: '#FFFFFF',
    labelColor: '#111111',
    logoName: 'logo-apple',
  },
  generic: {
    backgroundColor: '#FFFFFF',
    labelColor: '#111111',
  },
  google: {
    backgroundColor: '#FFFFFF',
    iconHeight: 20,
    iconSource: require('../../assets/social-auth/google-g-20dp.png'),
    iconWidth: 20,
    labelColor: '#111111',
  },
  kakao: {
    backgroundColor: '#FEE500',
    iconHeight: 18,
    iconSource: require('../../assets/social-auth/kakao-symbol-32.png'),
    iconWidth: 18,
    labelColor: '#191919',
  },
  naver: {
    backgroundColor: '#03C75A',
    iconHeight: 20,
    iconSource: require('../../assets/social-auth/naver-icon-white-h56.png'),
    iconWidth: 20,
    labelColor: '#FFFFFF',
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
  const visual = providerVisuals[provider] ?? providerVisuals.generic;

  return (
    <Pressable
      accessibilityLabel={label}
      accessibilityRole="button"
      disabled={disabled}
      onPress={disabled || !onPress ? undefined : onPress}
      style={({ pressed }) => ({
        backgroundColor: visual.backgroundColor,
        borderRadius: fortuneTheme.radius.full,
        justifyContent: 'center',
        minHeight: BUTTON_HEIGHT,
        opacity: disabled ? 0.46 : pressed ? 0.84 : 1,
        paddingHorizontal: 16,
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
            width: ICON_SLOT_WIDTH,
          }}
        >
          {visual.iconSource ? (
            <Image
              accessibilityIgnoresInvertColors
              resizeMode="contain"
              source={visual.iconSource}
              style={{
                height: visual.iconHeight,
                width: visual.iconWidth,
              }}
            />
          ) : visual.logoName ? (
            <Ionicons color={visual.labelColor} name={visual.logoName} size={18} />
          ) : (
            <View style={{ height: ICON_SLOT_WIDTH, width: ICON_SLOT_WIDTH }} />
          )}
        </View>
        <View style={{ flex: 1 }}>
          <AppText
            variant="labelLarge"
            color={visual.labelColor}
            style={{
              fontWeight: '700',
              textAlign: 'center',
            }}
          >
            {label}
          </AppText>
        </View>
        <View style={{ width: ICON_SLOT_WIDTH }} />
      </View>
    </Pressable>
  );
}
