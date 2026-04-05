import { useEffect, useMemo, useState } from "react";

import { router } from "expo-router";
import { Switch, View } from "react-native";

import { AppText } from "../components/app-text";
import { Card } from "../components/card";
import { Chip } from "../components/chip";
import { PrimaryButton } from "../components/primary-button";
import { Screen } from "../components/screen";
import { fortuneTheme } from "../lib/theme";
import { useAppBootstrap } from "../providers/app-bootstrap-provider";
import { useMobileAppState } from "../providers/mobile-app-state-provider";

type NotificationPreferenceKey =
  | "push"
  | "chatReminders"
  | "weeklyDigest"
  | "marketing";

const preferenceMeta: Record<
  NotificationPreferenceKey,
  { label: string; description: string }
> = {
  push: {
    label: "푸시 알림",
    description: "새 메시지, 딥링크 복귀, 구독 상태 알림",
  },
  chatReminders: {
    label: "채팅 리마인더",
    description: "캐릭터 대화가 끊겼을 때 다시 들어오게 돕습니다.",
  },
  weeklyDigest: {
    label: "주간 요약",
    description: "한 주 동안 쌓인 핵심 인사이트를 요약합니다.",
  },
  marketing: {
    label: "프로모션 안내",
    description: "상품과 이벤트 관련 안내를 표시합니다.",
  },
};

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
    await saveNotifications(preferences);
  }

  return (
    <Screen>
      <AppText
        variant="labelMedium"
        color={fortuneTheme.colors.accentSecondary}
      >
        /profile/notifications
      </AppText>
      <AppText variant="displaySmall">알림 설정</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        저장된 알림 기본값을 불러와 편집하고, shared state에 다시 저장합니다.
      </AppText>

      <Card>
        <AppText variant="heading4">상태</AppText>
        <View style={{ flexDirection: "row", flexWrap: "wrap", gap: 8 }}>
          <Chip label={`enabled:${enabledCount}`} tone="accent" />
          <Chip
            label={
              pendingChatFortuneType
                ? `pending:${pendingChatFortuneType}`
                : "pending:none"
            }
            tone={pendingChatFortuneType ? "success" : "neutral"}
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">저장된 기본값</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          푸시 {state.notifications.push ? "켜짐" : "꺼짐"} · 채팅 리마인더{" "}
          {state.notifications.chatReminders ? "켜짐" : "꺼짐"} · 주간 요약{" "}
          {state.notifications.weeklyDigest ? "켜짐" : "꺼짐"} · 마케팅{" "}
          {state.notifications.marketing ? "켜짐" : "꺼짐"}
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">알림 기본값</AppText>
        {(Object.keys(preferenceMeta) as NotificationPreferenceKey[]).map(
          (key) => (
            <NotificationRow
              key={key}
              description={preferenceMeta[key].description}
              label={preferenceMeta[key].label}
              value={preferences[key]}
              onValueChange={(next) =>
                setPreferences((current) => ({ ...current, [key]: next }))
              }
            />
          ),
        )}
      </Card>

      <Card>
        <AppText variant="heading4">미리보기</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {preferences.push
            ? "새 메시지와 딥링크는 표시됩니다."
            : "푸시가 꺼져 있습니다."}
        </AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {preferences.chatReminders
            ? "대화 리마인더가 활성화되었습니다."
            : "대화 리마인더가 비활성화되었습니다."}
        </AppText>
      </Card>

      <Card>
        <AppText variant="heading4">동작</AppText>
        <PrimaryButton onPress={() => void handleSave()}>
          저장하기
        </PrimaryButton>
        {!session ? (
          <PrimaryButton
            onPress={() => router.push("/signup")}
            tone="secondary"
          >
            계정 연결
          </PrimaryButton>
        ) : null}
        <PrimaryButton onPress={() => router.back()} tone="secondary">
          돌아가기
        </PrimaryButton>
        <PrimaryButton onPress={() => router.replace("/chat")} tone="secondary">
          Chat 허브로 이동
        </PrimaryButton>
      </Card>
    </Screen>
  );
}

function NotificationRow({
  description,
  label,
  value,
  onValueChange,
}: {
  description: string;
  label: string;
  value: boolean;
  onValueChange: (next: boolean) => void;
}) {
  return (
    <View
      style={{
        alignItems: "center",
        borderBottomColor: fortuneTheme.colors.border,
        borderBottomWidth: 1,
        flexDirection: "row",
        gap: fortuneTheme.spacing.md,
        justifyContent: "space-between",
        paddingVertical: fortuneTheme.spacing.sm,
      }}
    >
      <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
        <AppText variant="bodyMedium">{label}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {description}
        </AppText>
      </View>
      <Switch
        onValueChange={onValueChange}
        thumbColor={value ? fortuneTheme.colors.ctaBackground : "#FFFFFF"}
        trackColor={{
          false: fortuneTheme.colors.borderOpaque,
          true: fortuneTheme.colors.accentSecondary,
        }}
        value={value}
      />
    </View>
  );
}
