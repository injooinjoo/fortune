import { useEffect, useMemo, useState } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import { type FortuneTypeId } from '@fortune/product-contracts';
import { View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Screen } from '../components/screen';
import {
  ActiveChatComposer,
  ActiveCharacterChatHeader,
  ActiveCharacterChatSurface,
  ActiveSurveyFooter,
  ChatFirstRunSurface,
  ChatSoftGate,
  FloatingCreateButton,
  FortuneChipBar,
  ProfileFlowGateCard,
} from '../features/chat-surface/chat-surface';
import {
  applySurveyAnswer,
  formatSurveyAnswerLabel,
  getChatSurveyDefinition,
  getCurrentSurveyStep,
  resolveSurveyQuestion,
  startChatSurvey,
} from '../features/chat-survey/registry';
import type { ActiveChatSurvey } from '../features/chat-survey/types';
import { resolveResultKindFromFortuneType } from '../features/fortune-results/mapping';
import { captureError } from '../lib/error-reporting';
import { getFortuneResult, type FortuneRequestContext } from '../lib/fortune-service';
import {
  buildAssistantTextMessage,
  buildEmbeddedResultMessage,
  buildEmbeddedResultMessageFromPayload,
  buildDraftReply,
  buildInitialThread,
  buildLaunchMessages,
  buildSuggestedActions,
  buildUserMessage,
  formatFortuneTypeLabel,
  type ChatShellAction,
  type ChatShellEmbeddedResultMessage,
  type ChatShellMessage,
} from '../lib/chat-shell';
import {
  chatCharacters,
  findChatCharacterById,
  fortuneChatCharacters,
  isFortuneChatCharacter,
  storyChatCharacters,
  type ChatCharacterSpec,
  type ChatCharacterTab,
} from '../lib/chat-characters';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useFriendCreation } from '../providers/friend-creation-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';
import { useSocialAuth } from '../providers/social-auth-provider';

type SurfaceMode = 'list' | 'chat';

function readSearchParam(
  value: string | string[] | undefined,
): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

function supportsChatNativeRuntime(fortuneType: FortuneTypeId) {
  return (
    getChatSurveyDefinition(fortuneType) !== null ||
    resolveResultKindFromFortuneType(fortuneType) !== null
  );
}

export function ChatScreen() {
  const params = useLocalSearchParams<{ characterId?: string | string[] }>();
  const directCharacterId = readSearchParam(params.characterId);
  const directCharacter = findChatCharacterById(directCharacterId);
  const {
    consumePendingChatFortuneType,
    gate,
    markGuestBrowse,
    onboardingProgress,
    pendingChatFortuneType,
    status,
  } = useAppBootstrap();
  const { state: mobileAppState, recordChatIntent } = useMobileAppState();
  const { resetDraft } = useFriendCreation();
  const { isSupported, startSocialAuth } = useSocialAuth();
  const [activeFortuneType, setActiveFortuneType] =
    useState<FortuneTypeId | null>(null);
  const [activeProviderId, setActiveProviderId] = useState<
    'apple' | 'google' | null
  >(null);
  const [authMessage, setAuthMessage] = useState<string | null>(null);
  const [draft, setDraft] = useState('');
  const [surveyDraft, setSurveyDraft] = useState('');
  const [surveySelections, setSurveySelections] = useState<string[]>([]);
  const [isChipBarExpanded, setIsChipBarExpanded] = useState(false);
  const [pendingImage, setPendingImage] = useState<string | null>(null);
  const [launchOrigin, setLaunchOrigin] = useState<'deeplink' | 'user' | null>(
    null,
  );
  const [lastAutoLaunchKey, setLastAutoLaunchKey] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<ChatCharacterTab>(() => {
    if (directCharacter) {
      return directCharacter.kind;
    }

    const restoredCharacter = findChatCharacterById(
      mobileAppState.chat.selectedCharacterId,
    );

    return restoredCharacter?.kind ?? 'story';
  });
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
      chatCharacters.map((character) => [
        character.id,
        buildInitialThread(character),
      ]),
    ),
  );
  const [activeSurveysByCharacterId, setActiveSurveysByCharacterId] = useState<
    Record<string, ActiveChatSurvey | null>
  >({});

  const chatNativeFortuneCharacters = useMemo(
    () =>
      fortuneChatCharacters.filter((character) =>
        buildSuggestedActions(character).some((action) =>
          supportsChatNativeRuntime(action.fortuneType),
        ),
      ),
    [],
  );

  useEffect(() => {
    if (!pendingChatFortuneType) {
      return;
    }

    setActiveFortuneType(pendingChatFortuneType);
    setActiveTab('fortune');
    setLaunchOrigin('deeplink');
    setSurfaceMode('chat');
    consumePendingChatFortuneType().catch((error) => {
      captureError(error, { surface: 'chat:consume-pending-fortune' }).catch(
        () => undefined,
      );
    });
  }, [consumePendingChatFortuneType, pendingChatFortuneType]);

  const highlightedExpert = activeFortuneType
    ? fortuneChatCharacters.find((character) =>
        character.specialties.includes(activeFortuneType),
      )
    : undefined;
  const tabCharacters =
    activeTab === 'story' ? storyChatCharacters : fortuneChatCharacters;
  const defaultCharacter =
    highlightedExpert ??
    (activeTab === 'fortune'
      ? chatNativeFortuneCharacters[0] ?? fortuneChatCharacters[0]
      : tabCharacters[0]) ??
    storyChatCharacters[0] ??
    chatCharacters[0];
  const selectedCharacter = useMemo(() => {
    const targetId =
      selectedCharacterId ??
      directCharacterId ??
      mobileAppState.chat.selectedCharacterId;

    return (
      findChatCharacterById(targetId) ??
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
      setActiveTab(directCharacter?.kind ?? 'story');
      setSurfaceMode('chat');
      return;
    }

    if (highlightedExpert) {
      setSelectedCharacterId(highlightedExpert.id);
      setActiveTab('fortune');
      setSurfaceMode('chat');
      return;
    }

    setSelectedCharacterId((current) => current ?? defaultCharacter?.id ?? null);
  }, [
    defaultCharacter?.id,
    directCharacter?.kind,
    directCharacterId,
    highlightedExpert?.id,
  ]);

  const selectedThread = messagesByCharacterId[selectedCharacter.id] ?? [];
  const activeSurvey = activeSurveysByCharacterId[selectedCharacter.id] ?? null;
  const currentSurveyStep = activeSurvey
    ? getCurrentSurveyStep(activeSurvey)
    : null;

  useEffect(() => {
    setSurveyDraft('');
    setSurveySelections([]);
  }, [selectedCharacter.id, currentSurveyStep?.step.id]);

  const selectedCharacterActions = useMemo(
    () =>
      isFortuneChatCharacter(selectedCharacter)
        ? buildSuggestedActions(selectedCharacter).filter((action) =>
            supportsChatNativeRuntime(action.fortuneType),
          )
        : [],
    [selectedCharacter],
  );
  const firstRunActionPairs = useMemo(() => {
    const seen = new Set<FortuneTypeId>();

    return chatNativeFortuneCharacters
      .flatMap((character) =>
        buildSuggestedActions(character).map((action) => ({ action, character })),
      )
      .filter(({ action }) => supportsChatNativeRuntime(action.fortuneType))
      .filter(({ action }) => {
        if (seen.has(action.fortuneType)) {
          return false;
        }

        seen.add(action.fortuneType);
        return true;
      })
      .slice(0, 4);
  }, [chatNativeFortuneCharacters]);
  const firstRunActions = firstRunActionPairs.map(({ action }) => action);
  const firstRunCharacters = tabCharacters;
  const firstRunFeaturedCharacter =
    firstRunCharacters.find((character) => character.id === selectedCharacter.id) ??
    (activeTab === 'fortune'
      ? firstRunActionPairs[0]?.character
      : firstRunCharacters[0]) ??
    selectedCharacter;
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
    beginFortuneRuntime(targetCharacter, activeFortuneType);
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
    character: ChatCharacterSpec,
    nextMessages: ChatShellMessage[],
  ) {
    setMessagesByCharacterId((current) => ({
      ...current,
      [character.id]: [...(current[character.id] ?? []), ...nextMessages],
    }));
  }

  function setActiveSurvey(
    characterId: string,
    survey: ActiveChatSurvey | null,
  ) {
    setActiveSurveysByCharacterId((current) => ({
      ...current,
      [characterId]: survey,
    }));
    setSurveyDraft('');
    setSurveySelections([]);
  }

  function beginFortuneRuntime(
    character: ChatCharacterSpec,
    fortuneType: FortuneTypeId,
  ) {
    const definition = getChatSurveyDefinition(fortuneType);

    if (definition) {
      const survey = startChatSurvey(definition);
      const question =
        resolveSurveyQuestion(survey, {
          mbti: mobileAppState.profile.mbti || undefined,
        }) ?? definition.steps[0]?.question;

      setActiveSurvey(character.id, survey);

      if (question) {
        appendMessages(character, [buildAssistantTextMessage(question)]);
      }

      return true;
    }

    const embeddedResult = buildEmbeddedResultMessage(
      fortuneType,
      buildResultContext(character),
    );

    if (!embeddedResult) {
      return false;
    }

    setActiveSurvey(character.id, null);
    appendMessages(character, [
      buildAssistantTextMessage('좋아요. 결과를 같은 대화 안에 바로 붙여드릴게요.'),
      embeddedResult,
    ]);

    return true;
  }

  function completeSurvey(
    character: ChatCharacterSpec,
    completed: {
      fortuneType: FortuneTypeId;
      answers: Record<string, unknown>;
    },
  ) {
    const definition = getChatSurveyDefinition(completed.fortuneType);

    setActiveSurvey(character.id, null);

    appendMessages(character, [
      buildAssistantTextMessage(
        definition?.submitReply ??
          '좋아요. 결과를 같은 채팅 안에서 바로 보여드릴게요.',
      ),
      buildAssistantTextMessage('결과를 준비하고 있어요...'),
    ]);

    // Try API-backed fortune result first, fall back to fixture
    const requestContext: FortuneRequestContext = {
      birthDate: mobileAppState.profile.birthDate || undefined,
      birthTime: mobileAppState.profile.birthTime || undefined,
      mbti: mobileAppState.profile.mbti || undefined,
      bloodType: mobileAppState.profile.bloodType || undefined,
      answers: completed.answers,
    };

    getFortuneResult(completed.fortuneType, requestContext)
      .then((apiResult) => {
        // Build embedded result - use API data if available, fallback to fixture
        const embeddedResult = buildEmbeddedResultMessage(
          completed.fortuneType,
          buildResultContext(character, {
            ...completed.answers,
            ...(apiResult.source !== 'fixture' ? apiResult.data : {}),
          }),
        );

        if (embeddedResult) {
          appendMessages(character, [embeddedResult]);
        } else {
          // Fallback to fixture-based result
          const fixtureResult = buildEmbeddedResultMessage(
            completed.fortuneType,
            buildResultContext(character, completed.answers),
          );
          if (fixtureResult) {
            appendMessages(character, [fixtureResult]);
          }
        }
      })
      .catch((error) => {
        captureError(error, { surface: 'chat:fortune-api' }).catch(
          () => undefined,
        );
        // Fallback to fixture
        const embeddedResult = buildEmbeddedResultMessage(
          completed.fortuneType,
          buildResultContext(character, completed.answers),
        );
        if (embeddedResult) {
          appendMessages(character, [embeddedResult]);
        }
      });
  }

  function reopenFortuneResult(
    character: ChatCharacterSpec,
    fortuneType: FortuneTypeId,
    prefixText: string,
  ) {
    const previousMessage = findMostRecentEmbeddedResult(character.id, fortuneType);
    const embeddedResult = previousMessage
      ? buildEmbeddedResultMessageFromPayload(previousMessage.payload)
      : buildEmbeddedResultMessage(
          fortuneType,
          buildResultContext(character),
        );

    if (!embeddedResult) {
      return false;
    }

    setActiveSurvey(character.id, null);
    appendMessages(character, [
      buildAssistantTextMessage(prefixText),
      embeddedResult,
    ]);
    return true;
  }

  function handleCharacterSelect(characterId: string) {
    const character = findChatCharacterById(characterId);

    setSelectedCharacterId(characterId);
    setActiveTab(character?.kind ?? 'story');
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
      buildAssistantTextMessage(action.reply),
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

    beginFortuneRuntime(selectedCharacter, fortuneType);
  }

  function handleCreateFriend() {
    resetDraft();
    router.push({
      pathname: '/friends/new/basic',
      params: { reset: '1', returnTo: '/chat' },
    });
  }

  function handleOpenRecentResult(fortuneType: FortuneTypeId) {
    const recentFortuneCharacterId =
      fortuneChatCharacters.find((character) =>
        character.specialties.includes(fortuneType),
      )?.id ?? selectedCharacter.id;

    setActiveTab('fortune');
    setSelectedCharacterId(recentFortuneCharacterId);
    setSurfaceMode('chat');
    const character =
      findChatCharacterById(recentFortuneCharacterId) ?? selectedCharacter;
    reopenFortuneResult(
      character,
      fortuneType,
      `${character.name}와 보던 ${formatFortuneTypeLabel(fortuneType)} 결과를 같은 대화 안에 다시 열어드릴게요.`,
    );
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

  function submitSurveyAnswer(answer: unknown, displayLabel?: string) {
    if (!activeSurvey || !currentSurveyStep) {
      return;
    }

    const answerLabel =
      displayLabel ??
      formatSurveyAnswerLabel(currentSurveyStep.step, answer);

    appendMessages(selectedCharacter, [buildUserMessage(answerLabel)]);

    const { nextSurvey, completed } = applySurveyAnswer(activeSurvey, answer);

    if (nextSurvey) {
      setActiveSurvey(selectedCharacter.id, nextSurvey);
      const nextQuestion = resolveSurveyQuestion(nextSurvey, {
        mbti: mobileAppState.profile.mbti || undefined,
      });

      if (nextQuestion) {
        appendMessages(selectedCharacter, [
          buildAssistantTextMessage(nextQuestion),
        ]);
      }
    } else if (completed) {
      completeSurvey(selectedCharacter, completed);
    }

    recordChatIntent({
      characterId: selectedCharacter.id,
      fortuneType: activeSurvey.fortuneType,
      incrementMessages: true,
    }).catch((error) => {
      captureError(error, { surface: 'chat:record-survey-answer' }).catch(
        () => undefined,
      );
    });

    setSurveyDraft('');
    setSurveySelections([]);
  }

  function buildResultContext(
    character: ChatCharacterSpec,
    answers: Record<string, unknown> = {},
  ) {
    return {
      answers,
      characterName: character.name,
      profile: {
        birthDate: mobileAppState.profile.birthDate || undefined,
        birthTime: mobileAppState.profile.birthTime || undefined,
        mbti: mobileAppState.profile.mbti || undefined,
        bloodType: mobileAppState.profile.bloodType || undefined,
      },
    };
  }

  function findMostRecentEmbeddedResult(
    characterId: string,
    fortuneType: FortuneTypeId,
  ): ChatShellEmbeddedResultMessage | null {
    const thread = messagesByCharacterId[characterId] ?? [];

    for (let index = thread.length - 1; index >= 0; index -= 1) {
      const message = thread[index];

      if (
        message?.kind === 'embedded-result' &&
        message.fortuneType === fortuneType
      ) {
        return message;
      }
    }

    return null;
  }

  function handleSurveyToggleSelection(value: string) {
    const limit = currentSurveyStep?.step.maxSelections ?? Number.POSITIVE_INFINITY;

    setSurveySelections((current) => {
      if (current.includes(value)) {
        return current.filter((item) => item !== value);
      }

      if (current.length >= limit) {
        return [...current.slice(1), value];
      }

      return [...current, value];
    });
  }

  function handleSurveySubmitSelection() {
    if (!currentSurveyStep) {
      return;
    }

    submitSurveyAnswer(surveySelections, formatSurveyAnswerLabel(currentSurveyStep.step, surveySelections));
  }

  function handleSurveySubmitText() {
    const trimmed = surveyDraft.trim();

    if (!trimmed) {
      return;
    }

    submitSurveyAnswer(trimmed, trimmed);
  }

  function handleSurveySkip() {
    submitSurveyAnswer('skip', '건너뛰기');
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
    <Screen
      header={
        gate === 'ready' && surfaceMode === 'chat' ? (
          <ActiveCharacterChatHeader
            character={selectedCharacter}
            onBack={() => {
              setSurfaceMode('list');
              setActiveFortuneType(null);
            }}
            onOpenProfile={() =>
              router.push(`/character/${selectedCharacter.id}` as Href)
            }
          />
        ) : undefined
      }
      footer={
        gate === 'ready' && surfaceMode === 'chat' ? (
          currentSurveyStep ? (
            <ActiveSurveyFooter
              draft={surveyDraft}
              onDraftChange={setSurveyDraft}
              onPickSingle={(value) => submitSurveyAnswer(value)}
              onSkip={handleSurveySkip}
              onSubmitSelection={handleSurveySubmitSelection}
              onSubmitText={handleSurveySubmitText}
              onToggleSelection={handleSurveyToggleSelection}
              selections={surveySelections}
              step={currentSurveyStep.step}
            />
          ) : (
            <View style={{ gap: 8 }}>
              {isFortuneChatCharacter(selectedCharacter) &&
              selectedCharacter.specialties.length > 0 ? (
                <FortuneChipBar
                  specialties={selectedCharacter.specialties}
                  activeFortuneType={activeFortuneType}
                  expanded={isChipBarExpanded}
                  onPickAction={handleActionPress}
                  onToggleExpand={() => setIsChipBarExpanded((v) => !v)}
                />
              ) : null}
              <ActiveChatComposer
                draft={draft}
                onDraftChange={setDraft}
                onSend={handleSendDraft}
                onImageSelected={(uri) => {
                  setPendingImage(uri);
                  appendMessages(selectedCharacter, [
                    buildUserMessage(`[사진 첨부]`),
                  ]);
                  setPendingImage(null);
                }}
                onVoiceTranscript={(text) => {
                  setDraft(text);
                }}
              />
            </View>
          )
        ) : gate === 'ready' &&
          surfaceMode === 'list' &&
          activeTab === 'story' ? (
          <View style={{ alignItems: 'flex-end' }}>
            <FloatingCreateButton
              label="새 대화 시작"
              onPress={handleCreateFriend}
            />
          </View>
        ) : undefined
      }
      keyboardAvoiding={gate === 'ready' && surfaceMode === 'chat'}
    >
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
            actions={selectedCharacterActions}
            character={selectedCharacter}
            messages={selectedThread}
            surveyActive={Boolean(currentSurveyStep)}
            surveyEyebrow={
              currentSurveyStep
                ? `${activeSurvey?.definition.title ?? '설문'} 진행 중`
                : null
            }
            showHeader={false}
            onBack={() => {
              setSurfaceMode('list');
              setActiveFortuneType(null);
            }}
            onOpenProfile={() =>
              router.push(`/character/${selectedCharacter.id}` as Href)
            }
            onPickAction={handleActionPress}
          />
        ) : (
          <ChatFirstRunSurface
            activeTab={activeTab}
            actions={firstRunActions}
            characters={firstRunCharacters}
            featuredCharacter={firstRunFeaturedCharacter}
            lastFortuneType={mobileAppState.chat.lastFortuneType}
            onChangeTab={setActiveTab}
            onCreateFriend={handleCreateFriend}
            onOpenProfile={() => router.push('/profile')}
            onOpenRecentResult={handleOpenRecentResult}
            onPickAction={handleActionPress}
            onSelectCharacter={handleCharacterSelect}
            selectedCharacterId={selectedCharacter.id}
          />
        )
      ) : null}
    </Screen>
  );
}
