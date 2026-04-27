import { Pressable, View } from 'react-native';

import type { SajuResult } from '@fortune/saju-engine';

import { AppText } from '../../../components/app-text';
import { useEnterChatWithSaju } from '../../../hooks/use-enter-chat-with-saju';
import { useShareSaju } from '../../../hooks/use-share-saju';
import { fortuneTheme, withAlpha } from '../../../lib/theme';

interface Props {
  saju: SajuResult;
}

/**
 * Dual CTA row above the Manseryeok hero — "사주로 대화" and "공유".
 *
 * Chat CTA is primary (solid CTA background), share is secondary (tinted).
 * Both delegate to hooks so this file stays presentation-only.
 */
export function MySajuActions({ saju }: Props) {
  const enterChat = useEnterChatWithSaju();
  const share = useShareSaju();

  return (
    <View
      style={{
        flexDirection: 'row',
        gap: 12,
        marginBottom: 16,
      }}
    >
      <Pressable
        accessibilityRole="button"
        accessibilityLabel="내 사주로 대화하기"
        onPress={() => enterChat(saju)}
        style={({ pressed }) => ({
          flex: 1,
          paddingVertical: 14,
          paddingHorizontal: 16,
          borderRadius: fortuneTheme.radius.md,
          backgroundColor: fortuneTheme.colors.ctaBackground,
          alignItems: 'center',
          justifyContent: 'center',
          flexDirection: 'row',
          gap: 6,
          opacity: pressed ? 0.8 : 1,
        })}
      >
        <AppText
          variant="labelLarge"
          color={fortuneTheme.colors.ctaForeground}
          style={{ fontWeight: '700' }}
        >
          💬 사주로 대화하기
        </AppText>
      </Pressable>

      <Pressable
        accessibilityRole="button"
        accessibilityLabel="내 사주 공유하기"
        onPress={() => {
          void share(saju);
        }}
        style={({ pressed }) => ({
          paddingVertical: 14,
          paddingHorizontal: 18,
          borderRadius: fortuneTheme.radius.md,
          backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.1),
          borderWidth: 1,
          borderColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.3),
          alignItems: 'center',
          justifyContent: 'center',
          flexDirection: 'row',
          gap: 6,
          opacity: pressed ? 0.8 : 1,
        })}
      >
        <AppText
          variant="labelLarge"
          color={fortuneTheme.colors.ctaBackground}
          style={{ fontWeight: '700' }}
        >
          📤 공유
        </AppText>
      </Pressable>
    </View>
  );
}
