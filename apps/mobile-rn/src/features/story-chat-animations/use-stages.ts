// Ported from story-reveals.jsx:25-38. Cumulative timer → active step index.
import { useEffect, useState } from 'react';

export function useStages(play: number, steps: number[], speed = 1): number {
  const [stage, setStage] = useState(0);
  useEffect(() => {
    setStage(0);
    const timers: ReturnType<typeof setTimeout>[] = [];
    let c = 0;
    steps.forEach((d, i) => {
      c += d / speed;
      timers.push(setTimeout(() => setStage(i + 1), c));
    });
    return () => {
      timers.forEach(clearTimeout);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [play, speed]);
  return stage;
}
