import { type Session } from '@supabase/supabase-js';

import { type ChatCharacterSpec } from './chat-characters';
import {
  type ChatShellMessage,
  type ChatShellTextMessage,
} from './chat-shell';
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

function toPersistedStoryMessages(
  messages: ChatShellMessage[],
): PersistedStoryMessage[] {
  return messages
    .filter(isTextMessage)
    .slice(-50)
    .map((message) => ({
      id: message.id,
      type:
        message.sender === 'assistant'
          ? 'character'
          : message.sender === 'system'
            ? 'system'
            : 'user',
      content: message.text,
      timestamp: createTimestampFromMessageId(message.id, new Date().toISOString()),
    }));
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

      return {
        id: candidate.id,
        kind: 'text' as const,
        sender:
          candidate.type === 'user'
            ? 'user'
            : candidate.type === 'system'
              ? 'system'
              : 'assistant',
        text: candidate.content,
      };
    });

  return normalizedMessages.filter(
    (message): message is ChatShellTextMessage => message !== null,
  );
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

  return {
    success: typeof candidate.success === 'boolean' ? candidate.success : true,
    response: candidate.response,
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
  } catch {
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
      await saveLocalStoryThreadSnapshot(remoteSnapshot);
      return remoteSnapshot;
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
  await saveLocalStoryThreadSnapshot(snapshot);
  await saveRemoteStoryThreadSnapshot(snapshot);
  return snapshot;
}

export async function invokeStoryChat(
  character: ChatCharacterSpec,
  userMessage: string,
  thread: StoryChatThreadSnapshot | null,
  options?: { userDescription?: string },
): Promise<StoryChatResponse> {
  const request = buildStoryChatRequest(character, userMessage, thread);

  if (!request) {
    throw new Error(`Story chat is not configured for ${character.id}.`);
  }

  if (!supabase) {
    throw new Error('Supabase is not configured.');
  }

  const body = options?.userDescription
    ? { ...request, userDescription: options.userDescription }
    : request;

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
  } catch {
    // Soft-fail: don't disrupt the user experience
  }
}
