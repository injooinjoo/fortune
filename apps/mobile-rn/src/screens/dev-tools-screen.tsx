import { useMemo, useState } from 'react';

import { Alert, Pressable, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { confirmAndRunFactoryReset } from '../lib/dev-factory-reset';
import { storyChatCharacters } from '../lib/chat-characters';
import { appEnv } from '../lib/env';
import {
  APP_VERSION,
  RUNTIME_VERSION,
  UPDATE_CHANNEL,
  UPDATE_CREATED_AT_KST,
  UPDATE_ID,
  IS_EMBEDDED_LAUNCH,
  formatBuildBadge,
} from '../lib/build-identity';
import { toggleSelect } from '../lib/haptics';
import {
  getCurrentPushTokenSnapshot,
  presentLocalCharacterDmPushForDev,
  registerPushTokenForSignedInUser,
} from '../lib/push-notifications';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

/**
 * 개발자 도구 — 테스트 계정에만 노출되는 통합 디버그 화면.
 *
 * 정책:
 *   - 진입 자체를 profile-screen 에서 isTestAccount 가드로 차단. 이 화면은
 *     해당 가드를 신뢰하고 별도 권한 체크를 하지 않는다.
 *   - 액션은 OS 권한이 필요할 수 있으므로 실패 시 명확한 한 줄 사유로 Alert.
 *   - 실제 운영 데이터를 건드리는 액션(Factory Reset)은 destructive Alert
 *     를 거치게 만든다. UI 만 바꾸는 액션은 즉시 실행.
 */
export function DevToolsScreen() {
  const { session } = useAppBootstrap();
  const userId = session?.user.id ?? null;

  const [pickerCharacterId, setPickerCharacterId] = useState<string>(
    storyChatCharacters[0]?.id ?? 'luts',
  );
  const [tokenSnapshot, setTokenSnapshot] = useState<string | null>(
    getCurrentPushTokenSnapshot(),
  );
  const [isResolvingToken, setIsResolvingToken] = useState(false);

  const selectedCharacter = useMemo(
    () =>
      storyChatCharacters.find((c) => c.id === pickerCharacterId) ??
      storyChatCharacters[0],
    [pickerCharacterId],
  );

  async function handleFireLocalPush() {
    if (!selectedCharacter) return;
    const supabaseUrl = appEnv.supabaseUrl;
    const imageUrl = supabaseUrl
      ? `${supabaseUrl.replace(/\/$/, '')}/storage/v1/object/public/character-avatars/${selectedCharacter.id}.webp`
      : null;
    const result = await presentLocalCharacterDmPushForDev({
      characterId: selectedCharacter.id,
      characterName: selectedCharacter.name,
      body: '테스트 메시지: 푸시 페이로드 라우팅과 채널이 정상 동작하는지 확인합니다.',
      imageUrl,
    });
    if (!result.ok) {
      Alert.alert('로컬 푸시 발사 실패', result.reason);
      return;
    }
    Alert.alert(
      '로컬 푸시 발사됨',
      '알림센터를 확인해보세요.\n\niOS NSE 의 캐릭터 얼굴 첨부는 원격 푸시(서버 발송)에서만 검증됩니다. 이 도구는 페이로드/라우팅/Android BigPicture 검증용.',
    );
  }

  async function handleResolvePushToken() {
    setIsResolvingToken(true);
    try {
      const result = await registerPushTokenForSignedInUser({
        promptIfNotGranted: true,
      });
      if ('skipped' in result) {
        Alert.alert('토큰 발급 불가', result.reason);
        return;
      }
      setTokenSnapshot(result.token);
    } finally {
      setIsResolvingToken(false);
    }
  }

  function handleFactoryReset() {
    confirmAndRunFactoryReset(userId);
  }

  return (
    <Screen header={<RouteBackHeader fallbackHref="/profile" />}>
      <AppText
        variant="heading2"
        style={{
          textAlign: 'center',
          marginBottom: fortuneTheme.spacing.sm,
        }}
      >
        개발자 도구
      </AppText>

      <AppText
        variant="bodySmall"
        color={fortuneTheme.colors.textSecondary}
        style={{
          textAlign: 'center',
          marginBottom: fortuneTheme.spacing.md,
        }}
      >
        테스트 계정에만 노출됩니다. 실제 사용자 데이터를 다룰 수 있는 도구가 포함되어 있어요.
      </AppText>

      {/* 알림 섹션 */}
      <Card>
        <AppText variant="heading4">🔔 알림</AppText>

        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          로컬 푸시를 즉시 발사해 알림 페이로드와 라우팅을 검증합니다. 캐릭터를 골라 발사 후 잠금화면/알림센터에서 모양을 확인하세요.
        </AppText>

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 6 }}>
          {storyChatCharacters.map((character) => {
            const isSelected = character.id === pickerCharacterId;
            return (
              <Pressable
                key={character.id}
                onPress={() => {
                  toggleSelect();
                  setPickerCharacterId(character.id);
                }}
                style={({ pressed }) => ({
                  borderColor: isSelected
                    ? fortuneTheme.colors.accent
                    : fortuneTheme.colors.border,
                  borderRadius: fortuneTheme.radius.chip,
                  borderWidth: 1,
                  opacity: pressed ? 0.78 : 1,
                  paddingHorizontal: 10,
                  paddingVertical: 6,
                })}
              >
                <AppText
                  variant="labelMedium"
                  color={
                    isSelected
                      ? fortuneTheme.colors.accent
                      : fortuneTheme.colors.textSecondary
                  }
                >
                  {character.name}
                </AppText>
              </Pressable>
            );
          })}
        </View>

        <PrimaryButton onPress={() => void handleFireLocalPush()} tone="secondary">
          로컬 푸시 발사 ({selectedCharacter?.name ?? ''})
        </PrimaryButton>

        <View
          style={{
            borderTopWidth: 1,
            borderTopColor: fortuneTheme.colors.border,
            paddingTop: fortuneTheme.spacing.sm,
            gap: fortuneTheme.spacing.xs,
          }}
        >
          <AppText variant="labelLarge">현재 푸시 토큰</AppText>
          {tokenSnapshot ? (
            <AppText
              variant="caption"
              color={fortuneTheme.colors.textSecondary}
              selectable
              style={{ fontFamily: 'Courier' }}
            >
              {tokenSnapshot}
            </AppText>
          ) : (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
              아직 발급/보관된 토큰이 없습니다. 아래 버튼으로 발급하세요.
            </AppText>
          )}
          <PrimaryButton
            onPress={() => void handleResolvePushToken()}
            tone="secondary"
          >
            {isResolvingToken ? '발급 중…' : tokenSnapshot ? '토큰 새로고침' : '푸시 토큰 발급'}
          </PrimaryButton>
        </View>
      </Card>

      {/* 데이터 섹션 */}
      <Card>
        <AppText variant="heading4">🧹 데이터</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          서버 프로필·로컬 캐시·로그인 세션을 모두 지우고 앱을 재시작합니다. 처음 설치한 상태에서 온보딩을 다시 검증할 수 있어요. 복구 불가.
        </AppText>
        <PrimaryButton onPress={handleFactoryReset} tone="secondary">
          앱 초기화 (Factory Reset)
        </PrimaryButton>
      </Card>

      {/* 빌드 정보 섹션 */}
      <Card>
        <AppText variant="heading4">🪪 빌드 정보</AppText>
        <BuildInfoRow label="버전" value={`v${APP_VERSION}`} />
        <BuildInfoRow
          label="런타임"
          value={RUNTIME_VERSION ?? '—'}
        />
        <BuildInfoRow
          label="빌드 종류"
          value={IS_EMBEDDED_LAUNCH ? 'embedded' : 'OTA'}
        />
        <BuildInfoRow label="배지" value={formatBuildBadge()} />
        <BuildInfoRow
          label="채널"
          value={UPDATE_CHANNEL ?? '—'}
        />
        <BuildInfoRow
          label="Update ID"
          value={UPDATE_ID ?? '—'}
        />
        <BuildInfoRow
          label="OTA 시간(KST)"
          value={UPDATE_CREATED_AT_KST ?? '—'}
        />
        <BuildInfoRow
          label="환경"
          value={appEnv.environment}
        />
        <BuildInfoRow
          label="Supabase"
          value={appEnv.supabaseUrl || '—'}
        />
        <BuildInfoRow
          label="Sentry"
          value={appEnv.isCrashReportingConfigured ? 'on' : 'off'}
        />
        <BuildInfoRow
          label="Mixpanel"
          value={appEnv.isAnalyticsConfigured ? 'on' : 'off'}
        />
      </Card>
    </Screen>
  );
}

function BuildInfoRow({ label, value }: { label: string; value: string }) {
  return (
    <View
      style={{
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'flex-start',
        gap: fortuneTheme.spacing.sm,
      }}
    >
      <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
        {label}
      </AppText>
      <AppText
        variant="bodySmall"
        selectable
        style={{ flex: 1, textAlign: 'right' }}
      >
        {value}
      </AppText>
    </View>
  );
}
