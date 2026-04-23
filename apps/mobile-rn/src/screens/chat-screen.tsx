import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

import {
  router,
  useFocusEffect,
  useLocalSearchParams,
  type Href,
} from 'expo-router';
import { type FortuneTypeId } from '@fortune/product-contracts';
import { Alert, Dimensions, Keyboard, Modal, Pressable, ScrollView, TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { OnDeviceTransitionToast } from '../components/on-device-transition-toast';
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
  buildCharacterListMeta,
  type CharacterListRowMeta,
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
  buildUserImageMessage,
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
import {
  getChatLastSeenByCharacterId,
  setChatLastSeenForCharacter,
} from '../lib/storage';
import { getSecureItem, setSecureItem } from '../lib/secure-store-storage';
import { supabase } from '../lib/supabase';
import {
  buildNextStoryThreadSnapshot,
  buildStoryFallbackAssistantMessage,
  buildStoryChatRequest,
  buildStoryThreadSnapshot,
  loadCharacterConversation,
  loadStoryThreadSnapshot,
  saveCharacterConversation,
  saveStoryThreadSnapshot,
  type StoryChatThreadSnapshot,
} from '../lib/story-chat-runtime';
import {
  OnDeviceNotReadyError,
  cloudChatProvider,
  resolveChatProvider,
} from '../lib/chat-provider';
import { onDeviceLLMEngine } from '../lib/on-device-llm';
import { setAppIconBadgeCount } from '../lib/push-notifications';
import { useBlockedCharacterIds } from '../lib/character-blocks';
import { isStoryRomancePilotCharacterId } from '../lib/story-romance-pilots';
import {
  consumeRemoteTokens,
  RemoteTokenConsumeError,
} from '../lib/premium-remote';
import {
  socialAuthProviderLabelById,
  type SocialAuthProviderId,
} from '../lib/social-auth';
import {
  loadCharacterPersona,
  saveCharacterPersona,
} from '../lib/character-persona-store';
import { fortuneTheme } from '../lib/theme';
import { loveHeartbeat, scoreReveal, tapLight } from '../lib/haptics';
import { pickPresenceLine } from '../lib/presence-lines';
import { useVoiceInput } from '../lib/use-voice-input';
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

const PENDING_SENDS_STORAGE_KEY = 'fortune.pending-sends.v1';

/**
 * 미읽음 user kind='text' 메시지 전부에 `readAt`을 도장찍어 돌려준다.
 * AI 응답 시점에 호출되므로, 그 전까지 쌓인 모든 유저 메시지를 한꺼번에
 * 읽음 처리 (연속으로 보낸 경우에도 "1" 배지가 남지 않도록).
 */
function markLatestUserMessageAsRead(
  messages: ChatShellMessage[],
  readAt: string = new Date().toISOString(),
): ChatShellMessage[] {
  let patched = false;
  const next = messages.map((message) => {
    if (
      message.kind === 'text' &&
      message.sender === 'user' &&
      !message.readAt
    ) {
      patched = true;
      return { ...message, readAt };
    }
    return message;
  });
  return patched ? next : messages;
}

function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function randomInRange(minMs: number, maxMs: number): number {
  return minMs + Math.floor(Math.random() * Math.max(1, maxMs - minMs + 1));
}

/**
 * 두 메시지 리스트가 id 기준으로 같은지 얕은 비교. hydrate 결과가 캐시와
 * 동일할 때 불필요한 re-render(= old→new 플래시)를 막기 위해 사용.
 */
function isSameMessageList(
  a: ChatShellMessage[] | undefined,
  b: ChatShellMessage[] | undefined,
): boolean {
  if (a === b) return true;
  if (!a || !b) return false;
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) {
    if (a[i]?.id !== b[i]?.id) return false;
  }
  return true;
}

/**
 * 원격 hydrate 결과를 로컬 state에 적용할지 판단.
 *
 * 핵심 원칙: **원격이 더 짧으면 덮어쓰지 않는다**.
 *   → 유저가 방금 보낸 메시지가 remote save 전파되기 전에 focus 재하이드레이션이
 *     트리거되면 remote는 "이전 상태"를 반환한다. 이를 그대로 set하면 방금 보낸
 *     메시지가 사라진다. 즉 truncate race를 방지.
 *
 * 규칙:
 *   - 로컬 없음 → 원격 적용
 *   - 원격 비어있음 → 로컬 유지
 *   - 원격이 로컬보다 짧음 → 로컬 유지 (in-flight 로컬 쓰기 보존)
 *   - 길이 같음 → 마지막 메시지 id 다르면 원격 적용 (server authority)
 *   - 원격이 길면 적용 (서버가 proactive message 등 추가)
 */
function shouldAcceptRemoteMessages(
  local: ChatShellMessage[] | undefined,
  remote: ChatShellMessage[],
): boolean {
  if (!local || local.length === 0) return remote.length > 0;
  if (remote.length === 0) return false;
  if (remote.length < local.length) return false;
  if (remote.length === local.length) {
    return local[local.length - 1]?.id !== remote[remote.length - 1]?.id;
  }
  return true;
}

export function ChatScreen() {
  const params = useLocalSearchParams<{ characterId?: string | string[]; showList?: string | string[] }>();
  const directCharacterId = readSearchParam(params.characterId);
  const forceListMode = readSearchParam(params.showList) === '1';
  const directCharacter = findChatCharacterById(directCharacterId);
  const {
    cachedCharacterConversations,
    completeOnboarding,
    consumePendingChatFortuneType,
    consumePendingMySajuContext,
    gate,
    markGuestBrowse,
    onboardingProgress,
    pendingChatFortuneType,
    pendingMySajuContext,
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
  // 사진 첨부 미리보기 — 사용자가 "보내기"를 누를 때까지 대기. 캐릭터별로 관리.
  // 값이 있으면 composer 상단에 썸네일이 보이고 X로 취소 가능.
  const [pendingImageByCharacterId, setPendingImageByCharacterId] = useState<
    Record<string, { uri: string; base64?: string; mimeType?: string }>
  >({});
  const [personaModalOpen, setPersonaModalOpen] = useState(false);
  const [personaDraft, setPersonaDraft] = useState('');
  const [personaByCharacterId, setPersonaByCharacterId] = useState<
    Record<string, string>
  >({});
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
    forceListMode
      ? 'list'
      : directCharacterId ||
          mobileAppState.chat.sentMessageCount > 0 ||
          mobileAppState.chat.selectedCharacterId
        ? 'chat'
        : 'list',
  );
  // 초기값 우선순위:
  //   1) bootstrap이 SecureStore에서 preload한 "마지막으로 본 상태" (가장 최신)
  //   2) 로컬 story snapshot (romance pilot 캐릭터)
  //   3) 하드코딩 인트로 — 대화 한 번도 없는 신규 캐릭터만 해당
  // 이 순서를 지켜야 앱 재진입 시 "old → new 플래시"가 사라진다.
  const [messagesByCharacterId, setMessagesByCharacterId] = useState<
    Record<string, ChatShellMessage[]>
  >(() =>
    Object.fromEntries(
      chatCharacters.map((character) => {
        const cached = cachedCharacterConversations[character.id];
        if (cached && cached.length > 0) {
          return [character.id, cached];
        }
        const storySnapshot = buildStoryThreadSnapshot(character);
        return [
          character.id,
          storySnapshot?.messages ?? buildInitialThread(character),
        ];
      }),
    ),
  );
  const [lastSeenByCharacterId, setLastSeenByCharacterId] = useState<
    Record<string, string>
  >({});

  useEffect(() => {
    let mounted = true;
    void getChatLastSeenByCharacterId().then((loaded) => {
      if (mounted) setLastSeenByCharacterId(loaded);
    });
    return () => {
      mounted = false;
    };
  }, []);

  // 스레드 체류 중 새 AI/system 메시지 도착 → 즉시 읽음 처리.
  // 일반 메신저(iMessage/WhatsApp/KakaoTalk) 와 동일한 동작: 유저가 해당
  // 스레드를 보고 있는 동안 상대 메시지가 오면 수신과 동시에 "읽음".
  // handleCharacterSelect 가 진입 시점에 1회 lastSeen 을 찍지만, 그 이후에
  // 도착하는 메시지는 여기서 follow-up 으로 갱신해야 리스트 닷이 안 생김.
  useEffect(() => {
    if (surfaceMode !== 'chat') return;
    const charId = selectedCharacterId;
    if (!charId) return;
    const thread = messagesByCharacterId[charId];
    if (!thread || thread.length === 0) return;
    const latest = thread[thread.length - 1];
    // user 가 보낸 메시지면 굳이 갱신 필요 없음 (본인이 방금 보낸 것).
    if (latest.sender !== 'assistant' && latest.sender !== 'system') return;
    const currentSeen = lastSeenByCharacterId[charId];
    if (currentSeen === latest.id) return;
    setLastSeenByCharacterId((current) => ({
      ...current,
      [charId]: latest.id,
    }));
    void setChatLastSeenForCharacter(charId, latest.id).catch(() => undefined);
  }, [
    surfaceMode,
    selectedCharacterId,
    messagesByCharacterId,
    lastSeenByCharacterId,
  ]);
  const [storyThreadSnapshotsByCharacterId, setStoryThreadSnapshotsByCharacterId] =
    useState<Record<string, StoryChatThreadSnapshot | null>>(() =>
      Object.fromEntries(
        storyChatCharacters.map((character) => [
          character.id,
          buildStoryThreadSnapshot(character),
        ]),
      ),
    );
  const [storyTypingByCharacterId, setStoryTypingByCharacterId] = useState<
    Record<string, boolean>
  >({});
  // 모델 응답 대기 중에도 입력은 항상 가능. 같은 캐릭터에 도착한 다음 메시지들은
  // 여기 큐에 쌓이고, 현재 응답이 끝난 직후 하나씩 순차 발송된다.
  // 비동기 finally/타이머에서 최신값을 참조해야 해서 state 대신 ref로 관리.
  const pendingSendsRef = useRef<
    Record<string, { text: string; userMessageId: string }[]>
  >({});
  // UI 노출용 큐 카운트 (typing indicator "대기 +N"). ref 변경마다 동기 업데이트.
  const [pendingSendCountByCharacterId, setPendingSendCountByCharacterId] =
    useState<Record<string, number>>({});
  const [activeSurveysByCharacterId, setActiveSurveysByCharacterId] = useState<
    Record<string, ActiveChatSurvey | null>
  >({});
  const hydratedStoryThreadsKeyRef = useRef<string | null>(null);
  const hydratedCharacterIdsRef = useRef<Set<string>>(new Set());

  // Voice input (expo-av + Whisper via Edge Function)
  const handleVoiceTranscript = useCallback(
    (text: string) => {
      setDraft((prev) => (prev ? `${prev} ${text}` : text));
    },
    [],
  );
  const {
    state: voiceInputState,
    toggleRecording: toggleVoiceRecording,
  } = useVoiceInput({ onTranscript: handleVoiceTranscript });

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

  // "사주로 대화하기" entry: inject the user's manseryeok snapshot as a system
  // card at the top of the currently-selected fortune character's thread.
  // Picks the first fortune character when no selection exists yet so the
  // message lands somewhere the user will actually see after nav push.
  useEffect(() => {
    if (!pendingMySajuContext) {
      return;
    }

    const message = consumePendingMySajuContext();
    if (!message) {
      return;
    }

    const targetCharacterId =
      selectedCharacterId ??
      mobileAppState.chat.selectedCharacterId ??
      fortuneChatCharacters[0]?.id ??
      chatCharacters[0]?.id ??
      null;

    if (!targetCharacterId) {
      return;
    }

    setActiveTab('fortune');
    setSurfaceMode('chat');
    if (selectedCharacterId == null) {
      setSelectedCharacterId(targetCharacterId);
    }

    setMessagesByCharacterId((current) => {
      const existing = current[targetCharacterId] ?? [];
      // Dedupe by id in case the same message somehow lands twice.
      if (existing.some((m) => m.id === message.id)) {
        return current;
      }
      return {
        ...current,
        [targetCharacterId]: [message, ...existing],
      };
    });
  }, [
    consumePendingMySajuContext,
    mobileAppState.chat.selectedCharacterId,
    pendingMySajuContext,
    selectedCharacterId,
  ]);

  // Hydrate a single character's conversation from remote.
  // `force=true` 면 dedup 캐시를 무시하고 재로드 — 리스트 focus 시 호출해서
  // 백엔드(프로액티브 메시지, 다른 디바이스에서 보낸 메시지 등) 변경을
  // 리스트 프리뷰에 즉시 반영한다.
  const hydrateStoryCharacter = useCallback(
    async (characterId: string, options?: { force?: boolean }) => {
      if (!options?.force && hydratedCharacterIdsRef.current.has(characterId)) {
        return;
      }

      hydratedCharacterIdsRef.current.add(characterId);

      try {
        // Story romance pilots: load full snapshot with romance state
        if (isStoryRomancePilotCharacterId(characterId)) {
          const snapshot = await loadStoryThreadSnapshot(characterId);

          if (!snapshot) {
            return;
          }

          setMessagesByCharacterId((current) => {
            const cur = current[characterId];
            if (!shouldAcceptRemoteMessages(cur, snapshot.messages)) {
              return current;
            }
            if (isSameMessageList(cur, snapshot.messages)) {
              return current;
            }
            return { ...current, [characterId]: snapshot.messages };
          });
          setStoryThreadSnapshotsByCharacterId((current) => ({
            ...current,
            [characterId]: snapshot,
          }));
          return;
        }

        // All other characters: load messages only
        const messages = await loadCharacterConversation(characterId);

        if (!messages) {
          return;
        }

        setMessagesByCharacterId((current) => {
          const cur = current[characterId];
          if (!shouldAcceptRemoteMessages(cur, messages)) {
            return current;
          }
          if (isSameMessageList(cur, messages)) {
            return current;
          }
          return { ...current, [characterId]: messages };
        });
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

  // On gate ready: hydrate the initially-selected character immediately, then
  // opportunistically hydrate every character visible in the list so that the
  // last-message preview shows up on first load (before the user enters a
  // conversation). `hydrateStoryCharacter` is deduped via its internal Set, so
  // repeated calls are safe.
  useEffect(() => {
    if (gate !== 'ready') {
      return;
    }

    const hydrationKey = session?.user.id ?? 'guest';
    if (hydratedStoryThreadsKeyRef.current !== hydrationKey) {
      hydratedStoryThreadsKeyRef.current = hydrationKey;
      hydratedCharacterIdsRef.current = new Set();
    }

    const initialCharacterId =
      directCharacterId ??
      mobileAppState.chat.selectedCharacterId ??
      storyChatCharacters[0]?.id;

    if (initialCharacterId) {
      void hydrateStoryCharacter(initialCharacterId);
    }

    for (const character of chatCharacters) {
      if (character.id !== initialCharacterId) {
        void hydrateStoryCharacter(character.id);
      }
    }
  }, [gate, session?.user.id, directCharacterId, mobileAppState.chat.selectedCharacterId, hydrateStoryCharacter]);

  // 리스트 화면이 (재)포커스되면 전 캐릭터를 강제 재하이드레이션 —
  // 프로액티브 메시지 / 다른 디바이스에서의 변경을 리스트 프리뷰에 즉시 반영.
  // 메신저앱에서 리스트로 돌아올 때 최신 상태가 보이는 동작을 맞춤.
  //
  // surfaceMode 가 'list' 로 전환될 때, 그리고 expo-router focus 가 들어올 때
  // 모두 트리거. 빈번해 보이지만 force=true 경로도 내부에서 아이디별로 직렬
  // 호출되고, 로컬 SecureStore 는 빠르며 remote 는 edge function 한 번이라
  // 실전 체감 부하는 낮다.
  useFocusEffect(
    useCallback(() => {
      if (gate !== 'ready') return;
      for (const character of chatCharacters) {
        void hydrateStoryCharacter(character.id, { force: true });
      }
    }, [gate, hydrateStoryCharacter]),
  );

  useEffect(() => {
    if (gate !== 'ready') return;
    if (surfaceMode !== 'list') return;
    for (const character of chatCharacters) {
      void hydrateStoryCharacter(character.id, { force: true });
    }
  }, [gate, surfaceMode, hydrateStoryCharacter]);

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

  // Lazy-load conversation when user switches to a character not yet hydrated
  useEffect(() => {
    if (gate !== 'ready') {
      return;
    }

    void hydrateStoryCharacter(selectedCharacter.id);
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

  // Romance score for selected character (used for chat background tint)
  const selectedRomanceScore = selectedStorySnapshot
    ? Math.round(
        (selectedStorySnapshot.romanceState.attachmentSignal +
          selectedStorySnapshot.romanceState.emotionalTemperature) /
          2,
      )
    : 0;

  // Romance scores for all characters (used for list row tints)
  const romanceScoresByCharacterId = useMemo(
    () =>
      Object.fromEntries(
        Object.entries(storyThreadSnapshotsByCharacterId)
          .filter(([, snapshot]) => snapshot != null)
          .map(([id, snapshot]) => [
            id,
            Math.round(
              ((snapshot?.romanceState.attachmentSignal ?? 0) +
                (snapshot?.romanceState.emotionalTemperature ?? 0)) /
                2,
            ),
          ]),
      ),
    [storyThreadSnapshotsByCharacterId],
  );
  const [fortuneTypingCharacterId, setFortuneTypingCharacterId] = useState<string | null>(null);
  const selectedStoryIsTyping =
    storyTypingByCharacterId[selectedCharacter.id] === true;
  const selectedFortuneIsTyping = fortuneTypingCharacterId === selectedCharacter.id;

  // ---------------------------------------------------------------------------
  // F2 — 읽음 표시 타이머 (유저가 메시지 보내고 N초 뒤 "1" 배지 제거)
  // ---------------------------------------------------------------------------
  const readReceiptTimersRef = useRef<Map<string, ReturnType<typeof setTimeout>>>(
    new Map(),
  );

  const clearReadReceiptTimer = useCallback((characterId: string) => {
    const timer = readReceiptTimersRef.current.get(characterId);
    if (timer) {
      clearTimeout(timer);
      readReceiptTimersRef.current.delete(characterId);
    }
  }, []);

  const scheduleReadReceipt = useCallback(
    (characterId: string) => {
      clearReadReceiptTimer(characterId);
      const delay = randomInRange(8000, 20000); // 8-20초 랜덤
      const timer = setTimeout(() => {
        readReceiptTimersRef.current.delete(characterId);
        setMessagesByCharacterId((current) => ({
          ...current,
          [characterId]: markLatestUserMessageAsRead(
            current[characterId] ?? [],
          ),
        }));
      }, delay);
      readReceiptTimersRef.current.set(characterId, timer);
    },
    [clearReadReceiptTimer],
  );

  const markUserMessageReadImmediately = useCallback(
    (characterId: string) => {
      clearReadReceiptTimer(characterId);
      setMessagesByCharacterId((current) => ({
        ...current,
        [characterId]: markLatestUserMessageAsRead(
          current[characterId] ?? [],
        ),
      }));
    },
    [clearReadReceiptTimer],
  );

  // 언마운트 시 모든 타이머 정리
  useEffect(() => {
    const timersRef = readReceiptTimersRef;
    return () => {
      for (const timer of timersRef.current.values()) {
        clearTimeout(timer);
      }
      timersRef.current.clear();
    };
  }, []);

  // 부팅 시 큐 복원 — 앱 강제 종료되어도 대기 중이던 유저 메시지를 이어서 처리.
  useEffect(() => {
    void (async () => {
      const raw = await getSecureItem(PENDING_SENDS_STORAGE_KEY);
      if (!raw) return;
      try {
        const parsed = JSON.parse(raw) as typeof pendingSendsRef.current;
        if (!parsed || typeof parsed !== 'object') return;
        pendingSendsRef.current = parsed;
        const counts: Record<string, number> = {};
        for (const [cid, queue] of Object.entries(parsed)) {
          counts[cid] = Array.isArray(queue) ? queue.length : 0;
        }
        setPendingSendCountByCharacterId(counts);
      } catch {
        // 파싱 실패 시 무시 — 다음 저장이 덮어쓴다.
      }
    })();
  }, []);

  // gate=ready가 되면 복원된 큐를 자동으로 drain. 캐릭터별 1회만 트리거하고,
  // 이후 chain은 각 send 함수의 finally → drainNextPendingSend가 이어 받는다.
  const didInitialDrainRef = useRef(false);
  useEffect(() => {
    if (gate !== 'ready' || didInitialDrainRef.current) return;
    const entries = Object.entries(pendingSendsRef.current);
    if (entries.length === 0) return;
    didInitialDrainRef.current = true;
    for (const [cid, queue] of entries) {
      if (!Array.isArray(queue) || queue.length === 0) continue;
      if (storyTypingByCharacterId[cid]) continue;
      const character = findChatCharacterById(cid, createdFriends);
      if (!character) continue;
      drainNextPendingSend(character);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [gate, createdFriends]);

  // ---------------------------------------------------------------------------
  // F3 — 햅틱 토글 (chatHapticsEnabled 설정)
  // ---------------------------------------------------------------------------
  const chatHapticsEnabled = mobileAppState.settings.chatHapticsEnabled;
  const chatHapticsEnabledRef = useRef(chatHapticsEnabled);
  useEffect(() => {
    chatHapticsEnabledRef.current = chatHapticsEnabled;
  }, [chatHapticsEnabled]);

  const triggerAssistantHaptic = useCallback(
    (emotionTag: string | undefined) => {
      if (!chatHapticsEnabledRef.current) {
        return;
      }
      if (emotionTag === '애정') {
        loveHeartbeat();
      } else {
        tapLight();
      }
    },
    [],
  );

  // ---------------------------------------------------------------------------
  // F3 — 관계 단계 변화 시 scoreReveal(90)
  // ---------------------------------------------------------------------------
  const previousPhaseByCharacterIdRef = useRef<Record<string, string>>({});
  useEffect(() => {
    const previous = previousPhaseByCharacterIdRef.current;
    const nextSnapshot = {
      ...previous,
    };
    let phaseChanged = false;
    for (const [characterId, snapshot] of Object.entries(
      storyThreadSnapshotsByCharacterId,
    )) {
      const currentPhase = snapshot?.romanceState.safeAffectionStage ?? '';
      const prevPhase = previous[characterId];
      nextSnapshot[characterId] = currentPhase;
      if (prevPhase && prevPhase !== currentPhase && currentPhase.length > 0) {
        phaseChanged = true;
      }
    }
    if (phaseChanged && chatHapticsEnabledRef.current) {
      scoreReveal(90);
    }
    previousPhaseByCharacterIdRef.current = nextSnapshot;
  }, [storyThreadSnapshotsByCharacterId]);

  // ---------------------------------------------------------------------------
  // F1 — 멀티버블 순차 enqueue 헬퍼
  // ---------------------------------------------------------------------------
  /**
   * 어시스턴트 segments를 카톡 리듬으로 하나씩 append.
   * 각 버블 앞에 타이핑 인디케이터 200-600ms + 버블 사이 600-1800ms 랜덤 간격.
   * 첫 버블은 호출자가 이미 replyDelay를 걸었다고 가정 (중복 delay X).
   */
  const enqueueAssistantSegments = useCallback(
    async (options: {
      characterId: string;
      segments: string[];
      emotionTag?: string;
    }) => {
      const { characterId, segments, emotionTag } = options;
      // 응답 append는 항상 현재 state 위에 쌓는다. 큐잉된 유저 메시지(응답 대기 중
      // 사용자가 추가로 보낸 것)를 덮어쓰지 않도록 functional setter로만 처리.
      let latestThread: ChatShellMessage[] = [];

      for (let index = 0; index < segments.length; index += 1) {
        const text = segments[index]?.trim() ?? '';
        if (text.length === 0) {
          continue;
        }

        if (index > 0) {
          // 버블 간 타이핑 인디케이터 유지 — storyTyping/fortuneTyping은 이미 on 상태
          const gap = randomInRange(200, 600); // 타이핑 지속
          await sleep(gap);
          const betweenBubbles = randomInRange(600, 1800);
          await sleep(betweenBubbles);
        }

        const bubble = buildAssistantTextMessage(text, { animate: true });
        setMessagesByCharacterId((current) => {
          const thread = current[characterId] ?? [];
          const updated = [...thread, bubble];
          latestThread = updated;
          return { ...current, [characterId]: updated };
        });

        // 햅틱 — 첫 버블에서만 울리거나 전부 울리거나. 카톡도 각 메시지마다 울리므로 전부.
        triggerAssistantHaptic(emotionTag);
      }

      return latestThread;
    },
    [triggerAssistantHaptic],
  );

  // ---------------------------------------------------------------------------
  // F4 — 프레전스 라인 ("커피 내리는 중", "네 생각 중..." 등)
  // ---------------------------------------------------------------------------
  const [presenceLine, setPresenceLine] = useState<string>('');
  const lastAssistantEmotionTagRef = useRef<string>('일상');

  const refreshPresenceLine = useCallback(() => {
    const hour = new Date().getHours();
    const line = pickPresenceLine({
      hour,
      emotionTag: lastAssistantEmotionTagRef.current,
      characterName: selectedCharacter.name,
    });
    setPresenceLine(line);
  }, [selectedCharacter.name]);

  useEffect(() => {
    refreshPresenceLine();
    // 30초 → 5분. 30초 주기는 대화 중 헤더 라인이 계속 바뀌어서 유저가
    // "실제 메시지가 사라진다" 고 오인하는 혼란의 주원인이었다. presence 는
    // 어차피 "지금 뭐해" 정도의 ambient 라벨이라 5분 정도는 안정적.
    const interval = setInterval(refreshPresenceLine, 300_000);
    return () => {
      clearInterval(interval);
    };
  }, [refreshPresenceLine]);
  const activeSurvey = activeSurveysByCharacterId[selectedCharacter.id] ?? null;
  const currentSurveyStep = activeSurvey
    ? getCurrentSurveyStep(activeSurvey)
    : null;

  const scrollTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const prevContentHeightRef = useRef(0);
  const scrollViewHeightRef = useRef(Dimensions.get('window').height * 0.7);
  // 카드 상단 스크롤은 메시지 하나 당 한 번만 — 이후 카드 내부 애니메이션 등
  // 진행 중 재호출되는 onContentSizeChange 에서 다시 스크롤이 튀지 않도록.
  const cardTopScrolledMessageIdRef = useRef<string | null>(null);

  function scrollChatToBottom(animated = true) {
    // Single rAF is enough — the caller invokes this after React has scheduled
    // the re-render, and rAF runs after layout. The previous setTimeout(100) +
    // rAF double-wait caused visible jumps when two messages arrived within
    // the debounce window (the first scrollToEnd would get cancelled and the
    // user would briefly see the new message below the viewport).
    if (scrollTimerRef.current) {
      clearTimeout(scrollTimerRef.current);
      scrollTimerRef.current = null;
    }
    requestAnimationFrame(() => {
      chatScrollRef.current?.scrollToEnd({ animated });
    });
  }

  function scrollChatOnContentGrow(contentHeight: number) {
    const prevHeight = prevContentHeightRef.current;
    const viewportHeight = scrollViewHeightRef.current;
    prevContentHeightRef.current = contentHeight;

    // 입장 후 첫 hydration 완료 시점 — 마지막 메시지 종류 관계없이 무조건 바닥.
    if (prevHeight <= 0) {
      requestAnimationFrame(() => {
        chatScrollRef.current?.scrollToEnd({ animated: false });
      });
      return;
    }

    const addedHeight = contentHeight - prevHeight;
    if (addedHeight <= 0) return;

    if (scrollTimerRef.current) {
      clearTimeout(scrollTimerRef.current);
      scrollTimerRef.current = null;
    }

    // 최근 메시지가 운세 결과 카드면 카드 상단이 화면 최상단에 보이게 스크롤.
    const latestThread =
      messagesByCharacterId[selectedCharacter.id] ?? [];
    const latestMessage = latestThread[latestThread.length - 1];
    const isResultCardArriving =
      latestMessage?.kind === 'embedded-result' ||
      latestMessage?.kind === 'fortune-cookie' ||
      latestMessage?.kind === 'saju-preview';

    if (isResultCardArriving) {
      // 같은 카드에 대해서 이미 한 번 상단 스크롤을 했으면, 이후 카드
      // 내부 애니메이션으로 content height가 또 늘어나도 추가 스크롤 금지.
      if (cardTopScrolledMessageIdRef.current === latestMessage.id) {
        return;
      }
      cardTopScrolledMessageIdRef.current = latestMessage.id;
      // 카드 상단이 뷰포트 상단에 딱 오도록. prevHeight가 카드 시작 y.
      scrollTimerRef.current = setTimeout(() => {
        requestAnimationFrame(() => {
          chatScrollRef.current?.scrollTo({ y: Math.max(0, prevHeight - 8), animated: true });
        });
      }, 80);
    } else if (addedHeight > viewportHeight * 0.5) {
      scrollTimerRef.current = setTimeout(() => {
        requestAnimationFrame(() => {
          chatScrollRef.current?.scrollTo({ y: Math.max(0, prevHeight - 8), animated: true });
        });
      }, 80);
    } else {
      // 일반 메시지: 바닥으로.
      requestAnimationFrame(() => {
        chatScrollRef.current?.scrollToEnd({ animated: true });
      });
    }
  }

  useEffect(() => {
    const sub = Keyboard.addListener('keyboardDidShow', () => {
      scrollChatToBottom();
    });
    return () => sub.remove();
  }, []);

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
  // Apple 5.2.3 — 사용자가 차단한 캐릭터는 리스트에서 숨긴다. 운세 캐릭터는
  // 시스템 기본 제공이라 차단 대상 아님 → 필터 영향 없음.
  const blockedCharacterIds = useBlockedCharacterIds();
  const firstRunCharacters = useMemo(
    () =>
      blockedCharacterIds.size === 0
        ? tabCharacters
        : tabCharacters.filter((c) => !blockedCharacterIds.has(c.id)),
    [tabCharacters, blockedCharacterIds],
  );

  const characterListMetaById = useMemo(() => {
    const result: Record<string, CharacterListRowMeta> = {};
    for (const character of firstRunCharacters) {
      result[character.id] = buildCharacterListMeta(
        messagesByCharacterId[character.id],
        lastSeenByCharacterId[character.id],
      );
    }
    return result;
  }, [firstRunCharacters, messagesByCharacterId, lastSeenByCharacterId]);

  // 앱 아이콘 배지 = 전 캐릭터 unread 합산. messagesByCharacterId /
  // lastSeenByCharacterId 가 바뀔 때마다 재계산해 OS 배지와 동기화.
  // 메신저 앱 표준 — iMessage / WhatsApp / KakaoTalk 모두 홈스크린에 숫자.
  useEffect(() => {
    let total = 0;
    for (const characterId of Object.keys(messagesByCharacterId)) {
      const meta = buildCharacterListMeta(
        messagesByCharacterId[characterId],
        lastSeenByCharacterId[characterId],
      );
      total += meta.unreadCount;
    }
    void setAppIconBadgeCount(total);
  }, [messagesByCharacterId, lastSeenByCharacterId]);

  // 입장(캐릭터 진입) 시에는 항상 맨 아래로.
  // 결과 카드가 마지막이더라도, 진입 시점에서 사용자가 기대하는 위치는
  // 대화의 최하단이므로 카드 상단 스크롤 로직은 여기서 적용하지 않는다.
  useEffect(() => {
    if (gate !== 'ready' || surfaceMode !== 'chat') {
      return;
    }
    // hydration 후 첫 content grow 에서 다시 바닥으로 가도록 ref 리셋.
    prevContentHeightRef.current = 0;
    cardTopScrolledMessageIdRef.current = null;
    scrollChatToBottom(false);
  }, [
    gate,
    surfaceMode,
    selectedCharacter.id,
    currentSurveyStep?.step.id,
  ]);

  // 같은 방에 있는 동안 새 메시지가 도착하면 아래로 스크롤.
  // 단, 마지막 메시지가 결과 카드면 scrollChatOnContentGrow 가 카드 상단을
  // 뷰포트 상단에 고정하므로 여기선 스킵.
  useEffect(() => {
    if (gate !== 'ready' || surfaceMode !== 'chat') {
      return;
    }
    const latestMessage = selectedThread[selectedThread.length - 1];
    const latestIsResultCard =
      latestMessage?.kind === 'embedded-result' ||
      latestMessage?.kind === 'fortune-cookie' ||
      latestMessage?.kind === 'saju-preview';
    if (latestIsResultCard) {
      return;
    }
    scrollChatToBottom(true);
  }, [gate, surfaceMode, selectedThread.length]);
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
    // 새로 붙는 메시지 중 assistant/system 이 섞여 있으면, 그 시점에 미읽음
    // 상태인 user 메시지는 모두 읽음 처리. (운세 설문/액션/일반 채팅 등
    // 모든 경로를 한 곳에서 커버해서 "1" 배지가 남는 현상 방지)
    const hasNonUserMessage = nextMessages.some(
      (m) => m.sender === 'assistant' || m.sender === 'system',
    );
    setMessagesByCharacterId((current) => {
      const existing = current[character.id] ?? [];
      const base = hasNonUserMessage
        ? markLatestUserMessageAsRead(existing)
        : existing;
      return {
        ...current,
        [character.id]: [...base, ...nextMessages],
      };
    });
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

      const survey = startChatSurvey(definition, {
        mbti: mobileAppState.profile.mbti || undefined,
        bloodType: mobileAppState.profile.bloodType || undefined,
      });

      // If all steps are pre-filled from profile, skip survey entirely.
      const firstStep = getCurrentSurveyStep(survey);
      if (!firstStep) {
        setActiveSurvey(character.id, null);
        void appendResolvedFortuneResult(character, fortuneType);
        return true;
      }

      const question =
        resolveSurveyQuestion(survey, {
          mbti: mobileAppState.profile.mbti || undefined,
        }) ?? firstStep.step.question;

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

      const resultReply = buildAssistantTextMessage(
        definition?.submitReply ??
          '좋아요. 결과를 같은 채팅 안에서 바로 보여드릴게요.',
      );

      appendMessages(character, [resultReply, embeddedResult]);

      // Persist fortune conversation to remote (text messages only)
      const currentMessages = messagesByCharacterId[character.id] ?? [];
      saveCharacterConversation(character.id, [
        ...currentMessages,
        resultReply,
        embeddedResult,
      ]).catch((saveError: unknown) => {
        captureError(saveError, {
          surface: 'chat:fortune-save-conversation',
        }).catch(() => undefined);
      });
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

    const thread = messagesByCharacterId[characterId] ?? [];
    const lastMessage = thread[thread.length - 1];
    if (lastMessage) {
      setLastSeenByCharacterId((current) => ({
        ...current,
        [characterId]: lastMessage.id,
      }));
      void setChatLastSeenForCharacter(characterId, lastMessage.id).catch(
        () => undefined,
      );
    }

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
      pathname: '/friends/new',
      params: { returnTo: '/chat' },
    });
  }

  async function handleOpenPhotoPicker() {
    setComposerTrayOpen(false);

    const { launchImageLibraryAsync, requestMediaLibraryPermissionsAsync, MediaTypeOptions } =
      await import('expo-image-picker');

    const { status } = await requestMediaLibraryPermissionsAsync();
    if (status !== 'granted') {
      Alert.alert('권한 필요', '사진을 보내려면 갤러리 접근을 허용해주세요.');
      return;
    }

    const result = await launchImageLibraryAsync({
      mediaTypes: MediaTypeOptions.Images,
      quality: 0.7,
      allowsEditing: false,
      base64: true,
    });

    if (result.canceled || !result.assets?.[0]) {
      return;
    }

    const asset = result.assets[0];
    // 즉시 전송하지 않고 composer 미리보기에 적재. 유저가 캡션을 쓰고 "보내기"를
    // 눌렀을 때 handleSendDraft 에서 실제 전송이 일어난다. X 누르면 취소.
    setPendingImageByCharacterId((current) => ({
      ...current,
      [selectedCharacter.id]: {
        uri: asset.uri,
        base64: asset.base64 ?? undefined,
        mimeType: asset.mimeType ?? undefined,
      },
    }));
    setSurfaceMode('chat');
  }

  function handleClearPendingImage() {
    setPendingImageByCharacterId((current) => {
      if (!(selectedCharacter.id in current)) return current;
      const next = { ...current };
      delete next[selectedCharacter.id];
      return next;
    });
  }

  function handleToggleVoiceInput() {
    void toggleVoiceRecording();
  }

  function handleOpenPersonaSettings() {
    setComposerTrayOpen(false);
    setPersonaDraft(personaByCharacterId[selectedCharacter.id] ?? '');
    setPersonaModalOpen(true);
  }

  async function handleSavePersona() {
    const trimmed = personaDraft.trim();
    setPersonaByCharacterId((current) => ({
      ...current,
      [selectedCharacter.id]: trimmed,
    }));
    setPersonaModalOpen(false);

    await saveCharacterPersona(
      selectedCharacter.id,
      session?.user.id ?? null,
      trimmed,
    ).catch((error) => {
      captureError(error, { surface: 'chat:save-persona' }).catch(() => undefined);
    });
  }

  // Load persona when character changes
  useEffect(() => {
    if (gate !== 'ready') {
      return;
    }

    if (personaByCharacterId[selectedCharacter.id] !== undefined) {
      return;
    }

    loadCharacterPersona(selectedCharacter.id, session?.user.id ?? null)
      .then((persona) => {
        setPersonaByCharacterId((current) => ({
          ...current,
          [selectedCharacter.id]: persona?.customInstructions ?? '',
        }));
      })
      .catch(() => undefined);
  }, [gate, selectedCharacter.id, session?.user.id]);

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

  // 큐 전체를 비우고 해당 유저 메시지들을 thread에서 제거. 프리미엄 게이트
  // 같은 블로킹 조건이 걸렸을 때 "유저 메시지는 남아있는데 응답은 영영 안 옴"
  // 상태를 방지한다.
  function flushPendingQueue(characterId: string) {
    const queue = pendingSendsRef.current[characterId] ?? [];
    if (queue.length === 0) return;
    pendingSendsRef.current = {
      ...pendingSendsRef.current,
      [characterId]: [],
    };
    syncPendingCount(characterId);
    const idsToRemove = new Set(queue.map((item) => item.userMessageId));
    setMessagesByCharacterId((current) => {
      const thread = current[characterId] ?? [];
      return {
        ...current,
        [characterId]: thread.filter((m) => !idsToRemove.has(m.id)),
      };
    });
  }

  // 실패한 전송의 유저 메시지만 thread에서 제거. 뒤늦게 큐잉된 다른 메시지는
  // 건드리지 않는다. id가 없으면 가장 최근 user 메시지 하나를 pop.
  function rollbackUserMessage(characterId: string, userMessageId?: string) {
    setMessagesByCharacterId((current) => {
      const thread = current[characterId] ?? [];
      if (userMessageId) {
        return {
          ...current,
          [characterId]: thread.filter((m) => m.id !== userMessageId),
        };
      }
      const lastUserIndex = thread.findLastIndex((m) => m.sender === 'user');
      if (lastUserIndex < 0) return current;
      return {
        ...current,
        [characterId]: [
          ...thread.slice(0, lastUserIndex),
          ...thread.slice(lastUserIndex + 1),
        ],
      };
    });
  }

  // pendingSendsRef가 바뀔 때마다 UI 카운트 동기 업데이트 + 디스크 영속화.
  function syncPendingCount(characterId: string) {
    setPendingSendCountByCharacterId((current) => ({
      ...current,
      [characterId]: pendingSendsRef.current[characterId]?.length ?? 0,
    }));
    void setSecureItem(
      PENDING_SENDS_STORAGE_KEY,
      JSON.stringify(pendingSendsRef.current),
    ).catch(() => undefined);
  }

  // 응답 대기 중 사용자 입력을 큐에 적재. 유저 메시지는 즉시 thread에 보여
  // 전송 피드백을 준다. drain은 현재 응답 finally에서 처리.
  function enqueueStorySend(character: ChatCharacterSpec, text: string) {
    const queuedUserMessage = buildUserMessage(text);
    setMessagesByCharacterId((current) => ({
      ...current,
      [character.id]: [
        ...(current[character.id] ?? []),
        queuedUserMessage,
      ],
    }));
    pendingSendsRef.current = {
      ...pendingSendsRef.current,
      [character.id]: [
        ...(pendingSendsRef.current[character.id] ?? []),
        { text, userMessageId: queuedUserMessage.id },
      ],
    };
    syncPendingCount(character.id);
    setComposerTrayOpen(false);
    setSurfaceMode('chat');
  }

  function drainNextPendingSend(character: ChatCharacterSpec) {
    const queue = pendingSendsRef.current[character.id] ?? [];
    if (queue.length === 0) {
      return;
    }
    const [next, ...rest] = queue;
    pendingSendsRef.current = {
      ...pendingSendsRef.current,
      [character.id]: rest,
    };
    syncPendingCount(character.id);

    if (isStoryRomancePilotCharacterId(character.id)) {
      void sendStoryPilotMessage(character, next.text, {
        skipOptimisticUserMessage: true,
        userMessageId: next.userMessageId,
      });
      return;
    }

    if (character.kind === 'story') {
      void sendCharacterChatMessage(character, next.text, {
        skipOptimisticUserMessage: true,
        userMessageId: next.userMessageId,
      });
    }
  }

  async function sendStoryPilotMessage(
    character: ChatCharacterSpec,
    text: string,
    sendOptions?: {
      skipOptimisticUserMessage?: boolean;
      userMessageId?: string;
      imageBase64?: string;
    },
  ) {
    const trimmed = text.trim();

    // 이미지만 있고 텍스트가 비어있는 케이스(사진만 보내기)를 허용하기 위해
    // trimmed 가 비어 있어도 imageBase64 가 있으면 진행.
    if (!trimmed && !sendOptions?.imageBase64) {
      return;
    }

    const skipOptimistic = sendOptions?.skipOptimisticUserMessage === true;

    const existingSnapshot =
      storyThreadSnapshotsByCharacterId[character.id] ??
      buildStoryThreadSnapshot(character);
    const existingThread =
      messagesByCharacterId[character.id] ??
      existingSnapshot?.messages ??
      buildInitialThread(character);
    // 큐에서 drain되어 재진입한 경우, 유저 메시지는 이미 thread에 들어있다.
    const userMessage = skipOptimistic ? null : buildUserMessage(trimmed);
    const optimisticThread = userMessage
      ? [...existingThread, userMessage]
      : existingThread;
    const storyRequest = buildStoryChatRequest(
      character,
      trimmed,
      existingSnapshot,
    );

    if (!storyRequest) {
      return;
    }

    // 관계 진행 프리미엄 게이팅 — 친밀도 50+ 에서 무료 유저는 프리미엄 유도
    const currentAffinity = existingSnapshot?.romanceState?.emotionalTemperature ?? 0;
    const isPremiumUser = mobileAppState.premium.isUnlimited ||
      (mobileAppState.premium.tokenBalance ?? 0) > 0;
    if (currentAffinity >= 50 && !isPremiumUser && session) {
      Alert.alert(
        '관계가 깊어지고 있어요',
        `${character.name}과(와) 더 깊은 대화를 이어가려면 프리미엄이 필요해요.`,
        [
          { text: '나중에', style: 'cancel' },
          { text: '프리미엄 보기', onPress: () => router.push('/premium') },
        ],
      );
      // 큐잉된 메시지가 있으면 모두 thread에서 제거하고 큐 비움 — 안 그러면
      // 유저 메시지만 남고 응답이 영영 오지 않는 스턱 상태가 된다.
      if (skipOptimistic && sendOptions?.userMessageId) {
        rollbackUserMessage(character.id, sendOptions.userMessageId);
      }
      flushPendingQueue(character.id);
      return;
    }

    const optimisticSnapshot = buildNextStoryThreadSnapshot(
      existingSnapshot,
      character,
      optimisticThread,
      null,
      storyRequest,
    );
    let shouldClearDraft = !skipOptimistic;
    const effectiveUserMessageId = userMessage?.id ?? sendOptions?.userMessageId;

    if (userMessage) {
      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: [...(current[character.id] ?? []), userMessage],
      }));
    }
    setStoryTypingByCharacterId((current) => ({
      ...current,
      [character.id]: true,
    }));
    // F2 — 읽음 표시 랜덤 지연 타이머 시작 (서버 응답 먼저 오면 즉시 제거)
    scheduleReadReceipt(character.id);
    setComposerTrayOpen(false);
    setSurfaceMode('chat');

    try {
      if (!supabase) {
        const fallbackMessage = buildStoryFallbackAssistantMessage(character);
        clearReadReceiptTimer(character.id);
        setMessagesByCharacterId((current) => {
          const thread = current[character.id] ?? [];
          return {
            ...current,
            [character.id]: [
              ...markLatestUserMessageAsRead(thread),
              fallbackMessage,
            ],
          };
        });
        return;
      }

      const chatProvider = resolveChatProvider(mobileAppState.settings.aiMode, {
        requiresImageInput: !!sendOptions?.imageBase64,
      });

      // Skip token consumption for guest users and on-device mode
      if (session && chatProvider.getProviderName() === 'cloud') {
        await consumeRemoteTokens(session, {
          fortuneType: 'character-chat',
          referenceId: `story:${character.id}`,
        });

        syncRemoteProfile().catch((error: unknown) => {
          captureError(error, {
            surface: 'chat:story-pilot-sync-premium-after-consume',
          }).catch(() => undefined);
        });
      }

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

      const customPersona = personaByCharacterId[character.id];
      const invokeOptions: import('../lib/chat-provider').ChatProviderOptions = {};
      if (customPersona) {
        invokeOptions.userDescription = `[유저 커스텀 성격 요청] ${customPersona}`;
      }
      if (sendOptions?.imageBase64) {
        invokeOptions.imageBase64 = sendOptions.imageBase64;
      }

      const invokeWithRetry = async () => {
        let lastError: unknown;
        for (let attempt = 0; attempt < 2; attempt += 1) {
          try {
            return await chatProvider.invoke(
              character,
              trimmed,
              optimisticSnapshot,
              invokeOptions,
            );
          } catch (err) {
            lastError = err;
            // OnDevice 미준비 / 토큰 부족 같은 구조적 에러는 재시도 의미 없음.
            if (
              err instanceof OnDeviceNotReadyError ||
              err instanceof RemoteTokenConsumeError
            ) {
              throw err;
            }
            if (attempt < 1) {
              await new Promise((r) => setTimeout(r, 900));
            }
          }
        }
        throw lastError;
      };

      let response;
      try {
        response = await invokeWithRetry();
      } catch (providerError) {
        if (
          providerError instanceof OnDeviceNotReadyError &&
          chatProvider.getProviderName() === 'on-device'
        ) {
          if (providerError.status === 'not-downloaded') {
            onDeviceLLMEngine.startDownload().catch(() => undefined);
          }
          // 온디바이스 실패 → 같은 메시지 그대로 클라우드 재시도 (롤백 없음)
          if (session) {
            await consumeRemoteTokens(session, {
              fortuneType: 'character-chat',
              referenceId: `story:${character.id}`,
            }).catch(() => undefined);
          }
          response = await cloudChatProvider.invoke(
            character,
            trimmed,
            optimisticSnapshot,
            invokeOptions,
          );
        } else {
          throw providerError;
        }
      }

      // F2 — 서버 응답 도착. 랜덤 지연 타이머보다 먼저 오면 읽음 즉시 처리.
      markUserMessageReadImmediately(character.id);

      // 최신 assistant emotion 추적 (F4 presence 라인에 반영)
      if (response.emotionTag) {
        lastAssistantEmotionTagRef.current = response.emotionTag;
      }

      // Random reply delay — typing indicator stays visible during wait (첫 버블 전 딜레이)
      const replyDelay = response.delaySec
        ? Math.min(response.delaySec, 8)
        : Math.random() * 2 + 1; // 1-3초 기본 딜레이
      await new Promise((r) => setTimeout(r, replyDelay * 1000));

      // 최신 유저 메시지 읽음 처리 — 현재 state 기준으로 찍어야 큐잉된 다음
      // 메시지들을 덮어쓰지 않는다.
      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: markLatestUserMessageAsRead(
          current[character.id] ?? [],
        ),
      }));
      // F1 — segments 순차 enqueue. 단일 세그먼트는 하위 호환 동일 동작.
      const segments = response.segments ?? [response.response.trim()];
      const nextMessages = await enqueueAssistantSegments({
        characterId: character.id,
        segments,
        emotionTag: response.emotionTag,
      });
      const nextSnapshot = buildNextStoryThreadSnapshot(
        optimisticSnapshot,
        character,
        nextMessages,
        response,
        storyRequest,
      );

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
      if (error instanceof OnDeviceNotReadyError) {
        // 온디바이스 미준비 시: 팝업 없이 백그라운드 다운로드만 트리거.
        // 유저가 다시 보내면 클라우드 폴백으로 정상 동작함.
        if (error.status === 'not-downloaded') {
          onDeviceLLMEngine.startDownload().catch(() => undefined);
        }
        shouldClearDraft = false;
        setDraft(trimmed);
        clearReadReceiptTimer(character.id);
        rollbackUserMessage(character.id, effectiveUserMessageId);
        setStoryThreadSnapshotsByCharacterId((current) => ({
          ...current,
          [character.id]: existingSnapshot,
        }));
        return;
      }

      if (error instanceof RemoteTokenConsumeError) {
        shouldClearDraft = false;
        setDraft(trimmed);
        rollbackUserMessage(character.id, effectiveUserMessageId);
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

      // 에러 폴백에서도 읽음 처리 (더는 기다릴 필요 없음)
      markUserMessageReadImmediately(character.id);
      const fallbackMessage = buildStoryFallbackAssistantMessage(character);
      let nextMessages: ChatShellMessage[] = [];
      setMessagesByCharacterId((current) => {
        const thread = current[character.id] ?? [];
        const merged = [
          ...markLatestUserMessageAsRead(thread),
          fallbackMessage,
        ];
        nextMessages = merged;
        return { ...current, [character.id]: merged };
      });
      const nextSnapshot = buildNextStoryThreadSnapshot(
        optimisticSnapshot,
        character,
        nextMessages,
        null,
        storyRequest,
      );

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
      setStoryTypingByCharacterId((current) =>
        current[character.id]
          ? { ...current, [character.id]: false }
          : current,
      );
      if (shouldClearDraft) {
        setDraft('');
      }
      drainNextPendingSend(character);
    }
  }

  async function sendCharacterChatMessage(
    character: ChatCharacterSpec,
    text: string,
    sendOptions?: { skipOptimisticUserMessage?: boolean; userMessageId?: string },
  ) {
    const trimmed = text.trim();

    if (!trimmed) {
      return;
    }

    const skipOptimistic = sendOptions?.skipOptimisticUserMessage === true;

    const existingThread =
      messagesByCharacterId[character.id] ?? buildInitialThread(character);
    const userMessage = skipOptimistic ? null : buildUserMessage(trimmed);
    const optimisticThread = userMessage
      ? [...existingThread, userMessage]
      : existingThread;
    let shouldClearDraft = !skipOptimistic;

    const effectiveUserMessageId = userMessage?.id ?? sendOptions?.userMessageId;
    if (userMessage) {
      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: [...(current[character.id] ?? []), userMessage],
      }));
    }
    setStoryTypingByCharacterId((current) => ({
      ...current,
      [character.id]: true,
    }));
    scheduleReadReceipt(character.id);
    setComposerTrayOpen(false);
    setSurfaceMode('chat');

    try {
      if (!supabase) {
        const fallbackMessage = buildDraftReply(character, trimmed);
        clearReadReceiptTimer(character.id);
        setMessagesByCharacterId((current) => {
          const thread = current[character.id] ?? [];
          return {
            ...current,
            [character.id]: [
              ...markLatestUserMessageAsRead(thread),
              fallbackMessage,
            ],
          };
        });
        return;
      }

      // 온디바이스/자동 모드에서는 로컬 provider로 시도. 실패 시 같은 메시지를
      // 롤백 없이 그대로 클라우드 경로로 재전송 (아래로 자연 폴백).
      const aiMode = mobileAppState.settings.aiMode;
      if (aiMode !== 'cloud') {
        const chatProvider = resolveChatProvider(aiMode);
        if (chatProvider.getProviderName() === 'on-device') {
          const customPersona = personaByCharacterId[character.id];
          try {
            const response = await chatProvider.invoke(
              character,
              trimmed,
              null,
              customPersona
                ? { userDescription: `[유저 커스텀 성격 요청] ${customPersona}` }
                : undefined,
            );

            markUserMessageReadImmediately(character.id);
            if (response.emotionTag) {
              lastAssistantEmotionTagRef.current = response.emotionTag;
            }

            const replyDelay = response.delaySec
              ? Math.min(response.delaySec, 8)
              : Math.random() * 2 + 1;
            await new Promise((r) => setTimeout(r, replyDelay * 1000));

            setMessagesByCharacterId((current) => ({
              ...current,
              [character.id]: markLatestUserMessageAsRead(
                current[character.id] ?? [],
              ),
            }));
            const segments = response.segments ?? [response.response.trim()];
            const nextMessages = await enqueueAssistantSegments({
              characterId: character.id,
              segments,
              emotionTag: response.emotionTag,
            });
            saveCharacterConversation(character.id, nextMessages).catch(
              (saveError: unknown) => {
                captureError(saveError, {
                  surface: 'chat:character-chat-save-conversation',
                }).catch(() => undefined);
              },
            );
            return;
          } catch (onDeviceError) {
            if (!(onDeviceError instanceof OnDeviceNotReadyError)) {
              throw onDeviceError;
            }
            if (onDeviceError.status === 'not-downloaded') {
              onDeviceLLMEngine.startDownload().catch(() => undefined);
            }
            // 아래 cloud 경로로 fall-through → 같은 메시지 자동 재전송
          }
        }
        // aiMode==='auto' + 온디바이스 미준비 → 아래 cloud 경로로 자연 폴백
      }

      // Skip token consumption for guest users, but still call the server
      if (session) {
        await consumeRemoteTokens(session, {
          fortuneType: 'character-chat',
          referenceId: `character:${character.id}`,
        });

        syncRemoteProfile().catch((error: unknown) => {
          captureError(error, {
            surface: 'chat:character-chat-sync-premium-after-consume',
          }).catch(() => undefined);
        });
      }

      await recordChatIntent({
        characterId: character.id,
        fortuneType: activeFortuneType,
        incrementMessages: true,
      }).catch((error: unknown) => {
        captureError(error, {
          surface: 'chat:character-chat-record-intent',
        }).catch(() => undefined);
      });

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

      const customPersona = personaByCharacterId[character.id];
      const personaSuffix = customPersona ? ` [유저 커스텀 성격 요청] ${customPersona}` : '';

      const conceptType = customFriend
        ? customFriend.relationship === 'crush'
          ? 'crush'
          : customFriend.relationship === 'partner'
            ? 'partner'
            : customFriend.relationship === 'colleague'
              ? 'colleague'
              : 'friend'
        : 'friend';

      const { data, error } = await supabase.functions.invoke('character-chat', {
        body: {
          characterId: character.id,
          characterName: character.name,
          characterTraits: character.shortDescription,
          conceptType,
          systemPrompt: customFriend
            ? `너는 "${character.name}"이다. AI 어시스턴트가 아니라 실제 감정을 가진 사람이다. ${customFriend.scenario ? `상황: ${customFriend.scenario}. ` : ''}성격: ${customFriend.personalityTags.join(', ')}. ${customFriend.memoryNote ? `기억: ${customFriend.memoryNote}. ` : ''}스타일: ${customFriend.stylePreset || '자연스러운 대화'}. 사용자와 ${customFriend.relationship === 'friend' ? '친구' : customFriend.relationship === 'crush' ? '썸 상대' : customFriend.relationship === 'partner' ? '연인' : '동료'} 관계야.${personaSuffix}`
            : `너는 "${character.name}"이다. ${character.shortDescription}.${personaSuffix}`,
          userDescription: customPersona ? `[유저 커스텀 성격 요청] ${customPersona}` : undefined,
          messages: recentMessages,
          userMessage: trimmed,
          userName:
            (session?.user.user_metadata.name as string | undefined) ||
            (session?.user.user_metadata.full_name as string | undefined) ||
            mobileAppState.profile.displayName ||
            'user',
        },
      });

      if (error) {
        throw error;
      }

      const payload = data as {
        response?: string;
        success?: boolean;
        error?: string;
        delaySec?: number;
        emotionTag?: string;
        segments?: unknown;
      } | null;
      if (!payload?.response || (payload.success === false)) {
        throw new Error(payload?.error ?? 'Character chat response is empty.');
      }

      // F2 — 서버 응답 도착. 읽음 즉시 처리.
      markUserMessageReadImmediately(character.id);
      if (typeof payload.emotionTag === 'string' && payload.emotionTag.length > 0) {
        lastAssistantEmotionTagRef.current = payload.emotionTag;
      }

      // Random reply delay — typing indicator stays visible during wait (첫 버블 전)
      const replyDelay = typeof payload.delaySec === 'number'
        ? Math.min(payload.delaySec, 8)
        : Math.random() * 2 + 1;
      await new Promise((r) => setTimeout(r, replyDelay * 1000));

      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: markLatestUserMessageAsRead(
          current[character.id] ?? [],
        ),
      }));
      // F1 — segments 파싱 (없으면 단일 세그먼트로 폴백)
      const rawSegments = Array.isArray(payload.segments)
        ? payload.segments.filter(
            (segment): segment is string =>
              typeof segment === 'string' && segment.trim().length > 0,
          )
        : [];
      const segments =
        rawSegments.length > 0 ? rawSegments : [payload.response.trim()];
      const nextMessages = await enqueueAssistantSegments({
        characterId: character.id,
        segments,
        emotionTag: payload.emotionTag,
      });

      // Persist conversation to remote
      saveCharacterConversation(character.id, nextMessages).catch(
        (saveError: unknown) => {
          captureError(saveError, {
            surface: 'chat:character-chat-save-conversation',
          }).catch(() => undefined);
        },
      );
    } catch (error) {
      if (error instanceof OnDeviceNotReadyError) {
        // 온디바이스 미준비 시: 팝업 없이 백그라운드 다운로드만 트리거.
        if (error.status === 'not-downloaded') {
          onDeviceLLMEngine.startDownload().catch(() => undefined);
        }
        shouldClearDraft = false;
        setDraft(trimmed);
        clearReadReceiptTimer(character.id);
        setMessagesByCharacterId((current) => ({
          ...current,
          [character.id]: existingThread,
        }));
        return;
      }

      if (error instanceof RemoteTokenConsumeError) {
        shouldClearDraft = false;
        setDraft(trimmed);
        clearReadReceiptTimer(character.id);
        rollbackUserMessage(character.id, effectiveUserMessageId);

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

      markUserMessageReadImmediately(character.id);
      const fallbackMessage = buildDraftReply(character, trimmed);

      setMessagesByCharacterId((current) => {
        const thread = current[character.id] ?? [];
        return {
          ...current,
          [character.id]: [
            ...markLatestUserMessageAsRead(thread),
            fallbackMessage,
          ],
        };
      });
    } finally {
      setStoryTypingByCharacterId((current) =>
        current[character.id]
          ? { ...current, [character.id]: false }
          : current,
      );
      if (shouldClearDraft) {
        setDraft('');
      }
      drainNextPendingSend(character);
    }
  }

  function handleSendDraft() {
    const trimmed = draft.trim();
    const pendingImage = pendingImageByCharacterId[selectedCharacter.id];

    // 이미지 첨부가 있으면 여기서 먼저 처리. 사진 + 캡션(있으면) 을 한 번에 보낸다.
    // - 스토리 파일럿 캐릭터: 멀티모달 AI 경로로 imageBase64 전달
    // - 그 외 캐릭터: thread 에 이미지 메시지만 추가 (AI 전달 없음, 기존 동작과 동일)
    if (pendingImage) {
      const imageMessage = buildUserImageMessage(
        pendingImage.uri,
        trimmed || undefined,
      );
      appendMessages(selectedCharacter, [imageMessage]);
      setSurfaceMode('chat');
      setComposerTrayOpen(false);
      if (trimmed) setDraft('');
      handleClearPendingImage();

      recordChatIntent({
        characterId: selectedCharacter.id,
        fortuneType: activeFortuneType,
        incrementMessages: true,
      }).catch((error) => {
        captureError(error, { surface: 'chat:record-photo-send' }).catch(
          () => undefined,
        );
      });

      if (
        pendingImage.base64 &&
        isStoryRomancePilotCharacterId(selectedCharacter.id)
      ) {
        const mimeType = pendingImage.mimeType ?? 'image/jpeg';
        const dataUrl = pendingImage.base64.startsWith('data:')
          ? pendingImage.base64
          : `data:${mimeType};base64,${pendingImage.base64}`;
        void sendStoryPilotMessage(selectedCharacter, trimmed, {
          imageBase64: dataUrl,
        });
      }
      return;
    }

    // Clear input immediately — text is captured in `trimmed`.
    // Error handlers restore draft via setDraft(trimmed) if needed.
    if (trimmed) {
      setDraft('');
    }

    const isStoryCharacter = selectedCharacter.kind === 'story';
    const isBusy =
      isStoryCharacter &&
      storyTypingByCharacterId[selectedCharacter.id] === true;

    // 응답 대기 중에 빈 전송은 중복 트리거 방지를 위해 무시.
    if (isBusy && !trimmed) {
      return;
    }

    // 응답 대기 중 타이핑 → 큐 적재. 유저 메시지는 즉시 thread에 표시.
    if (isBusy && trimmed) {
      enqueueStorySend(selectedCharacter, trimmed);
      return;
    }

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

    const userMsg = buildUserMessage(trimmed);
    const draftMsg = buildDraftReply(selectedCharacter, trimmed);
    appendMessages(selectedCharacter, [userMsg, draftMsg]);
    setComposerTrayOpen(false);
    setSurfaceMode('chat');

    // Persist fortune conversation to remote
    const currentMessages = messagesByCharacterId[selectedCharacter.id] ?? [];
    saveCharacterConversation(selectedCharacter.id, [
      ...currentMessages,
      userMsg,
      draftMsg,
    ]).catch((saveError: unknown) => {
      captureError(saveError, {
        surface: 'chat:fortune-draft-save-conversation',
      }).catch(() => undefined);
    });

    recordChatIntent({
      characterId: selectedCharacter.id,
      fortuneType: activeFortuneType,
      incrementMessages: true,
    }).catch((error) => {
      captureError(error, { surface: 'chat:record-draft' }).catch(
        () => undefined,
      );
    });
  }

  function submitSurveyAnswer(answer: unknown, displayLabel?: string) {
    if (!activeSurvey || !currentSurveyStep) {
      return;
    }

    const step = currentSurveyStep.step;
    const answerLabel =
      displayLabel ?? formatSurveyAnswerLabel(step, answer);

    // 이미지 스텝(관상 등): 썸네일이 보이도록 image 메시지로 전송.
    // answer는 SurveyImagePicker에서 넘어온 raw base64. data URI로 감싸서 <Image source={{uri}}>에 바로 사용.
    // 캡션은 기존 라벨("사진을 보냈어요")을 그대로 유지 — 시각+텍스트 둘 다 보이게.
    if (
      step.inputKind === 'image' &&
      typeof answer === 'string' &&
      answer.length > 0
    ) {
      const dataUri = answer.startsWith('data:')
        ? answer
        : `data:image/jpeg;base64,${answer}`;
      appendMessages(selectedCharacter, [
        buildUserImageMessage(dataUri, answerLabel),
      ]);
    } else {
      appendMessages(selectedCharacter, [buildUserMessage(answerLabel)]);
    }

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
        // 설문 답변 직후 AI 다음 질문이 붙는 순간, 방금 보낸 유저 답변은
        // 읽음 처리되어야 함 ("1" 배지 제거).
        markUserMessageReadImmediately(selectedCharacter.id);
      }
    } else if (completed) {
      markUserMessageReadImmediately(selectedCharacter.id);
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
          aiMode: mobileAppState.settings.aiMode,
        },
      );

      if (payload) {
        return buildEmbeddedResultMessageFromPayload(payload);
      }
    } catch {
      // Edge Function 실패 시 로컬 fallback으로 자동 전환 — 에러 무시
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
            affinity={selectedStorySnapshot?.romanceState?.emotionalTemperature}
            presenceLine={presenceLine}
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
              onOpenPersonaSettings={handleOpenPersonaSettings}
              onPickAction={handleActionPress}
              onSend={handleSendDraft}
              onToggleVoiceInput={handleToggleVoiceInput}
              voiceInputState={voiceInputState}
              onToggleTray={() => setComposerTrayOpen((current) => !current)}
              quickActions={selectedCharacterActions}
              trayOpen={composerTrayOpen}
              hasCustomPersona={Boolean(personaByCharacterId[selectedCharacter.id])}
              pendingImageUri={
                pendingImageByCharacterId[selectedCharacter.id]?.uri
              }
              onRemovePendingImage={handleClearPendingImage}
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
          onEmail={() => router.push('/auth/email')}
          onPhone={() => router.push('/auth/phone')}
        />
      ) : null}

      {gate === 'profile-flow' ? (
        <ProfileFlowGateCard
          birthCompleted={onboardingProgress.birthCompleted}
          firstRunHandoffSeen={onboardingProgress.firstRunHandoffSeen}
          interestCompleted={onboardingProgress.interestCompleted}
          onContinue={() => {
            if (onboardingProgress.birthCompleted && onboardingProgress.interestCompleted) {
              void completeOnboarding();
            } else {
              router.push('/onboarding');
            }
          }}
        />
      ) : null}

      <OnDeviceTransitionToast />

      {gate === 'ready' ? (
        surfaceMode === 'chat' ? (
          <ActiveCharacterChatSurface
            actions={selectedCharacterActions}
            character={selectedCharacter}
            isTyping={selectedStoryIsTyping || selectedFortuneIsTyping}
            pendingQueueCount={
              pendingSendCountByCharacterId[selectedCharacter.id] ?? 0
            }
            messages={selectedThread}
            presenceLine={presenceLine}
            romanceScore={selectedRomanceScore}
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
            onOpenProfile={() => router.push(session ? '/profile' : '/signup')}
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
            romanceScores={romanceScoresByCharacterId}
            selectedCharacterId={selectedCharacter.id}
            metaByCharacterId={characterListMetaById}
          />
        )
      ) : null}

      <Modal
        animationType="slide"
        onRequestClose={() => setPersonaModalOpen(false)}
        transparent
        visible={personaModalOpen}
      >
        <Pressable
          onPress={() => setPersonaModalOpen(false)}
          style={{ flex: 1, backgroundColor: 'rgba(0,0,0,0.5)' }}
        >
          <View style={{ flex: 1 }} />
        </Pressable>
        <View
          style={{
            backgroundColor: fortuneTheme.colors.background,
            borderTopLeftRadius: 20,
            borderTopRightRadius: 20,
            paddingBottom: 40,
            paddingHorizontal: 20,
            paddingTop: 20,
          }}
        >
          <AppText variant="heading3" style={{ marginBottom: 8 }}>
            {selectedCharacter.name}의 성격 설정
          </AppText>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
            style={{ marginBottom: 16 }}
          >
            캐릭터에게 원하는 성격이나 말투를 자유롭게 적어주세요.
            {'\n'}예: "더 츤데레하게", "반말로 해줘", "질투 많이 해줘"
          </AppText>
          <TextInput
            autoFocus
            multiline
            onChangeText={setPersonaDraft}
            placeholder="원하는 성격이나 말투를 적어주세요..."
            placeholderTextColor={fortuneTheme.colors.textTertiary}
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderColor: fortuneTheme.colors.border,
              borderRadius: fortuneTheme.radius.lg,
              borderWidth: 1,
              color: fortuneTheme.colors.textPrimary,
              fontSize: 15,
              minHeight: 100,
              paddingHorizontal: 14,
              paddingVertical: 14,
              textAlignVertical: 'top',
            }}
            value={personaDraft}
          />
          <View
            style={{
              flexDirection: 'row',
              gap: 12,
              justifyContent: 'flex-end',
              marginTop: 16,
            }}
          >
            {personaDraft.trim() ? (
              <Pressable
                onPress={() => {
                  setPersonaDraft('');
                  void handleSavePersona();
                }}
                style={({ pressed }) => ({
                  opacity: pressed ? 0.7 : 1,
                  paddingHorizontal: 16,
                  paddingVertical: 10,
                })}
              >
                <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
                  초기화
                </AppText>
              </Pressable>
            ) : null}
            <Pressable
              onPress={() => void handleSavePersona()}
              style={({ pressed }) => ({
                backgroundColor: fortuneTheme.colors.ctaBackground,
                borderRadius: fortuneTheme.radius.md,
                opacity: pressed ? 0.7 : 1,
                paddingHorizontal: 24,
                paddingVertical: 10,
              })}
            >
              <AppText variant="labelLarge" color="#FFFFFF">
                저장
              </AppText>
            </Pressable>
          </View>
        </View>
      </Modal>
    </Screen>
  );
}
