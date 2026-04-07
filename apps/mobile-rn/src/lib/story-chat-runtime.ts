import * as SecureStore from 'expo-secure-store';

import { type ChatCharacterSpec } from './chat-characters';
import { supabase } from './supabase';
import { buildAssistantTextMessage, type ChatShellMessage } from './chat-shell';
import {
  buildPilotStoryFallbackReply,
  buildPilotStoryInitialThread,
  buildStoryRomanceSystemPrompt,
  getStoryRomanceProfile,
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
  updatedAt: string;
}

const storyChatThreadStorageKeyPrefix =
  'fortune.mobile-rn.story-chat-thread.v1';

function resolveStoryChatThreadStorageKey(
  characterId: string,
  userId: string | null,
) {
  return `${storyChatThreadStorageKeyPrefix}.${userId ?? 'guest'}.${characterId}`;
}

async function resolveCurrentUserId(): Promise<string | null> {
  if (!supabase) {
    return null;
  }

  const { data } = await supabase.auth.getSession();
  return data.session?.user.id ?? null;
}

function isTextMessage(message: ChatShellMessage) {
  return message.kind === 'text';
}

function normalizeChatShellMessage(raw: unknown): ChatShellMessage | null {
  if (!raw || typeof raw !== 'object') {
    return null;
  }

  const candidate = raw as Record<string, unknown>;
  const kind = candidate.kind;

  if (kind === 'text') {
    const sender = candidate.sender;
    const text = candidate.text;

    if (
      (sender === 'assistant' || sender === 'user' || sender === 'system') &&
      typeof text === 'string' &&
      typeof candidate.id === 'string'
    ) {
      return {
        id: candidate.id,
        kind: 'text',
        sender,
        text,
      };
    }
  }

  return null;
}

function normalizeStoryRomanceState(
  raw: unknown,
): StoryRomanceState | null {
  if (!raw || typeof raw !== 'object') {
    return null;
  }

  const candidate = raw as Partial<StoryRomanceState>;

  if (
    candidate.attachmentSignal !== 'guarded' &&
    candidate.attachmentSignal !== 'warming' &&
    candidate.attachmentSignal !== 'open' &&
    candidate.attachmentSignal !== 'deep'
  ) {
    return null;
  }

  if (
    candidate.emotionalTemperature !== 'cool' &&
    candidate.emotionalTemperature !== 'soft' &&
    candidate.emotionalTemperature !== 'warm' &&
    candidate.emotionalTemperature !== 'intense'
  ) {
    return null;
  }

  if (
    candidate.pursuitBalance !== 'receding' &&
    candidate.pursuitBalance !== 'balanced' &&
    candidate.pursuitBalance !== 'leaning_in'
  ) {
    return null;
  }

  if (
    candidate.vulnerabilityWindow !== 'narrow' &&
    candidate.vulnerabilityWindow !== 'steady' &&
    candidate.vulnerabilityWindow !== 'wide'
  ) {
    return null;
  }

  if (
    candidate.boundarySensitivity !== 'high' &&
    candidate.boundarySensitivity !== 'medium' &&
    candidate.boundarySensitivity !== 'low'
  ) {
    return null;
  }

  if (
    candidate.replyEnergy !== 'quiet' &&
    candidate.replyEnergy !== 'measured' &&
    candidate.replyEnergy !== 'steady' &&
    candidate.replyEnergy !== 'bright'
  ) {
    return null;
  }

  if (
    candidate.repairNeed !== 'stable' &&
    candidate.repairNeed !== 'low' &&
    candidate.repairNeed !== 'moderate' &&
    candidate.repairNeed !== 'high'
  ) {
    return null;
  }

  if (typeof candidate.dailyHook !== 'string') {
    return null;
  }

  return {
    attachmentSignal: candidate.attachmentSignal,
    emotionalTemperature: candidate.emotionalTemperature,
    pursuitBalance: candidate.pursuitBalance,
    vulnerabilityWindow: candidate.vulnerabilityWindow,
    boundarySensitivity: candidate.boundarySensitivity,
    replyEnergy: candidate.replyEnergy,
    repairNeed: candidate.repairNeed,
    dailyHook: candidate.dailyHook,
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

  if (
    candidate.attachmentSignal === 'guarded' ||
    candidate.attachmentSignal === 'warming' ||
    candidate.attachmentSignal === 'open' ||
    candidate.attachmentSignal === 'deep'
  ) {
    nextPatch.attachmentSignal = candidate.attachmentSignal;
  }

  if (
    candidate.emotionalTemperature === 'cool' ||
    candidate.emotionalTemperature === 'soft' ||
    candidate.emotionalTemperature === 'warm' ||
    candidate.emotionalTemperature === 'intense'
  ) {
    nextPatch.emotionalTemperature = candidate.emotionalTemperature;
  }

  if (
    candidate.pursuitBalance === 'receding' ||
    candidate.pursuitBalance === 'balanced' ||
    candidate.pursuitBalance === 'leaning_in'
  ) {
    nextPatch.pursuitBalance = candidate.pursuitBalance;
  }

  if (
    candidate.vulnerabilityWindow === 'narrow' ||
    candidate.vulnerabilityWindow === 'steady' ||
    candidate.vulnerabilityWindow === 'wide'
  ) {
    nextPatch.vulnerabilityWindow = candidate.vulnerabilityWindow;
  }

  if (
    candidate.boundarySensitivity === 'high' ||
    candidate.boundarySensitivity === 'medium' ||
    candidate.boundarySensitivity === 'low'
  ) {
    nextPatch.boundarySensitivity = candidate.boundarySensitivity;
  }

  if (
    candidate.replyEnergy === 'quiet' ||
    candidate.replyEnergy === 'measured' ||
    candidate.replyEnergy === 'steady' ||
    candidate.replyEnergy === 'bright'
  ) {
    nextPatch.replyEnergy = candidate.replyEnergy;
  }

  if (
    candidate.repairNeed === 'stable' ||
    candidate.repairNeed === 'low' ||
    candidate.repairNeed === 'moderate' ||
    candidate.repairNeed === 'high'
  ) {
    nextPatch.repairNeed = candidate.repairNeed;
  }

  if (typeof candidate.dailyHook === 'string') {
    nextPatch.dailyHook = candidate.dailyHook;
  }

  return Object.keys(nextPatch).length > 0 ? nextPatch : null;
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

  const messages = (thread?.messages ?? buildPilotStoryInitialThread(character))
    .filter(isTextMessage)
    .slice(-14)
    .map((message) => ({
      role: message.sender,
      content: message.text,
    }));

  return {
    characterId: character.id,
    personaKey: profile.personaKey,
    systemPrompt: buildStoryRomanceSystemPrompt(character),
    messages,
    userMessage,
    romanceState: thread?.romanceState ?? profile.romanceState,
    sceneIntent: resolveSceneIntent(userMessage, thread?.sceneIntent ?? profile.sceneIntent),
    responseGoal: resolveResponseGoal(
      userMessage,
      thread?.responseGoal ?? profile.responseGoal,
    ),
    safeAffectionCap: profile.safeAffectionCap,
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

function normalizeStoryChatResponse(raw: unknown): StoryChatResponse {
  if (!raw || typeof raw !== 'object') {
    throw new Error('Story chat response payload is empty.');
  }

  const candidate = raw as Record<string, unknown>;
  const response = candidate.response;

  if (typeof response !== 'string' || response.trim().length === 0) {
    throw new Error('Story chat response text is missing.');
  }

  const affinityDelta = candidate.affinityDelta;
  const romanceStatePatch = candidate.romanceStatePatch;
  const affinityCandidate =
    affinityDelta && typeof affinityDelta === 'object'
      ? (affinityDelta as Record<string, unknown>)
      : null;
  const metaCandidate =
    candidate.meta && typeof candidate.meta === 'object'
      ? (candidate.meta as Record<string, unknown>)
      : null;

  return {
    success: typeof candidate.success === 'boolean' ? candidate.success : true,
    response,
    emotionTag:
      typeof candidate.emotionTag === 'string' ? candidate.emotionTag : undefined,
    delaySec:
      typeof candidate.delaySec === 'number' ? candidate.delaySec : undefined,
    affinityDelta: affinityCandidate
      ? {
          points:
            typeof affinityCandidate.points === 'number'
              ? affinityCandidate.points
              : 0,
          reason:
            typeof affinityCandidate.reason === 'string'
              ? affinityCandidate.reason
              : 'basic_chat',
          quality:
            typeof affinityCandidate.quality === 'string'
              ? affinityCandidate.quality
              : 'neutral',
        }
      : undefined,
    romanceStatePatch:
      normalizeStoryRomanceStatePatch(romanceStatePatch) ?? undefined,
    followUpHint:
      typeof candidate.followUpHint === 'string'
        ? candidate.followUpHint
        : undefined,
    meta: metaCandidate
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
    error:
      typeof candidate.error === 'string' ? candidate.error : undefined,
  };
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

  const userId = await resolveCurrentUserId();
  const storageKey = resolveStoryChatThreadStorageKey(characterId, userId);
  const raw = await SecureStore.getItemAsync(storageKey);

  if (!raw) {
    return null;
  }

  try {
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    const messages = Array.isArray(parsed.messages)
      ? parsed.messages
          .map((message) => normalizeChatShellMessage(message))
          .filter((message): message is ChatShellMessage => message != null)
      : [];
    const romanceState = normalizeStoryRomanceState(parsed.romanceState);
    const sceneIntent = parsed.sceneIntent;
    const responseGoal = parsed.responseGoal;
    const safeAffectionCap = parsed.safeAffectionCap;

    if (!romanceState) {
      return null;
    }

    if (
      typeof sceneIntent !== 'string' ||
      typeof responseGoal !== 'string' ||
      typeof safeAffectionCap !== 'number'
    ) {
      return null;
    }

    if (messages.length === 0) {
      return null;
    }

    return {
      characterId,
      personaKey: typeof parsed.personaKey === 'string' ? parsed.personaKey : profile.personaKey,
      messages,
      romanceState,
      sceneIntent: sceneIntent as StorySceneIntent,
      responseGoal: responseGoal as StoryResponseGoal,
      safeAffectionCap,
      updatedAt:
        typeof parsed.updatedAt === 'string' ? parsed.updatedAt : new Date().toISOString(),
    };
  } catch {
    return null;
  }
}

export async function saveStoryThreadSnapshot(
  snapshot: StoryChatThreadSnapshot,
): Promise<StoryChatThreadSnapshot> {
  const userId = await resolveCurrentUserId();
  const storageKey = resolveStoryChatThreadStorageKey(
    snapshot.characterId,
    userId,
  );

  await SecureStore.setItemAsync(storageKey, JSON.stringify(snapshot));
  return snapshot;
}

export async function invokeStoryChat(
  character: ChatCharacterSpec,
  userMessage: string,
  thread: StoryChatThreadSnapshot | null,
): Promise<StoryChatResponse> {
  const request = buildStoryChatRequest(character, userMessage, thread);

  if (!request) {
    throw new Error(`Story chat is not configured for ${character.id}.`);
  }

  if (!supabase) {
    throw new Error('Supabase is not configured.');
  }

  const { data, error } = await supabase.functions.invoke('character-chat', {
    body: request,
  });

  if (error) {
    throw error;
  }

  return normalizeStoryChatResponse(data);
}

export function buildNextStoryThreadSnapshot(
  current: StoryChatThreadSnapshot | null,
  character: ChatCharacterSpec,
  nextMessages: ChatShellMessage[],
  response: StoryChatResponse | null,
  request?: StoryChatRequest | null,
): StoryChatThreadSnapshot | null {
  const profile = getStoryRomanceProfile(character.id);

  if (!profile) {
    return null;
  }

  const currentState = current?.romanceState ?? profile.romanceState;
  const nextState = applyStoryRomancePatch(
    currentState,
    response?.romanceStatePatch ?? null,
    response?.response ?? null,
  );

  return {
    characterId: character.id,
    personaKey: request?.personaKey ?? profile.personaKey,
    messages: nextMessages,
    romanceState: nextState,
    sceneIntent: request?.sceneIntent ?? current?.sceneIntent ?? profile.sceneIntent,
    responseGoal:
      request?.responseGoal ?? current?.responseGoal ?? profile.responseGoal,
    safeAffectionCap: request?.safeAffectionCap ?? profile.safeAffectionCap,
    updatedAt: new Date().toISOString(),
  };
}

function applyStoryRomancePatch(
  current: StoryRomanceState,
  patch: Partial<StoryRomanceState> | null,
  assistantText: string | null,
): StoryRomanceState {
  const nextState: StoryRomanceState = {
    ...current,
  };

  if (patch) {
    nextState.attachmentSignal = patch.attachmentSignal ?? nextState.attachmentSignal;
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
  }

  if (!patch && assistantText) {
    const normalized = assistantText.trim();

    if (normalized.length > 0) {
      if (normalized.length < 28 && nextState.replyEnergy === 'quiet') {
        nextState.replyEnergy = 'measured';
      }

      if (
        /미안|서운|걱정|기다|편해|괜찮/.test(normalized) &&
        nextState.emotionalTemperature === 'cool'
      ) {
        nextState.emotionalTemperature = 'soft';
      }

      if (
        /보고싶|좋아|궁금|더 알고|가까워/.test(normalized) &&
        nextState.attachmentSignal === 'guarded'
      ) {
        nextState.attachmentSignal = 'warming';
      }
    }
  }

  if (nextState.repairNeed === 'high' && assistantText && assistantText.length > 0) {
    nextState.repairNeed = 'moderate';
  }

  return nextState;
}
