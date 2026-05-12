import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";
import {
  ACTIVE_PROACTIVE_SLOT_KEYS,
  chooseDailyImageBearingPlan,
  determineSlotForLocalHour,
  getImageBearingPlanForSlot,
  IMAGE_BEARING_PROACTIVE_SLOT_KEYS,
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

Deno.test("chooseDailyImageBearingPlan keeps meal photo hooks on lunch", () => {
  const plan = chooseDailyImageBearingPlan("user-1", "2026-05-11");
  assertEquals(plan.slotKey, "lunch_share");
  assertEquals(plan.category, "meal");
  assertEquals(IMAGE_BEARING_PROACTIVE_SLOT_KEYS, ["lunch_share"]);

  let matchCount = 0;
  for (const slotKey of ACTIVE_PROACTIVE_SLOT_KEYS) {
    if (getImageBearingPlanForSlot("user-1", "2026-05-11", slotKey)) {
      matchCount += 1;
    }
  }
  assertEquals(matchCount, 1);
});

Deno.test("daily image-bearing plan is deterministic and user/date stable", () => {
  const first = chooseDailyImageBearingPlan("user-1", "2026-05-11");
  const second = chooseDailyImageBearingPlan("user-1", "2026-05-11");
  assertEquals(second, first);
  assertEquals(chooseDailyImageBearingPlan("user-2", "2026-05-12"), first);
  assertEquals(
    getImageBearingPlanForSlot("user-1", "2026-05-11", "evening_chat"),
    null,
  );
  assertEquals(
    getImageBearingPlanForSlot("user-1", "2026-05-11", "goodnight"),
    null,
  );
});
