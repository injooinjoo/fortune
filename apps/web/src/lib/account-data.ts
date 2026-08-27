type AccountIdentity = {
  email?: string | null;
  user_metadata?: Record<string, unknown> | null;
};

type BalanceRow = { balance?: unknown } | null;

type FortuneHistoryRow = {
  id: string;
  fortune_type: string;
  title: string | null;
  score: number | null;
  created_at: string;
};

export type AccountFortuneHistory = {
  id: string;
  fortuneType: string;
  title: string;
  score: number | null;
  createdAt: string;
};

export function displayAccountName(identity: AccountIdentity): string {
  const metadata = identity.user_metadata ?? {};
  for (const key of ['full_name', 'name']) {
    const value = metadata[key];
    if (typeof value === 'string' && value.trim()) return `${value.trim()}님`;
  }
  return '내 계정';
}

export function normalizeBalance(row: BalanceRow): number {
  const balance = row?.balance;
  return typeof balance === 'number' && Number.isFinite(balance) && balance >= 0
    ? Math.floor(balance)
    : 0;
}

export function normalizeFortuneHistory(rows: FortuneHistoryRow[] | null): AccountFortuneHistory[] {
  return [...(rows ?? [])]
    .sort((left, right) => Date.parse(right.created_at) - Date.parse(left.created_at))
    .map((row) => ({
      id: row.id,
      fortuneType: row.fortune_type,
      title: row.title?.trim() || '운세 결과',
      score: typeof row.score === 'number' ? row.score : null,
      createdAt: row.created_at,
    }));
}

export function formatKoreanDateTime(value: string): string {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '날짜 정보 없음';
  return new Intl.DateTimeFormat('ko-KR', {
    dateStyle: 'medium',
    timeStyle: 'short',
    timeZone: 'Asia/Seoul',
  }).format(date);
}
