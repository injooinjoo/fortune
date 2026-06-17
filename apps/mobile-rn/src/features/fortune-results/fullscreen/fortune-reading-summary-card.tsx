import { Pressable, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import type { EmbeddedResultPayload } from '../../chat-results/types';
import { fortuneReadingPalette, fortuneTheme, withAlpha } from '../../../lib/theme';

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
  ].slice(0, 5);
  const score = typeof payload.score === 'number' ? Math.max(0, Math.min(100, payload.score)) : null;

  return (
    <View
      accessibilityRole="summary"
      style={{
        alignSelf: 'stretch',
        backgroundColor: '#000000',
        borderColor: withAlpha(fortuneReadingPalette.textPrimary, 0.16),
        borderRadius: 24,
        borderWidth: 1,
        gap: fortuneTheme.spacing.lg,
        padding: fortuneTheme.spacing.lg,
      }}
    >
      <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
          <AppText variant="heading2" color={fortuneReadingPalette.textPrimary} style={{ textAlign: 'center' }}>
            오늘의 핵심 흐름을 다 읽었어요
          </AppText>
          <AppText
            variant="bodySmall"
            color={withAlpha(fortuneReadingPalette.textPrimary, 0.64)}
            style={{ maxWidth: 300, textAlign: 'center' }}
          >
            닫으면 하늘이 채팅 안에서 자세한 이유와 조언을 이어서 확인할 수 있어요.
          </AppText>
        </View>
      </View>

      {score !== null ? (
        <View
          style={{
            backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.08),
            borderColor: withAlpha(fortuneReadingPalette.textPrimary, 0.14),
            borderRadius: 24,
            borderWidth: 1,
            gap: 10,
            padding: 14,
          }}
        >
          <View style={{ alignItems: 'center', flexDirection: 'row', justifyContent: 'space-between' }}>
            <AppText variant="labelLarge" color={fortuneReadingPalette.textPrimary}>
              오늘의 흐름
            </AppText>
            <AppText variant="heading3" color={fortuneReadingPalette.textPrimary}>
              {score}점
            </AppText>
          </View>
          <View
            style={{
              backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.12),
              borderRadius: 999,
              height: 8,
              overflow: 'hidden',
            }}
          >
            <View
              style={{
                backgroundColor: fortuneReadingPalette.textPrimary,
                borderRadius: 999,
                height: 8,
                width: `${score}%`,
              }}
            />
          </View>
        </View>
      ) : null}

      {chips.length ? (
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: fortuneTheme.spacing.sm }}>
          {chips.map((chip, index) => (
            <View
              key={`${chip}-${index}`}
              style={{
                backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.1),
                borderColor: withAlpha(fortuneReadingPalette.textPrimary, 0.16),
                borderRadius: fortuneTheme.radius.full,
                borderWidth: 1,
                paddingHorizontal: fortuneTheme.spacing.md,
                paddingVertical: fortuneTheme.spacing.xs,
              }}
            >
              <AppText variant="caption" color={withAlpha(fortuneReadingPalette.textPrimary, 0.72)}>
                {chip}
              </AppText>
            </View>
          ))}
        </View>
      ) : null}

      <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
        <SummaryButton label="다시 보기" onPress={onReplay} />
        <SummaryButton label="채팅에서 계속 보기" primary onPress={onClose} />
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
          backgroundColor: primary ? fortuneReadingPalette.textPrimary : withAlpha(fortuneReadingPalette.textPrimary, 0.11),
          borderColor: primary ? fortuneReadingPalette.textPrimary : withAlpha(fortuneReadingPalette.textPrimary, 0.18),
          borderRadius: fortuneTheme.radius.full,
          borderWidth: 1,
          flex: 1,
          paddingHorizontal: fortuneTheme.spacing.md,
          paddingVertical: fortuneTheme.spacing.md,
        },
        pressed ? { opacity: 0.78 } : null,
      ]}
    >
      <AppText
        variant="labelLarge"
        color={primary ? fortuneReadingPalette.textInverse : fortuneReadingPalette.textPrimary}
        style={{ textAlign: 'center' }}
      >
        {label}
      </AppText>
    </Pressable>
  );
}
