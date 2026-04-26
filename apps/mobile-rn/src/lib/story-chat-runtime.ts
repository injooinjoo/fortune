import { type Session } from '@supabase/supabase-js';

import { type ChatCharacterSpec } from './chat-characters';
import { saveCachedCharacterMessages } from './character-conversation-cache';
import {
  type ChatShellMessage,
  type ChatShellTextMessage,
} from './chat-shell';
import { captureError } from './error-reporting';
import { getSecureItem, setSecureItem } from './secure-store-storage';
import { supabase } from './supabase';
import {
  buildPilotStoryFallbackReply,
  buildPilotStoryInitialThread,
  buildStoryRomanceSystemPrompt,
  clampSafeAffectionCap,
  getStoryRomanceProfile,
  inferStoryAffectionStage,
  isStoryAffectionStage,
  normalizeStoryRomanceState,
  type StoryAffectionStage,
  type StoryResponseGoal,
  type StoryRomanceState,
  type StorySceneIntent,
} from './story-romance-pilots';

export interface StoryChatMessagePayload {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface StoryChatRequest {
  characterId: string;
  personaKey: string;
  systemPrompt: string;
  messages: StoryChatMessagePayload[];
  userMessage: string;
  romanceState: StoryRomanceState;
  sceneIntent: StorySceneIntent;
  responseGoal: StoryResponseGoal;
  safeAffectionCap: number;
}

export interface StoryChatResponse {
  success?: boolean;
  response: string;
  /**
   * 카톡식 멀티버블 분할. 서버가 [SPLIT] 토큰으로 나눈 텍스트 덩어리들.
   * 항상 `[response]` 이상을 가짐 (단일 응답이면 길이 1).
   * on-device 경로에서는 undefined 가능 → 소비자는 `[response]`로 폴백.
   */
  segments?: string[];
  emotionTag?: string;
  delaySec?: number;
  affinityDelta?: {
    points: number;
    reason: string;
    quality: string;
  };
  romanceStatePatch?: Partial<StoryRomanceState>;
  followUpHint?: string;
  meta?: {
    provider?: string;
    model?: string;
    latencyMs?: number;
    fallbackUsed?: boolean;
  };
  error?: string;
}

export interface StoryChatThreadSnapshot {
  characterId: string;
  personaKey: string;
  messages: ChatShellMessage[];
  romanceState: StoryRomanceState;
  sceneIntent: StorySceneIntent;
  responseGoal: StoryResponseGoal;
  safeAffectionCap: number;
  followUpHint: string | null;
  updatedAt: string;
}

interface PersistedStoryMessage {
  id: string;
  type: 'user' | 'character' | 'system' | 'narration';
  content: string;
  timestamp: string;
  /**
   * 카톡식 "1" 읽음 배지 ISO 타임스탬프. `type: 'user'` 메시지에서만 의미.
   * 빠진 채로 저장된 과거 데이터는 `fromPersistedStoryMessages` 로드 단계에서
   * "뒤에 AI/system 응답이 있으면 그 시점에 읽혔다"로 추론 보강된다.
   */
  readAt?: string;
}

interface PersistedStoryRuntimeState {
  personaKey?: string;
  romanceState?: unknown;
  sceneIntent?: unknown;
  responseGoal?: unknown;
  safeAffectionCap?: unknown;
  followUpHint?: unknown;
}

interface StoryConversationLoadResponse {
  success?: boolean;
  messages?: unknown;
  lastMessageAt?: string | null;
  runtimeState?: PersistedStoryRuntimeState | null;
  error?: string;
}

const storyChatThreadStorageKeyPrefix =
  'fortune.mobile-rn.story-chat-thread.v1';

function resolveStoryChatThreadStorageKey(
  characterId: string,
  userId: string | null,
) {
  return `${storyChatThreadStorageKeyPrefix}.${userId ?? 'guest'}.${characterId}`;
}

async function resolveCurrentSession(): Promise<Session | null> {
  if (!supabase) {
    return null;
  }

  const { data } = await supabase.auth.getSession();
  return data.session ?? null;
}

function isTextMessage(message: ChatShellMessage) {
  return message.kind === 'text';
}

function normalizeChatShellMessage(raw: unknown): ChatShellMessage | null {
  if (!raw || typeof raw !== 'object') {
    return null;
  }

  const candidate = raw as Record<string, unknown>;

  if (candidate.kind !== 'text') {
    return null;
  }

  if (
    typeof candidate.id !== 'string' ||
    typeof candidate.text !== 'string' ||
    (candidate.sender !== 'assistant' &&
      candidate.sender !== 'user' &&
      candidate.sender !== 'system')
  ) {
    return null;
  }

  return {
    id: candidate.id,
    kind: 'text',
    sender: candidate.sender,
    text: candidate.text,
  };
}

function createTimestampFromMessageId(messageId: string, fallback: string) {
  const match = messageId.match(/-(\d{13})-/);
  if (!match?.[1]) {
    return fallback;
  }

  const timestamp = new Date(Number(match[1]));
  return Number.isNaN(timestamp.getTime()) ? fallback : timestamp.toISOString();
}

// 원격 저장 메시지 수 상한. 50 에서 200 으로 상향 — 활성 유저는 세션 몇 개만에도
// 100+ 메시지가 쌓이고, 그러면 load 때마다 원격이 잘린 상태로 돌아와 focus
// 재하이드레이션 시 shouldAcceptRemoteMessages 가 reject 하더라도 로컬 SecureStore
// (P1 가드 전까지) 가 손상되던 원인이었다. 200 은 gemini 컨텍스트 / edge row
// 크기 모두 여유.
const REMOTE_PERSIST_MESSAGE_CAP = 200;

function toPersistedStoryMessages(
  messages: ChatShellMessage[],
): PersistedStoryMessage[] {
  return messages
    .filter(isTextMessage)
    .slice(-REMOTE_PERSIST_MESSAGE_CAP)
    .map((message) => {
      const textMessage = message as ChatShellTextMessage;
      const base: PersistedStoryMessage = {
        id: textMessage.id,
        type:
          textMessage.sender === 'assistant'
            ? 'character'
            : textMessage.sender === 'system'
              ? 'system'
              : 'user',
        content: textMessage.text,
        timestamp: createTimestampFromMessageId(
          textMessage.id,
          new Date().toISOString(),
        ),
      };
      // "1" 배지 안 사라지는 버그의 근본 원인: readAt 이 로컬 전용이었음.
      // 서버에 함께 저장해야 재진입 시 force-rehydrate 해도 보존된다.
      if (textMessage.sender === 'user' && textMessage.readAt) {
        base.readAt = textMessage.readAt;
      }
      return base;
    });
}

function fromPersistedStoryMessages(
  messages: unknown,
): ChatShellMessage[] {
  if (!Array.isArray(messages)) {
    return [];
  }

  const normalizedMessages: Array<ChatShellTextMessage | null> = messages
    .map((rawMessage): ChatShellTextMessage | null => {
      if (!rawMessage || typeof rawMessage !== 'object') {
        return null;
      }

      const candidate = rawMessage as Record<string, unknown>;
      if (
        typeof candidate.id !== 'string' ||
        typeof candidate.content !== 'string' ||
        (candidate.type !== 'user' &&
          candidate.type !== 'character' &&
          candidate.type !== 'system' &&
          candidate.type !== 'narration')
      ) {
        return null;
      }

      const sender: ChatShellTextMessage['sender'] =
        candidate.type === 'user'
          ? 'user'
          : candidate.type === 'system'
            ? 'system'
            : 'assistant';

      const message: ChatShellTextMessage = {
        id: candidate.id,
        kind: 'text' as const,
        sender,
        text: candidate.content,
      };

      if (sender === 'user' && typeof candidate.readAt === 'string') {
        message.readAt = candidate.readAt;
      }

      return message;
    });

  const filtered = normalizedMessages.filter(
    (message): message is ChatShellTextMessage => message !== null,
  );

  // 레거시 데이터 보강: 서버에 readAt 필드 없이 저장된 과거 메시지 대응.
  // "뒤에 assistant/system 응답이 하나라도 있으면 그 user 메시지는 읽힌 것"
  // 으로 간주한다. AI가 답을 했다 = 읽었다는 사용자 멘탈 모델과 일치.
  // 한 번이라도 이 경로로 통과한 메시지는 다음 save 때 readAt이 서버에 함께
  // 저장되므로, 이 보강은 사실상 1회성 마이그레이션 역할.
  for (let i = 0; i < filtered.length; i += 1) {
    const current = filtered[i];
    if (current.sender !== 'user' || current.readAt) continue;
    for (let j = i + 1; j < filtered.length; j += 1) {
      const later = filtered[j];
      if (later.sender === 'assistant' || later.sender === 'system') {
        const fallbackTimestamp = createTimestampFromMessageId(
          later.id,
          new Date().toISOString(),
        );
        current.readAt = fallbackTimestamp;
        break;
      }
    }
  }

  return filtered;
}

function clampMetric(value: unknown, fallback: number) {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    return fallback;
  }

  return Math.max(0, Math.min(100, Math.round(value)));
}

function normalizeAffectionStage(
  value: unknown,
  fallback: StoryAffectionStage,
): StoryAffectionStage {
  return isStoryAffectionStage(value) ? value : fallback;
}

function isSceneIntent(value: unknown): value is StorySceneIntent {
  return (
    value === 'opening' ||
    value === 'check_in' ||
    value === 'comfort' ||
    value === 'flirt_softly' ||
    value === 'repair' ||
    value === 'reopen_memory'
  );
}

function isResponseGoal(value: unknown): value is StoryResponseGoal {
  return (
    value === 'ground_the_moment' ||
    value === 'nurture_curiosity' ||
    value === 'repair_distance' ||
    value === 'keep_soft_boundaries' ||
    value === 'deepen_attachment'
  );
}

function normalizeStoryRomanceStateValue(
  raw: unknown,
  fallback: StoryRomanceState,
  safeAffectionCap: number,
): StoryRomanceState {
  if (!raw || typeof raw !== 'object') {
    return fallback;
  }

  const candidate = raw as Partial<StoryRomanceState>;
  const nextState = normalizeStoryRomanceState(
    {
      attachmentSignal: clampMetric(
        candidate.attachmentSignal,
        fallback.attachmentSignal,
      ),
      emotionalTemperature: clampMetric(
        candidate.emotionalTemperature,
        fallback.emotionalTemperature,
      ),
      pursuitBalance: clampMetric(candidate.pursuitBalance, fallback.pursuitBalance),
      vulnerabilityWindow: clampMetric(
        candidate.vulnerabilityWindow,
        fallback.vulnerabilityWindow,
      ),
      boundarySensitivity: clampMetric(
        candidate.boundarySensitivity,
        fallback.boundarySensitivity,
      ),
      replyEnergy: clampMetric(candidate.replyEnergy, fallback.replyEnergy),
      repairNeed: clampMetric(candidate.repairNeed, fallback.repairNeed),
      dailyHook:
        typeof candidate.dailyHook === 'string' && candidate.dailyHook.trim().length > 0
          ? candidate.dailyHook.trim()
          : fallback.dailyHook,
      safeAffectionStage: normalizeAffectionStage(
        candidate.safeAffectionStage,
        fallback.safeAffectionStage,
      ),
    },
    safeAffectionCap,
  );

  return {
    ...nextState,
    safeAffectionStage: normalizeAffectionStage(
      candidate.safeAffectionStage,
      inferStoryAffectionStage(
        nextState.attachmentSignal,
        nextState.emotionalTemperature,
        safeAffectionCap,
      ),
    ),
  };
}

function normalizeStoryRomanceStatePatch(
  raw: unknown,
): Partial<StoryRomanceState> | null {
  if (!raw || typeof raw !== 'object') {
    return null;
  }

  const candidate = raw as Partial<StoryRomanceState>;
  const nextPatch: Partial<StoryRomanceState> = {};

  if (typeof candidate.attachmentSignal === 'number') {
    nextPatch.attachmentSignal = clampMetric(candidate.attachmentSignal, 0);
  }
  if (typeof candidate.emotionalTemperature === 'number') {
    nextPatch.emotionalTemperature = clampMetric(
      candidate.emotionalTemperature,
      0,
    );
  }
  if (typeof candidate.pursuitBalance === 'number') {
    nextPatch.pursuitBalance = clampMetric(candidate.pursuitBalance, 0);
  }
  if (typeof candidate.vulnerabilityWindow === 'number') {
    nextPatch.vulnerabilityWindow = clampMetric(
      candidate.vulnerabilityWindow,
      0,
    );
  }
  if (typeof candidate.boundarySensitivity === 'number') {
    nextPatch.boundarySensitivity = clampMetric(
      candidate.boundarySensitivity,
      0,
    );
  }
  if (typeof candidate.replyEnergy === 'number') {
    nextPatch.replyEnergy = clampMetric(candidate.replyEnergy, 0);
  }
  if (typeof candidate.repairNeed === 'number') {
    nextPatch.repairNeed = clampMetric(candidate.repairNeed, 0);
  }
  if (typeof candidate.dailyHook === 'string' && candidate.dailyHook.trim().length > 0) {
    nextPatch.dailyHook = candidate.dailyHook.trim();
  }
  if (isStoryAffectionStage(candidate.safeAffectionStage)) {
    nextPatch.safeAffectionStage = candidate.safeAffectionStage;
  }

  return Object.keys(nextPatch).length > 0 ? nextPatch : null;
}

function normalizeRuntimeState(
  characterId: string,
  rawRuntimeState: unknown,
  fallbackSnapshot: StoryChatThreadSnapshot,
): Pick<
  StoryChatThreadSnapshot,
  'personaKey' | 'romanceState' | 'sceneIntent' | 'responseGoal' | 'safeAffectionCap' | 'followUpHint'
> {
  const profile = getStoryRomanceProfile(characterId);
  if (!profile) {
    return {
      personaKey: fallbackSnapshot.personaKey,
      romanceState: fallbackSnapshot.romanceState,
      sceneIntent: fallbackSnapshot.sceneIntent,
      responseGoal: fallbackSnapshot.responseGoal,
      safeAffectionCap: fallbackSnapshot.safeAffectionCap,
      followUpHint: fallbackSnapshot.followUpHint,
    };
  }

  const candidate =
    rawRuntimeState && typeof rawRuntimeState === 'object'
      ? (rawRuntimeState as PersistedStoryRuntimeState)
      : null;
  const safeAffectionCap = clampSafeAffectionCap(
    typeof candidate?.safeAffectionCap === 'number'
      ? candidate.safeAffectionCap
      : fallbackSnapshot.safeAffectionCap,
  );

  return {
    personaKey:
      typeof candidate?.personaKey === 'string' && candidate.personaKey.length > 0
        ? candidate.personaKey
        : fallbackSnapshot.personaKey || profile.personaKey,
    romanceState: normalizeStoryRomanceStateValue(
      candidate?.romanceState,
      fallbackSnapshot.romanceState,
      safeAffectionCap,
    ),
    sceneIntent: isSceneIntent(candidate?.sceneIntent)
      ? candidate.sceneIntent
      : fallbackSnapshot.sceneIntent,
    responseGoal: isResponseGoal(candidate?.responseGoal)
      ? candidate.responseGoal
      : fallbackSnapshot.responseGoal,
    safeAffectionCap,
    followUpHint:
      typeof candidate?.followUpHint === 'string' &&
      candidate.followUpHint.trim().length > 0
        ? candidate.followUpHint.trim()
        : fallbackSnapshot.followUpHint,
  };
}

function normalizeStoryChatResponse(raw: unknown): StoryChatResponse {
  if (!raw || typeof raw !== 'object') {
    throw new Error('Story chat response payload is empty.');
  }

  const candidate = raw as Record<string, unknown>;
  const affinityDeltaCandidate =
    candidate.affinityDelta && typeof candidate.affinityDelta === 'object'
      ? (candidate.affinityDelta as Record<string, unknown>)
      : null;
  const metaCandidate =
    candidate.meta && typeof candidate.meta === 'object'
      ? (candidate.meta as Record<string, unknown>)
      : null;
  if (typeof candidate.response !== 'string' || candidate.response.trim().length === 0) {
    throw new Error('Story chat response text is missing.');
  }

  const rawSegments = Array.isArray(candidate.segments)
    ? candidate.segments.filter(
        (segment): segment is string =>
          typeof segment === 'string' && segment.trim().length > 0,
      )
    : null;
  const segments =
    rawSegments && rawSegments.length > 0
      ? rawSegments
      : [candidate.response.trim()];

  return {
    success: typeof candidate.success === 'boolean' ? candidate.success : true,
    response: candidate.response,
    segments,
    emotionTag:
      typeof candidate.emotionTag === 'string' ? candidate.emotionTag : undefined,
    delaySec:
      typeof candidate.delaySec === 'number' ? candidate.delaySec : undefined,
    affinityDelta:
      affinityDeltaCandidate &&
      (typeof affinityDeltaCandidate.points === 'number' ||
        typeof affinityDeltaCandidate.reason === 'string' ||
        typeof affinityDeltaCandidate.quality === 'string')
        ? {
            points:
              typeof affinityDeltaCandidate.points === 'number'
                ? affinityDeltaCandidate.points
                : 0,
            reason:
              typeof affinityDeltaCandidate.reason === 'string'
                ? affinityDeltaCandidate.reason
                : 'basic_chat',
            quality:
              typeof affinityDeltaCandidate.quality === 'string'
                ? affinityDeltaCandidate.quality
                : 'neutral',
          }
        : undefined,
    romanceStatePatch:
      normalizeStoryRomanceStatePatch(candidate.romanceStatePatch) ?? undefined,
    followUpHint:
      typeof candidate.followUpHint === 'string'
        ? candidate.followUpHint.trim()
        : undefined,
    meta:
      metaCandidate &&
      (typeof metaCandidate.provider === 'string' ||
        typeof metaCandidate.model === 'string' ||
        typeof metaCandidate.latencyMs === 'number' ||
        typeof metaCandidate.fallbackUsed === 'boolean')
        ? {
            provider:
              typeof metaCandidate.provider === 'string'
                ? metaCandidate.provider
                : undefined,
            model:
              typeof metaCandidate.model === 'string'
                ? metaCandidate.model
                : undefined,
            latencyMs:
              typeof metaCandidate.latencyMs === 'number'
                ? metaCandidate.latencyMs
                : undefined,
            fallbackUsed:
              typeof metaCandidate.fallbackUsed === 'boolean'
                ? metaCandidate.fallbackUsed
                : undefined,
          }
        : undefined,
    error: typeof candidate.error === 'string' ? candidate.error : undefined,
  };
}

function normalizeStoryConversationLoadResponse(
  raw: unknown,
): StoryConversationLoadResponse {
  if (!raw || typeof raw !== 'object') {
    throw new Error('Story conversation payload is empty.');
  }

  return raw as StoryConversationLoadResponse;
}

async function loadLocalStoryThreadSnapshot(
  characterId: string,
): Promise<StoryChatThreadSnapshot | null> {
  const profile = getStoryRomanceProfile(characterId);
  if (!profile) {
    return null;
  }

  const session = await resolveCurrentSession();
  const storageKey = resolveStoryChatThreadStorageKey(
    characterId,
    session?.user.id ?? null,
  );
  const raw = await getSecureItem(storageKey);

  if (!raw) {
    return null;
  }

  try {
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    const fallbackSnapshot = buildStoryThreadSnapshot({
      id: characterId,
    } as ChatCharacterSpec);

    if (!fallbackSnapshot) {
      return null;
    }

    const messages = Array.isArray(parsed.messages)
      ? parsed.messages
          .map((message) => normalizeChatShellMessage(message))
          .filter((message): message is ChatShellMessage => message != null)
      : [];

    if (messages.length === 0) {
      return null;
    }

    const runtimeState = normalizeRuntimeState(
      characterId,
      parsed.runtimeState ?? parsed,
      fallbackSnapshot,
    );

    return {
      characterId,
      personaKey: runtimeState.personaKey,
      messages,
      romanceState: runtimeState.romanceState,
      sceneIntent: runtimeState.sceneIntent,
      responseGoal: runtimeState.responseGoal,
      safeAffectionCap: runtimeState.safeAffectionCap,
      followUpHint: runtimeState.followUpHint,
      updatedAt:
        typeof parsed.updatedAt === 'string'
          ? parsed.updatedAt
          : new Date().toISOString(),
    };
  } catch (error) {
    // 손상된 snapshot — 무음으로 삼키면 cold start 직후 인트로만 보이는
    // 회귀가 디버깅 불가능해진다. 보고 후 null 로 빠져 fallback 분기 진입.
    captureError(error, {
      surface: 'story-chat:load-local-snapshot-parse',
    }).catch(() => undefined);
    return null;
  }
}

async function saveLocalStoryThreadSnapshot(
  snapshot: StoryChatThreadSnapshot,
): Promise<void> {
  const session = await resolveCurrentSession();
  const storageKey = resolveStoryChatThreadStorageKey(
    snapshot.characterId,
    session?.user.id ?? null,
  );

  await setSecureItem(storageKey, JSON.stringify(snapshot));
}

async function loadRemoteStoryThreadSnapshot(
  characterId: string,
  fallbackSnapshot: StoryChatThreadSnapshot,
): Promise<StoryChatThreadSnapshot | null> {
  if (!supabase) {
    return null;
  }

  const session = await resolveCurrentSession();
  if (!session) {
    return null;
  }

  const { data, error } = await supabase.functions.invoke(
    'character-conversation-load',
    {
      body: { characterId },
    },
  );

  if (error) {
    throw error;
  }

  const payload = normalizeStoryConversationLoadResponse(data);
  if (payload.success === false) {
    throw new Error(payload.error ?? 'Failed to load story conversation.');
  }

  const messages = fromPersistedStoryMessages(payload.messages);
  if (messages.length === 0) {
    return null;
  }

  const runtimeState = normalizeRuntimeState(
    characterId,
    payload.runtimeState,
    fallbackSnapshot,
  );

  return {
    characterId,
    personaKey: runtimeState.personaKey,
    messages,
    romanceState: runtimeState.romanceState,
    sceneIntent: runtimeState.sceneIntent,
    responseGoal: runtimeState.responseGoal,
    safeAffectionCap: runtimeState.safeAffectionCap,
    followUpHint: runtimeState.followUpHint,
    updatedAt: payload.lastMessageAt ?? new Date().toISOString(),
  };
}

async function saveRemoteStoryThreadSnapshot(
  snapshot: StoryChatThreadSnapshot,
): Promise<void> {
  if (!supabase) {
    return;
  }

  const session = await resolveCurrentSession();
  if (!session) {
    return;
  }

  const { data, error } = await supabase.functions.invoke(
    'character-conversation-save',
    {
      body: {
        characterId: snapshot.characterId,
        messages: toPersistedStoryMessages(snapshot.messages),
        runtimeState: {
          personaKey: snapshot.personaKey,
          romanceState: snapshot.romanceState,
          sceneIntent: snapshot.sceneIntent,
          responseGoal: snapshot.responseGoal,
          safeAffectionCap: snapshot.safeAffectionCap,
          followUpHint: snapshot.followUpHint,
        },
      },
    },
  );

  if (error) {
    throw error;
  }

  const payload = data as { success?: boolean; error?: string } | null;
  if (payload?.success === false) {
    throw new Error(payload.error ?? 'Failed to save story conversation.');
  }
}

export function buildStoryThreadSnapshot(
  character: ChatCharacterSpec,
): StoryChatThreadSnapshot | null {
  const profile = getStoryRomanceProfile(character.id);

  if (!profile) {
    return null;
  }

  return {
    characterId: character.id,
    personaKey: profile.personaKey,
    messages: buildPilotStoryInitialThread(character),
    romanceState: profile.romanceState,
    sceneIntent: profile.sceneIntent,
    responseGoal: profile.responseGoal,
    safeAffectionCap: profile.safeAffectionCap,
    followUpHint: profile.romanceState.dailyHook,
    updatedAt: new Date().toISOString(),
  };
}

export function buildStoryChatRequest(
  character: ChatCharacterSpec,
  userMessage: string,
  thread: StoryChatThreadSnapshot | null,
): StoryChatRequest | null {
  const profile = getStoryRomanceProfile(character.id);

  if (!profile) {
    return null;
  }

  const sceneIntent = resolveSceneIntent(
    userMessage,
    thread?.sceneIntent ?? profile.sceneIntent,
  );
  const responseGoal = resolveResponseGoal(
    userMessage,
    thread?.responseGoal ?? profile.responseGoal,
  );

  return {
    characterId: character.id,
    personaKey: profile.personaKey,
    systemPrompt: buildStoryRomanceSystemPrompt(character),
    messages: (thread?.messages ?? buildPilotStoryInitialThread(character))
      .filter(isTextMessage)
      .slice(-14)
      .map((message) => ({
        role: message.sender,
        content: message.text,
      })),
    userMessage,
    romanceState: thread?.romanceState ?? profile.romanceState,
    sceneIntent,
    responseGoal,
    safeAffectionCap: thread?.safeAffectionCap ?? profile.safeAffectionCap,
  };
}

function resolveSceneIntent(
  userMessage: string,
  fallback: StorySceneIntent,
): StorySceneIntent {
  const normalized = userMessage.trim();

  if (!normalized) {
    return fallback;
  }

  if (/미안|사과|서운|상처|다퉜|화났/.test(normalized)) {
    return 'repair';
  }
  if (/좋아|설레|보고싶|궁금|더 알고/.test(normalized)) {
    return 'flirt_softly';
  }
  if (/괜찮|힘들|지쳐|위로|안아/.test(normalized)) {
    return 'comfort';
  }
  if (/다시|이어|reopen|계속/.test(normalized)) {
    return 'reopen_memory';
  }
  if (/안녕|처음|시작/.test(normalized)) {
    return 'opening';
  }

  return fallback;
}

function resolveResponseGoal(
  userMessage: string,
  fallback: StoryResponseGoal,
): StoryResponseGoal {
  const normalized = userMessage.trim();

  if (!normalized) {
    return fallback;
  }

  if (/미안|사과|서운|상처|다퉜|화났/.test(normalized)) {
    return 'repair_distance';
  }
  if (/좋아|설레|보고싶|궁금|더 알고/.test(normalized)) {
    return 'deepen_attachment';
  }
  if (/괜찮|힘들|지쳐|위로|안아/.test(normalized)) {
    return 'ground_the_moment';
  }
  if (/다시|이어|reopen|계속/.test(normalized)) {
    return 'repair_distance';
  }

  return fallback;
}

export function buildStoryFallbackAssistantMessage(
  character: ChatCharacterSpec,
): ChatShellMessage {
  return buildPilotStoryFallbackReply(character);
}

export async function loadStoryThreadSnapshot(
  characterId: string,
): Promise<StoryChatThreadSnapshot | null> {
  const profile = getStoryRomanceProfile(characterId);

  if (!profile) {
    return null;
  }

  const initialSnapshot = buildStoryThreadSnapshot({ id: characterId } as ChatCharacterSpec);
  const localSnapshot = await loadLocalStoryThreadSnapshot(characterId);
  const fallbackSnapshot = localSnapshot ?? initialSnapshot;

  if (!fallbackSnapshot) {
    return null;
  }

  try {
    const remoteSnapshot = await loadRemoteStoryThreadSnapshot(
      characterId,
      fallbackSnapshot,
    );

    if (remoteSnapshot) {
      // Local-corruption 연쇄 방어: 원격이 로컬보다 짧으면 로컬을 덮어쓰지 않는다.
      // 배경 — 서버 스키마(character-conversation-save)가 텍스트 전용 +
      // slice(-200) 제한이라, 비-텍스트 카드(포춘쿠키/사주/이미지/임베디드 결과)
      // 또는 최근 200개 초과 히스토리는 원격에 누락된다. 이 상태에서 무조건
      // saveLocalStoryThreadSnapshot(remoteSnapshot) 을 호출하면, load 때마다
      // 로컬 SecureStore 가 stripped 버전으로 덮어써져 비-텍스트 카드가 영구 소실.
      // 메모리 쪽은 shouldAcceptRemoteMessages 가이드로 보호되지만 디스크는 매번
      // 손상되던 치명 버그. 이제 원격이 로컬 이상 길이일 때만 로컬 갱신.
      const localLen = localSnapshot?.messages.length ?? 0;
      const remoteLen = remoteSnapshot.messages.length;
      if (remoteLen >= localLen) {
        await saveLocalStoryThreadSnapshot(remoteSnapshot);
        return remoteSnapshot;
      }
      // 원격이 짧음 → 로컬이 더 최신/완전한 상태. 로컬 유지.
      return localSnapshot;
    }
  } catch (error) {
    if (!localSnapshot) {
      throw error;
    }
  }

  return localSnapshot;
}

export async function saveStoryThreadSnapshot(
  snapshot: StoryChatThreadSnapshot,
): Promise<StoryChatThreadSnapshot> {
  // 로컬 메시지 캐시 — chat-screen 재진입 시 즉시 최신 상태 노출용.
  // story snapshot 과 별개의 SecureStore 키 (`fortune.chat.msgs.v1.*`) 라
  // 한 쪽이 실패해도 다른 쪽은 성공할 수 있다. 무음 fail 로 두면 cold start
  // 직후 인트로만 보이는 회귀의 직접 원인이 되므로 각 단계 실패를 개별 surface
  // 로 보고하고 다른 저장은 계속 시도한다.
  await saveCachedCharacterMessages(
    snapshot.characterId,
    snapshot.messages,
  ).catch((error: unknown) => {
    captureError(error, {
      surface: 'story-chat:save-cached-messages',
    }).catch(() => undefined);
  });
  await saveLocalStoryThreadSnapshot(snapshot).catch((error: unknown) => {
    captureError(error, {
      surface: 'story-chat:save-local-snapshot',
    }).catch(() => undefined);
  });
  await saveRemoteStoryThreadSnapshot(snapshot).catch((error: unknown) => {
    captureError(error, {
      surface: 'story-chat:save-remote-snapshot',
    }).catch(() => undefined);
  });
  return snapshot;
}

export async function invokeStoryChat(
  character: ChatCharacterSpec,
  userMessage: string,
  thread: StoryChatThreadSnapshot | null,
  options?: { userDescription?: string; imageBase64?: string },
): Promise<StoryChatResponse> {
  const request = buildStoryChatRequest(character, userMessage, thread);

  if (!request) {
    throw new Error(`Story chat is not configured for ${character.id}.`);
  }

  if (!supabase) {
    throw new Error('Supabase is not configured.');
  }

  const baseBody = { ...request, conceptType: 'pilot_romance' as const };
  const bodyWithDesc = options?.userDescription
    ? { ...baseBody, userDescription: options.userDescription }
    : baseBody;
  // imageBase64 는 "data:image/jpeg;base64,XXXX" 또는 raw base64. 서버에서 두
  // 경우 모두 받아 LLMFactory 에 image_url 멀티파트로 전달.
  const body = options?.imageBase64
    ? { ...bodyWithDesc, imageBase64: options.imageBase64 }
    : bodyWithDesc;

  const { data, error } = await supabase.functions.invoke('character-chat', {
    body,
  });

  if (error) {
    throw error;
  }

  return normalizeStoryChatResponse(data);
}

function applyStoryRomancePatch(
  current: StoryRomanceState,
  patch: Partial<StoryRomanceState> | null,
  assistantText: string | null,
  safeAffectionCap: number,
): StoryRomanceState {
  const nextState = {
    ...current,
  };

  if (patch) {
    nextState.attachmentSignal =
      patch.attachmentSignal ?? nextState.attachmentSignal;
    nextState.emotionalTemperature =
      patch.emotionalTemperature ?? nextState.emotionalTemperature;
    nextState.pursuitBalance = patch.pursuitBalance ?? nextState.pursuitBalance;
    nextState.vulnerabilityWindow =
      patch.vulnerabilityWindow ?? nextState.vulnerabilityWindow;
    nextState.boundarySensitivity =
      patch.boundarySensitivity ?? nextState.boundarySensitivity;
    nextState.replyEnergy = patch.replyEnergy ?? nextState.replyEnergy;
    nextState.repairNeed = patch.repairNeed ?? nextState.repairNeed;
    nextState.dailyHook = patch.dailyHook ?? nextState.dailyHook;
    nextState.safeAffectionStage = normalizeAffectionStage(
      patch.safeAffectionStage,
      nextState.safeAffectionStage,
    );
  }

  if (!patch && assistantText) {
    if (/미안|서운|걱정|기다|편해|괜찮/.test(assistantText)) {
      nextState.emotionalTemperature = Math.min(
        100,
        nextState.emotionalTemperature + 6,
      );
    }

    if (/보고싶|좋아|궁금|더 알고|가까워/.test(assistantText)) {
      nextState.attachmentSignal = Math.min(
        100,
        nextState.attachmentSignal + 6,
      );
    }

    if (assistantText.trim().length < 42) {
      nextState.replyEnergy = Math.max(28, nextState.replyEnergy - 2);
    }
  }

  if (assistantText && assistantText.trim().length > 0 && nextState.repairNeed > 0) {
    nextState.repairNeed = Math.max(0, nextState.repairNeed - 6);
  }

  const normalized = normalizeStoryRomanceState(nextState, safeAffectionCap);
  return {
    ...normalized,
    safeAffectionStage: patch?.safeAffectionStage
      ? normalizeAffectionStage(patch.safeAffectionStage, normalized.safeAffectionStage)
      : inferStoryAffectionStage(
          normalized.attachmentSignal,
          normalized.emotionalTemperature,
          safeAffectionCap,
        ),
  };
}

export function buildNextStoryThreadSnapshot(
  current: StoryChatThreadSnapshot | null,
  character: ChatCharacterSpec,
  nextMessages: ChatShellMessage[],
  response: StoryChatResponse | null,
  request: StoryChatRequest | null,
): StoryChatThreadSnapshot | null {
  const profile = getStoryRomanceProfile(character.id);

  if (!profile) {
    return null;
  }

  const safeAffectionCap = clampSafeAffectionCap(
    request?.safeAffectionCap ??
      current?.safeAffectionCap ??
      profile.safeAffectionCap,
  );

  return {
    characterId: character.id,
    personaKey: request?.personaKey ?? current?.personaKey ?? profile.personaKey,
    messages: nextMessages,
    romanceState: applyStoryRomancePatch(
      current?.romanceState ?? request?.romanceState ?? profile.romanceState,
      response?.romanceStatePatch ?? null,
      response?.response ?? null,
      safeAffectionCap,
    ),
    sceneIntent: request?.sceneIntent ?? current?.sceneIntent ?? profile.sceneIntent,
    responseGoal:
      request?.responseGoal ?? current?.responseGoal ?? profile.responseGoal,
    safeAffectionCap,
    followUpHint:
      response?.followUpHint ??
      current?.followUpHint ??
      request?.romanceState.dailyHook ??
      profile.romanceState.dailyHook,
    updatedAt: new Date().toISOString(),
  };
}

// ---------------------------------------------------------------------------
// Generic character conversation persistence (non-romance characters)
// Uses the same edge functions but without romance-specific runtime state.
// ---------------------------------------------------------------------------

export async function loadCharacterConversation(
  characterId: string,
): Promise<ChatShellMessage[] | null> {
  if (!supabase) {
    return null;
  }

  const session = await resolveCurrentSession();
  if (!session) {
    return null;
  }

  try {
    const { data, error } = await supabase.functions.invoke(
      'character-conversation-load',
      { body: { characterId } },
    );

    if (error) {
      return null;
    }

    const payload = normalizeStoryConversationLoadResponse(data);
    if (payload.success === false) {
      return null;
    }

    const messages = fromPersistedStoryMessages(payload.messages);
    return messages.length > 0 ? messages : null;
  } catch {
    return null;
  }
}

export async function saveCharacterConversation(
  characterId: string,
  messages: ChatShellMessage[],
): Promise<void> {
  // 로컬 캐시는 네트워크/세션 독립적으로 항상 저장 — 재진입 시 플래시 방지.
  // saveCachedCharacterMessages 가 throw 할 수 있게 바뀌었으므로 await + catch
  // 로 잡아 surface. 이전에 `void ...` 였던 자리는 unhandled rejection 위험 +
  // 무음 디스크 쓰기 실패 라는 두 가지 문제를 동시에 갖고 있었다.
  await saveCachedCharacterMessages(characterId, messages).catch(
    (error: unknown) => {
      captureError(error, {
        surface: 'chat:save-cached-conversation',
      }).catch(() => undefined);
    },
  );

  if (!supabase) {
    return;
  }

  const session = await resolveCurrentSession();
  if (!session) {
    return;
  }

  try {
    await supabase.functions.invoke('character-conversation-save', {
      body: {
        characterId,
        messages: toPersistedStoryMessages(messages),
      },
    });
  } catch (error) {
    // 원격 저장은 네트워크/세션 의존적이라 일시 실패는 정상. 다만 silent
    // 처리 시 "내 메시지가 다른 디바이스에 안 떠요" 류의 회귀를 디버그 못하므로
    // 로컬 cache 와 별개로 surface 만 해둔다 (UX 차단 X).
    captureError(error, {
      surface: 'chat:remote-character-conversation-save',
    }).catch(() => undefined);
  }
}
