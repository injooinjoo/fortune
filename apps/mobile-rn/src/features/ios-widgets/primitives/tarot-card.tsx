/**
 * TarotCard — 3D Y축 flip 카드. 탭 시 뒤집기.
 * TarotBack / TarotFace 2개 면. backfaceVisibility: 'hidden'으로 교차.
 */

import { useEffect, useRef, useState } from 'react';
import { Animated, Easing, Pressable, View, type ViewStyle } from 'react-native';
import Svg, { Circle, G, Path } from 'react-native-svg';

import { AppText } from '../../../components/app-text';

import { WIDGET_COLORS } from './colors';

export interface TarotCardMeta {
  name: string;
  ko: string;
  arcana?: string;
  position?: string;
}

export interface TarotCardProps {
  width?: number;
  height?: number;
  flipped: boolean;
  onPress?: () => void;
  card: TarotCardMeta;
}

export function TarotCard({
  width = 64,
  height = 96,
  flipped,
  onPress,
  card,
}: TarotCardProps) {
  const rot = useRef(new Animated.Value(flipped ? 180 : 0)).current;
  const [displayFront, setDisplayFront] = useState(flipped);

  useEffect(() => {
    Animated.timing(rot, {
      toValue: flipped ? 180 : 0,
      duration: 700,
      easing: Easing.bezier(0.4, 0.1, 0.2, 1),
      useNativeDriver: true,
    }).start();
    // Toggle which side is "on top" for z-order at midpoint.
    const id = setTimeout(() => setDisplayFront(flipped), 350);
    return () => clearTimeout(id);
  }, [flipped, rot]);

  const frontRotate = rot.interpolate({
    inputRange: [0, 180],
    outputRange: ['180deg', '360deg'],
  });
  const backRotate = rot.interpolate({
    inputRange: [0, 180],
    outputRange: ['0deg', '180deg'],
  });

  const container: ViewStyle = {
    width,
    height,
    position: 'relative',
  };

  const face: ViewStyle = {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backfaceVisibility: 'hidden',
  };

  const Wrapper = onPress ? Pressable : View;

  return (
    <Wrapper onPress={onPress ?? undefined} style={container}>
      <Animated.View
        style={[
          face,
          { transform: [{ perspective: 800 }, { rotateY: backRotate }], zIndex: displayFront ? 0 : 1 },
        ]}
      >
        <TarotBack />
      </Animated.View>
      <Animated.View
        style={[
          face,
          { transform: [{ perspective: 800 }, { rotateY: frontRotate }], zIndex: displayFront ? 1 : 0 },
        ]}
      >
        <TarotFace card={card} />
      </Animated.View>
    </Wrapper>
  );
}

export function TarotBack() {
  return (
    <View
      style={{
        flex: 1,
        borderRadius: 6,
        backgroundColor: '#1A1330',
        borderWidth: 1,
        borderColor: 'rgba(224,167,107,0.35)',
        alignItems: 'center',
        justifyContent: 'center',
        shadowColor: WIDGET_COLORS.violet,
        shadowOpacity: 0.25,
        shadowRadius: 12,
        shadowOffset: { width: 0, height: 4 },
      }}
    >
      <Svg width={40} height={60} viewBox="0 0 40 60" opacity={0.4}>
        <G stroke={WIDGET_COLORS.amber} strokeWidth={0.7} fill="none">
          <Circle cx={20} cy={30} r={14} />
          <Circle cx={20} cy={30} r={9} />
          <Circle cx={20} cy={30} r={4} />
          <Path d="M20 6 L20 54 M6 30 L34 30 M10 16 L30 44 M30 16 L10 44" />
        </G>
        <Circle cx={20} cy={30} r={1.5} fill={WIDGET_COLORS.amber} />
      </Svg>
    </View>
  );
}

export function TarotFace({ card }: { card: TarotCardMeta }) {
  return (
    <View
      style={{
        flex: 1,
        borderRadius: 6,
        backgroundColor: '#E6D3B0',
        borderWidth: 1,
        borderColor: 'rgba(224,167,107,0.5)',
        alignItems: 'center',
        justifyContent: 'space-between',
        paddingHorizontal: 4,
        paddingVertical: 6,
      }}
    >
      <AppText
        color="#2A1810"
        style={{ fontFamily: 'ZenSerif', fontSize: 7, opacity: 0.55 }}
      >
        {card.arcana?.split('·').pop()?.trim() ?? 'XVII'}
      </AppText>
      <View style={{ alignItems: 'center', gap: 3 }}>
        <Svg width={28} height={28} viewBox="0 0 32 32">
          <G fill="#2A1810">
            <Path d="M16 3 L18 13 L27 13 L19.5 18 L22 27 L16 21.5 L10 27 L12.5 18 L5 13 L14 13 Z" />
          </G>
        </Svg>
        <AppText
          color="#2A1810"
          style={{ fontFamily: 'ZenSerif', fontSize: 6, fontStyle: 'italic' }}
        >
          {card.name.toUpperCase()}
        </AppText>
      </View>
      <AppText
        color="#2A1810"
        style={{ fontFamily: 'ZenSerif', fontSize: 7, opacity: 0.55 }}
      >
        {card.ko}
      </AppText>
    </View>
  );
}
