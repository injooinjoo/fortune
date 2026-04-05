import { useEffect, useMemo, useState } from 'react';

import { router, useLocalSearchParams } from 'expo-router';
import {
  findFortuneExpert,
  type FortuneCharacterSpec,
  fortuneCharacters,
  type FortuneTypeId,
} from '@fortune/product-contracts';
import { Pressable, TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import { Screen } from '../components/screen';
import { captureError } from '../lib/error-reporting';
import { appEnv } from '../lib/env';
import {
  buildDraftReply,
  buildInitialThread,
  buildLaunchMessages,
  buildSuggestedActions,
  buildUserMessage,
  formatFortuneTypeLabel,
  type ChatShellMessage,
} from '../lib/chat-shell';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';

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
  const {
    state: mobileAppState,
    status: mobileAppStateStatus,
    recordChatIntent,
  } = useMobileAppState();
  const [activeFortuneType, setActiveFortuneType] = useState<FortuneTypeId | null>(
    null,
  );
  const [draft, setDraft] = useState('');
  const [launchOrigin, setLaunchOrigin] = useState<'deeplink' | 'user' | null>(
    null,
  );
  const [lastAutoLaunchKey, setLastAutoLaunchKey] = useState<string | null>(null);
  const [selectedCharacterId, setSelectedCharacterId] = useState<string | null>(
    null,
  );
  const [messagesByCharacterId, setMessagesByCharacterId] = useState<
    Record<string, ChatShellMessage[]>
  >(() =>
    Object.fromEntries(
      fortuneCharacters.map((character) => [
        character.id,
        buildInitialThread(character),
      ]),
    ),
  );

  useEffect(() => {
    if (!pendingChatFortuneType) {
      return;
    }

    setActiveFortuneType(pendingChatFortuneType);
    setLaunchOrigin('deeplink');
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
    const targetId =
      selectedCharacterId ??
      params.characterId ??
      mobileAppState.chat.selectedCharacterId;

    return (
      fortuneCharacters.find((character) => character.id === targetId) ??
      highlightedExpert ??
      fortuneCharacters[0]
    );
  }, [
    highlightedExpert,
    mobileAppState.chat.selectedCharacterId,
    params.characterId,
    selectedCharacterId,
  ]);

  useEffect(() => {
    if (params.characterId) {
      setSelectedCharacterId(params.characterId);
      return;
    }

    if (highlightedExpert) {
      setSelectedCharacterId(highlightedExpert.id);
      return;
    }

    setSelectedCharacterId(
      (current) => current ?? fortuneCharacters[0]?.id ?? null,
    );
  }, [highlightedExpert?.id, params.characterId]);

  useEffect(() => {
    recordChatIntent({
      characterId: selectedCharacter.id,
      fortuneType: activeFortuneType,
    }).catch((error) => {
      captureError(error, { surface: 'chat:record-selection' }).catch(
        () => undefined,
      );
    });
  }, [activeFortuneType, recordChatIntent, selectedCharacter.id]);

  const selectedThread = messagesByCharacterId[selectedCharacter.id] ?? [];
  const suggestedActions = useMemo(
    () => buildSuggestedActions(selectedCharacter),
    [selectedCharacter],
  );

  useEffect(() => {
    if (launchOrigin !== 'deeplink' || !activeFortuneType) {
      return;
    }

    const targetCharacter = highlightedExpert ?? selectedCharacter;
    const launchKey = `${targetCharacter.id}:${activeFortuneType}:deeplink`;

    if (lastAutoLaunchKey === launchKey) {
      return;
    }

    setSelectedCharacterId(targetCharacter.id);
    appendMessages(
      targetCharacter,
      buildLaunchMessages(targetCharacter, activeFortuneType),
    );
    setLastAutoLaunchKey(launchKey);
    setLaunchOrigin(null);
  }, [
    activeFortuneType,
    highlightedExpert,
    lastAutoLaunchKey,
    launchOrigin,
    selectedCharacter,
  ]);

  function appendMessages(
    character: FortuneCharacterSpec,
    nextMessages: ChatShellMessage[],
  ) {
    setMessagesByCharacterId((current) => ({
      ...current,
      [character.id]: [...(current[character.id] ?? []), ...nextMessages],
    }));
  }

  function handleActionPress(fortuneType: FortuneTypeId) {
    const action = buildSuggestedActions(selectedCharacter).find(
      (candidate) => candidate.fortuneType === fortuneType,
    );

    if (!action) {
      return;
    }

    setActiveFortuneType(fortuneType);
    setLaunchOrigin('user');
    appendMessages(selectedCharacter, [
      buildUserMessage(action.prompt),
      {
        id: `assistant-action-${Date.now()}`,
        sender: 'assistant',
        text: action.reply,
      },
    ]);
    recordChatIntent({
      characterId: selectedCharacter.id,
      fortuneType,
      incrementMessages: true,
    }).catch((error) => {
      captureError(error, { surface: 'chat:record-action' }).catch(
        () => undefined,
      );
    });
  }

  function handleSendDraft() {
    const trimmed = draft.trim();

    if (!trimmed) {
      return;
    }

    appendMessages(selectedCharacter, [
      buildUserMessage(trimmed),
      buildDraftReply(selectedCharacter, trimmed),
    ]);
    recordChatIntent({
      characterId: selectedCharacter.id,
      fortuneType: activeFortuneType,
      incrementMessages: true,
    }).catch((error) => {
      captureError(error, { surface: 'chat:record-draft' }).catch(
        () => undefined,
      );
    });
    setDraft('');
  }

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
        <Chip
          label={`app-state:${mobileAppStateStatus}`}
          tone={mobileAppStateStatus === 'ready' ? 'success' : 'neutral'}
        />
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
            <AppText variant="heading4">Chat Surface</AppText>
            <AppText variant="bodyMedium">
              캐릭터 선택, suggested action, 메시지 스레드까지 한 화면에서 이어지는 RN chat shell 입니다.
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
            <Chip
              label={`tokens:${mobileAppState.premium.tokenBalance.toLocaleString('ko-KR')}`}
            />
            <Chip
              label={`messages:${mobileAppState.chat.sentMessageCount}`}
              tone="accent"
            />
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
                <Pressable
                  key={specialty}
                  accessibilityRole="button"
                  onPress={() => handleActionPress(specialty)}
                >
                  <View>
                    <Chip label={formatFortuneTypeLabel(specialty)} />
                  </View>
                </Pressable>
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
            {mobileAppState.profile.displayName ? (
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
              >
                {mobileAppState.profile.displayName} 님의 최근 채팅 기준으로 이 캐릭터를 계속 이어갑니다.
              </AppText>
            ) : null}
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
            <AppText variant="heading4">Suggested Actions</AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              Flutter 추천 칩 흐름처럼 선택된 캐릭터의 주력 운세를 빠르게 시작할 수 있습니다.
            </AppText>
            <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
              {suggestedActions.map((action) => (
                <Pressable
                  key={action.id}
                  accessibilityRole="button"
                  onPress={() => handleActionPress(action.fortuneType)}
                  style={({ pressed }) => ({
                    opacity: pressed ? 0.82 : 1,
                  })}
                >
                  <View>
                    <Chip
                      label={action.label}
                      tone={
                        activeFortuneType === action.fortuneType
                          ? 'accent'
                          : 'neutral'
                      }
                    />
                  </View>
                </Pressable>
              ))}
            </View>
          </Card>

          <Card>
            <AppText variant="heading4">Conversation Thread</AppText>
            <View style={{ gap: fortuneTheme.spacing.sm }}>
              {selectedThread.map((message) => (
                <MessageBubble key={message.id} message={message} />
              ))}
            </View>
          </Card>

          <Card>
            <AppText variant="heading4">Composer</AppText>
            <TextInput
              accessibilityLabel="chat composer"
              multiline
              onChangeText={setDraft}
              placeholder={`${selectedCharacter.name}에게 질문을 입력하세요`}
              placeholderTextColor={fortuneTheme.colors.textTertiary}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderColor: fortuneTheme.colors.border,
                borderRadius: fortuneTheme.radius.lg,
                borderWidth: 1,
                color: fortuneTheme.colors.textPrimary,
                minHeight: 104,
                padding: fortuneTheme.spacing.md,
                textAlignVertical: 'top',
              }}
              value={draft}
            />
            <PrimaryButton onPress={handleSendDraft}>메시지 보내기</PrimaryButton>
          </Card>

          <Card>
            <AppText variant="heading4">Next Surfaces</AppText>
            <PrimaryButton onPress={() => router.push('/premium')}>
              Premium surface
            </PrimaryButton>
            <PrimaryButton onPress={() => router.push('/profile')} tone="secondary">
              Profile surface
            </PrimaryButton>
          </Card>
        </>
      ) : null}
    </Screen>
  );
}

function MessageBubble({ message }: { message: ChatShellMessage }) {
  const isAssistant = message.sender === 'assistant';
  const isSystem = message.sender === 'system';

  return (
    <View
      style={{
        alignItems: isAssistant || isSystem ? 'flex-start' : 'flex-end',
      }}
    >
      <View
        style={{
          backgroundColor: isSystem
            ? fortuneTheme.colors.surfaceSecondary
            : isAssistant
              ? fortuneTheme.colors.backgroundTertiary
              : fortuneTheme.colors.userBubble,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.messageBubble,
          borderWidth: 1,
          maxWidth: '92%',
          paddingHorizontal: fortuneTheme.spacing.md,
          paddingVertical: fortuneTheme.spacing.sm,
        }}
      >
        <AppText
          variant="bodyMedium"
          color={
            isSystem
              ? fortuneTheme.colors.textSecondary
              : fortuneTheme.colors.textPrimary
          }
        >
          {message.text}
        </AppText>
      </View>
    </View>
  );
}
