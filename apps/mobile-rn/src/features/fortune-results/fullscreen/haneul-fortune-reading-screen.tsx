import { useMemo, useState } from 'react';
import { Modal, Pressable, View } from 'react-native';
import { SafeAreaView, useSafeAreaInsets } from 'react-native-safe-area-context';

import { AppText } from '../../../components/app-text';
import type { EmbeddedResultPayload } from '../../chat-results/types';
import { fortuneReadingPalette, fortuneTheme } from '../../../lib/theme';
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
  const insets = useSafeAreaInsets();
  const sentences = useMemo(
    () => buildReadingSentences(payload, resultKind),
    [payload, resultKind],
  );

  const readingDateLabel = useMemo(() => {
    return buildReadingHeaderLabel(payload);
  }, [payload]);

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
          edges={['left', 'right']}
          style={{
            backgroundColor: fortuneReadingPalette.background,
            flex: 1,
          }}
        >
          <View
            style={{
              flex: 1,
              paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
              paddingTop: Math.max(insets.top + fortuneTheme.spacing.lg, 88),
              paddingBottom: Math.max(insets.bottom, fortuneTheme.spacing.md),
            }}
          >
            <View
              style={{
                alignItems: 'center',
                flexDirection: 'row',
                justifyContent: 'space-between',
              }}
            >
              <View style={{ flex: 1, gap: fortuneTheme.spacing.xs, paddingRight: 12 }}>
                <AppText variant="heading3" color={fortuneReadingPalette.textPrimary}>
                  {readingDateLabel}
                </AppText>
              </View>
              <Pressable
                accessibilityRole="button"
                accessibilityLabel="운세 리딩 건너뛰기"
                onPress={() => setPhase('summary')}
                style={({ pressed }) => [
                  {
                    borderRadius: fortuneTheme.radius.full,
                    paddingHorizontal: fortuneTheme.spacing.md,
                    paddingVertical: fortuneTheme.spacing.sm,
                  },
                  pressed ? { opacity: 0.72 } : null,
                ]}
              >
                <AppText variant="labelSmall" color={fortuneReadingPalette.textPrimary}>
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

          </View>
        </SafeAreaView>
      ) : null}
    </Modal>
  );
}

function buildReadingHeaderLabel(payload: EmbeddedResultPayload): string {
  const targetDate = readPayloadDate(payload);
  if (targetDate) {
    return `${formatKoreanMonthDay(targetDate)} 운세`;
  }
  return payload.fortuneType === 'daily-calendar'
    ? '하늘이 운세 리딩'
    : payload.title;
}

function readPayloadDate(payload: EmbeddedResultPayload): string | undefined {
  const raw = payload.rawApiResponse;
  const candidates = [raw?.targetDate, raw?.target_date, raw?.date];
  for (const value of candidates) {
    if (typeof value === 'string' && value.trim().length > 0) {
      return value.trim();
    }
  }
  return undefined;
}

function formatKoreanMonthDay(value: string): string {
  const isoMatch = value.match(/^(\d{4})-(\d{1,2})-(\d{1,2})/);
  if (isoMatch) {
    return `${Number(isoMatch[2])}월 ${Number(isoMatch[3])}일`;
  }
  const koreanMatch = value.match(/(\d{1,2})\s*월\s*(\d{1,2})\s*일/);
  if (koreanMatch) {
    return `${Number(koreanMatch[1])}월 ${Number(koreanMatch[2])}일`;
  }
  return value;
}
