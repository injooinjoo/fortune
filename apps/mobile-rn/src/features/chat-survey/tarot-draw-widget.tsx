import { useCallback, useEffect, useRef, useState } from 'react';

import { Animated, Easing, Pressable, View } from 'react-native';

import { AppText } from '../../components/app-text';
import { PrimaryButton } from '../../components/primary-button';
import { confirmAction } from '../../lib/haptics';
import { fortuneTheme } from '../../lib/theme';

/* -------------------------------------------------------------------------- */
/*  Constants                                                                  */
/* -------------------------------------------------------------------------- */

const TOTAL_SLOTS = 12;
const CARD_WIDTH = 82;
const CARD_HEIGHT = 132;
const FAN_SPREAD_DEG = 50; // total arc (-25 to +25)
const CARD_OVERLAP = 28;
const SELECT_LIFT = 8;

const POSITION_LABELS_3: readonly string[] = ['과거', '현재', '미래'];
const POSITION_LABELS_1: readonly string[] = ['지금'];
const POSITION_COLORS_3: readonly string[] = ['#4FC3F7', '#FFD54F', '#B388FF'];
const POSITION_COLORS_1: readonly string[] = ['#FFD54F'];

/* -------------------------------------------------------------------------- */
/*  Types                                                                      */
/* -------------------------------------------------------------------------- */

interface TarotDrawWidgetProps {
  requiredCount: number; // 1 or 3
  deckName: string;
  deckColors: { primary: string; secondary: string };
  onComplete: (drawnCards: number[]) => void;
}

/* -------------------------------------------------------------------------- */
/*  CardGradient — pure RN faux gradient using layered views                   */
/* -------------------------------------------------------------------------- */

function CardGradient({
  primary,
  secondary,
  style,
  children,
}: {
  primary: string;
  secondary: string;
  style?: object;
  children?: React.ReactNode;
}) {
  return (
    <View style={[{ overflow: 'hidden' }, style]}>
      {/* Base color */}
      <View
        style={{
          ...({ position: 'absolute', top: 0, left: 0, right: 0, bottom: 0 } as const),
          backgroundColor: primary,
        }}
      />
      {/* Diagonal accent — top-right quadrant */}
      <View
        style={{
          position: 'absolute',
          top: 0,
          right: 0,
          width: '70%',
          height: '70%',
          backgroundColor: secondary,
          opacity: 0.35,
          borderBottomLeftRadius: 999,
        }}
      />
      {/* Diagonal accent — bottom-left highlight */}
      <View
        style={{
          position: 'absolute',
          bottom: 0,
          left: 0,
          width: '50%',
          height: '40%',
          backgroundColor: secondary,
          opacity: 0.15,
          borderTopRightRadius: 999,
        }}
      />
      {/* Center glow */}
      <View
        style={{
          position: 'absolute',
          top: '25%',
          left: '15%',
          width: '70%',
          height: '50%',
          backgroundColor: secondary,
          opacity: 0.12,
          borderRadius: 999,
        }}
      />
      {/* Content */}
      <View style={{ flex: 1, zIndex: 1 }}>{children}</View>
    </View>
  );
}

/* -------------------------------------------------------------------------- */
/*  Fan card position helpers                                                  */
/* -------------------------------------------------------------------------- */

function computeFanRotation(index: number, total: number): number {
  if (total <= 1) return 0;
  const halfSpread = FAN_SPREAD_DEG / 2;
  return -halfSpread + (index / (total - 1)) * FAN_SPREAD_DEG;
}

function computeFanTranslateY(index: number, total: number): number {
  // parabolic curve so outer cards sit higher
  const center = (total - 1) / 2;
  const dist = Math.abs(index - center) / center; // 0..1
  return dist * dist * 18; // max 18px rise at edges
}

function computeFanTranslateX(index: number, total: number, containerWidth: number): number {
  const totalCardsWidth = total * (CARD_WIDTH - CARD_OVERLAP) + CARD_OVERLAP;
  const startX = (containerWidth - totalCardsWidth) / 2;
  return startX + index * (CARD_WIDTH - CARD_OVERLAP);
}

/* -------------------------------------------------------------------------- */
/*  AnimatedFanCard                                                            */
/* -------------------------------------------------------------------------- */

function AnimatedFanCard({
  index,
  total,
  containerWidth,
  isSelected,
  isDrawn,
  deckColors,
  onPress,
}: {
  index: number;
  total: number;
  containerWidth: number;
  isSelected: boolean;
  isDrawn: boolean;
  deckColors: { primary: string; secondary: string };
  onPress: () => void;
}) {
  const liftAnim = useRef(new Animated.Value(0)).current;
  const opacityAnim = useRef(new Animated.Value(1)).current;

  useEffect(() => {
    Animated.spring(liftAnim, {
      toValue: isSelected ? 1 : 0,
      tension: 180,
      friction: 12,
      useNativeDriver: true,
    }).start();
  }, [isSelected, liftAnim]);

  useEffect(() => {
    if (isDrawn) {
      Animated.timing(opacityAnim, {
        toValue: 0.15,
        duration: 400,
        easing: Easing.out(Easing.ease),
        useNativeDriver: true,
      }).start();
    }
  }, [isDrawn, opacityAnim]);

  const rotation = computeFanRotation(index, total);
  const baseTranslateY = computeFanTranslateY(index, total);
  const translateX = computeFanTranslateX(index, total, containerWidth);

  const animatedTranslateY = liftAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [baseTranslateY, baseTranslateY - SELECT_LIFT],
  });

  const glowOpacity = liftAnim.interpolate({
    inputRange: [0, 1],
    outputRange: [0, 1],
  });

  return (
    <Animated.View
      style={{
        position: 'absolute',
        left: translateX,
        top: 20,
        width: CARD_WIDTH,
        height: CARD_HEIGHT,
        opacity: opacityAnim,
        transform: [
          { translateY: animatedTranslateY },
          { rotate: `${rotation}deg` },
        ],
        zIndex: isSelected ? 100 : index,
      }}
    >
      <Pressable
        accessibilityRole="button"
        accessibilityLabel={`카드 ${index + 1}`}
        disabled={isDrawn}
        onPress={onPress}
        style={({ pressed }) => ({
          width: CARD_WIDTH,
          height: CARD_HEIGHT,
          borderRadius: fortuneTheme.radius.md,
          overflow: 'hidden',
          opacity: pressed && !isDrawn ? 0.88 : 1,
        })}
      >
        {/* Glow border when selected */}
        <Animated.View
          style={{
            position: 'absolute',
            top: -2,
            left: -2,
            right: -2,
            bottom: -2,
            borderRadius: fortuneTheme.radius.md + 2,
            borderWidth: 2,
            borderColor: deckColors.secondary,
            opacity: glowOpacity,
            shadowColor: deckColors.secondary,
            shadowOpacity: 0.6,
            shadowRadius: 10,
            shadowOffset: { width: 0, height: 0 },
          }}
        />

        {/* Card back face */}
        <CardGradient
          primary={deckColors.primary}
          secondary={deckColors.secondary}
          style={{
            flex: 1,
            borderRadius: fortuneTheme.radius.md,
            borderWidth: 1,
            borderColor: 'rgba(255,255,255,0.12)',
          }}
        >
          <View
            style={{
              flex: 1,
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            {/* Inner border pattern */}
            <View
              style={{
                width: CARD_WIDTH - 14,
                height: CARD_HEIGHT - 14,
                borderRadius: fortuneTheme.radius.sm,
                borderWidth: 1,
                borderColor: 'rgba(255,255,255,0.15)',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <AppText
                variant="heading2"
                style={{ color: 'rgba(255,255,255,0.7)', textAlign: 'center' }}
              >
                ✦
              </AppText>
            </View>
          </View>
        </CardGradient>
      </Pressable>
    </Animated.View>
  );
}

/* -------------------------------------------------------------------------- */
/*  DrawnCardSlot                                                              */
/* -------------------------------------------------------------------------- */

function DrawnCardSlot({
  cardNumber,
  positionLabel,
  accentColor,
  deckColors,
}: {
  cardNumber: number;
  positionLabel: string;
  accentColor: string;
  deckColors: { primary: string; secondary: string };
}) {
  const scaleAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.spring(scaleAnim, {
      toValue: 1,
      tension: 120,
      friction: 8,
      useNativeDriver: true,
    }).start();
  }, [scaleAnim]);

  return (
    <Animated.View
      style={{
        alignItems: 'center',
        gap: 6,
        transform: [{ scale: scaleAnim }],
      }}
    >
      {/* Mini card */}
      <CardGradient
        primary={deckColors.primary}
        secondary={deckColors.secondary}
        style={{
          width: 56,
          height: 84,
          borderRadius: fortuneTheme.radius.sm,
          borderWidth: 2,
          borderColor: accentColor,
          shadowColor: accentColor,
          shadowOpacity: 0.4,
          shadowRadius: 8,
          shadowOffset: { width: 0, height: 2 },
        }}
      >
        <View style={{ flex: 1, alignItems: 'center', justifyContent: 'center' }}>
          <AppText
            variant="heading3"
            style={{ color: '#FFFFFF', fontWeight: '800' }}
          >
            {cardNumber}
          </AppText>
        </View>
      </CardGradient>

      {/* Position label */}
      <View
        style={{
          backgroundColor: accentColor + '22',
          borderRadius: fortuneTheme.radius.full,
          paddingHorizontal: 10,
          paddingVertical: 3,
        }}
      >
        <AppText variant="caption" style={{ color: accentColor, fontWeight: '600' }}>
          {positionLabel}
        </AppText>
      </View>
    </Animated.View>
  );
}

/* -------------------------------------------------------------------------- */
/*  ProgressBar                                                                */
/* -------------------------------------------------------------------------- */

function GradientProgressBar({
  progress,
  deckColors,
}: {
  progress: number; // 0..1
  deckColors: { primary: string; secondary: string };
}) {
  const widthAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(widthAnim, {
      toValue: progress,
      duration: 400,
      easing: Easing.out(Easing.ease),
      useNativeDriver: false, // width animation needs layout driver
    }).start();
  }, [progress, widthAnim]);

  return (
    <View
      style={{
        height: 3,
        backgroundColor: 'rgba(255,255,255,0.08)',
        borderRadius: 2,
        overflow: 'hidden',
      }}
    >
      <Animated.View
        style={{
          height: '100%',
          borderRadius: 2,
          backgroundColor: deckColors.secondary,
          width: widthAnim.interpolate({
            inputRange: [0, 1],
            outputRange: ['0%', '100%'],
          }),
        }}
      />
    </View>
  );
}

/* -------------------------------------------------------------------------- */
/*  TarotDrawWidget (main export)                                              */
/* -------------------------------------------------------------------------- */

export function TarotDrawWidget({
  requiredCount,
  deckName,
  deckColors,
  onComplete,
}: TarotDrawWidgetProps) {
  const [selectedSlot, setSelectedSlot] = useState<number | null>(null);
  const [drawnCards, setDrawnCards] = useState<number[]>([]);
  const completedRef = useRef(false);

  const positionLabels = requiredCount === 3 ? POSITION_LABELS_3 : POSITION_LABELS_1;
  const positionColors = requiredCount === 3 ? POSITION_COLORS_3 : POSITION_COLORS_1;
  const spreadLabel = requiredCount === 1 ? '1카드 드로우' : `${requiredCount}카드 스프레드`;
  const progress = drawnCards.length / requiredCount;

  // Fan container width: computed from card count
  const fanContainerWidth =
    TOTAL_SLOTS * (CARD_WIDTH - CARD_OVERLAP) + CARD_OVERLAP + 40;

  const handleCardTap = useCallback(
    (slotIndex: number) => {
      if (drawnCards.includes(slotIndex)) return;
      setSelectedSlot((prev) => (prev === slotIndex ? null : slotIndex));
      confirmAction();
    },
    [drawnCards],
  );

  const handleConfirm = useCallback(() => {
    if (selectedSlot === null) return;
    if (drawnCards.includes(selectedSlot)) return;
    if (drawnCards.length >= requiredCount) return;

    const nextDrawn = [...drawnCards, selectedSlot];
    setDrawnCards(nextDrawn);
    setSelectedSlot(null);
    confirmAction();

    // Auto-complete when all cards drawn
    if (nextDrawn.length >= requiredCount && !completedRef.current) {
      completedRef.current = true;
      setTimeout(() => {
        onComplete(nextDrawn.map((i) => i + 1)); // 1-indexed card numbers
      }, 300);
    }
  }, [selectedSlot, drawnCards, requiredCount, onComplete]);

  const isAllDrawn = drawnCards.length >= requiredCount;

  return (
    <View style={{ gap: 16, paddingBottom: 8 }}>
      {/* ---- Status bar ---- */}
      <View style={{ gap: 8 }}>
        <View
          style={{
            flexDirection: 'row',
            alignItems: 'center',
            gap: 8,
            flexWrap: 'wrap',
          }}
        >
          {/* Deck name pill */}
          <View
            style={{
              backgroundColor: deckColors.primary + 'CC',
              borderRadius: fortuneTheme.radius.full,
              paddingHorizontal: 12,
              paddingVertical: 5,
              borderWidth: 1,
              borderColor: deckColors.secondary + '44',
            }}
          >
            <AppText variant="caption" style={{ color: deckColors.secondary, fontWeight: '700' }}>
              {deckName} 덱
            </AppText>
          </View>

          {/* Spread type pill */}
          <View
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: fortuneTheme.radius.full,
              paddingHorizontal: 12,
              paddingVertical: 5,
              borderWidth: 1,
              borderColor: fortuneTheme.colors.border,
            }}
          >
            <AppText variant="caption" style={{ color: fortuneTheme.colors.textSecondary }}>
              {spreadLabel}
            </AppText>
          </View>

          {/* Progress counter */}
          <View
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: fortuneTheme.radius.full,
              paddingHorizontal: 12,
              paddingVertical: 5,
              borderWidth: 1,
              borderColor: fortuneTheme.colors.border,
            }}
          >
            <AppText variant="caption" style={{ color: fortuneTheme.colors.textSecondary }}>
              {drawnCards.length}/{requiredCount}
            </AppText>
          </View>
        </View>

        {/* Progress bar */}
        <GradientProgressBar progress={progress} deckColors={deckColors} />
      </View>

      {/* ---- Fan layout ---- */}
      <View
        style={{
          height: CARD_HEIGHT + 50,
          overflow: 'visible',
          alignSelf: 'center',
          width: fanContainerWidth,
        }}
      >
        {Array.from({ length: TOTAL_SLOTS }).map((_, i) => (
          <AnimatedFanCard
            key={i}
            index={i}
            total={TOTAL_SLOTS}
            containerWidth={fanContainerWidth}
            isSelected={selectedSlot === i}
            isDrawn={drawnCards.includes(i)}
            deckColors={deckColors}
            onPress={() => handleCardTap(i)}
          />
        ))}
      </View>

      {/* ---- Instruction / Confirm button ---- */}
      {!isAllDrawn && (
        <View style={{ alignItems: 'center', gap: 8 }}>
          {selectedSlot !== null ? (
            <PrimaryButton onPress={handleConfirm}>
              카드 확정
            </PrimaryButton>
          ) : (
            <AppText
              variant="labelSmall"
              style={{
                color: fortuneTheme.colors.textTertiary,
                textAlign: 'center',
              }}
            >
              마음이 가는 카드를 터치하세요
            </AppText>
          )}
        </View>
      )}

      {/* ---- Drawn cards row ---- */}
      {drawnCards.length > 0 && (
        <View
          style={{
            flexDirection: 'row',
            justifyContent: 'center',
            gap: 20,
            paddingTop: 4,
          }}
        >
          {drawnCards.map((slotIndex, drawOrder) => (
            <DrawnCardSlot
              key={slotIndex}
              cardNumber={slotIndex + 1}
              positionLabel={positionLabels[drawOrder] ?? `#${drawOrder + 1}`}
              accentColor={positionColors[drawOrder] ?? '#FFFFFF'}
              deckColors={deckColors}
            />
          ))}
        </View>
      )}

      {/* ---- Completion message ---- */}
      {isAllDrawn && (
        <View style={{ alignItems: 'center', paddingTop: 4 }}>
          <AppText
            variant="labelMedium"
            style={{
              color: deckColors.secondary,
              textAlign: 'center',
              fontWeight: '600',
            }}
          >
            카드가 모두 펼쳐졌어요. 해석을 준비할게요...
          </AppText>
        </View>
      )}
    </View>
  );
}
