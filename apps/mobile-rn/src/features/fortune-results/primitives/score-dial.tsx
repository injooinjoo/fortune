// ScoreDial: port of result-cards.jsx:65-85. Substituted SVG conic arc with a two-half masked
// rotation trick: outer ring is a bordered circle (track), two overlapping half-circle "masks" clip
// the colored ring to produce a 0-360° fill based on `score * easeOut(progress)`.
// Center shows the animated score number. No react-native-svg used.
import { useEffect, useRef, useState } from 'react';
import { Animated, Text, View } from 'react-native';

import { fortuneTheme } from '../../../lib/theme';

interface ScoreDialProps {
  score: number;
  color: string;
  progress: number;
  size?: number;
}

const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const clamp01 = (v: number) => Math.max(0, Math.min(1, v));

export function ScoreDial({
  score,
  color,
  progress,
  size = 68,
}: ScoreDialProps) {
  const strokeWidth = 5;
  const ringSize = size;
  const innerSize = ringSize - strokeWidth * 2;

  const rotAnim = useRef(new Animated.Value(0)).current;
  const [shown, setShown] = useState(0);

  const eased = easeOut(clamp01(progress));
  const fillRatio = clamp01((score / 100) * eased);

  useEffect(() => {
    Animated.timing(rotAnim, {
      toValue: fillRatio,
      duration: 120,
      useNativeDriver: true,
    }).start();
    setShown(Math.round(score * eased));
  }, [fillRatio, score, eased, rotAnim]);

  // Two-half strategy:
  //   - Right half: rotates 0° to 180° as fill goes 0 → 0.5, then stays at 180°.
  //   - Left half:  stays at 0° until fill > 0.5, then rotates 0° → 180°.
  const rightRot = rotAnim.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: ['0deg', '180deg', '180deg'],
  });
  const leftRot = rotAnim.interpolate({
    inputRange: [0, 0.5, 1],
    outputRange: ['0deg', '0deg', '180deg'],
  });
  // Mask covering the left half reveals itself only when fill > 0.5 so the right-half rotation
  // up to 180° remains clipped to its own semicircle.
  const leftMaskOpacity = rotAnim.interpolate({
    inputRange: [0, 0.5, 0.5001, 1],
    outputRange: [1, 1, 0, 0],
  });

  const halfW = ringSize / 2;
  const trackColor = 'rgba(255,255,255,0.08)';

  return (
    <View
      style={{
        width: size,
        height: size,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      {/* Track ring */}
      <View
        style={{
          position: 'absolute',
          width: ringSize,
          height: ringSize,
          borderRadius: ringSize / 2,
          borderWidth: strokeWidth,
          borderColor: trackColor,
        }}
      />

      {/* Color ring (full), will be clipped by half-masks below. */}
      <View
        style={{
          position: 'absolute',
          width: ringSize,
          height: ringSize,
          borderRadius: ringSize / 2,
          borderWidth: strokeWidth,
          borderColor: color,
        }}
      />

      {/* Right-half mask: a semicircle background-colored block that rotates to reveal the colored arc. */}
      <View
        style={{
          position: 'absolute',
          left: halfW,
          top: 0,
          width: halfW,
          height: ringSize,
          overflow: 'hidden',
        }}
      >
        <Animated.View
          style={{
            width: halfW,
            height: ringSize,
            borderTopRightRadius: ringSize,
            borderBottomRightRadius: ringSize,
            backgroundColor: fortuneTheme.colors.background,
            transform: [
              { translateX: -halfW / 2 },
              { rotate: rightRot },
              { translateX: halfW / 2 },
            ],
            transformOrigin: 'left center',
          }}
        />
      </View>

      {/* Left-half mask: rotates only after fill crosses 0.5. */}
      <Animated.View
        style={{
          position: 'absolute',
          left: 0,
          top: 0,
          width: halfW,
          height: ringSize,
          overflow: 'hidden',
          opacity: leftMaskOpacity,
        }}
      >
        <Animated.View
          style={{
            width: halfW,
            height: ringSize,
            borderTopLeftRadius: ringSize,
            borderBottomLeftRadius: ringSize,
            backgroundColor: fortuneTheme.colors.background,
            transform: [
              { translateX: halfW / 2 },
              { rotate: leftRot },
              { translateX: -halfW / 2 },
            ],
            transformOrigin: 'right center',
          }}
        />
      </Animated.View>

      {/* Center punch-out to hide the inner portion of the colored border ring,
          leaving only the thin stroke visible. */}
      <View
        style={{
          position: 'absolute',
          width: innerSize,
          height: innerSize,
          borderRadius: innerSize / 2,
          backgroundColor: fortuneTheme.colors.background,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <Text
          style={{
            fontSize: size * 0.36,
            lineHeight: size * 0.42,
            fontWeight: '800',
            color: fortuneTheme.colors.textPrimary,
            letterSpacing: -1,
          }}
        >
          {shown}
        </Text>
        <Text
          style={{
            fontSize: 9,
            lineHeight: 11,
            color: fortuneTheme.colors.textTertiary,
            letterSpacing: 1.2,
            marginTop: -2,
          }}
        >
          SCORE
        </Text>
      </View>
    </View>
  );
}
