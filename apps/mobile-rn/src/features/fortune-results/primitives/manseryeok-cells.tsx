/**
 * Manseryeok cells — 작은 재사용 primitives for Hero만세력.
 *
 * - StemBranchStamp: 천간/지지 한자를 오행 색상 배경의 정사각형 스탬프로 표시
 * - ElementBar: 오행 5개 카운트를 한 줄 요약
 * - StarBadge: 신살 한 개 (탭하면 용어 설명 훅에 연결)
 */

import { Pressable, View, type ViewStyle } from 'react-native';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import type { Element } from '@fortune/saju-engine';

const ELEMENT_COLOR_MAP: Record<Element, string> = {
  목: fortuneTheme.colors.elemental.wood,
  화: fortuneTheme.colors.elemental.fire,
  토: fortuneTheme.colors.elemental.earth,
  금: fortuneTheme.colors.elemental.metal,
  수: fortuneTheme.colors.elemental.water,
};

const ELEMENT_LABEL_MAP: Record<Element, string> = {
  목: '木',
  화: '火',
  토: '土',
  금: '金',
  수: '水',
};

const ELEMENT_ORDER: readonly Element[] = ['목', '화', '토', '금', '수'];

export function elementColor(el: Element): string {
  return ELEMENT_COLOR_MAP[el];
}

export function elementHanja(el: Element): string {
  return ELEMENT_LABEL_MAP[el];
}

interface StemBranchStampProps {
  hanja: string;
  element: Element;
  size?: number;
  /** 외곽 강조 테두리 (일간용) */
  emphasis?: boolean;
  style?: ViewStyle;
}

/** 천간/지지 한자를 오행 컬러 배경 위에 큰 글씨로 찍어주는 정사각형 스탬프. */
export function StemBranchStamp({
  hanja,
  element,
  size = 56,
  emphasis = false,
  style,
}: StemBranchStampProps) {
  const bg = ELEMENT_COLOR_MAP[element];
  // 금(metal)은 회색 계열이라 흰 글씨가 묻혀 보임 — 어두운 글씨로 전환.
  const isLightBg = element === '금';
  const textColor = isLightBg
    ? fortuneTheme.colors.background
    : fortuneTheme.colors.textPrimary;

  return (
    <View
      style={[
        {
          width: size,
          height: size,
          backgroundColor: bg,
          borderRadius: fortuneTheme.radius.sm,
          alignItems: 'center',
          justifyContent: 'center',
          borderWidth: emphasis ? 2 : 0,
          borderColor: emphasis
            ? fortuneTheme.colors.textPrimary
            : 'transparent',
        },
        style,
      ]}
    >
      <AppText
        variant="displaySmall"
        color={textColor}
        style={{
          fontSize: Math.round(size * 0.5),
          lineHeight: Math.round(size * 0.6),
          fontWeight: '900',
          textAlign: 'center',
        }}
      >
        {hanja}
      </AppText>
    </View>
  );
}

interface ElementBarProps {
  distribution: {
    wood: number;
    fire: number;
    earth: number;
    metal: number;
    water: number;
  };
}

/** 한 줄 요약: 木 0, 火 0, 土 3, 金 2, 水 3 */
export function ElementBar({ distribution }: ElementBarProps) {
  const entries: Array<{ element: Element; value: number }> = [
    { element: '목', value: distribution.wood },
    { element: '화', value: distribution.fire },
    { element: '토', value: distribution.earth },
    { element: '금', value: distribution.metal },
    { element: '수', value: distribution.water },
  ];

  return (
    <View
      style={{
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'center',
        gap: 12,
        paddingVertical: 10,
      }}
    >
      {entries.map((it) => (
        <View
          key={it.element}
          style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}
        >
          <AppText
            variant="labelMedium"
            color={ELEMENT_COLOR_MAP[it.element]}
            style={{ fontWeight: '800' }}
          >
            {ELEMENT_LABEL_MAP[it.element]}
          </AppText>
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textPrimary}
          >
            {it.value}
          </AppText>
        </View>
      ))}
    </View>
  );
}

interface StarBadgeProps {
  name: string;
  onPress?: (name: string) => void;
}

export function StarBadge({ name, onPress }: StarBadgeProps) {
  const handle = onPress ? () => onPress(name) : undefined;
  return (
    <Pressable
      onPress={handle}
      style={({ pressed }) => ({
        paddingHorizontal: 8,
        paddingVertical: 3,
        borderRadius: fortuneTheme.radius.full,
        backgroundColor: withAlpha(fortuneTheme.colors.textSecondary, 0.12),
        opacity: pressed ? 0.6 : 1,
      })}
    >
      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.textSecondary}
      >
        {name}
      </AppText>
    </Pressable>
  );
}

export { ELEMENT_ORDER };
