import { z } from "zod";
import { FORTUNE_TYPES, GENDERS, BIRTH_TIMES } from "./fortune-data";

const mbtiRegex = /^[EI][NS][TF][JP]$/i;

// Helper to create a Zod enum from the GENDERS constant
const genderValues = GENDERS.map(g => g.value) as [string, ...string[]];
// Helper to create a Zod enum from the BIRTH_TIMES constant for validation if needed,
// but for flexibility we'll use z.string() and let the Select component manage the options.
// const birthTimeValues = BIRTH_TIMES.map(bt => bt.value) as [string, ...string[]];


export const FortuneFormSchema = z.object({
  birthdate: z.date({
    required_error: "생년월일을 선택해주세요.",
    invalid_type_error: "올바른 날짜 형식이 아닙니다.",
  }),
  mbti: z.string()
    .min(4, "MBTI는 4글자여야 합니다.")
    .max(4, "MBTI는 4글자여야 합니다.")
    .regex(mbtiRegex, "올바른 MBTI 형식이 아닙니다. (예: INFJ)"),
  gender: z.enum(genderValues, {
    required_error: "성별을 선택해주세요.",
  }),
  birthTime: z.string({
    required_error: "태어난 시를 선택해주세요.",
  }), // Can be one of BIRTH_TIMES values
  fortuneTypes: z.array(z.enum(FORTUNE_TYPES))
    .min(1, "하나 이상의 운세 종류를 선택해주세요."),
});

export type FortuneFormValues = z.infer<typeof FortuneFormSchema>;
