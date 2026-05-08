/**
 * HaneulQuickActions — 하늘이 채팅 위에 떠 있는 카테고리 탭 + 빠른 액션 chips.
 *
 * 디자인:
 *  - 상단: 가로 스크롤 카테고리 탭 (오늘 + FORTUNE_CATALOG_GROUPS, 컬러 dot)
 *  - 하단: 활성 카테고리의 상위 entries (최대 4개) + "+ 전체 보기" (dashed)
 *  - "+ 전체 보기" 탭 → AllFortunesSheet 열기
 *  - entry 탭 → onSelect (chat-screen 의 cost modal 흐름)
 *
 * SoT: FORTUNE_CATALOG (PR-A).
 */

import { useMemo } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { Pressable, ScrollView, View } from 'react-native';

import {
  FORTUNE_CATALOG,
  FORTUNE_CATALOG_GROUPS,
  type FortuneCatalogEntry,
  type FortuneCatalogGroupId,
} from '@fortune/product-contracts';

import { AppText } from '../../components/app-text';
import { fortuneTheme } from '../../lib/theme';

type SyntheticGroupId = 'today';
export type HaneulCategoryId = FortuneCatalogGroupId | SyntheticGroupId;

const TODAY_FORTUNE_IDS: ReadonlyArray<string> = [
  'daily',
  'biorhythm',
  'lucky-items',
  'fortune-cookie',
];

const GROUP_BULLET_COLORS: Record<FortuneCatalogGroupId, string> = {
  tarot_saju: '#A78BFA',
  love: '#EC4899',
  career_money: '#FBBF24',
  lifestyle: '#34D399',
  premium_guide: '#F59E0B',
  health: '#F472B6',
  sports_game: '#60A5FA',
  meditation: '#22D3EE',
  personality: '#C084FC',
  coaching: '#14B8A6',
  past_life: '#DC2626',
};

interface CategoryTab {
  id: HaneulCategoryId;
  label: string;
  bullet: string;
}

const CATEGORY_TABS: ReadonlyArray<CategoryTab> = [
  { id: 'today', label: '오늘', bullet: '#F59E0B' },
  ...FORTUNE_CATALOG_GROUPS.map((g) => ({
    id: g.id,
    label: g.label,
    bullet: GROUP_BULLET_COLORS[g.id],
  })),
];

function iconForFortune(id: string): keyof typeof Ionicons.glyphMap {
  const map: Record<string, keyof typeof Ionicons.glyphMap> = {
    // tarot_saju
    daily: 'sunny-outline',
    tarot: 'albums-outline',
    'traditional-saju': 'grid-outline',
    'daily-calendar': 'calendar-outline',
    naming: 'create-outline',
    'new-year': 'star-outline',
    // love
    love: 'heart-outline',
    compatibility: 'people-outline',
    'blind-date': 'cafe-outline',
    'ex-lover': 'arrow-undo-outline',
    'avoid-people': 'shield-outline',
    'yearly-encounter': 'sparkles-outline',
    celebrity: 'star-half-outline',
    'blind-date-guide': 'shirt-outline',
    family: 'home-outline',
    'pet-compatibility': 'paw-outline',
    // career_money
    career: 'briefcase-outline',
    exam: 'school-outline',
    talent: 'rocket-outline',
    wealth: 'cash-outline',
    // lifestyle
    moving: 'business-outline',
    'lucky-items': 'gift-outline',
    'ootd-evaluation': 'shirt-outline',
    'fortune-cookie': 'sparkles-outline',
    birthstone: 'diamond-outline',
    // premium_guide
    'face-reading': 'eye-outline',
    'palm-reading': 'hand-left-outline',
    'beauty-simulation': 'color-wand-outline',
    'hair-style-guide': 'cut-outline',
    'face-reading-guide': 'happy-outline',
    'ootd-guide': 'shirt-outline',
    'past-life-guide': 'time-outline',
    wish: 'flash-outline',
    // health
    health: 'heart-circle-outline',
    biorhythm: 'pulse-outline',
    exercise: 'barbell-outline',
    // sports_game
    'match-insight': 'trophy-outline',
    'game-enhance': 'game-controller-outline',
    // meditation
    breathing: 'leaf-outline',
    // personality
    'personality-dna': 'person-outline',
    mbti: 'text-outline',
    'blood-type': 'water-outline',
    'zodiac-animal': 'globe-outline',
    // coaching
    coaching: 'compass-outline',
    'daily-review': 'moon-outline',
    'weekly-review': 'calendar-clear-outline',
    decision: 'options-outline',
    // past_life
    'past-life': 'infinite-outline',
  };
  return map[id] ?? 'sparkles-outline';
}

const MAX_CHIPS_PER_CATEGORY = 4;

function entriesForCategory(category: HaneulCategoryId): FortuneCatalogEntry[] {
  if (category === 'today') {
    const ordered: FortuneCatalogEntry[] = [];
    for (const id of TODAY_FORTUNE_IDS) {
      const found = FORTUNE_CATALOG.find((e) => e.id === id);
      if (found) ordered.push(found);
    }
    return ordered.slice(0, MAX_CHIPS_PER_CATEGORY);
  }
  return FORTUNE_CATALOG.filter((e) => e.group === category)
    .slice()
    .sort((a, b) => a.order - b.order)
    .slice(0, MAX_CHIPS_PER_CATEGORY);
}

export interface HaneulQuickActionsProps {
  activeCategory: HaneulCategoryId;
  onChangeCategory: (category: HaneulCategoryId) => void;
  onSelectEntry: (entry: FortuneCatalogEntry) => void;
  onOpenAllFortunes: () => void;
}

export function HaneulQuickActions({
  activeCategory,
  onChangeCategory,
  onSelectEntry,
  onOpenAllFortunes,
}: HaneulQuickActionsProps) {
  const entries = useMemo(
    () => entriesForCategory(activeCategory),
    [activeCategory],
  );

  return (
    <View
      style={{
        gap: fortuneTheme.spacing.xs,
        paddingHorizontal: fortuneTheme.spacing.md,
        paddingTop: fortuneTheme.spacing.xs,
        paddingBottom: fortuneTheme.spacing.sm,
        borderBottomWidth: 1,
        borderBottomColor: fortuneTheme.colors.borderOpaque,
      }}
    >
      {/* 카테고리 탭 (가로 스크롤) */}
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{
          gap: fortuneTheme.spacing.md,
          paddingVertical: 4,
        }}
      >
        {CATEGORY_TABS.map((tab) => {
          const isActive = activeCategory === tab.id;
          return (
            <Pressable
              key={tab.id}
              onPress={() => onChangeCategory(tab.id)}
              accessibilityRole="tab"
              accessibilityState={{ selected: isActive }}
              accessibilityLabel={tab.label}
              style={({ pressed }) => ({
                flexDirection: 'row',
                alignItems: 'center',
                gap: 6,
                opacity: pressed ? 0.84 : 1,
              })}
            >
              <View
                style={{
                  width: 8,
                  height: 8,
                  borderRadius: 4,
                  backgroundColor: tab.bullet,
                }}
              />
              <AppText
                variant="labelMedium"
                color={
                  isActive
                    ? fortuneTheme.colors.textPrimary
                    : fortuneTheme.colors.textSecondary
                }
                style={
                  isActive
                    ? { textDecorationLine: 'underline' }
                    : undefined
                }
              >
                {tab.label}
              </AppText>
            </Pressable>
          );
        })}
      </ScrollView>

      {/* quick-action chips: ScrollView (entries) + 우측 고정 "전체 보기" pill.
          항상 우측에 보이도록 ScrollView 밖에 둔다 (스크롤로 가려지지 않음). */}
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          gap: fortuneTheme.spacing.xs,
          paddingVertical: 4,
        }}
      >
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={{
            gap: fortuneTheme.spacing.xs,
            paddingRight: fortuneTheme.spacing.xs,
          }}
          style={{ flexShrink: 1, flexGrow: 1 }}
        >
          {entries.map((entry) => (
            <Pressable
              key={entry.id}
              onPress={() => onSelectEntry(entry)}
              accessibilityRole="button"
              accessibilityLabel={`${entry.displayName}, ${
                entry.costPoints === 0 ? '무료' : `${entry.costPoints} 포인트`
              }`}
              style={({ pressed }) => ({
                flexDirection: 'row',
                alignItems: 'center',
                gap: 6,
                paddingHorizontal: fortuneTheme.spacing.sm,
                paddingVertical: 8,
                borderRadius: 999,
                borderWidth: 1,
                borderColor: fortuneTheme.colors.borderOpaque,
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                opacity: pressed ? 0.84 : 1,
              })}
            >
              <Ionicons
                name={iconForFortune(entry.id)}
                size={14}
                color={fortuneTheme.colors.accentTertiary}
              />
              <AppText
                variant="labelMedium"
                color={fortuneTheme.colors.textPrimary}
              >
                {entry.displayName}
              </AppText>
            </Pressable>
          ))}
        </ScrollView>

        <Pressable
          onPress={onOpenAllFortunes}
          accessibilityRole="button"
          accessibilityLabel="전체 인사이트 보기"
          style={({ pressed }) => ({
            flexDirection: 'row',
            alignItems: 'center',
            gap: 6,
            paddingHorizontal: fortuneTheme.spacing.sm,
            paddingVertical: 8,
            borderRadius: 999,
            borderWidth: 1,
            borderStyle: 'dashed',
            borderColor: fortuneTheme.colors.accentTertiary,
            backgroundColor: 'rgba(245,158,11,0.08)',
            opacity: pressed ? 0.84 : 1,
          })}
        >
          <Ionicons
            name="add"
            size={14}
            color={fortuneTheme.colors.accentTertiary}
          />
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.accentTertiary}
          >
            전체 보기
          </AppText>
        </Pressable>
      </View>
    </View>
  );
}
