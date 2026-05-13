import { Pressable, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import type { EmbeddedResultPayload } from '../../chat-results/types';
import { fortuneTheme, withAlpha } from '../../../lib/theme';

interface FortuneReadingSummaryCardProps {
  payload: EmbeddedResultPayload;
  onReplay: () => void;
  onClose: () => void;
}

export function FortuneReadingSummaryCard({
  payload,
  onReplay,
  onClose,
}: FortuneReadingSummaryCardProps) {
  const chips = [
    ...(payload.contextTags ?? []),
    ...(payload.luckyItems ?? []),
    ...(payload.highlights ?? []).slice(0, 2),
  ].slice(0, 4);

  return (
    <View
      accessibilityRole="summary"
      style={{
        alignSelf: 'stretch',
        backgroundColor: withAlpha(fortuneTheme.colors.surfaceElevated, 0.94),
        borderColor: fortuneTheme.colors.border,
        borderRadius: fortuneTheme.radius.xxl,
        borderWidth: 1,
        gap: fortuneTheme.spacing.md,
        padding: fortuneTheme.spacing.lg,
      }}
    >
      <View style={{ gap: fortuneTheme.spacing.xs }}>
        <AppText variant="kicker" color={fortuneTheme.colors.textTertiary}>
          READING COMPLETE
        </AppText>
        <AppText variant="heading2">하늘이가 핵심 흐름을 다 읽었어요</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          닫으면 하늘이 채팅 안에서 자세한 이유와 조언을 이어서 확인할 수 있어요.
        </AppText>
      </View>

      {typeof payload.score === 'number' ? (
        <View
          style={{
            alignItems: 'center',
            alignSelf: 'flex-start',
            backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.16),
            borderColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.34),
            borderRadius: fortuneTheme.radius.full,
            borderWidth: 1,
            flexDirection: 'row',
            gap: fortuneTheme.spacing.sm,
            paddingHorizontal: fortuneTheme.spacing.md,
            paddingVertical: fortuneTheme.spacing.sm,
          }}
        >
          <AppText variant="labelLarge">{payload.score}점</AppText>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            오늘의 흐름
          </AppText>
        </View>
      ) : null}

      {chips.length ? (
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {chips.map((chip, index) => (
            <View
              key={`${chip}-${index}`}
              style={{
                backgroundColor: fortuneTheme.colors.accentSubtle,
                borderRadius: fortuneTheme.radius.full,
                paddingHorizontal: fortuneTheme.spacing.md,
                paddingVertical: fortuneTheme.spacing.xs,
              }}
            >
              <AppText variant="caption" color={fortuneTheme.colors.textSubtitle}>
                {chip}
              </AppText>
            </View>
          ))}
        </View>
      ) : null}

      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
          <SummaryButton label="다시 보기" onPress={onReplay} />
          <SummaryButton label="닫기" onPress={onClose} />
        </View>
      </View>
    </View>
  );
}

function SummaryButton({
  label,
  primary,
  onPress,
}: {
  label: string;
  primary?: boolean;
  onPress: () => void;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      onPress={onPress}
      style={({ pressed }) => [
        {
          alignItems: 'center',
          backgroundColor: primary
            ? fortuneTheme.colors.ctaBackground
            : fortuneTheme.colors.secondaryBackground,
          borderRadius: fortuneTheme.radius.full,
          flex: primary ? undefined : 1,
          paddingHorizontal: fortuneTheme.spacing.md,
          paddingVertical: fortuneTheme.spacing.md,
        },
        pressed ? { opacity: 0.88 } : null,
      ]}
    >
      <AppText
        variant="labelLarge"
        color={primary ? fortuneTheme.colors.ctaForeground : fortuneTheme.colors.secondaryForeground}
      >
        {label}
      </AppText>
    </Pressable>
  );
}
