/**
 * HeroExam — `result-cards.jsx:HeroExam` (650-656).
 *
 * 원본:
 *   padding 18px 6px 4px, gap 12
 *   연필 ✎ 40px, opacity stage(p, 0, 0.4), rotate tween(easeOut(stage), -30, -10)
 *   ScoreDial score=d.score color="#8FB8FF" size=72
 */
import { Text, View } from 'react-native';

import type { EmbeddedResultPayload } from '../../chat-results/types';
import { ScoreDial } from '../primitives/score-dial';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

const SKY = '#8FB8FF';

interface HeroExamProps {
  data?: EmbeddedResultPayload;
  progress?: number;
}

export default function HeroExam({ data, progress = 1 }: HeroExamProps) {
  const p = clamp01(progress);
  const pencilStage = stage(p, 0, 0.4);
  const rotate = tween(easeOut(pencilStage), -30, -10);
  const score = typeof data?.score === 'number' ? data.score : 78;

  return (
    <View
      style={{
        paddingTop: 18,
        paddingHorizontal: 6,
        paddingBottom: 4,
        flexDirection: 'row',
        alignItems: 'center',
        justifyContent: 'center',
        gap: 12,
      }}
    >
      <Text
        style={{
          fontSize: 40,
          opacity: pencilStage,
          transform: [{ rotate: `${rotate}deg` }],
        }}
      >
        ✎
      </Text>
      <ScoreDial score={score} color={SKY} progress={p} size={72} />
    </View>
  );
}
