import { useEffect, useState } from 'react';
import { Pressable, Text, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import {
  openPushNotificationSettings,
  shouldShowPushDeniedBanner,
} from '../lib/push-notifications';

/**
 * 사용자가 OS 시스템 설정에서 알림 거부한 상태에서만 노출.
 * canAskAgain=false 인 케이스 — JIT 소프트-prompt 가 더 이상 못 묻기 때문에
 * 설정으로 직접 보내는 게 유일한 회복 경로.
 *
 * 노출 조건은 비동기 OS 권한 조회라 useEffect 로 mount 시 1회 결정.
 * 사용자가 설정에서 권한 켰다 끄는 토글은 다음 cold-start 에 반영 — 매 frame
 * polling 은 비용 대비 효익 없음.
 */
export function PushDeniedBanner({
  characterName,
}: {
  characterName: string;
}) {
  const [show, setShow] = useState(false);

  useEffect(() => {
    let cancelled = false;
    void shouldShowPushDeniedBanner().then((next) => {
      if (!cancelled) setShow(next);
    });
    return () => {
      cancelled = true;
    };
  }, []);

  if (!show) return null;

  return (
    <Pressable
      onPress={() => {
        openPushNotificationSettings();
      }}
      style={({ pressed }) => ({
        marginHorizontal: fortuneTheme.spacing.md,
        marginTop: fortuneTheme.spacing.xs,
        marginBottom: fortuneTheme.spacing.xs,
        paddingHorizontal: fortuneTheme.spacing.md,
        paddingVertical: fortuneTheme.spacing.sm,
        borderRadius: fortuneTheme.radius.card,
        backgroundColor: fortuneTheme.colors.surfaceElevated,
        borderWidth: 1,
        borderColor: fortuneTheme.colors.borderOpaque,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'space-between',
        gap: fortuneTheme.spacing.sm,
        opacity: pressed ? 0.7 : 1,
      })}
      accessibilityRole="button"
      accessibilityLabel="알림 설정 열기"
    >
      <View style={{ flex: 1 }}>
        <Text
          style={{
            color: fortuneTheme.colors.textPrimary,
            fontSize: 13,
            fontWeight: '600',
          }}
        >
          알림이 꺼져 있어요
        </Text>
        <Text
          style={{
            color: fortuneTheme.colors.textSecondary,
            fontSize: 12,
            marginTop: 2,
          }}
        >
          설정에서 켜면 {characterName}이(가) 먼저 말 걸 수 있어요.
        </Text>
      </View>
      <Text
        style={{
          color: fortuneTheme.colors.textSubtitle,
          fontSize: 12,
          fontWeight: '600',
        }}
      >
        설정 열기
      </Text>
    </Pressable>
  );
}
