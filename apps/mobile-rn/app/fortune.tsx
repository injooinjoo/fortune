import { Redirect, useLocalSearchParams, type Href } from 'expo-router';
import { useEffect } from 'react';

import { useFeatureFlag } from '../src/lib/feature-flags';
import { logFlagExposure } from '../src/lib/feature-flag-exposure';

/**
 * PR-C: /fortune 라우트 flag 분기.
 *
 * 동작 (fortune_route_behavior):
 * - 'legacy' (default): 기존 dumb redirect → /chat
 * - 'redirect_to_haneul': 하늘이 채팅 + intent 보존 (fortuneType + source)
 * - 'disabled': 사용자에게 빈 화면 (사실상 not-found)
 *
 * 의존 그래프 다운그레이드 (server-side feature_flags 가 cascade 처리하지만 클라
 * 에서도 한 번 더 방어): fortune_route_behavior=redirect_to_haneul + haneul_fortune_enabled
 * =false → 'legacy' 강제. 잘못된 조합으로 사용자가 빈 하늘이 채팅에 떨어지는
 * 상황 차단.
 *
 * 외부 inbound 영향이 가장 큰 PR — flag 'legacy' 기본 유지하면 사용자 영향 zero.
 */
export default function FortuneRoute() {
  const params = useLocalSearchParams<{ type?: string; source?: string }>();
  const behaviorFlag = useFeatureFlag<string>('fortune_route_behavior');
  const haneulFortuneEnabledFlag = useFeatureFlag<boolean>('haneul_fortune_enabled');

  // 클라 측 cascade 다운그레이드 — server 도 같은 로직 수행하지만 fail-closed 방어.
  const effectiveBehavior =
    behaviorFlag.value === 'redirect_to_haneul' &&
    haneulFortuneEnabledFlag.value === false
      ? 'legacy'
      : behaviorFlag.value ?? 'legacy';

  // exposure logging — route_redirect surface
  useEffect(() => {
    if (behaviorFlag.loading || haneulFortuneEnabledFlag.loading) return;
    void logFlagExposure({
      surface: 'route_redirect',
      flags: {
        haneul_enabled: false, // 라우트 시점에 hanuel_enabled 값 모름 — placeholder
        haneul_fortune_enabled: haneulFortuneEnabledFlag.value,
        direct_chips_enabled: false,
        fortune_route_behavior: effectiveBehavior,
      },
      versions: {
        haneul_enabled: 0,
        haneul_fortune_enabled: haneulFortuneEnabledFlag.configVersion,
        direct_chips_enabled: 0,
        fortune_route_behavior: behaviorFlag.configVersion,
      },
      rampPcts: {
        haneul_enabled: 0,
        haneul_fortune_enabled: haneulFortuneEnabledFlag.rampPct,
        direct_chips_enabled: 0,
        fortune_route_behavior: behaviorFlag.rampPct,
      },
    });
  }, [
    behaviorFlag.loading,
    behaviorFlag.value,
    behaviorFlag.configVersion,
    behaviorFlag.rampPct,
    haneulFortuneEnabledFlag.loading,
    haneulFortuneEnabledFlag.value,
    haneulFortuneEnabledFlag.configVersion,
    haneulFortuneEnabledFlag.rampPct,
    effectiveBehavior,
  ]);

  // flag 로딩 중에도 안전하게 redirect — visibility flag 도 아니라 fail-closed.
  // legacy 가 모든 경우 안전한 default.
  if (behaviorFlag.loading || haneulFortuneEnabledFlag.loading) {
    return <Redirect href="/chat" />;
  }

  if (effectiveBehavior === 'disabled') {
    // 사용자 강제 라우팅 차단. expo-router 의 +not-found 가 자동 catch.
    return <Redirect href={'/+not-found' as Href} />;
  }

  if (effectiveBehavior === 'redirect_to_haneul') {
    // intent 보존 — type / source query 그대로 chat 으로 전달.
    // 이전엔 dumb redirect 라 type 손실됐으나 (audit 결과 실제 producer 미증명),
    // 향후 위젯/푸시가 type 을 보내기 시작하면 자동 보존됨.
    const type = typeof params.type === 'string' ? params.type : '';
    const source =
      typeof params.source === 'string' ? params.source : 'fortune_redirect';

    const queryParts: string[] = ['character=haneul_oracle'];
    if (type.length > 0) queryParts.push(`fortuneType=${encodeURIComponent(type)}`);
    queryParts.push(`source=${encodeURIComponent(source)}`);

    return (
      <Redirect href={`/chat?${queryParts.join('&')}` as Href} />
    );
  }

  // legacy default
  return <Redirect href="/chat" />;
}
