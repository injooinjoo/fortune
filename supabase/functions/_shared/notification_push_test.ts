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
