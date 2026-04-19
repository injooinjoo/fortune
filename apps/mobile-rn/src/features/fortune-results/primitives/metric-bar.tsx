// MetricBar: port of result-cards.jsx:88-100 (Bar). Horizontal bar grows 0 → value/max width as `progress` → 1; number counts up with easeOut cubic.
import { useEffect, useRef, useState } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

interface MetricBarProps {
  label: string;
  value: number;
  max: number;
  color: string;
  progress: number;
  suffix?: string;
}

const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);

export function MetricBar({
  label,
  value,
  max,
  color,
  progress,
  suffix = '',
}: MetricBarProps) {
  const widthAnim = useRef(new Animated.Value(0)).current;
  const [shownValue, setShownValue] = useState(0);

  useEffect(() => {
    const eased = easeOut(Math.max(0, Math.min(1, progress)));
    Animated.timing(widthAnim, {
      toValue: eased,
      duration: 60,
      useNativeDriver: false,
    }).start();
    setShownValue(Math.round(value * eased));
  }, [progress, value, widthAnim]);

  const widthPct = widthAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['0%', `${(value / max) * 100}%`],
  });

  return (
    <View style={{ gap: 5 }}>
      <View
        style={{
          flexDirection: 'row',
          justifyContent: 'space-between',
          alignItems: 'baseline',
        }}
      >
        <Text
          style={{
            fontSize: 12,
            lineHeight: 16,
            color: fortuneTheme.colors.textSecondary,
          }}
        >
          {label}
        </Text>
        <Text
          style={{
            fontSize: 12,
            lineHeight: 16,
            fontWeight: '700',
            color: fortuneTheme.colors.textPrimary,
          }}
        >
          {shownValue}
          {suffix}
        </Text>
      </View>
      <View
        style={{
          height: 6,
          borderRadius: 3,
          backgroundColor: 'rgba(255,255,255,0.06)',
          overflow: 'hidden',
        }}
      >
        <Animated.View
          style={{
            height: '100%',
            width: widthPct,
            backgroundColor: color,
          }}
        />
      </View>
    </View>
  );
}
