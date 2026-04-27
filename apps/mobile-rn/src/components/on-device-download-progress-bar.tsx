import { useEffect, useState } from 'react';
import { StyleSheet, View } from 'react-native';

import { onDeviceLLMEngine } from '../lib/on-device-llm';
import type { ModelStatus } from '../lib/on-device-llm-status';

const POLL_MS = 500;

/**
 * 온디바이스 모델 다운로드 진행 상황을 상단에 아주 얇은 바(2px)로 표시.
 * status === 'downloading' 일 때만 렌더. 그 외에는 null.
 */
export function OnDeviceDownloadProgressBar() {
  const [status, setStatus] = useState<ModelStatus>(onDeviceLLMEngine.getStatus());
  const [percentage, setPercentage] = useState<number>(() => {
    const p = onDeviceLLMEngine.getDownloadProgress();
    return p?.percentage ?? 0;
  });

  useEffect(() => {
    const unsubscribe = onDeviceLLMEngine.onStatusChange((nextStatus) => {
      setStatus(nextStatus);
    });
    return () => {
      unsubscribe();
    };
  }, []);

  useEffect(() => {
    if (status !== 'downloading') return;

    const id = setInterval(() => {
      const p = onDeviceLLMEngine.getDownloadProgress();
      if (p) setPercentage(p.percentage);
    }, POLL_MS);

    return () => clearInterval(id);
  }, [status]);

  if (status !== 'downloading') return null;

  const clamped = Math.max(0, Math.min(100, percentage));

  return (
    <View pointerEvents="none" style={styles.wrapper}>
      <View style={styles.track}>
        <View style={[styles.fill, { width: `${clamped}%` }]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrapper: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1000,
  },
  track: {
    height: 2,
    backgroundColor: 'rgba(255, 255, 255, 0.06)',
  },
  fill: {
    height: 2,
    backgroundColor: 'rgba(167, 139, 250, 0.9)',
  },
});
