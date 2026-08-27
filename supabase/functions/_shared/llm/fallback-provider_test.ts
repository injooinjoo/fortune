import { assertEquals } from "https://deno.land/std@0.224.0/assert/mod.ts";
import { BoundedFallbackProvider } from "./fallback-provider.ts";
import type { ILLMProvider, LLMResponse } from "./types.ts";

function response(provider: string): LLMResponse {
  return { content: provider, finishReason: "stop", usage: { promptTokens: 0, completionTokens: 0, totalTokens: 0 }, latency: 0, provider, model: provider };
}

Deno.test("bounded fallback calls each route at most once", async () => {
  let primaryCalls = 0;
  let fallbackCalls = 0;
  const primary: ILLMProvider = {
    async generate() { primaryCalls += 1; throw new Error("upstream"); },
    validateConfig: () => true,
    getModelInfo: () => ({ provider: "openrouter", model: "primary", capabilities: ["text"] }),
  };
  const fallback: ILLMProvider = {
    async generate() { fallbackCalls += 1; return response("gemini"); },
    validateConfig: () => true,
    getModelInfo: () => ({ provider: "gemini", model: "fallback", capabilities: ["text"] }),
  };
  const result = await new BoundedFallbackProvider(primary, fallback, "daily").generate([]);
  assertEquals(result.provider, "gemini");
  assertEquals({ primaryCalls, fallbackCalls }, { primaryCalls: 1, fallbackCalls: 1 });
});
