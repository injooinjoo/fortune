import { useMemo, useState } from 'react';
import { Modal, Pressable, View } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

import { AppText } from '../../../components/app-text';
import type { EmbeddedResultPayload } from '../../chat-results/types';
import { fortuneReadingPalette, fortuneTheme, withAlpha } from '../../../lib/theme';
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
          style={{
            backgroundColor: fortuneReadingPalette.background,
            flex: 1,
          }}
        >
          <TodayReadingBackdrop />

          <View
            style={{
              flex: 1,
              gap: fortuneTheme.spacing.lg,
              paddingHorizontal: fortuneTheme.spacing.pageHorizontal,
              paddingTop: fortuneTheme.spacing.lg,
              paddingBottom: fortuneTheme.spacing.md,
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
                <View
                  style={{
                    alignSelf: 'flex-start',
                    backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.08),
                    borderColor: withAlpha(fortuneReadingPalette.textPrimary, 0.15),
                    borderRadius: fortuneTheme.radius.full,
                    borderWidth: 1,
                    paddingHorizontal: 12,
                    paddingVertical: 6,
                  }}
                >
                  <AppText variant="kicker" color={withAlpha(fortuneReadingPalette.textPrimary, 0.68)}>
                    HANEUL DAILY READING
                  </AppText>
                </View>
                <AppText variant="heading2" color={fortuneReadingPalette.textPrimary}>
                  {readingDateLabel}
                </AppText>
                <AppText variant="bodySmall" color={withAlpha(fortuneReadingPalette.textPrimary, 0.62)}>
                  하늘이가 오늘의 기운을 한 장의 빛으로 먼저 펼쳐 보여드릴게요.
                </AppText>
              </View>
              <Pressable
                accessibilityRole="button"
                accessibilityLabel="운세 리딩 건너뛰기"
                onPress={() => setPhase('summary')}
                style={({ pressed }) => [
                  {
                    backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.1),
                    borderColor: withAlpha(fortuneReadingPalette.textPrimary, 0.18),
                    borderRadius: fortuneTheme.radius.full,
                    borderWidth: 1,
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

            <View
              style={{
                alignItems: 'center',
                alignSelf: 'stretch',
                backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.07),
                borderColor: withAlpha(fortuneReadingPalette.textPrimary, 0.13),
                borderRadius: 32,
                borderWidth: 1,
                flexDirection: 'row',
                gap: 12,
                paddingHorizontal: 14,
                paddingVertical: 12,
              }}
            >
              <View
                style={{
                  alignItems: 'center',
                  backgroundColor: withAlpha(fortuneReadingPalette.accent, 0.18),
                  borderRadius: 16,
                  height: 32,
                  justifyContent: 'center',
                  width: 32,
                }}
              >
                <AppText variant="labelLarge" color={fortuneReadingPalette.accent}>
                  ✦
                </AppText>
              </View>
              <AppText variant="bodySmall" color={withAlpha(fortuneReadingPalette.textPrimary, 0.7)} style={{ flex: 1 }}>
                결과 카드는 채팅에 저장되고, 이 화면은 예쁜 오늘의 운세 리딩만 담당해요.
              </AppText>
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

            <View
              style={{
                alignItems: 'center',
                gap: 10,
                paddingBottom: 4,
              }}
            >
              <View style={{ flexDirection: 'row', gap: 5 }}>
                {sentences.map((sentence, index) => (
                  <View
                    key={sentence.id}
                    style={{
                      backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, phase === 'reading' ? 0.24 : 0.4),
                      borderRadius: 3,
                      height: 3,
                      width: index === 0 ? 22 : 12,
                    }}
                  />
                ))}
              </View>
              <AppText
                variant="caption"
                color={withAlpha(fortuneReadingPalette.textPrimary, 0.55)}
                style={{ textAlign: 'center' }}
              >
                {phase === 'reading'
                  ? '화면을 탭하면 다음 문장으로 넘어가요'
                  : '닫으면 하늘이 채팅 안에서 결과를 계속 볼 수 있어요'}
              </AppText>
            </View>
          </View>
        </SafeAreaView>
      ) : null}
    </Modal>
  );
}

function TodayReadingBackdrop() {
  return (
    <View pointerEvents="none" style={{ bottom: 0, left: 0, position: 'absolute', right: 0, top: 0 }}>
      <View
        style={{
          backgroundColor: fortuneReadingPalette.background,
          bottom: 0,
          left: 0,
          position: 'absolute',
          right: 0,
          top: 0,
        }}
      />
      <View
        style={{
          backgroundColor: withAlpha(fortuneReadingPalette.warmth, 0.2),
          borderRadius: 190,
          height: 380,
          position: 'absolute',
          right: -132,
          top: -72,
          width: 380,
        }}
      />
      <View
        style={{
          backgroundColor: withAlpha(fortuneReadingPalette.coolGlow, 0.16),
          borderRadius: 180,
          bottom: 44,
          height: 360,
          left: -148,
          position: 'absolute',
          width: 360,
        }}
      />
      <View
        style={{
          backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.09),
          borderRadius: 150,
          height: 300,
          left: '50%',
          marginLeft: -150,
          position: 'absolute',
          top: '35%',
          width: 300,
        }}
      />
      <View
        style={{
          borderColor: withAlpha(fortuneReadingPalette.textPrimary, 0.1),
          borderRadius: 210,
          borderWidth: 1,
          height: 420,
          left: '50%',
          marginLeft: -210,
          position: 'absolute',
          top: '28%',
          width: 420,
        }}
      />
      <View
        style={{
          borderColor: withAlpha(fortuneReadingPalette.accent, 0.12),
          borderRadius: 260,
          borderWidth: 1,
          height: 520,
          left: '50%',
          marginLeft: -260,
          position: 'absolute',
          top: '20%',
          width: 520,
        }}
      />
      <View
        style={{
          backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.18),
          borderRadius: 2,
          height: 4,
          left: 58,
          position: 'absolute',
          top: 170,
          width: 4,
        }}
      />
      <View
        style={{
          backgroundColor: withAlpha(fortuneReadingPalette.textPrimary, 0.2),
          borderRadius: 2,
          height: 4,
          position: 'absolute',
          right: 80,
          top: 250,
          width: 4,
        }}
      />
      <View
        style={{
          backgroundColor: withAlpha(fortuneReadingPalette.accent, 0.34),
          borderRadius: 2,
          bottom: 180,
          height: 4,
          position: 'absolute',
          right: 38,
          width: 4,
        }}
      />
    </View>
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
