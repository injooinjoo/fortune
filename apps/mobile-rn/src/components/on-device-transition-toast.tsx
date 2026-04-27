import { useEffect, useRef, useState } from 'react';
import { Animated, StyleSheet, View } from 'react-native';

import { AppText } from './app-text';
import { fortuneTheme } from '../lib/theme';
import { onDeviceLLMEngine } from '../lib/on-device-llm';
import type { ModelStatus } from '../lib/on-device-llm-status';

const VISIBLE_DURATION_MS = 2200;
const FADE_IN_MS = 260;
const FADE_OUT_MS = 360;

export function OnDeviceTransitionToast() {
  const [visible, setVisible] = useState(false);
  const opacity = useRef(new Animated.Value(0)).current;
  const prevStatusRef = useRef<ModelStatus>(onDeviceLLMEngine.getStatus());
  const hasShownRef = useRef(false);

  useEffect(() => {
    const unsubscribe = onDeviceLLMEngine.onStatusChange((nextStatus) => {
      const prev = prevStatusRef.current;
      prevStatusRef.current = nextStatus;

      if (
        !hasShownRef.current &&
        nextStatus === 'ready' &&
        prev !== 'ready'
      ) {
        hasShownRef.current = true;
        setVisible(true);
      }
    });
    return () => {
      unsubscribe();
    };
  }, []);

  useEffect(() => {
    if (!visible) return;

    Animated.timing(opacity, {
      toValue: 1,
      duration: FADE_IN_MS,
      useNativeDriver: true,
    }).start();

    const hideTimer = setTimeout(() => {
      Animated.timing(opacity, {
        toValue: 0,
        duration: FADE_OUT_MS,
        useNativeDriver: true,
      }).start(() => setVisible(false));
    }, VISIBLE_DURATION_MS);

    return () => clearTimeout(hideTimer);
  }, [visible, opacity]);

  if (!visible) return null;

  return (
    <View pointerEvents="none" style={styles.wrapper}>
      <Animated.View style={[styles.pill, { opacity }]}>
        <AppText variant="labelSmall" color={fortuneTheme.colors.textPrimary}>
          온디바이스 AI로 전환되었어요
        </AppText>
      </Animated.View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    top: 8,
    left: 0,
    right: 0,
    alignItems: 'center',
    zIndex: 999,
  },
  pill: {
    paddingHorizontal: 14,
    paddingVertical: 6,
    borderRadius: 999,
    backgroundColor: 'rgba(0, 0, 0, 0.72)',
    borderWidth: StyleSheet.hairlineWidth,
    borderColor: 'rgba(255, 255, 255, 0.12)',
  },
});
