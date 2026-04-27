/**
 * HeroBlood — `result-cards.jsx:HeroBlood` (249-263). View-only 근사 (SVG 재적용은 다음 빌드).
 */
import { Text, View } from 'react-native';

const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
const stage = (p: number, from: number, to: number) =>
  clamp01((p - from) / Math.max(0.0001, to - from));
const easeOut = (t: number) => 1 - Math.pow(1 - t, 3);
const tween = (t: number, from: number, to: number) => from + (to - from) * t;

function extractBloodType(payload: unknown): string {
  if (!payload || typeof payload !== 'object') return 'A형';
  const root = payload as Record<string, unknown>;
  const raw =
    (root.rawApiResponse && typeof root.rawApiResponse === 'object'
      ? (root.rawApiResponse as Record<string, unknown>)
      : root) ?? {};
  const data = (raw.data ?? raw.fortune ?? raw) as Record<string, unknown>;
  return (
    (typeof data.bloodType === 'string' && data.bloodType) ||
    (typeof data.bloodTypeLabel === 'string' && data.bloodTypeLabel) ||
    'A형'
  );
}

interface HeroBloodProps {
  data: unknown;
  progress?: number;
}

export default function HeroBlood({ data: payload, progress = 1 }: HeroBloodProps) {
  const p = clamp01(progress);
  const local = stage(p, 0, 0.5);
  const revealScale = tween(easeOut(local), 0.5, 1);
  const bloodType = extractBloodType(payload);

  return (
    <View
      style={{
        paddingHorizontal: 6,
        paddingTop: 22,
        paddingBottom: 6,
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <View
        style={{
          width: 100,
          height: 100,
          borderRadius: 50,
          backgroundColor: '#C36D8B',
          opacity: local,
          alignItems: 'center',
          justifyContent: 'center',
          transform: [{ scale: revealScale }],
          shadowColor: '#C36D8B',
          shadowOffset: { width: 0, height: 0 },
          shadowOpacity: 0.4 * local,
          shadowRadius: 30,
          elevation: 8,
        }}
      >
        <View
          style={{
            position: 'absolute',
            top: 12,
            left: 20,
            width: 50,
            height: 50,
            borderRadius: 25,
            backgroundColor: '#FFC7D9',
            opacity: 0.7,
          }}
        />
        <View
          style={{
            position: 'absolute',
            inset: 0,
            borderRadius: 50,
            borderWidth: 12,
            borderColor: '#4a1f33',
            opacity: 0.35,
          }}
        />
        <Text
          style={{
            fontFamily: 'ZenSerif',
            fontSize: 56,
            color: '#FFFFFF',
            fontWeight: '700',
            letterSpacing: -2.24,
            zIndex: 1,
          }}
        >
          {bloodType.replace(/형.*$/, '')}
        </Text>
      </View>
    </View>
  );
}
