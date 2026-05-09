import {
  buildScheduledReplyMessages,
  normalizeScheduledSegments,
} from "./scheduled_reply_message.ts";

Deno.test("buildScheduledReplyMessages uses a stable single-message id", () => {
  const messages = buildScheduledReplyMessages({
    scheduledId: "abc",
    content: "응, 나중에 답할게.",
    segments: [],
    emotionTag: "일상",
    timestamp: "2026-05-09T00:00:00.000Z",
  });

  if (messages.length !== 1) {
    throw new Error(`expected 1 message, got ${messages.length}`);
  }
  if (messages[0].id !== "scheduled-abc") {
    throw new Error(`unexpected id: ${messages[0].id}`);
  }
  if (messages[0].emotionTag !== "일상") {
    throw new Error("emotionTag was not preserved");
  }
});

Deno.test("buildScheduledReplyMessages uses deterministic segment ids", () => {
  const messages = buildScheduledReplyMessages({
    scheduledId: "abc",
    content: "fallback",
    segments: ["첫 번째", "두 번째"],
    timestamp: "2026-05-09T00:00:00.000Z",
  });

  const ids = messages.map((message) => message.id).join(",");
  if (ids !== "scheduled-abc-0,scheduled-abc-1") {
    throw new Error(`unexpected ids: ${ids}`);
  }
});

Deno.test("normalizeScheduledSegments falls back to content", () => {
  const segments = normalizeScheduledSegments({
    content: "  본문 답장  ",
    segments: [" ", ""],
  });

  if (segments.length !== 1 || segments[0] !== "본문 답장") {
    throw new Error(`unexpected fallback segments: ${segments.join(",")}`);
  }
});
