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
