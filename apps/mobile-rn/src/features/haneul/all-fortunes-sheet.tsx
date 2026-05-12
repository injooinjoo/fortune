/**
 * AllFortunesSheet — 하늘이 "모든 운세" hero carousel bottom sheet.
 *
 * Claude Design handoff: haneul/Haneul Fortune Picker - Redesign.html
 * Selected direction: B · Strong-fit — Hero Carousel
 *  - 82% bottom sheet
 *  - minimal category pills
 *  - 1.1-up horizontal swipe deck
 *  - large glyph / category ambient scene / minimal copy
 */

import { useEffect, useMemo, useRef, useState } from 'react';

import { Ionicons } from '@expo/vector-icons';
import {
  Animated,
  Modal,
  NativeScrollEvent,
  NativeSyntheticEvent,
  Pressable,
  ScrollView,
  useWindowDimensions,
  View,
} from 'react-native';
import Svg, {
  Circle,
  Defs,
  G,
  Line,
  Path,
  RadialGradient,
  Rect,
  Stop,
} from 'react-native-svg';

import {
  FORTUNE_CATALOG,
  FORTUNE_CATALOG_GROUPS,
  type FortuneCatalogEntry,
  type FortuneCatalogGroupId,
  type FortuneTypeId,
} from '@fortune/product-contracts';

import { AppText } from '../../components/app-text';
import { fortuneTheme, withAlpha } from '../../lib/theme';

type SyntheticGroupId = 'today';
type SelectableGroupId = FortuneCatalogGroupId | SyntheticGroupId;

interface FilterPill {
  id: SelectableGroupId;
  label: string;
  /** 시트 안에서는 긴 group label 대신 짧은 라벨을 사용한다. */
  shortLabel: string;
  accent: string;
}

const TODAY_FORTUNE_IDS: readonly FortuneTypeId[] = [
  'daily',
  'biorhythm',
  'lucky-items',
  'fortune-cookie',
];

const GROUP_ACCENTS: Record<FortuneCatalogGroupId, string> = {
  tarot_saju: '#8B7BE8',
  love: '#FF8FB1',
  career_money: '#8FB8FF',
  lifestyle: '#34D399',
  premium_guide: '#E0A76B',
  health: '#F472B6',
  sports_game: '#60A5FA',
  meditation: '#22D3EE',
  personality: '#C9CED6',
  coaching: '#14B8A6',
  past_life: '#DC2626',
};

const GROUP_SHORT_LABELS: Record<FortuneCatalogGroupId, string> = {
  tarot_saju: '사주',
  love: '연애',
  career_money: '커리어',
  lifestyle: '생활',
  premium_guide: '프리미엄',
  health: '건강',
  sports_game: '게임',
  meditation: '명상',
  personality: '나',
  coaching: '코칭',
  past_life: '전생',
};

const FILTER_PILLS: readonly FilterPill[] = [
  { id: 'today', label: '오늘', shortLabel: '오늘', accent: '#FFC86B' },
  ...FORTUNE_CATALOG_GROUPS.map((group) => ({
    id: group.id,
    label: group.label,
    shortLabel: GROUP_SHORT_LABELS[group.id],
    accent: GROUP_ACCENTS[group.id],
  })),
];

const POETIC_COPY: Record<string, string> = {
  daily: '오늘의 흐름을 한 호흡으로',
  biorhythm: '몸과 마음의 리듬을 읽어요',
  'lucky-items': '오늘에 잘 맞는 색과 숫자',
  'fortune-cookie': '짧은 한 줄, 깊은 한 마디',
  tarot: '카드가 비추는 지금',
  'traditional-saju': '타고난 결을 다시 읽다',
  'daily-calendar': '음력과 간지가 비추는 하루',
  naming: '이름에 깃든 기운',
  'new-year': '올해 열두 달의 결',
  love: '끌림과 거리의 결',
  compatibility: '두 사람의 결을 겹쳐서',
  'blind-date': '다음 만남의 타이밍',
  'ex-lover': '지난 마음의 잔향',
  'avoid-people': '조심해야 할 관계의 온도',
  'yearly-encounter': '올해 다가올 인연의 결',
  celebrity: '이상형의 분위기를 읽어요',
  'blind-date-guide': '첫 만남에 어울리는 선택',
  family: '함께 사는 사람들의 결',
  'pet-compatibility': '곁의 생명과 같은 호흡',
  career: '성장과 변화가 어울리는 때',
  exam: '준비와 타이밍이 만나는 곳',
  talent: '타고난 재능의 방향',
  wealth: '돈이 흐르는 길',
  moving: '공간이 바뀌는 운의 흐름',
  'ootd-evaluation': '오늘의 옷차림과 기운',
  birthstone: '태어난 달의 작은 상징',
  'face-reading': '얼굴이 들려주는 이야기',
  'palm-reading': '손금에 남은 길의 흔적',
  'beauty-simulation': '나에게 어울리는 변화',
  'hair-style-guide': '머리결과 인상의 균형',
  'face-reading-guide': '얼굴의 장점을 살리는 길',
  'ootd-guide': '오늘의 분위기를 입어요',
  'past-life-guide': '다른 시간선의 단서',
  wish: '마음 속 한 가지',
  health: '몸이 보내는 조용한 신호',
  exercise: '오늘 몸에 맞는 움직임',
  'match-insight': '경기의 흐름을 읽는 감각',
  'game-enhance': '운과 판단이 만나는 순간',
  breathing: '한 호흡 느리게 돌아오기',
  'personality-dna': '내 안의 반복되는 결',
  mbti: '오늘의 나를 위한 한 마디',
  'blood-type': '가볍게 보는 성향의 온도',
  'zodiac-animal': '띠가 품은 오래된 상징',
  coaching: '지금 필요한 방향 정리',
  'daily-review': '어제와 오늘, 잔잔한 비교',
  'weekly-review': '이번 주의 리듬을 돌아봐요',
  decision: '갈림길 위에 앉아서',
  'past-life': '다른 시간선의 나',
};

function iconForFortune(id: string): keyof typeof Ionicons.glyphMap {
  const map: Record<string, keyof typeof Ionicons.glyphMap> = {
    daily: 'sunny-outline',
    tarot: 'albums-outline',
    'traditional-saju': 'grid-outline',
    'daily-calendar': 'calendar-outline',
    naming: 'create-outline',
    'new-year': 'star-outline',
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
    career: 'briefcase-outline',
    exam: 'school-outline',
    talent: 'rocket-outline',
    wealth: 'cash-outline',
    moving: 'business-outline',
    'lucky-items': 'gift-outline',
    'ootd-evaluation': 'shirt-outline',
    'fortune-cookie': 'sparkles-outline',
    birthstone: 'diamond-outline',
    'face-reading': 'eye-outline',
    'palm-reading': 'hand-left-outline',
    'beauty-simulation': 'color-wand-outline',
    'hair-style-guide': 'cut-outline',
    'face-reading-guide': 'happy-outline',
    'ootd-guide': 'shirt-outline',
    'past-life-guide': 'time-outline',
    wish: 'flash-outline',
    health: 'heart-circle-outline',
    biorhythm: 'pulse-outline',
    exercise: 'barbell-outline',
    'match-insight': 'trophy-outline',
    'game-enhance': 'game-controller-outline',
    breathing: 'leaf-outline',
    'personality-dna': 'person-outline',
    mbti: 'text-outline',
    'blood-type': 'water-outline',
    'zodiac-animal': 'globe-outline',
    coaching: 'compass-outline',
    'daily-review': 'moon-outline',
    'weekly-review': 'calendar-clear-outline',
    decision: 'options-outline',
    'past-life': 'infinite-outline',
  };
  return map[id] ?? 'sparkles-outline';
}

const GROUP_ORDER = new Map<FortuneCatalogGroupId, number>(
  FORTUNE_CATALOG_GROUPS.map((group, index) => [group.id, index]),
);

function allCarouselEntries(): FortuneCatalogEntry[] {
  const byId = new Map(FORTUNE_CATALOG.map((entry) => [entry.id, entry]));
  const todayEntries: FortuneCatalogEntry[] = [];

  for (const id of TODAY_FORTUNE_IDS) {
    const entry = byId.get(id);
    if (entry) todayEntries.push(entry);
  }

  const todaySet = new Set(TODAY_FORTUNE_IDS);
  const restEntries = FORTUNE_CATALOG.filter((entry) => !todaySet.has(entry.id))
    .slice()
    .sort((a, b) => {
      const groupDelta =
        (GROUP_ORDER.get(a.group) ?? 999) - (GROUP_ORDER.get(b.group) ?? 999);
      if (groupDelta !== 0) return groupDelta;
      return a.order - b.order;
    });

  return [...todayEntries, ...restEntries];
}

function filterForCarouselIndex(
  entries: readonly FortuneCatalogEntry[],
  index: number,
): SelectableGroupId {
  const entry = entries[index];
  if (!entry) return 'today';
  return TODAY_FORTUNE_IDS.includes(entry.id) ? 'today' : entry.group;
}

function firstIndexForFilter(
  entries: readonly FortuneCatalogEntry[],
  filter: SelectableGroupId,
): number {
  if (filter === 'today') return 0;
  const index = entries.findIndex((entry) => entry.group === filter);
  return index >= 0 ? index : 0;
}

function pillForFilter(filter: SelectableGroupId): FilterPill {
  return FILTER_PILLS.find((pill) => pill.id === filter) ?? FILTER_PILLS[0];
}

function pillForEntry(entry: FortuneCatalogEntry): FilterPill {
  return FILTER_PILLS.find((pill) => pill.id === entry.group) ?? FILTER_PILLS[0];
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
  const { width, height } = useWindowDimensions();
  const scrollRef = useRef<ScrollView | null>(null);
  const scrollX = useRef(new Animated.Value(0)).current;
  const [activeIndex, setActiveIndex] = useState(0);
  const [activeFilter, setActiveFilter] =
    useState<SelectableGroupId>(initialCategory);

  const entries = useMemo(() => allCarouselEntries(), []);
  const currentPill = pillForFilter(activeFilter);
  const sheetHeight = Math.min(Math.round(height * 0.82), 720);
  const cardWidth = Math.min(Math.round(width * 0.62), 252);
  const cardHeight = Math.min(Math.round(sheetHeight * 0.49), 348);
  const cardGap = fortuneTheme.spacing.md;
  const snapInterval = cardWidth + cardGap;
  const sideInset = Math.max(22, (width - cardWidth) / 2);

  useEffect(() => {
    if (!visible) return;
    const nextIndex = firstIndexForFilter(entries, initialCategory);
    const nextX = nextIndex * snapInterval;
    setActiveIndex(nextIndex);
    setActiveFilter(filterForCarouselIndex(entries, nextIndex));
    scrollX.setValue(nextX);
    requestAnimationFrame(() =>
      scrollRef.current?.scrollTo({ x: nextX, animated: false }),
    );
  }, [visible, initialCategory, entries, snapInterval, scrollX]);

  const updateActiveIndexFromOffset = (offsetX: number) => {
    const nextIndex = Math.max(
      0,
      Math.min(entries.length - 1, Math.round(offsetX / snapInterval)),
    );
    setActiveIndex(nextIndex);
    setActiveFilter(filterForCarouselIndex(entries, nextIndex));
  };

  const onCarouselScrollEnd = (event: NativeSyntheticEvent<NativeScrollEvent>) => {
    updateActiveIndexFromOffset(event.nativeEvent.contentOffset.x);
  };

  return (
    <Modal
      visible={visible}
      animationType="slide"
      transparent
      onRequestClose={onClose}
    >
      <View style={{ flex: 1, justifyContent: 'flex-end' }}>
        <Pressable
          onPress={onClose}
          accessibilityRole="button"
          accessibilityLabel="닫기"
          style={{
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(0,0,0,0.65)',
          }}
        />
        <View
          style={{
            height: sheetHeight,
            backgroundColor: '#0B0B10',
            borderTopLeftRadius: 28,
            borderTopRightRadius: 28,
            borderTopWidth: 1,
            borderTopColor: fortuneTheme.colors.borderOpaque,
            overflow: 'hidden',
          }}
        >
          <AmbientHalo accent={currentPill.accent} />

          <View style={{ alignItems: 'center', paddingTop: 10, paddingBottom: 4 }}>
            <View
              style={{
                width: 36,
                height: 4,
                borderRadius: 2,
                backgroundColor: 'rgba(255,255,255,0.22)',
              }}
            />
          </View>

          <View
            style={{
              flexDirection: 'row',
              alignItems: 'center',
              justifyContent: 'space-between',
              paddingHorizontal: 22,
              paddingTop: 6,
              paddingBottom: 12,
            }}
          >
            <View style={{ flexDirection: 'row', alignItems: 'center', gap: 10 }}>
              <View
                style={{
                  width: 28,
                  height: 28,
                  borderRadius: 14,
                  alignItems: 'center',
                  justifyContent: 'center',
                  backgroundColor: withAlpha(currentPill.accent, 0.18),
                  borderWidth: 1,
                  borderColor: withAlpha(currentPill.accent, 0.42),
                }}
              >
                <Ionicons name="sparkles-outline" size={15} color={currentPill.accent} />
              </View>
              <View>
                <AppText variant="labelLarge" color={fortuneTheme.colors.textPrimary}>
                  운세 펼치기
                </AppText>
                <AppText
                  variant="labelSmall"
                  color={fortuneTheme.colors.textTertiary}
                  style={{ marginTop: 1 }}
                >
                  좌우로 넘겨 골라보세요
                </AppText>
              </View>
            </View>
            <Pressable
              onPress={onClose}
              accessibilityRole="button"
              accessibilityLabel="닫기"
              hitSlop={8}
              style={({ pressed }) => ({
                width: 32,
                height: 32,
                borderRadius: 16,
                alignItems: 'center',
                justifyContent: 'center',
                backgroundColor: 'rgba(255,255,255,0.06)',
                borderWidth: 1,
                borderColor: fortuneTheme.colors.borderOpaque,
                opacity: pressed ? 0.78 : 1,
              })}
            >
              <Ionicons name="close" size={16} color={fortuneTheme.colors.textSecondary} />
            </Pressable>
          </View>

          <ScrollView
            horizontal
            showsHorizontalScrollIndicator={false}
            contentContainerStyle={{
              gap: 6,
              paddingHorizontal: 22,
              paddingBottom: 16,
            }}
            style={{ flexGrow: 0, flexShrink: 0 }}
          >
            {FILTER_PILLS.map((pill) => {
              const isActive = activeFilter === pill.id;
              return (
                <Pressable
                  key={pill.id}
                  onPress={() => {
                    const nextIndex = firstIndexForFilter(entries, pill.id);
                    const nextX = nextIndex * snapInterval;
                    setActiveIndex(nextIndex);
                    setActiveFilter(filterForCarouselIndex(entries, nextIndex));
                    scrollRef.current?.scrollTo({ x: nextX, animated: true });
                  }}
                  accessibilityRole="tab"
                  accessibilityState={{ selected: isActive }}
                  accessibilityLabel={pill.label}
                  hitSlop={{ top: 8, bottom: 8, left: 4, right: 4 }}
                  style={({ pressed }) => ({
                    minHeight: 28,
                    paddingHorizontal: 12,
                    borderRadius: fortuneTheme.radius.full,
                    borderWidth: 1,
                    borderColor: isActive
                      ? 'rgba(255,255,255,0.16)'
                      : 'transparent',
                    backgroundColor: isActive ? 'rgba(255,255,255,0.10)' : 'transparent',
                    flexDirection: 'row',
                    alignItems: 'center',
                    gap: 6,
                    opacity: pressed ? 0.78 : 1,
                  })}
                >
                  <View
                    style={{
                      width: 5,
                      height: 5,
                      borderRadius: 3,
                      backgroundColor: pill.accent,
                    }}
                  />
                  <AppText
                    variant="labelSmall"
                    color={
                      isActive
                        ? fortuneTheme.colors.textPrimary
                        : fortuneTheme.colors.textSecondary
                    }
                  >
                    {pill.shortLabel}
                  </AppText>
                </Pressable>
              );
            })}
          </ScrollView>

          <View style={{ flex: 1, justifyContent: 'center' }}>
            {entries.length === 0 ? (
              <View style={{ paddingHorizontal: 22, alignItems: 'center' }}>
                <AppText variant="bodyMedium" color={fortuneTheme.colors.textSecondary}>
                  이 카테고리는 아직 비어 있어요
                </AppText>
              </View>
            ) : (
              <Animated.ScrollView
                ref={scrollRef}
                horizontal
                showsHorizontalScrollIndicator={false}
                snapToInterval={snapInterval}
                decelerationRate="fast"
                onScroll={Animated.event(
                  [{ nativeEvent: { contentOffset: { x: scrollX } } }],
                  { useNativeDriver: true },
                )}
                onMomentumScrollEnd={onCarouselScrollEnd}
                onScrollEndDrag={onCarouselScrollEnd}
                scrollEventThrottle={16}
                contentContainerStyle={{
                  alignItems: 'center',
                  gap: cardGap,
                  paddingHorizontal: sideInset,
                }}
              >
                {entries.map((entry, index) => {
                  const isActive = index === activeIndex;
                  return (
                    <HeroFortuneCard
                      key={entry.id}
                      entry={entry}
                      width={cardWidth}
                      height={cardHeight}
                      scrollX={scrollX}
                      index={index}
                      snapInterval={snapInterval}
                      active={isActive}
                      onPress={() => {
                        if (isActive) {
                          onSelect(entry);
                          return;
                        }
                        scrollRef.current?.scrollTo({
                          x: index * snapInterval,
                          animated: true,
                        });
                        setActiveIndex(index);
                        setActiveFilter(filterForCarouselIndex(entries, index));
                      }}
                    />
                  );
                })}
              </Animated.ScrollView>
            )}
          </View>

          {entries.length > 0 ? (
            <View
              style={{
                alignItems: 'center',
                gap: 12,
                paddingHorizontal: 22,
                paddingTop: 14,
                paddingBottom: 26,
              }}
            >
              <PaginationDots
                total={entries.length}
                activeIndex={activeIndex}
                accent={currentPill.accent}
              />
              <AppText
                variant="labelSmall"
                color={fortuneTheme.colors.textTertiary}
                style={{ letterSpacing: 1.2 }}
              >
                <AppText variant="labelSmall" color={fortuneTheme.colors.textSecondary}>
                  {String(activeIndex + 1).padStart(2, '0')}
                </AppText>
                {'  /  '}
                {String(entries.length).padStart(2, '0')}
              </AppText>
            </View>
          ) : null}
        </View>
      </View>
    </Modal>
  );
}

function AmbientHalo({ accent }: { accent: string }) {
  return (
    <View
      pointerEvents="none"
      style={{
        position: 'absolute',
        top: -70,
        left: -40,
        right: -40,
        height: 280,
      }}
    >
      <Svg width="100%" height="100%">
        <Defs>
          <RadialGradient id="sheetHalo" cx="50%" cy="18%" r="62%">
            <Stop offset="0%" stopColor={accent} stopOpacity={0.34} />
            <Stop offset="58%" stopColor={accent} stopOpacity={0.08} />
            <Stop offset="100%" stopColor="#0B0B10" stopOpacity={0} />
          </RadialGradient>
        </Defs>
        <Rect x="0" y="0" width="100%" height="100%" fill="url(#sheetHalo)" />
      </Svg>
    </View>
  );
}

function HeroFortuneCard({
  entry,
  width,
  height,
  scrollX,
  index,
  snapInterval,
  active,
  onPress,
}: {
  entry: FortuneCatalogEntry;
  width: number;
  height: number;
  scrollX: Animated.Value;
  index: number;
  snapInterval: number;
  active: boolean;
  onPress: () => void;
}) {
  const category = pillForEntry(entry);
  const iconName = iconForFortune(entry.id);
  const subtitle = POETIC_COPY[entry.id] ?? entry.shortDesc;
  const inputRange = [
    (index - 1) * snapInterval,
    index * snapInterval,
    (index + 1) * snapInterval,
  ];
  const scale = scrollX.interpolate({
    inputRange,
    outputRange: [0.88, 1, 0.88],
    extrapolate: 'clamp',
  });
  const opacity = scrollX.interpolate({
    inputRange,
    outputRange: [0.58, 1, 0.58],
    extrapolate: 'clamp',
  });
  const translateY = scrollX.interpolate({
    inputRange,
    outputRange: [18, 0, 18],
    extrapolate: 'clamp',
  });

  return (
    <Animated.View
      style={{
        width,
        height,
        opacity,
        transform: [{ translateY }, { scale }],
        shadowColor: category.accent,
        shadowOpacity: 0.26,
        shadowRadius: 28,
        shadowOffset: { width: 0, height: 18 },
      }}
    >
      <Pressable
        onPress={onPress}
        accessibilityRole="button"
        accessibilityLabel={`${entry.displayName}, ${
          entry.costPoints === 0 ? '무료' : `${entry.costPoints} 포인트`
        }`}
        accessibilityHint={
          active ? '운세를 시작합니다' : '이 운세 카드를 가운데로 이동합니다'
        }
        style={({ pressed }) => ({
          width: '100%',
          height: '100%',
          borderRadius: 24,
          overflow: 'hidden',
          borderWidth: 1,
          borderColor: withAlpha(category.accent, 0.44),
          opacity: pressed ? 0.92 : 1,
          backgroundColor: '#15131E',
        })}
      >
      <SceneBackground accent={category.accent} active idSuffix={entry.id} />

      <View
        style={{
          position: 'absolute',
          top: 22,
          left: 22,
          minHeight: 24,
          paddingHorizontal: 10,
          borderRadius: fortuneTheme.radius.full,
          backgroundColor: 'rgba(0,0,0,0.40)',
          borderWidth: 1,
          borderColor: withAlpha(category.accent, 0.34),
          flexDirection: 'row',
          alignItems: 'center',
          gap: 6,
        }}
      >
        <View
          style={{
            width: 5,
            height: 5,
            borderRadius: 3,
            backgroundColor: category.accent,
          }}
        />
        <AppText variant="labelSmall" color={category.accent}>
          {category.shortLabel}
        </AppText>
      </View>

      <View
        pointerEvents="none"
        style={{
          position: 'absolute',
          top: 24,
          right: 18,
          width: 96,
          height: 96,
          borderRadius: 48,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <Svg width={96} height={96}>
          <Defs>
            <RadialGradient id={`glyphGlow-${entry.id}`} cx="50%" cy="50%" r="50%">
              <Stop offset="0%" stopColor={category.accent} stopOpacity={0.28} />
              <Stop offset="100%" stopColor={category.accent} stopOpacity={0} />
            </RadialGradient>
          </Defs>
          <Circle cx="48" cy="48" r="48" fill={`url(#glyphGlow-${entry.id})`} />
        </Svg>
        <View style={{ position: 'absolute' }}>
          <Ionicons name={iconName} size={54} color={category.accent} />
        </View>
      </View>

      <ElementsRing accent={category.accent} />

      <View
        style={{
          position: 'absolute',
          left: 22,
          right: 22,
          bottom: 24,
          alignItems: 'flex-start',
        }}
      >
        <AppText
          variant="oracleTitle"
          color={fortuneTheme.colors.textPrimary}
          numberOfLines={2}
          style={{ fontSize: 26, lineHeight: 31 }}
        >
          {entry.displayName}
        </AppText>
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
          numberOfLines={2}
          style={{ marginTop: 8, lineHeight: 19 }}
        >
          {subtitle}
        </AppText>
        {entry.costPoints > 0 ? (
          <View
            style={{
              marginTop: 14,
              minHeight: 24,
              paddingHorizontal: 10,
              borderRadius: fortuneTheme.radius.full,
              backgroundColor: 'rgba(255,255,255,0.06)',
              borderWidth: 1,
              borderColor: fortuneTheme.colors.borderOpaque,
              justifyContent: 'center',
            }}
          >
            <AppText variant="labelSmall" color={fortuneTheme.colors.textTertiary}>
              {entry.costPoints}P
            </AppText>
          </View>
        ) : null}
      </View>
      </Pressable>
    </Animated.View>
  );
}

function SceneBackground({
  accent,
  active,
  idSuffix,
}: {
  accent: string;
  active: boolean;
  idSuffix: string;
}) {
  const glowId = `cardGlow-${idSuffix}`;
  const floorId = `cardFloor-${idSuffix}`;

  return (
    <View pointerEvents="none" style={{ position: 'absolute', inset: 0 }}>
      <Svg width="100%" height="100%" preserveAspectRatio="none">
        <Defs>
          <RadialGradient id={glowId} cx="72%" cy="18%" r="90%">
            <Stop offset="0%" stopColor={accent} stopOpacity={active ? 0.34 : 0.22} />
            <Stop offset="42%" stopColor={accent} stopOpacity={0.11} />
            <Stop offset="100%" stopColor="#0B0B10" stopOpacity={0} />
          </RadialGradient>
          <RadialGradient id={floorId} cx="0%" cy="100%" r="80%">
            <Stop offset="0%" stopColor={accent} stopOpacity={0.13} />
            <Stop offset="100%" stopColor="#0B0B10" stopOpacity={0} />
          </RadialGradient>
        </Defs>
        <Rect x="0" y="0" width="100%" height="100%" fill="#15131E" />
        <Rect x="0" y="0" width="100%" height="100%" fill={`url(#${glowId})`} />
        <Rect x="0" y="0" width="100%" height="100%" fill={`url(#${floorId})`} />
        {STAR_POINTS.map((point, index) => (
          <Circle
            key={`${point.x}-${point.y}-${index}`}
            cx={`${point.x}%`}
            cy={`${point.y}%`}
            r={point.r}
            fill="white"
            opacity={active ? point.opacity : point.opacity * 0.7}
          />
        ))}
      </Svg>
    </View>
  );
}

const STAR_POINTS = [
  { x: 11, y: 18, r: 0.7, opacity: 0.25 },
  { x: 24, y: 31, r: 0.9, opacity: 0.32 },
  { x: 48, y: 14, r: 0.6, opacity: 0.3 },
  { x: 68, y: 39, r: 0.8, opacity: 0.28 },
  { x: 82, y: 22, r: 1.1, opacity: 0.38 },
  { x: 17, y: 62, r: 0.6, opacity: 0.24 },
  { x: 37, y: 72, r: 0.8, opacity: 0.27 },
  { x: 71, y: 68, r: 0.7, opacity: 0.25 },
  { x: 90, y: 82, r: 0.9, opacity: 0.3 },
] as const;

function ElementsRing({ accent }: { accent: string }) {
  return (
    <View
      pointerEvents="none"
      style={{
        position: 'absolute',
        left: -44,
        bottom: -48,
        opacity: 0.16,
      }}
    >
      <Svg width={180} height={180} viewBox="0 0 180 180">
        <G stroke={accent} strokeWidth={1} fill="none">
          <Circle cx="90" cy="90" r="48" />
          <Circle cx="90" cy="90" r="68" opacity={0.6} />
          {Array.from({ length: 12 }).map((_, index) => {
            const angle = (Math.PI * 2 * index) / 12;
            const x1 = 90 + Math.cos(angle) * 56;
            const y1 = 90 + Math.sin(angle) * 56;
            const x2 = 90 + Math.cos(angle) * 76;
            const y2 = 90 + Math.sin(angle) * 76;
            return (
              <Line
                key={index}
                x1={x1}
                y1={y1}
                x2={x2}
                y2={y2}
                opacity={0.55}
              />
            );
          })}
          <Path d="M90 30 L105 82 L158 90 L105 98 L90 150 L75 98 L22 90 L75 82 Z" opacity={0.38} />
        </G>
      </Svg>
    </View>
  );
}

function PaginationDots({
  total,
  activeIndex,
  accent,
}: {
  total: number;
  activeIndex: number;
  accent: string;
}) {
  return (
    <View style={{ flexDirection: 'row', gap: 5, alignItems: 'center' }}>
      {Array.from({ length: total }).map((_, index) => (
        <View
          key={index}
          style={{
            width: index === activeIndex ? 18 : 5,
            height: 5,
            borderRadius: 3,
            backgroundColor:
              index === activeIndex ? accent : 'rgba(255,255,255,0.18)',
          }}
        />
      ))}
    </View>
  );
}
