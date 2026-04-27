/**
 * HomeScreenA — 운세 위주 레이아웃.
 * Row(DailyFortuneSmall + TarotSmall) → DailyFortuneMedium → UnreadMedium → Dock.
 * 원본: Ondo Widgets.html HomeScreen().
 */

import { View } from 'react-native';

import {
  DailyFortuneMedium,
  DailyFortuneSmall,
  TarotSmall,
} from '../fortune-widgets';
import { UnreadMedium } from '../story-widgets';

import { AppIcon, Dock } from './dock';
import { Wallpaper } from './wallpaper';

export function HomeScreenA() {
  return (
    <Wallpaper variant="aurora">
      <View
        style={{
          position: 'absolute',
          top: 66,
          left: 18,
          right: 18,
          gap: 12,
        }}
      >
        <View style={{ flexDirection: 'row', gap: 12 }}>
          <DailyFortuneSmall />
          <TarotSmall />
        </View>
        <DailyFortuneMedium />
        <UnreadMedium />
      </View>

      <Dock>
        <AppIcon gradient={['#8B7BE8', '#5B4BB8']} glyph="온" />
        <AppIcon gradient={['#FFE8D6', '#E0A76B']} glyph="♪" />
        <AppIcon gradient={['#C9FFDC', '#4ECBA8']} glyph="✉" />
        <AppIcon gradient={['#8FB8FF', '#4B7BDE']} glyph="🗺" />
      </Dock>
    </Wallpaper>
  );
}
