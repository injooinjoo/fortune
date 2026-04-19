import { useState, useEffect } from 'react';
import { Pressable, StyleSheet, Text, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';
import { confirmAction } from '../lib/haptics';

const MBTI_TYPES = [
  'ISTJ',
  'ISFJ',
  'INFJ',
  'INTJ',
  'ISTP',
  'ISFP',
  'INFP',
  'INTP',
  'ESTP',
  'ESFP',
  'ENFP',
  'ENTP',
  'ESTJ',
  'ESFJ',
  'ENFJ',
  'ENTJ',
] as const;

export type MbtiType = (typeof MBTI_TYPES)[number];

interface MBTIPickerProps {
  value?: string;
  onChange?: (v: MbtiType) => void;
}

// Four axes, each with two options. Picking one per axis composes the
// 4-letter MBTI. This replaces the 16-tile grid — axis-based is clearer
// for users who don't remember their exact type and only know a few axes.
type Letter = 'E' | 'I' | 'S' | 'N' | 'T' | 'F' | 'J' | 'P';

interface Axis {
  key: 'EI' | 'SN' | 'TF' | 'JP';
  left: { letter: Extract<Letter, 'E' | 'S' | 'T' | 'J'>; title: string; caption: string };
  right: { letter: Extract<Letter, 'I' | 'N' | 'F' | 'P'>; title: string; caption: string };
}

const AXES: readonly Axis[] = [
  {
    key: 'EI',
    left: { letter: 'E', title: '외향', caption: '사람을 만나며 에너지를 얻어요' },
    right: { letter: 'I', title: '내향', caption: '혼자 있는 시간에 에너지를 얻어요' },
  },
  {
    key: 'SN',
    left: { letter: 'S', title: '감각', caption: '지금 여기, 구체적인 경험을 봐요' },
    right: { letter: 'N', title: '직관', caption: '가능성과 큰 그림을 그려요' },
  },
  {
    key: 'TF',
    left: { letter: 'T', title: '사고', caption: '논리와 분석으로 판단해요' },
    right: { letter: 'F', title: '감정', caption: '공감과 조화를 중요하게 봐요' },
  },
  {
    key: 'JP',
    left: { letter: 'J', title: '판단', caption: '계획적이고 체계적인 걸 선호해요' },
    right: { letter: 'P', title: '인식', caption: '유연하고 즉흥적인 걸 선호해요' },
  },
] as const;

type AxisState = Record<Axis['key'], Letter | null>;

function parseInitial(value: string | undefined): AxisState {
  const pos: AxisState = { EI: null, SN: null, TF: null, JP: null };
  if (!value || value.length !== 4) return pos;
  const upper = value.toUpperCase();
  if (upper[0] === 'E' || upper[0] === 'I') pos.EI = upper[0] as Letter;
  if (upper[1] === 'S' || upper[1] === 'N') pos.SN = upper[1] as Letter;
  if (upper[2] === 'T' || upper[2] === 'F') pos.TF = upper[2] as Letter;
  if (upper[3] === 'J' || upper[3] === 'P') pos.JP = upper[3] as Letter;
  return pos;
}

export function MBTIPicker({ value, onChange }: MBTIPickerProps) {
  const [axes, setAxes] = useState<AxisState>(() => parseInitial(value));

  // Compose + emit once all four axes are selected.
  useEffect(() => {
    if (axes.EI && axes.SN && axes.TF && axes.JP) {
      const combined = `${axes.EI}${axes.SN}${axes.TF}${axes.JP}`;
      if ((MBTI_TYPES as readonly string[]).includes(combined)) {
        onChange?.(combined as MbtiType);
      }
    }
  }, [axes, onChange]);

  const pick = (axis: Axis['key'], letter: Letter) => {
    confirmAction();
    setAxes((s) => ({ ...s, [axis]: letter }));
  };

  return (
    <View style={styles.wrap}>
      {AXES.map((axis) => (
        <View key={axis.key} style={styles.row}>
          <AxisCard
            letter={axis.left.letter}
            title={axis.left.title}
            caption={axis.left.caption}
            selected={axes[axis.key] === axis.left.letter}
            onPress={() => pick(axis.key, axis.left.letter)}
          />
          <AxisCard
            letter={axis.right.letter}
            title={axis.right.title}
            caption={axis.right.caption}
            selected={axes[axis.key] === axis.right.letter}
            onPress={() => pick(axis.key, axis.right.letter)}
          />
        </View>
      ))}
    </View>
  );
}

function AxisCard({
  letter,
  title,
  caption,
  selected,
  onPress,
}: {
  letter: Letter;
  title: string;
  caption: string;
  selected: boolean;
  onPress: () => void;
}) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => [
        styles.card,
        selected && styles.cardSelected,
        pressed && { opacity: 0.88 },
      ]}
    >
      <Text
        style={[
          styles.letter,
          { color: selected ? fortuneTheme.colors.ctaForeground : fortuneTheme.colors.textPrimary },
        ]}
      >
        {letter}
      </Text>
      <AppText
        variant="labelLarge"
        color={
          selected
            ? fortuneTheme.colors.ctaForeground
            : fortuneTheme.colors.textPrimary
        }
        style={{ marginTop: 2 }}
      >
        {title}
      </AppText>
      <AppText
        variant="labelSmall"
        color={
          selected
            ? fortuneTheme.colors.ctaForeground
            : fortuneTheme.colors.textSecondary
        }
        style={{ marginTop: 6, textAlign: 'center', opacity: selected ? 0.9 : 1 }}
      >
        {caption}
      </AppText>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  wrap: { gap: fortuneTheme.spacing.md },
  row: { flexDirection: 'row', gap: fortuneTheme.spacing.sm },
  card: {
    flex: 1,
    minHeight: 110,
    padding: fortuneTheme.spacing.md,
    borderRadius: fortuneTheme.radius.md,
    borderWidth: 1,
    borderColor: fortuneTheme.colors.border,
    backgroundColor: fortuneTheme.colors.surface,
    alignItems: 'center',
    justifyContent: 'center',
  },
  cardSelected: {
    backgroundColor: fortuneTheme.colors.ctaBackground,
    borderColor: fortuneTheme.colors.ctaBackground,
  },
  letter: {
    fontSize: 32,
    lineHeight: 36,
    fontWeight: '800',
    letterSpacing: 1,
    includeFontPadding: false,
  },
});
