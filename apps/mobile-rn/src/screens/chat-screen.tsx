import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

import {
  router,
  useFocusEffect,
  useLocalSearchParams,
  type Href,
} from 'expo-router';
import * as Crypto from 'expo-crypto';
import { type FortuneTypeId } from '@fortune/product-contracts';
import { AllFortunesSheet } from '../features/haneul/all-fortunes-sheet';
import { Alert, Dimensions, Keyboard, Modal, Pressable, ScrollView, TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { OnDeviceTransitionToast } from '../components/on-device-transition-toast';
import { PushDeniedBanner } from '../components/push-denied-banner';
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
  getCanonicalVisibleMessages,
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
import {
  fetchEmbeddedEdgeResultPayload,
  isAbortError,
  isAsyncPosterFortuneType,
  lookupCachedFortuneResult,
  startAsyncPosterJob,
} from '../features/chat-results/edge-runtime';
import { resolveResultKindFromFortuneType } from '../features/fortune-results/mapping';
import { captureError } from '../lib/error-reporting';
import {
  buildAssistantTextMessage,
  buildEmbeddedResultMessage,
  buildEmbeddedResultMessageFromPayload,
  buildFortuneCookieMessage,
  buildProgressMessage,
  buildSajuPreviewMessage,
  buildDraftReply,
  buildInitialThread,
  buildLaunchMessages,
  buildSuggestedActions,
  buildUserAudioMessage,
  buildUserImageMessage,
  buildUserMessage,
  formatFortuneTypeLabel,
  type ChatShellAction,
  type ChatShellEmbeddedResultMessage,
  type ChatShellMessage,
  type ChatShellTextMessage,
} from '../lib/chat-shell';
import { POSTER_PHASE_STEPS } from '../lib/long-running-jobs';
import {
  buildChatCharactersWithCustomFriends,
  buildStoryCharactersWithCustomFriends,
  chatCharacters,
  findChatCharacterById,
  fortuneChatCharacters,
  haneulOracleCharacter,
  isCustomFriendCharacter,
  isFortuneChatCharacter,
  storyChatCharacters,
  type ChatCharacterSpec,
  type ChatCharacterTab,
} from '../lib/chat-characters';
import { CostConfirmationSheet } from '../features/fortune-results/cost-confirmation-sheet';
import { findCatalogEntry, type FortuneCatalogEntry } from '@fortune/product-contracts';
import { setChatLastSeenForCharacter } from '../lib/storage';
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
  type StoryChatResponse,
  type StoryChatThreadSnapshot,
} from '../lib/story-chat-runtime';
import {
  OnDeviceNotReadyError,
  cloudChatProvider,
  resolveChatProvider,
} from '../lib/chat-provider';
import { onDeviceLLMEngine } from '../lib/on-device-llm';
import {
  markLatestUserMessageAsRead,
  sleep,
  randomInRange,
} from '../lib/chat-message-utils';
import {
  insertMessages as insertStoreMessages,
  getMessages as getStoreMessages,
  useStoreMessages,
  useStoreMessagesMap,
} from '../lib/message-store';
import { setTyping as setGlobalTyping } from '../lib/typing-store';
import { replyDeliveryController } from '../lib/reply-delivery-controller';
import { useChatMessageController } from '../features/chat-surface/hooks/use-chat-message-controller';
import { useMessageQueue } from '../features/chat-surface/hooks/use-message-queue';
import {
  ackScheduledReplyIfPresent,
  clearActiveChatCharacterId,
  consumePendingProactiveMessageId,
  maybePromptPushPermissionForCharacter,
  setActiveChatCharacterId,
  setAppIconBadgeCount,
} from '../lib/push-notifications';
import { useBlockedCharacterIds } from '../lib/character-blocks';
import { isStoryRomancePilotCharacterId } from '../lib/story-romance-pilots';
import {
  consumeRemoteTokens,
  RemoteTokenConsumeError,
} from '../lib/premium-remote';
// useTextToSpeech 는 useChatTtsHaptics hook 안에서 사용.
import {
  socialAuthProviderLabelById,
  type SocialAuthProviderId,
} from '../lib/social-auth';
import {
  loadCharacterPersona,
  saveCharacterPersona,
} from '../lib/character-persona-store';
import { fortuneTheme } from '../lib/theme';
// loveHeartbeat/tapLight 은 useChatTtsHaptics hook 안에서 사용. 여기엔 phase
// 전환 1회성 scoreReveal 만 남음.
import { scoreReveal } from '../lib/haptics';
import { useChatTtsHaptics } from '../features/chat-surface/hooks/use-chat-tts-haptics';
import { pickPresenceLine } from '../lib/presence-lines';
import { useVoiceInput } from '../lib/use-voice-input';
import { useRewardedAd } from '../lib/ad-rewards';
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

// AC1, AC3 — 메시지 배칭 및 응답 지연 floor.
// 첫 send 후 BATCH_IDLE_WINDOW_MS 동안 추가 send 가 없으면 누적 큐를 단일
// Edge Function 호출로 flush. 5초 idle + 서버 30~600초 지연 조합은 사용자가
// "답을 안 한다"고 인지하는 실제 회귀였으므로, 채팅 UX 는 빠른 피드백을
// 우선한다.
const BATCH_IDLE_WINDOW_MS = 1500;
const REPLY_FLOOR_MS = 4000;
// 서버 (supabase/functions/_shared/reply_delay.ts) 가 보통 4~45초 범위의
// delaySec 를 내려준다. 만약 (장애로) delaySec 가 0/missing 으로 오면 동일한
// 체감 범위로 폴백한다.
const FALLBACK_REPLY_MIN_SEC = 6;
const FALLBACK_REPLY_MAX_SEC = 18;

function randomFallbackReplyDelayMs() {
  return (Math.random() * (FALLBACK_REPLY_MAX_SEC - FALLBACK_REPLY_MIN_SEC) +
    FALLBACK_REPLY_MIN_SEC) * 1000;
}

function computeHumanReplyPhaseDelays(replyDelayMs: number) {
  // 읽음 배지가 수십 초~수분 유지되면 네트워크 장애처럼 보인다. 먼저 1~3.5초
  // 안에 읽음 처리하고, 남은 시간을 "읽고 생각 중 → 입력 중"으로 나눈다.
  const beforeReadMs = Math.min(replyDelayMs * 0.25, randomInRange(1000, 3500));
  const remainingAfterRead = Math.max(0, replyDelayMs - beforeReadMs);
  const typingPreviewMs = Math.min(
    remainingAfterRead,
    replyDelayMs * 0.45,
    randomInRange(1800, 5000),
  );
  const readToTypingMs = Math.max(0, remainingAfterRead - typingPreviewMs);
  return { beforeReadMs, readToTypingMs, typingPreviewMs };
}

/**
 * 미읽음 user kind='text' 메시지 전부에 `readAt`을 도장찍어 돌려준다.
 * AI 응답 시점에 호출되므로, 그 전까지 쌓인 모든 유저 메시지를 한꺼번에
 * 읽음 처리 (연속으로 보낸 경우에도 "1" 배지가 남지 않도록).
 */
// markLatestUserMessageAsRead, sleep, randomInRange 는 lib/chat-message-utils.ts
// 로 이동. import 는 파일 상단 named import 참고.

function getMessageTimestampMs(message: ChatShellMessage): number {
  if ('timestamp' in message && typeof message.timestamp === 'string') {
    const parsed = Date.parse(message.timestamp);
    if (Number.isFinite(parsed)) return parsed;
  }
  return 0;
}

/**
 * 서버 cron 이 character_conversations 에 assistant 답장을 붙였지만 열린 채팅창의
 * 로컬 state/SQLite 가 push 또는 foreground claim 을 놓친 경우를 복구한다.
 *
 * replace 가 아니라 local+remote id union 이라, 사용자가 방금 보낸 optimistic
 * 메시지는 보존하면서 서버에만 있는 scheduled assistant 메시지를 즉시 병합한다.
 */
function mergeRemoteMessagesPreservingLocal(
  local: ChatShellMessage[] | undefined,
  remote: ChatShellMessage[],
): { messages: ChatShellMessage[]; changed: boolean } {
  const base = local ?? [];
  if (remote.length === 0) return { messages: base, changed: false };
  const byId = new Map<string, ChatShellMessage>();
  for (const message of base) byId.set(message.id, message);
  let added = false;
  for (const message of remote) {
    if (!byId.has(message.id)) {
      byId.set(message.id, message);
      added = true;
    }
  }
  if (!added) return { messages: base, changed: false };
  const originalIndex = new Map(base.map((message, index) => [message.id, index]));
  const messages = Array.from(byId.values()).sort((a, b) => {
    const at = getMessageTimestampMs(a);
    const bt = getMessageTimestampMs(b);
    if (at !== bt) return at - bt;
    return (originalIndex.get(a.id) ?? Number.MAX_SAFE_INTEGER) -
      (originalIndex.get(b.id) ?? Number.MAX_SAFE_INTEGER);
  });
  return { messages, changed: true };
}

/**
 * 채팅 영속/읽음 정책 (2026-04-30 SQLite 마이그레이션 후):
 *  1) 메시지: SQLite (`apps/mobile-rn/src/lib/chat-db.ts`, 파일명 `fortune-chat.db`).
 *     Native(iOS/Android) 는 row-per-message append-only INSERT, web 은 기존
 *     SecureStore `fortune.chat.msgs.v1.*` 폴백 유지. bootstrap preload
 *     (`cachedCharacterConversations`) 가 batch SELECT 로 한 번에 로드.
 *     1회 백필: 첫 SQLite open 시 SecureStore 캐시 → SQLite INSERT, 성공
 *     하면 SecureStore 키 삭제 + `fortune.chat.db.migrated.v1` 플래그 set.
 *     원격 동기화 (`character-conversation-save/load` Edge Function) 는
 *     변경 없음 — SQLite 가 source of truth, 원격은 백업·기기간 복원용.
 *  2) 스토리 스냅샷: SecureStore
 *     `fortune.mobile-rn.story-chat-thread.v1.{userId}.{characterId}` —
 *     character open 시 lazy hydrate. romance state 포함 전체 snapshot.
 *     (메시지 부분은 SQLite 가 별도로 저장하므로 중복이지만 romance state
 *     스키마와 분리하기 위해 유지.)
 *  3) 읽음 상태: SecureStore `fortune.chat-last-seen.v1` — bootstrap preload
 *     (`cachedLastSeenByCharacterId`) 로 race 방지. 직렬화 큐로 concurrent
 *     write merge 보장 (`storage.ts:setChatLastSeenForCharacter`).
 *  4) Unread 계산: `chat-surface.buildCharacterListMeta`. lastSeen ID 가
 *     현재 메시지 배열에 없으면 "이미 다 읽음" 으로 보수적 fallback (시스템
 *     사정으로 ID 가 사라진 케이스에서 전체 unread 회귀 방지).
 *  5) 디버그: 프로필 화면 하단 `formatBuildBadge()` 에서 OTA 적용 여부 확인.
 */
export function ChatScreen() {
  const params = useLocalSearchParams<{ characterId?: string | string[]; showList?: string | string[] }>();
  const directCharacterId = readSearchParam(params.characterId);
  const forceListMode = readSearchParam(params.showList) === '1';
  const directCharacter = findChatCharacterById(directCharacterId);
  const {
    cachedCharacterConversations,
    cachedLastSeenByCharacterId,
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
  // 한도 도달 paywall 에서 "광고 보고 토큰" 옵션 제공. 광고 비활성 / 미준비
  // 시 isReady=false 라 alert 분기에서 자동 숨김.
  const rewardedAd = useRewardedAd({
    session,
    userId: session?.user.id ?? null,
    onReward: (outcome) => {
      if (outcome.success && outcome.tokensGranted) {
        // 잔액 갱신은 premium-remote 가 다음 fetch 시 반영. 여기선 토스트만.
        Alert.alert(
          '🎁 토큰 획득',
          `광고 시청으로 ${outcome.tokensGranted} 토큰을 받았어요.`,
        );
      }
    },
  });
  const [activeFortuneType, setActiveFortuneType] =
    useState<FortuneTypeId | null>(null);
  const [activeProviderId, setActiveProviderId] =
    useState<SocialAuthProviderId | null>(null);
  const [authMessage, setAuthMessage] = useState<string | null>(null);
  // draft (입력창 텍스트) 는 반드시 캐릭터별 격리 — 캐릭터 전환 시 다른 캐릭터의
  // 입력 잔여 텍스트가 새어나오면 안 됨. setDraft 는 현재 selectedCharacterId
  // 를 ref 로 읽어서 stale closure 회피.
  const [draftsByCharacterId, setDraftsByCharacterId] = useState<
    Record<string, string>
  >({});
  // surveyDraft / surveySelections 도 캐릭터별 격리 (입력창 draft 와 동일 이유).
  const [surveyDraftsByCharacterId, setSurveyDraftsByCharacterId] = useState<
    Record<string, string>
  >({});
  const [surveySelectionsByCharacterId, setSurveySelectionsByCharacterId] =
    useState<Record<string, string[]>>({});
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
  const [pendingAudioByCharacterId, setPendingAudioByCharacterId] = useState<
    Record<string, { uri: string; durationMillis?: number }>
  >({});
  const audioRecordingRef = useRef<import('expo-av').Audio.Recording | null>(null);
  const [recordingAudioForCharacterId, setRecordingAudioForCharacterId] = useState<string | null>(null);
  const [personaModalOpen, setPersonaModalOpen] = useState(false);
  const [personaDraft, setPersonaDraft] = useState('');
  const [personaByCharacterId, setPersonaByCharacterId] = useState<
    Record<string, string>
  >({});
  const chatScrollRef = useRef<ScrollView | null>(null);
  // 하늘이 통합 후: 채팅 리스트는 항상 'story' 뷰. fortuneChatCharacters
  // 는 deprecated (마르코/닥터마인드 등 더 이상 노출 안 함). activeTab state
  // 자체는 deep link / inner 분기 일부에 남아있지만 list 화면은 무조건 story.
  const [activeTab, setActiveTab] = useState<ChatCharacterTab>('story');
  const [selectedCharacterId, setSelectedCharacterId] = useState<string | null>(
    null,
  );
  // selectedCharacterId 의 최신 값을 ref 로 미러링 — async closure / useCallback
  // 안에서 stale state 회피용. setDraft / setSurveyDraft 가 사용.
  const selectedCharacterIdRef = useRef<string | null>(null);
  selectedCharacterIdRef.current = selectedCharacterId;

  // draft (입력창 텍스트) 캐릭터별 격리. 캐릭터 전환 시 다른 캐릭터 draft 안 새어나옴.
  const draft = selectedCharacterId
    ? (draftsByCharacterId[selectedCharacterId] ?? '')
    : '';
  const setDraft = useCallback(
    (value: string | ((prev: string) => string)) => {
      const id = selectedCharacterIdRef.current;
      if (!id) return;
      setDraftsByCharacterId((prev) => {
        const current = prev[id] ?? '';
        const next = typeof value === 'function' ? value(current) : value;
        if (next === current) return prev;
        return { ...prev, [id]: next };
      });
    },
    [],
  );

  // surveyDraft (서베이 텍스트 답변) 도 동일 패턴.
  const surveyDraft = selectedCharacterId
    ? (surveyDraftsByCharacterId[selectedCharacterId] ?? '')
    : '';
  const setSurveyDraft = useCallback(
    (value: string | ((prev: string) => string)) => {
      const id = selectedCharacterIdRef.current;
      if (!id) return;
      setSurveyDraftsByCharacterId((prev) => {
        const current = prev[id] ?? '';
        const next = typeof value === 'function' ? value(current) : value;
        if (next === current) return prev;
        return { ...prev, [id]: next };
      });
    },
    [],
  );

  // surveySelections (서베이 chip 다중 선택) 도 동일 패턴.
  const surveySelections = selectedCharacterId
    ? (surveySelectionsByCharacterId[selectedCharacterId] ?? [])
    : [];
  const setSurveySelections = useCallback(
    (value: string[] | ((prev: string[]) => string[])) => {
      const id = selectedCharacterIdRef.current;
      if (!id) return;
      setSurveySelectionsByCharacterId((prev) => {
        const current = prev[id] ?? [];
        const next = typeof value === 'function' ? value(current) : value;
        if (next === current) return prev;
        return { ...prev, [id]: next };
      });
    },
    [],
  );

  const [surfaceMode, setSurfaceMode] = useState<SurfaceMode>(() =>
    !forceListMode && directCharacterId ? 'chat' : 'list',
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
  // bootstrap 이 SecureStore 에서 미리 로드한 lastSeen 으로 초기화. mount
  // 후 비동기 hydrate 로 미루면 첫 렌더링 동안 빈 객체로 unread 가 계산되어
  // cold-start 직후 모든 캐릭터에 unread 닷이 일시적으로 깜빡인다 (race).
  const [lastSeenByCharacterId, setLastSeenByCharacterId] = useState<
    Record<string, string>
  >(cachedLastSeenByCharacterId);

  // useState lazy init 은 mount 시점에 한 번만 실행된다. cold start 에서
  // chat-screen 이 bootstrap 의 `Promise.all(loadCachedCharacterMessagesBatch)`
  // 보다 먼저 mount 되면 (= 거의 항상), `cachedCharacterConversations` 가
  // 빈 객체 `{}` 인 상태로 초기값이 평가되어 모든 캐릭터가 인트로 fallback
  // 으로 고착된다. 그 후 bootstrap 이 캐시를 채워도 messagesByCharacterId
  // state 는 자동 갱신되지 않아 "재진입 시 이전 대화가 사라지는" 회귀 발생.
  //
  // 이 effect 는 cachedCharacterConversations 가 채워지는 시점에 캐시를
  // state 로 흡수하되, `shouldAcceptRemoteMessages` 로 "캐시가 현재 state
  // 보다 더 길거나 더 최신" 일 때만 채택한다 → 사용자가 입력 중인 신규
  // 메시지를 절대 잃지 않는다.
  useEffect(() => {
    setMessagesByCharacterId((current) => {
      let next: Record<string, ChatShellMessage[]> | null = null;
      for (const [characterId, cached] of Object.entries(
        cachedCharacterConversations,
      )) {
        if (!cached || cached.length === 0) continue;
        const existing = current[characterId];
        const merged = mergeRemoteMessagesPreservingLocal(existing, cached);
        if (!merged.changed) continue;
        if (!next) next = { ...current };
        next[characterId] = merged.messages;
      }
      return next ?? current;
    });
  }, [cachedCharacterConversations]);

  // MessageStore → useState 단방향 sync (Step 2.A).
  //
  // 푸시 도착 시 push-handler 가 store.insertMessages 호출 → store 변경 →
  // useStoreMessages re-render → 이 effect 가 useState 갱신 → 화면 즉시 reflect.
  // iMessage/WhatsApp/KakaoTalk 표준 — 채팅창에 머무는 동안 새 메시지 자동 등장.
  //
  // 단방향 (store → useState) 인 이유: chat-screen 의 send/append 는 여전히
  // useState 가 source 이고 (옛 흐름 유지), store 에는 bridge 로 sync 만 됨.
  // 두 source 가 같은 메시지 (id 동일) 면 store 가 더 길 수 없어 no-op.
  // 다른 메시지 (push 로 도착한 새 메시지) 면 store len > useState len 으로 진입.
  //
  // **CRITICAL — cross-character leak 방지**:
  //   useStoreMessages 가 반환하는 snapshot 은 (characterId, messages) tuple
  //   이라 호출 측이 identity 검증 가능. 캐릭터 A→B 전환 순간 hook 의 stale
  //   캐시에서 A.messages 가 잠깐 반환되더라도 snapshot.characterId === 'A'
  //   여서 selectedCharacterId === 'B' 와 mismatch — 적용 SKIP. 다음 렌더에서
  //   B 의 정확한 데이터로 다시 시도. (이전 구조: messages-only 반환 →
  //   selectedCharacterId='B' + messages=A.messages 로 messagesByCharacterId
  //   ['B'] 에 A 의 데이터를 잘못 써 넣어 손금가이드 결과 이미지 등이 다른
  //   캐릭터 채팅창에 누출되던 1.0.11 production 버그.)
  //
  // 다음 phase 에서 useState 자체를 store 로 대체. 그때까지는 mirror sync.
  const storeSnapshot = useStoreMessages(selectedCharacterId);
  useEffect(() => {
    if (!selectedCharacterId) return;
    // Identity 검증 — snapshot 이 현재 활성 캐릭터의 것이 맞는지 반드시 확인.
    // 다른 캐릭터의 stale snapshot 이 현재 active id 와 짝지어지면 누출 발생.
    if (storeSnapshot.characterId !== selectedCharacterId) return;
    const storeMessagesForActive = storeSnapshot.messages;
    if (storeMessagesForActive.length === 0) return;
    setMessagesByCharacterId((prev) => {
      const existing = prev[selectedCharacterId] ?? [];

      // Store is a mirror, not an authority that may truncate/replace the active
      // in-memory thread. Real phones can receive a delayed store snapshot after
      // claim-scheduled-reply already rendered the assistant bubble; replacing by
      // length/equal-length-different-tail makes the bubble appear while typing,
      // then disappear. Always union by id and only append store-only messages.
      const merged = mergeRemoteMessagesPreservingLocal(
        existing,
        storeMessagesForActive,
      );
      if (merged.changed) {
        return { ...prev, [selectedCharacterId]: merged.messages };
      }

      // store 가 짧아진 경우: 원래 grow-only 라 in-flight send/append truncate
      // race 를 방어하던 자리. 단 ProgressMessageCard.useSelfReconcile 이 자기
      // 자신을 store 에서 deleteMessages 한 케이스는 반영돼야 한다 (그래야 진행
      // 카드가 화면에서 사라짐). 따라서 'progress' kind 만 prune, 다른 kind 는
      // 기존대로 보존.
      const storeIds = new Set(storeMessagesForActive.map((m) => m.id));
      const pruned = existing.filter(
        (m) => storeIds.has(m.id) || m.kind !== 'progress',
      );
      if (pruned.length === existing.length) return prev;
      return { ...prev, [selectedCharacterId]: pruned };
    });
  }, [storeSnapshot, selectedCharacterId]);

  // 스레드 체류 중 새 AI/system 메시지 도착 → 즉시 읽음 처리.
  // 일반 메신저(iMessage/WhatsApp/KakaoTalk) 와 동일한 동작: 유저가 해당
  // 스레드를 보고 있는 동안 상대 메시지가 오면 수신과 동시에 "읽음".
  // handleCharacterSelect 가 진입 시점에 1회 lastSeen 을 찍지만, 그 이후에
  // 도착하는 메시지는 여기서 follow-up 으로 갱신해야 리스트 닷이 안 생김.
  useEffect(() => {
    if (surfaceMode !== 'chat') return;
    const charId = selectedCharacterId;
    if (!charId) return;
    const storeThread =
      storeSnapshot.characterId === charId ? storeSnapshot.messages : [];
    const thread = storeThread.length > 0
      ? storeThread
      : messagesByCharacterId[charId];
    if (!thread || thread.length === 0) return;
    const canonicalThread = getCanonicalVisibleMessages(thread);
    const latest = canonicalThread[canonicalThread.length - 1];
    // user 가 보낸 메시지면 굳이 갱신 필요 없음 (본인이 방금 보낸 것).
    if (latest.sender !== 'assistant' && latest.sender !== 'system') return;
    const currentSeen = lastSeenByCharacterId[charId];
    if (currentSeen === latest.id) return;
    setLastSeenByCharacterId((current) => ({
      ...current,
      [charId]: latest.id,
    }));
    setChatLastSeenForCharacter(charId, latest.id).catch((error) => {
      captureError(error, { surface: 'chat:last-seen-flush' }).catch(
        () => undefined,
      );
    });
  }, [
    surfaceMode,
    selectedCharacterId,
    storeSnapshot,
    messagesByCharacterId,
    lastSeenByCharacterId,
  ]);

  // 활성 채팅창에 있을 때 같은 캐릭터 OS push alert 차단.
  // chat surface 진입 = banner/sound noise 제거 (메시지 자체는 채팅에 정상 표시).
  // expo-notifications handleNotification 은 foreground 일 때만 호출되므로
  // background 시점은 별도 clear 불필요 — 그땐 OS 가 알림 표시하는 게 정상.
  useEffect(() => {
    if (surfaceMode === 'chat' && selectedCharacterId) {
      setActiveChatCharacterId(selectedCharacterId);
      return () => {
        clearActiveChatCharacterId();
      };
    }
    clearActiveChatCharacterId();
    return undefined;
  }, [surfaceMode, selectedCharacterId]);

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
  // 여기 큐에 쌓이고, 5초 idle 후 단일 Edge Function 호출로 묶어서 보낸다.
  // 비동기 finally/타이머에서 최신값을 참조해야 해서 state 대신 ref로 관리.
  const pendingSendsRef = useRef<
    Record<string, { text: string; userMessageId: string }[]>
  >({});
  // 배칭 idle 타이머 (캐릭터별). reset 가능. unmount/캐릭터 전환 시 정리.
  const batchTimersRef = useRef<
    Record<string, ReturnType<typeof setTimeout> | null>
  >({});
  // 배치의 첫 send 시각 (캐릭터별). 응답 floor 계산용 (AC1) — 첫 send 부터
  // REPLY_FLOOR_MS 가 지나야 응답이 화면에 나오도록 보장.
  const batchFirstSendAtRef = useRef<Record<string, number>>({});
  // UI 노출용 큐 카운트. 배칭은 사용자에게 투명해야 하므로 항상 0 유지 (AC4).
  // state 자체는 surface prop 시그니처 호환을 위해 남겨둠.
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
    currentVolume: voiceVolume,
    toggleRecording: toggleVoiceRecording,
  } = useVoiceInput({ onTranscript: handleVoiceTranscript });

  useEffect(() => {
    if (!pendingChatFortuneType) {
      return;
    }

    // 하늘이 통합 후: deep link로 fortuneType 들어와도 haneul_oracle 로 라우팅.
    // 'fortune' tab 자체가 사라졌고 운세는 하늘이 단독.
    setActiveFortuneType(pendingChatFortuneType);
    setActiveTab('story');
    setSelectedCharacterId(haneulOracleCharacter.id);
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

    // 하늘이 통합 후: 사주 컨텍스트 카드는 하늘이 채팅으로 라우팅.
    // (deprecated fortune characters 더 이상 노출 X)
    const targetCharacterId =
      selectedCharacterId ??
      mobileAppState.chat.selectedCharacterId ??
      haneulOracleCharacter.id;

    setActiveTab('story');
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
      // Step G: store sync — store id-dedup 으로 멱등.
      insertStoreMessages(targetCharacterId, [message]).catch(() => undefined);
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
            // story snapshot 이 비어있어도 (`fortune.mobile-rn.story-chat-thread.v1`
            // 미스 OR JSON 손상 OR 원격도 빈 응답) bootstrap 이 preload 한 텍스트
            // 메시지 캐시(`fortune.chat.msgs.v1.*`) 에 과거 대화가 남아 있을 수
            // 있다. 인트로만 보여주는 회귀를 막기 위해 캐시된 메시지가 있으면
            // 그걸로 messagesByCharacterId 를 보강한다 (romance state 는 누락).
            const cachedMessages = cachedCharacterConversations[characterId];
            if (cachedMessages && cachedMessages.length > 0) {
              setMessagesByCharacterId((current) => {
                const cur = current[characterId];
                const merged = mergeRemoteMessagesPreservingLocal(
                  cur,
                  cachedMessages,
                );
                if (!merged.changed) {
                  return current;
                }
                return { ...current, [characterId]: merged.messages };
              });
              // Step G: store sync — 다른 화면 (chat list 등) 도 즉시 reflect.
              // Non-destructive: dedup-append. 절대 REPLACE 금지 — 원격이 in-flight
              // (push 도착 메시지, 막 보낸 user 메시지) 보다 짧을 수 있어 store
              // /SQLite 를 REPLACE 하면 그 메시지들이 사라진다 (Bug 2 회귀).
              insertStoreMessages(characterId, cachedMessages).catch(
                () => undefined,
              );
            }
            return;
          }

          setMessagesByCharacterId((current) => {
            const cur = current[characterId];
            const merged = mergeRemoteMessagesPreservingLocal(
              cur,
              snapshot.messages,
            );
            if (!merged.changed) {
              return current;
            }
            return { ...current, [characterId]: merged.messages };
          });
          // 원격 hydrate 도 dedup-append. REPLACE 하면 in-flight (push/optimistic)
          // 메시지가 사라진다.
          insertStoreMessages(characterId, snapshot.messages).catch(
            () => undefined,
          );
          setStoryThreadSnapshotsByCharacterId((current) => ({
            ...current,
            [characterId]: snapshot,
          }));
          return;
        }

        // All other characters: load messages only
        const messages = await loadCharacterConversation(characterId);

        if (!messages) {
          // 원격이 null (네트워크/세션/빈 응답) 이어도 로컬 캐시
          // (`fortune.chat.msgs.v1.*`) 에 이전 대화가 살아있을 수 있다.
          // romance pilot 분기와 동일하게 fallback 해서 인트로만 보이는
          // 회귀를 막는다. shouldAcceptRemoteMessages 로 in-flight 신규
          // 메시지는 보존.
          const cachedMessages = cachedCharacterConversations[characterId];
          if (cachedMessages && cachedMessages.length > 0) {
            setMessagesByCharacterId((current) => {
              const cur = current[characterId];
              const merged = mergeRemoteMessagesPreservingLocal(
                cur,
                cachedMessages,
              );
              if (!merged.changed) {
                return current;
              }
              return { ...current, [characterId]: merged.messages };
            });
            // Non-destructive: dedup-append. REPLACE 하면 in-flight 메시지
            // (push 본문, 막 보낸 user_msg) 가 store/SQLite 에서 사라진다.
            insertStoreMessages(characterId, cachedMessages).catch(
              () => undefined,
            );
          }
          return;
        }

        setMessagesByCharacterId((current) => {
          const cur = current[characterId];
          const merged = mergeRemoteMessagesPreservingLocal(cur, messages);
          if (!merged.changed) {
            return current;
          }
          return { ...current, [characterId]: merged.messages };
        });
        // 원격 hydrate 도 dedup-append. REPLACE 절대 금지 (Bug 2 회귀 방지).
        insertStoreMessages(characterId, messages).catch(() => undefined);
      } catch (error) {
        // Remove from set so it can be retried
        hydratedCharacterIdsRef.current.delete(characterId);
        await captureError(error, {
          surface: 'chat:hydrate-story-character',
        }).catch(() => undefined);
      }
    },
    // bootstrap 이 채워주는 텍스트 메시지 캐시를 fallback 분기에서 참조하므로
    // 의존성에 포함. 다운스트림 useEffect 들은 이 콜백을 dep 으로 갖지만
    // 호출은 hydratedCharacterIdsRef 로 dedupe 되어 중복 작업이 발생하지 않는다.
    [cachedCharacterConversations],
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
      // 챗 룸 안(detail) 에서는 force-refresh 스킵. 일반 메신저앱처럼 in-memory
      // + SQLite 가 source of truth. 캐릭터 프로필 등에서 돌아올 때 visible
      // flicker (응답 사라짐 → 재로드) 회귀 방지. 리스트 화면 복귀일 때만 새로고침.
      if (surfaceMode !== 'list') return;
      for (const character of chatCharacters) {
        void hydrateStoryCharacter(character.id, { force: true });
      }
    }, [gate, surfaceMode, hydrateStoryCharacter]),
  );

  useEffect(() => {
    if (gate !== 'ready') return;
    if (surfaceMode !== 'list') return;
    for (const character of chatCharacters) {
      void hydrateStoryCharacter(character.id, { force: true });
    }
  }, [gate, surfaceMode, hydrateStoryCharacter]);

  // 하늘이는 fortune 탭 폐지 이후 운세 진입의 단일 통합 캐릭터다.
  // chat-characters.ts:147 의 정리("haneul_enabled flag 게이팅이 있었지만 fortune
  // 탭 자체가 사라져서 단순화") 에 맞춰 채팅 리스트에서 항상 노출.
  // 이전 flag 게이트는 flag fetch 실패 / 새 cold start timing 으로 false 가 흘러
  // 들어가면 채팅 리스트에서 하늘이가 사라지고 + 버튼(allChatCharacters) 에서만
  // 보이는 회귀의 원인이었다. allChatCharacters 와 동일하게 항상 포함.
  const allStoryCharacters = useMemo(
    () => [
      ...buildStoryCharactersWithCustomFriends(createdFriends),
      haneulOracleCharacter,
    ],
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
  // 하늘이 통합 후: 운세 캐릭터는 하늘이 단독. 기존 fortuneChatCharacters
  // (마르코, 닥터마인드 등) 는 채팅 리스트에 노출 안 함. activeTab='fortune'
  // state 는 deeplink/내부 분기에 남아있지만 리스트는 항상 story+하늘이.
  const tabCharacters = allStoryCharacters;
  const defaultCharacter =
    highlightedExpert ??
    tabCharacters[0] ??
    allStoryCharacters[0] ??
    allChatCharacters[0];
  const selectedCharacter = useMemo(() => {
    const targetId =
      selectedCharacterId ??
      directCharacterId ??
      mobileAppState.chat.selectedCharacterId;

    const resolved = findChatCharacterById(targetId, createdFriends);

    // 하늘이 통합 후: 기존 fortune 캐릭터 (fortune_haneul, fortune_muhyeon, ...)
    // 가 selected 로 복원되면 사용자가 dead character 진입 = 회귀. 강제 폴백.
    // 새 통합 fortune entry 인 'haneul_oracle' 은 그대로 통과.
    const isDeprecatedFortune =
      resolved?.kind === 'fortune' && resolved.id !== 'haneul_oracle';

    return (
      (isDeprecatedFortune ? null : resolved) ??
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

  const storeMessageCharacterIds = useMemo(
    () => Array.from(new Set(tabCharacters.map((character) => character.id))),
    [tabCharacters],
  );
  const storeMessagesByCharacterId = useStoreMessagesMap(storeMessageCharacterIds);

  // 화면 read 모델은 MessageStore 를 우선한다. push/list/chat/badge 가 같은
  // 배열을 보도록 하고, 아직 store 에 실제 대화가 없는 신규 캐릭터만 기존
  // intro/useState fallback 을 쓴다.
  const displayMessagesByCharacterId = useMemo(() => {
    const next: Record<string, ChatShellMessage[]> = { ...messagesByCharacterId };
    for (const [characterId, storeMessages] of Object.entries(
      storeMessagesByCharacterId,
    )) {
      if (storeMessages.length > 0) {
        next[characterId] = storeMessages;
      }
    }
    return next;
  }, [messagesByCharacterId, storeMessagesByCharacterId]);

  // 자동 라우팅 마운트 1회만 — 한번 라우팅 결정한 후엔 사용자 탭 전환 등으로
  // 재실행되어 강제 복귀되지 않도록 ref 가드. 회귀: 사용자가 스토리 탭 chip 을
  // 눌러 list 모드로 가려고 해도 highlightedExpert 가 남아있으면 effect 재실행
  // 시 surfaceMode='chat' 으로 강제 되돌리는 버그 발견 → 1회만 적용.
  const initialRouteAppliedRef = useRef(false);
  useEffect(() => {
    if (initialRouteAppliedRef.current) {
      // directCharacterId 가 새로 들어오면 (push tap → /chat?characterId=X) 예외
      // — 사용자가 push 탭으로 명시적 진입했으므로 chat 모드 강제 OK.
      if (directCharacterId) {
        setSelectedCharacterId(directCharacterId);
        setActiveTab(directCharacter?.kind ?? 'story');
        setSurfaceMode('chat');
      }
      return;
    }
    initialRouteAppliedRef.current = true;

    if (directCharacterId) {
      setSelectedCharacterId(directCharacterId);
      setActiveTab(directCharacter?.kind ?? 'story');
      setSurfaceMode('chat');
      return;
    }

    if (highlightedExpert) {
      // 하늘이 통합 후: highlightedExpert (deprecated fortune character) 대신
      // haneul_oracle 로 라우팅. 운세 처리는 하늘이 단독.
      setSelectedCharacterId(haneulOracleCharacter.id);
      setActiveTab('story');
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

  const selectedThread = displayMessagesByCharacterId[selectedCharacter.id] ?? [];
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
  const [fortuneGenerationCancellableByCharacterId, setFortuneGenerationCancellableByCharacterId] =
    useState<Record<string, boolean>>({});
  const fortuneGenerationCancellableRef = useRef<Record<string, boolean>>({});
  const fortuneGenerationControllersRef = useRef<Record<string, AbortController | undefined>>({});
  const selectedStoryIsTyping =
    storyTypingByCharacterId[selectedCharacter.id] === true;
  const selectedFortuneIsTyping = fortuneTypingCharacterId === selectedCharacter.id;
  const selectedFortuneGenerationCanCancel =
    fortuneGenerationCancellableByCharacterId[selectedCharacter.id] === true;
  const activeRemoteReconcileInFlightRef = useRef(false);

  // 열린 채팅방 remote reconcile.
  // 서버 cron(deliver-due-replies)이 답장을 character_conversations 에 이미 붙였는데
  // foreground claim/push/store bridge 를 놓치면 사용자는 "계속 대답 안 함"으로 본다.
  // 리스트로 나갔다 와야만 force hydrate 되던 구멍을, 활성 채팅방에서도 보강한다.
  useEffect(() => {
    if (gate !== 'ready') return;
    if (surfaceMode !== 'chat') return;
    if (!session) return;
    if (!selectedCharacter?.id) return;
    if (isFortuneChatCharacter(selectedCharacter)) return;

    const characterId = selectedCharacter.id;
    let stopped = false;

    const reconcile = async () => {
      if (stopped || activeRemoteReconcileInFlightRef.current) return;
      const local = displayMessagesByCharacterId[characterId] ?? [];
      const canonicalLocal = getCanonicalVisibleMessages(local);
      const latest = canonicalLocal[canonicalLocal.length - 1];
      const shouldPoll =
        latest?.sender === 'user' ||
        storyTypingByCharacterId[characterId] === true ||
        selectedCharacterId === characterId;
      if (!shouldPoll) return;

      activeRemoteReconcileInFlightRef.current = true;
      try {
        // Active-chat reconciliation must read the canonical server conversation
        // directly. For story-romance pilots (luts 포함), `loadStoryThreadSnapshot`
        // can involve stale SecureStore snapshots; using it here can make a freshly
        // rendered scheduled reply disappear on real phones. The server truth for
        // delivered assistant bubbles is `character_conversations`.
        const remote = await loadCharacterConversation(characterId);
        if (stopped || !remote || remote.length === 0) return;

        const merged = mergeRemoteMessagesPreservingLocal(local, remote);
        if (!merged.changed) return;

        setMessagesByCharacterId((current) => {
          const currentLocal = current[characterId] ?? [];
          const currentMerged = mergeRemoteMessagesPreservingLocal(
            currentLocal,
            remote,
          );
          if (!currentMerged.changed) return current;
          return { ...current, [characterId]: currentMerged.messages };
        });
        // Never replace SQLite from an async reconcile based on a stale closure:
        // if the user sent another message while the request was in flight, replace
        // can erase that in-memory/store message. Append/dedupe the server-only
        // messages instead.
        await insertStoreMessages(characterId, remote);
      } catch (error) {
        captureError(error, {
          surface: 'chat:active-remote-reconcile',
        }).catch(() => undefined);
      } finally {
        activeRemoteReconcileInFlightRef.current = false;
      }
    };

    void reconcile();
    const interval = setInterval(() => {
      void reconcile();
    }, 15_000);

    return () => {
      stopped = true;
      clearInterval(interval);
    };
  }, [
    gate,
    surfaceMode,
    session,
    selectedCharacter,
    selectedCharacter?.id,
    selectedCharacterId,
    displayMessagesByCharacterId,
    storyTypingByCharacterId,
  ]);

  // 캐릭터 음성 재생 (Gemini TTS) + 응답 햅틱.
  // useChatTtsHaptics hook 안에서 useTextToSpeech 인스턴스 1개 + chatHaptics
  // 토글 ref 관리. chat-screen.tsx 분해 1단계 — TTS/Haptic 책임 격리.
  const {
    tts,
    handlePlayTts,
    handleStopTts,
    triggerAssistantHaptic,
  } = useChatTtsHaptics({
    selectedCharacterId: selectedCharacter.id,
    chatHapticsEnabled: mobileAppState.settings.chatHapticsEnabled,
  });
  const chatMessageController = useChatMessageController({
    setMessagesByCharacterId,
  });
  const lastAssistantEmotionTagRef = useRef<string>('일상');

  // ---------------------------------------------------------------------------
  // 자동 답장 재개 — 채팅방 진입 시 마지막 메시지가 user 면 AI 응답 트리거
  // ---------------------------------------------------------------------------
  // 시나리오: 사용자가 메시지 보낸 직후 앱이 강제 종료/네트워크 끊김 → 다음
  // 진입 시 thread 마지막이 user 메시지인 채로 멈춰 있음. 카톡/iMessage 처럼
  // "내가 마지막인 채로 멈춘 자리에서 자연스럽게 답장이 이어져야" 하므로
  // 진입 시 한 번만 자동으로 send 핸들러를 호출 (skipOptimistic=true 로
  // user 메시지 중복 추가 방지).
  //
  // 서버측 안전망(pending_character_reply_jobs cron, 30초 grace)이 추가된 후엔
  // 이 hook 은 보조 트리거 — 보통 cron 이 먼저 처리해 push 로 답장 도착, 진입
  // 시 last 가 이미 assistant. last 가 여전히 user 인 케이스(앱이 cron 보다
  // 먼저 살아남, 최근 send 직후 진입 등)에서 enqueue RPC 가 idempotent (same
  // user_message_id) 라 중복 row 없이 안전하게 invoke 만 트리거.
  const autoResumedUserMessageIdsRef = useRef<Set<string>>(new Set());
  useEffect(() => {
    if (gate !== 'ready') return;
    if (surfaceMode !== 'chat') return;
    if (!selectedCharacter) return;
    // 타이핑 중이면 이미 응답 진행 중 — 중복 트리거 금지.
    if (selectedStoryIsTyping || selectedFortuneIsTyping) return;

    const thread = displayMessagesByCharacterId[selectedCharacter.id];
    if (!thread || thread.length === 0) return;

    const canonicalThread = getCanonicalVisibleMessages(thread);
    const last = canonicalThread[canonicalThread.length - 1];
    if (last.kind !== 'text' || last.sender !== 'user') return;

    if (autoResumedUserMessageIdsRef.current.has(last.id)) return;
    autoResumedUserMessageIdsRef.current.add(last.id);

    // story romance pilot vs 일반 story 캐릭터 분기 — 기존 send 핸들러
    // 시그니처 그대로 재사용.
    if (isStoryRomancePilotCharacterId(selectedCharacter.id)) {
      void sendStoryPilotMessage(selectedCharacter, last.text, {
        skipOptimisticUserMessage: true,
        userMessageId: last.id,
      });
    } else if (selectedCharacter.kind === 'story') {
      void sendCharacterChatMessage(selectedCharacter, last.text, {
        skipOptimisticUserMessage: true,
        userMessageId: last.id,
      });
    }
    // fortune 캐릭터는 transactional (질문→결과 카드) 패턴이라 자동 재개
    // 의미가 약함 — 의도적으로 스킵.
  }, [
    gate,
    surfaceMode,
    selectedCharacter,
    displayMessagesByCharacterId,
    selectedStoryIsTyping,
    selectedFortuneIsTyping,
  ]);

  // ---------------------------------------------------------------------------
  // F2 — 읽음 표시
  //
  // 정책 (2026-05-02): 유저가 메시지를 보내면 LLM 호출 전에 즉시 readAt 을
  // 찍어 노란 "1" 뱃지를 제거한다. "캐릭터가 읽음 → 그 다음 답장" 흐름을 위해
  // 랜덤 지연 타이머는 폐기. 응답 도착 후 idempotent 재호출은 noop (이미 readAt
  // 가 있으면 markLatestUserMessageAsRead 가 그대로 통과).
  // 외부에 노출된 clearReadReceiptTimer 는 과거 타이머를 정리하던 호출 사이트
  // 들에서 noop 으로 남겨둔다 — 회귀 안전을 위해 함수 자체는 유지.
  // ---------------------------------------------------------------------------
  const clearReadReceiptTimer = useCallback((_characterId: string) => {
    // no-op (랜덤 지연 타이머 폐기). 호출 사이트 회귀 안전을 위해 시그니처 유지.
  }, []);

  const markUserMessageReadImmediately = useCallback(
    (characterId: string) => {
      chatMessageController.markUserMessagesRead(characterId);
    },
    [chatMessageController],
  );

  const cancelPendingReplyForCharacter = useCallback(
    (characterId: string) => {
      if (session) {
        replyDeliveryController.cancelServerScheduledReplies(characterId);
      } else {
        replyDeliveryController.cancelLocal(characterId);
      }
      setStoryTypingByCharacterId((current) => {
        if (current[characterId] !== true) return current;
        return { ...current, [characterId]: false };
      });
      setGlobalTyping(characterId, false);
    },
    [session],
  );

  const scheduleCanonicalScheduledReply = useCallback(
    (
      characterId: string,
      response: Pick<StoryChatResponse, 'scheduledId' | 'deliverAt'>,
      replyDelayMs: number,
      onDelivered?: (messages: ChatShellMessage[]) => void,
    ) => {
      return replyDeliveryController.scheduleScheduledReply({
        characterId,
        response,
        phaseDelays: computeHumanReplyPhaseDelays(replyDelayMs),
        onMarkRead: () => markUserMessageReadImmediately(characterId),
        onTypingChange: (isTyping) => {
          setStoryTypingByCharacterId((current) => {
            if (current[characterId] === isTyping) return current;
            return { ...current, [characterId]: isTyping };
          });
          setGlobalTyping(characterId, isTyping);
        },
        onMessages: (messages) => {
          chatMessageController.appendMessages(characterId, messages, {
            markUserReadBeforeAppend: true,
          });
          const emotionTag = messages.find(
            (message): message is ChatShellTextMessage =>
              message.kind === 'text' &&
              message.sender === 'assistant' &&
              typeof message.emotionTag === 'string',
          )?.emotionTag;
          if (emotionTag) {
            lastAssistantEmotionTagRef.current = emotionTag;
          }
          triggerAssistantHaptic(emotionTag);
          onDelivered?.(messages);
        },
        onError: (error) => {
          captureError(error, {
            surface: 'chat:claim-scheduled-reply',
          }).catch(() => undefined);
        },
      });
    },
    [
      chatMessageController,
      markUserMessageReadImmediately,
      triggerAssistantHaptic,
    ],
  );

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

  // gate=ready가 되면 복원된 큐를 자동으로 flush. 앱 강제 종료로 미전송된
  // 누적 메시지를 단일 배치로 보낸다. 캐릭터별 1회만 트리거.
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
      // 부트 복원은 anchor 가 없을 수 있으니 지금을 첫 send 시각으로 간주.
      if (!batchFirstSendAtRef.current[cid]) {
        batchFirstSendAtRef.current[cid] = Date.now();
      }
      flushBatch(character);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [gate, createdFriends]);

  // unmount 시 잔여 배치 타이머 정리. expo-router 에서 chat 스크린이 unmount
  // 되는 경우는 드물지만 안전장치.
  useEffect(() => {
    return () => {
      for (const id of Object.keys(batchTimersRef.current)) {
        const t = batchTimersRef.current[id];
        if (t) clearTimeout(t);
      }
      batchTimersRef.current = {};
    };
  }, []);

  // ---------------------------------------------------------------------------
  // F3 — 햅틱 토글 (chatHapticsEnabled 설정)
  // ---------------------------------------------------------------------------
  // chatHaptics + tts 는 useChatTtsHaptics hook 으로 이동 (위쪽).
  // scoreReveal 햅틱만 여기에 남김 (관계 phase 전환 1회성, TTS/응답 햅틱과
  // 다른 책임).

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
    if (phaseChanged && mobileAppState.settings.chatHapticsEnabled) {
      scoreReveal(90);
    }
    previousPhaseByCharacterIdRef.current = nextSnapshot;
  }, [storyThreadSnapshotsByCharacterId, mobileAppState.settings.chatHapticsEnabled]);

  // ---------------------------------------------------------------------------
  // F1 — 멀티버블 순차 enqueue 헬퍼
  // ---------------------------------------------------------------------------
  /**
   * 어시스턴트 segments를 카톡 리듬으로 하나씩 append.
   * 각 버블 앞에 타이핑 인디케이터 200-600ms + 버블 사이 600-1800ms 랜덤 간격.
   * 첫 버블은 호출자가 이미 replyDelay를 걸었다고 가정 (중복 delay X).
   */
  // enqueueAssistantSegments + appendMessages 는 useMessageQueue hook 으로 이동
  // (Step B 분해). 호출 시그니처 동일.
  const { enqueueAssistantSegments, appendMessages } = useMessageQueue({
    setMessagesByCharacterId,
    triggerAssistantHaptic,
  });

  // ---------------------------------------------------------------------------
  // F4 — 프레전스 라인 ("커피 내리는 중", "네 생각 중..." 등)
  // ---------------------------------------------------------------------------
  const [presenceLine, setPresenceLine] = useState<string>('');

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
  // 운세 entry 선택 직후에는 "내가 누른 운세부터 새 흐름이 시작된다"는
  // 기준점이 보여야 한다. 일반 새 메시지처럼 바닥으로 끌고 내려가면 이전 대화와
  // 섞여 보이고, 반대로 결과 카드 로직에만 맡기면 설문형 운세 시작에는 적용되지
  // 않는다. 그래서 다음 content grow 1회에 한해 새로 append 된 운세 시작점
  // (append 전 content height)을 화면 상단으로 앵커한다.
  const pendingFortuneStartTopAnchorRef = useRef(false);
  const suppressNextGenericBottomScrollRef = useRef(false);

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

    if (pendingFortuneStartTopAnchorRef.current) {
      pendingFortuneStartTopAnchorRef.current = false;
      scrollTimerRef.current = setTimeout(() => {
        requestAnimationFrame(() => {
          chatScrollRef.current?.scrollTo({ y: Math.max(0, prevHeight - 8), animated: true });
        });
      }, 80);
      return;
    }

    // 최근 메시지가 운세 결과 카드면 카드 상단이 화면 최상단에 보이게 스크롤.
    const latestThread = displayMessagesByCharacterId[selectedCharacter.id] ?? [];
    const canonicalLatestThread = getCanonicalVisibleMessages(latestThread);
    const latestMessage = canonicalLatestThread[canonicalLatestThread.length - 1];
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
        displayMessagesByCharacterId[character.id],
        lastSeenByCharacterId[character.id],
      );
    }
    return result;
  }, [firstRunCharacters, displayMessagesByCharacterId, lastSeenByCharacterId]);

  // 채팅 목록 정렬 (메신저 표준):
  //   1) 안 읽은 메시지 있는 캐릭터 그룹 (unreadCount > 0) 이 항상 위
  //   2) 각 그룹 내부는 lastActivityAt desc — 가장 최근에 보내거나 받은 쪽이 위
  //   3) 활동 시각이 같으면 firstRunCharacters 의 정의 순서 유지 (stable)
  // metaByCharacterId 가 이미 두 키를 모두 들고 있어 추가 입력 없이 정렬 가능.
  const sortedFirstRunCharacters = useMemo(() => {
    const arr = [...firstRunCharacters];
    arr.sort((a, b) => {
      const ma = characterListMetaById[a.id];
      const mb = characterListMetaById[b.id];
      const unreadA = ma && ma.unreadCount > 0 ? 1 : 0;
      const unreadB = mb && mb.unreadCount > 0 ? 1 : 0;
      if (unreadA !== unreadB) return unreadB - unreadA;
      const tA = ma?.lastActivityAt ?? 0;
      const tB = mb?.lastActivityAt ?? 0;
      return tB - tA;
    });
    return arr;
  }, [firstRunCharacters, characterListMetaById]);

  // 앱 아이콘 배지 = 전 캐릭터 unread 합산. displayMessagesByCharacterId /
  // lastSeenByCharacterId 가 바뀔 때마다 재계산해 OS 배지와 동기화.
  // 메신저 앱 표준 — iMessage / WhatsApp / KakaoTalk 모두 홈스크린에 숫자.
  useEffect(() => {
    let total = 0;
    for (const characterId of Object.keys(displayMessagesByCharacterId)) {
      const meta = buildCharacterListMeta(
        displayMessagesByCharacterId[characterId],
        lastSeenByCharacterId[characterId],
      );
      total += meta.unreadCount;
    }
    void setAppIconBadgeCount(total);
  }, [displayMessagesByCharacterId, lastSeenByCharacterId]);

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
    pendingFortuneStartTopAnchorRef.current = false;
    suppressNextGenericBottomScrollRef.current = false;
    scrollChatToBottom(false);
  }, [
    gate,
    surfaceMode,
    selectedCharacter.id,
  ]);

  // 같은 방에 있는 동안 새 메시지가 도착하면 아래로 스크롤.
  // 단, 마지막 메시지가 결과 카드면 scrollChatOnContentGrow 가 카드 상단을
  // 뷰포트 상단에 고정하므로 여기선 스킵.
  useEffect(() => {
    if (gate !== 'ready' || surfaceMode !== 'chat') {
      return;
    }
    const canonicalSelectedThread = getCanonicalVisibleMessages(selectedThread);
    const latestMessage = canonicalSelectedThread[canonicalSelectedThread.length - 1];
    const latestIsResultCard =
      latestMessage?.kind === 'embedded-result' ||
      latestMessage?.kind === 'fortune-cookie' ||
      latestMessage?.kind === 'saju-preview';
    if (latestIsResultCard) {
      return;
    }
    if (
      pendingFortuneStartTopAnchorRef.current ||
      suppressNextGenericBottomScrollRef.current
    ) {
      suppressNextGenericBottomScrollRef.current = false;
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

  // appendMessages 는 useMessageQueue hook 으로 이동 (위쪽). 호출 시그니처 동일.

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

  function setFortuneGenerationCancellable(characterId: string, cancellable: boolean) {
    fortuneGenerationCancellableRef.current[characterId] = cancellable;
    setFortuneGenerationCancellableByCharacterId((current) => {
      if (current[characterId] === cancellable) return current;
      return { ...current, [characterId]: cancellable };
    });
  }

  function startFortuneGenerationController(characterId: string): AbortController | null {
    const previousController = fortuneGenerationControllersRef.current[characterId];
    if (previousController && fortuneGenerationCancellableRef.current[characterId] === false) {
      return null;
    }
    previousController?.abort();
    const controller = new AbortController();
    fortuneGenerationControllersRef.current[characterId] = controller;
    setFortuneGenerationCancellable(characterId, true);
    return controller;
  }

  function isCurrentFortuneGeneration(
    characterId: string,
    controller: AbortController,
  ): boolean {
    return (
      !controller.signal.aborted &&
      fortuneGenerationControllersRef.current[characterId] === controller
    );
  }

  function clearFortuneGenerationController(
    characterId: string,
    controller?: AbortController,
  ) {
    if (controller && fortuneGenerationControllersRef.current[characterId] === controller) {
      delete fortuneGenerationControllersRef.current[characterId];
      setFortuneGenerationCancellable(characterId, false);
    }
  }

  function cancelFortuneFlow(character: ChatCharacterSpec) {
    const controller = fortuneGenerationControllersRef.current[character.id];
    const canCancelGeneration =
      fortuneGenerationCancellableRef.current[character.id] === true;
    if (controller && !canCancelGeneration) {
      // Ref 기반 hard gate: React state/UI가 한 프레임 늦어도 차감/큐 등록 이후에는 abort 하지 않는다.
      appendMessages(character, [
        buildAssistantTextMessage(
          '이미 결과를 마무리하는 단계라 여기서 끊지는 않을게요. 잠시만 기다려 주세요.',
        ),
      ]);
      return;
    }
    controller?.abort();
    clearFortuneGenerationController(character.id, controller);
    setActiveSurvey(character.id, null);
    if (fortuneTypingCharacterId === character.id) {
      setFortuneTypingCharacterId(null);
    }
    appendMessages(character, [
      buildAssistantTextMessage(
        '좋아요, 이번 운세 보기는 취소했어요. 언제든 다시 시작해도 돼요.',
      ),
    ]);
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
    const generationController = startFortuneGenerationController(character.id);
    if (!generationController) {
      appendMessages(character, [
        buildAssistantTextMessage(
          '이전 운세 결과가 마무리되는 중이에요. 잠시만 기다린 뒤 다시 시작해 주세요.',
        ),
      ]);
      return;
    }
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
      // 비동기 poster-guide 분기 (palm-reading 등 gpt-image-2 기반).
      // 즉시 큐 등록 + placeholder 메시지 → push 알림으로 결과 도착.
      // 사용자 자유롭게 다른 채팅 / 앱 종료 가능.
      if (isAsyncPosterFortuneType(completed.fortuneType)) {
        await handleAsyncPosterFortune(character, completed, generationController.signal);
        return;
      }

      // 설문 완료 후 LLM 호출 전 cost confirm. cancel 시 API 비용 0.
      // catalog entry 없으면 통과.
      if (session) {
        const ok = await confirmCostForFortune(completed.fortuneType);
        if (!ok || !isCurrentFortuneGeneration(character.id, generationController)) {
          return;
        }
      }

      // 동의 받은 후 Edge Function 호출 → 성공 시에만 토큰 차감.
      // 차감 실패(insufficient/race) 시 결과는 이미 생성됐으므로 보여주고 로그만.
      const embeddedResult = await resolveFortuneResultMessage(
        completed.fortuneType,
        buildResultContext(character, completed.answers),
        'chat:complete-survey',
        generationController.signal,
      );

      if (!embeddedResult || !isCurrentFortuneGeneration(character.id, generationController)) {
        return;
      }

      let tokensConsumedForResult = false;
      let shouldRenderResult = true;
      if (session) {
        if (!isCurrentFortuneGeneration(character.id, generationController)) {
          return;
        }
        setFortuneGenerationCancellable(character.id, false);
        try {
          // PR-0a: idempotencyKey 호출 단위 unique. reference_id 도 같은 값으로
          // 두어 같은 운세 결과의 환불이 필요할 때 단일 키로 추적 가능.
          const consumeKey = `fortune:${character.id}:${completed.fortuneType}:${Crypto.randomUUID()}`;
          await consumeRemoteTokens(session, {
            fortuneType: completed.fortuneType,
            referenceId: consumeKey,
            idempotencyKey: consumeKey,
          }, {
            signal: generationController.signal,
          });
          tokensConsumedForResult = true;
        } catch (chargeError) {
          if (isAbortError(chargeError) && generationController.signal.aborted) {
            shouldRenderResult = false;
            return;
          }
          if (
            chargeError instanceof RemoteTokenConsumeError &&
            chargeError.code === 'INSUFFICIENT_TOKENS'
          ) {
            appendMessages(character, [
              buildAssistantTextMessage(
                chargeError.message || '토큰이 부족해요. 토큰을 충전한 뒤 다시 시도해주세요.',
              ),
            ]);
            shouldRenderResult = false;
            return;
          }
          await captureError(chargeError, {
            surface: 'chat:fortune-charge-after-success',
          }).catch(() => undefined);
          shouldRenderResult = isCurrentFortuneGeneration(character.id, generationController);
        }
      }

      const resultReply = buildAssistantTextMessage(
        definition?.submitReply ??
          '좋아요. 결과를 같은 채팅 안에서 바로 보여드릴게요.',
      );

      if (!shouldRenderResult) {
        return;
      }

      if (
        !tokensConsumedForResult &&
        !isCurrentFortuneGeneration(character.id, generationController)
      ) {
        return;
      }

      appendMessages(character, [resultReply, embeddedResult]);

      // Persist fortune conversation to remote (text messages only)
      const currentMessages = displayMessagesByCharacterId[character.id] ?? [];
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
      if (isAbortError(error) && generationController.signal.aborted) {
        return;
      }
      // Edge Function 실패 (resolveFortuneResultMessage throw). 토큰 차감 X.
      throw error;
    } finally {
      clearFortuneGenerationController(character.id, generationController);
      if (fortuneGenerationControllersRef.current[character.id] === undefined) {
        setFortuneTypingCharacterId(null);
      }
    }
  }

  function posterTypeKoreanLabel(fortuneType: FortuneTypeId): string {
    switch (fortuneType) {
      case 'palm-reading':
        return '손금가이드';
      case 'beauty-simulation':
        return '뷰티 시뮬레이션';
      case 'hair-style-guide':
        return '헤어스타일 가이드';
      case 'face-reading-guide':
        return '얼굴 인상 리포트';
      case 'ootd-guide':
        return 'OOTD 가이드';
      case 'blind-date-guide':
        return '소개팅 가이드';
      case 'past-life-guide':
        return '전생 리포트';
      default:
        return '인사이트';
    }
  }

  /**
   * 비동기 poster-guide 처리 (palm-reading 등).
   *   1. 큐 등록 (start-poster-job) — 즉시 반환
   *   2. placeholder 메시지 로컬 append (서버측도 INSERT 됐으나 즉시 UI 반영 위해)
   *   3. 토큰 차감 (job 등록 성공이면 cron 이 처리할 거라 차감해도 안전)
   *   4. 사용자는 자유롭게 다른 채팅 / 앱 종료 가능
   *   5. cron 완료 → push 알림 → 사용자 진입 → hydrate → 결과 카드 등장
   */
  async function handleAsyncPosterFortune(
    character: ChatCharacterSpec,
    completed: { fortuneType: FortuneTypeId; answers: Record<string, unknown> },
    signal?: AbortSignal,
  ) {
    // 사진 base64 추출 (어느 키든 — palm/face/body)
    const answers = completed.answers ?? {};
    const imageBase64 =
      typeof answers.palmImage === 'string'
        ? answers.palmImage
        : typeof answers.faceImage === 'string'
          ? answers.faceImage
          : typeof answers.bodyImage === 'string'
            ? answers.bodyImage
            : undefined;

    // 컨텍스트 텍스트 (past-life / blind-date 등 옵션)
    const contextText =
      typeof answers.lookContext === 'string'
        ? answers.lookContext
        : typeof answers.scenario === 'string'
          ? answers.scenario
          : undefined;

    // 큐 등록 전 cost confirm. cancel 시 cron 이 처리할 잡 자체가 안 만들어져
    // LLM 비용 0. catalog entry 없으면 통과.
    if (session) {
      const ok = await confirmCostForFortune(completed.fortuneType);
      if (!ok || signal?.aborted) {
        return;
      }
    }

    const result = await startAsyncPosterJob({
      fortuneType: completed.fortuneType,
      characterId: character.id,
      characterName: character.name,
      imageBase64,
      contextText,
      signal,
    });

    if (!result) {
      // 큐 등록 실패 → 사용자에게 안내
      appendMessages(character, [
        buildAssistantTextMessage(
          '잠깐, 지금 분석 요청을 받지 못했어. 잠시 후 다시 시도해줘.',
        ),
      ]);
      return;
    }

    // 큐 등록 성공 시점부터는 서버 cron 이 처리할 side effect 가 생긴 상태다.
    // 이 이후에는 사용자 cancel/AbortSignal 을 billing 단계에 전달하지 않는다.
    // 그래야 "queued server work + client cancel + no charge" orphan race 를 막는다.
    setFortuneGenerationCancellable(character.id, false);
    let tokensConsumedForJob = false;
    if (session) {
      try {
        // PR-0a: jobId 가 이미 unique — referenceId/idempotencyKey 동일 값으로 사용.
        const jobConsumeKey = `fortune:${character.id}:${completed.fortuneType}:${result.jobId}`;
        await consumeRemoteTokens(session, {
          fortuneType: completed.fortuneType,
          referenceId: jobConsumeKey,
          idempotencyKey: jobConsumeKey,
        });
        tokensConsumedForJob = true;
      } catch (chargeError) {
        if (isAbortError(chargeError) && signal?.aborted) {
          return;
        }
        if (
          chargeError instanceof RemoteTokenConsumeError &&
          chargeError.code === 'INSUFFICIENT_TOKENS'
        ) {
          // 토큰 부족 — job 은 이미 큐에 있지만 cron 이 user_token_balance 도 체크하므로
          // 별도 cancel 안 해도 무해. 사용자에게 안내만.
          appendMessages(character, [
            buildAssistantTextMessage(
              chargeError.message ||
                '토큰이 부족해요. 토큰을 충전한 뒤 다시 시도해주세요.',
            ),
          ]);
          return;
        }
        await captureError(chargeError, {
          surface: 'chat:fortune-charge-after-async-queue',
        }).catch(() => undefined);
      }
    }

    if (signal?.aborted && !tokensConsumedForJob) {
      return;
    }

    // 진행 카드 로컬 INSERT — 카드 컴포넌트(ProgressMessageCard)가 mount 되면
    // 자기 jobId 의 status 를 직접 polling 해서 done/failed 시 스스로 사라진다.
    // 서버측 start-poster-job 도 텍스트 placeholder INSERT 하지만 (cross-device
    // hydration 용), 본 디바이스는 progress 카드를 우선 노출.
    const progressMessage = buildProgressMessage({
      jobId: result.jobId,
      fortuneType: completed.fortuneType,
      phase: '분석 준비 중',
      phaseSteps: [...POSTER_PHASE_STEPS],
      currentStepIndex: 0,
      estimatedSeconds: 60,
    });
    appendMessages(character, [progressMessage]);
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
    // 기존 결과 재표시는 운세 entry 선택 시점이 기준점이다. 방금 만든 카드 ID를
    // 이미 상단 스크롤 처리된 카드로 표시해, 뒤따르는 카드 mount/content grow가
    // 사용자 요청 메시지를 위로 밀어내지 않게 한다.
    cardTopScrolledMessageIdRef.current = embeddedResult.id;
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

    const thread = displayMessagesByCharacterId[characterId] ?? [];
    const canonicalThread = getCanonicalVisibleMessages(thread);
    const lastMessage = canonicalThread[canonicalThread.length - 1];
    if (lastMessage) {
      setLastSeenByCharacterId((current) => ({
        ...current,
        [characterId]: lastMessage.id,
      }));
      setChatLastSeenForCharacter(characterId, lastMessage.id).catch(
        (error) => {
          captureError(error, { surface: 'chat:last-seen-flush' }).catch(
            () => undefined,
          );
        },
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

    // 'view-all' 메타 — 결과 화면 매핑 없음. AllFortunesSheet 열고 종료.
    if (fortuneType === 'view-all') {
      setAllFortunesSheetVisible(true);
      return;
    }

    const action = buildSuggestedActions(character).find(
      (candidate) => candidate.fortuneType === fortuneType,
    );
    // 카탈로그 fallback — buildSuggestedActions 에 없는 fortuneType (대다수 catalog
    // entry) 도 cost confirm 후 진행되도록. 이전엔 silent return 으로 무동작.
    const catalogEntry = action ? null : findCatalogEntry(fortuneType);

    if (!action && !catalogEntry) {
      return;
    }

    const prompt =
      action?.prompt ?? `${catalogEntry!.displayName} 부탁해요.`;
    const reply =
      action?.reply ?? `${catalogEntry!.displayName} 흐름 같이 짚어볼게.`;

    setSelectedCharacterId(character.id);
    setActiveTab(character.kind);
    setActiveFortuneType(fortuneType);
    setLaunchOrigin('user');
    setSurfaceMode('chat');
    setComposerTrayOpen(false);
    pendingFortuneStartTopAnchorRef.current = true;
    suppressNextGenericBottomScrollRef.current = true;
    appendMessages(character, [
      buildUserMessage(prompt),
      buildAssistantTextMessage(reply),
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

  // 운세 cost confirm modal — UX 결정: entry 선택 직후가 아니라 설문 완료 후
  // LLM/큐 호출 **직전** 에 노출. 사용자가 설문 매몰된 상태라 거부감 ↓ +
  // cancel 시 LLM API/큐 잡 자체가 안 만들어져 provider 비용 0.
  // entry 선택 시점엔 modal 안 띄우고 흐름만 시작.
  const [pendingMenuEntry, setPendingMenuEntry] =
    useState<FortuneCatalogEntry | null>(null);
  const [costSheetVisible, setCostSheetVisible] = useState(false);
  const costConfirmResolverRef = useRef<((ok: boolean) => void) | null>(null);

  // 하늘이 "모든 운세" bottom sheet — view-all chip 또는 외부 트리거로 열림.
  const [allFortunesSheetVisible, setAllFortunesSheetVisible] = useState(false);

  // Promise 기반 cost confirm. 호출자는 await 으로 동의 여부 받아 흐름 분기.
  // resolver 는 ref 에 저장 — modal confirm/cancel 핸들러에서 resolve.
  const showCostConfirm = useCallback(
    (entry: FortuneCatalogEntry): Promise<boolean> => {
      setPendingMenuEntry(entry);
      setCostSheetVisible(true);
      return new Promise<boolean>((resolve) => {
        costConfirmResolverRef.current = resolve;
      });
    },
    [],
  );

  // catalog 에 entry 가 있으면 cost confirm 받기, 없으면 그냥 통과.
  // fortuneType 별로 catalog 에 등록된 운세는 cost confirm, 아니면 (예: 'view-all',
  // 'character-chat', 채팅 차감 등) 무모달 진행.
  const confirmCostForFortune = useCallback(
    async (fortuneType: FortuneTypeId): Promise<boolean> => {
      const entry = findCatalogEntry(fortuneType);
      if (!entry) return true;
      return showCostConfirm(entry);
    },
    [showCostConfirm],
  );

  // entry 선택 — modal 안 띄움. 바로 fortune 흐름 시작 (설문 등). 차감 동의는
  // 설문 끝나고 LLM 호출 직전 (consumeRemoteTokens 직전) 에 받는다.
  const handleSelectFortuneMenuEntry = useCallback(
    (entry: FortuneCatalogEntry) => {
      handleCharacterActionPress(
        selectedCharacter.id,
        entry.id as FortuneTypeId,
      );
    },
    [selectedCharacter.id],
  );

  const handleConfirmCostSheet = useCallback(() => {
    setCostSheetVisible(false);
    setPendingMenuEntry(null);
    costConfirmResolverRef.current?.(true);
    costConfirmResolverRef.current = null;
  }, []);

  const handleCancelCostSheet = useCallback(() => {
    setCostSheetVisible(false);
    setPendingMenuEntry(null);
    costConfirmResolverRef.current?.(false);
    costConfirmResolverRef.current = null;
  }, []);

  const handleTopUpFromCostSheet = useCallback(() => {
    setCostSheetVisible(false);
    setPendingMenuEntry(null);
    costConfirmResolverRef.current?.(false);
    costConfirmResolverRef.current = null;
    router.push('/premium' as Href);
  }, []);

  // 본인이 보낸 텍스트 메시지 길게 누르기 → 삭제 컨펌. messagesByCharacterId
  // 에서 빼고 디스크 + 원격 양쪽 갱신. story romance pilot 은 snapshot 통째로
  // 다시 저장해야 romance state / scene intent 보존됨. 자동 재개 ref 에서도
  // 같이 정리해서 같은 메시지가 다음 진입 시 fantom 트리거 되지 않도록.
  async function handleDeleteUserMessage(messageId: string) {
    const characterId = selectedCharacter.id;
    const currentThread = displayMessagesByCharacterId[characterId];
    if (!currentThread) return;
    const nextThread = currentThread.filter((m) => m.id !== messageId);
    if (nextThread.length === currentThread.length) return;
    chatMessageController.removeMessage(characterId, messageId);
    autoResumedUserMessageIdsRef.current.delete(messageId);
    // 디스크에 TTS 캐시가 있으면 정리. user 메시지는 캐시 없으므로 no-op이지만
    // 안전하게 호출 (idempotent).
    void tts.clearCache(messageId);

    if (isStoryRomancePilotCharacterId(characterId)) {
      const currentSnapshot = storyThreadSnapshotsByCharacterId[characterId];
      if (currentSnapshot) {
        const nextSnapshot = {
          ...currentSnapshot,
          messages: nextThread,
          updatedAt: new Date().toISOString(),
        };
        setStoryThreadSnapshotsByCharacterId((cur) => ({
          ...cur,
          [characterId]: nextSnapshot,
        }));
        await saveStoryThreadSnapshot(nextSnapshot).catch((error: unknown) => {
          captureError(error, {
            surface: 'chat:delete-user-message-snapshot',
          }).catch(() => undefined);
        });
        return;
      }
    }

    await saveCharacterConversation(characterId, nextThread).catch(
      (error: unknown) => {
        captureError(error, {
          surface: 'chat:delete-user-message-conversation',
        }).catch(() => undefined);
      },
    );
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

  function handleClearPendingAudio() {
    setPendingAudioByCharacterId((current) => {
      if (!(selectedCharacter.id in current)) return current;
      const next = { ...current };
      delete next[selectedCharacter.id];
      return next;
    });
  }

  async function handleToggleAudioMessageRecording() {
    setComposerTrayOpen(false);
    const characterId = selectedCharacter.id;

    if (audioRecordingRef.current) {
      const recording = audioRecordingRef.current;
      audioRecordingRef.current = null;
      setRecordingAudioForCharacterId(null);
      try {
        const status = await recording.stopAndUnloadAsync();
        const uri = recording.getURI();
        if (!uri) {
          Alert.alert('음성 메시지', '녹음 파일을 만들지 못했어요. 다시 시도해 주세요.');
          return;
        }
        setPendingAudioByCharacterId((current) => ({
          ...current,
          [characterId]: {
            uri,
            durationMillis: 'durationMillis' in status ? status.durationMillis : undefined,
          },
        }));
        setSurfaceMode('chat');
      } catch (error) {
        captureError(error, { surface: 'chat:audio-message-stop' }).catch(() => undefined);
        Alert.alert('음성 메시지', '녹음을 저장하지 못했어요. 다시 시도해 주세요.');
      }
      return;
    }

    try {
      const { Audio } = await import('expo-av');
      const permission = await Audio.requestPermissionsAsync();
      if (!permission.granted) {
        Alert.alert('마이크 권한', '음성 메시지를 보내려면 마이크 권한이 필요해요.');
        return;
      }
      await Audio.setAudioModeAsync({
        allowsRecordingIOS: true,
        playsInSilentModeIOS: true,
      });
      const { recording } = await Audio.Recording.createAsync(
        Audio.RecordingOptionsPresets.HIGH_QUALITY,
      );
      audioRecordingRef.current = recording;
      setRecordingAudioForCharacterId(characterId);
    } catch (error) {
      captureError(error, { surface: 'chat:audio-message-start' }).catch(() => undefined);
      Alert.alert('음성 메시지', '녹음을 시작할 수 없어요. 다시 시도해 주세요.');
      setRecordingAudioForCharacterId(null);
      audioRecordingRef.current = null;
    }
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
    // 하늘이 통합 후: 모든 운세 결과는 하늘이 채팅 안에 embed.
    // recent result 도 하늘이로 라우팅 (deprecated fortune characters 미사용).
    const recentFortuneCharacterId = haneulOracleCharacter.id;

    setActiveTab('story');
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
    const idsToRemove = queue.map((item) => item.userMessageId);
    chatMessageController.removeMessages(characterId, idsToRemove);
  }

  function rollbackUserMessages(characterId: string, userMessageIds: string[]) {
    const idsToRemove = userMessageIds.filter((id) => id.trim().length > 0);
    if (idsToRemove.length === 0) return;
    chatMessageController.removeMessages(characterId, idsToRemove);
  }

  // pendingSendsRef가 바뀔 때마다 UI 카운트 동기 업데이트 + 디스크 영속화.
  // AC4 — 배칭은 사용자에게 투명하므로 카운트는 항상 0 으로 유지. state 자체
  // 는 surface prop 호환을 위해 남겨둠.
  function syncPendingCount(characterId: string) {
    setPendingSendCountByCharacterId((current) => {
      if (current[characterId] === 0) return current;
      return { ...current, [characterId]: 0 };
    });
    void setSecureItem(
      PENDING_SENDS_STORAGE_KEY,
      JSON.stringify(pendingSendsRef.current),
    ).catch(() => undefined);
  }

  function clearBatchTimer(characterId: string) {
    const existing = batchTimersRef.current[characterId];
    if (existing) {
      clearTimeout(existing);
      batchTimersRef.current[characterId] = null;
    }
  }

  // 캐릭터별 누적 큐를 단일 Edge Function 호출로 보낸다. 5초 idle 윈도우
  // 만료 또는 부트 복원 시 호출. 큐는 비우고 첫 항목의 userMessageId 를 send
  // 함수에 넘겨 read receipt / rollback 가 head 메시지를 가리키게 한다.
  function flushBatch(character: ChatCharacterSpec) {
    clearBatchTimer(character.id);
    const queue = pendingSendsRef.current[character.id] ?? [];
    if (queue.length === 0) {
      return;
    }
    pendingSendsRef.current = {
      ...pendingSendsRef.current,
      [character.id]: [],
    };
    syncPendingCount(character.id);

    const combinedText = queue.map((item) => item.text).join('\n\n');
    const userMessageIds = queue.map((item) => item.userMessageId);
    const headUserMessageId = userMessageIds[0];

    if (isStoryRomancePilotCharacterId(character.id)) {
      void sendStoryPilotMessage(character, combinedText, {
        skipOptimisticUserMessage: true,
        userMessageId: headUserMessageId,
        userMessageIds,
      });
      return;
    }

    if (character.kind === 'story') {
      void sendCharacterChatMessage(character, combinedText, {
        skipOptimisticUserMessage: true,
        userMessageId: headUserMessageId,
        userMessageIds,
      });
    }
  }

  // 응답 대기 중에도 입력 가능. 첫 send 시 BATCH_IDLE_WINDOW_MS 타이머 시작,
  // 추가 send 마다 reset. idle 만료되면 누적 큐 한 번에 flush. typing
  // indicator 는 첫 send 부터 응답 렌더 직전까지 계속 표시 (AC3).
  function enqueueStorySend(character: ChatCharacterSpec, text: string) {
    cancelPendingReplyForCharacter(character.id);

    const queuedUserMessage = buildUserMessage(text);
    chatMessageController.appendMessages(character.id, [queuedUserMessage]);
    pendingSendsRef.current = {
      ...pendingSendsRef.current,
      [character.id]: [
        ...(pendingSendsRef.current[character.id] ?? []),
        { text, userMessageId: queuedUserMessage.id },
      ],
    };
    syncPendingCount(character.id);

    // 첫 send 만 batchFirstSendAt 기록. 이후 reset 되어도 floor 계산용
    // anchor 는 첫 send 시점으로 유지된다.
    if (!batchFirstSendAtRef.current[character.id]) {
      batchFirstSendAtRef.current[character.id] = Date.now();
    }
    clearBatchTimer(character.id);
    batchTimersRef.current[character.id] = setTimeout(() => {
      batchTimersRef.current[character.id] = null;
      flushBatch(character);
    }, BATCH_IDLE_WINDOW_MS);

    // 진짜 사람 흐름 — send 직후엔 "1" 유지 (안 봤음), typing X. markRead 는
    // 답장 도착 직전 (beforeReadMs sleep 후) sendStoryPilotMessage /
    // sendCharacterChatMessage 의 wait 단계에서 처리.
    setComposerTrayOpen(false);
    setSurfaceMode('chat');
  }

  // 배칭 모델 도입 후 sequential drain 은 사용 안 함. 호환을 위해 no-op
  // wrapper 만 유지 (sendStoryPilotMessage / sendCharacterChatMessage finally
  // 에서 호출되는 자리). 큐에 남은 메시지는 다음 enqueueStorySend 가 새
  // 배치를 시작하면서 처리한다.
  function drainNextPendingSend(_character: ChatCharacterSpec) {
    // intentional no-op
  }

  async function sendStoryPilotMessage(
    character: ChatCharacterSpec,
    text: string,
    sendOptions?: {
      skipOptimisticUserMessage?: boolean;
      userMessageId?: string;
      userMessageIds?: string[];
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
    if (!skipOptimistic) {
      cancelPendingReplyForCharacter(character.id);
    }

    const existingSnapshot =
      storyThreadSnapshotsByCharacterId[character.id] ??
      buildStoryThreadSnapshot(character);
    const existingThread =
      displayMessagesByCharacterId[character.id] ??
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
        rollbackUserMessages(
          character.id,
          sendOptions.userMessageIds ?? [sendOptions.userMessageId],
        );
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
    const effectiveUserMessageIds = userMessage?.id
      ? [userMessage.id]
      : (sendOptions?.userMessageIds ??
        (sendOptions?.userMessageId ? [sendOptions.userMessageId] : []));

    if (userMessage) {
      chatMessageController.appendMessages(character.id, [userMessage]);
    }
    // 진짜 사람 흐름 — send 직후엔 "1" 유지 + typing X. markRead 와 typing 은
    // replyDelayMs 분기에서 단계별 처리 (beforeReadMs → markRead →
    // readToTypingMs → setTyping → typingPreviewMs → render).
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
        // Step G: store sync — fallback assistant message
        insertStoreMessages(character.id, [fallbackMessage]).catch(() => undefined);
        return;
      }

      const chatProvider = resolveChatProvider(mobileAppState.settings.aiMode, {
        requiresImageInput: !!sendOptions?.imageBase64,
      });

      // Skip token consumption for guest users and on-device mode
      if (session && chatProvider.getProviderName() === 'cloud') {
        // PR-0a: 같은 캐릭터 메시지 여러 번 — referenceId 가 같으면 atomic refund 가
        // 모호해짐. idempotencyKey 만 호출 단위 unique 로 두고 reference_id 도 같이.
        const storyConsumeKey = `story:${character.id}:${Crypto.randomUUID()}`;
        await consumeRemoteTokens(session, {
          fortuneType: 'character-chat',
          referenceId: storyConsumeKey,
          idempotencyKey: storyConsumeKey,
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
      const invokeOptions: import('../lib/chat-provider').ChatProviderOptions = {
        userProfile: {
          displayName: mobileAppState.profile.displayName,
          birthDate: mobileAppState.profile.birthDate,
          mbti: mobileAppState.profile.mbti,
          relationship: mobileAppState.profile.relationship,
          conversationTone: mobileAppState.profile.conversationTone,
          interestIds: mobileAppState.profile.interestIds,
        },
      };
      if (customPersona) {
        invokeOptions.userDescription = `[유저 커스텀 성격 요청] ${customPersona}`;
      }
      if (sendOptions?.imageBase64) {
        invokeOptions.imageBase64 = sendOptions.imageBase64;
      }
      // pending_character_reply_jobs 큐 enqueue 키 — invokeStoryChat 의 cloud
      // 경로에서 사용. 자동 재개/재시도가 같은 user 메시지로 들어와도 idempotent.
      if (effectiveUserMessageId) {
        invokeOptions.userMessageId = effectiveUserMessageId;
      }
      // 현재 production 표준은 서버 DB 설정의 Gemini 3.1 Flash Lite.
      // 클라이언트에 과거 Grok 선호값이 남아 있어도 normalize 단계에서 default 로
      // 고정되므로 서버에는 별도 modelPreference 를 보내지 않는다.
      const cloudModelPref = mobileAppState.settings.cloudModelPreference;
      if (cloudModelPref && cloudModelPref !== 'default') {
        invokeOptions.modelPreference = cloudModelPref;
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
            // PR-0a: 호출 단위 unique key. 위 첫 시도 차감과 별도 keyed.
            const fallbackConsumeKey = `story:${character.id}:fallback:${Crypto.randomUUID()}`;
            await consumeRemoteTokens(session, {
              fortuneType: 'character-chat',
              referenceId: fallbackConsumeKey,
              idempotencyKey: fallbackConsumeKey,
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

      // F2 — 서버 응답 도착. markRead 는 단계별 sleep 안 (beforeReadMs 후) 에서
      // 호출 — 답장 직전 일정 시간 전에만 "1" 사라지도록 (진짜 사람 흐름).
      if (response.superseded) {
        return;
      }

      // 빈 응답 가드 — segments 전부 strip 되거나 response 가 빈 문자열이면
      // 타이핑 인디케이터만 떴다가 아무 메시지도 안 나오는 silent fail 발생.
      // 이 경우 typing 단계 들어가기 전에 Alert + early return 으로 사용자에게
      // 명확한 신호를 줘서 재전송 유도.
      const candidateSegments =
        response.segments?.filter((s) => s.trim().length > 0) ?? [];
      const hasContent =
        candidateSegments.length > 0 || (response.response?.trim().length ?? 0) > 0;
      if (!hasContent) {
        shouldClearDraft = false;
        setDraft(trimmed);
        clearBatchTimer(character.id);
        clearReadReceiptTimer(character.id);
        delete batchFirstSendAtRef.current[character.id];
        rollbackUserMessages(character.id, effectiveUserMessageIds);
        setStoryThreadSnapshotsByCharacterId((current) => ({
          ...current,
          [character.id]: existingSnapshot,
        }));
        await captureError(new Error('character-chat empty response'), {
          surface: 'chat:story-pilot-empty-response',
        }).catch(() => undefined);
        Alert.alert(
          '응답이 끊겼어요',
          '잠시 후 다시 보내볼까요?',
        );
        return;
      }

      // 최신 assistant emotion 추적 (F4 presence 라인에 반영)
      if (response.emotionTag) {
        lastAssistantEmotionTagRef.current = response.emotionTag;
      }

      // Reply delay — 서버가 emotion + 길이 + 낮밤 multiplier 적용한 delaySec
      // 를 그대로 신뢰 (단일 source: supabase/functions/_shared/reply_delay.ts).
      // 추가로 batchFirstSendAt 기준 floor (REPLY_FLOOR_MS) 적용. 서버 누락 시
      // 짧은 fallback (FALLBACK_REPLY_*).
      let replyDelayMs = typeof response.delaySec === 'number' &&
          Number.isFinite(response.delaySec)
        ? response.delaySec * 1000
        : randomFallbackReplyDelayMs();
      const elapsedSinceFirstSend = Date.now() -
        (batchFirstSendAtRef.current[character.id] ?? Date.now());
      const minRemaining = Math.max(0, REPLY_FLOOR_MS - elapsedSinceFirstSend);
      replyDelayMs = Math.max(replyDelayMs, minRemaining);
      delete batchFirstSendAtRef.current[character.id];

      if (
        response.scheduledId &&
        response.deliverAt &&
        Number.isFinite(Date.parse(response.deliverAt))
      ) {
        const scheduled = scheduleCanonicalScheduledReply(
          character.id,
          response,
          replyDelayMs,
          (deliveredMessages) => {
            if (deliveredMessages.length === 0) return;
            const nextMessages = getStoreMessages(character.id);
            const nextSnapshot = buildNextStoryThreadSnapshot(
              optimisticSnapshot,
              character,
              nextMessages,
              response,
              storyRequest,
            );
            if (!nextSnapshot) return;
            setStoryThreadSnapshotsByCharacterId((current) => ({
              ...current,
              [character.id]: nextSnapshot,
            }));
            saveStoryThreadSnapshot(nextSnapshot).catch((error: unknown) => {
              captureError(error, {
                surface: 'chat:story-pilot-save-scheduled',
              }).catch(() => undefined);
            });
          },
        );
        if (scheduled) return;
      }

      // 진짜 사람 흐름 4단계:
      //   1. send → "1" 유지 (캐릭터 안 봤음)
      //   2. beforeReadMs sleep → markRead → "1" 사라짐 (읽었음)
      //   3. readToTypingMs sleep → setTyping(true) → "..." (입력 중)
      //   4. typingPreviewMs sleep → 메시지 렌더 + setTyping(false)
      //
      // 읽음 배지는 빠르게 제거하고, 남은 시간을 "읽고 생각 중 → 입력 중"으로
      // 나누어 무응답/네트워크 장애처럼 보이지 않게 한다.
      const { beforeReadMs, readToTypingMs, typingPreviewMs } =
        computeHumanReplyPhaseDelays(replyDelayMs);
      const localReplyGeneration = replyDeliveryController.beginLocalReply(
        character.id,
      );
      await sleep(beforeReadMs);
      if (
        !replyDeliveryController.isLocalReplyCurrent(
          character.id,
          localReplyGeneration,
        )
      ) {
        return;
      }
      markUserMessageReadImmediately(character.id);
      await sleep(readToTypingMs);
      if (
        !replyDeliveryController.isLocalReplyCurrent(
          character.id,
          localReplyGeneration,
        )
      ) {
        return;
      }
      setStoryTypingByCharacterId((current) => ({
        ...current,
        [character.id]: true,
      }));
      setGlobalTyping(character.id, true);
      await sleep(typingPreviewMs);
      if (
        !replyDeliveryController.isLocalReplyCurrent(
          character.id,
          localReplyGeneration,
        )
      ) {
        return;
      }

      // 최신 유저 메시지 읽음 처리 — 현재 state 기준으로 찍어야 큐잉된 다음
      // 메시지들을 덮어쓰지 않는다.
      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: markLatestUserMessageAsRead(
          current[character.id] ?? [],
        ),
      }));
      // F1 — segments 순차 enqueue. 단일 세그먼트는 하위 호환 동일 동작.
      const segments = candidateSegments.length > 0
        ? candidateSegments
        : [response.response.trim()];
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
        rollbackUserMessages(character.id, effectiveUserMessageIds);
        setStoryThreadSnapshotsByCharacterId((current) => ({
          ...current,
          [character.id]: existingSnapshot,
        }));
        return;
      }

      if (error instanceof RemoteTokenConsumeError) {
        shouldClearDraft = false;
        setDraft(trimmed);
        rollbackUserMessages(character.id, effectiveUserMessageIds);
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
          setAuthMessage('세션이 만료되었어요. 다시 로그인해 주세요.');
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

      // 네트워크/서버 실패: 가짜 AI 응답을 주입하지 않는다 (페르소나 신뢰도 깨짐).
      // 사용자 메시지를 롤백하고 입력창에 텍스트 복구 → 재전송 가능.
      // 기존 OnDeviceNotReadyError 처리와 동일 패턴.
      shouldClearDraft = false;
      setDraft(trimmed);
      clearReadReceiptTimer(character.id);
      rollbackUserMessages(character.id, effectiveUserMessageIds);
      setStoryThreadSnapshotsByCharacterId((current) => ({
        ...current,
        [character.id]: existingSnapshot,
      }));
      Alert.alert(
        '메시지 전송 실패',
        '네트워크가 불안정해요. 잠시 후 다시 보내볼까요?',
      );
    } finally {
      setStoryTypingByCharacterId((current) =>
        current[character.id]
          ? { ...current, [character.id]: false }
          : current,
      );
      setGlobalTyping(character.id, false);
      if (shouldClearDraft) {
        setDraft('');
      }
      drainNextPendingSend(character);
    }
  }

  async function sendCharacterChatMessage(
    character: ChatCharacterSpec,
    text: string,
    sendOptions?: {
      skipOptimisticUserMessage?: boolean;
      userMessageId?: string;
      userMessageIds?: string[];
    },
  ) {
    const trimmed = text.trim();

    if (!trimmed) {
      return;
    }

    const skipOptimistic = sendOptions?.skipOptimisticUserMessage === true;
    if (!skipOptimistic) {
      cancelPendingReplyForCharacter(character.id);
    }

    const existingThread =
      displayMessagesByCharacterId[character.id] ?? buildInitialThread(character);
    const userMessage = skipOptimistic ? null : buildUserMessage(trimmed);
    const optimisticThread = userMessage
      ? [...existingThread, userMessage]
      : existingThread;
    let shouldClearDraft = !skipOptimistic;

    const effectiveUserMessageId = userMessage?.id ?? sendOptions?.userMessageId;
    const effectiveUserMessageIds = userMessage?.id
      ? [userMessage.id]
      : (sendOptions?.userMessageIds ??
        (sendOptions?.userMessageId ? [sendOptions.userMessageId] : []));
    if (userMessage) {
      chatMessageController.appendMessages(character.id, [userMessage]);
    }
    // 진짜 사람 흐름 — send 직후 "1" 유지 + typing X. markRead 와 typing 은
    // replyDelayMs 분기에서 단계별 처리.
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
        // Step G: store sync — draft fallback reply
        insertStoreMessages(character.id, [fallbackMessage]).catch(() => undefined);
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

            // markRead 는 단계별 sleep 안 (beforeReadMs 후) 에서 호출.
            if (response.emotionTag) {
              lastAssistantEmotionTagRef.current = response.emotionTag;
            }

            let replyDelayMs = typeof response.delaySec === 'number' &&
                Number.isFinite(response.delaySec)
              ? response.delaySec * 1000
              : randomFallbackReplyDelayMs();
            const elapsedSinceFirstSend = Date.now() -
              (batchFirstSendAtRef.current[character.id] ?? Date.now());
            const minRemaining = Math.max(0, REPLY_FLOOR_MS - elapsedSinceFirstSend);
            replyDelayMs = Math.max(replyDelayMs, minRemaining);
            delete batchFirstSendAtRef.current[character.id];
            // 4단계 진짜 사람 흐름 (위 첫 사이트와 동일 패턴):
            // 안 봄 → markRead → 읽고 잠시 → typing → 렌더.
            const { beforeReadMs, readToTypingMs, typingPreviewMs } =
              computeHumanReplyPhaseDelays(replyDelayMs);
            const localReplyGeneration = replyDeliveryController.beginLocalReply(
              character.id,
            );
            await sleep(beforeReadMs);
            if (
              !replyDeliveryController.isLocalReplyCurrent(
                character.id,
                localReplyGeneration,
              )
            ) {
              return;
            }
            markUserMessageReadImmediately(character.id);
            await sleep(readToTypingMs);
            if (
              !replyDeliveryController.isLocalReplyCurrent(
                character.id,
                localReplyGeneration,
              )
            ) {
              return;
            }
            setStoryTypingByCharacterId((current) => ({
              ...current,
              [character.id]: true,
            }));
            setGlobalTyping(character.id, true);
            await sleep(typingPreviewMs);
            if (
              !replyDeliveryController.isLocalReplyCurrent(
                character.id,
                localReplyGeneration,
              )
            ) {
              return;
            }

            setMessagesByCharacterId((current) => ({
              ...current,
              [character.id]: markLatestUserMessageAsRead(
                current[character.id] ?? [],
              ),
            }));
            const candidateSegments =
              response.segments?.filter((s) => s.trim().length > 0) ?? [];
            const segments = candidateSegments.length > 0
              ? candidateSegments
              : [response.response.trim()];
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
        // PR-0a: 호출 단위 unique. 같은 referenceId 여러 메시지 차감 = atomic refund 모호.
        const characterConsumeKey = `character:${character.id}:${Crypto.randomUUID()}`;
        await consumeRemoteTokens(session, {
          fortuneType: 'character-chat',
          referenceId: characterConsumeKey,
          idempotencyKey: characterConsumeKey,
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

      // Slice 2: hookForReveal hook 의 push payload 동봉 id 가 있으면 character-chat 에 전달.
      // 서버는 이 id 로 reveal claim (race-free).
      const pendingProactiveMessageId = consumePendingProactiveMessageId(character.id);

      const characterChatBody = {
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
        ...(effectiveUserMessageId ? { userMessageId: effectiveUserMessageId } : {}),
        userName:
          (session?.user.user_metadata.name as string | undefined) ||
          (session?.user.user_metadata.full_name as string | undefined) ||
          mobileAppState.profile.displayName ||
          'user',
        userProfile: {
          name: mobileAppState.profile.displayName,
          mbti: mobileAppState.profile.mbti,
          relationship: mobileAppState.profile.relationship,
          tone: mobileAppState.profile.conversationTone ?? undefined,
          topics: mobileAppState.profile.interestIds,
        },
        ...(pendingProactiveMessageId ? { pendingProactiveMessageId } : {}),
      };

      // 답장 생성 큐 enqueue — 앱이 이 라인 이후 어느 시점에 죽어도 cron 이
      // 30초 grace 후 같은 페이로드로 character-chat 재호출 → 답장 도달 보장.
      // 회귀 안전: enqueue 실패해도 invoke 는 그대로 진행 (jobId 없이) — 기존 동작.
      let pendingReplyJobId: string | undefined;
      if (session && effectiveUserMessageId) {
        try {
          const { data: enqueueData, error: enqueueError } = await supabase.rpc(
            'enqueue_pending_reply_job',
            {
              p_character_id: character.id,
              p_character_name: character.name,
              p_user_message_id: effectiveUserMessageId,
              p_user_message: trimmed,
              p_request_payload: characterChatBody,
            },
          );
          if (enqueueError) {
            console.warn(
              '[chat] enqueue_pending_reply_job 실패:',
              enqueueError.message,
            );
          } else if (Array.isArray(enqueueData) && enqueueData[0]?.job_id) {
            pendingReplyJobId = enqueueData[0].job_id as string;
          }
        } catch (jobEnqueueErr) {
          console.warn('[chat] enqueue_pending_reply_job 예외:', jobEnqueueErr);
        }
      }

      const { data, error } = await supabase.functions.invoke('character-chat', {
        body: {
          ...characterChatBody,
          ...(pendingReplyJobId ? { jobId: pendingReplyJobId } : {}),
        },
      });

      const payload = data as {
        response?: string;
        success?: boolean;
        error?: string;
        message?: string;
        chatLimit?: {
          currentCount: number;
          dailyLimit: number;
          streakDays: number;
        };
        delaySec?: number;
        emotionTag?: string;
        segments?: unknown;
        scheduledId?: string;
        deliverAt?: string;
        status?: string;
        meta?: { provider?: string };
        // Slice 2: 서버가 Stage 2 reveal 한 사진 (있을 때만).
        reveal?: { imageUrl: string; caption: string; category: string };
      } | null;

      // Streak 한도 도달 (429). 토큰/구독/광고 안내 후 chat 흐름 종료.
      if (payload?.error === 'daily_chat_limit_reached') {
        const limit = payload.chatLimit?.dailyLimit ?? 30;
        const buttons: import('react-native').AlertButton[] = [
          { text: '확인', style: 'cancel' as const },
          {
            text: '구독 알아보기',
            onPress: () => router.push('/premium'),
          },
        ];
        // 광고 시청 옵션은 광고 모듈 사용 가능 + 광고 prefetch 완료된 경우만 추가.
        if (rewardedAd.isReady && !rewardedAd.isUnavailable) {
          buttons.splice(1, 0, {
            text: '광고 보고 1 토큰',
            onPress: () => {
              void rewardedAd.showAd();
            },
          });
        }
        Alert.alert(
          '오늘 무료 채팅 한도',
          payload.message ??
            `오늘 ${limit}개 메시지를 모두 사용했어요. 광고 보고 토큰 받거나 구독으로 무제한 사용해보세요.`,
          buttons,
        );
        return;
      }

      if (error) {
        throw error;
      }

      if (payload?.status === 'superseded' || payload?.meta?.provider === 'noop') {
        return;
      }

      const payloadSegments = Array.isArray(payload?.segments)
        ? payload.segments.filter(
            (segment): segment is string =>
              typeof segment === 'string' && segment.trim().length > 0,
          )
        : [];
      const payloadResponse = payload?.response?.trim() ?? '';

      if (!payload || payload.success === false || (payloadSegments.length === 0 && !payloadResponse)) {
        throw new Error(payload?.error ?? 'Character chat response is empty.');
      }

      // F2 — 서버 응답 도착. markRead 는 단계별 sleep 안에서 호출 (진짜 사람 흐름).
      if (typeof payload.emotionTag === 'string' && payload.emotionTag.length > 0) {
        lastAssistantEmotionTagRef.current = payload.emotionTag;
      }

      // Phase 2 — 답장 지연 발송: scheduledId+deliverAt 이 오면 그 시각까지
      // 타이핑 유지. legacy(REPLY_DELAY_ENABLED=false) 면 payload.delaySec
      // (서버 emotion + 길이 + 야간 multiplier 적용분) 을 그대로 사용. 8초
      // cap 제거. AC1 — batchFirstSendAt 기준 floor (REPLY_FLOOR_MS).
      let replyDelayMs: number;
      const scheduledId = payload.scheduledId;
      if (scheduledId && payload.deliverAt) {
        const deliverAtMs = Date.parse(payload.deliverAt);
        replyDelayMs = Number.isFinite(deliverAtMs)
          ? Math.max(0, deliverAtMs - Date.now())
          : typeof payload.delaySec === 'number' && Number.isFinite(payload.delaySec)
            ? payload.delaySec * 1000
            : randomFallbackReplyDelayMs();
      } else if (typeof payload.delaySec === 'number' && Number.isFinite(payload.delaySec)) {
        replyDelayMs = payload.delaySec * 1000;
      } else {
        replyDelayMs = randomFallbackReplyDelayMs();
      }
      const elapsedSinceFirstSend = Date.now() -
        (batchFirstSendAtRef.current[character.id] ?? Date.now());
      const minRemaining = Math.max(0, REPLY_FLOOR_MS - elapsedSinceFirstSend);
      replyDelayMs = Math.max(replyDelayMs, minRemaining);
      delete batchFirstSendAtRef.current[character.id];

      if (
        scheduledId &&
        payload.deliverAt &&
        Number.isFinite(Date.parse(payload.deliverAt))
      ) {
        const scheduled = scheduleCanonicalScheduledReply(
          character.id,
          { scheduledId, deliverAt: payload.deliverAt },
          replyDelayMs,
          () => {
            if (payload.reveal?.imageUrl && payload.reveal.caption) {
              chatMessageController.appendMessages(character.id, [
                {
                  id: `proactive-reveal-${Date.now()}-${Math.random()
                    .toString(36)
                    .slice(2, 8)}`,
                  kind: 'image' as const,
                  sender: 'assistant' as const,
                  imageUrl: payload.reveal.imageUrl,
                  caption: payload.reveal.caption,
                  proactive: {
                    slotKey: 'lunch_share',
                    category: payload.reveal.category,
                    generatedAt: new Date().toISOString(),
                  },
                },
              ]);
            }
          },
        );
        if (scheduled) return;
      }

      // 4단계 진짜 사람 흐름 (위 두 사이트와 동일 패턴):
      // 안 봄 → markRead → 읽고 잠시 → typing → 렌더.
      const { beforeReadMs, readToTypingMs, typingPreviewMs } =
        computeHumanReplyPhaseDelays(replyDelayMs);
      const localReplyGeneration = replyDeliveryController.beginLocalReply(
        character.id,
      );
      await sleep(beforeReadMs);
      if (
        !replyDeliveryController.isLocalReplyCurrent(
          character.id,
          localReplyGeneration,
        )
      ) {
        return;
      }
      markUserMessageReadImmediately(character.id);
      await sleep(readToTypingMs);
      if (
        !replyDeliveryController.isLocalReplyCurrent(
          character.id,
          localReplyGeneration,
        )
      ) {
        return;
      }
      setStoryTypingByCharacterId((current) => ({
        ...current,
        [character.id]: true,
      }));
      setGlobalTyping(character.id, true);
      await sleep(typingPreviewMs);
      if (
        !replyDeliveryController.isLocalReplyCurrent(
          character.id,
          localReplyGeneration,
        )
      ) {
        return;
      }

      setMessagesByCharacterId((current) => ({
        ...current,
        [character.id]: markLatestUserMessageAsRead(
          current[character.id] ?? [],
        ),
      }));
      // F1 — segments 파싱 (없으면 단일 세그먼트로 폴백)
      const segments =
        payloadSegments.length > 0 ? payloadSegments : [payloadResponse];
      const nextMessages = await enqueueAssistantSegments({
        characterId: character.id,
        segments,
        emotionTag: payload.emotionTag,
      });

      // Slice 2: 서버가 reveal 사진을 함께 보냈으면 thread 에 image 메시지 즉시 append.
      // 서버 측 character_conversations 에도 이미 persist 됐으므로 reload 시에도 보존.
      if (payload.reveal?.imageUrl && payload.reveal.caption) {
        const revealImage = {
          id: `proactive-reveal-${Date.now()}-${Math.random()
            .toString(36)
            .slice(2, 8)}`,
          kind: 'image' as const,
          sender: 'assistant' as const,
          imageUrl: payload.reveal.imageUrl,
          caption: payload.reveal.caption,
          proactive: {
            slotKey: 'lunch_share',
            category: payload.reveal.category,
            generatedAt: new Date().toISOString(),
          },
        };
        try {
          await insertStoreMessages(character.id, [revealImage]);
        } catch (storeErr) {
          // 비치명: 서버 측에 persist 됐으니 reload 시 복구.
          console.warn('[chat] reveal image store insert 실패:', storeErr);
        }
      }

      // Persist conversation to remote
      saveCharacterConversation(character.id, nextMessages).catch(
        (saveError: unknown) => {
          captureError(saveError, {
            surface: 'chat:character-chat-save-conversation',
          }).catch(() => undefined);
        },
      );

      // Phase 2 — foreground 렌더 완료 ACK. 백엔드 cron 이 같은 메시지를
      // 푸시로 다시 보내지 않도록 client_acked_at 마킹. 실패해도 사용자
      // 가시 영향은 없음 — 푸시 1회 중복 노이즈만 발생할 수 있음 (backend
      // 가 20초 grace window 로 race 완화).
      // ackScheduledReplyIfPresent (push-notifications.ts) 가 module-scope
      // dedup Set 보유 → 같은 scheduledId 가 send→response + push receive
      // 양쪽 채널로 도착해도 네트워크 1회만.
      ackScheduledReplyIfPresent(scheduledId);
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
        rollbackUserMessages(character.id, effectiveUserMessageIds);

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
          setAuthMessage('세션이 만료되었어요. 다시 로그인해 주세요.');
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

      // 네트워크/서버 실패: 가짜 AI 응답 주입 금지. 사용자 메시지 롤백 + draft 복구.
      shouldClearDraft = false;
      setDraft(trimmed);
      clearReadReceiptTimer(character.id);
      rollbackUserMessages(character.id, effectiveUserMessageIds);
      Alert.alert(
        '메시지 전송 실패',
        '네트워크가 불안정해요. 잠시 후 다시 보내볼까요?',
      );
    } finally {
      setStoryTypingByCharacterId((current) =>
        current[character.id]
          ? { ...current, [character.id]: false }
          : current,
      );
      setGlobalTyping(character.id, false);
      if (shouldClearDraft) {
        setDraft('');
      }
      drainNextPendingSend(character);
    }
  }

  function handleSendDraft() {
    const trimmed = draft.trim();
    const pendingImage = pendingImageByCharacterId[selectedCharacter.id];
    const pendingAudio = pendingAudioByCharacterId[selectedCharacter.id];

    // 이 캐릭터에 유저가 처음 메시지를 보내는 시점이면 푸시 권한 soft-ask.
    // fire-and-forget — 모달은 비동기로 뜨고, 실제 send 흐름은 절대 막히지 않음.
    // 이미 granted/denied/soft-asked cooldown 중이면 helper 가 알아서 noop.
    //
    // 하늘이(haneul_oracle) 는 운세-only persona — proactive 답장/먼저 말걸기
    // 없어 푸시 가치 0. 모달 exclude.
    const existingThread = displayMessagesByCharacterId[selectedCharacter.id] ?? [];
    const hasPriorUserMessage = existingThread.some(
      (m) => m.sender === 'user',
    );
    const willSendSomething = Boolean(trimmed) || Boolean(pendingImage) || Boolean(pendingAudio);
    const isPushEligibleCharacter =
      selectedCharacter.id !== haneulOracleCharacter.id;
    if (
      !hasPriorUserMessage &&
      willSendSomething &&
      isPushEligibleCharacter
    ) {
      void maybePromptPushPermissionForCharacter(selectedCharacter.name);
    }

    // 이미지 첨부가 있으면 여기서 먼저 처리한다.
    // 사진 자체에는 캡션을 붙이지 않는다. 스토리 파일럿은 trimmed 를 별도 유저 텍스트로
    // append 하므로, 이미지 아래 캡션까지 표시하면 같은 문장이 두 번 보인다.
    if (pendingImage) {
      const imageMessage = buildUserImageMessage(pendingImage.uri);
      const isStoryPilotImageSend =
        pendingImage.base64 && isStoryRomancePilotCharacterId(selectedCharacter.id);
      const messagesToAppend =
        trimmed && !isStoryPilotImageSend
          ? [imageMessage, buildUserMessage(trimmed)]
          : [imageMessage];
      appendMessages(selectedCharacter, messagesToAppend);
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

    if (pendingAudio) {
      const audioMessage = buildUserAudioMessage(
        pendingAudio.uri,
        pendingAudio.durationMillis,
      );
      const messagesToAppend = trimmed
        ? [audioMessage, buildUserMessage(trimmed)]
        : [audioMessage];
      appendMessages(selectedCharacter, messagesToAppend);
      setSurfaceMode('chat');
      setComposerTrayOpen(false);
      if (trimmed) setDraft('');
      handleClearPendingAudio();

      recordChatIntent({
        characterId: selectedCharacter.id,
        fortuneType: activeFortuneType,
        incrementMessages: true,
      }).catch((error) => {
        captureError(error, { surface: 'chat:record-audio-send' }).catch(
          () => undefined,
        );
      });

      // Raw audio is a user-visible attachment for now. LLM context still receives
      // caption text only until the backend accepts audioBase64/audio_url parts.
      if (selectedCharacter.kind === 'story' && trimmed) {
        enqueueStorySend(selectedCharacter, trimmed);
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

    // 스토리/커스텀 친구 모든 텍스트는 enqueueStorySend 로 라우팅 — 5초 idle
    // 윈도우가 단일 메시지 케이스도 동일하게 처리한다 (AC3).
    if (isStoryCharacter && trimmed) {
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
    const currentMessages = displayMessagesByCharacterId[selectedCharacter.id] ?? [];
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
    const thread = displayMessagesByCharacterId[characterId] ?? [];

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
    const generationController = startFortuneGenerationController(character.id);
    if (!generationController) {
      appendMessages(character, [
        buildAssistantTextMessage(
          '이전 운세 결과가 마무리되는 중이에요. 잠시만 기다린 뒤 다시 시작해 주세요.',
        ),
      ]);
      return;
    }
    setFortuneTypingCharacterId(character.id);
    try {
      const embeddedResult = await resolveFortuneResultMessage(
        fortuneType,
        buildResultContext(character),
        'chat:begin-runtime',
        generationController.signal,
      );

      if (!embeddedResult || !isCurrentFortuneGeneration(character.id, generationController)) {
        return;
      }

      appendMessages(character, [
        buildAssistantTextMessage('좋아요. 결과를 같은 대화 안에 바로 붙여드릴게요.'),
        embeddedResult,
      ]);
    } finally {
      clearFortuneGenerationController(character.id, generationController);
      if (fortuneGenerationControllersRef.current[character.id] === undefined) {
        setFortuneTypingCharacterId(null);
      }
    }
  }

  async function resolveFortuneResultMessage(
    fortuneType: FortuneTypeId,
    context: ReturnType<typeof buildResultContext>,
    surface: string,
    signal?: AbortSignal,
  ) {
    try {
      const payload = await fetchEmbeddedEdgeResultPayload(
        fortuneType,
        context,
        {
          userId: session?.user.id ?? null,
          aiMode: mobileAppState.settings.aiMode,
          signal,
        },
      );

      if (payload) {
        return buildEmbeddedResultMessageFromPayload(payload);
      }
    } catch (error) {
      if (isAbortError(error) && signal?.aborted) {
        return null;
      }
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
      dismissKeyboardOnTap={surfaceMode === 'chat'}
      header={
        gate === 'ready' && surfaceMode === 'chat' ? (
          <View>
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
            {selectedCharacter.id !== haneulOracleCharacter.id ? (
              <PushDeniedBanner characterName={selectedCharacter.name} />
            ) : null}
          </View>
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
              onCancel={() => cancelFortuneFlow(selectedCharacter)}
              onSubmitSelection={handleSurveySubmitSelection}
              onSubmitText={handleSurveySubmitText}
              onToggleSelection={handleSurveyToggleSelection}
              selections={surveySelections}
              step={currentSurveyStep.step}
              surveyAnswers={activeSurvey?.answers}
            />
          ) : selectedFortuneIsTyping ? (
            <View
              style={{
                alignItems: 'center',
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderColor: fortuneTheme.colors.border,
                borderRadius: fortuneTheme.radius.inputArea,
                borderWidth: 1,
                gap: 8,
                marginBottom: 18,
                paddingHorizontal: 14,
                paddingVertical: 12,
              }}
            >
              <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
                {selectedFortuneGenerationCanCancel
                  ? '운세 결과를 준비하고 있어요. 원하면 지금 취소할 수 있어요.'
                  : '운세 결과를 마무리하고 있어요. 잠시만 기다려 주세요.'}
              </AppText>
              {selectedFortuneGenerationCanCancel ? (
                <Pressable
                  accessibilityLabel="운세 생성 취소"
                  accessibilityRole="button"
                  onPress={() => cancelFortuneFlow(selectedCharacter)}
                  style={({ pressed }) => ({ opacity: pressed ? 0.72 : 1 })}
                >
                  <View
                    style={{
                      backgroundColor: fortuneTheme.colors.backgroundTertiary,
                      borderRadius: 999,
                      paddingHorizontal: 18,
                      paddingVertical: 10,
                    }}
                  >
                    <AppText variant="labelLarge">운세 보기 취소</AppText>
                  </View>
                </Pressable>
              ) : null}
            </View>
          ) : (
            <ActiveChatComposer
              draft={draft}
              onDraftChange={setDraft}
              onOpenPhotoPicker={handleOpenPhotoPicker}
              onToggleAudioMessageRecording={handleToggleAudioMessageRecording}
              onOpenPersonaSettings={handleOpenPersonaSettings}
              onPickAction={handleActionPress}
              onSend={handleSendDraft}
              onToggleVoiceInput={handleToggleVoiceInput}
              voiceInputState={voiceInputState}
              voiceVolume={voiceVolume}
              onToggleTray={() => setComposerTrayOpen((current) => !current)}
              quickActions={selectedCharacterActions}
              trayOpen={composerTrayOpen}
              hasCustomPersona={Boolean(personaByCharacterId[selectedCharacter.id])}
              pendingImageUri={
                pendingImageByCharacterId[selectedCharacter.id]?.uri
              }
              onRemovePendingImage={handleClearPendingImage}
              pendingAudioDurationMillis={
                pendingAudioByCharacterId[selectedCharacter.id]
                  ? (pendingAudioByCharacterId[selectedCharacter.id]?.durationMillis ?? 0)
                  : undefined
              }
              onRemovePendingAudio={handleClearPendingAudio}
              audioMessageRecording={recordingAudioForCharacterId === selectedCharacter.id}
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
            onDeleteUserMessage={handleDeleteUserMessage}
            ttsControllerStatus={tts.state.status}
            ttsActiveMessageId={tts.state.activeMessageId}
            ttsError={tts.state.error}
            onPlayTts={handlePlayTts}
            onStopTts={handleStopTts}
            onSelectFortuneMenuEntry={handleSelectFortuneMenuEntry}
          />
        ) : (
          <ChatFirstRunSurface
            activeTab={activeTab}
            characters={sortedFirstRunCharacters}
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

      <AllFortunesSheet
        visible={allFortunesSheetVisible}
        onClose={() => setAllFortunesSheetVisible(false)}
        onSelect={(entry) => {
          setAllFortunesSheetVisible(false);
          handleSelectFortuneMenuEntry(entry);
        }}
      />

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
            {'\n'}예: &quot;더 츤데레하게&quot;, &quot;반말로 해줘&quot;, &quot;질투 많이 해줘&quot;
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

      {/* PR-B2: 하늘이 운세 메뉴 entry 탭 시 비용 확인 sheet. */}
      <CostConfirmationSheet
        visible={costSheetVisible}
        entry={pendingMenuEntry}
        currentBalance={mobileAppState.premium.tokenBalance ?? null}
        isUnlimited={mobileAppState.premium.isUnlimited}
        onConfirm={handleConfirmCostSheet}
        onCancel={handleCancelCostSheet}
        onTopUpRequest={handleTopUpFromCostSheet}
      />
    </Screen>
  );
}
