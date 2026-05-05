/**
 * PR-B1: 하늘이 운세 메뉴 카드.
 *
 * FORTUNE_CATALOG (product-contracts) 를 정적 렌더 — LLM 호출 없이 클라가
 * 카탈로그 SoT 그대로 그림. 그룹 단위 섹션 + entry 펼침 애니메이션.
 *
 * 사용:
 * ```tsx
 * <FortuneMenuCard
 *   message={fortuneMenuMessage}
 *   onSelect={(entry) => handleFortuneSelect(entry)}
 * />
 * ```
 */

import { useEffect, useRef } from 'react';

import { Animated, Easing, Pressable, View, useAnimatedValue } from 'react-native';

import {
  type ChatShellFortuneMenuMessage,
} from '../../lib/chat-shell';
import { fortuneTheme } from '../../lib/theme';
import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import {
  type FortuneCatalogEntry,
  type FortuneCatalogGroup,
  groupFortuneCatalog,
} from '@fortune/product-contracts';

const ROW_DURATION_MS = 240;
const STAGGER_DELAY_MS = 60;
const MAX_STAGGER_ROWS = 4; // 그 이상은 동시 페이드인

interface FortuneMenuCardProps {
  message: ChatShellFortuneMenuMessage;
  onSelect: (entry: FortuneCatalogEntry) => void;
  /** reduced-motion 시 stagger 없이 즉시 렌더. 기본 false. */
  reducedMotion?: boolean;
}

export function FortuneMenuCard({
  message,
  onSelect,
  reducedMotion = false,
}: FortuneMenuCardProps) {
  const grouped = groupFortuneCatalog();

  return (
    <View style={{ width: '100%', gap: fortuneTheme.spacing.sm }}>
      {message.intro ? (
        <AppText variant="bodyLarge" color={fortuneTheme.colors.textPrimary}>
          {message.intro}
        </AppText>
      ) : null}

      <Card style={{ gap: fortuneTheme.spacing.md }}>
        {grouped.map(({ group, entries }, groupIndex) => (
          <FortuneMenuGroup
            key={group.id}
            group={group}
            entries={entries}
            groupIndex={groupIndex}
            highlight={message.highlightGroupId === group.id}
            preselectedFortuneTypeId={message.preselectedFortuneTypeId}
            onSelect={onSelect}
            reducedMotion={reducedMotion}
          />
        ))}
      </Card>
    </View>
  );
}

function FortuneMenuGroup({
  group,
  entries,
  groupIndex,
  highlight,
  preselectedFortuneTypeId,
  onSelect,
  reducedMotion,
}: {
  group: FortuneCatalogGroup;
  entries: FortuneCatalogEntry[];
  groupIndex: number;
  highlight: boolean;
  preselectedFortuneTypeId?: string;
  onSelect: (entry: FortuneCatalogEntry) => void;
  reducedMotion: boolean;
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.xs }}>
      <AppText
        variant="labelLarge"
        color={
          highlight
            ? fortuneTheme.colors.accentSecondary
            : fortuneTheme.colors.textSecondary
        }
      >
        {group.label}
      </AppText>
      {entries.map((entry, idx) => {
        // group 단위로 stagger reset — 첫 그룹부터 entry 0,1,2... 가 stagger.
        // 다른 그룹끼리는 동시에 페이드인 (그룹별 max MAX_STAGGER_ROWS 까지만 stagger).
        const staggerIndex = Math.min(idx, MAX_STAGGER_ROWS);
        return (
          <FortuneMenuEntryRow
            key={entry.id}
            entry={entry}
            staggerIndex={staggerIndex}
            groupIndex={groupIndex}
            isPreselected={preselectedFortuneTypeId === entry.id}
            onSelect={onSelect}
            reducedMotion={reducedMotion}
          />
        );
      })}
    </View>
  );
}

function FortuneMenuEntryRow({
  entry,
  staggerIndex,
  groupIndex,
  isPreselected,
  onSelect,
  reducedMotion,
}: {
  entry: FortuneCatalogEntry;
  staggerIndex: number;
  groupIndex: number;
  isPreselected: boolean;
  onSelect: (entry: FortuneCatalogEntry) => void;
  reducedMotion: boolean;
}) {
  const opacity = useAnimatedValue(reducedMotion ? 1 : 0);
  const translateY = useAnimatedValue(reducedMotion ? 0 : 6);
  const mounted = useRef(false);

  useEffect(() => {
    if (mounted.current) return;
    mounted.current = true;
    if (reducedMotion) return;

    const delay = (groupIndex * 100) + (staggerIndex * STAGGER_DELAY_MS);
    Animated.parallel([
      Animated.timing(opacity, {
        toValue: 1,
        duration: ROW_DURATION_MS,
        delay,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
      Animated.timing(translateY, {
        toValue: 0,
        duration: ROW_DURATION_MS,
        delay,
        easing: Easing.out(Easing.quad),
        useNativeDriver: true,
      }),
    ]).start();
  }, [opacity, translateY, staggerIndex, groupIndex, reducedMotion]);

  return (
    <Animated.View style={{ opacity, transform: [{ translateY }] }}>
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={`${entry.displayName}, ${entry.costPoints} 포인트`}
        onPress={() => onSelect(entry)}
        style={({ pressed }) => ({
          backgroundColor: isPreselected
            ? fortuneTheme.colors.accentTertiary
            : fortuneTheme.colors.surfaceSecondary,
          borderRadius: fortuneTheme.radius.lg,
          paddingHorizontal: fortuneTheme.spacing.sm,
          paddingVertical: fortuneTheme.spacing.xs,
          opacity: pressed ? 0.84 : 1,
        })}
      >
        <View
          style={{
            flexDirection: 'row',
            justifyContent: 'space-between',
            alignItems: 'center',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <View style={{ flex: 1, gap: 2 }}>
            <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
              {entry.displayName}
            </AppText>
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {entry.shortDesc}
            </AppText>
          </View>
          <View
            style={{
              backgroundColor: fortuneTheme.colors.backgroundTertiary,
              borderRadius: fortuneTheme.radius.full,
              paddingHorizontal: fortuneTheme.spacing.xs,
              paddingVertical: 2,
            }}
          >
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {entry.costPoints === 0 ? '무료' : `${entry.costPoints}P`}
            </AppText>
          </View>
        </View>
      </Pressable>
    </Animated.View>
  );
}
