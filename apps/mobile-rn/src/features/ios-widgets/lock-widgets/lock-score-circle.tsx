/**
 * LockScoreCircle — 58×58. 운세 점수 ring.
 * 원본: story-widgets.jsx LockScoreCircle.
 */

import { View } from 'react-native';

import { AppText } from '../../../components/app-text';

import {
  CounterText,
  Ring,
  WidgetFrame,
} from '../primitives';
import { useWidgetData } from '../data/widget-data-live';

export function LockScoreCircle() {
  const { daily } = useWidgetData();
  return (
    <WidgetFrame size="lockCircle" tint="rgba(0,0,0,0.35)">
      <View
        style={{
          flex: 1,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <Ring
          size={52}
          value={daily.score}
          stroke={3.5}
          color="#FFFFFF"
          track="rgba(255,255,255,0.2)"
        >
          <View style={{ alignItems: 'center' }}>
            <CounterText
              value={daily.score}
              color="#FFFFFF"
              style={{ fontSize: 14, fontWeight: '800', letterSpacing: -0.5, lineHeight: 14 }}
            />
            <AppText
              color="rgba(255,255,255,0.7)"
              style={{ fontSize: 7, marginTop: 1, letterSpacing: 0.5 }}
            >
              운세
            </AppText>
          </View>
        </Ring>
      </View>
    </WidgetFrame>
  );
}
