import type {
  GenerateOptions,
  ILLMProvider,
  LLMMessage,
  LLMResponse,
} from "./types.ts";

export class BoundedFallbackProvider implements ILLMProvider {
  constructor(
    private primary: ILLMProvider,
    private fallback: ILLMProvider,
    private featureName: string,
  ) {}

  async generate(messages: LLMMessage[], options?: GenerateOptions): Promise<LLMResponse> {
    try {
      const response = await this.primary.generate(messages, options);
      if (response.content.trim().length > 0) return response;
      throw new Error("empty primary response");
    } catch {
      console.warn(`[llm-router] bounded fallback used: ${this.featureName}`);
      return await this.fallback.generate(messages, options);
    }
  }

  validateConfig(): boolean {
    return this.primary.validateConfig() && this.fallback.validateConfig();
  }

  getModelInfo() {
    const primary = this.primary.getModelInfo();
    const fallback = this.fallback.getModelInfo();
    return {
      provider: `${primary.provider}->${fallback.provider}`,
      model: `${primary.model}->${fallback.model}`,
      capabilities: Array.from(new Set([...primary.capabilities, ...fallback.capabilities])),
    };
  }
}
