import { z } from "zod";
import { FORTUNE_TYPES, GENDERS, BIRTH_TIMES, MBTI_TYPES } from "./fortune-data";
import { 
  LifeProfileResultSchema, 
  DailyFortuneResultSchema, 
  InteractiveFortuneOutputSchema 
} from "@/ai/flows/generate-specialized-fortune";

const mbtiRegex = /^[EI][NS][TF][JP]$/i;

const genderValues = GENDERS.map(g => g.value) as [string, ...string[]];

export const ProfileFormSchema = z.object({
  name: z.string()
    .min(1, "이름을 입력해주세요.")
    .max(6, "이름은 1~6자 한글만 가능합니다.")
    .regex(/^[가-힣]{1,6}$/, "이름은 1~6자 한글로 입력해주세요."),
  birthdate: z.date({
    required_error: "생년월일을 선택해주세요.",
    invalid_type_error: "올바른 날짜 형식이 아닙니다.",
  }),
  mbti: z.string()
    .refine(value => value === "모름" || mbtiRegex.test(value), {
      message: "올바른 MBTI 형식이 아니거나 '모름'을 선택해야 합니다. (예: INFJ 또는 모름)",
    })
    .default("모름"),
  gender: z.enum(genderValues, {
    required_error: "성별을 선택해주세요.",
  }),
  birthTime: z.string({
    required_error: "태어난 시를 선택해주세요.",
  }),
});

export type ProfileFormValues = z.infer<typeof ProfileFormSchema>;


// 이 스키마는 실제 운세 요청 시 사용될 수 있습니다. (향후 다른 페이지에서 사용)
export const FortuneRequestSchema = z.object({
  name: z.string().min(1).max(6).regex(/^[가-힣]{1,6}$/),
  birthdate: z.date(),
  mbti: z.string().refine(value => value === "모름" || mbtiRegex.test(value)),
  gender: z.enum(genderValues),
  birthTime: z.string(),
  fortuneTypes: z.array(z.enum(FORTUNE_TYPES))
    .min(1, "하나 이상의 운세 종류를 선택해주세요."),
});
export type FortuneRequestFormValues = z.infer<typeof FortuneRequestSchema>;

// 데일리 운세 저장을 위한 스키마
export const DailyFortuneSchema = z.object({
  id: z.string().optional(),
  user_id: z.string(),
  fortune_type: z.string(), // 운세 타입 (e.g., life-profile, daily-comprehensive, tarot)
  fortune_data: z.union([
    LifeProfileResultSchema, 
    DailyFortuneResultSchema, 
    InteractiveFortuneOutputSchema
  ]), // AI 플로우의 결과 데이터를 저장
  created_date: z.string(), // YYYY-MM-DD 형식
  created_at: z.string().optional(),
  updated_at: z.string().optional()
});

export type DailyFortuneData = z.infer<typeof DailyFortuneSchema>;
