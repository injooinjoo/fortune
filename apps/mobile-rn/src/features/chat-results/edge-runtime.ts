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
      copyLabeledValue(
        payload,
        readString(answers.targetDate) ?? labels.targetDate,
        "targetDate",
        "target_date",
        "date",
      );
      copyLabeledValue(payload, "today", "period");
      payload.calendarSynced = answers.calendarSynced === true;
      payload.hasCalendarEvents = answers.hasCalendarEvents === true;
      if (Array.isArray(answers.calendarEvents)) {
        payload.calendarEvents = answers.calendarEvents;
      }
      copyLabeledValue(
        payload,
        readString(answers.calendarSummary),
        "calendarSummary",
        "calendar_summary",
      );
      if (Array.isArray(answers.calendarTags)) {
        payload.calendarTags = answers.calendarTags;
      }
      break;
    case "biorhythm":
      copyLabeledValue(
        payload,
        readString(answers.targetDate) ?? labels.targetDate,
        "targetDate",
        "target_date",
      );
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
    case "love": {
      const age = deriveAge(profile.birthDate);
      const relationshipStatus = resolveLoveRelationshipStatus(
        readString(answers.status),
      );
      const datingStyles = resolveStringArray(answers.datingStyle);

      if (age == null || !relationshipStatus || datingStyles.length === 0) {
        return null;
      }

      payload.age = age;
      copyLabeledValue(payload, profile.gender ?? "other", "gender");
      copyLabeledValue(payload, relationshipStatus, "relationshipStatus");
      payload.datingStyles = datingStyles;
      payload.valueImportance = buildLoveValueImportance(
        readString(answers.concern),
      );
      payload.preferredAgeRange = {
        min: Math.max(19, age - 4),
        max: age + 4,
      };
      payload.idealLooks = resolveStringArray(answers.idealLooks);
      payload.preferredPersonality = resolveStringArray(
        answers.idealPersonality,
      );
      payload.preferredMeetingPlaces = buildLoveMeetingPlaces(
        readString(answers.concern),
      );
      copyLabeledValue(
        payload,
        resolveLoveRelationshipGoal(readString(answers.concern)),
        "relationshipGoal",
      );
      payload.appearanceConfidence = 3;
      payload.charmPoints = buildLoveCharmPoints(datingStyles, profile.mbti);
      payload.lifestyle = buildLoveLifestyle(profile.mbti, profile.bloodType);
      break;
    }
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
      {
        const primaryGoal = resolveExLoverGoal(readString(answers.primaryGoal));
        const timeSinceBreakup = resolveExLoverTimeSinceBreakup(
          readString(answers.breakupTime),
        );
        const breakupInitiator = resolveBreakupInitiator(
          readString(answers.breakupInitiator),
        );
        const relationshipDepth = resolveExLoverRelationshipDepth(
          readString(answers.relationshipDepth),
        );
        const coreReason = resolveExLoverCoreReason(
          readString(answers.coreReason),
        );
        const contactStatus = resolveExLoverContactStatus(
          readString(answers.contactStatus),
        );
        const currentState = resolveExLoverCurrentState(answers.currentState);

        if (
          !primaryGoal ||
          !timeSinceBreakup ||
          !relationshipDepth ||
          !coreReason ||
          !contactStatus ||
          currentState.length === 0
        ) {
          return null;
        }

        copyLabeledValue(payload, primaryGoal, "primaryGoal", "primary_goal");
        copyLabeledValue(
          payload,
          timeSinceBreakup,
          "time_since_breakup",
          "breakupTime",
          "breakup_time",
        );
        copyLabeledValue(
          payload,
          breakupInitiator ?? "mutual",
          "breakup_initiator",
          "breakupInitiator",
        );
        copyLabeledValue(
          payload,
          relationshipDepth,
          "relationshipDepth",
          "relationship_depth",
        );
        copyLabeledValue(payload, coreReason, "coreReason", "core_reason");
        payload.currentState = currentState;
        payload.current_state = currentState;
        copyLabeledValue(
          payload,
          contactStatus,
          "contact_status",
          "contactStatus",
        );
        copyLabeledValue(
          payload,
          readString(answers.detailedStory),
          "breakup_detail",
          "breakupDetail",
        );
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
        copyLabeledValue(
          payload,
          targetGender,
          "targetGender",
          "target_gender",
        );
      }
      copyLabeledValue(payload, labels.userAge, "userAge", "user_age");
      copyLabeledValue(
        payload,
        resolveYearlyEncounterIdealMbti(
          readString(answers.idealMbti),
          labels.idealMbti,
        ),
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
      {
        const currentCondition = resolveHealthCondition(
          readString(answers.currentCondition),
        );
        if (!currentCondition) {
          return null;
        }

        copyLabeledValue(
          payload,
          currentCondition,
          "currentCondition",
          "current_condition",
        );
        const concernedBodyParts = resolveHealthConcernedBodyParts(
          readString(answers.concern),
        );
        if (concernedBodyParts.length > 0) {
          payload.concerned_body_parts = concernedBodyParts;
        }
        const stressLevel = readIntegerValue(answers.stressLevel);
        if (stressLevel != null) {
          payload.stressLevel = stressLevel;
          payload.stress_level = stressLevel;
        }
        const sleepQuality = readIntegerValue(answers.sleepQuality);
        if (sleepQuality != null) {
          payload.sleepQuality = sleepQuality;
          payload.sleep_quality = sleepQuality;
        }
        const exerciseFrequency = readIntegerValue(answers.exerciseFrequency);
        if (exerciseFrequency != null) {
          payload.exerciseFrequency = exerciseFrequency;
          payload.exercise_frequency = exerciseFrequency;
        }
        const mealRegularity = readIntegerValue(answers.mealRegularity);
        if (mealRegularity != null) {
          payload.mealRegularity = mealRegularity;
          payload.meal_regularity = mealRegularity;
        }
      }
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
      copyLabeledValue(payload, profile.birthDate, "motherBirthDate");
      copyLabeledValue(payload, profile.birthTime, "motherBirthTime");
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
      copyLabeledValue(payload, readString(answers.lastName), "familyName");
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
        (tarotPurpose === "love" ? "relationship" : "threeCard");

      copyLabeledValue(payload, tarotDeckId, "deckId", "deck");
      copyLabeledValue(payload, tarotPurpose, "purpose");
      copyLabeledValue(payload, tarotQuestion, "questionText", "question");
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
      {
        const goal = resolveWealthGoal(readString(answers.goal));
        const concern = resolveWealthConcern(readString(answers.concern));
        const income = resolveWealthIncome(readString(answers.income));
        const expense = resolveWealthExpense(readString(answers.expense));
        const risk = resolveWealthRisk(readString(answers.risk));
        const urgency = resolveWealthUrgency(readString(answers.urgency));

        if (!goal || !concern || !income || !expense || !risk || !urgency) {
          return null;
        }

        copyLabeledValue(payload, goal, "goal");
        copyLabeledValue(payload, concern, "concern");
        copyLabeledValue(payload, income, "income");
        copyLabeledValue(payload, expense, "expense");
        copyLabeledValue(payload, risk, "risk");
        copyLabeledValue(payload, urgency, "urgency");
        payload.interests = resolveWealthInterests(answers.interests, goal);
      }
      break;
    case "talent":
      {
        const interests = resolveStringArray(answers.interest);
        const talentArea = resolveTalentArea(interests);
        if (!talentArea) {
          return null;
        }

        payload.talentArea = talentArea;
        payload.currentSkills = resolveTalentCurrentSkills(interests);
        copyLabeledValue(
          payload,
          readString(answers.goal) ?? buildTalentGoal(labels, interests),
          "goals",
        );
        copyLabeledValue(payload, labels.experience, "experience");
        copyLabeledValue(
          payload,
          labels.timeAvailable,
          "timeAvailable",
          "time_available",
        );
        payload.challenges = resolveStringArray(answers.challenges);
        copyLabeledValue(payload, labels.workStyle, "workStyle", "work_style");
        copyLabeledValue(
          payload,
          labels.problemSolving,
          "problemSolving",
          "problem_solving",
        );
      }
      break;
    case "exercise":
      {
        const exerciseGoal = resolveExerciseGoal(readString(answers.goal));
        const sportType = resolveExerciseSportType(
          readString(answers.sportType),
        );
        const weeklyFrequency = readIntegerValue(answers.weeklyFrequency) ?? 3;
        const preferredTime =
          resolveExercisePreferredTime(readString(answers.preferredTime)) ??
          "evening";

        if (!exerciseGoal || !sportType) {
          return null;
        }

        copyLabeledValue(payload, exerciseGoal, "exerciseGoal");
        copyLabeledValue(payload, sportType, "sportType");
        payload.weeklyFrequency = weeklyFrequency;
        copyLabeledValue(
          payload,
          resolveExerciseExperienceLevel(
            weeklyFrequency,
            readString(answers.intensity),
          ),
          "experienceLevel",
        );
        payload.fitnessLevel = resolveExerciseFitnessLevel(
          readString(answers.intensity),
        );
        payload.injuryHistory = resolveExerciseInjuryHistory(
          answers.injuryHistory,
        );
        copyLabeledValue(payload, preferredTime, "preferredTime");
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
  copyLabeledValue(payload, profile.gender, "gender");
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
  if (typeof value !== "object" || value == null || Array.isArray(value)) {
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
    fortuneType === "daily-calendar" ||
    fortuneType === "new-year" ||
    fortuneType === "love" ||
    fortuneType === "naming" ||
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

function deriveAge(birthDate?: string | null) {
  const yearText = birthDate?.split("-")[0];
  if (!yearText) {
    return null;
  }

  const year = Number(yearText);
  if (!Number.isFinite(year)) {
    return null;
  }

  return new Date().getFullYear() - year + 1;
}

function readIntegerValue(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return Math.trunc(value);
  }

  const text = readString(value);
  if (!text) {
    return null;
  }

  const parsed = Number(text);
  return Number.isFinite(parsed) ? Math.trunc(parsed) : null;
}

function resolveStringArray(value: unknown) {
  if (!Array.isArray(value)) {
    const single = readString(value);
    return single ? [single] : [];
  }

  return value.map((entry) => readString(entry)).filter(Boolean) as string[];
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

function resolveLoveRelationshipStatus(rawValue?: string | null) {
  switch (rawValue) {
    case "single":
    case "dating":
    case "crush":
    case "complicated":
      return rawValue;
    default:
      return null;
  }
}

function buildLoveValueImportance(concern?: string | null) {
  const base = {
    외모: 3,
    성격: 5,
    경제력: 3,
    가치관: 4,
    유머감각: 3,
  };

  switch (concern) {
    case "meeting":
      return { ...base, 외모: 4, 유머감각: 4 };
    case "confession":
      return { ...base, 성격: 4, 가치관: 5 };
    case "future":
      return { ...base, 경제력: 4, 가치관: 5 };
    default:
      return base;
  }
}

function buildLoveMeetingPlaces(concern?: string | null) {
  switch (concern) {
    case "meeting":
      return ["카페", "전시", "지인 모임"];
    case "confession":
      return ["조용한 산책길", "야경 좋은 장소", "둘이 대화하기 좋은 카페"];
    case "future":
      return ["한적한 식당", "주말 드라이브", "오래 머물 수 있는 공간"];
    default:
      return ["카페", "공원", "취향이 맞는 장소"];
  }
}

function resolveLoveRelationshipGoal(concern?: string | null) {
  switch (concern) {
    case "meeting":
      return "new_connection";
    case "confession":
      return "clear_signal";
    case "future":
      return "long_term_stability";
    default:
      return "relationship_growth";
  }
}

function buildLoveCharmPoints(datingStyles: string[], mbti?: string | null) {
  const mapped = datingStyles
    .map((style) => {
      switch (style) {
        case "active":
          return "주도적으로 분위기를 만드는 힘";
        case "romantic":
          return "감정을 따뜻하게 표현하는 매력";
        case "practical":
          return "안정적으로 관계를 이끄는 감각";
        case "independent":
          return "건강한 거리감을 지키는 태도";
        default:
          return null;
      }
    })
    .filter(Boolean) as string[];

  if (mbti) {
    mapped.push(`${mbti.toUpperCase()}다운 개성`);
  }

  return mapped.slice(0, 3);
}

function buildLoveLifestyle(mbti?: string | null, bloodType?: string | null) {
  const traits = [
    mbti ? `${mbti.toUpperCase()} 성향` : null,
    bloodType ? `${bloodType.toUpperCase()} 기질` : null,
  ]
    .filter(Boolean)
    .join(" · ");

  return traits || "일상 리듬을 중시하는 편";
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
      if (
        record &&
        typeof record.index === "number" &&
        Number.isFinite(record.index)
      ) {
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

function resolveExLoverGoal(rawValue?: string | null) {
  switch (rawValue) {
    case "reunion":
      return "reunion_strategy";
    case "closure":
    case "healing":
      return "healing";
    case "clarity":
      return "read_their_mind";
    default:
      return null;
  }
}

function resolveExLoverTimeSinceBreakup(rawValue?: string | null) {
  switch (rawValue) {
    case "recent":
      return "recent";
    case "quarter":
      return "short";
    case "half-year":
      return "medium";
    case "long":
      return "long";
    default:
      return null;
  }
}

function resolveBreakupInitiator(rawValue?: string | null) {
  if (rawValue === "me" || rawValue === "them" || rawValue === "mutual") {
    return rawValue;
  }

  return null;
}

function resolveExLoverRelationshipDepth(rawValue?: string | null) {
  switch (rawValue) {
    case "light":
      return "casual";
    case "steady":
      return "moderate";
    case "deep":
      return "deep";
    case "unfinished":
      return "very_deep";
    default:
      return null;
  }
}

function resolveExLoverCoreReason(rawValue?: string | null) {
  switch (rawValue) {
    case "distance":
      return "distance";
    case "conflict":
      return "communication";
    case "values":
      return "values";
    case "fade":
      return "feelings_changed";
    default:
      return null;
  }
}

function resolveExLoverCurrentState(value: unknown) {
  return resolveStringArray(value)
    .map((entry) => {
      switch (entry) {
        case "still-miss":
          return "miss_them";
        case "curious":
          return "checking_sns";
        case "hurt":
          return "crying";
        case "moving-on":
          return "moving_on";
        default:
          return null;
      }
    })
    .filter(Boolean) as string[];
}

function resolveExLoverContactStatus(rawValue?: string | null) {
  switch (rawValue) {
    case "blocked":
      return "blocked";
    case "no-contact":
      return "noContact";
    case "sometimes":
      return "sometimes";
    case "often":
      return "often";
    default:
      return null;
  }
}

function resolveHealthCondition(rawValue?: string | null) {
  switch (rawValue) {
    case "great":
      return "great";
    case "normal":
      return "normal";
    case "tired":
      return "tired";
    case "drained":
      return "exhausted";
    default:
      return null;
  }
}

function resolveHealthConcernedBodyParts(rawValue?: string | null) {
  switch (rawValue) {
    case "sleep":
      return ["head", "heart"];
    case "stress":
      return ["heart", "liver"];
    case "diet":
      return ["stomach", "spleen"];
    case "fitness":
      return ["muscle", "lung"];
    default:
      return [];
  }
}

function resolveWealthGoal(rawValue?: string | null) {
  switch (rawValue) {
    case "save":
      return "saving";
    case "income":
      return "income";
    case "invest":
      return "investment";
    case "debt":
      return "expense";
    default:
      return null;
  }
}

function resolveWealthConcern(rawValue?: string | null) {
  switch (rawValue) {
    case "cashflow":
      return "savings";
    case "overspend":
      return "spending";
    case "risk":
      return "loss";
    case "timing":
      return "returns";
    default:
      return null;
  }
}

function resolveWealthIncome(rawValue?: string | null) {
  switch (rawValue) {
    case "stable":
      return "stable";
    case "growing":
      return "increasing";
    case "variable":
      return "irregular";
    case "tight":
      return "decreasing";
    default:
      return null;
  }
}

function resolveWealthExpense(rawValue?: string | null) {
  switch (rawValue) {
    case "controlled":
      return "frugal";
    case "rising":
      return "variable";
    case "impulsive":
      return "spender";
    case "heavy":
      return "balanced";
    default:
      return null;
  }
}

function resolveWealthRisk(rawValue?: string | null) {
  switch (rawValue) {
    case "low":
      return "safe";
    case "balanced":
      return "balanced";
    case "high":
      return "aggressive";
    default:
      return null;
  }
}

function resolveWealthUrgency(rawValue?: string | null) {
  switch (rawValue) {
    case "low":
      return "longTerm";
    case "mid":
      return "thisYear";
    case "high":
      return "urgent";
    default:
      return null;
  }
}

function resolveWealthInterests(value: unknown, goal: string) {
  const interests = resolveStringArray(value).filter((entry) =>
    ["saving", "stock", "crypto", "realestate", "business", "side"].includes(
      entry,
    ),
  );

  if (interests.length > 0) {
    return interests;
  }

  switch (goal) {
    case "investment":
      return ["stock"];
    case "income":
      return ["business", "side"];
    default:
      return ["saving"];
  }
}

function resolveTalentArea(interests: string[]) {
  if (interests.includes("design")) {
    return "예술";
  }

  if (interests.includes("analysis")) {
    return "학문";
  }

  if (interests.includes("communication")) {
    return "비즈니스";
  }

  if (interests.includes("writing")) {
    return "학문";
  }

  return interests.length > 0 ? "기술" : null;
}

function resolveTalentCurrentSkills(interests: string[]) {
  const mapped = interests.map((interest) => {
    switch (interest) {
      case "writing":
        return "글쓰기";
      case "design":
        return "시각화";
      case "analysis":
        return "분석적 사고";
      case "communication":
        return "커뮤니케이션";
      default:
        return null;
    }
  });

  return mapped.filter(Boolean) as string[];
}

function buildTalentGoal(labels: Record<string, string>, interests: string[]) {
  const focus = labels.interest ?? interests.join(", ");
  const workStyle = labels.workStyle ? `${labels.workStyle} 방식으로` : "";
  return [focus ? `${focus} 역량을 키우고 싶어요.` : null, workStyle]
    .filter(Boolean)
    .join(" ");
}

function resolveExerciseGoal(rawValue?: string | null) {
  switch (rawValue) {
    case "health":
      return "flexibility";
    case "strength":
      return "strength";
    case "diet":
      return "diet";
    case "mood":
      return "stress_relief";
    default:
      return null;
  }
}

function resolveExerciseSportType(rawValue?: string | null) {
  switch (rawValue) {
    case "gym":
    case "running":
    case "yoga":
    case "swimming":
      return rawValue;
    default:
      return null;
  }
}

function resolveExercisePreferredTime(rawValue?: string | null) {
  switch (rawValue) {
    case "morning":
    case "afternoon":
    case "evening":
    case "night":
      return rawValue;
    default:
      return null;
  }
}

function resolveExerciseExperienceLevel(
  weeklyFrequency: number,
  intensity?: string | null,
) {
  if (weeklyFrequency >= 5 || intensity === "hard") {
    return "advanced";
  }

  if (weeklyFrequency >= 4 || intensity === "medium") {
    return "intermediate";
  }

  return "beginner";
}

function resolveExerciseFitnessLevel(intensity?: string | null) {
  switch (intensity) {
    case "light":
      return 2;
    case "medium":
      return 3;
    case "hard":
      return 4;
    default:
      return 3;
  }
}

function resolveExerciseInjuryHistory(value: unknown) {
  const injuries = resolveStringArray(value);
  if (injuries.includes("none")) {
    return [];
  }

  return injuries;
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
  if (
    rawGender === "male" ||
    rawGender === "female" ||
    rawGender === "unknown"
  ) {
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
