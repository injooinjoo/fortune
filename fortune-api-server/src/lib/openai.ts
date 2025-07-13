import OpenAI from 'openai';
import logger from '../utils/logger';

// OpenAI client with improved error handling
export class OpenAIService {
  private client: OpenAI;
  private maxRetries = 3;
  private retryDelay = 1000; // 1 second

  constructor() {
    const apiKey = process.env.OPENAI_API_KEY;
    if (!apiKey) {
      throw new Error('OPENAI_API_KEY is not set in environment variables');
    }

    this.client = new OpenAI({
      apiKey,
      maxRetries: 0, // We'll handle retries manually
    });
  }

  /**
   * Test API connection
   */
  async testConnection(): Promise<{ success: boolean; message: string }> {
    try {
      const response = await this.client.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [{ role: 'user', content: 'Hello' }],
        max_tokens: 5,
      });

      if (response.choices && response.choices.length > 0) {
        return { success: true, message: 'OpenAI API connection successful' };
      } else {
        return { success: false, message: 'OpenAI API returned empty response' };
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      return { success: false, message: `OpenAI API connection failed: ${errorMessage}` };
    }
  }

  /**
   * Generate fortune with retry logic and encoding fix
   */
  async generateFortune({
    prompt,
    model = 'gpt-3.5-turbo',
    maxTokens = 1500,
    temperature = 0.7,
    requireJson = true,
  }: {
    prompt: string;
    model?: string;
    maxTokens?: number;
    temperature?: number;
    requireJson?: boolean;
  }): Promise<{
    content: string;
    parsed?: any;
    tokenUsage: number;
    model: string;
  }> {
    let lastError: Error | null = null;

    for (let attempt = 1; attempt <= this.maxRetries; attempt++) {
      try {
        // Fix Korean encoding issues
        const encodedPrompt = this.fixKoreanEncoding(prompt);

        const messages: OpenAI.Chat.Completions.ChatCompletionMessageParam[] = [
          {
            role: 'system',
            content: '당신은 한국 전통 운세 전문가입니다. 정확하고 실용적인 운세 분석을 제공합니다.',
          },
          {
            role: 'user',
            content: encodedPrompt,
          },
        ];

        const requestOptions: OpenAI.Chat.Completions.ChatCompletionCreateParams = {
          model,
          messages,
          temperature,
          max_tokens: maxTokens,
        };

        // Add JSON format requirement if needed
        if (requireJson) {
          requestOptions.response_format = { type: 'json_object' };
          // Ensure system message mentions JSON
          messages[0].content += ' JSON 형식으로만 응답하세요.';
        }

        const completion = await this.client.chat.completions.create(requestOptions);

        const content = completion.choices[0]?.message?.content;
        if (!content) {
          throw new Error('Empty response from OpenAI');
        }

        const tokenUsage = completion.usage?.total_tokens || 0;
        let parsed = undefined;

        // Try to parse JSON if required
        if (requireJson) {
          try {
            parsed = JSON.parse(content);
          } catch (parseError) {
            logger.warn('Failed to parse JSON response:', parseError);
            // Don't throw error, return raw content
          }
        }

        return {
          content: this.fixKoreanEncoding(content),
          parsed,
          tokenUsage,
          model,
        };
      } catch (error) {
        lastError = error as Error;
        logger.error(`OpenAI attempt ${attempt}/${this.maxRetries} failed:`, error);

        // Don't retry on certain errors
        if (this.isNonRetryableError(error)) {
          break;
        }

        // Wait before retrying
        if (attempt < this.maxRetries) {
          await this.delay(this.retryDelay * attempt);
        }
      }
    }

    // All retries failed
    if (lastError) {
      logger.error('OpenAI API failed after all retries:', {
        prompt: prompt.substring(0, 200) + '...',
        model,
        attempts: this.maxRetries,
        error: lastError?.message,
      });

      throw new Error(`OpenAI API failed after ${this.maxRetries} attempts: ${lastError.message}`);
    }

    throw new Error('OpenAI API failed for unknown reason');
  }

  /**
   * Fix Korean encoding issues
   */
  private fixKoreanEncoding(text: string): string {
    try {
      // Remove null bytes and other problematic characters
      return text
        .replace(/\0/g, '') // Remove null bytes
        .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '') // Remove control characters
        .trim();
    } catch (error) {
      logger.warn('Encoding fix failed:', error);
      return text;
    }
  }

  /**
   * Check if error should not be retried
   */
  private isNonRetryableError(error: any): boolean {
    const errorMessage = error?.message?.toLowerCase() || '';

    // Don't retry on authentication errors
    if (errorMessage.includes('unauthorized') || errorMessage.includes('invalid api key')) {
      return true;
    }

    // Don't retry on quota exceeded errors
    if (errorMessage.includes('quota') || errorMessage.includes('billing')) {
      return true;
    }

    // Don't retry on invalid request format
    if (errorMessage.includes('invalid_request_error')) {
      return true;
    }

    return false;
  }

  /**
   * Delay helper for retries
   */
  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  /**
   * Generate batch fortunes efficiently
   */
  async generateBatchFortunes({
    userId,
    userProfile,
    fortuneTypes,
    targetDate,
  }: {
    userId: string;
    userProfile: {
      name: string;
      birthDate: string;
      gender?: string;
      mbti?: string;
    };
    fortuneTypes: string[];
    targetDate?: string;
  }): Promise<{
    results: Record<string, any>;
    tokenUsage: number;
  }> {
    const date = targetDate || new Date().toISOString().split('T')[0];

    const prompt = `
사용자 정보:
- 이름: ${userProfile.name}
- 생년월일: ${userProfile.birthDate}
- 성별: ${userProfile.gender || '미지정'}
- MBTI: ${userProfile.mbti || '미지정'}
- 운세 날짜: ${date}

요청된 운세 종류: ${fortuneTypes.join(', ')}

각 운세에 대해 다음 JSON 형식으로 응답해주세요:
{
  "${fortuneTypes[0]}": {
    "overall_score": 85,
    "summary": "오늘의 전체적인 운세 요약",
    "advice": "구체적인 조언",
    "lucky_color": "행운의 색깔",
    "lucky_number": 7,
    "detailed_analysis": "상세한 분석 내용"
  },
  // 다른 운세들도 같은 형식으로...
}

점수는 0-100 사이의 정수로, 내용은 구체적이고 실용적으로 작성해주세요.
`;

    try {
      const result = await this.generateFortune({
        prompt,
        requireJson: true,
        maxTokens: 2000,
      });

      return {
        results: result.parsed || {},
        tokenUsage: result.tokenUsage,
      };
    } catch (error) {
      logger.error('Batch fortune generation failed:', error);

      // Return fallback results
      const fallbackResults: Record<string, any> = {};
      fortuneTypes.forEach((type) => {
        fallbackResults[type] = {
          overall_score: 75,
          summary: `${userProfile.name}님의 ${type} 운세가 준비되었습니다.`,
          advice: '긍정적인 마음가짐으로 하루를 시작하세요.',
          lucky_color: '파란색',
          lucky_number: 7,
          detailed_analysis: '더 정확한 분석을 위해 잠시 후 다시 시도해보세요.',
        };
      });

      return {
        results: fallbackResults,
        tokenUsage: 0,
      };
    }
  }
}

// Singleton instance
let openaiService: OpenAIService | null = null;

export function getOpenAIService(): OpenAIService {
  if (!openaiService) {
    openaiService = new OpenAIService();
  }
  return openaiService;
}

// Export for testing
export { OpenAIService as OpenAIClient };