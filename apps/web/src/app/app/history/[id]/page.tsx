import type { Metadata } from 'next';
import { AppLink as Link } from '@/components/app-link';
import { notFound, redirect } from 'next/navigation';

import { FortuneHistoryView } from '@/features/fortune/history-view';
import { formatKoreanDateTime } from '@/lib/account-data';
import type { FortuneSummaryHighlight } from '@/lib/fortune-context';
import { readFortuneSnapshot } from '@/lib/fortune-snapshot';
import { createSupabaseServerClient } from '@/lib/supabase/server';

/**
 * 저장된 운세 하나를 다시 본다.
 *
 * 이게 없어서 온도를 내고 본 결과가 화면을 벗어나는 순간 사라졌다. 기록은
 * `/app` 에 남는데 열 수가 없었고, 잔액이 0 이면 다시 뽑을 수도 없다.
 *
 * 경로가 ASCII 인 이유는 취향이 아니라 라우팅이다. 처음에는 다른 운세 화면을
 * 따라 `/운세/기록/<id>` 로 뒀는데 프로덕션에서 `x-matched-path: /404` 가 났다.
 * Next 는 요청으로 들어온 퍼센트 인코딩 경로를 디코딩해서 앱 라우터 세그먼트에
 * 맞추지 않는다(vercel/next.js#62292). 지금 동작하는 한글 경로는 전부
 * `generateStaticParams` 로 미리 만들어져 출력 맵에 그대로 들어간 것들인데,
 * 사용자마다 id 가 다른 이 페이지는 미리 만들 수 없다. 게다가 개인 결과라
 * 색인 대상이 아니니 `/app/*` 아래가 맞는 자리이기도 하다.
 *
 * 행 접근은 RLS 가 막는다(`fortune_history` 는 `authenticated` 에게 SELECT 만
 * 주고 정책이 `user_id = auth.uid()` 로 좁힌다). 그래서 남의 id 를 넣어도
 * 결과가 안 나오고, 여기서는 없으면 404 로 끝낸다.
 */
export const dynamic = 'force-dynamic';

export const metadata: Metadata = {
  title: '저장된 운세',
  // 개인 결과라 색인 대상이 아니다.
  robots: { index: false, follow: false },
};

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function readHighlights(summary: unknown): FortuneSummaryHighlight[] {
  if (summary === null || typeof summary !== 'object') return [];
  const raw = (summary as Record<string, unknown>).highlights;
  if (!Array.isArray(raw)) return [];

  return raw.flatMap((entry) => {
    if (entry === null || typeof entry !== 'object') return [];
    const { label, value } = entry as Record<string, unknown>;
    if (typeof label !== 'string' || typeof value !== 'string') return [];
    return [{ label, value }];
  });
}

export default async function FortuneHistoryDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const decodedId = decodeURIComponent(id);
  if (!UUID.test(decodedId)) notFound();

  const supabase = await createSupabaseServerClient();
  const user = supabase ? (await supabase.auth.getUser()).data.user : null;
  if (!supabase || !user) {
    redirect(`/auth/login?next=${encodeURIComponent(`/app/history/${decodedId}`)}`);
  }

  const { data: row, error } = await supabase
    .from('fortune_history')
    .select('id, fortune_type, title, score, summary, fortune_data, created_at')
    .eq('id', decodedId)
    .maybeSingle();

  if (error || !row) notFound();

  const snapshot = readFortuneSnapshot(row.fortune_data);
  const score = typeof row.score === 'number' ? row.score : null;

  return (
    <main className="ondo-shell ondo-stack">
      <header className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <p className="ondo-kicker">{formatKoreanDateTime(row.created_at)}</p>
        <h1 className="ondo-h2">{row.title}</h1>
        {snapshot ? null : (
          <p className="ondo-muted">
            이 기록은 본문을 저장하기 전에 만들어져서 요약만 남아 있어요.
          </p>
        )}
      </header>

      <FortuneHistoryView
        highlights={readHighlights(row.summary)}
        score={score}
        snapshot={snapshot}
      />

      <nav className="ondo-account-actions" aria-label="기록 이동">
        <Link href="/app">내 기록으로</Link>
        <Link href="/운세">새 운세 보기</Link>
      </nav>
    </main>
  );
}
