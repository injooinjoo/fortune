/**
 * HeroManseryeok — 벤치마크 parity 만세력 대시보드.
 *
 * 각 기둥 컬럼에 아래 행 순서로 표시:
 *  1. 헤더 (시주/일주/월주/년주)
 *  2. 간지 한글
 *  3. 관계 요약 3자리 (합/충/형)
 *  4. 천간 십성
 *  5. 천간 한자 스탬프
 *  6. 지지 한자 스탬프
 *  7. 지지 십성
 *  8. 지장간
 *  9. 12운성 이중표기 (primary(jiJangGanMain))
 *  10. 납음
 *  11. 합충형파해 상세 (노란 박스, 다른 기둥과의 관계 상세)
 *  12. 공망 마크 ([日]공망 / [年]공망 / -)
 *  13. 12신살 년지 기준
 *  14. 12신살 일지 기준
 *  15. 길성 목록 (기둥별 신살)
 */

import { Pressable, View } from 'react-native';

import type {
  BranchRelation,
  InteractionEntry,
  PillarData,
  PillarName,
  SajuResult,
  StarName,
  TenGod,
  TwelveSpirit,
  TwelveStage,
} from '@fortune/saju-engine';

import { AppText } from '../../../components/app-text';
import { fortuneTheme, withAlpha } from '../../../lib/theme';
import {
  ElementBar,
  StarBadge,
  StemBranchStamp,
} from '../primitives/manseryeok-cells';

const PILLAR_ORDER: readonly PillarName[] = ['hour', 'day', 'month', 'year'];

const PILLAR_LABEL: Record<PillarName, string> = {
  hour: '시주',
  day: '일주',
  month: '월주',
  year: '년주',
};

const INTERACTION_GROUP: Record<InteractionEntry['type'], '합' | '충' | '형' | '파' | '해'> = {
  삼합: '합',
  육합: '합',
  방합: '합',
  육충: '충',
  삼형: '형',
  자형: '형',
  육파: '파',
  육해: '해',
  원진: '해',
  귀문: '해',
};

interface HeroManseryeokProfile {
  name: string;
  age: number;
  birthLabel: string;
}

interface HeroManseryeokProps {
  data: SajuResult;
  profile: HeroManseryeokProfile;
  onTermPress?: (term: string) => void;
}

export function HeroManseryeok({
  data,
  profile,
  onTermPress,
}: HeroManseryeokProps) {
  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surfaceElevated,
        borderRadius: fortuneTheme.radius.lg,
        overflow: 'hidden',
        borderWidth: 1,
        borderColor: fortuneTheme.colors.border,
      }}
    >
      <ProfileBar profile={profile} />
      <PillarsTable data={data} onTermPress={onTermPress} />
      <View
        style={{
          borderTopWidth: 1,
          borderColor: fortuneTheme.colors.border,
          paddingVertical: 8,
          paddingHorizontal: 12,
        }}
      >
        <ElementBar
          distribution={{
            wood: data.elements.wood,
            fire: data.elements.fire,
            earth: data.elements.earth,
            metal: data.elements.metal,
            water: data.elements.water,
          }}
        />
      </View>
      <NobleRow data={data} onTermPress={onTermPress} />
    </View>
  );
}

/* ───────────────────────── ProfileBar ───────────────────────── */

function ProfileBar({ profile }: { profile: HeroManseryeokProfile }) {
  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.ctaBackground,
        paddingHorizontal: 16,
        paddingVertical: 14,
        flexDirection: 'row',
        alignItems: 'center',
        gap: 12,
      }}
    >
      <View
        style={{
          width: 44,
          height: 44,
          borderRadius: 22,
          backgroundColor: withAlpha('#ffffff', 0.2),
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <AppText variant="heading3" color={fortuneTheme.colors.ctaForeground}>
          {profile.name.slice(0, 1) || '나'}
        </AppText>
      </View>
      <View style={{ flex: 1 }}>
        <AppText
          variant="heading4"
          color={fortuneTheme.colors.ctaForeground}
        >
          {profile.name} ({profile.age}세)
        </AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.ctaForeground}
        >
          {profile.birthLabel}
        </AppText>
      </View>
    </View>
  );
}

/* ───────────────────────── PillarsTable ───────────────────────── */

function PillarsTable({
  data,
  onTermPress,
}: {
  data: SajuResult;
  onTermPress?: (term: string) => void;
}) {
  return (
    <View style={{ flexDirection: 'row' }}>
      {PILLAR_ORDER.map((name, index) => (
        <PillarColumn
          key={name}
          name={name}
          isFirst={index === 0}
          data={data}
          onTermPress={onTermPress}
        />
      ))}
    </View>
  );
}

interface PillarColumnProps {
  name: PillarName;
  isFirst: boolean;
  data: SajuResult;
  onTermPress?: (term: string) => void;
}

function PillarColumn({ name, isFirst, data, onTermPress }: PillarColumnProps) {
  const pillar: PillarData = data.pillars[name];
  const isDay = name === 'day';
  const tenGodStem: TenGod = data.tenGods[name].stem;
  const tenGodBranch: TenGod = data.tenGods[name].branch;
  const twelveStagePrimary: TwelveStage = data.twelveStages[name];
  const twelveStageDual = data.twelveStagesDual?.[name];
  const twelveSpirit: TwelveSpirit = data.twelveSpirits[name];
  const twelveSpiritByDay: TwelveSpirit | undefined =
    data.twelveSpiritsByDay?.[name];
  const napEum = data.napEum[name];
  const jiJangGan = data.jiJangGan[name];
  const relationLabel = summarizeRelationForPillar(name, data.interactions);
  const relations: BranchRelation[] = data.branchRelations?.[name] ?? [];
  const voidFlag = data.voidFlags?.[name];
  const stars: StarName[] = data.stars[name];

  const topLabelColor = isDay
    ? fortuneTheme.colors.ctaBackground
    : fortuneTheme.colors.textSecondary;

  return (
    <View
      style={{
        flex: 1,
        borderLeftWidth: isFirst ? 0 : 1,
        borderColor: fortuneTheme.colors.border,
      }}
    >
      {/* 헤더 */}
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          paddingVertical: 6,
        }}
      >
        <AppText
          variant="labelMedium"
          color={fortuneTheme.colors.textPrimary}
          style={{ textAlign: 'center', fontWeight: '700' }}
        >
          {PILLAR_LABEL[name]}
        </AppText>
      </View>

      {/* 간지 한글 */}
      <View
        style={{
          backgroundColor: withAlpha(fortuneTheme.colors.textSecondary, 0.06),
          paddingVertical: 4,
        }}
      >
        <AppText
          variant="labelMedium"
          color={fortuneTheme.colors.textPrimary}
          style={{ textAlign: 'center' }}
        >
          {pillar.korean}
        </AppText>
      </View>

      {/* 관계 요약 3자리 */}
      <View
        style={{
          backgroundColor: withAlpha(fortuneTheme.colors.warning, 0.14),
          paddingVertical: 4,
        }}
      >
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textSecondary}
          style={{ textAlign: 'center' }}
        >
          {relationLabel}
        </AppText>
      </View>

      {/* 천간 십성 */}
      <AppText
        variant="labelSmall"
        color={isDay ? fortuneTheme.colors.ctaBackground : topLabelColor}
        onPress={
          onTermPress && !isDay ? () => onTermPress(tenGodStem) : undefined
        }
        style={{
          textAlign: 'center',
          paddingVertical: 4,
          fontWeight: isDay ? '700' : '500',
        }}
      >
        {isDay ? '일간(나)' : tenGodStem}
      </AppText>

      {/* 천간 한자 스탬프 */}
      <View style={{ alignItems: 'center', paddingVertical: 6 }}>
        <Pressable
          onPress={onTermPress ? () => onTermPress(pillar.stem.korean) : undefined}
          hitSlop={4}
        >
          <StemBranchStamp
            hanja={pillar.stem.hanja}
            element={pillar.stem.element}
            size={52}
            emphasis={isDay}
          />
        </Pressable>
      </View>

      {/* 지지 한자 스탬프 */}
      <View style={{ alignItems: 'center', paddingVertical: 6 }}>
        <Pressable
          onPress={onTermPress ? () => onTermPress(pillar.branch.korean) : undefined}
          hitSlop={4}
        >
          <StemBranchStamp
            hanja={pillar.branch.hanja}
            element={pillar.branch.element}
            size={52}
          />
        </Pressable>
      </View>

      {/* 지지 십성 */}
      <AppText
        variant="labelSmall"
        color={fortuneTheme.colors.textPrimary}
        onPress={onTermPress ? () => onTermPress(tenGodBranch) : undefined}
        style={{ textAlign: 'center', paddingVertical: 4 }}
      >
        {tenGodBranch}
      </AppText>

      {/* 지장간 */}
      <AppText
        variant="caption"
        color={fortuneTheme.colors.textSecondary}
        onPress={onTermPress ? () => onTermPress('지장간') : undefined}
        style={{ textAlign: 'center', paddingVertical: 2 }}
      >
        {jiJangGan.map((j) => j.hanja).join('')}
      </AppText>

      {/* 12운성 이중표기 */}
      <AppText
        variant="caption"
        color={fortuneTheme.colors.textSecondary}
        onPress={onTermPress ? () => onTermPress(twelveStagePrimary) : undefined}
        style={{ textAlign: 'center', paddingVertical: 2 }}
      >
        {twelveStageDual
          ? twelveStageDual.primary === twelveStageDual.jiJangGanMain
            ? twelveStageDual.primary
            : `${twelveStageDual.primary}(${twelveStageDual.jiJangGanMain})`
          : twelveStagePrimary}
      </AppText>

      {/* 납음 */}
      <AppText
        variant="caption"
        color={fortuneTheme.colors.textTertiary}
        onPress={onTermPress ? () => onTermPress(napEum) : undefined}
        style={{ textAlign: 'center', paddingVertical: 4, paddingHorizontal: 2 }}
        numberOfLines={1}
      >
        {napEum}
      </AppText>

      {/* 합충형파해 상세 — 노란 박스 */}
      <View
        style={{
          backgroundColor: withAlpha(fortuneTheme.colors.warning, 0.14),
          paddingVertical: 6,
          paddingHorizontal: 4,
          minHeight: 40,
          alignItems: 'center',
          gap: 2,
        }}
      >
        {relations.length === 0 ? (
          <AppText
            variant="caption"
            color={fortuneTheme.colors.textTertiary}
          >
            -
          </AppText>
        ) : (
          relations.slice(0, 3).map((rel, i) => (
            <AppText
              key={`${rel.target}-${rel.type}-${i}`}
              variant="caption"
              color={fortuneTheme.colors.textSecondary}
              style={{ textAlign: 'center' }}
            >
              ({rel.targetBranchKr}) {rel.shortLabel}
            </AppText>
          ))
        )}
      </View>

      {/* 공망 마크 */}
      <View style={{ paddingVertical: 4, alignItems: 'center', gap: 2 }}>
        {voidFlag?.dayVoid ? (
          <AppText
            variant="caption"
            color={fortuneTheme.colors.ctaBackground}
            style={{ fontWeight: '600' }}
            onPress={onTermPress ? () => onTermPress('공망') : undefined}
          >
            [日]공망
          </AppText>
        ) : null}
        {voidFlag?.yearVoid ? (
          <AppText
            variant="caption"
            color={fortuneTheme.colors.ctaBackground}
            style={{ fontWeight: '600' }}
            onPress={onTermPress ? () => onTermPress('공망') : undefined}
          >
            [年]공망
          </AppText>
        ) : null}
        {!voidFlag?.dayVoid && !voidFlag?.yearVoid ? (
          <AppText
            variant="caption"
            color={fortuneTheme.colors.textTertiary}
          >
            -
          </AppText>
        ) : null}
      </View>

      {/* 12신살 (년지 기준) */}
      <AppText
        variant="caption"
        color={fortuneTheme.colors.ctaBackground}
        onPress={onTermPress ? () => onTermPress(twelveSpirit) : undefined}
        style={{
          textAlign: 'center',
          paddingVertical: 2,
          fontWeight: '600',
        }}
      >
        {twelveSpirit}
      </AppText>

      {/* 12신살 (일지 기준) */}
      {twelveSpiritByDay ? (
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textSecondary}
          onPress={onTermPress ? () => onTermPress(twelveSpiritByDay) : undefined}
          style={{
            textAlign: 'center',
            paddingVertical: 2,
          }}
        >
          {twelveSpiritByDay}
        </AppText>
      ) : null}

      {/* 길성(신살) 목록 */}
      <View
        style={{
          paddingVertical: 6,
          paddingHorizontal: 2,
          gap: 4,
          alignItems: 'center',
        }}
      >
        {stars.length === 0 ? (
          <AppText
            variant="caption"
            color={fortuneTheme.colors.textTertiary}
          >
            -
          </AppText>
        ) : (
          stars.map((star) => (
            <StarBadge key={star} name={star} onPress={onTermPress} />
          ))
        )}
      </View>
    </View>
  );
}

/** 해당 주가 관여된 관계(interactions)를 합/충/형 요약 3글자로 압축. */
function summarizeRelationForPillar(
  name: PillarName,
  interactions: InteractionEntry[],
): string {
  const slots: Record<'합' | '충' | '형', boolean> = {
    합: false,
    충: false,
    형: false,
  };

  for (const entry of interactions) {
    if (!entry.pair.includes(name)) continue;
    const group = INTERACTION_GROUP[entry.type];
    if (group === '합' || group === '충' || group === '형') {
      slots[group] = true;
    }
  }

  const ch = (flag: boolean, sym: string) => (flag ? sym : '-');
  return `${ch(slots.합, '합')}${ch(slots.충, '충')}${ch(slots.형, '형')}`;
}

/* ───────────────────────── NobleRow ───────────────────────── */

function NobleRow({
  data,
  onTermPress,
}: {
  data: SajuResult;
  onTermPress?: (term: string) => void;
}) {
  const cheoneul = data.nobleStars.cheoneul.join('·');
  const wollyeong = data.nobleStars.wollyeong;
  return (
    <View
      style={{
        borderTopWidth: 1,
        borderColor: fortuneTheme.colors.border,
        paddingHorizontal: 14,
        paddingVertical: 8,
        gap: 4,
      }}
    >
      <AppText
        variant="caption"
        color={fortuneTheme.colors.textSecondary}
        onPress={onTermPress ? () => onTermPress('공망') : undefined}
        style={{ textAlign: 'center' }}
      >
        공망 · [年] {data.voids.year.join('')} · [日] {data.voids.day.join('')}
      </AppText>
      <AppText
        variant="caption"
        color={fortuneTheme.colors.textSecondary}
        style={{ textAlign: 'center' }}
      >
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textSecondary}
          onPress={onTermPress ? () => onTermPress('천을귀인') : undefined}
        >
          천을귀인 · {cheoneul}
        </AppText>
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textSecondary}
        >
          {'  ·  '}
        </AppText>
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textSecondary}
          onPress={onTermPress ? () => onTermPress('월령') : undefined}
        >
          월령 · {wollyeong}
        </AppText>
      </AppText>
    </View>
  );
}
