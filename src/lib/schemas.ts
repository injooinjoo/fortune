import { z } from "zod";
import { FORTUNE_TYPES } from "./fortune-data";

const mbtiRegex = /^[EI][NS][TF][JP]$/i;

export const FortuneFormSchema = z.object({
  birthdate: z.date({
    required_error: "생년월일을 선택해주세요.",
    invalid_type_error: "올바른 날짜 형식이 아닙니다.",
  }),
  mbti: z.string()
    .min(4, "MBTI는 4글자여야 합니다.")
    .max(4, "MBTI는 4글자여야 합니다.")
    .regex(mbtiRegex, "올바른 MBTI 형식이 아닙니다. (예: INFJ)"),
  fortuneTypes: z.array(z.enum(FORTUNE_TYPES))
    .min(1, "하나 이상의 운세 종류를 선택해주세요."),
});

export type FortuneFormValues = z.infer<typeof FortuneFormSchema>;
