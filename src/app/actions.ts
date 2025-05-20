"use server";

import { generateFortuneInsights, type GenerateFortuneInsightsInput, type GenerateFortuneInsightsOutput } from "@/ai/flows/generate-fortune-insights";
import type { FortuneFormValues } from "@/lib/schemas";
import { format } from "date-fns";

export interface ActionResult {
  data?: GenerateFortuneInsightsOutput;
  error?: string;
  input?: GenerateFortuneInsightsInput;
}

export async function getFortuneAction(
  values: FortuneFormValues
): Promise<ActionResult> {
  try {
    const birthdateString = format(values.birthdate, "yyyy-MM-dd");

    const aiInput: GenerateFortuneInsightsInput = {
      birthdate: birthdateString,
      mbti: values.mbti.toUpperCase(),
      fortuneTypes: values.fortuneTypes,
    };

    const result = await generateFortuneInsights(aiInput);
    
    if (!result || !result.insights) {
      return { error: "운세 결과를 생성하는데 실패했습니다. 다시 시도해주세요." };
    }

    // Ensure all requested types have some insight, even if it's a default message
    const validatedInsights: Record<string, string> = {};
    let allInsightsPresent = true;
    for (const type of values.fortuneTypes) {
      if (result.insights[type]) {
        validatedInsights[type] = result.insights[type];
      } else {
        // AI might not return a key if it can't generate insight for it. Add a placeholder.
        validatedInsights[type] = "현재 이 운세 종류에 대한 정보를 가져올 수 없습니다.";
        allInsightsPresent = false;
      }
    }
    
    return { data: { insights: validatedInsights }, input: aiInput };

  } catch (e) {
    console.error("Error generating fortune:", e);
    const errorMessage = e instanceof Error ? e.message : "알 수 없는 오류가 발생했습니다.";
    return { error: `운세 생성 중 오류가 발생했습니다: ${errorMessage}` };
  }
}
