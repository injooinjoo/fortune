import { AppLink as Link } from '@/components/app-link';
import { redirect } from 'next/navigation';

import { getFortuneCostPoints } from '@fortune/product-contracts';

import { SignOutButton } from '@/components/sign-out-button';
import {
  displayAccountName,
  formatKoreanDateTime,
  normalizeBalance,
  normalizeFortuneHistory,
} from '@/lib/account-data';
import { createSupabaseServerClient } from '@/lib/supabase/server';

export const dynamic = 'force-dynamic';

export default async function AppHomePage() {
  const supabase = await createSupabaseServerClient();
  const user = supabase ? (await supabase.auth.getUser()).data.user : null;
  if (!supabase || !user) redirect('/auth/login?next=%2Fapp');

  const [balanceResult, historyResult] = await Promise.all([
    supabase.from('token_balance').select('balance').eq('user_id', user.id).maybeSingle(),
    supabase
      .from('fortune_history')
      .select('id, fortune_type, title, score, created_at')
      .eq('user_id', user.id)
      .order('created_at', { ascending: false })
      .limit(20),
  ]);

  const balance = normalizeBalance(balanceResult.data);
  const history = normalizeFortuneHistory(historyResult.data ?? []);
  const accountName = user.is_anonymous ? '게스트로 이용 중' : displayAccountName(user);
  const readError = balanceResult.error || historyResult.error;

  return (
    <main className="ondo-shell ondo-stack ondo-account-page">
      <header className="ondo-stack" style={{ gap: 'var(--ondo-spacing-xs)' }}>
        <p className="ondo-kicker">내 온도</p>
        <h1 className="ondo-h2">{accountName}</h1>
        <p className="ondo-muted">
          {user.is_anonymous
            ? 'Google 계정을 연결하면 지금까지의 온도와 운세 기록을 그대로 보관할 수 있어요.'
            : '잔액과 최근 운세 기록을 한곳에서 확인하세요.'}
        </p>
      </header>

      <section className="ondo-account-summary" aria-label="계정 요약">
        <article className="ondo-card ondo-stack">
          <p className="ondo-kicker">사용 가능한 온도</p>
          <p className="ondo-account-balance"><strong>{balance}</strong>개</p>
          <p className="ondo-muted">오늘의 운세는 온도 {getFortuneCostPoints('daily')}개를 사용해요.</p>
          {user.is_anonymous ? null : (
            <Link className="ondo-button" href="/app/charge">온도 충전</Link>
          )}
        </article>
        <article className="ondo-card ondo-stack">
          <p className="ondo-kicker">계정 상태</p>
          <h2 className="ondo-h3">{user.is_anonymous ? '게스트' : 'Google 연결 완료'}</h2>
          <p className="ondo-muted">
            {user.is_anonymous ? '계정을 연결하면 45온도가 한 번 추가돼요.' : '운세와 대화 기록이 이 계정에 보관돼요.'}
          </p>
          {user.is_anonymous ? (
            <Link className="ondo-button" href="/auth/login?next=%2Fapp">Google 계정 연결</Link>
          ) : null}
        </article>
      </section>

      {readError ? (
        <p className="ondo-notice ondo-notice--error" role="alert">
          일부 계정 정보를 불러오지 못했어요. 잠시 후 새로고침해 주세요.
        </p>
      ) : null}

      <section className="ondo-stack" aria-labelledby="history-heading">
        <div className="ondo-section-heading">
          <div>
            <p className="ondo-kicker">최근 기록</p>
            <h2 className="ondo-h3" id="history-heading">운세 히스토리</h2>
          </div>
          <Link href="/운세">새 운세 보기</Link>
        </div>

        {history.length ? (
          <ol className="ondo-history-list">
            {history.map((item) => (
              <li className="ondo-card ondo-history-item" key={item.id}>
                <div>
                  <p className="ondo-kicker">{formatKoreanDateTime(item.createdAt)}</p>
                  <h3>{item.title}</h3>
                  <p className="ondo-muted">{item.fortuneType}</p>
                </div>
                {item.score === null ? null : <strong className="ondo-history-score">{item.score}점</strong>}
              </li>
            ))}
          </ol>
        ) : (
          <div className="ondo-card ondo-stack">
            <h3 className="ondo-h3">아직 저장된 운세가 없어요.</h3>
            <p className="ondo-muted">첫 운세를 보면 최근 기록이 여기에 차곡차곡 쌓여요.</p>
            <Link className="ondo-button" href="/운세">운세 둘러보기</Link>
          </div>
        )}
      </section>

      <section className="ondo-account-actions" aria-label="계정 작업">
        <Link href="/app/payments">결제 내역</Link>
        <Link href="/delete-account">계정 삭제 안내</Link>
        <SignOutButton />
      </section>
    </main>
  );
}
