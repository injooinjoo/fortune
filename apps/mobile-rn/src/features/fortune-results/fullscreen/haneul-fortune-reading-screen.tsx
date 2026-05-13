import { useMemo, useState } from 'react';
import { Modal, Pressable, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { AppText } from '../../../components/app-text';
import type { EmbeddedResultPayload } from '../../chat-results/types';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import type { ResultKind } from '../types';
import { FortuneReadingSummaryCard } from './fortune-reading-summary-card';
import { buildReadingSentences } from './reading-sentences';
import { SentenceReadingPlayer } from './sentence-reading-player';

interface HaneulFortuneReadingScreenProps {
  visible: boolean;
  resultKind: ResultKind;
  payload: EmbeddedResultPayload;
  onClose: () => void;
}

export function HaneulFortuneReadingScreen({
  visible,
  resultKind,
  payload,
  onClose,
}: HaneulFortuneReadingScreenProps) {
  const [phase, setPhase] = useState<'reading' | 'summary'>('reading');
  const [replayKey, setReplayKey] = useState(0);
  const sentences = useMemo(
    () => buildReadingSentences(payload, resultKind),
    [payload, resultKind],
  );

  const replay = () => {
    setPhase('reading');
    setReplayKey(current => current + 1);
  };

  const close = () => {
    setPhase('reading');
    onClose();
  };

  return (
    <Modal
      animationType="fade"
      onRequestClose={close}
      presentationStyle="fullScreen"
      visible={visible}
    >
      {visible ? (
        <SafeAreaView
          accessibilityViewIsModal
          style={{
            backgroundColor: fortuneTheme.colors.background,
            flex: 1,
          }}
        >
          <View
            pointerEvents="none"
            style={{
              backgroundColor: withAlpha(fortuneTheme.colors.ctaBackground, 0.12),
              borderRadius: fortuneTheme.radius.full,
              height: 220,
              position: 'absolute',
              right: -80,
              top: 64,
              width: 220,
            }}
          />
          <View
            pointerEvents="none"
            style={{
              backgroundColor: withAlpha(fortuneTheme.colors.accentSecondary, 0.08),
              borderRadius: fortuneTheme.radius.full,
              bottom: 96,
              height: 260,
              left: -120,
              position: 'absolute',
              width: 260,
            }}
          />

          <View
            style={{
              flex: 1,
              gap: fortuneTheme.spacing.lg,
              paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
              paddingVertical: fortuneTheme.spacing.lg,
            }}
          >
            <View
              style={{
                alignItems: 'center',
                flexDirection: 'row',
                justifyContent: 'space-between',
              }}
            >
              <View style={{ gap: fortuneTheme.spacing.xxs }}>
                <AppText variant="kicker" color={fortuneTheme.colors.textTertiary}>
                  HANEUL READING
                </AppText>
                <AppText variant="labelMedium" color={fortuneTheme.colors.textSecondary}>
                  한 문장씩 조용히 보여드릴게요
                </AppText>
              </View>
              <Pressable
                accessibilityRole="button"
                accessibilityLabel="운세 리딩 건너뛰기"
                onPress={() => setPhase('summary')}
                style={({ pressed }) => [
                  {
                    backgroundColor: fortuneTheme.colors.secondaryBackground,
                    borderRadius: fortuneTheme.radius.full,
                    paddingHorizontal: fortuneTheme.spacing.md,
                    paddingVertical: fortuneTheme.spacing.sm,
                  },
                  pressed ? { opacity: 0.84 } : null,
                ]}
              >
                <AppText variant="labelSmall" color={fortuneTheme.colors.secondaryForeground}>
                  건너뛰기
                </AppText>
              </Pressable>
            </View>

            {phase === 'reading' ? (
              <SentenceReadingPlayer
                key={replayKey}
                replayKey={replayKey}
                sentences={sentences}
                onComplete={() => setPhase('summary')}
              />
            ) : (
              <View style={{ flex: 1, justifyContent: 'center' }}>
                <FortuneReadingSummaryCard
                  payload={payload}
                  onClose={close}
                  onReplay={replay}
                />
              </View>
            )}

            <AppText
              variant="caption"
              color={fortuneTheme.colors.textTertiary}
              style={{ textAlign: 'center' }}
            >
              {phase === 'reading'
                ? '화면을 탭하면 다음 문장으로 넘어가요'
                : '닫으면 하늘이 채팅 안에서 결과를 계속 볼 수 있어요'}
            </AppText>
          </View>
        </SafeAreaView>
      ) : null}
    </Modal>
  );
}
