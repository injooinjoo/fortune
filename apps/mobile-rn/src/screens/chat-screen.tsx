import { useEffect, useMemo, useState } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import {
  findFortuneExpert,
  type FortuneCharacterSpec,
  fortuneCharacters,
  type FortuneTypeId,
} from '@fortune/product-contracts';
import { View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Screen } from '../components/screen';
import {
  ActiveCharacterChatSurface,
  ChatFirstRunSurface,
  ChatSoftGate,
  ProfileFlowGateCard,
} from '../features/chat-surface/chat-surface';
import { resolveResultKindFromFortuneType } from '../features/fortune-results/mapping';
import { captureError } from '../lib/error-reporting';
import {
  buildDraftReply,
  buildInitialThread,
  buildLaunchMessages,
  buildSuggestedActions,
  buildUserMessage,
  type ChatShellAction,
  type ChatShellMessage,
} from '../lib/chat-shell';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';
import { useSocialAuth } from '../providers/social-auth-provider';

type SurfaceMode = 'list' | 'chat';

function readSearchParam(
  value: string | string[] | undefined,
): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

export function ChatScreen() {
  const params = useLocalSearchParams<{ characterId?: string | string[] }>();
  const directCharacterId = readSearchParam(params.characterId);
  const {
    consumePendingChatFortuneType,
    gate,
    markGuestBrowse,
    onboardingProgress,
    pendingChatFortuneType,
    status,
  } = useAppBootstrap();
  const { state: mobileAppState, recordChatIntent } = useMobileAppState();
  const { isSupported, startSocialAuth } = useSocialAuth();
  const [activeFortuneType, setActiveFortuneType] =
    useState<FortuneTypeId | null>(null);
  const [activeProviderId, setActiveProviderId] = useState<
    'apple' | 'google' | null
  >(null);
  const [authMessage, setAuthMessage] = useState<string | null>(null);
  const [draft, setDraft] = useState('');
  const [launchOrigin, setLaunchOrigin] = useState<'deeplink' | 'user' | null>(
    null,
  );
  const [lastAutoLaunchKey, setLastAutoLaunchKey] = useState<string | null>(null);
  const [selectedCharacterId, setSelectedCharacterId] = useState<string | null>(
    null,
  );
  const [surfaceMode, setSurfaceMode] = useState<SurfaceMode>(() =>
    directCharacterId ||
    mobileAppState.chat.sentMessageCount > 0 ||
    mobileAppState.chat.selectedCharacterId
      ? 'chat'
      : 'list',
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

  const routeableCharacters = useMemo(
    () =>
      fortuneCharacters.filter((character) =>
        buildSuggestedActions(character).some((action) =>
          Boolean(resolveResultKindFromFortuneType(action.fortuneType)),
        ),
      ),
    [],
  );

  useEffect(() => {
    if (!pendingChatFortuneType) {
      return;
    }

    setActiveFortuneType(pendingChatFortuneType);
    setLaunchOrigin('deeplink');
    setSurfaceMode('chat');
    consumePendingChatFortuneType().catch((error) => {
      captureError(error, { surface: 'chat:consume-pending-fortune' }).catch(
        () => undefined,
      );
    });
  }, [consumePendingChatFortuneType, pendingChatFortuneType]);

  const highlightedExpert = activeFortuneType
    ? findFortuneExpert(activeFortuneType)
    : undefined;
  const defaultCharacter = highlightedExpert ?? routeableCharacters[0] ?? fortuneCharacters[0];
  const selectedCharacter = useMemo(() => {
    const targetId =
      selectedCharacterId ??
      directCharacterId ??
      mobileAppState.chat.selectedCharacterId;

    return (
      fortuneCharacters.find((character) => character.id === targetId) ??
      highlightedExpert ??
      defaultCharacter
    );
  }, [
    defaultCharacter,
    directCharacterId,
    highlightedExpert,
    mobileAppState.chat.selectedCharacterId,
    selectedCharacterId,
  ]);

  useEffect(() => {
    if (directCharacterId) {
      setSelectedCharacterId(directCharacterId);
      setSurfaceMode('chat');
      return;
    }

    if (highlightedExpert) {
      setSelectedCharacterId(highlightedExpert.id);
      setSurfaceMode('chat');
      return;
    }

    setSelectedCharacterId((current) => current ?? defaultCharacter?.id ?? null);
  }, [defaultCharacter?.id, directCharacterId, highlightedExpert?.id]);

  const selectedThread = messagesByCharacterId[selectedCharacter.id] ?? [];
  const selectedCharacterActions = useMemo(
    () => buildSuggestedActions(selectedCharacter),
    [selectedCharacter],
  );
  const firstRunActionPairs = useMemo(() => {
    const seen = new Set<FortuneTypeId>();

    return routeableCharacters
      .flatMap((character) =>
        buildSuggestedActions(character).map((action) => ({ action, character })),
      )
      .filter(({ action }) => Boolean(resolveResultKindFromFortuneType(action.fortuneType)))
      .filter(({ action }) => {
        if (seen.has(action.fortuneType)) {
          return false;
        }

        seen.add(action.fortuneType);
        return true;
      })
      .slice(0, 4);
  }, [routeableCharacters]);
  const firstRunActions = firstRunActionPairs.map(({ action }) => action);
  const firstRunFeaturedCharacter =
    firstRunActionPairs[0]?.character ?? selectedCharacter;
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
    openResultRoute(activeFortuneType, 'deeplink', targetCharacter.id);
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

  function openResultRoute(
    fortuneType: FortuneTypeId | null | undefined,
    source: 'chat-action' | 'deeplink' | 'recent-card',
    characterId: string | null = selectedCharacter.id,
  ) {
    if (!fortuneType) {
      return false;
    }

    const resultKind = resolveResultKindFromFortuneType(fortuneType);

    if (!resultKind) {
      return false;
    }

    router.push({
      pathname: '/result/[resultKind]',
      params: {
        resultKind,
        source,
        ...(characterId ? { characterId } : {}),
      },
    });

    return true;
  }

  function handleCharacterSelect(characterId: string) {
    setSelectedCharacterId(characterId);
    setSurfaceMode('chat');
    recordChatIntent({
      characterId,
      fortuneType: activeFortuneType,
    }).catch((error) => {
      captureError(error, {
        surface: 'chat:record-explicit-selection',
      }).catch(() => undefined);
    });
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
    setSurfaceMode('chat');
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

    openResultRoute(fortuneType, 'chat-action', selectedCharacter.id);
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
    setSurfaceMode('chat');
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

  async function handleSocialAuthStart(providerId: 'apple' | 'google') {
    try {
      setActiveProviderId(providerId);
      setAuthMessage(null);

      if (!isSupported(providerId)) {
        setAuthMessage(`${providerId === 'apple' ? 'Apple' : 'Google'} 로그인이 아직 준비되지 않았습니다.`);
        return;
      }

      const result = await startSocialAuth(providerId, '/chat');

      if (result.status === 'started') {
        setAuthMessage(
          `${providerId === 'apple' ? 'Apple' : 'Google'} 로그인 브라우저 인증을 시작했습니다.`,
        );
        return;
      }

      setAuthMessage(result.errorMessage ?? '로그인을 시작하지 못했습니다.');
    } catch (error) {
      await captureError(error, { surface: 'chat:start-social-auth' });
      setAuthMessage('소셜 로그인을 시작하지 못했습니다.');
    } finally {
      setActiveProviderId(null);
    }
  }

  async function handleBrowse() {
    try {
      await markGuestBrowse();
    } catch (error) {
      await captureError(error, { surface: 'chat:guest-browse' });
    }
  }

  if (status === 'loading') {
    return (
      <Screen>
        <Card>
          <AppText variant="displaySmall">메시지를 준비하는 중</AppText>
          <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
            세션, 온보딩 상태, 딥링크 의도를 읽고 있어요.
          </AppText>
        </Card>
      </Screen>
    );
  }

  return (
    <Screen>
      {gate === 'auth-entry' ? (
        <ChatSoftGate
          authMessage={
            activeProviderId
              ? `${activeProviderId === 'apple' ? 'Apple' : 'Google'} 연결을 준비 중입니다.`
              : authMessage
          }
          onApple={() => void handleSocialAuthStart('apple')}
          onBrowse={() => void handleBrowse()}
          onGoogle={() => void handleSocialAuthStart('google')}
        />
      ) : null}

      {gate === 'profile-flow' ? (
        <ProfileFlowGateCard
          birthCompleted={onboardingProgress.birthCompleted}
          firstRunHandoffSeen={onboardingProgress.firstRunHandoffSeen}
          interestCompleted={onboardingProgress.interestCompleted}
          onContinue={() => router.push('/onboarding')}
        />
      ) : null}

      {gate === 'ready' ? (
        surfaceMode === 'chat' ? (
          <ActiveCharacterChatSurface
            actions={
              selectedCharacterActions.length > 0
                ? selectedCharacterActions
                : firstRunActions
            }
            character={selectedCharacter}
            draft={draft}
            messages={selectedThread}
            onBack={() => {
              setSurfaceMode('list');
              setActiveFortuneType(null);
            }}
            onDraftChange={setDraft}
            onOpenProfile={() =>
              router.push(`/character/${selectedCharacter.id}` as Href)
            }
            onPickAction={handleActionPress}
            onSend={handleSendDraft}
          />
        ) : (
          <ChatFirstRunSurface
            actions={firstRunActions}
            characters={routeableCharacters}
            featuredCharacter={firstRunFeaturedCharacter}
            onPickAction={handleActionPress}
            onSelectCharacter={handleCharacterSelect}
          />
        )
      ) : null}
    </Screen>
  );
}
