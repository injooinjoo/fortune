
"use server";

import {
  generateFortuneInsights,
  type GenerateFortuneInsightsInput,
  type GenerateFortuneInsightsOutput as AIOutputType,
  type SajuDataType,
} from "@/ai/flows/generate-fortune-insights";
import {
  generateFaceReadingInsights,
  type FaceReadingInput,
  type FaceReadingOutput,
} from "@/ai/flows/generate-face-reading-insights";
import type { FortuneFormValues } from "@/lib/schemas";
import { format } from "date-fns";

// This is the structure expected by the Page component
export interface FormattedFortuneOutput {
  insights: Record<string, string>;
  sajuData?: SajuDataType; // Added SajuDataType
}

export interface FaceReadingResult {
  interpretation: string;
}

export interface ActionResult {
  data?: FormattedFortuneOutput;
  error?: string;
  input?: GenerateFortuneInsightsInput;
}

export interface FaceReadingActionResult {
  data?: FaceReadingResult;
  error?: string;
  input?: FaceReadingInput;
}

export async function getFortuneAction(
  values: FortuneFormValues
): Promise<ActionResult> {
  try {
    const birthdateString = format(values.birthdate, "yyyy-MM-dd");

    const aiInput: GenerateFortuneInsightsInput = {
      birthdate: birthdateString,
      mbti: values.mbti.toUpperCase(),
      gender: values.gender,
      birthTime: values.birthTime,
      fortuneTypes: values.fortuneTypes,
    };

    const result: AIOutputType = await generateFortuneInsights(aiInput);
    
    if (!result || !result.insights) {
      return { error: "운세 결과를 생성하는데 실패했습니다. AI로부터 유효한 응답을 받지 못했습니다." };
    }

    const remappedInsights: Record<string, string> = {};
    for (const item of result.insights) {
      remappedInsights[item.fortuneType] = item.insightText;
    }
    
    const validatedInsights: Record<string, string> = {};
    for (const type of values.fortuneTypes) {
      if (remappedInsights[type]) {
        validatedInsights[type] = remappedInsights[type];
      } else {
        console.warn(`Insight not found or missing for type: ${type}. Original AI output (array):`, result.insights);
        validatedInsights[type] = "현재 이 운세 종류에 대한 정보를 가져올 수 없습니다.";
      }
    }
    
    const responseData: FormattedFortuneOutput = { insights: validatedInsights };
    if (result.sajuData) {
      responseData.sajuData = result.sajuData;
    }
    
    return { data: responseData, input: aiInput };

  } catch (e) {
    console.error("Error generating fortune:", e);
    const errorMessage = e instanceof Error ? e.message : "알 수 없는 오류가 발생했습니다.";
    return { error: `운세 생성 중 오류가 발생했습니다: ${errorMessage}` };
  }
}

export async function getFaceReadingAction(
  labels: string[]
): Promise<FaceReadingActionResult> {
  try {
    const input: FaceReadingInput = { labels };
    const result: FaceReadingOutput = await generateFaceReadingInsights(input);
    return { data: result, input };
  } catch (e) {
    console.error('Error generating face reading:', e);
    const message = e instanceof Error ? e.message : '알 수 없는 오류가 발생했습니다.';
    return { error: message };
  }
}
