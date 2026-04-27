/**
 * CounterText — 숫자 count-up 애니메이션.
 * 마운트 시 0 → value (900ms ease-out). AppText를 감싸서 스타일 유지.
 */

import { useEffect, useState } from 'react';
import type { TextStyle } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme } from '../../../lib/theme';

type Variant = keyof typeof fortuneTheme.typography;

export interface CounterTextProps {
  value: number;
  duration?: number;
  variant?: Variant;
  color?: string;
  style?: TextStyle;
  /** number → string 포맷팅 (e.g., "%d%"). 기본은 숫자 그대로. */
  format?: (n: number) => string;
}

export function CounterText({
  value,
  duration = 900,
  variant,
  color,
  style,
  format,
}: CounterTextProps) {
  const [current, setCurrent] = useState(value);

  useEffect(() => {
    setCurrent(0);
    const start = Date.now();
    const id = setInterval(() => {
      const progress = Math.min(1, (Date.now() - start) / duration);
      const eased = 1 - Math.pow(1 - progress, 3);
      setCurrent(Math.round(value * eased));
      if (progress >= 1) clearInterval(id);
    }, 30);
    const timeout = setTimeout(() => {
      setCurrent(value);
      clearInterval(id);
    }, duration + 80);
    return () => {
      clearInterval(id);
      clearTimeout(timeout);
    };
  }, [value, duration]);

  const text = format ? format(current) : String(current);
  return (
    <AppText variant={variant} color={color} style={style}>
      {text}
    </AppText>
  );
}
