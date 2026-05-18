import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";
import {
  ACTIVE_PROACTIVE_SLOT_KEYS,
  buildDeterministicProactiveFallbackText,
  chooseDailyImageBearingPlan,
  determineSlotForLocalHour,
  getImageBearingPlanForSlot,
  IMAGE_BEARING_PROACTIVE_SLOT_KEYS,
  slotCanBypassQuietHours,
  slotCanBypassUnansweredCooldown,
} from "./proactive_message_rules.ts";

Deno.test("determineSlotForLocalHour maps Slice 2 luts slots", () => {
  assertEquals(determineSlotForLocalHour(8), null);
  assertEquals(determineSlotForLocalHour(9), "morning_greet");
  assertEquals(determineSlotForLocalHour(10), "morning_greet");
  assertEquals(determineSlotForLocalHour(11), "lunch_share");
  assertEquals(determineSlotForLocalHour(13), "lunch_share");
  assertEquals(determineSlotForLocalHour(14), null);
  assertEquals(determineSlotForLocalHour(20), "evening_chat");
  assertEquals(determineSlotForLocalHour(21), "evening_chat");
  assertEquals(determineSlotForLocalHour(22), "goodnight");
  assertEquals(determineSlotForLocalHour(23), "goodnight");
  assertEquals(determineSlotForLocalHour(24), null);
});

Deno.test("deterministic fallback keeps luts proactive alive when LLM quota fails", () => {
  assertEquals(
    buildDeterministicProactiveFallbackText("luts", "morning_greet").includes(
      "굿모닝",
    ),
    true,
  );
  assertEquals(
    buildDeterministicProactiveFallbackText("luts", "lunch_share").includes(
      "점심",
    ),
    true,
  );
  assertEquals(
    buildDeterministicProactiveFallbackText("luts", "goodnight").includes(
      "잘 자",
    ),
    true,
  );
});

Deno.test("routine slots keep luts relationship cadence without photo leakage", () => {
  assertEquals(slotCanBypassQuietHours("goodnight", 22, 9), true);
  assertEquals(slotCanBypassQuietHours("goodnight", 21, 8), false);
  assertEquals(slotCanBypassQuietHours("lunch_share", 22, 9), false);
  assertEquals(slotCanBypassUnansweredCooldown("morning_greet"), true);
  assertEquals(slotCanBypassUnansweredCooldown("lunch_share"), true);
  assertEquals(slotCanBypassUnansweredCooldown("evening_chat"), true);
  assertEquals(slotCanBypassUnansweredCooldown("goodnight"), true);
  assertEquals(slotCanBypassUnansweredCooldown("absence_24h"), false);
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
