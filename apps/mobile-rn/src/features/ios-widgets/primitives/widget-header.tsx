/**
 * WidgetHeader — 위젯 상단 작은 라벨 + 우측 슬롯 (주로 OndoMark).
 */

import type { ReactNode } from 'react';
import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import { WIDGET_COLORS } from './colors';

export interface WidgetHeaderProps {
  label: string;
  right?: ReactNode;
  color?: string;
}

export function WidgetHeader({
  label,
  right,
  color = WIDGET_COLORS.whiteSoft,
}: WidgetHeaderProps) {
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        marginBottom: 8,
      }}
    >
      <AppText
        variant="caption"
        color={color}
        style={{ fontSize: 11, fontWeight: '600', letterSpacing: 0.3 }}
      >
        {label}
      </AppText>
      {right ?? null}
    </View>
  );
}
