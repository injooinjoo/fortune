import { useEffect, useMemo, useState } from "react";

import { Alert, Pressable, Switch, View } from "react-native";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { PrimaryButton } from "../components/primary-button";
import { RouteBackHeader } from "../components/route-back-header";
import { Screen } from "../components/screen";
import { formSubmit, toggleSelect } from "../lib/haptics";
import { registerPushTokenForSignedInUser } from "../lib/push-notifications";
import { fortuneTheme } from "../lib/theme";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

type NotificationPreferenceKey =
  | "push"
  | "chatReminders"
  | "weeklyDigest"
  | "marketing";

const ACTIVE_PURPLE = "#8B7BE8";
const INACTIVE_TRACK = "#39393D";

const ALARM_TIMES = [
  { hour: 6, minute: 0 },
  { hour: 6, minute: 30 },
  { hour: 7, minute: 0 },
  { hour: 7, minute: 30 },
  { hour: 8, minute: 0 },
  { hour: 8, minute: 30 },
  { hour: 9, minute: 0 },
] as const;

function formatAlarmTime(hour: number, minute: number): string {
  return `매일 ${String(hour).padStart(2, "0")}:${String(minute).padStart(2, "0")}`;
}

const preferenceMeta: Record<
  NotificationPreferenceKey,
  { label: string; description: string; defaultOn: boolean }
> = {
  push: {
    label: "일일 인사이트 알림",
    description: "매일 아침 오늘의 인사이트를 알려드려요",
    defaultOn: true,
  },
  chatReminders: {
    label: "캐릭터 메시지",
    description: "캐릭터가 새 메시지를 보냈을 때",
    defaultOn: true,
  },
  weeklyDigest: {
    label: "이벤트 및 프로모션",
    description: "특별 이벤트와 할인 정보를 받습니다",
    defaultOn: false,
  },
  marketing: {
    label: "토큰 알림",
    description: "토큰이 부족할 때 미리 알려드려요",
    defaultOn: false,
  },
};

const preferenceOrder: NotificationPreferenceKey[] = [
  "push",
  "chatReminders",
  "weeklyDigest",
  "marketing",
];

export function ProfileNotificationsScreen() {
  const { pendingChatFortuneType, session } = useAppBootstrap();
  const { state, saveNotifications, status } = useMobileAppState();
  const [preferences, setPreferences] = useState<
    Record<NotificationPreferenceKey, boolean>
  >({
    push: false,
    chatReminders: false,
    weeklyDigest: false,
    marketing: false,
  });
  const [hydrated, setHydrated] = useState(false);
  const [alarmTimeIndex, setAlarmTimeIndex] = useState(2); // default index 2 = 07:00
  const alarmTime = ALARM_TIMES[alarmTimeIndex];
  const enabledCount = useMemo(
    () => Object.values(preferences).filter(Boolean).length,
    [preferences],
  );

  useEffect(() => {
    if (status !== "ready" || hydrated) {
      return;
    }

    setPreferences({
      push: state.notifications.push,
      chatReminders: state.notifications.chatReminders,
      weeklyDigest: state.notifications.weeklyDigest,
      marketing: state.notifications.marketing,
    });
    setHydrated(true);
  }, [
    hydrated,
    state.notifications.chatReminders,
    state.notifications.marketing,
    state.notifications.push,
    state.notifications.weeklyDigest,
    status,
  ]);

  async function handleSave() {
    // W9 완성형: push 토글이 ON 이면 실제 iOS 알림 권한 요청 + 푸시 토큰을
    // Supabase에 등록해야 푸시가 실제로 동작함. 이전 구현은 저장만 했고
    // OS 권한이 OFF 상태면 토큰이 영영 등록되지 않았다.
    if (preferences.push) {
      const result = await registerPushTokenForSignedInUser({
        promptIfNotGranted: true,
      });
      if ('skipped' in result && result.reason === 'permission denied') {
        // 사용자가 iOS 권한 시트에서 거부한 경우: 설정에서 수동으로 켜도록 안내
        // 하고 앱 내 prefs 는 OFF 로 되돌려 UI와 실제 동작을 일치시킨다.
        Alert.alert(
          '알림 권한이 꺼져 있어요',
          '설정 → 온도 → 알림에서 허용하시면 매일 인사이트 알림을 받을 수 있어요.',
        );
        setPreferences((current) => ({ ...current, push: false }));
        await saveNotifications({ ...preferences, push: false });
        return;
      }
    }
    await saveNotifications(preferences);
  }

  return (
    <Screen
      header={<RouteBackHeader fallbackHref="/profile" />}
    >
      {/* Title */}
      <AppText
        variant="heading2"
        style={{ textAlign: "center", marginBottom: fortuneTheme.spacing.sm }}
      >
        알림 설정
      </AppText>

      {/* Toggle rows */}
      <Card style={{ gap: 0 }}>
        {preferenceOrder.map((key, index) => (
          <NotificationRow
            key={key}
            description={preferenceMeta[key].description}
            label={preferenceMeta[key].label}
            value={preferences[key]}
            isLast={index === preferenceOrder.length - 1}
            onValueChange={(next) =>
              setPreferences((current) => ({ ...current, [key]: next }))
            }
          />
        ))}
      </Card>

      {/* Morning alarm time section */}
      <Card>
        <AppText variant="heading4">아침 알림 시간</AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
        >
          일일 인사이트 알림을 받을 시간을 정합니다
        </AppText>
        <Pressable
          onPress={() => {
            toggleSelect();
            setAlarmTimeIndex((prev) => (prev + 1) % ALARM_TIMES.length);
          }}
          style={({ pressed }) => ({
            alignSelf: "flex-start",
            backgroundColor: ACTIVE_PURPLE,
            borderRadius: fortuneTheme.radius.chip,
            paddingHorizontal: 16,
            paddingVertical: 8,
            marginTop: fortuneTheme.spacing.xs,
            opacity: pressed ? 0.82 : 1,
          })}
        >
          <AppText
            variant="labelLarge"
            color={fortuneTheme.colors.ctaForeground}
          >
            {formatAlarmTime(alarmTime.hour, alarmTime.minute)}
          </AppText>
        </Pressable>
      </Card>

      {/* Permission note */}
      <AppText
        variant="caption"
        color={fortuneTheme.colors.textSecondary}
        style={{
          textAlign: "center",
          paddingHorizontal: fortuneTheme.spacing.md,
        }}
      >
        알림 권한이 꺼져 있으면 테스트 알림은 동작하지 않습니다.
      </AppText>

      {/* Test notification CTA */}
      <PrimaryButton
        onPress={() => {
          formSubmit();
          void handleSave();
        }}
      >
        테스트 알림 보내기
      </PrimaryButton>
    </Screen>
  );
}

function NotificationRow({
  description,
  label,
  value,
  isLast,
  onValueChange,
}: {
  description: string;
  label: string;
  value: boolean;
  isLast: boolean;
  onValueChange: (next: boolean) => void;
}) {
  return (
    <View
      style={{
        alignItems: "center",
        borderBottomColor: isLast
          ? "transparent"
          : fortuneTheme.colors.border,
        borderBottomWidth: isLast ? 0 : 1,
        flexDirection: "row",
        justifyContent: "space-between",
        paddingVertical: fortuneTheme.spacing.md,
      }}
    >
      <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
        <AppText variant="bodyMedium">{label}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {description}
        </AppText>
      </View>
      <Switch
        onValueChange={(next) => {
          toggleSelect();
          onValueChange(next);
        }}
        thumbColor="#FFFFFF"
        trackColor={{
          false: INACTIVE_TRACK,
          true: ACTIVE_PURPLE,
        }}
        value={value}
      />
    </View>
  );
}
