import { assertEquals } from "https://deno.land/std@0.168.0/testing/asserts.ts";
import {
  buildCharacterDmPayload,
  getCharacterNotificationPreferenceColumn,
} from "./notification_push.ts";

Deno.test("character proactive push uses separate proactive notification preference", () => {
  assertEquals(getCharacterNotificationPreferenceColumn(), "character_dm");
  assertEquals(
    getCharacterNotificationPreferenceColumn("character_dm"),
    "character_dm",
  );
  assertEquals(
    getCharacterNotificationPreferenceColumn("character_proactive"),
    "character_proactive",
  );
  assertEquals(
    getCharacterNotificationPreferenceColumn("character_follow_up"),
    "character_proactive",
  );
});

Deno.test("proactive push payload carries pendingProactiveMessageId in snake and camel case", () => {
  const payload = buildCharacterDmPayload({
    characterId: "luts",
    characterName: "이서준",
    messageText: "나 지금 뭐 먹게.",
    messageId: "msg-1",
    type: "character_proactive",
    pendingProactiveMessageId: "log-1",
  });

  assertEquals(payload.type, "character_proactive");
  assertEquals(payload.channel, "character_dm");
  assertEquals(payload.character_id, "luts");
  assertEquals(payload.characterId, "luts");
  assertEquals(payload.pending_proactive_message_id, "log-1");
  assertEquals(payload.pendingProactiveMessageId, "log-1");
  assertEquals(payload.route, "/chat?characterId=luts");
});

Deno.test("image proactive push keeps human notification body and carries image metadata", () => {
  const payload = buildCharacterDmPayload({
    characterId: "luts",
    characterName: "luts",
    messageText: "사진 보냈어 — 너무먹었어",
    messageId: "img-1",
    type: "character_proactive",
    imageUrl: "https://example.com/photo.webp",
    caption: "너무먹었어",
  });

  assertEquals(payload.body, "사진 보냈어 — 너무먹었어");
  assertEquals(payload.kind, "image");
  assertEquals(payload.image_url, "https://example.com/photo.webp");
  assertEquals(payload.imageUrl, "https://example.com/photo.webp");
  assertEquals(payload.caption, "너무먹었어");
});
