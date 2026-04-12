import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

import { router, useLocalSearchParams, type Href } from 'expo-router';
import { type FortuneTypeId } from '@fortune/product-contracts';
import { Alert, Dimensions, ScrollView, View } from 'react-native';

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
import type { ActiveChatSurvey } from '../features/chat-survey/types';
import { fetchEmbeddedEdgeResultPayload } from '../features/chat-results/edge-runtime';
import { resolveResultKindFromFortuneType } from '../features/fortune-results/mapping';
import { captureError } from '../lib/error-reporting';
import {
  buildAssistantTextMessage,
  buildEmbeddedResultMessage,
  buildEmbeddedResultMessageFromPayload,
  buildFortuneCookieMessage,
  buildSajuPreviewMessage,
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
  buildChatCharactersWithCustomFriends,
  buildStoryCharactersWithCustomFriends,
  chatCharacters,
  findChatCharacterById,
  fortuneChatCharacters,
  isCustomFriendCharacter,
  isFortuneChatCharacter,
  storyChatCharacters,
  type ChatCharacterSpec,
  type ChatCharacterTab,
} from '../lib/chat-characters';
import { supabase } from '../lib/supabase';
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
    session,
    status,
  } = useAppBootstrap();
  const {
    state: mobileAppState,
    recordChatIntent,
    saveProfile,
    syncRemoteProfile,
  } = useMobileAppState();
  const { createdFriends, resetDraft, removeFriend } = useFriendCreation();
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
  const hydratedCharacterIdsRef = useRef<Set<string>>(new Set());

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

  // Hydrate a single story character's conversation from remote
  const hydrateStoryCharacter = useCallback(
    async (characterId: string) => {
      if (hydratedCharacterIdsRef.current.has(characterId)) {
        return;
      }

      if (!isStoryRomancePilotCharacterId(characterId)) {
        return;
      }

      hydratedCharacterIdsRef.current.add(characterId);

      try {
        const snapshot = await loadStoryThreadSnapshot(characterId);

        if (!snapshot) {
          return;
        }

        setMessagesByCharacterId((current) => ({
          ...current,
          [characterId]: snapshot.messages,
        }));
        setStoryThreadSnapshotsByCharacterId((current) => ({
          ...current,
          [characterId]: snapshot,
        }));
      } catch (error) {
        // Remove from set so it can be retried
        hydratedCharacterIdsRef.current.delete(characterId);
        await captureError(error, {
          surface: 'chat:hydrate-story-character',
        }).catch(() => undefined);
      }
    },
    [],
  );

  // On gate ready: only hydrate the currently selected character (not all)
  useEffect(() => {
    if (gate !== 'ready') {
      return;
    }

    const hydrationKey = session?.user.id ?? 'guest';
    if (hydratedStoryThreadsKeyRef.current !== hydrationKey) {
      hydratedStoryThreadsKeyRef.current = hydrationKey;
      hydratedCharacterIdsRef.current = new Set();
    }

    // Resolve which character is initially selected
    const initialCharacterId =
      directCharacterId ??
      mobileAppState.chat.selectedCharacterId ??
      storyChatCharacters[0]?.id;

    if (initialCharacterId && isStoryRomancePilotCharacterId(initialCharacterId)) {
      void hydrateStoryCharacter(initialCharacterId);
    }
  }, [gate, session?.user.id, directCharacterId, mobileAppState.chat.selectedCharacterId, hydrateStoryCharacter]);

  const allStoryCharacters = useMemo(
    () => buildStoryCharactersWithCustomFriends(createdFriends),
    [createdFriends],
  );
  const allChatCharacters = useMemo(
    () => buildChatCharactersWithCustomFriends(createdFriends),
    [createdFriends],
  );
  const highlightedExpert = activeFortuneType
    ? fortuneChatCharacters.find((character) =>
        character.specialties.includes(activeFortuneType),
      )
    : undefined;
  const tabCharacters =
    activeTab === 'story' ? allStoryCharacters : fortuneChatCharacters;
  const defaultCharacter =
    highlightedExpert ??
    (activeTab === 'fortune'
      ? fortuneChatCharacters[0]
      : tabCharacters[0]) ??
    allStoryCharacters[0] ??
    allChatCharacters[0];
  const selectedCharacter = useMemo(() => {
    const targetId =
      selectedCharacterId ??
      directCharacterId ??
      mobileAppState.chat.selectedCharacterId;

    return (
      findChatCharacterById(targetId, createdFriends) ??
      highlightedExpert ??
      defaultCharacter
    );
  }, [
    createdFriends,
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

  // Lazy-load story conversation when user switches to a character not yet hydrated
  useEffect(() => {
    if (gate !== 'ready') {
      return;
    }

    if (
      selectedCharacter.kind === 'story' &&
      isStoryRomancePilotCharacterId(selectedCharacter.id)
    ) {
      void hydrateStoryCharacter(selectedCharacter.id);
    }
  }, [gate, hydrateStoryCharacter, selectedCharacter.id, selectedCharacter.kind]);

  useEffect(() => {
    if (createdFriends.length === 0) {
      return;
    }

    const newEntries: Record<string, ChatShellMessage[]> = {};

    for (const friend of createdFriends) {
      if (!messagesByCharacterId[friend.id]) {
        const character = findChatCharacterById(friend.id, createdFriends);

        if (character) {
          const snapshot = buildStoryThreadSnapshot(character);
          newEntries[friend.id] =
            snapshot?.messages ?? buildInitialThread(character);
        }
      }
    }

    if (Object.keys(newEntries).length > 0) {
      setMessagesByCharacterId((current) => ({
        ...current,
        ...newEntries,
      }));
    }
  }, [createdFriends, messagesByCharacterId]);

  const selectedThread = messagesByCharacterId[selectedCharacter.id] ?? [];
  const selectedStorySnapshot =
    storyThreadSnapshotsByCharacterId[selectedCharacter.id] ?? null;
  const [fortuneTypingCharacterId, setFortuneTypingCharacterId] = useState<string | null>(null);
  const selectedStoryIsTyping = storyTypingCharacterId === selectedCharacter.id;
  const selectedFortuneIsTyping = fortuneTypingCharacterId === selectedCharacter.id;
  const storySendInFlight = storyTypingCharacterId !== null;
  const activeSurvey = activeSurveysByCharacterId[selectedCharacter.id] ?? null;
  const currentSurveyStep = activeSurvey
    ? getCurrentSurveyStep(activeSurvey)
    : null;

  const scrollTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const prevContentHeightRef = useRef(0);
  const scrollViewHeightRef = useRef(Dimensions.get('window').height * 0.7);

  function scrollChatToBottom(animated = true) {
    if (scrollTimerRef.current) {
      clearTimeout(scrollTimerRef.current);
    }
    scrollTimerRef.current = setTimeout(() => {
      requestAnimationFrame(() => {
        chatScrollRef.current?.scrollToEnd({ animated });
      });
    }, 100);
  }

  function scrollChatOnContentGrow(contentHeight: number) {
    const prevHeight = prevContentHeightRef.current;
    const viewportHeight = scrollViewHeightRef.current;
    prevContentHeightRef.current = contentHeight;

    if (prevHeight <= 0) return;

    const addedHeight = contentHeight - prevHeight;
    if (addedHeight <= 0) return;

    if (scrollTimerRef.current) {
      clearTimeout(scrollTimerRef.current);
    }

    if (addedHeight > viewportHeight * 0.8) {
      // Large content (fortune result card): scroll to show its top
      scrollTimerRef.current = setTimeout(() => {
        requestAnimationFrame(() => {
          chatScrollRef.current?.scrollTo({ y: prevHeight - 80, animated: true });
        });
      }, 120);
    } else {
      // Small content (regular message): scroll to end
      scrollTimerRef.current = setTimeout(() => {
        requestAnimationFrame(() => {
          chatScrollRef.current?.scrollToEnd({ animated: true });
        });
      }, 100);
    }
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

  function beginFortuneRuntime(
    character: ChatCharacterSpec,
    fortuneType: FortuneTypeId,
  ) {
    // Fortune cookie is local-only — no survey, no API call
    if (fortuneType === 'fortune-cookie') {
      setActiveSurvey(character.id, null);
      appendMessages(character, [
        buildAssistantTextMessage(
          '오늘의 쿠키를 준비했어요. 꾹 눌러서 깨뜨려 보세요!',
        ),
        buildFortuneCookieMessage(),
      ]);
      return true;
    }

    // Blood type already known — skip survey, go straight to result
    if (fortuneType === 'blood-type' && mobileAppState.profile.bloodType) {
      setActiveSurvey(character.id, null);
      void appendResolvedFortuneResult(character, fortuneType);
      return true;
    }

    const definition = getChatSurveyDefinition(fortuneType);

    if (definition) {
      // 전통사주: 설문 전에 사주 비주얼 카드를 먼저 보여줌
      if (fortuneType === 'traditional-saju' && session && mobileAppState.profile.birthDate) {
        void (async () => {
          try {
            const { getSajuData: fetchSaju } = await import('../lib/saju-remote');
            setFortuneTypingCharacterId(character.id);
            const sajuData = await fetchSaju(
              session,
              mobileAppState.profile.birthDate,
              mobileAppState.profile.birthTime,
            );
            setFortuneTypingCharacterId(null);

            const userName =
              mobileAppState.profile.displayName ||
              (session.user.user_metadata.name as string | undefined) ||
              '회원';

            appendMessages(character, [
              buildSajuPreviewMessage(userName, sajuData),
            ]);
          } catch {
            setFortuneTypingCharacterId(null);
          }
        })();
      }

      // Celebrity: show favorites hint before survey
      if (fortuneType === 'celebrity') {
        import('../lib/favorite-celebrities').then(({ loadFavoriteCelebrities }) =>
          loadFavoriteCelebrities().then((favs) => {
            if (favs.length > 0) {
              const names = favs.slice(0, 5).map((f) => f.name).join(', ');
              appendMessages(character, [
                buildAssistantTextMessage(`최근 본 연예인: ${names}\n이름을 입력하거나 새로운 연예인을 검색해보세요.`),
              ]);
            }
          }),
        ).catch(() => undefined);
      }

      const survey = startChatSurvey(definition);
      const question =
        resolveSurveyQuestion(survey, {
          mbti: mobileAppState.profile.mbti || undefined,
        }) ?? definition.steps[0]?.question;

      setActiveSurvey(character.id, survey);

      if (question) {
        // 전통사주일 때는 사주카드 뒤에 설문 질문이 약간 지연되어 보이도록
        if (fortuneType === 'traditional-saju' && session && mobileAppState.profile.birthDate) {
          setTimeout(() => {
            appendMessages(character, [buildAssistantTextMessage(question)]);
          }, 1500);
        } else {
          appendMessages(character, [buildAssistantTextMessage(question)]);
        }
      }

      return true;
    }

    if (!resolveResultKindFromFortuneType(fortuneType)) {
      return false;
    }

    // Dedup: check if this fortune type already has a recent result
    const existing = findMostRecentEmbeddedResult(character.id, fortuneType);
    if (existing) {
      reopenFortuneResult(
        character,
        fortuneType,
        '이전 결과를 다시 보여드릴게요.',
      );
      return true;
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
    setFortuneTypingCharacterId(character.id);

    // Save blood type to profile for next time
    if (completed.fortuneType === 'blood-type' && completed.answers.bloodType) {
      saveProfile({ bloodType: String(completed.answers.bloodType) }).catch(
        () => undefined,
      );
    }

    // Auto-save celebrity to favorites
    if (completed.fortuneType === 'celebrity' && completed.answers.celebrityName) {
      import('../lib/favorite-celebrities').then(({ saveFavoriteCelebrity }) =>
        saveFavoriteCelebrity({
          name: String(completed.answers.celebrityName),
          addedAt: new Date().toISOString(),
          lastMode: String(completed.answers.mode ?? ''),
          lastReason: String(completed.answers.reason ?? ''),
        }),
      ).catch(() => undefined);
    }

    try {
      if (session) {
        await consumeRemoteTokens(session, {
          fortuneType: completed.fortuneType,
          referenceId: `fortune:${character.id}:${completed.fortuneType}`,
        });
      }

      const embeddedResult = await resolveFortuneResultMessage(
        completed.fortuneType,
        buildResultContext(character, completed.answers),
        'chat:complete-survey',
      );

      if (!embeddedResult) {
        return;
      }

      appendMessages(character, [
        buildAssistantTextMessage(
          definition?.submitReply ??
            '좋아요. 결과를 같은 채팅 안에서 바로 보여드릴게요.',
        ),
        embeddedResult,
      ]);
    } catch (error) {
      if (error instanceof RemoteTokenConsumeError) {
        appendMessages(character, [
          buildAssistantTextMessage(
            error.message || '토큰이 부족해요. 토큰을 충전한 뒤 다시 시도해주세요.',
          ),
        ]);
        return;
      }
      throw error;
    } finally {
      setFortuneTypingCharacterId(null);
    }
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
    const character = findChatCharacterById(characterId, createdFriends);

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
    const character = findChatCharacterById(characterId, createdFriends) ?? selectedCharacter;
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
    // Photo attachment — silently ignore until feature is implemented
  }

  function handleStartVoiceInput() {
    let SpeechModule: {
      start: (o: { lang: string; interimResults: boolean }) => void;
      stop: () => void;
      requestPermissionsAsync: () => Promise<{ granted: boolean }>;
      addListener: (event: string, handler: (data: unknown) => void) => { remove: () => void };
    } | null = null;

    try {
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const mod = require('expo-speech-recognition');
      SpeechModule = mod.ExpoSpeechRecognitionModule ?? null;
    } catch {
      // not available
    }

    if (!SpeechModule) {
      // Voice input module unavailable — silently return
      return;
    }

    void (async () => {
      try {
        const { granted } = await SpeechModule!.requestPermissionsAsync();
        if (!granted) {
          Alert.alert('마이크 권한', '음성 입력을 위해 마이크 권한이 필요합니다.');
          return;
        }

        const resultSub = SpeechModule!.addListener('result', (event: unknown) => {
          const e = event as { results?: Array<{ transcript?: string }> };
          const transcript = e.results?.[0]?.transcript;
          if (transcript) {
            setDraft((prev) => prev ? `${prev} ${transcript}` : transcript);
          }
        });

        const endSub = SpeechModule!.addListener('end', () => {
          resultSub.remove();
          endSub.remove();
          errorSub.remove();
        });

        const errorSub = SpeechModule!.addListener('error', () => {
          resultSub.remove();
          endSub.remove();
          errorSub.remove();
        });

        SpeechModule!.start({ lang: 'ko-KR', interimResults: false });
      } catch {
        // ignore
      }
    })();
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
      findChatCharacterById(recentFortuneCharacterId, createdFriends) ?? selectedCharacter;
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
          setAuthMessage(error.message);
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

  async function sendCharacterChatMessage(
    character: ChatCharacterSpec,
    text: string,
  ) {
    const trimmed = text.trim();

    if (!trimmed) {
      return;
    }

    const existingThread =
      messagesByCharacterId[character.id] ?? buildInitialThread(character);
    const optimisticThread = [
      ...existingThread,
      buildUserMessage(trimmed),
    ];
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
        referenceId: `character:${character.id}`,
      });

      syncRemoteProfile().catch((error: unknown) => {
        captureError(error, {
          surface: 'chat:character-chat-sync-premium-after-consume',
        }).catch(() => undefined);
      });

      await recordChatIntent({
        characterId: character.id,
        fortuneType: activeFortuneType,
        incrementMessages: true,
      }).catch((error: unknown) => {
        captureError(error, {
          surface: 'chat:character-chat-record-intent',
        }).catch(() => undefined);
      });

      if (!supabase) {
        throw new Error('Supabase is not configured.');
      }

      const customFriend = isCustomFriendCharacter(character.id)
        ? createdFriends.find((f) => f.id === character.id) ?? null
        : null;

      const recentMessages = optimisticThread
        .filter((m): m is ChatShellTextMessage => m.kind === 'text')
        .slice(-10)
        .map((m) => ({
          role: m.sender === 'user' ? ('user' as const) : ('assistant' as const),
          content: m.text,
        }));

      const { data, error } = await supabase.functions.invoke('character-chat', {
        body: {
          characterId: character.id,
          characterName: character.name,
          characterTraits: character.shortDescription,
          systemPrompt: customFriend
            ? `당신은 "${character.name}"입니다. ${customFriend.scenario ? `상황: ${customFriend.scenario}. ` : ''}성격: ${customFriend.personalityTags.join(', ')}. ${customFriend.memoryNote ? `기억: ${customFriend.memoryNote}. ` : ''}스타일: ${customFriend.stylePreset || '자연스러운 대화'}. 사용자와 ${customFriend.relationship === 'friend' ? '친구' : customFriend.relationship === 'crush' ? '썸 상대' : customFriend.relationship === 'partner' ? '연인' : '동료'} 관계예요. 짧고 자연스럽게, 캐릭터답게 대화하세요.`
            : `당신은 "${character.name}"입니다. ${character.shortDescription}. 짧고 자연스럽게, 캐릭터답게 대화하세요.`,
          messages: recentMessages,
          userMessage: trimmed,
          userName:
            (session.user.user_metadata.name as string | undefined) ||
            (session.user.user_metadata.full_name as string | undefined) ||
            mobileAppState.profile.displayName ||
            'user',
        },
      });

      if (error) {
        throw error;
      }

      const payload = data as { response?: string; success?: boolean; error?: string } | null;
      if (!payload?.response || (payload.success === false)) {
        throw new Error(payload?.error ?? 'Character chat response is empty.');
      }

      const assistantText = payload.response.trim();
      const assistantMessage = buildAssistantTextMessage(assistantText);
      const nextMessages = [...optimisticThread, assistantMessage];

      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: nextMessages,
      }));
    } catch (error) {
      if (error instanceof RemoteTokenConsumeError) {
        shouldClearDraft = false;
        setDraft(trimmed);
        setMessagesByCharacterId((current) => ({
          ...current,
          [character.id]: existingThread,
        }));

        await syncRemoteProfile().catch((syncError: unknown) => {
          captureError(syncError, {
            surface: 'chat:character-chat-sync-premium-after-consume-error',
          }).catch(() => undefined);
        });

        if (error.code === 'INSUFFICIENT_TOKENS') {
          router.push('/premium');
          return;
        }

        if (error.code === 'UNAUTHORIZED') {
          setAuthMessage(error.message);
          return;
        }

        await captureError(error, {
          surface: 'chat:character-chat-consume-tokens',
        }).catch(() => undefined);

        return;
      }

      await captureError(error, { surface: 'chat:character-chat-send' }).catch(
        () => undefined,
      );

      const fallbackMessage = buildDraftReply(character, trimmed);
      const nextMessages = [...optimisticThread, fallbackMessage];

      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: nextMessages,
      }));
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

      if (selectedCharacter.kind === 'story') {
        void sendCharacterChatMessage(selectedCharacter, followUpText);
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

    if (selectedCharacter.kind === 'story') {
      void sendCharacterChatMessage(selectedCharacter, trimmed);
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
        displayName:
          mobileAppState.profile.displayName ||
          (session?.user.user_metadata.name as string | undefined) ||
          (session?.user.user_metadata.full_name as string | undefined) ||
          undefined,
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
    setFortuneTypingCharacterId(character.id);
    try {
      const embeddedResult = await resolveFortuneResultMessage(
        fortuneType,
        buildResultContext(character),
        'chat:begin-runtime',
      );

      if (!embeddedResult) {
        return;
      }

      appendMessages(character, [
        buildAssistantTextMessage('좋아요. 결과를 같은 대화 안에 바로 붙여드릴게요.'),
        embeddedResult,
      ]);
    } finally {
      setFortuneTypingCharacterId(null);
    }
  }

  async function resolveFortuneResultMessage(
    fortuneType: FortuneTypeId,
    context: ReturnType<typeof buildResultContext>,
    surface: string,
  ) {
    try {
      const payload = await fetchEmbeddedEdgeResultPayload(
        fortuneType,
        context,
        {
          userId: session?.user.id ?? null,
        },
      );

      if (payload) {
        return buildEmbeddedResultMessageFromPayload(payload);
      }
    } catch (error) {
      await captureError(error, { surface }).catch(() => undefined);
    }

    return buildEmbeddedResultMessage(fortuneType, context);
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
      onScrollContentSizeChange={(_w, h) => {
        if (gate === 'ready' && surfaceMode === 'chat') {
          scrollChatOnContentGrow(h);
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
              onPickSingle={(value) => submitSurveyAnswer(value)}
              onSkip={handleSurveySkip}
              onSubmitSelection={handleSurveySubmitSelection}
              onSubmitText={handleSurveySubmitText}
              onToggleSelection={handleSurveyToggleSelection}
              selections={surveySelections}
              step={currentSurveyStep.step}
              surveyAnswers={activeSurvey?.answers}
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
          onEmail={() => router.push('/auth/email')}
          onPhone={() => router.push('/auth/phone')}
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
            isTyping={selectedStoryIsTyping || selectedFortuneIsTyping}
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
            onDeleteFriend={(id) => {
              Alert.alert(
                '캐릭터 삭제',
                '이 캐릭터를 삭제하시겠어요? 대화 기록도 사라집니다.',
                [
                  { text: '취소', style: 'cancel' },
                  {
                    text: '삭제',
                    style: 'destructive',
                    onPress: () => void removeFriend(id),
                  },
                ],
              );
            }}
            onPickCharacterAction={handleCharacterActionPress}
            onSelectCharacter={handleCharacterSelect}
            selectedCharacterId={selectedCharacter.id}
          />
        )
      ) : null}
    </Screen>
  );
}
