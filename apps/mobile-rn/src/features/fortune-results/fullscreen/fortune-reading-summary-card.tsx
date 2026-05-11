import { Pressable, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';

interface FortuneReadingSummaryCardProps {
  payload: EmbeddedResultPayload;
  onReplay: () => void;
  onOpenDetail: () => void;
}

export function FortuneReadingSummaryCard({
  payload,
  onReplay,
  onOpenDetail,
}: FortuneReadingSummaryCardProps) {
  const luckyItems = payload.luckyItems?.slice(0, 3) ?? [];
  const highlights = payload.highlights?.slice(0, 2) ?? [];

  return (
    <View style={{ flex: 1, justifyContent: 'center', paddingHorizontal: 22 }}>
      <View
        style={{
          borderWidth: 1,
          borderColor: fortuneTheme.colors.borderOpaque,
          borderRadius: fortuneTheme.radius.xl,
          backgroundColor: withAlpha(fortuneTheme.colors.surface, 0.9),
          padding: 22,
          gap: 18,
        }}
      >
        <View style={{ gap: 8 }}>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            하늘이가 읽어준 오늘의 결론
          </AppText>
          <AppText variant="oracleTitle" style={{ fontSize: 28, lineHeight: 36 }}>
            {payload.title}
          </AppText>
          <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary} style={{ lineHeight: 24 }}>
            {payload.summary}
          </AppText>
        </View>

        {typeof payload.score === 'number' ? (
          <View
            style={{
              alignSelf: 'flex-start',
              borderRadius: fortuneTheme.radius.full,
              backgroundColor: withAlpha(fortuneTheme.colors.accentTertiary, 0.18),
              paddingHorizontal: 14,
              paddingVertical: 9,
            }}
          >
            <AppText variant="labelLarge">오늘의 흐름 {payload.score}점</AppText>
          </View>
        ) : null}

        {highlights.length ? (
          <View style={{ gap: 8 }}>
            {highlights.map((highlight) => (
              <AppText
                key={highlight}
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
                style={{ lineHeight: 22 }}
              >
                • {highlight}
              </AppText>
            ))}
          </View>
        ) : null}

        {luckyItems.length ? (
          <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
            {luckyItems.map((item) => (
              <View
                key={item}
                style={{
                  borderWidth: 1,
                  borderColor: withAlpha(fortuneTheme.colors.accentTertiary, 0.32),
                  borderRadius: fortuneTheme.radius.full,
                  paddingHorizontal: 12,
                  paddingVertical: 7,
                }}
              >
                <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
                  {item}
                </AppText>
              </View>
            ))}
          </View>
        ) : null}

        <View style={{ gap: 10 }}>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="하늘이 운세 다시 보기"
            onPress={onReplay}
            style={({ pressed }) => [
              {
                alignItems: 'center',
                borderRadius: fortuneTheme.radius.full,
                backgroundColor: fortuneTheme.colors.ctaBackground,
                paddingVertical: 15,
              },
              pressed ? { opacity: 0.86 } : null,
            ]}
          >
            <AppText variant="labelLarge" color={fortuneTheme.colors.ctaForeground}>
              다시 천천히 보기
            </AppText>
          </Pressable>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="상세 결과 열기"
            onPress={onOpenDetail}
            style={({ pressed }) => [
              {
                alignItems: 'center',
                borderRadius: fortuneTheme.radius.full,
                borderWidth: 1,
                borderColor: fortuneTheme.colors.borderOpaque,
                paddingVertical: 14,
              },
              pressed ? { opacity: 0.82 } : null,
            ]}
          >
            <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
              전체 결과 보기
            </AppText>
          </Pressable>
        </View>
      </View>
    </View>
  );
}
