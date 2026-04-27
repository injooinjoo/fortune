/**
 * HomeScreenB — 스토리 위주 레이아웃.
 * Row(StoryPreviewSmall + ConstellationSmall) → RecommendationMedium → Row(LoveSmall + DreamSmall) → Dock.
 * 원본: Ondo Widgets.html HomeScreenB().
 */

import { View } from 'react-native';

import {
  ConstellationSmall,
  DreamSmall,
  LoveSmall,
} from '../fortune-widgets';
import {
  RecommendationMedium,
  StoryPreviewSmall,
} from '../story-widgets';

import { AppIcon, Dock } from './dock';
import { Wallpaper } from './wallpaper';

export function HomeScreenB() {
  return (
    <Wallpaper variant="dusk">
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
          <StoryPreviewSmall />
          <ConstellationSmall />
        </View>
        <RecommendationMedium />
        <View style={{ flexDirection: 'row', gap: 12 }}>
          <LoveSmall />
          <DreamSmall />
        </View>
      </View>

      <Dock>
        <AppIcon gradient={['#8B7BE8', '#5B4BB8']} glyph="온" />
        <AppIcon gradient={['#B8B0FF', '#6B5BC8']} glyph="🌙" />
        <AppIcon gradient={['#000000', '#000000']} glyph="★" />
        <AppIcon gradient={['#E0A76B', '#8C5A30']} glyph="▲" />
      </Dock>
    </Wallpaper>
  );
}
