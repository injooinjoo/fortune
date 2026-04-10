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
import type {
  EmbeddedResultBuildContext,
  EmbeddedResultPayload,
  EmbeddedResultProfileContext,
} from './types';

type UnknownRecord = Record<string, unknown>;

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

export async function fetchEmbeddedEdgeResultPayload(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext = {},
  options: {
    userId?: string | null;
  } = {},
): Promise<EmbeddedResultPayload | null> {
  if (!supabase) {
    return null;
  }

  const resultKind = resolveResultKindFromFortuneType(fortuneType);
  if (!resultKind) {
    return null;
  }

  // Check client cache first
  const cacheKey = buildCacheKey(fortuneType, options.userId);
  const cached = getCachedResult(cacheKey);
  if (cached) {
    if (__DEV__) {
      console.log(`[fortune-cache] HIT: ${fortuneType} (skipping Edge Function)`);
    }
    return cached;
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
  const { data, error } = await supabase.functions.invoke(functionName, {
    body,
  });

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
