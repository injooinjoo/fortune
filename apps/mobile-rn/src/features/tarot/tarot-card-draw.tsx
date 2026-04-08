import { useMemo, useState } from 'react';

import { Pressable, ScrollView, View } from 'react-native';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { Chip } from '../../components/chip';
import { PrimaryButton } from '../../components/primary-button';
import { fortuneTheme } from '../../lib/theme';
import {
  buildTarotSelectionPayload,
  getTarotPositionNames,
  resolveTarotCardCount,
  type TarotPurpose,
  type TarotSelectedCard,
  type TarotSelectionPayload,
} from './tarot-payload';

export interface TarotDrawnCard extends TarotSelectedCard {
  slotIndex: number;
}

export interface TarotCardDrawSurfaceProps {
  deckId: string;
  purpose?: TarotPurpose | null;
  questionText?: string | null;
  title?: string;
  subtitle?: string;
  availableCardIndices?: readonly number[];
  slotCount?: number;
  maxCardCount?: number;
  initialSelectedCards?: readonly TarotDrawnCard[];
  onSelectionChange?: (payload: TarotSelectionPayload | null) => void;
  onComplete?: (payload: TarotSelectionPayload) => void;
}

const defaultAvailableCardIndices = Array.from({ length: 78 }, (_, index) => index);

export function TarotCardDrawSurface({
  deckId,
  purpose,
  questionText,
  title = '카드 뽑기',
  subtitle = '펼쳐진 카드 중 하나를 고르고 확정하세요.',
  availableCardIndices = defaultAvailableCardIndices,
  slotCount = 12,
  maxCardCount,
  initialSelectedCards = [],
  onSelectionChange,
  onComplete,
}: TarotCardDrawSurfaceProps) {
  const requiredCardCount = maxCardCount ?? resolveTarotCardCount(purpose);
  const positionNames = useMemo(
    () => getTarotPositionNames(purpose),
    [purpose],
  );
  const [selectedSlotIndex, setSelectedSlotIndex] = useState<number | null>(null);
  const [drawnCards, setDrawnCards] = useState<TarotDrawnCard[]>(
    () => [...initialSelectedCards],
  );
  const [isSubmitting, setIsSubmitting] = useState(false);

  const usedCardIndices = drawnCards.map((card) => card.index);
  const remainingCardIndices = availableCardIndices.filter(
    (index) => !usedCardIndices.includes(index),
  );
  const isComplete = drawnCards.length >= requiredCardCount;
  const progressRatio =
    requiredCardCount === 0 ? 0 : drawnCards.length / requiredCardCount;

  function emitSelection(nextCards: TarotDrawnCard[]) {
    const payload = buildTarotSelectionPayload({
      deckId,
      purpose,
      questionText,
      selectedCards: nextCards,
    });

    onSelectionChange?.(payload);
    return payload;
  }

  function confirmDraw() {
    if (selectedSlotIndex == null || isSubmitting || isComplete) {
      return;
    }

    if (remainingCardIndices.length === 0) {
      return;
    }

    const drawnIndex =
      remainingCardIndices[Math.floor(Math.random() * remainingCardIndices.length)];
    const nextCard: TarotDrawnCard = {
      index: drawnIndex,
      isReversed: false,
      slotIndex: selectedSlotIndex,
    };
    const nextCards = [...drawnCards, nextCard];
    const payload = emitSelection(nextCards);

    setDrawnCards(nextCards);
    setSelectedSlotIndex(null);

    if (nextCards.length >= requiredCardCount) {
      setIsSubmitting(true);
      setTimeout(() => {
        setIsSubmitting(false);
        onComplete?.(payload);
      }, 0);
    }
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      <Card style={{ gap: fortuneTheme.spacing.sm }}>
        <View style={{ gap: 4 }}>
          <AppText variant="heading4">{title}</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {subtitle}
          </AppText>
        </View>

        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={deckId} tone="accent" />
          <Chip
            label={
              purpose === 'love'
                ? '관계 스프레드'
                : requiredCardCount === 5
                  ? '5장 스프레드'
                  : '3카드 스프레드'
            }
            tone="neutral"
          />
          <Chip label={`${drawnCards.length}/${requiredCardCount}`} tone="success" />
        </View>

        <View
          style={{
            backgroundColor: fortuneTheme.colors.backgroundSecondary,
            borderRadius: fortuneTheme.radius.card,
            minHeight: 176,
            overflow: 'hidden',
            padding: fortuneTheme.spacing.sm,
          }}
        >
          <View style={{ flex: 1, position: 'relative' }}>
            {Array.from({ length: slotCount }, (_, slotIndex) => {
              const slotWidth = 80;
              const availableWidth = 1000;
              const left =
                slotCount <= 1
                  ? (availableWidth - slotWidth) / 2
                  : (availableWidth - slotWidth) *
                    (slotIndex / Math.max(slotCount - 1, 1));
              const isSelected = selectedSlotIndex === slotIndex;

              return (
                <Pressable
                  key={slotIndex}
                  accessibilityRole="button"
                  onPress={() => setSelectedSlotIndex(slotIndex)}
                  style={({ pressed }) => ({
                    left,
                    opacity: pressed ? 0.9 : 1,
                    position: 'absolute',
                    top: isSelected ? 0 : 22 + (slotIndex % 3) * 4,
                    transform: [
                      { translateX: -slotWidth / 2 },
                      { rotate: `${-24 + (slotIndex / Math.max(slotCount - 1, 1)) * 48}deg` },
                    ],
                  })}
                >
                  <Card
                    style={{
                      alignItems: 'center',
                      backgroundColor: fortuneTheme.colors.secondaryBackground,
                      borderColor: isSelected
                        ? fortuneTheme.colors.ctaBackground
                        : fortuneTheme.colors.border,
                      borderWidth: isSelected ? 1.5 : 1,
                      height: 132,
                      justifyContent: 'center',
                      paddingHorizontal: 10,
                      paddingVertical: 12,
                      width: slotWidth,
                    }}
                  >
                    <AppText
                      variant="labelSmall"
                      color={fortuneTheme.colors.textSecondary}
                      style={{ textAlign: 'center' }}
                    >
                      {deckId}
                    </AppText>
                    <AppText
                      variant="caption"
                      color={fortuneTheme.colors.textTertiary}
                      style={{ marginTop: 6, textAlign: 'center' }}
                    >
                      SLOT {slotIndex + 1}
                    </AppText>
                    <View
                      style={{
                        backgroundColor: fortuneTheme.colors.chipLavender,
                        borderRadius: fortuneTheme.radius.full,
                        height: 10,
                        marginTop: 16,
                        width: 28,
                      }}
                    />
                  </Card>
                </Pressable>
              );
            })}
          </View>
        </View>

        <View style={{ height: 6, width: '100%' }}>
          <View
            style={{
              backgroundColor: fortuneTheme.colors.ctaBackground,
              borderRadius: fortuneTheme.radius.full,
              height: 6,
              width: `${Math.max(0, Math.min(1, progressRatio)) * 100}%`,
            }}
          />
        </View>

        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {isComplete
            ? '카드가 모두 선택됐어요. 결과 요청을 준비하고 있어요.'
            : selectedSlotIndex == null
              ? '펼쳐진 카드 중 하나를 먼저 골라주세요.'
              : `${positionNames[drawnCards.length] ?? `카드 ${drawnCards.length + 1}`} 자리에 넣을 카드를 확정하세요.`}
        </AppText>

        <PrimaryButton
          disabled={selectedSlotIndex == null || isComplete || isSubmitting}
          onPress={confirmDraw}
        >
          {isComplete
            ? '리딩 준비 완료'
            : selectedSlotIndex == null
              ? '먼저 한 장을 고르세요'
              : `${drawnCards.length + 1}번째 카드 확정`}
        </PrimaryButton>
      </Card>

      {drawnCards.length > 0 ? (
        <Card style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText variant="labelLarge">뽑은 카드</AppText>
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
              {drawnCards.map((card, index) => (
                <View key={`${card.slotIndex}-${card.index}`} style={{ width: 112 }}>
                  <Card
                    style={{
                      backgroundColor: fortuneTheme.colors.surfaceSecondary,
                      alignItems: 'center',
                      justifyContent: 'center',
                      minHeight: 128,
                      paddingVertical: 10,
                    }}
                  >
                    <AppText variant="labelLarge">{card.index}</AppText>
                    <AppText
                      variant="caption"
                      color={fortuneTheme.colors.textSecondary}
                      style={{ marginTop: 4 }}
                    >
                      {positionNames[index] ?? `카드 ${index + 1}`}
                    </AppText>
                    <AppText
                      variant="caption"
                      color={fortuneTheme.colors.textTertiary}
                      style={{ marginTop: 8 }}
                    >
                      {card.isReversed ? '역방향' : '정방향'}
                    </AppText>
                  </Card>
                </View>
              ))}
            </View>
          </ScrollView>
        </Card>
      ) : null}
    </View>
  );
}
