/**
 * AllFortunesSheet — 하늘이 "모든 운세" bottom sheet.
 *
 * 디자인:
 *  - chat 위로 슬라이드업하는 modal sheet
 *  - 헤더: "모든 운세" + 닫기 버튼
 *  - 서브: "하늘이 채팅에서 바로 시작"
 *  - 가로 chip 행: 카테고리 필터 (오늘 + FORTUNE_CATALOG_GROUPS)
 *  - 2-열 그리드: 아이콘 + 이름 + 한 줄 설명
 *  - 카드 탭 → onSelect 호출 (호출자가 닫고 다음 액션 dispatch)
 *
 * SoT: FORTUNE_CATALOG (PR-A) — 13 entries × 7 groups + synthetic "오늘".
 */

import { useEffect, useState } from 'react';

import { Ionicons } from '@expo/vector-icons';
import {
  Modal,
  Pressable,
  ScrollView,
  TextInput,
  View,
} from 'react-native';

import {
  FORTUNE_CATALOG,
  FORTUNE_CATALOG_GROUPS,
  type FortuneCatalogEntry,
  type FortuneCatalogGroupId,
} from '@fortune/product-contracts';

import { AppText } from '../../components/app-text';
import { fortuneTheme } from '../../lib/theme';

type SyntheticGroupId = 'today' | 'all';
type SelectableGroupId = FortuneCatalogGroupId | SyntheticGroupId;

interface FilterPill {
  id: SelectableGroupId;
  label: string;
  /** chip bullet 색상. */
  bulletColor: string;
}

const TODAY_FORTUNE_IDS: ReadonlyArray<string> = [
  'daily',
  'biorhythm',
  'lucky-items',
  'fortune-cookie',
];

// 카테고리별 chip 색 — 디자인의 dot 색감과 일치.
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

const FILTER_PILLS: ReadonlyArray<FilterPill> = [
  { id: 'today', label: '오늘', bulletColor: '#F59E0B' },
  ...FORTUNE_CATALOG_GROUPS.map((group) => ({
    id: group.id,
    label: group.label,
    bulletColor: GROUP_BULLET_COLORS[group.id],
  })),
];

// 카탈로그 entry 의 fortune type id → Ionicons 이름. 미지정은 sparkles.
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

function entriesForFilter(
  filter: SelectableGroupId,
): FortuneCatalogEntry[] {
  if (filter === 'all') {
    return [...FORTUNE_CATALOG];
  }
  if (filter === 'today') {
    return FORTUNE_CATALOG.filter((entry) =>
      TODAY_FORTUNE_IDS.includes(entry.id),
    );
  }
  return FORTUNE_CATALOG.filter((entry) => entry.group === filter).slice();
}

export interface AllFortunesSheetProps {
  visible: boolean;
  onClose: () => void;
  onSelect: (entry: FortuneCatalogEntry) => void;
  /** 시트 열릴 때 동기화할 초기 카테고리. quick-actions banner 와 공유. */
  initialCategory?: SelectableGroupId;
}

export function AllFortunesSheet({
  visible,
  onClose,
  onSelect,
  initialCategory = 'today',
}: AllFortunesSheetProps) {
  const [activeFilter, setActiveFilter] =
    useState<SelectableGroupId>(initialCategory);

  // sheet 열릴 때마다 banner 의 활성 카테고리와 동기화.
  useEffect(() => {
    if (visible) setActiveFilter(initialCategory);
  }, [visible, initialCategory]);

  const entries = entriesForFilter(activeFilter);

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent
      onRequestClose={onClose}
    >
      {/* 컨테이너: backdrop 과 sheet 본체를 분리. backdrop 은 absolute Pressable.
          sheet 본체는 일반 View 라 자식 ScrollView 의 horizontal swipe 가 살아 있음.
          이전 onStartShouldSetResponder 패턴은 모든 touch 를 가로채 chip 가로 스크롤 차단. */}
      <View style={{ flex: 1, justifyContent: 'flex-end' }}>
        <Pressable
          onPress={onClose}
          accessibilityRole="button"
          accessibilityLabel="닫기"
          // eslint-disable-next-line react-native/no-inline-styles
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(0,0,0,0.55)',
          }}
        />
        <View
          // eslint-disable-next-line react-native/no-inline-styles
          style={{
            backgroundColor: fortuneTheme.colors.surface,
            borderTopLeftRadius: fortuneTheme.radius.xl,
            borderTopRightRadius: fortuneTheme.radius.xl,
            paddingTop: fortuneTheme.spacing.sm,
            paddingHorizontal: fortuneTheme.spacing.md,
            paddingBottom: fortuneTheme.spacing.xl,
            // 사용자 결정: 컨텐츠 양과 무관하게 고정 높이. 아래쪽 여백 남는 건 OK.
            height: 620,
          }}
        >
          {/* drag handle */}
          <View
            style={{
              alignSelf: 'center',
              width: 40,
              height: 4,
              borderRadius: 2,
              backgroundColor: fortuneTheme.colors.borderOpaque,
              marginBottom: fortuneTheme.spacing.md,
            }}
          />

          {/* 헤더 */}
          <View
            style={{
              flexDirection: 'row',
              alignItems: 'flex-start',
              justifyContent: 'space-between',
              marginBottom: fortuneTheme.spacing.sm,
            }}
          >
            <View style={{ flex: 1, gap: 4 }}>
              <AppText
                variant="heading2"
                color={fortuneTheme.colors.textPrimary}
              >
                모든 인사이트
              </AppText>
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
              >
                하늘이 채팅에서 바로 시작
              </AppText>
            </View>
            <Pressable
              onPress={onClose}
              accessibilityRole="button"
              accessibilityLabel="닫기"
              hitSlop={12}
            >
              <AppText
                variant="bodyMedium"
                color={fortuneTheme.colors.textSecondary}
              >
                닫기
              </AppText>
            </Pressable>
          </View>

          {/* 카테고리 chip 가로 스크롤. alignItems:'center' 없으면 부모 고정
              높이 + ScrollView 디폴트 stretch 로 chip 이 세로로 늘어남. */}
          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{
              gap: fortuneTheme.spacing.xs,
              paddingVertical: fortuneTheme.spacing.xs,
              alignItems: 'center',
            }}
            style={{
              marginBottom: fortuneTheme.spacing.sm,
              flexGrow: 0,
              flexShrink: 0,
            }}
          >
            {FILTER_PILLS.map((pill) => {
              const isActive = activeFilter === pill.id;
              return (
                <Pressable
                  key={pill.id}
                  onPress={() => setActiveFilter(pill.id)}
                  accessibilityRole="tab"
                  accessibilityState={{ selected: isActive }}
                  accessibilityLabel={pill.label}
                  style={({ pressed }) => ({
                    flexDirection: 'row',
                    alignItems: 'center',
                    gap: 6,
                    paddingHorizontal: fortuneTheme.spacing.md,
                    paddingVertical: 8,
                    borderRadius: fortuneTheme.radius.full,
                    borderWidth: 1,
                    borderColor: isActive
                      ? pill.bulletColor
                      : fortuneTheme.colors.borderOpaque,
                    backgroundColor: isActive
                      ? `${pill.bulletColor}22`
                      : 'transparent',
                    opacity: pressed ? 0.84 : 1,
                  })}
                >
                  <View
                    style={{
                      width: 6,
                      height: 6,
                      borderRadius: 3,
                      backgroundColor: pill.bulletColor,
                    }}
                  />
                  <AppText
                    variant="labelMedium"
                    color={
                      isActive
                        ? fortuneTheme.colors.textPrimary
                        : fortuneTheme.colors.textSecondary
                    }
                  >
                    {pill.label}
                  </AppText>
                </Pressable>
              );
            })}
          </ScrollView>

          {/* 2열 grid */}
          <ScrollView
            showsVerticalScrollIndicator={false}
            contentContainerStyle={{
              paddingBottom: fortuneTheme.spacing.lg,
            }}
          >
            <View
              style={{
                flexDirection: 'row',
                flexWrap: 'wrap',
                gap: fortuneTheme.spacing.sm,
              }}
            >
              {entries.length === 0 ? (
                <View style={{ width: '100%', paddingVertical: fortuneTheme.spacing.lg }}>
                  <AppText
                    variant="bodyMedium"
                    color={fortuneTheme.colors.textSecondary}
                    style={{ textAlign: 'center' }}
                  >
                    이 카테고리는 아직 비어 있어요
                  </AppText>
                </View>
              ) : (
                entries.map((entry) => (
                  <FortuneGridCard
                    key={entry.id}
                    entry={entry}
                    onPress={() => {
                      onSelect(entry);
                    }}
                  />
                ))
              )}
            </View>
          </ScrollView>
        </View>
      </View>
    </Modal>
  );
}

function FortuneGridCard({
  entry,
  onPress,
}: {
  entry: FortuneCatalogEntry;
  onPress: () => void;
}) {
  const iconName = iconForFortune(entry.id);
  return (
    <Pressable
      onPress={onPress}
      accessibilityRole="button"
      accessibilityLabel={`${entry.displayName}, ${
        entry.costPoints === 0 ? '무료' : `${entry.costPoints} 포인트`
      }`}
      style={({ pressed }) => ({
        flexBasis: '48%',
        flexGrow: 1,
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderRadius: fortuneTheme.radius.lg,
        padding: fortuneTheme.spacing.md,
        gap: fortuneTheme.spacing.xs,
        opacity: pressed ? 0.84 : 1,
        minHeight: 120,
      })}
    >
      <View
        style={{
          width: 36,
          height: 36,
          borderRadius: 10,
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          borderWidth: 1,
          borderColor: fortuneTheme.colors.accentTertiary,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <Ionicons
          name={iconName}
          size={20}
          color={fortuneTheme.colors.accentTertiary}
        />
      </View>
      <AppText
        variant="labelLarge"
        color={fortuneTheme.colors.textPrimary}
      >
        {entry.displayName}
      </AppText>
      <AppText
        variant="bodySmall"
        color={fortuneTheme.colors.textSecondary}
        numberOfLines={2}
      >
        {entry.shortDesc}
      </AppText>
      {entry.costPoints > 0 ? (
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textTertiary}
        >
          {entry.costPoints}P
        </AppText>
      ) : null}
    </Pressable>
  );
}
