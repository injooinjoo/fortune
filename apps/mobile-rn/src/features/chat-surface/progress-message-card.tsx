import { useEffect, useRef, useState } from 'react';
import { Animated, Easing, View } from 'react-native';

import { AppText } from '../../components/app-text';
import type { ChatShellProgressMessage } from '../../lib/chat-shell';
import { deleteMessages, insertMessages } from '../../lib/message-store';
import { loadCharacterConversation } from '../../lib/story-chat-runtime';
import { supabase } from '../../lib/supabase';
import { fortuneTheme, withAlpha } from '../../lib/theme';

interface Props {
  message: ChatShellProgressMessage;
  characterId: string;
}

/**
 * 30초+ 비동기 운세 작업이 진행 중일 때 채팅 흐름에 표시되는 카드.
 *
 * - 1초 tick으로 경과시간 갱신 (re-render는 메시지가 mount된 동안만)
 * - estimatedSeconds 가 있으면 "약 N초 남음" 표시 (음수 시 "곧 완료" 로 폴백)
 * - phaseSteps 가 있으면 도트 시각화 (●●●○ 패턴)
 * - 펄스 애니메이션은 소형: scale 1 → 1.04 (1.4s) Sine in-out
 *
 * 상태 변경(phase 텍스트 / step 인덱스)은 호출측이 message-store updateMessage 로
 * 인플레이스 갱신 → React 가 자동 re-render. 이 컴포넌트는 stateless 렌더러.
 */
export function ProgressMessageCard({ message, characterId }: Props) {
  const elapsed = useElapsedSeconds(message.startedAt);
  const isErrored = message.error != null && message.error.length > 0;
  const pulse = usePulseAnimation(!isErrored);

  // Self-polling 안전망 — 컴포넌트가 mount 된 동안 5초마다 자기 jobId 의
  // status 를 서버에서 직접 조회. status='done'/'failed' 면 즉시 카드 제거 +
  // server messages hydrate.
  //
  // 이전엔 long-running-jobs.ts 의 trackedJobs Map + Realtime 채널 + provider-
  // level setInterval 에 의존했는데, 그 체인 어느 한 곳이라도 깨지면 (Realtime
  // UPDATE 누락, trackJob 등록 누락, channel attach 실패 등) 무한 stuck 됐다.
  // 컴포넌트가 직접 자기 상태를 책임지면 외부 의존 0 — 가장 robust 한 안전망.
  useSelfReconcile(message.jobId, characterId, message.id);

  const remaining =
    message.estimatedSeconds != null
      ? Math.max(0, message.estimatedSeconds - elapsed)
      : null;

  const stepDots =
    message.phaseSteps && message.phaseSteps.length > 0 ? (
      <StepDots
        total={message.phaseSteps.length}
        currentIndex={message.currentStepIndex ?? 0}
      />
    ) : null;

  const accentColor = isErrored
    ? fortuneTheme.colors.error
    : fortuneTheme.colors.ctaBackground;

  return (
    <View
      style={{
        marginVertical: 6,
        paddingHorizontal: 16,
        paddingVertical: 14,
        borderRadius: fortuneTheme.radius.md,
        backgroundColor: withAlpha(accentColor, 0.06),
        borderWidth: 1,
        borderColor: withAlpha(accentColor, 0.18),
        gap: 10,
      }}
    >
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
        <Animated.View
          style={{
            width: 10,
            height: 10,
            borderRadius: 5,
            backgroundColor: accentColor,
            transform: [{ scale: pulse }],
          }}
        />
        <AppText
          variant="bodyMedium"
          color={fortuneTheme.colors.textPrimary}
          style={{ fontWeight: '600', flex: 1 }}
        >
          {message.phase}
        </AppText>
      </View>

      {stepDots}

      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.textSecondary}
      >
        {isErrored
          ? (message.error ?? '오류가 발생했어요')
          : formatStatusLine(elapsed, remaining)}
      </AppText>
    </View>
  );
}

function StepDots({
  total,
  currentIndex,
}: {
  total: number;
  currentIndex: number;
}) {
  return (
    <View style={{ flexDirection: 'row', gap: 6, alignItems: 'center' }}>
      {Array.from({ length: total }).map((_, idx) => {
        const isDone = idx < currentIndex;
        const isActive = idx === currentIndex;
        return (
          <View
            key={idx}
            style={{
              width: isActive ? 18 : 6,
              height: 6,
              borderRadius: 3,
              backgroundColor: isDone
                ? fortuneTheme.colors.ctaBackground
                : isActive
                  ? fortuneTheme.colors.ctaBackground
                  : withAlpha(fortuneTheme.colors.textSecondary, 0.25),
            }}
          />
        );
      })}
    </View>
  );
}

function formatStatusLine(elapsed: number, remaining: number | null): string {
  const elapsedLabel = `${elapsed}초 경과`;
  if (remaining == null) return elapsedLabel;
  if (remaining <= 0) return `${elapsedLabel} · 곧 완료`;
  return `${elapsedLabel} · 약 ${remaining}초 남음`;
}

function useElapsedSeconds(startedAt: number): number {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    setNow(Date.now());
    const tick = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(tick);
  }, [startedAt]);
  return Math.max(0, Math.floor((now - startedAt) / 1000));
}

function usePulseAnimation(active: boolean): Animated.Value {
  const value = useRef(new Animated.Value(1)).current;
  useEffect(() => {
    if (!active) {
      value.setValue(1);
      return;
    }
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(value, {
          toValue: 1.4,
          duration: 700,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
        Animated.timing(value, {
          toValue: 1,
          duration: 700,
          easing: Easing.inOut(Easing.sin),
          useNativeDriver: true,
        }),
      ]),
    );
    loop.start();
    return () => loop.stop();
  }, [value, active]);
  return value;
}

/**
 * 컴포넌트가 mount 된 동안 5초마다 자기 jobId 의 status 를 두 큐 테이블
 * (long_running_jobs, scheduled_poster_jobs) 에서 직접 조회. status 가
 * 'done'/'failed' 면 즉시 progress 카드를 store 에서 제거하고, 캐릭터의
 * server messages 를 다시 hydrate 해서 push 가 누락된 결과 카드 / 실패
 * 안내문을 화면에 띄운다.
 *
 * jobId 가 없으면(legacy fake-phase) noop. supabase client 미초기화 시도 noop.
 * 같은 jobId 에 대해 finalize 가 두 번 호출되면 두 번째는 message-store 가
 * 멱등 처리 (이미 없는 메시지 delete = noop, 같은 id 중복 insert dedup).
 */
function useSelfReconcile(
  jobId: string | undefined,
  characterId: string,
  messageId: string,
) {
  useEffect(() => {
    if (!jobId) return;
    if (!supabase) return;
    const client = supabase;
    let cancelled = false;

    const tick = async () => {
      try {
        // 두 큐 테이블에서 동일 jobId 검색. UNION 한 번이 아니라 순차 두 번이지만,
        // 한 사용자당 동시 활성 잡 5개라 부담 없음. .select() + array 결과로
        // .maybeSingle() race/edge case 회피 — 첫 row 가 곧 정답이거나 빈 배열.
        const tables = ['long_running_jobs', 'scheduled_poster_jobs'] as const;
        for (const table of tables) {
          if (cancelled) return;
          const { data } = await client
            .from(table)
            .select('status')
            .eq('id', jobId)
            .limit(1);
          if (cancelled) return;
          const status = (data?.[0] as { status?: string } | undefined)?.status;
          if (status === 'done' || status === 'failed') {
            deleteMessages(characterId, [messageId]);
            try {
              const server = await loadCharacterConversation(characterId);
              if (server && server.length > 0 && !cancelled) {
                await insertMessages(characterId, server);
              }
            } catch {}
            return;
          }
        }
      } catch {
        // 네트워크 일시 실패는 다음 tick 으로 재시도.
      }
    };

    // 즉시 한 번 + 3초 간격.
    void tick();
    const interval = setInterval(() => void tick(), 3000);
    return () => {
      cancelled = true;
      clearInterval(interval);
    };
  }, [jobId, characterId, messageId]);
}
