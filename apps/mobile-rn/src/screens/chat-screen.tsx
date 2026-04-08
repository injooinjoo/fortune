import { useEffect, useMemo, useRef, useState } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import {
  fortuneTypesById,
  type FortuneTypeId,
} from '@fortune/product-contracts';
import { Alert, ScrollView, View } from 'react-native';

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
import type {
  ActiveChatSurvey,
  ChatSurveyPhotoAnswer,
} from '../features/chat-survey/types';
import {
  buildFortuneRuntimeBlockMessage,
  resolveFortuneRuntimeBlockReason,
} from '../features/chat-results/runtime-capabilities';
import { resolveFortuneRuntimeOutcome } from '../features/chat-results/runtime-orchestrator';
import { resolveResultKindFromFortuneType } from '../features/fortune-results/mapping';
import { captureError } from '../lib/error-reporting';
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
  type ChatShellTextMessage,
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
import {
  buildNextStoryThreadSnapshot,
  buildStoryFallbackAssistantMessage,
  buildStoryChatRequest,
  buildStoryThreadSnapshot,
  invokeStoryChat,
  loadStoryThreadSnapshot,
  saveStoryThreadSnapshot,
  type StoryChatThreadSnapshot,
} from '../lib/story-chat-runtime';
import { isStoryRomancePilotCharacterId } from '../lib/story-romance-pilots';
import {
  consumeRemoteTokens,
  RemoteTokenConsumeError,
} from '../lib/premium-remote';
import {
  socialAuthProviderLabelById,
  type SocialAuthProviderId,
} from '../lib/social-auth';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';
import { useFriendCreation } from '../providers/friend-creation-provider';
import { useMobileAppState } from '../providers/mobile-app-state-provider';
import { useSocialAuth } from '../providers/social-auth-provider';

type SurfaceMode = 'list' | 'chat';
type ImagePickerModule = typeof import('expo-image-picker');

let imagePickerModulePromise: Promise<ImagePickerModule | null> | null = null;

function readSearchParam(
  value: string | string[] | undefined,
): string | undefined {
  return Array.isArray(value) ? value[0] : value;
}

function isImagePickerNativeModuleError(error: unknown) {
  if (!(error instanceof Error)) {
    return false;
  }

  return (
    error.message.includes("Cannot find native module 'ExponentImagePicker'") ||
    error.message.includes('ExponentImagePicker') ||
    error.message.includes('expo-image-picker')
  );
}

async function loadImagePickerModule() {
  if (!imagePickerModulePromise) {
    imagePickerModulePromise = import('expo-image-picker')
      .then((module) => module)
      .catch(async (error) => {
        if (!isImagePickerNativeModuleError(error)) {
          throw error;
        }

        await captureError(error, {
          surface: 'chat:load-image-picker',
        }).catch(() => undefined);

        return null;
      });
  }

  return imagePickerModulePromise;
}

function supportsChatNativeRuntime(fortuneType: FortuneTypeId) {
  return (
    getChatSurveyDefinition(fortuneType) !== null ||
    resolveResultKindFromFortuneType(fortuneType) !== null
  );
}

type ResolvedFortuneMessage =
  | {
      kind: 'result';
      message: ChatShellEmbeddedResultMessage;
    }
  | {
      kind: 'text';
      message: ChatShellTextMessage;
      routeToPremium?: boolean;
      routeToSignup?: boolean;
    };

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
    session,
    status,
  } = useAppBootstrap();
  const {
    state: mobileAppState,
    recordChatIntent,
    syncRemoteProfile,
  } = useMobileAppState();
  const { resetDraft } = useFriendCreation();
  const { isSupported, startSocialAuth } = useSocialAuth();
  const [activeFortuneType, setActiveFortuneType] =
    useState<FortuneTypeId | null>(null);
  const [activeProviderId, setActiveProviderId] =
    useState<SocialAuthProviderId | null>(null);
  const [authMessage, setAuthMessage] = useState<string | null>(null);
  const [draft, setDraft] = useState('');
  const [surveyDraft, setSurveyDraft] = useState('');
  const [surveySelections, setSurveySelections] = useState<string[]>([]);
  const [launchOrigin, setLaunchOrigin] = useState<'deeplink' | 'user' | null>(
    null,
  );
  const [lastAutoLaunchKey, setLastAutoLaunchKey] = useState<string | null>(null);
  const [composerTrayOpen, setComposerTrayOpen] = useState(false);
  const chatScrollRef = useRef<ScrollView | null>(null);
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
      chatCharacters.map((character) => {
        const storySnapshot = buildStoryThreadSnapshot(character);

        return [
          character.id,
          storySnapshot?.messages ?? buildInitialThread(character),
        ];
      }),
    ),
  );
  const [storyThreadSnapshotsByCharacterId, setStoryThreadSnapshotsByCharacterId] =
    useState<Record<string, StoryChatThreadSnapshot | null>>(() =>
      Object.fromEntries(
        storyChatCharacters.map((character) => [
          character.id,
          buildStoryThreadSnapshot(character),
        ]),
      ),
    );
  const [storyTypingCharacterId, setStoryTypingCharacterId] = useState<
    string | null
  >(null);
  const [activeSurveysByCharacterId, setActiveSurveysByCharacterId] = useState<
    Record<string, ActiveChatSurvey | null>
  >({});
  const hydratedStoryThreadsKeyRef = useRef<string | null>(null);

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

  useEffect(() => {
    if (gate !== 'ready') {
      return;
    }

    const hydrationKey = session?.user.id ?? 'guest';
    if (hydratedStoryThreadsKeyRef.current === hydrationKey) {
      return;
    }

    hydratedStoryThreadsKeyRef.current = hydrationKey;
    let cancelled = false;

    async function hydrateStoryThreads() {
      try {
        const snapshots = await Promise.all(
          storyChatCharacters
            .filter((character) => isStoryRomancePilotCharacterId(character.id))
            .map(async (character) => ({
              characterId: character.id,
              snapshot: await loadStoryThreadSnapshot(character.id),
            })),
        );

        if (cancelled) {
          return;
        }

        const nextMessages: Record<string, ChatShellMessage[]> = {};
        const nextSnapshots: Record<string, StoryChatThreadSnapshot | null> = {};

        for (const { characterId, snapshot } of snapshots) {
          if (snapshot) {
            nextMessages[characterId] = snapshot.messages;
            nextSnapshots[characterId] = snapshot;
          }
        }

        if (Object.keys(nextMessages).length === 0) {
          return;
        }

        setMessagesByCharacterId((current) => ({
          ...current,
          ...nextMessages,
        }));
        setStoryThreadSnapshotsByCharacterId((current) => ({
          ...current,
          ...nextSnapshots,
        }));
      } catch (error) {
        await captureError(error, { surface: 'chat:hydrate-story-threads' }).catch(
          () => undefined,
        );
      }
    }

    void hydrateStoryThreads();

    return () => {
      cancelled = true;
    };
  }, [gate, session?.user.id]);

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
      ? fortuneChatCharacters[0]
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
  const selectedStorySnapshot =
    storyThreadSnapshotsByCharacterId[selectedCharacter.id] ?? null;
  const selectedStoryIsTyping = storyTypingCharacterId === selectedCharacter.id;
  const storySendInFlight = storyTypingCharacterId !== null;
  const activeSurvey = activeSurveysByCharacterId[selectedCharacter.id] ?? null;
  const currentSurveyStep = activeSurvey
    ? getCurrentSurveyStep(activeSurvey)
    : null;

  function scrollChatToBottom(animated = true) {
    requestAnimationFrame(() => {
      chatScrollRef.current?.scrollToEnd({ animated });
    });
  }

  useEffect(() => {
    setSurveyDraft('');
    setSurveySelections([]);
  }, [selectedCharacter.id, currentSurveyStep?.step.id]);

  useEffect(() => {
    setComposerTrayOpen(false);
  }, [selectedCharacter.id, currentSurveyStep?.step.id, surfaceMode]);

  const selectedCharacterActions = useMemo(
    () =>
      isFortuneChatCharacter(selectedCharacter)
        ? buildSuggestedActions(selectedCharacter)
        : [],
    [selectedCharacter],
  );
  const firstRunCharacters = tabCharacters;

  useEffect(() => {
    if (gate !== 'ready' || surfaceMode !== 'chat') {
      return;
    }

    scrollChatToBottom(selectedThread.length > 2);
  }, [
    gate,
    surfaceMode,
    selectedCharacter.id,
    selectedThread.length,
    currentSurveyStep?.step.id,
  ]);
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

  function routeToSignup() {
    setAuthMessage(null);
    setComposerTrayOpen(false);
    router.push({
      pathname: '/signup',
      params: {
        requireAuth: '1',
        returnTo: '/chat',
      },
    });
  }

  function beginFortuneRuntime(
    character: ChatCharacterSpec,
    fortuneType: FortuneTypeId,
  ) {
    const runtimeBlockReason = resolveFortuneRuntimeBlockReason(
      fortuneType,
      mobileAppState.profile,
      Boolean(session),
    );

    if (runtimeBlockReason) {
      if (runtimeBlockReason === 'login-required') {
        routeToSignup();
        return true;
      }

      const blockMessage = buildFortuneRuntimeBlockMessage(
        fortuneType,
        runtimeBlockReason,
      );

      if (blockMessage) {
        appendMessages(character, [buildAssistantTextMessage(blockMessage)]);
      }

      return true;
    }

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

    if (!resolveResultKindFromFortuneType(fortuneType)) {
      return false;
    }

    setActiveSurvey(character.id, null);
    void appendResolvedFortuneResult(character, fortuneType);

    return true;
  }

  async function completeSurvey(
    character: ChatCharacterSpec,
    completed: {
      fortuneType: FortuneTypeId;
      answers: Record<string, unknown>;
    },
  ) {
    const definition = getChatSurveyDefinition(completed.fortuneType);
    setActiveSurvey(character.id, null);

    const resolved = await resolveFortuneResultMessage(
      completed.fortuneType,
      buildResultContext(character, completed.answers),
      'chat:complete-survey',
    );

    if (!resolved) {
      return;
    }

    if (resolved.kind === 'text') {
      if (resolved.routeToSignup) {
        routeToSignup();
        return;
      }

      appendMessages(character, [resolved.message]);
      if (resolved.routeToPremium) {
        router.push('/premium');
      }
      return;
    }

    appendMessages(character, [
      buildAssistantTextMessage(
        definition?.submitReply ??
          '좋아요. 결과를 같은 채팅 안에서 바로 보여드릴게요.',
      ),
      resolved.message,
    ]);
  }

  function reopenFortuneResult(
    character: ChatCharacterSpec,
    fortuneType: FortuneTypeId,
    prefixText: string,
  ) {
    const previousMessage = findMostRecentEmbeddedResult(character.id, fortuneType);
    if (!previousMessage) {
      return false;
    }

    const embeddedResult = buildEmbeddedResultMessageFromPayload(
      previousMessage.payload,
    );

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

  function handleCharacterActionPress(
    characterId: string,
    fortuneType: FortuneTypeId,
  ) {
    const character = findChatCharacterById(characterId) ?? selectedCharacter;
    const action = buildSuggestedActions(character).find(
      (candidate) => candidate.fortuneType === fortuneType,
    );

    if (!action) {
      return;
    }

    setSelectedCharacterId(character.id);
    setActiveTab(character.kind);
    setActiveFortuneType(fortuneType);
    setLaunchOrigin('user');
    setSurfaceMode('chat');
    setComposerTrayOpen(false);
    appendMessages(character, [
      buildUserMessage(action.prompt),
      buildAssistantTextMessage(action.reply),
    ]);
    recordChatIntent({
      characterId: character.id,
      fortuneType,
      incrementMessages: true,
    }).catch((error) => {
      captureError(error, { surface: 'chat:record-action' }).catch(
        () => undefined,
      );
    });

    const launched = beginFortuneRuntime(character, fortuneType);

    if (!launched && !supportsChatNativeRuntime(fortuneType)) {
      appendMessages(character, [
        buildAssistantTextMessage(
          `${formatFortuneTypeLabel(fortuneType)} 흐름은 같은 채팅 안에서 바로 이어질 수 있도록 준비 중이에요.`,
        ),
      ]);
    }
  }

  function handleActionPress(fortuneType: FortuneTypeId) {
    handleCharacterActionPress(selectedCharacter.id, fortuneType);
  }

  function handleCreateFriend() {
    resetDraft();
    router.push({
      pathname: '/friends/new/basic',
      params: { reset: '1', returnTo: '/chat' },
    });
  }

  function handleOpenPhotoPicker() {
    setComposerTrayOpen(false);

    if (currentSurveyStep?.step.inputKind === 'photo') {
      void handleSurveyPickPhoto();
      return;
    }

    Alert.alert(
      '사진 보내기',
      '일반 채팅 첨부는 아직 준비 중이고, 관상/OOTD 설문 안에서는 바로 사용할 수 있어요.',
    );
  }

  async function handleSurveyPickPhoto() {
    if (!currentSurveyStep || currentSurveyStep.step.inputKind !== 'photo') {
      return;
    }

    try {
      const imagePicker = await loadImagePickerModule();

      if (!imagePicker) {
        Alert.alert(
          '사진 선택 준비 중',
          '현재 설치된 앱 빌드에는 사진 선택 기능이 아직 포함되지 않았어요. iOS dev client를 다시 빌드한 뒤 다시 시도해주세요.',
        );
        return;
      }

      const permission =
        await imagePicker.requestMediaLibraryPermissionsAsync();

      if (!permission.granted) {
        Alert.alert(
          '사진 접근 권한 필요',
          '관상과 OOTD 결과를 보려면 사진 접근 권한이 필요해요.',
        );
        return;
      }

      const result = await imagePicker.launchImageLibraryAsync({
        allowsEditing: true,
        base64: true,
        mediaTypes: ['images'],
        quality: 0.8,
      });

      if (result.canceled || !result.assets.length) {
        return;
      }

      const asset = result.assets[0];

      if (!asset.base64) {
        Alert.alert(
          '사진 읽기 실패',
          '사진 데이터를 읽지 못했어요. 다른 사진으로 다시 시도해주세요.',
        );
        return;
      }

      const photoAnswer: ChatSurveyPhotoAnswer = {
        base64: asset.base64,
        fileName: asset.fileName ?? null,
        height: asset.height,
        mimeType: asset.mimeType ?? null,
        uri: asset.uri,
        width: asset.width,
      };

      submitSurveyAnswer(photoAnswer, '사진 1장 첨부');
    } catch (error) {
      await captureError(error, {
        surface: 'chat:pick-survey-photo',
      }).catch(() => undefined);
      Alert.alert(
        '사진 선택 실패',
        '사진을 불러오지 못했어요. 잠시 후 다시 시도해주세요.',
      );
    }
  }

  function handleStartVoiceInput() {
    Alert.alert('목소리로 하기', '음성 입력 연결은 다음 단계에서 바로 붙이겠습니다.');
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
    const reopened = reopenFortuneResult(
      character,
      fortuneType,
      `${character.name}와 보던 ${formatFortuneTypeLabel(fortuneType)} 결과를 같은 대화 안에 다시 열어드릴게요.`,
    );

    if (!reopened) {
      handleCharacterActionPress(character.id, fortuneType);
    }
  }

  async function sendStoryPilotMessage(
    character: ChatCharacterSpec,
    text: string,
  ) {
    const trimmed = text.trim();

    if (!trimmed) {
      return;
    }

    const existingSnapshot =
      storyThreadSnapshotsByCharacterId[character.id] ??
      buildStoryThreadSnapshot(character);
    const existingThread =
      messagesByCharacterId[character.id] ??
      existingSnapshot?.messages ??
      buildInitialThread(character);
    const optimisticThread = [
      ...existingThread,
      buildUserMessage(trimmed),
    ];
    const storyRequest = buildStoryChatRequest(
      character,
      trimmed,
      existingSnapshot,
    );

    if (!storyRequest) {
      return;
    }

    const optimisticSnapshot = buildNextStoryThreadSnapshot(
      existingSnapshot,
      character,
      optimisticThread,
      null,
      storyRequest,
    );
    let shouldClearDraft = true;

    setMessagesByCharacterId((current) => ({
      ...current,
      [character.id]: optimisticThread,
    }));
    setStoryTypingCharacterId(character.id);
    setComposerTrayOpen(false);
    setSurfaceMode('chat');

    try {
      if (!session) {
        throw new RemoteTokenConsumeError(
          'UNAUTHORIZED',
          '로그인이 필요해요. 로그인 후 다시 이어서 보내주세요.',
        );
      }

      await consumeRemoteTokens(session, {
        fortuneType: 'character-chat',
        referenceId: `story:${character.id}`,
      });

      syncRemoteProfile().catch((error: unknown) => {
        captureError(error, {
          surface: 'chat:story-pilot-sync-premium-after-consume',
        }).catch(() => undefined);
      });

      if (optimisticSnapshot) {
        setStoryThreadSnapshotsByCharacterId((current) => ({
          ...current,
          [character.id]: optimisticSnapshot,
        }));

        await saveStoryThreadSnapshot(optimisticSnapshot).catch((error: unknown) => {
          captureError(error, {
            surface: 'chat:story-pilot-save-optimistic',
          }).catch(() => undefined);
        });
      }

      await recordChatIntent({
        characterId: character.id,
        fortuneType: activeFortuneType,
        incrementMessages: true,
      }).catch((error: unknown) => {
        captureError(error, {
          surface: 'chat:story-pilot-record-intent',
        }).catch(() => undefined);
      });

      const response = await invokeStoryChat(character, trimmed, optimisticSnapshot);
      const assistantText = response.response.trim();
      const assistantMessage = buildAssistantTextMessage(assistantText);
      const nextMessages = [...optimisticThread, assistantMessage];
      const nextSnapshot = buildNextStoryThreadSnapshot(
        optimisticSnapshot,
        character,
        nextMessages,
        response,
        storyRequest,
      );

      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: nextMessages,
      }));

      if (nextSnapshot) {
        setStoryThreadSnapshotsByCharacterId((current) => ({
          ...current,
          [character.id]: nextSnapshot,
        }));

        await saveStoryThreadSnapshot(nextSnapshot).catch((error: unknown) => {
          captureError(error, { surface: 'chat:story-pilot-save-final' }).catch(
            () => undefined,
          );
        });
      }
    } catch (error) {
      if (error instanceof RemoteTokenConsumeError) {
        shouldClearDraft = false;
        setDraft(trimmed);
        setMessagesByCharacterId((current) => ({
          ...current,
          [character.id]: existingThread,
        }));
        setStoryThreadSnapshotsByCharacterId((current) => ({
          ...current,
          [character.id]: existingSnapshot,
        }));

        await syncRemoteProfile().catch((syncError: unknown) => {
          captureError(syncError, {
            surface: 'chat:story-pilot-sync-premium-after-consume-error',
          }).catch(() => undefined);
        });

        if (error.code === 'INSUFFICIENT_TOKENS') {
          router.push('/premium');
          return;
        }

        if (error.code === 'UNAUTHORIZED') {
          routeToSignup();
          return;
        }

        await captureError(error, {
          surface: 'chat:story-pilot-consume-tokens',
        }).catch(() => undefined);

        return;
      }

      await captureError(error, { surface: 'chat:story-pilot-send' }).catch(
        () => undefined,
      );

      const fallbackMessage = buildStoryFallbackAssistantMessage(character);
      const nextMessages = [...optimisticThread, fallbackMessage];
      const nextSnapshot = buildNextStoryThreadSnapshot(
        optimisticSnapshot,
        character,
        nextMessages,
        null,
        storyRequest,
      );

      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: nextMessages,
      }));

      if (nextSnapshot) {
        setStoryThreadSnapshotsByCharacterId((current) => ({
          ...current,
          [character.id]: nextSnapshot,
        }));

        await saveStoryThreadSnapshot(nextSnapshot).catch((saveError: unknown) => {
          captureError(saveError, {
            surface: 'chat:story-pilot-save-fallback',
          }).catch(() => undefined);
        });
      }
    } finally {
      setStoryTypingCharacterId((current) =>
        current === character.id ? null : current,
      );
      if (shouldClearDraft) {
        setDraft('');
      }
    }
  }

  function handleSendDraft() {
    const trimmed = draft.trim();

    if (!trimmed) {
      if (selectedCharacterActions.length > 0) {
        handleActionPress(selectedCharacterActions[0].fortuneType);
        return;
      }

      const followUpText =
        selectedStorySnapshot?.followUpHint ??
        selectedStorySnapshot?.romanceState.dailyHook ??
        '이어서 이야기해볼래요.';

      if (
        selectedCharacter.kind === 'story' &&
        isStoryRomancePilotCharacterId(selectedCharacter.id)
      ) {
        void sendStoryPilotMessage(selectedCharacter, followUpText);
        return;
      }

      appendMessages(selectedCharacter, [
        buildUserMessage(followUpText),
        buildDraftReply(selectedCharacter, followUpText),
      ]);
      setSurfaceMode('chat');
      recordChatIntent({
        characterId: selectedCharacter.id,
        fortuneType: activeFortuneType,
        incrementMessages: true,
      }).catch((error) => {
        captureError(error, { surface: 'chat:record-empty-draft-fallback' }).catch(
          () => undefined,
        );
      });
      return;
    }

    if (
      selectedCharacter.kind === 'story' &&
      isStoryRomancePilotCharacterId(selectedCharacter.id)
    ) {
      void sendStoryPilotMessage(selectedCharacter, trimmed);
      return;
    }

    appendMessages(selectedCharacter, [
      buildUserMessage(trimmed),
      buildDraftReply(selectedCharacter, trimmed),
    ]);
    setComposerTrayOpen(false);
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
      void completeSurvey(selectedCharacter, completed);
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
        displayName: mobileAppState.profile.displayName || undefined,
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

  async function appendResolvedFortuneResult(
    character: ChatCharacterSpec,
    fortuneType: FortuneTypeId,
  ) {
    const resolved = await resolveFortuneResultMessage(
      fortuneType,
      buildResultContext(character),
      'chat:begin-runtime',
    );

    if (!resolved) {
      return;
    }

    if (resolved.kind === 'text') {
      appendMessages(character, [resolved.message]);
      if (resolved.routeToPremium) {
        router.push('/premium');
      }
      return;
    }

    appendMessages(character, [
      buildAssistantTextMessage('좋아요. 결과를 같은 대화 안에 바로 붙여드릴게요.'),
      resolved.message,
    ]);
  }

  async function resolveFortuneResultMessage(
    fortuneType: FortuneTypeId,
    context: ReturnType<typeof buildResultContext>,
    surface: string,
  ): Promise<ResolvedFortuneMessage | null> {
    const spec = fortuneTypesById[fortuneType];
    if (spec.isLocalOnly || !spec.endpoint) {
      const embeddedResult = buildEmbeddedResultMessage(fortuneType, context);
      if (!embeddedResult || embeddedResult.kind !== 'embedded-result') {
        return null;
      }

      return {
        kind: 'result',
        message: embeddedResult,
      };
    }

    try {
      const outcome = await resolveFortuneRuntimeOutcome({
        fortuneType,
        context,
        session,
        premiumState: mobileAppState.premium,
        syncRemoteProfile,
      });

      if (outcome.kind === 'success') {
        return {
          kind: 'result',
          message: buildEmbeddedResultMessageFromPayload(outcome.payload),
        };
      }

      if (outcome.kind === 'failed' && outcome.error) {
        await captureError(outcome.error, { surface }).catch(() => undefined);
      }

      return {
        kind: 'text',
        message: buildAssistantTextMessage(outcome.message),
        routeToPremium:
          outcome.kind === 'blocked' && outcome.routeToPremium === true,
        routeToSignup:
          outcome.kind === 'blocked' && outcome.reason === 'login-required',
      };
    } catch (error) {
      await captureError(error, { surface }).catch(() => undefined);
      return {
        kind: 'text',
        message: buildAssistantTextMessage(
          '실제 운세 결과를 불러오지 못했어요. 잠시 후 다시 시도해주세요.',
        ),
      };
    }
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

  async function handleSocialAuthStart(providerId: SocialAuthProviderId) {
    try {
      setActiveProviderId(providerId);
      setAuthMessage(null);

      if (!isSupported(providerId)) {
        setAuthMessage(
          `${socialAuthProviderLabelById[providerId]} 로그인이 아직 준비되지 않았습니다.`,
        );
        return;
      }

      const result = await startSocialAuth(providerId, '/chat');

      if (result.status === 'started') {
        setAuthMessage(
          `${socialAuthProviderLabelById[providerId]} 로그인을 진행하고 있습니다. 잠시만 기다려 주세요.`,
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
            계정 상태와 준비된 정보를 확인한 뒤, 열어야 할 화면을 정하고 있어요.
          </AppText>
        </Card>
      </Screen>
    );
  }

  return (
    <Screen
      contentBottomInset={
        gate === 'ready' && surfaceMode === 'list' && activeTab === 'story'
          ? 88
          : 0
      }
      onScrollContentSizeChange={() => {
        if (gate === 'ready' && surfaceMode === 'chat') {
          scrollChatToBottom(true);
        }
      }}
      scrollViewRef={chatScrollRef}
      header={
        gate === 'ready' && surfaceMode === 'chat' ? (
          <ActiveCharacterChatHeader
            character={selectedCharacter}
            onBack={() => {
              setSurfaceMode('list');
              setActiveFortuneType(null);
            }}
            onOpenProfile={() =>
              router.push({
                pathname: '/character/[id]',
                params: { id: selectedCharacter.id, returnTo: '/chat' },
              })
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
              onPickPhoto={handleSurveyPickPhoto}
              onPickSingle={(value) => submitSurveyAnswer(value)}
              onSkip={handleSurveySkip}
              onSubmitSelection={handleSurveySubmitSelection}
              onSubmitText={handleSurveySubmitText}
              onToggleSelection={handleSurveyToggleSelection}
              selections={surveySelections}
              step={currentSurveyStep.step}
            />
          ) : (
            <ActiveChatComposer
              draft={draft}
              onDraftChange={setDraft}
              onOpenPhotoPicker={handleOpenPhotoPicker}
              onPickAction={handleActionPress}
              onSend={handleSendDraft}
              onStartVoiceInput={handleStartVoiceInput}
              onToggleTray={() => setComposerTrayOpen((current) => !current)}
              quickActions={selectedCharacterActions}
              trayOpen={composerTrayOpen}
              sendDisabled={selectedCharacter.kind === 'story' && storySendInFlight}
              auxiliaryAction={{
                label: '프로필 보기',
                onPress: () =>
                  router.push({
                    pathname: '/character/[id]',
                    params: { id: selectedCharacter.id, returnTo: '/chat' },
                  }),
              }}
            />
          )
        ) : undefined
      }
      overlay={
        gate === 'ready' && surfaceMode === 'list' && activeTab === 'story' ? (
          <View pointerEvents="box-none" style={{ alignItems: 'flex-end' }}>
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
              ? `${socialAuthProviderLabelById[activeProviderId]} 연결을 준비 중입니다.`
              : authMessage
          }
          onApple={() => void handleSocialAuthStart('apple')}
          onBrowse={() => void handleBrowse()}
          onGoogle={() => void handleSocialAuthStart('google')}
          onKakao={() => void handleSocialAuthStart('kakao')}
          onNaver={() => void handleSocialAuthStart('naver')}
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
            isTyping={selectedStoryIsTyping}
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
            characters={firstRunCharacters}
            lastFortuneType={mobileAppState.chat.lastFortuneType}
            onChangeTab={setActiveTab}
            onOpenProfile={() => router.push('/profile')}
            onOpenRecentResult={handleOpenRecentResult}
            onPickCharacterAction={handleCharacterActionPress}
            onSelectCharacter={handleCharacterSelect}
            selectedCharacterId={selectedCharacter.id}
          />
        )
      ) : null}
    </Screen>
  );
}
