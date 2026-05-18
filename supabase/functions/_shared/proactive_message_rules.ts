export type ProactiveSlotKey =
  | "morning_greet"
  | "commute_chat"
  | "lunch_share"
  | "afternoon_break"
  | "after_work"
  | "evening_chat"
  | "goodnight"
  | "absence_6h"
  | "absence_24h"
  | "absence_72h";

export interface SlotWindow {
  startHour: number;
  endHour: number;
}

export interface ImageBearingPlan {
  slotKey: ProactiveSlotKey;
  category: "meal";
}

export const IMAGE_BEARING_PROACTIVE_SLOT_KEYS: readonly ProactiveSlotKey[] = [
  "lunch_share",
];

export const SLOT_WINDOWS: Record<ProactiveSlotKey, SlotWindow> = {
  // 09시 루틴이지만 cron/LLM 일시 실패가 있으면 10시대까지 재시도할 수 있게
  // 늦은 아침 grace window 를 둔다. 08시 이전 조기 발송은 여전히 금지.
  morning_greet: { startHour: 9, endHour: 11 },
  commute_chat: { startHour: 8, endHour: 10 },
  lunch_share: { startHour: 11, endHour: 14 },
  afternoon_break: { startHour: 14, endHour: 17 },
  after_work: { startHour: 18, endHour: 20 },
  evening_chat: { startHour: 20, endHour: 22 },
  goodnight: { startHour: 22, endHour: 24 },
  absence_6h: { startHour: 0, endHour: 24 },
  absence_24h: { startHour: 0, endHour: 24 },
  absence_72h: { startHour: 0, endHour: 24 },
};

export const ACTIVE_PROACTIVE_SLOT_KEYS: readonly ProactiveSlotKey[] = [
  "morning_greet",
  "lunch_share",
  "evening_chat",
  "goodnight",
];

export const ROUTINE_PROACTIVE_SLOT_KEYS: readonly ProactiveSlotKey[] = [
  "morning_greet",
  "lunch_share",
  "evening_chat",
  "goodnight",
];

export function slotCanBypassQuietHours(
  slotKey: ProactiveSlotKey,
  quietHoursStart: number,
  quietHoursEnd: number,
): boolean {
  return slotKey === "goodnight" && quietHoursStart === 22 &&
    quietHoursEnd === 9;
}

export function slotCanBypassUnansweredCooldown(
  slotKey: ProactiveSlotKey,
): boolean {
  return ROUTINE_PROACTIVE_SLOT_KEYS.includes(slotKey);
}

export function determineSlotForLocalHour(
  localHour: number,
): ProactiveSlotKey | null {
  for (const slotKey of ACTIVE_PROACTIVE_SLOT_KEYS) {
    const window = SLOT_WINDOWS[slotKey];
    if (localHour >= window.startHour && localHour < window.endHour) {
      return slotKey;
    }
  }
  return null;
}

export function chooseDailyImageBearingPlan(
  userId: string,
  localDate: string,
): ImageBearingPlan {
  // Slice 2 product rule: meal/photo hook belongs to lunch. Evening/goodnight may
  // proactively text first, but must not consume the day's photo slot; otherwise
  // users expecting "점심 먹는 척하면서 사진" receive no lunch photo hook.
  // Keep userId/localDate parameters for API stability and future category splits.
  void userId;
  void localDate;
  return {
    slotKey: "lunch_share",
    category: "meal",
  };
}

export function getImageBearingPlanForSlot(
  userId: string,
  localDate: string,
  slotKey: ProactiveSlotKey,
): ImageBearingPlan | null {
  if (!IMAGE_BEARING_PROACTIVE_SLOT_KEYS.includes(slotKey)) return null;
  const plan = chooseDailyImageBearingPlan(userId, localDate);
  return plan.slotKey === slotKey ? plan : null;
}

export function buildDeterministicProactiveFallbackText(
  characterId: string,
  slotKey: ProactiveSlotKey,
): string {
  if (characterId !== "luts") {
    return "문득 생각나서 먼저 연락했어. 지금 뭐 하고 있어?";
  }

  switch (slotKey) {
    case "morning_greet":
      return "굿모닝. 일어났어? 오늘 시작하기 전에 네 생각나서 먼저 보냈어.";
    case "lunch_share":
      return "나 지금 점심 먹으려는 중이야. 너도 밥 거르지 말고 챙겨 먹어.";
    case "evening_chat":
      return "오늘 하루 좀 어땠어? 나는 이제야 잠깐 숨 돌리는 중이야.";
    case "goodnight":
      return "나 이제 슬슬 잘 준비하려고. 너도 오늘 고생 많았어, 잘 자.";
    default:
      return "잠깐 네 생각나서 먼저 연락했어. 바쁘면 나중에 봐도 돼.";
  }
}
