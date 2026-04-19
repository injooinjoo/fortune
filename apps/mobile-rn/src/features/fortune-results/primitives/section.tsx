// Section: port of result-cards.jsx:30-40. Titled container with left accent bar; fades + slides in with `appear`.
import { useEffect, useRef, type ReactNode } from 'react';
import { Animated, Text, View } from 'react-native';

interface SectionProps {
  title: string;
  accent: string;
  appear: number;
  children: ReactNode;
}

export function Section({ title, accent, appear, children }: SectionProps) {
  const anim = useRef(new Animated.Value(appear)).current;

  useEffect(() => {
    Animated.timing(anim, {
      toValue: appear,
      duration: 240,
      useNativeDriver: true,
    }).start();
  }, [appear, anim]);

  const translateY = anim.interpolate({
    inputRange: [0, 1],
    outputRange: [8, 0],
  });

  return (
    <Animated.View
      style={{
        marginTop: 14,
        opacity: anim,
        transform: [{ translateY }],
      }}
    >
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          marginBottom: 8,
        }}
      >
        <View
          style={{
            width: 4,
            height: 10,
            borderRadius: 2,
            backgroundColor: accent,
            marginRight: 8,
          }}
        />
        <Text
          style={{
            fontSize: 10,
            lineHeight: 12,
            letterSpacing: 1.6,
            color: '#9198AA',
            fontWeight: '700',
            textTransform: 'uppercase',
          }}
        >
          {title}
        </Text>
      </View>
      {children}
    </Animated.View>
  );
}
