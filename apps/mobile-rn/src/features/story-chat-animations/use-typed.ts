// Ported from story-reveals.jsx:41-57. Typewriter effect.
// Note: `cps` is the setInterval tick in ms (misnamed in source) — 45 is the
// JSX default, giving ~22 chars/sec at speed=1.
import { useEffect, useState } from 'react';

export function useTyped(
  text: string,
  play: number,
  startDelay = 0,
  speed = 1,
  cps = 45,
): string {
  const [out, setOut] = useState('');
  useEffect(() => {
    setOut('');
    let id: ReturnType<typeof setInterval> | undefined;
    const start = setTimeout(() => {
      let i = 0;
      id = setInterval(() => {
        i += 1;
        setOut(text.slice(0, i));
        if (i >= text.length && id) clearInterval(id);
      }, cps / speed);
    }, startDelay / speed);
    return () => {
      clearTimeout(start);
      if (id) clearInterval(id);
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [text, play, speed]);
  return out;
}
