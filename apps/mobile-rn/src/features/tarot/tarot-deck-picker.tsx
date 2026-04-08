import { Pressable, ScrollView, View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { Chip } from '../../components/chip';
import { fortuneTheme } from '../../lib/theme';

export interface TarotDeckOption {
  id: string;
  title: string;
  subtitle: string;
  description: string;
  recommendedFor?: readonly string[];
  previewCards?: readonly string[];
}

export const defaultTarotDeckOptions = [
  {
    id: 'rider_waite',
    title: '라이더-웨이트-스미스',
    subtitle: '가장 익숙한 기본 덱',
    description: '직관적인 상징과 읽기 쉬운 구성이 강점인 기본 덱입니다.',
    recommendedFor: ['일반 질문', '연애', '초보자'],
    previewCards: ['00_fool', '01_magician', '17_star'],
  },
  {
    id: 'thoth',
    title: '토트 타로',
    subtitle: '깊은 상징과 해석',
    description: '상징적 층위가 깊어서 심층 해석에 잘 맞는 덱입니다.',
    recommendedFor: ['명상', '심층 분석', '숙련자'],
    previewCards: ['00_fool', '03_empress', '20_judgement'],
  },
  {
    id: 'before_tarot',
    title: '비포 타로',
    subtitle: '원인과 직전의 흐름',
    description: '사건이 일어나기 전의 순간을 읽는 데 강한 덱입니다.',
    recommendedFor: ['과거 분석', '원인 추적', '스토리텔링'],
    previewCards: ['00_fool', '06_lovers', '16_tower'],
  },
  {
    id: 'after_tarot',
    title: '애프터 타로',
    subtitle: '결과와 이후의 흐름',
    description: '사건 이후의 변화와 결과를 읽을 때 좋은 덱입니다.',
    recommendedFor: ['미래 흐름', '결과 분석', '행동의 영향'],
    previewCards: ['00_fool', '10_wheel_of_fortune', '19_sun'],
  },
] as const satisfies readonly TarotDeckOption[];

export function TarotDeckPicker({
  decks = defaultTarotDeckOptions,
  value,
  onChange,
  title = '타로 덱 선택',
  subtitle = '질문의 결에 맞는 덱을 고르세요.',
}: {
  decks?: readonly TarotDeckOption[];
  value: string;
  onChange: (deckId: string) => void;
  title?: string;
  subtitle?: string;
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      <View style={{ gap: 4 }}>
        <AppText variant="heading4">{title}</AppText>
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {subtitle}
        </AppText>
      </View>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={{ gap: fortuneTheme.spacing.sm, paddingRight: 4 }}
      >
        {decks.map((deck) => {
          const selected = deck.id === value;

          return (
            <Pressable
              key={deck.id}
              accessibilityRole="button"
              onPress={() => onChange(deck.id)}
              style={({ pressed }) => ({
                opacity: pressed ? 0.88 : 1,
                transform: [{ scale: pressed ? 0.985 : 1 }],
                width: 248,
              })}
            >
              <Card
                style={{
                  borderColor: selected
                    ? fortuneTheme.colors.ctaBackground
                    : fortuneTheme.colors.border,
                  borderWidth: selected ? 1.5 : 1,
                  gap: fortuneTheme.spacing.sm,
                  minHeight: 180,
                }}
              >
                <View style={{ flexDirection: 'row', justifyContent: 'space-between', gap: 12 }}>
                  <View style={{ flex: 1, gap: 4 }}>
                    <AppText variant="labelLarge">{deck.title}</AppText>
                    <AppText
                      variant="bodySmall"
                      color={fortuneTheme.colors.textSecondary}
                    >
                      {deck.subtitle}
                    </AppText>
                  </View>
                  {selected ? <Chip label="선택됨" tone="accent" /> : null}
                </View>

                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                >
                  {deck.description}
                </AppText>

                {deck.previewCards?.length ? (
                  <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
                    {deck.previewCards.map((card) => (
                      <Chip key={card} label={card} tone="neutral" />
                    ))}
                  </View>
                ) : null}

                {deck.recommendedFor?.length ? (
                  <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
                    {deck.recommendedFor.map((item) => (
                      <Chip key={item} label={item} tone={selected ? 'success' : 'neutral'} />
                    ))}
                  </View>
                ) : null}
              </Card>
            </Pressable>
          );
        })}
      </ScrollView>
    </View>
  );
}
