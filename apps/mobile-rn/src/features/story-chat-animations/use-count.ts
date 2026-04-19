// Ported from story-reveals.jsx:5-22. easeOut3 count-up via requestAnimationFrame.
import { useEffect, useState } from 'react';

export function useCount(
  target: number,
  play: number,
  speed = 1,
  dur = 1400,
): number {
  const [v, setV] = useState(0);
  useEffect(() => {
    setV(0);
    const start =
      typeof performance !== 'undefined' && typeof performance.now === 'function'
        ? performance.now()
        : Date.now();
    const total = dur / speed;
    let raf: number;
    const tick = (now: number) => {
      const t = Math.min(1, (now - start) / total);
      const eased = 1 - Math.pow(1 - t, 3);
      setV(target * eased);
      if (t < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [target, play, speed, dur]);
  return v;
}
