import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";

import { planImmediateReplyDelivery } from "./pending_reply_delivery.ts";

Deno.test("immediate reply delivery persists direct character-chat response with job id", () => {
  const plan = planImmediateReplyDelivery({
    jobId: "job-123",
    chatData: {
      success: true,
      response: "  다시 말해. 듣고 있어.  ",
      emotionTag: "calm",
    },
  });

  assertEquals(plan.shouldDeliver, true);
  assertEquals(plan.content, "다시 말해. 듣고 있어.");
  assertEquals(plan.messages.length, 1);
  assertEquals(plan.messages[0].id, "job-123");
  assertEquals(plan.messages[0].content, "다시 말해. 듣고 있어.");
  assertEquals(plan.messages[0].emotionTag, "calm");
});

Deno.test("immediate reply delivery joins segments into one canonical job message", () => {
  const plan = planImmediateReplyDelivery({
    jobId: "job-456",
    chatData: {
      success: true,
      response: "fallback should not be used",
      segments: [" 첫 번째 ", "", "두 번째"],
    },
  });

  assertEquals(plan.shouldDeliver, true);
  assertEquals(plan.content, "첫 번째\n두 번째");
  assertEquals(plan.segments, ["첫 번째", "두 번째"]);
  assertEquals(plan.messages.length, 1);
  assertEquals(plan.messages[0].id, "job-456");
  assertEquals(plan.messages[0].content, "첫 번째\n두 번째");
});

Deno.test("immediate reply delivery skips scheduled noop superseded failed and empty replies", () => {
  const cases = [
    [{ success: false, response: "x" }, "chat_failed"],
    [
      { success: true, scheduledId: "scheduled-1", response: "x" },
      "scheduled_reply",
    ],
    [{ success: true, scheduledId: "", response: "x" }, "scheduled_reply"],
    [{ success: true, status: "superseded", response: "x" }, "superseded"],
    [
      { success: true, meta: { provider: "noop" }, response: "x" },
      "noop_provider",
    ],
    [{ success: true, response: "   ", segments: [" "] }, "empty_content"],
  ] as const;

  for (const [chatData, reason] of cases) {
    const plan = planImmediateReplyDelivery({ jobId: "job-skip", chatData });
    assertEquals(plan.shouldDeliver, false);
    assertEquals(plan.reason, reason);
    assertEquals(plan.messages, []);
  }
});
