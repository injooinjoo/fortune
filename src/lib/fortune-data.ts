
export const FORTUNE_TYPES = [
  "사주팔자", // Saju Palja (Four Pillars of Destiny)
  "MBTI 운세", // MBTI Fortune
  "띠운세", // Zodiac Animal Fortune (Chinese Zodiac)
  "별자리운세", // Constellation Fortune (Western Astrology)
  "연애운", // Love Fortune
  "결혼운", // Marriage Fortune
  "취업운", // Career/Job Fortune
  "오늘의 총운", // Today's General Fortune
  "금전운" // Wealth Fortune
] as const;

export type FortuneType = typeof FORTUNE_TYPES[number];

export const MBTI_TYPES = [
  "ISTJ", "ISFJ", "INFJ", "INTJ",
  "ISTP", "ISFP", "INFP", "INTP",
  "ESTP", "ESFP", "ENFP", "ENTP",
  "ESTJ", "ESFJ", "ENFJ", "ENTJ"
] as const;

export type MbtiType = typeof MBTI_TYPES[number];

export const GENDERS = [
  { value: "여성", label: "여성" },
  { value: "남성", label: "남성" },
  { value: "선택 안함", label: "선택 안함" },
] as const;

export type GenderValue = typeof GENDERS[number]['value'];

export const BIRTH_TIMES = [
  { value: "모름", label: "모름" },
  { value: "자시 (23:30 ~ 01:29)", label: "자시 (23:30 ~ 01:29)" },
  { value: "축시 (01:30 ~ 03:29)", label: "축시 (01:30 ~ 03:29)" },
  { value: "인시 (03:30 ~ 05:29)", label: "인시 (03:30 ~ 05:29)" },
  { value: "묘시 (05:30 ~ 07:29)", label: "묘시 (05:30 ~ 07:29)" },
  { value: "진시 (07:30 ~ 09:29)", label: "진시 (07:30 ~ 09:29)" },
  { value: "사시 (09:30 ~ 11:29)", label: "사시 (09:30 ~ 11:29)" },
  { value: "오시 (11:30 ~ 13:29)", label: "오시 (11:30 ~ 13:29)" },
  { value: "미시 (13:30 ~ 15:29)", label: "미시 (13:30 ~ 15:29)" },
  { value: "신시 (15:30 ~ 17:29)", label: "신시 (15:30 ~ 17:29)" },
  { value: "유시 (17:30 ~ 19:29)", label: "유시 (17:30 ~ 19:29)" },
  { value: "술시 (19:30 ~ 21:29)", label: "술시 (19:30 ~ 21:29)" },
  { value: "해시 (21:30 ~ 23:29)", label: "해시 (21:30 ~ 23:29)" },
] as const;

export type BirthTimeValue = typeof BIRTH_TIMES[number]['value'];
