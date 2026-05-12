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
  morning_greet: { startHour: 7, endHour: 9 },
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
  "lunch_share",
  "evening_chat",
  "goodnight",
];

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
