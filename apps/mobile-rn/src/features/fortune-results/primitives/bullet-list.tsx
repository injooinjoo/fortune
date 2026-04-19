// BulletList: port of result-cards.jsx:41-54 (Bullets). Tone-colored dot + text; items stagger in 100ms apart via `appear`.
import { useEffect, useRef } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

type Tone = 'neutral' | 'good' | 'warn';

interface BulletListProps {
  items: string[];
  tone: Tone;
  appear: number;
}

const textColors: Record<Tone, string> = {
  neutral: fortuneTheme.colors.textPrimary,
  good: '#A9E0C4',
  warn: '#FFB48A',
};

const dotColors: Record<Tone, string> = {
  neutral: fortuneTheme.colors.textSecondary,
  good: '#68B593',
  warn: '#E0A76B',
};

function BulletRow({
  text,
  index,
  appear,
  tone,
}: {
  text: string;
  index: number;
  appear: number;
  tone: Tone;
}) {
  // Per-item stagger: each item reveals 100ms after the previous.
  const delay = index * 100;
  const anim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(anim, {
      toValue: appear,
      duration: 260,
      delay,
      useNativeDriver: true,
    }).start();
  }, [appear, anim, delay]);

  const translateY = anim.interpolate({
    inputRange: [0, 1],
    outputRange: [4, 0],
  });

  return (
    <Animated.View
      style={{
        flexDirection: 'row',
        alignItems: 'flex-start',
        opacity: anim,
        transform: [{ translateY }],
      }}
    >
      <View
        style={{
          marginTop: 7,
          width: 4,
          height: 4,
          borderRadius: 2,
          backgroundColor: dotColors[tone],
          marginRight: 8,
        }}
      />
      <Text
        style={{
          flex: 1,
          fontSize: 13,
          lineHeight: 20,
          color: textColors[tone],
        }}
      >
        {text}
      </Text>
    </Animated.View>
  );
}

export function BulletList({ items, tone, appear }: BulletListProps) {
  return (
    <View style={{ gap: 7 }}>
      {items.map((t, i) => (
        <BulletRow key={i} text={t} index={i} appear={appear} tone={tone} />
      ))}
    </View>
  );
}
