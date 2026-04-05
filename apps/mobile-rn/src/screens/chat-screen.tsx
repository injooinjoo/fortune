import { useEffect, useMemo, useState } from 'react';

import { router, useLocalSearchParams } from 'expo-router';
import {
  findFortuneExpert,
  fortuneCharacters,
  type FortuneTypeId,
} from '@fortune/product-contracts';
import { Pressable, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { appEnv } from '../lib/env';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

export function ChatScreen() {
  const params = useLocalSearchParams<{ characterId?: string }>();
  const {
    completeOnboarding,
    consumePendingChatFortuneType,
    gate,
    hasSupabase,
    markAuthComplete,
    markGuestBrowse,
    onboardingProgress,
    pendingChatFortuneType,
    session,
    status,
  } = useAppBootstrap();
  const [activeFortuneType, setActiveFortuneType] = useState<FortuneTypeId | null>(
    null,
  );
  const [selectedCharacterId, setSelectedCharacterId] = useState<string | null>(
    null,
  );

  useEffect(() => {
    if (!pendingChatFortuneType) {
      return;
    }

    setActiveFortuneType(pendingChatFortuneType);
    consumePendingChatFortuneType().catch((error) => {
      captureError(error, { surface: 'chat:consume-pending-fortune' }).catch(
        () => undefined,
      );
    });
  }, [consumePendingChatFortuneType, pendingChatFortuneType]);

  const highlightedExpert = activeFortuneType
    ? findFortuneExpert(activeFortuneType)
    : undefined;
  const selectedCharacter = useMemo(() => {
    const targetId = selectedCharacterId ?? params.characterId;

    return (
      fortuneCharacters.find((character) => character.id === targetId) ??
      highlightedExpert ??
      fortuneCharacters[0]
    );
  }, [highlightedExpert, params.characterId, selectedCharacterId]);

  useEffect(() => {
    if (params.characterId) {
      setSelectedCharacterId(params.characterId);
      return;
    }

    if (highlightedExpert) {
      setSelectedCharacterId(highlightedExpert.id);
      return;
    }

    setSelectedCharacterId((current) => current ?? fortuneCharacters[0]?.id ?? null);
  }, [highlightedExpert?.id, params.characterId]);

  return (
    <Screen>
      <AppText variant="labelMedium" color={fortuneTheme.colors.accentSecondary}>
        /chat
      </AppText>
      <AppText variant="displaySmall">Fortune React Native</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        Flutter의 chat-first 제품면을 RN에서 동일한 계약으로 재구성하는 기반입니다.
      </AppText>

      <Card>
        <AppText variant="heading4">Bootstrap</AppText>
        <Chip label={`status:${status}`} tone="accent" />
        <Chip label={hasSupabase ? 'supabase:on' : 'supabase:off'} />
        <Chip label={session ? 'session:authenticated' : 'session:guest'} tone={session ? 'success' : 'neutral'} />
        <Chip label={`gate:${gate}`} />
        <AppText variant="bodySmall" color={fortuneTheme.colors.textTertiary}>
          env: {appEnv.environment} · scheme: com.beyond.fortune
        </AppText>
      </Card>

      {status === 'loading' ? (
        <Card>
          <AppText variant="heading4">Bootstrap Loading</AppText>
          <AppText variant="bodyMedium">
            세션 복원, 온보딩 상태, 딥링크 의도를 읽는 중입니다.
          </AppText>
        </Card>
      ) : null}

      {status === 'ready' && gate === 'auth-entry' ? (
        <Card>
          <AppText variant="heading4">Auth Entry Gate</AppText>
          <AppText variant="bodyMedium">
            Flutter `/chat` 셸과 동일하게 첫 진입 게스트는 soft gate를 먼저 통과해야 합니다.
          </AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            softGateCompleted=false 이므로 채팅 본문 대신 인증 진입 카드를 우선 노출합니다.
          </AppText>
          <PrimaryButton
            onPress={() => {
              markGuestBrowse().catch((error) => {
                captureError(error, { surface: 'chat:guest-browse' }).catch(
                  () => undefined,
                );
              });
            }}
          >
            게스트로 둘러보기
          </PrimaryButton>
          <PrimaryButton
            onPress={() => {
              markAuthComplete().catch((error) => {
                captureError(error, { surface: 'chat:auth-complete' }).catch(
                  () => undefined,
                );
              });
            }}
            tone="secondary"
          >
            인증 완료 상태로 전환
          </PrimaryButton>
          <PrimaryButton onPress={() => router.push('/signup')} tone="secondary">
            회원가입 표면 보기
          </PrimaryButton>
        </Card>
      ) : null}

      {status === 'ready' && gate === 'profile-flow' ? (
        <Card>
          <AppText variant="heading4">Profile Flow Gate</AppText>
          <AppText variant="bodyMedium">
            인증은 되었지만 출생 정보, 관심사, 첫 진입 handoff가 모두 완료되지 않아 온보딩을 계속해야 합니다.
          </AppText>
          <Chip
            label={`birth:${onboardingProgress.birthCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`interest:${onboardingProgress.interestCompleted ? 'done' : 'todo'}`}
          />
          <Chip
            label={`handoff:${onboardingProgress.firstRunHandoffSeen ? 'done' : 'todo'}`}
          />
          <PrimaryButton
            onPress={() => {
              completeOnboarding().catch((error) => {
                captureError(error, {
                  surface: 'chat:complete-onboarding',
                }).catch(() => undefined);
              });
            }}
          >
            온보딩 완료 처리
          </PrimaryButton>
          <PrimaryButton
            onPress={() => router.push('/onboarding')}
            tone="secondary"
          >
            온보딩 표면 보기
          </PrimaryButton>
        </Card>
      ) : null}

      {status === 'ready' && gate === 'ready' && activeFortuneType ? (
        <Card>
          <AppText variant="heading4">Pending Fortune Launch</AppText>
          <AppText variant="bodyMedium">
            딥링크로 전달된 운세 타입을 채팅 셸에서 보존했고, RN도 동일하게 캐릭터 진입 준비를 마쳤습니다.
          </AppText>
          <Chip label={`fortune:${activeFortuneType}`} tone="accent" />
          {highlightedExpert ? (
            <>
              <AppText variant="labelLarge">{highlightedExpert.name}</AppText>
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
              >
                {highlightedExpert.shortDescription}
              </AppText>
              <PrimaryButton
                onPress={() =>
                  router.push(`/character/${highlightedExpert.id}` as never)
                }
              >
                전문가 프로필 열기
              </PrimaryButton>
            </>
          ) : null}
        </Card>
      ) : null}

      {status === 'ready' && gate === 'ready' ? (
        <>
          <Card>
            <AppText variant="heading4">Chat Ready Shell</AppText>
            <AppText variant="bodyMedium">
              캐릭터 선택과 운세 launch intent를 한 화면에서 확인할 수 있도록 RN ready 상태를 실제 셸에 가깝게 재구성했습니다.
            </AppText>
            <Chip
              label={`selected:${selectedCharacter.id}`}
              tone="accent"
            />
            {activeFortuneType ? (
              <Chip label={`launch:${activeFortuneType}`} tone="success" />
            ) : (
              <Chip label="launch:none" />
            )}
          </Card>

          <Card>
            <AppText variant="heading4">Character Roster</AppText>
            <View
              style={{
                gap: fortuneTheme.spacing.sm,
              }}
            >
              {fortuneCharacters.map((character) => {
                const isSelected = selectedCharacter.id === character.id;
                const isRecommended =
                  activeFortuneType != null &&
                  (character.specialties as readonly FortuneTypeId[]).includes(
                    activeFortuneType,
                  );

                return (
                  <Pressable
                    key={character.id}
                    accessibilityRole="button"
                    onPress={() => setSelectedCharacterId(character.id)}
                    style={({ pressed }) => ({
                      opacity: pressed ? 0.85 : 1,
                    })}
                  >
                    <Card
                      style={{
                        backgroundColor: isSelected
                          ? fortuneTheme.colors.backgroundTertiary
                          : fortuneTheme.colors.surfaceSecondary,
                        borderColor: isSelected
                          ? fortuneTheme.colors.accentSecondary
                          : fortuneTheme.colors.border,
                      }}
                    >
                      <View
                        style={{
                          alignItems: 'center',
                          flexDirection: 'row',
                          justifyContent: 'space-between',
                        }}
                      >
                        <View style={{ flex: 1, gap: fortuneTheme.spacing.xs }}>
                          <AppText variant="labelLarge">{character.name}</AppText>
                          <AppText
                            variant="bodySmall"
                            color={fortuneTheme.colors.textSecondary}
                          >
                            {character.shortDescription}
                          </AppText>
                        </View>
                        <View
                          style={{
                            alignItems: 'flex-end',
                            gap: fortuneTheme.spacing.xs,
                          }}
                        >
                          <Chip label={character.category} />
                          {isRecommended ? (
                            <Chip label="deep-link 추천" tone="success" />
                          ) : null}
                        </View>
                      </View>
                    </Card>
                  </Pressable>
                );
              })}
            </View>
          </Card>

          <Card>
            <AppText variant="heading4">Selected Character</AppText>
            <AppText variant="displaySmall">{selectedCharacter.name}</AppText>
            <AppText
              variant="bodyMedium"
              color={fortuneTheme.colors.textSecondary}
            >
              {selectedCharacter.shortDescription}
            </AppText>
            <View
              style={{
                flexDirection: 'row',
                flexWrap: 'wrap',
                gap: fortuneTheme.spacing.xs,
              }}
            >
              {selectedCharacter.specialties.map((specialty) => (
                <Chip key={specialty} label={specialty} />
              ))}
            </View>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textTertiary}
            >
              {activeFortuneType &&
              (
                selectedCharacter.specialties as readonly FortuneTypeId[]
              ).includes(activeFortuneType)
                ? `${activeFortuneType} launch intent가 이 캐릭터로 직접 연결됩니다.`
                : '선택한 캐릭터를 기준으로 다음 채팅 패널 구현을 이어갈 수 있습니다.'}
            </AppText>
            <PrimaryButton
              onPress={() =>
                router.push(`/character/${selectedCharacter.id}` as never)
              }
            >
              캐릭터 프로필 보기
            </PrimaryButton>
            <PrimaryButton
              onPress={() =>
                router.push({
                  pathname: '/profile',
                  params: { source: selectedCharacter.id },
                })
              }
              tone="secondary"
            >
              프로필 표면으로 이동
            </PrimaryButton>
          </Card>

          <Card>
            <AppText variant="heading4">Next Surfaces</AppText>
            <PrimaryButton onPress={() => router.push('/premium')}>
              Premium surface
            </PrimaryButton>
            <PrimaryButton
              onPress={() => router.push('/fortune')}
              tone="secondary"
            >
              Fortune catalog surface
            </PrimaryButton>
          </Card>
        </>
      ) : null}
    </Screen>
  );
}
