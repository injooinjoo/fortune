import {
  assertEquals,
  assertNotEquals,
} from "https://deno.land/std@0.168.0/testing/asserts.ts";
import {
  ACTIVE_PROACTIVE_SLOT_KEYS,
  chooseDailyImageBearingPlan,
  determineSlotForLocalHour,
  getImageBearingPlanForSlot,
} from "./proactive_message_rules.ts";

Deno.test("determineSlotForLocalHour maps Slice 2 luts slots", () => {
  assertEquals(determineSlotForLocalHour(10), null);
  assertEquals(determineSlotForLocalHour(11), "lunch_share");
  assertEquals(determineSlotForLocalHour(13), "lunch_share");
  assertEquals(determineSlotForLocalHour(14), null);
  assertEquals(determineSlotForLocalHour(20), "evening_chat");
  assertEquals(determineSlotForLocalHour(21), "evening_chat");
  assertEquals(determineSlotForLocalHour(22), "goodnight");
  assertEquals(determineSlotForLocalHour(23), "goodnight");
  assertEquals(determineSlotForLocalHour(24), null);
});

Deno.test("chooseDailyImageBearingPlan chooses exactly one active slot per user-day", () => {
  const plan = chooseDailyImageBearingPlan("user-1", "2026-05-11");
  assertEquals(ACTIVE_PROACTIVE_SLOT_KEYS.includes(plan.slotKey), true);
  assertEquals(plan.category, "meal");

  let matchCount = 0;
  for (const slotKey of ACTIVE_PROACTIVE_SLOT_KEYS) {
    if (getImageBearingPlanForSlot("user-1", "2026-05-11", slotKey)) {
      matchCount += 1;
    }
  }
  assertEquals(matchCount, 1);
});

Deno.test("daily image-bearing plan is deterministic and date-sensitive", () => {
  const first = chooseDailyImageBearingPlan("user-1", "2026-05-11");
  const second = chooseDailyImageBearingPlan("user-1", "2026-05-11");
  assertEquals(second, first);

  const seen = new Set<string>();
  for (let day = 11; day <= 25; day += 1) {
    seen.add(chooseDailyImageBearingPlan("user-1", `2026-05-${day}`).slotKey);
  }
  assertNotEquals(seen.size, 1);
});
