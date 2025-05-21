import { z } from "zod";
import { FORTUNE_TYPES, GENDERS, BIRTH_TIMES, MBTI_TYPES } from "./fortune-data";

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
  // fortuneTypes는 프로필 설정 단계에서는 제거합니다.
});

export type ProfileFormValues = z.infer<typeof ProfileFormSchema>;


// 이 스키마는 실제 운세 요청 시 사용될 수 있습니다. (향후 다른 페이지에서 사용)
export const FortuneRequestSchema = z.object({
  // 여기에 name, birthdate 등 프로필 정보가 포함될 수 있고,
  // 사용자가 선택한 운세 종류만 받을 수도 있습니다.
  // 지금은 ProfileFormSchema의 필드를 그대로 가져오고 fortuneTypes만 추가합니다.
  name: z.string().min(1).max(6).regex(/^[가-힣]{1,6}$/),
  birthdate: z.date(),
  mbti: z.string().refine(value => value === "모름" || mbtiRegex.test(value)),
  gender: z.enum(genderValues),
  birthTime: z.string(),
  fortuneTypes: z.array(z.enum(FORTUNE_TYPES))
    .min(1, "하나 이상의 운세 종류를 선택해주세요."),
});
export type FortuneRequestFormValues = z.infer<typeof FortuneRequestSchema>;
