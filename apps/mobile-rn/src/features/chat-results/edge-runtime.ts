import {
  normalizeFortuneResult,
  resolveFortuneEndpoint,
  type FortuneTypeId,
} from '@fortune/product-contracts';

import {
  formatSurveyAnswerLabel,
  getChatSurveyDefinition,
} from '../chat-survey/registry';
import { resolveResultKindFromFortuneType } from '../fortune-results/mapping';
import { supabase } from '../../lib/supabase';
import {
  buildEmbeddedResultPayloadFromNormalizedResult,
} from './adapter';
import {
  isOnDeviceFortuneSupported,
  resolveOnDeviceFortunePayload,
} from './on-device-fortune';
import { onDeviceLLMEngine } from '../../lib/on-device-llm';
import type { AiMode } from '../../lib/mobile-app-state';
import type {
  EmbeddedResultBuildContext,
  EmbeddedResultPayload,
  EmbeddedResultProfileContext,
} from './types';

type UnknownRecord = Record<string, unknown>;

export function isAbortError(error: unknown): boolean {
  return (
    typeof error === 'object' &&
    error !== null &&
    ((error as { name?: string }).name === 'AbortError' ||
      (error as { code?: string }).code === 'ABORT_ERR')
  );
}

function createAbortError(message: string): Error {
  const error = new Error(message);
  error.name = 'AbortError';
  return error;
}

function throwIfAborted(signal?: AbortSignal): void {
  if (signal?.aborted) {
    throw createAbortError('fortune generation cancelled');
  }
}

function createLinkedAbortSignal(
  externalSignal: AbortSignal | undefined,
  timeoutMs: number,
): { signal: AbortSignal; dispose: () => void } {
  const controller = new AbortController();
  const abortFromExternal = () => controller.abort();

  if (externalSignal?.aborted) {
    controller.abort();
  } else {
    externalSignal?.addEventListener('abort', abortFromExternal, { once: true });
  }

  const timeoutHandle = setTimeout(() => controller.abort(), timeoutMs);

  return {
    signal: controller.signal,
    dispose: () => {
      clearTimeout(timeoutHandle);
      externalSignal?.removeEventListener('abort', abortFromExternal);
    },
  };
}

// ── Client-side fortune result cache ──────────────────────────
// Same fortune type + same day + same user → skip Edge Function entirely.
// Cache is keyed by `fortuneType:YYYY-MM-DD:userId` and holds up to 50 entries.
const fortuneResultCache = new Map<string, { payload: EmbeddedResultPayload; ts: number }>();
const CACHE_TTL_MS = 30 * 60 * 1000; // 30 minutes
const CACHE_MAX_SIZE = 50;

function buildCacheKey(fortuneType: string, userId?: string | null): string {
  const today = new Date().toISOString().slice(0, 10);
  return `${fortuneType}:${today}:${userId ?? 'guest'}`;
}

/** Clear all cached fortune results. Call after profile changes. */
export function invalidateFortuneResultCache(): void {
  fortuneResultCache.clear();
}

/**
 * 클라이언트 캐시 체크 — 같은 fortuneType + 동일 user + 같은 날 (UTC) 30분 TTL.
 * 동기 호출 (`fetchEmbeddedEdgeResultPayload`) 은 내부적으로 본 캐시를 자동
 * 사용하지만, 비동기 큐 경로 (long_running_jobs) 는 캐시를 우회하므로 chat-screen
 * 에서 명시적으로 체크해 큐 적체/대기시간 회피 — 동기 흐름과 UX 동일성 유지.
 */
export function lookupCachedFortuneResult(
  fortuneType: FortuneTypeId,
  userId?: string | null,
): EmbeddedResultPayload | null {
  return getCachedResult(buildCacheKey(fortuneType, userId));
}

function getCachedResult(key: string): EmbeddedResultPayload | null {
  const entry = fortuneResultCache.get(key);
  if (!entry) return null;
  if (Date.now() - entry.ts > CACHE_TTL_MS) {
    fortuneResultCache.delete(key);
    return null;
  }
  return entry.payload;
}

function setCachedResult(key: string, payload: EmbeddedResultPayload): void {
  // Evict oldest if full
  if (fortuneResultCache.size >= CACHE_MAX_SIZE) {
    const oldest = fortuneResultCache.keys().next().value;
    if (oldest) fortuneResultCache.delete(oldest);
  }
  fortuneResultCache.set(key, { payload, ts: Date.now() });
}

function readNestedString(record: unknown, path: string[]): string | undefined {
  let current: unknown = record;
  for (const key of path) {
    if (!current || typeof current !== 'object') return undefined;
    current = (current as UnknownRecord)[key];
  }
  return typeof current === 'string' && current.trim() ? current.trim() : undefined;
}

function hasPastLifePortrait(payload: EmbeddedResultPayload): boolean {
  return Boolean(
    readNestedString(payload, ['portraitUrl']) ??
      readNestedString(payload.rawApiResponse, ['portraitUrl']) ??
      readNestedString(payload.rawApiResponse, ['fortune', 'portraitUrl']) ??
      readNestedString(payload.rawApiResponse, ['data', 'portraitUrl']),
  );
}

export async function fetchEmbeddedEdgeResultPayload(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext = {},
  options: {
    userId?: string | null;
    aiMode?: AiMode;
    signal?: AbortSignal;
  } = {},
): Promise<EmbeddedResultPayload | null> {
  throwIfAborted(options.signal);
  const resultKind = resolveResultKindFromFortuneType(fortuneType);
  if (!resultKind) {
    return null;
  }

  // Check client cache first
  const cacheKey = buildCacheKey(fortuneType, options.userId);
  const cached = getCachedResult(cacheKey);
  if (cached) {
    if (fortuneType === 'past-life' && !hasPastLifePortrait(cached)) {
      // 이전 on-device 텍스트 결과가 30분 캐시에 남아 있으면 계속 🏯 placeholder 를
      // 재사용한다. 전생은 초상화가 핵심이므로 이미지 없는 캐시는 무시하고
      // 서버 이미지 생성 경로로 다시 간다.
      fortuneResultCache.delete(cacheKey);
    } else {
      if (__DEV__) {
        console.log(`[fortune-cache] HIT: ${fortuneType} (skipping Edge Function)`);
      }
      return cached;
    }
  }

  // On-device 라우팅 — aiMode='on-device' 이거나 'auto' 이고 모델이 ready 면
  // 먼저 로컬에서 시도. 실패하면 cloud 로 자동 폴백.
  const preferOnDevice =
    options.aiMode !== 'cloud' &&
    onDeviceLLMEngine.getStatus() === 'ready' &&
    isOnDeviceFortuneSupported(fortuneType);
  if (preferOnDevice) {
    try {
      const onDevicePayload = await resolveOnDeviceFortunePayload(
        fortuneType,
        context,
      );
      throwIfAborted(options.signal);
      setCachedResult(cacheKey, onDevicePayload);
      if (__DEV__) {
        console.log(`[fortune-on-device] SUCCESS: ${fortuneType}`);
      }
      return onDevicePayload;
    } catch (e) {
      if (isAbortError(e) && options.signal?.aborted) {
        throw e;
      }
      if (__DEV__) {
        console.warn(
          `[fortune-on-device] failed for ${fortuneType}, falling back to cloud:`,
          e,
        );
      }
      // fall through to cloud path.
    }
  }

  if (!supabase) {
    return null;
  }

  const body = buildFortuneRequestBody(fortuneType, context, options.userId);
  if (!body) {
    return null;
  }

  const endpoint = resolveFortuneEndpoint(fortuneType, {
    concern: readString(body.concern) ?? undefined,
    family_type: readString(body.family_type) ?? undefined,
  });
  if (!endpoint) {
    return null;
  }

  const functionName = endpoint.replace(/^\//u, '');
  // 타임아웃: gpt-image-2 / Gemini image 기반 poster-guide 및 전생 초상화는
  // 이미지 생성 + Storage upload 때문에 20-60s 걸릴 수 있음 → 90s 여유.
  // 일반 텍스트 fortune 은 보통 5s 안에 끝나므로 timeout 큼은 무해.
  const isImageGeneratingFortune =
    endpoint === '/generate-poster-guide' || fortuneType === 'past-life';
  const timeoutMs = isImageGeneratingFortune ? 90_000 : 35_000;
  const { signal, dispose } = createLinkedAbortSignal(options.signal, timeoutMs);
  let data: unknown;
  let error: unknown;
  try {
    const invoke = await supabase.functions.invoke(functionName, {
      body,
      // supabase-js v2 는 signal 옵션을 fetch 에 pass-through 한다.
      // 타입 선언은 signal 을 아직 안 가지고 있어 캐스트.
      ...({ signal } as { signal?: AbortSignal }),
    });
    throwIfAborted(options.signal);
    data = invoke.data;
    error = invoke.error;
  } catch (err) {
    if (isAbortError(err) && options.signal?.aborted) {
      throw createAbortError('edge-runtime aborted by user');
    }
    if (isAbortError(err)) {
      throw new Error(`edge-runtime timeout (${timeoutMs / 1000}s)`);
    }
    throw err;
  } finally {
    dispose();
  }

  if (error) {
    throw error;
  }

  const normalized = normalizeFortuneResult(data, { fortuneType });
  const result = buildEmbeddedResultPayloadFromNormalizedResult(
    fortuneType,
    resultKind,
    normalized,
    context,
  );

  throwIfAborted(options.signal);

  // Attach the ORIGINAL API response (before normalization) so result
  // components can access deep fields like fortune.portraitUrl, chapters, etc.
  if (result) {
    const rawData = typeof data === 'object' && data !== null
      ? (data as Record<string, unknown>).data ?? data
      : data;
    result.rawApiResponse = rawData as Record<string, unknown>;

    // Store in client cache
    setCachedResult(cacheKey, result);
  }

  return result;
}

/**
 * Async poster-job 시작 — palm-reading 등 gpt-image-2 기반 무거운 운세를
 * 백그라운드 큐에 등록한다. 즉시 반환 (~200ms) — 결과는 push 알림으로 도착.
 *
 * @returns
 *   - `{ jobId: string }` 성공
 *   - `null` 실패 (auth 누락 / supabase 미설정 / endpoint 누락 / 큐 초과)
 *
 * @sideEffect
 *   서버측 start-poster-job 이 character_conversations 에 placeholder
 *   text 메시지 ("분석 시작했어!") 를 INSERT 함. 클라이언트는 별도로 동일
 *   메시지를 local appendMessages 해도 무방 — merge RPC 가 id dedup 처리.
 */
export async function startAsyncPosterJob(params: {
  fortuneType: FortuneTypeId;
  characterId: string;
  characterName: string;
  imageBase64?: string;
  contextText?: string;
  signal?: AbortSignal;
}): Promise<{ jobId: string } | null> {
  if (!supabase) return null;

  throwIfAborted(params.signal);

  let data: unknown;
  let error: unknown;
  try {
    const response = await supabase.functions.invoke('start-poster-job', {
      body: {
        posterType: params.fortuneType,
        characterId: params.characterId,
        characterName: params.characterName,
        imageBase64: params.imageBase64,
        contextText: params.contextText,
      },
      ...({ signal: params.signal } as { signal?: AbortSignal }),
    });
    data = response.data;
    error = response.error;
  } catch (invokeError) {
    if (isAbortError(invokeError) || params.signal?.aborted) {
      throw createAbortError('async poster job registration cancelled');
    }
    throw invokeError;
  }

  throwIfAborted(params.signal);

  if (error) {
    console.warn('[start-poster-job] failed:', error);
    return null;
  }

  const result = data as { success?: boolean; jobId?: string };
  if (!result?.success || !result.jobId) {
    return null;
  }

  return { jobId: result.jobId };
}

/**
 * fortuneType 이 비동기 poster-guide 큐 (palm-reading 등) 대상인지.
 * `/generate-poster-guide` 엔드포인트에 매핑되는 타입만 true.
 */
export function isAsyncPosterFortuneType(fortuneType: FortuneTypeId): boolean {
  const endpoint = resolveFortuneEndpoint(fortuneType, {});
  return endpoint === '/generate-poster-guide';
}

function buildFortuneRequestBody(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext,
  userId?: string | null,
): UnknownRecord | null {
  const answers = context.answers ?? {};
  const labels = formatAnswerLabels(fortuneType, context);
  const profile = context.profile ?? {};

  if (requiresBirthDate(fortuneType) && !profile.birthDate) {
    return null;
  }

  const payload: UnknownRecord = {
    fortune_type: fortuneType.replace(/-/gu, '_'),
    fortuneType,
  };

  if (userId) {
    payload.userId = userId;
    payload.user_id = userId;
  }

  applyProfileFields(payload, profile);

  for (const [key, value] of Object.entries(answers)) {
    const normalizedValue = normalizeAnswerValue(value);

    if (normalizedValue == null) {
      continue;
    }

    payload[key] = normalizedValue;
  }

  switch (fortuneType) {
    case 'career': {
      const currentRole = [labels.field, labels.position].filter(Boolean).join(' ');
      if (currentRole) {
        payload.currentRole = currentRole;
        payload.current_role = currentRole;
      }
      if (labels.concern) {
        payload.primaryConcern = labels.concern;
        payload.primary_concern = labels.concern;
      }
      break;
    }
    case 'daily-calendar':
    case 'biorhythm':
      copyLabeledValue(payload, labels.targetDate, 'targetDate', 'target_date');
      break;
    case 'new-year':
      copyLabeledValue(payload, labels.goal, 'goal');
      break;
    case 'exam':
      copyLabeledValue(payload, labels.examType, 'examType', 'exam_type');
      copyLabeledValue(payload, readString(answers.examDate), 'examDate', 'exam_date');
      copyLabeledValue(
        payload,
        labels.preparation,
        'preparation',
        'preparation_status',
        'confidence',
      );
      break;
    case 'compatibility':
      copyLabeledValue(
        payload,
        profile.displayName || context.characterName || '본인',
        'name',
        'person1_name',
      );
      copyLabeledValue(payload, profile.birthDate, 'birthDate', 'birth_date', 'person1_birth_date');
      copyLabeledValue(payload, readString(answers.partnerName), 'partnerName', 'person2_name');
      copyLabeledValue(payload, readString(answers.partnerBirth), 'partnerBirth', 'person2_birth_date');
      copyLabeledValue(payload, labels.relationship, 'relationship');
      break;
    case 'blind-date':
      copyLabeledValue(payload, labels.dateType || readString(answers.dateType), 'dateType', 'date_type');
      copyLabeledValue(payload, readString(answers.partnerInfo), 'partnerInfo', 'partner_info');
      copyLabeledValue(payload, labels.meetingTime || readString(answers.meetingTime), 'meetingTime', 'meeting_time');
      copyLabeledValue(payload, labels.concern || readString(answers.concern), 'concern');
      if (Array.isArray(answers.myStrength)) {
        payload.myStrength = answers.myStrength;
      }
      // Partner photo (base64 image from survey)
      {
        const partnerPhoto = readString(answers.partnerPhoto);
        if (partnerPhoto && partnerPhoto.length > 100) {
          payload.partnerImage = partnerPhoto;
          payload.hasPartnerPhoto = true;
        }
      }
      break;
    case 'ex-lover':
      copyLabeledValue(payload, labels.primaryGoal, 'primaryGoal', 'primary_goal');
      copyLabeledValue(payload, labels.breakupTime, 'breakupTime', 'breakup_time');
      copyLabeledValue(
        payload,
        labels.relationshipDepth,
        'relationshipDepth',
        'relationship_depth',
      );
      copyLabeledValue(payload, labels.coreReason, 'coreReason', 'core_reason');
      if (Array.isArray(answers.currentState)) {
        payload.currentState = answers.currentState;
        payload.current_state = answers.currentState;
      }
      break;
    case 'avoid-people':
      copyLabeledValue(payload, labels.situation, 'situation');
      break;
    case 'yearly-encounter':
      copyLabeledValue(payload, labels.targetGender, 'targetGender', 'target_gender');
      copyLabeledValue(payload, labels.userAge, 'userAge', 'user_age');
      copyLabeledValue(payload, labels.idealMbti, 'idealMbti', 'ideal_mbti');
      copyLabeledValue(payload, readString(answers.idealType), 'idealType', 'ideal_type');
      break;
    case 'health':
      copyLabeledValue(
        payload,
        labels.currentCondition,
        'currentCondition',
        'current_condition',
      );
      copyLabeledValue(payload, labels.concern, 'concern');
      copyLabeledValue(payload, labels.stressLevel, 'stressLevel', 'stress_level');
      break;
    case 'family':
      payload.concern = resolveFamilyConcern(readString(answers.concern), labels.concern);
      if (payload.concern === 'children') {
        payload.family_type = 'children';
      }
      copyLabeledValue(payload, labels.member, 'member');
      break;
    case 'naming': {
      // Edge Function requires: userId, motherBirthDate, expectedBirthDate, babyGender, familyName
      // motherBirthDate comes from the user's own profile birthDate
      copyLabeledValue(payload, profile.birthDate, 'motherBirthDate', 'mother_birth_date');
      copyLabeledValue(payload, profile.birthTime, 'motherBirthTime', 'mother_birth_time');
      // Survey field "dueDate" maps to Edge Function "expectedBirthDate"
      copyLabeledValue(
        payload,
        readString(answers.dueDate),
        'expectedBirthDate',
        'expected_birth_date',
        'dueDate',
        'due_date',
      );
      // Survey sends gender as boy/girl/unknown; Edge Function expects male/female/unknown
      const namingGenderRaw = readString(answers.gender) ?? labels.gender;
      const babyGender = namingGenderRaw === 'boy' ? 'male'
        : namingGenderRaw === 'girl' ? 'female'
        : namingGenderRaw === '남아' ? 'male'
        : namingGenderRaw === '여아' ? 'female'
        : namingGenderRaw ?? 'unknown';
      copyLabeledValue(payload, babyGender, 'babyGender', 'baby_gender', 'gender');
      // Survey field "lastName" maps to Edge Function "familyName"
      copyLabeledValue(
        payload,
        readString(answers.lastName),
        'familyName',
        'family_name',
        'lastName',
        'last_name',
      );
      // Survey "style" maps to Edge Function "nameStyle"
      copyLabeledValue(payload, labels.style, 'nameStyle', 'name_style', 'style');
      copyLabeledValue(payload, readString(answers.babyDream), 'desiredMeanings', 'babyDream', 'baby_dream');
      break;
    }
    case 'lucky-items':
      copyLabeledValue(payload, labels.category, 'category');
      break;
    case 'dream':
      copyLabeledValue(payload, readString(answers.dreamContent), 'dreamContent', 'dream_content');
      copyLabeledValue(payload, labels.emotion, 'emotion');
      break;
    case 'tarot': {
      // TarotDrawWidget 은 12개 슬롯 중 N장을 1-indexed 슬롯 번호 콤마 문자열로
      // (`"3,7,11"`) 넘긴다. fortune-tarot Edge Function 은 78장 덱 인덱스
      // (0~77) 의 selectedCards 를 기대 — 슬롯 번호와 무관. 슬롯 선택은 셔플
      // 시뮬레이션이고 실제 카드 인덱스는 클라가 random 으로 결정한다.
      //
      // 슬롯 번호를 고정 시드로 deterministic 한 random 을 돌려, 같은 슬롯을
      // 다시 골랐을 때 같은 카드가 나오게 한다 (사용자 입장의 일관성).
      // 본 매핑이 누락돼 6회 연속 "필수 필드 누락: selectedCards" 400 발생.
      const slotsRaw = readString(answers.tarotSelection);
      const slots = (slotsRaw ?? '')
        .split(',')
        .map((token) => token.trim())
        .filter((token) => token.length > 0)
        .map((token) => Number(token))
        .filter((value) => Number.isFinite(value));

      // 사용자가 슬롯 선택을 끝내지 않은 비정상 진입에 대비해 최소 1장 보장.
      const draw = drawTarotCardsFromSlots(slots.length > 0 ? slots : [1, 2, 3]);
      payload.selectedCards = draw;
      payload.selectedCardIndices = draw.map((card) => card.index);
      copyLabeledValue(payload, readString(answers.deckId), 'deckId', 'deck_id');
      copyLabeledValue(payload, readString(answers.spreadType), 'spreadType', 'spread_type');
      copyLabeledValue(payload, readString(answers.purpose), 'purpose');
      copyLabeledValue(payload, readString(answers.questionText), 'questionText', 'question_text', 'question');
      break;
    }
    case 'talisman':
      copyLabeledValue(
        payload,
        labels.generationMode,
        'generationMode',
        'generation_mode',
      );
      copyLabeledValue(payload, labels.purpose, 'purpose');
      copyLabeledValue(payload, readString(answers.situation), 'situation');
      copyLabeledValue(payload, labels.purpose, 'category');
      break;
    case 'wish':
      copyLabeledValue(payload, labels.category, 'category');
      copyLabeledValue(payload, readString(answers.wishContent), 'wishContent', 'wish_content');
      copyLabeledValue(payload, labels.bokchae, 'bokchae');
      break;
    case 'ootd-evaluation':
      copyLabeledValue(payload, labels.tpo, 'tpo');
      copyLabeledValue(payload, readString(answers.lookNote), 'lookNote', 'look_note');
      break;
    case 'face-reading': {
      const gender = readString(answers.gender) ?? labels.gender ?? 'male';
      payload.userGender = gender;
      payload.gender = gender;

      // Image should be base64 from the survey answer
      const imageData = readString(answers.faceImage);
      if (imageData) {
        payload.image = imageData;
      }

      payload.userName = profile.displayName || 'user';
      break;
    }
    case 'palm-reading': {
      // Generic poster-guide Edge Function expects:
      //   { posterType, userId, imageBase64?, contextText? }
      // Survey field id is `palmImage` (defined in chat-survey/registry.ts).
      payload.posterType = 'palm-reading';
      const imageData = readString(answers.palmImage);
      if (imageData) {
        payload.imageBase64 = imageData;
      }
      // Drop the raw `palmImage` key to avoid shipping the same base64 twice.
      delete payload.palmImage;
      break;
    }
    case 'beauty-simulation':
    case 'hair-style-guide':
    case 'face-reading-guide': {
      // photoKind: 'face' — survey field id is `faceImage`.
      payload.posterType = fortuneType;
      const imageData = readString(answers.faceImage);
      if (imageData) {
        payload.imageBase64 = imageData;
      }
      delete payload.faceImage;
      break;
    }
    case 'ootd-guide': {
      // photoKind: 'face-and-body' — survey field id is `bodyImage`.
      // Optional contextText: lookContext label (work/date/daily/special).
      payload.posterType = 'ootd-guide';
      const imageData = readString(answers.bodyImage);
      if (imageData) {
        payload.imageBase64 = imageData;
      }
      const lookContextLabel = labels.lookContext ?? readString(answers.lookContext);
      if (lookContextLabel) {
        payload.contextText = lookContextLabel;
      }
      delete payload.bodyImage;
      delete payload.lookContext;
      break;
    }
    case 'blind-date-guide': {
      // photoKind: 'face' + optional contextText.
      payload.posterType = 'blind-date-guide';
      const imageData = readString(answers.faceImage);
      if (imageData) {
        payload.imageBase64 = imageData;
      }
      const contextText = readString(answers.contextText);
      if (contextText) {
        payload.contextText = contextText;
      }
      delete payload.faceImage;
      // contextText already in payload via generic loop — keep it as-is.
      break;
    }
    case 'past-life-guide': {
      // photoKind: 'none' — text-only survey. eraVibe + optional contextText.
      payload.posterType = 'past-life-guide';
      const eraLabel = labels.eraVibe ?? readString(answers.eraVibe);
      const ctxText = readString(answers.contextText);
      const merged = [eraLabel, ctxText].filter(Boolean).join(' / ');
      if (merged) {
        payload.contextText = merged;
      }
      delete payload.eraVibe;
      break;
    }
    case 'past-life': {
      // Survey answers — curiosity / eraVibe / feeling passed through generic loop.
      // Face image must be mapped to the Edge Function's `faceImageBase64` field.
      const imageData = readString(answers.faceImage);
      if (imageData) {
        payload.faceImageBase64 = imageData;
        // Remove the raw `faceImage` field (duplicated by the generic loop above)
        // so we don't ship a huge base64 string twice.
        delete payload.faceImage;
      }
      // Ensure gender + name are present for the Edge Function.
      if (profile.displayName) {
        payload.name = profile.displayName;
      }
      // The Edge Function expects `gender` at top level (current gender of user).
      // Fall back to profile if survey didn't collect it.
      break;
    }
    case 'mbti': {
      const mbtiVal = readString(answers.mbtiAxes) || readString(answers.mbtiType) || readString(answers.mbti) || profile.mbti;
      if (mbtiVal) {
        payload.mbti = mbtiVal;
      }
      copyLabeledValue(payload, labels.category || readString(answers.category), 'category');
      break;
    }
    case 'personality-dna': {
      // mbti-axis picker sends answer as 'mbtiAxes' key (e.g. "ENFJ" or "EXFP")
      const mbtiValue = readString(answers.mbtiAxes) || readString(answers.mbti) || profile.mbti;
      if (mbtiValue) {
        payload.mbti = mbtiValue;
      }
      copyLabeledValue(payload, labels.bloodType || readString(answers.bloodType), 'bloodType', 'blood_type');
      copyLabeledValue(payload, labels.zodiac || readString(answers.zodiac), 'zodiac');
      break;
    }
    case 'talent':
      copyLabeledValue(payload, labels.interest || readString(answers.interest), 'talentArea', 'talent_area');
      copyLabeledValue(payload, readString(answers.currentSkills), 'currentSkills', 'current_skills');
      copyLabeledValue(payload, labels.experience || readString(answers.experience), 'experience');
      copyLabeledValue(payload, labels.goals || readString(answers.goals), 'goals');
      copyLabeledValue(payload, labels.timeAvailable || readString(answers.timeAvailable), 'timeAvailable', 'time_available');
      if (Array.isArray(answers.challenges)) {
        payload.challenges = answers.challenges;
      } else {
        copyLabeledValue(payload, labels.challenges || readString(answers.challenges), 'challenges');
      }
      break;
    case 'blood-type':
      copyLabeledValue(payload, profile.bloodType || readString(answers.bloodType), 'bloodType', 'blood_type');
      break;
    case 'love':
      copyLabeledValue(payload, labels.status || readString(answers.status), 'relationshipStatus', 'relationship_status');
      copyLabeledValue(payload, labels.concern || readString(answers.concern), 'concern', 'relationshipGoal');
      if (Array.isArray(answers.loveLanguage)) {
        payload.loveLanguage = answers.loveLanguage;
      }
      break;
    case 'celebrity':
      copyLabeledValue(payload, readString(answers.celebrityName), 'celebrityName', 'celebrity_name');
      copyLabeledValue(payload, labels.mode || readString(answers.mode), 'mode', 'analysis_mode');
      copyLabeledValue(payload, labels.reason || readString(answers.reason), 'reason');
      break;
    case 'coaching':
      copyLabeledValue(payload, labels.currentGoal || readString(answers.currentGoal), 'currentGoal', 'current_goal');
      copyLabeledValue(payload, labels.blocker || readString(answers.blocker), 'blocker');
      copyLabeledValue(payload, labels.timeAvailable || readString(answers.timeAvailable), 'timeAvailable', 'time_available');
      break;
    case 'chat-insight':
      copyLabeledValue(payload, labels.relationship || readString(answers.relationship), 'relationship');
      copyLabeledValue(payload, labels.curiosity || readString(answers.curiosity), 'curiosity');
      copyLabeledValue(payload, readString(answers.chatContent), 'chatContent', 'chat_content');
      break;
    case 'match-insight': {
      copyLabeledValue(payload, labels.sport || readString(answers.sport), 'sport');
      const teamsText = readString(answers.teams) ?? '';
      const teamParts = teamsText.split(/vs|VS|대/);
      if (teamParts.length >= 2) {
        payload.homeTeam = teamParts[0]?.trim() ?? '';
        payload.awayTeam = teamParts[1]?.trim() ?? '';
      } else {
        payload.homeTeam = teamsText.trim();
        payload.awayTeam = '';
      }
      payload.gameDate = new Date().toISOString().slice(0, 10);
      copyLabeledValue(payload, readString(answers.favoriteTeam), 'favoriteTeam', 'favorite_team');
      break;
    }
    case 'moving':
      copyLabeledValue(payload, readString(answers.currentArea), 'currentArea', 'current_area');
      copyLabeledValue(payload, readString(answers.targetArea), 'targetArea', 'target_area');
      copyLabeledValue(payload, readString(answers.movingDate), 'movingDate', 'moving_date', 'movingPeriod', 'moving_period');
      copyLabeledValue(payload, labels.concern || readString(answers.concern), 'concern', 'purpose');
      break;
    case 'pet-compatibility':
      copyLabeledValue(payload, readString(answers.petName), 'petName', 'pet_name');
      copyLabeledValue(payload, labels.petType || readString(answers.petType), 'petType', 'pet_type');
      copyLabeledValue(payload, labels.petGender || readString(answers.petGender), 'petGender', 'pet_gender');
      break;
    case 'game-enhance':
      copyLabeledValue(payload, labels.gameType || readString(answers.gameType), 'gameType', 'game_type');
      copyLabeledValue(payload, labels.goal || readString(answers.goal), 'goal');
      break;
    case 'zodiac':
    case 'zodiac-animal':
    case 'constellation':
    case 'birthstone':
    case 'daily':
      if (profile.birthDate) {
        copyLabeledValue(payload, profile.birthDate, 'birthDate', 'birth_date');
        const birthMonth = profile.birthDate.split('-')[1];
        if (birthMonth) {
          // Send birthMonth/month as numbers — fortune-birthstone Edge Function
          // checks `typeof month === 'number'` and rejects string values.
          const birthMonthNum = Number(birthMonth);
          payload.birthMonth = birthMonthNum;
          payload.birth_month = birthMonthNum;
          payload.month = birthMonthNum;
        }
      }
      break;
    default:
      break;
  }

  return payload;
}

function formatAnswerLabels(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext,
) {
  const definition = getChatSurveyDefinition(fortuneType);
  const labels: Record<string, string> = {};

  if (!definition) {
    return labels;
  }

  for (const step of definition.steps) {
    const answer = context.answers?.[step.id];

    if (answer == null || answer === '' || answer === 'skip') {
      continue;
    }

    const label = formatSurveyAnswerLabel(step, answer).trim();
    if (!label) {
      continue;
    }

    labels[step.id] = label;
  }

  return labels;
}

function applyProfileFields(
  payload: UnknownRecord,
  profile: EmbeddedResultProfileContext,
) {
  copyLabeledValue(payload, profile.displayName, 'name', 'displayName');
  copyLabeledValue(payload, profile.birthDate, 'birthDate', 'birth_date');
  copyLabeledValue(payload, profile.birthTime, 'birthTime', 'birth_time');
  copyLabeledValue(payload, profile.mbti, 'mbti');
  copyLabeledValue(payload, profile.bloodType, 'bloodType', 'blood_type');
}

function copyLabeledValue(
  payload: UnknownRecord,
  value: string | null | undefined,
  ...keys: string[]
) {
  const text = readString(value);
  if (!text) {
    return;
  }

  for (const key of keys) {
    payload[key] = text;
  }
}

function normalizeAnswerValue(value: unknown) {
  if (value == null || value === '' || value === 'skip') {
    return null;
  }

  if (Array.isArray(value)) {
    return value.length > 0 ? value : null;
  }

  if (value instanceof Date) {
    return value.toISOString().slice(0, 10);
  }

  return value;
}

/**
 * 사용자가 셔플된 fan 위에서 고른 슬롯 번호(1~12)를 78장 덱의 카드 인덱스로
 * 변환. 슬롯 번호 자체를 deterministic seed 로 써서 같은 슬롯 → 항상 같은 카드
 * 가 나오게 한다 (사용자 입장의 일관성). isReversed 도 같은 시드로 결정.
 *
 * fortune-tarot Edge Function 의 selectedCards/selectedCardIndices 가 이 출력
 * 형태를 직접 받는다.
 */
function drawTarotCardsFromSlots(
  slots: number[],
): Array<{ index: number; isReversed: boolean }> {
  const used = new Set<number>();
  const result: Array<{ index: number; isReversed: boolean }> = [];

  for (const slot of slots) {
    // mulberry32-like 32-bit hash of slot number — deterministic per slot.
    const seed = (Math.imul(slot | 0, 2654435769) ^ 0x9e3779b9) >>> 0;
    let candidate = seed % 78;

    // 같은 카드가 이미 뽑혔으면 다음 빈 슬롯으로 (선형 탐색).
    while (used.has(candidate)) {
      candidate = (candidate + 1) % 78;
    }
    used.add(candidate);
    result.push({
      index: candidate,
      isReversed: ((seed >>> 16) & 1) === 1,
    });
  }

  return result;
}

function requiresBirthDate(fortuneType: FortuneTypeId) {
  return (
    fortuneType === 'blood-type' ||
    fortuneType === 'zodiac' ||
    fortuneType === 'zodiac-animal' ||
    fortuneType === 'constellation' ||
    fortuneType === 'birthstone' ||
    fortuneType === 'compatibility'
  );
}

function resolveFamilyConcern(
  rawConcern?: string | null,
  labelConcern?: string | null,
) {
  const source = (rawConcern ?? labelConcern ?? '').toLowerCase();

  if (
    source.includes('관계') ||
    source.includes('소통') ||
    source.includes('harmony') ||
    source.includes('conflict') ||
    source.includes('support')
  ) {
    return 'relationship';
  }

  if (source.includes('자녀') || source.includes('아이') || source.includes('child')) {
    return 'children';
  }

  if (source.includes('재물') || source.includes('wealth') || source.includes('돈')) {
    return 'wealth';
  }

  if (source.includes('future') || source.includes('앞으로') || source.includes('change')) {
    return 'change';
  }

  return 'health';
}

function readString(value: unknown) {
  if (typeof value === 'string') {
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }

  return null;
}
