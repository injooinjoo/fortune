import { useEffect, useMemo, useState } from 'react';

import { router } from 'expo-router';
import { Switch, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { formatFortuneTypeLabel } from '../lib/chat-shell';
import {
  notificationService,
  type NotificationRegistrationSnapshot,
} from '../lib/notifications/notification-service';
import type { NotificationPreferences } from '../lib/mobile-app-state';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

type NotificationPreferenceKey =
  | 'push'
  | 'dailyFortune'
  | 'tokenAlert'
  | 'characterDm'
  | 'marketing';

type NotificationPreferenceFormState = Pick<
  NotificationPreferences,
  NotificationPreferenceKey | 'dailyFortuneTime'
>;

const preferenceMeta: Record<
  NotificationPreferenceKey,
  { label: string; description: string }
> = {
  push: {
    label: '푸시 알림',
    description: '운세 결과, 딥링크 복귀, 앱 상태 알림의 전체 스위치입니다.',
  },
  dailyFortune: {
    label: '데일리 리마인더',
    description: '매일 정해진 시간에 오늘의 흐름을 확인하라고 알려줍니다.',
  },
  tokenAlert: {
    label: '토큰 알림',
    description: '토큰 부족이나 구독 상태 변화를 먼저 알려줍니다.',
  },
  characterDm: {
    label: '캐릭터 DM',
    description: '캐릭터 대화 복귀와 후속 제안을 푸시로 이어줍니다.',
  },
  marketing: {
    label: '프로모션 안내',
    description: '이벤트, 상품, 리텐션 캠페인 알림입니다.',
  },
};

const reminderTimes = ['07:00', '08:00', '12:00', '18:00', '21:00'] as const;

function formatDateTime(value: string | null) {
  if (!value) {
    return '아직 서버에 동기화되지 않았어요.';
  }

  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return '아직 서버에 동기화되지 않았어요.';
  }

  return parsed.toLocaleString('ko-KR');
}

export function ProfileNotificationsScreen() {
  const { pendingChatFortuneType, session } = useAppBootstrap();
  const { state, saveNotifications, status } = useMobileAppState();
  const [preferences, setPreferences] = useState<NotificationPreferenceFormState>({
    push: false,
    dailyFortune: false,
    tokenAlert: false,
    characterDm: false,
    marketing: false,
    dailyFortuneTime: '07:00',
  });
  const [runtimeSnapshot, setRuntimeSnapshot] =
    useState<NotificationRegistrationSnapshot | null>(null);
  const [statusMessage, setStatusMessage] = useState<string | null>(null);
  const [hydrated, setHydrated] = useState(false);
  const enabledCount = useMemo(
    () =>
      [
        preferences.push,
        preferences.dailyFortune,
        preferences.tokenAlert,
        preferences.characterDm,
        preferences.marketing,
      ].filter(Boolean).length,
    [preferences],
  );

  useEffect(() => {
    if (status !== 'ready' || hydrated) {
      return;
    }

    setPreferences({
      push: state.notifications.push,
      dailyFortune: state.notifications.dailyFortune,
      tokenAlert: state.notifications.tokenAlert,
      characterDm: state.notifications.characterDm,
      marketing: state.notifications.marketing,
      dailyFortuneTime: state.notifications.dailyFortuneTime,
    });
    setHydrated(true);
  }, [hydrated, state.notifications, status]);

  useEffect(() => {
    if (status !== 'ready') {
      return;
    }

    let cancelled = false;

    async function refreshRuntimeSnapshot() {
      const snapshot = await notificationService
        .getRegistrationSnapshot()
        .catch(() => null);

      if (!cancelled) {
        setRuntimeSnapshot(snapshot);
      }
    }

    void refreshRuntimeSnapshot();

    return () => {
      cancelled = true;
    };
  }, [status]);

  async function handleSave() {
    setStatusMessage('알림 설정을 저장하는 중이에요.');
    await saveNotifications(preferences);
    const snapshot = await notificationService
      .getRegistrationSnapshot()
      .catch(() => null);
    setRuntimeSnapshot(snapshot);
    setStatusMessage('알림 설정을 저장했어요.');
  }

  async function handleRequestPermission() {
    const permissionStatus = await notificationService
      .requestPermissions()
      .catch(() => 'denied');
    const snapshot = await notificationService
      .getRegistrationSnapshot()
      .catch(() => null);
    setRuntimeSnapshot(snapshot);
    setStatusMessage(
      permissionStatus === 'granted' || permissionStatus === 'provisional'
        ? '알림 권한이 허용됐어요.'
        : '알림 권한이 아직 허용되지 않았어요.',
    );
  }

  async function handleScheduleTest() {
    await notificationService.scheduleTestNotification({
      fortuneType: pendingChatFortuneType ?? 'daily',
      pathname: '/chat',
    });
    setStatusMessage('2초 뒤 테스트 알림을 예약했어요.');
  }

  return (
    <Screen header={<RouteBackHeader fallbackHref="/profile" />}>
      <AppText variant="displaySmall">알림 설정</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        Flutter에서 쓰던 푸시/리마인더 흐름을 RN에서도 같은 구조로 다룹니다.
      </AppText>

      <Card>
        <AppText variant="heading4">상태</AppText>
        <View style={{ gap: 8 }}>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            활성화된 알림은 {enabledCount}개예요.
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            권한 상태: {runtimeSnapshot?.permissionStatus ?? state.notifications.permissionStatus}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            최근 동기화: {formatDateTime(state.notifications.lastSyncedAt)}
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {pendingChatFortuneType
              ? `대기 중인 운세 신호: ${formatFortuneTypeLabel(pendingChatFortuneType)}`
              : '대기 중인 운세 신호는 없어요.'}
          </AppText>
          {statusMessage ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {statusMessage}
            </AppText>
          ) : null}
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">저장된 기본값</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`푸시 ${state.notifications.push ? '켜짐' : '꺼짐'}`} tone="neutral" />
          <Chip
            label={`리마인더 ${state.notifications.dailyFortune ? '켜짐' : '꺼짐'}`}
            tone="neutral"
          />
          <Chip
            label={`토큰 ${state.notifications.tokenAlert ? '켜짐' : '꺼짐'}`}
            tone="neutral"
          />
          <Chip
            label={`캐릭터 ${state.notifications.characterDm ? '켜짐' : '꺼짐'}`}
            tone="neutral"
          />
          <Chip
            label={`마케팅 ${state.notifications.marketing ? '켜짐' : '꺼짐'}`}
            tone="neutral"
          />
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">알림 기본값</AppText>
        {(Object.keys(preferenceMeta) as NotificationPreferenceKey[]).map((key) => (
          <NotificationRow
            key={key}
            description={preferenceMeta[key].description}
            label={preferenceMeta[key].label}
            value={preferences[key]}
            onValueChange={(next) =>
              setPreferences((current) => ({ ...current, [key]: next }))
            }
          />
        ))}
      </Card>

      <Card>
        <AppText variant="heading4">리마인더 시간</AppText>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {reminderTimes.map((time) => (
            <PrimaryButton
              key={time}
              onPress={() =>
                setPreferences((current) => ({
                  ...current,
                  dailyFortuneTime: time,
                }))
              }
              tone={preferences.dailyFortuneTime === time ? 'primary' : 'secondary'}
            >
              {time}
            </PrimaryButton>
          ))}
        </View>
      </Card>

      <Card>
        <AppText variant="heading4">동작</AppText>
        <PrimaryButton onPress={() => void handleSave()}>저장하기</PrimaryButton>
        <PrimaryButton onPress={() => void handleRequestPermission()} tone="secondary">
          권한 다시 요청
        </PrimaryButton>
        <PrimaryButton onPress={() => void handleScheduleTest()} tone="secondary">
          테스트 알림 보내기
        </PrimaryButton>
        {!session ? (
          <PrimaryButton
            onPress={() =>
              router.push({
                pathname: '/signup',
                params: { returnTo: '/profile/notifications' },
              })
            }
            tone="secondary"
          >
            계정 연결
          </PrimaryButton>
        ) : null}
        <PrimaryButton onPress={() => router.back()} tone="secondary">
          돌아가기
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
        thumbColor={value ? fortuneTheme.colors.ctaBackground : '#FFFFFF'}
        trackColor={{
          false: fortuneTheme.colors.borderOpaque,
          true: fortuneTheme.colors.accentSecondary,
        }}
        value={value}
      />
    </View>
  );
}
