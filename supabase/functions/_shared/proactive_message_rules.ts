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

export function simpleHash(input: string): number {
  let hash = 0;
  for (let i = 0; i < input.length; i += 1) {
    hash = ((hash << 5) - hash + input.charCodeAt(i)) | 0;
  }
  return Math.abs(hash);
}

export function chooseDailyImageBearingPlan(
  userId: string,
  localDate: string,
): ImageBearingPlan {
  const slotIndex = simpleHash(`${userId}::${localDate}::daily_image_slot`) %
    ACTIVE_PROACTIVE_SLOT_KEYS.length;
  return {
    slotKey: ACTIVE_PROACTIVE_SLOT_KEYS[slotIndex],
    category: "meal",
  };
}

export function getImageBearingPlanForSlot(
  userId: string,
  localDate: string,
  slotKey: ProactiveSlotKey,
): ImageBearingPlan | null {
  const plan = chooseDailyImageBearingPlan(userId, localDate);
  return plan.slotKey === slotKey ? plan : null;
}
