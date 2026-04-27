/**
 * useRevealProgress — ondo fortune_results/result-cards.jsx의 `progress ∈ [0,1]`
 * 리빌 드라이버를 RN으로 포트한 훅.
 *
 * 마운트 시 0에서 시작해 `durationMs` 동안 선형으로 1까지 증가한다. 하위 원자
 * (ScoreDial, Bar, Section, Hero*)가 이 값을 받아 각자 `stage(p, from, to)`로
 * 구간별 리빌/카운트업을 계산한다.
 *
 * 기존 코드가 `progress={1}`로 하드코딩해서 리빌이 전혀 재생되지 않던 버그를
 * 이 훅으로 대체.
 */
import { useEffect, useRef, useState } from 'react';

const DEFAULT_DURATION_MS = 1800;

export function useRevealProgress(durationMs: number = DEFAULT_DURATION_MS): number {
  const [progress, setProgress] = useState(0);
  const rafRef = useRef<number | null>(null);

  useEffect(() => {
    const start = Date.now();
    const tick = () => {
      const elapsed = Date.now() - start;
      const next = Math.min(1, elapsed / durationMs);
      setProgress(next);
      if (next < 1) {
        rafRef.current = requestAnimationFrame(tick);
      }
    };
    rafRef.current = requestAnimationFrame(tick);
    return () => {
      if (rafRef.current != null) {
        cancelAnimationFrame(rafRef.current);
      }
    };
  }, [durationMs]);

  return progress;
}
