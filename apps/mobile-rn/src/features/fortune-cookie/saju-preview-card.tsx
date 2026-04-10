/**
 * Rich saju preview card for chat — shows 4 pillars with colors,
 * element balance, and personality before the survey starts.
 */

import { View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { fortuneTheme } from '../../lib/theme';
import type { SajuData } from '../../lib/saju-remote';

const ELEMENT_COLORS: Record<string, string> = {
  목: '#4CAF50',
  화: '#F44336',
  토: '#FF9800',
  금: '#C0C0C0',
  수: '#2196F3',
};

const STEM_ELEMENT: Record<string, string> = {
  '甲': '목', '乙': '목', '丙': '화', '丁': '화', '戊': '토',
  '己': '토', '庚': '금', '辛': '금', '壬': '수', '癸': '수',
};

const PILLAR_COLORS = ['#4A90D9', '#3DB56E', '#D94A4A', '#9B59B6'];

function getElementColor(hanja: string): string {
  const el = STEM_ELEMENT[hanja];
  return el ? (ELEMENT_COLORS[el] ?? fortuneTheme.colors.ctaBackground) : fortuneTheme.colors.ctaBackground;
}

function PillarBox({
  label,
  stem,
  branch,
  color,
}: {
  label: string;
  stem: string;
  branch: string;
  color: string;
}) {
  return (
    <View style={{ alignItems: 'center', flex: 1, gap: 4 }}>
      <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
        {label}
      </AppText>
      <View
        style={{
          width: 44,
          height: 44,
          borderRadius: 10,
          backgroundColor: color,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <AppText variant="heading4" color="#FFFFFF" style={{ fontWeight: '800' }}>
          {stem}
        </AppText>
      </View>
      <View
        style={{
          width: 44,
          height: 44,
          borderRadius: 10,
          backgroundColor: `${color}88`,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <AppText variant="heading4" color="#FFFFFF" style={{ fontWeight: '800' }}>
          {branch}
        </AppText>
      </View>
    </View>
  );
}

function ElementBar({ label, value, max, color }: { label: string; value: number; max: number; color: string }) {
  const pct = max > 0 ? Math.max((value / max) * 100, 8) : 8;
  return (
    <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
      <AppText variant="caption" color={color} style={{ width: 16, textAlign: 'center', fontWeight: '700' }}>
        {label}
      </AppText>
      <View style={{ flex: 1, height: 6, borderRadius: 3, backgroundColor: fortuneTheme.colors.surfaceSecondary }}>
        <View style={{ width: `${pct}%`, height: '100%', borderRadius: 3, backgroundColor: color, opacity: 0.85 }} />
      </View>
    </View>
  );
}

export function SajuPreviewCard({
  data,
  userName,
}: {
  data: SajuData;
  userName: string;
}) {
  const pillars = [
    { label: '년주', stem: data.year_stem_hanja, branch: data.year_branch_hanja, color: PILLAR_COLORS[0]! },
    { label: '월주', stem: data.month_stem_hanja, branch: data.month_branch_hanja, color: PILLAR_COLORS[1]! },
    { label: '일주', stem: data.day_stem_hanja, branch: data.day_branch_hanja, color: PILLAR_COLORS[2]! },
    { label: '시주', stem: data.hour_stem_hanja ?? '?', branch: data.hour_branch_hanja ?? '?', color: PILLAR_COLORS[3]! },
  ];

  const balance = data.element_balance;
  const total = (balance.목 + balance.화 + balance.토 + balance.금 + balance.수) || 1;

  const dominant = data.dominant_element;
  const weak = data.weak_element;
  const dominantColor = dominant ? (ELEMENT_COLORS[dominant] ?? fortuneTheme.colors.textPrimary) : fortuneTheme.colors.textPrimary;

  return (
    <Card style={{ gap: 16 }}>
      {/* Header */}
      <View style={{ flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between' }}>
        <View>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            {userName}님의 사주
          </AppText>
          <AppText variant="heading4" style={{ fontWeight: '700', marginTop: 2 }}>
            사주 팔자
          </AppText>
        </View>
        {dominant ? (
          <View
            style={{
              backgroundColor: `${dominantColor}20`,
              borderRadius: fortuneTheme.radius.full,
              paddingHorizontal: 10,
              paddingVertical: 4,
            }}
          >
            <AppText variant="labelSmall" color={dominantColor} style={{ fontWeight: '700' }}>
              {dominant} 기운 강함
            </AppText>
          </View>
        ) : null}
      </View>

      {/* 4 Pillars */}
      <View style={{ flexDirection: 'row', justifyContent: 'space-between', paddingVertical: 4 }}>
        {pillars.map((p) => (
          <PillarBox key={p.label} label={p.label} stem={p.stem} branch={p.branch} color={p.color} />
        ))}
      </View>

      {/* Element Balance */}
      <View style={{ gap: 4 }}>
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary} style={{ marginBottom: 2 }}>
          오행 분포
        </AppText>
        <ElementBar label="목" value={balance.목} max={total} color={ELEMENT_COLORS['목']!} />
        <ElementBar label="화" value={balance.화} max={total} color={ELEMENT_COLORS['화']!} />
        <ElementBar label="토" value={balance.토} max={total} color={ELEMENT_COLORS['토']!} />
        <ElementBar label="금" value={balance.금} max={total} color={ELEMENT_COLORS['금']!} />
        <ElementBar label="수" value={balance.수} max={total} color={ELEMENT_COLORS['수']!} />
      </View>

      {/* Summary */}
      {dominant && weak ? (
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {dominant} 기운이 강하고 {weak}이(가) 부족해요. 더 자세히 볼까요?
        </AppText>
      ) : null}
    </Card>
  );
}
