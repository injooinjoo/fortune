/**
 * Fortune cookie messages and daily selection logic.
 *
 * 50 warm, encouraging Korean fortune messages (max 25 chars each).
 * `getDailyFortune()` uses a date-based seed so the same message
 * is returned for the entire calendar day.
 */

export const FORTUNE_MESSAGES: string[] = [
  '작은 용기가 큰 변화를 만듭니다',
  '오늘 만나는 사람이 행운의 열쇠',
  '당신의 직감을 믿어도 괜찮아요',
  '기다리던 소식이 곧 찾아옵니다',
  '지금 이 순간이 가장 좋은 타이밍',
  '예상 밖의 곳에서 기회가 옵니다',
  '마음을 열면 길이 보입니다',
  '오늘의 선택이 내일을 바꿉니다',
  '작은 친절이 큰 행운을 부릅니다',
  '당신은 생각보다 강한 사람이에요',
  '잠시 쉬어가도 괜찮아요',
  '좋은 인연이 가까이 있습니다',
  '포기하지 마세요, 거의 다 왔어요',
  '오늘 웃으면 내일도 웃게 됩니다',
  '당신의 노력은 반드시 빛납니다',
  '새로운 시작을 두려워하지 마세요',
  '감사하는 마음이 행운을 부릅니다',
  '지금 느끼는 감정을 소중히 하세요',
  '뜻밖의 행운이 오후에 찾아옵니다',
  '당신의 미소가 누군가의 하루예요',
  '천천히 가도 괜찮아요, 방향이 맞아요',
  '오늘은 자신에게 너그러워지세요',
  '작은 변화가 큰 흐름을 만듭니다',
  '당신의 이야기는 아직 끝나지 않았어요',
  '지금 하고 있는 일, 잘하고 있어요',
  '좋은 일은 예고 없이 찾아옵니다',
  '오늘의 휴식이 내일의 에너지예요',
  '당신 곁의 사람을 한번 돌아보세요',
  '마음이 이끄는 대로 따라가 보세요',
  '작은 습관이 큰 기적을 만듭니다',
  '오늘 시작하면 내일이 달라져요',
  '당신만의 속도가 있어요, 괜찮아요',
  '우연이라 생각한 것이 필연이에요',
  '지금 이 고민, 곧 해결됩니다',
  '당신에게 필요한 답은 이미 안에 있어요',
  '오늘 하루, 스스로를 칭찬해 주세요',
  '좋은 기운이 당신을 감싸고 있어요',
  '놓친 것보다 얻은 것이 더 많아요',
  '새로운 만남이 문을 열어줄 거예요',
  '지금의 불안은 성장의 신호예요',
  '당신의 따뜻함이 세상을 바꿉니다',
  '오늘 밤, 좋은 꿈을 꾸게 될 거예요',
  '조금만 더 기다려 보세요, 때가 와요',
  '있는 그대로의 당신이 충분해요',
  '오늘의 실수도 내일의 자양분이에요',
  '당신이 빛나는 순간이 다가오고 있어요',
  '작은 도전이 큰 자신감을 줍니다',
  '지금 이 자리에서 행복을 찾아보세요',
  '바람이 당신 편이에요, 힘내세요',
  '내일은 오늘보다 분명히 좋아질 거예요',
];

/**
 * Simple string hash (djb2).
 */
function hashString(s: string): number {
  let h = 5381;
  for (let i = 0; i < s.length; i++) {
    h = ((h << 5) + h + s.charCodeAt(i)) | 0;
  }
  return Math.abs(h);
}

/** Today's date key: "YYYYMMDD" */
function todayKey(): string {
  const now = new Date();
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, '0');
  const d = String(now.getDate()).padStart(2, '0');
  return `${y}${m}${d}`;
}

/**
 * In-memory daily cache. Once a fortune is selected for today,
 * it stays fixed even if the function is called again.
 */
let cachedDate = '';
let cachedMessage = '';

/**
 * Returns a deterministic fortune message for today.
 *
 * - Same user + same day = same message (cached in memory)
 * - Optional `userId` makes each user get a different message on the same day
 * - Without userId, all users share the same daily fortune
 */
export function getDailyFortune(userId?: string): string {
  const dateKey = todayKey();

  if (cachedDate === dateKey && cachedMessage) {
    return cachedMessage;
  }

  const seed = userId ? `${dateKey}:${userId}` : dateKey;
  const index = hashString(seed) % FORTUNE_MESSAGES.length;

  cachedDate = dateKey;
  cachedMessage = FORTUNE_MESSAGES[index]!;

  return cachedMessage;
}
