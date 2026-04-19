import { Image, Text, View, StyleSheet, type ViewStyle } from 'react-native';

import { fortuneTheme } from '../lib/theme';

interface AvatarProps {
  size?: number;
  uri?: string;
  /**
   * Fallback shown when `uri` is missing. Only the first two characters are
   * rendered, so pass the name or 2-char initials directly (e.g. "러츠", "JB").
   */
  initials?: string;
  /**
   * Optional two-color gradient. Only the second color is used as a flat
   * background until linear-gradient support is needed; accepting a tuple
   * keeps the API ready for `expo-linear-gradient` without a breaking change.
   */
  gradient?: [string, string];
  style?: ViewStyle;
}

export function Avatar({
  size = 44,
  uri,
  initials,
  gradient,
  style,
}: AvatarProps) {
  const background = gradient?.[1] ?? fortuneTheme.colors.surfaceElevated;

  return (
    <View
      style={[
        styles.wrap,
        {
          width: size,
          height: size,
          borderRadius: size / 2,
          backgroundColor: background,
        },
        style,
      ]}
    >
      {uri ? (
        <Image
          source={{ uri }}
          style={{ width: size, height: size, borderRadius: size / 2 }}
        />
      ) : (
        // Raw <Text> so AppText's default `bodyMedium` lineHeight (23) doesn't
        // clip large-font initials. Explicit lineHeight keeps 2-char Korean
        // names centered inside the circle.
        <Text
          style={{
            color: fortuneTheme.colors.textPrimary,
            fontSize: size * 0.38,
            lineHeight: size * 0.48,
            fontWeight: '700',
            textAlign: 'center',
            includeFontPadding: false,
          }}
        >
          {initials?.slice(0, 2) ?? ''}
        </Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    alignItems: 'center',
    justifyContent: 'center',
    overflow: 'hidden',
  },
});
