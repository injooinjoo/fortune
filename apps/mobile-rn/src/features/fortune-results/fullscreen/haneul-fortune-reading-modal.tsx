import { useCallback, useEffect, useMemo, useState } from 'react';
import { AccessibilityInfo, Modal, Pressable, SafeAreaView, View } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import type { EmbeddedResultPayload } from '../../chat-results/types';
import { FortuneReadingSummaryCard } from './fortune-reading-summary-card';
import { buildHaneulReadingSentences } from './haneul-reading-sequence';
import { SentenceReadingPlayer } from './sentence-reading-player';

interface HaneulFortuneReadingModalProps {
  visible: boolean;
  payload: EmbeddedResultPayload;
  onClose: () => void;
  onOpenDetail: () => void;
}

export function HaneulFortuneReadingModal({
  visible,
  payload,
  onClose,
  onOpenDetail,
}: HaneulFortuneReadingModalProps) {
  const sentences = useMemo(() => buildHaneulReadingSentences(payload), [payload]);
  const [activeIndex, setActiveIndex] = useState(0);
  const [phase, setPhase] = useState<'reading' | 'summary'>('reading');
  const activeSentence = sentences[activeIndex] ?? sentences[0];

  const reset = useCallback(() => {
    setActiveIndex(0);
    setPhase('reading');
  }, []);

  useEffect(() => {
    if (visible) reset();
  }, [reset, visible]);

  useEffect(() => {
    if (!visible || phase !== 'reading' || !activeSentence) return;
    AccessibilityInfo.announceForAccessibility(
      `${activeSentence.main}${activeSentence.sub ? ` ${activeSentence.sub}` : ''}`,
    );
  }, [activeSentence, phase, visible]);

  const handleClose = useCallback(() => {
    onClose();
  }, [onClose]);

  const handleOpenDetail = useCallback(() => {
    handleClose();
    onOpenDetail();
  }, [handleClose, onOpenDetail]);

  const handleStepDone = useCallback(() => {
    if (activeIndex >= sentences.length - 1) {
      setPhase('summary');
      return;
    }
    setActiveIndex(activeIndex + 1);
  }, [activeIndex, sentences.length]);

  return (
    <Modal
      visible={visible}
      transparent={false}
      animationType="fade"
      presentationStyle="fullScreen"
      onRequestClose={handleClose}
    >
      {visible ? (
      <SafeAreaView style={{ flex: 1, backgroundColor: fortuneTheme.colors.background }}>
        <View style={{ flex: 1, overflow: 'hidden' }}>
          <View
            pointerEvents="none"
            style={{
              position: 'absolute',
              top: -120,
              left: -90,
              width: 260,
              height: 260,
              borderRadius: 130,
              backgroundColor: withAlpha(fortuneTheme.colors.accentTertiary, 0.16),
            }}
          />
          <View
            pointerEvents="none"
            style={{
              position: 'absolute',
              right: -120,
              bottom: -160,
              width: 330,
              height: 330,
              borderRadius: 165,
              backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.1),
            }}
          />
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'space-between',
              paddingHorizontal: 20,
              paddingTop: 10,
              paddingBottom: 8,
            }}
          >
            <AppText variant="labelMedium" color={fortuneTheme.colors.textTertiary}>
              하늘이의 오늘 읽기
            </AppText>
            <Pressable
              accessibilityRole="button"
              accessibilityLabel="하늘이 운세 닫기"
              onPress={handleClose}
              style={({ pressed }) => [
                {
                  borderRadius: fortuneTheme.radius.full,
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  paddingHorizontal: 14,
                  paddingVertical: 9,
                },
                pressed ? { opacity: 0.78 } : null,
              ]}
            >
              <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                닫기
              </AppText>
            </Pressable>
          </View>

          {phase === 'reading' && activeSentence ? (
            <SentenceReadingPlayer
              key={activeSentence.id}
              sentence={activeSentence}
              step={activeIndex}
              total={sentences.length}
              onStepDone={handleStepDone}
            />
          ) : (
            <FortuneReadingSummaryCard
              payload={payload}
              onReplay={reset}
              onOpenDetail={handleOpenDetail}
            />
          )}
        </View>
      </SafeAreaView>
      ) : null}
    </Modal>
  );
}
