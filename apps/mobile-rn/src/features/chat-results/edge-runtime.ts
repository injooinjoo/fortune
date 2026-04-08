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
  return buildEmbeddedResultPayloadFromNormalizedResult(
    fortuneType,
    resultKind,
    normalized,
    context,
  );
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
      copyLabeledValue(payload, labels.dateType, 'dateType', 'date_type');
      copyLabeledValue(payload, labels.expectation, 'expectation');
      copyLabeledValue(payload, labels.meetingTime, 'meetingTime', 'meeting_time');
      copyLabeledValue(
        payload,
        labels.isFirstBlindDate,
        'isFirstBlindDate',
        'is_first_blind_date',
      );
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
    case 'naming':
      copyLabeledValue(payload, readString(answers.dueDate), 'dueDate', 'due_date');
      copyLabeledValue(payload, labels.gender, 'gender');
      copyLabeledValue(payload, readString(answers.lastName), 'lastName', 'last_name');
      copyLabeledValue(payload, labels.style, 'style');
      copyLabeledValue(payload, readString(answers.babyDream), 'babyDream', 'baby_dream');
      break;
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
    case 'blood-type':
      copyLabeledValue(payload, profile.bloodType, 'bloodType', 'blood_type');
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
          copyLabeledValue(payload, String(Number(birthMonth)), 'birthMonth', 'birth_month', 'month');
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
