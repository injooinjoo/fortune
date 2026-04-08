import {
  fortuneTypesById,
  type FortuneTypeId,
} from "@fortune/product-contracts";

import type { EmbeddedResultProfileContext } from "./types";

export type FortuneRuntimeBlockReason =
  | "login-required"
  | "missing-profile-birth-date"
  | "missing-profile-blood-type"
  | "edge-unavailable";

const edgeUnavailableFortuneTypes = new Set<FortuneTypeId>(["lotto"]);

const profileBirthDateRequiredFortuneTypes = new Set<FortuneTypeId>([
  "daily-calendar",
  "new-year",
  "love",
  "naming",
  "lucky-items",
  "mbti",
  "compatibility",
  "biorhythm",
  "past-life",
  "zodiac",
  "zodiac-animal",
  "constellation",
  "birthstone",
]);

const profileBloodTypeRequiredFortuneTypes = new Set<FortuneTypeId>([
  "blood-type",
]);

export function resolveFortuneRuntimeBlockReason(
  fortuneType: FortuneTypeId,
  profile: EmbeddedResultProfileContext,
  isAuthenticated = true,
): FortuneRuntimeBlockReason | null {
  const spec = fortuneTypesById[fortuneType];
  if (!spec.isLocalOnly && spec.endpoint && !isAuthenticated) {
    return "login-required";
  }

  if (
    profileBirthDateRequiredFortuneTypes.has(fortuneType) &&
    !profile.birthDate
  ) {
    return "missing-profile-birth-date";
  }

  if (
    profileBloodTypeRequiredFortuneTypes.has(fortuneType) &&
    !profile.bloodType
  ) {
    return "missing-profile-blood-type";
  }

  if (edgeUnavailableFortuneTypes.has(fortuneType)) {
    return "edge-unavailable";
  }

  return null;
}

export function buildFortuneRuntimeBlockMessage(
  fortuneType: FortuneTypeId,
  reason: FortuneRuntimeBlockReason,
) {
  switch (reason) {
    case "login-required":
      return "로그인이 필요해요. 결과 저장과 재호출 재사용까지 같이 처리하려면 먼저 로그인해주세요.";
    case "missing-profile-birth-date":
      return "이 결과는 생년월일이 있어야 정확히 볼 수 있어요. 프로필에서 생년월일을 먼저 입력해주세요.";
    case "missing-profile-blood-type":
      return "이 결과는 혈액형 정보가 있어야 정확히 볼 수 있어요. 프로필에서 혈액형을 먼저 입력해주세요.";
    case "edge-unavailable":
      return "이 운세는 전용 분석 연결을 정리 중이라 지금은 다른 결과로 섞어 보여주지 않겠습니다.";
    default:
      return null;
  }
}
