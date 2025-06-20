import { type ClassValue, clsx } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

// 12시진(時辰) 시스템
export const TIME_PERIODS = [
  { value: "자시", label: "자시 (子時)", time: "23:00-01:00", description: "밤 11시 ~ 새벽 1시" },
  { value: "축시", label: "축시 (丑時)", time: "01:00-03:00", description: "새벽 1시 ~ 새벽 3시" },
  { value: "인시", label: "인시 (寅時)", time: "03:00-05:00", description: "새벽 3시 ~ 새벽 5시" },
  { value: "묘시", label: "묘시 (卯時)", time: "05:00-07:00", description: "새벽 5시 ~ 오전 7시" },
  { value: "진시", label: "진시 (辰時)", time: "07:00-09:00", description: "오전 7시 ~ 오전 9시" },
  { value: "사시", label: "사시 (巳時)", time: "09:00-11:00", description: "오전 9시 ~ 오전 11시" },
  { value: "오시", label: "오시 (午時)", time: "11:00-13:00", description: "오전 11시 ~ 오후 1시" },
  { value: "미시", label: "미시 (未時)", time: "13:00-15:00", description: "오후 1시 ~ 오후 3시" },
  { value: "신시", label: "신시 (申時)", time: "15:00-17:00", description: "오후 3시 ~ 오후 5시" },
  { value: "유시", label: "유시 (酉時)", time: "17:00-19:00", description: "오후 5시 ~ 오후 7시" },
  { value: "술시", label: "술시 (戌時)", time: "19:00-21:00", description: "오후 7시 ~ 오후 9시" },
  { value: "해시", label: "해시 (亥時)", time: "21:00-23:00", description: "오후 9시 ~ 오후 11시" },
] as const;

// 현재 시간을 기준으로 해당하는 시진 찾기
export function getCurrentTimePeriod(): string {
  const now = new Date();
  const hour = now.getHours();
  
  if (hour >= 23 || hour < 1) return "자시";
  if (hour >= 1 && hour < 3) return "축시";
  if (hour >= 3 && hour < 5) return "인시";
  if (hour >= 5 && hour < 7) return "묘시";
  if (hour >= 7 && hour < 9) return "진시";
  if (hour >= 9 && hour < 11) return "사시";
  if (hour >= 11 && hour < 13) return "오시";
  if (hour >= 13 && hour < 15) return "미시";
  if (hour >= 15 && hour < 17) return "신시";
  if (hour >= 17 && hour < 19) return "유시";
  if (hour >= 19 && hour < 21) return "술시";
  if (hour >= 21 && hour < 23) return "해시";
  
  return "자시"; // 기본값
}

// 시간을 시진으로 변환
export function timeToTimePeriod(timeString: string): string {
  if (!timeString) return "";
  
  const [hour] = timeString.split(':').map(Number);
  
  if (hour >= 23 || hour < 1) return "자시";
  if (hour >= 1 && hour < 3) return "축시";
  if (hour >= 3 && hour < 5) return "인시";
  if (hour >= 5 && hour < 7) return "묘시";
  if (hour >= 7 && hour < 9) return "진시";
  if (hour >= 9 && hour < 11) return "사시";
  if (hour >= 11 && hour < 13) return "오시";
  if (hour >= 13 && hour < 15) return "미시";
  if (hour >= 15 && hour < 17) return "신시";
  if (hour >= 17 && hour < 19) return "유시";
  if (hour >= 19 && hour < 21) return "술시";
  if (hour >= 21 && hour < 23) return "해시";
  
  return "자시";
}

// 년도 옵션 생성 (1900-현재년도)
export function getYearOptions(): number[] {
  const currentYear = new Date().getFullYear();
  return Array.from({ length: currentYear - 1899 }, (_, i) => currentYear - i);
}

// 월 옵션 생성 (1-12)
export function getMonthOptions(): number[] {
  return Array.from({ length: 12 }, (_, i) => i + 1);
}

// 일 옵션 생성 (해당 년월에 맞는 일수)
export function getDayOptions(year?: number, month?: number): number[] {
  if (!year || !month) {
    return Array.from({ length: 31 }, (_, i) => i + 1);
  }
  
  const daysInMonth = new Date(year, month, 0).getDate();
  return Array.from({ length: daysInMonth }, (_, i) => i + 1);
}

// 날짜 포맷팅 (0000년 00월 00일)
export function formatKoreanDate(year: string | number, month: string | number, day: string | number): string {
  if (!year || !month || !day) return "";
  return `${String(year).padStart(4, '0')}년 ${String(month).padStart(2, '0')}월 ${String(day).padStart(2, '0')}일`;
}

// ISO 날짜를 한국식으로 변환
export function isoToKoreanDate(isoDate: string): string {
  if (!isoDate) return "";
  const date = new Date(isoDate);
  return formatKoreanDate(date.getFullYear(), date.getMonth() + 1, date.getDate());
}

// 한국식 날짜를 ISO 형식으로 변환
export function koreanToIsoDate(year: string | number, month: string | number, day: string | number): string {
  if (!year || !month || !day) return "";
  const yearStr = String(year);
  const monthStr = String(month).padStart(2, '0');
  const dayStr = String(day).padStart(2, '0');
  return `${yearStr}-${monthStr}-${dayStr}`;
}
