/**
 * LockUnreadCircle — 58×58. 안 읽음 숫자 + Ondo 뱃지.
 * 원본: story-widgets.jsx LockUnreadCircle.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import { CounterText, WIDGET_COLORS, WidgetFrame } from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function LockUnreadCircle() {
  const { unread } = useWidgetData();

  return (
    <WidgetFrame size="lockCircle" tint="rgba(0,0,0,0.35)">
      <View
        style={{
          flex: 1,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <AppText
          color="rgba(255,255,255,0.6)"
          style={{ fontSize: 9, letterSpacing: 1 }}
        >
          안읽음
        </AppText>
        <CounterText
          value={unread.total}
          color="#FFFFFF"
          style={{ fontSize: 24, fontWeight: '800', lineHeight: 24, marginTop: 2 }}
        />
        <AppText
          color={WIDGET_COLORS.violet}
          style={{ fontSize: 8, fontWeight: '700', marginTop: 1 }}
        >
          Ondo
        </AppText>
      </View>
    </WidgetFrame>
  );
}
