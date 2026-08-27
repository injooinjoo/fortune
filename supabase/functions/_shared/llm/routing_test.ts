import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { resolvePlatformLlmRoute } from "./routing.ts";

Deno.test("legacy keeps the configured provider", () => {
  assertEquals(resolvePlatformLlmRoute({ featureName: "daily", requestedProvider: "gemini", requestedModel: "gemini-2.0-flash-lite", mode: "legacy", hasOpenRouterKey: true }), {
    provider: "gemini",
    model: "gemini-2.0-flash-lite",
    reason: "legacy",
  });
});

Deno.test("openrouter uses purpose aliases only with a platform key", () => {
  assertEquals(resolvePlatformLlmRoute({ featureName: "fortune-face-reading", requestedProvider: "gemini", requestedModel: "gemini-2.0-flash-lite", mode: "openrouter", hasOpenRouterKey: true }).model, "google/gemini-2.5-flash");
  assertEquals(resolvePlatformLlmRoute({ featureName: "chat-insight", requestedProvider: "gemini", requestedModel: "gemini-2.0-flash-lite", mode: "openrouter", hasOpenRouterKey: true }).model, "openai/gpt-4o-mini");
});

Deno.test("missing workspace key fails closed to the requested legacy route", () => {
  const route = resolvePlatformLlmRoute({ featureName: "daily", requestedProvider: "openrouter", requestedModel: "google/gemini-2.5-flash-lite", mode: "openrouter", hasOpenRouterKey: false });
  assertEquals(route.provider, "gemini");
  assertEquals(route.reason, "openrouter-key-missing");
});

Deno.test("shadow observes the candidate without changing the live provider", () => {
  const route = resolvePlatformLlmRoute({ featureName: "daily", requestedProvider: "gemini", requestedModel: "gemini-2.0-flash-lite", mode: "shadow", hasOpenRouterKey: true });
  assertEquals(route.provider, "gemini");
  assertEquals(route.shadowModel, "google/gemini-2.5-flash-lite");
});
