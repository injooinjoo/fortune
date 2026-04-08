import {
  normalizeFortuneResult,
  resolveFortuneEndpoint,
  type FortuneTypeId,
  type NormalizedFortuneResult,
} from "@fortune/product-contracts";

import {
  formatSurveyAnswerLabel,
  getChatSurveyDefinition,
} from "../chat-survey/registry";
import type { ChatSurveyPhotoAnswer } from "../chat-survey/types";
import { resolveResultKindFromFortuneType } from "../fortune-results/mapping";
import type { ResultKind } from "../fortune-results/types";
import { supabase } from "../../lib/supabase";
import { buildEmbeddedResultPayloadFromNormalizedResult } from "./adapter";
import type {
  EmbeddedResultBuildContext,
  EmbeddedResultPayload,
  EmbeddedResultProfileContext,
} from "./types";

type UnknownRecord = Record<string, unknown>;

export interface PreparedEmbeddedEdgeInvocation {
  fortuneType: FortuneTypeId;
  resultKind: ResultKind;
  endpoint: string;
  functionName: string;
  body: UnknownRecord;
}

export interface EmbeddedEdgeResult {
  invocation: PreparedEmbeddedEdgeInvocation;
  rawResult: unknown;
  normalizedResult: NormalizedFortuneResult;
  payload: EmbeddedResultPayload;
}

export function prepareEmbeddedEdgeInvocation(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext = {},
  options: {
    userId?: string | null;
  } = {},
): PreparedEmbeddedEdgeInvocation | null {
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

  return {
    fortuneType,
    resultKind,
    endpoint,
    functionName: endpoint.replace(/^\//u, ""),
    body,
  };
}

export async function fetchEmbeddedEdgeResultPayload(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext = {},
  options: {
    userId?: string | null;
  } = {},
): Promise<EmbeddedResultPayload | null> {
  const result = await fetchEmbeddedEdgeResult(fortuneType, context, options);
  return result?.payload ?? null;
}

export async function fetchEmbeddedEdgeResult(
  fortuneType: FortuneTypeId,
  context: EmbeddedResultBuildContext = {},
  options: {
    userId?: string | null;
  } = {},
): Promise<EmbeddedEdgeResult | null> {
  if (!supabase) {
    return null;
  }

  const invocation = prepareEmbeddedEdgeInvocation(
    fortuneType,
    context,
    options,
  );
  if (!invocation) {
    return null;
  }

  const { data, error } = await supabase.functions.invoke(
    invocation.functionName,
    {
      body: invocation.body,
    },
  );

  if (error) {
    throw error;
  }

  const normalized = normalizeFortuneResult(data, { fortuneType });
  const payload = buildEmbeddedResultPayloadFromNormalizedResult(
    fortuneType,
    invocation.resultKind,
    normalized,
    context,
  );

  return {
    invocation,
    rawResult: data,
    normalizedResult: normalized,
    payload,
  };
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
    fortune_type: fortuneType.replace(/-/gu, "_"),
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
    case "career": {
      const currentRole = [labels.field, labels.position]
        .filter(Boolean)
        .join(" ");
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
    case "daily-calendar":
    case "biorhythm":
      copyLabeledValue(payload, labels.targetDate, "targetDate", "target_date");
      break;
    case "new-year":
      {
        const goal = resolveNewYearGoal(readString(answers.goal));
        copyLabeledValue(payload, goal, "goal");
        copyLabeledValue(payload, labels.goal, "goalLabel", "goal_label");
      }
      break;
    case "traditional-saju":
      copyLabeledValue(
        payload,
        buildTraditionalSajuQuestion(
          readString(answers.analysisType),
          readString(answers.specificQuestion),
          readString(answers.customQuestion),
          labels,
        ),
        "question",
      );
      copyLabeledValue(
        payload,
        profile.displayName ?? context.characterName ?? "회원님",
        "userName",
      );
      break;
    case "face-reading": {
      const photo = readPhotoAnswer(answers.photo);
      if (!photo?.base64) {
        return null;
      }
      copyLabeledValue(payload, photo.base64, "image", "imageBase64");
      copyLabeledValue(payload, "upload", "analysis_source");
      copyLabeledValue(
        payload,
        deriveUserAgeGroup(profile.birthDate),
        "userAgeGroup",
      );
      copyLabeledValue(
        payload,
        profile.displayName ?? context.characterName ?? "회원님",
        "userName",
        "user_name",
      );
      payload.useV2 = true;
      break;
    }
    case "mbti":
      {
        const mbti = readString(answers.mbtiType) ?? profile.mbti;
        if (!mbti) {
          return null;
        }
        copyLabeledValue(payload, mbti, "mbti");
        copyLabeledValue(
          payload,
          resolveMbtiCategory(readString(answers.category), labels.category),
          "category",
        );
      }
      break;
    case "exam":
      copyLabeledValue(payload, labels.examType, "examType", "exam_type");
      copyLabeledValue(
        payload,
        readString(answers.examDate),
        "examDate",
        "exam_date",
      );
      copyLabeledValue(
        payload,
        labels.preparation,
        "preparation",
        "preparation_status",
        "confidence",
      );
      break;
    case "compatibility":
      copyLabeledValue(
        payload,
        profile.displayName || context.characterName || "본인",
        "name",
        "person1_name",
      );
      copyLabeledValue(
        payload,
        profile.birthDate,
        "birthDate",
        "birth_date",
        "person1_birth_date",
      );
      copyLabeledValue(
        payload,
        readString(answers.partnerName),
        "partnerName",
        "person2_name",
      );
      copyLabeledValue(
        payload,
        readString(answers.partnerBirth),
        "partnerBirth",
        "person2_birth_date",
      );
      copyLabeledValue(payload, labels.relationship, "relationship");
      break;
    case "blind-date":
      copyLabeledValue(payload, labels.dateType, "dateType", "date_type");
      copyLabeledValue(payload, labels.expectation, "expectation");
      copyLabeledValue(
        payload,
        labels.meetingTime,
        "meetingTime",
        "meeting_time",
      );
      copyLabeledValue(
        payload,
        labels.isFirstBlindDate,
        "isFirstBlindDate",
        "is_first_blind_date",
      );
      break;
    case "ex-lover":
      copyLabeledValue(
        payload,
        labels.primaryGoal,
        "primaryGoal",
        "primary_goal",
      );
      copyLabeledValue(
        payload,
        labels.breakupTime,
        "breakupTime",
        "breakup_time",
      );
      copyLabeledValue(
        payload,
        labels.relationshipDepth,
        "relationshipDepth",
        "relationship_depth",
      );
      copyLabeledValue(payload, labels.coreReason, "coreReason", "core_reason");
      if (Array.isArray(answers.currentState)) {
        payload.currentState = answers.currentState;
        payload.current_state = answers.currentState;
      }
      break;
    case "avoid-people":
      copyLabeledValue(payload, labels.situation, "situation");
      break;
    case "yearly-encounter":
      {
        const targetGender = resolveYearlyEncounterTargetGender(
          readString(answers.targetGender),
        );
        if (!targetGender) {
          return null;
        }
        copyLabeledValue(payload, targetGender, "targetGender", "target_gender");
      }
      copyLabeledValue(
        payload,
        labels.userAge,
        "userAge",
        "user_age",
      );
      copyLabeledValue(
        payload,
        resolveYearlyEncounterIdealMbti(readString(answers.idealMbti), labels.idealMbti),
        "idealMbti",
        "ideal_mbti",
      );
      copyLabeledValue(
        payload,
        readString(answers.idealStyle),
        "idealStyle",
        "ideal_style",
      );
      copyLabeledValue(
        payload,
        readString(answers.idealType),
        "idealType",
        "ideal_type",
      );
      break;
    case "health":
      copyLabeledValue(
        payload,
        labels.currentCondition,
        "currentCondition",
        "current_condition",
      );
      copyLabeledValue(payload, labels.concern, "concern");
      copyLabeledValue(
        payload,
        labels.stressLevel,
        "stressLevel",
        "stress_level",
      );
      copyLabeledValue(
        payload,
        labels.sleepQuality,
        "sleepQuality",
        "sleep_quality",
      );
      copyLabeledValue(
        payload,
        labels.exerciseFrequency,
        "exerciseFrequency",
        "exercise_frequency",
      );
      copyLabeledValue(
        payload,
        labels.mealRegularity,
        "mealRegularity",
        "meal_regularity",
      );
      break;
    case "family":
      {
        const familyConcern = resolveFamilyConcern(
          readString(answers.concern),
          labels.concern,
        );
        const familyRelationship = resolveFamilyRelationship(
          readString(answers.member),
          labels.member,
        );
        const detailedQuestions = resolveFamilyDetailedQuestions(
          familyConcern,
          answers,
        );

        copyLabeledValue(payload, familyConcern, "concern", "family_type");
        copyLabeledValue(
          payload,
          readString(answers.concern) ?? labels.concern ?? familyConcern,
          "concern_label",
        );
        copyLabeledValue(payload, familyRelationship, "relationship");
        copyLabeledValue(payload, labels.member, "member");
        payload.family_member_count =
          resolveFamilyMemberCount(familyRelationship);
        payload.detailed_questions = detailedQuestions;
        copyLabeledValue(
          payload,
          readString(answers.specialQuestion),
          "special_question",
          "specialQuestion",
        );
      }
      break;
    case "naming":
      if (!profile.birthDate || !readString(answers.dueDate)) {
        return null;
      }
      copyLabeledValue(
        payload,
        profile.birthDate,
        "motherBirthDate",
      );
      copyLabeledValue(
        payload,
        profile.birthTime,
        "motherBirthTime",
      );
      copyLabeledValue(
        payload,
        readString(answers.dueDate),
        "expectedBirthDate",
      );
      copyLabeledValue(
        payload,
        resolveNamingGender(readString(answers.gender)),
        "babyGender",
      );
      copyLabeledValue(
        payload,
        readString(answers.lastName),
        "familyName",
      );
      copyLabeledValue(
        payload,
        resolveNamingStyle(readString(answers.style)),
        "nameStyle",
      );
      const desiredMeaning = readString(answers.babyDream);
      if (desiredMeaning) {
        payload.desiredMeanings = [desiredMeaning];
        payload.babyDream = desiredMeaning;
        payload.baby_dream = desiredMeaning;
      }
      break;
    case "lucky-items":
      copyLabeledValue(payload, labels.category, "category");
      break;
    case "dream":
      copyLabeledValue(
        payload,
        readString(answers.dreamContent),
        "dreamContent",
        "dream_content",
      );
      copyLabeledValue(payload, labels.emotion, "emotion");
      break;
    case "tarot": {
      const tarotSelection = readRecord(answers.tarotSelection);
      const tarotDeckId =
        readString(answers.deckId) ??
        readString(tarotSelection?.deckId) ??
        labels.deckId;
      const tarotPurpose =
        readString(answers.purpose) ??
        readString(tarotSelection?.purpose) ??
        labels.purpose;
      const tarotQuestion =
        readString(answers.questionText) ??
        readString(tarotSelection?.questionText) ??
        readString(tarotSelection?.question);
      const tarotSpreadType =
        readString(tarotSelection?.spreadType) ??
        (tarotPurpose === 'love' ? 'relationship' : 'threeCard');

      copyLabeledValue(payload, tarotDeckId, "deckId", "deck");
      copyLabeledValue(payload, tarotPurpose, "purpose");
      copyLabeledValue(
        payload,
        tarotQuestion,
        "questionText",
        "question",
      );
      payload.spreadType = tarotSpreadType;
      const selectedCardIndices = resolveTarotCardIndices(
        answers.tarotSelection,
      );
      if (selectedCardIndices.length === 0) {
        return null;
      }
      payload.selectedCardIndices = selectedCardIndices;
      payload.selectedCards = selectedCardIndices.map((index) => ({
        index,
        isReversed: false,
      }));
      payload.tarotSelection = {
        selectedCardIndices,
        selectedCards: selectedCardIndices.map((index) => ({
          index,
          isReversed: false,
        })),
        deckId: tarotDeckId ?? null,
        purpose: tarotPurpose ?? null,
        question: tarotQuestion ?? null,
        questionText: tarotQuestion ?? null,
        spreadType: tarotSpreadType,
      };
      break;
    }
    case "talisman":
      copyLabeledValue(
        payload,
        labels.generationMode,
        "generationMode",
        "generation_mode",
      );
      copyLabeledValue(payload, labels.purpose, "purpose");
      copyLabeledValue(payload, readString(answers.situation), "situation");
      copyLabeledValue(
        payload,
        resolveTalismanCategory(readString(answers.purpose), labels.purpose),
        "category",
      );
      break;
    case "wish":
      copyLabeledValue(payload, labels.category, "category");
      copyLabeledValue(
        payload,
        readString(answers.wishContent),
        "wishContent",
        "wish_content",
      );
      copyLabeledValue(payload, readString(answers.wishContent), "wish_text");
      copyLabeledValue(payload, labels.bokchae, "bokchae");
      payload.urgency = 3;
      payload.user_profile = buildWishUserProfile(profile);
      break;
    case "ootd-evaluation":
      {
        const photo = readPhotoAnswer(answers.photo);
        if (!photo?.base64) {
          return null;
        }
        copyLabeledValue(payload, photo.base64, "imageBase64", "image");
      }
      copyLabeledValue(payload, labels.tpo, "tpo");
      copyLabeledValue(
        payload,
        readString(answers.lookNote),
        "lookNote",
        "look_note",
      );
      copyLabeledValue(
        payload,
        profile.displayName ?? context.characterName ?? "회원님",
        "userName",
        "user_name",
      );
      break;
    case "personality-dna":
      copyLabeledValue(payload, labels.mbti, "mbti");
      copyLabeledValue(payload, labels.bloodType, "bloodType", "blood_type");
      copyLabeledValue(payload, labels.zodiac, "zodiac");
      copyLabeledValue(payload, labels.zodiacAnimal, "zodiacAnimal", "animal");
      break;
    case "wealth":
      copyLabeledValue(payload, labels.goal, "goal");
      copyLabeledValue(payload, labels.concern, "concern");
      copyLabeledValue(payload, labels.income, "income");
      copyLabeledValue(payload, labels.expense, "expense");
      copyLabeledValue(payload, labels.risk, "risk");
      copyLabeledValue(payload, labels.urgency, "urgency");
      if (Array.isArray(answers.interests)) {
        payload.interests = answers.interests;
      }
      break;
    case "talent":
      copyLabeledValue(payload, labels.workStyle, "workStyle", "work_style");
      copyLabeledValue(
        payload,
        labels.problemSolving,
        "problemSolving",
        "problem_solving",
      );
      copyLabeledValue(payload, labels.experience, "experience");
      copyLabeledValue(
        payload,
        labels.timeAvailable,
        "timeAvailable",
        "time_available",
      );
      if (Array.isArray(answers.interest)) {
        payload.interest = answers.interest;
      }
      if (Array.isArray(answers.challenges)) {
        payload.challenges = answers.challenges;
      }
      break;
    case "moving":
      copyLabeledValue(
        payload,
        readString(answers.currentArea),
        "currentArea",
        "current_area",
      );
      copyLabeledValue(
        payload,
        readString(answers.targetArea),
        "targetArea",
        "target_area",
      );
      copyLabeledValue(
        payload,
        labels.movingPeriod,
        "movingPeriod",
        "moving_period",
      );
      copyLabeledValue(payload, labels.purpose, "purpose");
      copyLabeledValue(
        payload,
        labels.purpose,
        "purposeCategory",
        "purpose_category",
      );
      if (Array.isArray(answers.concerns)) {
        payload.concerns = answers.concerns;
      }
      break;
    case "celebrity":
      copyLabeledValue(
        payload,
        readString(answers.celebrityName),
        "celebrity_name",
        "celebrityName",
      );
      copyLabeledValue(
        payload,
        labels.connectionType,
        "connection_type",
        "connectionType",
      );
      copyLabeledValue(
        payload,
        labels.interest,
        "question_type",
        "questionType",
      );
      break;
    case "pet-compatibility":
      copyLabeledValue(
        payload,
        readString(answers.petName),
        "pet_name",
        "petName",
      );
      copyLabeledValue(payload, labels.petSpecies, "pet_species", "petSpecies");
      copyNumericValue(
        payload,
        readString(answers.petAge),
        "pet_age",
        "petAge",
      );
      copyLabeledValue(payload, labels.petGender, "pet_gender", "petGender");
      copyLabeledValue(
        payload,
        labels.petPersonality,
        "pet_personality",
        "petPersonality",
      );
      break;
    case "match-insight": {
      copyLabeledValue(payload, labels.sport, "sport");
      copyLabeledValue(
        payload,
        readString(answers.homeTeam),
        "homeTeam",
        "home_team",
      );
      copyLabeledValue(
        payload,
        readString(answers.awayTeam),
        "awayTeam",
        "away_team",
      );
      copyLabeledValue(
        payload,
        readString(answers.gameDate),
        "gameDate",
        "game_date",
      );
      const favoriteTeam = resolveFavoriteTeam(answers);
      copyLabeledValue(payload, favoriteTeam, "favoriteTeam", "favorite_team");
      break;
    }
    case "decision":
      copyLabeledValue(
        payload,
        labels.decisionType,
        "decisionType",
        "decision_type",
      );
      copyLabeledValue(payload, readString(answers.question), "question");
      payload.options = parseOptionsList(readString(answers.optionsText));
      break;
    case "blood-type":
      copyLabeledValue(payload, profile.bloodType, "bloodType", "blood_type");
      break;
    case "zodiac":
    case "zodiac-animal":
    case "constellation":
    case "birthstone":
    case "daily":
      if (profile.birthDate) {
        copyLabeledValue(payload, profile.birthDate, "birthDate", "birth_date");
        const birthMonth = profile.birthDate.split("-")[1];
        if (birthMonth) {
          copyLabeledValue(
            payload,
            String(Number(birthMonth)),
            "birthMonth",
            "birth_month",
            "month",
          );
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

    if (answer == null || answer === "" || answer === "skip") {
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
  copyLabeledValue(
    payload,
    profile.displayName ?? "회원님",
    "name",
    "displayName",
  );
  copyLabeledValue(payload, profile.birthDate, "birthDate", "birth_date");
  copyLabeledValue(payload, profile.birthTime, "birthTime", "birth_time");
  copyLabeledValue(payload, profile.mbti, "mbti", "mbtiType");
  copyLabeledValue(payload, profile.bloodType, "bloodType", "blood_type");
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

function copyNumericValue(
  payload: UnknownRecord,
  value: string | null | undefined,
  ...keys: string[]
) {
  const text = readString(value);
  if (!text) {
    return;
  }

  const parsed = Number(text);
  if (!Number.isFinite(parsed)) {
    return;
  }

  for (const key of keys) {
    payload[key] = parsed;
  }
}

function readRecord(value: unknown): Record<string, unknown> | null {
  if (typeof value !== 'object' || value == null || Array.isArray(value)) {
    return null;
  }

  return value as Record<string, unknown>;
}

function normalizeAnswerValue(value: unknown) {
  if (value == null || value === "" || value === "skip") {
    return null;
  }

  if (readPhotoAnswer(value)) {
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
    fortuneType === "zodiac" ||
    fortuneType === "zodiac-animal" ||
    fortuneType === "constellation" ||
    fortuneType === "birthstone" ||
    fortuneType === "compatibility" ||
    fortuneType === "mbti"
  );
}

function deriveUserAgeGroup(birthDate?: string | null) {
  const yearText = birthDate?.split("-")[0];
  if (!yearText) {
    return null;
  }

  const year = Number(yearText);
  if (!Number.isFinite(year)) {
    return null;
  }

  const age = new Date().getFullYear() - year + 1;

  if (age < 20) {
    return "10s";
  }

  if (age < 30) {
    return "20s";
  }

  if (age < 40) {
    return "30s";
  }

  return "40s+";
}

function resolveFavoriteTeam(answers: Record<string, unknown>) {
  const favoriteSide = readString(answers.favoriteSide);
  if (!favoriteSide) {
    return null;
  }

  if (favoriteSide === "home") {
    return readString(answers.homeTeam);
  }

  if (favoriteSide === "away") {
    return readString(answers.awayTeam);
  }

  return null;
}

function resolveNewYearGoal(rawGoal?: string | null) {
  switch (rawGoal) {
    case "success":
    case "love":
    case "wealth":
    case "health":
    case "growth":
    case "travel":
    case "peace":
      return rawGoal;
    case "career":
      return "success";
    default:
      return null;
  }
}

function buildTraditionalSajuQuestion(
  analysisType?: string | null,
  specificQuestion?: string | null,
  customQuestion?: string | null,
  labels: Record<string, string> = {},
) {
  if (customQuestion) {
    return customQuestion;
  }

  const analysisLabel = labels.analysisType ?? analysisType ?? "overall";
  const pointLabel = labels.specificQuestion ?? specificQuestion ?? "overall";
  return `${analysisLabel} 중심으로 ${pointLabel} 포인트를 봐주세요.`;
}

function resolveMbtiCategory(
  rawCategory?: string | null,
  labelCategory?: string | null,
) {
  switch (rawCategory) {
    case "love":
    case "career":
    case "overall":
    case "all":
      return rawCategory;
    case "work":
      return "career";
    case "growth":
      return "all";
    case "mindset":
      return "overall";
    default:
      return readString(labelCategory);
  }
}

const tarotPlaceholderIndexMap: Record<string, number> = {
  "card-1": 3,
  "card-2": 12,
  "card-3": 27,
  "card-4": 41,
  "card-5": 56,
  "card-6": 70,
};

function resolveTarotCardIndices(value: unknown) {
  if (!Array.isArray(value)) {
    const record = readRecord(value);
    if (!record) {
      return [];
    }

    if (Array.isArray(record.selectedCardIndices)) {
      return resolveTarotCardIndices(record.selectedCardIndices);
    }

    if (Array.isArray(record.selectedCards)) {
      return resolveTarotCardIndices(
        record.selectedCards.map((entry) => readRecord(entry)?.index ?? entry),
      );
    }

    return [];
  }

  return value
    .map((entry) => {
      if (typeof entry === "number" && Number.isFinite(entry)) {
        return Math.trunc(entry);
      }

      const record = readRecord(entry);
      if (record && typeof record.index === 'number' && Number.isFinite(record.index)) {
        return Math.trunc(record.index);
      }

      const text = readString(entry);
      if (!text) {
        return null;
      }

      if (text in tarotPlaceholderIndexMap) {
        return tarotPlaceholderIndexMap[text];
      }

      const parsed = Number(text);
      return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
    })
    .filter((entry): entry is number => entry != null)
    .filter((entry) => entry >= 0 && entry < 78);
}

function resolveYearlyEncounterTargetGender(rawValue?: string | null) {
  if (rawValue === "male" || rawValue === "female") {
    return rawValue;
  }

  return null;
}

function resolveYearlyEncounterIdealMbti(
  rawValue?: string | null,
  labelValue?: string | null,
) {
  if (rawValue === "any") {
    return "상관없음";
  }

  return rawValue ?? labelValue ?? null;
}

function parseOptionsList(value: string | null) {
  if (!value) {
    return [];
  }

  return value
    .split(/[\n,]/u)
    .map((item) => item.trim())
    .filter(Boolean)
    .slice(0, 5);
}

function readPhotoAnswer(value: unknown): ChatSurveyPhotoAnswer | null {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return null;
  }

  const record = value as Record<string, unknown>;
  const base64 = readString(record.base64);
  if (!base64) {
    return null;
  }

  return {
    base64,
    fileName: readString(record.fileName),
    height: typeof record.height === "number" ? record.height : undefined,
    mimeType: readString(record.mimeType),
    uri: readString(record.uri) ?? undefined,
    width: typeof record.width === "number" ? record.width : undefined,
  };
}

function resolveFamilyConcern(
  rawConcern?: string | null,
  labelConcern?: string | null,
) {
  const source = (rawConcern ?? labelConcern ?? "").toLowerCase();

  if (
    source.includes("relationship") ||
    source.includes("관계") ||
    source.includes("소통") ||
    source.includes("harmony") ||
    source.includes("conflict") ||
    source.includes("support")
  ) {
    return "relationship";
  }

  if (
    source.includes("자녀") ||
    source.includes("아이") ||
    source.includes("child")
  ) {
    return "children";
  }

  if (
    source.includes("재물") ||
    source.includes("wealth") ||
    source.includes("돈")
  ) {
    return "wealth";
  }

  if (
    source.includes("future") ||
    source.includes("앞으로") ||
    source.includes("change")
  ) {
    return "change";
  }

  return "health";
}

function resolveFamilyRelationship(
  rawMember?: string | null,
  labelMember?: string | null,
) {
  const source = (rawMember ?? labelMember ?? "").toLowerCase();

  if (source.includes("parent") || source.includes("부모")) {
    return "parent";
  }

  if (
    source.includes("spouse") ||
    source.includes("partner") ||
    source.includes("배우자") ||
    source.includes("연인")
  ) {
    return "spouse";
  }

  if (
    source.includes("child") ||
    source.includes("자녀") ||
    source.includes("아이")
  ) {
    return "child";
  }

  if (source.includes("sibling") || source.includes("형제")) {
    return "sibling";
  }

  return "self";
}

function resolveFamilyDetailedQuestions(
  subtype: string,
  answers: Record<string, unknown>,
) {
  const answerKeyBySubtype: Record<string, string> = {
    relationship: "relationshipDetails",
    wealth: "wealthDetails",
    children: "childrenDetails",
    change: "changeDetails",
    health: "healthDetails",
  };

  const defaultsBySubtype: Record<string, string[]> = {
    relationship: ["couple"],
    wealth: ["income"],
    children: ["education"],
    change: ["timing"],
    health: ["family_health"],
  };

  const raw = answers[answerKeyBySubtype[subtype] ?? ""];
  if (Array.isArray(raw) && raw.length > 0) {
    return raw.map((entry) => readString(entry)).filter(Boolean) as string[];
  }

  return defaultsBySubtype[subtype] ?? [];
}

function resolveFamilyMemberCount(relationship: string) {
  return relationship === "self" ? 3 : 2;
}

function resolveTalismanCategory(
  rawPurpose?: string | null,
  labelPurpose?: string | null,
) {
  const source = (rawPurpose ?? labelPurpose ?? "").toLowerCase();

  if (source.includes("love") || source.includes("연애")) {
    return "love_relationship";
  }

  if (
    source.includes("career") ||
    source.includes("커리어") ||
    source.includes("기회")
  ) {
    return "wealth_career";
  }

  if (
    source.includes("health") ||
    source.includes("건강") ||
    source.includes("회복")
  ) {
    return "health_longevity";
  }

  if (
    source.includes("calm") ||
    source.includes("안정") ||
    source.includes("평안")
  ) {
    return "home_protection";
  }

  return "home_protection";
}

function buildWishUserProfile(profile: EmbeddedResultProfileContext) {
  return {
    name: profile.displayName ?? "회원님",
    birthDate: profile.birthDate ?? null,
    birthTime: profile.birthTime ?? null,
    mbti: profile.mbti ?? null,
    bloodType: profile.bloodType ?? null,
  };
}

function resolveNamingGender(rawGender?: string | null) {
  if (rawGender === "male" || rawGender === "female" || rawGender === "unknown") {
    return rawGender;
  }

  return "unknown";
}

function resolveNamingStyle(rawStyle?: string | null) {
  if (
    rawStyle === "traditional" ||
    rawStyle === "modern" ||
    rawStyle === "korean"
  ) {
    return rawStyle;
  }

  return "modern";
}

function readString(value: unknown) {
  if (typeof value === "string") {
    const trimmed = value.trim();
    return trimmed.length > 0 ? trimmed : null;
  }

  return null;
}
