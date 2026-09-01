import { DailyResult } from '@/features/daily/daily-result';
import type { DailyFortune } from '@/features/daily/types';
import { BulletList, Disclaimer, ScoreHeadline } from '@/features/fortune/result';
import type { FortuneSummaryHighlight } from '@/lib/fortune-context';
import type { FortuneSnapshot } from '@/lib/fortune-snapshot';

/**
 * 저장된 운세를 다시 렌더한다.
 *
 * 운세 종류마다 결과 컴포넌트가 따로 있어서(`daily-result`, `tarot-result`, …)
 * 한 번에 전부 붙일 수는 없다. 스냅샷이 있고 전용 렌더러가 있는 종류는 원래
 * 화면 그대로 보여주고, 나머지는 저장된 하이라이트로 떨어진다. 폴백이라도
 * 지금(아무것도 못 봄)보다는 낫고, 종류를 하나씩 옮길 때 이 표만 늘리면 된다.
 *
 * 훅을 쓰지 않지만 `DailyResult` 안에 버튼 핸들러가 있어 클라이언트 경계가
 * 필요하다. `onReset` 을 넘기지 않으면 그 툴바는 렌더되지 않는다.
 */
export function FortuneHistoryView({
  snapshot,
  highlights,
  score,
}: {
  snapshot: FortuneSnapshot | null;
  highlights: FortuneSummaryHighlight[];
  score: number | null;
}) {
  if (snapshot?.fortuneType === 'daily') {
    const fortune = (snapshot.value as { fortune?: DailyFortune }).fortune;
    if (fortune) return <DailyResult cached fortune={fortune} />;
  }

  return (
    <section aria-label="저장된 운세 결과" className="ondo-stack">
      {score === null ? null : <ScoreHeadline kicker="저장된 결과" score={score} />}
      {highlights.length > 0 ? (
        <BulletList
          items={highlights.map((entry) => `${entry.label}: ${entry.value}`)}
          label="저장된 요약"
        />
      ) : (
        <p className="ondo-muted">이 기록에는 다시 보여드릴 본문이 남아 있지 않아요.</p>
      )}
      <Disclaimer />
    </section>
  );
}
