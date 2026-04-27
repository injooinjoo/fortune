import { useEffect, useRef, useState } from 'react';
import { Animated, Easing, Pressable, View, type ViewStyle } from 'react-native';
import { router } from 'expo-router';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { resultReveal } from '../../lib/haptics';
import { fortuneTheme } from '../../lib/theme';
import type { ChatShellEmbeddedResultMessage } from '../../lib/chat-shell';
import { useMobileAppState } from '../../providers/mobile-app-state-provider';
import {
  BulletList as LegacyBulletList,
  InsetQuote,
  KeywordPills,
  MetricGrid,
  SectionCard,
} from '../fortune-results/primitives';
import { ResultCardFrame } from '../fortune-results/primitives/result-card-frame';
import {
  HeroCalendar,
  HeroCompat,
  HeroHealth,
  HeroLine,
  HeroOrbs,
  HeroPastLife,
  HeroRadar,
  HeroSaju,
  HeroTarot,
} from '../fortune-results/heroes';
import { resolveResultKindFromFortuneType } from '../fortune-results/mapping';
import { RenderFortuneResult } from '../fortune-results/registry';
import type { ResultKind } from '../fortune-results/types';

// Result kinds that have a Phase 3b hero component. Everything else falls
// back to the legacy registry rendering so no result type regresses while
// the remaining 26 kinds are ported in a follow-up sprint.
const HEROED_RESULT_KINDS: Partial<Record<ResultKind, React.ComponentType<any>>> = {
  tarot: HeroTarot,
  'traditional-saju': HeroSaju,
  'daily-calendar': HeroCalendar,
  wealth: HeroLine,
  career: HeroLine,
  'personality-dna': HeroRadar,
  mbti: HeroRadar,
  compatibility: HeroCompat,
  health: HeroHealth,
  love: HeroOrbs,
  'past-life': HeroPastLife,
};

const REVEAL_DURATION_MS = 2400;
const TAP_PROGRESS_THRESHOLD = 0.9;

export function EmbeddedResultCard({
  message,
}: {
  message: ChatShellEmbeddedResultMessage;
}) {
  const { payload } = message;
  const resultKind = resolveResultKindFromFortuneType(message.fortuneType);
  const Hero = resultKind ? HEROED_RESULT_KINDS[resultKind] : undefined;
  const { state: mobileAppState } = useMobileAppState();
  const hapticsEnabled = mobileAppState.settings.chatHapticsEnabled;

  // 결과 카드가 채팅에 "등장"하는 순간 한 번 햅틱 재생 (fortune type 별 맞춤 패턴).
  // message.id 기반 ref 가드로 리렌더 시 재발화 방지.
  const firedRef = useRef<string | null>(null);
  useEffect(() => {
    if (!hapticsEnabled) return;
    if (firedRef.current === message.id) return;
    firedRef.current = message.id;
    resultReveal(message.fortuneType, payload.score);
  }, [hapticsEnabled, message.id, message.fortuneType, payload.score]);

  if (resultKind && Hero) {
    return (
      <AnimatedResultCard
        resultKind={resultKind}
        payload={payload}
        Hero={Hero}
      />
    );
  }

  // Registry path: Ondo* components already render their own ResultCardFrame
  // (border + shimmer + footer). Don't wrap in <Card> or add EntertainmentFootnote
  // here — doing so produces a double frame and duplicated disclaimer.
  if (resultKind) {
    return (
      <Pressable
        onPress={() =>
          router.push({ pathname: '/result/[resultKind]', params: { resultKind } })
        }
        style={({ pressed }) => [
          { width: '100%' },
          pressed ? { opacity: 0.98, transform: [{ scale: 0.995 }] } : null,
        ]}
      >
        <RenderFortuneResult resultKind={resultKind} payload={payload} />
      </Pressable>
    );
  }

  // Fallback-fallback: generic normalized rendering (older flows that don't
  // have a dedicated component yet).
  return (
    <View style={{ width: '100%' }}>
      <Card>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <View
            style={{
              alignItems: 'flex-start',
              flexDirection: 'row',
              justifyContent: 'space-between',
              gap: fortuneTheme.spacing.sm,
            }}
          >
            <View style={{ flex: 1, gap: 4 }}>
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                {payload.eyebrow}
              </AppText>
              <AppText variant="oracleTitle">{payload.title}</AppText>
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {payload.subtitle}
              </AppText>
            </View>
            {typeof payload.score === 'number' ? (
              <View
                style={{
                  alignItems: 'center',
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  borderRadius: fortuneTheme.radius.full,
                  minWidth: 56,
                  paddingHorizontal: 12,
                  paddingVertical: 8,
                }}
              >
                <AppText variant="labelLarge">{payload.score}</AppText>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  score
                </AppText>
              </View>
            ) : null}
          </View>
          <AppText variant="oracleBody" color={fortuneTheme.colors.textSecondary}>
            {payload.summary}
          </AppText>
          {message.fortuneType !== 'celebrity' && payload.contextTags?.length ? (
            <SectionCard title="입력된 맥락">
              <KeywordPills keywords={payload.contextTags} />
            </SectionCard>
          ) : null}
          {payload.metrics?.length ? <MetricGrid items={payload.metrics} /> : null}
          {payload.highlights?.length ? (
            <SectionCard title="핵심 포인트">
              <LegacyBulletList items={payload.highlights} accent="핵심" />
            </SectionCard>
          ) : null}
          {payload.recommendations?.length ? (
            <SectionCard title="추천 액션">
              <LegacyBulletList items={payload.recommendations} accent="추천" />
            </SectionCard>
          ) : null}
          {payload.warnings?.length ? (
            <SectionCard title="주의 포인트">
              <LegacyBulletList items={payload.warnings} accent="주의" />
            </SectionCard>
          ) : null}
          {payload.luckyItems?.length ? (
            <SectionCard title="행운 포인트">
              <KeywordPills keywords={payload.luckyItems} />
            </SectionCard>
          ) : null}
          {payload.specialTip ? <InsetQuote text={payload.specialTip} /> : null}
          <EntertainmentFootnote />
        </View>
      </Card>
    </View>
  );
}

function AnimatedResultCard({
  resultKind,
  payload,
  Hero,
}: {
  resultKind: ResultKind;
  payload: ChatShellEmbeddedResultMessage['payload'];
  Hero: React.ComponentType<{ data: unknown; progress: number }>;
}) {
  // ResultCardFrame + heroes consume a plain numeric `progress`. We drive an
  // Animated.Value internally and mirror it into a React state so downstream
  // phase gates re-render smoothly. Listener detach on unmount.
  const [progress, setProgress] = useState(0);
  const animated = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    const listener = animated.addListener(({ value }) => setProgress(value));
    Animated.timing(animated, {
      toValue: 1,
      duration: REVEAL_DURATION_MS,
      easing: Easing.out(Easing.cubic),
      useNativeDriver: false,
    }).start();
    return () => animated.removeListener(listener);
  }, [animated]);

  const handleTap = () => {
    if (progress < TAP_PROGRESS_THRESHOLD) return;
    router.push({
      pathname: '/result/[resultKind]',
      params: { resultKind },
    });
  };

  const pressedStyle: ViewStyle = { opacity: 0.98, transform: [{ scale: 0.995 }] };

  return (
    <Pressable
      onPress={handleTap}
      style={({ pressed }) => [{ width: '100%' }, pressed ? pressedStyle : null]}
    >
      <ResultCardFrame kind={resultKind} data={payload} progress={progress}>
        <Hero data={payload} progress={progress} />
      </ResultCardFrame>
    </Pressable>
  );
}

function EntertainmentFootnote() {
  return (
    <AppText
      variant="caption"
      color={fortuneTheme.colors.textTertiary}
      style={{ textAlign: 'center', marginTop: 8 }}
    >
      오락 목적의 AI 생성 콘텐츠입니다
    </AppText>
  );
}
